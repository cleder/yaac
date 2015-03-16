unit UnitMapedit;
(*
YaAC  - Yet another Arcanoid Clone -  Map Editor
This work was inspired by the DGC Map Editor
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

Changes:
Beta 2 : 2000-04-09
Map Properties added. You may now change the name of a map.

SetTile moved to OnMouseMove Event. You may now 'paint' a map.

Splitters added to the Form so you can now resize the Listbox and the
ImageLibrary DrawGrid.

The Clear Map icon allows you to clean a map.
This action will use the currently selected tile as the clearing tile.
After you cleared a map, a redraw is forced.

Beta 1: Initial release.
*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DGCILib, DGCMap, ExtCtrls, Menus, StdCtrls, ComCtrls, Buttons,
  ToolWin;

type
  TForm1 = class(TForm)
    DrawGrid1: TDrawGrid;
    DGCImageLib1: TDGCImageLib;
    DGCMapLib1: TDGCMapLib;
    Panel1: TPanel;
    DrawGridImageLib: TDrawGrid;
    Image1: TImage;
    MainMenu1: TMainMenu;
    TitleFile: TMenuItem;
    ItemNewMap: TMenuItem;
    ItemOpenMapLibrary: TMenuItem;
    ItemSaveMapLibrary: TMenuItem;
    ItemSaveMapLibraryAs: TMenuItem;
    N1: TMenuItem;
    ItemExit: TMenuItem;
    TitleMap1: TMenuItem;
    ItemInsertMap: TMenuItem;
    ItemDeleteMap: TMenuItem;
    N2: TMenuItem;
    ItemClearMap: TMenuItem;
    ItemMapProperties: TMenuItem;
    ItemRemapTile: TMenuItem;
    N3: TMenuItem;
    ItemMapDetails: TMenuItem;
    TitleOptions: TMenuItem;
    ItemTransperency: TMenuItem;
    ItemGridLines: TMenuItem;
    TitleHelp: TMenuItem;
    ItemAbout: TMenuItem;
    N4: TMenuItem;
    ItemOpenImageLibrary: TMenuItem;
    OpenDialogMap: TOpenDialog;
    OpenDialogImage: TOpenDialog;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    ListBox1: TListBox;
    CoolBar1: TCoolBar;
    Panel3: TPanel;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButtonSaveAs: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Panel4: TPanel;
    SpeedButtonClearMap: TSpeedButton;
    SpeedButtonProps: TSpeedButton;
    SpeedButtonRemapTile: TSpeedButton;
    SpeedButtonTransparency: TSpeedButton;
    SpeedButtonGridLines: TSpeedButton;
    ComboBoxZoom: TComboBox;
    SpeedButtonZoomIn: TSpeedButton;
    SpeedButtonZoomOut: TSpeedButton;
    PanelBGCColor: TPanel;
    ColorDialog1: TColorDialog;
    Panel5: TPanel;
    SpeedButtonInsertMap: TSpeedButton;
    SpeedButtonDeleteMap: TSpeedButton;
    SpeedButtonMoveMapUp: TSpeedButton;
    SpeedButtonMoveMapDown: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    N5: TMenuItem;
    ItemUndo: TMenuItem;
    PopupMenu1: TPopupMenu;
    ItemProperties: TMenuItem;
    procedure DrawGridImageLibDrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure DrawGridImageLibClick(Sender: TObject);
    procedure ItemExitClick(Sender: TObject);
    procedure ItemOpenImageLibraryClick(Sender: TObject);
    procedure ItemOpenMapLibraryClick(Sender: TObject);
    procedure ItemGridLinesClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure DrawGrid1TopLeftChanged(Sender: TObject);
    procedure SpeedButtonZoomOutClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonZoomInClick(Sender: TObject);
    procedure ItemTransperencyClick(Sender: TObject);
    procedure PanelBGCColorClick(Sender: TObject);
    procedure ComboBoxZoomChange(Sender: TObject);
    procedure DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ItemClearMapClick(Sender: TObject);
    procedure ItemSaveMapLibraryClick(Sender: TObject);
    procedure ItemSaveMapLibraryAsClick(Sender: TObject);
    procedure DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ItemAboutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ItemMapPropertiesClick(Sender: TObject);
    procedure SpeedButtonMoveMapUpClick(Sender: TObject);
    procedure SpeedButtonMoveMapDownClick(Sender: TObject);
    procedure SpeedButtonDeleteMapClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure DrawLibImage(Canvas : TCanvas; x,y : Integer; Tile :Byte);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation
CONST ChangedChar ='*';
Var MapIsChanged : Boolean;
{$R *.DFM}

Function GetMapLibTile(FMapLib: TDGCMapLib; MapIdx,MapX,MapY:Integer) : Byte;
Begin
Result := 0;
   If (MapX > FMapLib.MapLib.Maps[MapIdx].XSize) or (MapX < 0) or
      (MapY > FMapLib.MapLib.Maps[MapIdx].YSize) or (MapY < 0) then exit;
   Result := FMapLib.MapLib.Maps[MapIdx].Data[MapX +(MapY * FMapLib.MapLib.Maps[MapIdx].XSize)];
End;

Procedure SetMaplibTile(FMapLib: TDGCMapLib; MapIdx:Integer; MapX,MapY : Integer; NewTile:Byte);
Begin
If (MapX > FMapLib.MapLib.Maps[MapIdx].XSize) or (MapX < 0) or
      (MapY > FMapLib.MapLib.Maps[MapIdx].YSize) or (MapY < 0) then exit;
   FMapLib.MapLib.Maps[MapIdx].Data[MapX +(MapY * FMapLib.MapLib.Maps[MapIdx].XSize)] := NewTile;
End;

Procedure TForm1.DrawLibImage(Canvas : TCanvas; x,y : Integer; Tile :Byte);
VAR TransColor : Integer;
begin
     TransColor:=DGCImageLib1.Images.ImgHeader.TransparentColor;
     if SpeedButtonTransparency.Down then
           DGCImageLib1.DrawTrans( Canvas, x, y, Tile, TransColor)
     else
         DGCImageLib1.DrawImage(Canvas, x, y, Tile);
end;

procedure TForm1.DrawGridImageLibDrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
  VAR I : Integer;
  DrawRect : TRect;
begin
 with Sender as TDrawGrid do
  begin
    for i := DrawGridImageLib.TopRow to  DrawGridImageLib.TopRow + DrawGridImageLib.VisibleRowCount do
    begin
    DrawRect := DrawGridImageLib.CellRect(0,i);
    Canvas.Brush.Color := PanelBGCColor.Color;
    Canvas.FillRect(DrawRect);
    DrawLibImage(Canvas,DrawRect.Left, DrawRect.Top,i);
    if gdFocused in State then
      Canvas.DrawFocusRect(Rect);
  end;
  end;
end;



procedure TForm1.DrawGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);

VAR
   Tile : Byte;

begin
     If (ListBox1.ItemIndex <> -1) and (DGCMapLib1.MapLib.MapCount >= ListBox1.ItemIndex)  Then
     begin
       Tile := GetMapLibTile( DGCMapLib1,ListBox1.ItemIndex, col , row);
       with Sender as TDrawGrid do
       begin
          Canvas.Brush.Color := PanelBGCColor.Color;
          Canvas.FillRect(Rect);

          DrawLibImage(Canvas,Rect.Left, Rect.Top,Tile);
          // DGCImageLib1.DrawTrans( Canvas,Rect.Left, Rect.Top,Tile,clBlack);
         // DGCImageLib1.DrawStretch(Canvas,Rect.Left, Rect.Top,Rect.Right-Rect.Left, Rect.Bottom - Rect.Top ,Tile);
             if gdFocused in State then
                Canvas.DrawFocusRect(Rect);
       end;
     end;
end;

procedure TForm1.DrawGridImageLibClick(Sender: TObject);
begin
     Image1.Canvas.Brush.Color := PanelBGCColor.Color;
     Image1.Canvas.Brush.Style := bsSolid;
     Image1.Canvas.FillRect(Image1.BoundsRect);
     DrawLibImage(Image1.Canvas,0, 0,DrawGridImageLib.Row)
end;

procedure TForm1.ItemExitClick(Sender: TObject);
begin
     Form1.Close;
end;

procedure TForm1.ItemOpenImageLibraryClick(Sender: TObject);
begin
     if OpenDialogImage.Execute Then Begin
          DGCImageLib1.LoadFromFile(OpenDialogImage.FileName);
          DrawGridImageLib.Rowcount := DGCImageLib1.ImageCount;
          //Adjust the Grids to the size of the images
          DrawGridImageLib.DefaultColWidth := DGCImageLib1.Images.ImageData[0].Width;
          DrawGridImageLib.DefaultRowHeight := DGCImageLib1.Images.ImageData[0].Height;
          DrawGrid1.DefaultColWidth := DGCImageLib1.Images.ImageData[0].Width;
          DrawGrid1.DefaultRowHeight := DGCImageLib1.Images.ImageData[0].Height;
          Image1.Width := DGCImageLib1.Images.ImageData[0].Width;
          Image1.Height := DGCImageLib1.Images.ImageData[0].Height;

     end;

end;

procedure TForm1.ItemOpenMapLibraryClick(Sender: TObject);
var I : Integer;
begin
     if StatusBar1.Panels[5].Text = ChangedChar Then
       case  MessageDlg( 'Do you want to save changed Work?' ,mtConfirmation,
                  [mbYes, mbNo,mbCancel],0) of
                  mrCancel : Exit;
                  mrYes : If SaveDialog1.Execute then
                          DGCMapLib1.MapLib.SaveToFile(SaveDialog1.FileName)
                          else Exit;

                  end;


     if OpenDialogMap.execute then Begin
        DGCMapLib1.MapLib.LoadFromFile(OpenDialogMap.FileName);
        ListBox1.Items.Clear;
        ItemSaveMapLibrary.Enabled := True;
        StatusBar1.Panels[0].Text := OpenDialogMap.FileName;
        StatusBar1.Panels[5].Text := '';
        for i :=0 to DGCMapLib1.MapLib.MapCount do begin
            ListBox1.Items.Add(DGCMapLib1.MapLib.Maps[i].Name);
         end;
         ListBox1.ItemIndex := 0;
         ListBox1Click(NIL);
         (*StatusBar1.Panels[1].Text := '0';
         DrawGrid1.ColCount := DGCMapLib1.MapLib.Maps[0].XSize;
         DrawGrid1.RowCount := DGCMapLib1.MapLib.Maps[0].YSize;
         DrawGrid1TopLeftChanged(NIL);*)
         ItemMapProperties.Enabled := True;
         SpeedButtonProps.Enabled := True;
         SpeedButtonMoveMapUp.Enabled := True;
         SpeedButtonMoveMapDown.Enabled := True;
     end;
end;

procedure TForm1.ItemGridLinesClick(Sender: TObject);
begin
     ItemGridLines.Checked := not ItemGridLines.Checked;
     if ItemGridLines.Checked then  begin
        DrawGrid1.GridLineWidth := 1;
        SpeedButtonGridLines.Down := true;
     end
     else Begin
        DrawGrid1.GridLineWidth := 0;
        SpeedButtonGridLines.Down := False;
     end;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  IF ListBox1.ItemIndex >=0 then
   if ListBox1.ItemIndex <= DGCMapLib1.MapLib.MapCount then Begin
      DrawGrid1.ColCount := DGCMapLib1.MapLib.Maps[ListBox1.ItemIndex].XSize;
      DrawGrid1.RowCount := DGCMapLib1.MapLib.Maps[ListBox1.ItemIndex].YSize;
      DrawGrid1.Col := 0;
      DrawGrid1.Row := 0;
      StatusBar1.Panels[1].Text := IntToStr(ListBox1.ItemIndex);
      StatusBar1.Panels[2].Text := IntToStr(DrawGrid1.ColCount) + ' x ' + IntToStr(DrawGrid1.RowCount);
      DrawGrid1TopLeftChanged(NIL);
   end; // if
end;

procedure TForm1.DrawGrid1TopLeftChanged(Sender: TObject);
VAR
   i,j :Integer;
   DrawRect : TRect;
   Tile : Byte;

begin
   If (ListBox1.ItemIndex <> -1) then //and (DGCMapLib1.MapLib.MapCount <= ListBox1.ItemIndex)  Then
     begin
     for I := DrawGrid1.LeftCol to DrawGrid1.LeftCol + DrawGrid1.VisibleColCount-1 do
           for J := DrawGrid1.TopRow to  DrawGrid1.TopRow + DrawGrid1.VisibleRowCount-1 do
               begin
               DrawRect := DrawGrid1.CellRect(i,j);
               Tile := GetMapLibTile( DGCMapLib1,ListBox1.ItemIndex, i,j);
               DrawGrid1.Canvas.Brush.Color :=  PanelBGCColor.Color;
               DrawGrid1.Canvas.FillRect(DrawRect);
               DrawLibImage(DrawGrid1.Canvas,DrawRect.Left, DrawRect.Top,Tile);
           end;
     end;

end;

procedure TForm1.SpeedButtonZoomOutClick(Sender: TObject);
begin
     if ComboBoxZoom.ItemIndex > 0 then
        ComboBoxZoom.ItemIndex :=  ComboBoxZoom.ItemIndex -1;
     ComboBoxZoomChange(NIL);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
     ComboBoxZoom.ItemIndex := 5;
end;

procedure TForm1.SpeedButtonZoomInClick(Sender: TObject);
begin
    if ComboBoxZoom.ItemIndex < ComboBoxZoom.Items.Count then
        ComboBoxZoom.ItemIndex :=  ComboBoxZoom.ItemIndex +1;
    ComboBoxZoomChange(NIL);
end;

procedure TForm1.ItemTransperencyClick(Sender: TObject);
begin
    ItemTransperency.Checked := not ItemTransperency.Checked;
    if ItemTransperency.Checked then begin
       SpeedButtonTransparency.Down := True;
    end
    else begin
        SpeedButtonTransparency.Down := False;
    end;
    ListBox1Click(NIL);
    Image1.Transparent := SpeedButtonTransparency.Down;
    
end;

procedure TForm1.PanelBGCColorClick(Sender: TObject);
begin
     if ColorDialog1.Execute then
        with (Sender as TPanel) do begin
             color := ColorDialog1.Color;
        end;
     ListBox1Click(NIL);
     Panel1.Color := color;
    // Panel1.Repaint;
end;

procedure TForm1.ComboBoxZoomChange(Sender: TObject);
var w, h : Integer;
begin
     w := DGCImageLib1.Images.ImageData[0].Width;
     h := DGCImageLib1.Images.ImageData[0].Height;
     case ComboboxZoom.ItemIndex of
     0: //025%
     begin
          DrawGrid1.DefaultColWidth := w div 4;
          DrawGrid1.DefaultRowHeight := h div 4;
     end;
     1: //033%
     begin
          DrawGrid1.DefaultColWidth := w div 3;
          DrawGrid1.DefaultRowHeight := h div 3;
     end;
     2: //050%
     begin
          DrawGrid1.DefaultColWidth := w div 2;
          DrawGrid1.DefaultRowHeight := h div 2;
     end;
     3: //066%
     begin
          DrawGrid1.DefaultColWidth := (w * 2) div 3;
          DrawGrid1.DefaultRowHeight := (h * 2) div 3;
     end;
     4: //075%
     begin
          DrawGrid1.DefaultColWidth := (w * 3) div 4;
          DrawGrid1.DefaultRowHeight := (h *3) div 4;
     end;
     5: //100%
     begin
          DrawGrid1.DefaultColWidth := w;
          DrawGrid1.DefaultRowHeight := h;
     end;
     6: //125%
     begin
          DrawGrid1.DefaultColWidth := w + ( w div 4);
          DrawGrid1.DefaultRowHeight := h + ( h div 4);
     end;
     7: //133%
     begin
          DrawGrid1.DefaultColWidth := w + (w div 3);
          DrawGrid1.DefaultRowHeight := h + ( h div 3);
     end;
     8: //150%
     begin
          DrawGrid1.DefaultColWidth := w + ( w div 2);
          DrawGrid1.DefaultRowHeight := h + (h div 2);
     end;
     9: //166%
     begin
          DrawGrid1.DefaultColWidth := w +((w * 2) div 3);
          DrawGrid1.DefaultRowHeight := h +((h * 2) div 3);
     end;
     10: //175%
     begin
          DrawGrid1.DefaultColWidth := w +((w * 3) div 4);
          DrawGrid1.DefaultRowHeight := h+((w * 3) div 4);
     end;
     11: //200%
     begin
          DrawGrid1.DefaultColWidth := w*2;
          DrawGrid1.DefaultRowHeight := h*2;
     end;
     12: //250%
     begin
          DrawGrid1.DefaultColWidth := w + (w div 2);
          DrawGrid1.DefaultRowHeight := h + (h div 2);
     end;
     13: //300%
     begin
          DrawGrid1.DefaultColWidth := w *3;
          DrawGrid1.DefaultRowHeight := h *3;
     end;
     else
     begin
          DrawGrid1.DefaultColWidth := w;
          DrawGrid1.DefaultRowHeight := h;
     end;
     end; // case
end;

procedure TForm1.DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var Col, Row, Tile : Integer;
    DrawRect : TRect;
begin
     DrawGrid1.MouseToCell(X, Y,  Col, Row);
     Tile := 0;
     if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) and
        (col >= 0) and (Row >= 0) then
     Begin
          Tile := GetMapLibTile(DGCMapLib1,Listbox1.ItemIndex ,Col, row);
          if ssLeft in Shift then
          begin
             DrawRect := DrawGrid1.CellRect(DrawGrid1.Col, DrawGrid1.Row);
             DrawLibImage(DrawGrid1.Canvas,DrawRect.Left, DrawRect.Top,DrawGridImageLib.Row);
             SetMaplibTile(DGCMapLib1, ListBox1.ItemIndex, DrawGrid1.Col, DrawGrid1.Row, DrawGridImageLib.Row);
             StatusBar1.Panels[5].Text := ChangedChar;
          end;
     end;
     StatusBar1.Panels[3].Text := 'POS: ' + IntToStr(col) + ',' + IntToStr(Row);
     StatusBar1.Panels[4].Text := 'Tile: ' + IntToStr( Tile);
end;

procedure TForm1.ItemClearMapClick(Sender: TObject);
Var i, j : Integer;
begin
   if MessageDlg( 'Do you realy want to clear this Map?' ,mtConfirmation,
                  [mbOk,mbCancel],0) = mrOk	Then
    if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) Then
     begin
          for I := 0 to  DrawGrid1.ColCount-1 do
              for j := 0 to DrawGrid1.RowCount-1 do
                  if DrawGridImageLib.Row >=0 Then
                     SetMaplibTile(DGCMapLib1, ListBox1.ItemIndex, i,j, DrawGridImageLib.Row)
                  else
                     SetMaplibTile(DGCMapLib1, ListBox1.ItemIndex, i,j, 0);
          DrawGrid1TopLeftChanged(NIL);
     end;
end;

procedure TForm1.ItemSaveMapLibraryClick(Sender: TObject);
begin
     DGCMapLib1.MapLib.SaveToFile(StatusBar1.Panels[0].Text);
     StatusBar1.Panels[5].Text :='';
end;

procedure TForm1.ItemSaveMapLibraryAsClick(Sender: TObject);
begin
   if (Listbox1.Items.Count > 0) Then
      If SaveDialog1.Execute then begin
          DGCMapLib1.MapLib.SaveToFile(SaveDialog1.FileName);
          StatusBar1.Panels[5].Text :='';
          end;
end;

procedure TForm1.DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  Var Col, Row, Tile : Integer;
begin
     if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) Then
        begin
        if Button = mbRight then  begin
           DrawGrid1.MouseToCell(X, Y,  Col, Row);
           Tile := GetMapLibTile(DGCMapLib1,Listbox1.ItemIndex ,Col, row);
           if Tile < DrawGridImageLib.RowCount then
              DrawGridImageLib.Row := Tile;
        end
     end;

end;

procedure TForm1.ItemAboutClick(Sender: TObject);
begin
     MessageDlg( 'YaAC Map Editor. See DGC Map Editor for more Information.' + chr(10)+ chr(13)+'    Christian Ledermann -- cleder@dcsnet.de' + chr(10)+ chr(13)+ chr(10)+ chr(13)+
                 'This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.',
                 mtInformation,
                  [mbOk],0)
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     if StatusBar1.Panels[5].Text = ChangedChar Then
       case  MessageDlg( 'Do you want to save changed Work?' ,mtConfirmation,
                  [mbYes, mbNo,mbCancel],0) of
                  mrNo : CanClose := True;
                  mrCancel : CanClose := False;
                  mrYes : If SaveDialog1.Execute then
                          DGCMapLib1.MapLib.SaveToFile(SaveDialog1.FileName)
                          else CanClose := False;

                  end
end;

procedure TForm1.FormCreate(Sender: TObject);
Var I : Integer;
    Ext : String;
begin
     if ParamStr(1) <> '' then Begin
        Ext := ExtractFileExt(ParamStr(1));
        if UpperCase(Ext) ='.MAP' Then begin
           DGCMapLib1.MapLib.LoadFromFile(ParamStr(1));
           ListBox1.Items.Clear;
           ItemSaveMapLibrary.Enabled := True;
           StatusBar1.Panels[0].Text := ParamStr(1);
           StatusBar1.Panels[5].Text := '';
           for i :=0 to DGCMapLib1.MapLib.MapCount do begin
               ListBox1.Items.Add(DGCMapLib1.MapLib.Maps[i].Name);
           end;
           ListBox1.ItemIndex := 0;
           ListBox1Click(NIL);
           (*StatusBar1.Panels[1].Text := '0';
           DrawGrid1.ColCount := DGCMapLib1.MapLib.Maps[0].XSize;
           DrawGrid1.RowCount := DGCMapLib1.MapLib.Maps[0].YSize;
           DrawGrid1TopLeftChanged(NIL);*)
           ItemMapProperties.Enabled := True;
           SpeedButtonProps.Enabled := True;
           SpeedButtonMoveMapUp.Enabled := True;
           SpeedButtonMoveMapDown.Enabled := True;
        end;
     end;
end;

procedure TForm1.ItemMapPropertiesClick(Sender: TObject);
VAR strMapName, strProps : String;

    i : Integer;
begin
     if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) Then
         i := ListBox1.ItemIndex
     else
         Begin
         ItemMapProperties.Enabled := False;
         SpeedButtonProps.Enabled := False;
         SpeedButtonMoveMapUp.Enabled := False;
         SpeedButtonMoveMapDown.Enabled := False;
         Exit;
         end;
     strProps := 'Index: ' + IntToStr(ListBox1.ItemIndex) + '  ';
     strProps := strProps + 'X Size: ' + IntToStr(DrawGrid1.ColCount)+ '  ';
     strProps := strProps + 'Y Size: ' + IntToStr(DrawGrid1.RowCount);
     strMapName := Listbox1.Items[i];
     strMapName:= InputBox('Map Properties', strProps, strMapName);
     if Length(strMapName) > 15 then
        showmessage('Map Name too long')
     else begin
          DGCMapLib1.MapLib.Maps[i].Name :=  strMapName;
          Listbox1.Items[i] := strMapName;
     end;
end;

procedure TForm1.SpeedButtonMoveMapUpClick(Sender: TObject);
VAR   SaveMapRec : TDGCMapRec;
      i : Integer;
begin
     if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) Then
         i := ListBox1.ItemIndex
     else
     Begin
         ItemMapProperties.Enabled := False;
         SpeedButtonProps.Enabled := False;
         SpeedButtonMoveMapUp.Enabled := False;
         SpeedButtonMoveMapDown.Enabled := False;
         Exit;
     end;
     if i > 0 Then Begin
        SaveMapRec := DGCMapLib1.MapLib.Maps[i];
        DGCMapLib1.MapLib.Maps[i] := DGCMapLib1.MapLib.Maps[i-1];
        DGCMapLib1.MapLib.Maps[i-1]:= SaveMapRec;
        Listbox1.Items[i] := DGCMapLib1.MapLib.Maps[i].Name;
        Listbox1.Items[i-1] := DGCMapLib1.MapLib.Maps[i-1].Name;
        Listbox1.ItemIndex := i-1;
        StatusBar1.Panels[5].Text := ChangedChar;
     end;
end;

procedure TForm1.SpeedButtonMoveMapDownClick(Sender: TObject);
VAR   SaveMapRec : TDGCMapRec;
      i : Integer;
begin
     if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) Then
         i := ListBox1.ItemIndex
     else
     Begin
         ItemMapProperties.Enabled := False;
         SpeedButtonProps.Enabled := False;
         SpeedButtonMoveMapUp.Enabled := False;
         SpeedButtonMoveMapDown.Enabled := False;
         Exit;
     end;
     if i < (DGCMapLib1.MapLib.MapCount)  Then Begin
        SaveMapRec := DGCMapLib1.MapLib.Maps[i];
        DGCMapLib1.MapLib.Maps[i] := DGCMapLib1.MapLib.Maps[i+1];
        DGCMapLib1.MapLib.Maps[i+1]:= SaveMapRec;
        Listbox1.Items[i] := DGCMapLib1.MapLib.Maps[i].Name;
        Listbox1.Items[i+1] := DGCMapLib1.MapLib.Maps[i+1].Name;
        Listbox1.ItemIndex := i+1;
        StatusBar1.Panels[5].Text := ChangedChar;
     end;
end;

procedure TForm1.SpeedButtonDeleteMapClick(Sender: TObject);
VAR i,j : Integer;
begin
     if (Listbox1.Items.Count > 0) and (ListBox1.ItemIndex <> -1) Then
         i := ListBox1.ItemIndex
     else
     Begin
         ItemMapProperties.Enabled := False;
         SpeedButtonProps.Enabled := False;
         SpeedButtonMoveMapUp.Enabled := False;
         SpeedButtonMoveMapDown.Enabled := False;
         ItemDeleteMap.Enabled := False;
         SpeedButtonDeleteMap.Enabled := False;
         Exit;
     end;
     if i < (DGCMapLib1.MapLib.MapCount)  Then Begin
        DGCMapLib1.MapLib.MapCount := DGCMapLib1.MapLib.MapCount -1;
        FreeMem(DGCMapLib1.MapLib.Maps[i].Data, DGCMapLib1.MapLib.Maps[i].MSize);
        for j := i to DGCMapLib1.MapLib.MapCount - 1  do begin
            DGCMapLib1.MapLib.Maps[j] := DGCMapLib1.MapLib.Maps[j+1];
            Listbox1.Items[j] := DGCMapLib1.MapLib.Maps[j].Name;
            StatusBar1.Panels[5].Text := ChangedChar;
        end; // for
        Listbox1.Items.Delete(i);
        Listbox1.ItemIndex := i;
     end;
end;

end.
