unit DemoProp;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ComCtrls, ExtCtrls;

type
  TPropDlg = class(TForm)
    pnlPages: TPanel;
    pnlBottom: TPanel;
    pgcMain: TPageControl;
    tabPosition: TTabSheet;
    grpEdge: TGroupBox;
    optEdgeFloat: TRadioButton;
    optEdgeLeft: TRadioButton;
    optEdgeTop: TRadioButton;
    optEdgeRight: TRadioButton;
    optEdgeBottom: TRadioButton;
    grpFlags: TGroupBox;
    chkAllowFloat: TCheckBox;
    chkAllowLeft: TCheckBox;
    chkAllowTop: TCheckBox;
    chkAllowRight: TCheckBox;
    chkAllowBottom: TCheckBox;
    tabAppearance: TTabSheet;
    tabSizing: TTabSheet;
    tabDocking: TTabSheet;
    tabFloating: TTabSheet;
    grpFloatCoords: TGroupBox;
    lblFloatLeft: TLabel;
    edtFloatLeft: TEdit;
    updFloatLeft: TUpDown;
    lblFloatTop: TLabel;
    edtFloatTop: TEdit;
    updFloatTop: TUpDown;
    lblFloatRight: TLabel;
    edtFloatRight: TEdit;
    updFloatRight: TUpDown;
    lblFloatBottom: TLabel;
    edtFloatBottom: TEdit;
    updFloatBottom: TUpDown;
    grpMinMax: TGroupBox;
    lblMinWidth: TLabel;
    edtMinWidth: TEdit;
    updMinWidth: TUpDown;
    lblMinHeight: TLabel;
    edtMinHeight: TEdit;
    updMinHeight: TUpDown;
    lblMaxWidth: TLabel;
    edtMaxWidth: TEdit;
    updMaxWidth: TUpDown;
    lblMaxHeight: TLabel;
    edtMaxHeight: TEdit;
    updMaxHeight: TUpDown;
    lblAuthor: TLabel;
    lblEMail: TLabel;
    lblHomePage: TLabel;
    btnApply: TButton;
    btnCancel: TButton;
    lblProductName: TLabel;
    grpMainWnd: TGroupBox;
    chkAlwaysOnTop: TCheckBox;
    chkAutohide: TCheckBox;
    grpTaskEntry: TRadioGroup;
    tabSliding: TTabSheet;
    grpSlideEffect: TGroupBox;
    lblSlideTime: TLabel;
    sldSlideTime: TTrackBar;
    lblFaster: TLabel;
    lblSlower: TLabel;
    chkSlideEffect: TCheckBox;
    grpSizeInc: TGroupBox;
    lblHorzSizeInc: TLabel;
    edtHorzSizeInc: TEdit;
    updHorzSizeInc: TUpDown;
    lblVertSizeInc: TLabel;
    edtVertSizeInc: TEdit;
    updVertSizeInc: TUpDown;
    lblZeroIncHint: TLabel;
    grpVertDock: TGroupBox;
    grpHorzDock: TGroupBox;
    edtHorzDockSize: TEdit;
    updHorzDockSize: TUpDown;
    edtVertDockSize: TEdit;
    updVertDockSize: TUpDown;
    edtMinVertDockSize: TEdit;
    updMinVertDockSize: TUpDown;
    edtMaxVertDockSize: TEdit;
    updMaxVertDockSize: TUpDown;
    edtMinHorzDockSize: TEdit;
    updMinHorzDockSize: TUpDown;
    edtMaxHorzDockSize: TEdit;
    updMaxHorzDockSize: TUpDown;
    lblMinVertDockSize: TLabel;
    lblVertDockSize: TLabel;
    lblMaxVertDockSize: TLabel;
    lblMinHorzDockSize: TLabel;
    lblHorzDockSize: TLabel;
    lblmaxHorzDockSize: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkSlideEffectClick(Sender: TObject);
  private
    procedure InitDialog;
    procedure ApplyChanges;
  end;

var
  PropDlg: TPropDlg;

implementation

uses Dialogs, Demo, AppBar;

{$R *.DFM}

procedure TPropDlg.FormCreate(Sender: TObject);
begin
  InitDialog;
end;

procedure TPropDlg.btnApplyClick(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TPropDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPropDlg.chkSlideEffectClick(Sender: TObject);
begin
  sldSlideTime.Enabled := chkSlideEffect.Checked;
  lblSlideTime.Enabled := chkSlideEffect.Checked;
  lblFaster.Enabled    := chkSlideEffect.Checked;
  lblSlower.Enabled    := chkSlideEffect.Checked;
end;

procedure TPropDlg.InitDialog;
begin
  // Appearance Page
  chkAlwaysOnTop.Checked := DemoBar.AlwaysOnTop;
  chkAutoHide.Checked    := DemoBar.AutoHide;
  grpTaskEntry.ItemIndex := Ord(DemoBar.TaskEntry);

  // Position Page
  optEdgeFloat.Checked  := (DemoBar.Edge = abeFloat);
  optEdgeLeft.Checked   := (DemoBar.Edge = abeLeft);
  optEdgeTop.Checked    := (DemoBar.Edge = abeTop);
  optEdgeRight.Checked  := (DemoBar.Edge = abeRight);
  optEdgeBottom.Checked := (DemoBar.Edge = abeBottom);

  chkAllowFloat.Checked  := (abfAllowFloat  in DemoBar.Flags);
  chkAllowLeft.Checked   := (abfAllowLeft   in DemoBar.Flags);
  chkAllowTop.Checked    := (abfAllowTop    in DemoBar.Flags);
  chkAllowRight.Checked  := (abfAllowRight  in DemoBar.Flags);
  chkAllowBottom.Checked := (abfAllowBottom in DemoBar.Flags);

  // Sizing Page
  updHorzSizeInc.Position := DemoBar.HorzSizeInc;
  updVertSizeInc.Position := DemoBar.VertSizeInc;

  // Docking Page
  updMinHorzDockSize.Position := DemoBar.MinHorzDockSize;
  updMinVertDockSize.Position := DemoBar.MinVertDockSize;
  updHorzDockSize.Position    := DemoBar.HorzDockSize;
  updVertDockSize.Position    := DemoBar.VertDockSize;
  updMaxHorzDockSize.Position := DemoBar.MaxHorzDockSize;
  updMaxVertDockSize.Position := DemoBar.MaxVertDockSize;

  // Floating Page
  updFloatLeft.Position   := DemoBar.FloatLeft;
  updFloatTop.Position    := DemoBar.FloatTop;
  updFloatRight.Position  := DemoBar.FloatRight;
  updFloatBottom.Position := DemoBar.FloatBottom;

  updMinWidth.Position  := DemoBar.MinWidth;
  updMinHeight.Position := DemoBar.MinHeight;
  updMaxWidth.Position  := DemoBar.MaxWidth;
  updMaxHeight.Position := DemoBar.MaxHeight;

  // Sliding Page
  chkSlideEffect.Checked := DemoBar.SlideEffect;
  sldSlideTime.Position  := DemoBar.SlideTime;
  sldSlideTime.Enabled   := chkSlideEffect.Checked;
  lblSlideTime.Enabled   := chkSlideEffect.Checked;
  lblFaster.Enabled      := chkSlideEffect.Checked;
  lblSlower.Enabled      := chkSlideEffect.Checked;
end;

procedure TPropDlg.ApplyChanges;
begin
  // Appearance Page
  DemoBar.AlwaysOnTop := chkAlwaysOnTop.Checked;
  DemoBar.AutoHide    := chkAutoHide.Checked;
  DemoBar.TaskEntry   := TAppBarTaskEntry(grpTaskEntry.ItemIndex);

  // Position Page
  if optEdgeFloat.Checked then
    DemoBar.Edge := abeFloat
  else if optEdgeLeft.Checked then
    DemoBar.Edge := abeLeft
  else if optEdgeTop.Checked then
    DemoBar.Edge := abeTop
  else if optEdgeRight.Checked then
    DemoBar.Edge := abeRight
  else if optEdgeBottom.Checked then
    DemoBar.Edge := abeBottom;

  if chkAllowFloat.Checked then
    DemoBar.Flags := DemoBar.Flags + [abfAllowFloat]
  else
    DemoBar.Flags := DemoBar.Flags - [abfAllowFloat];

  if chkAllowLeft.Checked then
    DemoBar.Flags := DemoBar.Flags + [abfAllowLeft]
  else
    DemoBar.Flags := DemoBar.Flags - [abfAllowLeft];

  if chkAllowTop.Checked then
    DemoBar.Flags := DemoBar.Flags + [abfAllowTop]
  else
    DemoBar.Flags := DemoBar.Flags - [abfAllowTop];

  if chkAllowRight.Checked then
    DemoBar.Flags := DemoBar.Flags + [abfAllowRight]
  else
    DemoBar.Flags := DemoBar.Flags - [abfAllowRight];

  if chkAllowBottom.Checked then
    DemoBar.Flags := DemoBar.Flags + [abfAllowBottom]
  else
    DemoBar.Flags := DemoBar.Flags - [abfAllowBottom];

  // Sizing Page
  DemoBar.HorzSizeInc := updHorzSizeInc.Position;
  DemoBar.VertSizeInc := updVertSizeInc.Position;

  // Docking Page
  DemoBar.MinHorzDockSize := updMinHorzDockSize.Position;
  DemoBar.MinVertDockSize := updMinVertDockSize.Position;
  DemoBar.HorzDockSize    := updHorzDockSize.Position;
  DemoBar.VertDockSize    := updVertDockSize.Position;
  DemoBar.MaxHorzDockSize := updMaxHorzDockSize.Position;
  DemoBar.MaxVertDockSize := updMaxVertDockSize.Position;

  // Floating Page
  DemoBar.FloatLeft   := updFloatLeft.Position;
  DemoBar.FloatTop    := updFloatTop.Position;
  DemoBar.FloatRight  := updFloatRight.Position;
  DemoBar.FloatBottom := updFloatBottom.Position;

  DemoBar.MinWidth  := updMinWidth.Position;
  DemoBar.MinHeight := updMinHeight.Position;
  DemoBar.MaxWidth  := updMaxWidth.Position;
  DemoBar.MaxHeight := updMaxHeight.Position;

  // Sliding Page
  DemoBar.SlideEffect := chkSlideEffect.Checked;
  DemoBar.SlideTime   := sldSlideTime.Position;
end;

end.

