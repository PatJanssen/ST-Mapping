unit MainUnit;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, StdActns, pngimage,
  ActnList, SysUtils, Math, FileUtil, BGRABitmap, BGRABitmapTypes;

type

  { TMainForm }

  TMainForm = class(TForm)
    MaskMenu: TMenuItem;
    LinkFilesMenu: TMenuItem;
    ExportDumpMenu: TMenuItem;
    MaskLimitsMenu: TMenuItem;
    CustomMaskMenu: TMenuItem;
    AllMaskMenu: TMenuItem;
    MainClient: TPanel;
    ShowCommentMenu: TMenuItem;
    ShowMapMenu: TMenuItem;
    SRKeyMenu: TMenuItem;
    WindowMenu: TMenuItem;
    TopMaskMenu: TMenuItem;
    BottomMaskMenu: TMenuItem;
    LeftMaskMenu: TMenuItem;
    RightMaskMenu: TMenuItem;
    N7: TMenuItem;
    NotePeak: TMenuItem;
    NoteTrough: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    OpenSequenceMenu: TMenuItem;
    N1: TMenuItem;
    ExitMenu: TMenuItem;
    SRDisplayMenu: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    Timer1: TTimer;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit2: TEdit;
    OpenStrainRateMenu: TMenuItem;
    TrackBar1: TTrackBar;
    Label6: TLabel;
    OpenDialog1: TOpenDialog;
    BitBtn3: TBitBtn;
    BitBtn7: TBitBtn;
    OpenPressureMenu: TMenuItem;
    OpenDialog2: TOpenDialog;
    DisplayMode1: TMenuItem;
    Cross_Menu: TMenuItem;
    ScaledDots_Menu: TMenuItem;
    PseudoCont_Menu: TMenuItem;
    SmoothPseudo_Menu: TMenuItem;
    PseudoStep_Menu: TMenuItem;
    None_Menu: TMenuItem;
    MyPopupMenu: TPopupMenu;
    NotePoint1: TMenuItem;
    NoteSpeed1: TMenuItem;
    N4: TMenuItem;
    Anchor11: TMenuItem;
    Anchor21: TMenuItem;
    ToggleMap_Menu: TMenuItem;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure ShowCommentMenuClick(Sender: TObject);
    procedure SmoothPseudo_MenuClick(Sender: TObject);
    procedure ToggleMap_MenuClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MaskMenuClick(Sender: TObject);
    procedure NotePeakClick(Sender: TObject);
    procedure NoteTroughClick(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure OpenStrainRateMenuClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure All1Click(Sender: TObject);
    procedure Top1Click(Sender: TObject);
    procedure Bottom1Click(Sender: TObject);
    procedure Left1Click(Sender: TObject);
    procedure Right1Click(Sender: TObject);
    procedure OpenPressureMenuClick(Sender: TObject);
    procedure LinkPressurestoImages1Click(Sender: TObject);
    procedure DumpImagesInfo1Click(Sender: TObject);
    procedure Cross_MenuClick(Sender: TObject);
    procedure ScaledDots_MenuClick(Sender: TObject);
    procedure PseudoCont_MenuClick(Sender: TObject);
    procedure PseudoStep_MenuClick(Sender: TObject);
    procedure None_MenuClick(Sender: TObject);
    procedure ImageBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NotePoint1Click(Sender: TObject);
    procedure NoteSpeed1Click(Sender: TObject);
    procedure CutItemClick(Sender: TObject);
    procedure CopyItemClick(Sender: TObject);
    procedure Anchor11Click(Sender: TObject);
    procedure Anchor21Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Show2Click(Sender: TObject);
    procedure UseCustomMaskClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadCustomMask;
    procedure OpenSequence;
    procedure ReadRectSRheader;
    procedure ReadArcSRheader;
    function LoadImgFile(FileNum : integer) : boolean;
    function CurrentFileExists(FileNum : integer) : boolean;
    procedure DisplayPicture;
    procedure UpdateLabels(ImNo: integer);
    procedure FormMouseDown(X, Y: Integer);
    procedure SetSRdisplay;
    procedure SetDisplayMode;
    procedure PositionControls;
    procedure DrawStrainRates;
    procedure DrawAreaChangeRates;
    procedure DrawAreaChangeRatesPseudo;
    procedure DrawSmoothAreaSR;
    procedure DumpImage(FileN : string);
    procedure MyRedraw;
    procedure SetEllipticMask;
    procedure DrawPressTrend;
    procedure DrawAnchors;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses ABOUT, UserPrompt, LinkDialog, DumpDialog, KeyForm, MapForm, SmoothDialog,
  Common, CommentForm, Ap, spline2d, linmin, minasa;

{$R *.lfm}

{==============================================================================}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  KeyFrm := TKeyFrm.Create(Application);
  KeyFrm.Parent := MainClient;
  MapFrm := TMapFrm.Create(Application);
  MapFrm.Parent := MainClient;
  CommentFrm := TCommentFrm.Create(Application);
  CommentFrm.Parent := MainClient;
  Picture := TBGRABitmap.Create(100,100,BGRABlack);
  NextImage := 1;
  ImageFreq := 5; {frames per second of image sequence}
  TimerInt := 200;
  Bright := 500.0;
  RelaxFlag := true;
  TopMask := 0;
  BotMask := 100;
  LeftMask := 0;
  RightMask := 100;
  PresWidth := 200;
  DumpFileName := 'C:\Movie\Dump';
  DumpFlag := false;
  DumpStart := 0;
  DumpEnd := 5000;
  CustomFlag := false;
  PrImgOffset := 0;
  DisplayMode := NoMap;
  CCRx := 10;
  CCRy := 10;
  iSpan :=14;
  SmoothFlag := false;
  TrendFlag := false;
  SRfileOpen := false;
  PrFileOpen := false;
  SetDisplayMode; {set to continuous pseudo colour}
end;
{==============================================================================}
procedure TMainForm.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;
{==============================================================================}
procedure TMainForm.FileOpen1Execute(Sender: TObject);
begin
//  MainClient.Canvas.Brush.Color := clBtnFace;
//  MainClient.Canvas.FillRect(MainClient.ClientRect);
  OpenSequence;
end;
{==============================================================================}
procedure TMainForm.SmoothPseudo_MenuClick(Sender: TObject);
{ Toggle smoothing of pseudo coloured area }
begin
  if SmoothPseudo_Menu.Checked then
    begin
      SmoothPseudo_Menu.Checked := false;
      SmoothFlag := false;
    end
  else
    begin
      SmoothPseudo_Menu.Checked := true;
      SmoothFlag := true;
    end;
end;
{==============================================================================}
procedure TMainForm.ToggleMap_MenuClick(Sender: TObject);
{ Initialise and switch on capture of line between anchors }
begin
  if ToggleMap_Menu.Checked then
    begin
      ToggleMap_Menu.Checked := false;
    end
  else
    begin
      ToggleMap_Menu.Checked := true;
      MapFrm.ClearMap;
      MapFrm.Visible := true;
    end;
end;
{==============================================================================}
procedure TMainForm.OpenSequence;
var
  F : TextFile;
  Err : Integer;
  S, S1 : string;
  c : array[0..511] of char;
  p : Pchar;
  FoundIt : boolean;
  tmpPNGimage : TPngObject;
begin
//  Canvas.FillRect(ClientRect);
  OpenDialog.Filter := 'Text Files (*.txt)|*.txt';
  if OpenDialog.Execute then
    begin
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
      InEvery := 1;
      Readln(F, S1);
      S := S + 'frame rate ' + S1 + #13#10;
      Val(S1, skip, Err);
      p := StrPCopy(c, S);
      if Application.MessageBox(p, 'Run Details', mb_OK) <> IDOK then ;
      CloseFile(F);
      Caption := OpenDialog.Filename;
      BaseName := OpenDialog.FileName;
      Delete(BaseName, Length(BaseName)-3, 4);
      CurImage := 0;
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
      PositionControls;
      Application.ProcessMessages;
      LoadImgFile(0);
      UpdateLabels(CurImage);
      SetEllipticMask;
      PrFileOpen := false;
    end;
end;
{==============================================================================}
function TMainForm.LoadImgFile(FileNum : integer) : boolean;
{
    Load numbered image file into grayscale PNG bitmap called "rawPNGimage"
    Returns true if file exists
}
var
  F : file;
  i, j : integer;
  buffer : array[0..6000] of byte;
  Row : PBGRAPixel;
  m_Width, m_Height, m_RowBytes, m_PixelFormat : integer;
  pBuffer, pData : PByte;
begin
  if CurrentFileExists(FileNum) then
    Result := true
  else
    begin
      Result := false;
      exit;
    end;
  { Now that we have filename and it exists, load it }
  if (ImgExt = '.bmp') or (ImgExt = '.png') or (ImgExt = '.tif') then
    Picture.LoadFromFile(CurrentFileName) {these ones are easy, let BGRABitmap do the work}
  else if ImgExt = '.yuv' then
    begin
      try
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
        Picture.SetSize(m_Width, m_Height);
        GetMem(pBuffer, m_RowBytes);
        for i := 0 to (m_Height div 2)-1 do
          begin
            BlockRead(F, pBuffer^, m_RowBytes);
            pData := pBuffer;
            Row := Picture.ScanLine[i*2];
            for j := 0 to m_Width-1 do
              begin
                Row[j].red := pData[j*2+1];
                Row[j].green := pData[j*2+1];
                Row[j].blue := pData[j*2+1];
              end;
            Row := Picture.ScanLine[i*2+1];
            for j := 0 to m_Width-1 do
              begin
                Row[j].red := pData[j*2+1];
                Row[j].green := pData[j*2+1];
                Row[j].blue := pData[j*2+1];
              end;
            BlockRead(F, pBuffer^, m_RowBytes); { skip interlaced line }
          end;
      finally
        CloseFile(F);
        FreeMem(pBuffer);
      end;
    end {yuv file input}
  else
    begin
      Application.MessageBox('Unknown file extension','Error',mb_OK and MB_ICONERROR);
      exit;
    end;
  if not((CurImage >= StartImg) and (((CurImage-StartImg) div InEvery) < nSRImages)
    and ((DisplayMode = PseudoColourCont) or (DisplayMode = PseudoColourStep))) then DisplayPicture;
end;
{==============================================================================}
function TMainForm.CurrentFileExists(FileNum : integer) : boolean;
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
procedure TMainForm.DisplayPicture;
{ Draw picture to screen, superimpose elliptical mask and and text in top-left corner }
var
  s : string;
  r : real;
begin
  Picture.Draw(MainClient.Canvas,0,0,True);
  MainClient.Canvas.Pen.Color := clWhite;
  if not(CustomFlag) then MainClient.Canvas.Arc(LeftMask, TopMask, RightMask, BotMask, 1, 0, 1, 0);
  MainClient.Canvas.Brush.Color := clBlack;
  MainClient.Canvas.Font.Color := clWhite;
  if DumpFlag and (CurImage >= DumpStart) and (CurImage <= DumpEnd) then
    begin { Write the time in big numbers prior to dumping }
      MainClient.Canvas.Font.Size := 24;
      MainClient.Canvas.Font.Name := 'Arial';
      r := (CurImage-DumpStart) / 5.0;
      Str(r:4:1, s);
      s := s + 's';
      MainClient.Canvas.TextOut(10,10,s);
      MainClient.Canvas.Font.Size := 12;
    end
  else
    begin { Write image number in small numbers }
      MainClient.Canvas.Font.Size := 12;
      MainClient.Canvas.Font.Name := 'System';
      Str(CurImage, s);
      MainClient.Canvas.TextOut(10,10,s);
    end;
end;
{==============================================================================}
procedure TMainForm.OpenPressureMenuClick(Sender: TObject);
var
  F : TextFile;
  ip : Integer;
  S, S1 : string;
begin
  OpenDialog2.Filter := 'Text Files (*.txt)|*.txt';
  if OpenDialog2.Execute then
    begin
      CommentFrm.ClearMemo;
      ip := -1;
      AssignFile(F, OpenDialog2.Filename);
      Reset(F);
      Repeat
        inc(ip);
        if ip > (Length(r_Time) - 10) then
          begin
            SetLength(r_Time, Length(r_Time) + 40);
            SetLength(r_Press, Length(r_Press) + 40);
          end;
        Readln(F, r_Time[ip], r_Press[ip], S);
        if Length(S) <> 0 then
          begin
            S1 := Format('Line %d, Comment %s',[ip, S]);
            CommentFrm.AddLineToMemo(S1);
          end;
      Until(Eof(F));
      CloseFile(F);
      SetLength(r_Time, ip+1); {trim back array to data read in}
      SetLength(r_Press, ip+1);
      CommentFrm.Visible := true;
      PrFileOpen := true;
    end;
  MyRedraw;
end;
{==============================================================================}
procedure TMainForm.PositionControls;
begin
{  ImageBox.Left := 0;
  ImageBox.Top := 0;
  ImageBox.Width := Picture.Width;
  ImageBox.Height := Picture.Height;}
  if (Picture.Height > 950) then
    begin
      label1.Left := Picture.Width + PresWidth + 16;
      label1.Top  := 16;
      label2.Left := Picture.Width + PresWidth + 72;
      label2.Top  := 16;
      BitBtn2.Left:= Picture.Width + PresWidth + 16;
      BitBtn2.Top := 48;
      BitBtn4.Left:= Picture.Width + PresWidth + 64;
      BitBtn4.Top := 48;
      BitBtn5.Left:= Picture.Width + PresWidth + 112;
      BitBtn5.Top := 48;
      BitBtn6.Left:= Picture.Width + PresWidth + 160;
      BitBtn6.Top := 48;
      BitBtn1.Left:= Picture.Width + PresWidth + 208;
      BitBtn1.Top := 48;
      TrackBar1.Left:= Picture.Width + PresWidth + 16;
      TrackBar1.Top := 80;
      Label6.Left   := Picture.Width + PresWidth + 16;
      Label6.Top    := 112;

      Button2.Left  := Picture.Width + PresWidth + 16;
      Button2.Top   := 200;
      Edit2.Left    := Picture.Width + PresWidth + 64;
      Edit2.Top     := 200;

      Button1.Left  := Picture.Width + PresWidth + 284;
      Button1.Top   := 80;
      BitBtn3.Left:= Picture.Width + PresWidth + 16;
      BitBtn3.Top := 140;
      BitBtn7.Left:= Picture.Width + PresWidth + 56;
      BitBtn7.Top := 140;

      KeyFrm.Left := Picture.Width + PresWidth + 16;
//      MapPos := Picture.Width + PresWidth + 66;
    end
  else
    begin
      label1.Left := 8;
      label1.Top  := Picture.Height + 2;
      label2.Left := 64;
      label2.Top  := Picture.Height + 2;
      BitBtn2.Left := 120;
      BitBtn2.Top  := Picture.Height + 2;
      BitBtn4.Left := 168;
      BitBtn4.Top  := Picture.Height + 2;
      BitBtn5.Left := 216;
      BitBtn5.Top  := Picture.Height + 2;
      BitBtn6.Left := 264;
      BitBtn6.Top  := Picture.Height + 2;
      BitBtn1.Left := 312;
      BitBtn1.Top  := Picture.Height + 2;
      TrackBar1.Left:= 368;
      TrackBar1.Top := Picture.Height + 2;
      Label6.Left  := 368;
      Label6.Top   := Picture.Height + 34;
      Button2.Left := 528;
      Button2.Top  := Picture.Height + 2;
      Edit2.Left   := 576;
      Edit2.Top    := Picture.Height + 2;
      Button1.Left := 640;
      Button1.Top  := Picture.Height + 2;
      BitBtn3.Left := 720;
      BitBtn3.Top  := Picture.Height + 2;
      BitBtn7.Left := 760;
      BitBtn7.Top  := Picture.Height + 2;
      KeyFrm.Left := Picture.Width + PresWidth + 16;
//      MapPos := KeyFrm.Left + 136;
    end;
end;
{==============================================================================}
procedure TMainForm.UpdateLabels(ImNo: integer);
var
  S1 : string;
begin
  Label1.Caption := 'File No.';
  Str(ImNo:4, S1);
  Label2.Caption := S1;
end;
{==============================================================================}
procedure TMainForm.FileSave1Execute(Sender: TObject);
begin
  SaveDialog.Execute;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;
{==============================================================================}
procedure TMainForm.Button2Click(Sender: TObject);
{ Go to specified image }
var
  NewVal : Integer;
  E, Ans : integer;
  S : String;
begin
  Timer1.Enabled := false;
  S := Edit2.Text;
  while (ord(S[1]) = 32) do Delete(S, 1 ,1);
  Val(S, Ans, E);
  if E = 0 then
    begin
      NewVal := (Ans div InEvery) * InEvery;
      if NewVal < 0 then NewVal := 0
      else if NewVal > nImages then NewVal := nImages;
      if LoadImgFile(NewVal) then
         begin
           CurImage := NewVal;
           if (CurImage >= StartImg) and (((CurImage-StartImg) div InEvery) < nSRImages) then
             begin
               if CustomFlag then LoadCustomMask;
               case DisplayMode of
                 CrossHatched : DrawStrainRates;
                 ScaledDots   : DrawAreaChangeRates;
                 PseudoColourCont, PseudoColourStep : if SmoothFlag then DrawSmoothAreaSR else DrawAreaChangeRatesPseudo;
               end; {case}
             end;
           DrawAnchors;
           if PrFileOpen then DrawPressTrend;
           UpdateLabels(CurImage);
           if DumpFlag and (CurImage >= DumpStart) and (CurImage <= DumpEnd) then
             begin
               Str(CurImage-DumpStart, S);
               S := DumpFileName + S + '.bmp';
               DumpImage(S);
             end;
         end;
    end;
end;
{==============================================================================}
procedure TMainForm.BitBtn5Click(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TMainForm.BitBtn6Click(Sender: TObject);
begin
  NextImage := abs(NextImage);
  Timer1.Interval := TimerInt;
  Timer1.Enabled := true;
end;

procedure TMainForm.BitBtn4Click(Sender: TObject);
begin
  NextImage := -1 * abs(NextImage);
  Timer1.Interval := TimerInt;
  Timer1.Enabled := true;
end;

procedure TMainForm.BitBtn2Click(Sender: TObject);
begin
  CurImage := abs(NextImage);
  NextImage := -1 * abs(NextImage);
  Timer1.Enabled := true;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  CurImage := nImages-abs(NextImage);
  NextImage := abs(NextImage);
  Timer1.Enabled := true;
end;
{==============================================================================}
procedure TMainForm.Timer1Timer(Sender: TObject);
var
  NewImage : integer;
  S : string;
begin
  if DumpFlag or ToggleMap_Menu.Checked then
    NewImage := CurImage + (Sign(NextImage) * InEvery) {only one SR frame at a time when dumping}
  else
    NewImage := CurImage + NextImage;
  NewImage := (NewImage div InEvery) * InEvery; {make sure synchronised with SR data}
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
      if (CurImage >= StartImg) and (((CurImage-StartImg) div Inevery) < nSRImages) then
        begin
          if CustomFlag then LoadCustomMask;
          case DisplayMode of
            CrossHatched : DrawStrainRates;
            ScaledDots   : DrawAreaChangeRates;
            PseudoColourCont, PseudoColourStep : if SmoothFlag then DrawSmoothAreaSR else DrawAreaChangeRatesPseudo;
          end; {case}
        end;
      DrawAnchors;
      if PrFileOpen then DrawPressTrend;
      UpdateLabels(CurImage);
      if DumpFlag and (CurImage >= DumpStart) and (CurImage <= DumpEnd) then
        begin
          Str(CurImage-DumpStart, S);
          S := DumpFileName + S + '.bmp';
          DumpImage(S);
        end;
    end;
end;
{==============================================================================}
procedure TMainForm.OpenStrainRateMenuClick(Sender: TObject);
begin
  OpenDialog.Filter := '2D Strain Rate Files (*.SR2,*.SRA)|*.SR2;*.SRA';
  if OpenDialog.Execute then
    begin
      if SRfileOpen then CloseFile(SRfile);
      if UpperCase(ExtractFileExt(OpenDialog.Filename)) = '.SR2' then
        ReadRectSRheader
      else
        ReadArcSRheader;
      SRfileOpen := true;
      NextImage := InEvery;
      TrackBar1.Position := 2;
      KeyFrm.PaintMapKey(Bright);
      KeyFrm.Visible := true;
    end;
  MyRedraw;
end;
{==============================================================================}
procedure TMainForm.ReadRectSRheader;
var r1, r2, r3, r4, r5 : real;
begin
  AssignFile(SRfile, OpenDialog.Filename);
  Reset(SRfile);
  Read(SRfile, r1);
  if r1 < -0.1 then {newer file includes InEvery}
    begin
      Read(SRfile, r1, r2, r3, r4, r5);
      StartImg := round(r1); nSRImages := round(r2); nCorPnts := round(r3); nPntRows := round(r4); InEvery := round(r5);
      DataPtr := 10; {two extra numbers}
    end
  else
    begin
      StartImg := round(r1);
      Read(SRfile, r2, r3, r4);
      nSRImages := round(r2); nCorPnts := round(r3); nPntRows := round(r4);
      InEvery := 1; {default value for older files}
      DataPtr := 8;
    end;
  Read(SRfile, r1, r2, r3, r4);
  LeftCrop := round(r1); RightCrop := round(r2); TopCrop := round(r3); BotCrop := round(r4);
  ROIshape := RectROI;
end;
{==============================================================================}
procedure TMainForm.ReadArcSRheader;
var r1, r2, r3, r4, r5, r6 : real;
begin
  AssignFile(SRfile, OpenDialog.Filename);
  Reset(SRfile);
  Read(SRfile, r1, r2, r3, r4, r5, r6);
  StartImg := round(r1); nSRImages := round(r2); nCorPnts := round(r3); RadPnts := round(r4); Arc2Arc := round(r5); InEvery := round(r6);
  nPntRows := RadPnts; { for compatibility }
  Read(SRfile, r1, r2, r3, r4, r5, r6);
  CCLx := round(r1); CCLy := round(r2); CCMx := round(r3); CCMy := round(r4); CCRx := round(r5); CCRy := round(r6);
  Read(SRfile, r1, r2, r3, r4, r5, r6);
  ArcRad := round(r1); ArcStart := round(r2); ArcAngle := round(r3);
  if r4 > 0.5 then RotRev := true else RotRev := false;
  DataPtr := 18; { first SR data should start at Seek(18) }
  ROIshape := ArcROI;
end;
{==============================================================================}
procedure TMainForm.DrawStrainRates;
{coloured cross}
var
  i, k, CentreX, CentreY, basePtr : integer;
  r : real;
begin
 { loop for each row }
  basePtr := DataPtr;
  for k := 0 to nPntRows-1 do
    begin
      CentreY := TopCrop + round((BotCrop-TopCrop)*k/(nPntRows-1));
      Seek(SRfile, basePtr + nCorPnts*(k*nSRImages + ((CurImage-StartImg) div InEvery)));
      for i := 1 to nCorPnts do
        begin
          read(SRfile, r);
          CentreX := LeftCrop + round((RightCrop-LeftCrop)*(i-1)/(nCorPnts-1));
{         if ((Picture.Canvas.Pixels[CentreX, CentreY] AND $FF) > Thrsh) then}
{         if (CentreX >= LeftB[CentreY]) and (CentreX <= RightB[CentreY]) then }{ point within mask? }
            begin
              Canvas.Pen.Color := clBlue;
              Canvas.MoveTo(CentreX-2, CentreY);
              Canvas.LineTo(CentreX+3, CentreY);
              Canvas.MoveTo(CentreX, CentreY-2);
              Canvas.LineTo(CentreX, CentreY+3);
{              r := Bright*r;
              if r < -10 then r := -10.0 else if r > 10 then r := 10.0;
              if r < 0.0 then Canvas.Pen.Color := clYellow else Canvas.Pen.Color := clBlue;
              if (r < 0.0) or RelaxFlag then
                begin
                  d2 := round(abs(r));
                  d1 := d2 div 2;
                  d2 := d2 - d1;
                  Canvas.MoveTo(CentreX-d1, CentreY);
                  Canvas.LineTo(CentreX, CentreY);
                  Canvas.MoveTo(CentreX+d2, CentreY);
                  Canvas.LineTo(CentreX, CentreY);
                end;}
            end;
        end;
    end;
  { loop for each column }
  basePtr := DataPtr + nSRImages*nPntRows*nCorPnts;
  for k := 0 to nCorPnts-1 do
    begin
      CentreX := LeftCrop + round((RightCrop-LeftCrop)*k/(nCorPnts-1));
      Seek(SRfile, basePtr + nPntRows*(k*nSRImages + ((CurImage-StartImg) div InEvery)));
      for i := 1 to nPntRows do
        begin
          read(SRfile, r);
          CentreY := TopCrop + round((BotCrop-TopCrop)*(i-1)/(nPntRows-1));
{         if ((Picture.Canvas.Pixels[CentreX, CentreY] AND $FF) > Thrsh) then}
          if (CentreX >= LeftB[CentreY]) and (CentreX <= RightB[CentreY]) then { point within mask? }
            begin
{              r := Bright*r;
              if r < -10 then r := -10.0 else if r > 10 then r := 10.0;
              if r < 0.0 then Canvas.Pen.Color := clOrange else Canvas.Pen.Color := clGreen;
              if (r < 0.0) or RelaxFlag then
                begin
                  d2 := round(abs(r));
                  d1 := d2 div 2;
                  d2 := d2 - d1;
                  Canvas.MoveTo(CentreX, CentreY-d1);
                  Canvas.LineTo(CentreX, CentreY);
                  Canvas.MoveTo(CentreX, CentreY+d2);
                  Canvas.LineTo(CentreX, CentreY);
                end;}
            end;
        end;
    end;
  Canvas.Pen.Color := clWhite;
  if not(CustomFlag) then Canvas.Arc(LeftMask, TopMask, RightMask, BotMask, 1, 0, 1, 0);
end;
{==============================================================================}
procedure TMainForm.DrawAreaChangeRates;
{ Variable size square }
var
  i, k, box, rim, d1, d2, CentreX, CentreY, cx, cy, basePtr : integer;
  r : real;
  StrainRates : array of array of array of real;
begin
  SetLength(StrainRates, 3, nCorPnts, nPntRows);
  { read each row }
  basePtr := DataPtr;
  for k := 0 to nPntRows-1 do
    begin
      Seek(SRfile, basePtr + nCorPnts*(k*nSRImages + ((CurImage-StartImg) div InEvery)));
      for i := 1 to nCorPnts do
        begin
          read(SRfile, StrainRates[0, i-1, k]);
        end;
    end;
{ read each column }
  basePtr := DataPtr + nSRImages*nPntRows*nCorPnts;
  for k := 0 to nCorPnts-1 do
    begin
      Seek(SRfile, basePtr + nPntRows*(k*nSRImages + ((CurImage-StartImg) div InEvery)));
      for i := 1 to nPntRows do
        begin
          read(SRfile, StrainRates[1, k, i-1]);
        end;
    end;
{ calculate areal strain rate from linear strain rates }
  for k := 0 to nCorPnts-1 do
    for i := 0 to nPntRows-1 do
      StrainRates[2, k, i] := ((1.0 + StrainRates[0, k, i])*(1.0 + StrainRates[1, k, i])) - 1.0;
{ fill in square with area proportional to change }
  Canvas.Brush.Style := bsSolid;
  for k := 0 to nPntRows-1 do
    begin
      CentreY := TopCrop + round((BotCrop-TopCrop)*k/(nPntRows-1));
      for i := 0 to nCorPnts-1 do
        begin
          CentreX := LeftCrop + round((RightCrop-LeftCrop)*i/(nCorPnts-1));
          if (CentreX >= LeftB[CentreY]) and (CentreX <= RightB[CentreY]) then { point within mask? }
            begin
              r := Bright*StrainRates[2, i, k];
              if r < -100 then r := -100.0 else if r > 100 then r := 100.0;
              if r < 0.0 then
                begin
                  Canvas.Pen.Color := clYellow;
                  Canvas.Brush.Color := clYellow;
                end
              else
                begin
                  Canvas.Pen.Color := clBlue;
                  Canvas.Brush.Color := clBlue;
                end;
              if (r < 0.0) or RelaxFlag then
                begin
                  r := abs(r);
                  box := trunc(sqrt(r)); { solid square at cetre of point }
                  rim := round(r - (box * box));
                  d1 := box div 2;
                  d2 := box - d1 - 1;
                  cx := CentreX;
                  cy := CentreY;
                  if box = 1 then
                    begin
                      Canvas.MoveTo(cx, cy);
                      Canvas.LineTo(cx+1, cy);
                    end
                  else if box > 1 then
                    Canvas.Rectangle(cx-d1, cy-d1, cx+d2+1, cy+d2+1);
                  if (rim > 0) and (rim <= box+1) then
                    begin
                      Canvas.MoveTo(cx-d1, cy+d2+1);
                      Canvas.LineTo(cx-d1+rim, cy+d2+1);
                    end
                  else if (rim > 0) and (rim > box+1) then
                    begin
                      Canvas.MoveTo(cx-d1, cy+d2+1);
                      Canvas.LineTo(cx-d1+box, cy+d2+1);
                      Canvas.LineTo(cx-d1+box, cy+d2+1-rim+box);
                    end;
                end;
            end;
        end;
    end;
end;
{==============================================================================}
procedure TMainForm.DrawAreaChangeRatesPseudo;
{ Colour-coded surface }
var
  i, ir, k, l, m, CentreX, CentreY, basePtr : integer;
  r : real;
  StrainRates : array of array of array of real;
  HalfPntGap : integer;
  P : PBGRAPixel;
begin
  SetLength(StrainRates, 3, nCorPnts, nPntRows);
  HalfPntGap := 1 + trunc((RightCrop-LeftCrop)*0.5/(nCorPnts-1));
  { read each row }
  basePtr := DataPtr;
  for k := 0 to nPntRows-1 do
    begin
      Seek(SRfile, basePtr + nCorPnts*(k*nSRImages + ((CurImage-StartImg) div InEvery)));
      for i := 1 to nCorPnts do
        begin
          read(SRfile, StrainRates[0, i-1, k]);
        end;
    end;
{ read each column }
  basePtr := DataPtr + nSRImages*nPntRows*nCorPnts;
  for k := 0 to nCorPnts-1 do
    begin
      Seek(SRfile, basePtr + nPntRows*(k*nSRImages + ((CurImage-StartImg) div InEvery)));
      for i := 1 to nPntRows do
        begin
          read(SRfile, StrainRates[1, k, i-1]);
        end;
    end;
{ calculate rate of change of area }
  for k := 0 to nCorPnts-1 do
    for i := 0 to nPntRows-1 do
      StrainRates[2, k, i] := ((1.0 + StrainRates[0, k, i])*(1.0 + StrainRates[1, k, i])) - 1.0;
{ fill in square from LUT }
  for k := 0 to nPntRows-1 do
    begin
      CentreY := TopCrop + round((BotCrop-TopCrop)*k/(nPntRows-1));
      for i := 0 to nCorPnts-1 do
        begin
          CentreX := LeftCrop + round((RightCrop-LeftCrop)*i/(nCorPnts-1));
          if (CustomFlag and (MaskArray[CentreX, CentreY] = 0)) or
           (not(CustomFlag) and (CentreX >= LeftB[CentreY]) and (CentreX <= RightB[CentreY])) then { point within mask? }
            begin
              r := Bright*StrainRates[2, i, k];
              ir := round(r);
              if ir < -255 then ir := -255 else if ir > 255 then ir := 255;
              if (r < 0.0) or RelaxFlag then
                for l := -1*HalfPntGap to HalfPntGap do
                  begin
                    P := Picture.ScanLine[CentreY+l];
                    for m := -1*HalfPntGap to HalfPntGap do
                      begin
                        P[CentreX+m].Red := MyLUT[ir] and $FF;
                        P[CentreX+m].Green := (MyLUT[ir] shr 8) and $FF;
                        P[CentreX+m].Blue := MyLUT[ir] shr 16;
                      end;
                  end;
            end;
        end;
    end;
  DisplayPicture;
end;
{==============================================================================}
procedure TMainForm.DrawSmoothAreaSR;
{ Smoothed colour-coded surface }
var
  i, j, ir, k, n, m, kn, im : integer;
  CentreX, CentreY, basePtr, ImgNo : integer;
  nTop, nBot, CentreHgt : integer;
  SumFull, SumTop, SumBot, CurPress : real;
  s1 : string;
  SRrowAvg, SRcolAvg, r : real;
  SRrow, SRcol : array of array of array of real;
  SRarea : array of array of real;
  P : PBGRAPixel;
{2D spline and optimisation data}
  X : TReal1DArray;
  Y : TReal1DArray;
  F : TReal2DArray;
  NR, NC : AlglibInteger;
  CSpline : Spline2DInterpolant;
  xp, yp : double;
begin
  SetLength(SRrow, 3, nCorPnts, nPntRows);
  SetLength(SRcol, 3, nCorPnts, nPntRows);
  SetLength(SRarea, nCorPnts, nPntRows);
  { read each row }
  basePtr := DataPtr;
  for j := 0 to 2 do
    begin
      ImgNo := ((CurImage-StartImg) div InEvery)-1;
      if ImgNo < 0 then ImgNo := 0
      else if ImgNo >= nSRImages then ImgNo := nSRImages - 1;
      for k := 0 to nPntRows-1 do
        begin
          Seek(SRfile, basePtr + nCorPnts*(k*nSRImages + ImgNo));
          for i := 1 to nCorPnts do read(SRfile, SRrow[j, i-1, k]);
        end;
    end;
{ read each column }
  basePtr := DataPtr + nSRImages*nPntRows*nCorPnts;
  for j := 0 to 2 do
    begin
      ImgNo := ((CurImage-StartImg) div InEvery)-1;
      if ImgNo < 0 then ImgNo := 0
      else if ImgNo >= nSRImages then ImgNo := nSRImages - 1;
      for k := 0 to nCorPnts-1 do
        begin
          Seek(SRfile, basePtr + nPntRows*(k*nSRImages + ImgNo));
          for i := 1 to nPntRows do read(SRfile, SRcol[j, k, i-1]);
        end;
    end;
{ calculate rate of change of area }
  for k := 0 to nCorPnts-1 do
    for i := 0 to nPntRows-1 do
      begin
        SRrowAvg := 0.0;
        SRcolAvg := 0.0;
        for j := 0 to 2 do
          for n := -1 to 1 do
            for m := -1 to 1 do
              begin
                if k = 0 then kn := 0
                else if k = nCorPnts-1 then kn := nCorPnts-1
                else kn := k+n;
                if i = 0 then im := 0
                else if i = nPntRows-1 then im := nPntRows-1
                else im := i+m;
                SRrowAvg := SRrowAvg + SRrow[j, kn, im];
                SRcolAvg := SRcolAvg + SRcol[j, kn, im];
              end;
        SRarea[k, i] := ((1.0 + SRrowAvg/27.0)*(1.0 + SRcolAvg/27.0)) - 1.0;
      end;
{ report average SR data to memo for trending }
  if TrendFlag then
    begin
      nTop := 0;
      nBot := 0;
      SumFull := 0.0;
      SumTop := 0.0;
      SumBot := 0.0;
      CentreHgt := (TopMask + BotMask) div 2;
      for k := 0 to nPntRows-1 do
        begin
          CentreY := TopCrop + round((BotCrop-TopCrop)*k/(nPntRows-1));
          for i := 0 to nCorPnts-1 do
            begin
              CentreX := LeftCrop + round((RightCrop-LeftCrop)*i/(nCorPnts-1));
              if (CustomFlag and (MaskArray[CentreX, CentreY] = 0)) or
               (not(CustomFlag) and (CentreX >= LeftB[CentreY]) and (CentreX <= RightB[CentreY])) then { point within mask? }
                begin
                  r := SRarea[i,k];
                  if CentreY < CentreHgt then
                    begin
                      inc(nTop);
                      if r < 0.0 then SumTop := SumTop + r;
                    end
                  else
                    begin
                      inc(nBot);
                      if r < 0.0 then SumBot := SumBot + r;
                    end;
                end;
            end;
        end;
      if (nTop > 0) or (nBot > 0) then SumFull := (SumTop + SumBot) * -1.0 / (nTop + nBot);
      if nTop > 0 then SumTop := SumTop * -1.0 / nTop;
      if nBot > 0 then SumBot := SumBot * -1.0 / nBot;
      if ((PrImgOffset+(CurImage*2)) >= 0) and ((PrImgOffset+(CurImage*2)) < Length(r_Press)) then CurPress := r_Press[PrImgOffset+(CurImage*2)] else CurPress := 0.0;
//      S1 := Format('%d, %f, %.6f, %.6f, %.6f',[CurImage, CurPress, SumTop, SumBot, SumFull]);
//      Memo1.Lines.Append(S1);
    end;
{ fill SR area data into function values for 2D spline determination }
  SetLength(X, nCorPnts);
  SetLength(Y, nPntRows);
  SetLength(F, nPntRows, nCorPnts);
  NR := nPntRows;
  NC := nCorPnts;
  for i := 0 to nCorPnts-1 do X[i] := round((RightCrop-LeftCrop)*i/(nCorPnts-1));
  for i := 0 to nPntRows-1 do Y[i] := round((BotCrop-TopCrop)*i/(nPntRows-1));
  for k := 0 to nCorPnts-1 do
    for i := 0 to nPntRows-1 do
      F[i,k] := SRarea[k,i];
  Spline2DBuildBicubic(X, Y, F, NR, NC, CSpline); { calc CSpline data }
{ fill in square from LUT }
  for k := 0 to BotCrop-TopCrop do
    begin
      yp := k;
      CentreY := TopCrop + k;
      P := Picture.ScanLine[CentreY];
      for i := 0 to RightCrop-LeftCrop do
        begin
          xp := i;
          CentreX := LeftCrop + i;
          if (CustomFlag and (MaskArray[CentreX, CentreY] = 0)) or
           (not(CustomFlag) and (CentreX >= LeftB[CentreY]) and (CentreX <= RightB[CentreY])) then { point within mask? }
            begin
              r := Bright*Spline2DCalc(CSpline, xp, yp);
              ir := round(r);
              if ir < -255 then ir := -255 else if ir > 255 then ir := 255;
              if (r < 0.0) or RelaxFlag then
                begin
                  P[CentreX].Red := MyLUT[ir] and $FF;
                  P[CentreX].Green := (MyLUT[ir] shr 8) and $FF;
                  P[CentreX].Blue := MyLUT[ir] shr 16;
                end;
            end;
        end;
    end;
  DisplayPicture;
end;
{==============================================================================}
procedure TMainForm.TrackBar1Change(Sender: TObject);
var
  iPos : integer;
begin
  iPos := TrackBar1.Position;
  case iPos of
    0 : begin
          NextImage := Sign(NextImage) * InEvery;
          TimerInt := 1000;
        end;
    1 : begin
          NextImage := Sign(NextImage) * InEvery;
          TimerInt := 400;
        end;
    2 : begin
          NextImage := Sign(NextImage) * InEvery;
          TimerInt := 200;
        end;
    3 : begin
          NextImage := 2 * Sign(NextImage) * InEvery;
          TimerInt := 200;
        end;
    4 : begin
          NextImage := 5 * Sign(NextImage) * InEvery;
          TimerInt := 200;
        end;
    5 : begin
          NextImage := 10 * Sign(NextImage) * InEvery;
          TimerInt := 200;
        end;
    6 : begin
          NextImage := 20 * Sign(NextImage) * InEvery;
          TimerInt := 200;
        end;
  end; {case}
  Timer1.Interval := TimerInt;
end;

procedure TMainForm.ToolButton8Click(Sender: TObject);
var i : integer;
begin
  if (DisplayMode = PseudoColourCont) or (DisplayMode = PseudoColourStep) then
    begin
      i := round(5.0*25500.0/Bright);
      if i >= 150 then
        i := 200
      else if i >= 100 then
        i := 150
      else if i >= 70 then
        i := 100
      else if i >= 50 then
        i := 70
      else if i >= 40 then
        i := 50
      else if i >= 30 then
        i := 40
      else if i >= 20 then
        i := 30
      else if i >= 15 then
        i := 20
      else if i >= 10 then
        i := 15
      else if i >= 7 then
        i := 10
      else if i >= 5 then
        i := 7
      else if i >= 3 then
        i := 5
      else if i >= 2 then
        i := 3
      else i := 2;
      Bright := 5.0*25500.0/i;
    end
  else
    Bright := Bright*2.0/3.0;
  KeyFrm.PaintMapKey(Bright);
end;

procedure TMainForm.ToolButton10Click(Sender: TObject);
var i : integer;
begin
  if (DisplayMode = PseudoColourCont) or (DisplayMode = PseudoColourStep) then
    begin
      i := round(5.0*25500.0/Bright);
      if i >= 200 then
        i := 150
      else if i >= 150 then
        i := 100
      else if i >= 100 then
        i := 70
      else if i >= 70 then
        i := 50
      else if i >= 50 then
        i := 40
      else if i >= 40 then
        i := 30
      else if i >= 30 then
        i := 20
      else if i >= 20 then
        i := 15
      else if i >= 15 then
        i := 10
      else if i >= 10 then
        i := 7
      else if i >= 7 then
        i := 5
      else if i >= 5 then
        i := 3
      else if i >= 3 then
        i := 2
      else i := 1;
      Bright := 5.0*25500.0/i;
    end
  else
    Bright := Bright*1.5;
  KeyFrm.PaintMapKey(Bright);
end;

procedure TMainForm.ToolButton12Click(Sender: TObject);
begin
  if RelaxFlag then RelaxFlag := false else RelaxFlag := true;
end;
{==============================================================================}
procedure TMainForm.DumpImage(FileN : string);
{ Screen dump to a BMP files }
var
  TmpBitmap: TBitmap;
  SrcRect: TRect;
begin
  TmpBitmap := TBitmap.Create;
  if PrFileOpen then
    TmpBitmap.Width := ((Picture.Width + PresWidth) div 2) * 2 {Some CODECS prefer round numbers}
  else
    TmpBitmap.Width := (Picture.Width div 2) * 2;
  TmpBitmap.Height := (Picture.Height div 2) * 2;
  {In case something goes wrong, free TmpBitmap}
  try
    SrcRect := Rect(0, 0, TmpBitmap.Width, TmpBitmap.Height);
    TmpBitmap.Canvas.CopyMode := cmSrcCopy;
    TmpBitmap.Canvas.CopyRect(SrcRect, Canvas, SrcRect);
    TmpBitmap.SaveToFile(FileN);
  finally
    TmpBitmap.Free;
  end; {try}
end;{dump BMP file}
{==============================================================================}

{ User-selected elliptical mask with mouse clicks }

procedure TMainForm.All1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter top of mask');
  Prompt.Show;
  WaitStatus := MaskT;
  AllFlag := true;
end;

procedure TMainForm.Top1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter top of mask');
  Prompt.Show;
  WaitStatus := MaskT;
  AllFlag := false;
end;

procedure TMainForm.Bottom1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter bottom of mask');
  Prompt.Show;
  WaitStatus := MaskB;
  AllFlag := false;
end;

procedure TMainForm.Left1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter left of mask');
  Prompt.Show;
  WaitStatus := MaskL;
  AllFlag := false;
end;

procedure TMainForm.Right1Click(Sender: TObject);
begin
  Prompt.SetMessage('Enter right of mask');
  Prompt.Show;
  WaitStatus := MaskR;
  AllFlag := false;
end;

procedure TMainForm.FormMouseDown(X, Y: Integer);
begin
  Prompt.Hide;
 	case WaitStatus of
  None : ;
  MaskR :
    begin
      WaitStatus := None;
      RightMask := X;
      MyRedraw;
    end;
  MaskL :
    begin
      LeftMask := X;
      MainClient.Canvas.Pen.Color := clyellow;
      MainClient.Canvas.MoveTo(X,0);
      MainClient.Canvas.LineTo(X, Picture.Height-1);
      if AllFlag then
        begin
          WaitStatus := MaskR;
          Prompt.SetMessage('Enter right of mask');
          Prompt.Show;
        end
      else
        MyRedraw;
    end;
  MaskB :
    begin
      BotMask := Y;
      MainClient.Canvas.Pen.Color := clyellow;
      MainClient.Canvas.MoveTo(0,Y);
      MainClient.Canvas.LineTo(Picture.Width-1,Y);
      if AllFlag then
        begin
          WaitStatus := MaskL;
          Prompt.SetMessage('Enter left of mask');
          Prompt.Show;
        end
      else
        MyRedraw;
    end;
  MaskT :
    begin
      TopMask := Y;
      MainClient.Canvas.Pen.Color := clyellow;
      MainClient.Canvas.MoveTo(0,Y);
      MainClient.Canvas.LineTo(Picture.Width-1,Y);
      if AllFlag then
        begin
          WaitStatus := MaskB;
          Prompt.SetMessage('Enter bottom of mask');
          Prompt.Show;
        end
      else
        MyRedraw;
    end;
  end; {case}
end;
{==============================================================================}

{ Use free-form mask from file }

procedure TMainForm.UseCustomMaskClick(Sender: TObject);
begin
  CustomFlag := true;
end;

procedure TMainForm.LoadCustomMask;
var
//  F : TextFile;
  i, j : Integer;
  S, S1 : string;
//  c : array[0..511] of char;
//  p : Pchar;
  PNG : TPngObject;
  SrcB : pByteArray;
begin
  Str(CurImage:5, S1);
  while (ord(S1[1]) = 32) do Delete(S1, 1 ,1);
  S := ExtractFilePath(BaseName)+ 'masks\mask' + S1 + '.png';
  if FileExistsUTF8(S) then
    begin
      try
        PNG := TPngObject.Create;
        PNG.LoadFromFile(S);
        SetLength(MaskArray, PNG.Width, PNG.Height);
        if PNG.Header.BitDepth = 8 then
          begin
            for j := 0 to PNG.Height-1 do
              begin
                SrcB := PNG.Scanline[j];
                for i := 0 to PNG.Width-1 do
                  begin
                    MaskArray[i,j] := SrcB[i];
                   end;
               end;
            end;
      finally
        PNG.Free;
      end; {try}
    end; {if exists}
end;
{==============================================================================}
procedure TMainForm.MyRedraw;
{ Reload image from disk and redraw }
begin
  Application.ProcessMessages; {Necessary to tidy up screen before redrawing}
  if LoadImgFile(CurImage) then
    begin
      SetEllipticMask;
      if (CurImage >= StartImg) and (((CurImage-StartImg) div InEvery) < nSRImages) then
        begin
          if CustomFlag then LoadCustomMask;
          case DisplayMode of
            CrossHatched : DrawStrainRates;
            ScaledDots   : DrawAreaChangeRates;
            PseudoColourCont, PseudoColourStep : if SmoothFlag then DrawSmoothAreaSR else DrawAreaChangeRatesPseudo;
          end; {case}
        end;
      if PrFileOpen then DrawPressTrend;
      UpdateLabels(CurImage);
    end;
end;
{==============================================================================}
procedure TMainForm.SetEllipticMask;
{ Generate left and right boundaries of elliptical mask }
var
  i, cx, cy, x, y, a, b : integer;
begin
  SetLength(LeftB, Picture.Height);
  SetLength(RightB, Picture.Height);
  for i := 0 to Picture.Height-1 do
    begin
      LeftB[i] := 1;
      RightB[i] := 0;
    end;
  cx := (LeftMask + RightMask) div 2;
  cy := (TopMask + BotMask) div 2;
  a :=  1 + (RightMask - LeftMask) div 2;
  b :=  1 + (BotMask - TopMask) div 2;
  for i := TopMask to BotMask do
    begin
      y := i - cy;
      x := round(sqrt(a*a*(1-(y*y)/(b*b))));
      LeftB[i] := cx - x;
      RightB[i] := cx + x;
    end;
end;
{==============================================================================}
procedure TMainForm.LinkPressurestoImages1Click(Sender: TObject);
var DataLine, ImageNo : integer;
begin
  if LinkInputDlg.GetLink(DataLine, ImageNo, ImageFreq, InEvery) then
    begin
      PrImgOffset := DataLine-(ImageNo * 10 div ImageFreq);
      MyRedraw; { redraw to update pressure trace }
    end;
end;

procedure TMainForm.DrawPressTrend;
var
  i, c, k, LineNo, BarL : integer;
  r, MinV, MaxV : real;
  s : string;
  Started : boolean;
begin
  with MainClient do
    begin
      LineNo := PrImgOffset + (CurImage * 10 div ImageFreq);
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := clLtGray;
      Canvas.Pen.Color := clLtGray;
      Canvas.Rectangle(Picture.Width, 0,Picture.Width+PresWidth, Picture.Height);
      c := Picture.Height div 2;
      Canvas.Pen.Color := clRed;
      Canvas.MoveTo(Picture.Width,c);
      Canvas.LineTo(Picture.Width+PresWidth,c);
      Canvas.MoveTo(Picture.Width,0);
      Canvas.Pen.Color := clBlue;
      Canvas.Font.Color := clBlack;
      MinV := 10000.0;
      MaxV := -10000.0;
      for i := 0 to Picture.Height-1 do { Find min and max for autoscaling }
        begin
          k := LineNo + (i - c);
          if (k >= 0) and (k < Length(r_Press)) then
            begin
              if r_Press[k] < MinV then MinV := r_Press[k];
              if r_Press[k] > MaxV then MaxV := r_Press[k];
            end;
        end;
      if (MaxV-MinV) < 1.5 then MaxV := MinV + 1.5; { Set scale to .GE. 1.5 }
      Started := false;
      for i := 0 to Picture.Height-1 do { Draw trend line }
        begin
          k := LineNo + (i - c);
          if (k >= 0) and (k < Length(r_Press)) then
            begin
              r := MaxV-MinV;
              if r = 0.0 then r := 0.0000001;
              r := 0.05 + 0.9*(r_Press[k]-MinV)/r;
              if Started then
                Canvas.LineTo(Picture.Width+round(PresWidth*r),i)
              else
                begin
                  Started := true;
                  Canvas.MoveTo(Picture.Width+round(PresWidth*r),i);
                end;
            end;
        end;
      if (LineNo >= 0) and (LineNo < Length(r_Press)) then
        begin
          str(r_Press[LineNo]:6:2, s);
          s := s + 'mm Hg';
          Canvas.TextOut(Picture.Width+50,c+10,s);
        end;
      BarL := round(0.9*PresWidth/(MaxV-MinV));
      Canvas.Pen.Color := clBlack;
      Canvas.MoveTo(Picture.Width+40,Picture.Height-125);
      Canvas.LineTo(Picture.Width+40,Picture.Height-25);
      Canvas.LineTo(Picture.Width+40+BarL,Picture.Height-25);
      s := '10s';
      Canvas.TextOut(Picture.Width+10,Picture.Height-85,s);
      s := '1mm Hg';
      Canvas.TextOut(Picture.Width+20+(BarL div 2),Picture.Height-20,s);
    end; {with}
end;

procedure TMainForm.DumpImagesInfo1Click(Sender: TObject);
begin
  if DumpInputDlg.GetDumpInfo(DumpFlag, DumpStart, DumpEnd, DumpFileName) then ;
end;
{==============================================================================}
procedure TMainForm.DrawAnchors;
{ Capture anchored line to map and draw anchors }
var
  j, xOff, yOff : integer;
begin
  if ToggleMap_Menu.Checked then { Capture line pixels between anchors }
    begin
      for j := 0 to iSpan do
        begin
          xOff := CCLx + round((CCRx-CCLx)*j/iSpan);
          yOff := CCLy + round((CCRy-CCLy)*j/iSpan);
          CaptureBuffer[j] := MainClient.Canvas.Pixels[xOff, yOff];
        end;
      MapFrm.AddLineToMap; { Shift line from buffer to map }
    end;
  if not(DumpFlag and (CurImage >= DumpStart) and (CurImage <= DumpEnd)) then
    with MainClient.Canvas do
      begin { Only draw anchors if not screen dumping images }
        Pen.Color := clWhite;
        MoveTo(CCLx-5,CCLy+5);
        LineTo(CCLx+6,CCLy-6);
        MoveTo(CCLx-5,CCLy-5);
        LineTo(CCLx+6,CCLy+6);
        MoveTo(CCRx-5,CCRy+5);
        LineTo(CCRx+6,CCRy-6);
        MoveTo(CCRx-5,CCRy-5);
        LineTo(CCRx+6,CCRy+6);
      end;
end;
{==============================================================================}
{ Routines to manage display mode of areal SR data }
{==============================================================================}
procedure TMainForm.SetSRdisplay;
begin
  None_Menu.Checked       := (DisplayMode = NoMap);
  Cross_Menu.Checked      := (DisplayMode = CrossHatched);
  ScaledDots_Menu.Checked := (DisplayMode = ScaledDots);
  PseudoCont_Menu.Checked := (DisplayMode = PseudoColourCont);
  PseudoStep_Menu.Checked := (DisplayMode = PseudoColourStep);
end;

procedure TMainForm.None_MenuClick(Sender: TObject);
begin
  DisplayMode := NoMap;
  KeyFrm.ClearKey;
  SetSRdisplay;
end;

procedure TMainForm.Cross_MenuClick(Sender: TObject);
begin
  DisplayMode := CrossHatched;
  Bright := 500.0;
  KeyFrm.ClearKey;
  SetSRdisplay;
end;

procedure TMainForm.ScaledDots_MenuClick(Sender: TObject);
begin
  DisplayMode := ScaledDots;
  Bright := 500.0;
  KeyFrm.ClearKey;
  SetSRdisplay;
end;

procedure TMainForm.SetDisplayMode;
var i, j : integer;
begin
  DisplayMode := PseudoColourCont;
  Bright := 18214.2857;
  for i := -255 to 255 do
    begin
      j := i;
      if i < 0 then
        begin
          j := j * -2;
          if j < 256 then
            MyLUT[i] := j
          else
            MyLUT[i] :=  ((j - 255) shl 8) + 255;
        end
      else
        MyLUT[i] := i shl 16;
    end;
  SetSRdisplay;
end;

procedure TMainForm.PseudoCont_MenuClick(Sender: TObject);
begin
  SetDisplayMode;
  KeyFrm.PaintMapKey(Bright);
  SetSRdisplay;
end;

procedure TMainForm.PseudoStep_MenuClick(Sender: TObject);
var
  i, j : integer;
  r : real;
begin
  DisplayMode := PseudoColourStep;
  Bright := 18214.2857;
  for i := -255 to 255 do
    begin
      r := abs(i)/36.43; {7 steps}
      j := round(r);
      r := j;
      j := round(r*36.43);
      j := sign(i)*j;
      if i < 0 then
        begin
          j := j * -2;
          if j < 256 then
            MyLUT[i] := j
          else
            MyLUT[i] :=  ((j - 255) shl 8) + 255;
        end
      else
        MyLUT[i] := j shl 16;
    end;
  KeyFrm.PaintMapKey(Bright);
  SetSRdisplay;
end;
{==============================================================================}
procedure TMainForm.Show1Click(Sender: TObject);
begin
  KeyFrm.PaintMapKey(Bright);
  KeyFrm.Visible := true;
end;

procedure TMainForm.Show2Click(Sender: TObject);
begin
  MapFrm.Visible := true;
end;

procedure TMainForm.ShowCommentMenuClick(Sender: TObject);
begin
  CommentFrm.Visible := true;
end;
{==============================================================================}
procedure TMainForm.ImageBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var s1, SBarMsg : string;
begin
  str(X:4, s1);
  SBarMsg := 'x=' + s1;
  str(Y:4, s1);
  SBarMsg := SBarMsg + ' ,y=' + s1;
//  StaticText1.Caption := SBarMsg;
end;

procedure TMainForm.ImageBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pnt: TPoint;
begin
  inherited;
  if Button = mbLeft then
    FormMouseDown(X, Y)
  else if (not Timer1.Enabled) and (Button = mbRight) then
    begin
      xCursor := X;
      yCursor := Y;
      if GetCursorPos(pnt) then MyPopupMenu.Popup(pnt.X, pnt.Y);
    end;
end;

procedure TMainForm.NotePoint1Click(Sender: TObject);
var
  LineNo : integer;
  s1, SMemoMsg : string;
begin
  str(CurImage, s1);
  SMemoMsg := s1;
  LineNo := PrImgOffset+(CurImage*2); {assume 5 and 10 Hz respectively}
  if (LineNo >= 0) and (LineNo < Length(r_Press)) then
    str(r_Press[LineNo]:6:2, s1)
  else
    s1 := '0.00';
  SMemoMsg := SMemoMsg + ', ' + s1;
  str(xCursor, s1);
  SMemoMsg := SMemoMsg + ', ' + s1;
  str(yCursor, s1);
  SMemoMsg := SMemoMsg + ', ' + s1;
//  Memo1.Lines.Add(SMemoMsg);
  cStored := CurImage;
  xStored := xCursor;
  yStored := yCursor;
end;

procedure TMainForm.NotePeakClick(Sender: TObject);
var
  LineNo : integer;
  s1, SMemoMsg : string;
begin
  str(CurImage, s1);
  SMemoMsg := s1;
  LineNo := PrImgOffset+(CurImage*2);
  if (LineNo >= 0) and (LineNo < Length(r_Press)) then
    str(r_Press[LineNo]:6:2, s1)
  else
    s1 := '0.00';
  SMemoMsg := SMemoMsg + ', ' + s1 + ', "P"';
//  Memo1.Lines.Add(SMemoMsg);
end;

procedure TMainForm.NoteTroughClick(Sender: TObject);
var
  LineNo : integer;
  s1, SMemoMsg : string;
begin
  str(CurImage, s1);
  SMemoMsg := s1;
  LineNo := PrImgOffset+(CurImage*2);
  if (LineNo >= 0) and (LineNo < Length(r_Press)) then
    str(r_Press[LineNo]:6:2, s1)
  else
    s1 := '0.00';
  SMemoMsg := SMemoMsg + ', ' + s1 + ', "T"';
//  Memo1.Lines.Add(SMemoMsg);
end;

procedure TMainForm.NoteSpeed1Click(Sender: TObject);
var
  s1, SMemoMsg : string;
  Dist, Speed, Direct : real;
begin
  Dist := sqrt(sqr(xCursor-xStored) + sqr(yCursor-yStored));
  if CurImage <> cStored then
    Speed := Dist/(CurImage-cStored)
  else
    Speed := 0.0;
  if (xCursor-xStored) <> 0 then
    Direct := arctan2(yStored-yCursor, xCursor-xStored)
  else if (yStored-yCursor) > 0 then
    Direct := PI/2.0
  else
    Direct := -1.0*PI/2.0;
  Direct := 180.0*Direct/PI;
  str(CurImage, s1);
  SMemoMsg := s1;
  str(xCursor, s1);
  SMemoMsg := SMemoMsg + ', ' + s1;
  str(yCursor, s1);
  SMemoMsg := SMemoMsg + ', ' + s1;
  str(Dist:6:1, s1);
  SMemoMsg := SMemoMsg + ',' + s1;
  str(Speed:6:1, s1);
  SMemoMsg := SMemoMsg + ',' + s1;
  str(Direct:6:1, s1);
  SMemoMsg := SMemoMsg + ',' + s1;
//  Memo1.Lines.Add(SMemoMsg);
  cStored := CurImage;
  xStored := xCursor;
  yStored := yCursor;
end;

procedure TMainForm.CutItemClick(Sender: TObject);
begin
//  Memo1.Clear;
end;

procedure TMainForm.CopyItemClick(Sender: TObject);
begin
//  Memo1.SelectAll;
//  Memo1.CopyToClipboard;
//  Memo1.SelLength := 0;
end;

procedure TMainForm.Anchor11Click(Sender: TObject);
begin
  CCLx := xCursor;
  CCLy := yCursor;
  with MainClient.Canvas do
    begin
      Pen.Color := clWhite;
      MoveTo(CCLx-5,CCLy+5);
      LineTo(CCLx+6,CCLy-6);
      MoveTo(CCLx-5,CCLy-5);
      LineTo(CCLx+6,CCLy+6);
    end;
  MapFrm.ClearMap;
end;

procedure TMainForm.Anchor21Click(Sender: TObject);
begin
  CCRx := xCursor;
  CCRy := yCursor;
  with MainClient.Canvas do
    begin
      Pen.Color := clWhite;
      MoveTo(CCRx-5,CCRy+5);
      LineTo(CCRx+6,CCRy-6);
      MoveTo(CCRx-5,CCRy-5);
      LineTo(CCRx+6,CCRy+6);
    end;
  MapFrm.ClearMap;
end;
{==============================================================================}
procedure TMainForm.MenuItem1Click(Sender: TObject);
begin
  if SmoothInputDlg.GetSmoothInfo(SmoothFlag, TrendFlag) then ;
end;

procedure TMainForm.MaskMenuClick(Sender: TObject);
begin

end;

end.
