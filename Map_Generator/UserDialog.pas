unit UserDialog;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type

  { TUserDlg }

  TUserDlg = class(TForm)
    Edit15: TEdit;
    GroupBox1: TGroupBox;
    Label20: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Bevel1: TBevel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Edit7: TEdit;
    Edit8: TEdit;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Edit9: TEdit;
    Edit10: TEdit;
    Bevel5: TBevel;
    Bevel6: TBevel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Label14: TLabel;
    Bevel7: TBevel;
    Label15: TLabel;
    Edit11: TEdit;
    Label16: TLabel;
    Edit12: TEdit;
    Bevel8: TBevel;
    Label17: TLabel;
    Label19: TLabel;
    Edit13: TEdit;
    Label18: TLabel;
    Edit14: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetData: Boolean;
  end;

var
  UserDlg: TUserDlg;

implementation

{$R *.lfm}

function TUserDlg.GetData: Boolean;
var
  nv : integer;
  Err : Integer;
  s1 : string;
  finished : boolean;
  ans : array[1..15] of integer;
  rGap : real;

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

function RealRange(MinLim, MaxLim : real; VarName, inStr : string; var rAns : real) : boolean;
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
  Str(TopCrop:4, s1);
  Edit1.Text := s1;
  Str(BotCrop:4, s1);
  Edit2.Text := s1;
  Str(LeftCrop:4, s1);
  Edit3.Text := s1;
  Str(RightCrop:4, s1);
  Edit4.Text := s1;
  Str(CCLx:4, s1);
  Edit5.Text := s1;
  Str(CCMx:4, s1);
  Edit11.Text := s1;
  Str(CCRx:4, s1);
  Edit6.Text := s1;
  Str(CCLy:4, s1);
  Edit7.Text := s1;
  Str(CCMy:4, s1);
  Edit12.Text := s1;
  Str(CCRy:4, s1);
  Edit8.Text := s1;
  Str(StartNo:6, s1);
  Edit9.Text := s1;
  Str(StopNo:6, s1);
  Edit10.Text := s1;
  Str(RadPnts:6, s1);
  Edit13.Text := s1;
  Str(RadGap:6:2, s1);
  Edit14.Text := s1;
  Str(InEvery:4, s1);
  Edit15.Text := s1;
  case FloatSts of
    Upper:  RadioButton1.Checked := true;
    Middle: RadioButton2.Checked := true;
    Lower:  RadioButton3.Checked := true;
  end;
  repeat
    finished := true;
    if ShowModal = mrOK then
      begin
        if InRange(0, 10000, 'Top crop limit', Edit1.Text, ans[1]) and
           InRange(0, 10000, 'Bottom crop limit', Edit2.Text, ans[2]) and
           InRange(0, 10000, 'Left crop limit', Edit3.Text, ans[3]) and
           InRange(0, 10000, 'Right crop limit', Edit4.Text, ans[4]) and
           InRange(0, 10000, 'Left anchor X coordinate', Edit5.Text, ans[5]) and
           InRange(-10, 10000, 'Mid anchor X coordinate', Edit11.Text, ans[11]) and
           InRange(0, 10000, 'Right anchor X coordinate', Edit6.Text, ans[6]) and
           InRange(0, 10000, 'Left anchor Y coordinate', Edit7.Text, ans[7]) and
           InRange(-10, 10000, 'Mid anchor Y coordinate', Edit12.Text, ans[12]) and
           InRange(0, 10000, 'Right anchor Y coordinate', Edit8.Text, ans[8]) and
           InRange(0, 1000000, 'Starting image no', Edit9.Text, ans[9]) and
           InRange(0, 1000000, 'Ending image', Edit10.Text, ans[10]) and
           InRange(3, 55, 'Number of radial points in 2D arc ROI', Edit13.Text, ans[13]) and
           RealRange(0.5, 5.0, 'Spacing of radial points in 2D arc ROI', Edit14.Text, rGap) and
           InRange(1, 10000, 'Down sampling, one in every', Edit15.Text, ans[15]) then
          begin
            TopCrop   := ans[1];
            BotCrop   := ans[2];
            LeftCrop  := ans[3];
            RightCrop := ans[4];
            CCLx      := ans[5];
            CCMx      := ans[11];
            CCRx      := ans[6];
            CCLy      := ans[7];
            CCMy      := ans[12];
            CCRy      := ans[8];
            StartNo   := ans[9];
            StopNo    := ans[10];
            RadPnts   := ans[13];
            RadGap    := rGap;
            InEvery   := ans[15];
            if RadioButton1.Checked = true then FloatSts := Upper
            else if RadioButton2.Checked = true then FloatSts := Middle
            else if RadioButton3.Checked = true then FloatSts := Lower;
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
