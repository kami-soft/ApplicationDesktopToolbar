program DemoApp;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  AppBar in '..\AppBar.pas',
  DemoForm in 'DemoForm.pas' {fmDemo};

{$R *.RES}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar:=True;
  Application.CreateForm(TfmDemo, fmDemo);
  Application.Run;
end.
