unit CommentForm;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, BGRABitmap, BGRABitmapTypes;

type

  { TCommentFrmFrm }

  TCommentFrm = class(TForm)
    CommentMemo: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
    procedure ClearMemo;
    procedure AddLineToMemo(StrToAdd : string);
  end;

var
  CommentFrm : TCommentFrm;

implementation

uses Common, BitmapSaver;

{$R *.lfm}

procedure TCommentFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  { Just make invisible }
end;
{==============================================================================}
procedure TCommentFrm.ClearMemo;
{ Clear comment memo }
begin
  CommentMemo.Clear;
end;
{==============================================================================}
procedure TCommentFrm.AddLineToMemo(StrToAdd : string);
{ Add a line to memo }
begin
  CommentMemo.Lines.Add(StrToAdd);
end;

end.

