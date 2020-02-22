unit DemoForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  AppBar,
  Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TPanel = class(Vcl.ExtCtrls.TPanel)
  strict private
    procedure WMNCHHitTest(var Message: TWMNCHitMessage); message WM_NCHITTEST;
  end;

  TfmDemo = class(TForm)
    pnlTop: TPanel;
    mmoEvents: TMemo;
    tmr1: TTimer;
    btnChangeEdge: TButton;
    chkAutohide: TCheckBox;
    procedure tmr1Timer(Sender: TObject);
    procedure btnChangeEdgeClick(Sender: TObject);
    procedure chkAutohideClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmDemo: TfmDemo;

implementation

{$R *.dfm}

procedure TfmDemo.btnChangeEdgeClick(Sender: TObject);
var
  tmpEdge: TAppBarEdge;
begin
  tmpEdge := Edge;
  if tmpEdge = abeFloat then
    tmpEdge := abeLeft
  else
    if tmpEdge = abeUnknown then
      tmpEdge := abeFloat
    else
      tmpEdge := Succ(tmpEdge);
  Edge := tmpEdge;
end;

procedure TfmDemo.chkAutohideClick(Sender: TObject);
begin
  Autohide := chkAutohide.Checked;
end;

procedure TfmDemo.FormCreate(Sender: TObject);
begin
  AppbarWidth := 250;
  Edge := abeLeft;
end;

procedure TfmDemo.tmr1Timer(Sender: TObject);
begin
  mmoEvents.Lines.Add('Event ' + FormatDateTime('hh:nn:ss', Now));
  if mmoEvents.Lines.Count > 200 then
    mmoEvents.Lines.Delete(0);
end;

{ Panel }

procedure TPanel.WMNCHHitTest(var Message: TWMNCHitMessage);
begin
  message.Result := HTTRANSPARENT;
end;

end.
