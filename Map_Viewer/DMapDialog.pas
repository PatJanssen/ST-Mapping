unit DMapDialog;

{$MODE Delphi}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TDMapDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Edit3: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Edit4: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Edit5: TEdit;
    Label10: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Edit6: TEdit;
    Label14: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetData: Boolean;
  end;

var
  DMapDlg: TDMapDlg;

implementation

{$R *.lfm}

function TDMapDlg.GetData: Boolean;
var
  s1 : string;
  finished : boolean;
  ans : array[1..6] of real;

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
  Str(PixMM:6:2, s1);
  Edit1.Text := s1;
  Str(ImgFreq:6:2, s1);
  Edit2.Text := s1;
  Str(KeySec:3, s1);
  Edit3.Text := s1;
  Str(KeyMM:3, s1);
  Edit4.Text := s1;
  Str(KeyMin:3, s1);
  Edit5.Text := s1;
  Str(KeyMax:3, s1);
  Edit6.Text := s1;
  if KeyLarge then
    RadioButton1.Checked := true
  else
    RadioButton2.Checked := true;
  repeat
    finished := true;
    if ShowModal = mrOK then
      begin
        if InRange(0.1, 100.0, 'image scale', Edit1.Text, ans[1]) and
           InRange(0.1, 100.0, 'image frequency', Edit2.Text, ans[2]) and
           InRange(1.0, 1000.0, 'Key height', Edit3.Text, ans[3]) and
           InRange(1.0, 1000.0, 'Key width', Edit4.Text, ans[4]) and
           InRange(0.0, 100.0, 'Minimum intensity', Edit5.Text, ans[5]) and
           InRange(1.0, 100.0, 'Maximum intensity', Edit6.Text, ans[6]) then
          begin
            PixMM     := ans[1];
            ImgFreq   := ans[2];
            KeySec    := round(ans[3]);
            KeyMM     := round(ans[4]);
            KeyMin    := round(ans[5]);
            KeyMax    := round(ans[6]);
            if RadioButton1.Checked then KeyLarge := true else KeyLarge := false;
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
