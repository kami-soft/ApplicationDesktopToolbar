unit Unit1;

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
  Vcl.StdCtrls;

const
  // AppBar's user notification message
  WM_APPBARNOTIFY = WM_USER + 100;
  SLIDE_DEF_TIMER_INTERVAL = 400;

type
  TAppBarMessage = (abmNew, abmRemove, abmQueryPos, abmSetPos, abmGetState, abmGetTaskBarPos, abmActivate, abmGetAutoHideBar, abmSetAutoHideBar, abmWindowPosChanged, abmSetState,
    abmGetAutoHideBarEx, abmSetAutoHideBarEx);
  TAppBarEdge = (abeLeft, abeTop, abeRight, abeBottom, abeUnknown, abeFloat);
  TAppBarFlag = (abfAllowLeft, abfAllowTop, abfAllowRight, abfAllowBottom, abfAllowFloat);
  TAppBarFlags = set of TAppBarFlag;

  TAppBarX = class(TForm)
    btn1: TButton;
    chkAutoHide: TCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure chkAutoHideClick(Sender: TObject);
  private
    FEdge: TAppBarEdge;
    FAppbarCreated: Boolean;
    FFloatRect: TRect;

    FAppbarWidth: integer;
    FAppbarHeight: integer;
    FAutohide: Boolean;
    procedure SetEdge(const Value: TAppBarEdge);
    procedure SetAutohide(const Value: Boolean);
    { Private declarations }
    procedure WMActivate(var Msg: TMessage); message WM_ACTIVATE;
    procedure WMWindowPosChanged(var Msg: TMessage); message WM_WINDOWPOSCHANGED;
    procedure WMNcHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMExitSizeMove(var Msg: TMessage); message WM_EXITSIZEMOVE;

    procedure AppBarCallbackMsg(var Msg: TMessage); message WM_APPBARNOTIFY;

    function AppBarMessage(abMessage: TAppBarMessage; abEdge: TAppBarEdge; lParam: lParam; var rc: TRect): UINT;

    procedure CreateAppbar;
    procedure FreeAppbar;
    procedure SetAppbarPos;
    procedure SetABNStateChanged;
    procedure SetABNFullscreenApp(bFullscreen: Boolean);

    function GetAppbarRect(AEdge: TAppBarEdge): TRect;

    procedure SlideWindow(var rcEnd: TRect);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property Edge: TAppBarEdge read FEdge write SetEdge;
    property Autohide: Boolean read FAutohide write SetAutohide;

    property AppbarWidth: integer read FAppbarWidth write FAppbarWidth;
    property AppbarHeight: integer read FAppbarHeight write FAppbarHeight;
  end;

var
  AppBarX: TAppBarX;

implementation

uses
  System.Types,
  Winapi.ShellAPI;

{$R *.dfm}
{ TAppBarX }

procedure TAppBarX.AppBarCallbackMsg(var Msg: TMessage);
begin
  case Msg.WParam of
    ABN_STATECHANGE:
      SetABNStateChanged;
    ABN_POSCHANGED:
      SetAppbarPos;
    ABN_FULLSCREENAPP:
      SetABNFullscreenApp(Msg.lParam <> 0);
  end;
end;

function TAppBarX.AppBarMessage(abMessage: TAppBarMessage; abEdge: TAppBarEdge; lParam: lParam; var rc: TRect): UINT;
var
  abd: TAppBarData;
begin
  // Initialize an APPBARDATA structure
  abd.cbSize := sizeof(TAppBarData);
  abd.hWnd := Self.Handle;
  abd.uCallbackMessage := WM_APPBARNOTIFY;
  abd.uEdge := Ord(abEdge);
  abd.rc := rc;
  abd.lParam := lParam;
  Result := SHAppBarMessage(Ord(abMessage), abd);

  // If the caller passed a rectangle, return the updated rectangle
  rc := abd.rc;
end;

procedure TAppBarX.btn1Click(Sender: TObject);
begin
  if Edge = abeFloat then
    Edge := abeLeft
  else
    if Edge < abeBottom then
      Edge := Succ(Edge)
    else
      Edge := abeFloat;
end;

constructor TAppBarX.Create(AOwner: TComponent);
begin
  inherited;
  FEdge := abeFloat;
  FAppbarWidth := 120;
  FAppbarHeight := 120;
end;

procedure TAppBarX.chkAutoHideClick(Sender: TObject);
begin
  Autohide := chkAutoHide.Checked;
end;

procedure TAppBarX.FormDestroy(Sender: TObject);
begin
  Edge := abeUnknown;
end;

procedure TAppBarX.CreateAppbar;
var
  rc: TRect;
begin
  if (not FAppbarCreated) and (FEdge in [abeLeft .. abeBottom]) then
    begin
      FFloatRect := BoundsRect;
      rc := TRect.Empty;
      AppBarMessage(abmNew, FEdge, 0, rc);
      FAppbarCreated := True;
    end;
end;

procedure TAppBarX.CreateParams(var Params: TCreateParams);
var
  dwAdd, dwRemove, dwAddEx, dwRemoveEx: DWORD;
begin
  inherited CreateParams(Params);

  dwAdd := 0;
  dwAddEx := WS_EX_TOOLWINDOW;

  dwRemove := WS_SYSMENU or WS_MAXIMIZEBOX or WS_MINIMIZEBOX;
  dwRemoveEx := WS_EX_APPWINDOW;

  Params.Style := Params.Style and (not dwRemove) or dwAdd;
  Params.ExStyle := Params.ExStyle and (not dwRemoveEx) or dwAddEx;
end;

procedure TAppBarX.FreeAppbar;
var
  rc: TRect;
begin
  if FAppbarCreated then
    begin
      rc := TRect.Empty;
      AppBarMessage(abmRemove, abeUnknown, 0, rc);
      FAppbarCreated := False;

      if not(csDestroying in ComponentState) then
        BoundsRect := FFloatRect;
    end;
end;

function TAppBarX.GetAppbarRect(AEdge: TAppBarEdge): TRect;
begin
  CreateAppbar;
  Result := Self.Monitor.BoundsRect;
  case AEdge of
    abeLeft:
      Result.Width := AppbarWidth;
    abeTop:
      Result.Height := AppbarHeight;
    abeRight:
      begin
        Result.SetLocation(Result.Right - AppbarWidth, Result.Top);
        Result.Width := AppbarWidth;
      end;
    abeBottom:
      begin
        Result.SetLocation(Result.Left, Result.Bottom - AppbarHeight);
        Result.Height := AppbarHeight;
      end;
    abeUnknown:
      ;
    abeFloat:
      ;
  end;
  AppBarMessage(abmQueryPos, AEdge, 0, Result);

  case AEdge of
    abeLeft:
      Result.Right := Result.Left + AppbarWidth;
    abeTop:
      Result.Bottom := Result.Top + AppbarHeight;
    abeRight:
      Result.Left := Result.Right - AppbarWidth;
    abeBottom:
      Result.Top := Result.Bottom - AppbarHeight;
    abeUnknown:
      ;
    abeFloat:
      ;
  end;
end;

procedure TAppBarX.SetABNFullscreenApp(bFullscreen: Boolean);
var
  ABNState: Cardinal;
  rc: TRect;
  c: Cardinal;
begin
  rc := BoundsRect;
  ABNState := AppBarMessage(abmGetState, FEdge, 0, rc);
  if (ABNState and ABS_ALWAYSONTOP) <> 0 then
    c := HWND_TOPMOST
  else
    c := HWND_BOTTOM;

  if bFullscreen then
    SetWindowPos(Handle, c, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE)
  else
    if (ABNState and ABS_ALWAYSONTOP) <> 0 then
      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TAppBarX.SetABNStateChanged;
var
  ABNState: Cardinal;
  rc: TRect;
  c: Cardinal;
begin
  rc := BoundsRect;
  ABNState := AppBarMessage(abmGetState, FEdge, 0, rc);
  if (ABNState and ABS_ALWAYSONTOP) <> 0 then
    c := HWND_TOPMOST
  else
    c := HWND_BOTTOM;
  SetWindowPos(Handle, c, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TAppBarX.SetAppbarPos;
var
  rc: TRect;
begin
  rc := GetAppbarRect(FEdge);
  if AppBarMessage(abmSetAutoHideBarEx, FEdge, lParam(BOOL(FAutohide)), rc) = 0 then
    FAutohide := False;

  if not FAutohide then
    begin
      rc := GetAppbarRect(FEdge);
      AppBarMessage(abmSetPos, FEdge, 0, rc);
      BoundsRect := rc;
    end
  else
    begin
      rc := Self.Monitor.BoundsRect;
      case FEdge of
        abeLeft:
          rc.Width := 2 * GetSystemMetrics(SM_CXBORDER);
        abeTop:
          rc.Height := 2 * GetSystemMetrics(SM_CYBORDER);
        abeRight:
          rc.Left := rc.Right - 2 * GetSystemMetrics(SM_CXBORDER);
        abeBottom:
          rc.Top := rc.Bottom - 2 * GetSystemMetrics(SM_CYBORDER);
      end;
      AppBarMessage(abmSetPos, FEdge, 0, rc);
      BoundsRect := rc;
    end;
end;

procedure TAppBarX.SetAutohide(const Value: Boolean);
begin
  if FAutohide <> Value then
    begin
      FAutohide := Value;
      if FEdge in [abeLeft .. abeBottom] then
        SetAppbarPos;
    end;
end;

procedure TAppBarX.SetEdge(const Value: TAppBarEdge);
var
  rc: TRect;
begin
  if FEdge = Value then
    exit;

  FEdge := Value;
  case FEdge of
    abeUnknown:
      FreeAppbar;
    abeFloat:
      FreeAppbar;
  else
    begin
      CreateAppbar;
      SetAppbarPos;
      AppBarMessage(abmActivate, FEdge, 0, rc);
      if FEdge in [abeLeft, abeRight] then
        rc.Width := Width
      else
        rc.Height := Height;
    end;
  end;

end;

procedure TAppBarX.SlideWindow(var rcEnd: TRect);
var
  bFullDragOn: LongBool;
  rcStart: TRect;
  dwTimeStart, dwTimeEnd, dwTime: DWORD;
  x, y, w, h: Integer;
begin
  // Only slide the window if the user has FullDrag turned on
  SystemParametersInfo(SPI_GETDRAGFULLWINDOWS, 0, @bFullDragOn, 0);

  // Get the current window position
  GetWindowRect(Handle, rcStart);
  if bFullDragOn and ((rcStart.Left <> rcEnd.Left) or (rcStart.Top <> rcEnd.Top) or (rcStart.Right <> rcEnd.Right) or (rcStart.Bottom <> rcEnd.Bottom)) then
    begin
      // Get our starting and ending time
      dwTimeStart := GetTickCount;
      dwTimeEnd := dwTimeStart + SLIDE_DEF_TIMER_INTERVAL;
      dwTime := dwTimeStart;
      while (dwTime < dwTimeEnd) do
        begin
          // While we are still sliding, calculate our new position
          x := rcStart.Left - (rcStart.Left - rcEnd.Left) * Integer(dwTime - dwTimeStart) div SLIDE_DEF_TIMER_INTERVAL;
          y := rcStart.Top - (rcStart.Top - rcEnd.Top) * Integer(dwTime - dwTimeStart) div SLIDE_DEF_TIMER_INTERVAL;
          w := rcStart.Width - (rcStart.Width - rcEnd.Width) * Integer(dwTime - dwTimeStart) div SLIDE_DEF_TIMER_INTERVAL;
          h := rcStart.Height - (rcStart.Height - rcEnd.Height) * Integer(dwTime - dwTimeStart) div SLIDE_DEF_TIMER_INTERVAL;
          // Show the window at its changed position
          SetWindowPos(Handle, 0, x, y, w, h, SWP_NOZORDER or SWP_NOACTIVATE or SWP_DRAWFRAME);
          UpdateWindow(Handle);
          dwTime := GetTickCount;
        end;
    end;

  // Make sure that the window is at its final position
  BoundsRect := rcEnd;
  UpdateWindow(Handle);
end;

procedure TAppBarX.WMActivate(var Msg: TMessage);
var
  rc: TRect;
begin
  inherited;
  if FAppbarCreated and (Msg.WParam <> WA_INACTIVE) then
    begin
      rc := BoundsRect;
      AppBarMessage(abmActivate, FEdge, 0, rc);
    end;
end;

procedure TAppBarX.WMExitSizeMove(var Msg: TMessage);
begin
  inherited;
  if FAppbarCreated then
    begin
      case FEdge of
        abeLeft, abeRight:
          AppbarWidth := Width;
        abeTop, abeBottom:
          AppbarHeight := Height;
        abeUnknown:
          ;
        abeFloat:
          ;
      end;
      SetAppbarPos;
    end;
end;

procedure TAppBarX.WMNcHitTest(var Msg: TWMNCHitTest);
const
  BorderDelta = 5;
var
  bPrimaryMouseBtnDown: Boolean;
  rcClient: TRect;
  pt: TPoint;
  vKey: integer;
begin
  inherited;
  pt := Msg.Pos;
  pt := ScreenToClient(pt);
  if Assigned(ControlAtPos(pt, False)) then
    exit;

  rcClient := ClientRect;

  if GetSystemMetrics(SM_SWAPBUTTON) <> 0 then
    vKey := VK_RBUTTON
  else
    vKey := VK_LBUTTON;
  bPrimaryMouseBtnDown := ((GetAsyncKeyState(vKey) and $8000) <> 0);

  if (Msg.Result = HTCLIENT) and bPrimaryMouseBtnDown and (Edge = abeFloat) then
    // User clicked in client area, allow AppBar to move.  We get this
    // behavior by pretending that the user clicked on the caption area
    Msg.Result := HTCAPTION;

  case FEdge of
    abeLeft:
      if pt.x > (rcClient.Right - BorderDelta) then
        Msg.Result := HTRIGHT;
    abeTop:
      if pt.y > (rcClient.Bottom - BorderDelta) then
        Msg.Result := HTBOTTOM;
    abeRight:
      if pt.x < (rcClient.Left + BorderDelta) then
        Msg.Result := HTLEFT;
    abeBottom:
      if pt.y < (rcClient.Top + BorderDelta) then
        Msg.Result := HTTOP;
    abeFloat:
      begin
        if pt.x <= BorderDelta then
          begin
            if (pt.y <= BorderDelta) then
              Msg.Result := HTTOPLEFT
            else
              if pt.y >= (rcClient.Height - BorderDelta) then
                Msg.Result := HTBOTTOMLEFT
              else
                Msg.Result := HTLEFT;
          end
        else
          if pt.x >= (rcClient.Width - BorderDelta) then
            begin
              if (pt.y <= BorderDelta) then
                Msg.Result := HTTOPRIGHT
              else
                if pt.y >= (rcClient.Height - BorderDelta) then
                  Msg.Result := HTBOTTOMRIGHT
                else
                  Msg.Result := HTRIGHT;
            end
          else
            begin
              if pt.y < BorderDelta then
                Msg.Result := HTTOP;
              if pt.y > (rcClient.Height - BorderDelta) then
                Msg.Result := HTBOTTOM;
            end;
      end;
  end;
end;

procedure TAppBarX.WMWindowPosChanged(var Msg: TMessage);
var
  rc: TRect;
begin
  inherited;
  if FAppbarCreated then
    begin
      rc := BoundsRect;
      AppBarMessage(abmWindowPosChanged, FEdge, 0, rc);
    end;
end;

end.
