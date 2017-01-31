program ST_Generator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainUnit, UserPrompt, Common, About,
  LongMapFm, STMap, UserDialog, ThreshDialog, ThreshGraph, CCrossDialog, ap,
  spline2d, minasa, linmin;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TPrompt, Prompt);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TLongMap, LongMap);
  Application.CreateForm(TSpatMap, SpatMap);
  Application.CreateForm(TUserDlg, UserDlg);
  Application.CreateForm(TThreshDlg, ThreshDlg);
  Application.CreateForm(TGraphThreshDlg, GraphThreshDlg);
  Application.CreateForm(TCCrossDlg, CCrossDlg);
  Application.Run;
end.

