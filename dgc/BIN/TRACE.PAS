{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit Trace;

interface

uses Windows, Messages, SysUtils;

type
  TCopyData = record
      dwData: LongInt;
      cbData: LongInt;
      lpData: Pointer;
  end;
  PCopyData = ^TCopyData;

procedure TraceString(Msg: String);

implementation

procedure TraceString(Msg: String);
var
   CopyData: TCopyData;
   TraceWin: hWnd;
   Buf: array[0..255] of Char;
begin
     TraceWin := FindWindow('TfrmDGCTrace', 'DGC Trace');
     if TraceWin = 0 then
          exit;
     if Length(Msg) > 255 then
        SetLength(Msg, 255);
     StrPCopy(Buf, Msg);
     CopyData.dwData := 0;
     CopyData.cbData := Length(Msg) + 1;
     CopyData.lpData := @Buf[0];
     SendMessage(TraceWin, WM_COPYDATA, 0, LongInt(@CopyData));
end;

end.
 