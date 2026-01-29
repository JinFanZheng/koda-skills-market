@echo off
REM Detect the current platform and print it in a standardized format
REM Outputs: macos | linux | windows

setlocal

REM Check if Windows
if defined OS (
    if /i "%OS%"=="Windows_NT" (
        echo windows
        exit /b 0
    )
)

REM Fallback for other systems (shouldn't reach here on Windows)
echo unknown
exit /b 1
