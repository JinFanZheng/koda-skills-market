@echo off
REM Install Go on Windows using winget
REM Usage: install_golang.bat [version]

setlocal

set "GO_VERSION=%~1"
if "%GO_VERSION%"=="" set "GO_VERSION=latest"

echo ========================================
echo Go Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo Target version: %GO_VERSION%
echo.

echo Installing Go...
winget install GoLang.Go --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo Verifying installation...
    go version
    echo.
    echo ✅ Go installed successfully!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use Go.
    echo    PATH changes take effect in new terminal sessions only.
    echo.
    echo NOTE: If 'go' command is not found after restart:
    echo   1. Open: System Properties ^> Environment Variables
    echo   2. Edit PATH variable
    echo   3. Add: C:\Program Files\Go\bin
    echo   4. Click OK and restart terminal again
) else (
    echo.
    echo ❌ Installation failed!
    echo Please run PowerShell as Administrator and try again.
)

endlocal
