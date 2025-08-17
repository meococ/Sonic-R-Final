# SONIC R MC - Fix Include Statements Script
# Đại Bàng Architecture - Include Update System

Write-Host "=== SONIC R MC - INCLUDE STATEMENTS UPDATE ===" -ForegroundColor Cyan
Write-Host "Boss's Include Standardization System" -ForegroundColor Yellow

$basePath = "01_SONIC R_MC_FINAL"

# Define include mappings (old -> new)
$includeMappings = @{
    # Core mappings
    "01_Core_06_Logger.mqh" = "01_Core_03_Logger.mqh"
    "01_Core_08_ErrorConstants_Clean.mqh" = "01_Core_05_ErrorConstants_Clean.mqh"
    "01_Core_08_SonicEnums.mqh" = "01_Core_06_SonicEnums.mqh"
    "01_Core_09_CommonStructures.mqh" = "01_Core_07_CommonStructures.mqh"
    "01_Core_09_ContextManager.mqh" = "01_Core_08_ContextManager.mqh"
    "01_Core_10_SharedDataStructures.mqh" = "01_Core_09_SharedDataStructures.mqh"
    "01_Core_11_SecurityHardening.mqh" = "01_Core_10_SecurityHardening.mqh"
    "01_Core_12_EnumHelpers.mqh" = "01_Core_11_EnumHelpers.mqh"
    "01_Core_13_CommonStructures.mqh" = "01_Core_07_CommonStructures.mqh"
    "01_Core_13_TradeGate.mqh" = "01_Core_12_TradeGate.mqh"
    "01_Core_14_AdvancedLogger.mqh" = "01_Core_13_AdvancedLogger.mqh"
    "01_Core_14_SharedDataStructures.mqh" = "01_Core_09_SharedDataStructures.mqh"
    
    # MarketAnalysis mappings
    "03_MarketAnalysis_13_WaveZigZagAnalyzer.mqh" = "03_MarketAnalysis_30_WaveZigZagAnalyzer.mqh"
    "03_MarketAnalysis_14_StructureManager.mqh" = "03_MarketAnalysis_31_StructureManager.mqh"
    "03_MarketAnalysis_22_RegimeDetector.mqh" = "03_MarketAnalysis_32_RegimeDetector.mqh"
    
    # SignalGeneration mappings
    "04_SignalGeneration_02_SMC_Consolidated.mqh" = "04_SignalGeneration_20_SMC_Consolidated.mqh"
    "04_SignalGeneration_03_SMC_Validator.mqh" = "04_SignalGeneration_21_SMC_Validator.mqh"
    "04_SignalGeneration_04_ScenarioConfig_Class.mqh" = "04_SignalGeneration_22_ScenarioConfig_Class.mqh"
    "04_SignalGeneration_04_SMC_Utils.mqh" = "04_SignalGeneration_23_SMC_Utils.mqh"
    "04_SignalGeneration_05_ScenarioPerformance.mqh" = "04_SignalGeneration_24_ScenarioPerformance.mqh"
    "04_SignalGeneration_05_ScenarioProfiles.mqh" = "04_SignalGeneration_25_ScenarioProfiles.mqh"
    "04_SignalGeneration_05_ScoutManager.mqh" = "04_SignalGeneration_26_ScoutManager.mqh"
    "04_SignalGeneration_06_ConfluenceTest.mqh" = "04_SignalGeneration_27_ConfluenceTest.mqh"
    "04_SignalGeneration_06_ScoutManager.mqh" = "04_SignalGeneration_26_ScoutManager.mqh"
}

Write-Host "`n=== UPDATING INCLUDE STATEMENTS ===" -ForegroundColor Green

# Get all .mqh and .mq5 files
$files = Get-ChildItem -Path $basePath -Filter "*.mqh" -Recurse
$files += Get-ChildItem -Path $basePath -Filter "*.mq5" -Recurse

$totalUpdates = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileUpdates = 0
    
    foreach ($oldInclude in $includeMappings.Keys) {
        $newInclude = $includeMappings[$oldInclude]
        
        # Pattern to match include statements
        $pattern = "#include\s+`"$([regex]::Escape($oldInclude))`""
        $replacement = "#include `"$newInclude`""
        
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacement
            $fileUpdates++
            Write-Host "  Updated: $oldInclude -> $newInclude in $($file.Name)" -ForegroundColor Cyan
        }
    }
    
    # Write back if changes were made
    if ($fileUpdates -gt 0) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $totalUpdates += $fileUpdates
        Write-Host "Updated $fileUpdates include(s) in: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=== INCLUDE UPDATE COMPLETE ===" -ForegroundColor Green
Write-Host "Total updates made: $totalUpdates" -ForegroundColor Cyan
Write-Host "Next step: Run compilation test" -ForegroundColor Yellow
