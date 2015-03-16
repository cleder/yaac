program tracewin;

uses
  Forms,
  dgctrace in 'dgctrace.pas' {frmDGCTrace},
  about in 'about.pas' {frmAbout};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'DGC Trace Window';
  Application.CreateForm(TfrmDGCTrace, frmDGCTrace);
  Application.Run;
end.
