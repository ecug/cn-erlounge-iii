// erl_interface.h
{$DEFINE _ERL_INTERFACE_H}

{ $DEFINE USE_EI_UNDOCUMENTED}

unit ErlDelphi;

interface

uses
  Types, Math, SysUtils, WinSock,
  EiDelphi;

const
  LIB_EI = 'erl.dll';
  LIB_ERL = 'erl.dll';

{ $L ei.lib}
{ $L erl_interface.lib}

const
  CERL_COMPOUND    = 1 shl 7;
  CERL_UNDEF       =  0;
  CERL_INTEGER     =  1;
  CERL_U_INTEGER   =  2; // unsigned int
  CERL_ATOM        =  3;
  CERL_PID         =  4;
  CERL_PORT        =  5;
  CERL_REF         =  6;
  CERL_CONS        =  7 + CERL_COMPOUND;
  CERL_LIST        =  CERL_CONS;
  CERL_NIL         =  8;
  CERL_EMPTY_LIST  =  CERL_NIL;
  CERL_TUPLE       =  9 + CERL_COMPOUND;
  CERL_BINARY      = 10;
  CERL_FLOAT       = 11;
  CERL_VARIABLE    = 12 + CERL_COMPOUND; // used in patterns
  CERL_SMALL_BIG   = 13;
  CERL_U_SMALL_BIG = 14;
  CERL_FUNCTION    = 15 + CERL_COMPOUND;
  CERL_BIG         = 16;

  MAXREGLEN       = 255;  // max length of registered (atom) name
  MAXELMLEN       = 1024*4;  // ext. by aimingoo

type
  ERL_TYPES = (
    ET_UNDEF,
    ET_INTEGER,
    ET_ATOM,
    ET_PID,
    ET_PORT,
    ET_REF,
    ET_EMPTY_LIST,
    ET_LIST,
    ET_TUPLE,
    ET_FLOAT,
    ET_BINARY,
    ET_FUNCTION
  );

type
  Erl_Header = packed record
    count: array [0..2] of byte;
    type_: byte;
  end;

  Erl_Integer = packed record
    h: Erl_Header;
    i: Integer;
  end;

  Erl_Uinteger = packed record
    h: Erl_Header;
    u: Cardinal;
  end;

  Erl_Float = packed record
    h: Erl_Header;
    f: Double;
  end;

  Erl_Atom = packed record
    h: Erl_Header;
    len: Integer;
    a: PAnsiChar;
  end;

  Erl_Pid = packed record
    h: Erl_Header;
    node: PAnsiChar;
    number: Cardinal;
    serial: Cardinal;
    creation: BYTE;
  end;

  Erl_Port = packed record
    h: Erl_Header;
    node: PAnsiChar;
    number: Cardinal;
    creation: BYTE;
  end;

(* ???
  unsigned int n[3];
*)
  Erl_Ref = packed record
    h: Erl_Header;
    node: PAnsiChar;
    len: Integer;
    n: array [0.. 3-1] of Cardinal;
    creation: BYTE;
  end;

  Erl_Big = packed record
    h: Erl_Header;
    arity: Integer;
    is_neg: Integer;
    digits: PWORD;
  end;

  PETERM = ^ETERM;
  PETERMS = ^ETERMS;
  PETERMLIST = array of PETERM;

  Erl_List = packed record
    h: Erl_Header;
    head: PETERM;
    tail: PETERM;
  end;

  Erl_EmptyList = packed record
    h: Erl_Header;
  end;

  Erl_Tuple = packed record
    h: Erl_Header;
    size: Integer;
    elems: PETERMS;
  end;

  Erl_Binary = packed record
    h: Erl_Header;
    size: Integer;
    b: PAnsiChar;
  end;

(*
/* Variables may only exist in patterns.
 * Note: identical variable names in a pattern
 * denotes the same value.
 */
*)
  Erl_Variable = packed record
    h: Erl_Header;
    len: Integer;
    name: PAnsiChar;
    v: PETERM;
  end;

  Erl_Function = packed record
      h: Erl_Header;
      size: Integer;		// size of closure
      arity: Integer;		// arity for new (post R7) external funs
      md5: array [0..16-1] of AnsiChar; // md5 for new funs
      new_index: Integer;	// new funs
      creator: PETERM;	// pid
      module: PETERM;	// module
      index: PETERM;
      uniq: PETERM;
      closure: PETERMS;
  end;

  _eterm = packed record
    case byte of
      1 : (ival    : Erl_Integer);
      2 : (uival   : Erl_Uinteger);
      3 : (fval    : Erl_Float);
      4 : (aval    : Erl_Atom);
      5 : (pidval  : Erl_Pid);
      6 : (portval : Erl_Port);
      7 : (refval  : Erl_Ref);
      8 : (lval    : Erl_List);
      9 : (nval    : Erl_EmptyList);
      10: (tval    : Erl_Tuple);
      11: (bval    : Erl_Binary);
      12: (vval    : Erl_Variable);
      13: (funcval : Erl_Function);
      14: (bigval  : Erl_Big);
  end;

  ETERM = _eterm;
  ETERMS = array [0..MAXELMLEN-1] of PETERM;

  ErlMessage = packed record
    type_: Integer;   // one of the message type constants in eiext.h
    msg: PETERM; // the actual message
    from: PETERM;
    to_: PETERM;
    to_name: array [0..MAXREGLEN] of AnsiChar;
  end;

  Erl_Heap = BYTE;

type
  ErlMessage_p = ^ErlMessage;
  ErlConnect_p = ^ErlConnect;
  Erl_Heap_p = ^Erl_Heap;
  PPBYTE = ^PBYTE;

(*
/* -------------------------------------------------------------------- */
/*                          The functions                               */
/* -------------------------------------------------------------------- */
*)
procedure erl_init; overload;
procedure erl_init(P:Pointer; I:Integer=0); cdecl; external LIB_ERL; overload;
procedure erl_set_compat_rel(release_number: LongInt); cdecl; external LIB_ERL;


(*******************************************************************************
 **                     erl_connect functions
 *******************************************************************************)
function erl_connect_init(num: Integer; cookie: PAnsiChar=nil; creation: ShortInt=0): Integer; cdecl; external LIB_ERL;
function erl_connect_xinit(host, alive, node: PAnsiChar; addr: PInAddr; cookie: PAnsiChar=nil; creation: ShortInt=0): Integer; cdecl; external LIB_ERL;
function erl_connect(node: PAnsiChar): Integer; cdecl; external LIB_ERL;
function erl_xconnect(addr: PInAddr; alive:PAnsiChar): Integer; cdecl; external LIB_ERL;

function erl_close_connection(fd: Integer): Integer; cdecl; external LIB_ERL;
function erl_receive(fd:Integer; bufp: PAnsiChar; bufsize: Integer): Integer; cdecl; external LIB_ERL;
function erl_receive_msg(fd:Integer; bufp: PAnsiChar; bufsize: Integer; emsg: ErlMessage_p): Integer; cdecl; external LIB_ERL;
function erl_xreceive_msg(fd:Integer; bufpp: PPAnsiChar; bufsizep: PInteger; emsg: ErlMessage_p): Integer; cdecl; external LIB_ERL;
function erl_send(fd:Integer; to_, msg: PETERM): Integer; cdecl; external LIB_ERL;
function erl_reg_send(fd: Integer; to_: PAnsiChar; msg: PETERM): Integer; cdecl; external LIB_ERL;
function erl_rpc(fd: Integer; model, fun: PAnsiChar; args: PETERM): PETERM; cdecl; external LIB_ERL;
function erl_rpc_to(fd: Integer; model, fun: PAnsiChar; args: PETERM): Integer; cdecl; external LIB_ERL;
function erl_rpc_from(fd: Integer; timeout: Integer;  emsg: ErlMessage_p): Integer; cdecl; external LIB_ERL;

// erl_publish returns open descriptor on success, or -1
function erl_publish(port: Integer): Integer; cdecl; external LIB_ERL;
function erl_accept(listensock: Integer;  conp: ErlConnect_p): Integer; cdecl; external LIB_ERL;

function erl_thiscookie: PAnsiChar; cdecl; external LIB_ERL;
function erl_thisnodename: PAnsiChar; cdecl; external LIB_ERL;
function erl_thishostname: PAnsiChar; cdecl; external LIB_ERL;
function erl_thisalivename: PAnsiChar; cdecl; external LIB_ERL;
function erl_thiscreation: ShortInt; cdecl; external LIB_ERL;

(*******************************************************************************
 **                     erl_error functions
 *******************************************************************************)
// returns 0 on success, -1 if node not known to epmd or epmd not reached
function  erl_unpublish(const alive: PAnsiChar): Integer; cdecl; external LIB_ERL;

// Report generic error to stderr.
procedure erl_err_msg(const fmt: string; args: array of const);
// Report generic error to stderr and die.
procedure erl_err_quit(const fmt: string; args: array of const);
// Report system/libc error to stderr.
procedure erl_err_ret(const fmt: string; args: array of const);
// Report system/libc error to stderr and die.
procedure erl_err_sys(const fmt: string; args: array of const);


(*******************************************************************************
 **                     erl_eterm functions
 *******************************************************************************)
function erl_cons(head, tail: PETERM): PETERM; cdecl; external LIB_ERL;
function erl_copy_term(const term: PETERM): PETERM; cdecl; external LIB_ERL;
function erl_element(position: Integer; const tuple:PETERM): PETERM; cdecl; external LIB_ERL;

function erl_hd(const list: PETERM): PETERM; cdecl; external LIB_ERL;
function erl_iolist_to_binary(const term: PETERM): PETERM; cdecl; external LIB_ERL;
function erl_iolist_to_string(const list: PETERM): PAnsiChar; cdecl; external LIB_ERL;
function erl_iolist_length(const list: PETERM): Integer; cdecl; external LIB_ERL;
function erl_length(const list: PETERM): Integer; cdecl; external LIB_ERL;

function erl_mk_atom(const str: PAnsiChar): PETERM; cdecl; external LIB_ERL;
function erl_mk_binary(const bptr: PAnsiChar; size: Integer): PETERM; cdecl; external LIB_ERL;
function erl_mk_empty_list(): PETERM; cdecl; external LIB_ERL;
function erl_mk_estring(const str: PAnsiChar; len: Integer): PETERM; cdecl; external LIB_ERL;
function erl_mk_float(f: double): PETERM; cdecl; external LIB_ERL;
function erl_mk_int(n: Integer): PETERM; cdecl; external LIB_ERL;
function erl_mk_list(arr: PETERMS; arrsize: Integer): PETERM; cdecl; external LIB_ERL;
function erl_mk_pid(const node: PAnsiChar; num: Cardinal; serial: Cardinal; creation: BYTE): PETERM; cdecl; external LIB_ERL;
function erl_mk_port(const node: PAnsiChar; num: Cardinal; creation: BYTE): PETERM; cdecl; external LIB_ERL;
function erl_mk_ref(const node: PAnsiChar; num: Cardinal; creation: BYTE): PETERM; cdecl; external LIB_ERL;
function erl_mk_long_ref(const node: PAnsiChar; n1, n2, n3: Cardinal; creation: BYTE): PETERM; cdecl; external LIB_ERL;
function erl_mk_string(const str: PAnsiChar): PETERM; cdecl; external LIB_ERL;
function erl_mk_tuple(arr: PETERMS; arrsize: Integer): PETERM; cdecl; external LIB_ERL;
function erl_mk_uint(n: Cardinal): PETERM; cdecl; external LIB_ERL;
function erl_mk_var(const name: PAnsiChar): PETERM; cdecl; external LIB_ERL;

// TTextRec(text), ref with pointer
function erl_print_term(const stream: text; const term: PETERM): Integer; cdecl; external LIB_ERL;
// int    erl_sprint_term(char*,const ETERM*)
function erl_size(const term: PETERM): Integer; cdecl; external LIB_ERL;
function erl_tl(const list: PETERM): PETERM; cdecl; external LIB_ERL;
function erl_var_content(const term: PETERM; const name: PAnsiChar): PETERM; cdecl; external LIB_ERL;


(*******************************************************************************
 **                     erl_format functions
 *******************************************************************************)
function erl_format(fmt: String; args: array of const): PETERM;
function erl_match(Pattern: PETERM; Term: PETERM): Integer; cdecl; external LIB_ERL;


(*******************************************************************************
 **                     erl_global functions
 *******************************************************************************)
function erl_global_names(fd: Integer; count: PInteger): PPAnsiChar; cdecl; external LIB_ERL;
function erl_global_register(fd: Integer; const name: PAnsiChar; pid: PETERM): Integer; cdecl; external LIB_ERL;
function erl_global_unregister(fd: Integer; const name: PAnsiChar): Integer; cdecl; external LIB_ERL;
function erl_global_whereis(fd: Integer; const name: PAnsiChar; node: PAnsiChar): PETERM; cdecl; external LIB_ERL;


(*******************************************************************************
 **                     erl_malloc functions
 *******************************************************************************)
procedure erl_init_malloc(heap: Erl_Heap_p; n: LongInt); cdecl; external LIB_ERL;
function erl_alloc_eterm(etype: BYTE): PETERM; cdecl; external LIB_ERL;  // CERL_xxx types
procedure erl_eterm_release; cdecl; external LIB_ERL;
procedure erl_eterm_statistics(allocated, freed: PLongInt); cdecl; external LIB_ERL;
procedure erl_free_array(arr: PETERMS; size: Integer); cdecl; external LIB_ERL;
procedure erl_free_term(t: PETERM); cdecl; external LIB_ERL;
procedure erl_free_compound(t: PETERM); cdecl; external LIB_ERL;
function erl_malloc(size: LongInt): Pointer; cdecl; external LIB_ERL;
procedure erl_free(const ptr); cdecl; external LIB_ERL;


(*******************************************************************************
 **                     erl_marshal functions
 *******************************************************************************)
function erl_compare_ext(bufp1, bufp2: PBYTE): Integer; cdecl; external LIB_ERL;
function erl_decode(bufp: PBYTE): PETERM; cdecl; external LIB_ERL;
function erl_decode_buf(bufpp: PPBYTE): PETERM; cdecl; external LIB_ERL;
function erl_encode(term: PETERM; bufp: PBYTE): Integer; cdecl; external LIB_ERL;
function erl_encode_buf(term: PETERM; bufpp: PPBYTE): Integer; cdecl; external LIB_ERL;
function erl_ext_size(bufp: PBYTE): Integer; cdecl; external LIB_ERL;
function erl_ext_type(bufp: PBYTE): BYTE; cdecl; external LIB_ERL; //* Note: returned 'char' before R9C
function erl_peek_ext(bufp: PBYTE; size: Integer): PBYTE; cdecl; external LIB_ERL;
function erl_term_len(t: PETERM): Integer; cdecl; external LIB_ERL;

{$IFDEF USE_EI_UNDOCUMENTED}
  {$I UNDOCUMENTED_ERL.INC}
{$ENDIF}

implementation

uses
  c_params;

procedure initWinSock;
{$J+}
const
  initialized: boolean = false;
  VersionRequested: WORD = $0101; // MAKEWORD(1,1), version 1.1
var
  aWsaData: WSADATA;
  err: Integer;
begin
    if not initialized then
    begin
      initialized := true;
      err := WSAStartup(VersionRequested, aWsaData);
{$IFDEF DEBUG}
      if (err <> 0) then
      begin
        writeln('erl_call: Can''t initialize windows sockets: ', err);
      end
      else
{$ENDIF}
      if aWsaData.wVersion <> VersionRequested then
      begin
{$IFDEF DEBUG}
        writeln('erl_call: This version of windows sockets not supported.');
{$ENDIF}
        WSACleanup();
      end;
    end;
end;

procedure erl_init;
begin
  initWinSock;
  erl_init(nil, 0);
end;

(*
function erl_connect_xinit(host, alive, node: PAnsiChar; addr: PInAddr; cookie: PAnsiChar; creation: ShortInt): Integer;
var N : ei_cnode;
begin
//  Result := ei_connect_xinit(@N, host, alive, node, addr, cookie, creation);
end;
*)

// ETERM *erl_format(PAnsiChar, ... ); cdecl;
function _erl_format(fmt: PAnsiChar; args: R_ARGS): PETERM; cdecl; external LIB_ERL name 'erl_format';
// new warp for delphi
function erl_format(fmt: String; args: array of const): PETERM;
begin
  Result := _erl_format(PAnsiChar(AnsiString(fmt)), FloatParams(args));
end;

// void   erl_err_msg(const char * __template, ...)
procedure _erl_err_msg(fmt: PAnsiChar; args: R_ARGS); cdecl; external LIB_ERL name 'erl_err_msg';
procedure erl_err_msg(const fmt: string; args: array of const);
begin
  _erl_err_msg(PAnsiChar(AnsiString(fmt)), FloatParams(args));
end;

// void   erl_err_quit(const char * __template, ...)
procedure _erl_err_quit(fmt: PAnsiChar; args: R_ARGS); cdecl; external LIB_ERL name 'erl_err_quit';
procedure erl_err_quit(const fmt: string; args: array of const);
begin
  _erl_err_quit(PAnsiChar(AnsiString(fmt)), FloatParams(args));
end;

// void   erl_err_ret(const char * __template, ...)
procedure _erl_err_ret(fmt: PAnsiChar; args: R_ARGS); cdecl; external LIB_ERL name 'erl_err_ret';
procedure erl_err_ret(const fmt: string; args: array of const);
begin
  _erl_err_ret(PAnsiChar(AnsiString(fmt)), FloatParams(args));
end;

// void   erl_err_sys(const char * __template, ...)
procedure _erl_err_sys(fmt: PAnsiChar; args: R_ARGS); cdecl; external LIB_ERL name 'erl_err_sys';
procedure erl_err_sys(const fmt: string; args: array of const);
begin
  _erl_err_sys(PAnsiChar(AnsiString(fmt)), FloatParams(args));
end;

end.
