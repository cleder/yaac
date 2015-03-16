{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit DGCILib;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DsgnIntf, BmpUtil;

const
     ImageLibID = 'IL10';

type
  //Image Library Storage Class
  TDGCImages = class(TPersistent)
  private
    { Private declarations }
    function GetImageData(Index: Integer): TImgLibImage;
    function GetCount: Integer;
  protected
    { Protected declarations }
    procedure DefineProperties(Filer: TFiler); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    { Public declarations }
    ImgHeader: TImgLibHeader;
    FImages: PImgLibImageList;
    procedure FreeImages;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property ImageData[Index: Integer]: TImgLibImage read GetImageData;
    property ImageList: PImgLibImageList read FImages;
    property Count: Integer read GetCount;
    property Header: TImgLibHeader read ImgHeader;
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FileName: String);
  end;

  //Property Editor Class
  TDGCOpenLibProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes : TPropertyAttributes; override;
    function GetValue : string; override;
  end;

  //Main Class
  TDGCImageLib = class(TComponent)
  private
    { Private declarations }
    FImages: TDGCImages;
    FFileName: String;
    function GetImageCount: Integer;
    procedure SetImages(NewVal: TDGCImages);
    function GetIsFileLibrary: Boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DrawImage(Canvas: TCanvas; X, Y: Integer; Idx: Integer);
    property ImageCount: Integer read GetImageCount;
    procedure LoadFromFile(FileName: String);
    procedure ReLoadFromFile;
    property IsFileLibrary: Boolean read GetIsFileLibrary;
  published
    { Published declarations }
    property Images: TDGCImages read FImages write SetImages;
  end;

//procedure Register;

implementation

uses dgcilo, DGC;

//TDGCImageLib Implementation
//===========================
constructor TDGCImageLib.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FFileName := '';
     FImages := TDGCImages.Create;
end;

destructor TDGCImageLib.Destroy;
begin
     FImages.Free;
     inherited Destroy;
end;

procedure TDGCImageLib.SetImages(NewVal: TDGCImages);
begin
     FImages.Assign(NewVal);
end;

function TDGCImageLib.GetImageCount: Integer;
begin
     if Assigned(FImages) then
        Result := FImages.Header.ImageCount
     else
         Result := 0;
end;

procedure TDGCImageLib.LoadFromFile(FileName: String);
begin
     FFileName := '';
     FImages.LoadFromFile(FileName);
     FFileName := FileName;
end;

function TDGCImageLib.GetIsFileLibrary: Boolean;
begin
     Result := FFileName <> '';
end;

procedure TDGCImageLib.ReLoadFromFile;
begin
     if FFileName = '' then
        raise Exception.Create('LoadFromFile must be called first');
     LoadFromFile(FFileName);
end;

procedure TDGCImageLib.DrawImage(Canvas: TCanvas; X, Y: Integer; Idx: Integer);
var
   BmpInfo: PBitmapInfo;
   HeaderSize: Integer;
   ImgHdr: TImgLibImage;
   Palette: TImgLibPalette;
   Bmp: TBitmap;
begin
     Bmp := TBitmap.Create;
     ImgHdr := Images.ImageData[idx];
     HeaderSize := SizeOf(TBitmapInfo) + (256 * SizeOf(TRGBQuad));
     BmpInfo := AllocMem(HeaderSize);
     //First Get Colours
     Palette := Images.Header.Palette;
     ImgLibPalToBmpInfo(Palette, BmpInfo);
     with BmpInfo^.bmiHeader do
     begin
          biSize := SizeOf(TBitmapInfoHeader);
          biWidth := ImgHdr.Width;
          biHeight := -ImgHdr.Height;
          biPlanes := 1;
          biBitCount := 8; //always convert to 8 bit image
          biCompression := BI_RGB;
          biClrUsed := 0;
          biClrImportant := 0;
     end;
     CreateDIB256(Bmp, BmpInfo, ImgHdr.Bits);

     //CleanUp
     FreeMem(BmpInfo, HeaderSize);
     Canvas.Draw(x, y, Bmp);
     Bmp.Free;
end;

//TDGCImages Implementation
//==========================
constructor TDGCImages.Create;
begin
     inherited Create;
     ZeroMemory(@ImgHeader, SizeOf(ImgHeader));
     FImages := nil;
end;

destructor TDGCImages.Destroy;
begin
     FreeImages;
     inherited Destroy;
end;


procedure TDGCImages.LoadFromStream(Stream: TStream);
var
   n: Integer;
   ImgHdr: TImgLibImage;
begin
     //Read Header
     FreeImages; //Remove current image list if there is one
     Stream.ReadBuffer(ImgHeader, SizeOf(ImgHeader));
     if StrLIComp(PChar(ImageLibID), ImgHeader.Ident, 4) <> 0 then
        raise Exception.Create('Not a valid Image Library File');
     GetMem(FImages, ImgHeader.ImageCount * SizeOF(TImgLibImage));
     if FImages = nil then
        raise Exception.Create('TDGCImage: GemMem Failed for FImages');
     for n := 0 to ImgHeader.ImageCount - 1 do
     begin
          ImgHdr := FImages^[n];
          //Read Image Header
          Stream.ReadBuffer(ImgHdr, SizeOf(TImgLibImage) - SizeOf(PByte));
          //Alocate memory for bits and read bits
          GetMem(ImgHdr.Bits, WidthBytes(ImgHdr.Width) * ImgHdr.Height);
          if ImgHdr.Bits = nil then
             raise Exception.Create('TDGCImage: GemMem Failed for ImgHdr.Bits');
         Stream.ReadBuffer(ImgHdr.Bits^, WidthBytes(ImgHdr.Width) * ImgHdr.Height);
         FImages^[n] := ImgHdr;
     end;
end;

procedure TDGCImages.SaveToStream(Stream: TStream);
var
   n: Integer;
   ImgHdr: TImgLibImage;
begin
     Stream.WriteBuffer(ImgHeader, SizeOf(ImgHeader));
     for n := 0 to ImgHeader.ImageCount - 1 do
     begin
          ImgHdr := FImages^[n];
          //write Image Header
          Stream.WriteBuffer(ImgHdr, SizeOf(TImgLibImage) - SizeOf(PByte));
          //Write image bits
          Stream.WriteBuffer(ImgHdr.Bits^, WidthBytes(ImgHdr.Width) * ImgHdr.Height);
     end;
end;

procedure TDGCImages.DefineProperties(Filer: TFiler);

    function HasImages: Boolean;
    begin
         if FImages <> nil then
            Result := True
         else
             Result := False;
    end;
begin
     inherited DefineProperties(Filer);
     Filer.DefineBinaryProperty('Images', LoadFromStream, SaveToStream, HasImages);
end;

//Free the specified Image from the list box item idx
procedure TDGCImages.FreeImages;
var
   Image: TImgLibImage;
   idx: Integer;
begin
     if FImages = nil then exit;
     for idx := 0 to ImgHeader.ImageCount - 1 do
     begin
          Image := FImages^[idx];
          if Image.Bits <> nil then
             FreeMem(Image.Bits, WidthBytes(Image.Width) * Image.Height);
     end;
     FreeMem(FImages, ImgHeader.ImageCount * SizeOF(TImgLibImage));
     FImages := nil;
     ImgHeader.ImageCount := 0;
end;

procedure TDGCImages.LoadFromFile(FileName: String);
var
   Stream: TFileStream;
begin
     Stream := TFileStream.Create(FileName, fmOpenRead);
     LoadFromStream(Stream);
     Stream.Free;
end;

function TDGCImages.GetImageData(Index: Integer): TImgLibImage;
begin
     Result := FImages^[Index];
end;

function TDGCImages.GetCount: Integer;
begin
     Result := ImgHeader.ImageCount;
end;

procedure TDGCImages.AssignTo(Dest: TPersistent);
var
   I: TDGCImages;
   ImageSize: Integer;
   n: Integer;
   ImgHdr: TImgLibImage;
   Ilist: PImgLibImageList;
begin
     //Copy Header
     if Dest is TDGCImages then
     begin
          //Remove any images already loaded
          I := TDGCImages(Dest);
          I.FreeImages;
          if ImgHeader.ImageCount = 0 then
             exit;
          //Move header
          I.ImgHeader := ImgHeader;
          //Allocate Memory for ImageList
          ImageSize := I.ImgHeader.ImageCount * SizeOF(TImgLibImage);
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
function TDGCOpenLibProperty.GetAttributes : TPropertyAttributes;
begin
  Result := [ paDialog ];
end;

//TDGCOpenLibProperty Implemenataion
function TDGCOpenLibProperty.GetValue : string;
begin
  Result := '(TDGCImages)';
end;

procedure TDGCOpenLibProperty.Edit;
var
   I: TDGCImages;
begin
     //This bit i'm not too sure about. The following code works
     //but other propert editors do not have to do the assign
     //they just call the GetOrdValue and SetOrdValue methods
     //???????
     frmOpenLib := TfrmOpenLib.Create(Application);
     I := TDGCImages(GetOrdValue);
     frmOpenLib.Images.Assign(I);
     if frmOpenLib.ShowModal = mrOK then
     begin
          SetOrdValue(LongInt(I));
          I.Assign(frmOpenLib.Images);
     end;
     frmOpenLib.Free;
end;

end.
