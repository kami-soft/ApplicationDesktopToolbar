unit DropFile;

interface

uses
  Graphics, DropObj;

type
  // The TDroppedFile class encapsulates an Explorer file
  TDroppedFile = class(TDroppedObject)
  protected
    function GetCaption : String; override;
    function GetIcon : TIcon; override;
  end;

implementation

uses
  SysUtils;

// TDroppedFile.GetCaption ////////////////////////////////////////////////////
function TDroppedFile.GetCaption : String;
begin
  Result := ExtractFileName(Name);
end;

// TDroppedFile.GetIcon ///////////////////////////////////////////////////////
function TDroppedFile.GetIcon : TIcon;
begin
  Result := ExtractIconFromFile(Name, 0);
end;

end.
