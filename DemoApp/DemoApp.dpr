program DemoApp;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  AppBar in '..\AppBar.pas',
  Demo in 'Demo.pas' {DemoBar},
  DemoProp in 'DemoProp.pas' {PropDlg},
  Unit1 in 'Unit1.pas' {AppBarX};

{$R *.RES}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar:=True;
  Application.CreateForm(TDemoBar, DemoBar);
  Application.CreateForm(TAppBarX, AppBarX);
  Application.CreateForm(TPropDlg, PropDlg);
  Application.Run;
end.
