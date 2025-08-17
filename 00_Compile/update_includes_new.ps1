#Requires -Version 5.1
param(
    [string]$BasePath = "01_SONIC R_MC_FINAL"
)

Write-Host "`n=== SONIC R MC - UPDATE INCLUDE STATEMENTS ===" -ForegroundColor Green
Write-Host "Updating include statements to match new file structure..." -ForegroundColor Cyan

# Define include mappings (old -> new) based on Boss's new structure
$includeMappings = @{
    # Core mappings - Boss's new numbering system
    "01_Core_06_SonicEnums.mqh" = "01_Core_12_SonicEnums.mqh"
    "01_Core_07_CoreEnums.mqh" = "01_Core_10_CoreEnums.mqh"
    "01_Core_08_IndicatorManager.mqh" = "01_Core_18_IndicatorManager.mqh"
    "01_Core_09_Utils.mqh" = "01_Core_17_Utils.mqh"
    "01_Core_05_ErrorConstants_Clean.mqh" = "01_Core_21_ErrorConstants_Clean.mqh"
    "01_Core_10_SecurityHardening.mqh" = "01_Core_19_SecurityHardening.mqh"
    "01_Core_12_TradeGate.mqh" = "01_Core_20_TradeGate.mqh"
    
    # SignalGeneration mappings - Boss's new numbering
    "04_SignalGeneration_20_SMC_Consolidated.mqh" = "04_SignalGeneration_08_SMC_Consolidated.mqh"
    "04_SignalGeneration_21_SMC_Validator.mqh" = "04_SignalGeneration_09_SMC_Validator.mqh"
    "04_SignalGeneration_23_SMC_Utils.mqh" = "04_SignalGeneration_10_SMC_Utils.mqh"
    "04_SignalGeneration_24_ScenarioPerformance.mqh" = "04_SignalGeneration_07_ScenarioPerformance.mqh"
    "04_SignalGeneration_25_ScenarioProfiles.mqh" = "04_SignalGeneration_12_ScenarioProfiles.mqh"
    "04_SignalGeneration_26_ScoutManager.mqh" = "04_SignalGeneration_13_ScoutManager.mqh"
    "04_SignalGeneration_27_ConfluenceTest.mqh" = "04_SignalGeneration_14_ConfluenceTest.mqh"
    "04_SignalGeneration_07_ConflictResolver.mqh" = "04_SignalGeneration_05_ConflictResolver.mqh"
    "04_SignalGeneration_08_DynamicWeightAdjuster.mqh" = "04_SignalGeneration_06_DynamicWeightAdjuster.mqh"
    
    # MarketAnalysis mappings
    "03_MarketAnalysis_30_WaveZigZagAnalyzer.mqh" = "03_MarketAnalysis_25_WaveZigZagAnalyzer.mqh"
    "03_MarketAnalysis_31_StructureManager.mqh" = "03_MarketAnalysis_26_StructureManager.mqh"
    "03_MarketAnalysis_32_RegimeDetector.mqh" = "03_MarketAnalysis_27_RegimeDetector.mqh"
}

# Get all .mqh and .mq5 files
$files = Get-ChildItem -Path $BasePath -Filter "*.mqh" -Recurse
$files += Get-ChildItem -Path $BasePath -Filter "*.mq5" -Recurse

$totalUpdates = 0
$filesUpdated = 0

foreach ($file in $files) {
    try {
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
            $filesUpdated++
            Write-Host "✅ Updated $fileUpdates include(s) in: $($file.Name)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ Error processing $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== UPDATE COMPLETE ===" -ForegroundColor Green
Write-Host "Files processed: $($files.Count)" -ForegroundColor Cyan
Write-Host "Files updated: $filesUpdated" -ForegroundColor Cyan
Write-Host "Total include updates: $totalUpdates" -ForegroundColor Cyan
Write-Host "`nNext step: Run compilation test" -ForegroundColor Yellow
