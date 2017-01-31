unit PenalDialog;

{$MODE Delphi}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TPenalDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetData: Boolean;
  end;

var
  PenalDlg: TPenalDlg;

implementation

{$R *.lfm}

function TPenalDlg.GetData: Boolean;
var
  s1 : string;
  finished : boolean;
  ans : array[1..2] of real;

function InRange(MinLim, MaxLim : real; VarName, inStr : string; var rAns : real) : boolean;
var
  S : string;
  E : integer;
  c : array[0..100] of char;
  p : Pchar;
begin
  Result := true;
  S := inStr;
  while (ord(s[1]) = 32) do Delete(s, 1 ,1);
  Val(S, rAns, E);
  if E <> 0 then
    begin
      S := 'Numerical data expected - "' + inStr + '"';
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
  if rAns < MinLim then
    begin
      Str(MinLim:6:2, S);
      S := 'Minimum ' + VarName + ' - ' + S;
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
  if rAns > MaxLim then
    begin
      Str(MaxLim:6:2, S);
      S := 'Maximum ' + VarName + ' - ' + S;
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
end;

begin
  Str(Mnodes:6, s1);
  Edit1.Text := s1;
  Str(NLpenal:6:2, s1);
  Edit2.Text := s1;
  repeat
    finished := true;
    if ShowModal = mrOK then
      begin
        if InRange(4.0, 1000.0, 'spline nodes', Edit1.Text, ans[1]) and
           InRange(-8.0, 8.0, 'non-linearity penalty', Edit2.Text, ans[2]) then
          begin
            Mnodes    := round(ans[1]);
            NLpenal   := ans[2];
            GetData   := true;
          end
        else
          finished := false;
      end
    else
      GetData := false;
  until finished;
end;

end.
