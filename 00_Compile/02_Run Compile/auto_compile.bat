@echo off
setlocal enabledelayedexpansion

echo ===============================================================================
echo                    SONIC R MC - AUTOMATED COMPILE SYSTEM
echo                           Dai Bang and Meo Coc Production
echo ===============================================================================
echo.

:: Set paths
set "PROJECT_DIR=%~dp0..\01_SONIC R_MC_FINAL"
set "EA_FILE=00_Main_EA_SonicR.mq5"
set "EA_PATH=%PROJECT_DIR%\%EA_FILE%"
set "METAEDITOR=C:\Program Files\MetaTrader 5\metaeditor64.exe"
set "MQL5_INC=C:\Users\ADMIN\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5"
set "LOG_DIR=%~dp0Logs"
set "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=!TIMESTAMP: =0!"

:: Create logs directory if not exists
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo [*] Configuration:
echo     EA File: %EA_FILE%
echo     Project: %PROJECT_DIR%
echo     MetaEditor: %METAEDITOR%
echo     Log Directory: %LOG_DIR%
echo     Timestamp: %TIMESTAMP%
echo.

:: Check if EA file exists
if not exist "%EA_PATH%" (
    echo [x] ERROR: EA file not found at %EA_PATH%
    echo [!] Please check the project structure.
    exit /b 1
)

:: Check if MetaEditor exists
if not exist "%METAEDITOR%" (
    echo [x] ERROR: MetaEditor not found at %METAEDITOR%
    echo [!] Please install MetaTrader 5 or update the path.
    exit /b 1
)

echo [+] All prerequisites checked successfully.
echo.

:: Start compilation
echo [*] Starting compilation at %date% %time%
echo     Command: "%METAEDITOR%" /compile:"%EA_PATH%" /log /inc:"%MQL5_INC%" /s
echo.

:: Compile with output capture
"%METAEDITOR%" /compile:"%EA_PATH%" /log /inc:"%MQL5_INC%" /s > "%LOG_DIR%\compile_%TIMESTAMP%.log" 2>&1
set COMPILE_RESULT=%ERRORLEVEL%

echo [*] Compilation completed at %date% %time%
echo.

:: Display results
if %COMPILE_RESULT%==0 (
    echo ===============================================================================
    echo                               SUCCESS! 
    echo ===============================================================================
    echo [+] EA compiled successfully with no errors!
    echo [+] Exit Code: %COMPILE_RESULT%
    echo [+] Log saved to: %LOG_DIR%\compile_%TIMESTAMP%.log
) else (
    echo ===============================================================================
    echo                               FAILED!   
    echo ===============================================================================
    echo [x] EA compilation failed!
    echo [x] Exit Code: %COMPILE_RESULT%
    echo [x] Check log for details: %LOG_DIR%\compile_%TIMESTAMP%.log
    echo.
    echo [*] Displaying last 20 lines of compilation log:
    echo -------------------------------------------------------------------------------
    powershell -Command "Get-Content '%LOG_DIR%\compile_%TIMESTAMP%.log' | Select-Object -Last 20"
    echo -------------------------------------------------------------------------------
)

echo.
echo ===============================================================================
echo                           AUTOMATED EXECUTION COMPLETE
echo ===============================================================================
echo [*] No user interaction required - script executed automatically
echo [*] Timestamp: %TIMESTAMP%
echo [*] Total execution time: Completed at %time%
echo.

:: Return appropriate exit code
exit /b %COMPILE_RESULT% 
