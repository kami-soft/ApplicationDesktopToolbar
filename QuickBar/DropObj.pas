unit DropObj;

interface

uses
  Graphics;

type
  // The TDroppedObject class encapsulates a generic object dropped on the form
  TDroppedObject = class(TObject)
  private
    FName : String;
  protected
    function GetCaption : String; virtual; abstract;
    function GetIcon : TIcon; virtual; abstract;
    function GetNamePtr : PChar;
    function ExtractIconFromFile(const FileName : String;
                                       nIndex   : Integer) : TIcon;
  public
    constructor Create(const FileName : String);
    property Name : String read FName;
    property Caption : String read GetCaption;
    property Icon : TIcon read GetIcon;
    property NamePtr : PChar read GetNamePtr;
  end;

  // The CreateDroppedObject is a factory that is able to create a
  // TDroppedLink or a TDroppedFile, depending on the FileName type
  function CreateDroppedObject(const FileName : String) : TDroppedObject;

implementation

uses
  Windows, Forms, SysUtils, ShellApi, Registry, DropLink, DropFile;

// TDroppedObject.Create //////////////////////////////////////////////////////
constructor TDroppedObject.Create(const FileName : String);
begin
  // Store the FileName
  FName := FileName;
end;

// TDroppedObject.GetNamePtr //////////////////////////////////////////////////
function TDroppedObject.GetNamePtr : PChar;
var
  p : PChar;
begin
  p := StrAlloc(Length(Name) + 1);
  StrPCopy(p, Name);
  Result := p;
end;

// TDroppedObject.ExtractIconFromFile /////////////////////////////////////////
function TDroppedObject.ExtractIconFromFile(const FileName : String;
                                                  nIndex   : Integer) : TIcon;
var
  Icon : TIcon;
  hIco : HIcon;
  reg : TRegistry;
  s : String;
  IconLocation : String;
  n, nResNum : Integer;

begin
  // Try to extract the icon from the file passed as argument
  hIco := ExtractIcon(HInstance, PChar(FileName), nIndex);

  // If the passed file does not contain an icon...
  if hIco = 0 then begin

    // Search it in the Registry
    reg := TRegistry.Create;
    reg.RootKey := HKEY_CLASSES_ROOT;

    // Get the file description given the extension
    reg.OpenKey(ExtractFileExt(FileName), False);
    try
      s := reg.ReadString('');
    finally
      reg.CloseKey;
    end;

    // Get the Icon Loaction given the file description
    reg.OpenKey(s + '\DefaultIcon', False);
    try
      s := reg.ReadString('');
    finally
      reg.CloseKey;
    end;

    // Free the registry object
    reg.Destroy;

    // Check if the registry contains a DefaultIcon for the file
    if s <> '' then begin

      // Parse the string (the format is '<icon location path>,<resource nr>')
      n := Pos(',', s);
      IconLocation := Copy(s, 1, n - 1);
      nResNum := StrToInt(Copy(s, n + 1, Length(s) - n));

      // Try to extract the icon from the parsed file and resource
      hIco := ExtractIcon(HInstance, PChar(IconLocation), nResNum);

    end else begin

      if Boolean(FileGetAttr(FileName) and faDirectory) then
        nResNum := 3  // Get the Folder Icon
      else
        nResNum := 0; // Get the Windows Default Icon
      hIco := ExtractIcon(HInstance,
                          '%SystemRoot%\system32\shell32.dll', nResNum);
    end;
  end;

  // Create and return a TIcon object setting the extracted icon
  Icon := TIcon.Create;
  Icon.ReleaseHandle;
  Icon.Handle := hIco;
  Result := Icon;
end;

// CreateDroppedObject (factory) //////////////////////////////////////////////
function CreateDroppedObject(const FileName : String) : TDroppedObject;
begin
  if ExtractFileExt(FileName) = '.lnk' then
    Result := TDroppedLink.Create(FileName)
  else
    Result := TDroppedFile.Create(FileName);
end;

end.
