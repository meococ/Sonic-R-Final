param(
  [string]$Root = "01_SONIC R_MC_FINAL"
)

$ErrorActionPreference = 'Stop'

# Gather files
$files = Get-ChildItem -Path $Root -Recurse -Include *.mq5,*.mqh -File

$includeRegex = [regex]'#include\s+"([^"]+)"'
$ifdefRegex   = [regex]'^\s*#ifdef\s+([A-Z0-9_]+)'
$endifRegex   = [regex]'^\s*#endif\b'
$defineRegex  = [regex]'^\s*#define\s+([A-Z0-9_]+)'

$includeGraph = @{}
$missing = New-Object System.Collections.Generic.List[object]
$definedMacros = New-Object 'System.Collections.Generic.HashSet[string]'

# Pass 0: collect defined macros
foreach($f in $files){
  $lines = Get-Content -Path $f.FullName
  foreach($line in $lines){
    $m = $defineRegex.Match($line)
    if($m.Success){ [void]$definedMacros.Add($m.Groups[1].Value) }
  }
}

foreach($f in $files){
  $lines = Get-Content -Path $f.FullName
  $list = New-Object System.Collections.Generic.List[string]
  $condStack = New-Object System.Collections.Stack
  foreach($line in $lines){
    if($line -match '^\s*//'){ continue }
    $mi = $ifdefRegex.Match($line)
    if($mi.Success){
      $macro = $mi.Groups[1].Value
      $isActive = $definedMacros.Contains($macro)
      $condStack.Push($isActive) | Out-Null
      continue
    }
    if($endifRegex.IsMatch($line)){
      if($condStack.Count -gt 0){ $condStack.Pop() | Out-Null }
      continue
    }
    $active = $true
    foreach($c in $condStack){ if(-not $c){ $active = $false; break } }
    $m = $includeRegex.Match($line)
    if($m.Success){
      if(-not $active){ continue }
      $inc = $m.Groups[1].Value
      $incPath = Join-Path $f.DirectoryName $inc
      try { [void](Resolve-Path -LiteralPath $incPath -ErrorAction Stop) }
      catch { $missing.Add([pscustomobject]@{ File=$f.FullName; Include=$inc }) | Out-Null }
      $list.Add($inc) | Out-Null
    }
  }
  $includeGraph[$f.FullName] = $list
}

function Resolve-IncludeAbs([string]$baseFile, [string]$inc){
  $p = Join-Path (Split-Path $baseFile) $inc
  try { return (Resolve-Path -LiteralPath $p -ErrorAction Stop).Path } catch { return $null }
}

# Detect circular deps (DFS)
$visiting = New-Object 'System.Collections.Generic.HashSet[string]'
$visited  = New-Object 'System.Collections.Generic.HashSet[string]'
$circular = New-Object 'System.Collections.Generic.List[string]'

function DFS([string]$node){
  if($visited.Contains($node)){ return }
  if($visiting.Contains($node)){ $circular.Add($node) | Out-Null; return }
  $visiting.Add($node) | Out-Null
  $neighbors = $includeGraph[$node]
  foreach($n in $neighbors){
    $abs = Resolve-IncludeAbs -baseFile $node -inc $n
    if($abs){ DFS -node $abs }
  }
  $visiting.Remove($node) | Out-Null
  $visited.Add($node) | Out-Null
}

foreach($k in $includeGraph.Keys){ DFS -node $k }

# extern vs implementations (heuristic)
$externNames = New-Object System.Collections.Generic.HashSet[string]
$implNames   = New-Object System.Collections.Generic.HashSet[string]
$externRegex = [regex]'(?m)^\s*extern\s+[A-Za-z_][A-Za-z0-9_\*\s:&<>\[\]]+\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('
$implRegex   = [regex]'(?m)^\s*[A-Za-z_][A-Za-z0-9_\*\s:&<>\[\]]+\s+([A-Za-z_][A-Za-z0-9_]*)\s*\('

foreach($f in $files){
  $content = Get-Content -Path $f.FullName -Raw
  foreach($m in $externRegex.Matches($content)){ [void]$externNames.Add($m.Groups[1].Value) }
  foreach($m in $implRegex.Matches($content)){   [void]$implNames.Add($m.Groups[1].Value) }
}

$externMissing = @()
foreach($name in $externNames){ if(-not $implNames.Contains($name)){ $externMissing += $name } }
# Apply whitelist if present
$wlPath = Join-Path $PSScriptRoot '00_Compile/03_Audit/externs_whitelist.txt'
if(Test-Path $wlPath){
  $wl = Get-Content -Path $wlPath | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object { $_.Trim() }
  $externMissing = $externMissing | Where-Object { $wl -notcontains $_ }
}

# Output report
$report = @()
$report += '=== INCLUDE AUDIT REPORT ==='
$report += ("Total files scanned: {0}" -f $files.Count)
$report += ("Missing includes: {0}" -f $missing.Count)
foreach($m in $missing){ $report += ("MISSING: {0} -> `"{1}`"" -f $m.File, $m.Include) }
$report += ("Circular deps detected: {0}" -f $circular.Count)
foreach($c in $circular){ $report += ("CIRCULAR: {0}" -f $c) }
$report += ("Externs without implementation: {0}" -f $externMissing.Count)
foreach($e in $externMissing){ $report += ("EXTERN_MISSING: {0}" -f $e) }

$OutFile = Join-Path $Root 'audit_includes_report.txt'
$report | Out-File -FilePath $OutFile -Encoding UTF8
Write-Host ("Audit complete. Report: {0}" -f $OutFile)

