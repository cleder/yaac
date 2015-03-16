{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit DGCReg;

interface

uses
  SysUtils, Classes, DsgnIntf, dgc, dgcsnd, dgcspts, dgcilib, dgcslib,
  dgcfx, dgcfxlib, dgcstar, hiscore;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DGC', [TDGCScreen, TDGCImageLib]);
  RegisterComponents('DGC', [TDGCSpriteMgr]);
  RegisterComponents('DGC', [TDGCAudio]);
  RegisterComponents('DGC', [TDGCSoundLib]);
  RegisterComponents('DGC', [TDGCIntroLib]);
  RegisterComponents('DGC', [TDGCHiScore]);
  RegisterComponents('DGC', [TDGCStarField]);
  RegisterPropertyEditor( TypeInfo(TDGCImages), TDGCImageLib, 'Images', TDGCOpenLibProperty);
  RegisterPropertyEditor( TypeInfo(TDGCSounds), TDGCSoundLib, 'Sounds', TDGCOpenSndLibProperty);
end;

end.
