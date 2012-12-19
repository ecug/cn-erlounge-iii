unit mess_m;

interface

uses
  EiDelphi,
  ErlDelphi,
  Classes;

type
  TERROR_NOTIFY = procedure(err: String);

var
  SYS_ERROR_NOTIFY : TERROR_NOTIFY;

procedure alert_error(err: String='');

function sys_init: boolean;
function sys_conn: Integer;
procedure sys_exit;

// for test demo
procedure msg_sender_t(fd:Integer);

implementation

const
  hostname = 'AIMINGPAD';
  alivename = 'dnode';
  cookie = 'JWRKJTKHMIMBRHCFAXZL';
  nodename = alivename + '@' + hostname;

  connect_host = 'aimingoo-desktop'; // set s_ipaddr for this host name
  connect_to = 'messenger';  // will conntect to <connect_to>@<s_ipaddr>

var
  fd : Integer;
  ipaddr : TInAddr = (S_un_b: (s_b1: 127; s_b2: 0; s_b3:0; s_b4: 1));
  s_ipaddr : TInAddr = (S_un_b: (s_b1: 192; s_b2: 168; s_b3:10; s_b4: 89));

procedure alert_error(err: String='');
begin
  if assigned(SYS_ERROR_NOTIFY) then
    SYS_ERROR_NOTIFY(err);
end;

function self_pid(fd: Integer): PETERM;
begin
  Result := erl_mk_pid(erl_thisnodename, fd, 0, erl_thiscreation);
end;

function sys_init: boolean;
begin
  erl_init;

  // re-write configs
  // ..

  Result := true;
end;

// return a fd(open file descriptor).
function sys_conn: Integer;
begin
  Result := erl_connect_xinit(hostname, alivename, nodename, @ipaddr, cookie, 0);
  if Result = ERL_ERROR then alert_error('connect init...');
  Result := erl_xconnect(@s_ipaddr, connect_to);
  if Result = ERL_ERROR then alert_error('connect...');
end;

procedure sys_exit;
begin
  // ...
end;

(******************************************************************************
 ***
 *** test for messeng send and receive
 ***
 ******************************************************************************)

function make_msg_t(fd:Integer): PETERM;
var
  selfp: PETERM;
  tp : PETERMLIST;
begin
  SetLength(tp, 2);

  selfp := self_pid(fd);
  tp[0] := selfp;
  tp[1] := erl_mk_atom('user_list');
  Result := erl_mk_tuple(Pointer(tp), 2);
  tp[1] := Result;
  Result := erl_mk_tuple(Pointer(tp), 2);

  SetLength(tp, 0);
end;

procedure msg_sender_t(fd:Integer);
var
  msgp : PETERM;
  r : Integer;
begin
  msgp := make_msg_t(fd);
  r := erl_reg_send(fd, 'messenger', msgp);
  if r = ERL_ERROR then alert_error('send msg...');
  erl_free_term(msgp);
end;

end.
