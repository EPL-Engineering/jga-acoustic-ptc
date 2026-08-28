; -- jga-acoustic-ptc.iss --

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!
#define SemanticVersion "1.5"
#define verStr_ StringChange(SemanticVersion, '.', '-')

#define DevRoot GetEnv("DEVROOT")
#if DevRoot == ""
    #error "DEVROOT environment variable is not set"
#endif
#define OppDir = DevRoot + "\Arenberg\jga-opp\MATLAB"

[Setup]
AppName=Acoustic PTC
AppVerName=Acoustic PTC V{#SemanticVersion}
DefaultDirName="C:\Acoustic PTC"
DisableDirPage=yes
DirExistsWarning=no
OutputDir=Output
AllowNoIcons=yes
OutputBaseFilename=AcousticPTC_v{#verStr_}
UsePreviousAppDir=no
UsePreviousGroup=no
UsePreviousSetupType=no
Uninstallable=no
DisableProgramGroupPage=yes
PrivilegesRequired=admin

[Dirs]
Name: "C:\EPL";

[Files]
Source: "..\*.*"; DestDir: "{app}"; Flags: replacesameversion; Excludes: .gitignore
Source: "..\Cochlear\*.*"; DestDir: "{app}\Cochlear"; Flags: replacesameversion
Source: "..\ProgressBar\*.*"; DestDir: "{app}\Cochlear\ProgressBar"; Flags: replacesameversion
; === OPP ===
Source: "{#OppDir}\OPP\*.*"; DestDir: "{app}\OPP\OPP"; Flags: replacesameversion;
Source: "{#OppDir}\OPP\DotNet\*.*"; DestDir: "{app}\OPP\OPP\DotNet"; Flags: replacesameversion recursesubdirs;
Source: "{#OppDir}\Help\*.*"; DestDir: "{app}\OPP\Help"; Flags: replacesameversion;
Source: "{#OppDir}\MOTU\*.*"; DestDir: "{app}\OPP\MOTU"; Flags: replacesameversion;
Source: "{#OppDir}\Ontrak\*.*"; DestDir: "{app}\OPP\Ontrak"; Flags: replacesameversion;
Source: "{#OppDir}\VLC\*.*"; DestDir: "{app}\OPP\VLC"; Flags: replacesameversion;
Source: "{#OppDir}\..\CHANGELOG.md"; DestDir: "{app}\OPP"; Flags: replacesameversion;

[InstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function IsProcessRunning(const ExeName: string): Boolean;
var
  ResultCode: Integer;
  TempFile: string;
  Contents: AnsiString;
begin
  Result := False;
  TempFile := ExpandConstant('{tmp}\proclist.txt');
  if Exec(ExpandConstant('{cmd}'),
          '/C tasklist /FI "IMAGENAME eq ' + ExeName + '" /NH > "' + TempFile + '"',
          '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    if LoadStringFromFile(TempFile, Contents) then
      Result := Pos(LowerCase(ExeName), LowerCase(string(Contents))) > 0;
  DeleteFile(TempFile);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpReady then
  begin
    { Gate first: refuse to proceed while MATLAB holds locks on the tree. }
    if IsProcessRunning('MATLAB.exe') then
    begin
      MsgBox('MATLAB is still running. Please close it completely, then click Next.',
             mbError, MB_OK);
      Result := False;
      Exit;
    end;

    { Then confirm the destructive wipe, showing the actual path. }
    Result := MsgBox(
      'IMPORTANT — read before continuing.' + #13#10 + #13#10 +
      'This installer will permanently DELETE everything in:' + #13#10 +
      ExpandConstant('{app}') + #13#10 +
      'and replace it with the new version. Only one copy of the code will ' +
      'remain on this machine.' + #13#10 + #13#10 +
      'Continue?',
      mbConfirmation, MB_YESNO) = IDYES;
  end;
end;

