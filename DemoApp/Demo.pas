unit Demo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, AppBar;

type
  TDemoBar = class(TAppBar)
    btnProperties: TSpeedButton;
    procedure btnPropertiesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DemoBar: TDemoBar;

implementation

uses DemoProp;

{$R *.DFM}

procedure TDemoBar.btnPropertiesClick(Sender: TObject);
begin
  // Create, Show modally and Destroy the Property Dialog
  PropDlg := TPropDlg.Create(Application);
  PropDlg.ShowModal;
  PropDlg.Free;

  // Update AppBar settings
  UpdateBar;
end;

end.
