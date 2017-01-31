unit ArcDialog;

{$MODE Delphi}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TArcDlg = class(TForm)
    OKBtn: TButton;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetStrainDir;
  end;

var
  ArcDlg: TArcDlg;

implementation

{$R *.lfm}

procedure TArcDlg.GetStrainDir;
begin
  case StrDir of
    SRlong  : RadioButton1.Checked := true;
    SRradial: RadioButton2.Checked := true;
  end;
  if ShowModal = mrOK then
    begin
      if RadioButton1.Checked = true then StrDir := SRlong
      else StrDir := SRradial;
     end;
end;

end.
