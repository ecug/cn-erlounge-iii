unit main5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, StdCtrls, ExtCtrls, StrUtils,
  SHDocVw_EWB, EwbCore, EmbeddedWB,
  Project5_TLB, mess_m, ReceiveThread;

type
  TMainForm = class(TForm)
    WB: TEmbeddedWB;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure WBGetExternal(Sender: TCustomEmbeddedWB;
      var ppDispatch: IDispatch);
  private
    { Private declarations }
    FRecThread : TReceiveThread;
    FServerMessenger : WideString;
    ISelf : IMessManager;
    procedure WMUserList_Data(var Message: TMessage); message WM_USERLIST_DATA;
  public
    property ServerMessenger:WideString read FServerMessenger;
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation
{$R *.dfm}

uses main5_f;

function TransitionUrl(url: String): String;
var
  curr : String;
begin
  curr := 'file:///' + ReplaceText(ExtractFileDir(ParamStr(0)), '\', '/');
  Result := curr + url;
end;

procedure TMainForm.WBGetExternal(Sender: TCustomEmbeddedWB;
  var ppDispatch: IDispatch);
begin
  ppDispatch := ISelf;
end;

procedure TMainForm.WMUserList_Data(var Message: TMessage);
var
  p : PAnsiChar;
begin
  p := Pointer(Message.WParam);
  FServerMessenger := p;
  StrDispose(p);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // WB.external
  ISelf := TMessManager.Create(Self);

  // connect to server, and Send/Receive loop
  sys_init;
  FRecThread := TReceiveThread.Create(sys_conn, Self.Handle);
  Timer.Enabled := true;

  // open url
  WB.Navigate(TransitionUrl('/SampleHtml/MsgMgr.html'));
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  if FRecThread.ConnectedFd > 0 then
    msg_sender_t(FRecThread.ConnectedFd);
end;

end.
