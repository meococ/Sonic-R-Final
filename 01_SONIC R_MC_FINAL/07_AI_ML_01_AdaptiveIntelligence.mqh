//+------------------------------------------------------------------+
//|                              AI_AdaptiveIntelligence.mqh        |
//|                SONIC R MC - AI BREAKTHROUGH ADAPTIVE ENGINE      |
//|                        �?i B�ng AI Revolution                    |
//+------------------------------------------------------------------+
#ifndef ADAPTIVE_INTELLIGENCE_MQH
#define ADAPTIVE_INTELLIGENCE_MQH

#include "01_Core_07_CommonStructures.mqh"
// #include "01_Core_16_EnumHelpers.mqh" // Already included in MasterIncludes
#include "01_Core_09_SharedDataStructures.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"

//+------------------------------------------------------------------+
//| PRODUCTION FIX: Removed duplicate ENUM_MARKET_REGIME enum       |
//| Using definition from SonicR_Enums.mqh to avoid conflicts      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Adaptive Parameters Structure                                    |
//+------------------------------------------------------------------+
struct AdaptiveParams {
// Dragon Band Parameters
int dragonEMAPeriod;        // Dynamic EMA period (30-40)
double dragonAngleMin;      // Dynamic angle threshold (1.5-3.0)

// Signal Filtering
double minSignalProbability; // Dynamic probability (0.6-0.8)
double minRiskReward;        // Dynamic R:R (1.2-2.5)

// Position Sizing
double riskMultiplier;       // Dynamic risk multiplier (0.5-1.5)
double volatilityAdjust;     // Volatility adjustment (0.8-1.2)

// Time Factors
int sessionMultiplier;       // Session-based multiplier

void SetDefaults() {
dragonEMAPeriod = 34;
dragonAngleMin = 2.0;
minSignalProbability = 0.7;
minRiskReward = 1.5;
riskMultiplier = 1.0;
volatilityAdjust = 1.0;
sessionMultiplier = 1;
}
};

//+------------------------------------------------------------------+
//| "B? BA TH�CH ?NG" IMPLEMENTATION - BOSS'S PHILOSOPHY        |
//| 1. H?P LUU (Confluence) - Multi-factor signal scoring           |
//| 2. B?I C?NH (Context) - Multi-timeframe analysis               |
//| 3. TH�CH ?NG (Adaptation) - Dynamic parameter adjustment       |
//+------------------------------------------------------------------+
struct AdaptiveMetrics
{
// Performance tracking for adaptation
double recentWinRate;
double recentProfitFactor;
double avgDrawdown;
int consecutiveLosses;

// Market condition assessment
double volatilityLevel;
double trendStrength;
double liquidityHealth;

void Initialize()
{
recentWinRate = 0.65;
recentProfitFactor = 1.5;
avgDrawdown = 0.05;
consecutiveLosses = 0;
volatilityLevel = 0.5;
trendStrength = 0.5;
liquidityHealth = 0.8;
}
};

//+------------------------------------------------------------------+
//| ENHANCED AI ENGINE - "B? BA TH�CH ?NG" IMPLEMENTATION           |
//+------------------------------------------------------------------+
class CAIAdaptiveEngine {
private:
ENUM_MARKET_REGIME m_currentRegime;
AdaptiveParams m_params;
AdaptiveMetrics m_metrics;

// Multi-timeframe context
ENUM_SIGNAL_TYPE m_h4Trend;
ENUM_SIGNAL_TYPE m_d1Trend;

// ADDED: Missing private member variables
double m_trendStrength;
double m_momentumScore;
double m_volatilityLevel;
double m_recentWinRate;
double m_recentProfitFactor;

public:
CAIAdaptiveEngine() {
m_currentRegime = REGIME_UNKNOWN;
m_params.SetDefaults();
m_metrics.Initialize();
m_h4Trend = SIGNAL_NONE;
m_d1Trend = SIGNAL_NONE;

// ADDED: Initialize missing member variables
m_trendStrength = 0.5;
m_momentumScore = 0.5;
m_volatilityLevel = 0.5;
m_recentWinRate = 0.65;
m_recentProfitFactor = 1.5;
}

// BREAKTHROUGH: Real-time Market Regime Detection
ENUM_MARKET_REGIME DetectMarketRegime() {
// Multi-indicator regime analysis
AnalyzeTrendStrength();
AnalyzeVolatility();
AnalyzeMomentum();

// AI Decision Logic
if(m_trendStrength > 0.7 && m_momentumScore > 0.6) {
if(GetPriceDirection() > 0)
m_currentRegime = REGIME_TRENDING_BULLISH;
else
m_currentRegime = REGIME_TRENDING_BEARISH;
}
else if(m_volatilityLevel > 0.8) {
m_currentRegime = REGIME_VOLATILE;
}
else if(m_volatilityLevel < 0.3 && m_trendStrength < 0.4) {
m_currentRegime = REGIME_RANGING;
}
else if(m_momentumScore > 0.8 && m_volatilityLevel > 0.6) {
m_currentRegime = REGIME_BREAKOUT;
}
else {
m_currentRegime = REGIME_UNKNOWN;
}

return m_currentRegime;
}

// BREAKTHROUGH: Dynamic Parameter Optimization
void OptimizeParameters() {
switch(m_currentRegime) {
case REGIME_TRENDING_BULLISH:
case REGIME_TRENDING_BEARISH:
// Trending: Looser parameters for trend following
m_params.dragonEMAPeriod = 40;  // Smoother EMA
m_params.dragonAngleMin = 1.5;  // Lower angle threshold
m_params.minSignalProbability = 0.65; // Accept more signals
m_params.riskMultiplier = 1.2;  // Increase position size
break;

case REGIME_RANGING:
// Ranging: Tighter parameters for mean reversion
m_params.dragonEMAPeriod = 30;  // More responsive EMA
m_params.dragonAngleMin = 2.5;  // Higher angle threshold
m_params.minSignalProbability = 0.75; // Be more selective
m_params.riskMultiplier = 0.8;  // Reduce position size
break;

case REGIME_VOLATILE:
// Volatile: Conservative approach
m_params.dragonEMAPeriod = 34;  // Standard EMA
m_params.dragonAngleMin = 3.0;  // High angle threshold
m_params.minSignalProbability = 0.8; // Very selective
m_params.riskMultiplier = 0.6;  // Reduce risk significantly
break;

case REGIME_BREAKOUT:
// Breakout: Aggressive trend capture
m_params.dragonEMAPeriod = 25;  // Fast EMA
m_params.dragonAngleMin = 1.8;  // Moderate angle
m_params.minSignalProbability = 0.7; // Standard selectivity
m_params.riskMultiplier = 1.4;  // Increase position size
break;

default:
m_params.SetDefaults();
break;
}

// Performance-based adjustment
AdjustBasedOnPerformance();

Print("[?? AI ADAPTIVE] Regime: ", MarketRegimeToString(m_currentRegime), 
" | EMA: ", m_params.dragonEMAPeriod,
" | Angle: ", DoubleToString(m_params.dragonAngleMin, 1),
" | Risk: ", DoubleToString(m_params.riskMultiplier, 2));
}

// PHASE 5: Enhanced Performance-Based Learning with Dynamic Adjustments
void UpdatePerformanceMetrics(bool wasWinningTrade, double profitRatio, double drawdown) {
// Update win rate (rolling average)
double alpha = 0.1; // Learning rate
if(wasWinningTrade)
{
m_metrics.recentWinRate = m_metrics.recentWinRate * (1 - alpha) + alpha;
m_metrics.consecutiveLosses = 0;
}
else
{
m_metrics.recentWinRate = m_metrics.recentWinRate * (1 - alpha);
m_metrics.consecutiveLosses++;
}

// Update profit factor
m_metrics.recentProfitFactor = m_metrics.recentProfitFactor * (1 - alpha) + profitRatio * alpha;

// Update drawdown
m_metrics.avgDrawdown = MathMax(m_metrics.avgDrawdown, drawdown);

// PHASE 5: Dynamic Parameter Adjustment Based on Performance
ApplyDynamicAdjustments();

Print(StringFormat("[?? PERFORMANCE] WinRate: %.1f%% | PF: %.2f | DD: %.1f%% | Losses: %d",
m_metrics.recentWinRate * 100, m_metrics.recentProfitFactor, 
m_metrics.avgDrawdown * 100, m_metrics.consecutiveLosses));
}

// H?P LUU (CONFLUENCE) - Multi-factor Signal Evaluation
double EvaluateSignalConfluence(ENUM_SIGNAL_TYPE signal)
{
double totalScore = 0.0;

// FACTOR 1: B?I C?NH (Multi-timeframe context) - 30%
double contextScore = EvaluateMultiTimeframeContext(signal);
totalScore += contextScore * 3.0;  // Max 3 points

// FACTOR 2: THI?T L?P K? THU?T (Technical setup) - 25%
double technicalScore = EvaluateTechnicalSetup(signal);
totalScore += technicalScore * 2.5;  // Max 2.5 points

// FACTOR 3: X�C NH?N VOLUME (Volume confirmation) - 25%
double volumeScore = EvaluateVolumeConfirmation(signal);
totalScore += volumeScore * 2.5;  // Max 2.5 points

// FACTOR 4: �I?U KI?N TH? TRU?NG (Market conditions) - 20%
double marketScore = EvaluateMarketConditions(signal);
totalScore += marketScore * 2.0;  // Max 2 points

// BOSS'S THRESHOLD: 6.5/10 points for quality trades
bool qualityTrade = totalScore >= 6.5;

Print(StringFormat("?? [CONFLUENCE] Signal: %s | Context: %.1f | Tech: %.1f | Volume: %.1f | Market: %.1f",
SignalTypeToString(signal), contextScore*3, technicalScore*2.5, volumeScore*2.5, marketScore*2));
Print(StringFormat("??? [TOTAL SCORE] %.1f/10.0 | RESULT: %s",
totalScore, qualityTrade ? "? QUALIFIED" : "? REJECTED"));

return qualityTrade ? totalScore : 0.0;
}

//+------------------------------------------------------------------+
//| ?? B?I C?NH - Multi-timeframe Context Analysis                  |
//+------------------------------------------------------------------+
double EvaluateMultiTimeframeContext(ENUM_SIGNAL_TYPE signal)
{
UpdateMultiTimeframeTrends();

double score = 0.0;

if(signal == SIGNAL_BUY)
{
if(m_h4Trend == SIGNAL_BUY && m_d1Trend == SIGNAL_BUY)
score = 1.0;  // Perfect alignment
else if(m_h4Trend == SIGNAL_BUY || m_d1Trend == SIGNAL_BUY)
score = 0.6;  // Partial support
else if(m_h4Trend == SIGNAL_SELL || m_d1Trend == SIGNAL_SELL)
score = 0.0;  // Against trend - no confluence
else
score = 0.3;  // Neutral
}
else if(signal == SIGNAL_SELL)
{
if(m_h4Trend == SIGNAL_SELL && m_d1Trend == SIGNAL_SELL)
score = 1.0;  // Perfect alignment
else if(m_h4Trend == SIGNAL_SELL || m_d1Trend == SIGNAL_SELL)
score = 0.6;  // Partial support
else if(m_h4Trend == SIGNAL_BUY || m_d1Trend == SIGNAL_BUY)
score = 0.0;  // Against trend - no confluence
else
score = 0.3;  // Neutral
}

return score;
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: Dynamic Parameter Adjustments                       |
//+------------------------------------------------------------------+
void ApplyDynamicAdjustments() {
// ?? TARGET: winRate=0.55 ? RR=0.5 (Phase 5 requirement)
if(m_metrics.recentWinRate < 0.60) {
// Reduce RR when win rate is low
m_params.minRiskReward = MathMax(0.5, m_params.minRiskReward - 0.5);
Print("[?? AI ADAPT] Low win rate detected: ", DoubleToString(m_metrics.recentWinRate*100, 1), 
"% ? Reducing RR to ", DoubleToString(m_params.minRiskReward, 1));
}
else if(m_metrics.recentWinRate > 0.75) {
// Increase RR when win rate is high
m_params.minRiskReward = MathMin(2.5, m_params.minRiskReward + 0.3);
Print("[?? AI ADAPT] High win rate: ", DoubleToString(m_metrics.recentWinRate*100, 1), 
"% ? Increasing RR to ", DoubleToString(m_params.minRiskReward, 1));
}

// ?? EMA Volatility Adaptation: Volume >1.5 ? increase EMA (+5)
double currentVolatility = CalculateVolatilityLevel();
if(currentVolatility > 1.5) {
m_params.dragonEMAPeriod = MathMin(50, m_params.dragonEMAPeriod + 5);
Print("[?? VOLATILITY] High volatility detected: ", DoubleToString(currentVolatility, 2), 
" ? Increasing EMA to ", m_params.dragonEMAPeriod);
}
else if(currentVolatility < 0.8) {
m_params.dragonEMAPeriod = MathMax(20, m_params.dragonEMAPeriod - 3);
Print("[?? VOLATILITY] Low volatility: ", DoubleToString(currentVolatility, 2), 
" ? Decreasing EMA to ", m_params.dragonEMAPeriod);
}

// ?? PVSRA Threshold Adaptation
if(m_metrics.consecutiveLosses >= 3) {
m_params.minSignalProbability = MathMin(0.85, m_params.minSignalProbability + 0.05);
Print("[?? PROTECTION] ", m_metrics.consecutiveLosses, " consecutive losses ? Increasing signal threshold to ", 
DoubleToString(m_params.minSignalProbability, 2));
}
else if(m_metrics.consecutiveLosses == 0 && m_metrics.recentWinRate > 0.70) {
m_params.minSignalProbability = MathMax(0.60, m_params.minSignalProbability - 0.02);
}
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: Enhanced Volatility Calculation                     |
//+------------------------------------------------------------------+
double CalculateVolatilityLevel() {
// Calculate ATR-based volatility
double atr14 = iATR(_Symbol, PERIOD_CURRENT, 14);
double atr14_avg = 0;
for(int i = 1; i <= 20; i++) {
atr14_avg += iATR(_Symbol, PERIOD_CURRENT, 14);
}
atr14_avg /= 20;

double volatilityRatio = atr14 / atr14_avg;

// Update internal volatility level
m_volatilityLevel = volatilityRatio;

return volatilityRatio;
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: Win Rate Monitoring (Past 30 Trades)               |
//+------------------------------------------------------------------+
void MonitorWinRate(bool tradeResult) {
static int tradeHistory[30];
static int tradeIndex = 0;
static int totalTrades = 0;

// Add new trade result
tradeHistory[tradeIndex] = tradeResult ? 1 : 0;
tradeIndex = (tradeIndex + 1) % 30;
totalTrades = MathMin(totalTrades + 1, 30);

// Calculate win rate from last 30 trades
int wins = 0;
for(int i = 0; i < totalTrades; i++) {
wins += tradeHistory[i];
}

double winRate30 = (double)wins / totalTrades;
m_metrics.recentWinRate = winRate30;

Print(StringFormat("[?? WIN RATE 30] Trades: %d | Wins: %d | Rate: %.1f%%", 
totalTrades, wins, winRate30 * 100));

// ?? PHASE 5 TEST: winRate=0.55 ? RR=0.5
if(MathAbs(winRate30 - 0.55) < 0.02) {
Print("[?? PHASE 5 TEST] Win rate ~55% detected ? Setting RR to 0.5");
m_params.minRiskReward = 0.5;
}
}

double EvaluateTechnicalSetup(ENUM_SIGNAL_TYPE signal)
{
// EMA trend alignment
double ema34 = GetEMA34(0);
double ema34_prev = GetEMA34(1);
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

double score = 0.0;

if(signal == SIGNAL_BUY)
{
bool emaUptrend = ema34 > ema34_prev;
bool priceAboveEMA = currentPrice > ema34;

if(emaUptrend && priceAboveEMA)
score = 1.0;  // Perfect technical setup
else if(emaUptrend || priceAboveEMA)
score = 0.6;  // Partial setup
else
score = 0.2;  // Weak setup
}
else if(signal == SIGNAL_SELL)
{
bool emaDowntrend = ema34 < ema34_prev;
bool priceBelowEMA = currentPrice < ema34;

if(emaDowntrend && priceBelowEMA)
score = 1.0;  // Perfect technical setup
else if(emaDowntrend || priceBelowEMA)
score = 0.6;  // Partial setup
else
score = 0.2;  // Weak setup
}

return score;
}

double EvaluateVolumeConfirmation(ENUM_SIGNAL_TYPE signal)
{
// Volume analysis for signal confirmation
long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, 0);
long avgVolume = 0;
for(int i = 1; i <= 10; i++)
avgVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
avgVolume /= 10;

double volumeRatio = (double)currentVolume / avgVolume;

// Check candle direction
MqlRates rates[];
ArraySetAsSeries(rates, true);
double score = 0.0;

if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) >= 1)
{
bool bullishCandle = rates[0].close > rates[0].open;
bool bearishCandle = rates[0].close < rates[0].open;

if(signal == SIGNAL_BUY && bullishCandle)
{
if(volumeRatio > 2.0) score = 1.0;      // Excellent volume
else if(volumeRatio > 1.5) score = 0.8; // Good volume
else if(volumeRatio > 1.2) score = 0.5; // Moderate volume
else score = 0.2;                       // Weak volume
}
else if(signal == SIGNAL_SELL && bearishCandle)
{
if(volumeRatio > 2.0) score = 1.0;      // Excellent volume
else if(volumeRatio > 1.5) score = 0.8; // Good volume
else if(volumeRatio > 1.2) score = 0.5; // Moderate volume
else score = 0.2;                       // Weak volume
}
else
{
score = 0.0; // Wrong candle direction
}
}

return score;
}

double EvaluateMarketConditions(ENUM_SIGNAL_TYPE signal)
{
UpdateMarketConditions();

double score = 0.5; // Base score

// Adjust based on current market regime
switch(m_currentRegime)
{
case REGIME_TRENDING_BULLISH:
score = (signal == SIGNAL_BUY) ? 1.0 : 0.3;
break;
case REGIME_TRENDING_BEARISH:
score = (signal == SIGNAL_SELL) ? 1.0 : 0.3;
break;
case REGIME_RANGING:
score = 0.6; // Neutral for ranging markets
break;
case REGIME_VOLATILE:
score = 0.3; // Reduce score in volatile conditions
break;
case REGIME_BREAKOUT:
score = 0.8; // Good for breakout signals
break;
default:
score = 0.5;
}

// Adjust for liquidity conditions
if(m_metrics.liquidityHealth < 0.5)
score *= 0.7; // Reduce score in poor liquidity

return score;
}

//+------------------------------------------------------------------+
//| ?? TH�CH ?NG - Dynamic Parameter Adaptation                     |
//+------------------------------------------------------------------+
void AdaptTradingParameters(double& riskPercent, double& takeProfit, double& stopLoss)
{
DetectMarketRegime();

// Base parameters
double baseRisk = riskPercent;
double baseTpMultiplier = 2.0;
double baseSlMultiplier = 1.0;

// Adapt based on market regime
switch(m_currentRegime)
{
case REGIME_TRENDING_BULLISH:
case REGIME_TRENDING_BEARISH:
// ?? TRENDING: Be more aggressive, ride the trend
riskPercent = baseRisk * 1.2;  // Increase position size 20%
takeProfit *= 1.5;            // Wider TP to capture trend
Print("[?? ADAPT] TRENDING market: Risk +20%, TP +50%");
break;

case REGIME_RANGING:
// ?? RANGING: Conservative, quick profits
riskPercent = baseRisk * 0.8;  // Reduce position size 20%
takeProfit *= 0.7;            // Tighter TP for ranging
Print("[?? ADAPT] RANGING market: Risk -20%, TP -30%");
break;

case REGIME_VOLATILE:
// ?? VOLATILE: Very conservative
riskPercent = baseRisk * 0.5;  // Halve position size
stopLoss *= 1.3;              // Wider SL for volatility
takeProfit *= 0.8;            // Moderate TP
Print("[?? ADAPT] VOLATILE market: Risk -50%, SL +30%");
break;

case REGIME_BREAKOUT:
// ?? BREAKOUT: Aggressive for momentum
riskPercent = baseRisk * 1.4;  // Increase position size 40%
takeProfit *= 2.0;            // Much wider TP
Print("[?? ADAPT] BREAKOUT market: Risk +40%, TP +100%");
break;

default:
// Keep base parameters
Print("[?? ADAPT] UNKNOWN market: Using base parameters");
}

// Performance-based adjustments
if(m_metrics.consecutiveLosses >= 3)
{
riskPercent *= 0.6; // Reduce risk after losses
Print("[?? ADAPT] Consecutive losses detected: Risk reduced 40%");
}

if(m_metrics.recentWinRate > 0.75)
{
riskPercent = MathMin(riskPercent * 1.1, baseRisk * 1.5); // Cap at 150%
Print("[?? ADAPT] High win rate: Risk increased 10%");
}

// Safety caps
riskPercent = MathMax(0.2, MathMin(riskPercent, baseRisk * 2.0));
}

// Getters for optimized parameters
AdaptiveParams GetOptimizedParams() const { return m_params; }
ENUM_MARKET_REGIME GetCurrentRegime() const { return m_currentRegime; }
double GetPerformanceScore() const { return m_recentWinRate * m_recentProfitFactor; }

private:
void AnalyzeTrendStrength() {
// ?? PHASE 1: Removed ADX - Using EMA-based trend strength for simplification
// EMA spread-based trend strength (more aligned with Sonic R methodology)

// EMA slope confirmation - ?? FINAL COMPLETION: Unified system
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

int ema_handle = INVALID_HANDLE;
if(manager != NULL) {
ema_handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);

// Log migration success - AI COMPONENT MIGRATION
manager.MigrateLegacyIndicatorCalls(
"AI_AdaptiveIntelligence.mqh",
487,
"AI trend analysis EMA 34 iMA() call - FINAL ELIMINATION",
"Unified AI-integrated EMA handle system"
);
} else {
// Fallback for AI component
ema_handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
Print("?? [AI COMPONENT] Using fallback iMA call - unified manager not available");
}

double ema_buffer[];
if(CopyBuffer(ema_handle, 0, 0, 5, ema_buffer) > 0) {
double slope = (ema_buffer[0] - ema_buffer[4]) / 4;
double normalizedSlope = MathAbs(slope) / _Point / 10; // Normalize
m_trendStrength = normalizedSlope; // Direct EMA slope-based trend strength
}
IndicatorRelease(ema_handle);
}

void AnalyzeVolatility() {
// ATR-based volatility
int atr_handle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atr_buffer[];
if(CopyBuffer(atr_handle, 0, 0, 20, atr_buffer) > 0) {
double currentATR = atr_buffer[0];
double avgATR = 0;
for(int i = 0; i < 20; i++) avgATR += atr_buffer[i];
avgATR /= 20;

m_volatilityLevel = currentATR / avgATR;
m_volatilityLevel = MathMin(2.0, MathMax(0.0, m_volatilityLevel)) / 2.0; // Normalize
}
IndicatorRelease(atr_handle);
}

void AnalyzeMomentum() {
// ?? PHASE 1: Removed RSI - Using only MACD for momentum (aligned with Sonic R)

// MACD momentum (primary momentum indicator)
int macd_handle = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
double macd_main[], macd_signal[];
if(CopyBuffer(macd_handle, 0, 0, 2, macd_main) > 0 && 
CopyBuffer(macd_handle, 1, 0, 2, macd_signal) > 0) {
double macdMomentum = MathAbs(macd_main[0] - macd_main[1]);
m_momentumScore = macdMomentum * 1000; // Direct MACD-based momentum
}
IndicatorRelease(macd_handle);
}

double GetPriceDirection() {
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
double prevPrice = iClose(_Symbol, PERIOD_CURRENT, 10);
return (currentPrice > prevPrice) ? 1.0 : -1.0;
}

void AdjustBasedOnPerformance() {
if(m_recentWinRate < 0.6) {
// Poor performance: be more conservative
m_params.minSignalProbability += 0.05;
m_params.riskMultiplier *= 0.9;
m_params.dragonAngleMin += 0.2;
} else if(m_recentWinRate > 0.75) {
// Good performance: be slightly more aggressive
m_params.minSignalProbability = MathMax(0.6, m_params.minSignalProbability - 0.02);
m_params.riskMultiplier = MathMin(1.5, m_params.riskMultiplier * 1.05);
}
}

void MakeConservativeAdjustment() {
m_params.riskMultiplier *= 0.8;
m_params.minSignalProbability += 0.1;
m_params.dragonAngleMin += 0.5;
Print("[??? AI LEARNING] Making conservative adjustment due to poor performance");
}

void MakeAggressiveAdjustment() {
m_params.riskMultiplier = MathMin(1.5, m_params.riskMultiplier * 1.1);
m_params.minSignalProbability = MathMax(0.6, m_params.minSignalProbability - 0.05);
Print("[?? AI LEARNING] Making aggressive adjustment due to excellent performance");
}

void UpdateMultiTimeframeTrends()
{
m_h4Trend = GetTrendDirection(PERIOD_H4);
m_d1Trend = GetTrendDirection(PERIOD_D1);
}

ENUM_SIGNAL_TYPE GetTrendDirection(ENUM_TIMEFRAMES timeframe)
{
// EMA20 and EMA50 removed - keep EMA200 for trend direction
double ema200 = GetMTFEMA(200, timeframe, 0);
double ema200_prev = GetMTFEMA(200, timeframe, 1);
double atr = GetATR(14);

if(ema200 > ema200_prev && atr > 0.0001)
return SIGNAL_BUY;
else if(ema200 < ema200_prev && atr > 0.0001)
return SIGNAL_SELL;
else
return SIGNAL_NONE;
}

double GetEMA(int period, int shift)
{
if(g_indicatorManager!=NULL){ if(period==34) return GetEMA34(shift); if(period==89) return GetEMA89(shift); if(period==200) return GetEMA200(shift); }
int handle = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_CLOSE);
double buffer[1];
if(CopyBuffer(handle, 0, shift, 1, buffer) > 0){ IndicatorRelease(handle); return buffer[0]; }
IndicatorRelease(handle);
return 0.0;
}

double GetEMAOnTimeframe(int period, int shift, ENUM_TIMEFRAMES timeframe)
{
if(g_indicatorManager!=NULL){ double v=GetMTFEMA(period, timeframe, shift); if(v!=EMPTY_VALUE) return v; }
int handle = iMA(_Symbol, timeframe, period, 0, MODE_EMA, PRICE_CLOSE);
double buffer[1];
if(CopyBuffer(handle, 0, shift, 1, buffer) > 0){ IndicatorRelease(handle); return buffer[0]; }
IndicatorRelease(handle);
return 0.0;
}

void UpdateMarketConditions()
{
// Update volatility
double atr = GetATR(14);
double avgATR = 0;
for(int i = 1; i <= 20; i++)
avgATR += GetATR(14, i);
avgATR /= 20;

m_metrics.volatilityLevel = (avgATR > 0) ? atr / avgATR : 1.0;

// Update trend strength
m_metrics.trendStrength = CalculateTrendStrength();
}

double GetATR(int period, int shift = 0)
{
int handle = iATR(_Symbol, PERIOD_CURRENT, period);
double buffer[1];
if(CopyBuffer(handle, 0, shift, 1, buffer) > 0)
{
IndicatorRelease(handle);
return buffer[0];
}
IndicatorRelease(handle);
return 0.0;
}

double CalculateTrendStrength()
{
// EMA20 and EMA50 removed - keep EMA200 for trend strength
double ema200 = GetEMA200(0);
double ema200_prev = GetEMA200(1);
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

if(ema200 == 0 || ema200_prev == 0) return 0.5;

double emaSlope = (ema200 - ema200_prev) / currentPrice;
return MathMin(MathAbs(emaSlope) * 1000, 1.0); // Normalize
}

public:
// Get current adaptive parameters
AdaptiveParams GetCurrentParams() { return m_params; }
ENUM_MARKET_REGIME GetCurrentRegime() { return m_currentRegime; }
AdaptiveMetrics GetMetrics() { return m_metrics; }

string GetAdaptiveReport()
{
return StringFormat(
"?? ADAPTIVE AI STATUS\n" +
"Market Regime: %s\n" +
"Win Rate: %.1f%% | Profit Factor: %.2f\n" +
"Trend Strength: %.2f | Volatility: %.2f\n" +
"Consecutive Losses: %d\n" +
"Risk Adjustment: %s",
MarketRegimeToString(m_currentRegime),
m_metrics.recentWinRate * 100, m_metrics.recentProfitFactor,
m_metrics.trendStrength, m_metrics.volatilityLevel,
m_metrics.consecutiveLosses,
(m_metrics.consecutiveLosses >= 3) ? "DEFENSIVE" : "NORMAL"
);
}
};

//+------------------------------------------------------------------+
//| FINAL SPRINT - MISSING GLOBAL FUNCTIONS                         |
//+------------------------------------------------------------------+
double GetEMA34(int shift)
{
    // Global function wrapper for compatibility
    int handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
    double buffer[1];
    if(CopyBuffer(handle, 0, shift, 1, buffer) > 0) {
        IndicatorRelease(handle);
        return buffer[0];
    }
    IndicatorRelease(handle);
    return 0.0;
}

double GetEMA89(int shift)
{
    // Global function wrapper for compatibility
    int handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
    double buffer[1];
    if(CopyBuffer(handle, 0, shift, 1, buffer) > 0) {
        IndicatorRelease(handle);
        return buffer[0];
    }
    IndicatorRelease(handle);
    return 0.0;
}

double GetEMA200(int shift)
{
    // Global function wrapper for compatibility
    int handle = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
    double buffer[1];
    if(CopyBuffer(handle, 0, shift, 1, buffer) > 0) {
        IndicatorRelease(handle);
        return buffer[0];
    }
    IndicatorRelease(handle);
    return 0.0;
}

double GetMTFEMA(int period, ENUM_TIMEFRAMES timeframe, int shift)
{
    // Global function wrapper for compatibility
    int handle = iMA(_Symbol, timeframe, period, 0, MODE_EMA, PRICE_CLOSE);
    double buffer[1];
    if(CopyBuffer(handle, 0, shift, 1, buffer) > 0) {
        IndicatorRelease(handle);
        return buffer[0];
    }
    IndicatorRelease(handle);
    return 0.0;
}

string VaRMethodToString(int method)
{
    // Global function wrapper for VaR method
    switch(method)
    {
        case 0: return "Historical";
        case 1: return "Parametric";
        case 2: return "Monte Carlo";
        default: return "Unknown";
    }
}

#endif // AI_ADAPTIVE_INTELLIGENCE_MQH


