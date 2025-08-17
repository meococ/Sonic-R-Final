@echo off
chcp 65001 >nul
title MQL5 Project Dumper
color 0A

echo ========================================
echo    MQL5 PROJECT DUMPER - LAUNCHER
echo ========================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not installed!
    echo Please install from: https://www.python.org
    pause
    exit /b 1
)

:: Install chardet if needed
echo Checking dependencies...
python -c "import chardet" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing chardet for better encoding support...
    pip install chardet
)

:: Configure default Dumps output directory
set "SCRIPT_DIR=%~dp0"
set "DUMPS_DIR=%SCRIPT_DIR%..\Dumps"
if not exist "%DUMPS_DIR%" (
    mkdir "%DUMPS_DIR%"
)
set "MQL5_DUMPER_OUTPUT_DIR=%DUMPS_DIR%"

:: Run the dumper
echo.
echo Starting MQL5 Project Dumper (GUI Mode)...
echo.

cd /d "%~dp0"
python mql5_dumper.py

pause