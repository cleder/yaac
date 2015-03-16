unit CleDX3DCanvas;

// WAISS 3D Canvas v1.5 Component
// Author: M Adler
// E-Mail: AISSSOFT@AOL.COM
// URL http://www.waiss.com  or http://members.xoom.com/WAISS
(* Modified by Christian Ledermann cleder@dcsnet.de for use with DGC *)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, DGC;

type
TCleDX3DStyle = (dsRaised,dsInlaid,dsNormal);
  TCleDX3DCanvas = class(TComponent)
  private
    { Private declarations }
    FScreen:TDGCScreen;
  protected
    { Protected declarations }

    sStyle:TCleDX3DStyle;
    sPen:Tpen;
    swidth:integer;
    hicol:TColor;
    ShadCol:Tcolor ;
    topcol,botcol:TColor; // actual color used based on drawstyle
    mfont:Tfont;

    Procedure setstyle(styl:TCleDX3DStyle);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
   destructor  Destroy; override;
   procedure MoveTo(X, Y: Integer);
   Procedure LineTo(X, Y: Integer);
     //Property Canvas read FScreen.Back.Canvas write FScreen.Back.Canvas;
  published
    { Published declarations }
  Property DGCScreen: TDGCScreen read FScreen write FScreen;
  Property DrawStyle:TCleDX3DStyle read sstyle write setstyle default dsRaised;
  Property DrawWidth:Integer read sWidth write sWidth default 1;
  Property HighLightColor:Tcolor read topcol write topcol default clWhite;
  Property ShadowColor:Tcolor read botcol write botcol default clGray;
  //Property Font : TFont; // read FScreen.Back.Canvas.Font write FScreen.Back.Canvas.Font;
  //------ Utility Procedures
  procedure shiftarray(var Points: array of TPoint;offset:integer);
  //------ functions of canvas
  procedure TextOut(X, Y: Integer;Text: string);
  procedure Ellipse(X1, Y1, X2, Y2: Integer);
  procedure Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
  procedure Rectangle(X1, Y1, X2, Y2: Integer);
  procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Longint);
  procedure RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
  procedure Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
  procedure FrameRect(Rect: TRect);
  procedure Polygon(Points: array of TPoint);
  procedure Polyline(Points: array of TPoint);
  end;

procedure Register;

implementation

//------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('DGC', [TCleDX3DCanvas]);
end;
//------------------------------------------------------------------------------
destructor TCleDX3DCanvas.Destroy;
begin
     inherited destroy;
end;
//------------------------------------------------------------------------------
constructor TCleDX3DCanvas.Create(AOwner: TComponent);
begin
     inherited create(AOwner);
     FScreen:=Nil;
     hicol := clWhite;
     shadcol := clGray;
     topcol :=clWhite;
     botcol := clgray;
     drawwidth := 1; 

     //canvas.Brush.style:=bsClear;
     //canvas.Pen.width:=1;

end;
//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.TextOut(X, Y: Integer;Text: string);
begin

with FScreen.Back.Canvas do
  begin
     //font.size := 22; //self.Font.Size;
     //font.name:= self.Font.Name;
     brush.style:=bsClear;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     font.Color :=hicol;
     textout(x,y,text);
     font.color :=shadcol;
     textout(x+2,y+2,text);
     font.color :=clbtnface;
     textout(x+1,y+1,text);
     Release;
  end;
end;

//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Ellipse(X1, Y1, X2, Y2: Integer);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     ellipse(x1,y1,x2,y2);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     ellipse(x1+2,y1+2,x2+2,y2+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     ellipse(x1+1,y1+1,x2+1,y2+1);
     Release;
end;
end;
//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Chord(X1+2, Y1+2, X2+2, Y2+2, X3+2, Y3+2, X4+2, Y4+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Chord(X1+1, Y1+1, X2+1, Y2+1, X3+1, Y3+1, X4+1, Y4+1);
     Release;
end;
end;

//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Rectangle(X1, Y1, X2, Y2: Integer);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     Rectangle(x1,y1,x2,y2);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Rectangle(x1+2,y1+2,x2+2,y2+2);///
     brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Rectangle(x1+1,y1+1,x2+1,y2+1);
     Release;
end;
end;
//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Longint);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Pie(X1+2, Y1+2, X2+2, Y2+2, X3+2, Y3+2, X4+2, Y4+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Pie(X1+1, Y1+1, X2+1, Y2+1, X3+1, Y3+1, X4+1, Y4+1);
     Release;
end;
end;

//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.RoundRect(X1, Y1, X2, Y2,X3,Y3: Integer);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     RoundRect(x1,y1,x2,y2,X3,Y3);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     RoundRect(x1+2,y1+2,x2+2,y2+2,X3+2,Y3+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     RoundRect(x1+1,y1+1,x2+1,y2+1,X3+1,Y3+1);
     Release;
end;
end;

//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4);////
     brush.Color := shadcol;
     pen.Color := shadcol;
     Arc(X1+2, Y1+2, X2+2, Y2+2, X3+2, Y3+2, X4+2, Y4+2);///
      brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     Arc(X1+1, Y1+1, X2+1, Y2+1, X3+1, Y3+1, X4+1, Y4+1);
     Release;
end;
end;

//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.FrameRect(Rect: TRect);
begin
with FScreen.Back.Canvas do
begin
     offsetrect(rect,1,1);
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := shadcol;
     framerect(rect);
     offsetrect(rect,-1,-1);
     brush.color := hicol;
     framerect(rect);
     Release;
end;
end;
//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Polygon(Points: array of TPoint);
begin
with FScreen.Back.Canvas do
begin
     brush.style:=bsSolid;
     //canvas.Brush.style:=bsClear;
     Pen.width:=1;
     brush.Color := hicol;
     pen.Color := hicol;
     polygon(points);////
     shiftarray(points,2);
     brush.Color := shadcol;
     pen.Color := shadcol;
     polygon(points);///
     shiftarray(points,-1);
     brush.Color := clBtnFace;
     pen.Color := clBtnFace;
     polygon(points);
     Release;
end;
end;
//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.Polyline(Points: array of TPoint);
begin
with FScreen.Back.Canvas do
begin
     Brush.style:=bsClear;
     Pen.width:=1;
     pen.color :=hicol;
     polyline(points);
     shiftarray(points,1);
     pen.color :=shadcol;
     polyline(points);
     Release;
end;
end;
//------------------------------------------------------------------------------
procedure TCleDX3DCanvas.shiftarray(var Points: array of TPoint;offset:integer);
var i:integer;
begin
for i := 0 to high(points) do
begin
points[i].x:=points[i].x+offset;
points[i].y:=points[i].y+offset;
end;
end;
//------------------------------------------------------------------------------
Procedure TCleDX3DCanvas.setstyle(styl:TCleDX3DStyle);
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
procedure TCleDX3DCanvas.MoveTo(X, Y: Integer);
begin

     FScreen.Back.canvas.moveto(x,y);
end;
//------------------------------------------------------------------------------
Procedure TCleDX3DCanvas.LineTo(X, Y: Integer);
var t:Tpoint ;
begin
with FScreen.Back.Canvas do

begin
     //Brush.style:=bsClear;
     //Pen.width:=1;
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

end.
