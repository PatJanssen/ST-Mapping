unit Common;

{$MODE Delphi}

interface

uses Graphics, BGRABitmap, BGRABitmapTypes;

type
  TStatus  = (None, MaskT, MaskB, MaskL, MaskR);
  TDisplayMode = (NoMap, CrossHatched, ScaledDots, PseudoColourCont, PseudoColourStep);
  T_ROI = (RectROI, ArcROI);
  TImageType = (PlainImg, DiaMap, DiaFilt, DispLOI, StRtLOI, DispArc, StRtArc, StRtRad, StRtRect,
                MapKey, PubDmap, PubLOI, PubLArc, PubRad, PubRect, PubImap );

var
  DumpFlag, CustomFlag, SRfileOpen, PrFileOpen : Boolean;
  PresWidth : integer;
  Arc2Arc  : Real;
  ArcRad   : Real;
  ArcStart : Real;
  ArcAngle : Real;
  RotRev : Boolean;
  WaitStatus : TStatus;
  DisplayMode : TDisplayMode;
  ROIshape : T_ROI;
  AllFlag, GrayImages : Boolean;
  TopMask, BotMask, LeftMask, RightMask : Integer; { rectangle surrounding mask }
  LeftB, RightB : array of integer; { left and right extents of elliptical mask }
  MaskArray: array of array of byte; { custom mask from file }
  PrImgOffset : integer; { offset to synchronise pressures with images }
  BaseName, CurrentFileName : string;
  CurImage, NextImage, TimerInt, skip, StartImg, ImageFreq : integer;
  ImgExt : string[4];  {Image sequence file extension}
  FNcharsNum : integer; {Number of characters in image sequence number convention}
  nImages : Integer;
  SRfile : file of real;
  nCorPnts, nPntRows, RadPnts, nSRImages, LeftCrop, RightCrop, TopCrop, BotCrop, DataPtr : integer;
  Bright : real;
  RelaxFlag, SmoothFlag, TrendFlag : boolean;
  DumpStart, DumpEnd : integer;
  DumpFileName : string;
  r_Time, r_Press : array of real;
  xCursor, yCursor, cStored, xStored, yStored, InEvery : integer;
  CCLx, CCLy, CCMx, CCMy, CCRx, CCRy : integer;
  {MapPos,} iSpan : Integer;
  Picture : TBGRABitmap;
//  MapPict : TPicture;
  MyLUT : array[-255..255] of TColor;
    ImgFreq : real = 5.0;
  PixMM : real = 10.0;
  KeyStrain : real = 30.0;
  KeySec : integer = 30;
  KeyMM : integer = 10;
  KeyHgt, KeyWid : integer;
  KeyMin : integer = 3;
  KeyMax : integer = 20;
  KeyLarge, KeyGray, KeyUnits : boolean;
  CaptureBuffer : array of TColor;

implementation

end.
