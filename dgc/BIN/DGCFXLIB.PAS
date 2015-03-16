{The Delpi Games Creator - Beta 2
 --------------------------------
 Copyright 1996 John Pullen
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
}

unit Dgcfxlib;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DsgnIntf, BmpUtil,DGC,DDraw,DGCfx;

const
     ImageLibID = 'CR10';
     MaxIntroFrames = 100;

type
  TIntroFrameArray = array[0..MaxIntroFrames] of Integer;
  TIntroEvent = Procedure of Object;

  //Image Library Storage Class
  TDGCIntros = class(TPersistent)
  private
    { Private declarations }
    function GetImageData(Index: Integer): TIntroLibImage;
    function GetCount: Integer;
  protected
    { Protected declarations }
    procedure DefineProperties(Filer: TFiler); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    { Public declarations }
    ImgHeader: TImgLibHeader;
    FImages: PIntroLibImageList;
    procedure FreeImages;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property ImageData[Index: Integer]: TIntroLibImage read GetImageData;
    property ImageList: PIntroLibImageList read FImages;
    property Count: Integer read GetCount;
    property Header: TImgLibHeader read ImgHeader;
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: String);
  end;

  //Property Editor Class
  TDGCOpenIntroLibProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes : TPropertyAttributes; override;
    function GetValue : string; override;
  end;

  //Main Class
  TDGCIntroLib = class(TComponent)
  private
    { Private declarations }
    FFrameCount:Integer;
    FFrames:TIntroFrameArray;
    FImages: TDGCIntros;
    FFileName: String;
    FScreen:TDGCScreen;
    FOnIntroStart:TIntroEvent;
    FOnIntroEnd:TIntroEvent;
    function GetImageCount: Integer;
    procedure SetImages(NewVal: TDGCIntros);
    function GetIsFileLibrary: Boolean;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent;Operation: TOperation);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ImageCount: Integer read GetImageCount;
    procedure LoadFromFile(NewFileName: String);
    procedure ReLoadFromFile;
    Procedure Play;
    Procedure PlaySlides(Frames:Array of Integer);
    Procedure AppearSurface(ASurface:TDGCSurface;AnEffect:TEffect;AppearSpeed,Holdtime:Integer);
    property IsFileLibrary: Boolean read GetIsFileLibrary;
    property Images: TDGCIntros read FImages write SetImages;
  published
    { Published declarations }

    Property DGCScreen:TDGCScreen read FScreen write FScreen;
    Property Filename:String Read FFileName Write FFileName;
    Property OnIntroStart:TIntroEvent Read FOnIntroStart Write FOnIntroStart;
    Property OnIntroEnd:TintroEvent Read FOnIntroEnd Write FOnIntroEnd;
  end;

implementation

uses dgcfxlo;

//TDGCIntroLib Implementation
//===========================
constructor TDGCIntroLib.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FFilename:='';
     FImages := TDGCIntros.Create;
end;

Procedure TDGCIntroLib.AppearSurface(ASurface:TDGCSurface;AnEffect:TEffect;AppearSpeed,Holdtime:Integer);
var
   FFx:TDGCEffects;
   FirstTick:Longint;
begin
     Ffx:=TDGCEffects.Create(nil);
     ffx.DGCScreen:=DGCscreen;
     With FFx do
     begin
          Effect:=AnEffect;
          Speed:=AppearSpeed;
          Appear(ASurface,false);
          firsttick:=gettickcount;
          while gettickcount-firsttick < HoldTime*1000 do
          begin
               if FScreen.keyDown(vk_escape) then
                  exit;
          end;
     end;
     Ffx.Free;
end;

procedure TDGCIntroLib.Play;
var
   n, y: Integer;
   Pal: T256PaletteEntry;
   Oldpal: TImgLibPalette;
   SBits, DBits: PByte;
   SWidthBytes, DWidthBytes: Integer;
   FFxSurface:TDgcSurface;
   FDirectDraw: IDirectDraw;
   Ffx:TDGCEffects;
   firsttick:longint;
   loadedfromfile:boolean;
begin
     If Assigned(FOnIntroStart) then
        OnIntroStart;
     Loadedfromfile:=false;
     if FScreen.ImageLibrary <> nil then
     oldpal:=FScreen.ImageLibrary.Images.Header.Palette;
     if (FImages = nil) then
         exit;
     if Not FileExists(FFilename) then
          exit
     else
     begin
           FImages.LoadfromFile(FFilename);
           Loadedfromfile:=true;
     end;
     if Fimages.Count = 0 then exit;
     for n := 0 to 255 do
     begin
          with FImages.Header.Palette[n] do
          begin
               Pal[n].peRed := Red;
               Pal[n].peGreen := Green;
               Pal[n].peBlue := Blue;
               Pal[n].peFlags := 0;
          end;
     end;
     Fscreen.SetPalette(Pal);
     //Create Surfaces for Objects
     //GetMem(FFxSurface, SizeOf(TDGCSurface));
     Ffx:=TDGCEffects.Create(nil);
     ffx.DGCScreen:=DGCscreen;
     for n := 0 to fImages.Count - 1 do
     begin
          with FImages.ImageData[n] do
          begin
               FFxSurface := TDGCSurface.Create(Fscreen.DirectDraw, Width, Height);
               SBits := Bits;
               DBits := FFxSurface.GetPointer;
               try
                  //Copy Bits
                  SWidthBytes := WidthBytes(Width);
                  DWidthBytes := FFxSurface.WidthBytes;
                  for y := 0 to Height - 1  do
                  begin
                       Move(SBits^, DBits^, Width);
                       Inc(SBits, SWidthBytes);
                       Inc(DBits, DWidthBytes);
                  end;
               finally
                      FFxSurface.ReleasePointer;
               end;
               FfxSurface.TransparentColor := 0;
          end;
          {effectspart here}
          With FFx do
          begin
               Effect:=FImages.ImageData[n].Effect;
               Speed:=FImages.ImageData[n].Speed;
               Appear(FFxSurface,false);
               firsttick:=gettickcount;
               while gettickcount-firsttick < Fimages.ImageData[n].Hold*1000 do
               begin
                      if FScreen.keyDown(vk_escape) then
                         exit;
                      if FScreen.keyDown(vk_space) then
                         break;
               end;
          end;
          if FScreen.keyDown(vk_escape) then
             exit;
     end;
     If (LoadedfromFile) and (FImages <> nil) then
     begin
        Fimages.Free;
        Fimages:=Nil;
     end;
     for n := 0 to 255 do
     begin
          with oldPal[n] do
          begin
               Pal[n].peRed := Red;
               Pal[n].peGreen := Green;
               Pal[n].peBlue := Blue;
               Pal[n].peFlags := 0;
          end;
     end;
     // if we got an image library reset it's palette
     if FScreen.ImageLibrary <> nil then
     Fscreen.SetPalette(Pal);
     FFx.Free;
     If Assigned(FOnIntroEnd) then
        OnIntroEnd;
end;

procedure TDGCIntroLib.PlaySlides(Frames:Array of Integer);
var
   n, y: Integer;
   Pal: T256PaletteEntry;
   Oldpal: TImgLibPalette;
   SBits, DBits: PByte;
   SWidthBytes, DWidthBytes: Integer;
   FFxSurface:TDgcSurface;
   FDirectDraw: IDirectDraw;
   Ffx:TDGCEffects;
   firsttick:longint;
   loadedfromfile:boolean;
   Framecount:word;
begin
     If Assigned(FOnIntroStart) then
        OnIntroStart;
     FrameCount:=High(Frames);
     Loadedfromfile:=false;
     if FScreen.ImageLibrary <> nil then
     oldpal:=FScreen.ImageLibrary.Images.Header.Palette;
     if (FImages = nil) then
         exit;
     if Not FileExists(FFilename) then
          exit
     else
     begin
           FImages.LoadfromFile(FFilename);
           Loadedfromfile:=true;
     end;
     if Fimages.Count = 0 then exit;
     for n := 0 to 255 do
     begin
          with FImages.Header.Palette[n] do
          begin
               Pal[n].peRed := Red;
               Pal[n].peGreen := Green;
               Pal[n].peBlue := Blue;
               Pal[n].peFlags := 0;
          end;
     end;
     Fscreen.SetPalette(Pal);
     //Create Surfaces for Objects
     //GetMem(FFxSurface, SizeOf(TDGCSurface));
     Ffx:=TDGCEffects.Create(nil);
     ffx.DGCScreen:=DGCscreen;
     for n := 0 to FrameCount do
     begin
          with FImages.ImageData[Frames[n]] do
          begin
               FFxSurface := TDGCSurface.Create(Fscreen.DirectDraw, Width, Height);
               SBits := Bits;
               DBits := FFxSurface.GetPointer;
               try
                  //Copy Bits
                  SWidthBytes := WidthBytes(Width);
                  DWidthBytes := FFxSurface.WidthBytes;
                  for y := 0 to Height - 1  do
                  begin
                       Move(SBits^, DBits^, Width);
                       Inc(SBits, SWidthBytes);
                       Inc(DBits, DWidthBytes);
                  end;
               finally
                      FFxSurface.ReleasePointer;
               end;
               FfxSurface.TransparentColor := 0;
          end;
          {effectspart here}
          With FFx do
          begin
               Effect:=FImages.ImageData[Frames[n]].Effect;
               Speed:=FImages.ImageData[Frames[n]].Speed;
               Appear(FFxSurface,false);
               firsttick:=gettickcount;
               while gettickcount-firsttick < Fimages.ImageData[Frames[n]].Hold*1000 do
               begin
                      if FScreen.keyDown(vk_escape) then
                         exit;
                      if FScreen.keyDown(vk_space) then
                         break;
               end;
          end;
          if FScreen.keyDown(vk_escape) then
             exit;
     end;
     If (LoadedfromFile) and (FImages <> nil) then
     begin
        Fimages.Free;
        Fimages:=Nil;
     end;
     for n := 0 to 255 do
     begin
          with oldPal[n] do
          begin
               Pal[n].peRed := Red;
               Pal[n].peGreen := Green;
               Pal[n].peBlue := Blue;
               Pal[n].peFlags := 0;
          end;
     end;
     // if we got an image library reset it's palette
     if FScreen.ImageLibrary <> nil then
     Fscreen.SetPalette(Pal);
     FFx.Free;
     If Assigned(FOnIntroEnd) then
        OnIntroEnd;
end;

procedure TDGCIntroLib.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
       if FScreen = AComponent then
          FScreen := nil;
  end;
end;

destructor TDGCIntroLib.Destroy;
begin
     FImages.Free;
     inherited Destroy;
end;

procedure TDGCIntroLib.SetImages(NewVal: TDGCIntros);
begin
     FImages.Assign(NewVal);
end;

function TDGCIntroLib.GetImageCount: Integer;
begin
     if Assigned(FImages) then
        Result := FImages.Header.ImageCount
     else
         Result := 0;
end;

procedure TDGCIntroLib.LoadFromFile(NewFilename:string);
begin
     if FFilename <> '' then
        exit;
     FImages.LoadFromFile(NewFileName);
     FFileName := NewFileName;
end;

function TDGCIntroLib.GetIsFileLibrary: Boolean;
begin
     Result := FFileName <> '';
end;

procedure TDGCIntroLib.ReLoadFromFile;
begin
     if FFileName = '' then
        raise Exception.Create('LoadFromFile must be called first');
     LoadFromFile(FFileName);
end;

//TDGCImages Implementation
//==========================
constructor TDGCIntros.Create;
begin
     inherited Create;
     ZeroMemory(@ImgHeader, SizeOf(ImgHeader));
     FImages := nil;
end;

destructor TDGCIntros.Destroy;
begin
     FreeImages;
     inherited Destroy;
end;


procedure TDGCIntros.LoadFromStream(Stream: TStream);
var
   n: Integer;
   ImgHdr: TIntroLibImage;
begin
     //Read Header
     FreeImages; //Remove current image list if there is one
     Stream.ReadBuffer(ImgHeader, SizeOf(ImgHeader));
     if StrLIComp(PChar(ImageLibID), ImgHeader.Ident, 4) <> 0 then
        raise Exception.Create('Not a valid Image Library File');
     GetMem(FImages, ImgHeader.ImageCount * SizeOF(TIntroLibImage));
     if FImages = nil then
        raise Exception.Create('TDGCImage: GemMem Failed for FImages');
     for n := 0 to ImgHeader.ImageCount - 1 do
     begin
          ImgHdr := FImages^[n];
          //Read Image Header
          Stream.ReadBuffer(ImgHdr, SizeOf(TIntroLibImage) - SizeOf(PByte));
          //Alocate memory for bits and read bits
          GetMem(ImgHdr.Bits, WidthBytes(ImgHdr.Width) * ImgHdr.Height);
          if ImgHdr.Bits = nil then
             raise Exception.Create('TDGCImage: GemMem Failed for ImgHdr.Bits');
         Stream.ReadBuffer(ImgHdr.Bits^, WidthBytes(ImgHdr.Width) * ImgHdr.Height);
         FImages^[n] := ImgHdr;
     end;
end;

procedure TDGCIntros.SaveToStream(Stream: TStream);
var
   n: Integer;
   ImgHdr: TIntroLibImage;
begin
     Stream.WriteBuffer(ImgHeader, SizeOf(ImgHeader));
     for n := 0 to ImgHeader.ImageCount - 1 do
     begin
          ImgHdr := FImages^[n];
          //write Image Header
          Stream.WriteBuffer(ImgHdr, SizeOf(TIntroLibImage) - SizeOf(PByte));
          //Write image bits
          Stream.WriteBuffer(ImgHdr.Bits^, WidthBytes(ImgHdr.Width) * ImgHdr.Height);
     end;
end;

procedure TDGCIntros.DefineProperties(Filer: TFiler);

    function HasImages: Boolean;
    begin
         if FImages <> nil then
            Result := True
         else
             Result := False;
    end;
begin
     inherited DefineProperties(Filer);
     Filer.DefineBinaryProperty('Intros', LoadFromStream, SaveToStream, HasImages);
end;

//Free the specified Image from the list box item idx
procedure TDGCIntros.FreeImages;
var
   Image: TIntroLibImage;
   idx: Integer;
begin
     if FImages = nil then exit;
     for idx := 0 to ImgHeader.ImageCount - 1 do
     begin
          Image := FImages^[idx];
          if Image.Bits <> nil then
             FreeMem(Image.Bits, WidthBytes(Image.Width) * Image.Height);
     end;
     FreeMem(FImages, ImgHeader.ImageCount * SizeOF(TIntroLibImage));
     FImages := nil;
     ImgHeader.ImageCount := 0;
end;

procedure TDGCIntros.LoadFromFile(FileName: String);
var
   Stream: TFileStream;
begin
     Stream := TFileStream.Create(FileName, fmOpenRead);
     LoadFromStream(Stream);
     Stream.Free;
end;

function TDGCIntros.GetImageData(Index: Integer): TIntroLibImage;
begin
     Result := FImages^[Index];
end;

function TDGCIntros.GetCount: Integer;
begin
     Result := ImgHeader.ImageCount;
end;

procedure TDGCIntros.AssignTo(Dest: TPersistent);
var
   I: TDGCIntros;
   ImageSize: Integer;
   n: Integer;
   ImgHdr: TIntroLibImage;
   Ilist: PIntroLibImageList;
begin
     //Copy Header
     if Dest is TDGCIntros then
     begin
          //Remove any images already loaded
          I := TDGCIntros(Dest);
          I.FreeImages;
          if ImgHeader.ImageCount = 0 then
             exit;
          //Move header
          I.ImgHeader := ImgHeader;
          //Allocate Memory for ImageList
          ImageSize := I.ImgHeader.ImageCount * SizeOF(TIntroLibImage);
          GetMem(IList, ImageSize);
          if IList = nil then
             raise Exception.Create('TDGCImages.AssignTo failed (GetMem): ' + IntToStr(ImageSize));
          I.FImages := IList;
          //Copy the data
          for n := 0 to I.ImgHeader.ImageCount - 1 do
          begin
               ImgHdr := FImages^[n];
               ImageSize := WidthBytes(ImgHdr.Width) * ImgHdr.Height;
               GetMem(ImgHdr.Bits, ImageSize);
               if ImgHdr.Bits = nil then
                  raise Exception.Create('TDGCImages.AssignTo failed');
               Move(FImages^[n].Bits^, ImgHdr.Bits^, ImageSize);
               I.FImages^[n] := ImgHdr;
          end;
          exit;
     end;
     inherited AssignTo(Dest);
end;

//Propery Editor Implemantation
function TDGCOpenIntroLibProperty.GetAttributes : TPropertyAttributes;
begin
  Result := [ paDialog ];
end;

//TDGCOpenLibProperty Implemenataion
function TDGCOpenIntroLibProperty.GetValue : string;
begin
  Result := '(TDGCIntros)';
end;

procedure TDGCOpenIntroLibProperty.Edit;
var
   I: TDGCIntros;
begin
     //This bit i'm not too sure about. The following code works
     //but other propert editors do not have to do the assign
     //they just call the GetOrdValue and SetOrdValue methods
     //???????
     frmOpenintroLib := TfrmOpenIntroLib.Create(Application);
     I := TDGCIntros(GetOrdValue);
     frmOpenintroLib.Images.Assign(I);
     if frmOpenintroLib.ShowModal = mrOK then
     begin
          SetOrdValue(LongInt(I));
          I.Assign(frmOpenintroLib.Images);
     end;
     frmOpenintroLib.Free;
end;


end.
