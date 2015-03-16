unit CollisionBasics;
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
  uses {Windows,Classes,} DGC;
Type
TMySpriteRect= Record
              x,y,w,h,
              px,py : Extended;
              XVel, YVel : Extended;
              Anim : Integer;
             end;
TCollisionSide = (csTop, csRight, csBottom, csLeft);
// auf welcher Seite fand die Collision statt?
function GetCollisionSide(r1,r2 :TMySpriteRect):TCollisionSide;
// Wo wird der Ball nach einer Kollision sein
Procedure GetNextPosition(r1,r2 :TMySpriteRect; CSide: TCollisionSide;
                          var rNext : TMySpriteRect);
// wieviele Tiles Idx befinden sich auf der Map[Level]
function countTiles(Level,idx:integer; MyScreen : TDGCScreen) : integer;
// Kolision von Sprite mit Tile Idx auf der aktuellen Screen
function TileCollision(r :TMySpriteRect;Level,Idx:integer; MyScreen : TDGCScreen;  var mx,my : Integer):boolean;
// sucht das N-te Tile Idx und dessen Mapkoordinaten, Rückgabe True wenn gefunden.
function FindTile( Level, N, iDx : integer; var MapX, MapY :integer; MyScreen : TDGCScreen): boolean;
// setzt den Ball wieder zurück auf eine Position ausserhalb des Tiles
Procedure SetPosOutsideTile(r1 :TMySpriteRect;  CSide: TCollisionSide;
                            Level, MapX, MapY :integer;
                            MyScreen : TDGCScreen;
                            var rNext : TMySpriteRect);
VAR
   TileWidth, TileHeight : integer;
implementation

function countTiles(Level,idx:integer; MyScreen : TDGCScreen) : integer;
var i, j, count : integer;
begin
     Count :=0;
     for i := 0 to 19 do
         for J := 0 to 19 do
             if MyScreen.getMapTile(Level,i,j) = idx then
                inc(count);
     countTiles:=Count;
end;  (*countTiles*)


function FindTile( Level,N , iDx : integer; var MapX, MapY :integer; MyScreen : TDGCScreen): boolean;
var i,j,count : Integer;
begin
     Count :=0;
     FindTile := False;
     for i := 0 to 19 DO
        for j := 0 To 19 do
            if MyScreen.getMapTile(Level,i,j) = idx then
               begin
               inc(count);
               if Count >= N then Begin
                  FindTile := True;
                  MapX:= i; MapY:=j;
                  Exit; // Raus hier
               end;
            end;
        // next j
     // next i

end;  (*FindTile*)

function TileCollision(r :TMySpriteRect;Level,Idx:integer; MyScreen : TDGCScreen;  var mx,my : Integer):boolean;
var tile : array [1..4] of TDGCMapPos;

function CheckCollisionX(T1,T2 : Integer) : Boolean;
var i : integer;
begin

  for i := Tile[T1].MapX to Tile[T2].MapX do

    if MyScreen.GetMapTile(Level,i,Tile[T1].MapY) = Idx then
        begin
             TileCollision:= True;
             CheckCollisionX := True;
             mx := i;
             my := Tile[T1].mapY;
             exit;
       end;
    CheckCollisionX := False;
end;

begin
    TileCollision:= False;

    Tile[1] := MyScreen.GetTileDrawn(Trunc(r.x),Trunc(r.y));
    Tile[2] := MyScreen.GetTileDrawn(Trunc(r.x+r.w),Trunc(r.y));
    if CheckCollisionX(1,2) then exit;

    Tile[3] := MyScreen.GetTileDrawn(Trunc(r.x),Trunc(r.y+r.h));
    Tile[4] := MyScreen.GetTileDrawn(Trunc(r.x+r.w),Trunc(r.y+r.h));
    if CheckCollisionX(3,4) then exit;

end; (*TileCollision*)



function GetCollisionSide(r1,r2 :TMySpriteRect):TCollisionSide;
// Wo hat der Ball r1 den Schläger r2 getroffen? (oben, unten, rechts, links)
Var dmX, dmY : real;
begin
  GetCollisionSide := csTop;
  dmX := r2.px + (r2.w / 2) - (r1.px + (r1.w / 2));
  dmY := r2.py + (r2.h / 2) - (r1.py + (r1.h / 2));
  if dmx = 0 then
  begin
     if dmy >= 0 then
        GetCollisionSide := csTop
     else
         GetCollisionSide := csBottom;
     exit;
  end
  else
      if ((abs(dmY) / abs(dmX)) > (r2.h / r2.w)) then
      begin
           if dmy >= 0 then
              GetCollisionSide := csTop
           else
               GetCollisionSide := csBottom;
      end
      else
      begin
          if dmX < 0 then
             GetCollisionSide := csRight
          else
              GetCollisionSide := csLeft;
      end;

end;  (*GetCollisionSide *)

Procedure SetPosOutsideTile(r1 :TMySpriteRect;  CSide: TCollisionSide;
                            Level, MapX, MapY :integer;
                            MyScreen : TDGCScreen;
                            var rNext : TMySpriteRect);
// wo muß der Ball r1 hin um nicht nochmal mit dem Stein zu kolidieren
//var dx, dy : Integer;
begin
     rNext := r1;
     rNext.px := r1.x;
     rNext.py := r1.y;
    {
     //Move the Ball to the next Pos (reflect it)
     if (CSide = csTop) or (CSide = csBottom) then
     begin
           r1.y := r1.py -r1.y + r1.py
     end
     else
     begin
          r1.x := (r1.px - r1.x) + r1.px;
     end;}
     //rNext.x := r1.x;
     //rNext.y := r1.y;
     case CSide of
          csTop    :Begin
                        rNext.y := (MapY) *  MyScreen.Images[0].Height - r1.h - 1;
                    end;
          csRight  :Begin
                        rNext.x := (Mapx+1) *  MyScreen.Images[0].Width + 1;
                    end;
          csBottom :Begin
                         rNext.y := (MapY+1) *  MyScreen.Images[0].Height + 1;
                    end;
          csLeft   :Begin
                         rNext.x := (MapX) *  MyScreen.Images[0].Width - r1.w - 1;
                    end
     end; // case

end; //SetPosOutsideTile



Procedure GetNextPosition(r1,r2 :TMySpriteRect; CSide: TCollisionSide;
                          var rNext : TMySpriteRect);
// wo muß der Ball r1 hin um nicht nochmal mit dem Schläger r2 zu kolidieren
var
    dx,dy : Extended;
begin
     rNext := r1;
     rNext.px := r1.x;
     rNext.py := r1.y;

     //Move the Ball to the next Pos (reflect it)
     if (CSide = csTop) or (CSide = csBottom) then
     begin
           r1.y := r1.y -r1.py + r1.y
           //r1.x := (r1.x - r1.px) + r1.x //+ r2.x - r2.px
     end
     else
     begin
          r1.x := (r1.x - r1.px) + r1.x;
          //r1.y := r1.y -r1.py + r1.y //+ r2.y - r2.py
     end;
     rNext := r1;
     dx := r2.px - r2.x;
     dy := r2.py - r2.y;

     case Cside of
          csTop    : if dy < 0 then
                        rNext.y := rNext.y + dy -1 ;
          csRight  :  if dx > 0 then
                        rNext.x := rNext.x + dx +1 ;
          csBottom : if dy > 0 then
                        rNext.y := rNext.y + dy + 1 ;
          csLeft   : if dx < 0 then
                        rNext.x := rNext.x + dx -1 ;
     end;


end;  (* GetNextPosition *)
end. // Unit
