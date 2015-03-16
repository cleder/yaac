{The Delphi Games Creator Demo Program
 -------------------------------------
 This is a simple demo that shows the use the trasition effects
 component and the FX editor. The intdem.crl file contains the
 bitmaps and effects options that make up the slideshow. This file
 is loaded at run-time and can be changed using the FXLIB.EXE 
 program (located in the dgc\bin directory).
}

unit Unit1;

interface

// Include BmpUtil for fade type definitions
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Dgcfxlib,BMPUtil, DGC;

type
  TForm1 = class(TForm)
    DGCScreen1: TDGCScreen;
    DGCIntroLib1: TDGCIntroLib;
    procedure DGCScreen1Initialize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure DrawFrame;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.DGCScreen1Initialize(Sender: TObject);
begin
     // set Introlib filename and path to the applications path
     DGCIntroLib1.Filename:=Extractfilepath(Application.ExeName)+'\intdem.crl';
     // Play The intro Screens
     DGCIntroLib1.Play;
     // Draw something on the background screen
     DrawFrame;
     // Make it appear using some effect
     // Parameters (DGCSurface,EffectType,Transition time(secs),HoldTime
     // note for effect type you need to include BmpUtil in the uses clause
     DGCIntroLib1.AppearSurface(DGCScreen1.Back,SlideRight,5,0);
end;

Procedure TForm1.DrawFrame;
begin
     with DGCScreen1.Back.Canvas do
     begin
          Brush.Style:=BsClear;
          Font.Size := 14;
          Font.Color := rgb(255,255,255);
          TextOut(((DGCScreen1.Back.Width div 2) - (TextWidth('Press Escape To Return To Windows') div 2)) ,240 , 'Press Escape to Return to Windows');
          Release;
     end;
end;


procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
      if key = #27 then
         close;
end;

end.
