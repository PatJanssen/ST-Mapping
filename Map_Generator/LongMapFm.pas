unit LongMapFm;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TLongMap = class(TForm)
    Image1: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetPicture(Pict : TPicture; Scale : Real);
  end;

var
  LongMap: TLongMap;

implementation

{$R *.lfm}

procedure TLongMap.SetPicture(Pict : TPicture; Scale : Real);
begin
  Image1.Height := Round(Scale * Pict.Height);
  Image1.Width := Round(Scale * Pict.Width);
  Image1.Picture := Pict;
end;

end.
