unit child_form;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, ClipBrd, Math, BGRABitmap, BGRABitmapTypes, Common,
  LCLType, LMessages, Menus, StdCtrls;

type

  { TChildForm }

  TChildForm = class(TForm)
    CalculateButton: TToolButton;
    ChildClient: TScrollBox;
    ChildImage: TImage;
    ChildToolBar: TToolBar;
    MarkedPtValue: TEdit;
    FilterButton: TToolButton;
    InfoButton: TToolButton;
    DullButton: TToolButton;
    BrightButton: TToolButton;
    ChildPopupMenu: TPopupMenu;
    MarkPointMenu: TMenuItem;
    MarkLineMenu: TMenuItem;
    CopyVerticalProfile: TMenuItem;
    CopyHorizontalProfile: TMenuItem;
    CopyLOIProfile: TMenuItem;
    SaveButton: TToolButton;
    ViewSplineFit: TMenuItem;
    MenuSep2: TMenuItem;
    MenuSep1: TMenuItem;
    PublishButton: TToolButton;
    ToolBarSep1: TToolButton;
    ToolBarSep2: TToolButton;
    ToolBarSep3: TToolButton;
    ToolBarSep4: TToolButton;
    ToolButtonSep2: TToolButton;
    ZoomInButton: TToolButton;
    ZoomOutButton: TToolButton;
    ToolButtonSep1: TToolButton;
    procedure BrightButtonClick(Sender: TObject);
    procedure CalculateButtonClick(Sender: TObject);
    procedure ChildClientClick(Sender: TObject);
    procedure ChildImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChildImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CopyHorizontalProfileClick(Sender: TObject);
    procedure CopyLOIProfileClick(Sender: TObject);
    procedure CopyVerticalProfileClick(Sender: TObject);
    procedure DullButtonClick(Sender: TObject);
    procedure FilterButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MarkLineMenuClick(Sender: TObject);
    procedure MarkPointMenuClick(Sender: TObject);
    procedure PublishButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure ViewSplineFitClick(Sender: TObject);
    procedure ZoomInButtonClick(Sender: TObject);
    procedure ZoomOutButtonClick(Sender: TObject);
    procedure InfoButtonClick(Sender: TObject);
  private
    { private declarations }
    MapPict : TBGRABitmap;
    Scale : Real;
    ImageType : TImageType;
    FullArray : Tlist;
    LongArray : Tlist;
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
    TaperDown : boolean;
    MyImgWidth : Integer;
    rPntGap : real;
    WinSize : integer; { moving average filter window size }
    AvgCount : integer;
    SourceFN : string[255];
    rcID : string[12];
    OrgScollBoxWndProc: TWndMethod;
    xCursor : Integer;
    yCursor : Integer;
    xCurOld : Integer;
    yCurOld : Integer;
    procedure ScrollBoxWndMethod(var TheMessage: TLMessage);
    procedure CalcArcLong;
    procedure CalcArcRadial;
    procedure Penalised_map;
    procedure GetXpnts(x : PDouble);
    function  GetStrainRate(col, row, FnFlg : integer) : real;
    procedure SetCaption;
    procedure MyBmpToImage(src : TBGRABitmap);
    procedure DisplayArray(Factor : Integer);
    procedure DisplaySmoothArray(Prompt: boolean);
    procedure Median3x3(RefreshFlag : boolean; ArrWid : integer);
    procedure Median5x3(RefreshFlag : boolean; ArrWid : integer);
    procedure Mean3x3(RefreshFlag : boolean; ArrWid : integer);
    procedure MovingWind(Prompt : boolean);
    procedure MultiplyImage(Factor : Real); { change displayed image contrast by xFactor }
    procedure GetCursorValue(xMouse, yMouse : Integer);
  public
    { public declarations }
    procedure LoadFromFile(FName : string);
    procedure TrackVScroll(NewPos : integer);
    procedure TrackHScroll(NewPos : integer);
    procedure MarkCursor(X, Y : integer);
    procedure MarkLine(X, Y : integer);
  end;

{ Link to DLL containing penalised spline routine from AlgLib }
function penspline(x : PDouble; dimx: integer; y : PDouble; dimy: integer; res: PDouble; dimres, fnflg, M : integer; rho : double) : integer; cdecl; external 'alglib64.dll';

implementation

uses PenalDialog, RectSRDialog, ArcDialog, InfoDialog, SplineGraph, DMapDialog,
  IMapDialog, LMapDialog, BitmapSaver, RealInput;

{$R *.lfm}

procedure TChildForm.FormCreate(Sender: TObject);
begin
  OrgScollBoxWndProc := ChildClient.WindowProc;
  ChildClient.WindowProc := @ScrollBoxWndMethod;
  MapPict := TBGRABitmap.Create(100,100);
  FullArray := TList.Create;
  LongArray := TList.Create;
  Scale := 1.0;
  WinSize := 32; { moving average filter window size }
  TaperDown := false;
end;
{==============================================================================}
procedure TChildForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  PLongScan : ^TLongScan;
  i : integer;
begin
  ChildClient.WindowProc := OrgScollBoxWndProc;
  OrgScollBoxWndProc := nil;
  MapPict.Free;
  for i := 0 to FullArray.Count-1 do
    begin
      PLongScan :=  FullArray.Items[i];
      Dispose(PLongScan);
    end;
  FullArray.Free;
  for i := 0 to LongArray.Count-1 do
    begin
      PLongScan :=  LongArray.Items[i];
      Dispose(PLongScan);
    end;
  LongArray.Free;
  CloseAction := caFree;
end;
{==============================================================================}
procedure TChildForm.ChildClientClick(Sender: TObject);
begin
  ShowOnTop;
end;
{==============================================================================}
procedure TChildForm.MyBmpToImage(src : TBGRABitmap);
{ Copy src bitmap to visible child image with simple scaling }
var
  Stretched : TBGRABitmap;
  i, j, k : integer;
  P, Q : PBGRAPixel;
begin
  // Set TImage dimensions as appropriate
  ChildImage.Height := Round(Scale * src.Height);
  ChildImage.Width := Round(Scale * src.Width);
  ChildImage.Picture.Bitmap.Height := ChildImage.Height;
  ChildImage.Picture.Bitmap.Width := ChildImage.Width;
  // Scale src bitmap
  Stretched := TBGRABitmap.Create(ChildImage.Width, ChildImage.Height);
  for i := 0 to Stretched.Height-1 do
    begin
      P := src.ScanLine[(i * src.Height) div Stretched.Height];
      Q := Stretched.ScanLine[i];
      for j := 0 to Stretched.Width-1 do
        begin
          k := (j * src.Width) div Stretched.Width;
          Q[j].red := P[k].red;
          Q[j].green := P[k].green;
          Q[j].blue := P[k].blue;
          Q[j].alpha := 255;
        end;
    end;
  // Draw to TImage
  Stretched.Draw(ChildImage.Picture.Bitmap.Canvas,0,0,True);
  Stretched.Free;
end;
{==============================================================================}
procedure TChildForm.DisplayArray(Factor : Integer);
{
  Display LongArray as image of coloured dashes with Factor as intensity multiplier

     Strain rates as a yellow/blue image
        yel => shortening
        blu => lengthening

     Displacements as a red/green image
        red => movement tpwards right
        grn => movement to left
}
var
  Row : PBGRAPixel;
  PLongScan : ^TLongScan;
  i, j, k, xorg, xfin, xcol : integer;
  rFactor : real;
begin
  MapPict.SetSize(MyImgWidth, LongArray.Count);
  rFactor := Factor;
  for i := 0 to LongArray.Count-1 do
    begin
      Row := MapPict.ScanLine[i];
      PLongScan :=  LongArray.Items[i];
      for j := 1 to nCorPnts do
        begin
          xCol := abs(round(PLongScan^[j]*rFactor));
          if xCol > 255 then xCol := 255;
          if j = 1 then
            xorg := 0
          else
            xorg := round((j-1.5)*rPntGap);
          if j = nCorPnts then
            xfin := MapPict.Width-1
          else
            xfin := round((j-0.5)*rPntGap);
          if ImageType = StRtRad then {Yellow/Violet type}
            for k := xorg to xfin do
              begin
                if PLongScan^[j] > 0 then
                  begin
                    Row[k].red   := xCol;
                    Row[k].green := 0;
                    Row[k].blue  := xCol;
                  end
                else
                  begin
                    Row[k].red   := xCol;
                    Row[k].green := xCol;
                    Row[k].blue  := 0;
                  end;
              end
          else { must be Red/Green type}
            for k := xorg to xfin do
              begin
                if PLongScan^[j] > 0 then
                  begin
                    Row[k].red   := xCol;
                    Row[k].green := 0;
                  end
                else
                  begin
                    Row[k].red   := 0;
                    Row[k].green := xCol;
                  end;
                Row[k].blue  := 0;
              end;
        end;
    end;
end;
{==============================================================================}
procedure TChildForm.DisplaySmoothArray(Prompt: boolean);
{
    Calculate penalised smoothed spline to strain rate data either from radial data
    of arc-shaped ROI or extracted from SR2 file.
    Set pixels in map image to interpolated strain rate values.
    Prompt user for spline settings if prompted.

    Input:  Strain rate data in LongArray

    Output: Strain rate data in image []
            Map image -255 to 255 correspond to standard or user-specified scale
}
var
  dd : real;
  Row : PBGRAPixel;
  P : ^TLongScan;
  x : PDouble;
  y : PDouble;
  ans : PDouble;
  dimX, dimY, dimAns : integer;
  Nodes : integer;
  Penal : double;
  i, j, jw, l, iRet, xval : integer;
begin
  if Prompt then
    begin
      if PenalDlg.GetData then
        begin
          Nodes := Mnodes;
          Penal := NLpenal;
          MapPict.SetSize(MyImgWidth,LongArray.Count);
          MyBmpToImage(MapPict);
        end
      else exit;
    end
  else
    begin { use standard spline settings if user is not prompted }
      Nodes := 30;
      Penal := 0.2;
    end;
  { Dimension arrays and load }
  x := getmem(nCorPnts*sizeof(double));
  y := getmem(nCorPnts*sizeof(double));
  ans := getmem(MapPict.Width*sizeof(double));
  dimX := nCorPnts-1;
  dimY := nCorPnts-1;
  dimAns := MapPict.Width-1;
  { Fill x array with actual distance between points }
  for i:= 0 to nCorPnts-1 do x[i] := (MapPict.Width-1)*i/(nCorPnts-1);
  { loop for lines of image }
  for l := 0 to LongArray.Count-1 do
    begin
      P :=  LongArray.Items[l];
      Row := MapPict.ScanLine[l];
      for i := 0 to nCorPnts-1 do y[i] := P^[i+1];
      { smooth using spline }
      iRet := penspline(x, dimX, y, dimY, ans, dimAns, 0, Mnodes, NLpenal);
      { Set map image pixels }
      jw := MapPict.Width-1;
      for j := 0 to jw do
        begin
          case ImageType of
            StRtRect, StRtRad:  { standard acale, about +/- 32%/sec }
                begin
                  dd := ans[j];
                  xval := round(dd*4000.0); { scale to make visible }
                end;
            PubRect, PubRad:  { user-specified scale }
                begin
                  dd := ImgFreq*ans[j]; { Scaled to 1/sec }
                  dd := 100.0*dd/KeyStrain; { scale to specified range }
                  { tweak to gamma enhance, if dd >= 0.0 then dd := Power(dd,0.75) else dd := -1.0*Power(abs(dd),0.75);}
                  if KeyGray then
                    xval := round(127.5 - dd*127.5){ -ve => shortening, white }
                  else { must be bicolour }
                    xval := round(dd*255.0);
                end;
          end; {case}
          if KeyGray and ((ImageType = PubRect) or (ImageType = PubRad)) then
            begin
              if xval > 255 then
                xval := 255
              else if xval < 0 then
                xval := 0;
              Row[j].red := xval;
              Row[j].green := xval;
              Row[j].blue := xval;
            end
          else
            begin
              if xval >= 0 then { +ve => lengthening, blue or violet }
                begin
                  if xval > 255 then xval := 255;
                  case ImageType of
                    StRtRect, PubRect: Row[j].red := 0; {blue}
                    else Row[j].red := xval; {violet}
                  end; {case}
                  Row[j].green := 0;
                  Row[j].blue := xval;
                end
              else
                begin
                  xval := abs(xval); { -ve => shortening, yellow }
                  if xval > 255 then xval := 255;
                  Row[j].red := xval;
                  Row[j].green := xval;
                  Row[j].blue := 0;
                end;
            end;
        end; { for each point along line }
    end; { for each line }
  freemem(x);
  freemem(y);
  freemem(ans);
end;
{==============================================================================}
procedure TChildForm.SetCaption;
var
  ScRatio, S : string;
begin
  if Scale < 1.01 then
    begin
      Str(round(1.0/Scale):1, S);
      ScRatio := ' [1:' + S + ']';
    end
  else
    begin
      Str(round(Scale):1, S);
      ScRatio := ' [' + S + ':1]';
    end;
  Caption := ExtractFileName(SourceFN) + rcID + ScRatio;
end;
{==============================================================================}
procedure TChildForm.LoadFromFile(FName : string);
var
  F : file;
  SRfile : file of real;
  FT : TextFile;
  PLongScan : ^TLongScan;
  i, j, nSRImages, basePtr1, basePtr2 : integer;
  r, r1, r2, r3, r4 : real;
  ROItype, s, FExt : string;
  Row : PBGRAPixel;
  buffer : array[0..6000] of byte;
  tagTag, tagType, tagLength, tagValue : integer;
  StripOffset, Offset, nTags : Integer;
  RGBtif, CompTif : boolean;
{======}
  function ShortRead : Integer;
    begin
      BlockRead(F, buffer, 2);
      ShortRead := buffer[0] + buffer[1] * 256;
    end;
{======}
  function LongRead : Integer;
    begin
      BlockRead(F, buffer, 4);
      LongRead := buffer[0] + 256*(buffer[1] + 256*(buffer[2] + (256 * buffer[3])));
    end;
{======}
  procedure ReadTag;
    begin
      tagTag := ShortRead;
      tagType := ShortRead;
      tagLength := LongRead;
      tagValue := LongRead;
    end;
{======}
begin
  rcID := '';
  FExt := LowerCase(ExtractFileExt(FName));
  if (FExt = '.ccd') then { 1D cross correlation data file }
    begin
      ImageType := DispLOI;
      AssignFile(FT, FName);
      Reset(FT);
      Readln(FT, nCorPnts);
      Readln(FT, CCLx, CCLy, CCRx, CCRy);
      MyImgWidth := 1+round(sqrt(sqr(CCLx-CCRx)+sqr(CCLy-CCRy)));
      rPntGap := MyImgWidth/(nCorPnts-1);
      repeat
        New(PLongScan);
        LongArray.Add(PLongScan);
        for i := 1 to nCorPnts-1 do
           read(FT,PLongScan^[i]);
        readln(FT,PLongScan^[nCorPnts]);
      until EOF(FT);
      CloseFile(FT);
      DisplayArray(60);
    end
  else if (FExt = '.arc') then { 2D cross correlation, arc ROI }
    begin
      ArcDlg.GetStrainDir;
      AssignFile(FT, FName);
      Reset(FT);
      Readln(FT, ROItype);
      if StrDir = SRlong then
        ImageType := DispArc
      else
        ImageType := StRtRad;
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
      MyImgWidth  := round(ArcRad*ArcAngle);
      rPntGap := MyImgWidth/(nCorPnts-1);
      repeat { Read raw displacement data from file into FullArray }
        New(PLongScan);
        FullArray.Add(PLongScan);
        for i := 1 to nCorPnts-1 do
           read(FT,PLongScan^[i]);
        readln(FT,PLongScan^[nCorPnts]);
      until EOF(FT);
      CloseFile(FT);
      if ImageType = DispArc then { calculate longitudinal direction }
        begin
          CalcArcLong;
          DisplayArray(60);
        end
      else { else calculate radial direction }
        begin
          CalcArcRadial;
          DisplayArray(4000);
        end;
      for i := 0 to FullArray.Count-1 do { Dispose of raw displacement data }
        begin
          PLongScan :=  FullArray.Items[i];
          Dispose(PLongScan);
        end;
      FullArray.Clear;
    end { arc files }
  else if (FExt = '.sr2') then { 2D strain rate data file }
    begin
      ImageType := StRtRect;
      AssignFile(SRfile, FName);
      Reset(SRfile);
      Read(SRfile, r1, r2, r3, r4);
      {StartImg := round(r1);} nSRImages := round(r2); nCorPnts := round(r3); nPntRows := round(r4);
      Read(SRfile, r1, r2, r3, r4);
      LeftCrop := round(r1); RightCrop := round(r2); TopCrop := round(r3); BotCrop := round(r4);
      if RectSRDlg.GetData(nPntRows, nCorPnts) then
      if true then
        begin
          { set sub-string for caption }
          if RowOrCol = 0 then
            rcID := ' Row '
          else
            rcID := ' Col ';
          str(nRowCol, s);
          rcID := rcID + s;
          case SRdir of
            0:  rcID := rcID + ' H';
            1:  rcID := rcID + ' V';
            2:  rcID := rcID + ' Mx';
          end; {case}
          { get specified data into LongArray }
          basePtr1 := 8;                                { horizonatal SR data }
          basePtr2 := 8 + nSRImages*nPntRows*nCorPnts;  { vertical SR data }
          if RowOrCol = 0 then { read in strain rate data along a row }
            begin
              MyImgWidth := RightCrop - LeftCrop + 1;
              rPntGap := MyImgWidth/(nCorPnts-1);
              for j := 1 to nSRImages do
                begin
                  New(PLongScan);
                  LongArray.Add(PLongScan);
                  for i := 0 to nCorPnts-1 do
                    begin
                      case SRdir of
                      0:  begin
                            seek(SRfile, basePtr1 + nCorPnts*(nRowCol*nSRImages + (j-1)) + i);
                            read(SRfile, r);
                          end;
                      1:  begin
                            seek(SRfile, basePtr2 + nPntRows*(i*nSRImages + (j-1)) + nRowCol);
                            read(SRfile, r);
                          end;
                      2:  begin
                            seek(SRfile, basePtr1 + nCorPnts*(nRowCol*nSRImages + (j-1)) + i);
                            read(SRfile, r1);
                            seek(SRfile, basePtr2 + nPntRows*(i*nSRImages + (j-1)) + nRowCol);
                            read(SRfile, r2);
                            if abs(r1) > abs(r2) then r := r1 else r := r2;
                          end;
                      end; {case}
                      PLongScan^[i+1] := r;
                    end;
                end;
            end
          else  { read in strain rate data along a column }
            begin
              MyImgWidth := BotCrop - TopCrop + 1;
              rPntGap := MyImgWidth/(nPntRows-1);
              for j := 1 to nSRImages do
                begin
                  New(PLongScan);
                  LongArray.Add(PLongScan);
                  for i := 0 to nPntRows-1 do
                    begin
                      case SRdir of
                      0:  begin
                            seek(SRfile, basePtr1 + nCorPnts*(i*nSRImages + (j-1)) + nRowCol);
                            read(SRfile, r);
                          end;
                      1:  begin
                            seek(SRfile, basePtr2 + nPntRows*(nRowCol*nSRImages + (j-1)) + i);
                            read(SRfile, r);
                          end;
                      2:  begin
                            seek(SRfile, basePtr1 + nCorPnts*(i*nSRImages + (j-1)) + nRowCol);
                            read(SRfile, r1);
                            seek(SRfile, basePtr2 + nPntRows*(nRowCol*nSRImages + (j-1)) + i);
                            read(SRfile, r2);
                            if abs(r1) > abs(r2) then r := r1 else r := r2;
                          end;
                      end; {case}
                      PLongScan^[i+1] := r;
                    end;
                end;
              nCorPnts := nPntRows; { only used when reading in a column }
            end;
        end;
      DisplaySmoothArray(true);
    end { sr2 files }
  else if FExt = '.tif' then
    begin
      StripOffset := 8; { Default location of image data }
      AssignFile(F, FName);
      Reset(F, 1);
      BlockRead(F, buffer, 4);
      Offset := LongRead;
      Seek(F, Offset);
      nTags := ShortRead;
      for i := 1 to nTags do
        begin
          ReadTag;
          case tagTag of
            254 : {NewSubfileType} ;
            256 : MapPict.SetSize(tagValue, MapPict.Height);
            257 : MapPict.SetSize(MapPict.Width, tagValue);
            258 : {BPP} ;
            259 : if tagValue = 1 then CompTif := false else CompTif := true;
            262 : if tagValue = 2 then RGBtif := true else RGBtif := false;
            269 : case tagValue of
                    Ord('A') : ImageType := DiaMap;
                    Ord('B') : ImageType := DiaFilt;
                    Ord('C') : ImageType := DispLOI;
                    Ord('D') : ImageType := StRtLOI;
                    Ord('E') : ImageType := MapKey;
                    Ord('F') : ImageType := PubLOI;
                    Ord('G') : ImageType := PubImap;
                    Ord('H') : ImageType := PubDmap;
                    Ord('I') : ImageType := DispArc;
                    Ord('J') : ImageType := StRtArc;
                    Ord('K') : ImageType := StRtRad;
                    Ord('L') : ImageType := StRtRect;
                    Ord('M') : ImageType := PubLArc;
                    Ord('N') : ImageType := PubRad;
                    Ord('O') : ImageType := PubRect;
                  else
                    ImageType := PlainImg;
                  end; {case}
            273 : if tagLength = 1 then
                    StripOffset := tagValue
                  else
                    begin
                      Offset := FilePos(F);
                      Seek(F, tagValue);
                      StripOffset := LongRead;
                      Seek(F, Offset);
                    end;
          end; {case}
        end;
      if CompTif then
        begin
          ImageType := DiaMap;
          MapPict.Canvas.Erase;
          Application.MessageBox('Not able to read compressed TIF files','Message',mb_OK);
        end
      else
        begin
          Seek(F, StripOffset);
          if RGBtif then
            for j := 0 to MapPict.Height-1 do
              begin
                BlockRead(F, buffer, MapPict.Width*3);
                Row := MapPict.ScanLine[j];
                for i := 0 to MapPict.Width-1 do
                  begin
                    Row[i].red := buffer[i*3];
                    Row[i].green := buffer[i*3+1];
                    Row[i].blue := buffer[i*3+2];
                  end;
              end
            else
              for j := 0 to MapPict.Height-1 do
                begin
                  BlockRead(F, buffer, MapPict.Width);
                  Row := MapPict.ScanLine[j];
                  for i := 0 to MapPict.Width-1 do
                    begin
                      Row[i].red := buffer[i];
                      Row[i].green := buffer[i];
                      Row[i].blue := buffer[i];
                    end;
                end;
        end;
      CloseFile(F);
      CalculateButton.Enabled := false;
    end {tif file input}
  else if FExt = '.bmp' then
    begin
      MapPict.LoadFromFile(FName);
      ImageType := DiaMap;
      CalculateButton.Enabled := false;
    end
  else
    Application.MessageBox('Unknown file extension','Error',mb_OK and MB_ICONERROR);
  MyBmpToImage(MapPict);
  Invalidate;
  SourceFN := FName;
  SetCaption;
end;
{==============================================================================}
procedure TChildForm.CalcArcLong;
{
  Calculate tangential displacements along central arc
    On entry : X & Y direction displacements in FullArray
    On exit  : tangential displacements in LongArray with order reversed if necessary
}
var
  i, j, nLines : integer;
  SourX, SourY, DestVect : ^TLongScan;
  r_cx2, r_cy2, delta, beta1, beta2, gamma, hypot1, hypot2, Lcomp1, Lcomp2 : real;
begin
  nLines := FullArray.Count div (2*RadPnts);
  for i := 1 to nLines do
    begin
      SourX := FullArray.Items[(i-1)*2*RadPnts + RadPnts - 1]; {Central arc ?}
      SourY := FullArray.Items[(i-1)*2*RadPnts + RadPnts];
      New(DestVect);
      LongArray.Add(DestVect);
      r_cx2 := SourX^[1]; { Get displacement values for first point }
      r_cy2 := -1.0*SourY^[1];
      if r_cx2 <> 0 then { Get beta, the angle of displacement for first point }
        beta2 := arctan2(r_cy2, r_cx2)
      else if r_cy2 > 0 then
        beta2 := PI/2.0
      else
        beta2 := -1.0*PI/2.0;
      hypot2 := sqrt(sqr(r_cx2)+sqr(r_cy2));
      for j := 2 to nCorPnts do
        begin
          beta1 := beta2;
          hypot1 := hypot2;
          r_cx2 := SourX^[j]; { Get displacement values for current point }
          r_cy2 := -1.0*SourY^[j];
          delta := ArcStart + (j - 1.5) * ArcAngle /(nCorPnts - 1.0); { Get angle of bisecting radial line }
          delta := delta + PI/2.0; { Get angle of tangential }
          if r_cx2 <> 0 then { Get beta, the angle of displacement for next point }
            beta2 := arctan2(r_cy2, r_cx2)
          else if r_cy2 > 0 then
            beta2 := PI/2.0
          else
            beta2 := -1.0*PI/2.0;
          hypot2 := sqrt(sqr(r_cx2)+sqr(r_cy2)); {Get the displacement for next point }
          gamma := beta1 - delta;
          Lcomp1 := hypot1 * cos(gamma); {Get displacement in direction of tangent }
          gamma := beta2 - delta;
          Lcomp2 := hypot2 * cos(gamma);
          if RotRev then  {Save the component of displacement}
            begin
              if j = 2 then
                begin
                  DestVect^[nCorPnts] := Lcomp1;
                  DestVect^[nCorPnts-1] := Lcomp2;
                end
              else
                DestVect^[nCorPnts+1-j] := DestVect^[nCorPnts+2-j] + Lcomp2 - Lcomp1;
            end
          else
            begin
              if j = 2 then
                begin
                  DestVect^[1] := Lcomp1;
                  DestVect^[2] := Lcomp2;
                end
              else
                DestVect^[j] := DestVect^[j-1] + Lcomp2 - Lcomp1;
            end;
        end;
    end;
end;
{==============================================================================}
procedure TChildForm.CalcArcRadial;
{
  Calculate radial strain rates along arc ROI
    On entry : X & Y direction displacements in FullArray
    On exit  : radial strain rates in LongArray with order reversed if necessary
}
var
  i, j, k, l, s, ln, nb, dv, nLines : integer;
  SourX, SourY, DestVect : ^TLongScan;
  r_cx, r_cy, delta, beta, gamma, hypot, BestVal : real;
  MoveMnt : array [0..24] of real; {maximum of 25 radial points}
  Diff : array [0..2, 1..mCorPnts, 0..23] of real;
  bin : array [-2000..2000] of byte;
begin
  nLines := FullArray.Count div (2*RadPnts);
  for i := 1 to nLines+1 do
    begin
      if i <> nLines+1 then {don't update for last line}
      for j := 1 to nCorPnts do
        begin
          delta := ArcStart + (j - 1.0) * ArcAngle /(nCorPnts - 1.0); { Get angle of radial line }
          delta := -1.0 * delta; {correct for image y dimension}
          for k := 0 to RadPnts-1 do { Calculate movement of all points in direction of radial line }
            begin
              SourX := FullArray.Items[(i-1)*2*RadPnts + k*2];
              SourY := FullArray.Items[(i-1)*2*RadPnts + k*2 + 1];
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
              MoveMnt[k] := hypot * cos(gamma);
            end;
          { Differentiate to get the strain rate }
          for k := 0 to RadPnts-2 do Diff[2,j,k] := (MoveMnt[k+1] - MoveMnt[k])/Arc2Arc;
        end; {for j, each point on line}
      { Run median filter for point along line and 3 images }
      if i <> 2 then {skip line 2, made up for with extra line at end}
        begin
          New(DestVect);
          LongArray.Add(DestVect);
          for j := 1 to nCorPnts do
            begin
              if odd(i) then dv := 0 else dv := 1;
              if (i = 1) or (i = (nLines+1))  then
                begin
                  dv := dv + ((RadPnts-1) div 2);
                  ln := 2;
                end
              else
                begin
                  dv := dv + ((3*(RadPnts-1)) div 2);
                  ln := 0;
                end;
              for k := -2000 to 2000 do bin[k]:= 0;
              for l := ln to 2 do
                for k := 0 to RadPnts-2 do
                  begin
                    nb := Round(10000.0*Diff[l,j,k]);
                    if nb < -2000 then nb := -2000
                    else if nb > 2000 then nb := 2000;
                    inc(bin[nb]);
                  end;
              k := -2001;
              s := 0;
              repeat
                inc(k);
                s := s + bin[k];
              until s >= dv;
              BestVal := k/10000.0;
              if RotRev then  {Save the component of displacement}
                DestVect^[nCorPnts+1-j] := BestVal
              else
                DestVect^[j] := BestVal;
            end;
        end;
      {shift buffer}
      for j := 1 to nCorPnts do
        for k := 0 to RadPnts-2 do
          begin
            Diff[0,j,k] := Diff[1,j,k];
            Diff[1,j,k] := Diff[2,j,k];
          end;
    end; {for i, each line}
  AvgCount := 0; {raw unaveraged data}
end;
{==============================================================================}
procedure TChildForm.Median3x3(RefreshFlag : boolean; ArrWid : integer);
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
          else
            begin
              st := -1;
              sp := 1;
              dv := 5;
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
{ Display changes }
  if RefreshFlag then
    begin
      if ImageType = StRtLOI then
        DisplayArray(4000)
      else
        DisplayArray(60);
      MyBmpToImage(MapPict);
      Invalidate;
    end;
end;
{==============================================================================}
procedure TChildForm.Median5x3(RefreshFlag : boolean; ArrWid : integer);
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
{ Display changes }
  if RefreshFlag then
    begin
      if ImageType = StRtLOI then
        DisplayArray(4000)
      else
        DisplayArray(60);
      MyBmpToImage(MapPict);
      Invalidate;
    end;
end;
{==============================================================================}
procedure TChildForm.Mean3x3(RefreshFlag : boolean; ArrWid : integer);
{
  Take mean over radial arched ROI data

    Input:  Strain rate data in LongArray

    Output: Averaged strain rate data in LongArray
}
var
  M, P, Q, R : ^TLongScan;
  i, j, aw : integer;
begin
  inc(AvgCount);
  if ArrWid = 0 then aw := nCorPnts else aw := ArrWid;
{ Insert two new rows at top and simply fill first }
  New(P);
  LongArray.Insert(0, P);
  New(P);
  LongArray.Insert(0, P);
  Q := LongArray.Items[2];
  for i := 1 to aw do P^[i] := Q^[i];
{ Calculate medians }
  for j := 1 to LongArray.Count-4 do
    begin
      M :=  LongArray.Items[j];
      P :=  LongArray.Items[j+1];
      Q :=  LongArray.Items[j+2];
      R :=  LongArray.Items[j+3];
      M^[1] := Q^[1]; M^[aw] := Q^[aw];
      for i := 2 to aw-1 do
        begin
          M^[i] := (P^[i-1]+P^[i]+P^[i+1]+Q^[i-1]+Q^[i]+Q^[i+1]+R^[i-1]+R^[i]+R^[i+1])/9.0;
        end;
    end;
{ Delete two penultimate rows }
  for i := 1 to 2 do
    begin
      P := LongArray.Items[LongArray.Count-2];
      Dispose(P);
      LongArray.Delete(LongArray.Count-2);
    end;
{ Display changes }
  if RefreshFlag then
    begin
      if ImageType = StRtRad then
        DisplaySmoothArray(false)
      else
        DisplayArray(60);
      MyBmpToImage(MapPict);
      Invalidate;
    end;
end;
{==============================================================================}
procedure TChildForm.MovingWind(Prompt : boolean);
{
  Pass a moving average filter over each column of a D, R or I map

    Input:  Unfiltered data in MapPict

    Output: Filtered data in MapPict
}
var
  TmpPict : TBGRABitmap;
  MovWind : array[0..32, 0..2] of integer;
  pix, SumPix : array[0..2] of integer;
  i, iw, ih, half, NextPix : integer;
  P, R : PBGRAPixel;
  tmp : real;
begin
  if Prompt then
    begin
      tmp := WinSize + 1.0;
      if not RealInputDlg.GetReal(tmp, 'Moving average window size') then exit;
      WinSize := round(tmp - 1.0);
    end;
  half := WinSize div 2;
  TmpPict := TBGRABitmap.Create(MapPict.Bitmap.Width, MapPict.Bitmap.Height);
  for iw := 0 to TmpPict.Width-1 do
    begin
      P := MapPict.ScanLine[0];
      pix[0] := p[iw].blue;
      pix[1] := p[iw].green;
      pix[2] := p[iw].red;
      for i := half to WinSize do
        begin
          MovWind[i,0] := pix[0];
          MovWind[i,1] := pix[1];
          MovWind[i,2] := pix[2];
        end;
      for i := 0 to half-1 do
        begin
          P := MapPict.ScanLine[i];
          pix[0] := p[iw].blue;
          pix[1] := p[iw].green;
          pix[2] := p[iw].red;
          MovWind[i,0] := pix[0];
          MovWind[i,1] := pix[1];
          MovWind[i,2] := pix[2];
        end;
      SumPix[0] := 0;
      SumPix[1] := 0;
      SumPix[2] := 0;
      for i := 0 to WinSize do
        begin
          SumPix[0] := SumPix[0] + MovWind[i,0];
          SumPix[1] := SumPix[1] + MovWind[i,1];
          SumPix[2] := SumPix[2] + MovWind[i,2];
        end;
      NextPix := half;
      for ih := 0 to TmpPict.Height-1 do
        begin
          if ih > TmpPict.Height-1-half then
            P := MapPict.ScanLine[TmpPict.Height-1]
          else
            P := MapPict.ScanLine[ih+half];
          pix[0] := p[iw].blue;
          pix[1] := p[iw].green;
          pix[2] := p[iw].red;
          SumPix[0] := SumPix[0] - MovWind[NextPix,0] + pix[0];
          SumPix[1] := SumPix[1] - MovWind[NextPix,1] + pix[1];
          SumPix[2] := SumPix[2] - MovWind[NextPix,2] + pix[2];
          MovWind[NextPix,0] := pix[0];
          MovWind[NextPix,1] := pix[1];
          MovWind[NextPix,2] := pix[2];
          inc(NextPix);
          if NextPix > WinSize then NextPix := 0;
          pix[0] := SumPix[0] div (WinSize+1);
          pix[1] := SumPix[1] div (WinSize+1);
          pix[2] := SumPix[2] div (WinSize+1);
          P := TmpPict.ScanLine[ih];
          P[iw].blue  := pix[0];
          P[iw].green := pix[1];
          P[iw].red   := pix[2];
        end;
    end;
  for ih := 0 to TmpPict.Height-1 do
    begin
      P := TmpPict.ScanLine[ih];
      R := MapPict.ScanLine[ih];
      for iw := 0 to TmpPict.Width-1 do
        begin
          pix[0] := P[iw].blue;
          pix[1] := P[iw].green;
          pix[2] := P[iw].red;
          R[iw].blue  := pix[0];
          R[iw].green := pix[1];
          R[iw].red   := pix[2];
//          R[iw].blue  := 128;
//          R[iw].green := 128;
//          R[iw].red   := 128;
        end;
    end;
  if ImageType = DiaMap then ImageType := DiaFilt;
  TmpPict.Free;
  MyBmpToImage(MapPict);
  Invalidate;
end;
{==============================================================================}
procedure TChildForm.Penalised_map;
{
    Calculate penalised smoothed spline to displacement data and differentiate
    Set pixels in map image to interpolated strain rate

    Input:  Displacement data in LongArray

    Output: Strain rate data in image []
            Map image -255 to 255 correspond to +/-100%/sec
}
var
  dd, reduce : real;
  Row : PBGRAPixel;
  P : ^TLongScan;
  x : PDouble;
  y : PDouble;
  ans : PDouble;
  dimX, dimY, dimAns : integer;
//  x : array of double;
//  y : array of double;
//  ans : array of double;
  i, j, jw, l, iRet, xval : integer;
begin
{ Dimension arrays and load }
{  SetLength(x, nCorPnts);
  SetLength(y, nCorPnts);
  SetLength(ans, MapPict.Width);}
  x := getmem(nCorPnts*sizeof(double));
  y := getmem(nCorPnts*sizeof(double));
  ans := getmem(MapPict.Width*sizeof(double));
  dimX := nCorPnts-1;
  dimY := nCorPnts-1;
  dimAns := MapPict.Width-1;
  GetXpnts(x);
{***************************}
{* loop for lines of image *}
{***************************}
  for l := 0 to LongArray.Count-1 do
    begin
      P :=  LongArray.Items[l];
      Row := MapPict.ScanLine[l];
{ Differentiate wrt distance and smooth using spline }
      for i := 1 to nCorPnts do
        begin
          y[i-1] := P^[i];
//          dy[i] := NoiseEst;
        end;
      iRet := penspline(x, dimX, y, dimY, ans, dimAns, 1, Mnodes, NLpenal);
      jw := MapPict.Width-1;
{ Taper down edges to zero SR to prepare maps for export and simulation }
      if TaperDown then
        begin
          for j := 0 to 120 do
            begin
              reduce := 0.5 - (0.5*cos(Pi*j/120.0));
              ans[j] := ans[j]*reduce;
              ans[jw-j] := ans[jw-j]*reduce;
            end;
        end;
{ Set map image pixels }
      for j := 0 to jw do
        begin
          if (ImageType = StRtLOI) or (ImageType = StRtArc) then {yellow/blue SR map}
            begin
              dd := ans[j];
              xval := round(dd*2048.0); { scale to make visible }
              if xval >= 0 then { +ve => lengthening, blue }
                begin
                  if xval > 255 then xval := 255;
                  Row[j].red := 0;
                  Row[j].green := 0;
                  Row[j].blue := xval;
                end
              else
                begin
                  xval := abs(xval); { -ve => shortening, yellow }
                  if xval > 255 then xval := 255;
                  Row[j].red := xval;
                  Row[j].green := xval;
                  Row[j].blue := 0;
                end;
            end
          else if ((ImageType = PubLOI) or (ImageType = PubLArc)) and (not KeyGray) then {yellow/blue publish SR map}
            begin
              dd := ImgFreq*ans[j]; { Scaled to 1/sec }
              dd := 100.0*dd/KeyStrain; { scale to specified range }
              xval := round(dd*255.0);{ -ve => shortening, white }
              if xval >= 0 then { +ve => lengthening, blue }
                begin
                  if xval > 255 then xval := 255;
                  Row[j].red := 0;
{                  Row[j].red := xval; }{temporary as violet}
                  Row[j].green := 0;
                  Row[j].blue := xval;
                end
              else
                begin
                  xval := abs(xval); { -ve => shortening, yellow }
                  if xval > 255 then xval := 255;
                  Row[j].red := xval;
                  Row[j].green := xval;
                  Row[j].blue := 0;
                end;
            end
          else {must be grayscale publish SR map}
            begin
              dd := ImgFreq*ans[j]; { Scaled to 1/sec }
              dd := 100.0*dd/KeyStrain; { scale to specified range }
              xval := round(127.5 - dd*127.5);{ -ve => shortening, white }
              if xval > 255 then
                xval := 255
              else if xval < 0 then
                xval := 0;
              Row[j].red := xval;
              Row[j].green := xval;
              Row[j].blue := xval;
            end;
        end;
    end;
  freemem(x);
  freemem(y);
  freemem(ans);
//  MapPict.Draw(Image1.Canvas,0,0,True);
  MyBmpToImage(MapPict);
  Invalidate;
end;
{==============================================================================}
procedure TChildForm.GetXpnts(x : PDouble);
var
  delta, beta, CentreX, CentreY : real;
  dd : real;
  i : integer;
begin
  if ImageType = DispLOI then { straight line LOI }
    begin
      { Fill x array with actual distance between points in the direction of straight LOI }
      x[0] := 0.0;
      { Get angle of LOI }
      if (CCRx-CCLx) <> 0 then
        delta := arctan2(CCRy-CCLy, CCRx-CCLx)
      else if (CCRy-CCLy) > 0 then
        delta := PI/2.0
      else
        delta := -1.0*PI/2.0;
      { Get component of point spacing in direction of LOI }
      for i:= 1 to nCorPnts-1 do
        begin
          CentreX := round((CCRx-CCLx)*i/(nCorPnts-1));
          CentreY := round((CCRy-CCLy)*i/(nCorPnts-1));
          if CentreX <> 0 then
            beta := arctan2(CentreY, CentreX)
          else if CentreY > 0 then
            beta := PI/2.0
          else
            beta := -1.0*PI/2.0;
          x[i] := sqrt(sqr(CentreX)+sqr(CentreY))*cos(beta-delta);
        end;
    end
  else { arched LOI }
    begin
      { break arc up into equal chunks }
      dd := MapPict.Bitmap.Width-1; { map width earlier set to length of arc }
      for i := 0 to nCorPnts-1 do x[i] := dd*i/(nCorPnts-1);
    end;
end;
{==============================================================================}
function TChildForm.GetStrainRate(col, row, FnFlg : integer) : real;
{
    Calculate penalised spline to single line of velocity data and differentiate

    Input:  Velocity data in LongArray

    Output: Strain rate data at point (col,row) in [1/delT]
}
var
  P : ^TLongScan;
  x : PDouble;
  y : PDouble;
  ans : PDouble;
  dimX, dimY, dimAns : integer;
  i, iRet : integer;
begin
  { Dimension arrays and load }
  x := getmem(nCorPnts*sizeof(double));
  y := getmem(nCorPnts*sizeof(double));
  ans := getmem(MapPict.Width*sizeof(double));
  dimX := nCorPnts-1;
  dimY := nCorPnts-1;
  dimAns := MapPict.Width-1;
  { load x and y vectors }
  GetXpnts(x);
  P :=  LongArray.Items[row];
  for i := 1 to nCorPnts do
    begin
      y[i-1] := P^[i];
    end;
  { Differentiate wrt distance and smooth using spline }
  iRet := penspline(x, dimX, y, dimY, ans, dimAns, FnFlg, Mnodes, NLpenal);
//tmp  iRet := penspline(x, y, ans, FnFlg, Mnodes, NLpenal);
  { Get appropriate value }
  Result := ans[Col];
  freemem(x);
  freemem(y);
  freemem(ans);
end;
{==============================================================================}
{ Handle user interaction }
{==============================================================================}
procedure TChildForm.ScrollBoxWndMethod(var TheMessage: TLMessage);
begin
  OrgScollBoxWndProc(TheMessage);
  if TheMessage.msg = LM_VSCROLL then
    PostMessage(Application.MainForm.Handle, LM_User + 26, 0, trunc(ChildClient.VertScrollBar.Position/Scale));
  if TheMessage.msg = LM_HSCROLL then
    PostMessage(Application.MainForm.Handle, LM_User + 27, 0, trunc(ChildClient.HorzScrollBar.Position/Scale));
end;
{==============================================================================}
procedure TChildForm.TrackVScroll(NewPos : integer);
begin
 if ChildClient.VertScrollBar.Position <> round(NewPos*Scale) then
   ChildClient.VertScrollBar.Position := round(NewPos*Scale);
end;
{==============================================================================}
procedure TChildForm.TrackHScroll(NewPos : integer);
begin
 if ChildClient.HorzScrollBar.Position <> round(NewPos*Scale) then
   ChildClient.HorzScrollBar.Position := round(NewPos*Scale);
end;
{==============================================================================}
procedure TChildForm.ChildImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  xMouse, yMouse : integer;
begin
  xMouse := trunc(X/Scale);
  yMouse := trunc(Y/Scale);
  GetCursorValue(xMouse, yMouse);
  PostMessage(Application.MainForm.Handle, LM_User + 25, X, Y);
end;
{==============================================================================}
procedure TChildForm.GetCursorValue(xMouse, yMouse : Integer);
var
  s1 : string;
  i : integer;
  v : real;
  P : PBGRAPixel;
  PLongScan : ^TLongScan;
label
  ErrDefault;
begin
  str(xMouse, s1);
  SBarMsg := 'x=' + s1;
  str(yMouse, s1);
  SBarMsg := SBarMsg + ' y=' + s1;
  case ImageType of
    DispLOI, DispArc :
      begin
        PLongScan := LongArray.Items[yMouse];
        i := round(1.0 + xMouse/rPntGap); {calculate dash no. of cursor}
        if i < 1 then i :=1
        else if i > nCorPnts then i := nCorPnts;
        v := PLongScan^[i];
        str(abs(v):6:3, s1);
        SBarMsg := SBarMsg + ' val=' + s1;
        if v < 0 then
          SBarMsg := SBarMsg + ' left'
        else
          SBarMsg := SBarMsg + ' right'
      end;
    StRtRad, PubRad :
      begin
        if (yMouse < 0) or (yMouse >= LongArray.Count) then GoTo ErrDefault;
        PLongScan := LongArray.Items[yMouse];
        if AvgCount = 0 then {unfiltered dashed map}
          begin
            i := round(1.0 + xMouse/rPntGap); {calculate dash number of cursor}
            if i < 1 then i := 1
            else if i > nCorPnts then i := nCorPnts;
            v := PLongScan^[i]*100.0;
            str(v:7:2, s1);
            SBarMsg := SBarMsg + ' val=' + s1 + ' %/delT';
          end
        else if ImageType = StRtRad then {filtered, spline-smoothed map}
          begin
            v := GetStrainRate(xMouse, yMouse, 0)*100.0;
            str(v:7:2, s1);
            SBarMsg := SBarMsg + ' val=' + s1 + ' %/delT';
          end
        else {filtered, spline-smoothed published map}
          begin
            v := ImgFreq*GetStrainRate(xMouse, yMouse, 0)*100.0;
            str(v:7:2, s1);
            SBarMsg := SBarMsg + ' val=' + s1 + ' %/s';
          end;
      end;
    StRtLOI, StRtArc :
      begin
        v := GetStrainRate(xMouse, yMouse, 1)*100.0;
        str(v:7:2, s1);
        SBarMsg := SBarMsg + ' val=' + s1 + ' %/delT';
      end;
    PubLOI, PubLArc :
      begin
        v := ImgFreq*GetStrainRate(xMouse, yMouse, 1)*100.0;
        str(v:7:2, s1);
        SBarMsg := SBarMsg + ' val=' + s1 + ' %/s';
      end;
    PubDmap :
      begin
        try
          P := MapPict.ScanLine[yMouse];
          i := P[xMouse].red;
        except
          i := 0;
        end;
        v := KeyMin + (KeyMax-KeyMin)*(255-i)/255.0;
        str(v:7:2, s1);
        SBarMsg := SBarMsg + ' val=' + s1 + ' mm';
      end;
    else
      begin
        try
          P := MapPict.ScanLine[yMouse];
          i := P[xMouse].red;
        except
          i := 0;
        end;
        str(i, s1);
        SBarMsg := SBarMsg + ' val=' + s1 + ' iu';
      end;
  end; {case}
  exit;
{===}
ErrDefault:
  try
    P := MapPict.ScanLine[yMouse];
    i := P[xMouse].red;
  except
    i := 0;
  end;
  str(i, s1);
  SBarMsg := SBarMsg + ' val=' + s1 + ' iu';
end;
{==============================================================================}
procedure TChildForm.FilterButtonClick(Sender: TObject);
begin
  case ImageType of
    DispLOI, DispArc : Median5x3(true, 0);
    StRtRad : Mean3x3(true, 0);
    DiaMap, DiaFilt, PlainImg, PubImap : MovingWind(true);
  end;
end;
{==============================================================================}
procedure TChildForm.CalculateButtonClick(Sender: TObject);
{
  change either straight or arched LOI displacement map to strain rate map
}
begin
  if PenalDlg.GetData then
    begin
      if ImageType = DispLOI then
        ImageType := StRtLOI
      else
        ImageType := StRtArc;
      Penalised_map;
    end;
end;
{==============================================================================}
procedure TChildForm.PublishButtonClick(Sender: TObject);
{
  Prepare a publishable map and associated key
}
var
  i, j, px : integer;
  P : PBGRAPixel;
  OldImageType : TImageType;
begin
  case ImageType of
    DiaMap, DiaFilt, PubDmap : {*** D & R maps }
      if DMapDlg.GetData then
        begin
          { Reload original image and change intensity to specified scaling }
          OldImageType := ImageType;
          LoadFromFile(SourceFN);
          if OldImageType = DiaFilt then MovingWind(false);
          for j := 0 to MapPict.Height-1 do
            for i := 0 to MapPict.Width-1 do
              begin
                P := MapPict.ScanLine[j];
                px := 255 - trunc((((255-P[i].red)/PixMM)-KeyMin)*255.0/KeyMax);
                if (px > 255) then px := 255;
                if (px < 0) then px := 0;
                P[i].red := px;
                P[i].green := px;
                P[i].blue := px;
              end;
          ImageType := PubDmap;
          MyBmpToImage(MapPict);
          Invalidate;
          PostMessage(Application.MainForm.Handle, LM_User + 30, ord('D'), 0);
        end;
    DispLOI, StRtLOI, StRtArc, PubLOI, PubLArc : {*** 1D Lmap or longitudinal SR map from 2D arc ROI }
      if LMapDlg.GetData then
        begin
          { Change strain rate map to specified publishable map }
          if PenalDlg.GetData then
            begin
              case ImageType of
                DispLOI, StRtLOI : ImageType := PubLOI;
                StRtArc : ImageType := PubLArc;
              end; {case}
              Penalised_map;
              PostMessage(Application.MainForm.Handle, LM_User + 30, ord('L'), 0);
            end;
        end;
    StRtRad, PubRad : {*** Radial SR map from 2D arc ROI }
      if LMapDlg.GetData then
        begin
          { Change strain rate map to requested grayscale or yellow/violet }
          ImageType := PubRad;
          DisplaySmoothArray(false);
          MyBmpToImage(MapPict);
          Invalidate;
          PostMessage(Application.MainForm.Handle, LM_User + 30, ord('S'), 0);
        end;
    StRtRect, PubRect : {*** SR map extracted from 2D rect ROI }
      if LMapDlg.GetData then
        begin
          { Change extracted yellow/blue strain rate map to specified without recalculating differentials }
          ImageType := PubRect;
          DisplaySmoothArray(true);
          MyBmpToImage(MapPict);
          Invalidate;
          PostMessage(Application.MainForm.Handle, LM_User + 30, ord('S'), 0);
        end;
    PlainImg, PubImap : {*** Intensity maps }
      if IMapDlg.GetData then
        begin
          ImageType := PubImap;
          PostMessage(Application.MainForm.Handle, LM_User + 30, ord('I'), 0);
        end;
  end; {case}
end;

procedure TChildForm.SaveButtonClick(Sender: TObject);
begin
  BmpSaveForm.SaveToTiff(MapPict, ImageType);
end;
{==============================================================================}
procedure TChildForm.ZoomInButtonClick(Sender: TObject);
begin
if Scale < 4.01 then
  begin
    Scale := 2.0 * Scale;
    MyBmpToImage(MapPict);
//    if Scale < 1.01 then ClientWidth := ChildImage.Width;
    SetCaption;
    Invalidate;
  end;
end;
{==============================================================================}
procedure TChildForm.ZoomOutButtonClick(Sender: TObject);
begin
  Scale := 0.5 * Scale;
  MyBmpToImage(MapPict);
//  if ChildImage.Width < ClientWidth then ClientWidth := ChildImage.Width;
  SetCaption;
  Invalidate;
end;
{==============================================================================}
procedure TChildForm.DullButtonClick(Sender: TObject);
begin
  MultiplyImage(2.0/3.0);
end;
{==============================================================================}
procedure TChildForm.BrightButtonClick(Sender: TObject);
begin
  MultiplyImage(1.5);
end;
{==============================================================================}
procedure TChildForm.MultiplyImage(Factor : Real);
var
  i, j, px, px1, px2, px3 : integer;
  P : PBGRAPixel;
begin
  for j := 0 to MapPict.Height-1 do
    begin
    P := MapPict.ScanLine[j];
    for i := 0 to MapPict.Width-1 do
      begin
        if ImageType = DiaFilt then
          begin
            px := 128 + trunc((P[i].red-128)*Factor);
            if (px > 255) then px := 255;
            if (px < 0) then px := 0;
            P[i].red := px;
            P[i].green := px;
            P[i].blue := px;
          end
        else if ImageType = DiaMap then
          begin
            px := trunc(P[i].red*Factor);
            if (px > 255) then px := 255;
            if (px < 0) then px := 0;
            P[i].red := px;
            P[i].green := px;
            P[i].blue := px;
          end
        else
          begin
            px1 := trunc(P[i].red*Factor);
            px2 := trunc(P[i].green*Factor);
            px3 := trunc(P[i].blue*Factor);
            if (px1 > 255) then px1 := 255;
            if (px2 > 255) then px2 := 255;
            if (px3 > 255) then px3 := 255;
            if (px1 < 0) then px1 := 0;
            if (px2 < 0) then px2 := 0;
            if (px3 < 0) then px3 := 0;
            P[i].red := px1;
            P[i].green := px2;
            P[i].blue := px3;
          end;
      end;
    end;
  MyBmpToImage(MapPict);
  Invalidate;
end;
{==============================================================================}
procedure TChildForm.InfoButtonClick(Sender: TObject);
begin
  InfoDlg.ShowInformation(SourceFN, ImageType, MapPict.Width, MapPict.Height);
end;
{==============================================================================}
{ Handlers for popup menu commands }
{==============================================================================}
procedure TChildForm.ChildImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbRight then
    begin
      xCursor := trunc(X/Scale); // Scale to MapPict cordinates
      yCursor := trunc(Y/Scale);
      ChildPopupMenu.Popup;
    end;
end;
{==============================================================================}
procedure TChildForm.MarkPointMenuClick(Sender: TObject);
begin
  if ScrollLocked then
    { Send message so that cursor location is marked on all child windows }
    PostMessage(Application.MainForm.Handle, LM_User + 28, xCursor, yCursor)
  else
    { Otherwise just mark current window }
    MarkCursor(xCursor, yCursor);
end;
{==============================================================================}
procedure TChildForm.MarkCursor(X, Y : integer);
var
  xp, yp : integer;
begin
  xCurOld := X; // Remember values relative to position in MapPict
  yCurOld := Y;
  xp := round(X * Scale); // Change back to ChildImage position
  yp := round(Y * Scale);
  ChildImage.Canvas.Pen.Color := clLime; // Draw cross at cursor position
  ChildImage.Canvas.MoveTo(xp-10,yp);
  ChildImage.Canvas.LineTo(xp+10,yp);
  ChildImage.Canvas.MoveTo(xp,yp-10);
  ChildImage.Canvas.LineTo(xp,yp+10);
  GetCursorValue(X, Y);
  MarkedPtValue.Text := SBarMsg; { Write cursor location and value to status bar }
end;
{==============================================================================}
procedure TChildForm.MarkLineMenuClick(Sender: TObject);
var
  Slope : real;
  s : string;
begin
  if ScrollLocked then
    { Send message so that line is marked on all child windows }
    PostMessage(Application.MainForm.Handle, LM_User + 29, xCursor, yCursor)
  else
    { Otherwise just mark line on current window }
    MarkLine(xCursor, yCursor);
  {  Write slope to status bar on current window }
  if yCursor = yCurOld then
    MarkedPtValue.Text := 'Horizontal line'
  else
    begin
      Slope := (xCursor-xCurOld)/(yCursor-yCurOld);
      case ImageType of
        PubDmap, PubLOI, PubLArc, PubRad, PubRect, PubImap :
          begin
            Slope := Slope*ImgFreq/PixMM;
            Str(Slope:8:3, s);
            s := s + ' mm/s';
          end;
      else
        begin
          Str(Slope:8:3, s);
          s := s + ' pixels/time interval';
        end;
      end; {case}
      MarkedPtValue.Text := s; { Write line slope to status bar }
    end;
end;
{==============================================================================}
procedure TChildForm.MarkLine(X, Y : integer);
var
  xp, yp, xpo, ypo : integer;
begin
  xp := round(X * Scale); // Change back to ChildImage position
  yp := round(Y * Scale);
  xpo := round(xCurOld * Scale);
  ypo := round(yCurOld * Scale);
  ChildImage.Canvas.Pen.Color := clLime; // Draw cross at end position
  ChildImage.Canvas.MoveTo(xp-10,yp);
  ChildImage.Canvas.LineTo(xp+10,yp);
  ChildImage.Canvas.MoveTo(xp,yp-10);
  ChildImage.Canvas.LineTo(xp,yp+10);
  ChildImage.Canvas.MoveTo(xpo,ypo); // Draw line between two points
  ChildImage.Canvas.LineTo(xp,yp);
end;
{==============================================================================}
procedure TChildForm.CopyVerticalProfileClick(Sender: TObject);
{
  Copy values of vertical line to the clipboard
}
var
  S, S1 : string;
  i, j : integer;
  v : real;
  P : PBGRAPixel;
  PLongScan : ^TLongScan;
begin
  S := '';
  case ImageType of
    DispLOI :
      begin
        j := round(1.0 + xCursor/rPntGap);
        if j < 1 then j :=1
        else if j > nCorPnts then j := nCorPnts;
        for i := 0 to MapPict.Height-1 do
          begin
            PLongScan := LongArray.Items[i];
            v := PLongScan^[j];
            str(v:6:3, S1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    StRtLOI :
      begin
        for i := 0 to MapPict.Height-1 do
          begin
            v := GetStrainRate(xCursor, i, 1)*100.0;
            str(v:7:2, S1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    PubLOI, PubLArc :
      begin
        for i := 0 to MapPict.Height-1 do
          begin
            v := ImgFreq*GetStrainRate(xCursor, i, 1)*100.0;
            str(v:7:2, S1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    StRtRad, PubRad :
      begin
        for i := 0 to MapPict.Height-1 do
          begin
            PLongScan := LongArray.Items[i];
            if AvgCount = 0 then {unfiltered dashed map}
              begin
                j := round(1.0 + xCursor/rPntGap); {calculate dash number of cursor}
                if j < 1 then j := 1
                else if j > nCorPnts then j := nCorPnts;
                v := PLongScan^[j]*100.0;
                str(v:7:2, s1);
                S := S + S1 + chr(13)+ chr(10);
    //            SBarMsg := SBarMsg + ' val=' + s1 + ' %/delT';
              end
            else if ImageType = StRtRad then {filtered, spline-smoothed map}
              begin
                v := GetStrainRate(xCursor, i, 0)*100.0;
                str(v:7:2, s1);
                S := S + S1 + chr(13)+ chr(10);
    //            SBarMsg := SBarMsg + ' val=' + s1 + ' %/delT';
              end
            else {filtered, spline-smoothed published map}
              begin
                v := ImgFreq*GetStrainRate(xCursor, i, 0)*100.0;
                str(v:7:2, s1);
                S := S + S1 + chr(13)+ chr(10);
    //            SBarMsg := SBarMsg + ' val=' + s1 + ' %/s';
              end;
          end;
      end;
    PubDmap :
      begin
        for i := 0 to MapPict.Height-1 do
          begin
            P := MapPict.ScanLine[i];
            v := KeyMin + (KeyMax-KeyMin)*(255-P[xCursor].red)/255.0;
            str(v:7:2, s1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    else
      begin
        for i := 0 to MapPict.Height-1 do
          begin
            P := MapPict.ScanLine[i];
            j := P[xCursor].red;
            str(j:4, s1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
  end; {case}
  Clipboard.AsText := S;
end;
{==============================================================================}
procedure TChildForm.CopyHorizontalProfileClick(Sender: TObject);
{
  Copy values of horizontal line to the clipboard
}
var
  S, S1 : string;
  i, j : integer;
  v : real;
  P : PBGRAPixel;
  PLongScan : ^TLongScan;
begin
  S := '';
  case ImageType of
    DispLOI :
      begin
        PLongScan := LongArray.Items[yCursor];
        for i := 1 to nCorPnts do
          begin
            v := PLongScan^[i];
            str(v:6:3, S1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    StRtLOI :
      begin
        for j := 0 to MapPict.Width-1 do
          begin
            v := GetStrainRate(j, yCursor, 1)*100.0;
            str(v:7:2, S1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    PubLOI :
      begin
        for j := 0 to MapPict.Width-1 do
          begin
            v := ImgFreq*GetStrainRate(j, yCursor, 1)*100.0;
            str(v:7:2, S1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    PubDmap :
      begin
        P   := MapPict.ScanLine[yCursor];
        for i := 0 to MapPict.Width-1 do
          begin
            v := KeyMin + (KeyMax-KeyMin)*(255-P[i].red)/255.0;
            str(v:7:2, s1);
            S := S + S1 + chr(13)+ chr(10);
          end;
      end;
    else
      begin
          begin
            P := MapPict.ScanLine[yCursor];
            for i := 0 to MapPict.Width-1 do
              begin
                j := P[i].red;
                str(j:4, s1);
                S := S + S1 + chr(13)+ chr(10);
              end;
          end;
      end;
  end; {case}
  Clipboard.AsText := S;
end;
{==============================================================================}
procedure TChildForm.CopyLOIProfileClick(Sender: TObject);
{
  Copy values of angled LOI to the clipboard
}
var
  S, S1 : string;
  i, j, k, pxR, pxG, pxB : integer;
  P : PBGRAPixel;
  px : real;
begin
  s := '';
  if abs(yCursor-yCurOld) >= abs(xCursor-xCurOld) then
    for i := 0 to abs(yCursor-yCurOld) do
      begin
        if yCurOld < yCursor then
          j := yCurOld + i
        else
          j := yCurOld - i;
        k := xCurOld + round(i*(xCursor-xCurOld)/(yCursor-yCurOld));
        P := MapPict.ScanLine[j];
        if ImageType = DiaFilt then
          px := P[k].red - 128
        else if ImageType = DiaMap then
          px := P[k].red
        else if ImageType = PubDmap then
          px := KeyMin + (KeyMax-KeyMin)*(255.0-P[k].red)/255.0
        else
          begin
            pxR := P[k].red;
            pxG := P[k].green;
            pxB := P[k].blue;
            if ImageType = DispLOI then
              px := pxR - pxG
            else if ImageType = StRtLOI then
              px := pxB - pxR
            else if ImageType = PubLOI then
              px := (127.5-pxR)* KeyStrain /127.5
            else
              px := pxR;
          end;
        Str(px:7:2,S1);
        S := S + S1 + chr(13)+ chr(10);
      end
  else
    for i := 0 to abs(xCursor-xCurOld) do
      begin
        if xCurOld < xCursor then
          k := xCurOld + i
        else
          k := xCurOld - i;
        j := yCurOld + round(i*(yCursor-yCurOld)/(xCursor-xCurOld));
        P := MapPict.ScanLine[j];
        if ImageType = DiaFilt then
          px := P[k].red - 128
        else if ImageType = DiaMap then
          px := P[k].red
        else if ImageType = PubDmap then
          px := KeyMin + (KeyMax-KeyMin)*(255.0-P[k].red)/255.0
        else
          begin
            pxR := P[k].red;
            pxG := P[k].green;
            pxB := P[k].blue;
            if ImageType = DispLOI then
              px := pxR - pxG
            else if ImageType = StRtLOI then
              px := pxB - pxR
            else if ImageType = PubLOI then
              px := (127.5-pxR)* KeyStrain /127.5
            else
              px := pxR;
          end;
        Str(px:7:2,S1);
        S := S + S1 + chr(13)+ chr(10);
      end;
  Clipboard.AsText := S;
end;
{==============================================================================}
procedure TChildForm.ViewSplineFitClick(Sender: TObject);
{
  Display dialog window with graph of raw, smoothed and differentiated data
}
var
  i, iRet : integer;
  x : PDouble;
  y : PDouble;
  ans : PDouble;
  dimX, dimY, dimAns : integer;
  displ, srate : array of real;
  P : ^TLongScan;
  yp : integer;
begin
  case ImageType of DispLOI, StRtLOI, PubLOI, DispArc, StRtArc, PubLArc:
    begin
      { draw reference line accross image }
      yp := round(YCursor * Scale); // Change back to ChildImage position
      ChildImage.Canvas.Brush.Style := bsClear; // Draw horizontal line
      ChildImage.Canvas.Pen.Color := clLime;
      ChildImage.Canvas.Pen.Style := psDot;
      ChildImage.Canvas.MoveTo(0,yp);
      ChildImage.Canvas.LineTo(ChildImage.Canvas.Width-1 ,yp);
      ChildImage.Canvas.Pen.Style := psSolid;
      { set up vectors to hold data and results }
      x := getmem(nCorPnts*sizeof(double));
      y := getmem(nCorPnts*sizeof(double));
      ans := getmem(MapPict.Width*sizeof(double));
      dimX := nCorPnts-1;
      dimY := nCorPnts-1;
      dimAns := MapPict.Width-1;
      SetLength(displ, MapPict.Bitmap.Width);
      SetLength(srate, MapPict.Bitmap.Width);
      { load x and y vectors }
      GetXpnts(x);
      P :=  LongArray.Items[yCursor];
      for i := 0 to nCorPnts-1 do y[i] := P^[i+1];
      { fit spline }
      iRet := penspline(x, dimX, y, dimY, ans, dimAns, 0, Mnodes, NLpenal);
      for i := 0 to MapPict.Bitmap.Width-1 do
        begin
          displ[i] := ans[i]; { get spline function }
        end;
      iRet := penspline(x, dimX, y, dimY, ans, dimAns, 1, Mnodes, NLpenal);
      for i := 0 to MapPict.Bitmap.Width-1 do
        begin
          srate[i] := ans[i]; { get spline 1st derivative }
        end;
      SplineGraphDlg.LoadData(x, y, nCorPnts, displ, srate);
      SplineGraphDlg.ShowOK;
      freemem(x);
      freemem(y);
      freemem(ans);
    end;
  end; {case}
end;
{==============================================================================}
end.

