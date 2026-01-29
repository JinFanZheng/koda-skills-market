@echo off
REM Install Node.js on Windows using winget
REM Usage: install_nodejs.bat [version]

setlocal

set "NODE_VERSION=%~1"
if "%NODE_VERSION%"=="" set "NODE_VERSION=lts"

echo ========================================
echo Node.js Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo Target version: %NODE_VERSION%
echo.

echo Installing Node.js...
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo Verifying installation...
    node --version
    npm --version
    echo.
    echo ✅ Node.js installed successfully!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use Node.js.
    echo    PATH changes take effect in new terminal sessions only.
) else (
    echo.
    echo ❌ Installation failed!
    echo Please run PowerShell as Administrator and try again.
)

endlocal
