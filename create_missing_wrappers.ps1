# Create missing wrapper files according to Boss's consolidation

# Create 01_Core_11_GlobalDeclarations.mqh -> 01_Core_06_GlobalDeclarations.mqh
$content = @"
//+------------------------------------------------------------------+
//|                        01_Core_11_GlobalDeclarations.mqh        |
//|                    Wrapper -> 01_Core_06_GlobalDeclarations.mqh |
//+------------------------------------------------------------------+
#ifndef CORE_11_GLOBAL_DECLARATIONS_MQH
#define CORE_11_GLOBAL_DECLARATIONS_MQH
#include "01_Core_06_GlobalDeclarations.mqh"
#endif // CORE_11_GLOBAL_DECLARATIONS_MQH
"@
Set-Content "01_SONIC R_MC_FINAL\01_Core_11_GlobalDeclarations.mqh" $content

# Create 01_Core_15_SecurityHardening.mqh -> 01_Core_19_SecurityHardening.mqh
$content = @"
//+------------------------------------------------------------------+
//|                        01_Core_15_SecurityHardening.mqh         |
//|                    Wrapper -> 01_Core_19_SecurityHardening.mqh  |
//+------------------------------------------------------------------+
#ifndef CORE_15_SECURITY_HARDENING_MQH
#define CORE_15_SECURITY_HARDENING_MQH
#include "01_Core_19_SecurityHardening.mqh"
#endif // CORE_15_SECURITY_HARDENING_MQH
"@
Set-Content "01_SONIC R_MC_FINAL\01_Core_15_SecurityHardening.mqh" $content

# Create 01_Core_21_TradeGate.mqh -> 05_Trading_03_TradeGate.mqh
$content = @"
//+------------------------------------------------------------------+
//|                           01_Core_21_TradeGate.mqh              |
//|                    Wrapper -> 05_Trading_03_TradeGate.mqh       |
//+------------------------------------------------------------------+
#ifndef CORE_21_TRADE_GATE_MQH
#define CORE_21_TRADE_GATE_MQH
#include "05_Trading_03_TradeGate.mqh"
#endif // CORE_21_TRADE_GATE_MQH
"@
Set-Content "01_SONIC R_MC_FINAL\01_Core_21_TradeGate.mqh" $content

# Create 01_Core_07_AdvancedLogger.mqh -> 01_Core_13_AdvancedLogger.mqh
$content = @"
//+------------------------------------------------------------------+
//|                        01_Core_07_AdvancedLogger.mqh            |
//|                    Wrapper -> 01_Core_13_AdvancedLogger.mqh     |
//+------------------------------------------------------------------+
#ifndef CORE_07_ADVANCED_LOGGER_MQH
#define CORE_07_ADVANCED_LOGGER_MQH
#include "01_Core_13_AdvancedLogger.mqh"
#endif // CORE_07_ADVANCED_LOGGER_MQH
"@
Set-Content "01_SONIC R_MC_FINAL\01_Core_07_AdvancedLogger.mqh" $content

# Create 02_DataProviders_02_SymbolInfo_Legacy.mqh -> 02_DataProviders_01_SymbolInfo_Primary.mqh
$content = @"
//+------------------------------------------------------------------+
//|                   02_DataProviders_02_SymbolInfo_Legacy.mqh     |
//|            Wrapper -> 02_DataProviders_01_SymbolInfo_Primary.mqh|
//+------------------------------------------------------------------+
#ifndef DATAPROVIDERS_02_SYMBOLINFO_LEGACY_MQH
#define DATAPROVIDERS_02_SYMBOLINFO_LEGACY_MQH
#include "02_DataProviders_01_SymbolInfo_Primary.mqh"
#endif // DATAPROVIDERS_02_SYMBOLINFO_LEGACY_MQH
"@
Set-Content "01_SONIC R_MC_FINAL\02_DataProviders_02_SymbolInfo_Legacy.mqh" $content

Write-Host "Missing wrapper files created successfully!"
