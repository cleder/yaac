{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit DGC;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DDraw, DGCILib, BmpUtil;

const
     WM_DGCACTIVATE = WM_USER + 200;

type
  //Default Exception Handler
  EDGCScreen = class(Exception);
  EDGCSurface = class(Exception);
  EDGCCanvas = class(Exception);

  //General enumerated types
  TDisplayMode = (dm640x480x8, dm320x200x8, dm800x600x8, dm1024x768x8);

  //Events
  TDGCSurface = class; //Forward
  TSurfaceLost = procedure (Surface: TDGCSurface) of Object;

  //Direct Draw Canvas
  //==================
  TDGCCanvas = class( TCanvas )
  private
    { Private declarations }
    FSurface: IDirectDrawSurface ;
    FDeviceContext: HDC ;
  protected
    { Protected declarations }
    procedure CreateHandle ; override ;
  public
    { Public declarations }
    constructor Create(ASurface : IDirectDrawSurface) ;
    destructor Destroy ; override ;
    procedure Release ;
    function  DrawingAllowed : boolean ;
  end;

  //DGC Surface
  TDGCScreen = class; 
  TDGCSurface = class(TObject)
  private
    { Private declarations }
    FSurface: IDirectDrawSurface;
    FCanvas: TDGCCanvas;
    FTransparentColor: Byte;
    FWidth: Integer;
    FHeight: Integer;
    FWidthBytes: Integer;
    FClientRect: TRect;
    FClipRect: TRect;
    IsBackBuffer: Boolean;
    FOnSurfaceLost: TSurfaceLost;
    SurfacePtr: Pointer;
    procedure SetTransparentColor(NewValue: Byte);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(DirectDraw: IDirectDraw; w, h: Integer);
    constructor CreatePrimary(DGCScreen: TDGCScreen);
    constructor CreateBackBuffer(Primary: TDGCSurface);
    destructor Destroy; override;
    procedure SetPixel(x, y: Integer; Color: Byte);
    function GetPointer: Pointer;
    procedure ReleasePointer;
    function  CollisionTest(x, y: Integer; SrcSurface: TDGCSurface;
         sx, sy: Integer; PixelTest: Boolean): Boolean;
    procedure Erase(Color: Byte);
    procedure EraseRect(r: TRect; Color: Byte);
    procedure Scroll(x, y: Integer);
    procedure Draw(x, y: Integer; SrcSurface: TDGCSurface; TransParent: Boolean);
    procedure StretchDraw(dr: TRect; SrcSurface: TDGCSurface; TransParent: Boolean);
    procedure BltFast(x, y: Integer; SrcSurface: TDGCSurface; r: TRect; TransParent: Boolean);
    procedure Tile(x, y: Integer; SrcSurface: TDGCSurface; TransParent: Boolean);
    property Surface: IDirectDrawSurface read FSurface;
    property Canvas: TDGCCanvas read FCanvas;
    property TransparentColor: Byte read FTransparentColor write SetTransparentColor;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property WidthBytes: Integer read FWidthBytes;
    property ClientRect: TRect read FClientRect;
    property ClipRect: TRect read FClipRect write FClipRect;
    property OnSurfaceLost: TSurfaceLost read FOnSurfaceLost write FOnSurfaceLost;
  end;

  //Surface Image List
  TDGCSurfaceList = array[0..0] of TDGCSurface;
  PDGCSurfaceList = ^TDGCSurfaceList;

  //Main DGC Component
  //==================
  TDGCScreen = class(TComponent)
  private
    { Private declarations }
    FDisplayMode: TDisplayMode;
    FDirectDraw: IDirectDraw;
    FPalette: IDirectDrawPalette;
    FPaletteEntries: T256PaletteEntry;
    FDGCImageLib: TDGCImageLib;
    FImageList: PDGCSurfaceList;
    FImageListCount: Integer;
    FFront: TDGCSurface;
    FBack: TDGCSurface;
    FFlippingEnabled : Boolean;
    FDebug: Boolean;
    FOnPaint: TNotifyEvent;
    FOnFlip: TNotifyEvent;
    FOnInitialize: TNotifyEvent;
    FOnCleanUp: TNotifyEvent;
    frmOnActivate: TNotifyEvent;
    FImageLib: TDGCImageLib;
    FBeepOnException: Boolean;
    procedure DoException(Sender: TObject; E: Exception);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure AppMessage(var Msg: TMsg; var Handled : boolean ) ;
    procedure SetFlippingEnabled(b: Boolean);
    procedure DoOnActivate(Sender: TObject);
    procedure InitDirectDraw;
    procedure CleanUpDirectDraw;
    procedure SetDebug(NewVal: Boolean);
    function GetScreenWidth: Integer;
    function GetScreenHeight: Integer;
    function GetImage(Index: Integer): TDGCSurface;
    procedure FreeImageList;
    procedure DoSurfaceLost(Surface: TDGCSurface);
    procedure StartTimer;
    procedure StopTimer;
    function GetClipRect: TRect;
    procedure SetClipRect(NewVal: TRect);
    procedure CreateDefaultPalette;
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Flip;
    procedure CreateSurface(var Surface: TDGCSurface; W, H: Integer);
    procedure WaitForVerticalBlank;
    function KeyDown(Key: Word): Boolean;
    procedure SetPalette(var NewPalette: T256PaletteEntry);
    procedure FadePaletteOut(Delay: Integer);
    procedure FadePaletteIn(Delay: Integer);
    procedure SetImageLibrary(Lib: TDGCImageLib; UsePalette: Boolean);
    procedure RestoreSurfaces;
    procedure FlipScroll(XSpeed, YSpeed: Integer);
    property DirectDraw: IDirectDraw read FDirectDraw;
    property Palette: IDirectDrawPalette read FPalette;
    property Front: TDGCSurface read FFront;
    property Back: TDGCSurface read FBack;
    property ScreenWidth: Integer read GetScreenWidth;
    property ScreenHeight: Integer read GetScreenHeight;
    property Images[Index: Integer]: TDGCSurface read GetImage;
    property ClipRect: TRect read GetClipRect write SetClipRect;
  published
    { Published declarations }
    property DisplayMode: TDisplayMode read FDisplayMode write FDisplayMode;
    property FlippingEnabled: Boolean read FFlippingEnabled write SetFlippingEnabled;
    property Debug: Boolean read FDebug write SetDebug;
    property ImageLibrary: TDGCImageLib read FImageLib write FImageLib;
    property BeepOnException: Boolean read FBeepOnException write FBeepOnException;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnFlip: TNotifyEvent read FOnFlip write FOnFlip;
    property OnInitialize: TNotifyEvent read FOnInitialize write FOnInitialize;
    property OnCleanUp: TNotifyEvent read FOnCleanUp write FOnCleanUp;
  end;


implementation

uses Trace, dgcspts, dgcsnd;

//TDGCCanvas Implementation
//========================
constructor TDGCCanvas.Create( ASurface : IDirectDrawSurface ) ;
begin
  inherited Create ;
  if ASurface = NIL then
    Raise EDGCCanvas.Create('Cannot create canvas for NIL surface' ) ;
  FSurface := ASurface ;
end;

destructor TDGCCanvas.Destroy ;
begin
  Release;
  inherited Destroy ;
end ;

procedure TDGCCanvas.CreateHandle ;
begin
  if FDeviceContext = 0 then begin
    FSurface.GetDC( FDeviceContext ) ;
    Handle := FDeviceContext ;
  end ;
end ;

procedure TDGCCanvas.Release ;
begin
  if FDeviceContext <> 0 then begin
    Handle := 0 ;
    FSurface.ReleaseDC( FDeviceContext ) ;
    FDeviceContext := 0 ;
  end ;
end ;

function  TDGCCanvas.DrawingAllowed : boolean ;
begin
  Result := FSurface.IsLost = DD_OK ;
end ;


//TDGCSurface Implementation
//==========================
//This handles the creation of a direct draw surface and creates a
//Canvas object for the surface.

constructor TDGCSurface.Create(DirectDraw: IDirectDraw; w, h: Integer);
var
   SurfaceDesc: DDSurfaceDesc;
begin
     inherited Create;
     //Fill in the DirectDrawSurface descriptor prior to creating the surface }
     IsBackBuffer := False;
     FillChar(SurfaceDesc, SizeOf(DDSurfaceDesc), 0) ;
     with SurfaceDesc do
     begin
          dwSize := SizeOf(DDSurfaceDesc) ;
          dwFlags := DDSD_CAPS or DDSD_HEIGHT or DDSD_WIDTH;
          ddSCaps.dwCaps := DDSCAPS_OFFSCREENPLAIN;
          dwWidth := w ;
          dwHeight := h ;
     end;
     if DirectDraw.CreateSurface(SurfaceDesc, FSurface, NIL ) <> DD_OK then
        Raise EDGCSurface.Create(Format('Could not create memory srface (%d, %d)',
                 [w, h])) ;
     //Create canvas
     FWidth := w;
     FHeight := h;
     FClientRect := Rect(0, 0, w, h);
     FClipRect := FClientRect;
     FCanvas := TDGCCanvas.Create(FSurface);
     //Get Pitch
     if FSurface.GetSurfaceDesc(SurfaceDesc) = DD_OK then
        FWidthBytes := SurfaceDesc.lPitch
     else
         FWidthBytes := 0;
end;

constructor TDGCSurface.CreatePrimary(DGCScreen: TDGCScreen);
var
   SurfaceDesc: DDSurfaceDesc;
begin
     inherited Create;
     //Fill in the DirectDrawSurface descriptor prior to creating the surface }
     IsBackBuffer := False;
     FillChar(SurfaceDesc, SizeOf(DDSurfaceDesc), 0) ;
     with SurfaceDesc do
     begin
          dwSize := SizeOf(DDSurfaceDesc) ;
          dwFlags := DDSD_CAPS or DDSD_BACKBUFFERCOUNT;
          ddSCaps.dwCaps := DDSCAPS_COMPLEX + DDSCAPS_FLIP + DDSCAPS_PRIMARYSURFACE;
          dwBackBufferCount := 1;
     end;

     // create the complex flipping surface
     if DGCScreen.DirectDraw.CreateSurface(SurfaceDesc, FSurface, NIL ) <> DD_OK then
        Raise EDGCSurface.Create( 'CreateSurface failed' ) ;

     //Create canvas
     FCanvas := TDGCCanvas.Create(FSurface);

     //Get Screen Width and Height
      if DGCScreen.DirectDraw.GetDisplayMode(SurfaceDesc) <> DD_OK then
         Raise EDGCSurface.Create('Get DisplayMode Failed');
      FWidth := SurfaceDesc.dwWidth;
      FHeight := SurfaceDesc.dwHeight;
      FWidthBytes := SurfaceDesc.lPitch;
      FClientRect := Rect(0, 0, FWidth, FHeight);
      FClipRect := FClientRect;
end;

constructor TDGCSurface.CreateBackBuffer(Primary: TDGCSurface);
var
   Caps: DDSCaps;
begin
     inherited Create;
     IsBackBuffer := True;
     Caps.dwCaps := DDSCAPS_BACKBUFFER ;
     if Primary.Surface.GetAttachedSurface(Caps, FSurface ) <> DD_OK then
        Raise EDGCSurface.Create( 'Failed to get background surface' );
     FCanvas := TDGCCanvas.Create(FSurface);

     //Set Width/Height Flags - Copy from Primary
     FWidth := Primary.Width;
     FHeight := Primary.Height;
     FWidthBytes := Primary.WidthBytes;
     FClientRect := Rect(0, 0, FWidth, FHeight);
     FClipRect := FClientRect;
end;

destructor TDGCSurface.Destroy;
begin
     //Free canvas
     if Assigned(FCanvas) then
        FCanvas.Free;

     //Release Surface (Back buffers are released when primary surfaced
     //released
     if Assigned(FSurface) and not IsBackBuffer
        then FSurface.Release ;

     inherited Destroy;
end;

procedure TDGCSurface.SetPixel(x, y: Integer; Color: Byte);
var
   SurfaceDesc: DDSurfaceDesc;
begin
     SurfaceDesc.dwSize := SizeOf(DDSurfaceDesc) ;
     if FSurface.Lock(Rect(x, y, x, y), SurfaceDesc, DDLOCK_SURFACEMEMORYPTR +
              DDLOCK_WAIT, 0) <> DD_OK then exit;
     PByte(SurfaceDesc.lpSurface)^ := Color;
     FSurface.UnLock(SurfaceDesc.lpSurface);
end;


function TDGCSurface.GetPointer: Pointer;
var
   SurfaceDesc: DDSurfaceDesc;
begin
     SurfaceDesc.dwSize := SizeOf(DDSurfaceDesc) ;
     if FSurface.Lock(FClientRect, SurfaceDesc, DDLOCK_SURFACEMEMORYPTR +
              DDLOCK_WAIT, 0) <> DD_OK then
     begin
          SurfacePtr := nil;
          Result := nil;
          exit;
     end;
     SurfacePtr := SurfaceDesc.lpSurface;
     Result := SurfaceDesc.lpSurface;
end;

procedure TDGCSurface.ReleasePointer;
begin
     if SurfacePtr <> nil then
     begin
          FSurface.UnLock(SurfacePtr);
          SurfacePtr := nil;
     end;
end;

procedure TDGCSurface.SetTransparentColor(NewValue: Byte);
var
    ColorKey: DDColorKey ;
begin
     FTransparentColor := NewValue;
     ColorKey.dwColorSpaceLowValue := FTransparentColor ;
     ColorKey.dwColorSpaceHighValue := FTransparentColor ;
     if FSurface.SetColorKey(DDCKEY_SRCBLT, ColorKey) <> DD_OK then
        Raise EDGCSurface.Create('SetColorKey failed') ;
end;

function TDGCSurface.CollisionTest(x, y: Integer; SrcSurface: TDGCSurface;
         sx, sy: Integer; PixelTest: Boolean): Boolean;
var
   r, r1, r2: TRect;
   lx, ly, w, h: Integer;
   bits1, bits2: PByte;
   savebits1, savebits2: PByte;
   pitch1, pitch2: Integer;
   t1, t2: Byte;
   SurfaceDesc: DDSurfaceDesc;
begin
     Result := False; //default to no collision
     r1 := Rect(x, y, x + FWidth, y + FHeight);
     r2 := Rect(sx, sy, sx + SrcSurface.Width, sy + SrcSurface.Height);
     //Do the images intersect?
     if not InterSectRect(r, r1, r2) then
        exit
     else
         if not PixelTest then
         begin
              Result := True;
              exit;
         end;

     //Check Pixel Data
     w := r.Right - r.Left; //width of intersecting rectangle
     h := r.Bottom - r.Top; //height of intersecting rectangle
     //Set Rectangle 1
     r1.Left := r.Left - r1.Left;
     r1.Top := r.Top - r1.Top;
     r1.Right := r1.Left + w;
     r1.Bottom := r1.Top + h;
     //Set Rectangle 2
     r2.Left := r.Left - r2.Left;
     r2.Top := r.Top - r2.Top;
     r2.Right := r2.Left + w;
     r2.Bottom := r2.Top + h;

     //Get pointer to surface 1
     SurfaceDesc.dwSize := SizeOf(DDSurfaceDesc) ;
     if FSurface.Lock(r1, SurfaceDesc, DDLOCK_SURFACEMEMORYPTR +
              DDLOCK_WAIT, 0) <> DD_OK then
          exit;

     bits1 := SurfaceDesc.lpSurface;
     pitch1 := SurfaceDesc.lPitch - w;

     //Get pointer to surface 1
     SurfaceDesc.dwSize := SizeOf(DDSurfaceDesc);
     if SrcSurface.Surface.Lock(r2, SurfaceDesc, DDLOCK_SURFACEMEMORYPTR +
              DDLOCK_WAIT, 0) <> DD_OK then
     begin
          FSurface.UnLock(bits1);
          exit;
     end;
     bits2 := SurfaceDesc.lpSurface;
     pitch2 := SurfaceDesc.lPitch - w;

     savebits1 := bits1;
     savebits2 := bits2;
     t1 := FTransparentColor;
     t2 := SrcSurface.TransparentColor;
     for ly := 1 to h do
     begin
          for lx := 1 to w do
          begin
               if (savebits1^ <> t1) and (savebits2^ <> t2) then
               begin
                    FSurface.UnLock(bits1);
                    SrcSurface.Surface.UnLock(bits2);
                    Result := True;
                    exit;
               end;
               Inc(savebits1);
               Inc(savebits2);
          end;
          Inc(savebits1, pitch1);
          Inc(savebits2, pitch2);
     end;
     FSurface.UnLock(bits1);
     SrcSurface.Surface.UnLock(bits2);
end;

procedure TDGCSurface.Erase(Color: Byte);
var
  BltFx: DDBLTFX;
  r: HResult;
begin
  ZeroMemory ( @BltFx, sizeof(BltFx));
  BltFx.dwSize := sizeof(BltFx);
  BltFx.dwFillColor := Color;
  r := FSurface.Blt(FClientRect, nil, FClientRect, DDBLT_COLORFILL + DDBLT_WAIT, BltFx);
  if r <> DD_OK then
     if (r = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
        FOnSurfaceLost(self)
     else
         raise EDGCSurface.Create('Erase (Blt) Failed');
end;

procedure TDGCSurface.EraseRect(r: Trect; Color: Byte);
var
  BltFx: DDBLTFX;
  res: HResult;
begin
  ZeroMemory ( @BltFx, sizeof(BltFx));
  BltFx.dwSize := sizeof(BltFx);
  BltFx.dwFillColor := Color;
  res := FSurface.Blt(r, nil, r, DDBLT_COLORFILL + DDBLT_WAIT, BltFx);
  if res <> DD_OK then
     if (res = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
        FOnSurfaceLost(self)
     else
         raise EDGCSurface.Create('Erase (Blt) Failed');
end;

procedure TDGCSurface.Scroll(x, y: Integer);
var
   r: TRect;
   res: HResult;
begin
     r := FClipRect;
     //X Scroll
     if x < 0 then
     begin
        Inc(r.Left, Abs(x));
        x := FClipRect.Left;
     end
     else
     begin
          Dec(r.Right, x);
          Inc(x, FClipRect.Left);
     end;

     //y Scroll
     if y < 0 then
     begin
        Inc(r.Top, Abs(y));
        y := FClipRect.Top;
     end
     else
     begin
          Dec(r.Bottom, y);
          Inc(y, FClipRect.Top);
     end;


     //Do the blit
     res := FSurface.BltFast(x, y, FSurface, r,
                            DDBLTFAST_NOCOLORKEY or DDBLTFAST_WAIT);
     if res <> DD_OK then
        if (res = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
           FOnSurfaceLost(self)
        else
           raise EDGCSurface.Create('Scroll (BltFast) Failed');
end;

procedure TDGCSurface.Draw(x, y: Integer; SrcSurface: TDGCSurface; TransParent: Boolean);
var
   res: HResult;
   r, sr: TRect;
begin
     //Clip Rectangle
     sr := Rect(x, y, x + SrcSurface.Width , y + SrcSurface.Height);
     if not IntersectRect(r, sr, FClipRect) then exit;
     r := SrcSurface.ClientRect;
     if x < FClipRect.Left then
     begin
        r.Left := FClipRect.Left - x;
        x := FClipRect.Left;
     end
     else
         if x + r.Right > FClipRect.Right then
            r.Right := FClipRect.Right - x;
     if y < FClipRect.Top then
     begin
        r.Top := FClipRect.Top - y;
        y := FClipRect.Top;
     end
     else
        if y + r.Bottom > FClipRect.Bottom then
           r.Bottom := FClipRect.Bottom - y;

     //Draw Image
     if Transparent then
        res := FSurface.BltFast(x, y, SrcSurface.Surface, r,
                           DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT)
     else
        res := FSurface.BltFast(x, y, SrcSurface.Surface, r,
                            DDBLTFAST_NOCOLORKEY or DDBLTFAST_WAIT);
     if res <> DD_OK then
        if (res = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
           FOnSurfaceLost(self)
        else
           raise EDGCSurface.Create('Draw (BltFast) Failed');
end;

procedure TDGCSurface.StretchDraw(dr: TRect; SrcSurface: TDGCSurface; TransParent: Boolean);
var
   res: HResult;
   r: TRect;
   BltFx: DDBltFx;
begin
     //Draw Image
     r := SrcSurface.ClientRect;
     ZeroMemory (@BltFx, sizeof(BltFx));
     BltFx.dwSize := sizeof(BltFx);
     if Transparent then
        res := FSurface.Blt(dr, SrcSurface.Surface, r, DDBLT_WAIT or DDBLT_KEYSRC, BltFx)
     else
        res := FSurface.Blt(dr, SrcSurface.Surface, r, DDBLTFAST_WAIT, BltFx);
     if res <> DD_OK then
        if (res = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
           FOnSurfaceLost(self)
        else
           raise EDGCSurface.Create('Draw (BltFast) Failed');
end;

procedure TDGCSurface.BltFast(x, y: Integer; SrcSurface: TDGCSurface; r: TRect; TransParent: Boolean);
var
   res: HResult;
begin
     //Draw Image
     if Transparent then
        res := FSurface.BltFast(x, y, SrcSurface.Surface, r,
                           DDBLTFAST_SRCCOLORKEY or DDBLTFAST_WAIT)
     else
        res := FSurface.BltFast(x, y, SrcSurface.Surface, r,
                            DDBLTFAST_NOCOLORKEY or DDBLTFAST_WAIT);
     if res <> DD_OK then
        if (res = DDERR_SURFACELOST) and Assigned(FOnSurfaceLost) then
           FOnSurfaceLost(self)
        else
           raise EDGCSurface.Create('Draw (BltFast) Failed');
end;

procedure TDGCSurface.Tile(x, y: Integer; SrcSurface: TDGCSurface; TransParent: Boolean);
var
   sx, ey, ex: Integer;
   w, h: Integer;
begin
     w := SrcSurface.Width;
     h := SrcSurface.Height;
     ey := FClipRect.Bottom + h;
     ex := FClipRect.Right + w;
     Inc(x, FClipRect.Left);
     Inc(y, FClipRect.Top);
     while y < ey do
     begin
          sx := x;
          while sx < ex do
          begin
               Draw(sx, y, SrcSurface, Transparent);
               Inc(sx, w);
          end;
          Inc(y, h);
     end;
end;

//TDGCScreen Implementation
//=======================
constructor TDGCScreen.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     //Initialise
     FPalette := nil;
     FDGCImageLib := nil;
     FImageList := nil;
     Debug := True;
     FBeepOnException := True;
     if not (csDesigning in ComponentState) then
     begin
          frmOnActivate := TForm(Owner).OnActivate;
          TForm(Owner).OnActivate := DoOnActivate;
     end;
end;

destructor TDGCScreen.Destroy;
begin
     CleanUpDirectDraw;
     inherited Destroy;
end;

procedure TDGCScreen.Loaded;
begin
     inherited Loaded;
     //Set from properties
     if not (csDesigning in ComponentState) then
     begin
          with Owner as TForm do
          begin
               BorderStyle := bsNone;
               BorderIcons := [];
               FormStyle := fsStayOnTop;
               Color := clBlack;
          end;
     end;
end;

procedure TDGCScreen.DoOnActivate(Sender: TObject);
var
   n: Integer;
begin
     if Assigned(frmOnActivate) then
        frmOnActivate(Owner);
     InitDirectDraw;
     //DirectDraw must be initialized before DirectSound.
     //Why I don't know. Check for DirectSound components and
     //call initialize.
     for n := 0 to Owner.ComponentCount - 1 do
         if Owner.Components[n] is TDGCAudio then
            TDGCAudio(Owner.Components[n]).InitDirectSound;
end;

procedure TDGCScreen.InitDirectDraw;
var
   SurfaceDesc: DDSurfaceDesc;
   Caps: DDSCaps;
   n, w, h: Integer;
begin
     if Assigned(FDirectDraw) then exit;

     //Create Direct Draw Object
     if DirectDrawCreate(nil, FDirectDraw, nil) <> DD_OK then
        raise EDGCScreen.Create('Failed to create IDerectDraw object');

     case DisplayMode of
          dm640x480x8:
          begin
               w := 640;
               h := 480;
          end;
          dm320x200x8:
          begin
               w := 320;
               h := 200;
          end;
          dm800x600x8:
          begin
               w := 800;
               h := 600;
          end;
          dm1024x768x8:
          begin
               w := 1024;
               h := 768;
          end;
     end;

     //Set Cooperative Level
     if DirectDraw.SetCooperativeLevel(TForm(Owner).Handle,
        DDSCL_FULLSCREEN + DDSCL_ALLOWREBOOT +
        DDSCL_ALLOWMODEX + DDSCL_EXCLUSIVE ) <> DD_OK then
     begin
          CleanUpDirectDraw;
          Raise EDGCScreen.Create('SetCooperativeLevel Failed');
     end;

     //Set Display Mode
     Application.OnException := DoException;
     Application.OnMessage := AppMessage;

     if DirectDraw.SetDisplayMode(w, h, 8) <> DD_OK then
     begin
          CleanUpDirectDraw;
          Raise EDGCScreen.Create('Set Display Mode Failed');
     end;

     //Create Primary Surface
     FFront := TDGCSurface.CreatePrimary(self);
     FFront.OnSurfaceLost := DoSurfaceLost;
     FBack := TDGCSurface.CreateBackBuffer(FFront);
     FBack.OnSurfaceLost := DoSurfaceLost;

     //Erase front and back buffers to Color Index 0
     CreateDefaultPalette;

     FDirectDraw.FlipToGDISurface;
     Back.Erase(0);
     Flip;
     Back.Erase(0);
     FDirectDraw.FlipToGDISurface;

     //Allow the game to be initialized but before calling event
     //Set library if one has been specified
     Screen.Cursor := crNone;
     if Assigned(FImageLib) then
        SetImageLibrary(FImageLib, True);
     if Assigned(FOnInitialize) then
        FOnInitialize(Self);
end;

procedure TDGCScreen.CleanUpDirectDraw;
begin
     //stop page flipping
     if not Assigned(FDirectDraw) then exit;
     FlippingEnabled := False ;

     //Call Cleanup method
     if Assigned(FOnCleanUp) then
        OnCleanUp(Self);

     //Free coonverted image library image list;
     FreeImageList;

     //Free the TDGCCanvas objects before the surfaces
     if Assigned(FFront) then FFront.Free;
     if Assigned(FBack) then FBack.Free;


     //Free Palette
     if Assigned(FPalette) then
        FPalette.Release;
     FPalette := nil;

     //Free the DirectDraw COM object by calling its Release method
     if Assigned(FDirectDraw) then
     begin
          FDirectDraw.RestoreDisplayMode;
          FDirectDraw.Release;
          FDirectDraw := nil;
     end;

     // remove application exception handler
     Application.OnException := nil;
     Application.OnMessage := nil;
end;

procedure TDGCScreen.DoException(Sender: TObject; E: Exception);
begin
     if FBeepOnException then
        MessageBeep(0);
     if FDebug then
        TraceString(E.Message);
end ;

procedure TDGCScreen.Flip;
var
   r: HResult;
begin
     r := FFront.Surface.Flip(nil, DDFLIP_WAIT);
     if r <> DD_OK then
        if r = DDERR_SURFACELOST then
           RestoreSurfaces
        else
           raise EDGCScreen.Create('Flip Failed');
end;

procedure TDGCScreen.AppIdle(Sender: TObject; var Done: Boolean);
begin
     Done := False;
     if not Assigned(FDirectDraw) then exit;
     if Assigned(FOnFlip) then
        FOnFlip(Self);
     Flip;
end;

procedure TDGCScreen.AppMessage(var Msg: TMsg; var Handled : boolean ) ;
begin
     //Enable/Disbale Idle event if application not active
     case Msg.Message of
          WM_ACTIVATEAPP:
          begin
               if not Boolean(Msg.wParam) then
                  StopTimer
               else
               begin
                  PostMessage(Application.Handle, WM_DGCACTIVATE, 0, 0);
               end;
          end;
          WM_DGCACTIVATE:
          begin
              RestoreSurfaces;
              if FlippingEnabled then
                 StartTimer;
              //else
              if Assigned(FOnPaint) then
                 FOnPaint(Self);
          end;
     end;
end ;

procedure TDGCScreen.SetFlippingEnabled(b: Boolean);
begin
     if b <> FFlippingEnabled then
     begin
          FFlippingEnabled := b;
          if not (csDesigning in ComponentState) then
          begin
               if FFlippingEnabled then
                  StartTimer
               else
                   StopTimer;
          end;
     end;
end;

procedure TDGCScreen.SetDebug(NewVal: Boolean);
begin
     if FDebug <> NewVal then
     begin
          FDebug := NewVal;
          //DebugMode := FDebug;
     end;
end;

procedure TDGCScreen.CreateSurface(var Surface: TDGCSurface; W, H: Integer);
begin
     Surface := nil;
     Surface := TDGCSurface.Create(DirectDraw, W, H);
end;

procedure TDGCScreen.WaitForVerticalBlank;
begin
     if DirectDraw.WaitForVerticalBlank(DDWAITVB_BLOCKBEGIN, 0) <> DD_OK then
        raise EDGCScreen.Create('WaitForVericalBlankError');
end;

function TDGCScreen.GetScreenWidth: Integer;
begin
     Result := Front.Width;
end;

function TDGCScreen.GetScreenHeight: Integer;
begin
     Result := Front.Height;
end;

function TDGCScreen.KeyDown(Key: Word): Boolean;
begin
     Result := GetASyncKeyState(Key) < 0;
end;

procedure TDGCScreen.SetPalette(var NewPalette: T256PaletteEntry);
var
   Flags: DWORD;
begin
     //First Release Pallete
     FPaletteEntries := NewPalette;
     if Assigned(FPalette) then
     begin
          if FPalette.SetEntries(0, 0, 256, @FPaletteEntries[0]) <> DD_OK then
             raise EDGCScreen.Create('SetEntries Failed');
          exit;
     end;

     //Create the Palette
     Flags := DDPCAPS_8BIT or DDPCAPS_ALLOW256;

     if FDirectDraw.CreatePalette (Flags, @FPaletteEntries[0],
                                   FPalette, nil ) <> DD_OK then
        raise EDGCScreen.Create('CreatePalette Failed');
     //Set Palette
     if FFront.Surface.SetPalette(FPalette) <> DD_OK then
       Raise EDGCScreen.Create('SetPalette Failed') ;
end;

procedure TDGCScreen.FadePaletteOut(Delay: Integer);
var
   Pal: T256PaletteEntry;
   n, c, d: Integer;
begin
     if not Assigned(FPalette) then
        raise EDGCScreen.Create('No palette set');
     //Get the current colours
     FPalette.GetEntries(0, 0, 256, @Pal[0]);

     //Create the temporary Palette

     //Set the color and step
     for c := Delay DownTo 0 do
     begin
          for n := 0 to 255 do
          begin
               with Pal[n] do
               begin
                    peRed := (FPaletteEntries[n].peRed * c) div Delay;
                    peGreen := (FPaletteEntries[n].peGreen * c) div Delay;
                    peBlue := (FPaletteEntries[n].peBlue * c) div Delay;
               end;
          end;
          WaitForVerticalBlank;
          FPalette.SetEntries(0, 0, 256, @Pal[0]);
     end;
end;

procedure TDGCScreen.FadePaletteIn(Delay: Integer);
var
   Pal: T256PaletteEntry;
   NewPal: IDirectDrawPalette;
   n, c: Integer;
begin
     if not Assigned(FPalette) then
        raise EDGCScreen.Create('No palette set');

     //Set the color and step
     ZeroMemory(@Pal[0], SizeOf(Pal));
     for c := 0 to Delay do
     begin
          for n := 0 to 255 do
          begin
               with Pal[n] do
               begin
                    peRed := (FPaletteEntries[n].peRed * c) div Delay;
                    peGreen := (FPaletteEntries[n].peGreen * c) div Delay;
                    peBlue := (FPaletteEntries[n].peBlue * c) div Delay;
               end;
          end;
          WaitForVerticalBlank;
          FPalette.SetEntries(0, 0, 256, @Pal[0]);
     end;
end;

procedure TDGCScreen.SetImageLibrary(Lib: TDGCImageLib; UsePalette: Boolean);
var
   n, y: Integer;
   Pal: T256PaletteEntry;
   SBits, DBits: PByte;
   SWidthBytes, DWidthBytes: Integer;
begin
     //Now assign library and create a palette
     FreeImageList;
     if Lib = nil then exit;
     if Lib.ImageCount = 0 then exit;
     FDGCImageLib := Lib;
     if UsePalette then
     begin
          for n := 0 to 255 do
          begin
               with Lib.Images.Header.Palette[n] do
               begin
                    Pal[n].peRed := Red;
                    Pal[n].peGreen := Green;
                    Pal[n].peBlue := Blue;
                    Pal[n].peFlags := 0;
               end;
          end;
          SetPalette(Pal);

     end;

     //Allocate Memory for Surfaces List
     FreeImageList;

     //Create Surfaces for Objects
     FImageListCount := Lib.ImageCount;
     GetMem(FImageList, FImageListCount * SizeOf(TDGCSurface));
     for n := 0 to Lib.ImageCount - 1 do
     begin
          with Lib.Images.ImageData[n] do
          begin
               FImageList^[n] := TDGCSurface.Create(FDirectDraw, Width, Height);
               FImageList^[n].OnSurfaceLost := DoSurfaceLost;
               SBits := Bits;
               DBits := FImageList^[n].GetPointer;
               try
                  //Copy Bits
                  SWidthBytes := WidthBytes(Width);
                  DWidthBytes := FImageList^[n].WidthBytes;
                  for y := 0 to Height - 1  do
                  begin
                       Move(SBits^, DBits^, Width);
                       Inc(SBits, SWidthBytes);
                       Inc(DBits, DWidthBytes);
                  end;
               finally
                      FImageList^[n].ReleasePointer;
               end;
               FImageList^[n].TransparentColor := 0;
          end;
     end;
     //If Image Library samples were loaded from file then
     //free them
     if FDGCImageLib.IsFileLibrary then
        FDGCImageLib.Images.FreeImages;
end;

function TDGCScreen.GetImage(Index: Integer): TDGCSurface;
begin
     if FImageList = nil then
        raise EDGCScreen.Create('A library must be set with SetImageLibrary');
     Result := FImageList^[Index];
end;

procedure TDGCScreen.FreeImageList;
var
   n: Integer;
begin
     if FImageList = nil then exit;
     //Free Surface variables
     for n := 0 to FImageListCount - 1 do
          FImageList^[n].Free;
     //Free List
     FreeMem(FImageList, FImageListCount * SizeOf(TDGCSurface));
     FImageList := nil;
end;

procedure TDGCScreen.DoSurfaceLost(Surface: TDGCSurface);
begin
     RestoreSurfaces;
end;

procedure TDGCScreen.RestoreSurfaces;
var
   r: HResult;
begin
     r := FFront.Surface.Restore;
     if r <> DD_OK then
     begin
          case r of
               DDERR_WRONGMODE: TraceString('Restore Failed: Wrong Mode');
               DDERR_INVALIDOBJECT: TraceString('Restore Failed: Invalid Object');
               DDERR_NOEXCLUSIVEMODE: TraceString('Restore Failed: No Exclusive');
               DDERR_GENERIC: TraceString('Restore Failed: Generic');
          else
              TraceString('Restore Failed: UnKnown');
          end;
          raise EDGCScreen.Create('RestoreSurfaces Failed (Front)');
     end;
     if FDGCImageLib <> nil then
     begin
          if FDGCImageLib.IsFileLibrary then
             FDGCImageLib.ReLoadFromFile;
          SetImageLibrary(FDGCImageLib, True);
     end;
     //if Assigned(FOnPaint) then
     //   FOnPaint(Self);
end;

procedure TDGCScreen.StartTimer;
begin
     Application.OnIdle := AppIdle;
end;

procedure TDGCScreen.StopTimer;
begin
     Application.OnIdle := nil;
end;

procedure TDGCScreen.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
       if FImageLib = AComponent then
          FImageLib := nil;
  end;
end;

function TDGCScreen.GetClipRect: TRect;
begin
     Result := FFront.ClipRect;
end;

procedure TDGCScreen.SetClipRect(NewVal: TRect);
begin
     FFront.ClipRect := NewVal;
     FBack.ClipRect := NewVal;
end;

procedure TDGCScreen.CreateDefaultPalette;
var
   n: Integer;
   Palette: T256PaletteEntry;
   Handle: hWnd;
   dc: HDC;
begin
     //Create Random Colors for non system colors
     for n := 10 to 245 do
     begin
          with Palette[n] do
          begin
               peRed := Random(255);
               peGreen := Random(255);
               peBlue := Random(255);
               peFlags := 0;
          end;
     end;
     Handle := GetFocus;
     dc := GetDC(Handle);
     GetSystemPaletteEntries(dc, 0, 10, Palette[0]);
     GetSystemPaletteEntries(dc,246, 10, Palette[246]);
     ReleaseDC(Handle, dc);
     SetPalette(Palette);
end;

procedure TDGCScreen.FlipScroll(XSpeed, YSpeed: Integer);
var
   nsh, nsw, sp: Integer;
   FromSurface, ToSurface: TDGCSurface;
   x, y, xp, yp: Integer;
begin
     //Create Surfaces
     try
        FromSurface := TDGCSurface.Create(DirectDraw, FFront.Width, FFront.Height);
        try
           ToSurface := TDGCSurface.Create(DirectDraw, FFront.Width, FFront.Height);
        except
              FromSurface.Free;
        end;
     except
           raise;
           exit;
     end;
     //DO the Flip - First take a copy of the front and back buffers
     try
        FromSurface.Draw(0, 0, FFront, False);
        ToSurface.Draw(0,0, FBack, False);
        FBack.Erase(0);
        if YSpeed <> 0 then
           nsh := (FromSurface.Height div Abs(YSpeed)) - 1
        else
            nsh := 0;
        if XSpeed <> 0 then
           nsw := (FromSurface.Width div Abs(XSpeed)) - 1
        else
            nsw := 0;
        xp := 0;
        yp := 0;
        if YSpeed = 0 then
           y := 0
        else if YSpeed > 0 then
           y := ToSurface.Height
        else
            y := -ToSurface.Height;
        if XSpeed = 0 then
           x := 0
        else if XSpeed > 0 then
           x := ToSurface.Width
        else
            x := -ToSurface.Width;
        while (nsw > 0) or (nsh > 0) do
        begin
             if nsh > 0 then
                Inc(yp, YSpeed);
             if nsw > 0 then
                Inc(xp, XSpeed);
             FBack.Draw(0 - xp, 0 - yp, FromSurface, False);
             FBack.Draw(x - xp, y - yp, ToSurface, False);
             Flip;
             Dec(nsw);
             Dec(nsh);
        end;
        FBack.Draw(0, 0, ToSurface, False);
        Flip;
     finally
            FromSurface.Free;
            ToSurface.Free;
     end;
end;


end.
