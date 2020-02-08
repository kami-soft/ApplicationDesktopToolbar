unit About;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    btnOk: TButton;
    bvlFrame: TBevel;
    imgIcon: TImage;
    lblAuthor: TLabel;
    lblEMail: TLabel;
    lblHomePage: TLabel;
    lblProductName: TLabel;
    lblPurpose: TLabel;
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

end.
