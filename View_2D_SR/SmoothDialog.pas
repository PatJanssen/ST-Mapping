unit SmoothDialog;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, FileCtrl;

type

  { TSmoothInputDlg }

  TSmoothInputDlg = class(TForm)
    CBox_SmoothFlag: TCheckBox;
    CBox_TrendFlag: TCheckBox;
    OKBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetSmoothInfo(var SmoothFG : boolean; var TrendFG : boolean): Boolean;
  end;

var
  SmoothInputDlg: TSmoothInputDlg;

implementation

{$R *.lfm}

function TSmoothInputDlg.GetSmoothInfo(var SmoothFG : boolean; var TrendFG : boolean): Boolean;
begin
  CBox_SmoothFlag.Checked := SmoothFG;
  CBox_TrendFlag.Checked := TrendFG;
  if ShowModal = mrOK then
    begin
      GetSmoothInfo := true;
      SmoothFG := CBox_SmoothFlag.Checked;
      TrendFG := CBox_TrendFlag.Checked;
    end
  else
    GetSmoothInfo := false;
end;

end.
