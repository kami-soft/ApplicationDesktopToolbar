unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolWin, ComCtrls, Buttons, ExtCtrls, Menus, AppBar;

const
  HANDLEBAR_SIZE = 13;
  BUTTON_WIDTH   = 39;
  BUTTON_HEIGHT  = 38;
  REG_SETTINGS   = 'Software\QuickBar';

type
  TClickAction = (caExec, caDrag);
  TDrawDirection = (ddHorizontal, ddVertical);
  // The TMainForm class is derived from TAppBar
  TMainForm = class(TAppBar)
    tbrQuickBar: TToolBar;
    imlIcons: TImageList;
    popMenu: TPopupMenu;
    miAlwaysOnTop: TMenuItem;
    miAutohide: TMenuItem;
    miSeparator1: TMenuItem;
    miAbout: TMenuItem;
    miSeparator2: TMenuItem;
    miExit: TMenuItem;
    imgMenu: TImage;
    imgDelete: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure popMenuPopup(Sender: TObject);
    procedure miAlwaysOnTopClick(Sender: TObject);
    procedure miAutohideClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure imgDeleteDragDrop(Sender, Source: TObject;
                                X, Y: Integer);
    procedure imgDeleteDragOver(Sender, Source: TObject;
                                X, Y: Integer;
                                State: TDragState;
                                var Accept: Boolean);
    procedure ToolButtonMouseDown(Sender: TObject;
                                  Button: TMouseButton;
                                  Shift: TShiftState;
                                  X, Y: Integer);
    procedure ToolButtonMouseUp(Sender: TObject;
                                Button: TMouseButton;
                                Shift: TShiftState;
                                X, Y: Integer);
    procedure ToolButtonMouseMove(Sender: TObject;
                                  Shift: TShiftState;
                                  X, Y: Integer);
    procedure ToolButtonDragDrop(Sender, Source: TObject;
                                 X, Y: Integer);
    procedure ToolButtonDragOver(Sender, Source: TObject;
                                 X, Y: Integer;
                                 State: TDragState;
                                 var Accept: Boolean);
  private
    ClickAction: TClickAction;
    procedure DrawHandleBar(Sender: TObject;
                            DrawDirection: TDrawDirection;
                            rc: TRect);
    function LoadSettings: Boolean; override;
    function SaveSettings: Boolean; override;
    procedure ShiftButtons(const ToolBar: TToolBar; Src, Dst: Integer);
  public
    procedure AddButton(const FileName: String);
  end;

var
  MainForm: TMainForm;

implementation

uses
  ActiveX, ShellApi, Registry, DragDrop, DropObj, About;

{$R *.DFM}

// TMainForm.FormCreate ///////////////////////////////////////////////////////
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Initialize the OLE libraries
  OleInitialize(nil);
  // Call the RegisterDragDrop function. OLE keeps a list of the windows that
  // are drop targets. Every window that accepts dropped objects must register
  // itself and its IDropTarget interface pointer
  RegisterDragDrop(Handle, TOleDragDrop.Create);
  // Initialize AppBar properties
  MinWidth        := BUTTON_WIDTH  + (Width - ClientWidth) + HANDLEBAR_SIZE;
  MinHeight       := BUTTON_HEIGHT + (Height - ClientHeight);
  VertDockSize    := BUTTON_WIDTH  + (Width - ClientWidth) - 2;
  HorzDockSize    := BUTTON_HEIGHT + (Width - ClientWidth) - 2;
  MinVertDockSize := BUTTON_WIDTH  + (Width - ClientWidth) - 2;
  MinHorzDockSize := BUTTON_HEIGHT + (Width - ClientWidth) - 2;
  HorzSizeInc     := BUTTON_WIDTH;
  VertSizeInc     := BUTTON_HEIGHT;
  FloatLeft   := Left;
  FloatTop    := Top;
  FloatRight  := Left + Width;
  FloatBottom := Top + Height;
  // Load settings from the registry
  LoadSettings;
  // Update the appbar
  UpdateBar;
end;

// TMainForm.FormDestroy //////////////////////////////////////////////////////
procedure TMainForm.FormDestroy(Sender: TObject);
var
  i : Integer;
begin
  // Save settings into the registry
  SaveSettings;
  // Free the strings allocated in the Tag property
  for i := 0 to tbrQuickBar.ButtonCount - 1 do
    StrDispose(PChar(tbrQuickBar.Buttons[i].Tag));
  // Call the RevokeDragDrop function. Before a drop target window is
  // destroyed, it must call the RevokeDragDrop to allow OLE to remove the
  // window from its list of drop targets
  RevokeDragDrop(Handle);
  // Uninitialize the OLE libraries
  OleUninitialize;
end;

// TMainForm.FormResize ///////////////////////////////////////////////////////
procedure TMainForm.FormResize(Sender: TObject);
begin
  // Invalidate the client area. Invalidate will cause the entire window to be
  // repainted in a single pass, avoiding flicker caused by redundant repaints
  Invalidate;
  // Position the tbrQuickBar and the images depending on the current edge
  case Edge of
    abeLeft, abeRight: begin
      // The HandleBar is placed horizontally
      with tbrQuickBar do begin
        Left   := 0;
        Top    := HANDLEBAR_SIZE;
        Width  := MainForm.ClientWidth;
        Height := MainForm.ClientHeight - HANDLEBAR_SIZE;
      end;
      // The Menu Image is topmost
      with imgMenu do begin
        Left := 0;
        Top  := 0;
      end;
      // The Delete Button Image is at the right of the Menu Image
      with imgDelete do begin
        Left := HANDLEBAR_SIZE;
        Top  := 0;
      end;
    end;
    abeTop, abeBottom, abeFloat: begin
      // The HandleBar is placed vertically
      with tbrQuickBar do begin
        Left   := HANDLEBAR_SIZE;
        Top    := 0;
        Width  := MainForm.ClientWidth - HANDLEBAR_SIZE;
        Height := MainForm.ClientHeight;
      end;
      // The Menu Image is topmost
      with imgMenu do begin
        Left := 0;
        Top  := 0;
      end;
      // The Delete Button Image is bottom the Menu Image
      with imgDelete do begin
        Left := 0;
        Top  := HANDLEBAR_SIZE;
      end;
    end;
  end;
end;

// TMainForm.FormPaint ////////////////////////////////////////////////////////
procedure TMainForm.FormPaint(Sender: TObject);
begin
  case Edge of
    abeLeft, abeRight:
      // The HandleBar is placed horizontally and topmost
      DrawHandleBar(Sender, ddHorizontal, Rect(HANDLEBAR_SIZE * 2,
                                               0,
                                               ClientWidth,
                                               HANDLEBAR_SIZE));
    abeTop, abeBottom, abeFloat:
      // The HandleBar is placed vertically and leftmost
      DrawHandleBar(Sender, ddVertical, Rect(0,
                                             HANDLEBAR_SIZE * 2,
                                             HANDLEBAR_SIZE,
                                             ClientHeight));
  end;
end;

// TMainForm.popMenuPopup /////////////////////////////////////////////////////
procedure TMainForm.popMenuPopup(Sender: TObject);
begin
  // Set the state of the menu items
  miAlwaysOnTop.Checked := AlwaysOnTop;
  miAutohide.Checked := Autohide;
end;

// TMainForm.miAlwaysOnTopClick ///////////////////////////////////////////////
procedure TMainForm.miAlwaysOnTopClick(Sender: TObject);
begin
  // Invert the state of the mneu item
  AlwaysOnTop := not AlwaysOnTop;
  // Update the appbar
  UpdateBar;
end;

// TMainForm.miAutohideClick //////////////////////////////////////////////////
procedure TMainForm.miAutohideClick(Sender: TObject);
begin
  // Invert the state of the mneu item
  Autohide := not Autohide;
  // Update the appbar
  UpdateBar;
end;

// TMainForm.miAboutClick /////////////////////////////////////////////////////
procedure TMainForm.miAboutClick(Sender: TObject);
begin
  // An AboutBox is mandatory! :-)
  AboutBox := TAboutBox.Create(Application);
  AboutBox.ShowModal;
  AboutBox.Release;
end;

// TMainForm.miExitClick //////////////////////////////////////////////////////
procedure TMainForm.miExitClick(Sender: TObject);
begin
  // Simply exit
  Close;
end;

// TMainForm.imgMenuClick /////////////////////////////////////////////////////
procedure TMainForm.imgMenuClick(Sender: TObject);
var
  pt : TPoint;
begin
  // Display the popup menu near the Menu Image
  pt := Point(-1, HANDLEBAR_SIZE);
  pt := ClientToScreen(pt);
  popMenu.Popup(pt.x, pt.y);
end;

// TMainForm.imgDeleteDragDrop ////////////////////////////////////////////////
procedure TMainForm.imgDeleteDragDrop(Sender, Source: TObject;
                                      X, Y: Integer);
var
  Src, Dst : Integer;
begin
  // Find the source index in the toolbar
  Src := 0;
  while tbrQuickBar.Buttons[Src] <> Source do Inc(Src);
  // The destination is the last button
  Dst := tbrQuickBar.ButtonCount - 1;
  // Place the button to be deleted in the last position
  ShiftButtons(tbrQuickBar, Src, Dst);
  // Free the last button
  with tbrQuickBar.Buttons[Dst] do begin
    StrDispose(PChar(Tag));
    Free;
  end;
end;

// TMainForm.imgDeleteDragOver ////////////////////////////////////////////////
procedure TMainForm.imgDeleteDragOver(Sender, Source: TObject;
                                      X, Y: Integer;
                                      State: TDragState;
                                      var Accept: Boolean);
begin
  Accept := (Source is TToolButton);
end;

// TMainForm.ToolButtonMouseDown //////////////////////////////////////////////
procedure TMainForm.ToolButtonMouseDown(Sender: TObject;
                                        Button: TMouseButton;
                                        Shift: TShiftState;
                                        X, Y: Integer);
begin
  if Button = mbLeft then
    ClickAction := caExec;
end;

// TMainForm.ToolButtonMouseUp ////////////////////////////////////////////////
procedure TMainForm.ToolButtonMouseUp(Sender: TObject;
                                      Button: TMouseButton;
                                      Shift: TShiftState;
                                      X, Y: Integer);
begin
  if (Button = mbLeft) and (ClickAction = caExec) then
    // The FileName to execute is stored in the Tag property of the TToolButton
    ShellExecute(Handle,
                 nil,
                 PChar((Sender as TToolButton).Tag),
                 nil,
                 nil,
                 SW_SHOW);
end;

// TMainForm.ToolButtonMouseMove //////////////////////////////////////////////
procedure TMainForm.ToolButtonMouseMove(Sender: TObject;
                                        Shift: TShiftState;
                                        X, Y: Integer);
var
  pt : TPoint;
  rc : TRect;
begin
  pt := Point(X, Y);
  rc := Rect(0,
             0,
             (Sender as TToolButton).ClientWidth,
             (Sender as TToolButton).ClientHeight);
  if (ssLeft in Shift) and not PtInRect(rc, pt) then begin
    ClickAction := caDrag;
    (Sender as TToolButton).BeginDrag(True);
  end;
end;

// TMainForm.ToolButtonDragDrop ///////////////////////////////////////////////
procedure TMainForm.ToolButtonDragDrop(Sender, Source: TObject;
                                       X, Y: Integer);
var
  Src, Dst : Integer;
begin
  // If the source button and destination button are the same, nothing to do
  if Source = Sender then Exit;
  // Find the source index in the toolbar
  Src := 0;
  while tbrQuickBar.Buttons[Src] <> Source do Inc(Src);
  // Find the destination index in the toolbar
  Dst := 0;
  while tbrQuickBar.Buttons[Dst] <> Sender do Inc(Dst);
  // The source takes the place of the destination, and the other buttons shift
  // right or left accordingly
  ShiftButtons(tbrQuickBar, Src, Dst);
end;

// TMainForm.ToolButtonDragOver ///////////////////////////////////////////////
procedure TMainForm.ToolButtonDragOver(Sender, Source: TObject;
                                       X, Y: Integer;
                                       State: TDragState;
                                       var Accept: Boolean);
begin
  Accept := (Source is TToolButton) and (Sender <> Source);
end;

// TMainForm.DrawHandleBar ////////////////////////////////////////////////////
procedure TMainForm.DrawHandleBar(Sender: TObject;
                                  DrawDirection: TDrawDirection;
                                  rc: TRect);
var
  i : Integer;
begin
  // Draw the HandleBar in the rectangle passed as argument with some plain
  // window painting
  with (Sender as TForm).Canvas do
    case DrawDirection of
      ddHorizontal:
        for i := 0 to HANDLEBAR_SIZE - 1 do begin
          case (i mod 3) of
            0:Pen.Color := clBtnFace;
            1:Pen.Color := clBtnHighlight;
            2:Pen.Color := clBtnShadow;
          end;
          MoveTo(rc.Left + 2, rc.Top + i);
          LineTo(rc.Right - 1, rc.Top + i);
        end;
      ddVertical:
        for i := 0 to HANDLEBAR_SIZE - 1 do begin
          case (i mod 3) of
            0:Pen.Color := clBtnFace;
            1:Pen.Color := clBtnHighlight;
            2:Pen.Color := clBtnShadow;
          end;
          MoveTo(rc.Left + i, rc.Top + 2);
          LineTo(rc.Left + i, rc.Bottom - 1);
        end;
    end;
end;

// TMainForm.LoadSettings /////////////////////////////////////////////////////
function TMainForm.LoadSettings: Boolean;
var
  reg : TRegistry;
  i : Integer;
begin
  // Call base class
  RootKey := HKEY_CURRENT_USER;
  KeyName := REG_SETTINGS;
  Result := inherited LoadSettings;
  // Create a TRegistry object
  reg := TRegistry.Create;
  // Set the RootKey
  reg.RootKey := HKEY_CURRENT_USER;
  // Open the key where settings are stored
  reg.OpenKey(REG_SETTINGS, True);
  // Add a button in the QuickBar for each value stored in the registry
  i := 0;
  while reg.ValueExists(IntToStr(i)) do begin
    AddButton(reg.ReadString(IntToStr(i)));
    i := i + 1;
  end;
  // Close the key
  reg.CloseKey;
  // Free the TRegistry object
  reg.Destroy;
end;

// TMainForm.SaveSettings /////////////////////////////////////////////////////
function TMainForm.SaveSettings: Boolean;
var
  reg : TRegistry;
  i : Integer;
begin
  // Create a TRegistry object
  reg := TRegistry.Create;
  // Set the RootKey
  reg.RootKey := HKEY_CURRENT_USER;
  // Clear the previous settings
  reg.DeleteKey(REG_SETTINGS);
  // Open the key to store settings
  reg.OpenKey(REG_SETTINGS, True);
  // Add an entry for each button in the QuickBar
  for i := 0 to tbrQuickBar.ButtonCount - 1 do
    reg.WriteString(IntToStr(i), PChar(tbrQuickBar.Buttons[i].Tag));
  // Close the key
  reg.CloseKey;
  // Free the TRegistry object
  reg.Destroy;
  // Call base class
  RootKey := HKEY_CURRENT_USER;
  KeyName := REG_SETTINGS;
  Result := inherited SaveSettings;
end;

// TMainForm.ShiftButtons /////////////////////////////////////////////////////
procedure TMainForm.ShiftButtons(const ToolBar: TToolBar; Src, Dst: Integer);
var
  i : Integer;
  btnSrc, btnDst : TToolButton;
  strHint : String;
  nTag : Integer;
  nImageIndex : Integer;
begin
  with ToolBar.Buttons[Src] do begin
    strHint := Hint;
    nTag := Tag;
    nImageIndex := ImageIndex;
  end;
  if Src < Dst then
    for i := Src to Dst - 1 do begin
      btnSrc := ToolBar.Buttons[i + 1];
      btnDst := ToolBar.Buttons[i];
      btnDst.Hint       := btnSrc.Hint;
      btnDst.Tag        := btnSrc.Tag;
      btnDst.ImageIndex := btnSrc.ImageIndex;
    end
  else
    for i := Src downto Dst + 1 do begin
      btnSrc := ToolBar.Buttons[i - 1];
      btnDst := ToolBar.Buttons[i];
      btnDst.Hint       := btnSrc.Hint;
      btnDst.Tag        := btnSrc.Tag;
      btnDst.ImageIndex := btnSrc.ImageIndex;
    end;
  with ToolBar.Buttons[Dst] do begin
    Hint := strHint;
    Tag := nTag;
    ImageIndex := nImageIndex;
  end;
end;

// TMainForm.AddButton ////////////////////////////////////////////////////////
procedure TMainForm.AddButton(const FileName: String);
var
  DropObj : TDroppedObject;
begin
  // Create a TDroppedObject from the FileName passed as argument
  DropObj := CreateDroppedObject(FileName);
  // Add a button to the ToolBar and set its properties
  with TToolButton.Create(tbrQuickBar) do begin
    Parent      := tbrQuickBar;
    Style       := tbsButton;
    Hint        := DropObj.Caption;
    Tag         := Integer(DropObj.NamePtr); // Implicit string allocation
    ImageIndex  := imlIcons.AddIcon(DropObj.Icon);
    OnMouseDown := ToolButtonMouseDown;
    OnMouseUp   := ToolButtonMouseUp;
    OnMouseMove := ToolButtonMouseMove;
    OnDragDrop  := ToolButtonDragDrop;
    OnDragOver  := ToolButtonDragOver;
  end;
  // Free the TDroppedObject
  DropObj.Free;
end;

end.
