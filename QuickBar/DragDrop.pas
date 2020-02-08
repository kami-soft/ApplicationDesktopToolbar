unit DragDrop;

interface

uses
  Windows, ActiveX, ComObj;

const
  CLSID_TOleDragDrop : TGUID = '{6AD8DDE1-803D-11D1-AD38-000000000000}';

type
  TOleDragDrop = class(TComObject, IDropTarget)
  // The TOleDragDrop class implements the IDropTarget interface. OLE uses the
  // IDropTarget interface pointer that you registered with RegisterDragDrop
  // to keep you informed of the state of a drop operation
  public
    function DragEnter(const dataObj     : IDataObject;
                             grfKeyState : Longint;
                             pt          : TPoint;
                         var dwEffect    : Longint): HResult; stdcall;

    function DragOver(    grfKeyState : Longint;
                          pt          : TPoint;
                      var dwEffect    : Longint): HResult; stdcall;

    function DragLeave: HResult; stdcall;

    function Drop(const dataObj     : IDataObject;
                        grfKeyState : Longint;
                        pt          : TPoint;
                    var dwEffect    : Longint): HResult; stdcall;
  end;

implementation

uses
  ComServ, ShellApi, Messages, Main;

// TOleDragDrop.DragEnter /////////////////////////////////////////////////////
function TOleDragDrop.DragEnter(
                const dataObj     : IDataObject;
                      grfKeyState : Longint;
                      pt          : TPoint;
                  var dwEffect    : Longint): HResult; stdcall;
// When the cursor first enters a registered drop target window, OLE calls
// the IDropTarget.DragEnter member function. In this member function, you
// must ensure that your application can create the dragged object if it is
// dropped. The application also displays visual feedback showing where the
// dropped object will appear
var
  hRes : HResult;
  FormatEtc : TFormatEtc;
begin
  // Initialize FormatEtc
  with FormatEtc do begin
    cfFormat := CF_HDROP;
    ptd := nil;
    dwAspect := DVASPECT_CONTENT;
    lindex := -1;
    tymed := TYMED_HGLOBAL;
  end;
  // Query dataObj if the data is in the expected format
  hRes := dataObj.QueryGetData(FormatEtc);
  // If OK, set the drop effect to COPY; else set the drop effect to NONE
  if hRes = S_OK then begin
    dwEffect := DROPEFFECT_COPY;
    PostMessage(MainForm.Handle, WM_NCMOUSEMOVE, 0, 0);
    Result := S_OK;
  end else begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_FALSE;
  end;
end;

// TOleDragDrop.DragOver //////////////////////////////////////////////////////
function TOleDragDrop.DragOver(
                      grfKeyState : Longint;
                      pt          : TPoint;
                  var dwEffect    : Longint): HResult; stdcall;
// When the cursor moves around inside a drop target window, OLE calls the
// IDropTarget.DragOver member function. Here you must update any visual
// feedback that your application displays to reflect the current cursor
// position
begin
  // Translate coordinates to the QuickBar client area
  pt := MainForm.tbrQuickBar.ScreenToClient(pt);
  // Accept drop if the mouse pointer is in the QuickBar client area
  if PtInRect(MainForm.tbrQuickBar.ClientRect, pt) then
    dwEffect := DROPEFFECT_COPY
  else
    dwEffect := DROPEFFECT_NONE;
  // Return success
  Result := S_OK;
end;

// TOleDragDrop.DragLeave /////////////////////////////////////////////////////
function TOleDragDrop.DragLeave: HResult; stdcall;
// When the cursor leaves a drop target window, OLE calls the
// IDropTarget.DragLeave member function. Here you must remove any feedback
// you displayed during DragOver and DragEnter
begin
  Result := S_OK;
end;

// TOleDragDrop.Drop //////////////////////////////////////////////////////////
function TOleDragDrop.Drop(
                const dataObj     : IDataObject;
                      grfKeyState : Longint;
                      pt          : TPoint;
                  var dwEffect    : Longint): HResult; stdcall;
// OLE calls your IDropTarget.Drop member function when the user drops the
// object. In the Drop member function, you must create an appropriate object
// from IDataObject that is passed as a parameter
var
  hRes : HResult;
  FormatEtc : TFormatEtc;
  StgMedium : TStgMedium;
  n, nLinks : Integer;
  szFileName : array [0..MAX_PATH] of char;
begin
  // Initialize FormatEtc
  with FormatEtc do begin
    cfFormat := CF_HDROP;
    ptd := nil;
    dwAspect := DVASPECT_CONTENT;
    lindex := -1;
    tymed := TYMED_HGLOBAL;
  end;
  // Query dataObj for data, filling the StgMedium structure
  hRes := dataObj.GetData(FormatEtc, StgMedium);
  // if OK, process data
  if hRes = S_OK then begin
    // Calculate the number of dropped files
    nLinks := DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
    // Iterate for each dropped file
    for n := 0 to nLinks - 1 do begin
      // Query the StgMedium structure for the n-th element
      DragQueryFile(StgMedium.hGlobal, n, szFileName, MAX_PATH);
      // Add a Button to the QuickBar
      MainForm.AddButton(String(szFileName));
    end;
    dwEffect := DROPEFFECT_COPY;
    Result := S_OK;
  end else begin
    dwEffect := DROPEFFECT_NONE;
    Result := S_FALSE;
  end;
end;

initialization

TComObjectFactory.Create(ComServer,
                         TOleDragDrop,
                         CLSID_TOleDragDrop,
                         'TOleDragDrop',
                         'TOleDragDrop class',
                         ciMultiInstance);

end.
