program YaacMapeditor;

uses
  Forms,
  UnitMapedit in 'UnitMapedit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'YaAC Map Editor';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
