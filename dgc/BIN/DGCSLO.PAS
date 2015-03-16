{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit dgcslo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, DGCSLib, DGCSnd;

type
  TfrmOpenSndLib = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    btnLoad: TButton;
    OpenDialog1: TOpenDialog;
    Bevel2: TBevel;
    IndexPanel: TPanel;
    NamePanel: TPanel;
    SizePanel: TPanel;
    FrequencyPanel: TPanel;
    ListBox1: TListBox;
    ChannelsPanel: TPanel;
    BPSPanel: TPanel;
    btnPlay: TButton;
    btnStop: TButton;
    chkLoop: TCheckBox;
    DGCAudio1: TDGCAudio;
    procedure btnLoadClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    FSounds: TDGCSounds;
    PlayWave: TDGCSoundBuffer;
    procedure SetListBox;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Sounds: TDGCSounds read FSounds write FSounds;
  end;

var
  frmOpenSndLib: TfrmOpenSndLib;

implementation

uses WavUtil;

{$R *.DFM}

constructor TfrmOpenSndLib.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FSounds := TDGCSounds.Create;
end;

destructor TfrmOpenSndLib.Destroy;
begin
     FSounds.Free;
     inherited Destroy;
end;

procedure TfrmOpenSndLib.btnLoadClick(Sender: TObject);
var
   n: Integer;
begin
     if OpenDialog1.Execute then
     begin
          Sounds.LoadFromFile(OpenDialog1.FileName);
          SetListBox;
     end;
end;


procedure TfrmOpenSndLib.ListBox1Click(Sender: TObject);
var
   Sound: TSndLibSound;
begin
     Sound := Sounds.SoundData[ListBox1.ItemIndex];
     NamePanel.Caption := Format('Name: %s', [Sound.Name]);
     IndexPanel.Caption := Format('Index: %d', [ListBox1.ItemIndex]);
     SizePanel.Caption := Format('Size: %d', [Sound.Size]);
     FrequencyPanel.Caption := Format('Frequency: %d', [Sound.Format.nSamplesPerSec]);
     ChannelsPanel.Caption := Format('Size: %d', [Sound.Format.nChannels]);
     BPSPanel.Caption := Format('BPS: %d', [Sound.Format.wBitsPerSample]);
     btnPlay.Enabled := True;
     btnStop.Enabled := True;
end;

procedure TfrmOpenSndLib.SetListBox;
var
   n: Integer;
begin
     ListBox1.Clear;
     for n := 0 to Sounds.Count - 1 do
         ListBox1.Items.Add(Sounds.SoundData[n].Name);
     if Sounds.Count > 0 then
     begin
        ListBox1.ItemIndex := 0;
        ListBox1Click(Self);
     end;
end;

procedure TfrmOpenSndLib.FormShow(Sender: TObject);
begin
     SetListBox;
end;

procedure TfrmOpenSndLib.FormDestroy(Sender: TObject);
begin
     if PlayWave <> nil then
        PlayWave.Free;
end;

procedure TfrmOpenSndLib.btnPlayClick(Sender: TObject);
var
   Wave: TDGCWave;
   Sound: TSndLibSound;
   idx: Integer;
begin
     idx := ListBox1.ItemIndex;
     if idx < 0 then exit;
     Sound := Sounds.SoundData[idx];
     if PlayWave <> nil then
        PlayWave.Free;
     PlayWave := TDGCSoundBuffer.CreateMemory(DGCAudio1.DirectSound,
              Sound.Format, Sound.Size, Sound.Data);
     PlayWave.Pan:= Sound.Pan;
     PlayWave.Volume := Sound.Volume;
     if chkLoop.Checked then
        PlayWave.PlayLoop
     else
        PlayWave.Play;
end;

procedure TfrmOpenSndLib.btnStopClick(Sender: TObject);
begin
     PlayWave.Stop;
end;

end.
