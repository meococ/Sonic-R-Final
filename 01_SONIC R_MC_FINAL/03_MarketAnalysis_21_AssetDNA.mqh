//+------------------------------------------------------------------+
//|                                                Asset_DNA_System.mqh |
//|                    SONIC R MC EA - Asset DNA Engine               |
//|                     Giai Ðo?n 3 - Advanced Market Intelligence    |
//+------------------------------------------------------------------+
#ifndef ASSET_DNA_SYSTEM_MQH
#define ASSET_DNA_SYSTEM_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_02_ConfigManager.mqh"
#include "01_Core_08_ContextManager.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"

//+------------------------------------------------------------------+
//| PHASE 1 FEATURE TOGGLES - Asset Classification System          |
//+------------------------------------------------------------------+
#ifndef ENABLE_ASSET_CLASSIFICATION
#define ENABLE_ASSET_CLASSIFICATION     true
#endif

#ifndef ENABLE_MULTI_ASSET_RISK
#define ENABLE_MULTI_ASSET_RISK         true
#endif

#ifndef ENABLE_ASSET_SPECIFIC_PARAMS
#define ENABLE_ASSET_SPECIFIC_PARAMS    true
#endif

#ifndef ENABLE_ASSET_CORRELATION
#define ENABLE_ASSET_CORRELATION        false  // Phase 3 feature
#endif

//+------------------------------------------------------------------+
//| Enhanced Asset DNA for SONIC R MC - Giai Ðo?n 3                |
//+------------------------------------------------------------------+
class CAssetDNASystem
{
private:
CEaContext*             m_context;
string                  m_symbol;
ENUM_TIMEFRAMES         m_timeframe;

// PHASE 1: Asset Classification
ENUM_ASSET_TYPE         m_assetType;

// Asset characteristics
struct AssetProfile {
// Existing fields
double              averageATR;
double              volatilityScore;
double              trendScore;
double              momentumScore;
double              liquidityScore;
bool                isStrongTrending;
bool                isMeanReverting;
bool                isHighVolatility;
double              optimalRiskPercent;
double              optimalSLMultiplier;
double              optimalTPMultiplier;
string              bestSession;
datetime            lastUpdate;

// PHASE 1: Asset Classification fields
ENUM_ASSET_TYPE     assetType;
double              assetRiskMultiplier;    // Risk multiplier based on asset type
double              assetVolatilityBase;    // Base volatility for this asset type
double              assetLiquidityFactor;   // Liquidity factor for this asset type
bool                isAssetClassified;      // Classification status
string              assetCategory;          // Human readable category

// PHASE 2: Market Regime Integration
ENUM_MARKET_REGIME  currentRegime;
ENUM_MARKET_REGIME  previousRegime;
double              regimeConfidence;
datetime            regimeChangeTime;
double              assetRegimeMultiplier;  // Combined asset + regime multiplier
bool                regimeDetectionEnabled;

void Reset()
{
assetType = ASSET_UNKNOWN;
assetRiskMultiplier = 1.0;
assetVolatilityBase = 1.0;
assetLiquidityFactor = 1.0;
isAssetClassified = false;
assetCategory = "Unknown";

// Phase 2 additions
currentRegime = REGIME_UNKNOWN;
previousRegime = REGIME_UNKNOWN;
regimeConfidence = 0.0;
regimeChangeTime = 0;
assetRegimeMultiplier = 1.0;
regimeDetectionEnabled = false;
}
} m_assetProfile;

//+------------------------------------------------------------------+
//| Asset-Regime Combination Profile - Phase 2 Enhancement          |
//+------------------------------------------------------------------+
struct AssetRegimeProfile {
ENUM_ASSET_TYPE     assetType;
ENUM_MARKET_REGIME  marketRegime;
double              combinedRiskMultiplier;  // Asset + Regime combined risk
double              volatilityAdjustment;    // Volatility adjustment factor
double              liquidityAdjustment;     // Liquidity adjustment factor
double              confidenceLevel;         // Confidence in classification
bool                isOptimal;               // Whether this combination is optimal
datetime            lastUpdate;

void CalculateCombinedMultiplier(double assetMultiplier, double regimeMultiplier)
{
// Weighted combination of asset and regime factors
combinedRiskMultiplier = (assetMultiplier * 0.6) + (regimeMultiplier * 0.4);

// Apply bounds
combinedRiskMultiplier = MathMax(0.3, MathMin(1.5, combinedRiskMultiplier));
lastUpdate = TimeCurrent();
}

void Reset()
{
assetType = ASSET_UNKNOWN;
marketRegime = REGIME_UNKNOWN;
combinedRiskMultiplier = 1.0;
volatilityAdjustment = 1.0;
liquidityAdjustment = 1.0;
confidenceLevel = 0.0;
isOptimal = false;
lastUpdate = 0;
}
} m_assetRegimeProfile;

// Strategy performance tracking
struct StrategyDNA {
ENUM_SIGNAL_TYPE    strategy;
int                 totalTrades;
int                 winningTrades;
double              avgWinRate;
double              profitFactor;
double              expectancy;
double              sharpeRatio;
double              maxDrawdown;
double              reliability;
datetime            lastUpdate;
} m_strategyPerformance[10]; // Support up to 10 strategies

int                     m_strategyCount;
bool                    m_initialized;

// Analysis methods
void                    AnalyzeAssetCharacteristics() {
// Calculate ATR for volatility - FIXED
int atrHandle = iATR(m_symbol, m_timeframe, 14);
if(atrHandle == INVALID_HANDLE) return;

double atrBuffer[1];
if(CopyBuffer(atrHandle, 0, 1, 1, atrBuffer) <= 0) return;
double atr = atrBuffer[0];
m_assetProfile.averageATR = atr;

// PRODUCTION FIX: Rename to avoid global variable hiding
double localCurrentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
// Calculate volatility score (0-1 scale)
double atrPercent = (atr / localCurrentPrice) * 100.0;
m_assetProfile.volatilityScore = MathMin(1.0, atrPercent / 2.0); // Scale to 0-1

// Determine volatility classification
m_assetProfile.isHighVolatility = (atrPercent > 1.5);

// Calculate trend score using EMAs - SONIC R FIX: Updated to EMA 34,89,200
// ?? PHASE FINAL: Complete migration to unified system
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

if(manager == NULL) {
::Print("[PHASE FINAL] Asset_DNA_System: Unified manager not available");
return;
}

// EMA20 and EMA50 removed - keep only EMA34, EMA89, EMA200
// NEW CODE (UNIFIED SYSTEM):
int ema34Handle = manager.GetOptimizedEMAHandle(m_symbol, m_timeframe, 34, PRICE_CLOSE);
int ema89Handle = manager.GetOptimizedEMAHandle(m_symbol, m_timeframe, 89, PRICE_CLOSE);
int ema200Handle = manager.GetOptimizedEMAHandle(m_symbol, m_timeframe, 200, PRICE_CLOSE);

// Log migration success - EMA20 and EMA50 removed
manager.MigrateLegacyIndicatorCalls(
"Asset_DNA_System.mqh",
240,
"Asset DNA EMA20/50 removed - keep 34/89/200",
"EMA20 and EMA50 eliminated from system"
);

if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE || ema200Handle == INVALID_HANDLE) {
::Print("[PHASE FINAL] Failed to create unified EMA handles for Asset DNA");
return;
}

if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE || ema200Handle == INVALID_HANDLE) return;

double ema34Buffer[1], ema89Buffer[1], ema200Buffer[1];
if(CopyBuffer(ema34Handle, 0, 1, 1, ema34Buffer) <= 0) return;
if(CopyBuffer(ema89Handle, 0, 1, 1, ema89Buffer) <= 0) return;
if(CopyBuffer(ema200Handle, 0, 1, 1, ema200Buffer) <= 0) return;

double ema34 = ema34Buffer[0];
double ema89 = ema89Buffer[0];
double ema200 = ema200Buffer[0];

// Trend score calculation (EMA20 and EMA50 removed)
if(ema34 > ema89 && ema89 > ema200) 
m_assetProfile.trendScore = 1.0; // Strong uptrend
else if(ema34 < ema89 && ema89 < ema200) 
m_assetProfile.trendScore = 0.0; // Strong downtrend
else 
m_assetProfile.trendScore = 0.5; // Sideways/weak trend

m_assetProfile.isStrongTrending = (m_assetProfile.trendScore <= 0.2 || m_assetProfile.trendScore >= 0.8);

// Calculate momentum score using RSI - FIXED
int rsiHandle = iRSI(m_symbol, m_timeframe, 14, PRICE_CLOSE);
if(rsiHandle == INVALID_HANDLE) return;

double rsiBuffer[1];
if(CopyBuffer(rsiHandle, 0, 1, 1, rsiBuffer) <= 0) return;
double rsi = rsiBuffer[0];

// Momentum score (distance from 50)
m_assetProfile.momentumScore = MathAbs(rsi - 50.0) / 50.0;

// Simple liquidity score based on symbol type
if(StringFind(m_symbol, "XAU") >= 0 || StringFind(m_symbol, "GOLD") >= 0)
m_assetProfile.liquidityScore = 0.8; // Gold - high liquidity
else if(StringFind(m_symbol, "USD") >= 0 || StringFind(m_symbol, "EUR") >= 0)
m_assetProfile.liquidityScore = 0.9; // Major pairs - very high liquidity
else
m_assetProfile.liquidityScore = 0.6; // Other symbols - medium liquidity

// Calculate optimal trading parameters based on asset characteristics
CalculateOptimalParameters();

// Determine best trading session
DetermineBestSession();

m_assetProfile.lastUpdate = TimeCurrent();
};
void                    UpdateStrategyPerformance();
double                  CalculateVolatilityScore();
double                  CalculateTrendScore();
double                  CalculateMomentumScore();
double                  CalculateLiquidityScore();

// PHASE 1: Asset Classification methods
ENUM_ASSET_TYPE         ClassifyAssetType()
{
if(!ENABLE_ASSET_CLASSIFICATION) return ASSET_UNKNOWN;

string symbol = m_symbol;  // Copy the symbol
StringToUpper(symbol);     // Convert to uppercase in-place - StringToUpper returns int, not string

// FOREX Classification
if(StringLen(symbol) == 6 && 
(StringFind(symbol, "USD") >= 0 || StringFind(symbol, "EUR") >= 0 || 
StringFind(symbol, "GBP") >= 0 || StringFind(symbol, "JPY") >= 0 ||
StringFind(symbol, "CHF") >= 0 || StringFind(symbol, "CAD") >= 0 ||
StringFind(symbol, "AUD") >= 0 || StringFind(symbol, "NZD") >= 0))
{
return ASSET_FOREX;
}

// COMMODITY Classification
if(StringFind(symbol, "XAU") >= 0 || StringFind(symbol, "GOLD") >= 0 ||
StringFind(symbol, "XAG") >= 0 || StringFind(symbol, "SILVER") >= 0 ||
StringFind(symbol, "OIL") >= 0 || StringFind(symbol, "WTI") >= 0 ||
StringFind(symbol, "BRENT") >= 0 || StringFind(symbol, "XTIUSD") >= 0 ||
StringFind(symbol, "XBRUSD") >= 0)
{
return ASSET_COMMODITY;
}

// CRYPTO Classification
if(StringFind(symbol, "BTC") >= 0 || StringFind(symbol, "ETH") >= 0 ||
StringFind(symbol, "LTC") >= 0 || StringFind(symbol, "XRP") >= 0 ||
StringFind(symbol, "ADA") >= 0 || StringFind(symbol, "DOT") >= 0 ||
StringFind(symbol, "CRYPTO") >= 0)
{
return ASSET_CRYPTO;
}

// INDEX Classification
if(StringFind(symbol, "SPX") >= 0 || StringFind(symbol, "SP500") >= 0 ||
StringFind(symbol, "NAS") >= 0 || StringFind(symbol, "DAX") >= 0 ||
StringFind(symbol, "FTSE") >= 0 || StringFind(symbol, "NIKKEI") >= 0 ||
StringFind(symbol, "DJI") >= 0 || StringFind(symbol, "INDEX") >= 0)
{
return ASSET_INDEX;
}

return ASSET_UNKNOWN;
}
void                    SetAssetSpecificParameters()
{
if(!ENABLE_ASSET_SPECIFIC_PARAMS) return;

m_assetProfile.assetType = ClassifyAssetType();
m_assetProfile.assetRiskMultiplier = GetAssetRiskMultiplier(m_assetProfile.assetType);
m_assetProfile.assetVolatilityBase = GetAssetVolatilityBase(m_assetProfile.assetType);
m_assetProfile.assetLiquidityFactor = GetAssetLiquidityFactor(m_assetProfile.assetType);

// Set human readable category
switch(m_assetProfile.assetType)
{
case ASSET_FOREX:
m_assetProfile.assetCategory = "Foreign Exchange";
break;
case ASSET_COMMODITY:
m_assetProfile.assetCategory = "Commodity";
break;
case ASSET_CRYPTO:
m_assetProfile.assetCategory = "Cryptocurrency";
break;
case ASSET_INDEX:
m_assetProfile.assetCategory = "Stock Index";
break;
default:
m_assetProfile.assetCategory = "Unknown Asset";
break;
}

m_assetProfile.isAssetClassified = (m_assetProfile.assetType != ASSET_UNKNOWN);

// Log classification result
if(m_context)
{
    string isClassifiedStr = m_assetProfile.isAssetClassified ? "true" : "false";
    ::Print("PHASE 1: Asset " + m_symbol + " classified as " + m_assetProfile.assetCategory +
        " (Risk Multiplier: " + DoubleToString(m_assetProfile.assetRiskMultiplier, 2) + ")" +
        " | isClassified: " + isClassifiedStr);
}
}
double                  GetAssetRiskMultiplier(ENUM_ASSET_TYPE assetType)
{
switch(assetType)
{
case ASSET_FOREX:
return 1.0;     // Base risk for FOREX
case ASSET_COMMODITY:
return 0.8;     // Lower risk for commodities (more volatile)
case ASSET_CRYPTO:
return 0.5;     // Much lower risk for crypto (extremely volatile)
case ASSET_INDEX:
return 1.2;     // Slightly higher risk for indices (more stable)
default:
return 1.0;     // Default risk
}
}
double                  GetAssetVolatilityBase(ENUM_ASSET_TYPE assetType)
{
switch(assetType)
{
case ASSET_FOREX:
return 0.5;     // Medium volatility base
case ASSET_COMMODITY:
return 0.7;     // Higher volatility base
case ASSET_CRYPTO:
return 0.9;     // Very high volatility base
case ASSET_INDEX:
return 0.4;     // Lower volatility base
default:
return 0.5;     // Default volatility
}
}
double                  GetAssetLiquidityFactor(ENUM_ASSET_TYPE assetType)
{
switch(assetType)
{
case ASSET_FOREX:
return 1.0;     // High liquidity
case ASSET_COMMODITY:
return 0.8;     // Good liquidity
case ASSET_CRYPTO:
return 0.6;     // Variable liquidity
case ASSET_INDEX:
return 0.9;     // Good liquidity
default:
return 0.7;     // Default liquidity
}
}

// PHASE 2: Market Regime methods
void                    DetectMarketRegime()
{
	// Simple heuristic using volatility and trend to set regime
	double vol = m_assetProfile.volatilityScore;
	double trend = m_assetProfile.trendScore;
	ENUM_MARKET_REGIME detected = REGIME_RANGING;
	if(vol >= 0.6 && trend >= 0.5) detected = REGIME_VOLATILE_TRENDING;
	else if(vol >= 0.6 && trend < 0.5) detected = REGIME_VOLATILE_RANGING;
	else if(vol < 0.6 && trend >= 0.5) detected = REGIME_STABLE_TRENDING;
	else detected = REGIME_STABLE_RANGING;
	
	if(!ValidateRegimeTransition(m_assetProfile.currentRegime, detected))
		return;
	
	m_assetProfile.previousRegime = m_assetProfile.currentRegime;
	m_assetProfile.currentRegime = detected;
	m_assetProfile.regimeConfidence = 0.7;
	m_assetProfile.regimeChangeTime = TimeCurrent();
}

double                  GetRegimeRiskMultiplier(ENUM_MARKET_REGIME regime)
{
	switch(regime)
	{
		case REGIME_VOLATILE_TRENDING:   return 0.8; // reduce size in volatile trend
		case REGIME_VOLATILE_RANGING:    return 0.7; // reduce more in volatile range
		case REGIME_STABLE_TRENDING:     return 1.1; // can scale slightly
		case REGIME_STABLE_RANGING:      return 1.0;
		default:                         return 1.0;
	}
}

void                    UpdateAssetRegimeCombination()
{
	double assetMult = m_assetProfile.assetRiskMultiplier;
	double regimeMult = GetRegimeRiskMultiplier(m_assetProfile.currentRegime);
	m_assetProfile.assetRegimeMultiplier = assetMult * regimeMult;
}

bool                    ValidateRegimeTransition(ENUM_MARKET_REGIME fromRegime, ENUM_MARKET_REGIME toRegime)
{
	if(fromRegime == toRegime) return false; // no change
	return true; // allow simple transitions; refine later
}

// Initialize Strategies - NEW METHOD
void                    InitializeStrategies()
{
    // Minimal safe initialization of strategy DNA array
    m_strategyCount = 0;
    const int maxStrategies = ArraySize(m_strategyPerformance);
    for(int i=0;i<maxStrategies;i++){
        m_strategyPerformance[i].strategy = SIGNAL_NONE;
        m_strategyPerformance[i].totalTrades = 0;
        m_strategyPerformance[i].winningTrades = 0;
        m_strategyPerformance[i].avgWinRate = 0.0;
        m_strategyPerformance[i].profitFactor = 0.0;
        m_strategyPerformance[i].expectancy = 0.0;
        m_strategyPerformance[i].sharpeRatio = 0.0;
        m_strategyPerformance[i].maxDrawdown = 0.0;
        m_strategyPerformance[i].reliability = 0.0;
        m_strategyPerformance[i].lastUpdate = 0;
    }
}

// Phase 3 Enhanced Methods
void                    CalculateOptimalParameters()
{
// Base values
double baseRisk = 1.0; // 1% base risk
double baseSL = 2.0;   // 2x ATR base SL
double baseTP = 3.0;   // 3x ATR base TP

// Adjust based on volatility
if(m_assetProfile.isHighVolatility)
{
// High volatility = wider stops, smaller positions
m_assetProfile.optimalRiskPercent = baseRisk * 0.7;
m_assetProfile.optimalSLMultiplier = baseSL * 1.5;
m_assetProfile.optimalTPMultiplier = baseTP * 1.5;
}
else if(m_assetProfile.volatilityScore < 0.3)
{
// Low volatility = tighter stops, larger positions
m_assetProfile.optimalRiskPercent = baseRisk * 1.2;
m_assetProfile.optimalSLMultiplier = baseSL * 0.8;
m_assetProfile.optimalTPMultiplier = baseTP * 0.8;
}
else
{
// Normal volatility
m_assetProfile.optimalRiskPercent = baseRisk;
m_assetProfile.optimalSLMultiplier = baseSL;
m_assetProfile.optimalTPMultiplier = baseTP;
}

// Adjust based on trend strength
if(m_assetProfile.isStrongTrending)
{
// Strong trend = let profits run
m_assetProfile.optimalTPMultiplier *= 1.3;
}
else if(m_assetProfile.isMeanReverting)
{
// Mean reverting = take profits quicker
m_assetProfile.optimalTPMultiplier *= 0.7;
m_assetProfile.optimalSLMultiplier *= 0.8;
}

// Liquidity adjustment
m_assetProfile.optimalRiskPercent *= m_assetProfile.liquidityScore;
}
void                    DetermineBestSession()
{
// Default session based on symbol
if(StringFind(m_symbol, "XAU") >= 0 || StringFind(m_symbol, "GOLD") >= 0)
{
// Gold trades best in London/NY overlap
m_assetProfile.bestSession = "LONDON_NY";
}
else if(StringFind(m_symbol, "JPY") >= 0)
{
// JPY pairs best in Asian session
m_assetProfile.bestSession = "ASIAN";
}
else if(StringFind(m_symbol, "EUR") >= 0 || StringFind(m_symbol, "GBP") >= 0)
{
// European pairs best in London
m_assetProfile.bestSession = "LONDON";
}
else if(StringFind(m_symbol, "USD") >= 0)
{
// USD pairs best in NY session
m_assetProfile.bestSession = "NEWYORK";
}
else
{
// Default to London session
m_assetProfile.bestSession = "LONDON";
}
}

public:
CAssetDNASystem() {
m_context = NULL;
m_symbol = "";
m_timeframe = PERIOD_CURRENT;
m_strategyCount = 0;
m_initialized = false;
m_assetType = ASSET_UNKNOWN;

// Initialize asset profile
m_assetProfile.averageATR = 0.0;
m_assetProfile.volatilityScore = 0.0;
m_assetProfile.trendScore = 0.0;
m_assetProfile.momentumScore = 0.0;
m_assetProfile.liquidityScore = 0.0;
m_assetProfile.isStrongTrending = false;
m_assetProfile.isMeanReverting = false;
m_assetProfile.isHighVolatility = false;
m_assetProfile.lastUpdate = 0;

// PHASE 1: Initialize asset classification fields
m_assetProfile.assetType = ASSET_UNKNOWN;
m_assetProfile.assetRiskMultiplier = 1.0;
m_assetProfile.assetVolatilityBase = 0.0;
m_assetProfile.assetLiquidityFactor = 1.0;
m_assetProfile.isAssetClassified = false;
m_assetProfile.assetCategory = "Unknown";

// PHASE 2: Initialize market regime fields
m_assetProfile.currentRegime = REGIME_UNKNOWN;
m_assetProfile.previousRegime = REGIME_UNKNOWN;
m_assetProfile.regimeConfidence = 0.0;
m_assetProfile.regimeChangeTime = 0;
m_assetProfile.assetRegimeMultiplier = 1.0;
m_assetProfile.regimeDetectionEnabled = false;

// Initialize asset-regime profile
m_assetRegimeProfile.Reset();

// Initialize strategy performance array
for(int i = 0; i < 10; i++)
{
m_strategyPerformance[i].strategy = SIGNAL_NONE;
m_strategyPerformance[i].totalTrades = 0;
m_strategyPerformance[i].winningTrades = 0;
m_strategyPerformance[i].avgWinRate = 0.0;
m_strategyPerformance[i].profitFactor = 0.0;
m_strategyPerformance[i].expectancy = 0.0;
m_strategyPerformance[i].sharpeRatio = 0.0;
m_strategyPerformance[i].maxDrawdown = 0.0;
m_strategyPerformance[i].reliability = 0.0;
m_strategyPerformance[i].lastUpdate = 0;
}
};
~CAssetDNASystem() {
Deinitialize();
};

// Core methods
bool                    Initialize(CEaContext* context) {
if(!context) return false;

m_context = context;
m_symbol = _Symbol;  // Use global symbol
m_timeframe = PERIOD_CURRENT;  // Use current timeframe
m_strategyCount = 0;

// Initialize strategy performance tracking for common signals
InitializeStrategies();

// PHASE 1: Set asset-specific parameters
SetAssetSpecificParameters();

// PHASE 2: Initialize market regime detection
m_assetProfile.regimeDetectionEnabled = true;
DetectMarketRegime();

// Perform initial asset analysis
AnalyzeAssetCharacteristics();

m_initialized = true;

// FIXED: Simplified logging without template syntax
if(m_context)
{
    ::Print("Asset DNA System initialized for " + m_symbol);
}

return true;
};
void                    Deinitialize() {
// FIXED: Simplified logging without template syntax
if(m_context)
{
    ::Print("Asset DNA System deinitialized");
}

m_initialized = false;
m_context = NULL;
};
bool                    UpdateAnalysis() {
if(!m_initialized || !m_context) return false;

// Update every hour to avoid overload
static datetime lastUpdate = 0;
if(TimeCurrent() - lastUpdate < 3600) return true;
lastUpdate = TimeCurrent();

AnalyzeAssetCharacteristics();
UpdateStrategyPerformance();

// PHASE 2: Update market regime analysis
if(m_assetProfile.regimeDetectionEnabled)
{
DetectMarketRegime();
UpdateAssetRegimeCombination();
}

return true;
};

// Strategy optimization
ENUM_SIGNAL_TYPE        GetOptimalStrategy()
{
if(!m_initialized) return SIGNAL_NONE;

// Simple strategy selection based on market conditions

// For trending markets
if(m_assetProfile.isStrongTrending)
{
if(m_assetProfile.trendScore > 0.6)
return SIGNAL_BUY; // Uptrend
else if(m_assetProfile.trendScore < 0.4)
return SIGNAL_SELL; // Downtrend
}

// For ranging markets with high volatility
if(m_assetProfile.isMeanReverting && m_assetProfile.isHighVolatility)
{
// Use momentum for entry decisions
if(m_assetProfile.momentumScore > 0.7)
return SIGNAL_SELL; // Overbought - sell
else if(m_assetProfile.momentumScore < 0.3)
return SIGNAL_BUY; // Oversold - buy
}

return SIGNAL_NONE;
}
double                  GetStrategyReliability(ENUM_SIGNAL_TYPE strategy)
{
for(int i = 0; i < m_strategyCount; i++)
{
if(m_strategyPerformance[i].strategy == strategy)
return m_strategyPerformance[i].reliability;
}

return 0.5; // Default reliability
}
bool                    IsStrategyRecommended(ENUM_SIGNAL_TYPE strategy)
{
double reliability = GetStrategyReliability(strategy);
return (reliability > 0.6); // Require 60%+ reliability
}

// Asset profiling
double                  GetAssetVolatilityScore() { return m_assetProfile.volatilityScore; }
double                  GetAssetTrendScore() { return m_assetProfile.trendScore; }
bool                    IsHighVolatilityAsset() { return m_assetProfile.isHighVolatility; }
bool                    IsTrendingAsset() { return m_assetProfile.isStrongTrending; }

// PHASE 1: Asset Classification getters
ENUM_ASSET_TYPE         GetAssetType() { return m_assetProfile.assetType; }
double                  GetAssetRiskMultiplier() { return m_assetProfile.assetRiskMultiplier; }
double                  GetAssetVolatilityBase() { return m_assetProfile.assetVolatilityBase; }
double                  GetAssetLiquidityFactor() { return m_assetProfile.assetLiquidityFactor; }
string                  GetAssetCategory() { return m_assetProfile.assetCategory; }
bool                    IsAssetClassified() { return m_assetProfile.isAssetClassified; }

// PHASE 2: Market Regime getters
ENUM_MARKET_REGIME      GetCurrentRegime() { return m_assetProfile.currentRegime; }
ENUM_MARKET_REGIME      GetPreviousRegime() { return m_assetProfile.previousRegime; }
double                  GetRegimeConfidence() { return m_assetProfile.regimeConfidence; }
double                  GetAssetRegimeMultiplier() { return m_assetProfile.assetRegimeMultiplier; }
bool                    IsRegimeDetectionEnabled() { return m_assetProfile.regimeDetectionEnabled; }
datetime                GetRegimeChangeTime() { return m_assetProfile.regimeChangeTime; }

// PHASE 2: Asset-Regime combination methods
void                    UpdateMarketRegime(ENUM_MARKET_REGIME newRegime, double confidence);
double                  GetCombinedRiskMultiplier()
{
	// If not initialized or regime detection is off, fall back to asset multiplier
	if(!m_initialized || !m_assetProfile.regimeDetectionEnabled)
		return MathMax(0.3, MathMin(1.5, m_assetProfile.assetRiskMultiplier));

	// Base multipliers
	double assetMult = m_assetProfile.assetRiskMultiplier;
	double regimeMult = GetRegimeRiskMultiplier(m_assetProfile.currentRegime);

	// Update asset-regime profile using the built-in weighted combiner
	m_assetRegimeProfile.assetType = m_assetProfile.assetType;
	m_assetRegimeProfile.marketRegime = m_assetProfile.currentRegime;
	m_assetRegimeProfile.CalculateCombinedMultiplier(assetMult, regimeMult);

	// Liquidity adjustment (dynamic, 0..1); default to neutral if not set
	double liquidityAdj = (m_assetProfile.liquidityScore > 0.0 ? m_assetProfile.liquidityScore : 1.0);
	m_assetRegimeProfile.liquidityAdjustment = liquidityAdj;

	// Final combined multiplier with clamp for safety
	double combined = m_assetRegimeProfile.combinedRiskMultiplier * liquidityAdj;
	combined = MathMax(0.3, MathMin(1.5, combined));
	return combined;
}
	bool                    IsOptimalAssetRegimeCombination()
	{
		return m_assetRegimeProfile.isOptimal && m_assetRegimeProfile.confidenceLevel > 0.7;
	}
string                  GetRegimeDescription(ENUM_MARKET_REGIME regime)
{
switch(regime)
{
case REGIME_TRENDING_LOW_VOL:
return "Trending Low Volatility";
case REGIME_TRENDING_HIGH_VOL:
return "Trending High Volatility";
case REGIME_RANGING_LOW_VOL:
return "Ranging Low Volatility";
case REGIME_RANGING_HIGH_VOL:
return "Ranging High Volatility";
default:
return "Unknown Regime";
}
}

// Performance metrics
void                    RecordTradeResult(ENUM_SIGNAL_TYPE strategy, bool isWin, double profit)
{
// Find or create strategy record
int strategyIndex = -1;
for(int i = 0; i < m_strategyCount; i++)
{
if(m_strategyPerformance[i].strategy == strategy)
{
strategyIndex = i;
break;
}
}

// Create new strategy record if not found
if(strategyIndex == -1 && m_strategyCount < 10)
{
strategyIndex = m_strategyCount;
m_strategyPerformance[strategyIndex].strategy = strategy;
m_strategyCount++;
}

if(strategyIndex >= 0)
{
// FIXED: Direct array access instead of pointer syntax
m_strategyPerformance[strategyIndex].totalTrades++;

if(isWin)
m_strategyPerformance[strategyIndex].winningTrades++;

// Update running averages (simplified)
m_strategyPerformance[strategyIndex].avgWinRate = (double)m_strategyPerformance[strategyIndex].winningTrades / m_strategyPerformance[strategyIndex].totalTrades * 100.0;
m_strategyPerformance[strategyIndex].lastUpdate = TimeCurrent();
}
}
double                  GetStrategyWinRate(ENUM_SIGNAL_TYPE strategy)
{
for(int i = 0; i < m_strategyCount; i++)
{
if(m_strategyPerformance[i].strategy == strategy)
return m_strategyPerformance[i].avgWinRate;
}

return 0.0;
}
double                  GetStrategyProfitFactor(ENUM_SIGNAL_TYPE strategy)
{
for(int i = 0; i < m_strategyCount; i++)
{
if(m_strategyPerformance[i].strategy == strategy)
return m_strategyPerformance[i].profitFactor;
}

return 1.0; // Default profit factor
}

// Reporting
string                  GenerateAssetReport()
{
string report = "";
report += "=== ASSET DNA ANALYSIS ===\n";
report += "Symbol: " + m_symbol + "\n";

// PHASE 1: Asset Classification Info
if(ENABLE_ASSET_CLASSIFICATION && m_assetProfile.isAssetClassified)
{
report += "Asset Type: " + m_assetProfile.assetCategory + "\n";
report += "Risk Multiplier: " + DoubleToString(m_assetProfile.assetRiskMultiplier, 2) + "\n";
report += "Volatility Base: " + DoubleToString(m_assetProfile.assetVolatilityBase, 2) + "\n";
report += "Liquidity Factor: " + DoubleToString(m_assetProfile.assetLiquidityFactor, 2) + "\n";
report += "---\n";
}

// PHASE 2: Market Regime Info
if(m_assetProfile.regimeDetectionEnabled)
{
report += "Current Regime: " + GetRegimeDescription(m_assetProfile.currentRegime) + "\n";
report += "Regime Confidence: " + DoubleToString(m_assetProfile.regimeConfidence * 100, 1) + "%\n";
report += "Combined Risk Multiplier: " + DoubleToString(GetCombinedRiskMultiplier(), 2) + "\n";
if(m_assetProfile.regimeChangeTime > 0)
{
report += "Last Regime Change: " + TimeToString(m_assetProfile.regimeChangeTime) + "\n";
}
report += "---\n";
}

report += "Volatility Score: " + DoubleToString(m_assetProfile.volatilityScore, 2) + "\n";
report += "Trend Score: " + DoubleToString(m_assetProfile.trendScore, 2) + "\n";
report += "Momentum Score: " + DoubleToString(m_assetProfile.momentumScore, 2) + "\n";
report += "Liquidity Score: " + DoubleToString(m_assetProfile.liquidityScore, 2) + "\n";
report += "Is Trending: " + (m_assetProfile.isStrongTrending ? "YES" : "NO") + "\n";
report += "Is High Volatility: " + (m_assetProfile.isHighVolatility ? "YES" : "NO") + "\n";
report += "========================\n";

return report;
}
string                  GenerateStrategyReport()
{
string report = "";
report += "=== STRATEGY PERFORMANCE ===\n";

for(int i = 0; i < m_strategyCount; i++)
{
// FIXED: Direct array access instead of pointer syntax
report += "Strategy: " + EnumToString(m_strategyPerformance[i].strategy) + "\n";
report += "  Total Trades: " + IntegerToString(m_strategyPerformance[i].totalTrades) + "\n";
report += "  Win Rate: " + DoubleToString(m_strategyPerformance[i].avgWinRate, 1) + "%\n";
report += "  Reliability: " + DoubleToString(m_strategyPerformance[i].reliability, 2) + "\n";
report += "  Recommended: " + (IsStrategyRecommended(m_strategyPerformance[i].strategy) ? "YES" : "NO") + "\n";
report += "---\n";
}

report += "========================\n";
return report;
}
void                    PrintDNAAnalysis()
{
// FIXED: Simplified logging using Print statements
::Print("=== GIAI ÐO?N 3: ASSET DNA ANALYSIS ===");
::Print("Volatility: " + DoubleToString(m_assetProfile.volatilityScore*100, 1) + 
"% | Trend: " + DoubleToString(m_assetProfile.trendScore*100, 1) + 
"% | Momentum: " + DoubleToString(m_assetProfile.momentumScore*100, 1) + "%");

ENUM_SIGNAL_TYPE optimal = GetOptimalStrategy();
if(optimal != SIGNAL_NONE)
{
::Print("Optimal Strategy: " + EnumToString(optimal) + 
" (Reliability: " + DoubleToString(GetStrategyReliability(optimal)*100, 1) + "%)");
}
else
{
::Print("No optimal strategy identified - market analysis pending");
}
}

// Phase 3 Adaptive Parameters
double                  GetAdaptivePositionSize(double baseSize)
{
if(!m_initialized) return baseSize;

double adaptiveSize = baseSize;

// Volatility adjustment
if(m_assetProfile.isHighVolatility)
{
adaptiveSize *= 0.7; // Reduce size by 30% for high volatility
}
else if(m_assetProfile.volatilityScore < 0.3)
{
adaptiveSize *= 1.2; // Increase size by 20% for low volatility
}

// Trend adjustment
if(m_assetProfile.isStrongTrending)
{
adaptiveSize *= 1.1; // Increase size by 10% for strong trends
}

// Liquidity adjustment
adaptiveSize *= m_assetProfile.liquidityScore;

// Session adjustment
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);
bool inBestSession = false;

if(m_assetProfile.bestSession == "ASIAN" && time.hour >= 0 && time.hour <= 8)
inBestSession = true;
else if(m_assetProfile.bestSession == "LONDON" && time.hour >= 8 && time.hour <= 16)
inBestSession = true;
else if(m_assetProfile.bestSession == "NEWYORK" && time.hour >= 13 && time.hour <= 21)
inBestSession = true;
else if(m_assetProfile.bestSession == "LONDON_NY" && time.hour >= 13 && time.hour <= 17)
inBestSession = true;

if(!inBestSession)
{
adaptiveSize *= 0.8; // Reduce size by 20% outside best session
}

return NormalizeDouble(adaptiveSize, 2);
}
double                  GetAdaptiveSLMultiplier() { return m_assetProfile.optimalSLMultiplier; }
double                  GetAdaptiveTPMultiplier() { return m_assetProfile.optimalTPMultiplier; }
double                  GetOptimalRiskPercent() { return m_assetProfile.optimalRiskPercent; }
string                  GetBestTradingSession() { return m_assetProfile.bestSession; }

};

#endif


