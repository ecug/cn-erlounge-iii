unit main5_f;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, ActiveX, Project5_TLB, main5, StdVcl;

type
  TMessManager = class(TAutoObject, IMessManager)
  protected
    FHost: TMainForm;
    function Get_Messenge: WideString; safecall;
  public
    constructor Create(Host: TMainForm);
  end;

implementation

uses ComServ;

constructor TMessManager.Create(Host: TMainForm);
begin
  inherited Create;
  FHost := Host;
end;

function TMessManager.Get_Messenge: WideString;
begin
  Result := FHost.ServerMessenger;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TMessManager, Class_MessManager,
    ciSingleInstance, tmApartment);
end.
