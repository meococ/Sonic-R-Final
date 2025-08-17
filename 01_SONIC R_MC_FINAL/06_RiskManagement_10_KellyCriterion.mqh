//+------------------------------------------------------------------+
//|                                           Risk_KellyCriterion.mqh |
//|                        SONIC R MC - KELLY CRITERION POSITION SIZING |
//|                            ?? MATHEMATICAL LOT CALCULATION        |
//+------------------------------------------------------------------+

#ifndef RISK_KELLY_CRITERION_MQH
#define RISK_KELLY_CRITERION_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| Kelly Criterion Performance Tracking                             |
//+------------------------------------------------------------------+
struct KellyPerformanceData {
double totalTrades;
double winningTrades;
double losingTrades;
double totalProfit;
double totalLoss;
double largestWin;
double largestLoss;
double avgWin;
double avgLoss;
double winRate;
double profitFactor;
double kellyFraction;
double edgeRatio;
datetime lastUpdate;

void Reset() {
totalTrades = 0;
winningTrades = 0;
losingTrades = 0;
totalProfit = 0;
totalLoss = 0;
largestWin = 0;
largestLoss = 0;
avgWin = 0;
avgLoss = 0;
winRate = 0;
profitFactor = 0;
kellyFraction = 0;
edgeRatio = 0;
lastUpdate = 0;
}

void Calculate() {
if(totalTrades > 0) {
winRate = winningTrades / totalTrades;
avgWin = (winningTrades > 0) ? totalProfit / winningTrades : 0;
avgLoss = (losingTrades > 0) ? totalLoss / losingTrades : 0;
profitFactor = (totalLoss > 0) ? totalProfit / totalLoss : 0;

// Kelly Fraction = (bp - q) / b
// where: b = odds received (avgWin/avgLoss), p = win probability, q = loss probability
if(avgLoss > 0) {
double b = avgWin / avgLoss;  // Odds ratio
double p = winRate;           // Win probability  
double q = 1 - p;            // Loss probability
kellyFraction = (b * p - q) / b;
edgeRatio = (p * avgWin) - (q * avgLoss);
}
}
}
};

//+------------------------------------------------------------------+
//| ?? KELLY CRITERION POSITION SIZER - SONIC R IMPLEMENTATION      |
//+------------------------------------------------------------------+
class CKellyCriterionSizer
{
private:
KellyPerformanceData    m_performance;
double                  m_safetyFactor;      // Reduce Kelly by this factor for safety
double                  m_maxRiskPercent;    // Maximum risk allowed per trade
double                  m_minRiskPercent;    // Minimum risk per trade
bool                    m_adaptiveMode;      // Use adaptive Kelly calculation
int                     m_minTradesRequired; // Minimum trades before using Kelly

// Performance tracking
double                  m_tradeHistory[200];  // Store last 200 trade results
int                     m_historyIndex;
int                     m_historyCount;

public:
CKellyCriterionSizer()
{
m_safetyFactor = 0.5;
m_maxRiskPercent = 2.0;
m_minRiskPercent = 0.2;
m_adaptiveMode = true;
m_minTradesRequired = 30;
m_historyIndex = 0;
m_historyCount = 0;
m_performance.Reset();
ArrayInitialize(m_tradeHistory, 0.0);
}

//+------------------------------------------------------------------+
//| ?? MAIN KELLY POSITION SIZE CALCULATION                         |
//+------------------------------------------------------------------+
double CalculateKellySize(double signalConfidence, double stopLossPoints, double takeProfitPoints, double accountBalance)
{
// Update performance metrics first
UpdatePerformanceMetrics();

// If insufficient trade history, use conservative sizing
if(m_performance.totalTrades < m_minTradesRequired) {
double conservativeSize = CalculateConservativeSize(signalConfidence, accountBalance);
Print(StringFormat("[?? KELLY] Insufficient history (%d trades), using conservative: %.3f%%", 
(int)m_performance.totalTrades, conservativeSize));
return conservativeSize;
}

// Calculate base Kelly fraction
double kellyFraction = CalculateKellyFraction(stopLossPoints, takeProfitPoints);

// Apply signal confidence adjustment
kellyFraction *= GetConfidenceAdjustment(signalConfidence);

// Apply safety factor (Boss's requirement for conservative approach)
kellyFraction *= m_safetyFactor;

// Apply market condition adjustment
kellyFraction *= GetMarketConditionAdjustment();

// Convert to risk percentage and apply limits
double riskPercent = MathMax(m_minRiskPercent, MathMin(m_maxRiskPercent, kellyFraction * 100));

Print(StringFormat("[?? KELLY FINAL] Raw: %.3f, Adjusted: %.3f, Final Risk: %.2f%% (Confidence: %.1f%%)", 
m_performance.kellyFraction, kellyFraction, riskPercent, signalConfidence * 100));

return riskPercent;
}

//+------------------------------------------------------------------+
//| ?? CALCULATE KELLY FRACTION                                      |
//+------------------------------------------------------------------+
double CalculateKellyFraction(double stopLossPoints, double takeProfitPoints)
{
if(stopLossPoints <= 0 || takeProfitPoints <= 0) return 0.01; // 1% fallback

// Calculate risk-reward ratio
double riskRewardRatio = takeProfitPoints / stopLossPoints;

// Kelly Fraction = (bp - q) / b
// where: b = risk-reward ratio, p = win probability, q = loss probability
double b = riskRewardRatio;
double p = m_performance.winRate;
double q = 1.0 - p;

if(b <= 0) return 0.01;

double kellyFraction = (b * p - q) / b;

// Kelly should be positive for profitable system
if(kellyFraction <= 0) {
Print("[?? KELLY] Negative Kelly fraction detected: ", kellyFraction, " - System may not be profitable");
return 0.01; // Minimum size
}

return kellyFraction;
}

//+------------------------------------------------------------------+
//| ?? SIGNAL CONFIDENCE ADJUSTMENT                                  |
//+------------------------------------------------------------------+
double GetConfidenceAdjustment(double signalConfidence)
{
// Higher confidence = can use more of Kelly fraction
if(signalConfidence >= 0.90) return 1.2;      // Very high confidence: use 120% of Kelly
else if(signalConfidence >= 0.80) return 1.0; // High confidence: full Kelly
else if(signalConfidence >= 0.70) return 0.8; // Medium confidence: 80% of Kelly
else if(signalConfidence >= 0.60) return 0.6; // Lower confidence: 60% of Kelly
else return 0.4;                               // Low confidence: 40% of Kelly
}

//+------------------------------------------------------------------+
//| ?? MARKET CONDITION ADJUSTMENT                                   |
//+------------------------------------------------------------------+
double GetMarketConditionAdjustment()
{
double adjustment = 1.0;

// Volatility adjustment
double atr = GetCurrentATR();
double avgATR = GetAverageATR(20);

if(avgATR > 0) {
double volatilityRatio = atr / avgATR;
if(volatilityRatio > 1.5) {
adjustment *= 0.7;  // High volatility: reduce position size
Print("[??? KELLY] High volatility adjustment: 0.7");
}
else if(volatilityRatio < 0.7) {
adjustment *= 1.1;  // Low volatility: can increase slightly
Print("[?? KELLY] Low volatility adjustment: 1.1");
}
}

// Drawdown protection
double currentDD = CalculateCurrentDrawdown();
if(currentDD > 0.05) {  // If drawdown > 5%
adjustment *= (1.0 - currentDD);  // Reduce size proportionally
Print(StringFormat("[??? KELLY] Drawdown protection: %.1f%% DD, adjustment: %.2f", currentDD * 100, adjustment));
}

return MathMax(0.3, adjustment); // Never reduce below 30%
}

//+------------------------------------------------------------------+
//| ?? CONSERVATIVE SIZING FOR INSUFFICIENT HISTORY                 |
//+------------------------------------------------------------------+
double CalculateConservativeSize(double signalConfidence, double accountBalance)
{
double baseSize = 1.0; // 1% base risk

// Adjust based on signal confidence
if(signalConfidence >= 0.85) baseSize = 1.5;
else if(signalConfidence >= 0.70) baseSize = 1.2;
else if(signalConfidence >= 0.60) baseSize = 1.0;
else baseSize = 0.5;

// Progressive increase as we gain more trades
double progressFactor = m_performance.totalTrades / m_minTradesRequired;
baseSize *= (0.5 + 0.5 * progressFactor); // Start at 50%, gradually increase

return MathMax(m_minRiskPercent, MathMin(m_maxRiskPercent * 0.5, baseSize));
}

//+------------------------------------------------------------------+
//| ?? UPDATE PERFORMANCE METRICS                                    |
//+------------------------------------------------------------------+
void UpdatePerformanceMetrics()
{
m_performance.Calculate();
m_performance.lastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| ?? ADD TRADE RESULT TO HISTORY                                   |
//+------------------------------------------------------------------+
void AddTradeResult(double profit, double riskAmount)
{
// Calculate percentage return
double percentReturn = (riskAmount > 0) ? (profit / riskAmount) * 100 : 0;

// Add to history
m_tradeHistory[m_historyIndex] = percentReturn;
m_historyIndex = (m_historyIndex + 1) % 200;
if(m_historyCount < 200) m_historyCount++;

// Update performance data
m_performance.totalTrades++;
if(profit > 0) {
m_performance.winningTrades++;
m_performance.totalProfit += profit;
if(profit > m_performance.largestWin) m_performance.largestWin = profit;
} else if(profit < 0) {
m_performance.losingTrades++;
m_performance.totalLoss += MathAbs(profit);
if(MathAbs(profit) > m_performance.largestLoss) m_performance.largestLoss = MathAbs(profit);
}

UpdatePerformanceMetrics();

Print(StringFormat("[?? KELLY] Trade added: P&L=%.2f, Total Trades=%d, Win Rate=%.1f%%, Kelly Fraction=%.3f",
profit, (int)m_performance.totalTrades, m_performance.winRate * 100, m_performance.kellyFraction));
}

//+------------------------------------------------------------------+
//| ?? HELPER METHODS                                                |
//+------------------------------------------------------------------+
double GetCurrentATR()
{
int atrHandle = iATR(_Symbol, PERIOD_H1, 14);
double atrBuffer[];
ArrayResize(atrBuffer, 1);
if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0) {
IndicatorRelease(atrHandle);
return atrBuffer[0];
}
IndicatorRelease(atrHandle);
return 0.0001; // Fallback
}

double GetAverageATR(int period)
{
int atrHandle = iATR(_Symbol, PERIOD_H1, 14);
double atrBuffer[];
ArrayResize(atrBuffer, 50);
ArraySetAsSeries(atrBuffer, true);
if(CopyBuffer(atrHandle, 0, 0, period, atrBuffer) >= period) {
double sum = 0;
for(int i = 0; i < period; i++) sum += atrBuffer[i];
IndicatorRelease(atrHandle);
return sum / (double)period;
}
IndicatorRelease(atrHandle);
return 0.0001; // Fallback
}

double CalculateCurrentDrawdown()
{
if(m_historyCount < 10) return 0.0;

double peak = 0;
double runningSum = 0;
double maxDD = 0;

for(int i = 0; i < m_historyCount; i++) {
runningSum += m_tradeHistory[i];
if(runningSum > peak) peak = runningSum;
double currentDD = (peak - runningSum) / 100.0; // Convert to percentage
if(currentDD > maxDD) maxDD = currentDD;
}

return maxDD;
}

double CalculateDynamicKelly(double winRate, double avgWin, double avgLoss, double volatility) {
double baseKelly = (avgWin * winRate - avgLoss * (1 - winRate)) / avgWin;
double adjustFactor = 1.0 - (volatility / 100.0);  // Reduce in high vol
return MathMin(baseKelly * adjustFactor, 0.25);
}

// Public getters
KellyPerformanceData GetPerformanceData() const { return m_performance; }
double GetCurrentKellyFraction() const { return m_performance.kellyFraction; }
double GetSafetyFactor() const { return m_safetyFactor; }
void SetSafetyFactor(double factor) { m_safetyFactor = MathMax(0.1, MathMin(1.0, factor)); }

string GetKellyReport()
{
return StringFormat(
"?? KELLY CRITERION REPORT\nTotal Trades: %d\nWin Rate: %.1f%%\nAvg Win: %.2f | Avg Loss: %.2f\nProfit Factor: %.2f\nKelly Fraction: %.3f\nSafety Factor: %.2f\nCurrent Risk Range: %.1f%% - %.1f%%",
(int)m_performance.totalTrades,
m_performance.winRate * 100,
m_performance.avgWin, m_performance.avgLoss,
m_performance.profitFactor,
m_performance.kellyFraction,
m_safetyFactor,
m_minRiskPercent, m_maxRiskPercent
);
}
};

#endif // RISK_KELLY_CRITERION_MQH 


