unit main_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Menus, ExtCtrls, child_form, Common, LCLType, LMessages;

type

  { TMainForm }

  TMainForm = class(TForm)
    MainImageList: TImageList;
    OpenDialog: TOpenDialog;
    MainClient: TPanel;
    MainToolBar: TToolBar;
    OpenFile: TToolButton;
    ToolBarSep1: TToolButton;
    CascadeWin: TToolButton;
    ToolBarSep2: TToolButton;
    ScrollLock: TToolButton;
    LastTBsep: TToolButton;
    VerticalStack: TToolButton;
    HorizontalStack: TToolButton;
    procedure ScrollLockClick(Sender: TObject);
    procedure CascadeWinClick(Sender: TObject);
    procedure TileVerticalClick(Sender: TObject);
    procedure TileHorizontalClick(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
  private
    { private declarations }
    procedure CurPixel(var Msg : TLMessage); message LM_User + 25;
    procedure VScroll(var Msg : TLMessage); message LM_User + 26;
    procedure HScroll(var Msg : TLMessage); message LM_User + 27;
    procedure MarkAllMaps(var Msg : TLMessage); message LM_User + 28;
    procedure MarkLineAllMaps(var Msg : TLMessage); message LM_User + 29;
    procedure CreateMapKey(var Msg : TLMessage); message LM_User + 30;
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses key_form;

{$R *.lfm}

{ TMainForm }

{==============================================================================}
procedure TMainForm.OpenFileClick(Sender: TObject);
var
  Child : TChildForm;
  n_Open, i : Integer;
begin
  OpenDialog.FilterIndex := 2;
  if OpenDialog.Execute then
    begin
      n_Open := 0; { Number of open children to determine position }
      if Application.ComponentCount > 0 then
          for i := 0 to Application.ComponentCount-1 do
            if Application.Components[i] is TChildForm then inc(n_Open);
      Child := TChildForm.Create(Application);
      Child.Parent := MainClient;
      Child.SetBounds(n_Open*22, n_Open*22, (MainClient.Width div 2), (MainClient.Height div 2));
      Child.LoadFromFile(OpenDialog.FileName);
    end;
end;
{==============================================================================}
procedure TMainForm.CreateMapKey(var Msg : TLMessage);
var
  Key : TKeyForm;
begin
  Key := TKeyForm.Create(Application);
  Key.Parent := MainClient;
  Key.LoadImage(Msg.WParam);
  Beep;
end;
{==============================================================================}
procedure TMainForm.CascadeWinClick(Sender: TObject);
var
  n_Child, i, iw, ih : Integer;
begin
  n_Child := -1; { Number of non-minimized children }
  iw := MainClient.Width div 2;
  ih := MainClient.Height div 2;
  if Application.ComponentCount > 0 then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
        begin
          inc(n_Child);
          (Application.Components[i] as TChildForm).SetBounds(n_Child*22, n_Child*22, iw, ih);
          (Application.Components[i] as TChildForm).ShowOnTop;
        end;
end;
{==============================================================================}
procedure TMainForm.TileVerticalClick(Sender: TObject);
var
  i, j, iw, ih, openCount : integer;
begin
  openCount := 0;
  if Application.ComponentCount > 0 then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then inc(openCount);
  if openCount <> 0 then
    begin
      iw := MainClient.Width;
      ih := MainClient.Height div openCount;
      j := -1;
      for i := 0 to Application.ComponentCount-1 do
        if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
          begin
            inc(j);
            (Application.Components[i] as TChildForm).SetBounds(0, j*ih, iw - 6, ih - 24);
          end;
    end;
end;
{==============================================================================}
procedure TMainForm.TileHorizontalClick(Sender: TObject);
var
  i, j, iw, ih, openCount : integer;
begin
  openCount := 0;
  if Application.ComponentCount > 0 then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then inc(openCount);
  if openCount <> 0 then
    begin
      iw := MainClient.Width div openCount;
      ih := MainClient.Height;
      j := -1;
      for i := 0 to Application.ComponentCount-1 do
        if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
          begin
            inc(j);
            (Application.Components[i] as TChildForm).SetBounds(j*iw, 0, iw - 6, ih - 24);
          end;
    end;
end;
{==============================================================================}
procedure TMainForm.ScrollLockClick(Sender: TObject);
begin
  { Toggle scroll lock state }
  if ScrollLocked then
    begin
      ScrollLocked := false;
      ScrollLock.ImageIndex := 9;
    end
  else
    begin
      ScrollLocked := true;
      ScrollLock.ImageIndex := 8;
    end;
end;
{==============================================================================}
procedure TMainForm.VScroll(var Msg : TLMessage);
var
  i : integer;
begin
  if ScrollLocked and (Application.ComponentCount > 0) then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
        (Application.Components[i] as TChildForm).TrackVScroll(Msg.LParam);
end;
{==============================================================================}
procedure TMainForm.HScroll(var Msg : TLMessage);
var
  i : integer;
begin
  if ScrollLocked and (Application.ComponentCount > 0) then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
        (Application.Components[i] as TChildForm).TrackHScroll(Msg.LParam);
end;
{==============================================================================}
procedure TMainForm.CurPixel(var Msg : TLMessage);
{ Update current cursor position to main toolbar }
begin
  with MainToolBar.Canvas do
    begin
      Font.Color := clBlack;
      Font.Style := [fsBold];
      Brush.Color := clBtnFace;
      TextOut(LastTBsep.Left+LastTBsep.Width+5, 5, SBarMsg+'          ');
    end;
end;
{==============================================================================}
procedure TMainForm.MarkAllMaps(var Msg : TLMessage);
var
  i : integer;
begin
  if Application.ComponentCount > 0 then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
        (Application.Components[i] as TChildForm).MarkCursor(Msg.WParam, Msg.LParam);
end;
{==============================================================================}
procedure TMainForm.MarkLineAllMaps(var Msg : TLMessage);
var
  i : integer;
begin
  if Application.ComponentCount > 0 then
    for i := 0 to Application.ComponentCount-1 do
      if (Application.Components[i] is TChildForm) and ((Application.Components[i] as TChildForm).WindowState <> wsMinimized) then
        (Application.Components[i] as TChildForm).MarkLine(Msg.WParam, Msg.LParam);
end;
{==============================================================================}

end.

