unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Menus, StdCtrls, Buttons, ExtCtrls, BGRABitmap, BGRABitmapTypes,
  pngimage, UserPrompt, ABOUT, UserDialog, ThreshDialog,
  ThreshGraph, CCrossDialog, GraphType, ComCtrls, Math, Crt;

type

  { TForm1 }

  TForm1 = class(TForm)
    AddMask: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenFirst1: TMenuItem;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    Save1: TMenuItem;
    N2: TMenuItem;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    OpenDialog2: TOpenDialog;
    Generate1: TMenuItem;
    MapAlongLine1: TMenuItem;
    UserInput: TMenuItem;
    Setcroplimits1: TMenuItem;
    All1: TMenuItem;
    N5: TMenuItem;
    op1: TMenuItem;
    Bottom1: TMenuItem;
    Left1: TMenuItem;
    Right1: TMenuItem;
    ClearLimits1: TMenuItem;
    DiameterMap1: TMenuItem;
    DiameterandLongitudinalMap1: TMenuItem;
    N6: TMenuItem;
    UpperRadialMap1: TMenuItem;
    LowerRadialMap1: TMenuItem;
    N7: TMenuItem;
    MapLineIntensity1: TMenuItem;
    N8: TMenuItem;
    SetAnchorPoints1: TMenuItem;
    N9: TMenuItem;
    ManualInput1: TMenuItem;
    DMapandFixedLMap1: TMenuItem;
    Edit2: TEdit;
    Button2: TButton;
    N3: TMenuItem;
    ThresholdGraph1: TMenuItem;
    N10: TMenuItem;
    RedrawImage1: TMenuItem;
    N11: TMenuItem;
    FollowSinglePoint1: TMenuItem;
    CorrelationAdjust1: TMenuItem;
    SaveAnnotatedSequence1: TMenuItem;
    StopAnnotatedSequence1: TMenuItem;
    SetArcAnchorPoints1: TMenuItem;
    Generate2D1: TMenuItem;
    ArcROI1: TMenuItem;
    RectangularROIMap1: TMenuItem;
    TrackBar1: TTrackBar;
    Label6: TLabel;
    ImportInputs1: TMenuItem;
    AverageIntensityMap1: TMenuItem;
    AnchorPointShift1: TMenuItem;
    procedure AddMaskClick(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenFirst1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Point1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
{    procedure PlotPressures1Click(Sender: TObject);}
{    procedure LoadMap1Click(Sender: TObject);}
{    procedure BoostContrast1Click(Sender: TObject);}
    procedure Button1Click(Sender: TObject);
    procedure SetRange1Click(Sender: TObject);
    procedure DiameterOnly1Click(Sender: TObject);
    procedure DiameterAxial1Click(Sender: TObject);
    procedure MapAlongLine1Click(Sender: TObject);
    procedure CropAllClick(Sender: TObject);
    procedure CropTopClick(Sender: TObject);
    procedure CropBottomClick(Sender: TObject);
    procedure CropLeftClick(Sender: TObject);
    procedure CropRightClick(Sender: TObject);
    procedure CropClearClick(Sender: TObject);
    procedure MapLineIntensity1Click(Sender: TObject);
    procedure SetAnchorPoints1Click(Sender: TObject);
    procedure SetArcAnchorPoints1Click(Sender: TObject);
    procedure ManualInput1Click(Sender: TObject);
    procedure UpperRadialMap1Click(Sender: TObject);
    procedure LowerRadialMap1Click(Sender: TObject);
    procedure DMapandFixedLMap1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ThresholdGraph1Click(Sender: TObject);
    procedure RedrawImage1Click(Sender: TObject);
    procedure CorrelationAdjust1Click(Sender: TObject);
    procedure SaveAnnotatedSequence1Click(Sender: TObject);
    procedure StopAnnotatedSequence1Click(Sender: TObject);
    procedure ArcROI1Click(Sender: TObject);
    procedure RectangularROIMap1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure ImportInputs1Click(Sender: TObject);
    procedure AverageIntensityMap1Click(Sender: TObject);
    procedure AnchorPointShift1Click(Sender: TObject);
  private
    { Private declarations }
    CCflag : Boolean;
    HaltGeneration : Boolean;
    nImages : Integer;
    nCorPnts : Integer;
    nPntRows : Integer;
    PntGap : Integer;
    procedure GenerateMap;
    function LoadImgFile(FileNum : integer) : boolean;
    function CurrentFileExists(FileNum : integer) : boolean;
    procedure DumpImage(DumpFN : string);
    procedure CalcArcParams;
    procedure SinglePointCC;
    procedure AutoThreshold;
    procedure HorizontalMap;
    procedure UpdateLabels(ImNo: integer);
    procedure AvgIntMap;
    procedure CC2PointsMap;
    procedure CC2DimMap;
    procedure MyRedraw;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses {ABOUT, SpatialMap, UserPrompt, IntegerInput,} STMap,
  LongMapFm, Common {, tpmath, UserDialog, ThreshGraph, ThreshDialog},
  ap, minasa, spline2d{, CCrossDialog};

{==============================================================================}

type
	TStatus  = (None, CropT, CropB, CropL, CropR, CCarc1, CCarc2, CCarc3,
              DirCen, Pylor1, Pylor2, TrackPt, CCleft, CCright);
  TMapping = (HTube, GenLOI, AvgInt, Arc2D, Rect2D);
  TRadius  = (FullRad, TopRad, BotRad);

var
  BaseName, CurrentFileName : string;
  cx, cy : integer;
  r_cx, r_cy : Real;
  CurImage, NextImage, TimerInt, skip : integer;
  WaitStatus : TStatus;
  ReqMap : TMapping;
  RadTyp : TRadius;
  AllFlag, FixedFlag, GrayImages : Boolean;
  RotRev : string[1];
  LongPict: TPicture;
  rawPNGimage, PNGmap : TPngObject;
  RotCenX, RotCenY, ArcRad, ArcStart, ArcAngle : Real; {Arced ROI parameters}
  LongArray : Tlist;
  ImgExt : string[4]; {Image sequence file extension}
  FNcharsNum : integer; {Number of characters in image sequence number convention}
  Masked : boolean;
  MaskArray: array of array of byte; { custom mask from file }
{$R *.lfm}

{==============================================================================}
procedure TForm1.FormCreate(Sender: TObject);
begin
  rawPNGimage := TPngObject.CreateBlank(COLOR_GRAYSCALE, 8, 10, 10);
  PNGmap := TPngObject.CreateBlank(COLOR_GRAYSCALE, 8, 10, 10);
  LongPict := TPicture.Create;
  LongArray := TList.Create;
  CorWindow := 20;
  HalfWin := CorWindow div 2;
  WinSize := (CorWindow+1) * (CorWindow+1);
  nSearch := 10;
  ScanSize := CorWindow + (2 * nSearch);
  FloatSts := Middle;
  WaitStatus := None;
  SaveAnnot := false;
  RadPnts := 5;  { number of concentric arcs }
  RadGap := 0.75; { number of CorWindows }
  NextImage := 1;
  TimerInt := 200;
  Masked := false;
end;
{==============================================================================}
procedure TForm1.FileExit1Execute(Sender: TObject);
begin
  rawPNGimage.Free;
  PNGmap.Free;
  LongPict.Free;
  LongArray.Free;
  Close;
end;
{==============================================================================}
procedure TForm1.AddMaskClick(Sender: TObject);
var
  F : TextFile;
  i, j, Err : Integer;
  S, S1 : string;
  c : array[0..511] of char;
  p : Pchar;
  PNG : TPngObject;
  SrcB : pByteArray;
begin
  OpenDialog.FileName := '';
  OpenDialog.Filter := 'Mask Files (*.png)|*.png';
  if OpenDialog.Execute and FileExistsUTF8(OpenDialog.FileName) then
    begin
      try
        PNG := TPngObject.Create;
        PNG.LoadFromFile(OpenDialog.FileName);
        SetLength(MaskArray, PNG.Width, PNG.Height);
        if PNG.Header.BitDepth = 8 then
          begin
            for j := 0 to PNG.Height-1 do
              begin
                SrcB := PNG.Scanline[j];
                for i := 0 to PNG.Width-1 do
                  begin
                    MaskArray[i,j] := SrcB^[i];
                   end;
               end;
            Masked := true;
          end;
      finally
        PNG.Free;
      end; {try}
    end; {if exists}
  Application.ProcessMessages;
  MyRedraw;
end;
{==============================================================================}
procedure TForm1.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;
{==============================================================================}
procedure TForm1.ImportInputs1Click(Sender: TObject);
var
  FT : TextFile;
  n_1, n_2, n_3 : Integer;
  r1 : Real;
  s1 : String;
begin
  OpenDialog.Filter := 'Output files|*.ccd;*.arc;*.rct';
  if OpenDialog.Execute then
    begin
      AssignFile(FT, OpenDialog.Filename);
      Reset(FT);
      if (ExtractFileExt(OpenDialog.Filename) = '.ccd') then { 1D cross correlation data file }
        begin
          Readln(FT, n_1);
          Readln(FT, CCLx, CCLy, CCRx, CCRy);
        end
      else if (ExtractFileExt(OpenDialog.Filename) = '.arc') then { 2D cross correlation, arc ROI }
        begin
          Readln(FT, s1);
          Readln(FT, n_1, n_2, n_3, r1);
          Readln(FT, CCLx, CCLy, CCMx, CCMy, CCRx, CCRy);
          CalcArcParams;
        end
	    else if (ExtractFileExt(OpenDialog.Filename) = '.rct') then { 2D cross correlation, rectangular ROI }
        begin
          Readln(FT, s1);
          Readln(FT, n_1, n_2, n_3);
          Readln(FT, LeftCrop, RightCrop, TopCrop, BotCrop);
        end;
      CloseFile(FT);
      MyRedraw;
    end;
end;
{==============================================================================}
function TForm1.LoadImgFile(FileNum : integer) : boolean;
{
    Load numbered image file into grayscale PNG bitmap called "rawPNGimage"
    Returns true if file exists
}
var
  F: file;
  tagTag, tagType, tagLength, tagValue : integer;
  i, j : integer;
  StripOffset, Offset, nTags : Integer;
  P, Q : PByteArray;
  buffer : array[0..6000] of byte;
  m_Width, m_Height, m_RowBytes, m_PixelFormat : integer;
  pBuffer, pData : PByte;
  TmpBGRABmp : TBGRABitmap;
  Row : PBGRAPixel;
{===}
function ShortRead : Integer;
begin
  BlockRead(F, buffer, 2);
  ShortRead := buffer[0] + buffer[1] * 256;
end;
{===}
function LongRead : Integer;
begin
  BlockRead(F, buffer, 4);
  LongRead := buffer[0] + 256*(buffer[1] + 256*(buffer[2] + (256 * buffer[3])));
end;
{===}
procedure ReadTag;
begin
  tagTag := ShortRead;
  tagType := ShortRead;
  tagLength := LongRead;
  tagValue := LongRead;
end;
{===}
begin
  if CurrentFileExists(FileNum) then
    Result := true
  else
    begin
      Result := false;
      exit;
    end;
  { Now that we have filename and it exists, load it }
  if ImgExt = '.tif' then
    begin
      StripOffset := 8; { Default location of image data }
      AssignFile(F, CurrentFileName);
      Reset(F, 1);
      BlockRead(F, buffer, 4);
      Offset := LongRead;
      Seek(F, Offset);
      nTags := ShortRead;
      for i := 1 to nTags do
        begin
          ReadTag;
          case tagTag of
            256 : rawPNGimage.Resize(tagValue, rawPNGimage.Height);
            257 : rawPNGimage.Resize(rawPNGimage.Width, tagValue);
            273 : begin
                    if tagLength = 1 then
                       StripOffset := tagValue
                    else
                      begin
                        Offset := FilePos(F);
                        Seek(F, tagValue);
                        StripOffset := LongRead;
                        Seek(F, Offset);
                      end;
                  end;
          end; {case}
        end;
      Seek(F, StripOffset);
      for i := 0 to rawPNGimage.Height-1 do
        begin
          BlockRead(F, buffer, rawPNGimage.Width);
          P := rawPNGimage.ScanLine[i];
          Move(buffer[0], P[0], rawPNGimage.Width);
        end;
      CloseFile(F);
    end {tif file input}
  else if (ImgExt = '.png') and GrayImages then
    begin
      rawPNGimage.LoadFromFile(CurrentFileName); {Grayscale PNG is read direct has minimum overhead}
    end
  else if (ImgExt = '.bmp') or ((ImgExt = '.png') and not(GrayImages)) then
    begin
      TmpBGRABmp := TBGRABitmap.Create(CurrentFileName);
      m_Width := TmpBGRABmp.Width;
      m_Height := TmpBGRABmp.Height;
      rawPNGimage.Resize(m_Width, m_Height);
      for i := 0 to m_Height-1 do
        begin
          P := rawPNGimage.ScanLine[i];
          Row := TmpBGRABmp.ScanLine[i];
          for j := 0 to m_Width-1 do
            begin
              P^[j] := (Row[j].red + Row[j].green + Row[j].blue) div 3; {simple colour to grayscale conversion}
            end;
        end;
      TmpBGRABmp.Free;
    end {24bit colour bmp file input}
  else if ImgExt = '.yuv' then
    begin
      AssignFile(F, CurrentFileName);
      Reset(F, 1);
      BlockRead(F, buffer, 2);
      m_Width := buffer[0] + buffer[1] * 256;
      BlockRead(F, buffer, 2);
      m_Height := buffer[0] + buffer[1] * 256;
      BlockRead(F, buffer, 2);
      m_RowBytes := buffer[0] + buffer[1] * 256;
      BlockRead(F, buffer, 4);
      m_PixelFormat := buffer[0] + 256*(buffer[1] + 256*(buffer[2] + (256 * buffer[3])));
      rawPNGimage.Resize(m_Width, m_Height);
      GetMem(pBuffer, m_RowBytes);
      for i := 0 to (m_Height div 2)-1 do
        begin
          BlockRead(F, pBuffer^, m_RowBytes);
          pData := pBuffer;
          P := rawPNGimage.ScanLine[i*2];
          for j := 0 to m_Width-1 do P^[j] := pData[j*2+1];
          P := rawPNGimage.ScanLine[i*2+1];
          for j := 0 to m_Width-1 do P^[j] := pData[j*2+1];
          BlockRead(F, pBuffer^, m_RowBytes);
        end;
      CloseFile(F);
      FreeMem(pBuffer);
    end; {yuv file input}
{ Mask if necessary }
  if Masked then
    begin
      for j := 0 to rawPNGimage.Height-1 do
        begin
          P := rawPNGimage.ScanLine[j];
          for i := 0 to rawPNGimage.Width-1 do if MaskArray[i,j] = 0 then P^[i] := 0;
        end;
    end;
{ Update new image to main canvas }
  Canvas.Draw(0, 0, rawPNGimage);
  Canvas.Pen.Color := clYellow;
  Canvas.MoveTo(LeftCrop,TopCrop);
  Canvas.LineTo(RightCrop,TopCrop);
  Canvas.LineTo(RightCrop,BotCrop);
  Canvas.LineTo(LeftCrop,BotCrop);
  Canvas.LineTo(LeftCrop,TopCrop);
  Canvas.Pen.Color := claqua;
  Canvas.MoveTo(CCLx-5,CCLy+5);
  Canvas.LineTo(CCLx+6,CCLy-6);
  Canvas.MoveTo(CCLx-5,CCLy-5);
  Canvas.LineTo(CCLx+6,CCLy+6);
  Canvas.MoveTo(CCRx-5,CCRy+5);
  Canvas.LineTo(CCRx+6,CCRy-6);
  Canvas.MoveTo(CCRx-5,CCRy-5);
  Canvas.LineTo(CCRx+6,CCRy+6);
  if (CCMx >= 0) and (CCMy >= 0) then
    begin
      Canvas.MoveTo(CCMx-5,CCMy+5);
      Canvas.LineTo(CCMx+6,CCMy-6);
      Canvas.MoveTo(CCMx-5,CCMy-5);
      Canvas.LineTo(CCMx+6,CCMy+6);
{      Canvas.Pen.Color := clred;
      Canvas.MoveTo(round(RotCenX),round(RotCenY-10));
      Canvas.LineTo(round(RotCenX),round(RotCenY+10));
      Canvas.MoveTo(round(RotCenX-10),round(RotCenY));
      Canvas.LineTo(round(RotCenX+10),round(RotCenY));
      Canvas.MoveTo(round(RotCenX+ArcRad*cos(ArcStart)),round(RotCenY-ArcRad*sin(ArcStart)));
      for i := 0 to 100 do
        begin
          TmpAngle := ArcStart + i * ArcAngle /100.0;
          Canvas.LineTo(round(RotCenX+ArcRad*cos(TmpAngle)),round(RotCenY-ArcRad*sin(TmpAngle)));
        end;}
    end;
  Result := true;
end;
{==============================================================================}
function TForm1.CurrentFileExists(FileNum : integer) : boolean;
{ Construct image file name and check that it exists }
var fmt : string;
begin
  if FNcharsNum = 1 then
    begin
      fmt := '%d';
      CurrentFileName := Format(fmt,[FileNum]);
    end
  else
    begin
      fmt := '%.20d';
      CurrentFileName := Format(fmt,[FileNum]);
      CurrentFileName := RightStr(CurrentFileName, FNcharsNum);
    end;
  CurrentFileName := BaseName + CurrentFileName + ImgExt;
  Result := FileExistsUTF8(CurrentFileName);
end;
{==============================================================================}
procedure TForm1.UpdateLabels(ImNo: integer);
var
  S1 : string;
//  imTime : real;
begin
  Label1.Invalidate;
  Str(ImNo:4, S1);
  Label2.Caption := S1;
  Label2.Invalidate;

{  imTime := ImNo * skip / 25.0;
  Str(imTime:6:1, S1);
  Label4.Caption := S1;}
end;
{==============================================================================}
procedure TForm1.CalcArcParams;
var
  numer, denom, xy1, xy2, xy3, ArcMid, ArcEnd : real;
begin
  denom := (CCLx*CCMy + CCRx*CCLy + CCMx*CCRy - CCRx*CCMy - CCLx*CCRy - CCMx*CCLy) * 2;
  xy1 := CCLx*CCLx + CCLy*CCLy;
  xy2 := CCMx*CCMx + CCMy*CCMy;
  xy3 := CCRx*CCRx + CCRy*CCRy;
  numer := xy1*CCMy + xy3*CCLy + xy2*CCRy - xy3*CCMy - xy1*CCRy - xy2*CCLy;
  RotCenX := numer/denom;
  numer := CCLx*xy2 + CCRx*xy1 + CCMx*xy3 - CCRx*xy2 - CCLx*xy3 - CCMx*xy1;
  RotCenY := numer/denom;
  ArcRad := sqrt((RotCenX-CCLx)*(RotCenX-CCLx)+(RotCenY-CCLy)*(RotCenY-CCLy));
  if (CCLx-RotCenX) <> 0 then
    ArcStart := arctan2(RotCenY-CCLy, CCLx-RotCenX)
  else if (RotCenY-CCLy) > 0 then
    ArcStart := PI/2.0
  else
    ArcStart := -1.0*PI/2.0;
  if (CCMx-RotCenX) <> 0 then
    ArcMid := arctan2(RotCenY-CCMy, CCMx-RotCenX)
  else if (RotCenY-CCMy) > 0 then
    ArcMid := PI/2.0
  else
    ArcMid := -1.0*PI/2.0;
  if (CCRx-RotCenX) <> 0 then
    ArcEnd := arctan2(RotCenY-CCRy, CCRx-RotCenX)
  else if (RotCenY-CCRy) > 0 then
    ArcEnd := PI/2.0
  else
    ArcEnd := -1.0*PI/2.0;
  ArcAngle := ArcStart - ArcMid;
  if ArcAngle < 0.0 then ArcAngle := ArcAngle + 2.0 * PI;
  if ArcAngle < PI then
    begin
      ArcMid := ArcStart;
      ArcStart := ArcEnd;
      ArcEnd := ArcMid;
      RotRev := 'T';
    end
  else
    RotRev := 'F';
  ArcAngle := ArcEnd - ArcStart;
  if ArcAngle < 0.0 then ArcAngle := ArcAngle + 2.0 * PI;
end;
{==============================================================================}
procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Prompt.Hide;
 	case WaitStatus of
  None : ;
  CCleft :
    begin
      WaitStatus := CCright;
      CCLx := X;
      CCLy := Y;
      Canvas.Pen.Color := claqua;
      Canvas.MoveTo(CCLx-5,CCLy+5);
      Canvas.LineTo(CCLx+6,CCLy-6);
      Canvas.MoveTo(CCLx-5,CCLy-5);
      Canvas.LineTo(CCLx+6,CCLy+6);
      Prompt.SetMessage('Enter right anchor point');
      Prompt.Show;
    end;
  CCright :
    begin
      WaitStatus := None;
      CCRx := X;
      CCRy := Y;
      MyRedraw;
    end;
  CCarc1 :
    begin
      WaitStatus := CCarc2;
      CCLx := X;
      CCLy := Y;
      Canvas.Pen.Color := claqua;
      Canvas.MoveTo(CCLx-5,CCLy+5);
      Canvas.LineTo(CCLx+6,CCLy-6);
      Canvas.MoveTo(CCLx-5,CCLy-5);
      Canvas.LineTo(CCLx+6,CCLy+6);
      Prompt.SetMessage('Enter mid anchor point');
      Prompt.Show;
    end;
  CCarc2 :
      begin
      WaitStatus := CCarc3;
      CCMx := X;
      CCMy := Y;
      Canvas.Pen.Color := claqua;
      Canvas.MoveTo(CCMx-5,CCMy+5);
      Canvas.LineTo(CCMx+6,CCMy-6);
      Canvas.MoveTo(CCMx-5,CCMy-5);
      Canvas.LineTo(CCMx+6,CCMy+6);
      Prompt.SetMessage('Enter right anchor point');
      Prompt.Show;
    end;
  CCarc3 :
    begin
      WaitStatus := None;
      CCRx := X;
      CCRy := Y;
      CalcArcParams;
      MyRedraw;
    end;
  CropR :
    begin
      WaitStatus := None;
      RightCrop := X;
      MyRedraw;
    end;
  CropL :
    begin
      LeftCrop := X;
      Canvas.Pen.Color := clyellow;
      Canvas.MoveTo(X,0);
      Canvas.LineTo(X, rawPNGimage.Height-1);
      if AllFlag then
        begin
          WaitStatus := CropR;
          Prompt.SetMessage('Enter right cropping width');
          Prompt.Show;
        end
      else
        MyRedraw;
    end;
  CropB :
    begin
      BotCrop := Y;
      Canvas.Pen.Color := clyellow;
      Canvas.MoveTo(0,Y);
      Canvas.LineTo(rawPNGimage.Width-1,Y);
      if AllFlag then
        begin
          WaitStatus := CropL;
          Prompt.SetMessage('Enter left cropping width');
          Prompt.Show;
        end
      else
        MyRedraw;
    end;
  CropT :
    begin
      TopCrop := Y;
      Canvas.Pen.Color := clyellow;
      Canvas.MoveTo(0,Y);
      Canvas.LineTo(rawPNGimage.Width-1,Y);
      if AllFlag then
        begin
          WaitStatus := CropB;
          Prompt.SetMessage('Enter bottom cropping height');
          Prompt.Show;
        end
      else
        MyRedraw;
    end;
  TrackPt :
    begin
      WaitStatus := None;
      cx := X;
      cy := Y;
      SinglePointCC;
    end;
  end; {case}
end;
{==============================================================================}
procedure TForm1.OpenFirst1Click(Sender: TObject);
var
  F : TextFile;
  Err : Integer;
  S, S1 : string;
  c : array[0..511] of char;
  p : Pchar;
  FoundIt : boolean;
  tmpPNGimage : TPngObject;
begin
  Canvas.Brush.Color := clBtnFace;
  Canvas.FillRect(ClientRect);
  OpenDialog.Filter := 'Text Files (*.txt)|*.txt';
  if OpenDialog.Execute then
    begin
      { Display header file and reset some parameters for new file }
      Masked := false;
      AssignFile(F, OpenDialog.Filename);
      Reset(F);
      Readln(F, S);
      Readln(F, S1);
      S := S + #13#10 + S1 + #13#10;
      Readln(F, S1);
      S := S + S1 + #13#10;
      Readln(F, S1);
      S := S + S1 + ' images' + #13#10;
      Val(S1, nImages, Err);
      StartNo := 0;
      if nImages > 5000 then
        StopNo := 5000
      else
        StopNo := nImages;
      InEvery := 1;
      Readln(F, S1);
      S := S + 'frame rate ' + S1 + #13#10;
      Val(S1, skip, Err);
      p := StrPCopy(c, S);
      Application.MessageBox(p, 'Run Details', 0);
      CloseFile(F);
      Caption := OpenDialog.Filename;
      BaseName := OpenDialog.FileName;
      Delete(BaseName, Length(BaseName)-3, 4); { Get base file name by cutting extension from header file name }
      CurImage := 0;
      TopCrop := 0; { Temporary crop parameters }
      BotCrop := 1;
      LeftCrop := 0;
      RightCrop := 1;
      { Search for image file type and numbering convention }
      FNcharsNum := 0;
      repeat
        begin
          inc(FNcharsNum);
          ImgExt := '.tif';
          FoundIt := CurrentFileExists(0);
          if not(FoundIt) then
            begin
              ImgExt := '.png';
              FoundIt := CurrentFileExists(0);
            end;
          if not(FoundIt) then
            begin
              ImgExt := '.bmp';
              FoundIt := CurrentFileExists(0);
            end;
          if not(FoundIt) then
            begin
              ImgExt := '.yuv';
              FoundIt := CurrentFileExists(0);
            end;
        end;
      until FoundIt or (FNcharsNum = 21); { Maximum number characters is 20 }
      { Check if images are grayscale }
      if FoundIt then
        begin
          if ImgExt = '.png' then
            begin
              tmpPNGimage := TPngObject.Create;
              tmpPNGimage.LoadFromFile(CurrentFileName);
              GrayImages := (tmpPNGimage.Header.ColorType = COLOR_GRAYSCALE);
              tmpPNGimage.Free;
            end;
        end
      else
        begin
          Application.MessageBox('Unable to find first image in sequence', 'Error', 0);
          exit;
        end;
      { Load the first image, set a few parameters and rearrange display to suit }
      LoadImgFile(0);
      TopCrop := 0; { Initialise cropping to full picture }
      BotCrop := rawPNGimage.Height - 1;
      LeftCrop := 0;
      RightCrop := rawPNGimage.Width - 1;
      CCLx := 0;
      CCLy := rawPNGimage.Height div 2;
      CCMx := -1;
      CCMy := -1;
      CCRx := rawPNGimage.Width - 1;
      CCRy := rawPNGimage.Height div 2;
      if rawPNGimage.Height > 950 then
        begin
          label1.Left := rawPNGimage.Width + 16;
          label1.Top  := 16;
          label2.Left := rawPNGimage.Width + 72;
          label2.Top  := 16;
          BitBtn2.Left:= rawPNGimage.Width + 16;
          BitBtn2.Top := 48;
          BitBtn4.Left:= rawPNGimage.Width + 64;
          BitBtn4.Top := 48;
          BitBtn5.Left:= rawPNGimage.Width + 112;
          BitBtn5.Top := 48;
          BitBtn6.Left:= rawPNGimage.Width + 160;
          BitBtn6.Top := 48;
          BitBtn1.Left:= rawPNGimage.Width + 208;
          BitBtn1.Top := 48;
          TrackBar1.Left:= rawPNGimage.Width + 16;
          TrackBar1.Top := 80;
          Label6.Left   := rawPNGimage.Width + 16;
          Label6.Top    := 112;
          Button2.Left  := rawPNGimage.Width + 172;
          Button2.Top   := 80;
          Edit2.Left    := rawPNGimage.Width + 220;
          Edit2.Top     := 80;
          Button1.Left  := rawPNGimage.Width + 284;
          Button1.Top   := 80;
        end
      else
        begin
          label1.Left := 8;
          label1.Top  := rawPNGimage.Height + 2;
          label2.Left := 64;
          label2.Top  := rawPNGimage.Height + 2;
          BitBtn2.Left := 120;
          BitBtn2.Top  := rawPNGimage.Height + 2;
          BitBtn4.Left := 168;
          BitBtn4.Top  := rawPNGimage.Height + 2;
          BitBtn5.Left := 216;
          BitBtn5.Top  := rawPNGimage.Height + 2;
          BitBtn6.Left := 264;
          BitBtn6.Top  := rawPNGimage.Height + 2;
          BitBtn1.Left := 312;
          BitBtn1.Top  := rawPNGimage.Height + 2;
          TrackBar1.Left:= 368;
          TrackBar1.Top := rawPNGimage.Height + 2;
          Label6.Left  := 368;
          Label6.Top   := rawPNGimage.Height + 34;
          Button2.Left := 528;
          Button2.Top  := rawPNGimage.Height + 2;
          Edit2.Left   := 576;
          Edit2.Top    := rawPNGimage.Height + 2;
          Button1.Left := 640;
          Button1.Top  := rawPNGimage.Height + 2;
        end;
      Application.ProcessMessages;
      LoadImgFile(0);
      UpdateLabels(CurImage);
      MovAvg := 5; { Moving average window size }
      ThrshScope := 4;
      ThrshFrac := 65;
      ManualThrsh := 30;
      ThrshAdj := 0;
      ThrshTech := HistMin;
    end;
end;
{==============================================================================}
procedure TForm1.SinglePointCC;
{
    Test procedure follows a single point using cross correlation
}
var
{  TF : TextFile;}
  R : TRect;
  s1 : String;
  FilePart: string;
  loop, i, j, k, l, bx, by, BestSES, Err : Integer;
  mm, nn : Integer;
  OldMean, NewMean : Integer;
  PA : PByteArray;
  OldROI, NewROI : array of array of Integer;
  SES : array of array of Integer;

{2D spline and optimisation data}
  X : TReal1DArray;
  Y : TReal1DArray;
  F : TReal2DArray;
  M : AlglibInteger;
  N : AlglibInteger;
  CSpline : Spline2DInterpolant;
  Nvar : AlglibInteger;
  State : MinASAState;
  Rep : MinASAReport;
  S : TReal1DArray;
  BndL : TReal1DArray;
  BndU : TReal1DArray;
  Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt : Double;

begin
{ Dimension arrays and load }
  SetLength(SES, 2*nSearch+1, 2*nSearch+1);
  SetLength(OldROI, CorWindow+1, CorWindow+1);
  SetLength(NewROI, CorWindow+1, CorWindow+1);
  N := 2*nSearch+1;
  M := N;
  SetLength(X, N);
  SetLength(Y, M);
  SetLength(F, M, N);
  for i := 0 to N-1 do
    begin
      X[i] := i - nSearch;
      Y[i] := i - nSearch;
    end;
  Nvar := 2;
  SetLength(S, Nvar);
  SetLength(BndL, Nvar);
  SetLength(BndU, Nvar);
  BndL[0] := -1*nSearch;
  BndL[1] := -1*nSearch;
  BndU[0] := nSearch;
  BndU[1] := nSearch;
{ main CC code }
  Button1.Visible := true;
  HaltGeneration := false;
  Canvas.Brush.Color := clLime;
  for nn := 0 to CorWindow do
    begin
      PA := rawPNGimage.ScanLine[cy+nn-HalfWin];
      for mm := 0 to CorWindow do
        OldROI[mm,nn] := PA^[cx+mm-HalfWin];
    end;
  r_cx := cx;
  r_cy := cy;
  loop := StartNo;
  while (loop <= StopNo) and (not HaltGeneration) do
    begin
      LoadImgFile(loop);
      BestSES := -1;
      bx := 0;
      by := 0;
      for i := 0 to 2*nSearch do
       begin
        for j := 0 to 2*nSearch do
          begin
            for nn := 0 to CorWindow do
              begin
                PA := rawPNGimage.ScanLine[cy+j-nSearch+nn-HalfWin];
                for mm := 0 to CorWindow do
                  NewROI[mm,nn] := PA^[cx+i-nSearch+mm-HalfWin];
              end;
            SES[i,j] := 0;
            OldMean := 0;
            NewMean := 0;
            for k := 0 to CorWindow do
              for l := 0 to CorWindow do
                begin
                  OldMean := OldMean + OldROI[k,l];
                  NewMean := NewMean + NewROI[k,l];
                end;
            OldMean := OldMean div WinSize;
            NewMean := NewMean div WinSize;
            for k := 0 to CorWindow do
              for l := 0 to CorWindow do
                begin
                  Err := OldROI[k,l] - NewROI[k,l] - OldMean + NewMean;
                  SES[i,j] := SES[i,j] + (Err*Err);
{                  SES[i,j] := SES[i,j] + abs(Err);}
                end;
            if (BestSES = -1) or (SES[i,j] < BestSES) then
              begin
                BestSES := SES[i,j];
                bx := i-nSearch;
                by := j-nSearch;
              end;
{            write(TF, SES[i,j]:10, ',');}
          end;
{        writeln(TF,' ');}
       end;

      { fill SES data into function values for 2D spline determination }
      for i := 0 to N-1 do
        for j := 0 to M-1 do
          F[j,i] := SES[i,j];
      Spline2DBuildBicubic(X, Y, F, M, N, CSpline); { calc CSpline data }
{      writeln(TF,'Spline found');}

      { Find surface minimum }
      S[0] := bx;
      S[1] := by;
      MinASACreate(Nvar, S, BndL, BndU, State);
      MinASASetCond(State, 0.0, 0.0, 0.00001, 100);
{      MinASASetXRep(State, True);}
      while MinASAIteration(State) do
        begin
          if State.NeedFG then
            begin
                Xopt := State.X[0];
                Yopt := State.X[1];
                Spline2DDiff(CSpline, Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt);
                State.F := Fopt;
                State.G[0] := FXopt;
                State.G[1] := FYopt;
            end;
{          if State.XUpdated then
            begin
                Writeln(TF,'Step  ',State.X[0]:6:4, '  ', State.X[1]:6:4, '  ', State.F);
            end;}
        end;
      MinASAResults(State, S, Rep);
{      Writeln(TF,'X ans = ',S[0]:6:4);
      Writeln(TF,'Y ans = ',S[1]:6:4);}
      r_cx := r_cx + S[0];
      r_cy := r_cy + S[1];
      cx := round(r_cx);
      cy := round(r_cy);
      Canvas.Draw(0, 0, rawPNGimage);
      R.Left := cx-HalfWin;
      R.Top := cy-HalfWin;
      R.Right := cx+HalfWin;
      R.Bottom := cy+HalfWin;
      Canvas.FrameRect(R);
{      for l := 0 to CorWindow do
        begin
          PA := rawPNGimage.ScanLine[by+l-HalfWin];
          for k := 0 to CorWindow do OldROI[k,l] := PA[bx+k-HalfWin];
        end;}
{      for k := 0 to CorWindow do
         for l := 0 to CorWindow do
          begin
            OldROI[k,l] := rawPNGimage.Canvas.Pixels[bx+k-HalfWin, by+l-HalfWin] AND $FF;
          end;}
      for nn := 0 to CorWindow do
        begin
          PA := rawPNGimage.ScanLine[cy+nn-HalfWin];
          for mm := 0 to CorWindow do
            OldROI[mm,nn] := PA^[cx+mm-HalfWin];
        end;
      UpdateLabels(loop);
      Application.ProcessMessages;
      inc(loop, InEvery);
      Delay(500);
{      CloseFile(TF);}
      if SaveAnnot then
        begin
		      FilePart := ExtractFileName(S1);
          Delete(FilePart, Pos('.', FilePart) ,4);
          FilePart := FilePart + '.tif';
          S1 := AnnotDirectory + '\' + FilePart;
          DumpImage(S1);
        end;
    end;{loop}
  Button1.Visible := false;
end;

{==============================================================================}
procedure TForm1.Timer1Timer(Sender: TObject);
var
  NewImage : integer;
begin
  NewImage := CurImage + NextImage;
  { Check if overshooting sequence and stop if necessary }
  if NewImage < 0 then
    begin
      NewImage := 0;
      Timer1.Enabled := false;
    end
  else if NewImage > nImages then
    begin
      NewImage := nImages;
      Timer1.Enabled := false;
    end;
  { Now get it if you can }
  if LoadImgFile(NewImage) then
    begin
      CurImage := NewImage;
      UpdateLabels(CurImage);
    end;
end;

{==============================================================================}
procedure TForm1.BitBtn5Click(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
begin
  NextImage := abs(NextImage);
  Timer1.Interval := TimerInt;
  Timer1.Enabled := true;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  NextImage := -1 * abs(NextImage);
  Timer1.Interval := TimerInt;
  Timer1.Enabled := true;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  CurImage := abs(NextImage);
  NextImage := -1 * abs(NextImage);
  Timer1.Enabled := true;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  CurImage := nImages-abs(NextImage);
  NextImage := abs(NextImage);
  Timer1.Enabled := true;
end;
{==============================================================================}
procedure TForm1.GenerateMap;
begin
  Timer1.Enabled := false;
  CurImage := StartNo;
  if LoadImgFile(CurImage) then
    begin
      UpdateLabels(CurImage);
      case ReqMap of
        HTube : HorizontalMap;
        GenLOI : CC2PointsMap;
        AvgInt : AvgIntMap;
        Arc2D, Rect2D : CC2DimMap;
      end;
    end;
end;
{==============================================================================}
procedure TForm1.Point1Click(Sender: TObject);
begin
  Timer1.Enabled := false;
  CurImage := StartNo;
  if LoadImgFile(CurImage) then
    begin
      UpdateLabels(CurImage);
      Prompt.SetMessage('Enter point to track');
      Prompt.Show;
      WaitStatus := TrackPt;
    end;
end;
{==============================================================================}
procedure TForm1.AnchorPointShift1Click(Sender: TObject);
var
  S, S1 : string;
  c : array[0..255] of char;
  p : Pchar;
begin
  Timer1.Enabled := false;
  CurImage := StartNo;
  if LoadImgFile(CurImage) then UpdateLabels(CurImage);
  cx := CCLx;
  cy := CCLy;
  SinglePointCC;
  str(r_cx:7:2, S1);
  S := 'x =' + S1;
  str(r_cy:7:2, S1);
  S := S + ' ,y =' + S1;
  p := StrPCopy(c, S);
  Application.MessageBox(p, 'Final Location', 0);
end;
{==============================================================================}
procedure TForm1.RedrawImage1Click(Sender: TObject);
begin
  MyRedraw;
end;
{==============================================================================}
procedure TForm1.AutoThreshold;
var
{  FT: textfile;}
  ThrshOpt, nSearch : Integer;
  m, n, jl : Integer;
  P : PByteArray;
  mav : integer;
begin
{Generate rough histogram}
  for n := 0 to 255 do RawHist[n] := 0;
  m := TopCrop;
  while m <= BotCrop do
    begin
      P := rawPNGimage.ScanLine[m];
      for n := LeftCrop to RightCrop do inc(RawHist[P^[n]]);
      m := m + 5;
    end;
{Moving average filter}
  for n := 0 to 255 do FiltHist[n] := RawHist[n];
  mav := MovAvg div 2;
  if mav > 0 then
    begin
      for n := 0 to 255-mav do
        for m := 1 to mav do FiltHist[n] := FiltHist[n] + RawHist[n+m];
      for n := mav to 255 do
        for m := 1 to mav do FiltHist[n] := FiltHist[n] + RawHist[n-m];
    end;

  case ThrshTech of
    HistMin :
      begin
        {Search for minima if selected}
        Thrsh := 0;
        for jl := 1 to 255 do
        if FiltHist[jl] > FiltHist[Thrsh] then Thrsh := jl; {Find peak}
        Thrsh := Thrsh + 10; {Begin search to left of peak}
        ThrshOpt := FiltHist[Thrsh];
        nSearch := 1;
        Repeat {Search above}
          if (FiltHist[Thrsh+nSearch] < ThrshOpt) then
            begin
              Thrsh := Thrsh+nSearch;
              ThrshOpt := FiltHist[Thrsh];
              nSearch := 1;
            end
          else
            begin
              nSearch := nSearch + 1;
            end;
        Until (nSearch = ThrshScope);
        nSearch := 1;
        Repeat
          if (FiltHist[Thrsh-nSearch] < ThrshOpt) then
            begin
              Thrsh := Thrsh-nSearch;
              ThrshOpt := FiltHist[Thrsh];
              nSearch := 1;
            end
          else
            begin
              nSearch := nSearch + 1;
            end;
        Until (nSearch = ThrshScope);
      end;
    PeakFrac:
      begin
        { Fixed fraction of peak height }
        n := 0;
        for jl := 1 to 255 do
          if FiltHist[jl] > FiltHist[n] then n := jl;
        m := trunc(FiltHist[n] * ThrshFrac div 100);
        for jl := n to 255 do
          if FiltHist[jl] > m then Thrsh := jl;
      end;
    ManThresh: Thrsh := ManualThrsh;
  end;{case}

  case ThrshTech of
    HistMin, PeakFrac: Thrsh := Thrsh + ThrshAdj;
  end;

end; {AutoThreshold}
{==============================================================================}
procedure TForm1.HorizontalMap;
{
  Generate ST maps assuming organ is horizontal across image
}
var
  s1 : String;
  i, j, k, ij, ik, pn, xOff, yOff, xCol : Integer;
  bx, by, BestSES, Err : Integer;
  SES : array of array of Integer;
  OldMean, NewMean : Integer;
  r_cx, r_cy : Real;
  RefSlp : real;
//  imTime : real;
  CentreX, CentreY : array[1..mCorPnts] of Integer;
  OldWind : array of array of array of Byte;
  NewWind : array of array of Byte;
  limTop, limBot, lvlPixel : Integer;
  PLongScan : ^TLongScan;
  P : PByteArray;
  R : TRect;
  FilePart: string;
{  TF : TextFile;}

  {2D spline and optimisation data}
  X : TReal1DArray;
  Y : TReal1DArray;
  F, B : TReal2DArray;
  M : AlglibInteger;
  N : AlglibInteger;
  CSpline : Spline2DInterpolant;
  Nvar : AlglibInteger;
  State : MinASAState;
  Rep : MinASAReport;
  S : TReal1DArray;
  BndL : TReal1DArray;
  BndU : TReal1DArray;
  Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt : Double;

begin
  Button1.Visible := true;
  HaltGeneration := false;
{ Dimension arrays and load }
  SetLength(SES, 2*nSearch+1, 2*nSearch+1);
  SetLength(OldWind, mCorPnts+1, CorWindow+1, CorWindow+1);
  SetLength(NewWind, ScanSize+1, ScanSize+1);
  N := 2*nSearch+1;
  M := N;
  SetLength(X, N);
  SetLength(Y, M);
  SetLength(F, M, N);
  for i := 0 to N-1 do
    begin
      X[i] := i - nSearch;
      Y[i] := i - nSearch;
    end;
  Nvar := 2;
  SetLength(S, Nvar);
  SetLength(BndL, Nvar);
  SetLength(BndU, Nvar);
  BndL[0] := -1*nSearch;
  BndL[1] := -1*nSearch;
  BndU[0] := nSearch;
  BndU[1] := nSearch;
{ Tidy up longitudinal map array storage }
  if LongArray.Count >= 1 then
    for i := 0 to LongArray.Count-1 do
      begin
        PLongScan := LongArray.Items[i];
        Dispose(PLongScan);
      end;
  LongArray.Clear;
{ Set up bitmaps to hold new maps }
  PNGmap.Resize(RightCrop - LeftCrop + 1, ((StopNo - StartNo) div InEvery) + 1);
  LongPict.Bitmap.Height := (StopNo - StartNo) div InEvery;
  LongPict.Bitmap.Width := RightCrop - LeftCrop + 1;
  PntGap := HalfWin;
  nCorPnts := round(PNGmap.Width / PntGap) + 1;
  if CCRX <> CCLX then
    RefSlp := (CCRY - CCLY)/(CCRX - CCLX)
  else
    RefSlp := 0.0;
  for i:= 1 to nCorPnts do
    begin
      CentreX[i] := LeftCrop + round((RightCrop-LeftCrop)*(i-1)/(nCorPnts-1));
      if FixedFlag then CentreY[i] := CCLY + round((CentreX[i]-CCLX)*RefSlp);
    end;
{ Loop through images }
  i := StartNo;
  while (i <= StopNo) and (not HaltGeneration) do
    begin
      {Read next image in sequence and display}
      LoadImgFile(i);
      {Canvas.Draw(0,0, rawPNGimage);}
      {Cross correlate if necessary}
      if CCflag and (i > StartNo) then
       begin
        {Get new dynamic array}
        New(PLongScan);
        LongArray.Add(PLongScan);
        for pn := 1 to nCorPnts do
          begin
            {Get new data window for next point}
            xOff := CentreX[pn]-(ScanSize div 2);
            yOff := CentreY[pn]-(ScanSize div 2);
            for j := 0 to ScanSize do
              begin
                P := rawPNGimage.ScanLine[yOff + j];
                  for k := 0 to ScanSize do
                    NewWind[k, j] := P^[xOff + k];
              end;
            {Cross correlate with old data window}
            BestSES := -1;
            bx := 0;
            by := 0;
            {Get mean of old window}
            OldMean := 0;
            for j := 0 to CorWindow do
              for k := 0 to CorWindow do
                  OldMean := OldMean + OldWind[pn,k,j];
            OldMean := OldMean div WinSize;
            for j := 0 to 2*nSearch do
              for k := 0 to 2*nSearch do
                begin
                  SES[k,j] := 0;
                  {Get mean of new window}
                  NewMean := 0;
                  for ij := 0 to CorWindow do
                    for ik := 0 to CorWindow do
                      NewMean := NewMean + NewWind[k+ik,j+ij];
                  NewMean := NewMean div WinSize;
                  {Correlate old window with current new window}
                  for ij := 0 to CorWindow do
                    for ik := 0 to CorWindow do
                      begin
                        Err := OldWind[pn,ik,ij] - NewWind[k+ik,j+ij] - OldMean + NewMean;
                        SES[k,j] := SES[k,j] + (Err*Err);
//                        SES[k,j] := SES[k,j] + abs(Err);
                      end;
                  if (BestSES = -1) or (SES[k,j] < BestSES) then
                    begin
                      BestSES := SES[k,j];
                      bx := k-nSearch;
                      by := j-nSearch;
                    end;
                  end;
            { fill SES data into  function values for 2D spline determination }
            for k := 0 to N-1 do
              for j := 0 to M-1 do
                F[j,k] := SES[k ,j];
            Spline2DBuildBicubic(X, Y, F, M, N, CSpline); { calc CSpline data }
            { Find surface minimum }
            S[0] := bx;
            S[1] := by;
            MinASACreate(Nvar, S, BndL, BndU, State);
            MinASASetCond(State, 0.0, 0.0, 0.00001, 100);
            while MinASAIteration(State) do
              begin
                if State.NeedFG then
                  begin
                    Xopt := State.X[0];
                    Yopt := State.X[1];
                    Spline2DDiff(CSpline, Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt);
                    State.F := Fopt;
                    State.G[0] := FXopt;
                    State.G[1] := FYopt;
                  end;
              end;
            MinASAResults(State, S, Rep);
            r_cx := S[0];
            r_cy := S[1];
            PLongScan^[pn] := r_cx; { only use x direction value )
//          Debug start
            if (i = 97) and (pn = 57) then
              begin
                AssignFile(TF, 'c:\tmp.dat');
                Rewrite(TF);
                Writeln(TF, r_cx:9:3);
                for k := 0 to N-1 do
                  begin
                    for j := 0 to M-2 do Write(TF, SES[k ,j]:10, ',');
                    Writeln(TF, SES[k ,M-1]:10);
                  end;
                CloseFile(TF);
              end;}
//          Debug end
            {Draw box in shift colour}
            xCol := abs(round(r_cx*50.0));
            if xCol > 255 then xCol := 255;
            if r_cx < 0.0 then xCol := xCol*256; {Shift left is red else green}
            Canvas.Brush.Color := xCol;
            R.Left := CentreX[pn]-HalfWin;
            R.Top := CentreY[pn]-HalfWin;
            R.Right := CentreX[pn]+HalfWin;
            R.Bottom := CentreY[pn]+HalfWin;
            Canvas.FrameRect(R);
            {Draw to longitudinal map}
            if pn = 1 then
              xOff := 0
            else
              xOff := round((pn-1.5)*PntGap);
            if pn = nCorPnts then
              yOff := LongPict.Bitmap.Width
            else
              yOff := round((pn-0.5)*PntGap);
            xCol := abs(round(PLongScan^[pn]*25.0));
            if xCol > 255 then xCol := 255;
            if PLongScan^[pn] < 0.0 then xCol := xCol*256; {left is green}
            LongPict.Bitmap.Canvas.Brush.Color := xCol;
            for j := xOff to yOff do
               LongPict.Bitmap.Canvas.Pixels[j,((i-StartNo) div InEvery)-1] := xCol;
          end; {Cross correlate}
         end;
      {Search for top and bottom profiles of gut}
      AutoThreshold;
      limTop := TopCrop; {Start first column at crop limits}
      limBot := BotCrop;
      for j := LeftCrop to RightCrop do {loop for each image column}
        begin
          P := rawPNGimage.Scanline[limTop];
          if (P^[j] < Thrsh) then
            begin
              repeat
                limTop := limTop + 1;
                P := rawPNGimage.Scanline[limTop];
              until (limTop >= BotCrop) or (P^[j] > Thrsh);
            end
          else
            begin
              repeat
                limTop := limTop - 1;
                P := rawPNGimage.Scanline[limTop];
              until (limTop <= TopCrop) or (P^[j] < Thrsh);
              limTop := limTop + 1;
            end;
          P := rawPNGimage.Scanline[limBot];
          if (P^[j] < Thrsh) then
            begin
              repeat
                limBot := limBot - 1;
                P := rawPNGimage.Scanline[limBot];
              until (limBot <= TopCrop) or (P^[j] > Thrsh);
            end
          else
            begin
              repeat
                limBot := limBot + 1;
                P := rawPNGimage.Scanline[limBot];
              until (limBot >= BotCrop) or (P^[j] < Thrsh);
              limBot := limBot - 1;
            end;
          if (limBot > BotCrop) then limBot := BotCrop;
          if (limBot <= TopCrop) then limBot := BotCrop;
          if (limTop >= BotCrop) then limTop := TopCrop;
          if (limTop < TopCrop) then limTop := TopCrop;
          {Save centre of gut if needed}
          if CCflag and (not FixedFlag) then
            begin
              case FloatSts of
                Upper :
                  begin
                    for pn := 1 to nCorPnts do
                      if j = CentreX[pn] then CentreY[pn] := limTop+HalfWin+2;
                  end;
                Middle :
                  begin
                    for pn := 1 to nCorPnts do
                      if j = CentreX[pn] then CentreY[pn] := (limBot+LimTop) div 2;
                  end;
                Lower :
                  begin
                    for pn := 1 to nCorPnts do
                      if j = CentreX[pn] then CentreY[pn] := limBot-HalfWin-2;
                  end;
              end;
            end;
          {Calculate gut diameter}
          case RadTyp of
            TopRad :
              begin
                k := round(CCLY + (RefSlp*(j-CCLX)));
                lvlPixel := k - limTop + 1;
                Canvas.Pixels[j, limTop] := $FF;
                Canvas.Pixels[j, k] := $FF0000;
              end;
            BotRad :
              begin
                k := round(CCLY + (RefSlp*(j-CCLX)));
                lvlPixel := limBot + 1 - k;
                Canvas.Pixels[j, limBot] := $FF00;
                Canvas.Pixels[j, k] := $FF0000;
              end;
          else
            begin
              Canvas.Pixels[j, limTop] := $FF;
              Canvas.Pixels[j, limBot] := $FF00;
              lvlPixel := limBot - limTop + 1;
            end;
          end; {case}
          {Calculate gut diameter in standard MAC format white = 0, black = 255}
          lvlPixel := 255 - lvlPixel;
          if (lvlPixel < 0) then
            begin
              lvlPixel := 0;
            end
          else
            begin
              if (lvlPixel > 255) then
                begin
                  lvlPixel := 255;
                end;
            end;
          P := PNGmap.Scanline[(i - StartNo) div InEvery];
          P^[j - LeftCrop] := lvlPixel;
        end;
      if CCflag and (not FixedFlag) and (FloatSts = Middle) then
        begin
          CentreY[1] := CentreY[4];
          CentreY[2] := CentreY[4];
          CentreY[3] := CentreY[4];
          CentreY[nCorPnts] := CentreY[nCorPnts-3];
          CentreY[nCorPnts-1] := CentreY[nCorPnts-3];
          CentreY[nCorPnts-2] := CentreY[nCorPnts-3];
        end;
      if CCflag then
        for pn := 1 to nCorPnts do
            begin
              xOff := CentreX[pn]-HalfWin;
              yOff := CentreY[pn]-HalfWin;
              for ij := 0 to CorWindow do
              begin
                P := rawPNGimage.ScanLine[yOff + ij];
                  for ik := 0 to CorWindow do
                    OldWind[pn,ik, ij] := P^[xOff + ik];
              end;
            end;
      UpdateLabels(i);
      Application.ProcessMessages;
      inc(i, InEvery);
      if SaveAnnot then
        begin
		      FilePart := ExtractFileName(S1);
          Delete(FilePart, Pos('.', FilePart) ,4);
          FilePart := FilePart + '.tif';
          S1 := AnnotDirectory + '\' + FilePart;
          DumpImage(S1);
        end;
    end; {for i}
  if HaltGeneration then PNGmap.Resize(PNGmap.Width, i);
  case RadTyp of
    TopRad : SpatMap.Caption := 'Upper Radial Spatial-Temporal Map';
    BotRad : SpatMap.Caption := 'Lower Radial Spatial-Temporal Map';
  else
    SpatMap.Caption := 'Diameter Spatial-Temporal Map';
  end;
  SpatMap.SetPicture(PNGmap, 1.0);
  SpatMap.Show;
  if CCflag then
    begin
      LongMap.SetPicture(LongPict, 1.0);
      LongMap.Show;
    end;
  Button1.Visible := false;
end;
{==============================================================================}
procedure TForm1.DumpImage(DumpFN : string);
var
  F: file;
  imgWidth, imgHeight : integer;
  i, j, k : integer;
  buffer : array[0..5000] of byte;
const
  hdr : array[0..9] of byte =(ord('I'),ord('I'),42,0,8,0,0,0,10,0);
  zero : integer = 0;

procedure WriteTag(tagTag,tagType,tagLength,tagValue : integer);
begin
  BlockWrite(F, tagTag, 2);
  BlockWrite(F, tagType, 2);
  BlockWrite(F, tagLength, 4);
  BlockWrite(F, tagValue, 4);
end;

begin
  imgWidth := rawPNGimage.Width;
  imgHeight := rawPNGimage.Height;
  AssignFile(F, DumpFN);
  Rewrite(F, 1);
  BlockWrite(F, hdr, 10);
  WriteTag(254,4,1,0);
  WriteTag(256,3,1,imgWidth);
  WriteTag(257,3,1,imgHeight);
  WriteTag(258,3,1,8); {BPP}
  WriteTag(259,3,1,1);
  WriteTag(262,3,1,2); {RGB}
  WriteTag(269,2,1,ord('A')); {document name}
  WriteTag(273,4,1,134); {start at byte 122}
  WriteTag(277,3,1,3); {SPP}
  WriteTag(278,3,1,imgHeight);
  BlockWrite(F, zero, 4);
  for j := 0 to imgHeight-1 do
    begin
      for i := 0 to imgWidth-1 do
        begin
          k := Canvas.Pixels[i, j];
          buffer[3*i] := k AND $FF;
          k := k div 256;
          buffer[3*i+1] := k AND $FF;
          k := k div 256;
          buffer[3*i+2]   := k AND $FF;
        end;
      BlockWrite(F, buffer, 3*imgWidth);
    end;
  CloseFile(F);
end;
{==============================================================================}
procedure TForm1.Save1Click(Sender: TObject);
var
  F: file;
  FT: textfile;
  i, j : integer;
  r : real;
  s, s1 : string;
  P : PByteArray;
  PA : ^TLongScan;
  buffer : array[0..3000] of byte;
const
  hdr : array[0..9] of byte =(ord('I'),ord('I'),42,0,8,0,0,0,10,0);
  zero : integer = 0;

procedure WriteTag(tagTag,tagType,tagLength,tagValue : integer);
begin
  BlockWrite(F, tagTag, 2);
  BlockWrite(F, tagType, 2);
  BlockWrite(F, tagLength, 4);
  BlockWrite(F, tagValue, 4);
end;

begin
  { Set appropriate save file extension }
  if (ReqMap = HTube) or (ReqMap = GenLOI) or (ReqMap = AvgInt) then
    SaveDialog.Filter := 'TIF Files (*.tif)|*.tif'
  else if ReqMap = Arc2D then
    SaveDialog.Filter := 'ARC Files (*.arc)|*.arc'
  else if ReqMap = Rect2D then
    SaveDialog.Filter := 'RCT Files (*.rct)|*.rct'
  else
    SaveDialog.Filter := 'All Files (*.*)|*.*';
  { Get user specified file name and save }
  if SaveDialog.Execute then
    begin
      Prompt.Show;
//      Application.ProcessMessages;
      if (ReqMap = HTube) or (ReqMap = GenLOI) or (ReqMap = AvgInt) then {only those that generate a bitmap}
        begin
          Prompt.SetMessage('Please wait while saving TIF file');
          Prompt.Repaint;
          s := ChangeFileExt(SaveDialog.FileName, '.tif');
          AssignFile(F, s);
          Rewrite(F, 1);
          BlockWrite(F, hdr, 10);
          WriteTag(254,4,1,0);
          WriteTag(256,3,1,PNGmap.Width);
          WriteTag(257,3,1,PNGmap.Height);
          WriteTag(258,3,1,8); {BPP}
          WriteTag(259,3,1,1);
          WriteTag(262,3,1,1); {zero = black}
          WriteTag(269,2,1,ord('A')); {document name}
          WriteTag(273,4,1,134); {start at byte 122}
          WriteTag(277,3,1,1); {SPP}
          WriteTag(278,3,1,PNGmap.Height);
          BlockWrite(F, zero, 4);
          for j := 0 to PNGmap.Height-1 do
            begin
              P := PNGmap.ScanLine[j];
              for i := 0 to PNGmap.Width-1 do buffer[i] := P^[i];
              BlockWrite(F, buffer, PNGmap.Width);
            end;
          CloseFile(F);
        end;
      if CCflag or (ReqMap = Arc2D) or (ReqMap = Rect2D) then
        begin
          Prompt.SetMessage('Please wait while saving CCD, ARC or RCT file');
          Prompt.Repaint;
          case ReqMap of
            HTube, GenLOI : s := ChangeFileExt(SaveDialog.FileName, '.ccd');
            Arc2D : s := ChangeFileExt(SaveDialog.FileName, '.arc');
            Rect2D : s := ChangeFileExt(SaveDialog.FileName, '.rct');
          end; {case}
          AssignFile(FT, s);
          Rewrite(FT);
          case ReqMap of
            Arc2D : begin
                      Writeln(FT, 'arc');
                      Writeln(FT, '-1 ', StartNo,' ',nCorPnts,' ',RadPnts,' ',RadGap*CorWindow,' ',InEvery); { -1 indicates newer file version with InEvery addition }
                    end;
            Rect2D: begin
                      Writeln(FT, 'rect');
                      Writeln(FT, StartNo,' ',nCorPnts,' ',nPntRows,' ',InEvery);
                    end;
            else
              begin
                Writeln(FT, nCorPnts);
              end;
          end; {case}
          case ReqMap of
            HTube  : Writeln(FT, LeftCrop,' ' ,((TopCrop+BotCrop) div 2),' ', RightCrop,' ', ((TopCrop+BotCrop) div 2));
            GenLOI : Writeln(FT, CCLx,' ' ,CCLy,' ', CCRx,' ', CCRy);
            Arc2D : begin
                      Writeln(FT, CCLx,' ',CCLy,' ',CCMx,' ',CCMy,' ',CCRx,' ',CCRy);
                      Writeln(FT, ArcRad,' ',ArcStart,' ',ArcAngle,' ',RotRev);
                    end;
            Rect2D  : Writeln(FT, LeftCrop,' ' , RightCrop,' ', TopCrop,' ', BotCrop);
          end; {case}
          for i := 0 to LongArray.Count-1 do
            begin
              PA :=  LongArray.Items[i];
              r := PA^[1];
              if r < -99.99 then
                r := -99.99
              else if r > 99.99 then
                r := 99.99;
              Str(r:8:3, S);
              for j := 2 to nCorPnts do
                begin
                  r := PA^[j];
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
        end;
      Prompt.Hide;
      Prompt.Repaint;
      Beep;
    end;
end;
{==============================================================================}
procedure TForm1.SaveAnnotatedSequence1Click(Sender: TObject);
begin
  if SelectDirectory('Select a directory', 'C:\', AnnotDirectory)
  then
    SaveAnnot := true
  else
    SaveAnnot := false;
end;
{==============================================================================}
procedure TForm1.StopAnnotatedSequence1Click(Sender: TObject);
begin
  SaveAnnot := false;
end;
{==============================================================================}
{procedure TForm1.PlotPressures1Click(Sender: TObject);
var
  imgWidth, imgHeight : Integer;
  i, px : Integer;
  time, press1, press2 : Real;
  F : TextFile;
begin
  OpenDialog1.Filter := 'Text Files (*.txt)|*.txt';
  if OpenDialog1.Execute then
    begin
      AssignFile(F, OpenDialog1.Filename);
      Reset(F);
      imgWidth := PNGmap.Bitmap.Width;
      imgHeight := PNGmap.Bitmap.Height;
      PNGmap.Bitmap.Width := PNGmap.Bitmap.Width + 100;
      for i := 0 to imgHeight-1 do
        begin
          repeat
            Readln(F, time, press1, press2);
          until (time >= ((i-1)*5.0/25.0));
          px := imgWidth + round(press1 * 50.0);
          if (px > (imgWidth + 99)) then px := imgWidth + 99;
          PNGmap.Bitmap.Canvas.Pixels[px, i] := $FF;
          px := imgWidth + round(press2 * 100.0);
          if (px > (imgWidth + 99)) then px := imgWidth + 99;
          PNGmap.Bitmap.Canvas.Pixels[px, i] := $FF00;
        end;
    CloseFile(F);
    SpatMap.SetPicture(PNGmap, 1.0);
    SpatMap.Show;
  end;
end;}
{==============================================================================}
{procedure TForm1.LoadMap1Click(Sender: TObject);
begin
  OpenDialog.Filter := 'TIF Files (*.tif)|*.tif|BMP Files (*.bmp)|*.bmp';
  if OpenDialog.Execute then
    begin
      PNGmap.LoadFromFile(OpenDialog.FileName);
      SpatMap.SetPicture(PNGmap, 1.0);
      SpatMap.Show;
    end;
end;}
{==============================================================================}
{procedure TForm1.BoostContrast1Click(Sender: TObject);
var
  imgWidth, imgHeight : Integer;
  i, j, px : integer;
  P : PByteArray;
begin
  imgWidth := PNGmap.Bitmap.Width;
  imgHeight := PNGmap.Bitmap.Height;
  for j := 0 to imgHeight-1 do
    begin
      P := PNGmap.Bitmap.ScanLine[j];
      for i := 0 to imgWidth-1 do
        begin
          px := 2 * p[i*4];
          if (px > 255) then px := 255;
          P[i*4]     := px;
          P[(i*4)+1] := px;
          P[(i*4)+2] := px;
        end;
    end;
  SpatMap.SetPicture(PNGmap, 0.5);
  SpatMap.Show;
end;}
{==============================================================================}
procedure TForm1.Button1Click(Sender: TObject);
begin
  HaltGeneration := true;
end;
{==============================================================================}
procedure TForm1.Button2Click(Sender: TObject);
var
  NewVal : Integer;
  E, Ans : integer;
  s1 : String;
begin
  Timer1.Enabled := false;
  s1 := Edit2.Text;
  while (ord(s1[1]) = 32) do Delete(s1, 1 ,1);
  Val(s1, Ans, E);
  if E = 0 then
    begin
      NewVal := Ans;
      if NewVal < 0 then NewVal := 0
      else if NewVal > nImages then NewVal := nImages;
      if LoadImgFile(NewVal) then
         begin
           CurImage := NewVal;
           UpdateLabels(CurImage);
         end;
    end;
end;
{==============================================================================}
procedure TForm1.SetRange1Click(Sender: TObject);
//var
//  NewVal : Integer;
begin
{Tmp  NewVal := StartNo;
  if IntegerInputDlg.GetInteger(NewVal, 'Enter start image No.') then
    begin
      if NewVal < 0 then StartNo := 0
      else if NewVal > nImages then StartNo := nImages
      else StartNo := NewVal;
      NewVal := StopNo;
      if IntegerInputDlg.GetInteger(NewVal, 'Enter stop image No.') then
        begin
          if NewVal < StartNo then StopNo := StartNo
          else if NewVal > nImages then StopNo := nImages
          else StopNo := NewVal;
        end;
    end;}
end;
{==============================================================================}
procedure TForm1.DiameterOnly1Click(Sender: TObject);
begin
  ReqMap := HTube;
  CCflag := false;
  RadTyp := FullRad;
  GenerateMap;
end;

procedure TForm1.DiameterAxial1Click(Sender: TObject);
begin
  ReqMap := HTube;
  CCflag := true;
  FixedFlag := false;
  RadTyp := FullRad;
  GenerateMap;
end;

procedure TForm1.UpperRadialMap1Click(Sender: TObject);
begin
  ReqMap := HTube;
  CCflag := false;
  RadTyp := TopRad;
  GenerateMap;
end;

procedure TForm1.LowerRadialMap1Click(Sender: TObject);
begin
  ReqMap := HTube;
  CCflag := false;
  RadTyp := BotRad;
  GenerateMap;
end;

procedure TForm1.DMapandFixedLMap1Click(Sender: TObject);
begin
  ReqMap := HTube;
  CCflag := true;
  FixedFlag := true;
  RadTyp := FullRad;
  GenerateMap;
end;

procedure TForm1.MapAlongLine1Click(Sender: TObject);
begin
  ReqMap := GenLOI;
  CCflag := true;
  GenerateMap;
end;

procedure TForm1.MapLineIntensity1Click(Sender: TObject);
begin
  ReqMap := GenLOI;
  CCflag := false;
  GenerateMap;
end;

procedure TForm1.AverageIntensityMap1Click(Sender: TObject);
begin
  ReqMap := AvgInt;
  CCflag := false;
  GenerateMap;
end;

procedure TForm1.ArcROI1Click(Sender: TObject);
begin
  ReqMap := Arc2D;
  GenerateMap;
end;

procedure TForm1.RectangularROIMap1Click(Sender: TObject);
begin
  ReqMap := Rect2D;
  GenerateMap;
end;
{==============================================================================}
procedure TForm1.CC2PointsMap;
{
  Generate a strain rate contraction map between two specified points
}
var
  s1 : String;
  i, j, k, ij, ik, pn, xOff, yOff, xCol : Integer;
  bx, by, BestSES, Err : Integer;
  SES : array of array of Integer;
  OldMean, NewMean, iSpan : Integer;
  r_cx, r_cy, Span : real;
  CentreX, CentreY : array[1..mCorPnts] of Integer;
  OldWind : array of array of array of Byte;
  NewWind : array of array of Byte;
//  limTop, limBot, lvlPixel : Integer;
  PLongScan : ^TLongScan;
  P, Q : PByteArray;
//  R : TRect;
  delta, beta, gamma, hypot, Lcomp : real;
//  FT: textfile;
  {2D spline and optimisation data}
  X : TReal1DArray;
  Y : TReal1DArray;
  F : TReal2DArray;
  M : AlglibInteger;
  N : AlglibInteger;
  CSpline : Spline2DInterpolant;
  Nvar : AlglibInteger;
  State : MinASAState;
  Rep : MinASAReport;
  S : TReal1DArray;
  BndL : TReal1DArray;
  BndU : TReal1DArray;
  Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt : Double;
begin
  Button1.Visible := true;
  HaltGeneration := false;
{ Dimension arrays and load }
  SetLength(SES, 2*nSearch+1, 2*nSearch+1);
  SetLength(OldWind, mCorPnts+1, CorWindow+1, CorWindow+1);
  SetLength(NewWind, ScanSize+1, ScanSize+1);
  N := 2*nSearch+1;
  M := N;
  SetLength(X, N);
  SetLength(Y, M);
  SetLength(F, M, N);
  for i := 0 to N-1 do
    begin
      X[i] := i - nSearch;
      Y[i] := i - nSearch;
    end;
  Nvar := 2;
  SetLength(S, Nvar);
  SetLength(BndL, Nvar);
  SetLength(BndU, Nvar);
  BndL[0] := -1*nSearch;
  BndL[1] := -1*nSearch;
  BndU[0] := nSearch;
  BndU[1] := nSearch;
{ Tidy up longitudinal map array storage }
  if LongArray.Count >= 1 then
    for i := 0 to LongArray.Count-1 do
      begin
        PLongScan := LongArray.Items[i];
        Dispose(PLongScan);
      end;
  LongArray.Clear;
{ Set up centers for cross correlation squares }
  PntGap := HalfWin;
  Span := sqrt(sqr(CCLx-CCRx)+sqr(CCLy-CCRy));
  iSpan := round(Span);
  nCorPnts := round(Span/PntGap)+1;
  for i:= 1 to nCorPnts do
    begin
      CentreX[i] := CCLx + round((CCRx-CCLx)*(i-1)/(nCorPnts-1));
      CentreY[i] := CCLy + round((CCRy-CCLy)*(i-1)/(nCorPnts-1));
    end;
{ Set up bitmaps to hold new maps }
  PNGmap.Resize(iSpan + 1, ((StopNo - StartNo) div InEvery) + 1);
  LongPict.Bitmap.Height := (StopNo - StartNo) div InEvery;
  LongPict.Bitmap.Width := iSpan + 1;
{ Loop through images }
  i := StartNo;
  while (i <= StopNo) and (not HaltGeneration) do
    begin
      {Read next image in sequence and display}
      LoadImgFile(i);
      {Cross correlate if necessary}
      if CCflag and (i > StartNo) then {skip 1st image in sequence}
       begin
        {Get new dynamic array}
        New(PLongScan);
        LongArray.Add(PLongScan);
        for pn := 1 to nCorPnts do
          begin
            {Get new data window for next point}
            xOff := CentreX[pn]-(ScanSize div 2);
            yOff := CentreY[pn]-(ScanSize div 2);
            for j := 0 to ScanSize do
              begin
                P := rawPNGimage.ScanLine[yOff + j];
                for k := 0 to ScanSize do NewWind[k, j] := P^[xOff + k];
              end;
            {Cross correlate with old data window}
            BestSES := -1;
            bx := 0;
            by := 0;
            {Get mean of old window}
            OldMean := 0;
            for j := 0 to CorWindow do
              for k := 0 to CorWindow do
                  OldMean := OldMean + OldWind[pn,k,j];
            OldMean := OldMean div WinSize;
            for j := 0 to 2*nSearch do
              for k := 0 to 2*nSearch do
                begin
                  SES[k,j] := 0;
                  {Get mean of new window}
                  NewMean := 0;
                  for ij := 0 to CorWindow do
                    for ik := 0 to CorWindow do
                      NewMean := NewMean + NewWind[k+ik,j+ij];
                  NewMean := NewMean div WinSize;
                  {Correlate old window with current new window}
                  for ij := 0 to CorWindow do
                    for ik := 0 to CorWindow do
                      begin
                        Err := OldWind[pn,ik,ij] - NewWind[k+ik,j+ij] - OldMean + NewMean;
                        SES[k,j] := SES[k,j] + (Err*Err);
                        {Err := abs(Err);
                        SES := SES + Err;}
                      end;
                  if (BestSES = -1) or (SES[k,j] < BestSES) then
                    begin
                      BestSES := SES[k,j];
                      bx := k-nSearch;
                      by := j-nSearch;
                    end;
                  end;
            { fill SES data into function values for 2D spline determination }
            for k := 0 to N-1 do
              for j := 0 to M-1 do
                F[j,k] := SES[k ,j];
            Spline2DBuildBicubic(X, Y, F, M, N, CSpline); { calc CSpline data }
            { Find surface minimum }
            S[0] := bx;
            S[1] := by;
            MinASACreate(Nvar, S, BndL, BndU, State);
            MinASASetCond(State, 0.0, 0.0, 0.00001, 100);
            while MinASAIteration(State) do
              begin
                if State.NeedFG then
                  begin
                    Xopt := State.X[0];
                    Yopt := State.X[1];
                    Spline2DDiff(CSpline, Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt);
                    State.F := Fopt;
                    State.G[0] := FXopt;
                    State.G[1] := FYopt;
                  end;
              end;
            MinASAResults(State, S, Rep);
            r_cx := S[0];
            r_cy := S[1];
            { Draw shift in red }
            Canvas.Pen.Color := clRed;
            Canvas.MoveTo(CentreX[pn], CentreY[pn]);
            Canvas.LineTo(round(CentreX[pn]+(3.0*r_cx)), round(CentreY[pn]+(3.0*r_cy)));
            Canvas.Pixels[CentreX[pn], CentreY[pn]] := clYellow;
            if (CCRx-CCLx) <> 0 then
              delta := arctan2(CCRy-CCLy, CCRx-CCLx)
            else if (CCRy-CCLy) > 0 then
              delta := PI/2.0
            else
              delta := -1.0*PI/2.0;
            if r_cx <> 0 then
              beta := arctan2(r_cy, r_cx)
            else if r_cy > 0 then
              beta := PI/2.0
            else
              beta := -1.0*PI/2.0;
            gamma := beta - delta;
            hypot := sqrt(sqr(r_cx)+sqr(r_cy));
            Lcomp := hypot * cos(gamma);
            PLongScan^[pn] := Lcomp; {Save the component of movement}
            {Draw to longitudinal map}
            if pn = 1 then
              xOff := 0
            else
              xOff := round((pn-1.5)*PntGap);
            if pn = nCorPnts then
              yOff := LongPict.Bitmap.Width
            else
              yOff := round((pn-0.5)*PntGap);
            xCol := abs(round(PLongScan^[pn]*25.0));
            if xCol > 255 then xCol := 255;
            if PLongScan^[pn] < 0.0 then xCol := xCol*256; {left is green}
            LongPict.Bitmap.Canvas.Brush.Color := xCol;
            for j := xOff to yOff do
               LongPict.Bitmap.Canvas.Pixels[j,((i-StartNo) div InEvery)-1] := xCol;
          end; {Cross correlate}
         end;
      {Copy line intensities to intensity map}
      Q := PNGmap.Scanline[(i-StartNo) div InEvery];
      for j := 0 to iSpan do
        begin
          xOff := CCLx + round((CCRx-CCLx)*j/iSpan);
          yOff := CCLy + round((CCRy-CCLy)*j/iSpan);
          P := rawPNGimage.Scanline[yoff];
          Q^[j] := P^[xOff];
        end;
      {Save contents of squares for next iteration}
      for pn := 1 to nCorPnts do
        begin
          xOff := CentreX[pn]-HalfWin;
          yOff := CentreY[pn]-HalfWin;
          for ij := 0 to CorWindow do
            begin
              P := rawPNGimage.ScanLine[yOff + ij];
              for ik := 0 to CorWindow do
                OldWind[pn,ik, ij] := P^[xOff + ik];
            end;
        end;
      UpdateLabels(i);
      Application.ProcessMessages;
      inc(i, InEvery);
    end; {for i while loop}
  if HaltGeneration then PNGmap.Resize(PNGmap.Width, i);
  SpatMap.Caption := 'Intensity Spatial-Temporal Map';
  SpatMap.SetPicture(PNGmap, 1.0);
//  SpatMap.Invalidate;
  SpatMap.Show;
  if CCflag then
    begin
      LongMap.SetPicture(LongPict, 1.0);
      LongMap.Show;
    end;
  Button1.Visible := false;
end;
{==============================================================================}
procedure TForm1.AvgIntMap;
{
  Generate an average intensity map following a single point
}
var
  R : TRect;
  s1 : String;
  FilePart: string;
  loop, i, j, k, l, bx, by, BestSES, Err : Integer;
  mm, nn, BoxW, BoxH, lvlPixel : Integer;
  OldMean, NewMean : Integer;
  r_cx, r_cy : Real;
  P, Q : PByteArray;
  OldROI, NewROI : array of array of Integer;
  SES : array of array of Integer;
  {i, j, k, ij, ik, pn, xOff, yOff, xCol : Integer;
  bx, by, BestSES, Err : Integer;
  SES : array of array of Integer;
  OldMean, NewMean, iSpan : Integer;
  r_cx, r_cy, old_cx, old_cy : Real;
  OrigDist, NewDist, imTime, Span : real;
  limTop, limBot, lvlPixel : Integer;}
{2D spline and optimisation data}
  X : TReal1DArray;
  Y : TReal1DArray;
  F : TReal2DArray;
  M : AlglibInteger;
  N : AlglibInteger;
  CSpline : Spline2DInterpolant;
  Nvar : AlglibInteger;
  State : MinASAState;
  Rep : MinASAReport;
  S : TReal1DArray;
  BndL : TReal1DArray;
  BndU : TReal1DArray;
  Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt : Double;
begin
{ Dimension arrays and load }
  SetLength(SES, 2*nSearch+1, 2*nSearch+1);
  SetLength(OldROI, CorWindow+1, CorWindow+1);
  SetLength(NewROI, CorWindow+1, CorWindow+1);
  N := 2*nSearch+1;
  M := N;
  SetLength(X, N);
  SetLength(Y, M);
  SetLength(F, M, N);
  for i := 0 to N-1 do
    begin
      X[i] := i - nSearch;
      Y[i] := i - nSearch;
    end;
  Nvar := 2;
  SetLength(S, Nvar);
  SetLength(BndL, Nvar);
  SetLength(BndU, Nvar);
  BndL[0] := -1*nSearch;
  BndL[1] := -1*nSearch;
  BndU[0] := nSearch;
  BndU[1] := nSearch;
{ main CC code }
  Button1.Visible := true;
  HaltGeneration := false;
{ Set up bitmaps to hold new maps }
  BoxW := (RightCrop - LeftCrop + 1) div 2;
  BoxH := (BotCrop - TopCrop + 1) div 2;
  PNGmap.Resize(2 * BoxW + 1, ((StopNo - StartNo) div InEvery) + 1);
{ Start at center of crop region }
  r_cx := (RightCrop + LeftCrop) / 2.0;
  r_cy := (TopCrop + BotCrop) / 2.0;
  cx := round(r_cx);
  cy := round(r_cy);
  { Preload old points for CC }
  Canvas.Brush.Color := clLime;
  for nn := 0 to CorWindow do
    begin
      P := rawPNGimage.ScanLine[cy+nn-HalfWin];
      for mm := 0 to CorWindow do
        OldROI[mm,nn] := P^[cx+mm-HalfWin];
    end;
{ Loop through images }
  loop := StartNo;
  while (loop <= StopNo) and (not HaltGeneration) do
    begin
      {Read next image in sequence and display}
      LoadImgFile(loop);
      BestSES := -1;
      bx := 0;
      by := 0;
      for i := 0 to 2*nSearch do
       begin
        for j := 0 to 2*nSearch do
          begin
            for nn := 0 to CorWindow do
              begin
                P := rawPNGimage.ScanLine[cy+j-nSearch+nn-HalfWin];
                for mm := 0 to CorWindow do
                  NewROI[mm,nn] := P^[cx+i-nSearch+mm-HalfWin];
              end;
            SES[i,j] := 0;
            OldMean := 0;
            NewMean := 0;
            for k := 0 to CorWindow do
              for l := 0 to CorWindow do
                begin
                  OldMean := OldMean + OldROI[k,l];
                  NewMean := NewMean + NewROI[k,l];
                end;
            OldMean := OldMean div WinSize;
            NewMean := NewMean div WinSize;
            for k := 0 to CorWindow do
              for l := 0 to CorWindow do
                begin
                  Err := OldROI[k,l] - NewROI[k,l] - OldMean + NewMean;
                  SES[i,j] := SES[i,j] + (Err*Err);
                end;
            if (BestSES = -1) or (SES[i,j] < BestSES) then
              begin
                BestSES := SES[i,j];
                bx := i-nSearch;
                by := j-nSearch;
              end;
          end;
       end;
      { fill SES data into function values for 2D spline determination }
      for i := 0 to N-1 do
        for j := 0 to M-1 do
          F[j,i] := SES[i,j];
      Spline2DBuildBicubic(X, Y, F, M, N, CSpline); { calc CSpline data }
      { Find surface minimum }
      S[0] := bx;
      S[1] := by;
      MinASACreate(Nvar, S, BndL, BndU, State);
      MinASASetCond(State, 0.0, 0.0, 0.00001, 100);
      while MinASAIteration(State) do
        begin
          if State.NeedFG then
            begin
                Xopt := State.X[0];
                Yopt := State.X[1];
                Spline2DDiff(CSpline, Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt);
                State.F := Fopt;
                State.G[0] := FXopt;
                State.G[1] := FYopt;
            end;
        end;
      MinASAResults(State, S, Rep);
      r_cx := r_cx + S[0];
      r_cy := r_cy + S[1];
      cx := round(r_cx);
      cy := round(r_cy);
      Canvas.Draw(0, 0, rawPNGimage);
      R.Left := cx-HalfWin;
      R.Top := cy-HalfWin;
      R.Right := cx+HalfWin;
      R.Bottom := cy+HalfWin;
      Canvas.FrameRect(R);
      for nn := 0 to CorWindow do
        begin
          P := rawPNGimage.ScanLine[cy+nn-HalfWin];
          for mm := 0 to CorWindow do
            OldROI[mm,nn] := P^[cx+mm-HalfWin];
        end;
      {Calculate average intensities and write to AvgInt map}
      P := PNGmap.Scanline[(loop-StartNo) div InEvery];
      for j := cx - BoxW to cx + BoxW do
        begin
          lvlPixel := 0;
          for k := cy - BoxH to cy + BoxH do
            begin
              Q := rawPNGimage.ScanLine[k];
              lvlPixel := lvlPixel + Q^[j];
            end;
          lvlPixel := lvlPixel div (2 * BoxH + 1);
          P^[j - cx + BoxW] := lvlPixel;
        end;
      LeftCrop := cx - BoxW;
      RightCrop := cx + BoxW;
      TopCrop := cy - BoxH;
      BotCrop := cy + BoxH;
      UpdateLabels(loop);
      Application.ProcessMessages;
      inc(loop, InEvery);
{      CloseFile(TF);}
      if SaveAnnot then
        begin
    		  FilePart := ExtractFileName(S1);
          Delete(FilePart, Pos('.', FilePart) ,4);
          FilePart := FilePart + '.tif';
          S1 := AnnotDirectory + '\' + FilePart;
          DumpImage(S1);
        end;
    end;{loop}
  if HaltGeneration then PNGmap.Resize(PNGmap.Width, loop);
  SpatMap.Caption := 'Avaerage Intensity ST Map';
  SpatMap.SetPicture(PNGmap, 1.0);
  SpatMap.Show;
  Button1.Visible := false;
end;
{==============================================================================}
procedure TForm1.CC2DimMap;
{
  Generate a 2 dimensional strain rate map of an arc-shaped or rectangular ROI
}
var
  s1 : String;
  i, j, k, ij, ik, an, pn, xOff, yOff, nRows : Integer;
  bx, by, BestSES, Err : Integer;
  SES : array of array of Integer;
  OldMean, NewMean, iSpan : Integer;
  r_cx, r_cy, TmpRad, TmpAngle, Span : real;
  CentreX : array of array of Integer;
  CentreY : array of array of Integer;
  OldWind : array of array of array of array of Byte;
  NewWind : array of array of Byte;
//  limTop, limBot, lvlPixel : Integer;
  PLongScanX, PLongScanY : ^TLongScan;
  P : PByteArray;
//  R : TRect;
//  delta, beta, gamma, hypot, Lcomp : real;
//  FT: textfile;
  {2D spline and optimisation data}
  X : TReal1DArray;
  Y : TReal1DArray;
  F : TReal2DArray;
  M : AlglibInteger;
  N : AlglibInteger;
  CSpline : Spline2DInterpolant;
  Nvar : AlglibInteger;
  State : MinASAState;
  Rep : MinASAReport;
  S : TReal1DArray;
  BndL : TReal1DArray;
  BndU : TReal1DArray;
  Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt : Double;
begin
  Button1.Visible := true;
  HaltGeneration := false;
{ Dimension arrays and load }
  SetLength(SES, 2*nSearch+1, 2*nSearch+1);
  SetLength(NewWind, ScanSize+1, ScanSize+1);
  N := 2*nSearch+1;
  M := N;
  SetLength(X, N);
  SetLength(Y, M);
  SetLength(F, M, N);
  for i := 0 to N-1 do
    begin
      X[i] := i - nSearch;
      Y[i] := i - nSearch;
    end;
  Nvar := 2;
  SetLength(S, Nvar);
  SetLength(BndL, Nvar);
  SetLength(BndU, Nvar);
  BndL[0] := -1*nSearch;
  BndL[1] := -1*nSearch;
  BndU[0] := nSearch;
  BndU[1] := nSearch;
{ Tidy up longitudinal map array storage }
  if LongArray.Count >= 1 then
    for i := 0 to LongArray.Count-1 do
      begin
        PLongScanX := LongArray.Items[i];
        Dispose(PLongScanX);
      end;
  LongArray.Clear;
{ Set up centers for cross correlation squares }
  if ReqMap = Arc2D then
    begin
      PntGap := HalfWin;
      Span := ArcRad*ArcAngle;
      iSpan := round(Span);
      nCorPnts := round(Span/PntGap)+1;
      SetLength(CentreX, RadPnts+1, nCorPnts+1);
      SetLength(CentreY, RadPnts+1, nCorPnts+1);
      SetLength(OldWind, RadPnts+1, nCorPnts+1, CorWindow+1, CorWindow+1);
      for an := 1 to RadPnts do
        begin
          TmpRad := ArcRad + RadGap*CorWindow*(an-1.0-(RadPnts-1)/2.0);
          for i:= 1 to nCorPnts do
            begin
              TmpAngle := ArcStart + (i - 1.0) * ArcAngle /(nCorPnts - 1.0);
              CentreX[an,i] := round(RotCenX+TmpRad*cos(TmpAngle));
              CentreY[an,i] := round(RotCenY-TmpRad*sin(TmpAngle));
            end;
        end;
      nRows := RadPnts;
    end
  else {ReqMap = Rect2D}
    begin
      PntGap := HalfWin;
      nPntRows := round((BotCrop - TopCrop + 1) / PntGap) + 1;
      nCorPnts := round((RightCrop - LeftCrop + 1) / PntGap) + 1;
      SetLength(CentreX, nPntRows+1, nCorPnts+1);
      SetLength(CentreY, nPntRows+1, nCorPnts+1);
      SetLength(OldWind, nPntRows+1, nCorPnts+1, CorWindow+1, CorWindow+1);
      for j := 1 to nPntRows do
        begin
          for i:= 1 to nCorPnts do
            begin
              CentreX[j,i] := LeftCrop + round((RightCrop-LeftCrop)*(i-1)/(nCorPnts-1));
              CentreY[j,i] := TopCrop + round((BotCrop-TopCrop)*(j-1)/(nPntRows-1));
            end;
        end;
      nRows := nPntRows;
    end;
{#####################}
{ Loop through images }
{#####################}
  i := StartNo;
  while (i <= StopNo) and (not HaltGeneration) do
    begin
      {Read next image in sequence and display}
      LoadImgFile(i);
      {Cross correlate if necessary}
      if i > StartNo then {skip 1st image in sequence}
      for an := 1 to nRows do
        begin
        {Get new dynamic arrays}
        New(PLongScanX);
        LongArray.Add(PLongScanX);
        New(PLongScanY);
        LongArray.Add(PLongScanY);
        for pn := 1 to nCorPnts do
          begin
            {Get new data window for next point}
            xOff := CentreX[an,pn]-(ScanSize div 2);
            yOff := CentreY[an,pn]-(ScanSize div 2);
            for j := 0 to ScanSize do
              begin
                P := rawPNGimage.ScanLine[yOff + j];
                  for k := 0 to ScanSize do
                    NewWind[k, j] := P^[xOff + k];
              end;
            {Cross correlate with old data window}
            BestSES := -1;
            bx := 0;
            by := 0;
            {Get mean of old window}
            OldMean := 0;
            for j := 0 to CorWindow do
              for k := 0 to CorWindow do
                  OldMean := OldMean + OldWind[an,pn,k,j];
            OldMean := OldMean div WinSize;
            for j := 0 to 2*nSearch do
              for k := 0 to 2*nSearch do
                begin
                  SES[k,j] := 0;
                  {Get mean of new window}
                  NewMean := 0;
                  for ij := 0 to CorWindow do
                    for ik := 0 to CorWindow do
                      NewMean := NewMean + NewWind[k+ik,j+ij];
                  NewMean := NewMean div WinSize;
                  {Correlate old window with current new window}
                  for ij := 0 to CorWindow do
                    for ik := 0 to CorWindow do
                      begin
                        Err := OldWind[an,pn,ik,ij] - NewWind[k+ik,j+ij] - OldMean + NewMean;
                        SES[k,j] := SES[k,j] + (Err*Err);
                        {Err := abs(Err);
                        SES := SES + Err;}
                      end;
                  if (BestSES = -1) or (SES[k,j] < BestSES) then
                    begin
                      BestSES := SES[k,j];
                      bx := k-nSearch;
                      by := j-nSearch;
                    end;
                  end;
            { fill SES data into function values for 2D spline determination }
            for k := 0 to N-1 do
              for j := 0 to M-1 do
                F[j,k] := SES[k ,j];
            Spline2DBuildBicubic(X, Y, F, M, N, CSpline); { calc CSpline data }
            { Find surface minimum }
            S[0] := bx;
            S[1] := by;
            MinASACreate(Nvar, S, BndL, BndU, State);
            MinASASetCond(State, 0.0, 0.0, 0.00001, 100);
            while MinASAIteration(State) do
              begin
                if State.NeedFG then
                  begin
                    Xopt := State.X[0];
                    Yopt := State.X[1];
                    Spline2DDiff(CSpline, Xopt, Yopt, Fopt, FXopt, FYopt, FXYopt);
                    State.F := Fopt;
                    State.G[0] := FXopt;
                    State.G[1] := FYopt;
                  end;
              end;
            MinASAResults(State, S, Rep);
            r_cx := S[0];
            r_cy := S[1];
            { Draw shift in red }
            Canvas.Pen.Color := clRed;
            Canvas.MoveTo(CentreX[an,pn], CentreY[an,pn]);
            Canvas.LineTo(round(CentreX[an,pn]+(3.0*r_cx)), round(CentreY[an,pn]+(3.0*r_cy)));
            Canvas.Pixels[CentreX[an,pn], CentreY[an,pn]] := clYellow;
            { Alternatively, just draw dots }
{            Canvas.Pen.Color := clWhite;
            Canvas.MoveTo(CentreX[an,pn]-1, CentreY[an,pn]-1);
            Canvas.LineTo(CentreX[an,pn]-1, CentreY[an,pn]+2);
            Canvas.MoveTo(CentreX[an,pn], CentreY[an,pn]-1);
            Canvas.LineTo(CentreX[an,pn], CentreY[an,pn]+2);
            Canvas.MoveTo(CentreX[an,pn]+1, CentreY[an,pn]-1);
            Canvas.LineTo(CentreX[an,pn]+1, CentreY[an,pn]+2);}
            {Save the movements}
            PLongScanX^[pn] := r_cx;
            PLongScanY^[pn] := r_cy;
          end; {Cross correlate}
        Application.ProcessMessages;
       end;
      {Copy line intensities to second map
      for j := 0 to iSpan do
        begin
          xOff := CCLx + round((CCRx-CCLx)*j/iSpan);
          yOff := CCLy + round((CCRy-CCLy)*j/iSpan);
          lvlPixel := rawPNGimage.Canvas.Pixels[xOff, yOff] AND $FF;
          PNGmap.Bitmap.Canvas.Pixels[j, i - StartNo] := (((($100 * lvlPixel) + lvlPixel)* $100) + lvlPixel);
        end;}
      {Save contents of squares for next iteration}
      for an := 1 to nRows do
        for pn := 1 to nCorPnts do
          begin
            xOff := CentreX[an,pn]-HalfWin;
            yOff := CentreY[an,pn]-HalfWin;
            for ij := 0 to CorWindow do
              begin
                P := rawPNGimage.ScanLine[yOff + ij];
                for ik := 0 to CorWindow do
                  OldWind[an,pn,ik, ij] := P^[xOff + ik];
              end;
          end;
      UpdateLabels(i);
      inc(i, InEvery);
    end; {for i}
{  if HaltGeneration then PNGmap.Bitmap.Height := i;
  SpatMap.Caption := 'Intensity Spatial-Temporal Map';
  SpatMap.SetPicture(PNGmap, 1.0);
  SpatMap.Show;}
  Button1.Visible := false;
  Application.MessageBox('2D data ready to save', 'Message', 0);
end;
{==============================================================================}
procedure TForm1.CropAllClick(Sender: TObject);
begin
  Prompt.SetMessage('Enter top cropping height');
  Prompt.Show;
  WaitStatus := CropT;
  AllFlag := true;
end;

procedure TForm1.CropTopClick(Sender: TObject);
begin
  Prompt.SetMessage('Enter top cropping height');
  Prompt.Show;
  WaitStatus := CropT;
  AllFlag := false;
end;

procedure TForm1.CropBottomClick(Sender: TObject);
begin
  Prompt.SetMessage('Enter bottom cropping height');
  Prompt.Show;
  WaitStatus := CropB;
  AllFlag := false;
end;

procedure TForm1.CropLeftClick(Sender: TObject);
begin
  Prompt.SetMessage('Enter left cropping width');
  Prompt.Show;
  WaitStatus := CropL;
  AllFlag := false;
end;

procedure TForm1.CropRightClick(Sender: TObject);
begin
  Prompt.SetMessage('Enter right cropping width');
  Prompt.Show;
  WaitStatus := CropR;
  AllFlag := false;
end;

procedure TForm1.CropClearClick(Sender: TObject);
begin
  TopCrop := 0; { Initialise cropping to full picture }
  BotCrop := rawPNGimage.Height - 1;
  LeftCrop := 0;
  RightCrop := rawPNGimage.Width - 1;
  MyRedraw;
end;

procedure TForm1.MyRedraw;
begin
  if LoadImgFile(CurImage) then UpdateLabels(CurImage);
end;

procedure TForm1.SetAnchorPoints1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter left anchor point');
  Prompt.Show;
  WaitStatus := CCleft;
end;

procedure TForm1.SetArcAnchorPoints1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter left anchor point');
  Prompt.Show;
  WaitStatus := CCarc1;
end;

procedure TForm1.ManualInput1Click(Sender: TObject);
begin
  if UserDlg.GetData then
    begin
      CalcArcParams;
      MyRedraw;
    end;
end;

procedure TForm1.ThresholdGraph1Click(Sender: TObject);
var
  i, j: Integer;
  P : PByteArray;
begin
  if ThreshDlg.GetData then
    begin
      MyRedraw;
      AutoThreshold;
      for i := TopCrop to BotCrop do
        begin
          P := rawPNGimage.ScanLine[i];
          for j := LeftCrop to RightCrop do
            if ((j mod 3) = 0) and (P^[j] < Thrsh) then Canvas.Pixels[j, i] := $FFFF;
        end;
      if GraphThreshDlg.DispGraph then ;
    end;
end;

procedure TForm1.CorrelationAdjust1Click(Sender: TObject);
begin
  if CCrossDlg.GetData then ;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  iPos : integer;
begin
  iPos := TrackBar1.Position;
  case iPos of
    0 : begin
          NextImage := Sign(NextImage);
          TimerInt := 1000;
        end;
    1 : begin
          NextImage := Sign(NextImage);
          TimerInt := 400;
        end;
    2 : begin
          NextImage := Sign(NextImage);
          TimerInt := 200;
        end;
    3 : begin
          NextImage := 2 * Sign(NextImage);
          TimerInt := 200;
        end;
    4 : begin
          NextImage := 5 * Sign(NextImage);
          TimerInt := 200;
        end;
    5 : begin
          NextImage := 10 * Sign(NextImage);
          TimerInt := 200;
        end;
    6 : begin
          NextImage := 20 * Sign(NextImage);
          TimerInt := 200;
        end;
  end; {case}
  Timer1.Interval := TimerInt;
end;

end.
