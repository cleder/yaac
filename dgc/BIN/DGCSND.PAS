{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit DGCSnd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DSound, MMSystem, DGCSLib;

type

  //TDGCSoundBuffer class
  TDGCSoundBuffer = class(TObject)
  private
    { Private declarations }
    SoundBuffer: IDirectSoundBuffer;
    FOnRestoreBuffer: TNotifyEvent;
    FSize: Integer;
    FChannels: Integer;
    FBitsPerSample: Integer;
    procedure RestoreBuffer;
    function GetVolume: LongInt;
    procedure SetVolume(NewVal: LongInt);
    function GetPan: LongInt;
    procedure SetPan(NewVal: LongInt);
    function GetFrequency: DWord;
    procedure SetFrequency(NewVal: DWord);
    function GetPosition: DWord;
    procedure SetPosition(NewVal: DWord);
    function GetPlaying: Boolean;
  public
    { Public declarations }
    constructor Create(DirectSound: IDirectSound; FileName: String);
    constructor CreateMemory(DirectSound: IDirectSound; WaveFormat:
         TWaveFormatEx; Size: Integer; Data: PChar);
    destructor Destroy; override;
    procedure Play;
    procedure Replay;
    procedure PlayLoop;
    procedure Stop;
    property Size: Integer read FSize;
    property Channels: Integer read FChannels;
    property BitsPersample: Integer read FBitsPerSample;
    property OnRestoreBuffer: TNotifyEvent read FOnRestoreBuffer write FOnRestoreBuffer;
    property Volume: LongInt read GetVolume write SetVolume;
    property Pan: LongInt read GetPan write SetPan;
    property Frequency: DWord read GetFrequency write SetFrequency;
    property Position: DWord read GetPosition write SetPosition;
    property Playing: Boolean read GetPlaying;
  end;

  //Surface Image List
  TDGCSoundBufferList = array[0..0] of TDGCSoundBuffer;
  PDGCSoundBufferList = ^TDGCSoundBufferList;

  //TDGCSound Component
  TDGCAudio = class(TComponent)
  private
    { Private declarations }
    FDirectSound: IDirectSound;
    FDGCSoundLib: TDGCSoundLib;
    FSoundList: PDGCSoundBufferList;
    FSoundListCount: Integer;
    procedure CreateSoundBuffers;
    procedure FreeSoundBuffers;
    procedure SetSoundLib(NewLib: TDGCSoundLib);
    procedure RestoreBuffers(Sender: TObject);
    function GetSound(Index: Integer): TDGCSoundBuffer;
  protected
    { Protected declarations }
     procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitDirectSound;
    property DirectSound: IDirectSound read FDirectSound;
    property Sound[Index: Integer]: TDGCSoundBuffer read GetSound; default;
  published
    { Published declarations }
   property SoundLibrary: TDGCSoundLib read FDGCSoundLib write SetSoundLib;
 end;


implementation

uses WavUtil, dgc;

constructor TDGCAudio.Create(AOwner: TComponent);
var
   n: Integer;
begin
     inherited Create(AOwner);
     FDirectSound := nil;
     //If a DirectDraw component exists then it must
     //be initialized first (Why I don't know)
     for n := 0 to Owner.ComponentCount - 1 do
         if Owner.Components[n] is TDGCScreen then
            exit;
     InitDirectSound;
end;

destructor TDGCAudio.Destroy;
begin
     if FSoundList <> nil then
        FreeSoundBuffers;
     if FDirectSound <> nil then
          FDirectSound.Release;
     inherited Destroy;
end;

procedure TDGCAudio.InitDirectSound;
begin
     if DirectSoundCreate(nil, FDirectSound, nil) <> DS_OK then
        raise Exception.Create('Failed to Create DirectSound');
     if FDirectSound.SetCooperativeLevel(Application.Handle, DSSCL_NORMAL) <> DS_OK then
        Raise Exception.Create('Failed to set directsound copoperative level');
     //Create sound buffers if sound buffer assigned
     FSoundList := nil;
     if (SoundLibrary <> nil) and not (csDesigning in ComponentState) then
        CreateSoundBuffers;
end;

procedure TDGCAudio.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
       if FDGCSoundLib = AComponent then
          FDGCSoundLib := nil;
  end;
end;

procedure TDGCAudio.CreateSoundBuffers;
var
   n: Integer;
begin
     if FDGCSoundLib = nil then exit;
     if FDGCSoundLib.SoundCount = 0 then exit;
     FSoundListCount := FDGCSoundLib.SoundCount;
     GetMem(FSoundList, FSoundListCount * SizeOf(TDGCSoundBuffer));
     if FSoundList = nil then
        raise Exception.Create('Failed to allocate memory for Sound Buffers');
     for n := 0 to FSoundListCount - 1 do
     begin
          //Create and instance of a TDGCSoundBuffer
          with FDGCSoundLib.Sounds.SoundData[n] do
          begin
               FSoundList^[n] := TDGCSoundBuffer.CreateMemory(FDirectSound,
                   Format, Size, Data);
               FSoundList^[n].Pan:= Pan;
               FSoundList^[n].Volume:= Volume;
               FSoundList^[n].OnRestoreBuffer := RestoreBuffers;
          end;
     end;
     //If Sound Library samples were loaded from file then
     //free them
     if FDGCSoundLib.IsFileLibrary then
        FDGCSoundLib.Sounds.FreeSounds;
end;

procedure TDGCAudio.FreeSoundBuffers;
var
   n: Integer;
begin
     if FSoundList = nil then exit;
     for n := 0 to FSoundListCount - 1 do
     begin
          FSoundList^[n].Free;
     end;
     FreeMem(FSoundList, FSoundListCount * SizeOf(TDGCSoundBuffer));
     FSoundList := nil;
end;

procedure TDGCAudio.SetSoundLib(NewLib: TDGCSoundLib);
begin
     FreeSoundBuffers;
     FDGCSoundLib := NewLib;
     if not (csDesigning in ComponentState) and (FDirectSound <> nil) then
        CreateSoundBuffers;
end;

procedure TDGCAudio.RestoreBuffers(Sender: TObject);
begin
     FreeSoundBuffers;
     if FDGCSoundLib.IsFileLibrary then
        FDGCSoundLib.ReLoadFromFile;
     CreateSoundBuffers;
end;

function TDGCAudio.GetSound(Index: Integer): TDGCSoundBuffer;
begin
     if FSoundList = nil then
        raise Exception.Create('A library must be assigned to SoundLibrary');
     Result := FSoundList^[Index];
end;

//TDGCSoundBuffer Implementation
constructor TDGCSoundBuffer.Create(DirectSound: IDirectSound; FileName: String);
var
   w: TDGCWave;
   wf: TWaveFormatEx;
   Data1, Data2: PChar;
   Data1Size, Data2Size: DWord;
   BufferDesc: DSBUFFERDESC ;
begin
     SoundBuffer := nil;
     FSize := 0;
     FChannels := 0;
     FBitsPerSample := 0;
     //Load the wave file
     w := TDGCWave.Create(FileName);
     try
        //Create the sound buffer and copy the data
        w.GetWaveFormat(wf);
        ZeroMemory(@BufferDesc, SizeOf(BufferDesc));
        BufferDesc.dwSize := sizeof ( DSBUFFERDESC ) ;
        BufferDesc.dwFlags := DSBCAPS_STATIC + DSBCAPS_CTRLDEFAULT;
        BufferDesc.dwBufferBytes := w.Size;
        BufferDesc.lpwfxFormat := @wf;
        if DirectSound.CreateSoundBuffer(BufferDesc, SoundBuffer, nil ) <> DS_OK then
           raise Exception.Create('CreateSoundBuffer Failed');
        try
           //Lock the wave file
           if SoundBuffer.Lock(0, w.Size, Pointer(Data1), Data1Size, Pointer(Data2),
              Data2Size, 0) <> DS_OK then
              raise Exception.Create('DirectSoundSurface Lock Failed');
           //Move Data
           Move(w.Data^, Data1^, Data1Size);
           //UnLock
           SoundBuffer.UnLock(Pointer(Data1), Data1Size, Pointer(Data2), Data2Size);
        except
              SoundBuffer.Release;
              SoundBuffer := nil;
              raise;
        end;
     finally
       FSize := w.Size;
       FBitsPerSample := w.BitsPerSample;
       FChannels := w.Channels;
       w.Free;
     end;
end;

destructor TDGCSoundBuffer.Destroy;
begin
     if SoundBuffer <> nil then
     begin
        Stop;
        SoundBuffer.Release;
     end;
     inherited Destroy;
end;

procedure TDGCSoundBuffer.Play;
var
   r: Hresult;
begin
     //Stop;
     r := SoundBuffer.Play(0, 0, 0);
     if r <> DS_OK then
        if r =  DSERR_BUFFERLOST then
           RestoreBuffer
        else
            raise Exception.Create('Play Failed');
end;

procedure TDGCSoundBuffer.RePlay;
begin
     Stop;
     Position := 0;
     Play;
end;

procedure TDGCSoundBuffer.PlayLoop;
var
   r: Hresult;
begin
     Stop;
     r := SoundBuffer.Play(0, 0, DSBPLAY_LOOPING);
     if r <> DS_OK then
        if r =  DSERR_BUFFERLOST then
           RestoreBuffer
        else
            raise Exception.Create('Play Failed');
end;

procedure TDGCSoundBuffer.Stop;
begin
     if SoundBuffer.Stop <> DS_OK then
        raise Exception.Create('Stop Failed');
end;

procedure TDGCSoundBuffer.RestoreBuffer;
begin
     SoundBuffer.Restore;
     if Assigned(FOnRestoreBuffer) then
        FOnRestoreBuffer(Self);
end;

procedure TDGCSoundBuffer.SetVolume(NewVal: LongInt);
begin
     if SoundBuffer.SetVolume(NewVal) <> DS_OK then
        raise Exception.Create('SetVolume Failed');
end;

function TDGCSoundBuffer.GetVolume: LongInt;
var
   v: LongInt;
begin
     if SoundBuffer.GetVolume(v) <> DS_OK then
        raise Exception.Create('GetVolume Failed');
     Result := v;
end;

procedure TDGCSoundBuffer.SetPan(NewVal: LongInt);
begin
     if SoundBuffer.SetPan(NewVal) <> DS_OK then
        raise Exception.Create('SetPan Failed');
end;

function TDGCSoundBuffer.GetPan: LongInt;
var
   v: LongInt;
begin
     if SoundBuffer.GetPan(v) <> DS_OK then
        raise Exception.Create('GetPan Failed');
     Result := v;
end;

procedure TDGCSoundBuffer.SetFrequency(NewVal: DWord);
begin
     if SoundBuffer.SetFrequency(NewVal) <> DS_OK then
        raise Exception.Create('SetFrequency Failed');
end;

function TDGCSoundBuffer.GetFrequency: DWord;
var
   v: DWord;
begin
     if SoundBuffer.GetFrequency(v) <> DS_OK then
        raise Exception.Create('GetFrequency Failed');
     Result := v;
end;

procedure TDGCSoundBuffer.SetPosition(NewVal: DWord);
begin
     if SoundBuffer.SetCurrentPosition(NewVal) <> DS_OK then
        raise Exception.Create('SetPosition Failed');
end;

function TDGCSoundBuffer.GetPosition: DWord;
var
   ReadPos, WritePos: DWord;
begin
     if SoundBuffer.GetCurrentPosition(ReadPos, WritePos) <> DS_OK then
        raise Exception.Create('GetPosition Failed');
     Result := ReadPos;
end;

function TDGCSoundBuffer.GetPlaying: Boolean;
var
   v: DWord;
begin
     if SoundBuffer.GetStatus(v) <> DS_OK then
        raise Exception.Create('GetFrequency Failed');
     Result := (v = DSBSTATUS_PLAYING);
end;

constructor TDGCSoundBuffer.CreateMemory(DirectSound: IDirectSound; WaveFormat:
    TWaveFormatEx; Size: Integer; Data: PChar);
var
   wf: TWaveFormatEx;
   Data1, Data2: PChar;
   Data1Size, Data2Size: DWord;
   BufferDesc: DSBUFFERDESC ;
begin
     wf := WaveFormat;
     ZeroMemory(@BufferDesc, SizeOf(BufferDesc));
     BufferDesc.dwSize := sizeof ( DSBUFFERDESC ) ;
     BufferDesc.dwFlags := DSBCAPS_STATIC + DSBCAPS_CTRLDEFAULT;
     BufferDesc.dwBufferBytes := Size;
     BufferDesc.lpwfxFormat := @wf;
     if DirectSound.CreateSoundBuffer(BufferDesc, SoundBuffer, nil ) <> DS_OK then
        raise Exception.Create('CreateSoundBuffer Failed');
     try
        //Lock the wave file
        if SoundBuffer.Lock(0, Size, Pointer(Data1), Data1Size, Pointer(Data2),
           Data2Size, 0) <> DS_OK then
           raise Exception.Create('DirectSoundSurface Lock Failed');
        //Move Data
        Move(Data^, Data1^, Data1Size);
        //UnLock
        SoundBuffer.UnLock(Pointer(Data1), Data1Size, Pointer(Data2), Data2Size);
     except
           SoundBuffer.Release;
           SoundBuffer := nil;
           raise;
     end;
     FSize := Size;
     FBitsPerSample := WaveFormat.wBitsPerSample;
     FChannels := WaveFormat.nChannels;
     //if Loaded from file then free the sounds
end;


end.
