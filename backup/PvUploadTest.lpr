program PvUploadTest;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, anchordockpkg, lazcontrols, U_frmAuroraDataUpload, U_frmSettings;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmAuroraDataUpload, frmAuroraDataUpload);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.Run;
end.

