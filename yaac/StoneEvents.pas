unit StoneEvents;
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

*)

interface
uses {Windows,} Classes, dsound, DGC,DGCSnd, CollisionBasics;

Type
    TStoneCollisionProc = Procedure ( var Ball: TMySpriteRect;
                                      Level : Integer;
                                      CollisionSide : TCollisionSide;
                                      MapX, MapY :integer;
                                      MyScreen : TDGCScreen;
                                      MyAudio : TDGCAudio);
    ForceFieldEntry = Record
                      xAccel, yAccel : Extended;
                      end;
const
   MinStone = 12;
   MaxStone = 61;
   MaxNonSolidStone = 53;
   MaxForceX = 79;
   MaxForceY = 59;



var
   StoneCollision : Array[MinStone..MaxStone] of TStoneCollisionProc;
   Score     : Integer;  // holds the score
   NewBallScore : Integer; // Wann gibts den nächsten Ball?
   BallsLeft : Integer; // Wieviele Bälle hab Ich noch?
   ForceFieldArray : Array [0..MaxForceX, 0..MaxForceY] of ForceFieldEntry;
   MouseSensitivity : Integer;  // The higher this Value the slower the Mouse moves
  procedure DrawBallsLeft(Level: Integer; MyScreen : TDGCScreen);
  // Anzeigen Wieviele Bälle der Spieler noch hat
  procedure AddToScore(Points,Level: Integer; MyScreen : TDGCScreen);

  procedure ComputeForceField(x,y: Integer);
implementation
var
   i : Integer;
   {SoundList : TList;}
const
   BallAcceleration = 4;

procedure ComputeForceField(x,y: Integer);
var i, j, dx, dy : Integer;
begin
     x := x div 8;
     y := y div 8;
     if (x = 0) and (y = 0) then
        for i := 0 to MaxForceX do
           for j := 0 to MaxForceY do begin
               ForceFieldArray[i,j].xAccel := 0;
               ForceFieldArray[i,j].yAccel := 0;
           end
     else
         for i := 0 to MaxForceX do
           for j := 0 to MaxForceY do begin
               dx := x-i;
               dy := y-j;
               if (dx = 0) and (dy = 0) then begin
                  ForceFieldArray[i,j].xAccel := 0;
                  ForceFieldArray[i,j].yAccel := 0;
               end
               else begin
                  ForceFieldArray[i,j].xAccel := (dx*1)/(sqr(dx)+sqr(dy));
                  ForceFieldArray[i,j].yAccel := (dy*1)/(sqr(dx)+sqr(dy));
               end;
           end; //for
end; (*ComputeForceField*)

Procedure DrawScore(Level: Integer; MyScreen : TDGCScreen);
var i, n, iScore : Integer;
const NumberPosInMap = 62;
begin
     iScore := Score;
     for i := 12 downto 6 do begin
         n := iScore MOD 10;
         MyScreen.SetMapTile(Level,i, 0 ,NumberPosInMap+n);
         iscore := iScore div 10;
     end;
      MyScreen.SetMapTile(Level,17, 0 ,NumberPosInMap+10);
      n := Level DIV 10;
      MyScreen.SetMapTile(Level,18, 0 ,NumberPosInMap+n);
      n := Level MOD 10;
      MyScreen.SetMapTile(Level,19, 0 ,NumberPosInMap+n);

end;   //DrawScore

procedure DrawBallsLeft(Level: Integer;MyScreen : TDGCScreen); // Anzeigen Wieviele Bälle der Spieler noch hat
var i : Integer;
begin
     if BallsLeft > 16 then BallsLeft := 16; // Maximum
     for i:= 0 to BallsLeft do begin
        MyScreen.SetMapTile(Level,i, 19 ,11);
     end;
      MyScreen.SetMapTile(Level, BallsLeft+1,19 ,0);
end;

procedure AddToScore(Points,Level: Integer; MyScreen : TDGCScreen);
var Mult : Integer;
begin
     Mult := MyScreen.GetMapTile(Level,1, 0) -7;
     if (Mult < 1) OR (Mult > 4) then Mult := 1;
     Points := Points * Mult;
     Score := Score + Points;
     if Score >=  NewBallScore then begin
        inc(BallsLeft);
        DrawBallsLeft(Level,MyScreen);
        NewBallScore := NewBallScore +5000;
     end;
     DrawScore(Level,Myscreen);


end;


procedure StoneSimple ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyAudio.Sound[3].Replay;
     //SoundListPlay(3,MyAudio);
     AddToScore(25,Level,MyScreen);
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
end;

procedure StonePlusX ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
var
   j : Integer;
begin
     MyAudio.Sound[29].Replay;
     //SoundListPlay(3,MyAudio);
     AddToScore(50,Level,MyScreen);
     j := MyScreen.getMapTile(Level,Mapx, MapY);
     MyScreen.SetMapTile(Level,Mapx, MapY ,j-1);
     SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
     
end;

procedure Stone0G ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[6].Replay;
      AddToScore(125,Level,MyScreen);
      MyScreen.SetMapTile(Level,0,0 ,3);
      MyScreen.SetMapTile(Level,Mapx, MapY ,0);
end;

procedure Stone5G ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyScreen.SetMapTile(Level,0,0 ,4);
      AddToScore(75,Level,MyScreen);
      MyAudio.Sound[6].Replay;
      MyScreen.SetMapTile(Level,Mapx, MapY ,0);
end;
procedure Stone10G ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,0,0 ,5);
     AddToScore(125,Level,MyScreen);
     MyAudio.Sound[6].Replay;
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
end;
procedure Stone20G ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,0, 0 ,6);
     AddToScore(150,Level,MyScreen);
     MyAudio.Sound[6].Replay;
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
end;
procedure StoneQueerG ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,0,0 ,7);
     AddToScore(250,Level,MyScreen);
     MyAudio.Sound[6].Replay;
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
end;
procedure StoneTimes1 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[12].Replay;
     MyScreen.SetMapTile(Level,1, 0 ,0);
end;
procedure StoneTimes2 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[29].Replay;
     MyScreen.SetMapTile(Level,1, 0 ,8);
end;
procedure StoneTimes3 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[29].Replay;
     MyScreen.SetMapTile(Level,1, 0 ,9);
end;
procedure StoneTimes4 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[29].Replay;
     MyScreen.SetMapTile(Level,1, 0 ,10);
end;
procedure StoneApple ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(300,Level,MyScreen);
     MyAudio.Sound[8].Replay;
end;
procedure StoneSun ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(200,Level,MyScreen);
     MyAudio.Sound[12].Replay;
     //MouseSensitivity := -1;
end;
procedure StoneYinYang ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
//Var xVel : Extended;
begin

     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(225,Level,MyScreen);
     MyAudio.Sound[12].Replay;
  //   xVel := Ball.XVel;
     //Ball.XVel := Ball.Yvel;
     //Ball.YVel :=  xVel;
end;

procedure StoneSmallBall ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[21].Replay;
end;
procedure StoneMediumBall ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[21].Replay;

end;
procedure StoneBigBall ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(25,Level,MyScreen);
     MyAudio.Sound[21].Replay;
end;
procedure StoneDonut ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(75,Level,MyScreen);
     MyAudio.Sound[9].Replay;
end;
procedure StoneRed1 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(100,Level,MyScreen);
     MyAudio.Sound[25].Replay;
end;
procedure StoneRed2 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(100,Level,MyScreen);
     MyAudio.Sound[25].Replay;
end;
procedure StoneRed3 ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(100,Level,MyScreen);
     MyAudio.Sound[25].Replay;
end;
procedure StoneBomb ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(100,Level,MyScreen);
     MyAudio.Sound[19].Replay;
end;
procedure StoneExtra ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[14].Replay;
     inc(BallsLeft);
     DrawBallsLeft(Level,Myscreen)
end;

procedure StoneKill ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(90,Level,MyScreen);
     MyAudio.Sound[11].Replay;
end;

procedure StoneDown ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(125,Level,MyScreen);
     //SoundListPlay(2,MyAudio);
     MyAudio.Sound[15].Replay;
     Ball.YVel := abs(Ball.Yvel);
      //if CollisionSide = csBottom then begin
     Ball.yVel := Ball.yVel+BallAcceleration;
        //Ball.x := Ball.x-2;
      //end;
end;

procedure StoneLeft ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(125,Level,MyScreen);
     MyAudio.Sound[15].Replay;
     Ball.XVel := - abs(Ball.XVel);
               //SoundListPlay(2,MyAudio);
               //if CollisionSide = csLeft then begin
     Ball.XVel:=Ball.XVel-BallAcceleration;
     //Ball.x := Ball.x-2;
     //end;
end;

procedure StoneRight ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[15].Replay;
     AddToScore(125,Level,MyScreen);
      // SoundListPlay(2,MyAudio);
     // if CollisionSide = csRight then begin
     Ball.XVel :=  abs(Ball.XVel);
     Ball.XVel:=Ball.XVel+BallAcceleration;
       //inc(Ball.x,2);
     // end;
end;

procedure StoneUp ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[15].Replay;
     AddToScore(125,Level,MyScreen);
     //SoundListPlay(2,MyAudio);
     // if CollisionSide = csTop then begin
     Ball.YVel := -Abs(Ball.Yvel);
     Ball.yVel:=Ball.yVel-BallAcceleration;
     //inc(Ball.y,2)
     // end;
end;
procedure StoneUpRight ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[15].Replay;
     AddToScore(125,Level,MyScreen);
      //if (CollisionSide = csTop) or (CollisionSide = csRight) then begin
      Ball.XVel := abs(Ball.XVel);
      Ball.XVel:=(Ball.XVel+BallAcceleration);
      Ball.YVel := -Abs(Ball.Yvel);
      Ball.yVel:=(Ball.yVel-BallAcceleration);
      //end;
      //if CollisionSide = csTop then  inc(Ball.y,2);
      //if CollisionSide = csRight then  dec(Ball.X,2);
end;
procedure StoneUpLeft ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[15].Replay;
     AddToScore(125,Level,MyScreen);
     //if (CollisionSide = csTop) or (CollisionSide = csLeft) then begin
     Ball.Xvel := -Abs(Ball.Xvel);
     Ball.XVel:=(Ball.XVel-BallAcceleration);
     Ball.YVel := -Abs(Ball.Yvel);
     Ball.yVel:=(Ball.yVel-BallAcceleration);
     //end;

end;

procedure StoneWarp ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
var NextTileX, NextTileY,Count,NextTile : integer;
begin
     NextTileX :=  MapX;
     NextTileY :=  MapY;
     AddToScore(150,Level,MyScreen);
     MyAudio.Sound[32].Replay;
     Count := CountTiles(Level,45, MyScreen);
     if Count >= 1 Then Begin
        NextTile := Random(Count);
        if not FindTile(Level,NextTile,45,NextTileX, NextTileY,MyScreen) then
        begin
            NextTileX :=  MapX;
            NextTileY :=  MapY;
        end;
        // Ball auf die Mitte des Näcsten Tiles setzen
        Ball.x := (2 * NextTileX + 1 )* MyScreen.Images[0].width div 2;
        Ball.y := (2 * NextTileY + 1 ) * MyScreen.Images[0].height div 2;
        Ball.px := Ball.x;
        Ball.py := Ball.y;
     end;
     MyScreen.SetMapTile(Level, NextTileX, NextTileY ,0)
end;

procedure StoneSmily ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(300,Level,MyScreen);
     MyAudio.Sound[33].Replay;
end;

procedure StoneHourGlass ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     AddToScore(30,Level,MyScreen);
     Ball.XVel :=  Ball.XVel / 2;
     Ball.YVel :=  Ball.YVel / 2;
     MyAudio.Sound[5].Replay;
     MouseSensitivity := 2;
end;
procedure StonePhone ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[26].Replay;
     Ball.XVel := Random(13) - 7;
     Ball.YVel := Random(13) - 7;
     AddToScore(40,Level,MyScreen);
end;
procedure StoneQuestion ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
Var NextTile : Integer;
begin
     NextTile := Random(49-MinStone) + MinStone;
     AddToScore(Random(500),Level,MyScreen);
     MyScreen.SetMapTile(Level, Mapx, MapY, NextTile);
     MyAudio.Sound[13].Replay;
end;

procedure StoneLevel ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[22].Replay;
end;

procedure StoneMagnetEnabled ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
var NextTileX, NextTileY,Count,NextTile,MyIdx : integer;
begin
     MyIdx:=MyScreen.GetMapTile(Level,Mapx, MapY);
     // destroy Stone
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     Count := CountTiles(Level,MyIdx+1, MyScreen);
     Ball.XVel := Ball.XVel * 0.7;
     Ball.YVel := Ball.YVel * 0.7;
    (* if Ball.XVel > 0 then  Ball.XVel := 1 else Ball.XVel := -1;
     if Ball.YVel > 0 then  Ball.YVel := 1 else Ball.YVel := -1;*)
     if Count >= 1 Then Begin
        NextTile := Random(Count)+1;
        //if NextTile = 0 Then NextTile := 1;
        if NextTile > Count Then NextTile := Count;
        if FindTile(Level,NextTile,MyIdx+1,NextTileX, NextTileY,MyScreen) then
        begin // enable next magnet
            MyScreen.SetMapTile(Level, NextTileX, NextTileY ,MyIdx);
            ComputeForceField((2 *NextTileX -1) * MyScreen.Images[0].width div 2 , (2* NextTileY - 1) * MyScreen.Images[0].height div 2);
        end
        else ComputeForceField(0,0);

     end
     else ComputeForceField(0,0);

      MyAudio.Sound[3].Replay;
end;

procedure StoneMagnetDisabled ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyScreen.SetMapTile(Level,Mapx, MapY ,0);
     MyAudio.Sound[3].Replay;
end;
procedure StoneBat ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     //i:= MyScreen.getMapTile(Level,Mapx, MapY);
     //MyScreen.SetMapTile(Level,Mapx, MapY ,i-1);
     MyAudio.Sound[10].Replay;
     SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;

procedure StoneSolid ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
     MyAudio.Sound[2].Replay;
     SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;
procedure StoneSolidDie ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;
procedure StoneSolidDown ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      if CollisionSide = csBottom then begin
        Ball.yVel:=(Ball.yVel+BallAcceleration);
        //Ball.y := Ball.y+2;
         //MyAudio.Sound[3].Replay;
      end;
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;
procedure StoneSolidLeft ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      if CollisionSide <> csRight then begin
         Ball.XVel := -Abs(Ball.XVel);
         Ball.XVel:=(Ball.XVel-BallAcceleration);
          //Ball.x := Ball.x-2;
      end;
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;
procedure StoneSolidRight ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      if CollisionSide <> csLeft then begin
         Ball.XVel := Abs(Ball.XVel);
         Ball.XVel:=(Ball.XVel+BallAcceleration);
       //inc(Ball.x,2);
      end;
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;
procedure StoneSolidUp ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      if CollisionSide = csTop then begin
         Ball.yVel := -Abs(Ball.yVel);
         Ball.yVel:=(Ball.yVel-BallAcceleration);
         //dec(Ball.y,4)
      end;
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;
procedure StoneSolidUpLeft ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      {if (CollisionSide = csTop) or (CollisionSide = csRight) then begin
        Dec(Ball.xVel,BallAcceleration);
        Dec(Ball.yVel,BallAcceleration);
        //dec(Ball.yVel,BallAcceleration);
      end; }
      Case CollisionSide of
       csTop,csLeft  : begin
              Ball.Xvel := -Abs(Ball.Xvel);
              Ball.XVel:=Ball.XVel-BallAcceleration;
              Ball.YVel := -Abs(Ball.Yvel);
              Ball.yVel:=Ball.yVel-BallAcceleration;
              end;
       end; // case
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);

end;
procedure StoneSolidUpRight ( var Ball: TMySpriteRect;Level : Integer;CollisionSide : TCollisionSide;
                       MapX, MapY :integer;MyScreen : TDGCScreen;MyAudio : TDGCAudio);
begin
      MyAudio.Sound[2].Replay;
      Case CollisionSide of
       csTop, csRight  : begin
              Ball.Xvel := Abs(Ball.Xvel);
              Ball.XVel:=(Ball.XVel+BallAcceleration);
              Ball.YVel := -Abs(Ball.Yvel);
              Ball.yVel:=(Ball.yVel-BallAcceleration);
              end;
       end; // case
      SetPosOutsideTile(Ball,CollisionSide,Level,MapX, MapY, MyScreen,Ball);
end;





BEGIN (* Unit*)
      i := MinStone;
       StoneCollision[i] := StoneSimple;             // 12
      inc(i);
       StoneCollision[i] := StonePlusX;              // 13
      inc(i);
       StoneCollision[i] := StonePlusX;              // 14
      inc(i);
       StoneCollision[i] := StonePlusX;              // 15
      inc(i);
       StoneCollision[i] := StonePlusX;              // 16
      inc(i);
       StoneCollision[i] := Stone0G;                 // 17
      inc(i);
       StoneCollision[i] := Stone5G;                 // 18
      inc(i);
       StoneCollision[i] := Stone10G;                // 19
      inc(i);
       StoneCollision[i] := Stone20G;                // 20
      inc(i);
       StoneCollision[i] := StoneQueerG;             // 21
      inc(i);
       StoneCollision[i] := StoneTimes1;             // 22
      inc(i);
       StoneCollision[i] := StoneTimes2;             // 23
      inc(i);
       StoneCollision[i] := StoneTimes3;             // 24
      inc(i);
       StoneCollision[i] := StoneTimes4;             // 25
      inc(i);
       StoneCollision[i] := StoneApple;              // 26
      inc(i);
       StoneCollision[i] := StoneSun;                // 27
      inc(i);
       StoneCollision[i] := StoneYinYang;            // 28

      inc(i);
        StoneCollision[i] := StoneSmallBall;          // 30
      inc(i);
       StoneCollision[i] := StoneMediumBall;         // 31
      inc(i);
       StoneCollision[i] := StoneBigBall;            //32
      inc(i);
       StoneCollision[i] := StoneDonut;              //33
      inc(i);
       StoneCollision[i] := StoneRed1;               // 34
      inc(i);
        StoneCollision[i] := StoneRed2;             // 29
      inc(i);
       StoneCollision[i] := StoneRed3;               // 35
      inc(i);
       StoneCollision[i] := StoneBomb;               // 36
      inc(i);
       StoneCollision[i] := StoneExtra;              // 37
      inc(i);
       StoneCollision[i] := StoneKill;               // 38
      inc(i);
       StoneCollision[i] := StoneDown;               // 39
      inc(i);
       StoneCollision[i] := StoneLeft;               // 40
      inc(i);
       StoneCollision[i] := StoneRight;              // 41
      inc(i);
       StoneCollision[i] := StoneUp;                 // 42
      inc(i);
       StoneCollision[i] := StoneUpRight;            // 43
      inc(i);
       StoneCollision[i] := StoneUpLeft;             // 44
      inc(i);
       StoneCollision[i] := StoneWarp;               // 45
      inc(i);
       StoneCollision[i] := StoneSmily;              // 46
      inc(i);
       StoneCollision[i] := StoneHourGlass;          // 47
      inc(i);
       StoneCollision[i] := StonePhone;              // 48
      inc(i);
       StoneCollision[i] := StoneQuestion;           // 49
      inc(i);
       StoneCollision[i] := StoneLevel;              // 50
      inc(i);
       StoneCollision[i] := StoneMagnetEnabled;      // 51
      inc(i);
       StoneCollision[i] := StoneMagnetDisabled;     // 52
      inc(i);
       StoneCollision[i] := StoneBat;                // 53
      inc(i);
       StoneCollision[i] := StoneSolid;              // 54
      inc(i);
       StoneCollision[i] := StoneSolidDie;           // 55
      inc(i);
       StoneCollision[i] := StoneSolidDown;          // 56
      inc(i);
       StoneCollision[i] := StoneSolidLeft;          // 57
      inc(i);
       StoneCollision[i] := StoneSolidRight;         // 58
      inc(i);
       StoneCollision[i] := StoneSolidUp;            // 59
      inc(i);
       StoneCollision[i] := StoneSolidUpLeft;        // 60
      inc(i);
       StoneCollision[i] := StoneSolidUpRight;       // 61
     // inc(i);
     NewBallScore := 5000;
     Score := 0;
     MouseSensitivity := 1;


end.
