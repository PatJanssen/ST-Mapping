unit MapForm;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, BGRABitmap, BGRABitmapTypes;

type

  { TMapFrm }

  TMapFrm = class(TForm)
    MapImage: TImage;
    MapToolBar: TToolBar;
    SaveButton: TToolButton;
    ScrollBox1: TScrollBox;
    ClearButton1: TToolButton;
    procedure ClearButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure MapImageClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure ClearMap;
    procedure AddLineToMap;
  end;

var
  MapFrm : TMapFrm;

implementation

uses Common, BitmapSaver;

{$R *.lfm}

procedure TMapFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  { Just make invisible }
end;
{==============================================================================}
procedure TMapFrm.ClearButton1Click(Sender: TObject);
begin
  ClearMap;
end;
{==============================================================================}
procedure TMapFrm.MapImageClick(Sender: TObject);
begin
  ShowOnTop;
end;
{==============================================================================}
procedure TMapFrm.SaveButtonClick(Sender: TObject);
{ Save map to disk }
var
  MapBmp : TBGRABitmap;
begin
  MapBmp := TBGRABitmap.Create(100,100);
  MapBmp.Assign(MapImage.Picture.Bitmap);
  BmpSaveForm.SaveToTiff(MapBmp, PlainImg);
  MapBmp.Free;
end;
{==============================================================================}
procedure TMapFrm.ClearMap;
{ Clear map }
var
  Span : Real;
begin
  Span := sqrt(sqr(CCLx-CCRx)+sqr(CCLy-CCRy));
  iSpan := round(Span);
  SetLength(CaptureBuffer, iSpan + 1);
  Width := iSpan + 30;
  MapImage.Width := iSpan + 1;
  MapImage.Height := 0;
  MapImage.Picture.Bitmap.Height := MapImage.Height;
  MapImage.Picture.Bitmap.Width  := MapImage.Width;
//  MapImage.Canvas.Brush.Color := clBtnFace;
//  MapImage.Canvas.Pen.Color := clBtnFace;
//  MapImage.Canvas.Rectangle(MapImage.ClientRect);
//  Canvas.Brush.Color := clBtnFace; { erase area first }
{  Canvas.Pen.Color := clBtnFace;
  Canvas.Rectangle(MapPos, 430, MapPos+iSpan+1, 929);
  NextLine := 0;
  Span := sqrt(sqr(CCLx-CCRx)+sqr(CCLy-CCRy));
  iSpan := round(Span);
  MapPict.Bitmap.Width := iSpan+1;
  MapPict.Bitmap.Height := 0;
  Canvas.Brush.Color := clWhite;
  Canvas.Pen.Color := clBlack;
  if MapFlag then Canvas.Rectangle(MapPos, 430, MapPos+iSpan+1, 929);}
end;
{==============================================================================}
procedure TMapFrm.AddLineToMap;
{ Add a line to map }
var
  j, ih : integer;
  s : string;
begin
  ih := MapImage.Height;
  MapImage.Height := ih + 1;
  MapImage.Picture.Bitmap.Height := MapImage.Height;
  for j := 0 to iSpan do MapImage.Canvas.Pixels[j, ih] := CaptureBuffer[j];
end;

end.

