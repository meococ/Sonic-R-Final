param(
  [string]$From = "",
  [string]$To   = ""
)

# Defaults: last 12 months if not provided
if([string]::IsNullOrWhiteSpace($To)){
  $To = (Get-Date).ToString('yyyy.MM.dd')
}
if([string]::IsNullOrWhiteSpace($From)){
  $From = (Get-Date).AddMonths(-12).ToString('yyyy.MM.dd')
}

# Prefer the exact Terminal associated with this workspace hash to ensure EA path resolution
$terminalHash = "D0E8209F77C8CF37AD8BF550E51FF075"
$metaCandidate1 = Join-Path $env:APPDATA "MetaQuotes/Terminal/$terminalHash/terminal64.exe"
$metaCandidate2 = (Get-ChildItem "$env:APPDATA/MetaQuotes/Terminal/*/terminal64.exe" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
$metaCandidate3 = "C:\\Program Files\\MetaTrader 5\\terminal64.exe"
if(Test-Path $metaCandidate1){ $meta = $metaCandidate1 }
elseif($metaCandidate2 -and (Test-Path $metaCandidate2)){ $meta = $metaCandidate2 }
else{ $meta = $metaCandidate3 }
Write-Host "Using MT5 terminal: $meta"
$testerIni = Join-Path $PSScriptRoot "XAU_M15_KinhBan.ini"
# $preset reserved (not used)

$reportsDir = Join-Path $PSScriptRoot "Reports"
$samplesDir = Join-Path $PSScriptRoot "Samples"
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null
New-Item -ItemType Directory -Force -Path $samplesDir | Out-Null

# Update INI dynamically: dates, model=2 (Open prices), absolute report path, preset
$ini = Get-Content $testerIni
$ini = $ini -replace "^FromDate=.*$","FromDate=$From"
$ini = $ini -replace "^ToDate=.*$","ToDate=$To"
$ini = $ini -replace "^Model=.*$","Model=2"
$reportBase = Join-Path $reportsDir "XAU_M15_SoftPVSRA_Debug"
$reportEsc = $reportBase -replace "\\","\\\\"  # ensure backslashes in INI
$ini = $ini -replace "^Report=.*$","Report=$reportEsc"
# Fix ReportFormat as a standalone INI line
$ini = $ini -replace "^ReportFormat=.*$","ReportFormat=html"
$ini | Set-Content $testerIni

# Launch MT5 Strategy Tester headless (non-portable to use AppData data folder)
$mtArgs = "/config:$testerIni /expert:Experts\\Sonic R_MC\\01_SONIC R_MC_FINAL\\00_Main_EA_SonicR.ex5 /symbol:XAUUSD /period:M15 /optimize:false /log"
Write-Host "Launching tester with args: $mtArgs"
Start-Process -FilePath $meta -ArgumentList $mtArgs -Wait

# Poll for report file
$reportHtml = "$reportBase.htm"
$attempts = 0
while(-not (Test-Path $reportHtml) -and $attempts -lt 180){ Start-Sleep -Seconds 5; $attempts++ }

# Copy trace CSVs from AppData data folder into Samples
$traceDir = "$env:APPDATA\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\trace"
if(Test-Path $traceDir){
  Get-ChildItem $traceDir -Filter "XAUUSD*PERIOD_M15*.csv" | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $samplesDir $_.Name) -Force
  }
}

# Aggregate BYPASS from samples (reason column starts with BP_)
$summary = @{}
$total = 0
Get-ChildItem $samplesDir -Filter "*.csv" | ForEach-Object {
  $rows = Import-Csv $_.FullName -Delimiter ';'
  foreach($r in $rows){
    $reason = $r.reason
    if($null -ne $reason -and $reason -like 'BP_*'){
      if(-not $summary.ContainsKey($reason)){ $summary[$reason] = 0 }
      $summary[$reason]++
      $total++
    }
  }
}

$summaryPath = Join-Path $samplesDir "BYPASS_summary.csv"
"Reason,Count,Percent" | Set-Content $summaryPath
foreach($k in $summary.Keys){
  $cnt = $summary[$k]
  $pct = if($total -gt 0){ [math]::Round(100.0*$cnt/$total,1) } else { 0 }
  Add-Content $summaryPath "$k,$cnt,$pct"
}

Write-Host "Backtest completed for $From..$To (Open Prices)."
Write-Host "Report: $reportHtml"
Write-Host "Samples: $samplesDir (trace CSVs and BYPASS_summary.csv)"
