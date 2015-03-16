{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit dgcspts;

interface

uses
  Windows, SysUtils, Classes, DGC, Math;

const
     FPMultiplier = 65536.0000000;
     MaxFrames = 32;
     CosTab: array[0..31] of LongInt = (0, 12785, 25080,
             36410, 46341, 54491, 60547, 64277, 65536,
             64277, 60547, 54491, 46341, 36410, 25080,
             12785, 0, -12785, -25080, -36410, -46341,
             -54491, -60547, -64277, -65536, -64277,
             -60547, -54491, -46341, -36410, -25080,
             -12785);
     SinTab: array[0..31] of LongInt = (-65536, -64277,
             -60547, -54491, -46341, -36410, -25080,
             -12785, 0, 12785, 25080, 36410, 46341,
             54491, 60547, 64277, 65536, 64277, 60547,
             54491, 46341, 36410, 25080, 12785, 0,
             -12785, -25080, -36410, -46341, -54491,
             -60547, -64277);

type
  //Fixed Point coords
  TFixedReal = record
         case byte of
              0: (Value: LongInt);
              1: (Frac: Word;
                  Int: SmallInt);
  end;

  //Movement type
  TLimitsAction = (laNone,laReverse, laStopInside, laStopOutside, laWrap, laEvent,
                   laBounce);
  TLimitsSide = (lsLeft, lsTop, lsRight, lsBottom);

  //Animation types
  TFramesInfo = record
        Speed: Integer;
        FrameCount: Integer;
        Frame: array[0..MaxFrames - 1] of Cardinal;
  end;
  PFramesInfo = ^TFramesInfo;

  //Declare classes
  TDGCSprites = class;
  TDGCAnimations = class;
  TDGCBouncer = class;
  TDGCRaceCar = class;
  TDGCPlayer8 = class;
  TDGCThruster = Class;
  TDGCSprite = class;

  //Events
  TDGCSpriteMoved = procedure(Sprite: TDGCSprite) of object;
  TDGCSpriteEvent = procedure(Sprite: TDGCSprite; LimitsSide: TLimitsSide) of Object;
  TDGCAnimationEnd = procedure(Sprite: TDGCSprite) of object;

  //Sprite Manager Component
  //========================
  TDGCSpriteMgr = class(TComponent)
  private
    { Private declarations }
    FSprites: TDGCSprites;
    FAnimations: TDGCAnimations;
    FScreen: TDGCScreen;
    FOnSpriteMoved: TDGCSpriteMoved;
    FOnSpriteDirChange: TDGCSpriteEvent;
    FOnSpriteStopped: TDGCSpriteEvent;
    FOnSpriteEvent: TDGCSpriteEvent;
    FOnAnimationEnd: TDGCAnimationEnd;
    FKeyUp: Word;
    FKeyDown: Word;
    FKeyLeft: Word;
    FKeyRight: Word;
    FKeyFire1: Word;
    FKeyFire2: Word;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update;
    procedure Draw;
    property Animations: TDGCAnimations read FAnimations;
    property Sprites: TDGCSprites read FSprites;
  published
    { Published declarations}
    property DGCScreen: TDGCScreen read FScreen write FScreen;
    property KeyUp: Word read FKeyUp write FKeyUp;
    property KeyDown: Word read FKeyDown write FKeyDown;
    property KeyLeft: Word read FKeyLeft write FKeyLeft;
    property KeyRight: Word read FKeyRight write FKeyRight;
    property KeyFire1: Word read FKeyFire1 write FKeyFire1;
    property KeyFire2: Word read FKeyFire2 write FKeyFire2;
    property OnSpriteMoved: TDGCSpriteMoved read FOnSpriteMoved write
        FOnSpriteMoved;
    property OnSpriteDirChange: TDGCSpriteEvent read FOnSpriteDirChange write
        FOnSpriteDirChange;
    property OnSpriteStopped: TDGCSpriteEvent read FOnSpriteStopped write
        FOnSpriteStopped;
    property OnSpriteEvent: TDGCSpriteEvent read FOnSpriteEvent write
        FOnSpriteEVent;
    property OnAnimationEnd: TDGCAnimationEnd read FOnAnimationEnd write
        FOnAnimationEnd;

  end;


  //Animation Item Class
  //====================
  TDGCAnimation = class(TObject)
  private
    { Private declarations }
    FName: String;
    FLoop: Boolean;
    FFrames: array[0..31] of PFramesInfo;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(Name: String; ALoop: Boolean);
    destructor Destroy; override;
    procedure SetFrames(ADir: Cardinal; ASpeed: Integer; AFrames: array of Word);
    procedure SetAllDirections(ASpeed: Integer; AFrames: array of Word);
    function HasFrames(ADir: Cardinal): Boolean;
    function Frame(ADir, AFrame: Cardinal): Cardinal;
    function FrameCount(ADir: Cardinal): Cardinal;
    function Speed(ADir: Cardinal): Cardinal;
    property Name: String read FName write FName;
    property Loop: Boolean read FLoop write FLoop;
  end;

  //Base Sprite Class
  //=================
  TDGCSprite = class(TObject)
  private
    { Private declarations }
    function GetX: Smallint;
    procedure SetX(Value: SmallInt);
    function GetY: SmallInt;
    procedure SetY(Value: SmallInt);
    function GetVelX: double;
    procedure SetVelX(Value: double);
    function GetVelY: double;
    procedure SetVelY(Value: double);
    procedure SetActions(Value: TLimitsAction);
    procedure SetAnimation(Value: Integer);
    function GetFrame: Integer;
    function GetDec: double;
    procedure SetDec(Value: double);
    function GetAcc: double;
    procedure SetAcc(Value: double);
    function GetSpeed: double;
    procedure SetSpeed(Value: double);
    function GetMinSpeed: double;
    procedure SetMinSpeed(Value: double);
    function GetMaxSpeed: double;
    procedure SetMaxSpeed(Value: double);
    procedure SetDirection(Value: Integer);
  protected
    { Protected declarations }
    SpriteMgr: TDgcSpriteMgr;
    FX: TFixedReal;
    FY: TFixedReal;
    FVelX: TFixedReal;
    FListPos:Integer;
    FVelY: TFixedReal;
    FMaxSpeed: TFixedReal;
    FSpeed: TFixedReal;
    FMinSpeed: TFixedReal;
    FAcc: TFixedReal;
    FDec: TFixedReal;
    FLimits: TRect;
    FStopped: Boolean;
    FLeftAction: TLimitsAction;
    FRightAction: TLimitsAction;
    FTopAction: TLimitsAction;
    FBottomAction: TLimitsAction;
    FID:Integer;
    FWidth: Integer;
    FHeight: Integer;
    FVisible: Boolean;
    FEnabled: Boolean;
    FAnimation: Integer;
    FDirection: Integer;      //The movement direction
    FAnimDirection: Integer;  //The Animation direction
    FFrameNbr: Cardinal;
    FFrameCount: Cardinal;
    FAnimTickCount: DWord;
    FAnimInterval: DWord;
    FAutomatic: Boolean;
    procedure Update(TickCount: DWord); virtual; abstract;
    procedure CycleFrame(TickCount: DWord);
  { Public declarations }
  public
    Data: Pointer;
    constructor Create;
    procedure Accelerate;
    procedure Deccelerate;
    procedure FlipYDirection;
    procedure FlipXDirection;
    procedure CheckLimits;
    procedure Stop;
    procedure Resume;
    procedure Hide;
    procedure Show;
    procedure Enable;
    procedure Disable;
    Procedure LookAt(AnX,AnY:Integer);
    property X: SmallInt read GetX write SetX;
    property Y: SmallInt read GetY write SetY;
    property VelocityX: double read GetVelX write SetVelX;
    property VelocityY: double read GetVelY write SetVelY;
    property Speed: Double read GetSpeed write SetSpeed;
    property MinSpeed: Double read GetMinSpeed write SetMinSpeed;
    property MaxSpeed: Double read GetMaxSpeed write SetMaxSpeed;
    property Acceleration: double read GetAcc write SetAcc;
    property Decceleration: double read GetDec write SetDec;
    property Direction: Integer read FDirection write SetDirection;
    property Animation: Integer read FAnimation write SetAnimation;
    property Frame: Integer read GetFrame;
    property Automatic: Boolean read FAutomatic write FAutomatic;
    property Limits: TRect read FLimits write FLimits;
    property LeftAction: TLimitsAction read FLeftAction write FLeftAction;
    property RightAction: TLimitsAction read FRightAction write FRightAction;
    property TopAction: TLimitsAction read FTopAction write FTopAction;
    property BottomAction: TLimitsAction read FBottomAction write FBottomAction;
    property AllActions: TLimitsAction write SetActions;
    property ID: Integer read FID Write FID;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property Visible: Boolean read FVisible write FVisible;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Stopped: Boolean read FStopped write FStopped;
    Property ListPosition:Integer Read FListPos write FListPos;
  end;

  //TDGCBouncer Class
  //=================
  TDGCBouncer = class(TDGCSprite)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure Update(TickCount: DWord); override;
  public
    { Public declarations }
    constructor Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, ADir: Integer;
          ASpeed: Double; Animations: Integer); virtual;
  end;

  //TDGCRaceCar Class
  //=================
  TDGCRaceCar = class(TDGCSprite)
  private
    { Private declarations }
    FLastRotTick: Integer;
    FHandling: Integer;
  protected
    { Protected declarations }
    procedure Update(TickCount: DWord); override;
  public
    { Public declarations }
    constructor Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, ADir: Integer;
          ASpeed: Double; Animations: Integer); virtual;
    property Handling: Integer read FHandling write FHandling;
  end;

  TDGCThruster = class(TDGCSprite)
  private
    { Private declarations }
    FLastRotTick: Integer;
    FHandling: Integer;
    FCurrentDirection:Integer;
    procedure DrawAnimation(Value: Integer);
  protected
    { Protected declarations }
    procedure Update(TickCount: DWord); override;
  public
    { Public declarations }
    constructor Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, ADir: Integer;
          ASpeed: Double; Animations: Integer); virtual;
    property Handling: Integer read FHandling write FHandling;
    Property CurrentDirection:Integer Read FCurrentDirection Write FCurrentDirection;
  end;

  //TDGCPlayer8 Class
  //=====================
  TDGCPlayer8 = class(TDGCSprite)
  private
    { Private declarations }
    FActiveAnimation: Integer;
    FIdleAnimation: Integer;
    FAllowUp: Boolean;
    FAllowDown: Boolean;
    FAllowLeft: Boolean;
    FAllowRight: Boolean;
  protected
    { Protected declarations }
    procedure Update(TickCount: DWord); override;
  public
    { Public declarations }
    constructor Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, StartDir: Integer;
     AMaxSpeed: Double; Animations: Integer);
     property ActiveAnimation: Integer read FActiveAnimation write FActiveAnimation;
     property IdleAnimation: Integer read FIdleAnimation write FIdleAnimation;
     property AllowUp: Boolean read FAllowUp write FAllowUp;
     property AllowDown: Boolean read FAllowDown write FAllowDown;
     property AllowLeft: Boolean read FAllowLeft write FAllowLeft;
     property AllowRight: Boolean read FAllowRight write FAllowRight;
  end;


  //Animation List Class
  //====================
  TDGCAnimations = class(TObject)
  private
    { Private declarations }
    FAnimations: TList;
    procedure FreeAnimations;
    function GetAnimation(n: Integer): TDGCAnimation;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    function Add(Name: String; ALoop: Boolean): Integer;
    procedure Delete(n: Integer);
    property Objects[n: Integer]: TDGCAnimation read GetAnimation; default;
  end;

  //Sprites List Class
  //==================
  TDGCSprites = class(TObject)
  private
    { Private declarations }
    FSprites: TList;
    SpriteMgr: TDGCSpriteMgr;
    procedure FreeSprites;
    function GetSprite(n: Integer): TDGCSprite;
    function GetCount: Integer;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AMgr: TDGCSpriteMgr);
    destructor Destroy; override;
    function AddBouncer(ID, X, Y, Angle: Integer; Velocity: Double;
         Animations: Integer): Integer;
    function AddRaceCar(ID, X, Y, Angle: Integer; Velocity: Double;
         Animations: Integer): Integer;
    function AddThruster(ID, X, Y, Angle: Integer; Velocity: Double;
         Animations: Integer): Integer;
    function AddPlayer8(ID, X, Y, StartDir: Integer; MaxSpeed: Double;
         Animations: Integer): Integer;
    procedure MoveSprites(ID: Integer; AdjustPos: Boolean; X, Y: Integer;
          AdjustVel: Boolean; VelX, VelY: double);
    Procedure Delete(n:integer);      
    function Collision(s1, s2: Integer): Boolean;
    property Objects[n: Integer]: TDGCSprite read GetSprite; default;
    property Count: Integer read GetCount;
  end;


implementation

uses Trace;

function CosVal(Dir: Integer): Double;
begin
     Result := CosTab[Dir] / FPMultiplier;
end;

function SinVal(Dir: Integer): Double;
begin
     Result := SinTab[Dir] / FPMultiplier;
end;

//Sprite Manager Implementation
//=============================
constructor TDGCSpriteMgr.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FSprites := TDGCSprites.Create(Self);
     FAnimations := TDGCAnimations.Create;
     FKeyUp := VK_UP;
     FKeyDown := VK_DOWN;
     FKeyLeft := VK_LEFT;
     FKeyRight := VK_RIGHT;
     FKeyFire1 := VK_CONTROL;
     FKeyFIre2 := VK_MENU;

end;

destructor TDGCSpriteMgr.Destroy;
begin
     FSprites.Free;
     FAnimations.Free;
     inherited Destroy;
end;



procedure TDGCSpriteMgr.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
       if FScreen = AComponent then
          FScreen := nil;
  end;
end;

procedure TDGCSpriteMgr.Update;
var
   n: Integer;
   TickCount: DWord;
begin
     TickCount := GetTickCount ;
     for n := 0 to Pred(FSprites.Count) do
     begin
          with Sprites[n] as TDGCSprite do
          begin
               if Enabled then
                  Update(TickCount);
          end;
     end;
end;

procedure TDGCSpriteMgr.Draw;
var
   n, ImgNbr: Integer;
begin
     for n := 0 to Pred(Sprites.Count) do
     begin
          with Sprites[n] as TDGCSprite do
          begin
               if Visible then
               begin
                    ImgNbr := SpriteMgr.Animations[FAnimation].Frame(FAnimDirection, FFrameNbr);
                  SpriteMgr.DGCScreen.Back.Draw(X, Y, SpriteMgr.DGCScreen.Images[ImgNbr],
                     True);
               end;
          end;
     end;
end;

//Animations Item Implementation
//==============================
constructor TDGCAnimation.Create(Name: String; ALoop: Boolean);
begin
     FName := Name;
     FLoop := ALoop;
     ZeroMemory(@FFrames[0], SizeOf(FFrames));
end;

destructor TDGCAnimation.Destroy;
var
   n: Integer;
begin
     for n := 0 to 31 do
         if FFrames[n] <> nil then
            Dispose(FFrames[n]);
     inherited Destroy;
end;


procedure TDGCAnimation.SetFrames(ADir: Cardinal; ASpeed: Integer; AFrames: array of Word);
var
   n: Integer;
begin
     if FFrames[ADir] = nil then
        New(FFrames[Adir]);
     with FFrames[ADir]^ do
     begin
          FrameCount := High(AFrames) + 1;
          Speed := ASpeed;
          for n := 0 to High(AFrames) do
          begin
               Frame[n] := AFrames[n];
          end;
     end;
end;

procedure TDGCAnimation.SetAllDirections(ASpeed: Integer; AFrames: array of Word);
var
   n, d: Integer;
begin
     for d := 0 to 31 do
     begin
          if FFrames[d] = nil then
             New(FFrames[d]);
          with FFrames[d]^ do
          begin
               FrameCount := High(AFrames) + 1;
               Speed := ASpeed;
               for n := 0 to High(AFrames) do
               begin
                    Frame[n] := AFrames[n];
               end;
          end;
     end;
end;


function TDGCAnimation.HasFrames(ADir: Cardinal): Boolean;
begin
     Result := FFrames[ADir] <> nil;
end;

function TDGCAnimation.Frame(ADir, AFrame: Cardinal): Cardinal;
begin
     Result := FFrames[ADir]^.Frame[AFrame];
end;

function TDGCAnimation.Speed(ADir: Cardinal): Cardinal;
begin
     Result := FFrames[ADir]^.Speed;
end;

function TDGCAnimation.FrameCount(ADir: Cardinal): Cardinal;
begin
     Result := FFrames[ADir]^.FrameCount;
end;



//Animations List Implementation
//==============================
constructor TDGCAnimations.Create;
begin
     FAnimations := TList.Create;
end;

destructor TDGCAnimations.Destroy;
begin
     FreeAnimations;
     FAnimations.Free;
     inherited Destroy;
end;

procedure TDGCAnimations.FreeAnimations;
var
   n: Integer;
begin
     for n := 0 to Pred(FAnimations.Count) do
         TDGCAnimations(FAnimations[n]).Free;
     FAnimations.Clear;
end;

function TDGCAnimations.Add(Name: String; ALoop: Boolean): Integer;
var
   a: TDGCAnimation;
begin
     a := TDGCAnimation.Create(Name, ALoop);
     Result := FAnimations.Add(a);
end;

procedure TDGCAnimations.Delete(n: Integer);
begin
     TDGCAnimation(FAnimations[n]).Free;
     FAnimations.Delete(n);
end;

function TDGCAnimations.GetAnimation(n: Integer): TDGCAnimation;
begin
     Result := TDGCAnimation(FAnimations[n]);
end;

//Sprites List Implementation
//===========================
constructor TDGCSprites.Create(AMgr: TDGCSpriteMgr);
begin
     SpriteMgr := AMgr;
     FSprites := TList.Create;
end;

destructor TDGCSprites.Destroy;
begin
     FreeSprites;
     FSprites.Free;
     inherited Destroy;
end;

procedure TDGCSprites.FreeSprites;
var
   n: Integer;
begin
     for n := 0 to Pred(FSprites.Count) do
         TDGCSprite(FSprites[n]).Free;
     FSprites.Clear;
end;

procedure TDGCSprites.Delete(n: Integer);
begin
     TDGCSprite(FSprites[n]).Free;
     FSprites.Delete(n);
end;

function TDGCSprites.GetSprite(n: Integer): TDGCSprite;
begin
     Result := TDGCSprite(FSprites[n]);
end;

function TDGCSprites.AddBouncer(ID, X, Y, Angle: Integer; Velocity: Double;
            Animations: Integer): Integer;
var
   s: TDGCBouncer;
begin
     s := TDGCBouncer.Create(SpriteMgr, ID, X, Y, Angle, Velocity, Animations);
     Result := FSprites.Add(s);
     S.ListPosition:=Result;
end;

function TDGCSprites.AddRaceCar(ID, X, Y, Angle: Integer; Velocity: Double;
            Animations: Integer): Integer;
var
   s: TDGCRaceCar;
begin
     s := TDGCRaceCar.Create(SpriteMgr, ID, X, Y, Angle, Velocity, Animations);
     Result := FSprites.Add(s);
     S.ListPosition:=result;
end;

function TDGCSprites.AddThruster(ID, X, Y, Angle: Integer; Velocity: Double;
            Animations: Integer): Integer;
var
   s: TDGCThruster;
begin
     s := TDGCThruster.Create(SpriteMgr, ID, X, Y, Angle, Velocity, Animations);
     Result := FSprites.Add(s);
     S.ListPosition:=result;
end;



function TDGCSprites.AddPlayer8(ID, X, Y, StartDir: Integer; MaxSpeed: Double;
         Animations: Integer): Integer;
var
   s: TDGCPlayer8;
begin
     s := TDGCPlayer8.Create(SpriteMgr, ID, X, Y, StartDir, MaxSpeed, Animations);
     Result := FSprites.Add(s);
     S.ListPosition:=result;
end;


function TDGCSprites.GetCount: Integer;
begin
     Result := FSprites.Count;
end;

//This method will adjust or set the sprite positions and velocities for all
//sprites based on a sprite ID. If AdjustPos/AdjustPos is set to True the
// X/Y/VelX/VelY paramaters are added to the sprite values.
procedure TDGCSprites.MoveSprites(ID: Integer; AdjustPos: Boolean; X, Y: Integer;
          AdjustVel: Boolean; VelX, VelY: double);
var
   n: Cardinal;
   Spt: TDGCSprite;
begin
     for n := 0 to Pred(FSprites.Count) do
     begin
          Spt := FSprites[n];
          if (Spt.Enabled) and (Spt.ID = ID) then
          begin
               if AdjustPos then
               begin
                    Spt.X := Spt.X + X;
                    Spt.Y := Spt.Y + Y;
               end
               else
               begin
                   Spt.X := X;
                   Spt.Y := Y;
               end;
               if AdjustVel then
               begin
                    Spt.VelocityX := Spt.VelocityX + VelX;
                    Spt.VelocityY := Spt.VelocityY + VelY;
               end
               else
               begin
                    Spt.VelocityX := VelX;
                    Spt.VelocityY := VelY;
               end
          end;
     end;
end;

function TDGCSprites.Collision(s1, s2: Integer): Boolean;
var
   spt1, spt2: TDGCSprite;
   Img1, Img2: Integer;
begin
     Result:=false;
     spt1 := FSprites[s1];
     spt2 := FSprites[s2];
     if (not spt1.enabled) or (not spt2.enabled) then
        exit;
     Img1 := SpriteMgr.Animations[spt1.FAnimation].Frame(spt1.FAnimDirection, spt1.FFrameNbr);
     Img2 := SpriteMgr.Animations[spt2.FAnimation].Frame(spt2.FAnimDirection, spt2.FFrameNbr);
     Result := SpriteMgr.DGCScreen.Images[Img1].CollisionTest(spt1.X, spt1.Y,
          SpriteMgr.DGCScreen.Images[Img2], spt2.X, spt2.Y, True);
end;

//Base Sprite Class Implementation
//================================
//TDGCSprite Implementation
constructor TDGCSprite.Create;
begin
     FEnabled := True;
     FVisible := True;
     FVelX.Value := 0;
     FVelY.Value := 0;
     FAnimTickCount := 0;
     FFrameCount := 0;
     FFrameNbr := 0;
     Acceleration := 0;
     Decceleration := 0;
     Speed := 0;
     MinSpeed := 0;
     MaxSpeed := 0;
     FAutomatic := True;
     FDirection := 0;
     FAnimDirection := 0;
     FAnimation := 0;
     if SpriteMgr.DGCScreen <> nil then
        FLimits := SpriteMgr.DGCScreen.ClipRect;
end;


Procedure TDGCSprite.LookAt(AnX,AnY:Integer);
var
   orgx,orgy:integer;
   w,h,angle:extended;
begin
     // set org to center of sprite
     orgx:=X + (Width div 2);
     Orgy:=Y + (height div 2);
     w:=abs(Orgx - AnX);
     H:=abs(OrgY - AnY);
     angle:=Radtodeg(Arctan2(H,W));
     if (orgx < AnX) and (orgy > AnY) then
        angle:= abs(angle - 90);
     if (orgx < AnX) and (orgy < AnY) then
        angle:= abs(angle + 90);
     if (orgx > AnX) and (orgy < AnY) then
        angle:= abs(angle - 90) + 180;
     if (orgx > AnX) and (orgy > AnY) then
        angle:= abs(angle  + 270);
     direction:=round(angle / (360/32));
end;

{Procedure TDGCSprite.LookAt(AnX,AnY:Integer);
var
   w,h:Extended;
   angle:extended;
   tempdirection:integer;
begin
    w:=X-AnX;
    if w = 0 then w:=1;
    h:=Y-AnY;
    if h = 0 then h:=1;
    angle:=RadtoDeg(ArcTan2(H,W));
    if (angle >= 0) and (angle <= 90) then
    begin
         Direction := round(angle / (360/32))+24;
    end;
    if (angle >= 91) and (angle <= 180) then
    begin
         Direction:=round((angle - 90) / (360/32));
    end;
    if (angle <= -90) and (angle >= -180) then
    begin
         Direction := round((angle +180) / (360/32))+8;
    end;
    if (angle <= -1) and (angle >= -89) then
    begin
         Direction:=round((angle +90) / (360/32))+16;
    end;
end; }

procedure TDGCSprite.SetActions(Value: TLimitsAction);
begin
     FLeftAction := Value;
     FRightAction := Value;
     FTopAction := Value;
     FBottomAction := Value;
end;

function TDGCSprite.GetX: Smallint;
begin
     Result := FX.Int;
     if FX.Frac > $7FFF then Inc(Result); //Round
end;

procedure TDGCSprite.SetX(Value: SmallInt);
begin
     FX.Int := Value;
     FX.Frac := 0;
end;

function TDGCSprite.GetY: SmallInt;
begin
     Result := FY.Int;
     if FY.Frac > $7FFF then Inc(Result); //Round
end;

procedure TDGCSprite.SetY(Value: SmallInt);
begin
     FY.Int := Value;
     FY.Frac := 0;
end;

function TDGCSprite.GetVelX: double;
begin
     Result := FVelX.Value / FPMultiplier;
end;

procedure TDGCSprite.SetVelX(Value: double);
begin
     FVelX.Value := Round(Value * FPMultiplier);
end;

function TDGCSprite.GetVelY: double;
begin
     Result := FVelY.Value / FPMultiplier;
end;

procedure TDGCSprite.SetVelY(Value: double);
begin
     FVelY.Value := Round(Value * FPMultiplier);
end;

procedure TDGCSprite.SetAnimation(Value: Integer);
begin
     if FAnimation <> Value then
     begin
          FAnimation := Value;
          if not SpriteMgr.Animations[FAnimation].HasFrames(FDirection) then
             FDirection := 0;
          SetDirection(FDirection);
     end;
end;

function TDGCSprite.GetDec: double;
begin
     Result := FDec.Value / FPMultiplier;
end;

procedure TDGCSprite.SetDec(Value: double);
begin
     FDec.Value := Round(Value * FPMultiplier);
end;

function TDGCSprite.GetAcc: double;
begin
     Result := FAcc.Value / FPMultiplier;
end;

procedure TDGCSprite.SetAcc(Value: double);
begin
     FAcc.Value := Round(Value * FPMultiplier);
end;

function TDGCSprite.GetSpeed: double;
begin
     Result := FSpeed.Value / FPMultiplier;
end;

procedure TDGCSprite.SetSpeed(Value: double);
begin
     if FSpeed.Value > FMaxSpeed.Value then
        FSpeed.Value := FMaxSpeed.Value
     else
         if FSpeed.Value < FMinSpeed.Value then
            FSpeed.Value := FMinSpeed.Value;
     FSpeed.Value := Round(Value * FPMultiplier);
     VelocityX := CosVal(FDirection) * Speed;
     VelocityY := SinVal(FDirection) * Speed;
end;

function TDGCSprite.GetMaxSpeed: double;
begin
     Result := FMaxSpeed.Value / FPMultiplier;
end;

procedure TDGCSprite.SetMaxSpeed(Value: double);
begin
     FMaxSpeed.Value := Round(Value * FPMultiplier);
end;

function TDGCSprite.GetMinSpeed: double;
begin
     Result := FMinSpeed.Value / FPMultiplier;
end;

procedure TDGCSprite.SetMinSpeed(Value: double);
begin
     FMinSpeed.Value := Round(Value * FPMultiplier);
end;

procedure TDGCSprite.SetDirection(Value: Integer);
var
   ImgNbr: Integer;
begin
     FDirection := Value;
     //Only change animation direction if the slot has frames
     if SpriteMgr.Animations[FAnimation].HasFrames(FDirection) then
     begin
          FAnimDirection := FDirection;
          with SpriteMgr.Animations[FAnimation] do
          begin
               FAnimInterval := Speed(FAnimDirection);
               FFrameNbr := 0;
               FFrameCount := FrameCount(FAnimDirection);
               ImgNbr := Frame(FAnimDirection, 0);
               FWidth := SpriteMgr.DGCScreen.Images[ImgNbr].Width;
               FHeight := SpriteMgr.DGCScreen.Images[ImgNbr].Width;
               //TraceString(Format('FFrameNbr=%d, ', []);
          end;
     end;
     VelocityX := CosVal(FDirection) * Speed;
     VelocityY := SinVal(FDirection) * Speed;
end;

function TDGCSprite.GetFrame: Integer;
begin
     Result := SpriteMgr.Animations[FAnimation].Frame(FAnimDirection, FFrameNbr)
end;

procedure TDGCSprite.Accelerate;
var
   n: Integer;
begin
     if FSpeed.Value <> FMaxSpeed.Value then
     begin
          Inc(FSpeed.Value, FAcc.Value);
          if FSpeed.Value > FMaxSpeed.Value then
             FSpeed.Value := FMaxSpeed.Value;
             VelocityX := CosVal(FDirection) * Speed;
             VelocityY := SinVal(FDirection) * Speed;
     end;
end;

procedure TDGCSprite.Deccelerate;
begin
     if FSpeed.Value <> FMinSpeed.Value then
     begin
          Dec(FSpeed.Value, FDec.Value);
          if FSpeed.Value < FMinSpeed.Value then
             FSpeed.Value := FMinSpeed.Value;
          VelocityX := CosVal(FDirection) * Speed;
          VelocityY := SinVal(FDirection) * Speed;
     end;
end;

procedure TDGCSprite.CycleFrame(TickCount: DWord);
var
   ImgNbr: Integer;
   Anim: TDGCAnimation;
begin
     if TickCount - FAnimTickCount >= FAnimInterval then
     begin
          Anim := SpriteMgr.Animations[FAnimation];
          FAnimTickCount := TickCount;
          Inc(FFrameNbr);
          if FFrameNbr = FFrameCount then
             if Anim.Loop then
                FFrameNbr := 0
             else
             begin
                  Dec(FFrameNbr);
                  if Assigned(SpriteMgr.OnAnimationEnd) then
                     SpriteMgr.OnAnimationEnd(self);
                  exit;
             end;
          ImgNbr := Anim.Frame(FAnimDirection, FFrameNbr);
          FWidth := SpriteMgr.DGCScreen.Images[ImgNbr].Width;
          FHeight := SpriteMgr.DGCScreen.Images[ImgNbr].Height;
     end;
end;

procedure TDGCSprite.FlipYDirection;
begin
     if FDirection >  16 then
        Direction := 16 + (32 - FDirection)
     else
         Direction := 16 - FDirection;
end;

procedure TDGCSprite.FlipXDirection;
begin
     if FDirection >= 8 then
        Direction := 24 + (8 - FDirection)
     else
         if FDirection > 0 then
            Direction := 32 - FDirection;
end;

procedure TDGCSprite.CheckLimits;
begin
     //Hit Left Edge?
     if X < Limits.Left then
     begin
          case LeftAction of
               laBounce:
               begin
                    X := Limits.Left;
                    FlipXDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsLeft);
               end;
               laReverse:
               begin
                    X := Limits.Left;
                    FlipXDirection;
                    FlipYDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsLeft);
               end;
               laStopInside:
               begin
                    X := Limits.Left;
                    Stop;
                    if Assigned(SpriteMgr.OnSpriteStopped) then
                                 SpriteMgr.OnSpriteStopped(Self, lsLeft);
               end;
               laStopOutSide:
               begin
                    if X + FWidth < Limits.Left then
                    begin
                         Stop;
                         if Assigned(SpriteMgr.OnSpriteStopped) then
                                     SpriteMgr.OnSpriteStopped(Self, lsLeft);
                    end;
               end;
               laEvent:
               begin
                    if Assigned(SpriteMgr.OnSpriteEvent) then
                       SpriteMgr.OnSpriteEvent(Self, lsLeft);
               end;
               laWrap:
               begin
                    if X + FWidth < Limits.Left then
                       X := Limits.Right;
               end;
          end;
     end;

     //Hit thr Right Edge?
     if (X + FWidth > Limits.Right) and (FDirection in [1..15]) then
     begin
          case RightAction of
               laBounce:
               begin
                    X := Limits.Right - FWidth;
                    FlipXDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsRight);
               end;
               laReverse:
               begin
                    X := Limits.Right - FWidth;
                    FlipXDirection;
                    FlipYDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsRight);
               end;
               laStopInside:
               begin
                    X := Limits.Right - FWidth;
                    Stop;
                    if Assigned(SpriteMgr.OnSpriteStopped) then
                                 SpriteMgr.OnSpriteStopped(Self, lsRight);
               end;
               laStopOutSide:
               begin
                    if X > Limits.Right then
                    begin
                         Stop;
                         if Assigned(SpriteMgr.OnSpriteStopped) then
                                     SpriteMgr.OnSpriteStopped(Self, lsRight);
                    end;
               end;
               laEvent:
               begin
                    if Assigned(SpriteMgr.OnSpriteEvent) then
                       SpriteMgr.OnSpriteEvent(Self, lsRight);
               end;
               laWrap:
               begin
                    if X > Limits.Right then
                       X := Limits.Left - FWidth;
               end;
          end;
     end;

     //Hit Top Edge?
     if Y < Limits.Top then
     begin
          case TopAction of
               laBounce:
               begin
                    Y := Limits.Top;
                    FlipYDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsTop);
               end;
               laReverse:
               begin
                    Y := Limits.Top;
                    FlipXDirection;
                    FlipYDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsTop);
               end;
               laStopInside:
               begin
                    Y := Limits.Top;
                    Stop;
                    if Assigned(SpriteMgr.OnSpriteStopped) then
                                 SpriteMgr.OnSpriteStopped(Self, lsTop);
               end;
               laStopOutSide:
               begin
                    if Y + FHeight < Limits.Top then
                    begin
                         Stop;
                         if Assigned(SpriteMgr.OnSpriteStopped) then
                                     SpriteMgr.OnSpriteStopped(Self, lsTop);

                    end;
               end;
               laEvent:
               begin
                    if Assigned(SpriteMgr.OnSpriteEvent) then
                       SpriteMgr.OnSpriteEvent(Self, lsTop);
               end;
               laWrap:
               begin
                    if Y + FHeight < Limits.Top then
                       Y := Limits.Bottom;
               end;
          end;
     end;

     //Hit the Bottom Edge?
     if (Y + FHeight > Limits.Bottom) and (FDirection in [9..23]) then
     begin
          case BottomAction of
               laBounce:
               begin
                    Y := Limits.Bottom - FHeight;
                    FlipYDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsBottom);
               end;
               laReverse:
               begin
                    Y := Limits.Bottom - FHeight;
                    FlipXDirection;
                    FlipYDirection;
                    if Assigned(SpriteMgr.OnSpriteDirChange) then
                                 SpriteMgr.OnSpriteDirChange(Self, lsBottom);
               end;
               laStopInside:
               begin
                    Y := Limits.Bottom - FHeight;
                    Stop;
                    if Assigned(SpriteMgr.OnSpriteStopped) then
                                 SpriteMgr.OnSpriteStopped(Self, lsBottom);
               end;
               laStopOutSide:
               begin
                    if Y > Limits.Bottom then
                    begin
                         Stop;
                         if Assigned(SpriteMgr.OnSpriteStopped) then
                                     SpriteMgr.OnSpriteStopped(Self, lsBottom);
                    end;
               end;
               laEvent:
               begin
                    if Assigned(SpriteMgr.OnSpriteEvent) then
                       SpriteMgr.OnSpriteEvent(Self, lsBottom);
               end;
               laWrap:
               begin
                    if Y > Limits.Bottom then
                       Y := Limits.Top - FHeight;
               end;
          end;
     end;
end;

procedure TDGCSprite.Stop;
begin
     FStopped := True;
end;

procedure TDGCSprite.Resume;
begin
     FStopped := False;
end;

procedure TDGCSprite.Hide;
begin
     FVisible := False;
end;

procedure TDGCSprite.Show;
begin
     FVisible :=True;
end;

procedure TDGCSprite.Enable;
begin
     FEnabled := True;
end;

procedure TDGCSprite.Disable;
begin
     FEnabled := False;
end;

//TDGCBouncer Sprite Class Implementation
//=======================================
constructor TDGCBouncer.Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, ADir: Integer;
     ASpeed: Double; Animations: Integer);
begin
     SpriteMgr := Mgr; //Set SpriteMgr variable first before calling Create
     inherited Create;
     FAnimation := Animations;
     FID := AID;
     X := XStart;
     Y := YStart;
     MaxSpeed := ASpeed;
     Acceleration := ASpeed;
     Decceleration := ASpeed;
     Direction := ADir;
     AllActions := laBounce;
end;

procedure TDGCBouncer.Update(TickCount: DWord);
begin
     CycleFrame(TickCount);
     if FAutomatic then
        Accelerate;

     if not FStopped then
     begin
          Inc(FX.Value, FVelX.Value);
          Inc(FY.Value, FVelY.Value);
     end;

     CheckLimits;

    //Whatever we have done to the sprite allow the position to
    //be changed
    if Assigned(SpriteMgr.OnSpriteMoved) then
       SpriteMgr.OnSpriteMoved(Self);
end;

//TDGCRaceCar Sprite Class Implementation
//=======================================
constructor TDGCRaceCar.Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, ADir: Integer;
     ASpeed: Double; Animations: Integer);
begin
     SpriteMgr := Mgr; //Set SpriteMgr variable first before calling Create
     inherited Create;
     FAnimation := Animations;
     FID := AID;
     X := XStart;
     Y := YStart;
     MaxSpeed := ASpeed;
     Handling := 50;
     FLastRotTick := 0;
     Acceleration := ASpeed / 100;
     Decceleration := ASpeed / 100;
     Direction := ADir;
     AllActions := laWrap;
end;

procedure TDGCRaceCar.Update(TickCount: DWord);
var
   OldDir, tc: Integer;
begin
     //If the sprite hit the side it is automatically stopped so
     //resume movement
     Resume;

     OldDir := FDirection;
     if FAutomatic then
     begin
          //Rotation based on RotationSpeed propetry
          tc := GetTickCount;
          if tc - FLastRotTick > FHandling then
          begin
               FLastRotTick := tc;
               //Rotate Right
               if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyRight) then
               begin
                    if FDirection = 31 then
                       Direction := 0
                    else
                        Direction := Direction + 1;
               end;
               //Rotate Left
               if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyLeft) then
               begin
                    if FDirection = 0 then
                       Direction := 31
                    else
                        Direction := Direction - 1;
               end;
          end;
          //Thrust
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyUp) or
             SpriteMgr.DGCSCreen.KeyDown(SpriteMgr.KeyFire1) then
             Accelerate
          else
              Deccelerate; //If not thrusting then slow down.

          //Reverse Thrust or brake
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyDown) or
             SpriteMgr.DGCSCreen.KeyDown(SpriteMgr.KeyFire2) then
             Deccelerate;
     end;

     if OldDir = FDirection then
        CycleFrame(TickCount);

     if not FStopped then
     begin
          Inc(FX.Value, FVelX.Value);
          Inc(FY.Value, FVelY.Value);
     end;

     CheckLimits;

    //Whatever we have done to the sprite allow the position to
    //be changed
    if Assigned(SpriteMgr.OnSpriteMoved) then
       SpriteMgr.OnSpriteMoved(Self);
end;

//TDGCThruster Sprite Class Implementation
//=======================================
constructor TDGCThruster.Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, ADir: Integer;
     ASpeed: Double; Animations: Integer);
begin
     SpriteMgr := Mgr; //Set SpriteMgr variable first before calling Create
     inherited Create;
     FAnimation := Animations;
     FID := AID;
     X := XStart;
     Y := YStart;
     MaxSpeed := ASpeed;
     Handling := 50;
     FLastRotTick := 0;
     Acceleration := ASpeed / 100;
     Decceleration := ASpeed / 100;
     Direction := ADir;
     CurrentDirection:=FAnimdirection;
     AllActions := laWrap;
end;


procedure TDGCThruster.Drawanimation(Value: Integer);
var
   ImgNbr: Integer;
begin
     FCurrentDirection:=Value;
     //Only change animation direction if the slot has frames
     if SpriteMgr.Animations[FAnimation].HasFrames(Value) then
     begin
          FAnimDirection:=Value;
          with SpriteMgr.Animations[FAnimation] do
          begin
               FAnimInterval := Speed(FAnimDirection);
               FFrameNbr := 0;
               FFrameCount := FrameCount(FAnimDirection);
               ImgNbr := Frame(FAnimDirection, 0);
               FWidth := SpriteMgr.DGCScreen.Images[ImgNbr].Width;
               FHeight := SpriteMgr.DGCScreen.Images[ImgNbr].Width;
          end;
     end;

end;

procedure TDGCThruster.Update(TickCount: DWord);
var
   OldDir, tc: Integer;
begin
     //If the sprite hit the side it is automatically stopped so
     //resume movement
     Resume;

     if FAutomatic then
     begin
          //Rotation based on RotationSpeed propetry
          tc := GetTickCount;
          if tc - FLastRotTick > FHandling then
          begin
               FLastRotTick := tc;
               //Rotate Right
               if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyRight) then
               begin
                   if FCurrentDirection = 31 then
                       Drawanimation(0)
                   else
                        DrawAnimation(FCurrentDirection+1);
               end;
               //Rotate Left
               if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyLeft) then
               begin
                    if FCurrentDirection = 0 then
                       DrawAnimation(31)
                    else
                        DrawAnimation(FCurrentDirection-1);
               end;
          end;
          //Thrust
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyUp) or
             SpriteMgr.DGCSCreen.KeyDown(SpriteMgr.KeyFire1) then
          begin
             if (FSpeed.Value = FMinSpeed.Value) then
                 Direction:=FanimDirection;
             // stationary so set the thrust direction
             if (FSpeed.Value <= FMinSpeed.Value)  or (Direction = FAnimdirection) then
             begin
                 Accelerate;
             end
             else
                 // moving in differant direction so slow it down
                 Deccelerate;

          end;
     end;
     CycleFrame(TickCount);
     if not FStopped then
     begin
          Inc(FX.Value, FVelX.Value);
          Inc(FY.Value, FVelY.Value);
     end;

     CheckLimits;

    //Whatever we have done to the sprite allow the position to
    //be changed
    if Assigned(SpriteMgr.OnSpriteMoved) then
       SpriteMgr.OnSpriteMoved(Self);
end;


//TDGCPlayer8 Sprite Class Implementation
//===========================================
constructor TDGCPlayer8.Create(Mgr: TDGCSpriteMgr; AID, XStart, YStart, StartDir: Integer;
     AMaxSpeed: Double; Animations: Integer);
begin
     SpriteMgr := Mgr; //Set SpriteMgr variable first before calling Create
     inherited Create;
     FAllowUp := True;
     FAllowDown := True;
     FAllowLeft := True;
     FAllowRight := True;
     FAnimation := Animations;
     FID := AID;
     X := XStart;
     Y := YStart;
     VelocityX := 0;
     VelocityY := 0;
     AllActions := laStopInside;
     Acceleration := AMaxSpeed;
     Decceleration := AMaxSpeed;
     MaxSpeed := AMaxSpeed;
     FActiveAnimation := FAnimation;
     FIdleAnimation := FAnimation;
     Direction := StartDir;
end;

procedure TDGCPlayer8.Update(TickCount: DWord);
var
   KUp, KDown, KLeft, KRight: Boolean;
   NewDir: Integer;
begin
     //If the sprite hit the side it is automatically stopped so
     //resume movement
     Resume;

     //Check for keypresses
     KUp := False;
     KDown := False;
     KLeft := False;
     KRight := False;
     if FAutomatic then
     begin
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyLeft) and FAllowLeft then KLeft := True;
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyRight) and FAllowRight then KRight := True;
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyUp) and FAllowUp then KUp := True;
          if SpriteMgr.DGCScreen.KeyDown(SpriteMgr.KeyDown) and FAllowDown then KDown := True;
     end;

     //From the keypresses determine new direction
     NewDir := -1;
     if KRight and KDown then
        NewDir := 12
     else if KRight and KUp then
        NewDir := 4
     else if KLeft and KDown then
        NewDir := 20
     else if KLeft and KUp then
        NewDir := 28
     else if KRight then
        NewDir := 8
     else if KDown then
        NewDir := 16
     else if KLeft then
        NewDir := 24
     else if KUp then
        NewDir := 0;

     //Was any key pressed at all?
     if NewDir = -1 then
     begin
          if FAnimation <> FIdleAnimation then
               Animation := FIdleAnimation
          else
              CycleFrame(TickCount);
          Deccelerate; //If no keys are pressed then decellerate
     end
     else //Keys have been pressed - has the direction changed?
     begin
         if FAnimation <> FActiveAnimation then
            Animation := FActiveAnimation;
         Accelerate;
         if FDirection <> NewDir then
            Direction := NewDir
         else
             CycleFrame(TickCount);
     end;

     //Update Position
     if not FStopped then
     begin
          Inc(FX.Value, FVelX.Value);
          Inc(FY.Value, FVelY.Value);
     end;

     CheckLimits;

     if Assigned(SpriteMgr.OnSpriteMoved) then
        SpriteMgr.OnSpriteMoved(Self);
end;


end.
