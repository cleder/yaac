unit b0l01;
(*
YaAC  - Yet another Arcanoid Clone
Christian Ledermann cleder@dcsnet.de

Copyright (C) 2000 Christian Ledermann

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.



Changes:
Ver 1.0
Additional Levels
Bug in AddToScore fixed
Beta 9.5
Added GPL disclaymer
Fixed the 'tacky delay' in DGCHiScore
Beta 9.4
Additional Levels
Fixed the problem with the taskbar (hopefully)
Kill Ball shortcut added
Beta 9.2:
Skull Animation added.
Fixed Bug: Explosions appear at the Position of the Ball
that hit the stone, not at position of Ball 1
Beta 9:
Raquet can not longer be stuck inside a wall
Wall collision of the raquet.
Added ScrollLevelIn and ScrollLevelOut. (replacement for fadePaletteIn, -Out)
based on DGC Beta 7.1
16 BPP Color Support
uses Arne Schäpers  DXInputAS to handle Direct Input
fixed a Bug when computing the new Positions

*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DGCMap, DGCILib, DGC, dgcspts, ExtCtrls , CollisionBasics, DGCSnd,
  dgcslib,StoneEvents, DXInputAS, DGCStar, hiscore,p3dTextOut, DGCInput;

type
  TFormMain = class(TForm)
    DGCScreenMain: TDGCScreen;
    DGCImageLibPlayer: TDGCImageLib;
    DGCSpriteMgr1: TDGCSpriteMgr;
    DGCSoundLib1: TDGCSoundLib;
    DGCAudio1: TDGCAudio;
    DGCMapLib1: TDGCMapLib;
    Timer1: TTimer;
    DGCStarField1: TDGCStarField;
    DGCHiScore1: TDGCHiScore;
    TimerLife: TTimer;
    DGCHiColorImageLib1: TDGCHiColorImageLib;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DGCScreenMainInitialize(Sender: TObject);
    procedure DGCScreenMainFlip(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DGCSpriteMgr1AnimationEnd(Sprite: TDGCSprite);
    procedure TimerLifeTimer(Sender: TObject);
    procedure DGCScreenMainPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DGCScreenMainCleanUp(Sender: TObject);
    procedure DrawIntro(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    { Private-Deklarationen }
    Background: TDGCSurface;
    procedure ScrollLevelIn;
    procedure ScrollLevelOut;
    function  SaveHiscoreFile(strSaveFile : String): boolean;
    procedure SaveGame;
    procedure LoadGame;
  public
    { Public-Deklarationen }
  end;

CONST
     MaxBalls = 3;
     MaxVel = 8;
     MinBackground = 36; // Ab hier stehen die Hintergründe in der HiColorLib
var
  FormMain: TFormMain;
  MyBall : array [0..MaxBalls] of TMySpriteRect;
   GForce, GForceHoriz : Extended; // Fallbeschleunigung
   QueerG : Boolean;
   CurrG : Integer;
   Level : Integer;
   CollAtLastFlip : boolean;
   MyScreenWidth, MyScreenHeight : Integer;
   LastScore : Integer; // Letzter Score, Falls Ball verloren geht ohne das Punkte gemacht wurden
   FragRoundRobin : Integer; // Welche Fragmente sind zum Explodieren dran
   RotorRoundRobin : Integer; // selbiges für die Rotoren
   SkullRoundRobin : Integer; // SkullAnimation
   bStars : Boolean ; // Wird ein Starfield angezeigt?
   Generation : Byte; // Generationen für Life
   NumOfBalls : Byte; // Wieviele Bälle werden angezeigt?
   MapXOffSet, MapYOffSet : Integer; 
implementation

{$R *.DFM}

var Cheatmode : Boolean; // Was mag das wohl sein?
    PreviousTicks : LongInt; // Time in ms
    TextXPos : Integer;
    //IsFlipping : Boolean; // Is beschäftigt mit Pageflip
procedure InitLevel(var Level : integer);
 var i, j, MagnetTileX, MagnetTileY :integer;
     bLife : Boolean;
 begin
    FormMain.DGCScreenMain.FlippingEnabled := false;
    if Level < 0 then  Level := 0; // Bei Level < 0
    TextXPos := 0;
    MouseSensitivity := 1;
    if Level > FormMain.DGCScreenMain.MapLibrary.MapLib.MapCount then
    begin
         BallsLeft := -10;
         Level := FormMain.DGCScreenMain.MapLibrary.MapLib.MapCount;

    end; //if
    if BallsLeft < -1 Then
    begin
         FormMain.ScrollLevelOut;
         //FormMain.DGCHiScore1.Showscores;
         FormMain.DGCScreenMain.Back.Canvas.Font := FormMain.Font;
         if not CheatMode then // HiScore kann nicht mit cheaten erreicht werden!!!
            if FormMain.DGCHiScore1.CheckHiScore(Score,Level) then
               FormMain.DGCHiScore1.Execute(Score,level);
          //
          FormMain.DGCHiScore1.SubCaption := 'Have a nice Day ;-)';
          FormMain.DGCHiScore1.Showscores;

          //FormMain.Close;
         Level := 0;
         {FormMain.DGCScreenMain.Back.Erase(0);
         FormMain.DGCScreenMain.Front.Erase(0);
         FormMain.Background.Erase(0); }
         //FormMain.DrawIntro(nil);
         {FormMain.DGCScreenMain.Flip;
         FormMain.DrawIntro(nil);}
    end; //if

    MapXOffSet:=0; MapYOffSet :=0;

    FormMain.TimerLife.Enabled := False;

    If Level = 0 then
       FormMain.DGCScreenMain.OnFlip := FormMain.DrawIntro
    else
       FormMain.DGCScreenMain.OnFlip := FormMain.DGCScreenMainFlip;

    LastScore := Score;
    bLife := True;
    FormMain.DGCScreenMain.FadePaletteOut(100);
    NumOfBalls := 1; // Nur 1 Ball zu Begin des Spiels
    GForce := 0;  // Schwerkraft aus
    GForceHoriz := 0;
    QueerG := False;
    // Ball in die Mitte des Bildschirms und DefaultWerte einsetzten
    for i := 1 to MaxBalls do begin
    MyBall[i].X :=320;
    MyBall[i].Y := 240;
    MyBall[i].pX  := MyBall[1].X-1;
    MyBall[i].py  := MyBall[1].y-1;
    MyBall[i].w :=FormMain.DGCScreenMain.Images[1].width;
    MyBall[i].h :=FormMain.DGCScreenMain.Images[1].Height;
    // Geschwindigkeit des Balles = 0
    MyBall[i].xvel:=0;
    MyBall[i].yvel:=0;
    MyBall[i].anim :=0;
    end; // for
    // Nur 1 Ball hat ne Anmimation
    MyBall[1].anim :=1;
    FormMain.DGCSpriteMgr1.Sprites[1].Animation :=1;
    // Schläger an Defaultposition
    mouse_event(MOUSEEVENTF_ABSOLUTE + MOUSEEVENTF_MOVE, 0,0,0,0);
     MyBall[0].x := 320;
     MyBall[0].Y := 460;
     MyBall[0].px := 320;
     MyBall[0].pY := 460;
    // Größe des Schlägers normal
    MyBall[0].w := FormMain.DGCScreenMain.Images[4].width;
    MyBall[0].h := FormMain.DGCScreenMain.Images[4].height;

    DrawBallsLeft(Level,FormMain.DGCScreenMain);

    // Alle Übereste der Explosionen und Rotoren löschen
    for i := 2 to 29 do
     with FormMain.DGCSpriteMgr1.Sprites[i] do
          begin
               Disable;
               Hide;
          end; // With + for
    // define the Background
    {if FormMain.DGCScreenMain.GetMapTile(Level,19,19) <> 0 then
        begin
        FormMain.Background.Tile(0, 0, FormMain.DGCScreenMain.Images[FormMain.DGCScreenMain.GetMapTile(Level,19,19)], False);
        //FormMain.DGCStarField1.
        bStars := false;
        end
    else
        // wenn kein Hintergrund angegeben wurde dann nimmt man ein Starfield;
        begin
        FormMain.DGCStarField1.Generate;
         FormMain.Background.Erase(0);
        bStars := true;
        end;
        }

    if FormMain.DGCHiColorImageLib1.Images.Count > Level + MinBackGround then
       if FormMain.DGCHiColorImageLib1.Images.Items[Level+ MinBackGround].Image.Graphic.Empty then
       begin
          FormMain.DGCStarField1.Generate;
          FormMain.Background.Erase(0);
          bStars := true;
        end
        else begin
            if (FormMain.DGCHiColorImageLib1.Images.Items[Level+ MinBackGround].Image.Graphic.Height > 1)
            and (FormMain.DGCHiColorImageLib1.Images.Items[Level+ MinBackGround].Image.Graphic.Width > 1) then begin
                FormMain.BackGround.Tile(0,0,FormMain.DGCScreenMain.Images[Level+ MinBackGround],False);
                bStars := False;
            end
            else
            begin
                 FormMain.DGCStarField1.Generate;
                 FormMain.Background.Erase(0);
                 bStars := true;
            end;
        end;
    AddToScore(0,Level,FormMain.DGCScreenMain); // Force DrawScore
    for i := 0 to 19 do begin
    for j := 0 to 19 do begin
     if FormMain.DGCScreenMain.GetMapTile(Level,i,j) = 2 then
            begin
               // Schläger an die ausgangsposition setzten!

               MyBall[0].X := i * FormMain.DGCScreenMain.Images[0].Width;
               MyBall[0].Y := j * FormMain.DGCScreenMain.Images[0].height;
               MyBall[0].pX  := MyBall[0].X;
               MyBall[0].py  := MyBall[0].y;
               bLife := False;
             end; // if

     if FormMain.DGCScreenMain.GetMapTile(Level,i,j) = 1 then
     begin
         MyBall[1].X := i * FormMain.DGCScreenMain.Images[0].Width;
         MyBall[1].Y := j * FormMain.DGCScreenMain.Images[0].height;
         MyBall[1].pX  := MyBall[1].X;
         MyBall[1].py  := MyBall[1].y;
         bLife := False;
     end; //if
     end; // for j
    end; // for i
    //Suche nach einem Magneten
     if FindTile(Level,1,51,MagnetTileX, MagnetTileY,FormMain.DGCScreenMain) then
        Begin
             MagnetTileX := (2* MagnetTileX -1) * FormMain.DGCScreenMain.Images[0].width div 2;
             MagnetTileY := (2* MagnetTileY -1) * FormMain.DGCScreenMain.Images[0].height div 2;
             ComputeForceField(MagnetTileX ,MagnetTileY);
        end
      Else
          Begin
             ComputeForceField(0,0);
        end;


    {FormMain.DGCScreenMain.Back.Draw(0, 0, FormMain.Background, False);
    FormMain.DGCScreenMain.DrawMap(FormMain.DGCScreenMain.Back,Level,0,0,0,0,True);
    FormMain.DGCScreenMain.Flip;
    FormMain.DGCScreenMain.Back.Erase(0);
    FormMain.DGCScreenMain.FadePaletteIn(100); }
    // Ball taucht auf Animation
    FormMain.DGCSpriteMgr1.Sprites[0].Animation := 3;
    if level > 0 then begin
       Try
          FormMain.DGCAudio1.Sound[35].Replay;
          //if FormMain.DGCAudio1.Sound[20].Playing then
          FormMain.DGCAudio1.Sound[20].Stop;
       Except
           beep;
       end;
    end;
    FormMain.DGCSpriteMgr1.Sprites[0].Enable;
    FormMain.DGCSpriteMgr1.Sprites[0].Show;
    FormMain.DGCSpriteMgr1.Sprites[1].Enable;
    FormMain.DGCSpriteMgr1.Sprites[1].Show;
    FormMain.DGCSpriteMgr1.Sprites[0].Resume;
    if Level = 0 then bLife := false;

    // Set the Bat at the new Position
    FormMain.DGCSpriteMgr1.Sprites[0].X := Trunc(MyBall[0].X);
    FormMain.DGCSpriteMgr1.Sprites[0].Y := Trunc(MyBall[0].Y);
    FormMain.DGCSpriteMgr1.Sprites[MyBall[1].Anim].X := Trunc(MyBall[1].X);
    FormMain.DGCSpriteMgr1.Sprites[MyBall[1].Anim].y := Trunc(MyBall[1].y);
    // Scroll the new Level in
    FormMain.ScrollLevelIn;
    FormMain.TimerLife.Enabled := bLife; // Life wird True falls Ball oder Schläger keine Position haben!
    // Poll the Mouse Events
    DIMouse.Poll;
    // Set elapsed Time to 0
    PreviousTicks := GetTickCount;
    FormMain.DGCScreenMain.FlippingEnabled := TRUE;
    // Maus in die Mitte des Bildschirms
    mouse_event(MOUSEEVENTF_ABSOLUTE + MOUSEEVENTF_MOVE, 35767,32767,0,0);
end; // InitLevel
function tFormMain.SaveHiscoreFile(strSaveFile : String): boolean;

var  IntCheckSum : Integer;
     SaveFile : TextFile;
begin
        {$I-}
        AssignFile( SaveFile,strSaveFile );
        Rewrite(SaveFile);
        {$I+}
        SaveHiscoreFile := False;
        if IOResult = 0 Then begin
           Writeln(SaveFile,Score);
           Writeln(Savefile,BallsLeft);
           Writeln(Savefile,Level);
           IntCheckSum :=  Score +  BallsLeft + Level;
           Writeln(Savefile,IntCheckSum);
           CloseFile(Savefile);
           SaveHiscoreFile:=true;
        end;


end;
procedure TFormMain.SaveGame;
VAR      SaveFile : TextFile;

begin

      if SaveHiscoreFile('YAAC.SAV') then  Begin
           DGCScreenMain.FlippingEnabled:= False;
           with DGCScreenMain.Back.Canvas do
           begin
                Brush.Style := bsClear;
                Font.Size := 24;
                Font.Color := clYellow;
                TextOut(110, 60, 'Saving Please Wait');
                Release; //This must be called to release the device context.
          end;
          DGCScreenMain.Flip;
          Sleep(500);
          DGCScreenMain.FlippingEnabled:= True;
        end;
end;
procedure tformMain.LoadGame;
VAR      SaveFile : TextFile;
         IntCheckSum : Integer;
         intScore, IntBallsLeft,IntLevel : Integer;
         TextLoad : String;
Begin
        {$I-}
        AssignFile( SaveFile, 'YAAC.SAV');
        Reset(SaveFile);
        {$I+}
        if IOResult = 0 Then begin
           {$I-}
           readln(SaveFile,IntScore);
           Readln(Savefile,IntBallsLeft);
           Readln(Savefile,IntLevel);
           Readln(Savefile,IntCheckSum);
           CloseFile(Savefile);
           {$I+}
           DGCScreenMain.FlippingEnabled:= False;
           if IntCheckSum <> IntLevel + IntBallsLeft + IntScore then
              Begin
              TextLoad := 'Bad Savefile';
              DGCAudio1.Sound[39].Replay;
              dec(BallsLeft); // Wenn schon cheaten dann auch richtig mein Freund!
              end
           else begin
              TextLoad := 'Loading Please Wait';
              Score := intScore;
              BallsLeft := IntBallsLeft;
              Level:= IntLevel;
              if FileExists(Extractfilepath(Application.ExeName)+'\YAAC.MAP') then
                 DGCMapLib1.MapLib.LoadFromFile( Extractfilepath(Application.ExeName)+'\YAAC.MAP');
           end;

           with DGCScreenMain.Back.Canvas do
           begin
                Brush.Style := bsClear;
                Font.Size := 24;
                Font.Color := clYellow;
                TextOut(110, 60, TextLoad);
                Release; //This must be called to release the device context.
           end;
           DGCScreenMain.Flip;
           Sleep(500);
           DGCScreenMain.FlippingEnabled:= True;

           NewBallScore := ((Score div 5000) + 1) * 5000; // errechne wann es den nächsten Extraball gibt
           initLevel(Level);
        end;
end;
procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
//var

    //intScore, IntBallsLeft,IntLevel,IntCheckSum : Integer;
begin
     if (key = #27) or (Key = 'x') then
        begin
        //DGCHiScore1.Showscores;
        BallsLeft := -10;
        ScrollLevelOut;
        //initLevel(Level);
        Application.Terminate;
        exit;
        //DGCScreenMain.FadePaletteOut(100);
        //close;
     end;
     if Key = 'n' then
      if FileExists(Extractfilepath(Application.ExeName)+'\YAAC.MAP') then
         begin
         DGCMapLib1.MapLib.LoadFromFile( Extractfilepath(Application.ExeName)+'\YAAC.MAP');
         Level := 1;
         NewBallScore := 5000;
         Score := 0;
         BallsLeft := 3;
         InitLevel(Level);
         exit;
         end;
     if ( Key = 'k' ) AND ( Level > 0 ) Then Begin
     //Kill the current Ball
          dec(BallsLeft);
          DGCAudio1.Sound[22].Replay;
          InitLevel(Level);
          end;
     if ( key = 'l') and ( Score > 0) then begin // Load Game
        LoadGame;
     end;
     if Key = 'C'  then Cheatmode := not CheatMode;
     if Key = '+' Then
        If CheatMode then begin
           inc(Level);
           InitLevel(Level)
        end;
     if Key = '-' Then
        If CheatMode then begin
           if Level > 0 then
           dec(Level);
           InitLevel(Level)
        end;
     if Key = '*' Then
        If CheatMode then begin
           inc(BallsLeft)
        end;

     if key = 's' then begin // Save Game
         SaveGame;
     end;
     {if key = 'm' then begin
        Level := 13;
        initLevel(Level);
     end;}
     if key = 'z' then begin
          // DGCScreenMain.Back.Canvas.Font.Name := 'Comic Sans MS';
          DGCHiScore1.SubCaption := 'Press P to continue';
          DGCHiScore1.Showscores;
          DGCScreenMain.FlippingEnabled := false;

     end;
     if Key = 'p' then // pause game
     begin
        if DGCScreenMain.FlippingEnabled Then Begin
           DGCScreenMain.FlippingEnabled:= False;
           with DGCScreenMain.Back.Canvas do
           begin
                Brush.Style := bsClear;
                Font.Size := 24;
                Font.Color := clYellow;
                //TextOut(140, 60, 'Game Paused');
                s3DTextOutS(140,60,2, 'Game Paused',DGCScreenMain.Back.Canvas);
                Font.Color := clTeal;
                s3DTextOutS(140, 130,2, 'Press P to continue',DGCScreenMain.Back.Canvas);
                Release; //This must be called to release the device context.
          end; // With
          DGCScreenMain.Flip;
        end //if  FlippingEnabled
        else
            DGCScreenMain.FlippingEnabled := True;
        DIMouse.Poll;
        PreviousTicks := GetTickCount;
     end; // Pause

end; (*FormKeyPress*)

procedure TFormMain.DGCScreenMainInitialize(Sender: TObject);
var i : Integer;
begin
     FormMain.DGCScreenMain.Back.Canvas.Font := FormMain.Font;
     // wenn Map Datei existiert dann wird Map aus der Datei geladen!
     if FileExists(Extractfilepath(Application.ExeName)+'\YAAC.MAP') then
        DGCMapLib1.MapLib.LoadFromFile( Extractfilepath(Application.ExeName)+'\YAAC.MAP')
     else  // sonst erzeuge Map Datei
         DGCMapLib1.MapLib.SaveToFile( Extractfilepath(Application.ExeName)+'\YAAC.MAP');
     BallsLeft := 3; // =  Bälle 0..4
     MyBall[1].Xvel := 0;
     MyBall[1].YVel := 0;
     MyBall[1].X := 320;
     MyBall[1].Y := 350;
     CurrG := 0;
     //Create Background
     Background := TDGCSurface.Create(DGCScreenMain.DirectDraw4, 640, 480,16);
     //DGCScreenMain.CreateSurface(BackGroundTile, 64, 64 );
     // define the Background
     if FileExists(Extractfilepath(Application.ExeName)+'\YAAC.HCL') then
        DGCHiColorImageLib1.Loadfromfile( Extractfilepath(Application.ExeName)+'\YAAC.HCL')
     else
         Application.Terminate;

     if DGCHiColorImageLib1.Images.Items[1].Image.Graphic.Empty then
       bStars := True
     else begin
         if (DGCHiColorImageLib1.Images.Items[MinBackground].Image.Graphic.Height > 1)
         and (DGCHiColorImageLib1.Images.Items[MinBackground].Image.Graphic.Width > 1) then begin
             //BackGroundTile.Canvas.Draw(0,0,DGCHiColorImageLib1.Images.Items[0].Image.Graphic);
             //BackGroundTile.Canvas.Release;
             BackGround.Tile(0,0,DGCScreenMain.Images[MinBackground],False);
             bStars := False;
         end
         else   bStars := True
     end;


     //Schläger:
     DGCSpriteMgr1.Animations.Add('BAT', True);
     DGCSpriteMgr1.Animations[0].SetAllDirections(100, [4]);
      //Add Player Sprite - ID=0;
     {DGCSpriteMgr1.Sprites.AddPlayer8(0, 320, 440, 0, 4, 0);
     with DGCSpriteMgr1.Sprites[0] as TDGCPlayer8 do
     begin
          Acceleration := 0.10;  //Try making this a smaller value
          Decceleration := 0.10; //Try making this a smaller value
          AllowUp := True;
          AllowDown := True;
     end;
      }
     // Static => compute all the Movement by yourself
     // Schläger:
     DGCSpriteMgr1.Sprites.AddStatic(0, 320, 440, 0);
     MyBall[0].w := DGCScreenMain.Images[4].width;
     MyBall[0].h := DGCScreenMain.Images[4].height;

     // Ball:
     DGCSpriteMgr1.Animations.Add('Ball', True);
     DGCSpriteMgr1.Animations[1].SetAllDirections(100, [1]);
     DGCSpriteMgr1.Sprites.AddStatic(1, 90, 300, 1);

     // Schläger ist kaputt
     DGCSpriteMgr1.Animations.Add('HideBat', false);
     DGCSpriteMgr1.Animations[2].SetAllDirections(100, [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]);
     // Schläger taucht auf:
     DGCSpriteMgr1.Animations.Add('ShowBat', false);
     DGCSpriteMgr1.Animations[3].SetAllDirections(100, [20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4]);

     // Fragmente der Expoldierenden Steine
     FragRoundRobin := 2;
     DGCSpriteMgr1.Animations.Add('Frag1', True);
     DGCSpriteMgr1.Animations[4].SetAllDirections(100,[24]);
     for i := 2 to 6 do begin
          DGCSpriteMgr1.Sprites.AddBouncer( i, 320, 240, 14, 3, 4);
          with DGCSpriteMgr1.Sprites[i] do
          begin
               Disable;
               Hide;
               AllActions := laStopOutside;
          end;
     end; // for
     DGCSpriteMgr1.Animations.Add('Frag2', True);
     DGCSpriteMgr1.Animations[5].SetAllDirections(100,[23]);
     for i := 7 to 11 do begin
         DGCSpriteMgr1.Sprites.AddBouncer(i,320, 240, 26, 5, 5);
         with DGCSpriteMgr1.Sprites[i] do
         begin
               Disable;
               Hide;
               AllActions := laStopOutside;
         end;
     end; // for
     DGCSpriteMgr1.Animations.Add('Frag3', True);
     DGCSpriteMgr1.Animations[6].SetAllDirections(100,[22]);
     for i := 12 to 16 do begin
         DGCSpriteMgr1.Sprites.AddBouncer(i, 320, 240, 12, 2, 6);
         with DGCSpriteMgr1.Sprites[i] do
         begin
              Disable;
              Hide;
              AllActions := laStopOutside;
         end;
     end; // for
     // Rotor hinzufügen
     DGCSpriteMgr1.Animations.Add('Rotor', True);
     DGCSpriteMgr1.Animations[7].SetAllDirections(100,[25,26,27]);
     RotorRoundRobin := 17;
     for i := 17 to 21 do begin
          DGCSpriteMgr1.Sprites.AddBouncer(i, 320, 240, 12, 2, 7);
          with DGCSpriteMgr1.Sprites[i] do
               begin
               Disable;
               Hide;
               AllActions := laBounce;
          end;
     end; // for
      //großer Schläger:
     DGCSpriteMgr1.Animations.Add('BigBAT', True);
     DGCSpriteMgr1.Animations[8].SetAllDirections(100, [21]);

      // Weitere Baelle:
     DGCSpriteMgr1.Sprites.AddStatic(22, 90, 300, 1);
     DGCSpriteMgr1.Sprites.AddStatic(23, 90, 300, 1);
     DGCSpriteMgr1.Sprites[22].disable;
     DGCSpriteMgr1.Sprites[22].Hide;
     DGCSpriteMgr1.Sprites[23].disable;
     DGCSpriteMgr1.Sprites[23].Hide;
     // Medium Ball
     DGCSpriteMgr1.Animations.Add('MidBall', True);
     DGCSpriteMgr1.Animations[9].SetAllDirections(100, [2]);
     // Big Ball
     DGCSpriteMgr1.Animations.Add('BigBall', True);
     DGCSpriteMgr1.Animations[10].SetAllDirections(100, [3]);
     // Skull
     DGCSpriteMgr1.Animations.Add('Skull', True);
     DGCSpriteMgr1.Animations[11].SetAllDirections(150, [28,29,30,31,32,33,34,35,34,33,32,31,30,29]);
     SkullRoundRobin := 24;
     for i := 24 to 29 do begin
     DGCSpriteMgr1.Sprites.AddBouncer(i, 320, 240, 25, 1.0, 11);
          with DGCSpriteMgr1.Sprites[i]  do
               begin
               Disable;
               Hide;
               AllActions := laWrap;
          end;
     end; // for
     //Alles auf Variablen Zuweisen damit man nicht über das Objekt und damit Read/Write Procedures gehen muss
     MyBall[1].w := DGCScreenMain.Images[1].width;
     MyBall[1].h := DGCScreenMain.Images[1].height;

    
     MyScreenWidth :=  DGCScreenMain.ScreenWidth;
     MyScreenHeight := DGCScreenMain.ScreenHeight;
     TileWidth := DGCScreenMain.Images[0].Width;
     TileHeight := DGCScreenMain.Images[0].Height;
     Randomize; // Zufallszahlen Anfang generieren
     Level := 0;


     initLevel(Level);

end; (*DGCScreenMainInitialize*)

procedure ComputeBallPos(  ElapsedTime : longint);
// computes the new Position of the Ball
var   i, TileCount : integer;
    Ball : Integer;
    BallOut : Boolean;
Procedure SortBalls;
var Temp : TMySpriteRect;
    i,j : integer;
Begin
     // Bubble Sort
    for i := 1 to MaxBalls do
       for j := i to MaxBalls do
           if MyBall[i].Anim < MyBall[j].Anim Then  begin
              Temp:=MyBall[i];
              MyBall[i]:= MyBall[j];
              MyBall[j] := Temp;
           end;
end; //SortBalls
begin
     
     BallOut := False;
     for Ball := 1 To NumOfBalls do
     with MyBall[Ball] do Begin
          PX := X;
          PY:= Y;
           // hier schlägt die Schwerkraft zu
           yVel:=yVel + (GForce * ElapsedTime)/ 200;
           xVel:=xVel + (GForceHoriz * ElapsedTime)/ 200;
          // Gibt es einen Magneten ?
          xVel:=xVel + ((ForceFieldArray[Trunc(x/8),Trunc(y/8)].xAccel * ElapsedTime)/10);
          yVel:=yVel + ((ForceFieldArray[Trunc(x/8),Trunc(y/8)].yAccel * ElapsedTime)/10);

          // Geschwindigkeiten nur bis zu einem Maximum zulassen, sonst wirds unspielbar
          if Xvel > MaxVel then Xvel := MaxVel;
          if Yvel > MaxVel then Yvel := MaxVel;
          if Xvel < -MaxVel then Xvel := -MaxVel;
          if Yvel < -MaxVel then Yvel := -MaxVel;

          X := (X + (XVel*ElapsedTime)/18);
            //X := ((X + XVel)
          Y := (Y + (YVel*ElapsedTime)/18);
            //Y := ((Y + YVel)
          // Ist der Ball noch auf der Screen
          if MyBall[Ball].y < 0 then begin
             FormMain.DGCAudio1.Sound[4].Replay;
             MyBall[Ball].y := 1;
             MyBall[Ball].yVel := -MyBall[Ball].yVel;
          end;
          if MyBall[Ball].x < 0 then begin
             FormMain.DGCAudio1.Sound[4].Replay;
             MyBall[Ball].x := 1;
             MyBall[Ball].xVel := -MyBall[Ball].xVel;
          end;
          if MyBall[Ball].x > MyScreenWidth - MyBall[Ball].w  then begin
             FormMain.DGCAudio1.Sound[4].Replay;
             MyBall[Ball].x := MyScreenWidth-MyBall[Ball].w-1;
             MyBall[Ball].xVel := -MyBall[Ball].xVel;
          end;
          if MyBall[Ball].y >  MyScreenHeight then
           begin
              //FormMain.DGCSpriteMgr1.Sprites[0].Frame := 0;
              //if MyBall[Ball].anim <> 0 then begin
              FormMain.DGCSpriteMgr1.Sprites[MyBall[Ball].anim].Hide;
              FormMain.DGCSpriteMgr1.Sprites[MyBall[Ball].anim].Disable;
              MyBall[Ball].anim := 0;
              //end;
              dec(NumOfBalls); // Zahl der Bälle erniedrigen
              BallOut := True;
           end;

     end; // with

     if BallOut then Begin
        // Zähle wieviele Steine noch übrig sind
        TileCount := 0;
        For i := MinStone to MaxNonSolidStone do Begin
             TileCount := TileCount + CountTiles(Level,i,FormMain.DGCScreenMain);
             if TileCount > 0 then Break; // sobald auch nur einer Übrig ist
        end; (*FOR*)
        if (TileCount = 0) then begin // Keine Steine mehr übrig ->
           inc(Level); // Next Level
           InitLevel(Level);
           exit;
        end;
        if (Score > LastScore)  then  // Hat nen Punkt gemacht und den Ball verloren
           if (NumOfBalls=0) then   // 0 Bälle
             Begin
             Dec(BallsLeft);  // Hat nen Punkt gemacht und den Ball verloren
             FormMain.DGCAudio1.Sound[22].Replay;
             InitLevel(Level);
             exit;
             end
           else SortBalls
        else // +0 Punkte und
          Begin
             FormMain.DGCAudio1.Sound[22].Replay;
             InitLevel(Level);
             exit;
         end
      end; // BallOut


end; (*ComputeBallPos*)


procedure TFormMain.DGCScreenMainFlip(Sender: TObject);
var
   ElapsedTicks, CurrentTicks : Longint;
   BBCS : TCollisionSide;
   CollX, CollY : Integer;
   Stone : TMySpriteRect;
   bMoved : Boolean; // Wurde der Schläger durch ein Ereignis bewegt
   i,rnd : Integer;
   DeltaX, DeltaY, DeltaZ : Integer; // Difference between Current and Previous Mouse Position

Procedure PollMouse;
begin
  with DIMouse do
  begin
    Poll;  // Acquire, GetDeviceState (= Übertrag nach Data)
    with Data do
    begin
      DeltaX:=lX div MouseSensitivity;
      DeltaY:=lY div MouseSensitivity;
      DeltaZ:=lZ div MouseSensitivity;  // Rädchen der IntelliMouse
    end; // With
  end; // With DIMouse
end; // Poll Mouse
Procedure StoneBallCollision;
var i,j : Integer;
begin
     for j := 1 to NumOfBalls do
     For i := MinStone to MaxStone do Begin
        if TileCollision(MyBall[j],Level,i,DGCScreenMain,CollX, CollY ) then
           begin  // Dieser Code wird für alle Kollisionen ausgeführt
              Stone.x := collX * DGCScreenMain.Images[0].width;
              Stone.Y :=  collY * DGCScreenMain.Images[0].height;
              Stone.w :=  DGCScreenMain.Images[0].width;
              Stone.h :=  DGCScreenMain.Images[0].height;
              Stone.Px := Stone.x;
              Stone.Py := Stone.y;
              // Auf welcher Seite war die Kollision
              //BBCS :=  GetCollisionSide (Stone,MyBall[1]);
              BBCS :=  GetCollisionSide (MyBall[j],Stone);
              // Ball wird reflektiert...

              case BBCS of
               csTop, csBottom : begin
                      MyBall[j].XVel := MyBall[j].XVel ;
                      MyBall[j].YVel := -MyBall[j].YVel ;
                      end;
               else begin
                       MyBall[j].XVel := -MyBall[j].XVel;
                       MyBall[j].YVel :=  MyBall[j].YVel;
               end;
              end; // case
              // Steinspezifisches Event
           StoneCollision[i]( MyBall[j],Level,BBCS,CollX, CollY,DGCScreenMain,DGCAudio1);
           case i of
                26 : DGCSpriteMgr1.Sprites[0].Animation := 2; // Apple -> Schläger shrumpft
                27 : begin
                      inc(SkullRoundRobin);
                      if SkullRoundRobin > 29 then SkullRoundRobin := 24;
                      rnd := Random(32);
                      DGCAudio1.Sound[20].PlayLoop;
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].enable;
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].show;
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].X := Trunc(MyBall[j].x);
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].y := Trunc(MyBall[j].y);
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].Speed := Random(8) +2;
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].Direction := rnd;
                      DGCSpriteMgr1.Sprites[SkullRoundRobin].Resume;
                     end;
                28 : Begin
                      DGCSpriteMgr1.Sprites[0].Animation := 8; // YinYan -> Großer Schläger
                      // Größe des Schlägers bestimmen.
                      MyBall[0].w := DGCScreenMain.Images[21].width;
                      MyBall[0].h := DGCScreenMain.Images[21].height;
                     end;
                29 : begin //Normal Ball
                      MyBall[j].w := DGCScreenMain.Images[1].width;
                      MyBall[j].h := DGCScreenMain.Images[1].Height;
                      DGCSpriteMgr1.Sprites[1].Animation :=1;
                      MyBall[j].Anim := 1;

                     end;
                30 : begin // Medium Ball
                       MyBall[j].w := DGCScreenMain.Images[2].width;
                       MyBall[j].h := DGCScreenMain.Images[2].Height;
                       MyBall[j].Anim := 1;
                       DGCSpriteMgr1.Sprites[1].Animation :=9;

                     end;
                31 : begin // Big Ball
                       MyBall[j].w := DGCScreenMain.Images[3].width;
                       MyBall[j].h := DGCScreenMain.Images[3].Height;
                       MyBall[j].Anim := 1;
                       DGCSpriteMgr1.Sprites[1].Animation :=10;
                     end;
                32 : Begin // Donut
                      inc( RotorRoundRobin);
                      if RotorRoundRobin > 21 then RotorRoundRobin := 17;
                      rnd := Random(32);
                       DGCAudio1.Sound[20].PlayLoop;
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].enable;
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].show;
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].X := Trunc(MyBall[j].x);
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].y := Trunc(MyBall[j].y);
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].Speed := Random(3) +2;
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].Direction := rnd;
                      DGCSpriteMgr1.Sprites[RotorRoundRobin].Resume;
                     END;
                33 : Begin// 1 Ball
                          DGCSpriteMgr1.Sprites[1].Enable;
                          DGCSpriteMgr1.Sprites[1].Show;
                          NumOfBalls := 1;
                          MyBall[1] := MyBall[j];
                          MyBall[1].anim := 1;
                          MyBall[2].anim := 0;
                          MyBall[3].anim := 0;
                          DGCSpriteMgr1.Sprites[22].Disable;
                          DGCSpriteMgr1.Sprites[22].Hide;
                          DGCSpriteMgr1.Sprites[23].Disable;
                          DGCSpriteMgr1.Sprites[23].Hide;
                     end;
                34 : Begin // 2 Bälle
                          DGCSpriteMgr1.Sprites[1].Enable;
                          DGCSpriteMgr1.Sprites[1].Show;
                          DGCSpriteMgr1.Sprites[1].Animation :=1;
                          NumOfBalls := 2;
                          if MyBall[j].Xvel = 0 then MyBall[j].XVel :=1;
                          MyBall[1] := MyBall[j];
                          MyBall[1].anim := 1;
                          //GCSpriteMgr1.Sprites[22].Animation :=22;
                          DGCSpriteMgr1.Sprites[22].Animation :=1;
                          MyBall[2] := MyBall[j];
                          MyBall[2].anim := 22;
                          MyBall[2].xvel := -MyBall[2].xvel;
                          DGCSpriteMgr1.Sprites[22].Enable;
                          DGCSpriteMgr1.Sprites[22].Resume;
                          DGCSpriteMgr1.Sprites[22].Show;
                          DGCSpriteMgr1.Sprites[23].Disable;
                          DGCSpriteMgr1.Sprites[23].Hide;
                          MyBall[3].anim := 0;
                     end;
                35 : Begin // 3 Bälle
                          DGCSpriteMgr1.Sprites[1].Enable;
                          DGCSpriteMgr1.Sprites[1].Show;
                          NumOfBalls := 3;
                          if MyBall[j].Xvel = 0 then MyBall[j].XVel :=1;
                          if MyBall[j].yvel = 0 then MyBall[j].yVel :=1;
                          MyBall[1] := MyBall[j];
                          MyBall[2] := MyBall[j];
                          MyBall[3] := MyBall[j];
                          MyBall[2].xvel := -MyBall[2].xvel;
                          MyBall[3].xvel := -MyBall[3].yvel;
                          MyBall[1].anim := 1;
                          MyBall[2].anim := 22;
                          MyBall[3].anim := 23;

                          DGCSpriteMgr1.Sprites[22].Animation :=1;
                          DGCSpriteMgr1.Sprites[23].Animation :=1;

                          DGCSpriteMgr1.Sprites[22].Enable;
                          //DGCSpriteMgr1.Sprites[22].Resume;
                          DGCSpriteMgr1.Sprites[22].Show;

                          DGCSpriteMgr1.Sprites[23].Enable;
                          //DGCSpriteMgr1.Sprites[23].Resume;
                          DGCSpriteMgr1.Sprites[23].Show;


                     end;
                36 : Begin // Bombe
                      inc(FragRoundRobin);
                      if FragRoundRobin >= 7 then FragRoundRobin := 2; // Fragmente durchrotieren
                      rnd := Random(11);
                      DGCSpriteMgr1.Sprites[FragRoundRobin].enable;
                      DGCSpriteMgr1.Sprites[FragRoundRobin].show;
                      DGCSpriteMgr1.Sprites[FragRoundRobin].X := Trunc(MyBall[j].x);
                      DGCSpriteMgr1.Sprites[FragRoundRobin].y := Trunc(MyBall[j].y);
                      DGCSpriteMgr1.Sprites[FragRoundRobin].Direction := rnd;
                      DGCSpriteMgr1.Sprites[FragRoundRobin].Resume;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+5].enable;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+5].show;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+5].X := Trunc(MyBall[j].x);
                      DGCSpriteMgr1.Sprites[FragRoundRobin+5].y := Trunc(MyBall[j].y);
                      DGCSpriteMgr1.Sprites[FragRoundRobin+5].Direction := rnd+10;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+5].Resume;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+10].enable;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+10].show;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+10].X := Trunc(MyBall[j].x);
                      DGCSpriteMgr1.Sprites[FragRoundRobin+10].y := Trunc(MyBall[j].y);
                      DGCSpriteMgr1.Sprites[FragRoundRobin+10].Direction := rnd+20;
                      DGCSpriteMgr1.Sprites[FragRoundRobin+10].Resume;

                     end;
                46 : begin // Smily :-)
                     inc(Level);
                     initLevel(Level);
                     end;
                50 : begin // Smily   :-(
                     dec(Level);
                      if FileExists(Extractfilepath(Application.ExeName)+'\YAAC.MAP') then
                         DGCMapLib1.MapLib.LoadFromFile( Extractfilepath(Application.ExeName)+'\YAAC.MAP')
                      else BallsLeft := 0 ;
                     initLevel(Level);
                     end;

                else;
           end; // case
           Break; // Ein Steinspezifisches Event pro Flip ist genug!
        end; //if
    end; (* for*)
end; // StoneBallCollision

Procedure BallBatCollision;
var i  : Integer;
    Rebound,Decel : Single;
begin
   bMoved := True;
   for i := 1 To NumOfBalls DO
    if DGCSpriteMgr1.Sprites.Collision(MyBall[i].Anim, 0) then
    begin
        case  DGCSpriteMgr1.Sprites[MyBall[i].Anim].Animation  of
                9  : Begin
                      Rebound := 3;
                      Decel := 8;
                     end;
                10 :  Begin
                      Rebound := 5;
                      Decel := 7;
                     end;
        else
        Begin
            Rebound := 1.0;
            Decel := 9.0;
            end;
        end; // case
       // Where did the Ball hit the Bat?
       BBCS :=  GetCollisionSide (MyBall[i],MyBall[0]);
       case BBCS of
       csTop, csBottom : begin
              DGCAudio1.Sound[0].Replay;
              //MyBall[1].XVel :=  (MyBall[1].XVel *9) div 10 +  (DeltaX );
              //MyBall[1].YVel := - 1 *  MyBall[1].YVel *99 div 100 + (DeltaY);
              MyBall[i].XVel := ((MyBall[i].XVel   +  (DeltaX * Decel / 10)) * Decel) / 10;
              MyBall[i].YVel := ((- 1 *  MyBall[i].YVel  + (DeltaY * Decel / 1))* Decel) / 10;
              end;
       else begin
               DGCAudio1.Sound[1].Replay;
               //MyBall[1].XVel := -1 * (MyBall[1].XVel*9 div 10) +  (DeltaX);
               //MyBall[1].YVel :=  MyBall[1].YVel*99 div 100 + (DeltaY);
               MyBall[i].XVel := ((-1* MyBall[i].XVel +  (DeltaX* Decel  / 10))* Decel) / 10;
               MyBall[i].YVel :=  ((MyBall[i].YVel + (DeltaY))* Decel* Decel / 10) / 10;
       end;
       end; // case
         (*mouse_event(MOUSEEVENTF_MOVE,
         ( Trunc((MyBall[i].X-MyBall[i].pX)
         * Rebound)),
         ( Trunc((MyBall[i].Y-MyBall[i].py) * Rebound)),
          0,0); *)
          MyBall[0].X := MyBall[0].X +((MyBall[i].X-MyBall[i].pX) * Rebound);
          MyBall[0].Y := MyBall[0].Y +((MyBall[i].Y-MyBall[i].py) * Rebound);
          GetNextPosition(MyBall[i],MyBall[0],BBCS,MyBall[i]);

          // wenn der Ball den Schläger zweimal hintereinander traf
          // setzte ihn in einen Sicherheitsabstand (eignet sich zum cheaten)
          if CollAtLastFlip then
             case BBCS of
              csTop    : MyBall[i].y := MyBall[i].y-6;
              csRight  : MyBall[i].x := MyBall[i].x+6;
              csBottom : MyBall[i].y := MyBall[i].y+6;
              csLeft   : MyBall[i].x := MyBall[i].x-6;
          end;
          CollAtLastFlip:= True;
       end //if  Sprites.Collision
       else begin
         //PreviousX := CurrentX;
         //PreviousY := CurrentY;
         CollAtLastFlip := False;
       end;
end; // BallBatCollision

Procedure AccelBalls;
Var I : Integer;
    r : Extended;
Begin
    DGCAudio1.Sound[44].Play;
    r := Random;
    MapXOffSet:= - DeltaX div 5; MapYOffSet := - DeltaY div 5;
    for i := 1 to NumOfBalls do
    begin
        MyBall[i].XVel := MyBall[i].XVel - (DeltaX * ElapsedTicks/3000) * (r);
        MyBall[i].YVel := MyBall[i].YVel - (DeltaY * ElapsedTicks/3000) * (r);
    end;
end; //AccelBalls

begin // On Flip
      // Nur einmal ausführen!!
     // if  IsFlipping then Exit else
     //IsFlipping := True;
     // Draw the Background
      bMoved := False;
     if bStars then
        DGCStarField1.Update
     else
         DGCScreenMain.Back.Draw(0, 0, Background, False);
     // Draw map to screen with transparency
     DGCScreenMain.DrawMap(DGCScreenMain.Back,Level,0,0,MapXOffSet, MapYOffSet ,true);
     MapXOffSet:=0; MapYOffSet :=0;
     (*DeltaX := CurrentX - PreviousX;
     DeltaY := CurrentY - PreviousY;*)
     PollMouse;
     // Set the Bat at the new Position
     DGCSpriteMgr1.Sprites[0].X := Trunc(MyBall[0].X);
     DGCSpriteMgr1.Sprites[0].Y := Trunc(MyBall[0].Y);
     MyBall[0].pX := MyBall[0].X;
     MyBall[0].pY := MyBall[0].Y;
     MyBall[0].X := MyBall[0].X + DeltaX;
     MyBall[0].Y := MyBall[0].Y + DeltaY;
    (* How much Time has passed (in ms) since last Update?*)
    CurrentTicks := GetTickCount;
    ElapsedTicks := CurrentTicks -PreviousTicks;
    PreviousTicks := CurrentTicks;
    {if ElapsedTicks > 40 then // 25 Fps
       DGCAudio1.Sound[1].Replay;
     }
    ComputeBallPos(ElapsedTicks);
    // Set the Balls to the new Pos
    for i := 1 to NumOfBalls do Begin
        DGCSpriteMgr1.Sprites[MyBall[i].Anim].X := Trunc(MyBall[i].X);
        DGCSpriteMgr1.Sprites[MyBall[i].Anim].y := Trunc(MyBall[i].y);
    end;
    // is the bat inside the screen?
    if   MyBall[0].X > MyScreenWidth - MyBall[0].W then
    begin
         MyBall[0].X := MyScreenWidth - MyBall[0].W - 4;
         AccelBalls
    end;
    if   MyBall[0].Y > MyScreenHeight - MyBall[0].H then
    begin
         MyBall[0].Y  := MyScreenHeight - MyBall[0].H - 4;
         AccelBalls
    end;
    if MyBall[0].X < 0 Then
    begin
       MyBall[0].X := 4;
       AccelBalls
    end;
    if MyBall[0].Y < 0 Then
    begin
       MyBall[0].Y := 4;
       AccelBalls
    end;
    StoneBallCollision; // Hat der Ball einen Stein getroffen?

    if (DeltaX <> 0) or (DeltaY <> 0) Then // Wenn der Schläger sich nicht Bewegt hat brauch ich auch nicht zu Schauen ob er mit was kollidiert ist
    For i := MinStone to MaxStone do Begin
      if TileCollision(MyBall[0],Level,i,DGCScreenMain,CollX, CollY ) then
      begin
          //if TileCollision(MyBall[0],Level,i,DGCScreenMain,CollX -(2*deltaX), CollY -(2*deltaY) ) then
          //mouse_event( MOUSEEVENTF_MOVE, -2*deltaX, -2*deltaY, 0,0);
          bMoved := True;
          MyBall[0].X := MyBall[0].X - 2* DeltaX;
          MyBall[0].Y := MyBall[0].Y - 2* DeltaY;
          case i of
               MaxNonSolidStone : begin
                                AddToScore(250,Level,DGCScreenMain);
                                DGCScreenMain.SetMapTile(Level,CollX, CollY ,0);
                                DGCAudio1.Sound[36].Replay;
                                end;
               38 : Begin Dec(BallsLeft);DGCAudio1.Sound[18].Replay; InitLevel(Level); exit;  end;// Killer
               55 : begin Dec(BallsLeft);DGCAudio1.Sound[18].Replay; InitLevel(Level); exit; end
          else DGCAudio1.Sound[1].Replay;
          end; // case
      end; //if TileCollision
    end; (* for*)


    // check Collision
    for i := 2 to 21 do
       if DGCSpriteMgr1.Sprites[i].Enabled then
           if DGCSpriteMgr1.Sprites.Collision(i, 0) then
           begin
                if i >= 17 then DGCAudio1.Sound[37].Replay
                else DGCAudio1.Sound[38].Replay;
                Dec(BallsLeft);
                initLevel(Level);
                //IsFlipping := False; // Wichtig sonst komm ich nicht mehr rein!
                exit;
           end;
       for i := 24 to 29 do
       if DGCSpriteMgr1.Sprites[i].Enabled then
           if DGCSpriteMgr1.Sprites.Collision(i, 0) then
           begin
                DGCAudio1.Sound[7].Replay;
                Dec(BallsLeft);
                //IsFlipping := False; // Wichtig sonst komm ich nicht mehr rein!
                initLevel(Level);
                exit;
           end;
     //Draw the sprites
    DGCSpriteMgr1.Draw;
     //Update the sprites
    DGCSpriteMgr1.Update;

    BallBatCollision; // Collision zwischen Schläger und Ball

    if  bMoved Then
       For i := MinStone to MaxStone do
           if TileCollision(MyBall[0],Level,i,DGCScreenMain,CollX, CollY ) then
           begin
           // Schläger darf nicht auf einem Stein landen -> lieber wieder auf die alte Position
             MyBall[0].X := MyBall[0].pX;
             MyBall[0].Y := MyBall[0].pY;
           end;

     MyBall[0].pX := MyBall[0].X;
     MyBall[0].pY := MyBall[0].Y;
     //IsFlipping := False;

end;  (*DGCScreenMainFlip*)




procedure TFormMain.Timer1Timer(Sender: TObject);
var i,k, TileCount : integer;
begin
     // alles Was nicht bei jedem Flip gemacht werden muß landet hier ...

     // nachschauen was für eine Schwerkraft herrscht
     k:=DGCScreenMain.getMapTile(Level,0,0);
     QueerG := False;
     case k of
          3 : GForce := 0; // 0 G
          4 : GForce := 0.5;  // 5 G
          5 : GForce := 0.9; // 10 G
          6 : GForce := 1.8; // 20 G
          7 : QueerG := True; // queer G
     else
           GForce := 0.1; // 0,1 G
     end; // case
     If QueerG then begin
        Gforce := 3.0*(Random -0.5);
        GForceHoriz := 3.0*(Random -0.5);
     end
     else
         GForceHoriz := 0;

     // Zähle wieviele Steine noch übrig sind
     TileCount := 0;
     For i := MinStone to MaxNonSolidStone do Begin
         if i <> 50 Then // Level Down Bricks do not count
            TileCount := TileCount + CountTiles(Level,i,DGCScreenMain);
         if TileCount > 0 then Break; // sobald auch nur einer Übrig ist
     end; (*FOR*)
     // Wenn es keine Steine mehr zum Kaputtmachen gibt ab ins nächste Level
     if TileCount = 0 then begin // end of Level
           inc(Level);
           InitLevel(Level);
     end; // if
     //if isFlipping then
       // Maus in die Mitte des Bildschirms
       // mouse_event(MOUSEEVENTF_ABSOLUTE + MOUSEEVENTF_MOVE, 35767,32767,0,0);
end; (*Timer1Timer*)

procedure TFormMain.DGCSpriteMgr1AnimationEnd(Sprite: TDGCSprite);
begin
      case Sprite.ID of
           0 : Begin // Raquet
                Sprite.Animation := 0; // Schläger solide
                // Größe des Schlägers normal
                MyBall[0].w := DGCScreenMain.Images[4].width;
                MyBall[0].h := DGCScreenMain.Images[4].height;
               end;
      else
          //Sprite.Hide;
          //Sprite.Disable;
          ;
      end; // case
      //Sprite.Animation := 0;
      //Sprite.Animation.
      //Sprite.Resume;
end; (*DGCSpriteMgr1AnimationEnd*)

procedure TFormMain.TimerLifeTimer(Sender: TObject);
var x,y, Neighbours : Integer;
 //This array holds the map details so that we can restore it after a race
    MapHold   : Array[0..19, 0..19] of byte;
    ParentStone : Byte;
function NeighbourCount(x,y : Integer):Integer;
var i,j, count : Integer;

begin
   Count := 0;
   for i := x-1 to x+1 do
       for j := y-1 to y+1 do
           if not((x=i) and (y=j)) then // Zelle selbst nicht betrachten
           if (MapHold[i,j] >= MinStone) and (MapHold[i,j] <= MaxStone)   Then
              inc (Count);
    NeighbourCount := Count;
end; (*NeighbourCount*)

begin
   if (Generation > 4) or  (Generation < 2) then Generation := 2;
   ParentStone :=  DGCScreenMain.GetMapTile(Level,Generation,0);
   if ParentStone = 0 Then ParentStone := 12;
   inc(Generation);
   for x := 0 to 19 do
    for y := 0 to 19 do
    begin
         MapHold[x][y] := DGCScreenMain.GetMapTile(Level,x,y);
    end;
    // 12 = Stone
    for x := 1 to 18 do
     for y := 1 to 18 do
        begin
        Neighbours :=  NeighbourCount(x,y);
        if MapHold[x][y] = 0 then // Tote Zelle
         if Neighbours = 3 Then
             DGCScreenMain.SetMapTile(Level,x,y,ParentStone); // erwecken

         if MapHold[x][y] >= 12 then // Stone
             if (Neighbours > 3) or (Neighbours < 2) then
                DGCScreenMain.SetMapTile(Level,x,y,0); // die
             //else
             //   DGCScreen1.SetMapTile(Level,x,y,12); // survive

        end;
end;  (*TimerLifeTimer*)

procedure TFormMain.DGCScreenMainPaint(Sender: TObject);
Var FlipMode : Boolean;
begin
     //Create Background
     Flipmode :=  DGCScreenMain.FlippingEnabled;
     DGCScreenMain.FlippingEnabled := False;
     //Background.Free;
     //Background := TDGCSurface.Create(DGCScreenMain.DirectDraw4, 640, 480,16);
     if bStars then DGCStarField1.Generate
     else
     //BackGround.Tile(0,0,DGCScreenMain.Images[Level+ MinBackGround],False);
     // Poll the Mouse Events so that any Mouse move while you tabbed away is void
     DIMouse.Poll;
     // No Time past since you tabbed away!
     PreviousTicks := GetTickCount;
     DGCScreenMain.FlippingEnabled := Flipmode;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
     Cheatmode := False;
      //IsFlipping := False;
end;

procedure TFormMain.DrawIntro(Sender: TObject);

begin
     if Level <> 0 then close; // Scores werden nur in Level 0 Gemalt
     DGCStarField1.Update;
     DGCScreenMain.DrawMap(DGCScreenMain.Back,Level,0,0,0,0,True);
     With DGCScreenMain.Back.Canvas do  begin
          Font.Color := clWhite;
          Font.Size := 14;
          Brush.Style := bsClear;
          TextOut( 3*32 +16 ,2*24,'25');
          TextOut( 3*32 +16 ,4*24,'50');
          TextOut( 3*32 +16 ,6*24,'50');
          TextOut( 3*32 +16 ,8*24,'50');
          TextOut( 3*32 +16 ,10*24,'50');
          TextOut( 3*32 +16 ,12*24,'125');
          TextOut( 3*32 +16 ,14*24,'75');
          TextOut( 3*32 +16 ,16*24,'150');

          TextOut( 6*32 +16 ,2*24,'250');
          TextOut( 6*32 +16 ,4*24,'1 x');
          TextOut( 6*32 +16 ,6*24,'2 x');
          TextOut( 6*32 +16 ,8*24,'3 x');
          TextOut( 6*32 +16 ,10*24,'4 x');
          TextOut( 6*32 +16 ,12*24,'300');
          TextOut( 6*32 +16 ,14*24,'200');
          TextOut( 6*32 +16 ,16*24,'225');

          TextOut( 9*32 +16 ,2*24,'25');
          TextOut( 9*32 +16 ,4*24,'25');
          TextOut( 9*32 +16 ,6*24,'25');
          TextOut( 9*32 +16 ,8*24,'75');
          TextOut( 9*32 +16 ,10*24,'100');
          TextOut( 9*32 +16 ,12*24,'100');
          TextOut( 9*32 +16 ,14*24,'100');
          TextOut( 9*32 +16 ,16*24,'100');

          TextOut( 12*32 +16 ,2*24,'Ball');
          TextOut( 12*32 +16 ,4*24,'90');
          TextOut( 12*32 +16 ,6*24,'125');
          TextOut( 12*32 +16 ,8*24,'125');
          TextOut( 12*32 +16 ,10*24,'125');
          TextOut( 12*32 +16 ,12*24,'125');
          TextOut( 12*32 +16 ,14*24,'125');
          TextOut( 12*32 +16 ,16*24,'125');

          TextOut( 15*32 +16 ,2*24,'150');
          TextOut( 15*32 +16 ,4*24,'+ L');
          TextOut( 15*32 +16 ,6*24,'30');
          TextOut( 15*32 +16 ,8*24,'40');
          TextOut( 15*32 +16 ,10*24,'???');
          TextOut( 15*32 +16 ,12*24,'- L');
          TextOut( 15*32 +16 ,14*24,'00');
          TextOut( 15*32 +16 ,16*24,'250');

          TextOut( 18*32 +16 ,2*24,'00');
          TextOut( 18*32 +16 ,4*24,'00');
          TextOut( 18*32 +16 ,6*24,'00');
          TextOut( 18*32 +16 ,8*24,'00');
          TextOut( 18*32 +16 ,10*24,'00');
          TextOut( 18*32 +16 ,12*24,'00');
          TextOut( 18*32 +16 ,14*24,'00');
          TextOut( 18*32 +16 ,16*24,'00');
          Dec(TextXPos,1);

          If TextXPos < -1000 then TextXPos := 644;
          TextOut(TextXPos,18,'PRESS [L] TO LOAD GAME -- [S] TO SAVE CURRENT GAME -- [N] FOR A NEW GAME -- [P] TO PAUSE -- [ESC] TO EXIT!');
          Font.Color := clRed;
          TextOut(2*TextXPos,420,'This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.');
          Release;
     end;
end;

procedure TFormMain.ScrollLevelIn;
var i : Integer;
begin
     for i := -DGCScreenMain.ScreenHeight div 2 to 0 do begin
         if bStars then
            DGCStarField1.Update
         else
             DGCScreenMain.Back.Draw(0, 0, Background, False);

         // Draw map to screen with transparency
         DGCScreenMain.DrawMap(DGCScreenMain.Back,Level,0,0,0,i*2,true);
         if Level > 0 then Begin
            //Draw the sprites
            DGCSpriteMgr1.Draw;
            //Update the sprites
            DGCSpriteMgr1.Update;
         end;
         DGCScreenMain.Flip;
     end;
end;
procedure TFormMain.ScrollLevelOut;
var i : Integer;
begin
     for i := 0 to DGCScreenMain.ScreenHeight div 2  do begin
         if bStars then
            DGCStarField1.Update
         else
             DGCScreenMain.Back.Draw(0, 0, Background, False);
         DGCScreenMain.DrawMap(DGCScreenMain.Back,Level,0,0,0,i*2,true);
         DGCScreenMain.Flip;
     end;
end;

procedure TFormMain.DGCScreenMainCleanUp(Sender: TObject);
begin
     Background.Free;
end;

procedure TFormMain.FormClick(Sender: TObject);
begin
 // Maus in die Mitte des Bildschirms
   mouse_event(MOUSEEVENTF_ABSOLUTE + MOUSEEVENTF_MOVE, 35767,32767,0,0);
end;

end.
