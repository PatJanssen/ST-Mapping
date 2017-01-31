unit InfoDialog;

{$MODE Delphi}

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Common;

type

  { TInfoDlg }

  TInfoDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    OKButton: TButton;
    function ShowInformation(SourceFN : string; ImageType : TImageType; ImgWidth, ImgHgt : integer) : boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoDlg: TInfoDlg;

implementation

{$R *.lfm}

{ TInfoDlg }

function TInfoDlg.ShowInformation(SourceFN : string; ImageType : TImageType; ImgWidth, ImgHgt : integer) : boolean;
var
  s1, s2 : string;
begin
  Label2.Caption := SourceFN;
  case ImageType of
    PlainImg : Label4.Caption := 'Plain image or unknown map';
    DiaMap : Label4.Caption := 'Diameter or radius map';
    DiaFilt : Label4.Caption := 'Filtered map';
    DispLOI : Label4.Caption := 'Displacement map along user-specified LOI';
    StRtLOI : Label4.Caption := 'Strain rate map along user-specified LOI';
    MapKey : Label4.Caption := 'Key';
    PubLOI : Label4.Caption := 'Published strain rate map along user-specified LOI';
    PubImap : Label4.Caption := 'Published intensity map along user-specified LOI';
    PubDmap : Label4.Caption := 'Published diameter or radius map';
    DispArc : Label4.Caption := 'Longitudinal displacement map along arc-shaped ROI';
    StRtArc : Label4.Caption := 'Longitudinal strain rate map along arc-shaped ROI';
    StRtRad : Label4.Caption := 'Radial strain rate map along arc-shaped ROI';
    StRtRect : Label4.Caption := 'Strain rate map from rectangular ROI';
    PubLArc : Label4.Caption := 'Published longitudinal strain rate map along arc-shaped ROI';
    PubRad : Label4.Caption := 'Published radial strain rate map along arc-shaped ROI';
    PubRect : Label4.Caption := 'Published strain rate map from rectangular ROI';
  else
    Label4.Caption := 'Unknown';
  end; {case}
  str(ImgWidth, s1);
  str(ImgHgt, s2);
  Label6.Caption := s1+'x'+s2;
  if ShowModal = mrOK then ;
end;

end.
 
