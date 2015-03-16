{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit DGCFx;

interface

uses
  Windows, Messages, SysUtils, Classes,
   Graphics, Controls, Forms, Dialogs,DDraw,DGC,bmputil;

const
     IntroLibId ='CR10';
type


  TDGCEffects = class(Tobject)
  private
    { Private declarations }
    FFXSurface:TDGcSurface;
    FEffect:TEffect;
    FScreen:TDGCScreen;
    FSpeed:Integer;
    DripArray:Array [0..800] of integer;
  protected
    { Protected declarations }
    OrgTop,OrgBottom:Double;
    Swidth,SHeight:Integer;
    SRatio:Double;
    R,R2:TRect;
    Procedure SetEffect(value:Teffect);
    Function DoDelay:Boolean;
    Procedure AppearNone;
    Procedure AppearSlideRight;
    Procedure AppearSlideLeft;
    Procedure AppearSlideUp;
    Procedure AppearSlideDown;
    Procedure AppearZoomOpen;
    Procedure AppearQuarters;
    Procedure AppearCurtains;
    Procedure AppearShutters;
    Procedure AppearHorizontalLines;
    Procedure AppearVerticalLines;
    Procedure AppearLeftRightLines;
    Procedure AppearUpDownLines;
    Procedure AppearScrollright;
    Procedure AppearScrollLeft;
    Procedure AppearScrollDown;
    Procedure AppearScrollUp;
    Procedure AppearDrip;
    Procedure AppearHOpenOut;
    Procedure AppearVOpenOut;
    Procedure AppearDiagTopLeft;
    Procedure AppearDiagTopRight;
    Procedure AppearDiagBottomLeft;
    Procedure AppearDiagBottomRight;
    Procedure AppearLargeVertStripes;
    Procedure AppearVertStripes;
    Procedure AppearLargeHorzStripes;
    Procedure AppearHorzStripes;
    Procedure AppearQuarteredStripes;
    Procedure AppearTest;
  public
    { Public declarations }
    Constructor Create(AOwner:TComponent);
    Procedure Appear(Appearsurface:TDGCSurface;CopytoBack:Boolean);
    Destructor Destroy;Override;
  published
    { Published declarations }
    Property Effect:TEffect read FEffect write SetEffect;
    Property DGCScreen:TDGCScreen Read FScreen write FScreen;
    Property Speed:Integer read FSpeed write FSpeed;
  end;



implementation


Constructor TDGCEffects.Create(Aowner:TComponent);
begin
     Inherited Create;
     FEffect:=None;
     FSpeed:=5;
     FFXSurface:=nil;
end;

Destructor TDGCEffects.Destroy;
begin
     if FFXSurface <> nil Then
        FFXSurface.Free;
end;

Procedure TDGCEffects.SetEffect(value:Teffect);
begin
     if value <> Feffect then
        Feffect:=Value;
end;


function TDGCEffects.DoDelay:boolean;
var
   Delay:Cardinal;
begin
     result:=false;
     if FScreen.keyDown(vk_escape) then
             result:=true;
     for delay:=1 to Fspeed*50000 do ;

end;



Procedure TDGCEffects.AppearHopenout;
var
   i,j:integer;
   X,Y:Integer;
begin
     SWidth:=FScreen.Front.Width Div 2;
     R:=Rect(Swidth-1,0,Swidth+1,FScreen.Front.height);
     for  i := Swidth to Fscreen.Front.Width-1 do
     begin
          FScreen.Front.BltFast(R.left,0,FFXSurface,R,false);
          if DoDelay then exit;
          R.left:=R.Left -1;
          R.Right:=R.right+1;
     end;
end;

Procedure TDGCEffects.AppearDiagTopLeft;
var
    i,j:integer;
    X,Y:Integer;
begin
     X:=0;
     Y:=0;
     while (X < FScreen.Front.Width-4) or (Y < FScreen.Front.height-4) do
     begin
          inc(X,4);
          if FScreen.keyDown(vk_escape) then
             exit;
          if X > FScreen.Front.Width-4 then
          begin
               X := FScreen.Front.Width-4;
               If Y < FScreen.Front.Height-4 then
                  inc(Y,4);
          end;
          i:=X;
          J:=Y;
          While True do
          begin
               FScreen.Front.bltFast(i,j,FFxSurface,Rect(i,j,i+4,j+4),false);
               dec(i);
               inc(j);
               if (i < 0) or (j > FScreen.Front.Height-4) or (i > FScreen.Front.Width-4) then
                  break;
          end;
     end;
end;

Procedure TDGCEffects.AppearDiagTopRight;
var
    i,j:integer;
    X,Y:Integer;
begin
     X:=FScreen.Front.Width;
     Y:=0;
     while (Y < FScreen.Front.height-4) or (X > 0) do
     begin
          dec(X,4);
          if FScreen.keyDown(vk_escape) then
             exit;
          if X < 0 then
          begin
               X := 0;
               If Y < FScreen.Front.height then
                  inc(y,4);
          end;
          i:=X;
          J:=Y;
          While True do
          begin
               FScreen.Front.bltFast(i,j,FFxSurface,Rect(i,j,i+4,j+4),false);
               inc(i);
               inc(j);
               if (i < 0) or (j > FScreen.Front.Height-4) or (i > FScreen.Front.Width-4) then
                  break;
          end;
     end;
end;

Procedure TDGCEffects.AppearDiagBottomLeft;
var
    i,j:integer;
    X,Y:Integer;
begin
     X:=0;
     Y:=FScreen.Front.Height;
     while (X < FScreen.Front.Width-4) or (Y < 0) do
     begin
          dec(Y,4);
          if FScreen.keyDown(vk_escape) then
             exit;
          if Y < 0 then
          begin
               Y := 0;
               If X < FScreen.Front.width then
                  inc(X,4);
          end;
          i:=X;
          J:=Y;
          While True do
          begin
               FScreen.Front.bltFast(i,j,FFxSurface,Rect(i,j,i+4,j+4),false);
               inc(i);
               inc(j);
               if (i < 0) or (j > FScreen.Front.Height-4) or (i > FScreen.Front.Width-4) then
                  break;
          end;
     end;
end;

Procedure TDGCEffects.AppearDiagBottomRight;
var
    i,j:integer;
    X,Y:Integer;
begin
     X:=FScreen.Front.Width - 4;
     Y:=FScreen.Front.Height ;
     while (Y > 0) or (X > 0) do
     begin
          dec(y,4);
          if FScreen.keyDown(vk_escape) then
             exit;
          if y < 0 then
          begin
               y := 0;
               If x > 0 then
                  dec(x,4);
          end;
          i:=X;
          J:=Y;
          While True do
          begin
               FScreen.Front.bltFast(i,j,FFxSurface,Rect(i,j,i+4,j+4),false);
               dec(i);
               inc(j);
               if (i < 0) or (j > FScreen.Front.Height-4) or (j<0) then
                  break;
          end;
     end;
end;


Procedure TDGCEffects.Appearvopenout;
var
   i:integer;
begin
     Sheight:=FScreen.Front.height Div 2;
     R:=Rect(0,Sheight-1,FScreen.Front.width,Sheight+1);
     for  i := Sheight to Fscreen.Front.height-1 do
     begin
          FScreen.Front.BltFast(0,R.Top,FFXSurface,R,false);
          if DoDelay then exit;
          R.top:=R.top -1;
          R.bottom:=R.bottom+1;
     end;
end;

Procedure TDGCEffects.AppearNone;
begin
     FScreen.Front.BltFast(0,0,FFXSurface,FScreen.Front.Clientrect,False);
end;

Procedure TDGCEffects.AppearSlideRight;
Var
   i:Integer;
begin
     for i:= 1 to Fscreen.Front.Width do
     begin
          FScreen.Front.BltFast(0,0,FFXSurface,Rect(0,0,i,FScreen.Front.Height),false);
          if DoDelay then exit;
     end;
end;

Procedure TDGCEffects.AppearSCrollRight;
Var
   i:Integer;
begin
     for i:= Fscreen.Front.Width-1 downto 1 do
     begin
          FScreen.Front.BltFast(0,0,FFXSurface,Rect(i,0,FScreen.Front.width,FScreen.Front.Height),false);
          if DoDelay then exit;
     end;
end;

Procedure TDGCEffects.AppearSCrollLeft;
Var
   i:Integer;
begin
     for i:=1 to  Fscreen.Front.Width-1 do
     begin
          FScreen.Front.BltFast(Fscreen.Front.Width - i,0,FFXSurface,Rect(0,0,i,FScreen.Front.Height),false);
          if DoDelay then exit;
     end;
end;

Procedure TDGCEffects.AppearSlideLeft;
Var
   i:Integer;
begin
     for i:= Fscreen.Front.Width-1 downto 1 do
     begin
          FScreen.Front.BltFast(i,0,FFXSurface,Rect(i,0,FScreen.Front.width,FScreen.Front.Height),false);
          if DoDelay then exit;
     end;
end;

Procedure TDGCEffects.AppearSCrollUp;
Var
   i:Integer;
begin
     for i:= 1 to Fscreen.Front.Height-1 do
     begin
          FScreen.Front.BltFast(0,Fscreen.Front.Height-i,FFXSurface,Rect(0,0,FScreen.Front.width,i),false);
          if DoDelay then exit;
     end;
end;

Procedure TDGCEffects.AppearSlideUp;
Var
   i:Integer;
begin
     for i:= Fscreen.Front.Height-1 downto 1 do
     begin
          FScreen.Front.BltFast(0,i,FFXSurface,Rect(0,i-1,FScreen.Front.width,FScreen.Front.Height-1),false);
          if DoDelay then exit;
     end;
end;

Procedure TDGCEffects.AppearSlideDown;
Var
   i:Integer;
begin
     for i:= 1 to Fscreen.Front.Height do
     begin
         FScreen.Front.BltFast(0,0,FFXSurface,Rect(0,0,FScreen.Front.width,i),false);
         DoDelay;
     end;
end;

Procedure TDGCEffects.AppearSCrollDown;
Var
   i:Integer;
begin
     for i:= Fscreen.Front.Height-1 downto 1 do
     begin
         FScreen.Front.BltFast(0,0,FFXSurface,Rect(0,i,FScreen.Front.width,Fscreen.Front.Height),false);
         if dodelay then exit;
     end;
end;


Procedure TDGCEffects.AppearDrip;
var
   k,i:integer;
   r:trect;
       function allatbottom:boolean;
       var
          temp:boolean;
          j:integer;
       begin
            temp:=true;
            for j:=0 to FFXsurface.width-1 do
              if dripArray[j] < FFXsurface.height then
                 temp:=False;

            result:=temp;
       end;

begin
    // set back to start
    for k:= 0 to 800 do
       DripArray[k]:=1;
    repeat
          for k:= 0 to FFXSurface.Width-1 do
              DripArray[k]:=DripArray[k]+Random(16);

          for i:= 0 to FFXSurface.width - 1 do
          begin
              if driparray[i] > FFxSurface.height then
                 driparray[i]:=FFXSurface.Height;
              FScreen.Front.bltfast(i,0,FFxSurface,rect(i,0,i+1,DripArray[i]),false);
          end;
          if FScreen.keyDown(vk_escape) then
             exit;
    until allatbottom;
end;

Procedure TDGCEffects.AppearZoomOpen;
Var
   i:Integer;
begin
     SWidth:=FScreen.Front.Width Div 2;
     SHeight:=FScreen.Front.height Div 2;
     SRatio:=Sheight / Swidth;
     R:=Rect(Swidth-1,Sheight-1,Swidth+1,Sheight+1);
     Orgtop:=R.Top;
     OrgBottom:=R.Bottom;
     for  i := Swidth to Fscreen.Front.Width-1 do
     begin
          FScreen.Front.BltFast(R.left,R.top,FFXSurface,R,false);
          if dodelay then exit;
          R.left:=R.Left -1;
          R.Right:=R.right+1;
          OrgTop:=OrgTop-Sratio;
          OrgBottom:=OrgBottom+Sratio;
          R.top:=round(OrgTop);
          R.Bottom:=round(OrgBottom);
     end;
end;

Procedure TDGCEffects.AppearCurtains;
Var
   i:Integer;
begin
     for i:= 1 to Fscreen.Front.Width div 2 do
     begin
          FScreen.Front.BltFast(0,0,FFXSurface,Rect(0,0,i,FScreen.Front.Height),false);
          FScreen.Front.BltFast((FScreen.Front.Width-i),0,FFXSurface,Rect(FScreen.Front.Width-i,0,
                                 FScreen.Front.Width,FScreen.Front.Height),false);
          if dodelay then exit;
     end;
end;

Procedure TDGCEffects.AppearShutters;
Var
   i:Integer;
begin
     for i:= 1 to Fscreen.Front.height div 2 do
     begin
          FScreen.Front.BltFast(0,0,FFXSurface,Rect(0,0,FScreen.Front.width,i),false);
          FScreen.Front.BltFast(0,(FScreen.Front.height-i),FFXSurface,Rect(0,FScreen.Front.height-i,
                                FScreen.Front.Width,FScreen.Front.Height),false);
          if dodelay then exit;
     end;
end;

Procedure TDGCEffects.AppearTest;
var
   X,Y:integer;
   StripesizeX:Integer;
   StripeSizeY:Integer;
Begin
     StripeSizeX:=round(Fscreen.Front.Width / 2);
     StripeSizeY:=Round(FScreen.Front.Height / 2)-1;
     For Y:=1 to StripeSizeY do
     begin
          For X:= 1 to stripesizeX do
          begin
               FScreen.Front.BltFast(X,Y,FFxSurface,rect(X,Y,X+1,Y+1),False);
               FScreen.Front.BltFast(X,StripeSizeY+Y,FFxSurface,rect(X,StripeSizeY+Y,X+1,StripeSizeY+Y+1),False);
               FScreen.Front.BltFast(StripesizeX-1+X,FScreen.Front.Height-Y-StripeSizeY,FFxSurface,rect(StripeSizeX-1+X,FScreen.Front.Height-Y-StripeSizeY,StripeSizeX-1+X+1,Fscreen.Front.Height-Y+1-StripesizeY),False);
               FScreen.Front.BltFast(StripeSizeX-1+X,FScreen.Front.height-Y,FFxSurface,rect(StripeSizeX-1+X,Fscreen.Front.Height-Y,StripeSizeX-1+X+1,FScreen.Front.Height-Y+1),False);
          end;
     end;
end;

Procedure TDGCEffects.AppearQuarteredStripes;
var
   X,Y:integer;
   StripesizeX:Integer;
   StripeSizeY:Integer;
Begin
     StripeSizeX:=round(Fscreen.Front.Width / 2);
     StripeSizeY:=Round(FScreen.Front.Height / 2)-1;
     For Y:=1 to StripeSizeY do
     begin
          For X:= 1 to stripesizeX do
          begin
               FScreen.Front.BltFast(X,Y,FFxSurface,rect(X,Y,X+1,Y+1),False);
               FScreen.Front.BltFast(X,StripeSizeY+Y,FFxSurface,rect(X,StripeSizeY+Y,X+1,StripeSizeY+Y+1),False);
               FScreen.Front.BltFast(StripesizeX-1+X,FScreen.Front.Height-Y-StripeSizeY,FFxSurface,rect(StripeSizeX-1+X,FScreen.Front.Height-Y-StripeSizeY,StripeSizeX-1+X+1,Fscreen.Front.Height-Y+1-StripesizeY),False);
               FScreen.Front.BltFast(StripeSizeX-1+X,FScreen.Front.height-Y,FFxSurface,rect(StripeSizeX-1+X,Fscreen.Front.Height-Y,StripeSizeX-1+X+1,FScreen.Front.Height-Y+1),False);
          end;
     end;
end;

Procedure TDGCEffects.AppearLargeVertStripes;
var
   X,Y:integer;
   Stripesize:Integer;
Begin
     StripeSize:=round(Fscreen.Front.Width / 4);
     For Y:=1 to Fscreen.Front.Height-1 do
     begin
          For X:= 1 to stripesize do
          begin
               FScreen.Front.BltFast(X,Y,FFxSurface,rect(X,Y,X+1,Y+1),False);
               FScreen.Front.BltFast((Stripesize*2)+X,Y,FFxSurface,rect((Stripesize*2)+X,Y,(Stripesize*2)+X+1,Y+1),False);
               FScreen.Front.BltFast(Stripesize+X,Fscreen.Front.Height-Y,FFxSurface,rect(Stripesize+X,Fscreen.Front.Height-Y,StripeSize+X+1,Fscreen.Front.Height-Y+1),False);
               FScreen.Front.BltFast(((Stripesize-1)*3)+X,Fscreen.Front.Height-Y,FFxSurface,rect(((Stripesize-1)*3)+X,Fscreen.Front.Height-Y,((Stripesize-1)*3)+X+1,Fscreen.Front.Height-Y+1),False);
          end;
     end;
end;

Procedure TDGCEffects.AppearLargeHorzStripes;
var
   X,Y:integer;
   Stripesize:Integer;
Begin
     StripeSize:=round(Fscreen.Front.height / 4);
     For X:=1 to Fscreen.Front.width-1 do
     begin
          For Y:= 1 to stripesize do
          begin
               FScreen.Front.BltFast(X,Y,FFxSurface,rect(X,Y,X+1,Y+1),False);
               FScreen.Front.BltFast(X,(Stripesize*2)+Y,FFxSurface,rect(X,(Stripesize*2)+Y,X+1,(Stripesize*2)+Y+1),False);
               FScreen.Front.BltFast(Fscreen.Front.width-X,StripeSize+Y,FFxSurface,rect(Fscreen.Front.width-X,Stripesize+Y,Fscreen.Front.Width-X+1,StripeSize+Y+1),False);
               FScreen.Front.BltFast(Fscreen.Front.width-X,((StripeSize-1)*3)+Y,FFxSurface,rect(Fscreen.Front.width-X,((Stripesize-1)*3)+Y,Fscreen.Front.Width-X+1,((StripeSize-1)*3)+Y+1),False);
          end;
     end;
end;

Procedure TDGCEffects.AppearHorzStripes;
var
   X,Y:integer;
   Stripesize:Integer;
Begin
     StripeSize:=round(Fscreen.Front.height / 8);
     For X:=1 to Fscreen.Front.width-1 do
     begin
          For Y:= 1 to stripesize do
          begin
               FScreen.Front.BltFast(X,Y,FFxSurface,rect(X,Y,X+1,Y+1),False);
               FScreen.Front.BltFast(X,(Stripesize*2)+Y,FFxSurface,rect(X,(Stripesize*2)+Y,X+1,(Stripesize*2)+Y+1),False);
               FScreen.Front.BltFast(X,(Stripesize*4)+Y,FFxSurface,rect(X,(Stripesize*4)+Y,X+1,(Stripesize*4)+Y+1),False);
               FScreen.Front.BltFast(X,(Stripesize*6)+Y,FFxSurface,rect(X,(Stripesize*6)+Y,X+1,(Stripesize*6)+Y+1),False);
               FScreen.Front.BltFast(Fscreen.Front.width-X,StripeSize+Y,FFxSurface,rect(Fscreen.Front.width-X,Stripesize+Y,Fscreen.Front.Width-X+1,StripeSize+Y+1),False);
               FScreen.Front.BltFast(Fscreen.Front.width-X,(StripeSize*3)+Y,FFxSurface,rect(Fscreen.Front.width-X,(Stripesize*3)+Y,Fscreen.Front.Width-X+1,(StripeSize*3)+Y+1),False);
               FScreen.Front.BltFast(Fscreen.Front.width-X,(StripeSize*5)+Y,FFxSurface,rect(Fscreen.Front.width-X,(Stripesize*5)+Y,Fscreen.Front.Width-X+1,(StripeSize*5)+Y+1),False);
               FScreen.Front.BltFast(Fscreen.Front.width-X,((StripeSize-1)*7)+Y,FFxSurface,rect(Fscreen.Front.width-X,((Stripesize-1)*7)+Y,Fscreen.Front.Width-X+1,((StripeSize-1)*7)+Y+1),False);
          end;
     end;
end;

Procedure TDGCEffects.AppearVertStripes;
var
   X,Y:integer;
   Stripesize:Integer;
Begin
     StripeSize:=round(Fscreen.Front.Width / 8);
     For Y:=1 to Fscreen.Front.Height-1 do
     begin
          For X:= 1 to stripesize do
          begin
               FScreen.Front.BltFast(X,Y,FFxSurface,rect(X,Y,X+1,Y+1),False);
               FScreen.Front.BltFast((Stripesize*2)+X,Y,FFxSurface,rect((Stripesize*2)+X,Y,(Stripesize*2)+X+1,Y+1),False);
               FScreen.Front.BltFast((Stripesize*4)+X,Y,FFxSurface,rect((Stripesize*4)+X,Y,(Stripesize*4)+X+1,Y+1),False);
               FScreen.Front.BltFast((Stripesize*6)+X,Y,FFxSurface,rect((Stripesize*6)+X,Y,(Stripesize*6)+X+1,Y+1),False);
               FScreen.Front.BltFast(Stripesize+X,Fscreen.Front.Height-Y,FFxSurface,rect(Stripesize+X,Fscreen.Front.Height-Y,StripeSize+X+1,Fscreen.Front.Height-Y+1),False);
               FScreen.Front.BltFast((Stripesize*3)+X,Fscreen.Front.Height-Y,FFxSurface,rect((Stripesize*3)+X,Fscreen.Front.Height-Y,(Stripesize*3)+X+1,Fscreen.Front.Height-Y+1),False);
               FScreen.Front.BltFast((Stripesize*5)+X,Fscreen.Front.Height-Y,FFxSurface,rect((Stripesize*5)+X,Fscreen.Front.Height-Y,(Stripesize*5)+X+1,Fscreen.Front.Height-Y+1),False);
               FScreen.Front.BltFast(((Stripesize-1)*7)+X,Fscreen.Front.Height-Y,FFxSurface,rect(((Stripesize-1)*7)+X,Fscreen.Front.Height-Y,((Stripesize-1)*7)+X+1,Fscreen.Front.Height-Y+1),False);
          end;
     end;
end;

Procedure TDGCEffects.AppearQuarters;
Var
   i:Integer;
begin
     SWidth:=FScreen.Front.Width Div 4;
     SHeight:=FScreen.Front.height Div 4;
     SRatio:=Sheight / Swidth;
     R:=Rect(Swidth-1,Sheight-1,Swidth+1,Sheight+1);
     R2:=R;
     Orgtop:=R.Top;
     OrgBottom:=R.Bottom;
     for  i := Swidth to Fscreen.Front.Width div 2-1 do
     begin
          R2:=R;
          FScreen.Front.BltFast(R.left,R.top,FFXSurface,R,false);
          R2.Left:=R2.Left+(FScreen.Front.width div 2);
          R2.Right:=R2.Right+(FScreen.Front.width div 2);
          FScreen.Front.BltFast(R.left+(FScreen.Front.width div 2),R.top,FFXSurface,R2,false);
          R2.Top:=R2.Top+(FScreen.Front.height div 2);
          R2.Bottom:=R2.Bottom+(FScreen.Front.height div 2);
          FScreen.Front.BltFast(R.left+(FScreen.Front.width div 2),R.top+(FScreen.Front.Height div 2),FFXSurface,R2,false);
          R2.Left:=R.left;
          R2.Right:=R.Right;
          FScreen.Front.BltFast(R.left,R.top+(FScreen.Front.Height div 2),FFXSurface,R2,false);
          if dodelay then exit;
          R.left:=R.Left -1;
          R.Right:=R.right+1;
          OrgTop:=OrgTop-Sratio;
          OrgBottom:=OrgBottom+Sratio;
          R.top:=round(OrgTop);
          R.Bottom:=round(OrgBottom);
     end;
end;

Procedure TDGCEffects.AppearVerticalLines;
var
   i,j:Integer;
begin
    for j:= 0 to 5 do
    begin
         i:=J;
         while i <  FScreen.Front.width  do
         begin
              FScreen.Front.BltFast(i,0,FFXSurface,Rect(i,0,i+1,FScreen.Front.Height),False);
              inc(i,5);
              if dodelay then exit;
         end;
    end;
end;

Procedure TDGCEffects.AppearHorizontalLines;
var
   i,j:integer;
begin
    for j:= 0 to 5 do
    begin
         i:=J;
         while i <  FScreen.Front.Height  do
         begin
              FScreen.Front.BltFast(0,i,FFXSurface,Rect(0,i,FScreen.Front.Width,i+1),False);
              inc(i,5);
              if dodelay then exit;
         end;
    end;
end;

Procedure TDGCEffects.AppearUpDownLines;
var
   i,j:integer;
begin
    for j:= 0 to 3 do
    begin
         i:=J;
         while i <  FScreen.Front.Height  do
         begin
              FScreen.Front.BltFast(0,i,FFXSurface,Rect(0,i,FScreen.Front.Width,i+1),False);
              inc(i,4);
              if dodelay then exit;
         end;
         dec(i,4);
         while i >  0  do
         begin
              FScreen.Front.BltFast(0,i,FFXSurface,Rect(0,i-1,FScreen.Front.Width,i),False);
              Dec(i,4);
              if dodelay then exit;
         end;
    end;
end;

Procedure TDGCEffects.AppearLeftRightLines;
var
   i,j:integer;
begin
    for j:= 0 to 1 do
    begin
         i:=J;
         while i <  FScreen.Front.width  do
         begin
              FScreen.Front.BltFast(i,0,FFXSurface,Rect(i,0,i+1,FScreen.Front.Height),False);
              inc(i,4);
              if dodelay then exit;
         end;
         dec(i,2);
         while i >  1  do
         begin
              FScreen.Front.BltFast(i,0,FFXSurface,Rect(i,0,i+1,FScreen.Front.Height),False);
              Dec(i,4);
              if dodelay then exit;
         end;
    end;
end;

Procedure TDGCEffects.Appear(Appearsurface:TDGCSurface;copytoback:Boolean);
begin
     if FFXSurface = nil then
        FFXSurface := TDGCSurface.Create(FScreen.DirectDraw, Fscreen.Back.Width,Fscreen.Back.Height);
     FFxSurface.StretchDraw(rect(0,0,FfxSurface.Width,FfxSurface.Height),AppearSurface,false);
     //Flip the hidden surface with the visible one so you can
     Case FEffect of
             None:AppearNone;
       SlideRight:AppearSlideRight;
        SlideDown:AppearSlideDown;
          SlideUp:AppearSlideUp;
        SlideLeft:AppearSlideLeft;
         ZoomOpen:AppearZoomOpen;
         Curtains:AppearCurtains;
         shutters:AppearShutters;
         Quarters:AppearQuarters;
  HorizontalLines:AppearHorizontalLines;
    VerticalLines:AppearVerticalLines;
      UpDownLines:AppearUpDownLines;
   LeftRightLines:AppearLeftRightLines;
   ScrollRight:AppearScrollRight;
   ScrollLeft:AppearScrollleft;
   Scrolldown:AppearScrollDown;
   ScrollUp:AppearScrollUp;
   Drip:AppearDrip;
   HorizontalOpenOut:AppearHopenOut;
   VerticalOpenOut:AppearVopenOut;
   DiagonalTopLeft:AppearDiagTopLeft;
   DiagonalBottomRight:AppearDiagBottomRight;
   DiagonalBottomLeft:AppearDiagBottomLeft;
   DiagonalTopRight:AppearDiagTopRight;
   VerticalStripes:AppearVertStripes;
   HorizontalStripes:AppearHorzStripes;
   LargeVerticalStripes:AppearLargeVertStripes;
   LargeHorizontalStripes:AppearLargeHorzStripes;
   FollowMe:AppearQuarteredStripes;
     end;
   If (FScreen <> nil ) and (CopyToBack) then
   begin
          FScreen.Back.BltFast(0, 0, FScreen.Front, FScreen.Back.ClientRect, false);
          FScreen.Flip;
   end;
end;

end.
