unit BrowserUtil;

interface

uses
  System.SysUtils, Winapi.Windows, Winapi.WinInet, System.Win.Registry,
  System.IOUtils, System.Classes, Winapi.ShellAPI, System.Types,
  Winapi.TlHelp32, Winapi.Winsock, Psapi;

const
  PROCESS_NAME_NATIVE = 0;

procedure KillFirefoxProcesses;
procedure KillMiniBrowserProcesses;
function GetProcessPath(hProcess: THandle): string;

implementation

function QueryFullProcessImageName(hProcess: THandle; dwFlags: DWORD; lpExeName: PChar; var lpdwSize: DWORD): BOOL; stdcall;
  external 'kernel32.dll' name 'QueryFullProcessImageNameW';

procedure KillFirefoxProcesses;
var
  hSnapshot: THandle;
  ProcEntry: TProcessEntry32;
  hProcess: THandle;
begin
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnapshot = INVALID_HANDLE_VALUE then
    Exit;
  try
    ProcEntry.dwSize := SizeOf(TProcessEntry32);
    if Process32First(hSnapshot, ProcEntry) then
    begin
      repeat
        if SameText(ExtractFileName(ProcEntry.szExeFile), 'firefox.exe') then
        begin
          hProcess := OpenProcess(PROCESS_TERMINATE, False, ProcEntry.th32ProcessID);
          if hProcess <> 0 then
          begin
            TerminateProcess(hProcess, 0);
            CloseHandle(hProcess);
          end;
        end;
      until not Process32Next(hSnapshot, ProcEntry);
    end;
  finally
    CloseHandle(hSnapshot);
  end;
end;

procedure KillMiniBrowserProcesses;
var
  Snapshot: THandle;
  ProcEntry: TProcessEntry32;
  hProc: THandle;
  CurrentProcessID: DWORD;
begin
  CurrentProcessID := GetCurrentProcessId;

  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then Exit;

  ProcEntry.dwSize := SizeOf(TProcessEntry32);
  if Process32First(Snapshot, ProcEntry) then
  repeat
    if SameText(ProcEntry.szExeFile, 'MiniBrowser.exe') then
    begin
      if ProcEntry.th32ProcessID <> CurrentProcessID then
      begin
        hProc := OpenProcess(PROCESS_TERMINATE, False, ProcEntry.th32ProcessID);
        if hProc <> 0 then
        begin
          TerminateProcess(hProc, 0);
          CloseHandle(hProc);
        end;
      end;
    end;
  until not Process32Next(Snapshot, ProcEntry);

  CloseHandle(Snapshot);
end;

procedure KillMiniBrowserProcesses;
var
  Snapshot: THandle;
  ProcEntry: TProcessEntry32;
  hProc: THandle;
begin
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then Exit;

  ProcEntry.dwSize := SizeOf(TProcessEntry32);
  if Process32First(Snapshot, ProcEntry) then
  repeat
    if SameText(ProcEntry.szExeFile, 'MiniBrowser.exe') then
    begin
      hProc := OpenProcess(PROCESS_TERMINATE, False, ProcEntry.th32ProcessID);
      if hProc <> 0 then
      begin
        TerminateProcess(hProc, 0);
        CloseHandle(hProc);
      end;
    end;
  until not Process32Next(Snapshot, ProcEntry);

  CloseHandle(Snapshot);
end;

function GetProcessPath(hProcess: THandle): string;
var
  buffer: array[0..MAX_PATH - 1] of Char;
  size: DWORD;
begin
  Result := '';
  size := MAX_PATH;
  if QueryFullProcessImageName(hProcess, 0, buffer, size) then
    Result := buffer
  else if GetModuleFileNameEx(hProcess, 0, buffer, size) > 0 then
    Result := buffer;
end;

end.

