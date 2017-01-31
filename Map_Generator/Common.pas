unit Common;

{$MODE Delphi}

interface

const
  mCorPnts = 150; { roughly spaced at 10 pixels => 1500 pixel wide image }

type
  TThresh = (HistMin, PeakFrac, ManThresh);
  TFloat = (Upper, Middle, Lower);
  TLongScan = array[1..mCorPnts] of Real;

var
  CorWindow, HalfWin, WinSize, nSearch, ScanSize : integer;
  TopCrop, BotCrop, LeftCrop, RightCrop : Integer;
  CCLx, CCLy, CCMx, CCMy, CCRx, CCRy : Integer; { anchor points }
  StartNo, StopNo, InEvery : Integer; { frame range }
  RadPnts : integer; { of 2D arc ROI }
  RadGap : real; { number of CorWindow widths between arcs in ROI }
  Thrsh, MovAvg, ThrshScope, ThrshFrac, ManualThrsh, ThrshAdj : Integer;
  RawHist, FiltHist : array[0..255] of Integer;
  ThrshTech : TThresh;
  FloatSts : TFloat;
  AnnotDirectory : string;
  SaveAnnot : boolean;

implementation

end.
