{The Delphi Games Creator Demo Program
 -------------------------------------
 This simple demo shows how the standard Delphi TCanvas class
 is used with DirectDraw surfaces. This demo also uses
 palette fade functions.
}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DGC;

type
  TForm1 = class(TForm)
    DGCScreen1: TDGCScreen;
    procedure DGCScreen1Initialize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DGCScreen1Paint(Sender: TObject);
  private
    { Private declarations }
    procedure DrawFrame;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.DGCScreen1Initialize(Sender: TObject);
begin
     //Draw stuff on the hidden surface
     DrawFrame;

     //Quickly fade palette to black
     DGCScreen1.FadePaletteOut(1);

     //Flip the hidden surface with the visible one so you can
     //see it on the screen - but you can't see it yet cause the
     //palette is still black???
     DGCScreen1.Flip;

     //Finally Smoothly fade the palette in
     DGCScreen1.FadePaletteIn(100);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
     //If the escape key is pressed fade the palette out and
     //Close the demo
     if Key = #27 then
     begin
          DGCScreen1.FadePaletteOut(100);
          Close;
     end;
end;

procedure TForm1.DrawFrame;
var
   n: Integer;
begin
     with DGCScreen1.Back.Canvas do
     begin
          Brush.Style := bsClear;
          Font.Size := 24;
          Font.Color := clBlue;
          TextOut(110, 60, 'The Delphi Games Creator');
          Font.Color := clTeal;
          TextOut(108, 58, 'The Delphi Games Creator');
          Font.Size := 12;
          Font.Color := clYellow;
          TextOut(110, 150, 'This is a simple demo to show how the standard Delphi ');
          TextOut(130, 170, 'TCanvas class is used with DirectDraw surfaces.');
          for n := 0 to 100 do
          begin
               Brush.Color := RGB(Random(255), Random(255), Random(255));
               FillRect(Rect(n, 250 + n, 640 - n, 480 - n));
          end;
          Font.Color := clRed;
          TextOut(225, 355, 'Press Escape to Quit');
          Release; //This must be called to release the device context.
     end;
end;

procedure TForm1.DGCScreen1Paint(Sender: TObject);
begin
     //The paint event should only be called when surfaces are lost. This
     //can be caused when application switching with ALT+TAB.
     DrawFrame;
     DGCScreen1.Flip;
end;

end.
