@echo off
REM Install Docker on Windows using winget
REM Usage: install_docker.bat

setlocal

echo ========================================
echo Docker Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo.

echo Installing Docker Desktop...
winget install Docker.DockerDesktop --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use Docker commands.
    echo    PATH changes take effect in new terminal sessions only.
    echo.
    echo 📝 Next steps:
    echo    1. Start Docker Desktop from Start Menu
    echo    2. Wait for Docker daemon to start (check system tray)
    echo    3. Verify: docker --version
    echo    4. Verify: docker ps
) else (
    echo.
    echo ❌ Installation failed!
    echo Please ensure:
    echo   - You're running Windows 10/11 Pro/Enterprise
    echo   - WSL 2 is installed
    echo   - Virtualization is enabled in BIOS
    echo.
    echo For manual installation, visit:
    echo   https://docs.docker.com/desktop/install/windows-install/
)

endlocal
