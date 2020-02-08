program DemoApp;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  Demo in 'Demo.pas' {DemoBar},
  DemoProp in 'DemoProp.pas' {PropDlg},
  AppBar in '..\AppBar.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDemoBar, DemoBar);
  Application.Run;
end.
