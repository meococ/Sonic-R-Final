# SONIC R MC - Fix Missing Files Script
# Đại Bàng Architecture - Missing File Resolution System

Write-Host "=== SONIC R MC - MISSING FILES FIX ===" -ForegroundColor Cyan
Write-Host "Boss's Missing File Resolution System" -ForegroundColor Yellow

$basePath = "01_SONIC R_MC_FINAL"

# Define missing files and their replacements
$missingFileReplacements = @{
    # Core files that were deleted but still referenced
    "01_Core_12_SonicEnums.mqh" = "01_Core_06_SonicEnums.mqh"
    "01_Core_10_CoreEnums.mqh" = "01_Core_07_CoreEnums.mqh"
    "01_Core_16_EnumHelpers.mqh" = "01_Core_11_EnumHelpers.mqh"
    "01_Core_07_ErrorHandler.mqh" = "01_Core_04_ErrorHandler.mqh"
    "01_Core_11_GlobalDeclarations.mqh" = "01_Core_06_GlobalDeclarations.mqh"
    "01_Core_15_SecurityHardening.mqh" = "01_Core_10_SecurityHardening.mqh"
    "01_Core_21_TradeGate.mqh" = "01_Core_12_TradeGate.mqh"
    "01_Core_07_AdvancedLogger.mqh" = "01_Core_13_AdvancedLogger.mqh"
    
    # DataProviders
    "02_DataProviders_07_IndicatorManager.mqh" = "02_DataProviders_05_IndicatorManager.mqh"
    
    # SignalGeneration
    "04_SignalGeneration_11_ScenarioPerformance.mqh" = "04_SignalGeneration_24_ScenarioPerformance.mqh"
}

Write-Host "`n=== FIXING MISSING FILE REFERENCES ===" -ForegroundColor Green

# Get all .mqh and .mq5 files
$files = Get-ChildItem -Path $basePath -Filter "*.mqh" -Recurse
$files += Get-ChildItem -Path $basePath -Filter "*.mq5" -Recurse

$totalUpdates = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileUpdates = 0
    
    foreach ($missingFile in $missingFileReplacements.Keys) {
        $replacementFile = $missingFileReplacements[$missingFile]
        
        # Pattern to match include statements
        $pattern = "#include\s+`"$([regex]::Escape($missingFile))`""
        $replacement = "#include `"$replacementFile`""
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $fileUpdates++
            Write-Host "  Fixed missing: $missingFile -> $replacementFile in $($file.Name)" -ForegroundColor Cyan
        }
    }
    
    # Write back if changes were made
    if ($fileUpdates -gt 0) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $totalUpdates += $fileUpdates
        Write-Host "Fixed $fileUpdates missing reference(s) in: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=== CREATING MISSING WRAPPER FILES ===" -ForegroundColor Green

# Create wrapper files for critical missing files
$wrapperFiles = @{
    "01_Core_12_SonicEnums.mqh" = @"
//+------------------------------------------------------------------+
//|                       01_Core_12_SonicEnums.mqh                 |
//|                    Wrapper -> 01_Core_06_SonicEnums.mqh         |
//+------------------------------------------------------------------+
#ifndef CORE_12_SONIC_ENUMS_MQH
#define CORE_12_SONIC_ENUMS_MQH
#include "01_Core_06_SonicEnums.mqh"
#endif // CORE_12_SONIC_ENUMS_MQH
"@

    "01_Core_10_CoreEnums.mqh" = @"
//+------------------------------------------------------------------+
//|                       01_Core_10_CoreEnums.mqh                  |
//|                    Wrapper -> 01_Core_07_CoreEnums.mqh          |
//+------------------------------------------------------------------+
#ifndef CORE_10_CORE_ENUMS_MQH
#define CORE_10_CORE_ENUMS_MQH
#include "01_Core_07_CoreEnums.mqh"
#endif // CORE_10_CORE_ENUMS_MQH
"@

    "01_Core_16_EnumHelpers.mqh" = @"
//+------------------------------------------------------------------+
//|                       01_Core_16_EnumHelpers.mqh                |
//|                    Wrapper -> 01_Core_11_EnumHelpers.mqh        |
//+------------------------------------------------------------------+
#ifndef CORE_16_ENUM_HELPERS_MQH
#define CORE_16_ENUM_HELPERS_MQH
#include "01_Core_11_EnumHelpers.mqh"
#endif // CORE_16_ENUM_HELPERS_MQH
"@

    "01_Core_07_ErrorHandler.mqh" = @"
//+------------------------------------------------------------------+
//|                       01_Core_07_ErrorHandler.mqh               |
//|                    Wrapper -> 01_Core_04_ErrorHandler.mqh       |
//+------------------------------------------------------------------+
#ifndef CORE_07_ERROR_HANDLER_MQH
#define CORE_07_ERROR_HANDLER_MQH
#include "01_Core_04_ErrorHandler.mqh"
#endif // CORE_07_ERROR_HANDLER_MQH
"@

    "02_DataProviders_07_IndicatorManager.mqh" = @"
//+------------------------------------------------------------------+
//|                  02_DataProviders_07_IndicatorManager.mqh       |
//|                Wrapper -> 02_DataProviders_05_IndicatorManager.mqh |
//+------------------------------------------------------------------+
#ifndef DATAPROVIDERS_07_INDICATOR_MANAGER_MQH
#define DATAPROVIDERS_07_INDICATOR_MANAGER_MQH
#include "02_DataProviders_05_IndicatorManager.mqh"
#endif // DATAPROVIDERS_07_INDICATOR_MANAGER_MQH
"@

    "04_SignalGeneration_11_ScenarioPerformance.mqh" = @"
//+------------------------------------------------------------------+
//|            04_SignalGeneration_11_ScenarioPerformance.mqh       |
//|          Wrapper -> 04_SignalGeneration_24_ScenarioPerformance.mqh |
//+------------------------------------------------------------------+
#ifndef SIGNALGENERATION_11_SCENARIO_PERFORMANCE_MQH
#define SIGNALGENERATION_11_SCENARIO_PERFORMANCE_MQH
#include "04_SignalGeneration_24_ScenarioPerformance.mqh"
#endif // SIGNALGENERATION_11_SCENARIO_PERFORMANCE_MQH
"@
}

foreach ($wrapperFile in $wrapperFiles.Keys) {
    $wrapperPath = Join-Path $basePath $wrapperFile
    $wrapperContent = $wrapperFiles[$wrapperFile]
    
    if (-not (Test-Path $wrapperPath)) {
        Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding UTF8
        Write-Host "Created wrapper: $wrapperFile" -ForegroundColor Green
    } else {
        Write-Host "Wrapper already exists: $wrapperFile" -ForegroundColor Yellow
    }
}

Write-Host "`n=== MISSING FILES FIX COMPLETE ===" -ForegroundColor Green
Write-Host "Total updates made: $totalUpdates" -ForegroundColor Cyan
Write-Host "Next step: Run compilation test again" -ForegroundColor Yellow
