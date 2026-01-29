@echo off
REM Install Python on Windows using winget
REM Usage: install_python.bat [version]

setlocal

set "PYTHON_VERSION=%~1"
if "%PYTHON_VERSION%"=="" set "PYTHON_VERSION=3.12"

echo ========================================
echo Python Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo Target version: %PYTHON_VERSION%
echo.

echo Installing Python...
winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo Verifying installation...
    python --version
    pip --version
    echo.
    echo ✅ Python installed successfully!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use Python.
    echo    PATH changes take effect in new terminal sessions only.
) else (
    echo.
    echo ❌ Installation failed!
    echo Please run PowerShell as Administrator and try again.
)

endlocal
