program ST_Viewer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Main_Form, child_form, Common, PenalDialog, RectSRDialog, ArcDialog,
  InfoDialog, SplineGraph, LMapDialog, DMapDialog, IMapDialog, key_form, 
  BitmapSaver, RealInput;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPenalDlg, PenalDlg);
  Application.CreateForm(TArcDlg, ArcDlg);
  Application.CreateForm(TRectSRDlg, RectSRDlg);
  Application.CreateForm(TInfoDlg, InfoDlg);
  Application.CreateForm(TSplineGraphDlg, SplineGraphDlg);
  Application.CreateForm(TLMapDlg, LMapDlg);
  Application.CreateForm(TDMapDlg, DMapDlg);
  Application.CreateForm(TIMapDlg, IMapDlg);
  Application.CreateForm(TBmpSaveForm, BmpSaveForm);
  Application.CreateForm(TRealInputDlg, RealInputDlg);
  Application.Run;
end.

