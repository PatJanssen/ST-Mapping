unit SplineGraph;

{$MODE Delphi}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit;

type
  TSplineGraphDlg = class(TForm)
    OKBtn: TButton;
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadData(XD, YD : PDouble; len_XY : integer; FD, SD : array of real);
    procedure ShowOK;
  end;

var
  SplineGraphDlg: TSplineGraphDlg;

implementation

{$R *.lfm}

var
  xData, yData, FuncData, SlopeData : array of real;

procedure TSplineGraphDlg.FormPaint(Sender: TObject);
const
  Xorg = 50;
  Yorg = 410;
  Yhgt = 400;
  Xwid = 1100;
var
  i, j, l, XC, YC : integer;
  Yscale : real;
begin
  canvas.MoveTo(Xorg,Yorg-Yhgt);
  canvas.LineTo(Xorg,Yorg+Yhgt);
  canvas.MoveTo(Xorg,Yorg);
  canvas.LineTo(Xorg+Xwid,Yorg);
  l := Length(FuncData);
  j := Length(xData);
  Yscale := 0.0;
  for i:= 0 to l - 1 do
    begin
      if abs(FuncData[i]) > Yscale then Yscale := abs(FuncData[i]);
    end;
  for i:= 0 to j - 1 do
    begin
      if abs(yData[i]) > Yscale then Yscale := abs(yData[i]);
    end;
  canvas.MoveTo(Xorg,Yorg-round(FuncData[0]*Yhgt/Yscale));
  for i:= 1 to l - 1 do
    begin
      if FuncData[i] < 0.0 then
        canvas.Pen.Color := clGreen
      else
        canvas.Pen.Color := clRed;
      canvas.LineTo(Xorg+round(Xwid*i/(l-1)),Yorg-round(FuncData[i]*Yhgt/Yscale));
    end;
  for i:= 0 to j - 1 do
    begin
      if yData[i] < 0.0 then
        begin
          canvas.Pen.Color := clGreen;
          canvas.Brush.Color := clGreen;
        end
      else
        begin
          canvas.Pen.Color := clRed;
          canvas.Brush.Color := clRed;
        end;
      XC := Xorg+round(Xwid*xData[i]/(l-1));
      YC := Yorg-round(yData[i]*Yhgt/Yscale);
      canvas.Ellipse(XC-5, YC-5, XC+5, YC+5);
    end;
  l := Length(FuncData);
  Yscale := 0.0;
  for i:= 0 to l - 1 do
    begin
      if abs(SlopeData[i]) > Yscale then Yscale := abs(SlopeData[i]);
    end;
  canvas.MoveTo(Xorg,Yorg-round(SlopeData[0]*Yhgt/Yscale));
  for i:= 1 to l - 1 do
    begin
      if SlopeData[i] < 0.0 then
        canvas.Pen.Color := clYellow
      else
        canvas.Pen.Color := clBlue;
      canvas.LineTo(Xorg+round(Xwid*i/(l-1)),Yorg-round(SlopeData[i]*Yhgt/Yscale));
    end;
end;

procedure TSplineGraphDlg.LoadData(XD, YD : PDouble; len_XY : integer; FD, SD : array of real);
var
  i, l : Integer;
//  TF : TextFile;
begin
//  AssignFile(TF, 'c:\tmp.dat');
//  Rewrite(TF);
  l := len_XY;
  SetLength(xData, l);
  SetLength(yData, l);
  for i := 0 to l - 1 do
    begin
      xData[i] := XD[i];
      yData[i] := YD[i];
    end;
//  for i := 0 to l - 1 do Write(TF, xData[i]:8:3,','); Writeln(TF,' ');
//  for i := 0 to l - 1 do Write(TF, yData[i]:8:3,','); Writeln(TF,' ');
  l := Length(FD);
  SetLength(FuncData, l);
  SetLength(SlopeData, l);
  for i := 0 to l - 1 do
    begin
      FuncData[i] := FD[i];
      SlopeData[i] := SD[i];
    end;
//  for i := 0 to l - 1 do Write(TF, FuncData[i]:8:3,','); Writeln(TF,' ');
//  for i := 0 to l - 1 do Write(TF, SlopeData[i]:9:5,','); Writeln(TF,' ');
//  CloseFile(TF);
end;

procedure TSplineGraphDlg.ShowOK;
begin
  if ShowModal = mrOK then ;
end;

end.
