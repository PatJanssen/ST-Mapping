unit RealInput;

{$MODE Delphi}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, MaskEdit;

type
  TRealInputDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetReal(var NewVal: Real; Instruct: string): Boolean;
  end;

var
  RealInputDlg: TRealInputDlg;

implementation

{$R *.lfm}

function TRealInputDlg.GetReal(var NewVal: Real; Instruct: string): Boolean;
var
  nv : Real;
  Err : Integer;
  s1 : string;
begin
  Label1.Caption := Instruct;
  Str(NewVal:7:2, s1);
  Edit1.Text := s1;
  if ShowModal = mrOK then
    begin
      s1 := Edit1.Text;
      while (ord(s1[1]) = 32) do Delete(s1, 1 ,1);
      Val(s1, nv, Err);
      if Err = 0 then
        begin
          NewVal := nv;
          GetReal := true;
        end
      else
        GetReal := false;
    end
  else
    GetReal := false;
end;

end.
