unit uMiniBrowser;

{$I source\cef.inc}

interface

uses
{$IFDEF DELPHI16_UP}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.RegularExpressions,
  System.Classes, Vcl.Graphics, Vcl.Menus, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Types, Vcl.ComCtrls, Vcl.ClipBrd,
  System.UITypes, Vcl.AppEvnts, Winapi.ActiveX, Winapi.ShlObj,
  System.NetEncoding, System.JSON, System.Win.Registry, ShellAPI, BrowserUtil,
{$ELSE}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Menus,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Types, ComCtrls, ClipBrd,
  AppEvnts, ActiveX, ShlObj, NetEncoding,
{$ENDIF}
  uCEFChromium, uCEFWindowParent, uCEFInterfaces, uCEFApplication, uCEFTypes,
  uCEFConstants, uCEFWinControl, uCEFChromiumCore, uCEFDomVisitor, Vcl.Imaging.jpeg;

const
  MINIBROWSER_SHOWRESPONSE = WM_APP + $104;
  MINIBROWSER_COPYFRAMEIDS = WM_APP + $105;
  MINIBROWSER_COPYFRAMENAMES = WM_APP + $106;
  MINIBROWSER_SHOWNAVIGATION = WM_APP + $10A;
  MINIBROWSER_DTDATA_AVLBL = WM_APP + $10E;
  MINIBROWSER_SELECTCERT = WM_APP + $110;
  MINIBROWSER_HOMEPAGE = 'https://nsocks.net/#';
  SOCKS_EXCHANGE_PATH = 'C:\ProgramData\SocksChanger\proxy.json';

type
  TBrowserInfo = record
    protocolVersion: string;
    product: string;
    revision: string;
    userAgent: string;
    jsVersion: string;
    RuntimeStyle: string;
  end;

  TMiniBrowserFrm = class(TForm)
    Chromium1: TChromium;
    DevTools: TCEFWindowParent;
    Timer1: TTimer;
    BottomPanel: TPanel;
    GetNewIdenty: TButton;
    OpenBrowserWithNewIdenty: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    CEFWindowParent1: TCEFWindowParent;
    Logs: TTabSheet;
    AppLog: TMemo;
    TabSheet2: TTabSheet;
    HostManualInput: TEdit;
    PortManualInput: TEdit;
    UsernameManualInput: TEdit;
    PasswordManualInput: TEdit;
    ProxyStringManualInput: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Chromium1AfterCreated(Sender: TObject;
      const browser: ICefBrowser);
    procedure Chromium1LoadingStateChange(Sender: TObject;
      const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
    procedure Chromium1StatusMessage(Sender: TObject;
      const browser: ICefBrowser; const value: ustring);
    procedure Chromium1ResourceResponse(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const response: ICefResponse;
      out Result: Boolean);
    procedure Chromium1BeforeResourceLoad(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefCallback;
      out Result: TCefReturnValue);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure Chromium1LoadingProgressChange(Sender: TObject;
      const browser: ICefBrowser; const progress: Double);
    procedure Chromium1LoadEnd(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; httpStatusCode: Integer);
    procedure Chromium1SelectClientCertificate(Sender: TObject;
      const browser: ICefBrowser; isProxy: Boolean; const host: ustring;
      port: Integer; certificatesCount: NativeUInt;
      const certificates: TCefX509CertificateArray;
      const callback: ICefSelectClientCertificateCallback;
      var aResult: Boolean);
    procedure Chromium1CertificateError(Sender: TObject;
      const browser: ICefBrowser; certError: TCefErrorCode;
      const requestUrl: ustring; const sslInfo: ICefSslInfo;
      const callback: ICefCallback; out Result: Boolean);
    procedure Chromium1ConsoleMessage(Sender: TObject;
      const browser: ICefBrowser; level: TCefLogSeverity;
      const message_, source: ustring; line: Integer; out Result: Boolean);
    procedure Chromium1LoadError(Sender: TObject; const browser: ICefBrowser;
      const frame: ICefFrame; errorCode: TCefErrorCode;
      const errorText, failedUrl: ustring);
    procedure Chromium1ResolvedHostAvailable(Sender: TObject;
      Result: TCefErrorCode; const resolvedIps: TStrings);
    procedure Timer1Timer(Sender: TObject);
    procedure GetLocalizedProxies();
    procedure ShowCartAndBuyProxy();
    procedure ExtractProxiesIDs(const HTML: string; AList: TStringList);
    procedure GetNewIdentyClick(Sender: TObject);
    procedure GetBuyedProxyFromCart();
    procedure SetBuyedProxy();
    procedure OpenBrowserWithNewIdentyClick(Sender: TObject);
    procedure ParseProxyString();
    procedure SaveProxyForHelper();
    procedure StartHelperInstance();
    function GetRandomProxy(): string;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);

  protected
    FPendingMsgID: Integer;
    FDevToolsMsgValue: ustring;
    FShutdownReason: string;
    FHasShutdownReason: Boolean;
    FSelectCertCallback: ICefSelectClientCertificateCallback;
    FCertificates: TCefX509CertificateArray;
    FAllowDownloads: Boolean;
    FJSException: Integer;
    FBrowserInfo: TBrowserInfo;

    FMediaAccessCallback: ICefMediaAccessCallback;
    FRequestingOrigin: string;
    FRequestedPermissions: cardinal;

    FResponse: TStringList;
    FRequest: TStringList;
    FNavigation: TStringList;

    FCanClose: Boolean;
    FClosing: Boolean;

    procedure DestroyCertificates;

    procedure ReplaceAcceptEncoding(const aRequest: ICefRequest);
    procedure InspectRequest(const aRequest: ICefRequest);
    procedure InspectResponse(const aResponse: ICefResponse);

    procedure BrowserCreatedMsg(var aMessage: TMessage);
      message CEF_AFTERCREATED;
    procedure ShowResponseMsg(var aMessage: TMessage);
      message MINIBROWSER_SHOWRESPONSE;
    procedure ShowNavigationMsg(var aMessage: TMessage);
      message MINIBROWSER_SHOWNAVIGATION;
    procedure WMQueryEndSession(var aMessage: TWMQueryEndSession);
      message WM_QUERYENDSESSION;

  public

  end;

var
  MiniBrowserFrm: TMiniBrowserFrm;
  CurrentDirectory: string;
  ProxyId: string;
  ProxiesIDs: TStringList;
  ProxyString: string;
  Username: string = '';
  Password: string = '';
  Host: string = '';
  Port: string = '';

procedure CreateGlobalCEFApp;

implementation

{$R *.dfm}

uses
  uCefStringMultimap, uCEFMiscFunctions, uSimpleTextViewer,
  uCEFClient, uCEFDictionaryValue, uCEFWindowInfoWrapper, uCEFTaskManager;

procedure GlobalCEFApp_OnUncaughtException(const browser: ICefBrowser;
  const frame: ICefFrame; const context: ICefv8Context;
  const exception: ICefV8Exception; const stackTrace: ICefV8StackTrace);
begin
  if assigned(frame) and frame.IsValid then
    frame.ExecuteJavaScript
      ('console.log("GlobalCEFApp_OnUncaughtException");', '', 0);
end;

procedure CreateGlobalCEFApp;
begin
  GlobalCEFApp := TCefApplication.Create;
  GlobalCEFApp.cache := 'cache';
  GlobalCEFApp.EnablePrintPreview := True;
  GlobalCEFApp.EnableGPU := True;
  GlobalCEFApp.LogFile := 'debug.log';
  GlobalCEFApp.LogSeverity := LOGSEVERITY_INFO;
  GlobalCEFApp.UncaughtExceptionStackSize := 50;
  GlobalCEFApp.OnUncaughtException := GlobalCEFApp_OnUncaughtException;
end;

procedure TMiniBrowserFrm.Button1Click(Sender: TObject);
begin
AppLog.Lines.Add('Command: Set proxy manually');
  ProxyString := ProxyStringManualInput.Text;
  SaveProxyForHelper();
  StartHelperInstance();
  KillFirefoxProcesses();
  ShellExecute(0, 'open', 'firefox.exe', nil, nil, SW_SHOWNORMAL);
  OpenBrowserWithNewIdenty.Enabled := False;
end;

procedure TMiniBrowserFrm.Chromium1AfterCreated(Sender: TObject;
  const browser: ICefBrowser);
begin
  if Chromium1.IsSameBrowser(browser) then
    PostMessage(Handle, CEF_AFTERCREATED, 0, 0)
  else
    SendMessage(browser.host.WindowHandle, WM_SETICON, 1,
      application.Icon.Handle);
end;

procedure TMiniBrowserFrm.Chromium1BeforeClose(Sender: TObject;
  const browser: ICefBrowser);
begin
  if (Chromium1.BrowserId = 0) then
  begin
    FCanClose := True;
    PostMessage(Handle, WM_CLOSE, 0, 0);
  end;
end;

procedure TMiniBrowserFrm.Chromium1BeforeResourceLoad(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const callback: ICefCallback;
  out Result: TCefReturnValue);
begin
  Result := RV_CONTINUE;

  if Chromium1.IsSameBrowser(browser) and (frame <> nil) and frame.IsMain and
    frame.IsValid then
  begin
    ReplaceAcceptEncoding(request);
    InspectRequest(request);
  end;
end;

procedure TMiniBrowserFrm.Chromium1CertificateError(Sender: TObject;
  const browser: ICefBrowser; certError: TCefErrorCode;
  const requestUrl: ustring; const sslInfo: ICefSslInfo;
  const callback: ICefCallback; out Result: Boolean);
begin
  CefDebugLog('Certificate error code:' + inttostr(certError) + ' - URL:' +
    requestUrl, CEF_LOG_SEVERITY_ERROR);
  Result := False;
end;

procedure TMiniBrowserFrm.Chromium1LoadEnd(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
var
  TempHandle: THandle;
begin
  if FClosing or (frame = nil) or not(frame.IsValid) or (browser = nil) then
    exit;
  if Chromium1.IsSameBrowser(browser) then
  begin
    if SameText(Chromium1.browser.MainFrame.url, 'https://nsocks.net/proxy')
    then
    begin
      GetLocalizedProxies();
    end;
    if frame.IsMain then
    begin
      AppLog.Lines.Add('Status: Proxy service main page loaded');
      Chromium1.browser.MainFrame.ExecuteJavaScript
        ('var btn = document.querySelector("a.login-button");if(btn) btn.click();',
        Chromium1.browser.MainFrame.url, 0);
    end
    else
     AppLog.Lines.Add('Status: Proxy service part of page loaded');
  end
  else
  begin
    TempHandle := Winapi.Windows.GetWindow(browser.host.WindowHandle, GW_OWNER);
    if (TempHandle <> Handle) then
      Winapi.Windows.SetFocus(TempHandle);
  end;
end;

procedure TMiniBrowserFrm.Chromium1LoadError(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; errorCode: TCefErrorCode;
  const errorText, failedUrl: ustring);
var
  TempString: string;
begin
  if (errorCode = ERR_ABORTED) then
    exit;

  TempString := '<html><body bgcolor="white">' + '<h2>Failed to load URL ' +
    failedUrl + ' with error ' + errorText + ' (' + inttostr(errorCode) +
    ').</h2></body></html>';

  Chromium1.LoadString(TempString, frame);
end;

procedure TMiniBrowserFrm.Chromium1LoadingProgressChange(Sender: TObject;
  const browser: ICefBrowser; const progress: Double);
begin
  AppLog.Lines.Add('Status: Loading... ' + FloatToStrF(progress * 100,
    ffFixed, 3, 0) + '%');
end;

procedure TMiniBrowserFrm.Chromium1LoadingStateChange(Sender: TObject;
  const browser: ICefBrowser; isLoading, canGoBack, canGoForward: Boolean);
begin
  if not(Chromium1.IsSameBrowser(browser)) or FClosing then
    exit;

  if isLoading then
  begin
    AppLog.Lines.Add('Status: Loading...');
  end
  else
  begin
    AppLog.Lines.Add('Status: Finished');
  end;
end;

procedure TMiniBrowserFrm.Chromium1ResolvedHostAvailable(Sender: TObject;
  Result: TCefErrorCode; const resolvedIps: TStrings);
begin
  if (Result = ERR_NONE) then
    showmessage('Resolved IPs : ' + resolvedIps.CommaText)
  else
    showmessage('There was a problem resolving the host.' + CRLF +
      'Error code : ' + inttostr(Result));
end;

// This is just an example of HTTP header replacement.
procedure TMiniBrowserFrm.ReplaceAcceptEncoding(const aRequest: ICefRequest);
const
  ACCEPT_ENCODING_HEADER = 'Accept-Encoding';
var
  TempOldMap, TempNewMap: ICefStringMultimap;
  i: NativeUInt;
begin
  try
    TempNewMap := TCefStringMultimapOwn.Create;
    TempOldMap := TCefStringMultimapOwn.Create;

    // We get all the old request headers
    aRequest.GetHeaderMap(TempOldMap);

    i := 0;
    while (i < TempOldMap.Size) do
    begin
      // Copy all headers except the "Accept-Encoding" header
      if (CompareText(TempOldMap.Key[i], ACCEPT_ENCODING_HEADER) <> 0) then
        TempNewMap.Append(TempOldMap.Key[i], TempOldMap.value[i]);

      inc(i);
    end;

    // We append the new "Accept-Encoding" header with a custom value
    TempNewMap.Append(ACCEPT_ENCODING_HEADER, 'gzip');

    // And then we set all the headers in the request
    aRequest.SetHeaderMap(TempNewMap);
  finally
    TempNewMap := nil;
    TempOldMap := nil;
  end;
end;

procedure TMiniBrowserFrm.InspectRequest(const aRequest: ICefRequest);
var
  TempHeaderMap: ICefStringMultimap;
  i, j: Integer;
begin
  if (aRequest <> nil) then
  begin
    FRequest.Clear;

    TempHeaderMap := TCefStringMultimapOwn.Create;
    aRequest.GetHeaderMap(TempHeaderMap);

    i := 0;
    j := TempHeaderMap.Size;

    while (i < j) do
    begin
      FRequest.Add(TempHeaderMap.Key[i] + '=' + TempHeaderMap.value[i]);
      inc(i);
    end;
  end;
end;

procedure TMiniBrowserFrm.InspectResponse(const aResponse: ICefResponse);
var
  TempHeaderMap: ICefStringMultimap;
  i, j: Integer;
begin
  if (aResponse <> nil) then
  begin
    FResponse.Clear;

    TempHeaderMap := TCefStringMultimapOwn.Create;
    aResponse.GetHeaderMap(TempHeaderMap);

    i := 0;
    j := TempHeaderMap.Size;

    while (i < j) do
    begin
      FResponse.Add(TempHeaderMap.Key[i] + '=' + TempHeaderMap.value[i]);
      inc(i);
    end;
  end;
end;

procedure TMiniBrowserFrm.Chromium1ResourceResponse(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const response: ICefResponse;
  out Result: Boolean);
begin
  Result := False;

  if Chromium1.IsSameBrowser(browser) and (frame <> nil) and frame.IsMain and
    frame.IsValid then
    InspectResponse(response);
end;


procedure TMiniBrowserFrm.Chromium1SelectClientCertificate(Sender: TObject;
  const browser: ICefBrowser; isProxy: Boolean; const host: ustring;
  port: Integer; certificatesCount: NativeUInt;
  const certificates: TCefX509CertificateArray;
  const callback: ICefSelectClientCertificateCallback; var aResult: Boolean);
var
  i: Integer;
begin
  if assigned(callback) and assigned(certificates) and (length(certificates) > 0)
  then
  begin
    aResult := True;
    FSelectCertCallback := callback;

    SetLength(FCertificates, length(certificates));

    for i := 0 to pred(length(certificates)) do
      FCertificates[i] := certificates[i];

    PostMessage(Handle, MINIBROWSER_SELECTCERT, 0, 0);
  end
  else
    aResult := False;
end;

procedure TMiniBrowserFrm.Chromium1StatusMessage(Sender: TObject;
  const browser: ICefBrowser; const value: ustring);
begin
  if Chromium1.IsSameBrowser(browser) then
    AppLog.Lines.Add(value);
end;

procedure TMiniBrowserFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 KillMiniBrowserProcesses;
end;

procedure TMiniBrowserFrm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := FCanClose;
  if not(FClosing) then
  begin
    FClosing := True;
    Visible := False;
    Chromium1.CloseAllBrowsers;
    CEFWindowParent1.Free;
  end;
end;

procedure TMiniBrowserFrm.FormCreate(Sender: TObject);
begin
  CurrentDirectory := ExtractFilePath(paramstr(0));
  ProxiesIDs := TStringList.Create;
  FCanClose := False;
  FClosing := False;
  FResponse := TStringList.Create;
  FRequest := TStringList.Create;
  FNavigation := TStringList.Create;
  FSelectCertCallback := nil;
  FMediaAccessCallback := nil;
  FCertificates := nil;
  FPendingMsgID := 0;
  FAllowDownloads := True;
  FShutdownReason := 'Socks changer service closing...';
  FHasShutdownReason := ShutdownBlockReasonCreate(application.Handle,
    @FShutdownReason[1]);
  Chromium1.MultiBrowserMode := True;
  Chromium1.DefaultURL := MINIBROWSER_HOMEPAGE;
  Chromium1.OnConsoleMessage := Chromium1ConsoleMessage;
end;

procedure TMiniBrowserFrm.FormDestroy(Sender: TObject);
begin
  if FHasShutdownReason then
    ShutdownBlockReasonDestroy(application.Handle);

  ProxiesIDs.Free;
  DestroyCertificates;

  FSelectCertCallback := nil;
  FMediaAccessCallback := nil;
  FResponse.Free;
  FRequest.Free;
  FNavigation.Free;
end;

procedure TMiniBrowserFrm.FormShow(Sender: TObject);
begin
  AppLog.Lines.Add('Status: Initializing browser. Please wait...');

  Chromium1.WebRTCIPHandlingPolicy := hpDisableNonProxiedUDP;
  Chromium1.WebRTCMultipleRoutes := STATE_DISABLED;
  Chromium1.WebRTCNonproxiedUDP := STATE_DISABLED;
  Chromium1.AcceptLanguageList := 'en-GB,en';
  if not(Chromium1.CreateBrowser(CEFWindowParent1, '')) then
    Timer1.Enabled := True;
end;

procedure TMiniBrowserFrm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if not(Chromium1.CreateBrowser(CEFWindowParent1, '')) and
    not(Chromium1.Initialized) then
    Timer1.Enabled := True;
end;

procedure TMiniBrowserFrm.BrowserCreatedMsg(var aMessage: TMessage);
begin
  CEFWindowParent1.UpdateSize;
end;

procedure TMiniBrowserFrm.DestroyCertificates;
var
  i: Integer;
begin
  if assigned(FCertificates) then
  begin
    i := 0;
    while (i < length(FCertificates)) do
    begin
      FCertificates[i] := nil;
      inc(i);
    end;

    Finalize(FCertificates);
    FCertificates := nil;
  end;
end;


procedure TMiniBrowserFrm.ShowResponseMsg(var aMessage: TMessage);
begin
  SimpleTextViewerFrm.Memo1.Lines.Clear;

  SimpleTextViewerFrm.Memo1.Lines.Add('--------------------------');
  SimpleTextViewerFrm.Memo1.Lines.Add('Request headers : ');
  SimpleTextViewerFrm.Memo1.Lines.Add('--------------------------');
  if (FRequest <> nil) then
    SimpleTextViewerFrm.Memo1.Lines.AddStrings(FRequest);

  SimpleTextViewerFrm.Memo1.Lines.Add('');

  SimpleTextViewerFrm.Memo1.Lines.Add('--------------------------');
  SimpleTextViewerFrm.Memo1.Lines.Add('Response headers : ');
  SimpleTextViewerFrm.Memo1.Lines.Add('--------------------------');
  if (FResponse <> nil) then
    SimpleTextViewerFrm.Memo1.Lines.AddStrings(FResponse);

  SimpleTextViewerFrm.ShowModal;
end;

procedure TMiniBrowserFrm.ShowNavigationMsg(var aMessage: TMessage);
begin
  SimpleTextViewerFrm.Memo1.Lines.Clear;
  SimpleTextViewerFrm.Memo1.Lines.AddStrings(FNavigation);
  SimpleTextViewerFrm.ShowModal;
end;

procedure TMiniBrowserFrm.WMQueryEndSession(var aMessage: TWMQueryEndSession);
begin
  aMessage.Result := 0;
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;

procedure TMiniBrowserFrm.SaveProxyForHelper();
var
  JSONObject: TJSONObject;
  JSONString: TStringList;
  FilePath: string;
begin
  AppLog.Lines.Add('Command: Save proxy for helper');
  ParseProxyString();
  JSONObject := TJSONObject.Create;
  JSONString := TStringList.Create;
  try
    JSONObject.AddPair('type', 'socks');
    JSONObject.AddPair('host', Host);
    JSONObject.AddPair('port', Port);
    JSONObject.AddPair('username', Username);
    JSONObject.AddPair('password', Password);
    JSONString.Text := JSONObject.ToJSON;
    FilePath := SOCKS_EXCHANGE_PATH;
    ForceDirectories(ExtractFilePath(FilePath));
    JSONString.SaveToFile(FilePath, TEncoding.UTF8);
  finally
    JSONObject.Free;
    JSONString.Free;
  end;
end;

procedure TMiniBrowserFrm.GetLocalizedProxies();
var
  jsCode: string;
  FileName: string;
  FileContent: TStringList;
begin
  AppLog.Lines.Add('Command: Set localized proxies');
  CEFWindowParent1.Enabled := False;
  FileContent := TStringList.Create;
  FileName := GetCurrentDir + PathDelim + 'Javascript' + PathDelim +
    'LoadLocalizedProxies.js';

  try
    FileContent.LoadFromFile(FileName, TEncoding.UTF8);
    jsCode := FileContent.Text;
  finally
    FileContent.Free;
  end;

  Chromium1.browser.MainFrame.ExecuteJavaScript(jsCode,
    Chromium1.browser.MainFrame.url, 0);
end;

procedure TMiniBrowserFrm.Chromium1ConsoleMessage(Sender: TObject;
  const browser: ICefBrowser; level: TCefLogSeverity;
  const message_, source: ustring; line: Integer; out Result: Boolean);
var
  HTML: string;
begin
  AppLog.Lines.Add('Console: ' + message_);
  if Copy(message_, 1, 9) = 'MAINLIST:' then
  begin
    ProxiesIDs.Clear;
    ProxiesIDs.Add(Copy(message_, 10, MaxInt));
    HTML := AppLog.Text;
    AppLog.Lines.Clear;
    try
      ExtractProxiesIDs(HTML, ProxiesIDs);
      if (ProxiesIDs.Count > 0) then
        GetNewIdenty.Enabled := True;
    finally
    end;
  end;

  if message_ = 'CartIsReady' then
  begin
    ShowCartAndBuyProxy();
  end;

  if Copy(message_, 1, 6) = 'PROXY:' then
  begin
    ProxyString := Copy(message_, 7, MaxInt);
    SaveProxyForHelper();
    SetBuyedProxy();
  end;

  if (message_ = 'GlobalCEFApp_OnUncaughtException') then
  begin
    inc(FJSException);
    AppLog.Lines.Add('JS exception: ' + inttostr(FJSException));
  end;
end;

procedure TMiniBrowserFrm.ExtractProxiesIDs(const HTML: string;
  AList: TStringList);
var
  Regex: TRegEx;
  Matches: TMatchCollection;
  Match: TMatch;
begin
  AppLog.Lines.Add('Command: Extract proxies');
  AList.Clear;
  AList.Sorted := True;
  AList.Duplicates := dupIgnore;
  Regex := TRegEx.Create('id="(\d+)"');
  Matches := Regex.Matches(HTML);
  for Match in Matches do
    AList.Add(Match.Groups[1].value);
end;

procedure TMiniBrowserFrm.GetNewIdentyClick(Sender: TObject);
begin
  ProxyId := GetRandomProxy();
  AppLog.Lines.Add('Command: Select random proxy: ' + ProxyId);
  Chromium1.browser.MainFrame.ExecuteJavaScript
    ('document.querySelector(''button.btn-sm-cart[data-id="' + ProxyId +
    '"]'').click();setTimeout(function() {console.log("CartIsReady");}, 2000);',
    Chromium1.browser.MainFrame.url, 0);
  AppLog.Lines.Add('Command: Cart is ready');
end;

procedure TMiniBrowserFrm.OpenBrowserWithNewIdentyClick(Sender: TObject);
begin
  GetBuyedProxyFromCart();
end;

procedure TMiniBrowserFrm.ShowCartAndBuyProxy();
begin
  AppLog.Lines.Add('Command: Show cart and buy random proxy ' + ProxyId);
  Chromium1.browser.MainFrame.ExecuteJavaScript
    ('document.querySelector("button.view-cart").click();',
    Chromium1.browser.MainFrame.url, 0);
  Sleep(3000);
  Chromium1.browser.MainFrame.ExecuteJavaScript
    ('document.querySelector(''button.cart-buy-item[data-id="' + ProxyId +
    '"]'').click();', Chromium1.browser.MainFrame.url, 0);
  Sleep(5000);
  OpenBrowserWithNewIdenty.Enabled := True;
  CEFWindowParent1.Enabled := True;
  GetNewIdenty.Enabled := False;
end;

procedure TMiniBrowserFrm.GetBuyedProxyFromCart();
begin
  AppLog.Lines.Add('Command: Copy random buyed proxy string ' + ProxyId);

  Chromium1.browser.MainFrame.ExecuteJavaScript
    ('var value = document.querySelector(''span[data-id="' + ProxyId +
    '"] .bi-back'').parentElement.textContent.trim();console.log("PROXY:" + value);',
    Chromium1.browser.MainFrame.url, 0);
end;

procedure TMiniBrowserFrm.SetBuyedProxy();
begin
  AppLog.Lines.Add('Command: Set buyed proxy ' + ProxyId);
  StartHelperInstance();
  Chromium1.CloseAllBrowsers;
  AppLog.Lines.Add('Command: Open browser');
  KillFirefoxProcesses();
  ShellExecute(0, 'open', 'firefox.exe', nil, nil, SW_SHOWNORMAL);
  OpenBrowserWithNewIdenty.Enabled := False;
end;

function TMiniBrowserFrm.GetRandomProxy(): string;
var
  Index: Integer;
begin
  AppLog.Lines.Add('Command: Prepare a random proxy selection');
  Result := '';
  if ProxiesIDs.Count > 0 then
  begin
    Randomize;
    Index := Random(ProxiesIDs.Count);
    Result := ProxiesIDs[Index];
  end;
end;

procedure TMiniBrowserFrm.ParseProxyString;
var
  ProxyLine, UserPass, HostPort, UsernamePart, PasswordPart, HostPart,
    PortPart: string;
  AtPos, ColonPos: Integer;
begin
  Username := '';
  Password := '';
  Host := '';
  Port := '';

  ProxyLine := Trim(ProxyString);
  AtPos := Pos('@', ProxyLine);

  if AtPos > 0 then
  begin
    UserPass := Copy(ProxyLine, 1, AtPos - 1);
    HostPort := Copy(ProxyLine, AtPos + 1, MaxInt);

    ColonPos := Pos(':', UserPass);
    if ColonPos > 0 then
    begin
      UsernamePart := Copy(UserPass, 1, ColonPos - 1);
      PasswordPart := Copy(UserPass, ColonPos + 1, MaxInt);
    end
    else
    begin
      UsernamePart := UserPass;
      PasswordPart := '';
    end;

    ColonPos := Pos(':', HostPort);
    if ColonPos > 0 then
    begin
      HostPart := Copy(HostPort, 1, ColonPos - 1);
      PortPart := Copy(HostPort, ColonPos + 1, MaxInt);
    end
    else
    begin
      HostPart := HostPort;
      PortPart := '';
    end;

    Username := UsernamePart;
    Password := PasswordPart;
    Host := HostPart;
    Port := PortPart;

    HostManualInput.Text := Host;
    PortManualInput.Text := Port;
    UsernameManualInput.Text := Username;
    PasswordManualInput.Text := Password;

  end
  else
  begin
    ColonPos := Pos(':', ProxyLine);
    if ColonPos > 0 then
    begin
      Host := Copy(ProxyLine, 1, ColonPos - 1);
      Port := Copy(ProxyLine, ColonPos + 1, MaxInt);
    end
    else
    begin
      Host := ProxyLine;
      Port := '';
    end;
  end;
end;

procedure TMiniBrowserFrm.StartHelperInstance();
var
  FileName: string;
begin
  AppLog.Lines.Add('Command: Start helper instance');
  FileName := IncludeTrailingPathDelimiter(GetCurrentDir) + 'Helper' + PathDelim
    + 'Helper.exe';
  ShellExecute(0, 'open', pchar(FileName), nil, nil, SW_SHOWNORMAL);
end;

end.
