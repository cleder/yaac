unit DGC3DCanvas;

// WAISS 3D Canvas v1.5 Component
// Author: M Adler
// E-Mail: AISSSOFT@AOL.COM
// URL http://www.waiss.com  or http://members.xoom.com/WAISS


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,DGC;

type
DGCTW3DStyle = (dsRaised,dsInlaid,dsNormal);

 VAR
    sStyle:DGCTW3DStyle;
    sPen:Tpen;
    swidth:integer;
    hicol:TColor;
    ShadCol:Tcolor ;
    topcol,botcol:TColor; // actual color used based on drawstyle
    mfont:Tfont;
    drawwidth :Integer;
    //Procedure DGCTW3DCanvas_setstyle(styl:DGCTW3Dstyle);


    { Published declarations }
 (* Property DrawStyle:DGCTW3DStyle read sstyle write setstyle default dsRaised;
  Property DrawWidth:Integer read sWidth write sWidth default 1;
  Property HighLightColor:Tcolor read topcol write topcol default clWhite;
  Property ShadowColor:Tcolor read botcol write botcol default clGray;
  Property Font;
  *)
  //------ Utility Procedures
  procedure DGCTW3DCanvas_shiftarray(var Points: array of TPoint;offset:integer);
  //------ functions of canvas
  Procedure DGCTW3DCanvas_setstyle(styl:DGCTW3Dstyle);
  procedure DGCTW3DCanvas_MoveTo(X, Y: Integer);
  procedure DGCTW3DCanvas_LineTo(X, Y: Integer);
  procedure DGCTW3DCanvas_TextOut(X, Y: Integer;Text: string);
  procedure DGCTW3DCanvas_Ellipse(X1, Y1, X2, Y2: Integer);
  procedure DGCTW3DCanvas_Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
  procedure DGCTW3DCanvas_Rectangle(X1, Y1, X2, Y2: Integer);
  procedure DGCTW3DCanvas_Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Longint);
  procedure DGCTW3DCanvas_RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
  procedure DGCTW3DCanvas_Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
  procedure DGCTW3DCanvas_FrameRect(Rect: TRect);
  procedure DGCTW3DCanvas_Polygon(Points: array of TPoint);
  procedure DGCTW3DCanvas_Polyline(Points: array of TPoint);
  procedure DGCTW3DCanvas_Assign(Canvas : TDGCCanvas);



implementation

//------------------------------------------------------------------------------
 Var DGCTW3DCanvas : TDGCCanvas;

//------------------------------------------------------------------------------
 procedure DGCTW3DCanvas_Assign(Canvas : TDGCCanvas);
 begin
      DGCTW3DCanvas := Canvas;
 end;
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_TextOut(X, Y: Integer;Text: string);
begin
with DGCTW3DCanvas do
  begin

     brush.style:=bsClear;
     font.Color :=hicol;
     textout(x,y,text);
     font.color :=shadcol;
     textout(x+2,y+2,text);
     font.color :=clbtnface;
     textout(x+1,y+1,text);
  end;
end;

//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Ellipse(X1, Y1, X2, Y2: Integer);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     ellipse(x1,y1,x2,y2);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     ellipse(x1+2,y1+2,x2+2,y2+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     ellipse(x1+1,y1+1,x2+1,y2+1);
end;
end;
//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Chord(X1+2, Y1+2, X2+2, Y2+2, X3+2, Y3+2, X4+2, Y4+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Chord(X1+1, Y1+1, X2+1, Y2+1, X3+1, Y3+1, X4+1, Y4+1);
end;
end;

//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Rectangle(X1, Y1, X2, Y2: Integer);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     Rectangle(x1,y1,x2,y2);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Rectangle(x1+2,y1+2,x2+2,y2+2);///
     brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Rectangle(x1+1,y1+1,x2+1,y2+1);
end;
end;
//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Longint);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Pie(X1+2, Y1+2, X2+2, Y2+2, X3+2, Y3+2, X4+2, Y4+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Pie(X1+1, Y1+1, X2+1, Y2+1, X3+1, Y3+1, X4+1, Y4+1);
end;
end;

//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_RoundRect(X1, Y1, X2, Y2,X3,Y3: Integer);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     RoundRect(x1,y1,x2,y2,X3,Y3);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     RoundRect(x1+2,y1+2,x2+2,y2+2,X3+2,Y3+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     RoundRect(x1+1,y1+1,x2+1,y2+1,X3+1,Y3+1);
end;
end;

//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Arc(X1+2, Y1+2, X2+2, Y2+2, X3+2, Y3+2, X4+2, Y4+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Arc(X1+1, Y1+1, X2+1, Y2+1, X3+1, Y3+1, X4+1, Y4+1);
end;
end;

//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_FrameRect(Rect: TRect);
begin
with DGCTW3DCanvas do
begin
     offsetrect(rect,1,1);
     brush.Color := shadcol;
     framerect(rect);
     offsetrect(rect,-1,-1);
     brush.color := hicol;
     framerect(rect);
end;
end;
//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Polygon(Points: array of TPoint);
begin
with DGCTW3DCanvas do
begin
     brush.style:=bsSolid;
     brush.Color := hicol;
     pen.Color := hicol;
     polygon(points);////
     DGCTW3DCanvas_shiftarray(points,2);
     brush.Color := shadcol;
     pen.Color := shadcol;
     polygon(points);///
     DGCTW3DCanvas_shiftarray(points,-1);
     brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     polygon(points);
end;
end;
//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_Polyline(Points: array of TPoint);
begin
with DGCTW3DCanvas do
begin

     pen.color :=hicol;
     polyline(points);
     DGCTW3DCanvas_shiftarray(points,1);
     pen.color :=shadcol;
     polyline(points);
end;
end;
//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_shiftarray(var Points: array of TPoint;offset:integer);
var i:integer;
begin
for i := 0 to high(points) do
begin
points[i].x:=points[i].x+offset;
points[i].y:=points[i].y+offset;
end;
end;
//------------------------------------------------------------------------------
Procedure DGCTW3DCanvas_setstyle(styl:DGCTW3Dstyle);
begin
sstyle := styl;
if styl = dsRaised then
begin
  hicol := topcol;
  shadcol := botcol;
end
else
begin
  hicol := botcol;
  shadcol := topcol;
end;
end;
//------------------------------------------------------------------------------
procedure DGCTW3DCanvas_MoveTo(X, Y: Integer);
begin
DGCTW3DCanvas.moveto(x,y);
end;
//------------------------------------------------------------------------------
Procedure DGCTW3DCanvas_LineTo(X, Y: Integer);
var t:Tpoint ;
begin
with DGCTW3DCanvas do

begin
     t:= penpos;
     pen.color :=hicol;
     lineto(x,y);
     pen.color :=shadcol;
     moveto(t.x-2,t.y+2);
     lineto(x-2,y+2);
     pen.color := clBtnFace;
     moveto(t.x-1,t.y+1) ;
     lineto(x-1,y+1);
end;
end;
initialization //DGCTW3DCanvas.Create(AOwner: TComponent);
begin
     //inherited create(AOwner);
     hicol := clWhite;
     shadcol := clGray;
     topcol :=clWhite;
     botcol := clgray;
     drawwidth := 1;
     DGCTW3DCanvas.Brush.style:=bsClear;
     DGCTW3DCanvas.Pen.width:=1;

end;


end.
