# SONIC R MC - Fix Duplicate Files Script
# Đại Bàng Architecture - File Cleanup System

Write-Host "=== SONIC R MC - DUPLICATE FILE CLEANUP ===" -ForegroundColor Cyan
Write-Host "Boss's File Standardization System" -ForegroundColor Yellow

$basePath = "01_SONIC R_MC_FINAL"

# Define files to remove (duplicates/obsolete)
$filesToRemove = @(
    # Core duplicates
    "01_Core_07_AdvancedLogger.mqh",        # Keep 14_AdvancedLogger
    "01_Core_07_ErrorHandler.mqh",          # Keep 04_ErrorHandler  
    "01_Core_08_ErrorConstants.mqh",        # Keep 05_ErrorConstants
    "01_Core_10_CoreEnums.mqh",             # Keep 07_CoreEnums
    "01_Core_11_GlobalDeclarations.mqh",    # Keep 06_GlobalDeclarations
    "01_Core_12_SonicEnums.mqh",            # Keep 08_SonicEnums
    "01_Core_13_CommonStructures.mqh",      # Keep 09_CommonStructures
    "01_Core_14_SharedDataStructures.mqh",  # Keep 10_SharedDataStructures
    "01_Core_15_SecurityHardening.mqh",     # Keep 11_SecurityHardening
    "01_Core_16_EnumHelpers.mqh",           # Keep 12_EnumHelpers
    "01_Core_21_TradeGate.mqh",             # Keep 13_TradeGate
    
    # DataProviders duplicates
    "02_DataProviders_07_IndicatorManager.mqh", # Keep 05_IndicatorManager
    
    # MarketAnalysis duplicates
    "03_MarketAnalysis_25_WaveZigZagAnalyzer.mqh", # Keep 13_WaveZigZagAnalyzer
    "03_MarketAnalysis_26_ScenarioEngine.mqh",     # Keep 14_ScenarioEngine
    "03_MarketAnalysis_27_RegimeDetector.mqh",     # Keep 22_RegimeDetector
    
    # SignalGeneration duplicates
    "04_SignalGeneration_05_ScenarioConfig_Class.mqh", # Keep 04_ScenarioConfig_Class
    "04_SignalGeneration_06_ScoutManager.mqh",         # Keep 05_ScoutManager
    "04_SignalGeneration_09_DynamicWeightAdjuster.mqh", # Keep 08_DynamicWeightAdjuster
    "04_SignalGeneration_10_SMC_Consolidated.mqh",     # Keep 02_SMC_Consolidated
    "04_SignalGeneration_11_ScenarioPerformance.mqh",  # Keep 05_ScenarioPerformance
    "04_SignalGeneration_12_ScenarioProfiles.mqh",     # Keep 05_ScenarioProfiles
    
    # Risk duplicates
    "06_Risk_14_MonteCarlo.mqh"  # Keep 06_RiskManagement_15_MonteCarlo.mqh
)

# Define files to rename (resolve numbering conflicts)
$filesToRename = @{
    # Core renaming to fix sequence
    "01_Core_08_ErrorConstants_Clean.mqh" = "01_Core_05_ErrorConstants_Clean.mqh"
    "01_Core_08_SonicEnums.mqh" = "01_Core_06_SonicEnums.mqh"
    "01_Core_09_CommonStructures.mqh" = "01_Core_07_CommonStructures.mqh"
    "01_Core_09_ContextManager.mqh" = "01_Core_08_ContextManager.mqh"
    "01_Core_10_SharedDataStructures.mqh" = "01_Core_09_SharedDataStructures.mqh"
    "01_Core_11_SecurityHardening.mqh" = "01_Core_10_SecurityHardening.mqh"
    "01_Core_12_EnumHelpers.mqh" = "01_Core_11_EnumHelpers.mqh"
    "01_Core_13_TradeGate.mqh" = "01_Core_12_TradeGate.mqh"
    "01_Core_14_AdvancedLogger.mqh" = "01_Core_13_AdvancedLogger.mqh"
    
    # MarketAnalysis renaming
    "03_MarketAnalysis_13_WaveZigZagAnalyzer.mqh" = "03_MarketAnalysis_30_WaveZigZagAnalyzer.mqh"
    "03_MarketAnalysis_14_StructureManager.mqh" = "03_MarketAnalysis_31_StructureManager.mqh"
    "03_MarketAnalysis_22_RegimeDetector.mqh" = "03_MarketAnalysis_32_RegimeDetector.mqh"
    
    # SignalGeneration renaming
    "04_SignalGeneration_02_SMC_Consolidated.mqh" = "04_SignalGeneration_20_SMC_Consolidated.mqh"
    "04_SignalGeneration_03_SMC_Validator.mqh" = "04_SignalGeneration_21_SMC_Validator.mqh"
    "04_SignalGeneration_04_ScenarioConfig_Class.mqh" = "04_SignalGeneration_22_ScenarioConfig_Class.mqh"
    "04_SignalGeneration_04_SMC_Utils.mqh" = "04_SignalGeneration_23_SMC_Utils.mqh"
    "04_SignalGeneration_05_ScenarioPerformance.mqh" = "04_SignalGeneration_24_ScenarioPerformance.mqh"
    "04_SignalGeneration_05_ScenarioProfiles.mqh" = "04_SignalGeneration_25_ScenarioProfiles.mqh"
    "04_SignalGeneration_05_ScoutManager.mqh" = "04_SignalGeneration_26_ScoutManager.mqh"
    "04_SignalGeneration_06_ConfluenceTest.mqh" = "04_SignalGeneration_27_ConfluenceTest.mqh"
}

Write-Host "`n=== PHASE 1: REMOVING DUPLICATE FILES ===" -ForegroundColor Green

foreach ($file in $filesToRemove) {
    $fullPath = Join-Path $basePath $file
    if (Test-Path $fullPath) {
        Write-Host "Removing duplicate: $file" -ForegroundColor Red
        Remove-Item $fullPath -Force
    } else {
        Write-Host "File not found (already removed?): $file" -ForegroundColor Yellow
    }
}

Write-Host "`n=== PHASE 2: RENAMING FILES TO FIX NUMBERING ===" -ForegroundColor Green

foreach ($oldName in $filesToRename.Keys) {
    $newName = $filesToRename[$oldName]
    $oldPath = Join-Path $basePath $oldName
    $newPath = Join-Path $basePath $newName
    
    if (Test-Path $oldPath) {
        if (Test-Path $newPath) {
            Write-Host "Target exists, skipping: $oldName -> $newName" -ForegroundColor Yellow
        } else {
            Write-Host "Renaming: $oldName -> $newName" -ForegroundColor Cyan
            Move-Item $oldPath $newPath
        }
    } else {
        Write-Host "Source not found: $oldName" -ForegroundColor Yellow
    }
}

Write-Host "`n=== CLEANUP COMPLETE ===" -ForegroundColor Green
Write-Host "Next step: Update include statements in 00_Main_MasterIncludes.mqh" -ForegroundColor Cyan
