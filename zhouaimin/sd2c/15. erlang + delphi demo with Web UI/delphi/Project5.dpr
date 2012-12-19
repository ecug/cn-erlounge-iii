program Project5;

uses
  Forms,
  main5 in 'main5.pas' {MainForm},
  Project5_TLB in 'Project5_TLB.pas',
  main5_f in 'main5_f.pas' {MessManager: CoClass};

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
