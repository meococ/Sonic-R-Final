//+------------------------------------------------------------------+
//|                                AI_AdaptiveParameterOptimization.mqh |
//|                        SONIC R MC - ADAPTIVE PARAMETER OPTIMIZATION |
//|                            [BRAIN] INTELLIGENT SELF-TUNING SYSTEM        |
//+------------------------------------------------------------------+

#ifndef AI_ADAPTIVE_PARAMETER_OPTIMIZATION_MQH
#define AI_ADAPTIVE_PARAMETER_OPTIMIZATION_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| Optimizable Parameter Set                                        |
//+------------------------------------------------------------------+
struct OptimizableParameters
{
// Signal generation parameters
double confluenceThreshold;     // Minimum confluence for signal (0.5-0.8)
double dragonBandWeight;        // Dragon band importance (0.1-0.4)
double wavePatternWeight;       // Wave pattern importance (0.1-0.3)
double pvsraWeight;            // PVSRA importance (0.1-0.3)
double smcWeight;              // SMC importance (0.1-0.2)

// Risk management parameters
double maxRiskPercent;         // Maximum risk per trade (1.0-3.0)
double dynamicRRMultiplier;    // Risk-reward multiplier (1.5-3.0)
double volatilityAdjustment;   // Volatility-based adjustment (0.5-1.5)

// Timing parameters
int processingFrequency;       // Ticks between analysis (1-10)
int signalValidityPeriod;      // How long signal stays valid (5-30 minutes)

// Performance thresholds
double minWinRate;            // Minimum acceptable win rate (0.6-0.8)
double maxDrawdown;           // Maximum acceptable drawdown (0.05-0.15)

void SetDefaults()
{
confluenceThreshold = 0.65;
dragonBandWeight = 0.25;
wavePatternWeight = 0.20;
pvsraWeight = 0.20;
smcWeight = 0.15;
maxRiskPercent = 2.0;
dynamicRRMultiplier = 2.0;
volatilityAdjustment = 1.0;
processingFrequency = 5;
signalValidityPeriod = 15;
minWinRate = 0.65;
maxDrawdown = 0.10;
}

void ApplyBounds()
{
confluenceThreshold = MathMax(0.5, MathMin(0.8, confluenceThreshold));
dragonBandWeight = MathMax(0.1, MathMin(0.4, dragonBandWeight));
wavePatternWeight = MathMax(0.1, MathMin(0.3, wavePatternWeight));
pvsraWeight = MathMax(0.1, MathMin(0.3, pvsraWeight));
smcWeight = MathMax(0.1, MathMin(0.2, smcWeight));
maxRiskPercent = MathMax(1.0, MathMin(3.0, maxRiskPercent));
dynamicRRMultiplier = MathMax(1.5, MathMin(3.0, dynamicRRMultiplier));
volatilityAdjustment = MathMax(0.5, MathMin(1.5, volatilityAdjustment));
processingFrequency = (int)MathMax(1, MathMin(10, processingFrequency));
signalValidityPeriod = (int)MathMax(5, MathMin(30, signalValidityPeriod));
minWinRate = MathMax(0.6, MathMin(0.8, minWinRate));
maxDrawdown = MathMax(0.05, MathMin(0.15, maxDrawdown));
}
};

//+------------------------------------------------------------------+
//| Performance Metrics for Optimization                            |
//+------------------------------------------------------------------+
struct AIPerformanceMetrics
{
double winRate;                // Win rate percentage
double profitFactor;           // Gross profit / gross loss
double sharpeRatio;            // Risk-adjusted return
double maxDrawdown;            // Maximum drawdown percentage
double avgWin;                 // Average winning trade
double avgLoss;                // Average losing trade
double totalTrades;            // Total number of trades
double totalProfit;            // Total profit/loss
datetime evaluationPeriod;     // Period length for evaluation
double fitnessScore;           // Overall fitness score

void Reset()
{
winRate = 0.0;
profitFactor = 0.0;
sharpeRatio = 0.0;
maxDrawdown = 0.0;
avgWin = 0.0;
avgLoss = 0.0;
totalTrades = 0.0;
totalProfit = 0.0;
evaluationPeriod = 0;
fitnessScore = 0.0;
}

void CalculateFitnessScore()
{
// Multi-objective fitness function
double winRateScore = winRate * 0.3;              // 30% weight
double profitFactorScore = MathMin(profitFactor / 2.0, 1.0) * 0.25; // 25% weight
double drawdownScore = (1.0 - maxDrawdown / 0.15) * 0.25;           // 25% weight
double tradeCountScore = MathMin(totalTrades / 100.0, 1.0) * 0.20;   // 20% weight

fitnessScore = winRateScore + profitFactorScore + drawdownScore + tradeCountScore;
fitnessScore = MathMax(0.0, MathMin(1.0, fitnessScore));
}
};

//+------------------------------------------------------------------+
//| Market Regime Data                                               |
//+------------------------------------------------------------------+
struct MarketRegimeData
{
ENUM_MARKET_REGIME currentRegime;   // Current market regime
ENUM_MARKET_REGIME previousRegime;  // Previous regime
double regimeConfidence;            // Confidence in regime classification
datetime regimeStartTime;           // When current regime started
int regimeDuration;                 // Duration in bars
double volatilityLevel;             // Current volatility (0-1)
double trendStrength;               // Trend strength (-1 to 1)
bool regimeChanged;                 // Flag for regime change

void Reset()
{
currentRegime = REGIME_UNKNOWN;
previousRegime = REGIME_UNKNOWN;
regimeConfidence = 0.0;
regimeStartTime = 0;
regimeDuration = 0;
volatilityLevel = 0.0;
trendStrength = 0.0;
regimeChanged = false;
}
};

//+------------------------------------------------------------------+
//| ?? ADAPTIVE PARAMETER OPTIMIZATION SYSTEM                       |
//+------------------------------------------------------------------+
class CAdaptiveParameterOptimization
{
private:
// Parameter sets for different market regimes
OptimizableParameters m_currentParams;           // Currently active parameters
OptimizableParameters m_regimeParams[7];         // Parameters for each regime
OptimizableParameters m_bestParams;              // Best performing parameters
OptimizableParameters m_defaultParams;           // Default fallback parameters

// Market regime analysis
MarketRegimeData m_marketRegime;

// Performance tracking
AIPerformanceMetrics m_currentPerformance;
AIPerformanceMetrics m_regimePerformance[7];       // Performance per regime
AIPerformanceMetrics m_bestPerformance;            // Best performance achieved

// Optimization state
bool m_optimizationEnabled;                      // Whether optimization is active
bool m_learningMode;                             // Whether in learning mode
int m_evaluationPeriodBars;                      // Bars for performance evaluation
int m_minTradesForOptimization;                  // Minimum trades before optimization
double m_improvementThreshold;                   // Minimum improvement to change params

// Adaptation history
datetime m_lastOptimization;                     // When last optimization occurred
int m_optimizationInterval;                      // Hours between optimizations
int m_totalOptimizations;                        // Total optimizations performed

// Market data for regime detection
double m_priceData[50];                          // Recent price data
double m_volumeData[50];                         // Recent volume data
int m_dataCount;                                 // Current data count

public:
CAdaptiveParameterOptimization()
{
m_optimizationEnabled = true;
m_learningMode = true;
m_evaluationPeriodBars = 100;        // Evaluate over 100 bars
m_minTradesForOptimization = 20;     // Need 20 trades minimum
m_improvementThreshold = 0.05;       // 5% improvement threshold
m_optimizationInterval = 6;          // Optimize every 6 hours
m_totalOptimizations = 0;
m_dataCount = 0;

// Initialize default parameters
m_defaultParams.SetDefaults();
m_currentParams = m_defaultParams;
m_bestParams = m_defaultParams;

// Initialize regime-specific parameters
InitializeRegimeParameters();

// Reset performance metrics
m_currentPerformance.Reset();
m_bestPerformance.Reset();
for(int i = 0; i < 7; i++) {
m_regimePerformance[i].Reset();
}

m_marketRegime.Reset();
m_lastOptimization = TimeCurrent();

Print("[?? ADAPTIVE] Adaptive Parameter Optimization initialized");
}

//+------------------------------------------------------------------+
//| ?? MAIN PARAMETER ADAPTATION METHOD                             |
//+------------------------------------------------------------------+
void AdaptParameters()
{
// Update market regime
UpdateMarketRegime();

// Check if it's time for optimization
if(!ShouldOptimize()) return;

// Evaluate current performance
EvaluateCurrentPerformance();

// Optimize parameters based on current regime
OptimizeForCurrentRegime();

// Apply optimized parameters
ApplyOptimizedParameters();

m_lastOptimization = TimeCurrent();
m_totalOptimizations++;

Print(StringFormat("[?? ADAPTIVE] Parameter optimization #%d completed for regime: %s",
m_totalOptimizations, GetRegimeString(m_marketRegime.currentRegime)));
}

//+------------------------------------------------------------------+
//| ?? MARKET REGIME DETECTION                                      |
//+------------------------------------------------------------------+
void UpdateMarketRegime()
{
// Update market data
UpdateMarketData();

if(m_dataCount < 20) {
m_marketRegime.currentRegime = REGIME_UNKNOWN;
return;
}

// Calculate market characteristics
double volatility = CalculateVolatility();
double trendStrength = CalculateTrendStrength();
double momentum = CalculateMomentum();

m_marketRegime.volatilityLevel = volatility;
m_marketRegime.trendStrength = trendStrength;

// Classify regime
ENUM_MARKET_REGIME newRegime = ClassifyMarketRegime(volatility, trendStrength, momentum);

// Check for regime change
if(newRegime != m_marketRegime.currentRegime) {
m_marketRegime.previousRegime = m_marketRegime.currentRegime;
m_marketRegime.currentRegime = newRegime;
m_marketRegime.regimeStartTime = TimeCurrent();
m_marketRegime.regimeDuration = 0;
m_marketRegime.regimeChanged = true;

Print(StringFormat("[?? REGIME] Market regime changed: %s . %s",
GetRegimeString(m_marketRegime.previousRegime),
GetRegimeString(m_marketRegime.currentRegime)));
} else {
m_marketRegime.regimeDuration++;
m_marketRegime.regimeChanged = false;
}

// Calculate confidence in regime classification
m_marketRegime.regimeConfidence = CalculateRegimeConfidence(volatility, trendStrength);
}

//+------------------------------------------------------------------+
//| ?? REGIME CLASSIFICATION LOGIC                                  |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME ClassifyMarketRegime(double volatility, double trendStrength, double momentum)
{
double volThresholdLow = 0.3;
double volThresholdHigh = 0.7;
double trendThresholdStrong = 0.6;
double trendThresholdWeak = 0.2;

// Strong trending markets
if(MathAbs(trendStrength) > trendThresholdStrong) {
if(trendStrength > 0) return REGIME_TRENDING_BULLISH;
else return REGIME_TRENDING_BEARISH;
}

// Ranging markets
if(MathAbs(trendStrength) < trendThresholdWeak) {
if(volatility > volThresholdHigh) return REGIME_VOLATILE;
else if(volatility < volThresholdLow) return REGIME_RANGING_TIGHT;
else return REGIME_RANGING;
}

// Transitional states
if(volatility > volThresholdHigh && MathAbs(momentum) > 0.5) {
return REGIME_BREAKOUT;
}

// Check for reversal patterns
if(DetectReversalPattern()) {
return REGIME_TRENDING_WEAK;
}

// Default to consolidation
return REGIME_RANGING;
}

//+------------------------------------------------------------------+
//| ?? PARAMETER OPTIMIZATION FOR CURRENT REGIME                   |
//+------------------------------------------------------------------+
void OptimizeForCurrentRegime()
{
ENUM_MARKET_REGIME regime = m_marketRegime.currentRegime;

if(regime == REGIME_UNKNOWN) return;

// Get current regime parameters
OptimizableParameters regimeParams = m_regimeParams[(int)regime];

// Apply regime-specific adaptations
switch(regime) {
case REGIME_TRENDING_BULLISH:
case REGIME_TRENDING_BEARISH:
OptimizeForTrendingMarket(regimeParams);
break;

case REGIME_VOLATILE:
OptimizeForHighVolatilityRanging(regimeParams);
break;

case REGIME_RANGING_TIGHT:
OptimizeForLowVolatilityRanging(regimeParams);
break;

case REGIME_BREAKOUT:
OptimizeForBreakout(regimeParams);
break;

case REGIME_TRENDING_WEAK:
OptimizeForReversal(regimeParams);
break;

case REGIME_RANGING:
OptimizeForConsolidation(regimeParams);
break;
}

// Update regime parameters
m_regimeParams[(int)regime] = regimeParams;
}

//+------------------------------------------------------------------+
//| ?? REGIME-SPECIFIC OPTIMIZATION METHODS                        |
//+------------------------------------------------------------------+

void OptimizeForTrendingMarket(OptimizableParameters& params)
{
// Trending markets: favor trend-following signals
params.dragonBandWeight = 0.30;       // Increase trend weight
params.wavePatternWeight = 0.25;      // Increase wave pattern weight
params.confluenceThreshold = 0.60;    // Lower threshold for trend signals
params.dynamicRRMultiplier = 2.5;     // Higher reward for trends
params.processingFrequency = 3;       // More frequent analysis

// Adjust for volatility
params.volatilityAdjustment = 1.0 + (m_marketRegime.volatilityLevel * 0.3);

params.ApplyBounds();
}

void OptimizeForHighVolatilityRanging(OptimizableParameters& params)
{
// High vol ranging: be more selective, use mean reversion
params.confluenceThreshold = 0.75;    // Higher threshold
params.pvsraWeight = 0.30;            // Increase PVSRA weight for reversals
params.smcWeight = 0.20;              // Increase SMC weight
params.maxRiskPercent = 1.5;          // Reduce risk
params.dynamicRRMultiplier = 1.8;     // Lower R:R for quick profits
params.signalValidityPeriod = 10;     // Shorter validity

params.ApplyBounds();
}

void OptimizeForLowVolatilityRanging(OptimizableParameters& params)
{
// Low vol ranging: avoid trading or use very tight parameters
params.confluenceThreshold = 0.80;    // Very high threshold
params.maxRiskPercent = 1.0;          // Minimal risk
params.processingFrequency = 8;       // Less frequent analysis
params.signalValidityPeriod = 20;     // Longer validity

params.ApplyBounds();
}

void OptimizeForBreakout(OptimizableParameters& params)
{
// Breakout: favor momentum and volume
params.dragonBandWeight = 0.25;
params.pvsraWeight = 0.30;            // Volume confirmation important
params.confluenceThreshold = 0.65;
params.dynamicRRMultiplier = 3.0;     // High R:R for breakouts
params.maxRiskPercent = 2.5;          // Higher risk for opportunity

params.ApplyBounds();
}

void OptimizeForReversal(OptimizableParameters& params)
{
// Reversal: focus on reversal patterns
params.wavePatternWeight = 0.30;      // Wave patterns important for reversals
params.pvsraWeight = 0.25;            // Volume divergence
params.confluenceThreshold = 0.70;    // Higher threshold for reversals
params.dynamicRRMultiplier = 2.0;     // Moderate R:R

params.ApplyBounds();
}

void OptimizeForConsolidation(OptimizableParameters& params)
{
// Consolidation: reduce activity, wait for clarity
params.confluenceThreshold = 0.75;
params.processingFrequency = 6;
params.maxRiskPercent = 1.5;
params.signalValidityPeriod = 25;

params.ApplyBounds();
}

//+------------------------------------------------------------------+
//| ?? HELPER METHODS                                               |
//+------------------------------------------------------------------+

void UpdateMarketData()
{
// Get recent price data
double closes[];
long volumes[];

ArraySetAsSeries(closes, true);
ArraySetAsSeries(volumes, true);

int copied = MathMin(50, CopyClose(_Symbol, PERIOD_H1, 0, 50, closes));
if(copied < 20) return;

CopyTickVolume(_Symbol, PERIOD_H1, 0, copied, volumes);

m_dataCount = copied;
for(int i = 0; i < copied; i++) {
m_priceData[i] = closes[i];
m_volumeData[i] = (double)volumes[i];
}
}

double CalculateVolatility()
{
if(m_dataCount < 20) return 0.5;

// Calculate ATR-based volatility
double sum = 0.0;
for(int i = 1; i < 20; i++) {
double range = MathAbs(m_priceData[i-1] - m_priceData[i]);
sum += range;
}

double avgRange = sum / 19;
double currentPrice = m_priceData[0];
double volatility = (currentPrice > 0) ? avgRange / currentPrice : 0.0;

return MathMin(1.0, volatility * 100); // Normalize to 0-1
}

double CalculateTrendStrength()
{
if(m_dataCount < 20) return 0.0;

// Linear regression slope
double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
int n = 20;

for(int i = 0; i < n; i++) {
double x = i;
double y = m_priceData[i];
sumX += x;
sumY += y;
sumXY += x * y;
sumX2 += x * x;
}

double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

// Normalize slope
double avgPrice = sumY / n;
double normalizedSlope = (avgPrice > 0) ? slope / avgPrice : 0.0;

return MathMax(-1.0, MathMin(1.0, normalizedSlope * 1000)); // Scale and bound
}

double CalculateMomentum()
{
if(m_dataCount < 10) return 0.0;

double momentum = (m_priceData[0] - m_priceData[9]) / m_priceData[9];
return MathMax(-1.0, MathMin(1.0, momentum * 100));
}

double CalculateRegimeConfidence(double volatility, double trendStrength)
{
// Higher confidence when characteristics are clear
double volConfidence = (volatility < 0.3 || volatility > 0.7) ? 0.8 : 0.5;
double trendConfidence = (MathAbs(trendStrength) > 0.5) ? 0.8 : 0.5;

return (volConfidence + trendConfidence) / 2.0;
}

bool DetectReversalPattern()
{
// Simplified reversal detection
if(m_dataCount < 10) return false;

// Check for momentum divergence
double recentMomentum = (m_priceData[0] - m_priceData[4]) / m_priceData[4];
double olderMomentum = (m_priceData[5] - m_priceData[9]) / m_priceData[9];

return (recentMomentum * olderMomentum < 0 && MathAbs(recentMomentum - olderMomentum) > 0.01);
}

bool ShouldOptimize()
{
if(!m_optimizationEnabled) return false;

// Check time interval
datetime currentTime = TimeCurrent();
if(currentTime - m_lastOptimization < m_optimizationInterval * 3600) return false;

// Check minimum trades
if(m_currentPerformance.totalTrades < m_minTradesForOptimization) return false;

// Check if regime has changed
if(m_marketRegime.regimeChanged) return true;

// Regular optimization interval
return true;
}

void EvaluateCurrentPerformance()
{
// This would evaluate real trading performance
// For now, simulate performance evaluation
m_currentPerformance.totalTrades = 25;
m_currentPerformance.winRate = 0.68;
m_currentPerformance.profitFactor = 1.8;
m_currentPerformance.maxDrawdown = 0.08;
m_currentPerformance.CalculateFitnessScore();
}

void ApplyOptimizedParameters()
{
ENUM_MARKET_REGIME regime = m_marketRegime.currentRegime;
if(regime != REGIME_UNKNOWN) {
m_currentParams = m_regimeParams[(int)regime];

// Check if this is better than best performance
if(m_currentPerformance.fitnessScore > m_bestPerformance.fitnessScore) {
m_bestParams = m_currentParams;
m_bestPerformance = m_currentPerformance;
}
}
}

void InitializeRegimeParameters()
{
// Initialize all regime parameters with defaults
for(int i = 0; i < 7; i++) {
m_regimeParams[i].SetDefaults();
}
}

string GetRegimeString(ENUM_MARKET_REGIME regime)
{
switch(regime) {
case REGIME_TRENDING_BULLISH: return "Trending Bullish";
case REGIME_TRENDING_BEARISH: return "Trending Bearish";
case REGIME_VOLATILE: return "Volatile";
case REGIME_RANGING_TIGHT: return "Ranging Tight";
case REGIME_BREAKOUT: return "Breakout";
case REGIME_TRENDING_WEAK: return "Trending Weak";
case REGIME_RANGING: return "Ranging";
default: return "Unknown";
}
}

// Public interface
OptimizableParameters GetCurrentParameters() const { return m_currentParams; }
MarketRegimeData GetMarketRegime() const { return m_marketRegime; }
AIPerformanceMetrics GetCurrentPerformance() const { return m_currentPerformance; }
bool IsOptimizationEnabled() const { return m_optimizationEnabled; }

void SetOptimizationEnabled(bool enabled) { m_optimizationEnabled = enabled; }
void SetLearningMode(bool enabled) { m_learningMode = enabled; }

string GetAdaptiveOptimizationReport()
{
return StringFormat(
"?? ADAPTIVE PARAMETER OPTIMIZATION\n" +
"Current Regime: %s (%.1f%% confidence)\n" +
"Optimization Enabled: %s\n" +
"Total Optimizations: %d\n" +
"Current Confluence Threshold: %.1f%%\n" +
"Current Max Risk: %.1f%%\n" +
"Current R:R Multiplier: %.1f\n" +
"Processing Frequency: Every %d ticks\n" +
"Current Performance: %.1f%% win rate, %.2f PF\n" +
"Best Performance: %.1f%% win rate, %.2f PF",
GetRegimeString(m_marketRegime.currentRegime),
m_marketRegime.regimeConfidence * 100,
m_optimizationEnabled ? "YES" : "NO",
m_totalOptimizations,
m_currentParams.confluenceThreshold * 100,
m_currentParams.maxRiskPercent,
m_currentParams.dynamicRRMultiplier,
m_currentParams.processingFrequency,
m_currentPerformance.winRate * 100,
m_currentPerformance.profitFactor,
m_bestPerformance.winRate * 100,
m_bestPerformance.profitFactor
);
}
};

#endif // AI_ADAPTIVE_PARAMETER_OPTIMIZATION_MQH 


