//+------------------------------------------------------------------+
//|                         Analysis_AdvancedSignalProcessing.mqh    |
//|                  SONIC R MC - Advanced Signal Processing         |
//|                    Phase 3: Institutional Grade Analytics        |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_ADVANCED_SIGNAL_PROCESSING_MQH
#define ANALYSIS_ADVANCED_SIGNAL_PROCESSING_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_08_ContextManager.mqh"

//+------------------------------------------------------------------+
//| Advanced Signal Quality Metrics                                  |
//+------------------------------------------------------------------+
struct SignalQualityMetrics
{
double strengthScore;      // 0-1 signal strength
double confluenceScore;    // Multi-factor confluence
double probabilityScore;   // Win probability estimate
double riskRewardScore;    // RR quality
double timingScore;        // Entry timing quality
double overallGrade;       // A-F grade

void Reset()
{
strengthScore = 0;
confluenceScore = 0;
probabilityScore = 0;
riskRewardScore = 0;
timingScore = 0;
overallGrade = 0;
}
};

//+------------------------------------------------------------------+
//| Advanced Signal Processor - Phase 3 Implementation              |
//+------------------------------------------------------------------+
class CAdvancedSignalProcessor
{
private:
// Core components
CEaContext*             m_context;
bool                    m_initialized;

// Signal processing state
SignalQualityMetrics    m_currentMetrics;
double                  m_adaptiveThreshold;
double                  m_marketNoiseLevel;
double                  m_signalClarity;

// Performance tracking
int                     m_totalSignals;
int                     m_successfulSignals;
double                  m_avgQualityScore;

// Advanced filters
bool                    m_useMLFilter;
bool                    m_useNoiseFilter;
bool                    m_useContextFilter;

public:
CAdvancedSignalProcessor() : 
m_initialized(false),
m_context(NULL),
m_adaptiveThreshold(0.7),
m_marketNoiseLevel(0.3),
m_signalClarity(0.5),
m_totalSignals(0),
m_successfulSignals(0),
m_avgQualityScore(0),
m_useMLFilter(true),
m_useNoiseFilter(true),
m_useContextFilter(true)
{
m_currentMetrics.Reset();
}

~CAdvancedSignalProcessor() {}

//+------------------------------------------------------------------+
//| Initialize processor                                             |
//+------------------------------------------------------------------+
bool Initialize(CEaContext* context)
{
if(!context) return false;

m_context = context;
m_initialized = true;

// Calculate initial adaptive threshold based on market
UpdateAdaptiveThreshold();

::Print("[SIGNAL PROCESSOR] Advanced Signal Processing initialized");
::Print("[SIGNAL PROCESSOR] Adaptive threshold: ", m_adaptiveThreshold);

return true;
}

//+------------------------------------------------------------------+
//| Process and enhance signal quality                               |
//+------------------------------------------------------------------+
bool ProcessSignal(ENUM_SIGNAL_TYPE& signal, double& confidence)
{
if(!m_initialized || signal == SIGNAL_NONE) return false;

// Reset metrics for new signal
m_currentMetrics.Reset();

// Step 1: Calculate base signal strength
m_currentMetrics.strengthScore = CalculateSignalStrength(signal);

// Step 2: Multi-factor confluence analysis
m_currentMetrics.confluenceScore = CalculateConfluence(signal);

// Step 3: Win probability estimation
m_currentMetrics.probabilityScore = EstimateWinProbability(signal);

// Step 4: Risk/Reward quality check
m_currentMetrics.riskRewardScore = EvaluateRiskReward(signal);

// Step 5: Timing analysis
m_currentMetrics.timingScore = AnalyzeTiming(signal);

// Calculate overall signal quality
double overallQuality = CalculateOverallQuality();
m_currentMetrics.overallGrade = overallQuality;

// Apply adaptive filtering
if(overallQuality < m_adaptiveThreshold)
{
signal = SIGNAL_NONE;
confidence = 0;
return false;
}

// Enhance confidence based on quality
confidence = EnhanceConfidence(confidence, overallQuality);

// Track performance
m_totalSignals++;
m_avgQualityScore = ((m_avgQualityScore * (m_totalSignals - 1)) + overallQuality) / m_totalSignals;

return true;
}

//+------------------------------------------------------------------+
//| Calculate signal strength using multiple indicators              |
//+------------------------------------------------------------------+
double CalculateSignalStrength(ENUM_SIGNAL_TYPE signal)
{
double strength = 0.5; // Base strength

// Momentum confirmation
double rsi = GetRSI(14);
if(signal == SIGNAL_BUY && rsi > 30 && rsi < 70)
strength += 0.1;
else if(signal == SIGNAL_SELL && rsi > 30 && rsi < 70)
strength += 0.1;

// Trend alignment
double ma50 = GetMA(50);
double ma200 = GetMA(200);
double localPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

if(signal == SIGNAL_BUY && localPrice > ma50 && ma50 > ma200)
strength += 0.2;
else if(signal == SIGNAL_SELL && localPrice < ma50 && ma50 < ma200)
strength += 0.2;

// Volume confirmation
if(IsVolumeAboveAverage())
strength += 0.1;

// Market structure
if(IsKeyLevel(localPrice))
strength += 0.1;

return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| Calculate multi-factor confluence                                |
//+------------------------------------------------------------------+
double CalculateConfluence(ENUM_SIGNAL_TYPE signal)
{
int confluenceFactors = 0;
int totalFactors = 0;

// Technical confluence
totalFactors++;
if(CheckTechnicalConfluence(signal)) confluenceFactors++;

// Price action confluence
totalFactors++;
if(CheckPriceActionConfluence(signal)) confluenceFactors++;

// Volume confluence
totalFactors++;
if(CheckVolumeConfluence(signal)) confluenceFactors++;

// Time confluence (session overlap)
totalFactors++;
if(CheckTimeConfluence()) confluenceFactors++;

// Market structure confluence
totalFactors++;
if(CheckStructureConfluence(signal)) confluenceFactors++;

return (double)confluenceFactors / totalFactors;
}

//+------------------------------------------------------------------+
//| Estimate win probability using historical performance            |
//+------------------------------------------------------------------+
double EstimateWinProbability(ENUM_SIGNAL_TYPE signal)
{
// Base probability from historical win rate
double baseProbability = 0.6; // 60% base win rate

// Adjust based on market conditions
double marketConditionAdjustment = GetMarketConditionAdjustment();

// Adjust based on signal quality
double qualityAdjustment = (m_currentMetrics.strengthScore + m_currentMetrics.confluenceScore) / 2;

// Calculate final probability
double probability = baseProbability * marketConditionAdjustment * qualityAdjustment;

return MathMin(MathMax(probability, 0.3), 0.9); // Cap between 30% and 90%
}

//+------------------------------------------------------------------+
//| Evaluate risk/reward quality                                     |
//+------------------------------------------------------------------+
double EvaluateRiskReward(ENUM_SIGNAL_TYPE signal)
{
double localPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double atr = GetATR(14);

// Find potential stop loss and take profit
double stopLoss = 0;
double takeProfit = 0;

if(signal == SIGNAL_BUY)
{
stopLoss = localPrice - (atr * 1.5);
takeProfit = localPrice + (atr * 3.0);
}
else if(signal == SIGNAL_SELL)
{
stopLoss = localPrice + (atr * 1.5);
takeProfit = localPrice - (atr * 3.0);
}

// Calculate R:R ratio
double risk = MathAbs(localPrice - stopLoss);
double reward = MathAbs(takeProfit - localPrice);
double rrRatio = (risk > 0) ? reward / risk : 0;

// Score based on R:R ratio
if(rrRatio >= 3.0) return 1.0;
else if(rrRatio >= 2.5) return 0.9;
else if(rrRatio >= 2.0) return 0.7;
else if(rrRatio >= 1.5) return 0.5;
else return 0.3;
}

//+------------------------------------------------------------------+
//| Analyze entry timing quality                                     |
//+------------------------------------------------------------------+
double AnalyzeTiming(ENUM_SIGNAL_TYPE signal)
{
double timingScore = 0.5;

// Check if we're at session open/close (usually more volatile)
if(IsNearSessionBoundary())
timingScore -= 0.2;

// Check if we're during high-impact news
if(IsHighImpactNewsTime())
timingScore -= 0.3;

// Check if we're in optimal trading hours
if(IsOptimalTradingHours())
timingScore += 0.2;

// Check momentum timing
if(IsMomentumFavorable(signal))
timingScore += 0.3;

return MathMin(MathMax(timingScore, 0.0), 1.0);
}

//+------------------------------------------------------------------+
//| Calculate overall signal quality                                 |
//+------------------------------------------------------------------+
double CalculateOverallQuality()
{
// Weighted average of all metrics
double weights[] = {0.25, 0.25, 0.20, 0.20, 0.10}; // Strength, Confluence, Probability, RR, Timing

double quality = 
m_currentMetrics.strengthScore * weights[0] +
m_currentMetrics.confluenceScore * weights[1] +
m_currentMetrics.probabilityScore * weights[2] +
m_currentMetrics.riskRewardScore * weights[3] +
m_currentMetrics.timingScore * weights[4];

return quality;
}

//+------------------------------------------------------------------+
//| Enhance confidence based on quality metrics                      |
//+------------------------------------------------------------------+
double EnhanceConfidence(double baseConfidence, double quality)
{
// Apply quality multiplier
double enhancedConfidence = baseConfidence * (0.5 + quality * 0.5);

// Apply noise reduction
if(m_useNoiseFilter && m_marketNoiseLevel > 0.5)
enhancedConfidence *= (1.0 - m_marketNoiseLevel * 0.3);

return MathMin(enhancedConfidence, 1.0);
}

//+------------------------------------------------------------------+
//| Update adaptive threshold based on performance                   |
//+------------------------------------------------------------------+
void UpdateAdaptiveThreshold()
{
if(m_totalSignals < 20) return; // Need minimum signals

double successRate = (m_totalSignals > 0) ? (double)m_successfulSignals / m_totalSignals : 0;

// Adjust threshold based on success rate
if(successRate < 0.5)
m_adaptiveThreshold = MathMin(m_adaptiveThreshold + 0.05, 0.9);
else if(successRate > 0.7)
m_adaptiveThreshold = MathMax(m_adaptiveThreshold - 0.05, 0.6);

// Adjust for market conditions
if(m_marketNoiseLevel > 0.6)
m_adaptiveThreshold = MathMin(m_adaptiveThreshold + 0.1, 0.95);
}

//+------------------------------------------------------------------+
//| Helper methods                                                   |
//+------------------------------------------------------------------+
double GetRSI(int period)
{
int handle = iRSI(_Symbol, PERIOD_CURRENT, period, PRICE_CLOSE);
double buffer[1];
if(CopyBuffer(handle, 0, 0, 1, buffer) > 0)
{
IndicatorRelease(handle);
return buffer[0];
}
IndicatorRelease(handle);
return 50; // Default neutral
}

double GetMA(int period)
{
int handle = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_SMA, PRICE_CLOSE);
double buffer[1];
if(CopyBuffer(handle, 0, 0, 1, buffer) > 0)
{
IndicatorRelease(handle);
return buffer[0];
}
IndicatorRelease(handle);
return 0;
}

double GetATR(int period)
{
int handle = iATR(_Symbol, PERIOD_CURRENT, period);
double buffer[1];
if(CopyBuffer(handle, 0, 0, 1, buffer) > 0)
{
IndicatorRelease(handle);
return buffer[0];
}
IndicatorRelease(handle);
return 0;
}

bool IsVolumeAboveAverage()
{
long volumes[];
if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 20, volumes) < 20) return false;

long avgVolume = 0;
for(int i = 1; i < 20; i++)
avgVolume += volumes[i];
avgVolume /= 19;

return volumes[0] > avgVolume * 1.2;
}

bool IsKeyLevel(double price)
{
// Check if price is near round numbers or key S/R
double roundLevel = MathRound(price / 100) * 100;
return MathAbs(price - roundLevel) < SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 20;
}

bool CheckTechnicalConfluence(ENUM_SIGNAL_TYPE signal)
{
// Check multiple technical indicators alignment
double rsi = GetRSI(14);
double ma50 = GetMA(50);
double localPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

if(signal == SIGNAL_BUY)
return (rsi < 70 && localPrice > ma50);
else
return (rsi > 30 && localPrice < ma50);
}

bool CheckPriceActionConfluence(ENUM_SIGNAL_TYPE signal)
{
// Simplified price action check
return true; // Placeholder - implement candlestick patterns
}

bool CheckVolumeConfluence(ENUM_SIGNAL_TYPE signal)
{
return IsVolumeAboveAverage();
}

bool CheckTimeConfluence()
{
// Check if we're in active session overlap
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);

// London-NY overlap (best liquidity)
return (time.hour >= 13 && time.hour <= 17);
}

bool CheckStructureConfluence(ENUM_SIGNAL_TYPE signal)
{
// Check market structure alignment
return true; // Placeholder - integrate with market structure analysis
}

double GetMarketConditionAdjustment()
{
// Adjust based on current market conditions
double volatility = GetATR(14) / SymbolInfoDouble(_Symbol, SYMBOL_BID);

if(volatility < 0.001) return 0.8;  // Low volatility
else if(volatility > 0.003) return 0.7;  // High volatility
else return 1.0;  // Normal conditions
}

bool IsNearSessionBoundary()
{
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);
return (time.min >= 55 || time.min <= 5);
}

bool IsHighImpactNewsTime()
{
// Placeholder - integrate with news calendar
return false;
}

bool IsOptimalTradingHours()
{
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);
return (time.hour >= 8 && time.hour <= 20);
}

bool IsMomentumFavorable(ENUM_SIGNAL_TYPE signal)
{
double rsi = GetRSI(14);
if(signal == SIGNAL_BUY)
return (rsi > 40 && rsi < 60);
else
return (rsi > 40 && rsi < 60);
}

//+------------------------------------------------------------------+
//| Public getters                                                   |
//+------------------------------------------------------------------+
SignalQualityMetrics GetCurrentMetrics() const { return m_currentMetrics; }
double GetAdaptiveThreshold() const { return m_adaptiveThreshold; }
double GetAverageQualityScore() const { return m_avgQualityScore; }
int GetTotalSignals() const { return m_totalSignals; }

void SignalResult(bool success)
{
if(success) m_successfulSignals++;
UpdateAdaptiveThreshold();
}

string GetQualityReport()
{
string grade = "F";
if(m_currentMetrics.overallGrade >= 0.9) grade = "A";
else if(m_currentMetrics.overallGrade >= 0.8) grade = "B";
else if(m_currentMetrics.overallGrade >= 0.7) grade = "C";
else if(m_currentMetrics.overallGrade >= 0.6) grade = "D";

return StringFormat(
"Signal Quality: %s (%.2f)\n" +
"Strength: %.2f | Confluence: %.2f\n" +
"Probability: %.2f | RR: %.2f | Timing: %.2f\n" +
"Adaptive Threshold: %.2f | Avg Quality: %.2f",
grade, m_currentMetrics.overallGrade,
m_currentMetrics.strengthScore, m_currentMetrics.confluenceScore,
m_currentMetrics.probabilityScore, m_currentMetrics.riskRewardScore,
m_currentMetrics.timingScore,
m_adaptiveThreshold, m_avgQualityScore
);
}
};

#endif // ANALYSIS_ADVANCED_SIGNAL_PROCESSING_MQH


