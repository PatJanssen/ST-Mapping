unit STMap;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, pngimage;

type

  { TSpatMap }

  TSpatMap = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetPicture(Pict : TPngObject; Scale : Real);
  end;

var
  SpatMap: TSpatMap;

implementation

{$R *.lfm}

procedure TSpatMap.FormCreate(Sender: TObject);
begin

end;

procedure TSpatMap.SetPicture(Pict : TPngObject; Scale : Real);
begin
  Image1.Height := Round(Scale * Pict.Height);
  Image1.Width := Round(Scale * Pict.Width);
  Image1.Picture.Bitmap.Height := Image1.Height;
  Image1.Picture.Bitmap.Width := Image1.Width;
//  Image1.Canvas.Draw(0, 0, Pict);
  Pict.Draw(Image1.Picture.Bitmap.Canvas, Rect(0,0,Pict.Width,Pict.Height));
//  Stretched.Draw(Image1.Picture.Bitmap.Canvas,0,0,True);
//  Image1.Picture := Pict;
end;

end.
