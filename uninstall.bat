@echo off
REM Metire — uninstall.bat
REM Usage: curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.bat | cmd
REM MIT License — https://github.com/arTTiK9408/metire

setlocal
set "INSTALL_DIR=%USERPROFILE%\.metire\bin"
set "BINARY=%INSTALL_DIR%\metire.exe"

if not exist "%BINARY%" (
  echo Metire not found at %BINARY%
  exit /b 0
)

del /f "%BINARY%"
rmdir "%INSTALL_DIR%" 2>nul

powershell -NoProfile -Command "$dir = [Environment]::GetFolderPath('UserProfile') + '\.metire\bin'; $p = [Environment]::GetEnvironmentVariable('Path', 'User'); $newPath = ($p -split ';') | Where-Object { $_ -ne $dir }; [Environment]::SetEnvironmentVariable('Path', ($newPath -join ';'), 'User'); Write-Host 'Metire removed from PATH (user level).'"

echo Metire has been uninstalled.
