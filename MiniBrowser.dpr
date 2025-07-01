program MiniBrowser;

{$I source\cef.inc}

uses
  {$IFDEF DELPHI16_UP}
  Vcl.Forms,
  {$ELSE}
  Forms,
  {$ENDIF }
  uCEFApplication,
  uMiniBrowser in 'uMiniBrowser.pas' {MiniBrowserFrm},
  BrowserUtil in 'BrowserUtil.pas';

{$R *.res}

const
  IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;

// CEF needs to set the LARGEADDRESSAWARE ($20) flag which allows 32-bit processes to use up to 3GB of RAM.
{$IFDEF WIN32}{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}{$ENDIF}

begin
   ReportMemoryLeaksOnShutdown := False;
   CreateGlobalCEFApp;

  if GlobalCEFApp.StartMainProcess then
    begin
	FreeMiniBrowserProcesses;
      Application.Initialize;
      {$IFDEF DELPHI11_UP}
      Application.MainFormOnTaskbar := True;
      {$ENDIF}
  Application.CreateForm(TMiniBrowserFrm, MiniBrowserFrm);
  Application.Run;
    end;

  DestroyGlobalCEFApp;
end.

