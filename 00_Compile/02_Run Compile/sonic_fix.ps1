#requires -version 5.0
<#
.SYNOPSIS
      SONIC R MC - Auto Fix Script
    Sa cc l-i chnh trong EA

.DESCRIPTION
    Script t 'ng sa cc l-i ph-  bin:
    - Missing includes
    - Syntax errors
    - Class structure issues
    - Enum definitions

.PARAMETER Mode
    Ch ' fix:
    - quick: Sa nhanh cc l-i chnh
    - full: Sa tt c l-i
    - check: Ch kim tra khng sa

.EXAMPLE
    .\sonic_fix.ps1 -Mode quick
    .\sonic_fix.ps1 -Mode full
    .\sonic_fix.ps1 -Mode check
#>

param(
    [ValidateSet("quick", "full", "check")]
    [string]$Mode = "quick",
    
    [switch]$Verbose,
    [switch]$Backup
)

# === CONFIGURATION ===
$ScriptDir = $PSScriptRoot
$ProjectDir = Join-Path $ScriptDir "..\01_SONIC R_MC_FINAL"
$BackupDir = Join-Path $ScriptDir "Backup"

# Colors for output
$Colors = @{
    Header = "Cyan"
    Success = "Green" 
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Debug = "DarkGray"
}

function Write-SonicHeader {
    param([string]$Title)
    
    Write-Host ""
    Write-Host "+===============================================================================+" -ForegroundColor $Colors.Header
    Write-Host "|   SONIC R MC - $Title" -ForegroundColor $Colors.Header
    Write-Host "+===============================================================================+" -ForegroundColor $Colors.Header
    Write-Host ""
}

function Write-SonicStatus {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
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

function Backup-Files {
    if ($Backup) {
        Write-SonicStatus "Creating backup..." "Info"
        
        if (!(Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = Join-Path $BackupDir "Backup_$timestamp"
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        
        Copy-Item -Path "$ProjectDir\*.mqh" -Destination $backupPath -Force
        Copy-Item -Path "$ProjectDir\*.mq5" -Destination $backupPath -Force
        
        Write-SonicStatus "Backup created: $backupPath" "Success"
    }
}

function Fix-EnumHelpers {
    Write-SonicStatus "Fixing EnumHelpers includes..." "Info"
    
    $file = Join-Path $ProjectDir "01_Core_16_EnumHelpers.mqh"
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Add missing include for CoreEnums
        if ($content -notmatch "01_Core_10_CoreEnums\.mqh") {
            $newContent = $content -replace "#include `"01_Core_12_SonicEnums\.mqh`"", "#include `"01_Core_12_SonicEnums.mqh`"`n#include `"01_Core_10_CoreEnums.mqh`"  // For ENUM_TRADING_SCENARIO and ENUM_TRADING_STRATEGY"
            
            if ($Mode -ne "check") {
                Set-Content -Path $file -Value $newContent -Encoding UTF8
                Write-SonicStatus "Fixed EnumHelpers includes" "Success"
            } else {
                Write-SonicStatus "Would fix EnumHelpers includes" "Warning"
            }
        } else {
            Write-SonicStatus "EnumHelpers includes already correct" "Success"
        }
    }
}

function Fix-ConsolidatedSignals {
    Write-SonicStatus "Fixing ConsolidatedSignals structure..." "Info"
    
    $file = Join-Path $ProjectDir "04_SignalGeneration_01_ConsolidatedSignals.mqh"
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Fix class structure issues
        if ($content -match "class CConsolidatedSignals") {
            # Check for duplicate class definitions
            $classCount = ([regex]::Matches($content, "class CConsolidatedSignals")).Count
            if ($classCount -gt 1) {
                Write-SonicStatus "Found duplicate class definitions in ConsolidatedSignals" "Warning"
                
                if ($Mode -ne "check") {
                    # Remove duplicate class definitions
                    $lines = Get-Content $file
                    $inClass = $false
                    $classStart = -1
                    $classEnd = -1
                    
                    for ($i = 0; $i -lt $lines.Count; $i++) {
                        if ($lines[$i] -match "class CConsolidatedSignals") {
                            if (-not $inClass) {
                                $inClass = $true
                                $classStart = $i
                            } else {
                                # Found second class definition
                                $classEnd = $i - 1
                                break
                            }
                        }
                    }
                    
                    if ($classStart -ge 0 -and $classEnd -ge 0) {
                        $newLines = $lines[0..$classStart] + $lines[$classEnd..($lines.Count-1)]
                        Set-Content -Path $file -Value $newLines -Encoding UTF8
                        Write-SonicStatus "Removed duplicate class definition" "Success"
                    }
                }
            }
        }
    }
}

function Fix-MasterOrchestrator {
    Write-SonicStatus "Fixing MasterOrchestrator structure..." "Info"
    
    $file = Join-Path $ProjectDir "03_MarketAnalysis_08_MasterOrchestrator.mqh"
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Check for code outside class scope
        if ($content -match "m_waveAnalyzer = new CEnhancedWavePatternAnalyzer\(\);") {
            Write-SonicStatus "Found code outside class scope in MasterOrchestrator" "Warning"
            
            if ($Mode -ne "check") {
                # This is a complex fix - would need to restructure the entire file
                Write-SonicStatus "MasterOrchestrator needs manual restructuring" "Error"
            }
        }
    }
}

function Fix-CommonSyntaxErrors {
    Write-SonicStatus "Fixing common syntax errors..." "Info"
    
    # Fix missing semicolons and other syntax issues
    $files = Get-ChildItem $ProjectDir -Filter "*.mqh" -Recurse
    
    foreach ($file in $files) {
        $content = Get-Content $file -Raw
        $modified = $false
        
        # Fix common issues
        if ($content -match "if\s*\(\s*!.*\)\s*\{") {
            # Fix if statement formatting
            $content = $content -replace "if\s*\(\s*!([^)]+)\)\s*\{", "if(!`$1) {"
            $modified = $true
        }
        
        if ($modified -and $Mode -ne "check") {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-SonicStatus "Fixed syntax in $($file.Name)" "Success"
        }
    }
}

function Check-Compilation {
    Write-SonicStatus "Checking compilation..." "Info"
    
    # Run compilation check
    $compileScript = Join-Path $ScriptDir "sonic_compile.ps1"
    if (Test-Path $compileScript) {
        $result = & $compileScript -Mode quick -Target ea -Silent
        return $LASTEXITCODE -eq 0
    }
    
    return $false
}

# === MAIN EXECUTION ===

Write-SonicHeader "AUTO FIX SYSTEM V1.0"

if ($Mode -eq "check") {
    Write-SonicStatus "Running in CHECK mode - no files will be modified" "Warning"
}

# Create backup if requested
Backup-Files

# Apply fixes
Fix-EnumHelpers
Fix-ConsolidatedSignals
Fix-MasterOrchestrator
Fix-CommonSyntaxErrors

# Check results
if ($Mode -ne "check") {
    Write-SonicStatus "Running compilation check..." "Info"
    $compilationOK = Check-Compilation
    
    if ($compilationOK) {
        Write-SonicStatus "... All fixes applied successfully!" "Success"
    } else {
        Write-SonicStatus " Some issues remain - manual review needed" "Error"
    }
} else {
    Write-SonicStatus "Check mode completed - review results above" "Info"
}

Write-SonicHeader "FIX COMPLETED"

