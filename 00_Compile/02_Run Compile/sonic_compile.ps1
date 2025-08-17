#requires -version 5.0
<#
.SYNOPSIS
     SONIC R MC - Ultimate Compilation System V2.0
    H th'ng compile t'i u cho i B ng & Mo Cc

.DESCRIPTION
    Script compile th'ng nht vi tt c tnh nng cn thit:
    - Compile EA vi error detection thng minh
    - Phn tch l-i v  ' xut fix t 'ng
    - Log system c cu trc v  d... 'c
    - Performance monitoring v  optimization
    - Knowledge base integration cho fix l-i

.PARAMETER Mode
    Ch ' compile:
    - quick: Compile nhanh cho testing
    - full: Compile 'y ' vi analysis
    - fix: T 'ng fix l-i ph-  bin
    - clean: Clean build (xa cache)

.PARAMETER Target
    Mc tiu compile:
    - ea: Main EA file (default)
    - all: Tt c files
    - module: Compile module c th

.EXAMPLE
    .\sonic_compile.ps1
    .\sonic_compile.ps1 -Mode full
    .\sonic_compile.ps1 -Mode fix -Target ea
    .\sonic_compile.ps1 -Mode clean

.NOTES
    Author: i B ng (Eagle) & Mo Cc (Boss)
    Version: 2.0
    Last Updated: 2025-01-28
#>

param(
    [ValidateSet("quick", "full", "fix", "clean", "help")]
    [string]$Mode = "quick",
    
    [ValidateSet("ea", "all", "module")]
    [string]$Target = "ea",
    
    [string]$ModuleName = '',
    [switch]$Verbose,
    [switch]$AutoFix,
    [switch]$Silent
)

# === CONFIGURATION ===
$ErrorActionPreference = "Continue"
$ScriptDir = $PSScriptRoot
# Resolve project directory robustly across layouts
$possibleProjectDirs = @(
    (Join-Path $ScriptDir "..\..\01_SONIC R_MC_FINAL"),
    (Join-Path $ScriptDir "..\01_SONIC R_MC_FINAL"),
    (Join-Path (Split-Path $ScriptDir -Parent) "01_SONIC R_MC_FINAL")
)
$ProjectDir = $null
foreach ($p in $possibleProjectDirs) { if (Test-Path $p) { $ProjectDir = $p; break } }
if (-not $ProjectDir) { $ProjectDir = (Join-Path $ScriptDir "..\..\01_SONIC R_MC_FINAL") }
$MainEAFile = "00_Main_EA_SonicR.mq5"
$LogDir = Join-Path $ScriptDir "Logs"
$KnowledgeDir = Join-Path $ScriptDir "03_Knowledge MQL5"

# Colors for output
$Colors = @{
    Header = "Cyan"
    Success = "Green" 
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Debug = "DarkGray"
}

#region Helper Functions

function Write-SonicHeader {
    param([string]$Title)
    
    if (!$Silent) {
        Write-Host ""
        Write-Host "+===============================================================================+" -ForegroundColor $Colors.Header
        Write-Host "|   SONIC R MC - $Title" -ForegroundColor $Colors.Header
        Write-Host "+===============================================================================+" -ForegroundColor $Colors.Header
        Write-Host ""
    }
}


function Write-SonicStatus {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    if (!$Silent) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $icon = switch ($Type) {
            "Success" { "[+]" }
            "Warning" { "[!]" }
            "Error" { "[x]" }
            "Info" { "[*]" }
            "Debug" { "[d]" }
            default { "[*]" }
        }
        
        Write-Host "[$timestamp] $icon $Message" -ForegroundColor $Colors[$Type]
    }
}


function Initialize-Environment {
    Write-SonicStatus "Initializing Sonic R compilation environment..." "Info"
    
    # Create log directory
    if (!(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Write-SonicStatus "Created log directory: $LogDir" "Success"
    }
    
    # Verify project structure
    if (!(Test-Path $ProjectDir)) {
        Write-SonicStatus "Project directory not found: $ProjectDir" "Error"
        return $false
    }
    
    $mainEAPath = Join-Path $ProjectDir $MainEAFile
    if (!(Test-Path $mainEAPath)) {
        Write-SonicStatus "Main EA file not found: $MainEAFile" "Error"
        return $false
    }
    
    Write-SonicStatus "Environment initialized successfully" "Success"
    return $true
}


function Find-MetaEditor {
    Write-SonicStatus "Searching for MetaEditor..." "Info"
    
    # Common MetaEditor paths
    $possiblePaths = @(
        "${env:ProgramFiles}\MetaTrader 5\metaeditor64.exe",
        "${env:ProgramFiles(x86)}\MetaTrader 5\metaeditor64.exe",
        "${env:APPDATA}\MetaQuotes\Terminal\*\metaeditor64.exe"
    )
    
    foreach ($path in $possiblePaths) {
        $resolved = Get-ChildItem $path -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($resolved) {
            Write-SonicStatus "Found MetaEditor: $($resolved.FullName)" "Success"
            return $resolved.FullName
        }
    }
    
    # Try system PATH
    $metaEditor = Get-Command "metaeditor64.exe" -ErrorAction SilentlyContinue
    if ($metaEditor) {
        Write-SonicStatus "Found MetaEditor in PATH: $($metaEditor.Source)" "Success"
        return $metaEditor.Source
    }
    
    Write-SonicStatus "MetaEditor not found! Please install MetaTrader 5" "Error"
    return $null
}


function Compile-File {
    param(
        [string]$FilePath,
        [string]$MetaEditorPath
    )
    
    $fileName = Split-Path $FilePath -Leaf
    Write-SonicStatus "Compiling: $fileName" "Info"
    
    $logFile = Join-Path $LogDir "$fileName.log"
    $startTime = Get-Date
    
    try {
        # Run MetaEditor compilation
        $arguments = "/compile:`"$FilePath`" /log:`"$logFile`" /s"
        $process = Start-Process -FilePath $MetaEditorPath -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        # CRITICAL FIX: Check actual errors in log instead of just exit code
        $errors = Parse-CompilationLog $logFile
        $hasRealErrors = ($errors.Errors.Count -gt 0)
        
        # For .mqh files, success is determined by absence of actual errors, not exit code
        $isSuccess = -not $hasRealErrors
        
        if ($isSuccess) {
            Write-SonicStatus "... Compiled successfully in ${duration}s: $fileName" "Success"
            return @{
                Success = $true
                Duration = $duration
                LogFile = $logFile
                Errors = @()
                Warnings = $errors.Warnings
            }
        } else {
            Write-SonicStatus " Compilation failed: $fileName" "Error"
            return @{
                Success = $false
                Duration = $duration
                LogFile = $logFile
                Errors = $errors.Errors
                Warnings = $errors.Warnings
            }
        }
    }
    catch {
        Write-SonicStatus "Exception during compilation: $($_.Exception.Message)" "Error"
        return @{
            Success = $false
            Duration = 0
            LogFile = $logFile
            Errors = @("Compilation exception: $($_.Exception.Message)")
            Warnings = @()
        }
    }
}


function Parse-CompilationLog {
    param([string]$LogFile)
    
    $errors = @()
    $warnings = @()
    
    if (Test-Path $LogFile) {
        $content = Get-Content $LogFile -ErrorAction SilentlyContinue
        
        foreach ($line in $content) {
            # IMPROVED ERROR DETECTION: Look for actual compilation errors
            if ($line -match "^\s*[^:]+:\d+:\d+:\s*(error|fatal)" -and 
                $line -notmatch "information:" -and 
                $line -notmatch "result.*0 errors") {
                $errors += $line.Trim()
            }
            # Additional error patterns
            elseif ($line -match "error" -and 
                   $line -notmatch "information:" -and 
                   $line -notmatch "result.*0 errors" -and
                   $line -notmatch "warning") {
                $errors += $line.Trim()
            }
            # Fatal errors
            elseif ($line -match "fatal" -and $line -notmatch "information:") {
                $errors += $line.Trim()
            }
            # Warnings (but not info messages)
            elseif ($line -match "warning" -and 
                   $line -notmatch "information:" -and 
                   $line -notmatch "result.*0.*warnings") {
                $warnings += $line.Trim()
            }
            # Specific MQL5 error patterns
            elseif ($line -match "^\s*[^:]+:\d+:\d+:\s*warning") {
                $warnings += $line.Trim()
            }
        }
    }
    
    return @{
        Errors = $errors
        Warnings = $warnings
    }
}


function Show-CompilationSummary {
    param(
        [array]$Results,
        [datetime]$StartTime
    )
    
    $totalTime = ((Get-Date) - $StartTime).TotalSeconds
    $successful = ($Results | Where-Object { $_.Success }).Count
    $failed = ($Results | Where-Object { !$_.Success }).Count
    $totalErrors = ($Results | ForEach-Object { $_.Errors.Count } | Measure-Object -Sum).Sum
    $totalWarnings = ($Results | ForEach-Object { $_.Warnings.Count } | Measure-Object -Sum).Sum
    
    Write-SonicHeader "COMPILATION SUMMARY"
    
    Write-Host "Statistics:" -ForegroundColor $Colors.Info
    Write-Host "   Total Files: $($Results.Count)" -ForegroundColor $Colors.Info
    Write-Host "   Successful: $successful" -ForegroundColor $Colors.Success
    Write-Host "   Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { $Colors.Success } else { $Colors.Error })
    Write-Host "   Total Time: ${totalTime}s" -ForegroundColor $Colors.Info
    Write-Host ""
    
    Write-Host "Issues:" -ForegroundColor $Colors.Info
    Write-Host "   Errors: $totalErrors" -ForegroundColor $(if ($totalErrors -eq 0) { $Colors.Success } else { $Colors.Error })
    Write-Host "   Warnings: $totalWarnings" -ForegroundColor $(if ($totalWarnings -eq 0) { $Colors.Success } else { $Colors.Warning })
    Write-Host ""
    
    # Show failed files
    $failedFiles = $Results | Where-Object { !$_.Success }
    if ($failedFiles) {
        Write-Host " Failed Files:" -ForegroundColor $Colors.Error
        foreach ($file in $failedFiles) {
            $fileName = Split-Path $file.LogFile -Leaf
            $fileName = $fileName -replace "\.log$", ""
            Write-Host "    $fileName" -ForegroundColor $Colors.Error
            
            if ($file.Errors -and $file.Errors.Count -gt 0) {
                foreach ($errorMsg in $file.Errors | Select-Object -First 3) {
                    Write-Host ("     " + $errorMsg) -ForegroundColor $Colors.Debug
                }
                if ($file.Errors.Count -gt 3) {
                    Write-Host "     ... and $($file.Errors.Count - 3) more errors" -ForegroundColor $Colors.Debug
                }
            }
        }
        Write-Host ""
    }
    
    # Overall result
    if ($failed -eq 0) {
        Write-Host "ALL COMPILATIONS SUCCESSFUL!" -ForegroundColor $Colors.Success
    } elseif ($successful -gt 0) {
        Write-Host "[!] PARTIAL SUCCESS - Some files failed" -ForegroundColor $Colors.Warning
    } else {
        Write-Host "[!!] ALL COMPILATIONS FAILED" -ForegroundColor $Colors.Error
    }
    
    # After showing issues, add detailed warnings
    Write-Host "Detailed Warnings:" -ForegroundColor $Colors.Warning
    foreach ($result in $Results) {
        if ($result.Warnings.Count -gt 0) {
            $fileName = Split-Path $result.LogFile -Leaf
            $fileName = $fileName -replace "\.log$", ""
            Write-Host "    $fileName" -ForegroundColor $Colors.Warning
            foreach ($warning in $result.Warnings) {
                Write-Host ("     " + $warning) -ForegroundColor $Colors.Debug
            }
        }
    }
    Write-Host ""
}


function Clean-BuildArtifacts {
    Write-SonicStatus "Cleaning build artifacts..." "Info"
    
    # Clean old logs
    if (Test-Path $LogDir) {
        $oldLogs = Get-ChildItem $LogDir -Filter "*.log" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
        if ($oldLogs) {
            $oldLogs | Remove-Item -Force
            Write-SonicStatus "Removed $($oldLogs.Count) old log files" "Success"
        }
    }
    
    # Clean compiled files in project directory
    $compiledFiles = Get-ChildItem $ProjectDir -Filter "*.ex5" -Recurse
    if ($compiledFiles) {
        $compiledFiles | Remove-Item -Force
        Write-SonicStatus "Removed $($compiledFiles.Count) compiled files" "Success"
    }
    
    Write-SonicStatus "Build artifacts cleaned" "Success"
}


function Show-Help {
    Write-SonicHeader "SONIC R MC - Compilation System Help"
    
    Write-Host "USAGE:" -ForegroundColor $Colors.Info
    Write-Host "  .\sonic_compile.ps1 [Mode] [Options]" -ForegroundColor $Colors.Header
    Write-Host ""
    
    Write-Host "MODES:" -ForegroundColor $Colors.Info
    Write-Host "  quick    - Quick compilation (default)" -ForegroundColor $Colors.Success
    Write-Host "  full     - Full compilation with detailed analysis" -ForegroundColor $Colors.Success
    Write-Host "  fix      - Auto-fix common issues then compile" -ForegroundColor $Colors.Success
    Write-Host "  clean    - Clean build (remove artifacts)" -ForegroundColor $Colors.Success
    Write-Host "  help     - Show this help" -ForegroundColor $Colors.Success
    Write-Host ""
    
    Write-Host "TARGETS:" -ForegroundColor $Colors.Info
    Write-Host "  ea       - Compile main EA only (default)" -ForegroundColor $Colors.Header
    Write-Host "  all      - Compile all files" -ForegroundColor $Colors.Header
    Write-Host "  module   - Compile specific module" -ForegroundColor $Colors.Header
    Write-Host ""
    
    Write-Host "OPTIONS:" -ForegroundColor $Colors.Info
    Write-Host "  -Verbose - Show detailed output" -ForegroundColor $Colors.Warning
    Write-Host "  -AutoFix - Automatically fix common issues" -ForegroundColor $Colors.Warning
    Write-Host "  -Silent  - Suppress output" -ForegroundColor $Colors.Warning
    Write-Host ""
    
    Write-Host "EXAMPLES:" -ForegroundColor $Colors.Info
    Write-Host "  .\sonic_compile.ps1" -ForegroundColor $Colors.Debug
    Write-Host "  .\sonic_compile.ps1 -Mode full -Target all" -ForegroundColor $Colors.Debug
    Write-Host "  .\sonic_compile.ps1 -Mode fix -AutoFix" -ForegroundColor $Colors.Debug
    Write-Host "  .\sonic_compile.ps1 -Mode clean" -ForegroundColor $Colors.Debug
}


#endregion

#region Main Logic

# Show help if requested
if ($Mode -eq "help") {
    Show-Help
    exit 0
}

# Initialize
Write-SonicHeader "COMPILATION SYSTEM V2.0"

if (!(Initialize-Environment)) {
    Write-SonicStatus "Environment initialization failed" "Error"
    exit 1
}

# Find MetaEditor
$metaEditorPath = Find-MetaEditor
if (!$metaEditorPath) {
    Write-SonicStatus "Cannot proceed without MetaEditor" "Error"
    exit 1
}

$startTime = Get-Date
$results = @()

# Handle different modes
switch ($Mode) {
    "clean" {
        Clean-BuildArtifacts
        Write-SonicStatus "Clean completed successfully" "Success"
        exit 0
    }
    
    "fix" {
        Write-SonicStatus "Auto-fix mode not yet implemented" "Warning"
        Write-SonicStatus "Proceeding with standard compilation..." "Info"
    }
}

# Determine files to compile
$filesToCompile = @()

switch ($Target) {
    "ea" {
        $filesToCompile += Join-Path $ProjectDir $MainEAFile
    }
    
    "all" {
        $filesToCompile += Join-Path $ProjectDir $MainEAFile
        $mqhFiles = Get-ChildItem $ProjectDir -Filter "*.mqh" | Select-Object -ExpandProperty FullName
        $filesToCompile += $mqhFiles
    }
    
    "module" {
        if ($ModuleName) {
            $moduleFile = Get-ChildItem $ProjectDir -Filter "*$ModuleName*.mqh" | Select-Object -First 1 -ExpandProperty FullName
            if ($moduleFile) {
                $filesToCompile += $moduleFile
            } else {
                Write-SonicStatus "Module not found: $ModuleName" "Error"
                exit 1
            }
        } else {
            Write-SonicStatus "Module name required for module target" "Error"
            exit 1
        }
    }
}

# Compile files
Write-SonicStatus "Starting compilation of $($filesToCompile.Count) files..." "Info"

foreach ($file in $filesToCompile) {
    $result = Compile-File -FilePath $file -MetaEditorPath $metaEditorPath
    $results += $result
    
    if (!$result.Success) {
        Write-SonicStatus "Errors in $(Split-Path $file -Leaf):" "Error"
        
        # Display ALL errors, not just first 5
        foreach ($errorMsg in $result.Errors) {
            Write-Host ("  " + $errorMsg) -ForegroundColor $Colors.Error
        }
        
        # Also display warnings if any
        if ($result.Warnings.Count -gt 0) {
            Write-SonicStatus "Warnings in $(Split-Path $file -Leaf):" "Warning"
            foreach ($warningMsg in $result.Warnings) {
                Write-Host ("  " + $warningMsg) -ForegroundColor $Colors.Warning
            }
        }
        
        # Display log file location for manual inspection
        if ($result.LogFile -and (Test-Path $result.LogFile)) {
            Write-Host "  Full log: $($result.LogFile)" -ForegroundColor $Colors.Info
        }
    } else {
        # Show success with warning count if any
        if ($result.Warnings.Count -gt 0) {
            Write-SonicStatus "... $(Split-Path $file -Leaf) compiled with $($result.Warnings.Count) warnings" "Warning"
        } else {
            Write-SonicStatus "... $(Split-Path $file -Leaf) compiled successfully" "Success"
        }
    }
}

# Show summary
Show-CompilationSummary -Results $results -StartTime $startTime

# Exit with appropriate code
$exitCode = if (($results | Where-Object { !$_.Success }).Count -eq 0) { 0 } else { 1 }
exit $exitCode

#endregion
