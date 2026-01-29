@echo off
REM Install .NET on Windows using winget
REM Usage: install_dotnet.bat [version]

setlocal

set "DOTNET_VERSION=%~1"
if "%DOTNET_VERSION%"=="" set "DOTNET_VERSION=8"

echo ========================================
echo .NET Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo Target version: %DOTNET_VERSION%
echo.

echo Installing .NET SDK %DOTNET_VERSION%...
winget install Microsoft.DotNet.SDK.%DOTNET_VERSION% --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo Verifying installation...
    dotnet --version
    echo.
    echo ✅ .NET SDK installed successfully!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use .NET.
    echo    PATH changes take effect in new terminal sessions only.
    echo.
    echo 📝 Useful commands:
    echo    dotnet --info          Show .NET information
    echo    dotnet --list-sdks     List installed SDKs
    echo    dotnet --list-runtimes List installed runtimes
    echo    dotnet new             Create a new project
) else (
    echo.
    echo ❌ Installation failed!
    echo Please run PowerShell as Administrator and try again.
    echo.
    echo For manual installation, visit:
    echo   https://dotnet.microsoft.com/download
)

endlocal
