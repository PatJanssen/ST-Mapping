unit ThreshGraph;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, Common;

type
  TGraphThreshDlg = class(TForm)
    OKBtn: TButton;
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function DispGraph: Boolean;
  end;

var
  GraphThreshDlg: TGraphThreshDlg;

implementation

{$R *.lfm}

function TGraphThreshDlg.DispGraph: Boolean;
begin
  if ShowModal = mrOK then ;
end;

procedure TGraphThreshDlg.FormPaint(Sender: TObject);
const
  orgX = 50;
  orgY = 350;
  rngX = 512;
  rngY = 300;
var
  i, j, maxH: Integer;
  s: string;
begin
  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(orgX, orgY - rngY);
  Canvas.LineTo(orgX, orgY);
  Canvas.LineTo(orgX + rngX, orgY);
  for i := 0 to 5 do
    begin
      j := i * 50;
      Str(j:3, s);
      while (ord(s[1]) = 32) do Delete(s, 1 ,1);
      Canvas.MoveTo(orgX+(i*100), orgY);
      Canvas.LineTo(orgX+(i*100), orgY+10);
      Canvas.TextOut(orgX+(i*100)-(Canvas.TextWidth(s) div 2), orgY+10, s);
    end;
  maxH := 0;
  for i := 0 to 255 do if RawHist[i] > maxH then maxH := RawHist[i];
  Canvas.Pen.Color := clRed;
  Canvas.MoveTo(orgX, orgY - (RawHist[0]*rngY div maxH));
  for i := 1 to 255 do
    begin
      Canvas.LineTo(orgX + (i*2), orgY - (RawHist[i]*rngY div maxH));
    end;
  maxH := 0;
  for i := 0 to 255 do if FiltHist[i] > maxH then maxH := FiltHist[i];
  Canvas.Pen.Color := clGreen;
  Canvas.MoveTo(orgX, orgY - (FiltHist[0]*rngY div maxH));
  for i := 1 to 255 do
    begin
      Canvas.LineTo(orgX + (i*2), orgY - (FiltHist[i]*rngY div maxH));
    end;
  Canvas.Pen.Color := clBlue;
  Canvas.MoveTo(orgX + (Thrsh*2), orgY);
  Canvas.LineTo(orgX + (Thrsh*2), orgY - rngY);

end;

end.
