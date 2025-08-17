# Sonic R MC - Error Analysis Script
# Phn tch chi tit tng l-i compile

$metaeditor = "C:\Program Files\MetaTrader 5\metaeditor64.exe"
$mqhFile = "..\01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5"
$logFile = "error_analysis.log"

Write-Host "=================================" -ForegroundColor Cyan
Write-Host " SONIC R MC - ERROR ANALYSIS" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Cyan

# Compile v  ly output
Write-Host "`n[*] Compiling EA..." -ForegroundColor Green
$process = Start-Process -FilePath $metaeditor -ArgumentList "/compile:`"$mqhFile`"", "/log:`"$logFile`"", "/s" -PassThru -WindowStyle Hidden
$process.WaitForExit()

# c log file
if (Test-Path $logFile) {
    $content = Get-Content $logFile -Raw
    
    # Parse errors
    $errorPattern = '(?m)^(.+?)\((\d+),(\d+)\)\s*:\s*(error|warning)\s+(\d+):\s*(.+)$'
    $matches = [regex]::Matches($content, $errorPattern)
    
    Write-Host "`n[*] Found $($matches.Count) errors/warnings" -ForegroundColor Yellow
    Write-Host "=================================" -ForegroundColor Cyan
    
    # Group errors by type
    $errorGroups = @{}
    foreach ($match in $matches) {
        $file = [System.IO.Path]::GetFileName($match.Groups[1].Value)
        $line = $match.Groups[2].Value
        $col = $match.Groups[3].Value
        $type = $match.Groups[4].Value
        $code = $match.Groups[5].Value
        $msg = $match.Groups[6].Value
        
        $key = "$code - $msg"
        if (-not $errorGroups.ContainsKey($key)) {
            $errorGroups[$key] = @()
        }
        $errorGroups[$key] += @{
            File = $file
            Line = $line
            Col = $col
            Type = $type
        }
    }
    
    # Display grouped errors
    $errorGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending | ForEach-Object {
        Write-Host "`n[$($_.Value.Count)x] $($_.Key)" -ForegroundColor Red
        $_.Value | Select-Object -First 3 | ForEach-Object {
            Write-Host "    -> $($_.File):$($_.Line):$($_.Col)" -ForegroundColor Gray
        }
        if ($_.Value.Count -gt 3) {
            Write-Host "    ... and $($_.Value.Count - 3) more" -ForegroundColor DarkGray
        }
    }
    
    # Save detailed report
    $errorGroups | ConvertTo-Json -Depth 3 | Out-File "error_groups.json"
    Write-Host "`n[+] Detailed report saved to error_groups.json" -ForegroundColor Green
} else {
    Write-Host "[!] No log file found" -ForegroundColor Red
}

