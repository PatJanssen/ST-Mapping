unit DumpDialog;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit, FileCtrl;

type
  TDumpInputDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Label3: TLabel;
    Edit3: TEdit;
    BrowseButton: TButton;
    procedure BrowseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetDumpInfo(var OnOff : boolean; var StartImg : integer; var EndImg : integer; var SaveDir : string): Boolean;
  end;

var
  DumpInputDlg: TDumpInputDlg;

implementation

{$R *.lfm}

function TDumpInputDlg.GetDumpInfo;
var
  nv, Err : Integer;
  s : string;
begin
  CheckBox1.Checked := OnOff;
  Str(StartImg, s);
  Edit1.Text := s;
  Str(EndImg, s);
  Edit2.Text := s;
  Edit3.Text := SaveDir;
  if ShowModal = mrOK then
    begin
      GetDumpInfo := true;
      OnOff := CheckBox1.Checked;
      s := Edit1.Text;
      while (ord(s[1]) = 32) do Delete(s, 1 ,1);
      Val(s, nv, Err);
      if Err = 0 then StartImg := nv;
      s := Edit2.Text;
      while (ord(s[1]) = 32) do Delete(s, 1 ,1);
      Val(s, nv, Err);
      if Err = 0 then EndImg := nv;
      SaveDir := Edit3.Text;
    end
  else
    GetDumpInfo := false;
end;

procedure TDumpInputDlg.BrowseButtonClick(Sender: TObject);
var MyDir : string;
begin
  MyDir := Edit3.Text;
{  if SelectDirectory('Dump Folder','C:',MyDir) then Edit3.Text := MyDir;}
end;

end.
