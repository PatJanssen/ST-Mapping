unit LinkDialog;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, MaskEdit;

type

  { TLinkInputDlg }

  TLinkInputDlg = class(TForm)
    Bevel2: TBevel;
    Edit3: TEdit;
    Edit4: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    function GetLink(var DataLine : integer; var ImageNo : integer; var ImageFreq : integer; InEvery : integer): Boolean;
  end;

var
  LinkInputDlg: TLinkInputDlg;

implementation

{$R *.lfm}

function TLinkInputDlg.GetLink(var DataLine : integer; var ImageNo : integer; var ImageFreq : integer; InEvery : integer): Boolean;
var
  nv, Err : Integer;
  s1 : string;
begin
  Edit1.Text := '0';
  Edit2.Text := '0';
  Str(ImageFreq, s1);
  Edit3.Text := s1;
  Str(InEvery, s1);
  Edit4.Text := s1; // Displayed only
  if ShowModal = mrOK then
    begin
      GetLink := true;
      s1 := Edit1.Text;
      while (ord(s1[1]) = 32) do Delete(s1, 1 ,1);
      Val(s1, nv, Err);
      if Err <> 0 then
        begin
          GetLink := false;
          exit;
        end;
      DataLine := nv;
      s1 := Edit2.Text;
      while (ord(s1[1]) = 32) do Delete(s1, 1 ,1);
      Val(s1, nv, Err);
      if Err <> 0 then
        begin
          GetLink := false;
          exit;
        end;
      ImageNo := nv;
      s1 := Edit3.Text;
      while (ord(s1[1]) = 32) do Delete(s1, 1 ,1);
      Val(s1, nv, Err);
      if Err <> 0 then
        begin
          GetLink := false;
          exit;
        end;
      ImageFreq := nv;
    end
  else
    GetLink := false;
end;

end.
