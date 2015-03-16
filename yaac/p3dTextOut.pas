unit p3dTextOut;

interface
uses graphics;

procedure s3DTextOutR(x,y,Offset : Integer; sText : String; Canvas : Tcanvas);
procedure s3DTextOutS(x,y,Offset : Integer; sText : String; Canvas : Tcanvas);
implementation

procedure s3DTextOutR(x,y,Offset : Integer; sText : String; Canvas : Tcanvas);
begin
     with  Canvas do begin
           Brush.Style := bsClear;
           Font.Color := clWhite;
           TextOut(x, y, sText);
           //Font.Color := clDkGray;
           //TextOut(x+Offset, y+Offset, sText);
           Font.Color := clGray;
           TextOut(x+Offset, y+Offset, sText);
           Font.Color := clBlack;
           TextOut(x+2*Offset, y+2*Offset, sText);
     end; // with
end; (*s3DTextOutR*)
procedure s3DTextOutS(x,y,Offset : Integer; sText : String; Canvas : Tcanvas);
begin
     with  Canvas do begin
           Brush.Style := bsClear;
           Font.Color := clBlack;
           TextOut(x+2*Offset, y+2*Offset, sText);
           Font.Color := clGray;
           TextOut(x+Offset, y+Offset, sText);
           Font.Color := clWhite;
           TextOut(x, y, sText);
           //Font.Color := clDkGray;
           //TextOut(x+Offset, y+Offset, sText);


     end; // with
end; (*s3DTextOutS*)
end.
