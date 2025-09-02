# Advanced EA Compilation with Error Capture
$ErrorActionPreference = "Continue"

$eaFile = "01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5"
$metaEditor = "C:\Program Files\MetaTrader 5\metaeditor64.exe"

Write-Host "=== ADVANCED EA COMPILATION ===" -ForegroundColor Yellow
Write-Host "EA File: $eaFile"
Write-Host "MetaEditor: $metaEditor"
Write-Host ""

# Get full paths
$fullEAPath = (Resolve-Path $eaFile).Path
$logDir = "00_Compile\Logs"
$errorLog = "$logDir\compilation_errors.txt"
$outputLog = "$logDir\compilation_output.txt"

# Ensure log directory exists
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

Write-Host "Full EA Path: $fullEAPath" -ForegroundColor Cyan
Write-Host ""

# Method 1: Try with ProcessStartInfo for better control
Write-Host "--- Method 1: Using ProcessStartInfo ---" -ForegroundColor Green
try {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $metaEditor
    $psi.Arguments = "/compile:`"$fullEAPath`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    
    $process = [System.Diagnostics.Process]::Start($psi)
    
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    
    Write-Host "Exit Code: $exitCode"
    
    if ($output) {
        Write-Host "--- STDOUT ---" -ForegroundColor Blue
        Write-Host $output
        $output | Out-File -FilePath $outputLog -Encoding UTF8
    }
    
    if ($errorOutput) {
        Write-Host "--- STDERR ---" -ForegroundColor Red
        Write-Host $errorOutput
        $errorOutput | Out-File -FilePath $errorLog -Encoding UTF8
    }
    
} catch {
    Write-Host "Error in Method 1: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Method 2: Try with cmd.exe wrapper
Write-Host "--- Method 2: Using CMD wrapper ---" -ForegroundColor Green
try {
    $cmdArgs = "/c `"$metaEditor`" /compile:`"$fullEAPath`" 2>&1"
    $result = cmd.exe $cmdArgs
    Write-Host "CMD Result:"
    $result | ForEach-Object { Write-Host $_ }
} catch {
    Write-Host "Error in Method 2: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Check if EX5 was generated
$ex5Path = $fullEAPath -replace "\.mq5$", ".ex5"
if (Test-Path $ex5Path) {
    Write-Host "✅ SUCCESS: EX5 file generated!" -ForegroundColor Green
    $fileInfo = Get-Item $ex5Path
    Write-Host "File: $($fileInfo.FullName)"
    Write-Host "Size: $($fileInfo.Length) bytes"
    Write-Host "Modified: $($fileInfo.LastWriteTime)"
} else {
    Write-Host "❌ FAILED: No EX5 file generated at: $ex5Path" -ForegroundColor Red
    
    # Check for any EX5 files with similar names
    $eaDir = Split-Path $fullEAPath
    $possibleEX5 = Get-ChildItem -Path $eaDir -Filter "*.ex5" -ErrorAction SilentlyContinue
    if ($possibleEX5) {
        Write-Host "Found other EX5 files in directory:" -ForegroundColor Yellow
        $possibleEX5 | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Length) bytes, $($_.LastWriteTime))" }
    }
}

Write-Host ""
Write-Host "=== COMPILATION ANALYSIS COMPLETE ===" -ForegroundColor Yellow
