program QuickBar;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  DragDrop in 'DragDrop.pas',
  DropLink in 'DropLink.pas',
  DropObj in 'DropObj.pas',
  DropFile in 'DropFile.pas',
  About in 'About.pas' {AboutBox};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'QuickBar';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
