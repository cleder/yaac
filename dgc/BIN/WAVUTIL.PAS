{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stability and must be 
 used at your own risk.
} 

unit WavUtil;

interface

uses Classes, SysUtils, Windows, MMSystem;

const
     ERR_NOTAWAVE = 'Not a wave file';
     ERR_READING = 'Error reading wave file';
     ERR_CORRUPT = 'Corrupt Wave File';

type
  //The following records have been copied from the MMSystem unit and
  //modified. The 'Packed' declaration were missing and caused the mmio
  //functions to fill them in wrong. For some reason the original structures
  //work okay when passed to DirectSound????
  TDGCWaveFormat = packed record
    wFormatTag: Word;         { format type }
    nChannels: Word;          { number of channels (i.e. mono, stereo, etc.) }
    nSamplesPerSec: DWORD;  { sample rate }
    nAvgBytesPerSec: DWORD; { for buffer estimation }
    nBlockAlign: Word;      { block size of data }
  end;

  TDGCPCMWaveFormat = packed record
      wf: TDGCWaveFormat;
      wBitsPerSample: Word;
   end;

  TDGCWaveFormatEx =  packed record
    wFormatTag: Word;         { format type }
    nChannels: Word;          { number of channels (i.e. mono, stereo, etc.) }
    nSamplesPerSec: DWORD;  { sample rate }
    nAvgBytesPerSec: DWORD; { for buffer estimation }
    nBlockAlign: Word;      { block size of data }
    wBitsPerSample: Word;   { number of bits per sample of mono data }
    cbSize: Word;           { the count in bytes of the size of }
  end;
  PDGCWaveFormatEx = ^TDGCWaveFormatEx;

  //Sound Library headers
  TSndLibHeader = record
       IDent: array[0..3] of Char;
       WaveCount: Integer;
  end;

   //Image Structure
  TSndLibSound = record
       Format: TWaveFormatEx;
       Name: String[8];
       Pan: Integer;
       Volume: Integer;
       Size: Integer;
       Data: PChar;
  end;
  PSndLibSound = ^TSndLibSound;
  TSndLibSoundList = array[0..0] of TSndLibSound;
  PSndLibSoundList = ^TSndLibSoundList;


  //TDGCWave Class
  TDGCWave = class(TObject)
  private
    { Private declarations }
    Fppwfxinfo: PDGCWaveFormatEx;
    FFileName: String;
    FSampleSize: Integer;
    FWaveFormatSize: Integer;
    FSamples: DWord;
    FSampleData: PChar;
    function WaveOpenFile(FileName: String; var ppwfxInfo: PDGCWaveFormatEx;
            var pckInRiff: TMMCKInfo; var WaveFormatSize: Integer): HMMIO;
    procedure WaveStartDataRead(var hmmioIn: HMMIO; var pckIn: TMMCKInfo;
            var pckInRiff: TMMCKInfo);
    function WaveReadFile(var hmmioIn:HMMIO; cbRead: Integer; pbDest: PChar;
            var pckIn: TMMCKInfo): Integer;
    function WaveLoadFile(FileName: String; var cbSize: Integer;
      var cSamples: DWord; var ppwfxInfo: PDGCWaveFormatEx; var ppbData: PChar): Integer;
    function GetSampleRate: Integer;
    function GetChannels: Integer;
    function GetBitsPerSample: Integer;
  public
    { Public declarations }
    constructor Create(FileName: String);
    destructor Destroy; override;
    procedure SaveRawSample(FileName: String);
    procedure GetWaveFormat(var WaveFormat: TWaveFormatEx);
    property Size: Integer read FSampleSize;
    property Samples: Integer read FSamples;
    property Data: PChar read FSampleData;
    property SampleRate: Integer  read GetSampleRate;
    property Channels: Integer read GetChannels;
    property BitsPerSample: Integer read GetBitsPerSample;
  end;



implementation

constructor TDGCWave.Create(FileName: String);
begin
     FFileName := FileName;
     FSamples := 0;
     FSampleSize := 0;
     FWaveFormatSize := WaveLoadFile(FileName, FSampleSize, FSamples, FppwfxInfo,
                FSampleData);
end;

destructor TDGCWave.Destroy;
begin
     if FSampleData <> nil then
        FreeMem(FSampleData, FSampleSize);
     if FppwfxInfo <> nil then
        FreeMem(fppwfxInfo, FWaveFormatSize);
     inherited Destroy;
end;

function TDGCWave.WaveOpenFile(FileName: String; var ppwfxInfo: PDGCWaveFormatEx;
            var pckInRiff: TMMCKInfo; var WaveFormatSize: Integer): HMMIO;
var
   hmmioIn: HMMIO;
   ckIn: TMMCKInfo;
   pcmWaveFormat: TDGCPCMWaveFormat;
   cbExtraAlloc: Word;
   nError: Integer;
   DataPtr: PChar;
begin
     //Open the file
     hmmioIn := 0;
     ppwfxInfo := nil;
     hmmioIn := mmioOpen(PChar(FileName), nil, MMIO_ALLOCBUF or MMIO_READ);
     if hmmioIn = 0 then
        raise Exception.Create('mmioOpen Failed');
     try
        //Is it a WAV?
        if mmioDescend(hmmioIn, @pckInRiff, nil, 0) <> 0 then
           raise Exception.Create('mmioDescend Failed');
        if (pckInRiff.cKid <> FOURCC_RIFF) or
           (pckInRiff.fccType <> mmioStringToFOURCC('WAVE', 0)) then
           raise Exception.Create(ERR_NOTAWAVE);

        //Find the Format chunk
        ckIn.ckId := mmioStringToFOURCC('fmt ', 0);
        if mmioDescend(hmmioIn, @ckIn, @pckInRiff, MMIO_FINDCHUNK) <> 0 then
           raise Exception.Create(ERR_READING);
        if ckIn.ckSize < SizeOf(TDGCPCMWaveFormat) then
           raise Exception.Create(ERR_NOTAWAVE);

        //Read the Format Chunk
        if mmioRead(hmmioIN, @pcmWaveFormat, SizeOf(TDGCPCMWaveFormat)) <>
           SizeOf(TDGCPCMWaveFormat) then
           raise Exception.Create(ERR_READING);

        //Allocate nmemory for Format Info. If the wave is not a PCM then
        //read the next word and that how many extra bytes to allocate
        if pcmWaveFormat.wf.wFormatTag = WAVE_FORMAT_PCM then
           cbExtraAlloc := 0
        else
        begin
             if mmioRead(hmmioIn, @cbExtraAlloc, SizeOf(cbExtraAlloc)) <>
                SizeOF(cbExtraAlloc) then
                raise Exception.Create(ERR_READING);
        end;

        //Allocate the memory
        WaveFormatSize := SizeOF(TDGCWaveFormatEx) + cbExtraAlloc;
        GetMem(ppwfxInfo, WaveFormatSize);
        if ppwfxInfo = nil then
           raise Exception.Create('Failed to allocate memory');

        //Copy the bytes from the pcm Structure to the waveformatex structure
        Move(pcmWaveFormat, ppwfxInfo^, SizeoF(TDGCPCMWaveFormat));
        ppwfxInfo^.cbSize := cbExtraAlloc;

        //Read in the extra bytes into the structire if cbExtraAlloc <> 0]
        if cbExtraAlloc <> 0 then
        begin
             DataPtr := PChar(ppwfxInfo) +  SizeOf(TDGCWaveFormatEx);
             if mmioRead(hmmioIn, DataPtr, cbExtraAlloc) <> cbExtraAlloc then
                raise Exception.Create(ERR_NOTAWAVE);
        end;

        //Ascend the input file out of the 'fmt ' chunk.
        if mmioAscend(hmmioIn, @ckIn, 0) <> 0 then
           raise Exception.Create(ERR_READING);

        //Done
        Result := hmmioIn;
     except
           if ppwfxInfo <> nil then
           begin
              FreeMem(ppwfxInfo, WaveFormatSize);
              ppwfxInfo := nil;
           end;
           if hmmioIn <> 0 then
           begin
              mmioClose(hmmioIn, 0);
              hmmioIn := 0;
           end;
           raise;
     end;
end;

function TDGCWave.WaveLoadFile(FileName: String; var cbSize: Integer;
           var cSamples: DWord; var ppwfxInfo: PDGCWaveFormatEx; var ppbData: PChar): Integer;
var
   hmmioIn: HMMIO;
   ckInRiff: TMMCKInfo;
   ckIn: TMMCKInfo;
   cbActualRead: Integer;
   DataSize: Integer;
   WaveFormatSize: Integer;
begin
     ppbData := nil;
     ppwfxInfo := nil;
     hmmioIn := 0;
     Result := 0;
     hmmioIN := WaveOpenFile(FileName, ppwfxInfo, ckInRiff, WaveFormatSize);
     try
        WaveStartDataRead(hmmioIN, ckIn, ckInRiff);
        DataSize := ckIn.ckSize;
        GetMem(ppbData, DataSize);
        cbSize := WaveReadFile(hmmioIn, DataSize, ppbData, ckIn);
     except
           if ppbData <> nil then
           begin
              FreeMem(ppbData, DataSize);
              ppbData := nil;
           end;
           if ppwfxInfo <> nil then
           begin
                FreeMem(ppwfxInfo, WaveFormatSize);
                ppwfxInfo := nil;
           end;
     end;
     Result := WaveFormatSize;
end;

procedure TDGCWave.WaveStartDataRead(var hmmioIn: HMMIO; var pckIn: TMMCKInfo;
            var pckInRiff: TMMCKInfo);
begin
     //Seek
     if mmioSeek(hmmioIn, pckInRiff.dwDataOffSet + SizeOF(FOURCC), SEEK_SET) = -1 then
        raise Exception.Create(ERR_READING);

     //Search the input file for the data chunk
     pckIn.ckId := mmioStringToFOURCC('data', 0);
     if mmioDescend(hmmioIn, @pckIn, @pckInRiff, MMIO_FINDCHUNK) <> 0 then
        raise Exception.Create(ERR_READING);
end;

function TDGCWave.WaveReadFile(var hmmioIn:HMMIO; cbRead: Integer; pbDest: PChar;
            var pckIn: TMMCKInfo): Integer;
var
   mmioinfoIn: TMMIOInfo;
   ct, cbDataIn: integer;
begin
     Result := 0; //Default to nothing read

     if mmioGetInfo(hmmioIn, @mmioinfoIn, 0) <> 0 then
        raise Exception.Create(ERR_READING);

     cbDataIn := cbread;
     if cbDataIn > pckIn.ckSize then
        cbDataIn := pckIn.ckSize;

     Dec(pckIn.ckSize, cbDataIn);

     for ct := 0 to cbDataIn - 1 do
     begin
          //copy the bytes s from the io to the byffer
          if mmioInfoIn.pchNext = mmioInfoIn.pchEndRead then
          begin
               if mmioAdvance(hmmioIn, @mmioinfoIn, MMIO_READ) <> 0 then
                  raise Exception.Create(ERR_READING);
               if mmioInfoIn.pchNext = mmioInfoIn.pchEndRead then
                  raise Exception.Create(ERR_CORRUPT);
          end;
          (pbDest + ct)^ := mmioInfoIn.pchNext^;
          Inc(mmioInfoIn.pchNext);
     end;
     if mmioSetInfo(hmmioIn, @mmioInfoIn, 0) <> 0 then
        raise Exception.Create(ERR_READING);
     Result := cbDataIn;
end;

function TDGCWave.GetSampleRate: Integer;
begin
     if FppwfxInfo = nil then
        Result := 0
     else
         Result := FppwfxInfo^.nSamplesPerSec;
end;

function TDGCWave.GetChannels: Integer;
begin
     if FppwfxInfo = nil then
        Result := 0
     else
         Result := FppwfxInfo^.nChannels;
end;

function TDGCWave.GetBitsPerSample: Integer;
begin
     if FppwfxInfo = nil then
        Result := 0
     else
         Result := FppwfxInfo^.wBitsPerSample;
end;

procedure TDGCWave.SaveRawSample(FileName: String);
var
   f: File;
begin
     if FSampleData = nil then exit;
     AssignFile(f, FileName);
     Rewrite(f, 1);
     Blockwrite(f, FSampleData^, FSampleSize);
     CloseFile(f);
end;

//This methid is needed as 'packed' was missed off of the TWaveFormatEx
//structure (see note at top of program).
procedure TDGCWave.GetWaveFormat(var WaveFormat: TWaveFormatEx);
begin
     with WaveFormat do
     begin
          wFormatTag := Fppwfxinfo^.wFormatTag;
          nChannels := Fppwfxinfo^.nChannels;
          nSamplesPerSec := Fppwfxinfo^.nSamplesPerSec;
          nAvgBytesPerSec := Fppwfxinfo^.nAvgBytesPerSec;
          nBlockAlign := Fppwfxinfo^.nBlockAlign;
          wBitsPerSample := Fppwfxinfo^.wBitsPerSample;
          cbSize := Fppwfxinfo^.cbSize;
     end;
end;

end.
