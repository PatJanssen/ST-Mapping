unit BitmapSaver;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  BGRABitmap, BGRABitmapTypes, Common;

type

  { TBmpSaveForm }

  TBmpSaveForm = class(TForm)
    ProgressBar1: TProgressBar;
    SaveDialog: TSaveDialog;
  private
    { private declarations }
  public
    { public declarations }
    procedure SaveToTiff(BmpSrc : TBGRABitmap; BmpType : TImageType);
  end;

var
  BmpSaveForm: TBmpSaveForm;

implementation

{$R *.lfm}

procedure TBmpSaveForm.SaveToTiff(BmpSrc : TBGRABitmap; BmpType : TImageType);
{ Save specified BGRA bitmap as a TIF file }
var
  F : file;
  FName : string;
  imgWidth, imgHeight, imult : integer;
  i, j : integer;
  Row : PBGRAPixel;
  buffer : array[0..6000] of byte;
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
  Visible := false;
  if SaveDialog.Execute then
    begin
      imgWidth := BmpSrc.Width;
      imgHeight := BmpSrc.Height;
      FName := SaveDialog.FileName;
      if pos('.',FName) = 0 then FName := FName + '.tif';
      AssignFile(F, FName);
      Rewrite(F, 1);
      BlockWrite(F, hdr, 10);
      WriteTag(254,4,1,0);
      WriteTag(256,3,1,imgWidth);
      WriteTag(257,3,1,imgHeight);
      WriteTag(258,3,1,8); {BPP}
      WriteTag(259,3,1,1);
      WriteTag(262,3,1,2); {RGB}
      case BmpType of
            DiaMap   : WriteTag(269,2,1,Ord('A'));
            DiaFilt  : WriteTag(269,2,1,Ord('B'));
            DispLOI  : WriteTag(269,2,1,Ord('C'));
            StRtLOI  : WriteTag(269,2,1,Ord('D'));
            MapKey   : WriteTag(269,2,1,Ord('E'));
            PubLOI   : WriteTag(269,2,1,Ord('F'));
            PubImap  : WriteTag(269,2,1,Ord('G'));
            PubDmap  : WriteTag(269,2,1,Ord('H'));
            DispArc  : WriteTag(269,2,1,Ord('I'));
            StRtArc  : WriteTag(269,2,1,Ord('J'));
            StRtRad  : WriteTag(269,2,1,Ord('K'));
            StRtRect : WriteTag(269,2,1,Ord('L'));
            PubLArc  : WriteTag(269,2,1,Ord('M'));
            PubRad   : WriteTag(269,2,1,Ord('N'));
            PubRect  : WriteTag(269,2,1,Ord('O'));
      else
            WriteTag(269,2,1,Ord('A'));
      end; {case}
      WriteTag(273,4,1,134); {start at byte 122}
      WriteTag(277,3,1,3); {SPP}
      WriteTag(278,3,1,imgHeight);
      BlockWrite(F, zero, 4);
      for j := 0 to imgHeight-1 do
        begin
          Row := BmpSrc.ScanLine[j];
              for i := 0 to imgWidth-1 do
                begin
                  buffer[i*3] := Row[i].red;
                  buffer[i*3+1] := Row[i].green;
                  buffer[i*3+2] := Row[i].blue;
                end;
              BlockWrite(F, buffer, imgWidth*3);
        end;
      CloseFile(F);
    end;
  Visible := false;
end;

end.

