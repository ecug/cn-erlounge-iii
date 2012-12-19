{$APPTYPE CONSOLE}
{$RANGECHECKS OFF}

(*
  change directory to <erlang demo with delphi at srv>, and
  C:> werl -sname messenger
  > messenger_app:start_server(messenger_m).

  C:> werl -sname cli1
  > messenger_cli:logon("aimingoo").

  C:> werl -sname cli2
  > messenger_cli:logon("cat").
  > messenger_cli:message("aimingoo", "muh").
*)

program server_manager_c;

uses
  SysUtils,
  WinSock,
  EiDelphi in 'EiDelphi.pas',
  ErlDelphi in 'ErlDelphi.pas';

const
  hostname = 'AIMINGPAD';
  alivename = 'dnode';
  cookie = 'JWRKJTKHMIMBRHCFAXZL';
  nodename = alivename + '@' + hostname;

  connect_host = 'aimingoo-desktop'; // set s_ipaddr for this host name
  connect_to = 'messenger';  // will conntect to <connect_to>@<s_ipaddr>

var
  ipaddr : TInAddr = (S_un_b: (s_b1: 127; s_b2: 0; s_b3:0; s_b4: 1));
  s_ipaddr : TInAddr = (S_un_b: (s_b1: 192; s_b2: 168; s_b3:10; s_b4: 89));
  fd : Integer;

  buf : AnsiString;
  msg : ErlMessage;
  pmsg: ErlMessage_p;

  got : Integer;
  destp, msgp, selfp : PETERM;
  fromp, listp : PETERM;

  func_name: String;
  func_value: Integer;
  tp : PETERMLIST;

  r : Integer;

procedure alert_error(err: String='');
begin
  writeln(format('>>> Error(%d): %s', [erl_errno, err]));
  readln;
  halt(0);
end;

var
  _NULL : PETERM = nil;
function NulArg: PETERM;
begin
  if _NULL = nil then
    // _NULL := erl_format('[]', []);
    _NULL := erl_mk_empty_list;
  Result := _NULL;
end;

function self_pid(fd: Integer): PETERM;
begin
  Result := erl_mk_pid(erl_thisnodename, fd, 0, erl_thiscreation);
end;

begin
  erl_init;
  r := erl_connect_xinit(hostname, alivename, nodename, @ipaddr, cookie, 0);
  if r = ERL_ERROR then alert_error('connect init...');

  writeln('node: ', erl_thisnodename, erl_thishostname:20, erl_thisalivename:10, '  ', erl_thiscookie);
//  fd := erl_connect(connect_to);
  fd := erl_xconnect(@s_ipaddr, connect_to);
  if fd = ERL_ERROR then alert_error('connect...');

  // get connected node's name
  destp := erl_rpc(fd, 'erlang', 'self', NulArg);
  selfp := self_pid(fd);

  // msgp := erl_format('{~w, {~w, ~a}}', [selfp, selfp, 'user_list']);
  // -  or call erl_mk_XXXXX().
  setlength(tp,2);
  tp[0] := selfp;
  tp[1] := erl_mk_atom('user_list');
  msgp := erl_mk_tuple(Pointer(tp), 2);
  tp[1] := msgp;
  msgp := erl_mk_tuple(Pointer(tp), 2);

  r := erl_reg_send(fd, 'messenger', msgp);
(* send test, success:
  msgp := erl_mk_atom('hello!');
  r := erl_reg_send(fd, 'messenger', msgp);
  // but, why not?
  // r := erl_send(fd, destp, msgp);
*)
  if r = ERL_ERROR then alert_error('send msg...');

  writeln('Receive messages from other node...');
  SetLength(buf, 1024);
  fillchar(msg, sizeof(msg), 0);
  pmsg := @msg;
  while True do
  try
    got := erl_receive_msg(fd, PAnsiChar(buf), Length(buf), pmsg);
    case got of
      ERL_TICK : begin writeln('tick...'); continue; end;
      ERL_ERROR: alert_error;
    else    // ERL MSG with a Emsg struct
      case msg.type_ of
        EiDelphi.ERL_SEND,
        EiDelphi.ERL_REG_SEND:
        begin
          writeln('got messages!');

          // get call info.
          fromp := erl_element(1, msg.msg);    // {messenger, Result}
          listp := erl_element(2, msg.msg);

          // show list as string
          writeln(erl_iolist_to_string(listp));

          // clear
          erl_free_term(msg.from);
          erl_free_term(msg.msg);
          erl_free_term(fromp);
          erl_free_term(listp);

          sleep(5*1000);
          erl_reg_send(fd, 'messenger', msgp);
        end;
      else // ERL_SEND, ERL_LINK, ERL_UNLINK and ERL_EXIT
        writeln('unknow msg type:', msg.type_ );
      end;
    end;
  except
    on e:exception do
      writeln('>>> Error: ', e.Message);
  end;

readln;
end.
