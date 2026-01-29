@echo off
REM Install Java (OpenJDK) on Windows using winget
REM Usage: install_java.bat [version]

setlocal

set "JAVA_VERSION=%~1"
if "%JAVA_VERSION%"=="" set "JAVA_VERSION=21"

echo ========================================
echo Java Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo Target version: %JAVA_VERSION%
echo.

echo Installing Java %JAVA_VERSION% (Temurin)...
winget install EclipseAdoptium.Temurin.%JAVA_VERSION%.JDK --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo Verifying installation...
    java -version
    echo.
    echo ✅ Java installed successfully!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use Java.
    echo    PATH changes take effect in new terminal sessions only.
) else (
    echo.
    echo ❌ Installation failed!
    echo Please run PowerShell as Administrator and try again.
)

endlocal
