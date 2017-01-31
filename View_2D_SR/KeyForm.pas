unit KeyForm;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, BGRABitmap, BGRABitmapTypes;

type

  { TKeyFrm }

  TKeyFrm = class(TForm)
    KeyImage: TImage;
    KeyToolBar: TToolBar;
    SaveButton: TToolButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure KeyImageClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure LoadImage(KeyType: integer);
    procedure PaintMapKey(Scale: real);
    procedure ClearKey;
  end;

var
  KeyFrm : TKeyFrm;

implementation

uses Common, BitmapSaver;

{$R *.lfm}

procedure TKeyFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  { Just make invisible }
end;
{==============================================================================}
procedure TKeyFrm.KeyImageClick(Sender: TObject);
begin
  ShowOnTop;
end;
{==============================================================================}
procedure TKeyFrm.SaveButtonClick(Sender: TObject);
{ Save map key to disk }
var
  KeyBmp : TBGRABitmap;
begin
  KeyBmp := TBGRABitmap.Create(100,100);
  KeyBmp.Assign(KeyImage.Picture.Bitmap);
  BmpSaveForm.SaveToTiff(KeyBmp, MapKey);
  KeyBmp.Free;
end;
{==============================================================================}
procedure TKeyFrm.LoadImage(KeyType: integer);
{ Draw a map scale key to KeyImage }
var
  c, i : integer;
  x_orig, y_orig, img_hgt, img_wid : integer;
  WidthOfText : integer;
  S : string;
begin
  KeyHgt := Round(ImgFreq * KeySec);
  KeyWid := Round(PixMM * KeyMM);
  if KeyLarge then
      x_orig := 110
    else
      x_orig := 60;
  y_orig := 20;
  if KeyLarge then
    img_hgt := y_orig + KeyHgt + 70
  else
    img_hgt := y_orig + KeyHgt + 50;
  img_wid := x_orig + KeyWid + 30;
  Height := img_hgt-3;
  Width := img_wid;
  KeyImage.Height := img_hgt;
  KeyImage.Width := img_wid;
//  KeyImage.SetSize(img_wid, img_hgt);
  KeyImage.Canvas.Pen.Color := clWhite;
  KeyImage.Canvas.FillRect(0,0,img_wid, img_hgt);
  KeyImage.Canvas.Pen.Color := clBlack;
{ Draw box outline }
  KeyImage.Canvas.MoveTo(x_orig, y_orig);
  KeyImage.Canvas.LineTo(x_orig+KeyWid, y_orig);
  KeyImage.Canvas.LineTo(x_orig+KeyWid, y_orig+KeyHgt);
  KeyImage.Canvas.LineTo(x_orig, y_orig+KeyHgt);
  KeyImage.Canvas.LineTo(x_orig, y_orig);
  KeyImage.Canvas.MoveTo(x_orig-1, y_orig-1);
  KeyImage.Canvas.LineTo(x_orig+KeyWid+1, y_orig-1);
  KeyImage.Canvas.LineTo(x_orig+KeyWid+1, y_orig+KeyHgt+1);
  KeyImage.Canvas.LineTo(x_orig-1, y_orig+KeyHgt+1);
  KeyImage.Canvas.LineTo(x_orig-1, y_orig-1);
{ Fill box in progressive intensities }
  for i := 1 to KeyHgt-1 do
    begin
      if KeyGray then
        begin
          c := Round(255.0*(i-1)/(KeyHgt-2.0));
          KeyImage.Canvas.Pen.Color := (((c*256)+c)*256)+c;
        end
      else
        begin
          c := Round(510.0*(i-1)/(KeyHgt-2.0) - 255.0);
          if c < 0 then
            begin
              if KeyType = ord('S') then
                KeyImage.Canvas.Pen.Color := (-1*c*256)*256-c
              else
                KeyImage.Canvas.Pen.Color := (-1*c*256)*256;
            end
          else
            KeyImage.Canvas.Pen.Color := (c*256)+c; {yellow}
        end;
      KeyImage.Canvas.MoveTo(x_orig+1, y_orig+i);
      KeyImage.Canvas.LineTo(x_orig+KeyWid, y_orig+i);
    end;
  SetBkMode(KeyImage.Canvas.Handle, Transparent);
  case KeyType of
    ord('Z'): { Custom key }
      begin
        S := '0';
        KeyImage.Canvas.Font.Color := $FFFFFF;
        if KeyLarge then
          KeyImage.Canvas.Font.Size := 30
        else
          KeyImage.Canvas.Font.Size := 16;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2, y_orig, S);
        if KeyStrain >= 10.0 then
          Str(KeyStrain:2:0, S)
        else if KeyStrain >= 3.0 then
          Str(KeyStrain:1:0, S)
        else Str(KeyStrain:3:1, S);
        KeyImage.Canvas.Font.Color := $0;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                            y_orig + KeyHgt - KeyImage.Canvas.TextHeight(S), S);
        S := '% s ';
        KeyImage.Canvas.Font.Color := $FFFFFF;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                            y_orig + (KeyHgt - KeyImage.Canvas.TextHeight(S)) div 2, S);
        WidthOfText := KeyImage.Canvas.TextWidth(S);
        {HeightOfText := KeyImage.Canvas.TextHeight(S);}
        S := '-1';
        if KeyLarge then
          KeyImage.Canvas.Font.Size := 16
        else
          KeyImage.Canvas.Font.Size := 8;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S) + WidthOfText)div 2,
                            y_orig + KeyHgt div 2 - KeyImage.Canvas.TextHeight(S), S);
      end;
    ord('L'),ord('S'): { Strain rate key }
      begin
        if KeyStrain >= 10.0 then
          Str(KeyStrain:2:0, S)
        else if KeyStrain >= 3.0 then
          Str(KeyStrain:1:0, S)
        else Str(KeyStrain:3:1, S);
        KeyImage.Canvas.Font.Color := $FFFFFF;
        if KeyLarge then
          KeyImage.Canvas.Font.Size := 30
        else
          KeyImage.Canvas.Font.Size := 16;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2, y_orig, S);
        if KeyStrain >= 10.0 then
          Str(-1.0*KeyStrain:3:0, S)
        else if KeyStrain >= 3.0 then
          Str(-1.0*KeyStrain:2:0, S)
        else Str(-1.0*KeyStrain:4:1, S);
        KeyImage.Canvas.Font.Color := $0;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                            y_orig + KeyHgt - KeyImage.Canvas.TextHeight(S), S);
        S := '% s ';
        KeyImage.Canvas.Font.Color := $FFFFFF;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                            y_orig + (KeyHgt - KeyImage.Canvas.TextHeight(S)) div 2, S);
        WidthOfText := KeyImage.Canvas.TextWidth(S);
        {HeightOfText := KeyImage.Canvas.TextHeight(S);}
        S := '-1';
        if KeyLarge then
          KeyImage.Canvas.Font.Size := 16
        else
          KeyImage.Canvas.Font.Size := 8;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S) + WidthOfText)div 2,
                            y_orig + KeyHgt div 2 - KeyImage.Canvas.TextHeight(S), S);
      end;
    ord('D'): { Diameter map key }
      begin
        Str(KeyMax:2, S);
        while (ord(s[1]) = 32) do Delete(s, 1 ,1);
        KeyImage.Canvas.Font.Color := $FFFFFF;
        if KeyLarge then
          KeyImage.Canvas.Font.Size := 30
        else
          KeyImage.Canvas.Font.Size := 16;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2, y_orig, S);
        if KeyUnits then
          S := S + ' '+ chr(181) + 'm'
        else
        S := S + ' mm';
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                            y_orig + (KeyHgt - KeyImage.Canvas.TextHeight(S)) div 2, S);
        Str(KeyMin:2, S);
        while (ord(s[1]) = 32) do Delete(s, 1 ,1);
        KeyImage.Canvas.Font.Color := $0;
        KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                            y_orig + KeyHgt - KeyImage.Canvas.TextHeight(S), S);
      end;
  end; {case}
  KeyImage.Canvas.Font.Color := $0;
  if KeyLarge then
    KeyImage.Canvas.Font.Size := 30
  else
    KeyImage.Canvas.Font.Size := 16;
  Str(KeyMM:2, S);
  if KeyUnits then
    S := S + ' mm'
  else
    S := S + ' '+ chr(181) + 'm';
  KeyImage.Canvas.TextOut(x_orig + (KeyWid - KeyImage.Canvas.TextWidth(S))div 2,
                        y_orig + KeyHgt, S);
  Str(KeySec:2, S);
  S := S + ' s ';
  KeyImage.Canvas.TextOut(x_orig - KeyImage.Canvas.TextWidth(S),
                        y_orig + (KeyHgt - KeyImage.Canvas.TextHeight(S)) div 2, S);
  case KeyType of
    ord('L'): Caption := ' L Map';
    ord('S'): Caption := ' Radial SR Map';
    ord('I'): Caption := ' I Map';
    ord('D'): Caption := ' D Map';
  else
    Caption := ' ? Map';
  end; {case}
end;
{==============================================================================}
{
  Genrate a map key
}
procedure TKeyFrm.PaintMapKey(Scale: real);
var
  i, ir : integer;
  x_orig, y_orig, KeyWid, KeyHgt : integer;
  S : string;
begin
  x_orig := 70;
  y_orig := 20;
  KeyWid := 40;
  KeyHgt := 300;
  KeyImage.Width := x_orig + KeyWid + 10;
  KeyImage.Height := y_orig + KeyHgt + 20;
  Width := KeyImage.Width;
  Height := KeyImage.Height+26;
  KeyImage.Canvas.Brush.Color := clWhite;
  KeyImage.Canvas.Pen.Color := clBlack;
  KeyImage.Canvas.Rectangle(KeyImage.ClientRect);
  KeyImage.Canvas.Brush.Color := clBlack;
{ Draw box outline }
  KeyImage.Canvas.FrameRect(Rect(x_orig-1, y_orig-1, x_orig+KeyWid+2, y_orig+KeyHgt+2));
  KeyImage.Canvas.FrameRect(Rect(x_orig, y_orig, x_orig+KeyWid+1, y_orig+KeyHgt+1));
{ Fill box in progressive intensities }
  for i := 1 to KeyHgt-1 do
    begin
      ir := round(510.0*(i-1.0)/(KeyHgt-2.0)) - 255;
      if ir < -255 then ir := -255 else if ir > 255 then ir := 255;
      KeyImage.Canvas.Pen.Color := MyLUT[ir];
      KeyImage.Canvas.MoveTo(x_orig+1, y_orig+i);
      KeyImage.Canvas.LineTo(x_orig+KeyWid, y_orig+i);
    end;
    SetBkMode(KeyImage.Canvas.Handle, Transparent);
    S := '0';
    KeyImage.Canvas.Font.Color := $0;
    KeyImage.Canvas.Font.Name := 'Arial';
    KeyImage.Canvas.Font.Size := 20;
    KeyImage.Canvas.TextOut(x_orig - KeyImage.Canvas.TextWidth(S) - 10, y_orig + ((KeyHgt - KeyImage.Canvas.TextHeight(S)) div 2), S);
    Str((5.0*25500.0/Scale):3:0, S);
    KeyImage.Canvas.TextOut(x_orig - KeyImage.Canvas.TextWidth(S) - 10, y_orig + KeyHgt -(KeyImage.Canvas.TextHeight(S) div 2), S);
    S := '-'+S;
    KeyImage.Canvas.TextOut(x_orig - KeyImage.Canvas.TextWidth(S) - 10, y_orig - (KeyImage.Canvas.TextHeight(S) div 2), S);
    S := '%/s';
    KeyImage.Canvas.Font.Color := clWhite;
    KeyImage.Canvas.Font.Size := 14;
    KeyImage.Canvas.TextOut(x_orig + 2, y_orig + ((KeyHgt - KeyImage.Canvas.TextHeight(S)) div 2), S);
end;
{
  Clear map key
}
procedure TKeyFrm.ClearKey;
var
  x_orig, y_orig, KeyWid, KeyHgt : integer;
begin
  x_orig := 70;
  y_orig := 20;
  KeyWid := 40;
  KeyHgt := 300;
  KeyImage.Width := x_orig + KeyWid + 10;
  KeyImage.Height := y_orig + KeyHgt + 20;
  KeyImage.Canvas.Brush.Color := clBtnFace;
  KeyImage.Canvas.Pen.Color := clBtnFace;
  KeyImage.Canvas.Rectangle(KeyImage.ClientRect);
end;

end.

