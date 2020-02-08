unit DropLink;

interface

uses
  Windows, Graphics, ComObj, ActiveX, ShlObj, DropObj;

type
  // The TDroppedLink class encapsulates an Explorer Shortcut
  TDroppedLink = class(TDroppedObject)
  private
    FLink : IShellLink;
    FFile : IPersistFile;
  protected
    function GetCaption : String; override;
    function GetIcon : TIcon; override;
  public
    constructor Create(const FileName : String);
  end;

implementation

uses
  SysUtils, ShellApi;

// TDroppedLink.Create ////////////////////////////////////////////////////////
constructor TDroppedLink.Create(const FileName : String);
var
  wszFileName : array [0..MAX_PATH] of WideChar;
begin
  // Call the base class constructor
  inherited Create(FileName);
  // Get a pointer to the IShellLink interface and store it
  FLink := CreateComObject(CLSID_ShellLink) as IShellLink;
  // Get a pointer to the IPersistFile interface and store it
  FFile := FLink as IPersistFile;
  // Load the shortcut file into memory
  StringToWideChar(FileName, wszFileName, MAX_PATH);
  FFile.Load(wszFileName, STGM_READ);
end;

// TDroppedLink.GetCaption ////////////////////////////////////////////////////
function TDroppedLink.GetCaption : String;
var
  s : String;
begin
  // Get the FileName without the path
  s := ExtractFileName(Name);
  // Return the FileName without the .lnk extension
  Result := Copy(s, 1, Length(s) - 4);
end;

// TDroppedLink.GetIcon ///////////////////////////////////////////////////////
function TDroppedLink.GetIcon : TIcon;
var
  szPath : array [0..MAX_PATH] of char;
  pfd: TWin32FindData;
  nIndex : Integer;
begin
  // Clean the array of char
  szPath[0] := #0;
  // Query the shortcut for the Icon Location
  FLink.GetIconLocation(szPath, MAX_PATH, nIndex);
  // If no icon location is specified...
  if szPath[0] = #0 then begin
    // Query the shortcut for the linked file
    FLink.GetPath(szPath, MAX_PATH, pfd, SLGP_UNCPRIORITY);
    nIndex := 0;
  end;
  Result := ExtractIconFromFile(szPath, nIndex);
end;

end.
