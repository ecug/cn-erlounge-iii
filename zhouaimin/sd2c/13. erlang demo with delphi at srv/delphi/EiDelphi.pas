//  ei_connect.h
{$DEFINE EI_CONNECT_H}

// eicode.h
{$DEFINE EICODE_H}

// ei.h
{$DEFINE EI_H}
{ $DEFINE GNU_MP_VERSION}
{ $DEFINE USE_EI_UNDOCUMENTED}

unit EiDelphi;

interface

uses
  windows;

const
  LIB_EI = 'erl.dll';
  LIB_ERL = 'erl.dll';

(*
/* -------------------------------------------------------------------- */
/*                      socket base define                              */
/* -------------------------------------------------------------------- */
*)
//
type
  hostent = packed record
    h_name: PAnsiChar;             // official name of host
    h_aliases: PPAnsiChar;         // alias list
    h_addrtype: LongInt;       // host address type
    h_length: LongInt;         // length of address
    case byte of
       0: (h_addr_list: pPAnsiChar); // list of addresses from name server
       1: (h_addr: pPAnsiChar)       // address, for backward compatiblity
  end;
  phostent=^hostent;
  THostEnt = hostent;

type
  in_addr = packed record
  case Integer of
    1:(S_un_b:record s_b1,s_b2,s_b3,s_b4: Byte; end;);
    2:(s_un_w:record s_w1,s_w2: Word; end;);
    3:(s_addr: Cardinal);
  end;
  TInAddr = in_addr;
  PInAddr = ^TInAddr;

type
  Erl_IpAddr = ^in_addr;
  // Erl_IpAddr = PInAddr;
  h_errno = Integer;

(*
/* -------------------------------------------------------------------- */
/*                      Defines part of API                             */
/* -------------------------------------------------------------------- */

/*
 * Some error codes might be missing, so here's a backstop definitions
 * of the ones we use with `erl_errno':
 */

/* Message too long */
#define EMSGSIZE        EIO

/* Connection timed out */
#define ETIMEDOUT       EIO

/* No route to host */
#define EHOSTUNREACH    EIO
*)

// FIXME just a few are documented, does it mean they can't be returned?
const
  ERL_ERROR = -1;           // Error of some kind
  ERL_NO_DAEMON = -2;       // No contact with EPMD
  ERL_NO_PORT = -3;         // No port received from EPMD
  ERL_CONNECT_FAIL = -4;    // Connect to Erlang Node failed
  ERL_TIMEOUT = -5;         // A timeout has expired
  ERL_NO_REMOTE = -6;       // Cannot execute rsh

  ERL_TICK = 0;
  ERL_MSG = 1;

  ERL_NO_TIMEOUT = -1;

// these are the control message types
  ERL_LINK         = 1;
  ERL_SEND         = 2;
  ERL_EXIT         = 3;
  ERL_UNLINK       = 4;
  ERL_NODE_LINK    = 5;
  ERL_REG_SEND     = 6;

  ERL_GROUP_LEADER = 7;
  ERL_EXIT2        = 8;
  ERL_PASS_THROUGH_C = 'p';
  ERL_PASS_THROUGH = ORD('p');

// new ones for tracing, from Kenneth
  ERL_SEND_TT     = 12;
  ERL_EXIT_TT     = 13;
  ERL_REG_SEND_TT = 16;
  ERL_EXIT2_TT    = 18;

(*
/* -------------------------------------------------------------------- */
/*           Defines used for ei_get_type_internal() output             */
/* -------------------------------------------------------------------- */
/*
 * these are the term type indicators used in
 * the external (distribution) format
 */
*)

// FIXME we don't want to export these.....
  ERL_SMALL_INTEGER_EXT = 'a';
  ERL_INTEGER_EXT       = 'b';
  ERL_FLOAT_EXT         = 'c';
  ERL_ATOM_EXT          = 'd';
  ERL_REFERENCE_EXT     = 'e';
  ERL_NEW_REFERENCE_EXT = 'r';
  ERL_PORT_EXT          = 'f';
  ERL_PID_EXT           = 'g';
  ERL_SMALL_TUPLE_EXT   = 'h';
  ERL_LARGE_TUPLE_EXT   = 'i';
  ERL_NIL_EXT           = 'j';
  ERL_STRING_EXT        = 'k';
  ERL_LIST_EXT          = 'l';
  ERL_BINARY_EXT        = 'm';
  ERL_SMALL_BIG_EXT     = 'n';
  ERL_LARGE_BIG_EXT     = 'o';
  ERL_NEW_FUN_EXT	      = 'p';
  ERL_FUN_EXT           = 'u';
  ERL_NEW_CACHE         = 'N'; // c nodes don't know these two
  ERL_CACHED_ATOM       = 'C';

(*
/* -------------------------------------------------------------------- */
/*                      Type definitions                                */
/* -------------------------------------------------------------------- */

/*
 * To avoid confusion about the MAXHOSTNAMELEN when compiling the
 * library and when using the library we set a value that we use
 */
*)

const
  EI_MAXHOSTNAMELEN = 64;
  EI_MAXALIVELEN = 63;
  EI_MAX_COOKIE_SIZE = 512;
  MAXATOMLEN = 255;
  MAXNODELEN = EI_MAXALIVELEN+1+EI_MAXHOSTNAMELEN;

type
  (* a pid *)
  erlang_pid = packed record
    node: array [0..MAXATOMLEN] of AnsiChar;
    num: DWORD;
    serial: DWORD;
    creation: DWORD;
  end;

  (* a port *)
  erlang_port = packed record
    node : array [0..MAXATOMLEN] of AnsiChar;
    id : DWORD;
    creation : DWORD;
  end;

  (* a ref *)
  erlang_ref = packed record
    node : array [0..MAXATOMLEN] of AnsiChar;
    len : Integer;
    n : array [0..3-1] of DWORD;
    creation : DWORD;
  end;

  (* a trace token *)
  erlang_trace = packed record
    serial : LongInt;
    prev : LongInt;
    from : erlang_pid;
    label_ : LongInt;
    flags : LongInt;
  end;

  (* a message *)
  erlang_msg = packed record
    msgtype : LongInt;
    from : erlang_pid;
    to_ : erlang_pid;
    toname : array [0..MAXATOMLEN] of AnsiChar;
    cookie : array [0..MAXATOMLEN] of AnsiChar;
    token : erlang_trace;
  end;

  (* a fun *)
  erlang_fun = packed record
      arity : LongInt;
      module : array [0..MAXATOMLEN] of AnsiChar;
      md5: array [0..16-1] of AnsiChar;
      index : LongInt;
      old_index : LongInt;
      uniq : LongInt;
      n_free_vars : LongInt;
      pid : erlang_pid;
      free_var_len : LongInt;
      free_vars: PAnsiChar;
  end;

  erlang_big = packed record
      arity: DWORD;
      is_neg : Integer;
      digits: Pointer;
  end;

  ei_term = packed record
    ei_type: AnsiChar;
    arity : Integer;
    size : Integer;
    value : record   // union
      i_val : LongInt;
      d_val: double;
      atom_name : array [0..MAXATOMLEN] of AnsiChar;
      pid : erlang_pid;
      port : erlang_port;
      ref : erlang_ref;
    end
  end;

  ErlConnect = packed record
    ipadr: array [0..4-1] of BYTE;     (* stored in network byte order *)
    nodename: array [0..MAXNODELEN] of AnsiChar;
  end;

  ei_cnode = packed record
      thishostname: array [0 .. EI_MAXHOSTNAMELEN] of AnsiChar;
      thisnodename: array [0 .. MAXNODELEN] of AnsiChar;
      thisalivename: array [0 .. EI_MAXALIVELEN] of AnsiChar;
  (* Currently this_ipaddr isn't used *)
  (*    struct in_addr this_ipaddr; *)
      ei_connect_cookie: array [0 .. EI_MAX_COOKIE_SIZE] of AnsiChar;
      creation: ShortInt;
      self : erlang_pid;
  end;
  ei_cnode_s = ei_cnode;

  (* A dynamic version of ei XX *)
  ei_x_buff = packed record
      buff: PAnsiChar;
      buffsz : Integer;
      index : Integer;
  end;
  ei_x_buff_TAG = ei_x_buff;

const
  HOST_NOT_FOUND = 1; // Authoritative Answer Host not found
  TRY_AGAIN      = 2; // Non-Authoritive Host not found, or SERVERFAIL
  NO_RECOVERY    = 3; // Non recoverable errors, FORMERR, REFUSED, NOTIMP
  NO_DATA        = 4; // Valid name, no data record of requested type
  NO_ADDRESS     = NO_DATA;         // no address, look for MX record

const
  EI_SMALLKEY    = 32;

type
  bucket_s = packed record
    rawhash: Integer;
    key: PAnsiChar;
    keybuf: array [0..EI_SMALLKEY-1] of PAnsiChar;
    value: Pointer;
    next: ^bucket_s;
  end;
  ei_bucket = bucket_s;
  ei_bucker_p = ^ei_bucket;
  ei_bucker_pp = ^ei_bucker_p;

  // users of the package declare variables as pointers to this.
  ei_hash_func = function(str: PAnsiChar): Integer;
  ei_hash = packed record
    tab: ei_bucker_pp;
    hash: ei_hash_func; // hash function for this table
    size: Integer; // size of table
    nelem: Integer; // nr elements
    npos: Integer;  // nr occupied positions
    freelist: ^ei_bucket; // reuseable freed buckets
  end;

(*
/***************************************************************************
 *
 *  Registry defines, types, functions
 *
 ***************************************************************************/
*)

// registry object attributes
const
  EI_DIRTY = $01; // dirty bit (object value differs from backup)
  EI_DELET = $02; // object is deleted
  EI_INT = $10; // object is an integer
  EI_FLT = $20; // object is a float
  EI_STR = $40; // object is a string
  EI_BIN = $80; // object is a binary, i.e. pointer to arbitrary type

type
  ei_reg_obj_val = packed record
    case byte of  //val
      0: (i: LongInt);
      1: (f: double);
      2: (s: PAnsiChar);
      3: (p: Pointer);
  end;

  ei_reg_obj = packed record
    attr: Integer;
    size: Integer;
    val: ei_reg_obj_val;
    next_: ^ei_reg_obj;
  end;
  ei_reg_inode = ei_reg_obj;
  ei_reg_inode_p = ^ei_reg_inode;

  ei_reg = packed record
    freelist: ^ei_reg_obj;
    tab: ^ei_hash;
  end;

  ei_reg_stat_t = packed record
    attr: Integer;             // object attributes (see above)
    size: Integer;             // size in bytes (for STR and BIN) 0 for others
  end;

  ei_reg_tabstat_t = packed record
    size: Integer;   // size of table
    nelem: Integer; // number of stored elements
    npos: Integer;   // number of occupied positions
    collisions: Integer; // number of positions with more than one element
  end;

{$IFDEF GNU_MP_VERSION}
  {$I GMP.INC}
{$ENDIF}

{$IFDEF USE_EI_UNDOCUMENTED}
  {$I UNDOCUMENTED_EI.INC}
{$ENDIF}

type
  hostent_p = ^hostent;

  ei_cnode_p = ^ei_cnode;
  ei_term_p = ^ei_term;
  ei_x_buff_p = ^ei_x_buff;

  erlang_msg_p = ^erlang_msg;
  erlang_pid_p = ^erlang_pid;
  erlang_fun_p = ^erlang_fun;
  erlang_port_p = ^erlang_port;
  erlang_ref_p = ^erlang_ref;
  erlang_trace_p = ^erlang_trace;

  ei_reg_p = ^ei_reg;
  ei_reg_stat_p = ^ei_reg_stat_t;
  ei_reg_tabstat_p = ^ei_reg_tabstat_t;

  PDOWRD = ^DWORD;
  PDOUBLE = ^double;

(*******************************************************************************
 **                     Function definitions
 *******************************************************************************)

// Handle the connection

function erl_errno : longint;

function ei_connect_init(ec: ei_cnode_p; const this_node_name: PAnsiChar; const cookie: PAnsiChar; creation: ShortInt): Integer; cdecl; external LIB_EI;
function ei_connect_xinit (ec: ei_cnode_p; const thishostname: PAnsiChar; const thisalivename: PAnsiChar; const thisnodename: PAnsiChar; thisipaddr: Erl_IpAddr; const cookie: PAnsiChar; const creation:ShortInt): Integer; cdecl; external LIB_EI;

function ei_connect(ec: ei_cnode_p; nodename: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_connect_tmo(ec: ei_cnode_p; nodename: PAnsiChar; const ms): Integer; cdecl; external LIB_EI;
function ei_xconnect(ec: ei_cnode_p; adr: Erl_IpAddr; alivename: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_xconnect_tmo(ec: ei_cnode_p; adr: Erl_IpAddr; alivename: PAnsiChar; const ms): Integer; cdecl; external LIB_EI;

function ei_receive(fd: Integer; const bufp: PAnsiChar; bufsize: Integer): Integer; cdecl; external LIB_EI;
function ei_receive_tmo(fd: Integer; const bufp: PAnsiChar; bufsize: Integer; const ms): Integer; cdecl; external LIB_EI;
function ei_receive_msg(fd: Integer; msg: erlang_msg_p; x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_receive_msg_tmo(fd: Integer; msg: erlang_msg_p; x: ei_x_buff; const ms): Integer; cdecl; external LIB_EI;
function ei_xreceive_msg(fd: Integer; msg: erlang_msg_p; x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_xreceive_msg_tmo(fd: Integer; msg: erlang_msg_p; x: ei_x_buff; const ms): Integer; cdecl; external LIB_EI;

function ei_send(fd: Integer; to_: erlang_pid_p; buf: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_send_tmo(fd: Integer; to_: erlang_pid_p; buf: PAnsiChar; len: Integer; const ms): Integer; cdecl; external LIB_EI;
function ei_reg_send(ec: ei_cnode_p; fd: Integer; server_name: PAnsiChar; buf: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_reg_send_tmo(ec: ei_cnode_p; fd: Integer; server_name: PAnsiChar; buf: PAnsiChar; len: Integer; const ms): Integer; cdecl; external LIB_EI;

function ei_rpc(ec: ei_cnode_p; fd: Integer; mod_: PAnsiChar; fun: PAnsiChar; const inbuf: PAnsiChar; inbuflen: Integer; x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_rpc_to(ec: ei_cnode_p; fd: Integer; mod_: PAnsiChar; fun: PAnsiChar; const buf: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_rpc_from(ec: ei_cnode_p; fd: Integer; timeout: Integer; msg: erlang_msg_p; x: ei_x_buff): Integer; cdecl; external LIB_EI;

function ei_publish(ec: ei_cnode_p; port: Integer): Integer; cdecl; external LIB_EI;
function ei_publish_tmo(ec: ei_cnode_p; port: Integer; const ms): Integer; cdecl; external LIB_EI;
function ei_accept(ec: ei_cnode_p; lfd:ErlConnect; conp: PInteger): Integer; cdecl; external LIB_EI;
function ei_accept_tmo(ec: ei_cnode_p; lfd:ErlConnect; conp: PInteger; const ms): Integer; cdecl; external LIB_EI;
function ei_unpublish(ec: ei_cnode_p): Integer; cdecl; external LIB_EI;
function ei_unpublish_tmo(const alive: PAnsiChar; const ms): Integer; cdecl; external LIB_EI;

function ei_thisnodename(const ec: ei_cnode_p): PAnsiChar; cdecl; external LIB_EI;
function ei_thishostname(const ec: ei_cnode_p): PAnsiChar; cdecl; external LIB_EI;
function ei_thisalivename(const ec: ei_cnode_p): PAnsiChar; cdecl; external LIB_EI;

function ei_self(ec: ei_cnode_p): erlang_pid_p; cdecl; external LIB_EI;

procedure ei_set_compat_rel(const rel); cdecl; external LIB_EI;

function ei_gethostbyname(const name: PAnsiChar): hostent_p; cdecl; external LIB_EI;
function ei_gethostbyaddr(const addr: PAnsiChar; len: Integer; type_: Integer): hostent_p; cdecl; external LIB_EI;
function ei_gethostbyname_r(const name: PAnsiChar; hostp: hostent_p; buffer: PAnsiChar; buflen: Integer; h_errnop: PInteger):hostent_p; cdecl; external LIB_EI;
function ei_gethostbyaddr_r(const addr: PAnsiChar; length: Integer; type_: Integer; hostp: hostent_p; buffer: PAnsiChar; buflen: Integer; h_errnop:PInteger):hostent_p; cdecl; external LIB_EI;

// Encode/decode functions

function ei_encode_version      (buf: PAnsiChar; const index: Integer): Integer; cdecl; external LIB_EI;
function ei_encode_long         (buf: PAnsiChar; const index: Integer; p: LongInt): Integer; cdecl; external LIB_EI;
function ei_encode_ulong        (buf: PAnsiChar; const index: Integer; const p: LongInt): Integer; cdecl; external LIB_EI;
function ei_encode_double       (buf: PAnsiChar; const index: Integer; p:double): Integer; cdecl; external LIB_EI;
function ei_encode_boolean      (buf: PAnsiChar; const index: Integer; p: Integer): Integer; cdecl; external LIB_EI;
function ei_encode_char         (buf: PAnsiChar; const index: Integer; p:char): Integer; cdecl; external LIB_EI;
function ei_encode_string       (buf: PAnsiChar; const index: Integer; const p: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_encode_string_len   (buf: PAnsiChar; const index: Integer; const p: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_encode_atom         (buf: PAnsiChar; const index: Integer; const p: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_encode_atom_len     (buf: PAnsiChar; const index: Integer; const p: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_encode_binary       (buf: PAnsiChar; const index: Integer; const p; len: LongInt): Integer; cdecl; external LIB_EI;
function ei_encode_pid          (buf: PAnsiChar; const index: Integer; const p: erlang_pid_p): Integer; cdecl; external LIB_EI;
function ei_encode_fun          (buf: PAnsiChar; const index: Integer; const p: erlang_fun_p): Integer; cdecl; external LIB_EI;
function ei_encode_port         (buf: PAnsiChar; const index: Integer; const p: erlang_port_p): Integer; cdecl; external LIB_EI;
function ei_encode_ref          (buf: PAnsiChar; const index: Integer; const p: erlang_ref_p): Integer; cdecl; external LIB_EI;
function ei_encode_term         (buf: PAnsiChar; const index: Integer; t:pointer): Integer; cdecl; external LIB_EI;
function ei_encode_trace        (buf: PAnsiChar; const index: Integer; const p: erlang_trace_p): Integer; cdecl; external LIB_EI;
function ei_encode_tuple_header (buf: PAnsiChar; const index: Integer; arity: Integer): Integer; cdecl; external LIB_EI;
function ei_encode_list_header  (buf: PAnsiChar; const index: Integer; arity: Integer): Integer; cdecl; external LIB_EI;
function ei_encode_empty_list   (buf: PAnsiChar; const index: Integer): Integer; cdecl;

function ei_x_encode_version    (x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_x_encode_long       (x: ei_x_buff; n: LongInt): Integer; cdecl; external LIB_EI;
function ei_x_encode_ulong      (x: ei_x_buff; const n: LongInt): Integer; cdecl; external LIB_EI;
function ei_x_encode_double     (x: ei_x_buff; dbl:double): Integer; cdecl; external LIB_EI;
function ei_x_encode_boolean    (x: ei_x_buff; p: Integer): Integer; cdecl; external LIB_EI;
function ei_x_encode_char       (x: ei_x_buff; p:char ): Integer; cdecl; external LIB_EI;
function ei_x_encode_string     (x: ei_x_buff; const s: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_x_encode_string_len (x: ei_x_buff; const s: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_x_encode_atom       (x: ei_x_buff; const s: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_x_encode_atom_len   (x: ei_x_buff; const s: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_x_encode_binary     (x: ei_x_buff; const s; len: Integer): Integer; cdecl; external LIB_EI;
function ei_x_encode_pid        (x: ei_x_buff; const pid: erlang_pid_p): Integer; cdecl; external LIB_EI;
function ei_x_encode_fun        (x: ei_x_buff; const fun: erlang_fun_p): Integer; cdecl; external LIB_EI;
function ei_x_encode_port       (x: ei_x_buff; const p: erlang_port_p): Integer; cdecl; external LIB_EI;
function ei_x_encode_ref        (x: ei_x_buff; const p: erlang_ref_p): Integer; cdecl; external LIB_EI;
function ei_x_encode_term       (x: ei_x_buff_p; t: pointer): Integer; cdecl; external LIB_EI;
function ei_x_encode_trace      (x: ei_x_buff; const p: erlang_trace_p): Integer; cdecl; external LIB_EI;
function ei_x_encode_tuple_header(x: ei_x_buff; n: LongInt): Integer; cdecl; external LIB_EI;
function ei_x_encode_list_header (x: ei_x_buff; n: LongInt): Integer; cdecl; external LIB_EI;
function ei_x_encode_empty_list  (x: ei_x_buff): Integer; cdecl; external LIB_EI;

(*
/*
 * ei_get_type() returns the type and "size" of the item at
 * buf[index]. For strings and atoms, size is the number of characters
 * not including the terminating 0. For binaries, size is the number
 * of bytes. For lists and tuples, size is the arity of the
 * object. For other types, size is 0. In all cases, index is left
 * unchanged.
 */
*)
function ei_get_type(const buf: PAnsiChar; const index: PInteger; type_: PInteger; size: PInteger): Integer; cdecl; external LIB_EI;
function ei_get_type_internal(const buf: PAnsiChar; const index: PInteger; type_: PInteger; size: PInteger): Integer; cdecl; external LIB_EI;

(*
/* Step through buffer, decoding the given type into the buffer
 * provided. On success, 0 is returned and index is updated to point
 * to the start of the next item in the buffer. If the type of item at
 * buf[index] is not the requested type, -1 is returned and index is
 * not updated. The buffer provided by the caller must be sufficiently
 * large to contain the decoded object.
 */
*)
procedure free_fun(f: erlang_fun_p); cdecl; external LIB_EI;
function ei_decode_version     (const buf: PAnsiChar; index: PInteger; version: PInteger): Integer; cdecl; external LIB_EI;
function ei_decode_long        (const buf: PAnsiChar; index: PInteger; p: PLongInt): Integer; cdecl; external LIB_EI;
function ei_decode_ulong       (const buf: PAnsiChar; index: PInteger; p: PDOWRD): Integer; cdecl; external LIB_EI;
function ei_decode_double      (const buf: PAnsiChar; index: PInteger; p: PDOUBLE): Integer; cdecl; external LIB_EI;
function ei_decode_boolean     (const buf: PAnsiChar; index: PInteger; p: PInteger): Integer; cdecl; external LIB_EI;
function ei_decode_char        (const buf: PAnsiChar; index: PInteger; p: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_decode_string      (const buf: PAnsiChar; index: PInteger; p: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_decode_atom        (const buf: PAnsiChar; index: PInteger; p: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_decode_binary      (const buf: PAnsiChar; index: PInteger; const p; len: PLongInt): Integer; cdecl; external LIB_EI;
function ei_decode_fun         (const buf: PAnsiChar; index: PInteger; p: erlang_fun_p): Integer; cdecl; external LIB_EI;
function ei_decode_pid         (const buf: PAnsiChar; index: PInteger; p: erlang_pid_p): Integer; cdecl; external LIB_EI;
function ei_decode_port        (const buf: PAnsiChar; index: PInteger; p: erlang_port_p): Integer; cdecl; external LIB_EI;
function ei_decode_ref         (const buf: PAnsiChar; index: PInteger; p: erlang_ref_p): Integer; cdecl; external LIB_EI;
function ei_decode_term        (const buf: PAnsiChar; index: PInteger; const t): Integer; cdecl; external LIB_EI;
function ei_decode_trace       (const buf: PAnsiChar; index: PInteger; p: erlang_trace_p): Integer; cdecl; external LIB_EI;
function ei_decode_tuple_header(const buf: PAnsiChar; index: PInteger; arity: PInteger): Integer; cdecl; external LIB_EI;
function ei_decode_list_header (const buf: PAnsiChar; index: PInteger; arity: PInteger): Integer; cdecl; external LIB_EI;
(*
/*
 * ei_decode_ei_term() returns 1 if term is decoded, 0 if term is OK,
 * but not decoded here and -1 if something is wrong.  ONLY changes
 * index if term is decoded (return value 1)!
 */
*)
function ei_decode_ei_term     (const buf: PAnsiChar; index: PInteger; term: ei_term_p): Integer; cdecl; external LIB_EI;


(*
/*
 * ei_print_term to print out a binary coded term
 */
*)
function ei_print_term(const fp: text; const buf: PAnsiChar; index: PInteger): Integer; cdecl; external LIB_EI;
function ei_s_print_term(s: PPAnsiChar; const buf: PAnsiChar; index: PInteger): Integer; cdecl; external LIB_EI;

(*
/*
 * format to build binary format terms a bit like printf
 */
*)
function ei_x_format(x: ei_x_buff; const fmt: PAnsiChar; args: array of const): Integer;
function ei_x_format_wo_ver(x: ei_x_buff; const fmt: PAnsiChar; args: array of const): Integer;

function ei_x_new(x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_x_new_with_version(x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_x_free(x: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_x_append(x: ei_x_buff; const x2: ei_x_buff): Integer; cdecl; external LIB_EI;
function ei_x_append_buf(x: ei_x_buff; const buf: PAnsiChar; len: Integer): Integer; cdecl; external LIB_EI;
function ei_skip_term(const buf: PAnsiChar; index: PInteger): Integer; cdecl; external LIB_EI;

(*******************************************************************************
 **                     Hash types needed by registry types
 *******************************************************************************)

(*
/* open / close registry. On open, a descriptor is returned that must
 * be specified in all subsequent calls to registry functions. You can
 * open as many registries as you like.
 */
*)
function ei_reg_open(size: Integer): ei_reg_p; cdecl; external LIB_EI;
function ei_reg_resize(oldreg: ei_reg_p; newsize: Integer): Integer; cdecl; external LIB_EI;
function ei_reg_close(reg: ei_reg_p): Integer; cdecl; external LIB_EI;

(*
/* set values... these routines assign values to keys. If the key
 * exists, the previous value is discarded and the new one replaces
 * it.
 *
 * BIN objects require an additional argument indicating the size in
 * bytes of the stored object. This will be used when the object is
 * backed up, since it will need to be copied at that time. Remember
 * also that pointers are process-space specific and it is not
 * meaningful to back them up for later recall. If you are storing
 * binary objects for backup, make sure that they are self-contained
 * (without references to other objects).
 *
 * On success the function returns 0, otherwise a value
 * indicating the reason for failure will be returned.
 */
*)
function ei_reg_setival(reg: ei_reg_p; const key: PAnsiChar; i: LongInt): Integer; cdecl; external LIB_EI;
function ei_reg_setfval(reg: ei_reg_p; const key: PAnsiChar; f: double ): Integer; cdecl; external LIB_EI;
function ei_reg_setsval(reg: ei_reg_p; const key: PAnsiChar; const s: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_reg_setpval(reg: ei_reg_p; const key: PAnsiChar; const p; size: Integer): Integer; cdecl; external LIB_EI;

(*
/* general set function (specifiy type via flags)
 * optional arguments are as for equivalent type-specific function,
 * i.e.:
 * ei_reg_setval(fd, path, EI_INT, int i);
 * ei_reg_setval(fd, path, EI_FLT, float f);
 * ei_reg_setval(fd, path, EI_STR, const char *s);
 * ei_reg_setval(fd, path, EI_BIN, const void *p, int size);
 */
*)
function ei_reg_setval(reg: ei_reg_p; const key: PAnsiChar; flags: Integer; args: array of const): Integer;

(* ???, re-check
const char *ei_reg_getsval(ei_reg *reg, const char *key);
int ei_reg_stat(ei_reg *reg, const char *key, struct ei_reg_stat *obuf);
*)

(*
/* get value of specific type object */
/* warning: it may be difficult to detect errors when using these
 * functions, since the error values are returned "in band"
 */
*)
function ei_reg_getival(reg: ei_reg_p; const key: PAnsiChar): LongInt; cdecl; external LIB_EI;
function ei_reg_getfval(reg: ei_reg_p; const key: PAnsiChar): double; cdecl; external LIB_EI;
function ei_reg_getsval(reg: ei_reg_p; const key: PAnsiChar): PAnsiChar; cdecl; external LIB_EI;
function ei_reg_getpval(reg: ei_reg_p; const key: PAnsiChar; size: PInteger): Pointer; cdecl; external LIB_EI;
(*
/* get value of any type object (must specify)
 * Retrieve a value from an object. The type of value expected and a
 * pointer to a large enough buffer must be provided. flags must be
 * set to the appropriate type (see type constants above) and the
 * object type must match. If (flags == 0) the pointer is *assumed* to
 * be of the correct type for the object. In any case, the actual
 * object type is always returned on success.
 *
 * The argument following flags must be one of int*, double*, const
 * char** and const void**.
 *
 * for BIN objects an int* is needed to return the size of the object, i.e.
 * int ei_reg_getval(ei_reg *reg, const char *path, int flags, void **p, int *size);
 */
 *)
 function ei_reg_getval(reg: ei_reg_p; const key: PAnsiChar; flags: Integer; args: array of const): Integer;


(*
/* mark the object as dirty. Normally this operation will not be
 * necessary, as it is done automatically by all of the above 'set'
 * functions. However, if you modify the contents of an object pointed
 * to by a STR or BIN object, then the registry will not be aware of
 * the change. As a result, the object may be missed on a subsequent
 * backup operation. Use this function to set the dirty bit on the
 * object.
 */
*)
function ei_reg_markdirty(reg: ei_reg_p; const key: PAnsiChar): Integer; cdecl; external LIB_EI;
// remove objects. The value, if any, is discarded. For STR and BIN
// objects, the object itself is removed using free().
function ei_reg_delete(reg: ei_reg_p; const key: PAnsiChar): Integer; cdecl; external LIB_EI;
// get information about an object
function ei_reg_stat(reg: ei_reg_p; const key: PAnsiChar; obuf: ei_reg_stat_p): Integer; cdecl; external LIB_EI;
// get information about table
function ei_reg_tabstat(reg: ei_reg_p; obuf: ei_reg_tabstat_p): Integer; cdecl; external LIB_EI;

// dump to / restore from backup
// fd is open descriptor to Erlang, mntab is Mnesia table name
// flags here:
const
  EI_FORCE = 1; // dump all records (not just dirty ones)
  EI_NOPURGE = 2; // don't purge deleted records
function ei_reg_dump(fd: Integer; reg: ei_reg_p; const mntab: PAnsiChar; flags: Integer): Integer; cdecl; external LIB_EI;
function ei_reg_restore(fd: Integer; reg: ei_reg_p; const mntab: PAnsiChar): Integer; cdecl; external LIB_EI;
function ei_reg_purge(reg: ei_reg_p): Integer; cdecl; external LIB_EI;

implementation

uses
  c_params;

function __erl_errno_place: PInteger; cdecl; external LIB_EI;

function erl_errno: longint;
begin
  Result := __erl_errno_place()^;
end;

function ei_encode_empty_list (buf: PAnsiChar; const index: Integer): Integer; cdecl;
begin
  Result := ei_encode_list_header(buf, index, 0);
end;

// int ei_x_format(ei_x_buff* x, const char* fmt, ...);
function _ei_x_format(x: ei_x_buff; const fmt: PAnsiChar; args: R_ARGS): Integer; external LIB_EI name 'ei_x_format';
function ei_x_format(x: ei_x_buff; const fmt: PAnsiChar; args: array of const): Integer;
begin
  Result := _ei_x_format(x, fmt, FloatParams(args));
end;

// int ei_x_format_wo_ver(ei_x_buff* x, const char *fmt, ...);
function _ei_x_format_wo_ver(x: ei_x_buff; const fmt: PAnsiChar; args: R_ARGS): Integer; external LIB_EI name 'ei_x_format_wo_ver';
function ei_x_format_wo_ver(x: ei_x_buff; const fmt: PAnsiChar; args: array of const): Integer;
begin
  Result := _ei_x_format_wo_ver(x, fmt, FloatParams(args));
end;


// int ei_reg_setval(ei_reg *reg, const char *key, int flags, ...);
function _ei_reg_setval(reg: ei_reg_p; const key: PAnsiChar; flags: Integer; args: R_ARGS): Integer; cdecl; external LIB_EI name 'ei_reg_setval';
function ei_reg_setval(reg: ei_reg_p; const key: PAnsiChar; flags: Integer; args: array of const): Integer;
begin
  Result := _ei_reg_setval(reg, key, flags, FloatParams(args));
end;

// int ei_reg_getval(ei_reg *reg, const char *key, int flags, ...);
function _ei_reg_getval(reg: ei_reg_p; const key: PAnsiChar; flags: Integer; args: R_ARGS): Integer; cdecl; external LIB_EI name 'ei_reg_getval';
function ei_reg_getval(reg: ei_reg_p; const key: PAnsiChar; flags: Integer; args: array of const): Integer;
begin
  Result := _ei_reg_getval(reg, key, flags, FloatParams(args));
end;

end.
