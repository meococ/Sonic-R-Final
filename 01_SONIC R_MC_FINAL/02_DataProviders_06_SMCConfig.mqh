//+------------------------------------------------------------------+
//|                                                    SMC_Config.mqh |
//|                        SONIC R MC EA - SMC Configuration         |
//|                     Ð?i Bàng Architecture - SMC Settings         |
//+------------------------------------------------------------------+
#ifndef SMC_CONFIG_MQH
#define SMC_CONFIG_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| SMC Configuration Constants                                      |
//+------------------------------------------------------------------+
#define SMC_MAX_ORDER_BLOCKS      50
#define SMC_MAX_FAIR_VALUE_GAPS   30
#define SMC_MAX_LIQUIDITY_POOLS   20
#define SMC_MIN_ORDER_BLOCK_SIZE  10  // pips
#define SMC_MIN_FVG_SIZE          5   // pips
#define SMC_ORDER_BLOCK_TIMEOUT   86400 // seconds (24 hours)
#define SMC_FVG_TIMEOUT           43200 // seconds (12 hours)

//+------------------------------------------------------------------+
//| SMC Configuration Structure                                      |
//+------------------------------------------------------------------+
struct SMCConfig
{
// Order Block Settings
int         maxOrderBlocks;
int         minOrderBlockSizePips;
int         orderBlockTimeoutSeconds;
bool        enableOrderBlockFilter;

// Fair Value Gap Settings
int         maxFairValueGaps;
int         minFVGSizePips;
int         fvgTimeoutSeconds;
bool        enableFVGFilter;

// Liquidity Pool Settings
int         maxLiquidityPools;
double      minLiquidityStrength;
bool        enableLiquidityFilter;

// General SMC Settings
bool        enableSMCAnalysis;
bool        enableSMCSignals;
double      smcSignalStrength;
int         smcLookbackPeriod;

void Reset()
{
maxOrderBlocks = SMC_MAX_ORDER_BLOCKS;
minOrderBlockSizePips = SMC_MIN_ORDER_BLOCK_SIZE;
orderBlockTimeoutSeconds = SMC_ORDER_BLOCK_TIMEOUT;
enableOrderBlockFilter = true;

maxFairValueGaps = SMC_MAX_FAIR_VALUE_GAPS;
minFVGSizePips = SMC_MIN_FVG_SIZE;
fvgTimeoutSeconds = SMC_FVG_TIMEOUT;
enableFVGFilter = true;

maxLiquidityPools = SMC_MAX_LIQUIDITY_POOLS;
minLiquidityStrength = 0.5;
enableLiquidityFilter = true;

enableSMCAnalysis = true;
enableSMCSignals = true;
smcSignalStrength = 0.7;
smcLookbackPeriod = 100;
}
};

//+------------------------------------------------------------------+
//| Global SMC Configuration                                         |
//+------------------------------------------------------------------+
SMCConfig g_smcConfig;

//+------------------------------------------------------------------+
//| SMC Configuration Functions                                      |
//+------------------------------------------------------------------+
void InitializeSMCConfig()
{
g_smcConfig.Reset();
}

SMCConfig GetSMCConfig()
{
return g_smcConfig;
}

void SetSMCConfig(const SMCConfig& config)
{
g_smcConfig = config;
}

bool ValidateSMCConfig(const SMCConfig& config)
{
if(config.maxOrderBlocks <= 0 || config.maxOrderBlocks > 100)
return false;

if(config.maxFairValueGaps <= 0 || config.maxFairValueGaps > 100)
return false;

if(config.minOrderBlockSizePips <= 0)
return false;

if(config.minFVGSizePips <= 0)
return false;

return true;
}

#endif // SMC_CONFIG_MQH


