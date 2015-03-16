unit DGCTrace;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus;

type
  TCopyData = record
      dwData: LongInt;
      cbData: LongInt;
      lpData: Pointer;
  end;
  PCopyData = ^TCopyData;

  TfrmDGCTrace = class(TForm)
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    Memo1: TMemo;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    Help1: TMenuItem;
    mnuAbout: TMenuItem;
    SaveDialog1: TSaveDialog;
    mnuSaveDebugOutput: TMenuItem;
    mnuEdit: TMenuItem;
    mnuCopy: TMenuItem;
    N2: TMenuItem;
    mnuClearBuffer: TMenuItem;
    mnuSelectAll: TMenuItem;
    mnuOptions: TMenuItem;
    mnuAlwaysOnTop: TMenuItem;
    mnuBeep: TMenuItem;
    procedure mnuExitClick(Sender: TObject);
    procedure mnuSaveDebugOutputClick(Sender: TObject);
    procedure mnuCopyClick(Sender: TObject);
    procedure mnuClearBufferClick(Sender: TObject);
    procedure mnuAlwaysOnTopClick(Sender: TObject);
    procedure mnuSelectAllClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuBeepClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMCopyData(var Msg: TMessage); message WM_COPYDATA;
  public
    { Public declarations }
  end;

var
  frmDGCTrace: TfrmDGCTrace;

implementation

uses about;

{$R *.DFM}

procedure TfrmDGCTrace.WMCopyData(var Msg: TMessage);
var
   CopyData: PCopyData;
begin
     CopyData := PCopyData(Msg.LParam);
     Memo1.Lines.Add(StrPas(CopyData^.lpData));
     if mnuBeep.Checked then
        MessageBeep(0);
end;

procedure TfrmDGCTrace.mnuExitClick(Sender: TObject);
begin
     Application.Terminate;
end;

procedure TfrmDGCTrace.mnuSaveDebugOutputClick(Sender: TObject);
begin
     if not SaveDialog1.Execute then
        exit;
     Memo1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrmDGCTrace.mnuCopyClick(Sender: TObject);
begin
     Memo1.CopyToClipBoard;
end;

procedure TfrmDGCTrace.mnuClearBufferClick(Sender: TObject);
begin
     Memo1.Lines.Clear;
end;

procedure TfrmDGCTrace.mnuAlwaysOnTopClick(Sender: TObject);
begin
     mnuAlwaysOnTop.Checked := not mnuAlwaysOnTop.Checked;
     if mnuAlwaysOnTop.Checked then
        FormStyle := fsStayOnTop
     else
         FormStyle := fsNormal;
end;

procedure TfrmDGCTrace.mnuSelectAllClick(Sender: TObject);
begin
     Memo1.SelectAll;
end;

procedure TfrmDGCTrace.mnuAboutClick(Sender: TObject);
begin
     frmAbout := TfrmAbout.Create(Self);
     frmAbout.ShowModal;
     frmAbout.Free;
end;

procedure TfrmDGCTrace.mnuBeepClick(Sender: TObject);
begin
     mnuBeep.Checked := not mnuBeep.Checked;
end;

end.
