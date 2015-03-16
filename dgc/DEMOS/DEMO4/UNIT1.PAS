{The Delphi Games Creator Demo Program
 -------------------------------------
 This demo shows the use of animation and sound effects. Use
 the arrow keys to move the ship. Press escape to quit. When the
 ship blows up you must restart the demo.
}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DGC, DGCILib, dgcspts, DGCSnd, dgcslib;

type
  TForm1 = class(TForm)
    DGCScreen1: TDGCScreen;
    DGCImageLib1: TDGCImageLib;
    DGCAudio1: TDGCAudio;
    DGCSoundLib1: TDGCSoundLib;
    DGCSpriteMgr1: TDGCSpriteMgr;
    procedure DGCScreen1Initialize(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DGCScreen1Flip(Sender: TObject);
    procedure DGCScreen1Paint(Sender: TObject);
    procedure DGCSpriteMgr1AnimationEnd(Sprite: TDGCSprite);
    procedure DGCSpriteMgr1SpriteDirChange(Sprite: TDGCSprite;
      LimitsSide: TLimitsSide);
  private
    { Private declarations }
    procedure DrawFrame;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Trace;

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

     //Create the Animations. Note: Here we are just defining animations
     //not the sprites. The Animation name is optional (the first paramter).
     //The second paramter is LoopAnimation flag.
     DGCSpriteMgr1.Animations.Add('Invader', True);

     //We have added an animation (Index 0) so set the images for the animations.
     //If we want to use the same images for all 32 directions we use the
     //SetAllDirections method. 100=Speed, [1, 2]=Image Numbers
     DGCSpriteMgr1.Animations[0].SetAllDirections(100, [1, 2]);

     //Define the animations for the player controlled ship and explosion. Again
     //we are using the same images for all 32 directions so we use the
     //SetAllDirections method.
     DGCSpriteMgr1.Animations.Add('Ship', True);
     DGCSpriteMgr1.Animations[1].SetAllDirections(100, [0]);

     //For the explosion event we say not to loop because and event is fired
     //when the animation has reached the last frame. This will be our cue to
     //remove the player controlled ship as it has just been blown up.
     DGCSpriteMgr1.Animations.Add('Explode', False);
     DGCSpriteMgr1.Animations[2].SetAllDirections(100, [3, 4, 5, 6]);

     //Now we have defined the animations is is time to create the sprites.
     //Start with the player controlled ship. Note the Allow???? properties
     //are used so the sprite can only move left and right
     //Params=ID, X, Y, Direction (0=North), Speed, Animation# (Defined above)
     DGCSpriteMgr1.Sprites.AddPlayer8(0, 320, 440, 0, 3, 1);
     with DGCSpriteMgr1.Sprites[0] as TDGCPlayer8 do
     begin
          AllowUp := False;        //Not now allow up
          AllowDown := False;      //Do not allow down
          Acceleration := 0.1;     //Do not allow the ship to reach maximum
          Decceleration := 0.1;    //speed and stop instantly.
          //Each sprite can moved within a defined rectangle held in property
          //'Limits'. When the sprite reaches the edge of the rectangle an action
          //can occur. For example, when the sprites reaches the side of the
          //limits rectangle you can make it bounce off the side or just stop.
          //An action can be set for each side of the Limits rectangle.
          //If you want the same action for all four sides of the Limits
          //rectangle use the AllActions property. The Limits rectangle will default
          //to the entire screen. To set an action for just one side use the
          //LeftAction/TopAction,RightAction/BottomAction properties.
          //Note: Some of the Limits Actions values are ignored for player
          //controlled sprites. Try changing the AllActions property for
          //the bouncer sprite created next.
          AllActions := laWrap; //laWrap        = Wrap from one side to the other
                                //laBounce      = Bounce off the side
                                //laReverse     = Reverse direction
                                //laStopInside  = Stop inside the rectangle
                                //laStopOutside = Stop outside the rectangle
                                //laEvent       = Fire the OnSpriteEvent

     end;

     //Create the Invader sprite (TDGCBouncer)
     DGCSpriteMgr1.Sprites.AddBouncer(0, 90, 300, 14, 5, 0);
     with DGCSpriteMgr1.Sprites[1] as TDGCBouncer do
     begin
         Limits := Rect(0, 200, 640, 468);
         Acceleration := 0.01;   //Invader will increase speed slowly
         AllActions := laBounce; //try changing this to laWrap, laReverse,
                                 //laStopinside or laStopOutside.
     end;

     //Set the clipping region to the area we are drawing the sprite in
     DGCScreen1.ClipRect := Rect(0, 200, 640, 468);

     TraceString('Initialise');

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
          TextOut(120, 150, 'Simple Animation and Sound Demo. Use arrow keys');
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
     //Erase the area theat the sprites will move in
     //This is also our screen clipping region
     DGCScreen1.Back.EraseRect(Rect(0, 200, 640, 468), 0);

     //Draw the sprites
     DGCSpriteMgr1.Draw;

     //Update the sprites
     DGCSpriteMgr1.Update;

     //Is there a collision between sprite 0 and 1 (the invader and player ship)?
     if (DGCSpriteMgr1.Sprites.Collision(0, 1)) and
        (DGCSpriteMgr1.Sprites[0].Animation <> 2) then
     begin
          //There is a collision so make the player sprite explode
          with DGCSpriteMgr1.Sprites[0] as TDGCPlayer8 do
          begin
               //A Player8 sprite has two types of animations
               //one for when it's moving when the keys are
               //help down and one when it's idle.
               ActiveAnimation := 2;
               IdleAnimation := 2;
               Automatic := False; //Disable automatic key checks
          end;

          //Make an explosion noise. Replay is the same as
          //using the Stop, Position := 0, and Play commands.
          DGCAudio1.Sound[0].Replay;

          //As well as making the player explode lets send the invader
          //wizzing off in a random direction. The AllActions property
          //is set to laStopOutside which means the invader will stop
          //when is completely leavs the LimitsRect.
          with DGCSpriteMgr1.Sprites[1] as TDGCBouncer do
          begin
               Randomize;
               Direction := Random(32);
               MaxSpeed := 5;               //Set the maximum speed
               Speed := 5;                  //Set the current speed
               AllActions := laStopOutSide; 
          end;
     end;
end;

procedure TForm1.DGCScreen1Paint(Sender: TObject);
begin
     //The paint event should only be called when surfaces are lost. This
     //can be caused when application switching with ALT+TAB.
     DrawFrame;
     DGCScreen1.Flip;
     DrawFrame;
end;

procedure TForm1.DGCSpriteMgr1AnimationEnd(Sprite: TDGCSprite);
begin
     //In this particular demo this event is called when the explosion
     //animation as reached the end. The OnAnimationEnd event is only
     //called if the animation is not looped. The only thing that blows
     //up in this demo is the player so hide and disable it. Although
     //you would normally decrease the player lives and do stuff like that.
     DGCSpriteMgr1.Sprites[0].Hide;
     DGCSpriteMgr1.Sprites[0].Disable;
end;

procedure TForm1.DGCSpriteMgr1SpriteDirChange(Sprite: TDGCSprite;
  LimitsSide: TLimitsSide);
begin
     //Make a boing! noise when the invader hits the limits rectangle
     if Sprite is TDGCBouncer then
          DGCAudio1.Sound[1].Replay;
end;

end.
