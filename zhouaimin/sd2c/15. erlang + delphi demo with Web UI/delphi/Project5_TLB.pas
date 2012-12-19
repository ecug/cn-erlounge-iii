unit Project5_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 16059 $
// File generated on 2008-12-3 14:07:37 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\Tao\JavaScript + Delphi + ErLang\15. erlang + delphi demo with Web UI\delphi\Project5 (1)
// LIBID: {5E5FA31C-3369-43EE-8F3D-63A45C669CBB}
// LCID: 0
// Helpfile:
// HelpString:
// DepndLst:
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  Project5MajorVersion = 1;
  Project5MinorVersion = 0;

  LIBID_Project5: TGUID = '{5E5FA31C-3369-43EE-8F3D-63A45C669CBB}';

  IID_IMessManager: TGUID = '{7050DC74-BBF5-42BA-8DE6-B0CED01CE7F3}';
  CLASS_MessManager: TGUID = '{EB9DCA70-EEB0-4379-8245-CBA5E00E1774}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IMessManager = interface;
  IMessManagerDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  MessManager = IMessManager;


// *********************************************************************//
// Interface: IMessManager
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7050DC74-BBF5-42BA-8DE6-B0CED01CE7F3}
// *********************************************************************//
  IMessManager = interface(IDispatch)
    ['{7050DC74-BBF5-42BA-8DE6-B0CED01CE7F3}']
    function Get_Messenge: WideString; safecall;
    property Messenge: WideString read Get_Messenge;
  end;

// *********************************************************************//
// DispIntf:  IMessManagerDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {7050DC74-BBF5-42BA-8DE6-B0CED01CE7F3}
// *********************************************************************//
  IMessManagerDisp = dispinterface
    ['{7050DC74-BBF5-42BA-8DE6-B0CED01CE7F3}']
    property Messenge: WideString readonly dispid 201;
  end;

// *********************************************************************//
// The Class CoMessManager provides a Create and CreateRemote method to
// create instances of the default interface IMessManager exposed by
// the CoClass MessManager. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoMessManager = class
    class function Create: IMessManager;
    class function CreateRemote(const MachineName: string): IMessManager;
  end;

implementation

uses ComObj;

class function CoMessManager.Create: IMessManager;
begin
  Result := CreateComObject(CLASS_MessManager) as IMessManager;
end;

class function CoMessManager.CreateRemote(const MachineName: string): IMessManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_MessManager) as IMessManager;
end;

end.

