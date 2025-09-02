# Direct EA Compilation Script
param(
    [string]$EAFile = "01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5"
)

$ErrorActionPreference = "Continue"
$metaEditor = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$logFile = "00_Compile\Logs\direct_compile.log"

Write-Host "=== SONIC R MC EA - DIRECT COMPILATION ==="
Write-Host "EA File: $EAFile"
Write-Host "Log File: $logFile"
Write-Host ""

# Ensure log directory exists
New-Item -ItemType Directory -Force -Path "00_Compile\Logs" | Out-Null

# Try compilation with different approaches
Write-Host "Attempting compilation..."

try {
    # Method 1: With log file
    $process = Start-Process -FilePath $metaEditor -ArgumentList @("/compile:$EAFile", "/log:$logFile") -Wait -PassThru -NoNewWindow
    $exitCode = $process.ExitCode
    
    Write-Host "Exit Code: $exitCode"
    
    if (Test-Path $logFile) {
        Write-Host ""
        Write-Host "=== COMPILATION LOG ==="
        Get-Content $logFile | ForEach-Object { Write-Host $_ }
        Write-Host "=== END OF LOG ==="
    } else {
        Write-Host "No log file created at: $logFile"
        
        # Method 2: Try without log file
        Write-Host "Trying compilation without log file..."
        $process2 = Start-Process -FilePath $metaEditor -ArgumentList @("/compile:$EAFile") -Wait -PassThru -NoNewWindow
        $exitCode2 = $process2.ExitCode
        Write-Host "Exit Code (no log): $exitCode2"
    }
    
    # Check for generated EX5 file
    $ex5File = $EAFile -replace "\.mq5$", ".ex5"
    if (Test-Path $ex5File) {
        Write-Host ""
        Write-Host "✅ SUCCESS: EX5 file generated at: $ex5File"
        $fileInfo = Get-Item $ex5File
        Write-Host "File size: $($fileInfo.Length) bytes"
        Write-Host "Modified: $($fileInfo.LastWriteTime)"
    } else {
        Write-Host ""
        Write-Host "❌ FAILED: No EX5 file generated"
    }
    
} catch {
    Write-Host "Error during compilation: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "=== COMPILATION COMPLETE ==="
