unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Common, Strutils, LCLType, Math;

type

  { TMainForm }

  TMainForm = class(TForm)
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog: TOpenDialog;
    YProgress: TProgressBar;
    XProgress: TProgressBar;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    CalcButton: TToolButton;
    ExportButton: TToolButton;
    procedure CalcButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
    FullArray : Tlist;
    LongArray : Tlist;
//    ImageType : TImageType;
//    xCursor : Integer;
//    yCursor : Integer;
//    xCurOld : Integer;
//    yCurOld : Integer;
    nCorPnts : Integer;
    nPntRows : Integer;
    InEvery : Integer;
    LeftCrop : integer;
    RightCrop : integer;
    TopCrop : integer;
    BotCrop : integer;
    StartNo : integer;
    nImages : Integer;
    RadPnts : Integer;
    Arc2Arc : Real;
    CCLx : Integer;
    CCLy : Integer;
    CCMx : Integer;
    CCMy : Integer;
    CCRx : Integer;
    CCRy : Integer;
    ArcRad   : Real;
    ArcStart : Real;
    ArcAngle : Real;
    RotRev : boolean;
//    TaperDown : boolean;
//    MyImgWidth : Integer;
//    rPntGap : real;
//    WinSize : integer; {  moving average filter window size }
//    AvgCount : integer;
//    SourceFN : string[255];
//    rcID : string[12];
    procedure ProcessRectROI;
    procedure ProcessArcROI;
    procedure Calc2dRectStrains(FName : string);
    procedure Calc2dArcStrains(FName : string);
    procedure Median5x3(ArrWid : integer);
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

{ penalized spline routine in AlgLib library }
  function penspline(x : PDouble; dimx: integer; y : PDouble; dimy: integer; res: PDouble; dimres, fnflg, M : integer; rho : double) : integer; cdecl; external 'alglib64.dll';

implementation

{$R *.lfm}

{ TMainForm }


procedure TMainForm.FormCreate(Sender: TObject);
begin
  FullArray := Tlist.Create;
  LongArray := Tlist.Create;
end;
{==============================================================================}
procedure TMainForm.CalcButtonClick(Sender: TObject);
{ Select file of 2D cross correlation data, either over a rectangular or arc-shaped ROI }
begin
  if OpenDialog.Execute and FileExistsUTF8(OpenDialog.FileName) then
    begin
      if (LowerCase(ExtractFileExt(OpenDialog.FileName)) = '.rct') then { 2D cross correlation, rectangular ROI }
        ProcessRectROI
      else if (LowerCase(ExtractFileExt(OpenDialog.FileName)) = '.arc') then { 2D cross correlation, arc-shaped ROI }
        ProcessArcROI;
    end;
end;
{==============================================================================}
procedure TMainForm.ProcessRectROI;
{ Read in 2D cross correlation data based on a rectangular grid of reference points, i.e. ROI, and
  pass on for further processing }
var
  FT : TextFile;
  PLongScan : ^TLongScan;
  ROItype, s : string;
  i : integer;
begin
  AssignFile(FT, OpenDialog.FileName);
  Reset(FT);
  Readln(FT, ROItype);
  Readln(FT, s); { fudge to deal with old files that lack InEvery downsampling parameter, default to 1 }
  CloseFile(FT);
  Reset(FT);
  Readln(FT, ROItype);
  if NPos(' ', s, 3) = 0 then
    begin
      Readln(FT, StartNo, nCorPnts, nPntRows);
      InEvery := 1;
    end
  else
    Readln(FT, StartNo, nCorPnts, nPntRows, InEvery);
  Readln(FT, LeftCrop, RightCrop, TopCrop, BotCrop);
  repeat { Read all displacement values from file }
    New(PLongScan);
    FullArray.Add(PLongScan);
    for i := 1 to nCorPnts-1 do
       read(FT,PLongScan^[i]);
    readln(FT,PLongScan^[nCorPnts]);
  until EOF(FT);
  CloseFile(FT);
  s:= ChangeFileExt(OpenDialog.FileName,'.sr2');
  Calc2dRectStrains(s);
  for i := 0 to FullArray.Count-1 do { Dispose of raw displacements data }
    begin
      PLongScan :=  FullArray.Items[i];
      Dispose(PLongScan);
    end;
  FullArray.Clear;
  Application.MessageBox('Conversion to .sr2 file complete','Message',mb_OK);
end;
{==============================================================================}
procedure TMainForm.Calc2dRectStrains(FName : string);
{
  Calculate 2d strain rates in X & Y direction
    On entry : X & Y direction displacements in FullArray
    On exit  : horizontal and vertical strain rates written to .sr2 file
}
var
  SRfile : file of real;  {Storage of strain rates}
  SourX, DestVect, P : ^TLongScan;
  i, j, k, l : integer;
  x : PDouble;
  y : PDouble;
  ans : PDouble;
  dimX, dimY, dimAns : integer;
  iRet : integer;
  S1 : string;
  r, r1, r2, r3, r4, r5 : real;
begin
  XProgress.Position := 0;
  YProgress.Position := 0;
  AssignFile(SRfile, FName);
  ReWrite(SRfile);
  nImages := FullArray.Count div (nPntRows*2);
  r1 := -1.0;
  Write(SRfile, r1); { indicates new SR file type }
  r1 := StartNo; r2 := nImages; r3 := nCorPnts; r4 := nPntRows; r5 := InEvery;
  Write(SRfile, r1, r2, r3, r4, r5);
  r1 := LeftCrop; r2 := RightCrop; r3 := TopCrop; r4 := BotCrop;
  Write(SRfile, r1, r2, r3, r4); { first SR data should start at Seek(10) }
{****************************************************
  Initialise only once for spline fitting to ROI rows
*****************************************************}
{ Dimension arrays and load }
  x := getmem(nCorPnts*sizeof(double));
  y := getmem(nCorPnts*sizeof(double));
  ans := getmem((RightCrop-LeftCrop+1)*sizeof(double));
  dimX := nCorPnts-1;
  dimY := nCorPnts-1;
  dimAns := RightCrop-LeftCrop;
{ Fill x array with actual distance between points }
  for i:= 0 to nCorPnts-1 do
    begin
      x[i] := round((RightCrop-LeftCrop)*i/(nCorPnts-1));
    end;
{ Loop through the rows within the ROI and treat as separate SR maps}
  for k := 0 to nPntRows-1 do
    begin
      {clear out LongArray}
      for i := 0 to LongArray.Count-1 do
        begin
          P := LongArray.Items[i];
          Dispose(P);
        end;
      LongArray.Clear;
      {load LongArray with next row of ROI}
      for j := 0 to nImages-1 do
        begin
          SourX := FullArray.Items[j*2*nPntRows + k*2];
          New(DestVect);
          LongArray.Add(DestVect);
          for i := 1 to nCorPnts do DestVect^[i] := SourX^[i];
        end;
      Median5x3(nCorPnts); {Filter current array}
      {differentiate each row of image }
      for l := 0 to LongArray.Count-1 do
        begin
          P :=  LongArray.Items[l];
          { Differentiate wrt distance and smooth using spline }
          for i := 1 to nCorPnts do
            begin
              y[i-1] := P^[i];
              {dy[i] := NoiseEst;}
            end;
          iRet := penspline(x, dimX, y, dimY, ans, dimAns, 1, Mnodes, NLpenal);
          { Save horizontal direction strain rates to SR file }
          for i := 0 to nCorPnts-1 do
            begin
              Write(SRfile, ans[round((RightCrop-LeftCrop)*i/(nCorPnts-1))]);
            end;
          XProgress.Position := (k+1) * 100 div nPntRows;
          Application.ProcessMessages;
        end;
    end; {for k}
  freemem(x);
  freemem(y);
  freemem(ans);
{*****************************************
  Repeat spline fitting to all ROI columns
******************************************}
{ Dimension arrays and load }
  x := getmem(nPntRows*sizeof(double));
  y := getmem(nPntRows*sizeof(double));
  ans := getmem((BotCrop-TopCrop+1)*sizeof(double));
  dimX := nPntRows-1;
  dimY := nPntRows-1;
  dimAns := BotCrop-TopCrop;
{ Fill x array with actual distance between points }
  for i:= 0 to nPntRows-1 do
    begin
      x[i] := round((BotCrop-TopCrop)*i/(nPntRows-1));
    end;
{ Loop through the columns within the ROI and treat as separate SR maps}
  for k := 0 to nCorPnts-1 do
    begin
      {clear out LongArray}
      for i := 0 to LongArray.Count-1 do
        begin
          P := LongArray.Items[i];
          Dispose(P);
        end;
      LongArray.Clear;
      {load LongArray with next column of ROI}
      for j := 0 to nImages-1 do
        begin
          New(DestVect);
          LongArray.Add(DestVect);
          for i := 1 to nPntRows do
            begin
              SourX := FullArray.Items[j*2*nPntRows + i*2 - 1];
              DestVect^[i] := SourX^[k+1];
            end;
        end;
      Median5x3(nPntRows); {Filter current array}
      {differentiate each column of image }
      for l := 0 to LongArray.Count-1 do
        begin
          P :=  LongArray.Items[l];
          { Differentiate wrt distance and smooth using spline }
          for i := 1 to nPntRows do
            begin
              y[i-1] := P^[i];
              {dy[i] := NoiseEst;}
            end;
          iRet := penspline(x, dimX, y, dimY, ans, dimAns, 1, Mnodes, NLpenal);
          { Save horizontal direction strain rates to SR file }
          for i := 0 to nPntRows-1 do
            begin
              Write(SRfile, ans[round((BotCrop-TopCrop)*i/(nPntRows-1))]);
            end;
          YProgress.Position := (k+1) * 100 div nCorPnts;
          Application.ProcessMessages;
        end;
    end; {for k}
  CloseFile(SRfile);
  freemem(x);
  freemem(y);
  freemem(ans);
end;
{==============================================================================}
procedure TMainForm.Median5x3(ArrWid : integer);
var
  M, P, Q, R : ^TLongScan;
  i, j, k, s, st, sp, dv, nb, aw : integer;
  bin : array[-100*MaxSearch..100*MaxSearch] of byte;
begin
  if ArrWid = 0 then aw := nCorPnts else aw := ArrWid;
{ Insert two new rows at top and one at the end }
  New(P);
  LongArray.Insert(0, P);
  Q := LongArray.Items[1];
  for i := 1 to aw do P^[i] := Q^[i];
  New(P);
  LongArray.Add(P);
  Q := LongArray.Items[LongArray.Count-2];
  for i := 1 to aw do P^[i] := Q^[i];
  New(P);
  LongArray.Insert(0, P);
{ Calculate medians }
  for j := 0 to LongArray.Count-4 do
    begin
      M :=  LongArray.Items[j];
      P :=  LongArray.Items[j+1];
      Q :=  LongArray.Items[j+2];
      R :=  LongArray.Items[j+3];
      M^[1] := Q^[1]; M^[2] := Q^[2]; M^[aw-1] := Q^[aw-1]; M^[aw] := Q^[aw];
      for i := 1 to aw do
        begin
          if i = 1 then
            begin
              st := 0;
              sp := 0;
              dv := 2;
            end
          else if i = aw then
            begin
              st := 0;
              sp := 0;
              dv := 2;
            end
          else if i = 2 then
            begin
              st := -1;
              sp := 1;
              dv := 5;
            end
          else if i = aw-1 then
            begin
              st := -1;
              sp := 1;
              dv := 5;
            end
          else
            begin
              st := -2;
              sp := 2;
              dv := 8;
            end;
          for k := -100*MaxSearch to 100*MaxSearch do bin[k]:= 0;
          for k := st to sp do
            begin
              nb := Round(100.0*P^[i+k]);
              if nb < -100*MaxSearch then nb := -100*MaxSearch
              else if nb > 100*MaxSearch then nb := 100*MaxSearch;
              inc(bin[nb]);
            end;
          for k := st to sp do
            begin
              nb := Round(100.0*Q^[i+k]);
              if nb < -100*MaxSearch then nb := -100*MaxSearch
              else if nb > 100*MaxSearch then nb := 100*MaxSearch;
              inc(bin[nb]);
            end;
          for k := st to sp do
            begin
              nb := Round(100.0*R^[i+k]);
              if nb < -100*MaxSearch then nb := -100*MaxSearch
              else if nb > 100*MaxSearch then nb := 100*MaxSearch;
              inc(bin[nb]);
            end;
          k := (-100*MaxSearch) - 1;
          s := 0;
          repeat
            inc(k);
            s := s + bin[k];
          until s >= dv;
          M^[i] := k/100.0;
        end;
    end;
{ Delete last three rows }
  for i := 1 to 3 do
    begin
      P := LongArray.Items[LongArray.Count-1];
      Dispose(P);
      LongArray.Delete(LongArray.Count-1);
    end;
end;
{==============================================================================}
procedure TMainForm.ProcessArcROI;
{ Read in 2D cross correlation data based on an arc-shaped grid of reference points, i.e. ROI, and
  pass on for further processing }
var
  FT : TextFile;
  PLongScan : ^TLongScan;
  ROItype, s : string;
  i : integer;
begin
  AssignFile(FT, OpenDialog.FileName);
  Reset(FT);
  Readln(FT, ROItype);
  Readln(FT, i); { fudge to deal with old files that lack InEvery downsampling parameter, default to 1 }
  CloseFile(FT);
  Reset(FT);
  Readln(FT, ROItype);
  if i >= 0 then { if first number is positive then it must be StartNo }
    begin
      Readln(FT, StartNo, nCorPnts, RadPnts, Arc2Arc);
      InEvery := 1;
    end
  else {if neqative it marks newer file type with InEvery addition }
    Readln(FT, i, StartNo, nCorPnts, RadPnts, Arc2Arc, InEvery);
  Readln(FT, CCLx, CCLy, CCMx, CCMy, CCRx, CCRy);
  Readln(FT, ArcRad, ArcStart, ArcAngle, s);
  if s = 'T' then
    RotRev := true
  else
    RotRev := false;

  {?????????????????????????????????????}
//MyImgWidth  := round(ArcRad*ArcAngle);
//rPntGap := MyImgWidth/(nCorPnts-1);
  {?????????????????????????????????????}

  repeat { Read all displacement values from file }
    New(PLongScan);
    FullArray.Add(PLongScan);
    for i := 1 to nCorPnts-1 do
       read(FT,PLongScan^[i]);
    readln(FT,PLongScan^[nCorPnts]);
  until EOF(FT);
  CloseFile(FT);

  s:= ChangeFileExt(OpenDialog.FileName,'.SRA');
  Calc2dArcStrains(s);
  for i := 0 to FullArray.Count-1 do { Dispose of raw displacements data }
    begin
      PLongScan :=  FullArray.Items[i];
      Dispose(PLongScan);
    end;
  FullArray.Clear;
  Application.MessageBox('Conversion to .SRA file complete','Message',mb_OK);
end;
{==============================================================================}
procedure TMainForm.Calc2dArcStrains(FName : string);
{
  Calculate 2d strain rates in longitudinal & radial direction
    On entry : X & Y direction displacements in FullArray
    On exit  : longitudinal & radial strain rates written to .SRA file
}
var
  FT : TextFile;
  SRfile : file of real;  {Storage of strain rates}
  SourX, SourY, DestVect, P : ^TLongScan;
  r_cx, r_cy, r_cx1, r_cy1, r_cx2, r_cy2, delta, beta, beta1, beta2, gamma, hypot, hypot1, hypot2, Lcomp1, Lcomp2 : real;
  i, j, k, l : integer;
  x : PDouble;
  y : PDouble;
  ans : PDouble;
  dimX, dimY, dimAns : integer;
  iRet : integer;
  S, S1 : string;
  r, r1, r2, r3, r4, r5, r6 : real;
begin
  XProgress.Position := 0;
  YProgress.Position := 0;
  nImages := FullArray.Count div (RadPnts*2);
  {****************************************************
    Convert coordinate system of all displacements
      Start with : X & Y direction displacements in FullArray
      End with : tangential and radial displacements in FullArray
  *****************************************************}
  for i := 0 to nImages-1 do
    for j := 1 to nCorPnts do
      begin
        delta := ArcStart + (j - 1.0) * ArcAngle /(nCorPnts - 1.0); { Get angle of radial line }
        delta := -1.0 * delta; {correct for image y dimension}
        for k := 0 to RadPnts-1 do { Calculate movement of all points in direction of radial line }
          begin
            SourX := FullArray.Items[i*2*RadPnts + k*2];
            SourY := FullArray.Items[i*2*RadPnts + k*2 + 1];
            r_cx := SourX^[j]; { Get displacement values for current point }
            r_cy := SourY^[j];
            if r_cx <> 0 then { Get beta, the angle of displacement }
              beta := arctan2(r_cy, r_cx)
            else if r_cy > 0 then
              beta := PI/2.0
            else
              beta := -1.0*PI/2.0;
            gamma := beta - delta;
            hypot := sqrt(sqr(r_cx)+sqr(r_cy));
            SourX^[j] := hypot * sin(gamma);
            SourY^[j] := hypot * cos(gamma);
          end;
        end;
  { Write header information to new strain rate data file }
{ AssignFile(FT, FName);
 Rewrite(FT);
 for i := 0 to FullArray.Count-1 do
   begin
     P :=  FullArray.Items[i];
     r := P^[1];
     if r < -99.99 then
       r := -99.99
     else if r > 99.99 then
       r := 99.99;
     Str(r:8:3, S);
     for j := 2 to nCorPnts do
       begin
         r := P^[j];
         if r < -99.99 then
           r := -99.99
         else if r > 99.99 then
           r := 99.99;
         Str(r:8:3, S1);
         S := S + ' ' + S1;
       end;
     writeln(FT, S);
    end;
  CloseFile(FT);
  Exit;}
  AssignFile(SRfile, FName);
  ReWrite(SRfile);
  r1 := StartNo; r2 := nImages; r3 := nCorPnts; r4 := RadPnts; r5 := Arc2Arc; r6 := InEvery;
  Write(SRfile, r1, r2, r3, r4, r5, r6);
  r1 := CCLx; r2 := CCLy; r3 := CCMx; r4 := CCMy; r5 := CCRx; r6 := CCRy;
  Write(SRfile, r1, r2, r3, r4, r5, r6);
  r1 := ArcRad; r2 := ArcStart; r3 := ArcAngle; if RotRev then r4 := 1.0 else r4 := 0.0; r5 := 0.0; r6 := 0.0;
  Write(SRfile, r1, r2, r3, r4, r5, r6);  { first SR data should start at Seek(18) }
{****************************************************
  Spline fitting to all ROI arcs
*****************************************************}
{ Dimension arrays and load }
  x := getmem(nCorPnts*sizeof(double));
  y := getmem(nCorPnts*sizeof(double));
  ans := getmem((RightCrop-LeftCrop+1)*sizeof(double));
  dimX := nCorPnts-1;
  dimY := nCorPnts-1;
  dimAns := RightCrop-LeftCrop;
{ Loop through the arcs within the ROI and treat as separate SR maps}
  for k := 0 to RadPnts-1 do
    begin
      { Fill x array with actual distance between points }
      for i:= 0 to nCorPnts-1 do
        begin
          x[i] := round((RightCrop-LeftCrop)*i/(nCorPnts-1));
        end;
      {clear out LongArray}
      for i := 0 to LongArray.Count-1 do
        begin
          P := LongArray.Items[i];
          Dispose(P);
        end;
      LongArray.Clear;
      {load LongArray with next row of ROI}
      for j := 0 to nImages-1 do
        begin
          SourX := FullArray.Items[j*2*RadPnts + k*2];
          New(DestVect);
          LongArray.Add(DestVect);
          for i := 1 to nCorPnts do DestVect^[i] := SourX^[i];
        end;
      Median5x3(nCorPnts); {Filter current array}
      {differentiate each row of image }
      for l := 0 to LongArray.Count-1 do
        begin
          P :=  LongArray.Items[l];
          { Differentiate wrt distance and smooth using spline }
          for i := 1 to nCorPnts do
            begin
              y[i-1] := P^[i];
              {dy[i] := NoiseEst;}
            end;
          iRet := penspline(x, dimX, y, dimY, ans, dimAns, 1, Mnodes, NLpenal);
          { Save longitudinal direction strain rates to SRA file }
          for i := 0 to nCorPnts-1 do
            begin
              Write(SRfile, ans[round((RightCrop-LeftCrop)*i/(nCorPnts-1))]);
            end;
          XProgress.Position := (k+1) * 100 div RadPnts;
          Application.ProcessMessages;
        end;
    end; {for k}
  freemem(x);
  freemem(y);
  freemem(ans);
{**********************************************
  Repeat spline fitting to all ROI radial lines
***********************************************}
{ Dimension arrays and load }
  x := getmem(RadPnts*sizeof(double));
  y := getmem(RadPnts*sizeof(double));
  ans := getmem((BotCrop-TopCrop+1)*sizeof(double));
  dimX := RadPnts-1;
  dimY := RadPnts-1;
  dimAns := BotCrop-TopCrop;
{ Fill x array with actual distance between points }
  for i:= 0 to RadPnts-1 do
    begin
      x[i] := round((BotCrop-TopCrop)*i/(RadPnts-1));
    end;
{ Loop through the columns within the ROI and treat as separate SR maps}
  for k := 0 to nCorPnts-1 do
    begin
      {clear out LongArray}
      for i := 0 to LongArray.Count-1 do
        begin
          P := LongArray.Items[i];
          Dispose(P);
        end;
      LongArray.Clear;
      {load LongArray with next column of ROI}
      for j := 0 to nImages-1 do
        begin
          New(DestVect);
          LongArray.Add(DestVect);
          for i := 1 to RadPnts do
            begin
              SourX := FullArray.Items[j*2*RadPnts + i*2 - 1];
              DestVect^[i] := SourX^[k+1];
            end;
        end;
      Median5x3(RadPnts); {Filter current array}
      {differentiate each column of image }
      for l := 0 to LongArray.Count-1 do
        begin
          P :=  LongArray.Items[l];
          { Differentiate wrt distance and smooth using spline }
          for i := 1 to RadPnts do
            begin
              y[i-1] := P^[i];
              {dy[i] := NoiseEst;}
            end;
          iRet := penspline(x, dimX, y, dimY, ans, dimAns, 1, Mnodes, NLpenal);
          { Save radial direction strain rates to SRA file }
          for i := 0 to RadPnts-1 do
            begin
              Write(SRfile, ans[round((RightCrop-LeftCrop)*i/(nCorPnts-1))]);
            end;
          YProgress.Position := (k+1) * 100 div nCorPnts;
          Application.ProcessMessages;
        end;
    end; {for k}
  CloseFile(SRfile);
  freemem(x);
  freemem(y);
  freemem(ans);
end;
{==============================================================================}
end.

