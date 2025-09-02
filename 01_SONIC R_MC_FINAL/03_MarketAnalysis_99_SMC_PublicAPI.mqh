//+------------------------------------------------------------------+
//|                              03_MarketAnalysis_99_SMC_PublicAPI.mqh |
//|                  Public API facade for SMC data to UI/Overlays      |
//+------------------------------------------------------------------+
#ifndef SMC_PUBLIC_API_MQH
#define SMC_PUBLIC_API_MQH
#property strict

// Signal availability so UI stubs are skipped
#define SMC_PUBLIC_API_AVAILABLE 1

// Minimal SMC data structures for UI consumption
struct SOrderBlockData { double high; double low; datetime time; bool isBullish; double strength; };
struct SLiquidityData { double price; datetime time; bool isBuyLiquidity; bool isSwept; double volume; };
struct SStructureData { double price; datetime time; bool isBOS; bool isBullish; };
struct SFVGData { double high; double low; datetime time; bool isBullish; double fillPercentage; };

// Public API functions (temporary basic implementations)
bool HasNewOrderBlock(){ return false; }
SOrderBlockData GetLatestOrderBlock(){ SOrderBlockData r; r.high=0; r.low=0; r.time=0; r.isBullish=false; r.strength=0; return r; }

bool HasNewLiquidityLevel(){ return false; }
SLiquidityData GetLatestLiquidity(){ SLiquidityData r; r.price=0; r.time=0; r.isBuyLiquidity=false; r.isSwept=false; r.volume=0; return r; }

bool HasNewStructureBreak(){ return false; }
SStructureData GetLatestStructure(){ SStructureData r; r.price=0; r.time=0; r.isBOS=false; r.isBullish=false; return r; }

bool HasNewFVG(){ return false; }
SFVGData GetLatestFVG(){ SFVGData r; r.high=0; r.low=0; r.time=0; r.isBullish=false; r.fillPercentage=0; return r; }

#endif // SMC_PUBLIC_API_MQH 