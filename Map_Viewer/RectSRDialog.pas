unit RectSRDialog;

{$MODE Delphi}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TRectSRDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
    myRows : Integer;
    myCols : Integer;
  public
    { Public declarations }
    function GetData(nRows, nCols : integer): Boolean;
    procedure UpdateLabel2;
  end;

var
  RectSRDlg: TRectSRDlg;

implementation

{$R *.lfm}

procedure TRectSRDlg.UpdateLabel2;
var
  i : integer;
  s : string;
  c : array[0..100] of char;
  p : Pchar;
begin
  if RadioGroup1.ItemIndex = 0 then
    i := MyRows - 1
  else
    i := MyCols - 1;
  Str(i, s);
  s := '(Range 0 to ' + s + ')';
  p := StrPCopy(c, s);
  Label2.Caption := p;
end;

function TRectSRDlg.GetData(nRows, nCols : integer): Boolean;
var
  s1 : string;
  finished : boolean;
  ans : integer;

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
      Str(MinLim:3, S);
      S := 'Minimum ' + VarName + ' - ' + S;
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
  if rAns > MaxLim then
    begin
      Str(MaxLim:3, S);
      S := 'Maximum ' + VarName + ' - ' + S;
      p := StrPCopy(c, S);
      Application.MessageBox(p,'Input error',mb_OK and MB_ICONERROR);
      Result := false;
      Exit;
    end;
end;

begin
  Str(nRowCol:3, s1);
  Edit1.Text := s1;
  RadioGroup1.ItemIndex := RowOrCol;
  RadioGroup2.ItemIndex := SRdir;
  myRows := nRows;
  myCols := nCols;
  UpdateLabel2;
  repeat
    finished := true;
    if ShowModal = mrOK then
      begin
        if ((RadioGroup1.ItemIndex = 0) and InRange(0, nRows-1, 'row number', Edit1.Text, ans)) or
           ((RadioGroup1.ItemIndex = 1) and InRange(0, nCols-1, 'column number', Edit1.Text, ans)) then
          begin
            nRowCol  := ans;
            RowOrCol := RadioGroup1.ItemIndex;
            SRdir    := RadioGroup2.ItemIndex;
            GetData   := true;
          end
        else
          finished := false;
      end
    else
      GetData := false;
  until finished;
end;

procedure TRectSRDlg.RadioGroup1Click(Sender: TObject);
begin
  UpdateLabel2;
end;

end.
