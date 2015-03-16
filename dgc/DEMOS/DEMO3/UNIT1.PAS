{The Delphi Games Creator Demo Program
 -------------------------------------
 This demo shows how to use images from the Image Library component and
 demonstrates collision detection and keyboard handling.
}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DGC, DGCILib;

type
  TForm1 = class(TForm)
    DGCScreen1: TDGCScreen;
    DGCImageLib1: TDGCImageLib;
    procedure DGCScreen1Initialize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DGCScreen1Flip(Sender: TObject);
    procedure DGCScreen1Paint(Sender: TObject);
  private
    { Private declarations }
    x, y, xvel, yvel: Integer;
    px: Integer;
    KillDuration: Integer;
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

     //Copy the Front surface to the back buffer so
     //both surfaces contain the same info
     DGCScreen1.Back.BltFast(0, 0, DGCScreen1.Front, DGCScreen1.Front.ClientRect, False);

     //Initialise the image attributes (for my crude bounce code)
     x := 150;
     y := 200;
     px := 100;
     yvel := 1;
     xvel := 2;
     KillDuration := 0;

     //Now Start the page flipping
     DGCScreen1.FlippingEnabled := True;
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
          TextOut(130, 150, 'Simple collision detection demo. Use arrow keys');
          TextOut(160, 170, 'to move the ship. Press Escape to Quit');
          Font.Color := clWhite;
          Font.Size := 8;
          TextOut(0, 467, 'Sprites by Ari Feldman');
          Release; //This must be called to release the device context.
     end;
end;

procedure TForm1.DGCScreen1Flip(Sender: TObject);
var
   ShipHit: Boolean;
begin
     //Erase the area theat the sprite will bounce in
     DGCScreen1.Back.EraseRect(Rect(0, 200, 640, 468), 0);

     //Now Draw the Sprite
     DGCScreen1.Back.Draw(x, y, DGCScreen1.Images[0], True);

     //Update the Images X position
     Inc(x, xvel);
     if (x < 0) or (x > 500) then
        xvel := -xvel;

     //Update the y position using yvel
     Inc(y, yvel);

     //Uncrease the Velocity and make sure it is in a range
     Inc(yvel);
     if yvel > 18 then yvel := 18;
     if yvel < -18 then yvel := -18;

     //If the image has reached the bottom then reverse direction
     if y > 380 then
     begin
          y := 380;
          yvel := -yvel;
     end;

     //Draw and update the players ship based on a collision test.
     //Image[0] = Invader, Image[1] = Players Ship. If the collision
     //test is True then draw the all white ship (Images[2]) otherwise
     //draw the normal ship (Images[1])
     if DGCScreen1.Images[0].CollisionTest(x, y, DGCScreen1.Images[1],
        px, 450, True) then
        Killduration := 10;

     if KillDuration > 0 then
     begin
        DGCScreen1.Back.Draw(px, 430, DGCScreen1.Images[2], True);
        Dec(KillDuration);
     end
     else
        DGCScreen1.Back.Draw(px, 430, DGCScreen1.Images[1], True);



     //Update the Ship position based on the arrow keys
     if (DGCScreen1.KeyDown(VK_LEFT)) and (px > 2) then
        Dec(px, 2)
     else
         if (DGCScreen1.KeyDown(VK_RIGHT)) and (px < 605) then
            Inc(px, 2);
end;

procedure TForm1.DGCScreen1Paint(Sender: TObject);
begin
     //The paint event should only be called when surfaces are lost. This
     //can be caused when application switching with ALT+TAB.
     DrawFrame;
     DGCScreen1.Flip;
     DrawFrame;
end;

end.
