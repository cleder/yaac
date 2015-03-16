{The Delphi Games Creator Demo Program
 -------------------------------------
This demo shows how to create a simple shoot-em-up. There is no
scoring, sound and the player can't event die but you will
probably be impressed with how little code there is. Use the
arrow keys to move the sprite and Ctrl to file.
Note: The TDGCStarField component uses palette entries 240-244 to
      color the stars. 244 is the brightest star and 240 is the
      dimest. These palette entries can be set using the Image
      Library Editor and reloading the .IML file into the
      Image Library component (the .IML files do not come withe the
      demos though).
}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dgcspts, DGCILib, DGC, DGCStar;

type
  TForm1 = class(TForm)
    DGCScreen1: TDGCScreen;
    DGCImageLib1: TDGCImageLib;
    DGCSpriteMgr1: TDGCSpriteMgr;
    DGCStarField1: TDGCStarField;
    procedure DGCScreen1Initialize(Sender: TObject);
    procedure DGCScreen1Flip(Sender: TObject);
    procedure DGCSpriteMgr1SpriteStopped(Sprite: TDGCSprite;
      LimitsSide: TLimitsSide);
    procedure DGCSpriteMgr1AnimationEnd(Sprite: TDGCSprite);
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
var
   n: Integer;
begin
     //Add the enemy animation
     DGCSpriteMgr1.Animations.Add('8WayShip', True);
     with DGCSpriteMgr1.Animations[0] do
     begin
          SetFrames(0, 100, [14]);
          SetFrames(4, 100, [15]);
          SetFrames(8, 100, [8]);
          SetFrames(12, 100, [9]);
          SetFrames(16, 100, [10]);
          SetFrames(20, 100, [11]);
          SetFrames(24, 100, [12]);
          SetFrames(28, 100, [13]);
     end;

     //Add the Player Animatiom
     DGCSpriteMgr1.Animations.Add('Player', True);
     DGCSpriteMgr1.Animations[1].SetAllDirections(100, [0,1,2]);

     //Add Spinning Enemy Animation
     DGCSpriteMgr1.Animations.Add('SpinEnmy', True);
     DGCSpriteMgr1.Animations[2].SetAllDirections(50, [14,15,8,9,10,11,12,13]);

     //Add Bullet Animation
     DGCSpriteMgr1.Animations.Add('Bullet', True);
     DGCSpriteMgr1.Animations[3].SetAllDirections(100, [3]);

     //Add Explosion Animation - The loop is set to false
     //so the OnAnimationEnd event is fired
     DGCSpriteMgr1.Animations.Add('Explode', False);
     DGCSpriteMgr1.Animations[4].SetAllDirections(100, [4,5,6,7]);

     //Add Player Sprite - ID=0;
     DGCSpriteMgr1.Sprites.AddPlayer8(0, 320, 440, 0, 3, 1);
     with DGCSpriteMgr1.Sprites[0] as TDGCPlayer8 do
     begin
          Acceleration := 0.10;  //Try making this a smaller value
          Decceleration := 0.10; //Try making this a smaller value
          AllowUp := False;
          AllowDown := False;
     end;

     //Add Player Bullet -  ID=1
     DGCSpriteMgr1.Sprites.AddBouncer(1, 0, 0, 0, 5, 3);
     with DGCSpriteMgr1.Sprites[1] do
     begin
          Disable;
          Hide;
          AllActions := laStopOutside;
     end;


     //Add Enemy Sprites ID = 2, n * 4 = Direction from 0-31;
     for n := 0 to 7 do
     begin
          DGCSpriteMgr1.Sprites.AddBouncer(2, 320, 220, n * 4, 2, 0);
     end;

     //Initialise Starfield
     DGCStarfield1.Generate;

end;

procedure TForm1.DGCScreen1Flip(Sender: TObject);
var
   n: Integer;
begin
     DGCScreen1.Back.Erase(0); //Completely Erase Background
     DGCStarfield1.Update;     //Draw the starfield
     DGCSpriteMgr1.Draw;       //Draw the sprites
     DGCSpriteMgr1.Update;     //Update sprite positions for next time

     //Allow player to fire at enemy
     if DGCScreen1.KeyDown(VK_CONTROL) and not DGCSpriteMgr1.Sprites[1].Enabled then
     begin
          with DGCSpriteMgr1.Sprites[1] do
          begin
               X := DGCSpriteMgr1.Sprites[0].X + 15;
               Y := DGCSpriteMgr1.Sprites[0].Y;
               Enable;
               Show;
          end;
     end;

     //Check for Collisions with the bullet and enemy
     //only if bullet enabled;
     if DGCSpriteMgr1.Sprites[1].Enabled then
     begin
          for n := 2 to Pred(DGCSpriteMgr1.Sprites.Count) do
          begin
               if DGCSpriteMgr1.Sprites.Collision(1, n) then
               begin
                    with DGCSpriteMgr1.Sprites[n] do
                    begin
                         Animation := 2; //Spinning Enemy Animation
                         Direction := Random(32);
                         AllActions := laStopInside;
                         MaxSpeed := 5; //Increase Max Speed
                    end;
                    DGCSpriteMgr1.Sprites[1].Disable;
                    DGCSpriteMgr1.Sprites[1].Hide;
                    break;
               end;
          end;
     end;
end;

procedure TForm1.DGCSpriteMgr1SpriteStopped(Sprite: TDGCSprite;
  LimitsSide: TLimitsSide);
begin
     //Note: The sprite engine will stop the sprite by setting it's
     //Stopped property to True. If you want the sprite to continue
     //moving you will need to set Stopped to False or use the Resume
     //method.
     case Sprite.ID of
          1: //Bullet
          begin
               Sprite.Disable;
               Sprite.Hide;
               Sprite.Resume;
          end;
          2: //Spinning Enemy - Change Animation to explosion
          begin
               if Sprite.Animation <> 4 then
               begin
                    Sprite.Animation := 4;
                    Sprite.Direction := 16; //South
                    Sprite.Resume;
               end;
          end;
     end;
end;

procedure TForm1.DGCSpriteMgr1AnimationEnd(Sprite: TDGCSprite);
begin
     Sprite.Hide;
     Sprite.Disable;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if Key = #27 then Close;
end;

end.
