param(
  [string]$SourceDir = "01_SONIC R_MC_FINAL",
  [string]$OutDir = "00_Compile/Logs",
  [ValidateSet("graph","check","both")] [string]$Mode = "both"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null }
}

function Get-RelativePath {
  param([string]$Base, [string]$Full)
  $basePath = [System.IO.Path]::GetFullPath($Base)
  $fullPath = [System.IO.Path]::GetFullPath($Full)
  if ($fullPath.StartsWith($basePath, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $fullPath.Substring($basePath.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
  }
  return $fullPath
}

function Parse-Includes {
  param([string]$FilePath)
  $includes = @()
  $content = Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue
  if ($null -eq $content) { return $includes }
  $inBlock = $false
  foreach ($raw in $content) {
    $line = $raw
    if ($inBlock) {
      if ($line -match '\*/') {
        # end of block comment
        $inBlock = $false
      }
      continue
    }
    # handle start of block comment
    if ($line -match '/\*') {
      $inBlock = $true
      # take part before block only
      $line = $line -replace '/\*.*$',''
    }
    # strip single-line comments
    if ($line -match '^\s*//') { continue }
    # match include
    if ($line -match '^\s*#\s*include\s*[<"]([^">]+)[">]') {
      $inc = $Matches[1]
      $includes += $inc
    }
  }
  return $includes
}

function Build-Graph {
  param([string]$Root)
  $graph = @{}
  $unresolved = @()
  $files = Get-ChildItem -LiteralPath $Root -Recurse -Include *.mqh, *.mq5 -File
  $rootAbs = [System.IO.Path]::GetFullPath($Root)

  foreach ($f in $files) {
    $nodeRel = Get-RelativePath -Base $rootAbs -Full $f.FullName
    if (-not $graph.ContainsKey($nodeRel)) { $graph[$nodeRel] = New-Object System.Collections.Generic.HashSet[string] }
    $includes = Parse-Includes -FilePath $f.FullName
    foreach ($inc in $includes) {
      $isAngle = $false
      if ($inc -match '^[A-Za-z]:\\' -or $inc -match '^/|^\\') {
        # absolute path in include (rare), record as unresolved
        $targetRel = "external::$inc"
        $unresolved += $targetRel
        [void]$graph[$nodeRel].Add($targetRel)
        continue
      }
      # Try resolve quoted include relative to file dir
      $candidate = Join-Path -Path $f.DirectoryName -ChildPath $inc
      if (Test-Path -LiteralPath $candidate) {
        $targetRel = Get-RelativePath -Base $rootAbs -Full $candidate
        [void]$graph[$nodeRel].Add($targetRel)
      } else {
        # Try resolve relative to root
        $candidate2 = Join-Path -Path $rootAbs -ChildPath $inc
        if (Test-Path -LiteralPath $candidate2) {
          $targetRel = Get-RelativePath -Base $rootAbs -Full $candidate2
          [void]$graph[$nodeRel].Add($targetRel)
        } else {
          # Treat as external (stdlib or outside project)
          $targetRel = "external::$inc"
          [void]$graph[$nodeRel].Add($targetRel)
          $unresolved += $targetRel
        }
      }
    }
  }
  return @{ Graph = $graph; Unresolved = ($unresolved | Select-Object -Unique) }
}

function Find-Cycles {
  param([hashtable]$Graph)
  $visited = @{}
  $stack = @{}
  $path = New-Object System.Collections.Generic.List[string]
  $cycles = New-Object System.Collections.Generic.List[string]

  function DFS {
    param([string]$node)
    $visited[$node] = $true
    $stack[$node] = $true
    $null = $path.Add($node)

    $neighbors = $Graph[$node]
    if ($neighbors -ne $null) {
      foreach ($nbr in $neighbors) {
        # Ignore external deps in cycle detection
        if ($nbr -like 'external::*') { continue }
        if (-not $Graph.ContainsKey($nbr)) { continue }
        if (-not $visited.ContainsKey($nbr)) {
          DFS -node $nbr
        } elseif ($stack.ContainsKey($nbr)) {
          # Found cycle: extract path from first occurrence of $nbr
          $startIdx = $path.IndexOf($nbr)
          if ($startIdx -ge 0) {
            $len = $path.Count - $startIdx
            $cycleNodes = New-Object System.Collections.Generic.List[string]
            for ($i = 0; $i -lt $len; $i++) { $null = $cycleNodes.Add($path[$startIdx + $i]) }
            $null = $cycleNodes.Add($nbr)
            $cycleStr = ($cycleNodes -join ' -> ')
            $cycles.Add($cycleStr)
          }
        }
      }
    }

    $stack.Remove($node) | Out-Null
    if ($path.Count -gt 0) { $path.RemoveAt($path.Count - 1) }
  }

  foreach ($n in $Graph.Keys) {
    if ($n -like 'external::*') { continue }
    if (-not $visited.ContainsKey($n)) { DFS -node $n }
  }

  # Deduplicate cycles ignoring rotation
  $norm = @{}
  foreach ($c in $cycles) {
    $parts = $c -split ' -> '
    # Normalize by rotating to lexicographically smallest node
    $minIdx = 0; for ($i=1; $i -lt $parts.Length; $i++){ if ($parts[$i] -lt $parts[$minIdx]) { $minIdx = $i } }
    $rot = @()
    for ($i=0; $i -lt $parts.Length; $i++){ $rot += $parts[($minIdx + $i) % $parts.Length] }
    $key = ($rot -join ' -> ')
    $norm[$key] = $true
  }
  return ($norm.Keys | Sort-Object)
}

function Write-Dot {
  param([hashtable]$Graph, [string]$OutFile)
  $lines = @()
  $lines += 'digraph EADeps {'
  $lines += '  rankdir=LR;'
  foreach ($from in $Graph.Keys) {
    foreach ($to in $Graph[$from]) {
      $f = $from.Replace('\\','/'); $t = $to.Replace('\\','/')
      $lines += '  "' + $f + '" -> "' + $t + '";'
    }
  }
  $lines += '}'
  Set-Content -LiteralPath $OutFile -Value $lines -Encoding UTF8
}

# Main
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projRoot = Resolve-Path -LiteralPath (Join-Path $scriptRoot '..') | Select-Object -ExpandProperty Path
$src = Join-Path $projRoot $SourceDir
$out = Join-Path $projRoot $OutDir
Ensure-Directory -Path $out

$build = Build-Graph -Root $src
$graph = $build.Graph
$unresolved = $build.Unresolved

$reportPath = Join-Path $out 'dependency_report.txt'
$dotPath = Join-Path $out 'dependency_graph.dot'

if ($Mode -in @('graph','both')) {
  Write-Dot -Graph $graph -OutFile $dotPath
}

$cycles = @()
if ($Mode -in @('check','both')) {
  $cycles = @(Find-Cycles -Graph $graph)
}

# Write report
$nodeCount = $graph.Keys.Count
$edgeCount = ($graph.GetEnumerator() | ForEach-Object { $_.Value.Count } | Measure-Object -Sum).Sum
$report = @()
$report += "EA Dependency Report"
$report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$report += "SourceDir: $SourceDir"
$report += "Nodes: $nodeCount | Edges: $edgeCount"
$report += "Unresolved includes: $($unresolved.Count)"
if ($unresolved.Count -gt 0) {
  $report += "Unresolved list (top 20):"
  $report += ($unresolved | Select-Object -First 20)
}
$cycleCount = @($cycles).Count
$report += "Cycles found: $cycleCount"
if (@($cycles).Count -gt 0) {
  $report += "Cycle list:"
  $report += @($cycles)
}
Set-Content -LiteralPath $reportPath -Value $report -Encoding UTF8

Write-Host "[+] Dependency analysis completed"
Write-Host "    Nodes: $nodeCount, Edges: $edgeCount, Cycles: $cycleCount"
Write-Host "    Report: $reportPath"
if (Test-Path -LiteralPath $dotPath) { Write-Host "    Graph:  $dotPath" } 