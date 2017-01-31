program SDIAPP;

{$MODE Delphi}

uses
  Forms, Interfaces,
  MainUnit in 'MainUnit.PAS' {MainForm},
  About in 'About.PAS' {AboutBox},
  UserPrompt in 'UserPrompt.pas' {Prompt},
  LinkDialog in 'LinkDialog.pas' {LinkInputDlg},
  DumpDialog in 'DumpDialog.pas' {DumpInputDlg},
  SmoothDialog in 'SmoothDialog.pas' {SmoothInputDlg},
  KeyForm in 'KeyForm.pas',
  CommentForm in 'CommentForm.pas',
  BitmapSaver in 'BitmapSaver.pas',
  MapForm in 'MapForm.pas',
  spline2d in '..\AlgLib_Lazarus\src\spline2d.pas',
  Ap in '..\AlgLib_Lazarus\src\ap.pas',
  linmin in '..\AlgLib_Lazarus\src\linmin.pas',
  minasa in '..\AlgLib_Lazarus\src\minasa.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Live ST viewer';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TPrompt, Prompt);
  Application.CreateForm(TLinkInputDlg, LinkInputDlg);
  Application.CreateForm(TDumpInputDlg, DumpInputDlg);
  Application.CreateForm(TSmoothInputDlg, SmoothInputDlg);
  Application.CreateForm(TBmpSaveForm, BmpSaveForm);
//  Application.CreateForm(TKeyFrm, KeyFrm);
//  Application.CreateForm(TMapFrm, MapFrm);
//  Application.CreateForm(TCommentFrm, CommentFrm);
  Application.Run;
end.
 
