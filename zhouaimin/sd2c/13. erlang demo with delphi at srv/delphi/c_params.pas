unit c_params;

interface

const
  MAX_ARGS = 16;

type
  TStringArgs = array of AnsiString;
  R_ARGS = packed record
    V: array [0..MAX_ARGS-1] of Pointer;
    S: TStringArgs;  // a pointer, auto manage by delphi
  end;

function FloatParams(args: array of const): R_ARGS;

implementation

uses
  math;

// float-params push from right to left in cdecl, fake the stack with packed-record.
function FloatParams(args: array of const): R_ARGS;
const
  filter = [vtString, vtWideChar, vtWideString, vtUnicodeString, vtPWideChar];
var
  I, J, L : Integer;
  S : TStringArgs;
begin
  Assert(high(args) < MAX_ARGS);

  // high() is -1, or >=1
  L := Min(high(args), MAX_ARGS-1);
  SetLength(S, L+1);

  J := 0;
  for I := 0 to L do
  begin
    case args[I].VType of
      vtString:        S[J] := AnsiString(args[I].VString);
      vtWideChar:      S[J] := String(args[I].VWideChar);
      vtWideString:    S[J] := WideString(args[I].VPointer);
      vtUnicodeString: S[J] := UnicodeString(args[I].VPointer);
      vtPWideChar:     S[J] := String(args[I].VPWideChar);
    else
      Pointer(Result.V[I]) := args[I].VPointer;
    end;

    if args[I].VType in filter then
    begin
      Result.V[I] := Pointer(S[J]);
      inc(J);
    end;
  end;

  SetLength(S, J);
  Result.S := S;
end;

end.