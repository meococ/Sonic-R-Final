@echo off
setlocal

echo ===============================================================================
echo                    SONIC R MC - UNIFIED COMPILE SYSTEM
echo                           All-in-One Compilation Suite
echo ===============================================================================
echo.

:: Check command line arguments
if "%1"=="" goto :ShowMenu
if /i "%1"=="quick" goto :QuickCompile
if /i "%1"=="simple" goto :SimpleCompile  
if /i "%1"=="auto" goto :AutoCompile
if /i "%1"=="test" goto :TestCompile
if /i "%1"=="powershell" goto :PowerShellCompile
if /i "%1"=="help" goto :ShowHelp
goto :ShowHelp

:ShowMenu
echo Available compile modes:
echo.
echo   1. quick      - Quick compile (minimal output)
echo   2. simple     - Simple compile (basic feedback) 
echo   3. auto       - Automated compile (full logging)
echo   4. test       - Test compile (with full output display)
echo   5. powershell - PowerShell compile (advanced features)
echo   6. help       - Show detailed help
echo.
echo Usage: %0 [mode]
echo Example: %0 quick
echo.
echo Running default AUTO mode in 3 seconds...
timeout /t 3 /nobreak >nul 2>&1
goto :AutoCompile

:QuickCompile
echo [*] QUICK COMPILE MODE
call "%~dp0quick_compile.bat"
goto :End

:SimpleCompile  
echo [*] SIMPLE COMPILE MODE
call "%~dp0..\compile_simple.bat"
goto :End

:AutoCompile
echo [*] AUTOMATED COMPILE MODE
call "%~dp0auto_compile.bat"
goto :End

:TestCompile
echo [*] TEST COMPILE MODE (Full Output Display)
call "%~dp0test_compile.bat"
goto :End

:PowerShellCompile
echo [*] POWERSHELL COMPILE MODE
powershell -ExecutionPolicy Bypass -File "%~dp0sonic_compile.ps1" -Mode quick
goto :End

:ShowHelp
echo ===============================================================================
echo                         SONIC R MC COMPILE HELP
echo ===============================================================================
echo.
echo MODES:
echo   quick      - Fast compilation with minimal output
echo   simple     - Basic compilation with standard feedback
echo   auto       - Full automated compilation with detailed logging
echo   test       - Test compilation with full output display
echo   powershell - Advanced PowerShell-based compilation
echo.
echo USAGE:
echo   %0 [mode]
echo.
echo EXAMPLES:
echo   %0 quick          - Quick compile
echo   %0 auto           - Full automated compile
echo   %0 test           - Test compile with output
echo   %0 powershell     - PowerShell compile
echo   %0                - Show menu and auto-run
echo.
echo EXIT CODES:
echo   0 = Success
echo   1 = Compilation failed
echo   2 = Invalid arguments
echo.
goto :End

:End
echo.
echo ===============================================================================
echo                           COMPILE SYSTEM COMPLETE
echo ===============================================================================
echo [*] All operations completed automatically - no user input required
exit /b %ERRORLEVEL% 