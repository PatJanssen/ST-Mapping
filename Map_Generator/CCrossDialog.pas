unit CCrossDialog;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TCCrossDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Bevel1: TBevel;
    Label2: TLabel;
    Label6: TLabel;
    Bevel4: TBevel;
    Label3: TLabel;
    Label4: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetData: Boolean;
  end;

var
  CCrossDlg: TCCrossDlg;

implementation

{$R *.lfm}

function TCCrossDlg.GetData: Boolean;
var
  nv : integer;
  Err : Integer;
  s1 : string;
  finished : boolean;
  ans : array[1..2] of integer;

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
  Str(CorWindow:2, s1);
  Edit1.Text := s1;
  Str(nSearch:2, s1);
  Edit2.Text := s1;
  repeat
    finished := true;
    if ShowModal = mrOK then
      begin
        if InRange(4, 40,  'Cross correlation window size', Edit1.Text, ans[1]) and
           InRange(4, 100,  'Search scope', Edit2.Text, ans[2]) then
          begin
            if odd(ans[1]) then inc(ans[1]);
            CorWindow := ans[1];
            nSearch   := ans[2];
            HalfWin := CorWindow div 2;
            WinSize := (CorWindow+1) * (CorWindow+1);
            ScanSize := CorWindow + (2 * nSearch);
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
