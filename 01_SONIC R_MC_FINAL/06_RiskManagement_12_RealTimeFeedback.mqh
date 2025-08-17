//+------------------------------------------------------------------+
//|                            Risk_RealTimePerformanceFeedback.mqh |
//|              SONIC R MC - REAL-TIME PERFORMANCE FEEDBACK LOOP    |
//|                   🎯 QUYẾT ĐỊNH SỐ 9: FEEDBACK BREAKTHROUGH      |
//+------------------------------------------------------------------+

#ifndef RISK_REAL_TIME_PERFORMANCE_FEEDBACK_MQH
#define RISK_REAL_TIME_PERFORMANCE_FEEDBACK_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| Performance Trend Analysis                                       |
//+------------------------------------------------------------------+
enum ENUM_PERFORMANCE_TREND
{
TREND_STRONG_UP,        // Strong upward performance trend
TREND_MODERATE_UP,      // Moderate upward trend
TREND_FLAT,             // Flat/sideways performance
TREND_MODERATE_DOWN,    // Moderate downward trend
TREND_STRONG_DOWN,      // Strong downward trend
TREND_VOLATILE,         // Highly volatile, no clear trend
TREND_INSUFFICIENT      // Insufficient data for trend analysis
};

//+------------------------------------------------------------------+
//| Real-Time Performance Metrics                                   |
//+------------------------------------------------------------------+
struct RealTimePerformanceData
{
// Recent performance tracking (sliding windows)
double recentWinRate10;           // Win rate last 10 trades
double recentWinRate20;           // Win rate last 20 trades
double recentWinRate50;           // Win rate last 50 trades

double recentProfitFactor10;      // Profit factor last 10 trades
double recentProfitFactor20;      // Profit factor last 20 trades
double recentProfitFactor50;      // Profit factor last 50 trades

// Consecutive performance tracking
int consecutiveWins;              // Current winning streak
int consecutiveLosses;            // Current losing streak
double consecutiveWinProfit;      // Profit from current win streak
double consecutiveLossAmount;     // Loss from current loss streak

// Performance trend analysis
ENUM_PERFORMANCE_TREND performanceTrend;
double trendStrength;             // Strength of current trend (0-1)
double trendDuration;             // How long trend has persisted
double trendConfidence;           // Confidence in trend assessment

// Risk adjustment factors
double adaptiveRiskMultiplier;    // Overall risk adjustment
double winStreakAdjustment;       // Adjustment for winning streaks
double lossStreakAdjustment;      // Adjustment for losing streaks
double volatilityAdjustment;      // Adjustment for performance volatility

// Performance quality metrics
double performanceQuality;        // Overall performance quality score
double consistencyScore;          // How consistent the performance is
double stabilityScore;            // How stable the performance is
double recoveryScore;             // How well system recovers from losses

// Warning flags
bool performanceWarning;          // General performance warning
bool drawdownWarning;             // Drawdown warning
bool volatilityWarning;           // Performance volatility warning
bool streakWarning;               // Excessive streak warning

void Reset()
{
recentWinRate10 = 0.5;
recentWinRate20 = 0.5;
recentWinRate50 = 0.5;
recentProfitFactor10 = 1.0;
recentProfitFactor20 = 1.0;
recentProfitFactor50 = 1.0;
consecutiveWins = 0;
consecutiveLosses = 0;
consecutiveWinProfit = 0.0;
consecutiveLossAmount = 0.0;
performanceTrend = TREND_INSUFFICIENT;
trendStrength = 0.0;
trendDuration = 0.0;
trendConfidence = 0.0;
adaptiveRiskMultiplier = 1.0;
winStreakAdjustment = 1.0;
lossStreakAdjustment = 1.0;
volatilityAdjustment = 1.0;
performanceQuality = 0.5;
consistencyScore = 0.5;
stabilityScore = 0.5;
recoveryScore = 0.5;
performanceWarning = false;
drawdownWarning = false;
volatilityWarning = false;
streakWarning = false;
}
};

//+------------------------------------------------------------------+
//| Trade Result for Feedback Analysis                              |
//+------------------------------------------------------------------+
struct TradeResult
{
ulong ticket;
datetime openTime;
datetime closeTime;
double openPrice;
double closePrice;
double volume;
double profit;
double commission;
double swap;
bool isWin;
double riskAmount;
double riskRewardRatio;
double holdingTimeHours;
string signal;
double confidence;
};

//+------------------------------------------------------------------+
//| 🎯 REAL-TIME PERFORMANCE FEEDBACK LOOP SYSTEM                   |
//+------------------------------------------------------------------+
class CRealTimePerformanceFeedback
{
private:
RealTimePerformanceData m_performanceData;

// Trade history for analysis
TradeResult m_tradeHistory[200];      // Store last 200 trades
int m_tradeIndex;
int m_tradeCount;

// Performance time series
double m_equityCurve[500];            // Equity progression
double m_dailyReturns[100];           // Daily returns
int m_equityIndex;
int m_equityCount;
int m_dailyIndex;
int m_dailyCount;

// Feedback parameters
double m_feedbackSensitivity;         // How aggressively to adjust
bool m_enableFeedbackLoop;            // Whether feedback is active
double m_minRiskMultiplier;           // Minimum risk multiplier
double m_maxRiskMultiplier;           // Maximum risk multiplier

// Performance thresholds
double m_goodWinRateThreshold;        // Threshold for good win rate
double m_badWinRateThreshold;         // Threshold for bad win rate
double m_goodProfitFactorThreshold;   // Threshold for good profit factor
double m_badProfitFactorThreshold;    // Threshold for bad profit factor

// Adaptive learning parameters
double m_learningRate;                // Rate of parameter adaptation
bool m_conservativeMode;              // Whether in conservative mode
datetime m_lastPerformanceCheck;      // Last performance analysis time

public:
CRealTimePerformanceFeedback() {
m_performanceData.Reset();

// Initialize trade history
for(int i = 0; i < 200; i++) {
m_tradeHistory[i].ticket = 0;
m_tradeHistory[i].profit = 0.0;
m_tradeHistory[i].isWin = false;
}

m_tradeIndex = 0;
m_tradeCount = 0;

// Initialize arrays
ArrayInitialize(m_equityCurve, 0.0);
ArrayInitialize(m_dailyReturns, 0.0);

m_equityIndex = 0;
m_equityCount = 0;
m_dailyIndex = 0;
m_dailyCount = 0;

// Initialize parameters
m_feedbackSensitivity = 1.0;
m_enableFeedbackLoop = true;
m_minRiskMultiplier = 0.3;
m_maxRiskMultiplier = 1.8;

// Initialize thresholds
m_goodWinRateThreshold = 0.7;
m_badWinRateThreshold = 0.5;
m_goodProfitFactorThreshold = 1.8;
m_badProfitFactorThreshold = 1.2;

// Initialize learning parameters
m_learningRate = 0.1;
m_conservativeMode = false;
m_lastPerformanceCheck = TimeCurrent();

::Print("[FEEDBACK] Real-Time Performance Feedback Loop initialized");
::Print("[CONFIGURATION] Sensitivity: ", m_feedbackSensitivity, 
" | Risk Range: ", m_minRiskMultiplier, "x - ", m_maxRiskMultiplier, "x");
};
~CRealTimePerformanceFeedback() {}

//+------------------------------------------------------------------+
//| 🎯 MAIN PERFORMANCE FEEDBACK PROCESSING                        |
//+------------------------------------------------------------------+
void ProcessPerformanceFeedback()
{
// Update performance metrics
UpdatePerformanceMetrics();

// Analyze performance trend
AnalyzePerformanceTrend();

// Calculate adaptive adjustments
CalculateAdaptiveAdjustments();

// Apply feedback corrections
ApplyFeedbackCorrections();

// Update warning system
UpdatePerformanceWarnings();

// Log performance feedback
LogPerformanceFeedback();

m_lastPerformanceCheck = TimeCurrent();
}

//+------------------------------------------------------------------+
//| 🎯 ADD TRADE RESULT FOR ANALYSIS                               |
//+------------------------------------------------------------------+
void AddTradeResult(ulong ticket, double profit, double riskAmount, 
double confidence, string signal)
{
// Store trade result
m_tradeHistory[m_tradeIndex].ticket = ticket;
m_tradeHistory[m_tradeIndex].profit = profit;
m_tradeHistory[m_tradeIndex].riskAmount = riskAmount;
m_tradeHistory[m_tradeIndex].confidence = confidence;
m_tradeHistory[m_tradeIndex].signal = signal;
m_tradeHistory[m_tradeIndex].isWin = (profit > 0);
m_tradeHistory[m_tradeIndex].closeTime = TimeCurrent();

// Calculate additional metrics
if(riskAmount > 0) {
m_tradeHistory[m_tradeIndex].riskRewardRatio = profit / riskAmount;
}

// Update index and count
m_tradeIndex = (m_tradeIndex + 1) % 200;
if(m_tradeCount < 200) m_tradeCount++;

// Update consecutive streaks
UpdateConsecutiveStreaks(profit > 0);

// Trigger immediate feedback processing for significant events
if(ShouldTriggerImmediateFeedback(profit)) {
ProcessPerformanceFeedback();
}
}

//+------------------------------------------------------------------+
//| 🎯 PERFORMANCE METRICS UPDATE                                  |
//+------------------------------------------------------------------+
void UpdatePerformanceMetrics()
{
if(m_tradeCount < 5) {
m_performanceData.Reset();
return;
}

// Calculate win rates for different periods
m_performanceData.recentWinRate10 = CalculateWinRate(10);
m_performanceData.recentWinRate20 = CalculateWinRate(20);
m_performanceData.recentWinRate50 = CalculateWinRate(50);

// Calculate profit factors for different periods
m_performanceData.recentProfitFactor10 = CalculateProfitFactor(10);
m_performanceData.recentProfitFactor20 = CalculateProfitFactor(20);
m_performanceData.recentProfitFactor50 = CalculateProfitFactor(50);

// Calculate quality metrics
CalculatePerformanceQualityMetrics();
}

double CalculateWinRate(int period)
{
if(m_tradeCount == 0) return 0.5;

int trades = MathMin(period, m_tradeCount);
int wins = 0;

for(int i = 0; i < trades; i++) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
if(m_tradeHistory[idx].isWin) wins++;
}

return (double)wins / trades;
}

double CalculateProfitFactor(int period)
{
if(m_tradeCount == 0) return 1.0;

int trades = MathMin(period, m_tradeCount);
double totalProfit = 0.0;
double totalLoss = 0.0;

for(int i = 0; i < trades; i++) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
double profit = m_tradeHistory[idx].profit;
if(profit > 0) totalProfit += profit;
else totalLoss += MathAbs(profit);
}

return (totalLoss > 0) ? totalProfit / totalLoss : 
(totalProfit > 0) ? 10.0 : 1.0;
}

void CalculatePerformanceQualityMetrics()
{
// Performance Quality Score (0-1)
double winRateScore = (m_performanceData.recentWinRate20 - 0.4) / 0.4; // Normalize from 40%
double profitFactorScore = (m_performanceData.recentProfitFactor20 - 1.0) / 2.0; // Normalize from 1.0

winRateScore = MathMax(0.0, MathMin(1.0, winRateScore));
profitFactorScore = MathMax(0.0, MathMin(1.0, profitFactorScore));

m_performanceData.performanceQuality = (winRateScore + profitFactorScore) / 2.0;

// Consistency Score
m_performanceData.consistencyScore = CalculateConsistencyScore();

// Stability Score
m_performanceData.stabilityScore = CalculateStabilityScore();

// Recovery Score
m_performanceData.recoveryScore = CalculateRecoveryScore();
}

double CalculateConsistencyScore()
{
if(m_tradeCount < 10) return 0.5;

// Calculate variance in returns
double mean = 0.0;
int trades = MathMin(20, m_tradeCount);

for(int i = 0; i < trades; i++) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
mean += m_tradeHistory[idx].profit;
}
mean /= trades;

double variance = 0.0;
for(int i = 0; i < trades; i++) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
double diff = m_tradeHistory[idx].profit - mean;
variance += diff * diff;
}
variance /= trades;

// Lower variance = higher consistency
double consistency = 1.0 / (1.0 + variance * 0.0001); // Scale factor
return MathMax(0.0, MathMin(1.0, consistency));
}

double CalculateStabilityScore()
{
if(m_tradeCount < 10) return 0.5;

// Compare different period win rates for stability
double wr10 = m_performanceData.recentWinRate10;
double wr20 = m_performanceData.recentWinRate20;
double wr50 = m_performanceData.recentWinRate50;

double maxDiff = MathMax(MathAbs(wr10 - wr20), MathAbs(wr20 - wr50));

// Lower difference = higher stability
double stability = 1.0 - (maxDiff * 2.0); // Scale factor
return MathMax(0.0, MathMin(1.0, stability));
}

double CalculateRecoveryScore()
{
// Analyze how well the system recovers from losing streaks
if(m_tradeCount < 15) return 0.5;

int recoveryCount = 0;
int lossStreakCount = 0;
bool inLossStreak = false;
int currentStreakLength = 0;

for(int i = m_tradeCount - 1; i >= 0; i--) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
bool isWin = m_tradeHistory[idx].isWin;

if(!isWin) {
if(!inLossStreak) {
inLossStreak = true;
currentStreakLength = 1;
} else {
currentStreakLength++;
}
} else {
if(inLossStreak && currentStreakLength >= 2) {
// End of loss streak, check for recovery
lossStreakCount++;
// Check next few trades for recovery
bool recovered = false;
for(int j = i + 1; j < MathMin(i + 4, m_tradeCount); j++) {
int recoveryIdx = (m_tradeIndex - j - 1 + 200) % 200;
if(m_tradeHistory[recoveryIdx].isWin) {
recovered = true;
break;
}
}
if(recovered) recoveryCount++;
}
inLossStreak = false;
currentStreakLength = 0;
}
}

return (lossStreakCount > 0) ? (double)recoveryCount / lossStreakCount : 0.8;
}

//+------------------------------------------------------------------+
//| 🎯 PERFORMANCE TREND ANALYSIS                                  |
//+------------------------------------------------------------------+
void AnalyzePerformanceTrend()
{
if(m_tradeCount < 10) {
m_performanceData.performanceTrend = TREND_INSUFFICIENT;
return;
}

// Calculate recent vs older performance
double recentPerf = CalculateAverageReturn(10);  // Last 10 trades
double olderPerf = CalculateAverageReturn(20, 10); // Trades 11-20

double perfDiff = recentPerf - olderPerf;
double perfVolatility = CalculateReturnVolatility(20);

// Determine trend
if(perfDiff > perfVolatility * 0.5) {
if(perfDiff > perfVolatility) {
m_performanceData.performanceTrend = TREND_STRONG_UP;
m_performanceData.trendStrength = 0.8;
} else {
m_performanceData.performanceTrend = TREND_MODERATE_UP;
m_performanceData.trendStrength = 0.6;
}
} else if(perfDiff < -perfVolatility * 0.5) {
if(perfDiff < -perfVolatility) {
m_performanceData.performanceTrend = TREND_STRONG_DOWN;
m_performanceData.trendStrength = 0.8;
} else {
m_performanceData.performanceTrend = TREND_MODERATE_DOWN;
m_performanceData.trendStrength = 0.6;
}
} else if(perfVolatility > CalculateAverageVolatility() * 1.5) {
m_performanceData.performanceTrend = TREND_VOLATILE;
m_performanceData.trendStrength = 0.4;
} else {
m_performanceData.performanceTrend = TREND_FLAT;
m_performanceData.trendStrength = 0.2;
}

// Calculate trend confidence
m_performanceData.trendConfidence = MathMin(1.0, m_performanceData.trendStrength * 
(m_tradeCount / 20.0));
}

double CalculateAverageReturn(int period, int offset = 0)
{
if(m_tradeCount <= offset) return 0.0;

int trades = MathMin(period, m_tradeCount - offset);
if(trades <= 0) return 0.0;

double sum = 0.0;
for(int i = offset; i < offset + trades; i++) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
sum += m_tradeHistory[idx].profit;
}

return sum / trades;
}

double CalculateReturnVolatility(int period)
{
if(m_tradeCount < period) return 1.0;

double mean = CalculateAverageReturn(period);
double variance = 0.0;

for(int i = 0; i < period; i++) {
int idx = (m_tradeIndex - i - 1 + 200) % 200;
double diff = m_tradeHistory[idx].profit - mean;
variance += diff * diff;
}

return MathSqrt(variance / period);
}

double CalculateAverageVolatility()
{
// Calculate historical average volatility for comparison
return CalculateReturnVolatility(MathMin(50, m_tradeCount));
}

//+------------------------------------------------------------------+
//| 🎯 ADAPTIVE ADJUSTMENTS CALCULATION                            |
//+------------------------------------------------------------------+
void CalculateAdaptiveAdjustments()
{
// Base adjustment starts at neutral
m_performanceData.adaptiveRiskMultiplier = 1.0;

// Adjust based on performance trend
AdjustForPerformanceTrend();

// Adjust for consecutive streaks
AdjustForConsecutiveStreaks();

// Adjust for win rate performance
AdjustForWinRatePerformance();

// Adjust for profit factor performance
AdjustForProfitFactorPerformance();

// Adjust for performance volatility
AdjustForPerformanceVolatility();

// Apply safety bounds
ApplyAdjustmentBounds();
}

void AdjustForPerformanceTrend()
{
double adjustment = 1.0;

switch(m_performanceData.performanceTrend) {
case TREND_STRONG_UP:
// Gradually increase risk for strong uptrend
adjustment = 1.0 + (m_performanceData.trendStrength * 0.3);
break;

case TREND_MODERATE_UP:
// Slight increase for moderate uptrend
adjustment = 1.0 + (m_performanceData.trendStrength * 0.15);
break;

case TREND_FLAT:
// Neutral for flat performance
adjustment = 1.0;
break;

case TREND_MODERATE_DOWN:
// Reduce risk for downtrend
adjustment = 1.0 - (m_performanceData.trendStrength * 0.2);
break;

case TREND_STRONG_DOWN:
// Significantly reduce risk for strong downtrend
adjustment = 1.0 - (m_performanceData.trendStrength * 0.4);
break;

case TREND_VOLATILE:
// Reduce risk during high volatility
adjustment = 1.0 - (m_performanceData.trendStrength * 0.3);
break;
}

// Apply trend confidence weighting
adjustment = 1.0 + (adjustment - 1.0) * m_performanceData.trendConfidence;
m_performanceData.adaptiveRiskMultiplier *= adjustment;
}

void AdjustForConsecutiveStreaks()
{
// Win streak adjustment
if(m_performanceData.consecutiveWins >= 5) {
m_performanceData.winStreakAdjustment = 1.0 + (m_performanceData.consecutiveWins - 4) * 0.05;
m_performanceData.winStreakAdjustment = MathMin(1.3, m_performanceData.winStreakAdjustment);
} else {
m_performanceData.winStreakAdjustment = 1.0;
}

// Loss streak adjustment
if(m_performanceData.consecutiveLosses >= 3) {
m_performanceData.lossStreakAdjustment = 1.0 - (m_performanceData.consecutiveLosses - 2) * 0.1;
m_performanceData.lossStreakAdjustment = MathMax(0.6, m_performanceData.lossStreakAdjustment);
} else {
m_performanceData.lossStreakAdjustment = 1.0;
}

// Apply the more conservative adjustment
double streakAdjustment = MathMin(m_performanceData.winStreakAdjustment,
m_performanceData.lossStreakAdjustment);
m_performanceData.adaptiveRiskMultiplier *= streakAdjustment;
}

void AdjustForWinRatePerformance()
{
double winRate = m_performanceData.recentWinRate20;
double adjustment = 1.0;

if(winRate > m_goodWinRateThreshold) {
// Good win rate: gradually increase risk
adjustment = 1.0 + (winRate - m_goodWinRateThreshold) * 0.5;
} else if(winRate < m_badWinRateThreshold) {
// Poor win rate: reduce risk
adjustment = 1.0 - (m_badWinRateThreshold - winRate) * 1.0;
}

m_performanceData.adaptiveRiskMultiplier *= adjustment;
}

void AdjustForProfitFactorPerformance()
{
double pf = m_performanceData.recentProfitFactor20;
double adjustment = 1.0;

if(pf > m_goodProfitFactorThreshold) {
// Good profit factor: increase risk
adjustment = 1.0 + (pf - m_goodProfitFactorThreshold) * 0.1;
} else if(pf < m_badProfitFactorThreshold) {
// Poor profit factor: reduce risk
adjustment = 1.0 - (m_badProfitFactorThreshold - pf) * 0.3;
}

m_performanceData.adaptiveRiskMultiplier *= adjustment;
}

void AdjustForPerformanceVolatility()
{
// Reduce risk if performance is highly volatile
double consistency = m_performanceData.consistencyScore;
double stability = m_performanceData.stabilityScore;

double volatilityAdjustment = (consistency + stability) / 2.0;
volatilityAdjustment = 0.7 + (volatilityAdjustment * 0.3); // Scale to 0.7-1.0

m_performanceData.volatilityAdjustment = volatilityAdjustment;
m_performanceData.adaptiveRiskMultiplier *= volatilityAdjustment;
}

void ApplyAdjustmentBounds()
{
m_performanceData.adaptiveRiskMultiplier = MathMax(m_minRiskMultiplier,
MathMin(m_maxRiskMultiplier,
m_performanceData.adaptiveRiskMultiplier));
}

//+------------------------------------------------------------------+
//| 🎯 FEEDBACK CORRECTIONS APPLICATION                            |
//+------------------------------------------------------------------+
void ApplyFeedbackCorrections()
{
// This is where the system would actually adjust trading parameters
// based on the calculated feedback adjustments

// Examples of what could be adjusted:
// - Signal confidence thresholds
// - Risk per trade
// - Take profit / stop loss ratios
// - Trading frequency

if(m_performanceData.adaptiveRiskMultiplier < 0.8) {
// Defensive mode: reduce activity
m_conservativeMode = true;
} else if(m_performanceData.adaptiveRiskMultiplier > 1.2) {
// Aggressive mode: can increase activity
m_conservativeMode = false;
}
}

//+------------------------------------------------------------------+
//| 🎯 WARNING SYSTEM                                              |
//+------------------------------------------------------------------+
void UpdatePerformanceWarnings()
{
// Reset warnings
m_performanceData.performanceWarning = false;
m_performanceData.drawdownWarning = false;
m_performanceData.volatilityWarning = false;
m_performanceData.streakWarning = false;

// Check performance warnings
if(m_performanceData.recentWinRate20 < 0.4 || 
m_performanceData.recentProfitFactor20 < 1.0) {
m_performanceData.performanceWarning = true;
::Print("[PERFORMANCE] Poor recent performance detected");
}

// Check streak warnings
if(m_performanceData.consecutiveLosses >= 5) {
m_performanceData.streakWarning = true;
::Print("[STREAK] Excessive losing streak: ", m_performanceData.consecutiveLosses);
}

// Check volatility warnings
if(m_performanceData.consistencyScore < 0.3) {
m_performanceData.volatilityWarning = true;
::Print("[VOLATILITY] High performance volatility detected");
}

// Check drawdown (simplified)
if(m_performanceData.consecutiveLossAmount > 1000.0) { // Adjust threshold as needed
m_performanceData.drawdownWarning = true;
::Print("[DRAWDOWN] Significant drawdown detected");
}
}

//+------------------------------------------------------------------+
//| 🎯 HELPER METHODS                                              |
//+------------------------------------------------------------------+
void UpdateConsecutiveStreaks(bool isWin)
{
if(isWin) {
m_performanceData.consecutiveWins++;
m_performanceData.consecutiveLosses = 0;
m_performanceData.consecutiveLossAmount = 0.0;

// Update win profit
if(m_tradeCount > 0) {
int idx = (m_tradeIndex - 1 + 200) % 200;
m_performanceData.consecutiveWinProfit += m_tradeHistory[idx].profit;
}
} else {
m_performanceData.consecutiveLosses++;
m_performanceData.consecutiveWins = 0;
m_performanceData.consecutiveWinProfit = 0.0;

// Update loss amount
if(m_tradeCount > 0) {
int idx = (m_tradeIndex - 1 + 200) % 200;
m_performanceData.consecutiveLossAmount += MathAbs(m_tradeHistory[idx].profit);
}
}
}

bool ShouldTriggerImmediateFeedback(double profit)
{
// Trigger immediate feedback for significant events
return (MathAbs(profit) > 500.0 ||  // Large profit/loss
m_performanceData.consecutiveLosses >= 3 ||  // Loss streak
m_performanceData.consecutiveWins >= 5);     // Win streak
}

void LogPerformanceFeedback()
{
static datetime lastLog = 0;
if(TimeCurrent() - lastLog < 3600) return; // Log hourly

::Print(StringFormat("[FEEDBACK] Trend: %s | Quality: %.2f | Risk Mult: %.2fx | Conservative: %s",
PerformanceTrendToString(m_performanceData.performanceTrend),
m_performanceData.performanceQuality,
m_performanceData.adaptiveRiskMultiplier,
m_conservativeMode ? "YES" : "NO"));

lastLog = TimeCurrent();
}

string PerformanceTrendToString(ENUM_PERFORMANCE_TREND trend)
{
switch(trend) {
case TREND_STRONG_UP: return "STRONG_UP";
case TREND_MODERATE_UP: return "MODERATE_UP";
case TREND_FLAT: return "FLAT";
case TREND_MODERATE_DOWN: return "MODERATE_DOWN";
case TREND_STRONG_DOWN: return "STRONG_DOWN";
case TREND_VOLATILE: return "VOLATILE";
default: return "UNKNOWN";
}
}

// Public interface methods
double GetAdaptiveRiskMultiplier() const { return m_performanceData.adaptiveRiskMultiplier; }
RealTimePerformanceData GetPerformanceData() const { return m_performanceData; }
bool IsInConservativeMode() const { return m_conservativeMode; }
bool HasPerformanceWarning() const { return m_performanceData.performanceWarning; }

void SetFeedbackSensitivity(double sensitivity) 
{ 
m_feedbackSensitivity = MathMax(0.1, MathMin(2.0, sensitivity)); 
}

void SetRiskMultiplierBounds(double minMult, double maxMult)
{
m_minRiskMultiplier = MathMax(0.2, minMult);
m_maxRiskMultiplier = MathMin(2.0, maxMult);
}

void EnableFeedbackLoop(bool enable) { m_enableFeedbackLoop = enable; }

string GetPerformanceFeedbackReport()
{
return StringFormat(
"REAL-TIME PERFORMANCE FEEDBACK\n" +
"Performance Trend: %s (Strength: %.1f%%, Confidence: %.1f%%)\n" +
"Win Rates - 10T: %.1f%% | 20T: %.1f%% | 50T: %.1f%%\n" +
"Profit Factors - 10T: %.2f | 20T: %.2f | 50T: %.2f\n" +
"Streaks - Wins: %d | Losses: %d\n" +
"Quality Scores - Performance: %.2f | Consistency: %.2f | Stability: %.2f | Recovery: %.2f\n" +
"Adaptive Risk Multiplier: %.2fx\n" +
"Conservative Mode: %s\n" +
"Warnings - Performance: %s | Drawdown: %s | Volatility: %s | Streak: %s",
PerformanceTrendToString(m_performanceData.performanceTrend),
m_performanceData.trendStrength * 100,
m_performanceData.trendConfidence * 100,
m_performanceData.recentWinRate10 * 100,
m_performanceData.recentWinRate20 * 100,
m_performanceData.recentWinRate50 * 100,
m_performanceData.recentProfitFactor10,
m_performanceData.recentProfitFactor20,
m_performanceData.recentProfitFactor50,
m_performanceData.consecutiveWins,
m_performanceData.consecutiveLosses,
m_performanceData.performanceQuality,
m_performanceData.consistencyScore,
m_performanceData.stabilityScore,
m_performanceData.recoveryScore,
m_performanceData.adaptiveRiskMultiplier,
m_conservativeMode ? "YES" : "NO",
m_performanceData.performanceWarning ? "YES" : "NO",
m_performanceData.drawdownWarning ? "YES" : "NO",
m_performanceData.volatilityWarning ? "YES" : "NO",
m_performanceData.streakWarning ? "YES" : "NO"
);
}
};


#endif // RISK_REAL_TIME_PERFORMANCE_FEEDBACK_MQH


