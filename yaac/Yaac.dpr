program yaac;

uses
  Forms,
  b0l01 in 'b0l01.pas' {FormMain},
  CollisionBasics in 'CollisionBasics.pas',
  DGC in '..\Programme\DGC\Bin\DGC.pas',
  StoneEvents in 'StoneEvents.pas',
  p3dTextOut in 'p3dTextOut.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Yet another Arcanoid Clone';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
