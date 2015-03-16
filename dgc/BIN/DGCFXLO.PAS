{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 


unit Dgcfxlo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, DGCfxLib;

type
  TfrmOpenIntroLib = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    Panel1: TPanel;
    btnLoad: TButton;
    OpenDialog1: TOpenDialog;
    PaintBox1: TPaintBox;
    ScrollBar1: TScrollBar;
    Bevel2: TBevel;
    Panel2: TPanel;
    IndexPanel: TPanel;
    NamePanel: TPanel;
    WidthPanel: TPanel;
    HeightPanel: TPanel;
    EffectPanel: TPanel;
    SpeedPanel: TPanel;
    HoldPanel: TPanel;
    procedure btnLoadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Init;
    procedure ScrollBar1Change(Sender: TObject);
  private
    { Private declarations }
    FImages: TDGCIntros;
    procedure ShowLibImage(idx: Integer);
    procedure DrawImage;
    procedure ErasePaintBox;
  public
    { Public declarations }
    Bmp: TBitmap;
    LastWidth, LastHeight: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Images: TDGCIntros read FImages write FImages;
  end;

var
  frmOpenIntroLib: TfrmOpenIntroLib;

implementation

uses BmpUtil;

{$R *.DFM}

constructor TfrmOpenIntroLib.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     LastWidth := 0;
     LastHeight := 0;
     Bmp := TBitmap.Create;
     FImages := TDGCIntros.Create;
end;

destructor TfrmOpenIntroLib.Destroy;
begin
     Bmp.Free;
     FImages.Free;
     inherited Destroy;
end;

procedure TfrmOpenIntroLib.btnLoadClick(Sender: TObject);
begin
     if OpenDialog1.Execute then
     begin
          Images.LoadFromFile(OpenDialog1.FileName);
          Init;
          if Images.Header.ImageCount > 0 then
             ScrollBar1Change(Self);
     end;
end;


procedure TfrmOpenIntroLib.FormShow(Sender: TObject);
begin
     Init;
end;

procedure TfrmOpenIntroLib.DrawImage;
begin
     if not Bmp.Empty then
     begin
          if (Bmp.Width > PaintBox1.Width) or (Bmp.Height > PaintBox1.Height) then
             PaintBox1.Canvas.StretchDraw(PaintBox1.ClientRect, Bmp)
          else
          begin
               if (LastWidth <> Bmp.Width) or (LastHeight <> Bmp.Height) then
                  ErasePaintBox;
               PaintBox1.Canvas.Draw((PaintBox1.Width div 2) - (Bmp.Width div 2),
                 (PaintBox1.Height div 2) - (Bmp.Height div 2), Bmp);
          end;
          LastWidth := Bmp.Width;
          LastHeight := Bmp.Height;
     end
     else
         ErasePaintBox; //No library loaded so erase the paint box
end;

procedure TfrmOpenIntroLib.ErasePaintBox;
begin
     with PaintBox1.Canvas do
     begin
          Brush.Color := clBlack;
          Brush.Style := bsDiagCross;
          Pen.Color := clWhite;
          FillRect(PaintBox1.ClientRect);
          Brush.Style := bsSolid;
     end;
end;

procedure TfrmOpenIntroLib.PaintBox1Paint(Sender: TObject);
begin
     ErasePaintBox;
     DrawImage;
end;

procedure TfrmOpenIntroLib.ShowLibImage(idx: Integer);
var
   BmpInfo: PBitmapInfo;
   HeaderSize: Integer;
   ImgHdr: TIntroLibImage;
   Palette: TImgLibPalette;
begin
     ImgHdr := Images.ImageData[idx];
     HeaderSize := SizeOf(TBitmapInfo) + (256 * SizeOf(TRGBQuad));
     BmpInfo := AllocMem(HeaderSize);
     //First Get Colours
     Palette := Images.Header.Palette;
     ImgLibPalToBmpInfo(Palette, BmpInfo);
     with BmpInfo^.bmiHeader do
     begin
          biSize := SizeOf(TBitmapInfoHeader);
          biWidth := ImgHdr.Width;
          biHeight := -ImgHdr.Height;
          biPlanes := 1;
          biBitCount := 8; //always convert to 8 bit image
          biCompression := BI_RGB;
          biClrUsed := 0;
          biClrImportant := 0;
     end;
     CreateDIB256(Bmp, BmpInfo, ImgHdr.Bits);

     //CleanUp
     FreeMem(BmpInfo, HeaderSize);
     DrawImage;
end;

procedure TfrmOpenIntroLib.Init;
begin
     if Images.Header.ImageCount = 0 then
        ScrollBar1.Enabled := False
     else
     begin
          ScrollBar1.Position := 0;
          ScrollBar1.Max := Images.Header.ImageCount - 1;
     end;
     Panel2.Caption := Format('Image Count: %d', [Images.Header.ImageCount]);
     if ScrollBar1.Enabled then
        ScrollBar1Change(Self);
     LastWidth := 0;
     LastHeight := 0;
     DrawImage;
end;

procedure TfrmOpenIntroLib.ScrollBar1Change(Sender: TObject);
begin
     ShowLibImage(ScrollBar1.Position);
     IndexPanel.Caption := Format('Index: %d', [ScrollBar1.Position]);
     with Images.ImageData[ScrollBar1.Position] do
     begin
          NamePanel.Caption := Format('Name: %s', [Name]);
          WidthPanel.Caption := Format('Width: %d', [Width]);
          HeightPanel.Caption := Format('Height: %d', [Height]);
          EffectPanel.Caption := Format('Effect: %d',[ord(Effect)]);
          SpeedPanel.Caption := Format('Speed: %d',[Speed]);
          HoldPanel.Caption := Format('Hold: %d',[Hold]);
     end;
end;

end.
