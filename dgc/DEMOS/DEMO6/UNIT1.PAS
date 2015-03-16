{The Delphi Games Creator Demo Program
 -------------------------------------
 This is a simple demo that shows the use of the TDGCRace car
 sprite class. For the rotation of the car to be smoother all
 32 directions must be used.
 }

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dgcspts, DGCILib, DGC;

type
  TForm1 = class(TForm)
    DGCScreen1: TDGCScreen;
    DGCImageLib1: TDGCImageLib;
    DGCSpriteMgr1: TDGCSpriteMgr;
    procedure DGCScreen1Initialize(Sender: TObject);
    procedure DGCScreen1Flip(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.DGCScreen1Initialize(Sender: TObject);
begin
     //Add car animation
     DGCSpriteMgr1.Animations.Add('car', True);
     with DGCSpriteMgr1.Animations[0] do
     begin
          SetFrames(0, 100, [0]);
          SetFrames(2, 100, [1]);
          SetFrames(4, 100, [2]);
          SetFrames(6, 100, [3]);
          SetFrames(8, 100, [4]);
          SetFrames(10, 100, [5]);
          SetFrames(12, 100, [6]);
          SetFrames(14, 100, [7]);
          SetFrames(16, 100, [8]);
          SetFrames(18, 100, [9]);
          SetFrames(20, 100, [10]);
          SetFrames(22, 100, [11]);
          SetFrames(24, 100, [12]);
          SetFrames(26, 100, [13]);
          SetFrames(28, 100, [14]);
          SetFrames(30, 100, [15]);
     end;

     //Add cone animation
     DGCSpriteMgr1.Animations.Add('Cone', True);
     with DGCSpriteMgr1.Animations[1] do
     begin
          SetAllDirections(100, [17]);
     end;

     //Add spinning cone animation
     DGCSpriteMgr1.Animations.Add('SpinCone', True);
     with DGCSpriteMgr1.Animations[2] do
     begin
          SetAllDirections(60, [17,18,19,20]);
     end;

     //Add car sprite
     DGCSpriteMgr1.Sprites.AddRaceCar(0, 320, 360, 8, 4, 0);
     with DGCSpriteMgr1.Sprites[0] as TDGCRaceCar do
     begin
          AllActions := laStopInside;
          Handling := 50; //try changing this value < 50 = better handling
                          //Also try changing Acceleration/Decelleration
     end;

     //Add some cones
     DGCSpriteMgr1.Sprites.AddBouncer(1, 70, 320, 0, 0, 1);
     DGCSpriteMgr1.Sprites.AddBouncer(1, 320, 70, 0, 0, 1);
     DGCSpriteMgr1.Sprites.AddBouncer(1, 80, 100, 0, 0, 1);
     DGCSpriteMgr1.Sprites.AddBouncer(1, 280, 120, 0, 0, 1);
     DGCSpriteMgr1.Sprites.AddBouncer(1, 550, 160, 0, 0, 1);
     DGCSpriteMgr1.Sprites.AddBouncer(1, 520, 290, 0, 0, 1);
end;

procedure TForm1.DGCScreen1Flip(Sender: TObject);
var
   sx, sy, n: Integer;
begin
     //Draw background image
     DGCScreen1.Back.Draw(0, 0, DGCScreen1.Images[16], False);

     //Update the sprites but save car x, y in case hit side of track
     with DGCSpriteMgr1.Sprites[0] do
     begin
          sx := x;
          sy := y;
          DGCSpriteMgr1.Update;
          if DGCScreen1.Back.CollisionTest(0, 0, DGCScreen1.Images[Frame],
              X, Y, True) then
          begin
               X := sx;
               Y := sy;
               Speed := 0;
          end;
      end;

      //check for collisions with cones
      for n := 1 to Pred(DGCSpriteMgr1.Sprites.Count) do
      begin
           if DGCSpriteMgr1.Sprites.Collision(n, 0) then
           begin
                with DGCSpriteMgr1.Sprites[n] do
                begin
                     //Send cone off in direction of car
                     MaxSpeed := 5;
                     Speed := 5;
                     Direction := DGCSpriteMgr1.Sprites[0].Direction;
                     Animation := 2;
                     AllActions := laStopOutSide;
                end;
                break;
           end;
      end;

      //Draw sprites
      DGCSpriteMgr1.Draw;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = #27 then Close;
end;

end.
