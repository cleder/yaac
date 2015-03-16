{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 
unit DGCStar;

interface

uses
  Windows, Messages, SysUtils, Classes,
   Graphics, Controls, Forms, Dialogs,DGC;

const
     MaxStars = 1000;
type

  TStar = Record
        X,Y,Z:Integer;
        end;

  TStarPos = Record
           X,Y:Integer;
        end;

  TDGCStarField = class(TComponent)
  private
    { Private declarations }
    FScreen:TDGCScreen;
    FStars:Array[1.. MaxStars] of TStar;
    FStarPos:Array[1..2,1..MaxStars] of TStarPos;
    FNumofStars:Integer;
    FStarVelocity:Word;
    FTowards:Boolean;
  protected
    { Protected declarations }
    Procedure SetNumOfstars(value:Integer);
    Procedure Calc2Dposition;
    Procedure DrawStars;
    Procedure MoveStars;
    Procedure ClearStars;
    Procedure CreateStars;
    Procedure Notification(AComponent: TComponent; Operation: TOperation);
  public
    { Public declarations }
    Constructor Create(Aowner:Tcomponent);Override;
    Procedure Update;
    Procedure Generate;
  published
    { Published declarations }
    Property NumberofStars:Integer read FNumofStars write FNumofStars;
    Property Velocity:Word read FStarVelocity write FStarVelocity;
    Property Towards:Boolean read FTowards Write FTowards;
    Property DGCScreen:TDGCScreen Read FScreen Write FScreen;
  end;

procedure Register;

implementation
Constructor TDGCStarField.Create(Aowner:Tcomponent);
begin
     Inherited create(Aowner);
     Fnumofstars:=200;
     FScreen:=nil;
     FStarVelocity:=2;
     FTowards:=True;
end;

Procedure TDGCStarField.Generate;
begin
     CreateStars;
     Calc2DPosition;
     DrawStars;
end;

Procedure TDGCStarField.Calc2DPosition;
var
   i:integer;
begin
     for i:= 1 to FNumofStars do
     begin
          FStarpos[1,i].X:=((FStars[i].X shl 7) div FStars[i].Z)+(FScreen.Back.Width div 2);
          FStarpos[1,i].Y:=((FStars[i].Y shl 7) div FStars[i].Z)+(FScreen.Back.height div 2);
     end;
end;

Procedure TDGCStarField.DrawStars;
var
   i,X,Y:integer;
begin
     for i:= 1 to FnumofStars do
     begin
          X:=FStarPos[1,i].X;
          Y:=FStarPos[1,i].Y;
          With FScreen.Back do
          begin
            if (X > 0) and (X < Width) and (Y > 0) and (Y < Height) then
              if FStars[i].Z > 400 then SetPixel(X,Y,240)
              else
                 if FStars[i].Z > 300 then SetPixel(X,Y,241)
                 else
                     if FStars[i].Z > 200 then SetPixel(X,Y,242)
                     else
                         if FStars[i].Z > 100 then SetPixel(X,Y,243)
                         else
                             setPixel(X,Y,rgb(30,30,244));
        end;
     end;
end;

Procedure TDGCStarField.ClearStars;
var
   i,X,Y:Integer;
begin
    Fscreen.Back.EraseRect(FScreen.Back.ClientRect, 0);
end;

Procedure TDGCStarField.MoveStars;
var
   i:integer;
begin
     if FTowards then
     begin
          for i:= 1 to Fnumofstars do
          begin
               FStars[i].Z:=FStars[i].Z-FStarVelocity;
               if FStars[i].Z < 1 then FStars[i].Z:=FStars[i].Z + Fnumofstars;
          end;
     end
     else
     begin
          for i:= 1 to Fnumofstars do
          begin
               FStars[i].Z:=FStars[i].Z+FStarVelocity;
               if FStars[i].Z > Fnumofstars then FStars[i].Z:=FStars[i].Z - Fnumofstars;
          end;
     end;
end;

Procedure TDGCStarField.Update;
begin
     FStarPos[2]:=FStarpos[1];
     Calc2dPosition;
     ClearStars;
     DrawStars;
     Movestars;
end;

Procedure TDGCStarField.CreateStars;
var
   i:integer;
begin
     for i:= 1 to Fnumofstars do
     begin
          repeat
                FStars[i].X:=Random(FScreen.Back.width) - (FScreen.Back.Width div 2);
                FStars[i].Y:=Random(FScreen.Back.Height) - (FScreen.Back.Height div 2);
                FStars[i].Z:=I;
          Until (FStars[i].X <> 0) and (FStars[i].Y <> 0);
    end;
end;

Procedure TDGCStarField.SetNumofStars(value:Integer);
begin
     if (value <> FNumofstars) then
     begin
          if value > 1000 then
             value:=1000;
          FNumofstars:=Value;
          if Fscreen <> nil then
             CreateStars;
     end;
end;

procedure TDGCStarField.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
       if FScreen = AComponent then
          FScreen := nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('DGC', [TDGCStarField]);
end;

end.
