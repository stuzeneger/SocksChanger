program Helper;

{$APPTYPE GUI}

uses
  SysUtils, Classes,
  IdHTTPServer, IdContext, IdCustomHTTPServer,
  Windows, Registry;

type
  TMyServer = class
  private
    FHTTPServer: TIdHTTPServer;
    procedure OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  end;

{ TMyServer }

constructor TMyServer.Create;
begin
  inherited;
  FHTTPServer := TIdHTTPServer.Create(nil);
  FHTTPServer.DefaultPort := 8765;
  FHTTPServer.OnCommandGet := OnCommandGet;
end;

destructor TMyServer.Destroy;
begin
  FHTTPServer.Free;
  inherited;
end;

procedure TMyServer.Start;
begin
  FHTTPServer.Active := True;
  //Writeln('Server started on port ', FHTTPServer.DefaultPort);
end;

procedure TMyServer.Stop;
begin
  FHTTPServer.Active := False;
end;

procedure TMyServer.OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  ProxyJSON: TStringList;
  FileName: string;
begin
  if ARequestInfo.Document = '/proxydata' then
  begin
    FileName := 'C:\\ProgramData\\SocksChanger\\proxy.json';
    ProxyJSON := TStringList.Create;
    try
      if FileExists(FileName) then
      begin
        ProxyJSON.LoadFromFile(FileName);
        AResponseInfo.ContentType := 'application/json';
        AResponseInfo.ContentText := ProxyJSON.Text;
        AResponseInfo.ResponseNo := 200;
      end
      else
      begin
        AResponseInfo.ContentText := '{"error": "File not found"}';
        AResponseInfo.ResponseNo := 404;
      end;
    finally
      ProxyJSON.Free;
    end;
  end
  else
  begin
    AResponseInfo.ContentText := '{"error": "Unknown endpoint"}';
    AResponseInfo.ResponseNo := 404;
  end;
end;

procedure AddToStartup;
var
  Reg: TRegistry;
  AppName, AppPath: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\\Microsoft\\Windows\\CurrentVersion\\Run', True) then
    begin
      AppName := 'Helper';
      AppPath := ParamStr(0);
      Reg.WriteString(AppName, AppPath);
      Reg.CloseKey;
      //Writeln('Added to Windows startup: ', AppPath);
    end;
  finally
    Reg.Free;
  end;
end;

var
  Server: TMyServer;
  hMutex: THandle;
begin
  hMutex := CreateMutex(nil, True, 'HelperSingletonMutex');
  if (hMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    //Writeln('Instance already running. Exiting.');
    Exit;
  end;

  AddToStartup;

  try
    Server := TMyServer.Create;
    try
      Server.Start;
      while True do
        Sleep(1000);
    finally
      Server.Free;
    end;
  finally
    CloseHandle(hMutex);
  end;
end.


destructor TMyServer.Destroy;
begin
  FHTTPServer.Free;
  inherited;
end;

procedure TMyServer.Start;
begin
  FHTTPServer.Active := True;
  //Writeln('Server started on port ', FHTTPServer.DefaultPort);
end;

procedure TMyServer.Stop;
begin
  FHTTPServer.Active := False;
end;

procedure TMyServer.OnCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  ProxyJSON: TStringList;
  FileName: string;
begin
  if ARequestInfo.Document = '/proxydata' then
  begin
    FileName := 'C:\ProgramData\SocksChanger\proxy.json';
    ProxyJSON := TStringList.Create;
    try
      if FileExists(FileName) then
      begin
        ProxyJSON.LoadFromFile(FileName);
        AResponseInfo.ContentType := 'application/json';
        AResponseInfo.ContentText := ProxyJSON.Text;
        AResponseInfo.ResponseNo := 200;
      end
      else
      begin
        AResponseInfo.ContentText := '{"error": "File not found"}';
        AResponseInfo.ResponseNo := 404;
      end;
    finally
      ProxyJSON.Free;
    end;
  end
  else
  begin
    AResponseInfo.ContentText := '{"error": "Unknown endpoint"}';
    AResponseInfo.ResponseNo := 404;
  end;
end;

var
  Server: TMyServer;

begin
  try
    Server := TMyServer.Create;
    try
      Server.Start;
      while True do
        Sleep(1000);
    finally
      Server.Free;
    end;
  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;
end.

