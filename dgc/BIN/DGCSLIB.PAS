{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit dgcslib;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DsgnIntf, WavUtil;

const
     SoundLibID = 'SL10';

type
  //Sound Library Storage Class
  TDGCSounds = class(TPersistent)
  private
    { Private declarations }
    function GetSoundData(Index: Integer): TSndLibSound;
    function GetCount: Integer;
  protected
    { Protected declarations }
    procedure DefineProperties(Filer: TFiler); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    { Public declarations }
    SndHeader: TSndLibHeader;
    FSounds: PSndLibSoundList;
    procedure FreeSounds;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property SoundData[Index: Integer]: TSndLibSound read GetSoundData;
    property SoundList: PSndLibSoundList read FSounds;
    property Count: Integer read GetCount;
    property Header: TSndLibHeader read SndHeader;
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: String);
  end;

  //Property Editor Class
  TDGCOpenSndLibProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes : TPropertyAttributes; override;
    function GetValue : string; override;
  end;

  //Main Class
  TDGCSoundLib = class(TComponent)
  private
    { Private declarations }
    FSounds: TDGCSounds;
    FFileName: String;
    function GetSoundCount: Integer;
    procedure SetSounds(NewVal: TDGCSounds);
    function GetIsFileLibrary: Boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: String);
    procedure ReLoadFromFile;
    property SoundCount: Integer read GetSoundCount;
    property IsFileLibrary: Boolean read GetIsFileLibrary;
  published
    { Published declarations }
    property Sounds: TDGCSounds read FSounds write SetSounds;
  end;

implementation

uses dgcslo;

//TDGCSoundLib Implementation
//===========================
constructor TDGCSoundLib.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FFileName := '';
     FSounds := TDGCSounds.Create;
end;

destructor TDGCSoundLib.Destroy;
begin
     FSounds.Free;
     inherited Destroy;
end;

procedure TDGCSoundLib.SetSounds(NewVal: TDGCSounds);
begin
     FSounds.Assign(NewVal);
end;

function TDGCSoundLib.GetSoundCount: Integer;
begin
     if Assigned(FSounds) then
        Result := FSounds.Header.WaveCount
     else
         Result := 0;
end;

procedure TDGCSoundLib.LoadFromFile(FileName: String);
begin
     FFileName := '';
     FSounds.LoadFromFile(FileName);
     FFileName := FileName;
end;

function TDGCSoundLib.GetIsFileLibrary: Boolean;
begin
     Result := FFileName <> '';
end;

procedure TDGCSoundLib.ReLoadFromFile;
begin
     if FFileName = '' then
        raise Exception.Create('LoadFromFile must be called first');
     LoadFromFile(FFileName);
end;

//TDGCSounds Implementation
//==========================
constructor TDGCSounds.Create;
begin
     inherited Create;
     FSounds := nil;
end;

destructor TDGCSounds.Destroy;
begin
     FreeSounds;
     inherited Destroy;
end;

procedure TDGCSounds.LoadFromStream(Stream: TStream);
var
   n: Integer;
   Sound: TSndLibSound;
begin
     //Read Header
     FreeSounds; //Remove current sound list if there is one
     Stream.ReadBuffer(SndHeader, SizeOf(SndHeader));
     if StrLIComp(PChar(SoundLibID), SndHeader.Ident, 4) <> 0 then
        raise Exception.Create('Not a valid Sound Library File');
     GetMem(FSounds, SndHeader.WaveCount * SizeOF(TSndLibSound));
     if FSounds = nil then
        raise Exception.Create('TDGCSounds: GemMem Failed for FSounds');
     for n := 0 to SndHeader.WaveCount - 1 do
     begin
          Sound := FSounds^[n];
          //Read Sound Header
          Stream.ReadBuffer(Sound, SizeOf(TSndLibSound) - SizeOf(PChar));
          //Alocate memory for sound data and read
          GetMem(Sound.Data, Sound.Size);
          if Sound.Data = nil then
             raise Exception.Create('TDGCSounds: GemMem Failed for Sound.Data');
         Stream.ReadBuffer(Sound.Data^, Sound.Size);
         FSounds^[n] := Sound;
     end;
end;

procedure TDGCSounds.SaveToStream(Stream: TStream);
var
   n: Integer;
   Sound: TSndLibSound;
begin
     Stream.WriteBuffer(SndHeader, SizeOf(SndHeader));
     for n := 0 to SndHeader.WaveCount - 1 do
     begin
          Sound := FSounds^[n];
          //write sound Header
          Stream.WriteBuffer(Sound, SizeOf(TSndLibSound) - SizeOf(PChar));
          //Write sound data
          Stream.WriteBuffer(Sound.Data^, Sound.Size);
     end;
end;

procedure TDGCSounds.DefineProperties(Filer: TFiler);

    function HasSounds: Boolean;
    begin
         if FSounds <> nil then
            Result := True
         else
             Result := False;
    end;
begin
     inherited DefineProperties(Filer);
     Filer.DefineBinaryProperty('Sounds', LoadFromStream, SaveToStream, HasSounds);
end;

//Free the specified Sound from the list box item idx
procedure TDGCSounds.FreeSounds;
var
   Sound: TSndLibSound;
   idx: Integer;
begin
     if FSounds = nil then exit;
     for idx := 0 to SndHeader.WaveCount - 1 do
     begin
          Sound := FSounds^[idx];
          if Sound.Data <> nil then
             FreeMem(Sound.Data, Sound.Size);
     end;
     FreeMem(FSounds, SndHeader.WaveCount * SizeOF(TSndLibSound));
     FSounds := nil;
     SndHeader.WaveCount := 0;
end;

procedure TDGCSounds.LoadFromFile(FileName: String);
var
   Stream: TFileStream;
begin
     Stream := TFileStream.Create(FileName, fmOpenRead);
     LoadFromStream(Stream);
     Stream.Free;
end;

function TDGCSounds.GetSoundData(Index: Integer): TSndLibSound;
begin
     Result := FSounds^[Index];
end;

function TDGCSounds.GetCount: Integer;
begin
     Result := SndHeader.WaveCount;
end;

procedure TDGCSounds.AssignTo(Dest: TPersistent);
var
   I: TDGCSounds;
   SoundSize: Integer;
   n: Integer;
   Sound: TSndLibSound;
   Ilist: PSndLibSoundList;
begin
     //Copy Header
     if Dest is TDGCSounds then
     begin
          //Remove any sounds already loaded
          I := TDGCSounds(Dest);
          I.FreeSounds;
          if SndHeader.WaveCount = 0 then
             exit;
          //Move header
          I.SndHeader := SndHeader;
          //Allocate Memory for SoundList
          SoundSize := I.SndHeader.WaveCount * SizeOF(TSndLibSound);
          GetMem(IList, SoundSize);
          if IList = nil then
             raise Exception.Create('TDGCSounds.AssignTo failed (GetMem): ' + IntToStr(SoundSize));
          I.FSounds := IList;
          //Copy the data
          for n := 0 to I.SndHeader.WaveCount - 1 do
          begin
               Sound := FSounds^[n];
               SoundSize := Sound.Size;
               GetMem(Sound.Data, SoundSize);
               if Sound.Data = nil then
                  raise Exception.Create('TDGCSounds.AssignTo failed');
               Move(FSounds^[n].Data^, Sound.Data^, SoundSize);
               I.FSounds^[n] := Sound;
          end;
          exit;
     end;
     inherited AssignTo(Dest);
end;

//Propery Editor Implemantation
function TDGCOpenSndLibProperty.GetAttributes : TPropertyAttributes;
begin
  Result := [ paDialog ];
end;

//TDGCOpenLibProperty Implemenataion
function TDGCOpenSndLibProperty.GetValue : string;
begin
  Result := '(TDGCSounds)';
end;

procedure TDGCOpenSndLibProperty.Edit;
var
   I: TDGCSounds;
begin
     //This bit i'm not too sure about. The following code works
     //but other propert editors do not have to do the assign
     //they just call the GetOrdValue and SetOrdValue methods
     //???????
     frmOpenSndLib := TfrmOpenSndLib.Create(Application);
     I := TDGCSounds(GetOrdValue);
     frmOpenSndLib.Sounds.Assign(I);
     if frmOpenSndLib.ShowModal = mrOK then
     begin
          SetOrdValue(LongInt(I));
          I.Assign(frmOpenSndLib.Sounds);
     end;
     frmOpenSndLib.Free;
end;

end.
