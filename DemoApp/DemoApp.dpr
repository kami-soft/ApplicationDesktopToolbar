program DemoApp;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  AppBar in '..\AppBar.pas',
  Unit1 in 'Unit1.pas' {AppBarX};

{$R *.RES}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar:=True;
  Application.CreateForm(TAppBarX, AppBarX);
  Application.Run;
end.
