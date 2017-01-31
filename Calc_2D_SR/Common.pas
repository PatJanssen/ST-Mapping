unit Common;

{$MODE Delphi}

interface

const
  MaxSearch = 40; { maximum possible CC search }
  mCorPnts = 150; { maximum possible CC points }

type
  TImageType = (PlainImg, DiaMap, DiaFilt, DispLOI, StRtLOI, DispArc, StRtArc, StRtRad, StRtRect,
                MapKey, PubDmap, PubLOI, PubLArc, PubRad, PubRect, PubImap );
  TStrainDir = (SRlong, SRradial);
var
  ImgFreq, PixMM, KeyStrain : real;
  KeySec, KeyMM, KeyHgt, KeyWid, KeyMin, KeyMax : integer;
  KeyLarge, KeyGray, KeyUnits : boolean;
  nRowCol : integer = 0;
  RowOrCol : integer = 0;
  SRdir : integer = 0;
  SBarMsg : string;
  NoiseEst : real = 0.1; { estimate of CC movement noise for Reinsch algorithm }
  Mnodes : integer = 30; { number of nodes for penalised spline algorithm }
  NLpenal : double = 0.2; { non-linearity penalty for penalised spline algorithm }
  ScrollLocked : Boolean;
  StrDir : TStrainDir = SRlong;

type
  TLongScan = array[1..mCorPnts] of Real;

var
  SmthXd, SmthYd : integer;
  Smth : array of array of real;

procedure SetupSmth(Xd, Yd : integer);

implementation

procedure SetupSmth(Xd, Yd : integer);
begin
  SmthXd := Xd;
  SmthYd := Yd;
  SetLength(Smth, Xd, Yd);
end;

end.
