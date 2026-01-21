@echo off
setlocal EnableDelayedExpansion

:: -------------------------
:: ADMIN CHECK
:: -------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script needs admin rights. Relaunching...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: -------------------------
:: FILES
:: -------------------------
set "ROOT=%~dp0"
set "LOG=%ROOT%install.log"
set "SELECTED=%ROOT%selected.txt"
set "HEADLESS=0"
set "ALL=0"

:: -------------------------
:: CLI FLAGS
:: -------------------------
for %%A in (%*) do (
    if /i "%%A"=="--headless" set "HEADLESS=1"
    if /i "%%A"=="--all" set "ALL=1"
)

echo ==== INSTALL START - %date% %time% ==== > "%LOG%"

:: -------------------------
:: CHECK WINGET
:: -------------------------
where winget >nul 2>&1
if errorlevel 1 (
    echo ERROR: winget not found. Install App Installer from Microsoft Store.
    echo ERROR: winget not found >> "%LOG%"
    pause
    exit /b 1
)

:: -------------------------
:: UI
:: -------------------------
if %HEADLESS%==0 (
    if exist "%ROOT%ui.ps1" (
        powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%ui.ps1"
    ) else (
        echo WARNING: ui.ps1 not found, using --all mode
        set "ALL=1"
    )
)

:: -------------------------
:: AUTO-SELECT ALL IF NEEDED
:: -------------------------
if %ALL%==1 (
    echo Browsers> "%SELECTED%"
    echo Dev>> "%SELECTED%"
    echo Utilities>> "%SELECTED%"
    echo Runtime>> "%SELECTED%"
    echo Tweaks>> "%SELECTED%"
)

if not exist "%SELECTED%" (
    echo Nothing selected. Exiting.
    pause
    exit /b 1
)

:: -------------------------
:: CATEGORY LOOP
:: -------------------------
for /f "usebackq tokens=*" %%C in ("%SELECTED%") do (
    echo.
    echo ========================================
    echo Installing category: %%C
    echo ========================================
    
    if /i "%%C"=="Browsers" (
        call :install Mozilla.Firefox "Firefox"
        call :install Mozilla.Firefox.ESR "Firefox ESR"
        call :install Brave.Brave "Brave"
        call :install eloston.ungoogled-chromium "Ungoogled Chromium"
        call :install Hibbiki.Chromium "Chromium"
        call :install LibreWolf.LibreWolf "LibreWolf"
        call :install MullvadVPN.MullvadBrowser "Mullvad Browser"
        call :install TorProject.TorBrowser "Tor Browser"
        call :install VivaldiTechnologies.Vivaldi "Vivaldi"
        call :install Opera.OperaGX "Opera GX"
    )
    
    if /i "%%C"=="Dev" (
        call :install Git.Git "Git"
        call :install GitHub.GitLFS "Git LFS"
        call :install GitHub.GitHubDesktop "GitHub Desktop"
        call :install OpenJS.NodeJS.LTS "Node.js LTS"
        call :install Python.Python.3.13 "Python 3.13"
        call :install Rustlang.Rustup "Rust"
        call :install GoLang.Go "Go"
        call :install EclipseAdoptium.Temurin.17.JDK "Java 17 JDK"
        call :install Docker.DockerDesktop "Docker Desktop"
        call :install Microsoft.PowerShell "PowerShell 7"
        call :install Microsoft.WindowsTerminal "Windows Terminal"
    )
    
    if /i "%%C"=="Utilities" (
        call :install 7zip.7zip "7-Zip"
        call :install M2Team.NanaZip "NanaZip"
        call :install voidtools.Everything "Everything"
        call :install AntibodySoftware.WizTree "WizTree"
        call :install ShareX.ShareX "ShareX"
        call :install Rufus.Rufus "Rufus"
        call :install Ventoy.Ventoy "Ventoy"
        call :install Notepad++.Notepad++ "Notepad++"
        call :install Microsoft.VisualStudioCode "VS Code"
        call :install VideoLAN.VLC "VLC Media Player"
        call :install clsid2.mpc-hc "MPC-HC"
        call :install SumatraPDF.SumatraPDF "Sumatra PDF"
        call :install OBSProject.OBSStudio "OBS Studio"
        call :install Valve.Steam "Steam"
        call :install Discord.Discord "Discord"
    )
    
    if /i "%%C"=="Runtime" (
        call :install Microsoft.VCRedist.2015+.x64 "Visual C++ Redist"
        call :install Microsoft.DotNet.DesktopRuntime.8 ".NET 8 Desktop Runtime"
        call :install Microsoft.DirectX "DirectX"
        call :install OpenAL.OpenAL "OpenAL"
        call :install Microsoft.EdgeWebView2Runtime "Edge WebView2"
    )
    
    if /i "%%C"=="Tweaks" (
        if exist "%ROOT%tweaks.ps1" (
            echo Running tweaks.ps1...
            powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%tweaks.ps1" >> "%LOG%" 2>&1
            if errorlevel 1 (
                echo FAILED: tweaks.ps1 >> "%LOG%"
                echo WARNING: tweaks.ps1 failed, check log
            ) else (
                echo SUCCESS: tweaks.ps1 applied
            )
        ) else (
            echo WARNING: tweaks.ps1 not found, skipping tweaks
            echo WARNING: tweaks.ps1 not found >> "%LOG%"
        )
    )
)

:: -------------------------
:: CLEANUP
:: -------------------------
del "%SELECTED%" >nul 2>&1

echo.
echo ==== DONE - %date% %time% ==== >> "%LOG%"
echo.
echo ========================================
echo All done! Check install.log for details
echo ========================================
pause
exit /b 0

:: -------------------------
:: INSTALL FUNCTION
:: -------------------------
:install
set "PACKAGE_ID=%~1"
set "PACKAGE_NAME=%~2"

echo.
echo [%time%] Installing %PACKAGE_NAME%...
echo [%time%] Installing %PACKAGE_NAME% (%PACKAGE_ID%) >> "%LOG%"

winget install --id "%PACKAGE_ID%" -e --accept-package-agreements --accept-source-agreements --silent >> "%LOG%" 2>&1

if errorlevel 1 (
    echo [%time%] FAILED: %PACKAGE_NAME% >> "%LOG%"
    echo [X] FAILED: %PACKAGE_NAME%
) else (
    echo [%time%] SUCCESS: %PACKAGE_NAME% >> "%LOG%"
    echo [+] SUCCESS: %PACKAGE_NAME%
)

exit /b
