@echo off
REM Install Git on Windows using winget
REM Usage: install_git.bat

setlocal

echo ========================================
echo Git Installer for Windows
echo ========================================
echo.

echo Detected platform: Windows
echo.

echo Installing Git for Windows...
winget install Git.Git --accept-package-agreements --accept-source-agreements

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Installation completed!
    echo.
    echo Verifying installation...
    git --version
    echo.
    echo ✅ Git installed successfully!
    echo.
    echo ⚠️  IMPORTANT: Close and reopen your terminal to use Git.
    echo    PATH changes take effect in new terminal sessions only.
    echo.
    echo 📝 Recommended Git Configuration:
    echo    git config --global user.name "Your Name"
    echo    git config --global user.email "your.email@example.com"
    echo.
    echo    # Set default branch name to main
    echo    git config --global init.defaultBranch main
    echo.
    echo    # Enable colored output
    echo    git config --global color.ui auto
    echo.
    echo 📝 Note: Git for Windows includes:
    echo    - Git Bash (Unix-like shell)
    echo    - Git GUI (graphical interface)
    echo    - Git integration with Windows Explorer
) else (
    echo.
    echo ❌ Installation failed!
    echo Please run PowerShell as Administrator and try again.
    echo.
    echo For manual installation, visit:
    echo   https://git-scm.com/download/win
)

endlocal
