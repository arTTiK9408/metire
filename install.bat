@echo off
REM Metire — install.bat
REM Usage: curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.bat | cmd
REM MIT License — https://github.com/arTTiK9408/metire

setlocal
set "REPO=arTTiK9408/metire"
set "INSTALL_DIR=%USERPROFILE%\.metire\bin"

REM Detect architecture
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set "ARCH=x86_64") else (
  if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" (set "ARCH=aarch64") else (
    echo Unsupported architecture: %PROCESSOR_ARCHITECTURE%
    exit /b 1
  )
)

set "ASSET=metire-windows-%ARCH%.exe"

REM Fetch latest release tag via PowerShell (write to temp file for reliability)
echo Looking up latest release...
powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { $r = Invoke-RestMethod 'https://api.github.com/repos/%REPO%/releases/latest' -EA Stop; Write-Output $r.tag_name } catch { Write-Output 'error' }" > "%TEMP%\metire_tag.txt"
set /p TAG=<"%TEMP%\metire_tag.txt"
del "%TEMP%\metire_tag.txt" 2>nul

if "%TAG%"=="error" (echo Failed to fetch latest release & exit /b 1)
if "%TAG%"=="" (echo Failed to fetch latest release & exit /b 1)

set "URL=https://github.com/%REPO%/releases/download/%TAG%/%ASSET%"
set "TMP=%TEMP%\metire.exe"

echo Downloading Metire %TAG%...
curl.exe -#fL "%URL%" -o "%TMP%"
if %ERRORLEVEL% neq 0 (echo Download failed & exit /b 1)

REM Create install directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Install binary
move /y "%TMP%" "%INSTALL_DIR%\metire.exe" >nul
if %ERRORLEVEL% neq 0 (echo Install failed & exit /b 1)

REM Add to user PATH via PowerShell
powershell -NoProfile -Command "$dir = [Environment]::GetFolderPath('UserProfile') + '\.metire\bin'; $p = [Environment]::GetEnvironmentVariable('Path', 'User'); if (($p -split ';') -notcontains $dir) { [Environment]::SetEnvironmentVariable('Path', $p + ';' + $dir, 'User'); Write-Host 'Metire added to PATH (user level).' } else { Write-Host 'Metire is already in PATH.' }"

echo.
echo Metire %TAG% installed to %INSTALL_DIR%\metire.exe
echo Restart your terminal or run: set PATH=%%PATH%%;%INSTALL_DIR%
