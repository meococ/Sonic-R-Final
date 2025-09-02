Param(
  [ValidateSet('quick','auto','test')][string]$Mode = 'quick',
  [ValidateSet('ea')][string]$Target = 'ea',
  [string]$MetaEditorPath,
  [switch]$ShowConfig
)

$ErrorActionPreference = 'Stop'

function Resolve-MetaEditorPath {
  param([string]$Override)
  if($Override -and (Test-Path $Override)) { return (Resolve-Path $Override).Path }
  $candidates = @(
    'C:\Program Files\MetaTrader 5\metaeditor64.exe',
    'C:\Program Files\MetaTrader 5\metaeditor.exe',
    'C:\Program Files (x86)\MetaTrader 5\metaeditor.exe'
  )
  foreach($p in $candidates){ if(Test-Path $p){ return $p } }
  # Try from PATH
  try { $p = (Get-Command metaeditor64.exe -ErrorAction Stop).Source; if($p){ return $p } } catch {}
  try { $p = (Get-Command metaeditor.exe -ErrorAction Stop).Source; if($p){ return $p } } catch {}
  throw "MetaEditor not found. Provide -MetaEditorPath or install MetaTrader 5."
}

$metaEditor = Resolve-MetaEditorPath -Override $MetaEditorPath
$root = (Get-Location).Path
$eaPath = Join-Path $root '01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5'
# Use a log directory without spaces to avoid CLI quoting issues
$logDir = Join-Path $root '00_Compile\Logs'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$mainLog = Join-Path $logDir '00_Main_EA_SonicR.mq5.log'

function New-LogFileIfMissing {
  param([string]$Path)
  try { New-Item -ItemType File -Force -Path $Path -ErrorAction Stop | Out-Null } catch {}
}

function Invoke-Compile {
  param([string]$ea,[string]$log)
  if(-not (Test-Path $ea)) { Write-Host "[x] ERROR: EA path not found: $ea"; return @{ ExitCode = 2; Time = '0 ms' } }
  New-LogFileIfMissing -Path $log
  $argList = @("/compile:$ea","/log:$log")
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $proc = Start-Process -FilePath $metaEditor -ArgumentList $argList -PassThru -Wait -WindowStyle Hidden
  $sw.Stop()
  $elapsed = '{0:N0} ms' -f $sw.ElapsedMilliseconds
  $exitCode = 1
  if($proc -and $null -ne $proc.ExitCode){ $exitCode = $proc.ExitCode }
  return @{ ExitCode = $exitCode; Time = $elapsed }
}

function Show-LogTail {
  param([string]$Path,[int]$Count=60)
  if(Test-Path $Path){
    Write-Host "--- Last $Count lines of $Path ---"
    Get-Content $Path -Tail $Count | Write-Host
    Write-Host "--- End ---"
  } else {
    Write-Host "[!] Log file not found: $Path"
  }
}

function Summarize-Log {
  param([string]$Path)
  if(-not (Test-Path $Path)) { return @{ Errors = 0; Warnings = 0 } }
  $errors = (Select-String -Path $Path -Pattern 'error ' -SimpleMatch -CaseSensitive:$false -ErrorAction SilentlyContinue).Count
  $warnings = (Select-String -Path $Path -Pattern 'warning ' -SimpleMatch -CaseSensitive:$false -ErrorAction SilentlyContinue).Count
  return @{ Errors = $errors; Warnings = $warnings }
}

if($ShowConfig){
  Write-Host "[Config] MetaEditor: $metaEditor"
  Write-Host "[Config] EA: $eaPath"
  Write-Host "[Config] LogDir: $logDir"
}

switch($Mode){
  'quick' {
    Write-Host "[*] Quick compiling EA..."
    $res = Invoke-Compile -ea $eaPath -log $mainLog
    $sum = Summarize-Log -Path $mainLog
    if($res.ExitCode -eq 0){
      Write-Host ("[+] SUCCESS: EA compiled! | Time: {0} | Errors: {1} | Warnings: {2}" -f $res.Time,$sum.Errors,$sum.Warnings)
      if($sum.Errors -gt 0){ Write-Host "[!] Hidden error suspected: ExitCode=0 but errors found in log" }
      exit 0
    } else {
      Write-Host ("[-] FAILED: See log: {0} (ExitCode={1}) | Time: {2}" -f $mainLog,$res.ExitCode,$res.Time)
      Show-LogTail -Path $mainLog -Count 80
      exit 1
    }
  }
  'auto' {
    $stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $tsLog = Join-Path $logDir ("compile_"+$stamp+".log")
    Write-Host "[*] Starting Auto Compile: $stamp"
    $res = Invoke-Compile -ea $eaPath -log $tsLog
    $sum = Summarize-Log -Path $tsLog
    if($res.ExitCode -eq 0){
      Write-Host ("[+] SUCCESS | Log: {0} | Time: {1} | Errors: {2} | Warnings: {3}" -f $tsLog,$res.Time,$sum.Errors,$sum.Warnings)
      if($sum.Errors -gt 0){ Write-Host "[!] Hidden error suspected: ExitCode=0 but errors found in log" }
      exit 0
    } else {
      Write-Host ("[-] FAILED | Log: {0} | ExitCode: {1} | Time: {2}" -f $tsLog,$res.ExitCode,$res.Time)
      Show-LogTail -Path $tsLog -Count 120
      exit 1
    }
  }
  'test' {
    Write-Host "=== COMPILATION OUTPUT ==="
    New-LogFileIfMissing -Path $mainLog
    $res = Invoke-Compile -ea $eaPath -log $mainLog
    if(Test-Path $mainLog){ Get-Content $mainLog | Write-Host } else { Write-Host "[!] No log generated at $mainLog" }
    $sum = Summarize-Log -Path $mainLog
    Write-Host "=== END OF OUTPUT ==="
    Write-Host ("[Summary] ExitCode: {0} | Time: {1} | Errors: {2} | Warnings: {3}" -f $res.ExitCode,$res.Time,$sum.Errors,$sum.Warnings)
    if($res.ExitCode -eq 0){ if($sum.Errors -gt 0){ Write-Host "[!] Hidden error suspected." }; Write-Host "[SUCCESS]"; exit 0 } else { Write-Host "[FAILED]"; exit 1 }
  }
}
