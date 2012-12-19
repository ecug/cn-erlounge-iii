unit ReceiveThread;

interface

uses
  Windows, Messages, SysUtils, Classes,
  EiDelphi, ErlDelphi,
  mess_m;

const
  WM_USERLIST_DATA = WM_USER + 100;

type
  TReceiveThread = class(TThread)
  protected
    Ffd : Integer;
    Fwnd : HWND;
    procedure Execute; override; // This never runs.
  public
    constructor Create(fd:Integer; wnd:HWND);
    property ConnectedFd : Integer read Ffd;
  end;

implementation

constructor TReceiveThread.Create(fd:Integer; wnd:HWND);
begin
  Ffd := fd;
  Fwnd := wnd;
  inherited Create(False);
end;

(* --->
   sys_init();
   fd := sys_conn();
-> Start ReceiveThread;  // enter executor.
*)
procedure TReceiveThread.Execute;
const
  receive_buff_length = 1024*2;
var
  msg : ErlMessage;
  buf : pointer;
  got, fd : Integer;
  data1 : pansichar;
  data2 : pansichar;
  fromp, listp : PETERM;
begin
  buf := erl_malloc(receive_buff_length);
  repeat
    got := erl_receive_msg(Ffd, buf, receive_buff_length, @msg);
    case got of
      ERL_TICK :; // continue
      ERL_ERROR: alert_error('receive msg...');
    else    // ERL MSG with a Emsg struct
      case msg.type_ of
        EiDelphi.ERL_SEND,
        EiDelphi.ERL_REG_SEND:
        begin
          // get call info.
          fromp := erl_element(1, msg.msg);    // {messenger, Result}
          listp := erl_element(2, msg.msg);

          // trans message
          data1 := erl_iolist_to_string(listp);
          data2 := StrNew(data1);
          // erl_free(data1);  // skip? why?
          PostMessageA(Fwnd, WM_USERLIST_DATA, Cardinal(data2), 0);

          // clear
          erl_free_term(msg.to_);
          erl_free_term(msg.msg);
          erl_free_term(fromp);
          erl_free_term(listp);
        end;
      end;
    end;
  until Terminated;

  fd := ConnectedFd;
  Ffd := -1;
  erl_close_connection(fd);
  erl_free(buf);
end;

end.