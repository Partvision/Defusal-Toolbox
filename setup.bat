@echo off
setlocal EnableDelayedExpansion

:: -------------------------
:: ADMIN CHECK
:: -------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This shit needs admin. Relaunching...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: -------------------------
:: FILES
:: -------------------------
set ROOT=%~dp0
set LOG=%ROOT%install.log
set SELECTED=%ROOT%selected.txt
set HEADLESS=0
set ALL=0

:: -------------------------
:: CLI FLAGS
:: -------------------------
for %%A in (%*) do (
    if "%%A"=="--headless" set HEADLESS=1
    if "%%A"=="--all" set ALL=1
)

echo ==== INSTALL START ==== > "%LOG%"

:: -------------------------
:: UI
:: -------------------------
if %HEADLESS%==0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%ui.ps1"
)

if %ALL%==1 (
    echo Browsers> "%SELECTED%"
    echo Dev>> "%SELECTED%"
    echo Utilities>> "%SELECTED%"
    echo Runtime>> "%SELECTED%"
    echo Tweaks>> "%SELECTED%"
)

if not exist "%SELECTED%" (
    echo Nothing selected. Exiting.
    exit /b 1
)

:: -------------------------
:: INSTALL FUNCTION
:: -------------------------
:install
echo Installing %1 >> "%LOG%"
winget install --id %1 -e --accept-package-agreements --accept-source-agreements >> "%LOG%" 2>&1
if errorlevel 1 (
    echo FAILED: %1 >> "%LOG%"
    echo FUCKED INSTALL: %1
)
exit /b

:: -------------------------
:: CATEGORY LOOP
:: -------------------------
for /f %%C in (%SELECTED%) do (

    if "%%C"=="Browsers" (
        call :install Mozilla.Firefox
        call :install Mozilla.Firefox.ESR
        call :install Brave.Brave
        call :install UngoogledChromium.UngoogledChromium
        call :install Chromium.Chromium
        call :install LibreWolf.LibreWolf
        call :install MullvadVPN.MullvadBrowser
        call :install TorProject.TorBrowser
        call :install Vivaldi.Vivaldi
        call :install Opera.OperaGX
    )

    if "%%C"=="Dev" (
        call :install Git.Git
        call :install GitHub.GitLFS
        call :install GitHub.GitHubDesktop
        call :install OpenJS.NodeJS.LTS
        call :install Python.Python.3
        call :install Rustlang.Rustup
        call :install GoLang.Go
        call :install EclipseAdoptium.Temurin.17.JDK
        call :install Docker.DockerDesktop
        call :install Microsoft.PowerShell
        call :install Microsoft.WindowsTerminal
        call :install Microsoft.WSL
    )

    if "%%C"=="Utilities" (
        call :install 7zip.7zip
        call :install Microsoft.NanaZip
        call :install voidtools.Everything
        call :install AntibodySoftware.WizTree
        call :install ShareX.ShareX
        call :install Rufus.Rufus
        call :install Ventoy.Ventoy
        call :install Notepad++.Notepad++
        call :install Microsoft.VisualStudioCode
        call :install VideoLAN.VLC
        call :install clsid2.mpc-hc
        call :install SumatraPDF.SumatraPDF
        call :install OBSProject.OBSStudio
        call :install Valve.Steam
        call :install Discord.Discord
    )

    if "%%C"=="Runtime" (
        call :install Microsoft.VCRedist.2015+.x64
        call :install Microsoft.DotNet.DesktopRuntime.8
        call :install Microsoft.DirectX
        call :install OpenAL.OpenAL
        call :install Microsoft.EdgeWebView2Runtime
    )

    if "%%C"=="Tweaks" (
        powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%tweaks.ps1" >> "%LOG%" 2>&1
    )
)

echo ==== DONE ==== >> "%LOG%"
echo All done. Check install.log for the carnage.
pause
