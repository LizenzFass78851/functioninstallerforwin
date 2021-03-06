@echo off

echo Checking for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

echo Permission check result: %errorlevel%

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

echo Running created temporary "%temp%\getadmin.vbs"
timeout /T 2
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0" 

echo Batch was successfully started with admin privileges
echo .
cls
GOTO:menu
:menu
Title Hyper-V Installer
echo Backup wird dringend empfohlen!
echo um u.a. Hyper-V spurenlos und sicher zu entfernen.
echo --------------------------------------------------
echo Was soll das Setup tun?
echo 1 Installieren
echo 2 Deinstallieren
echo 3 Beenden
set /p uni= Option in Zahl eintippen:
if %uni% ==1 goto :in
if %uni% ==2 goto :un
if %uni% ==3 goto :ex

:in
cls
Title Install Hyper-V

pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt

for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

del hyper-v.txt

Dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /LimitAccess /ALL /NoRestart

goto :remenu

:un
cls
Title Uninstall Hyper-V

pushd "%~dp0"

Dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /NoRestart

dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt

for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /remove-package:"%SystemRoot%\servicing\Packages\%%i"

del hyper-v.txt

goto :remenu

:remenu
cls
echo Möchten Sie den Computer jetzt neu starten?
echo 1 Ja
echo 2 Nein
set /p uni= Option in Zahl eintippen:
if %uni% ==1 goto :re
if %uni% ==2 goto :ex

:re
shutdown /r /t 0 /f
goto :ex

:ex
exit