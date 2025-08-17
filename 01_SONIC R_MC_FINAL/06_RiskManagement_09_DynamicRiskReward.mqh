//+------------------------------------------------------------------+
//|                                  Risk_DynamicRiskReward.mqh     |
//|                SONIC R MC - DYNAMIC RISK-REWARD ADAPTATION       |
//|                   ?? QUY?T Ð?NH S? 6: RISK-REWARD BREAKTHROUGH   |
//+------------------------------------------------------------------+

#ifndef RISK_DYNAMIC_RISK_REWARD_MQH
#define RISK_DYNAMIC_RISK_REWARD_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| Risk-Reward Optimization Data                                   |
//+------------------------------------------------------------------+
struct RiskRewardOptimizationData
{
// Base R:R calculations
double baseRiskReward;         // Base R:R ratio
double dynamicRiskReward;      // Dynamically adjusted R:R
double optimalRiskReward;      // Optimal R:R for current conditions

// Market condition adjustments
double volatilityAdjustment;   // Volatility-based adjustment
double trendAdjustment;        // Trend strength adjustment
double liquidityAdjustment;    // Liquidity-based adjustment
double sessionAdjustment;      // Trading session adjustment

// Signal quality adjustments
double signalQualityMultiplier; // Signal quality multiplier
double confluenceMultiplier;    // Confluence strength multiplier
double timeframeMultiplier;     // Multi-timeframe multiplier

// Performance-based adjustments
double recentPerformanceAdj;    // Recent performance adjustment
double winRateAdjustment;       // Win rate based adjustment
double profitFactorAdj;         // Profit factor adjustment

// Risk management constraints
double minAllowedRR;            // Minimum allowed R:R
double maxAllowedRR;            // Maximum allowed R:R
double riskConstraint;          // Risk constraint factor

void Reset()
{
baseRiskReward = 2.0;
dynamicRiskReward = 2.0;
optimalRiskReward = 2.0;
volatilityAdjustment = 1.0;
trendAdjustment = 1.0;
liquidityAdjustment = 1.0;
sessionAdjustment = 1.0;
signalQualityMultiplier = 1.0;
confluenceMultiplier = 1.0;
timeframeMultiplier = 1.0;
recentPerformanceAdj = 1.0;
winRateAdjustment = 1.0;
profitFactorAdj = 1.0;
minAllowedRR = 1.2;
maxAllowedRR = 3.5;
riskConstraint = 1.0;
}
};

//+------------------------------------------------------------------+
//| Market Condition Analysis for R:R Optimization                 |
//+------------------------------------------------------------------+
struct MarketConditionRR
{
ENUM_MARKET_REGIME currentRegime;
double volatilityLevel;        // Current volatility (0-2+)
double trendStrength;          // Trend strength (0-1)
double liquidityHealth;        // Liquidity quality (0-1)
ENUM_TRADING_SESSION currentSession;
double sessionVolatility;      // Session-specific volatility
double marketNoise;            // Market noise level
double breakoutPotential;      // Breakout potential assessment

void Update()
{
// Update market condition data
currentRegime = REGIME_UNKNOWN; // Will be updated by calling code
volatilityLevel = 1.0;
trendStrength = 0.5;
liquidityHealth = 0.8;
currentSession = SESSION_LONDON; // Default
sessionVolatility = 1.0;
marketNoise = 0.5;
breakoutPotential = 0.5;
}
};

//+------------------------------------------------------------------+
//| ?? DYNAMIC RISK-REWARD OPTIMIZATION SYSTEM                      |
//+------------------------------------------------------------------+
class CDynamicRiskRewardOptimizer
{
private:
RiskRewardOptimizationData m_rrData;
MarketConditionRR m_marketCondition;

// Historical R:R performance tracking
double m_rrPerformanceHistory[100];   // Historical R:R performance
int m_performanceIndex;
int m_performanceCount;

// Volatility analysis
double m_atrHistory[30];              // ATR history for volatility
int m_atrIndex;
int m_atrCount;

// Performance metrics for optimization
double m_recentWinRate;
double m_recentProfitFactor;
double m_avgHoldingTime;

// Optimization parameters
bool m_adaptiveMode;                  // Whether to use adaptive R:R
double m_aggressiveness;              // How aggressive the adjustments are

public:
CDynamicRiskRewardOptimizer()
{
m_rrData.Reset();
m_marketCondition.Update();

// Initialize arrays
ArrayInitialize(m_rrPerformanceHistory, 0.0);
ArrayInitialize(m_atrHistory, 0.0);

m_performanceIndex = 0;
m_performanceCount = 0;
m_atrIndex = 0;
m_atrCount = 0;

// Initialize performance metrics
m_recentWinRate = 0.65;        // Default starting values
m_recentProfitFactor = 1.5;
m_avgHoldingTime = 4.0;        // Hours

// Initialize optimization parameters
m_adaptiveMode = true;
m_aggressiveness = 1.0;        // Neutral aggressiveness

::Print("[MONEY DYNAMIC R:R] Dynamic Risk-Reward Optimization system initialized");
::Print("[MONEY CONFIGURATION] Min R:R: ", m_rrData.minAllowedRR, " | Max R:R: ", m_rrData.maxAllowedRR);
}
~CDynamicRiskRewardOptimizer() {}

//+------------------------------------------------------------------+
//| ?? MAIN DYNAMIC R:R CALCULATION                                 |
//+------------------------------------------------------------------+
double CalculateDynamicRiskReward(ENUM_MARKET_REGIME regime, double signalQuality, 
double confluenceScore, double volatilityRatio)
{
// Update market conditions
UpdateMarketConditions(regime, volatilityRatio);

// Calculate base R:R for current regime
CalculateBaseRiskReward(regime);

// Apply market condition adjustments
ApplyMarketConditionAdjustments();

// Apply signal quality adjustments
ApplySignalQualityAdjustments(signalQuality, confluenceScore);

// Apply performance-based adjustments
ApplyPerformanceAdjustments();

// Calculate final optimal R:R
CalculateOptimalRiskReward();

// Apply safety constraints
ApplySafetyConstraints();

// Log R:R analysis
LogRiskRewardAnalysis();

return m_rrData.optimalRiskReward;
}

//+------------------------------------------------------------------+
//| ?? BASE RISK-REWARD CALCULATION BY REGIME                      |
//+------------------------------------------------------------------+
void CalculateBaseRiskReward(ENUM_MARKET_REGIME regime)
{
switch(regime) {
case REGIME_TRENDING_BULLISH:
case REGIME_TRENDING_BEARISH:
// Trending markets: Higher R:R for trend following
m_rrData.baseRiskReward = 2.0;
break;

case REGIME_BREAKOUT:
// Breakout markets: Moderate R:R for momentum
m_rrData.baseRiskReward = 1.8;
break;

case REGIME_RANGING:
// Ranging markets: Lower R:R for mean reversion
m_rrData.baseRiskReward = 1.5;
break;

case REGIME_VOLATILE:
// Volatile markets: Conservative R:R
m_rrData.baseRiskReward = 1.7;
break;

case REGIME_RANGING_TIGHT:
// Tight ranging: Very low R:R
m_rrData.baseRiskReward = 1.3;
break;

default:
m_rrData.baseRiskReward = 1.7; // Default moderate R:R
}
}

//+------------------------------------------------------------------+
//| ?? MARKET CONDITION ADJUSTMENTS                                 |
//+------------------------------------------------------------------+
void ApplyMarketConditionAdjustments()
{
// 1. Volatility Adjustment
CalculateVolatilityAdjustment();

// 2. Trend Strength Adjustment
CalculateTrendAdjustment();

// 3. Liquidity Adjustment
CalculateLiquidityAdjustment();

// 4. Session Adjustment
CalculateSessionAdjustment();
}

void CalculateVolatilityAdjustment()
{
double vol = m_marketCondition.volatilityLevel;

if(vol > 1.5) {
// High volatility: Increase R:R to capture larger moves
m_rrData.volatilityAdjustment = 1.3;
}
else if(vol > 1.2) {
// Moderate high volatility
m_rrData.volatilityAdjustment = 1.1;
}
else if(vol < 0.7) {
// Low volatility: Reduce R:R for tighter targets
m_rrData.volatilityAdjustment = 0.8;
}
else if(vol < 0.5) {
// Very low volatility
m_rrData.volatilityAdjustment = 0.7;
}
else {
// Normal volatility
m_rrData.volatilityAdjustment = 1.0;
}
}

void CalculateTrendAdjustment()
{
double trendStr = m_marketCondition.trendStrength;

if(trendStr > 0.8) {
// Very strong trend: Increase R:R significantly
m_rrData.trendAdjustment = 1.4;
}
else if(trendStr > 0.6) {
// Strong trend: Increase R:R
m_rrData.trendAdjustment = 1.2;
}
else if(trendStr > 0.4) {
// Moderate trend
m_rrData.trendAdjustment = 1.0;
}
else if(trendStr > 0.2) {
// Weak trend: Reduce R:R
m_rrData.trendAdjustment = 0.8;
}
else {
// No trend: Significantly reduce R:R
m_rrData.trendAdjustment = 0.6;
}
}

void CalculateLiquidityAdjustment()
{
double liquidity = m_marketCondition.liquidityHealth;

if(liquidity > 0.8) {
// Good liquidity: Neutral adjustment
m_rrData.liquidityAdjustment = 1.0;
}
else if(liquidity > 0.6) {
// Moderate liquidity: Slight reduction
m_rrData.liquidityAdjustment = 0.9;
}
else if(liquidity > 0.4) {
// Poor liquidity: Reduce R:R
m_rrData.liquidityAdjustment = 0.8;
}
else {
// Very poor liquidity: Significantly reduce
m_rrData.liquidityAdjustment = 0.7;
}
}

void CalculateSessionAdjustment()
{
// Adjust R:R based on trading session characteristics
switch(m_marketCondition.currentSession) {
case SESSION_LONDON:
// London session: Good liquidity, moderate volatility
m_rrData.sessionAdjustment = 1.1;
break;

case SESSION_OVERLAP_LONDON_NY:
// NY/London overlap: High liquidity, high volatility
m_rrData.sessionAdjustment = 1.2;
break;

default:
m_rrData.sessionAdjustment = 1.0;
}

// Adjust based on session volatility
if(m_marketCondition.sessionVolatility > 1.3) {
m_rrData.sessionAdjustment *= 1.1; // Increase for high session volatility
}
else if(m_marketCondition.sessionVolatility < 0.7) {
m_rrData.sessionAdjustment *= 0.9; // Decrease for low session volatility
}
}

//+------------------------------------------------------------------+
//| ?? SIGNAL QUALITY ADJUSTMENTS                                  |
//+------------------------------------------------------------------+
void ApplySignalQualityAdjustments(double signalQuality, double confluenceScore)
{
// Signal Quality Multiplier
if(signalQuality >= 0.9) {
m_rrData.signalQualityMultiplier = 1.3; // Very high quality
}
else if(signalQuality >= 0.8) {
m_rrData.signalQualityMultiplier = 1.2; // High quality
}
else if(signalQuality >= 0.7) {
m_rrData.signalQualityMultiplier = 1.1; // Good quality
}
else if(signalQuality >= 0.6) {
m_rrData.signalQualityMultiplier = 1.0; // Average quality
}
else if(signalQuality >= 0.5) {
m_rrData.signalQualityMultiplier = 0.9; // Below average
}
else {
m_rrData.signalQualityMultiplier = 0.8; // Poor quality
}

// Confluence Score Multiplier
if(confluenceScore >= 0.8) {
m_rrData.confluenceMultiplier = 1.2; // Strong confluence
}
else if(confluenceScore >= 0.7) {
m_rrData.confluenceMultiplier = 1.1; // Good confluence
}
else if(confluenceScore >= 0.6) {
m_rrData.confluenceMultiplier = 1.0; // Moderate confluence
}
else if(confluenceScore >= 0.5) {
m_rrData.confluenceMultiplier = 0.9; // Weak confluence
}
else {
m_rrData.confluenceMultiplier = 0.8; // Very weak confluence
}

// Multi-timeframe analysis (simplified)
m_rrData.timeframeMultiplier = CalculateTimeframeMultiplier();
}

double CalculateTimeframeMultiplier()
{
// Simplified multi-timeframe analysis
// In a real implementation, this would analyze multiple timeframes

// Check H4 and D1 alignment (simplified)
double h4Trend = GetTrendStrength(PERIOD_H4);
double d1Trend = GetTrendStrength(PERIOD_D1);

if(h4Trend > 0.6 && d1Trend > 0.6) {
return 1.2; // Strong multi-timeframe alignment
}
else if(h4Trend > 0.4 || d1Trend > 0.4) {
return 1.0; // Partial alignment
}
else {
return 0.9; // Weak alignment
}
}

//+------------------------------------------------------------------+
//| ?? PERFORMANCE-BASED ADJUSTMENTS                               |
//+------------------------------------------------------------------+
void ApplyPerformanceAdjustments()
{
// Recent Performance Adjustment
if(m_recentWinRate > 0.75) {
// High win rate: Can use higher R:R
m_rrData.recentPerformanceAdj = 1.1;
}
else if(m_recentWinRate > 0.65) {
// Good win rate
m_rrData.recentPerformanceAdj = 1.0;
}
else if(m_recentWinRate > 0.55) {
// Average win rate: Slightly reduce R:R
m_rrData.recentPerformanceAdj = 0.9;
}
else {
// Low win rate: Reduce R:R significantly
m_rrData.recentPerformanceAdj = 0.8;
}

// Profit Factor Adjustment
if(m_recentProfitFactor > 2.0) {
m_rrData.profitFactorAdj = 1.1;
}
else if(m_recentProfitFactor > 1.5) {
m_rrData.profitFactorAdj = 1.0;
}
else if(m_recentProfitFactor > 1.2) {
m_rrData.profitFactorAdj = 0.9;
}
else {
m_rrData.profitFactorAdj = 0.8;
}

// Win Rate Specific Adjustment
m_rrData.winRateAdjustment = CalculateWinRateAdjustment();
}

double CalculateWinRateAdjustment()
{
// Kelly-inspired win rate adjustment
double winRate = m_recentWinRate;

if(winRate > 0.7) {
// High win rate: Can afford higher R:R
return 0.8 + (winRate - 0.7) * 2.0; // Scale up from 0.8
}
else if(winRate > 0.6) {
// Good win rate: Standard R:R
return 1.0;
}
else if(winRate > 0.5) {
// Average win rate: Reduce R:R
return 1.0 - (0.6 - winRate) * 2.0; // Scale down from 1.0
}
else {
// Low win rate: Significantly reduce R:R
return 0.6;
}
}

//+------------------------------------------------------------------+
//| ?? OPTIMAL R:R CALCULATION AND SAFETY                          |
//+------------------------------------------------------------------+
void CalculateOptimalRiskReward()
{
// Combine all adjustments
m_rrData.dynamicRiskReward = m_rrData.baseRiskReward *
m_rrData.volatilityAdjustment *
m_rrData.trendAdjustment *
m_rrData.liquidityAdjustment *
m_rrData.sessionAdjustment;

// Apply signal quality multipliers
m_rrData.optimalRiskReward = m_rrData.dynamicRiskReward *
m_rrData.signalQualityMultiplier *
m_rrData.confluenceMultiplier *
m_rrData.timeframeMultiplier;

// Apply performance adjustments
m_rrData.optimalRiskReward *= m_rrData.recentPerformanceAdj *
m_rrData.winRateAdjustment *
m_rrData.profitFactorAdj;

// Apply aggressiveness factor
if(m_aggressiveness != 1.0) {
double adjustment = 1.0 + (m_aggressiveness - 1.0) * 0.3;
m_rrData.optimalRiskReward *= adjustment;
}
}

void ApplySafetyConstraints()
{
// Apply minimum and maximum R:R constraints
m_rrData.optimalRiskReward = MathMax(m_rrData.minAllowedRR, 
MathMin(m_rrData.maxAllowedRR, 
m_rrData.optimalRiskReward));

// Apply risk constraint (if system is performing poorly)
m_rrData.optimalRiskReward *= m_rrData.riskConstraint;

// Round to reasonable precision
m_rrData.optimalRiskReward = MathRound(m_rrData.optimalRiskReward * 10) / 10.0;
}

//+------------------------------------------------------------------+
//| ?? HELPER METHODS                                               |
//+------------------------------------------------------------------+
void UpdateMarketConditions(ENUM_MARKET_REGIME regime, double volatilityRatio)
{
m_marketCondition.currentRegime = regime;
m_marketCondition.volatilityLevel = volatilityRatio;

// Update other market conditions
m_marketCondition.trendStrength = CalculateCurrentTrendStrength();
m_marketCondition.liquidityHealth = CalculateLiquidityHealth();
m_marketCondition.currentSession = GetCurrentTradingSession();
m_marketCondition.sessionVolatility = CalculateSessionVolatility();
m_marketCondition.marketNoise = CalculateMarketNoise();
m_marketCondition.breakoutPotential = CalculateBreakoutPotential();
}

double CalculateCurrentTrendStrength()
{
// EMA20 and EMA50 removed - keep EMA200 for trend strength
double ema200 = GetEMA(200);
// Safe fallback if global manager not declared
#ifdef __HAS_INDICATOR_MANAGER__
if(g_indicatorManager!=NULL) ema200 = (*g_indicatorManager).GetEMA200(0);
#endif
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

if(ema200 > 0) {
double spread = MathAbs(currentPrice - ema200) / currentPrice;
return MathMin(1.0, spread * 1000); // Normalize
}

return 0.5; // Default moderate strength
}

double GetEMA(int period)
{
#ifdef __HAS_INDICATOR_MANAGER__
if(g_indicatorManager!=NULL){ if(period==34) return (*g_indicatorManager).GetEMA34(0); if(period==89) return (*g_indicatorManager).GetEMA89(0); if(period==200) return (*g_indicatorManager).GetEMA200(0); }
#endif
int handle = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_CLOSE);
double buffer[1];
if(CopyBuffer(handle, 0, 0, 1, buffer) > 0) { IndicatorRelease(handle); return buffer[0]; }
IndicatorRelease(handle);
return 0.0;
}

double GetTrendStrength(ENUM_TIMEFRAMES timeframe)
{
// Simplified trend strength for specific timeframe
#ifdef __HAS_INDICATOR_MANAGER__
double ema0 = (g_indicatorManager?(*g_indicatorManager).GetMTFEMA(21, timeframe, 0):EMPTY_VALUE);
#else
double ema0 = EMPTY_VALUE;
#endif
#ifdef __HAS_INDICATOR_MANAGER__
double ema1 = (g_indicatorManager?(*g_indicatorManager).GetMTFEMA(21, timeframe, 1):EMPTY_VALUE);
#else
double ema1 = EMPTY_VALUE;
#endif
if(ema0!=EMPTY_VALUE && ema1!=EMPTY_VALUE){ double slope = ema0-ema1; return MathMin(1.0, MathAbs(slope) * 100000); }
int handle = iMA(_Symbol, timeframe, 21, 0, MODE_EMA, PRICE_CLOSE);
double buffer[2];
if(CopyBuffer(handle, 0, 0, 2, buffer) >= 2) { double slope = buffer[0] - buffer[1]; IndicatorRelease(handle); return MathMin(1.0, MathAbs(slope) * 100000); }
IndicatorRelease(handle);
return 0.5;
}

// Placeholder methods for additional calculations
double CalculateLiquidityHealth() { return 0.8; }
ENUM_TRADING_SESSION GetCurrentTradingSession() { return SESSION_LONDON; }
double CalculateSessionVolatility() { return 1.0; }
double CalculateMarketNoise() { return 0.5; }
double CalculateBreakoutPotential() { return 0.5; }

void LogRiskRewardAnalysis()
{
::Print(StringFormat("[MONEY R:R] Base: %.1f | Dynamic: %.1f | Final: %.1f | Vol: %.2fx | Trend: %.2fx | Signal: %.2fx",
m_rrData.baseRiskReward,
m_rrData.dynamicRiskReward,
m_rrData.optimalRiskReward,
m_rrData.volatilityAdjustment,
m_rrData.trendAdjustment,
m_rrData.signalQualityMultiplier));
}

// Public interface methods
void UpdatePerformanceMetrics(double winRate, double profitFactor, double avgHoldingTime)
{
m_recentWinRate = winRate;
m_recentProfitFactor = profitFactor;
m_avgHoldingTime = avgHoldingTime;
}

RiskRewardOptimizationData GetOptimizationData() const { return m_rrData; }
double GetOptimalRiskReward() const { return m_rrData.optimalRiskReward; }

void SetAggressiveness(double aggressiveness) 
{ 
m_aggressiveness = MathMax(0.5, MathMin(1.5, aggressiveness)); 
}

void SetRiskRewardLimits(double minRR, double maxRR)
{
m_rrData.minAllowedRR = MathMax(1.0, minRR);
m_rrData.maxAllowedRR = MathMin(5.0, maxRR);
}

string GetRiskRewardReport()
{
return StringFormat(
"MONEY DYNAMIC RISK-REWARD OPTIMIZATION\n" +
"Regime: %s | Base R:R: %.1f\n" +
"Adjustments - Vol: %.2fx | Trend: %.2fx | Liquidity: %.2fx | Session: %.2fx\n" +
"Signal Quality: %.2fx | Confluence: %.2fx | Timeframe: %.2fx\n" +
"Performance - WinRate: %.2fx | PF: %.2fx | Recent: %.2fx\n" +
"Final Optimal R:R: %.1f (Range: %.1f - %.1f)",
MarketRegimeToString(m_marketCondition.currentRegime),
m_rrData.baseRiskReward,
m_rrData.volatilityAdjustment,
m_rrData.trendAdjustment,
m_rrData.liquidityAdjustment,
m_rrData.sessionAdjustment,
m_rrData.signalQualityMultiplier,
m_rrData.confluenceMultiplier,
m_rrData.timeframeMultiplier,
m_rrData.winRateAdjustment,
m_rrData.profitFactorAdj,
m_rrData.recentPerformanceAdj,
m_rrData.optimalRiskReward,
m_rrData.minAllowedRR,
m_rrData.maxAllowedRR
);
}
};

#endif // RISK_DYNAMIC_RISK_REWARD_MQH


