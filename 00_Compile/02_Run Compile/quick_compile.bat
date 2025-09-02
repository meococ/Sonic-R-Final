@echo off
:: SONIC R MC - Quick Compile (Wrapper to canonical PowerShell tool)
setlocal

:: Delegate to PowerShell sonic_compile.ps1 for unified parsing & reporting
powershell -ExecutionPolicy Bypass -File "%~dp0sonic_compile.ps1" -Mode quick -Target ea
set EXITCODE=%ERRORLEVEL%

exit /b %EXITCODE%