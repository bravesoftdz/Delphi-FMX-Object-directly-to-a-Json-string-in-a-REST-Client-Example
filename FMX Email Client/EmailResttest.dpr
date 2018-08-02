program EmailResttest;

uses
  System.StartUpCopy,
  FMX.Forms,
  emailmain in 'emailmain.pas' {fmmain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfmmain, fmmain);
  Application.Run;
end.
