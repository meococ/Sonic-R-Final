@echo off
:: SONIC R MC - Quick Compile (Robust, Hang-safe)
setlocal enabledelayedexpansion

set "METAEDITOR=C:\Program Files\MetaTrader 5\metaeditor64.exe"
set "EA_PATH=%~dp0..\..\01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5"
set "INC_PATH=%~dp0..\.."
set "LOG_DIR=%~dp0Logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\quick_compile_current.log"
set "META_LOG=%LOG_DIR%\00_Main_EA_SonicR.mq5.log"
set "ROOT_LOG=%~dp0..\..\01_SONIC R_MC_FINAL\00_Main_EA_SonicR.log"

:: Kill any stale MetaEditor to avoid hangs
for /f "tokens=1,*" %%P in ('tasklist /FI "IMAGENAME eq metaeditor64.exe" ^| find /I "metaeditor64.exe"') do (
  taskkill /IM metaeditor64.exe /F >nul 2>&1
)

if exist "%LOG_FILE%" del /f /q "%LOG_FILE%" >nul 2>&1
if exist "%META_LOG%" del /f /q "%META_LOG%" >nul 2>&1

:: Run compile (wait for process to exit)
start "ME5" /WAIT "%METAEDITOR%" /compile:"%EA_PATH%" /log /inc:"%INC_PATH%" /s > "%LOG_FILE%" 2>&1
set COMPILE_RC=%ERRORLEVEL%

:: Prefer MetaEditor log if present; else fall back to redirected stdout
set "PARSE_LOG=%META_LOG%"
if not exist "%PARSE_LOG%" set "PARSE_LOG=%LOG_FILE%"

:: Mirror selected log to root for single-source-of-truth
if exist "%PARSE_LOG%" (
  copy /y "%PARSE_LOG%" "%ROOT_LOG%" >nul 2>&1
) else (
  type nul > "%ROOT_LOG%"
)

:: Parse for ' : error ' lines or ' result X errors'
set "HAVE_ERRORS=0"
if exist "%PARSE_LOG%" (
  findstr /r /c:": error " /c:" result [0-9][0-9]* errors" "%PARSE_LOG%" >nul 2>&1 && set "HAVE_ERRORS=1"
)

:: Also treat non-zero exit code as failure
if %COMPILE_RC% NEQ 0 set "HAVE_ERRORS=1"

if %HAVE_ERRORS%==1 (
  echo [x] FAILED: Errors detected. See logs in "%LOG_DIR%" and "%ROOT_LOG%".
  exit /b 1
)

echo [+] SUCCESS: EA compiled cleanly (no errors found)
exit /b 0