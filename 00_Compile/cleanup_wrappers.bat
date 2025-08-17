@echo off
echo Cleaning up wrapper files...
cd "..\01_SONIC R_MC_FINAL"

del "01_Core_05_ErrorConstants.mqh" 2>nul
del "01_Core_06_GlobalDeclarations.mqh" 2>nul
del "01_Core_11_EnumHelpers.mqh" 2>nul
del "01_Core_12_SonicEnums.mqh" 2>nul
del "01_Core_13_AdvancedLogger.mqh" 2>nul
del "01_Core_16_EnumHelpers.mqh" 2>nul  
del "01_Core_19_SecurityHardening.mqh" 2>nul
del "01_Core_20_TradeGate.mqh" 2>nul
del "04_SignalGeneration_07_ScenarioPerformance.mqh" 2>nul
del "06_RiskManagement_06_MonteCarlo.mqh" 2>nul

echo Wrapper files cleaned up!
cd ..
