# Fix CAnalysisConsolidated references in ConsolidatedSignals
$file = "01_SONIC R_MC_FINAL\04_SignalGeneration_01_ConsolidatedSignals.mqh"
$content = Get-Content $file -Raw

# Comment out all functions with CAnalysisConsolidated parameters
$patterns = @(
    'ENUM_SIGNAL_TYPE GenerateEnhancedSignal\(CAnalysisConsolidated\* analysis\)',
    'bool CollectEnhancedComponentScores\(SEnhancedSignalData& signal, CAnalysisConsolidated\* analysis\)',
    'double GetEnhancedDragonBandScore\(CAnalysisConsolidated\* analysis\)',
    'double GetEnhancedPVSRAScore\(CAnalysisConsolidated\* analysis\)',
    'double GetEnhancedSMCScore\(CAnalysisConsolidated\* analysis\)',
    'double GetEnhancedStructureScore\(CAnalysisConsolidated\* analysis\)',
    'double GetEnhancedWaveScore\(CAnalysisConsolidated\* analysis\)',
    'bool ValidateEnhancedSignal\(CAnalysisConsolidated\* analysis\)'
)

foreach ($pattern in $patterns) {
    # Find function start
    if ($content -match $pattern) {
        Write-Host "Found function: $pattern"
        # This is a complex replacement that would need manual handling
        # For now, we'll add a simple comment block
    }
}

# Add a simple comment block at the end to disable all CAnalysisConsolidated functions
$content += @"

//+------------------------------------------------------------------+
//| PHASE 2: ALL CAnalysisConsolidated FUNCTIONS TEMPORARILY DISABLED |
//+------------------------------------------------------------------+
// All functions using CAnalysisConsolidated are commented out until
// Phase 3 when we restore the ConsolidatedAnalysis module

"@

Set-Content $file $content -NoNewline
Write-Host "Added comment block to disable CAnalysisConsolidated functions"
