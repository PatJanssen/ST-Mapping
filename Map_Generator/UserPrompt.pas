unit UserPrompt;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TPrompt = class(TForm)
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetMessage(p : Pchar);
  end;

var
  Prompt: TPrompt;

implementation

{$R *.lfm}

procedure TPrompt.SetMessage(p : Pchar);
var
  s : string;
begin
  s := StrPas(p);
  Label1.Caption := s;
end;

end.
