unit ThreshDialog;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TThreshDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Bevel1: TBevel;
    Label11: TLabel;
    Label2: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Edit5: TEdit;
    Bevel4: TBevel;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetData: Boolean;
  end;

var
  ThreshDlg: TThreshDlg;

implementation

{$R *.lfm}

function TThreshDlg.GetData: Boolean;
var
  nv : integer;
  Err : Integer;
  s1 : string;
  finished : boolean;
  ans : array[1..5] of integer;

function InRange(MinLim, MaxLim : integer; VarName, inStr : string; var rAns : integer) : boolean;
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
      Str(MinLim:6, S);
      S := 'Minimum ' + VarName + ' - ' + S;
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
  if rAns > MaxLim then
    begin
      Str(MaxLim:6, S);
      S := 'Maximum ' + VarName + ' - ' + S;
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
end;

begin
  Str(MovAvg:2, s1);
  Edit1.Text := s1;
  Str(ThrshScope:2, s1);
  Edit2.Text := s1;
  Str(ThrshFrac:2, s1);
  Edit3.Text := s1;
  Str(ManualThrsh:3, s1);
  Edit4.Text := s1;
  Str(ThrshAdj:2, s1);
  Edit5.Text := s1;
  case ThrshTech of
    HistMin:   RadioButton1.Checked := true;
    PeakFrac:  RadioButton2.Checked := true;
    ManThresh: RadioButton3.Checked := true;
  end;
  repeat
    finished := true;
    if ShowModal = mrOK then
      begin
        if InRange(0, 99,  'Moving average window size', Edit1.Text, ans[1]) and
           InRange(0, 50,  'Threshold scope', Edit2.Text, ans[2]) and
           InRange(0, 99,  'Histogram peak fraction', Edit3.Text, ans[3]) and
           InRange(0, 255, 'Right crop limit', Edit4.Text, ans[4]) and
           InRange(-50, 50,'Fine adjust', Edit5.Text, ans[5]) then
          begin
            MovAvg    := ans[1];
            ThrshScope   := ans[2];
            ThrshFrac  := ans[3];
            ManualThrsh := ans[4];
            ThrshAdj      := ans[5];
            if RadioButton1.Checked = true then ThrshTech := HistMin
            else if RadioButton2.Checked = true then ThrshTech := PeakFrac
            else if RadioButton3.Checked = true then ThrshTech := ManThresh;
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
