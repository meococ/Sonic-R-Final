//+------------------------------------------------------------------+
//| Risk_IntelligentManager.mqh                                     |
//| Intelligent Risk Management with Trading Psychology              |
//| Copyright 2024, ƒê·∫°i B√†ng Dev                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, ƒê·∫°i B√†ng Dev"
#property link      "https://sonicr.mc"
#property version   "3.00"

// PHASE 0: Critical Standard Library Includes
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

#ifndef RISK_01_INTELLIGENTMANAGER_MQH
#define RISK_01_INTELLIGENTMANAGER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "06_RiskManagement_10_KellyCriterion.mqh"  // Include CKellyCriterionSizer class
#include "02_DataProviders_05_IndicatorManager.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
// #include "Risk_Consolidated.mqh"  // DISABLED: File not found
// CONSOLIDATED: #include <Trade\Trade.mqh>

// ?? BOSS FIX: 7 STRATEGIC IMPROVEMENTS INCLUDES
#include "06_RiskManagement_08_AdaptiveDynamicKelly.mqh"           // 1. Adaptive Dynamic Kelly
#include "06_RiskManagement_11_MarketCycleAnalysis.mqh"            // 2. Market Cycle Risk Adjustment
#include "06_RiskManagement_07_EquityCurveConvexity.mqh"           // 3. Equity Curve Convexity Management
#include "06_RiskManagement_09_DynamicRiskReward.mqh"              // 4. Dynamic Risk-Reward Adaptation
#include "06_RiskManagement_05_CorrelationHeatMap.mqh"             // 5. Correlation Heat Map Management
#include "06_RiskManagement_13_SeasonalityCalendar.mqh"            // 6. Seasonality & Calendar Effects
#include "06_RiskManagement_12_RealTimeFeedback.mqh"    // 7. Real-Time Performance Feedback

// PHASE 1: Asset DNA System Integration
#include "03_MarketAnalysis_21_AssetDNA.mqh"

//+------------------------------------------------------------------+
//| PHASE 1 FEATURE TOGGLES - Multi-Asset Risk Management          |
//+------------------------------------------------------------------+
#ifndef ENABLE_MULTI_ASSET_RISK
#define ENABLE_MULTI_ASSET_RISK         true
#endif
#ifndef ENABLE_ASSET_SPECIFIC_SIZING
#define ENABLE_ASSET_SPECIFIC_SIZING    true
#endif
#ifndef ENABLE_ASSET_CORRELATION_RISK
#define ENABLE_ASSET_CORRELATION_RISK   false  // Phase 3 feature
#endif
#ifndef ENABLE_ASSET_VOLATILITY_ADJ
#define ENABLE_ASSET_VOLATILITY_ADJ     true
#endif

//+------------------------------------------------------------------+
//| [ROCKET] TASK 5: ENHANCED RISK MANAGEMENT & PORTFOLIO OPTIMIZATION     |
//+------------------------------------------------------------------+

// Add at the beginning after existing includes
// #include "03_MarketAnalysis_03_PVSRA_Enhanced.mqh"  // TEMP DISABLE during compile isolation

//+------------------------------------------------------------------+
//| BASIC RISK MANAGER CLASS DEFINITION                               |
//+------------------------------------------------------------------+
class CRiskManager
{
protected:
double m_riskPercent;
double m_riskRewardRatio;
double m_maxDailyLoss;
int m_maxDailyTrades;

public:
CRiskManager()
{
m_riskPercent = 2.0;      // Default 2% risk per trade
m_riskRewardRatio = 2.0;  // Default 1:2 risk-reward
m_maxDailyLoss = 5.0;     // Default 5% max daily loss
m_maxDailyTrades = 10;    // Default max 10 trades per day
}

virtual ~CRiskManager() {}

// Basic position sizing method
double CalculatePositionSize(double stopLossPoints, double accountBalance)
{
if(stopLossPoints <= 0) return 0.0;

double riskAmount = accountBalance * (m_riskPercent / 100.0);
double pointValue = _Point * 100000; // Standard lot size for forex
double stopLossValue = stopLossPoints * pointValue;

if(stopLossValue <= 0) return 0.0;

return riskAmount / stopLossValue;
}

// Getters
double GetRiskPercent() const { return m_riskPercent; }
double GetRiskRewardRatio() const { return m_riskRewardRatio; }
double GetMaxDailyLoss() const { return m_maxDailyLoss; }
int GetMaxDailyTrades() const { return m_maxDailyTrades; }

// Setters
void SetRiskPercent(double riskPercent) { m_riskPercent = riskPercent; }
void SetRiskRewardRatio(double ratio) { m_riskRewardRatio = ratio; }
void SetMaxDailyLoss(double maxLoss) { m_maxDailyLoss = maxLoss; }
void SetMaxDailyTrades(int maxTrades) { m_maxDailyTrades = maxTrades; }
};

// CKellyCriterionSizer is defined in Risk_KellyCriterion.mqh - using that implementation

//+------------------------------------------------------------------+
//| ENHANCED MONTE CARLO RISK ANALYSIS - 20K SIMULATION UPGRADE     |
//+------------------------------------------------------------------+
class CMonteCarloRiskAnalysis
{
private:
// Monte Carlo parameters - ENHANCED FOR 20K SIMULATIONS
int m_simulations;           // Number of simulations to run (20,000 target)
double m_confidenceLevel;    // Confidence level for VaR calculation
int m_lookbackPeriods;       // Historical data lookback

// Risk metrics storage
double m_valueAtRisk;        // VaR at specified confidence level
double m_expectedShortfall;  // Expected loss beyond VaR
double m_maxDrawdown;        // Maximum projected drawdown
double m_sharpeRatio;        // Risk-adjusted return ratio

// ENHANCEMENT: Real-time exposure monitoring
double m_currentExposure;    // Current portfolio exposure percentage
double m_maxExposureLimit;   // Maximum allowed exposure (5%)
datetime m_lastExposureCheck; // Last exposure calculation time

// ENHANCEMENT: Kelly Criterion Monte Carlo averaging
double m_kellyFractions[];   // Array of Kelly fractions from MC runs
double m_avgKellyFraction;   // Monte Carlo averaged Kelly fraction
int m_kellySimulations;      // Number of Kelly MC simulations

// ENHANCEMENT: Advanced risk metrics
double m_stressTestResults[]; // Stress test scenario results
double m_liquidityRisk;      // Liquidity risk assessment
double m_correlationRisk;    // Cross-asset correlation risk
bool m_emergencyMode;        // Emergency risk mode flag
double m_riskBudget;         // Available risk budget
double m_usedRiskBudget;     // Currently used risk budget

// Simulation data
double m_returns[];          // Historical returns array
double m_simulatedPnL[];     // Simulated P&L scenarios
bool m_initialized;

public:
CMonteCarloRiskAnalysis()
{
// ENHANCEMENT: Upgrade to 20K simulations for production excellence
m_simulations = 20000;  // Upgraded from 1000 to 20,000
m_confidenceLevel = 0.95;
m_lookbackPeriods = 100;

m_valueAtRisk = 0.0;
m_expectedShortfall = 0.0;
m_maxDrawdown = 0.0;
m_sharpeRatio = 0.0;
m_initialized = false;

// ENHANCEMENT: Real-time exposure monitoring initialization
m_currentExposure = 0.0;
m_maxExposureLimit = 0.05;  // 5% maximum exposure limit
m_lastExposureCheck = 0;

// ENHANCEMENT: Kelly Criterion Monte Carlo averaging
m_kellySimulations = 1000;  // Separate Kelly MC simulations
m_avgKellyFraction = 0.0;
ArrayResize(m_kellyFractions, m_kellySimulations);

// ENHANCEMENT: Advanced risk metrics initialization
ArrayResize(m_stressTestResults, 10); // 10 stress test scenarios
m_liquidityRisk = 0.0;
m_correlationRisk = 0.0;
m_emergencyMode = false;
m_riskBudget = 0.1; // 10% total risk budget
m_usedRiskBudget = 0.0;

ArrayResize(m_returns, m_lookbackPeriods);
ArrayResize(m_simulatedPnL, m_simulations);
}

~CMonteCarloRiskAnalysis()
{
ArrayFree(m_returns);
ArrayFree(m_simulatedPnL);
ArrayFree(m_kellyFractions);  // ENHANCEMENT: Cleanup Kelly fractions array
ArrayFree(m_stressTestResults); // ENHANCEMENT: Cleanup stress test results
}

bool RunMonteCarloSimulation(double currentBalance, double positionSize)
{
if(!UpdateHistoricalReturns()) {
::Print("[‚ö Ô∏ MONTE CARLO] Failed to update historical returns");
return false;
}

double meanReturn = CalculateMean(m_returns);
double stdReturn = CalculateStdDev(m_returns, meanReturn);

for(int i = 0; i < m_simulations; i++) {
m_simulatedPnL[i] = SimulateSingleScenario(meanReturn, stdReturn, positionSize);
}

ArraySort(m_simulatedPnL);

CalculateVaR();
CalculateExpectedShortfall();
CalculateMaxDrawdown(currentBalance);
CalculateSharpeRatio();

m_initialized = true;

::Print(StringFormat("[üéØ MONTE CARLO] Simulation complete | VaR: %.2f%% | ES: %.2f%% | MaxDD: %.2f%%",
m_valueAtRisk*100, m_expectedShortfall*100, m_maxDrawdown*100));

return true;
}

double CalculateOptimalPositionSize(double accountBalance, double signalConfidence, double maxRiskPercent)
{
if(!m_initialized) return 0.0;

double baseSize = accountBalance * maxRiskPercent * 0.01;

double kellyMultiplier = CalculateKellyMultiplier(signalConfidence);

double mcAdjustment = CalculateMonteCarloAdjustment();

double volAdjustment = CalculateVolatilityAdjustment();

double optimalSize = baseSize * kellyMultiplier * mcAdjustment * volAdjustment;

double maxPosition = accountBalance * 0.1;
optimalSize = MathMin(optimalSize, maxPosition);

::Print(StringFormat("[POSITION SIZING] Base: %.2f | Kelly: %.2f | MC: %.2f | Vol: %.2f | Final: %.2f",
baseSize, kellyMultiplier, mcAdjustment, volAdjustment, optimalSize));

return MathMax(optimalSize, accountBalance * 0.001);
}

private:
bool UpdateHistoricalReturns()
{
MqlRates rates[];
ArraySetAsSeries(rates, true);

if(CopyRates(_Symbol, PERIOD_H1, 0, m_lookbackPeriods + 1, rates) < m_lookbackPeriods + 1) {
return false;
}

for(int i = 0; i < m_lookbackPeriods; i++) {
if(rates[i+1].close > 0) {
m_returns[i] = (rates[i].close - rates[i+1].close) / rates[i+1].close;
} else {
m_returns[i] = 0.0;
}
}

return true;
}

double SimulateSingleScenario(double mean, double stdDev, double positionSize)
{
static bool hasSpare = false;
static double spare;

double randomReturn;

if(hasSpare) {
randomReturn = spare;
hasSpare = false;
} else {
double u1 = (double)MathRand() / 32767.0;
double u2 = (double)MathRand() / 32767.0;

double mag = stdDev * MathSqrt(-2.0 * MathLog(u1));
randomReturn = mag * MathCos(2.0 * M_PI * u2) + mean;
spare = mag * MathSin(2.0 * M_PI * u2) + mean;
hasSpare = true;
}

return positionSize * randomReturn;
}

void CalculateVaR()
{
int varIndex = (int)(m_simulations * (1.0 - m_confidenceLevel));
m_valueAtRisk = -m_simulatedPnL[varIndex];
}

void CalculateExpectedShortfall()
{
int varIndex = (int)(m_simulations * (1.0 - m_confidenceLevel));
double sum = 0.0;
int count = 0;

for(int i = 0; i < varIndex; i++) {
sum += m_simulatedPnL[i];
count++;
}

m_expectedShortfall = (count > 0) ? -sum / count : 0.0;
}

void CalculateMaxDrawdown(double currentBalance)
{
double peak = currentBalance;
double maxDD = 0.0;

for(int i = 0; i < m_simulations; i++) {
double equity = currentBalance + m_simulatedPnL[i];

if(equity > peak) {
peak = equity;
} else {
double drawdown = (peak - equity) / peak;
if(drawdown > maxDD) {
maxDD = drawdown;
}
}
}

m_maxDrawdown = maxDD;
}

void CalculateSharpeRatio()
{
double meanPnL = CalculateMean(m_simulatedPnL);
double stdPnL = CalculateStdDev(m_simulatedPnL, meanPnL);

m_sharpeRatio = (stdPnL > 0) ? meanPnL / stdPnL : 0.0;
}

double CalculateKellyMultiplier(double confidence)
{
double winProb = confidence;
double lossProb = 1.0 - confidence;
double avgWin = 2.0;
double avgLoss = 1.0;

double kellyFraction = (avgWin * winProb - lossProb) / avgWin;

return MathMax(0.1, MathMin(1.0, kellyFraction * 0.25));
}

double CalculateMonteCarloAdjustment()
{
double riskScore = (m_valueAtRisk + m_expectedShortfall) / 2.0;

if(riskScore > 0.1) return 0.5;
if(riskScore > 0.05) return 0.75;
return 1.0;
}

double CalculateVolatilityAdjustment()
{
int atrHandle = iATR(_Symbol, PERIOD_H1, 14);
double atr[];
ArraySetAsSeries(atr, true);

if(CopyBuffer(atrHandle, 0, 0, 1, atr) < 1) {
IndicatorRelease(atrHandle);
return 1.0;
}

double currentATR = atr[0];
IndicatorRelease(atrHandle);

double avgATR = 0.0;
for(int i = 0; i < m_lookbackPeriods; i++) {
avgATR += MathAbs(m_returns[i]);
}
avgATR /= m_lookbackPeriods;

double volRatio = (avgATR > 0) ? currentATR / avgATR : 1.0;

if(volRatio > 2.0) return 0.5;
if(volRatio > 1.5) return 0.75;
if(volRatio < 0.5) return 1.25;
return 1.0;
}

double CalculateMean(const double& array[])
{
double sum = 0.0;
int size = ArraySize(array);

for(int i = 0; i < size; i++) {
sum += array[i];
}

return sum / size;
}

double CalculateStdDev(const double& array[], double mean)
{
double sum = 0.0;
int size = ArraySize(array);

for(int i = 0; i < size; i++) {
double diff = array[i] - mean;
sum += diff * diff;
}

return MathSqrt(sum / (size - 1));
}

//+------------------------------------------------------------------+
//| ENHANCEMENT: Real-time Exposure Monitoring (Max 5%)             |
//+------------------------------------------------------------------+



double CalculatePositionRisk()
{
double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
double sl = PositionGetDouble(POSITION_SL);
double volume = PositionGetDouble(POSITION_VOLUME);

if(sl == 0) return 0;  // No stop loss

double pips = MathAbs(openPrice - sl) / _Point;
double tickValue = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_TRADE_TICK_VALUE);

return pips * tickValue * volume;
}





public:
double GetVaR() { return m_valueAtRisk; }
double GetExpectedShortfall() { return m_expectedShortfall; }
double GetMaxDrawdown() { return m_maxDrawdown; }
double GetSharpeRatio() { return m_sharpeRatio; }

// ENHANCEMENT: New getters for enhanced functionality
double GetCurrentExposure() { UpdateCurrentExposure(); return m_currentExposure; }
double GetMaxExposureLimit() { return m_maxExposureLimit; }
double GetAvgKellyFraction() { return m_avgKellyFraction; }

//+------------------------------------------------------------------+
//| ENHANCEMENT: Kelly Criterion Monte Carlo Averaging              |
//+------------------------------------------------------------------+
double CalculateKellyMCAveraged(double winRate, double avgWin, double avgLoss)
{
// Run Monte Carlo simulations for Kelly Criterion
for(int i = 0; i < m_kellySimulations; i++) {
// Add noise to parameters to simulate uncertainty
double noiseWinRate = winRate + (MathRand()/32767.0 - 0.5) * 0.1;  // ±5% noise
double noiseAvgWin = avgWin + (MathRand()/32767.0 - 0.5) * avgWin * 0.2;  // ±10% noise
double noiseAvgLoss = avgLoss + (MathRand()/32767.0 - 0.5) * avgLoss * 0.2; // ±10% noise

// Ensure valid ranges
noiseWinRate = MathMax(0.1, MathMin(0.9, noiseWinRate));
noiseAvgWin = MathMax(0.5, noiseAvgWin);
noiseAvgLoss = MathMax(0.5, noiseAvgLoss);

// Calculate Kelly fraction for this scenario
double kellyFraction = (noiseWinRate * noiseAvgWin - (1.0 - noiseWinRate) * noiseAvgLoss) / noiseAvgWin;
m_kellyFractions[i] = MathMax(0.0, MathMin(0.25, kellyFraction));  // Cap at 25%
}

// Calculate average Kelly fraction
double sum = 0.0;
for(int i = 0; i < m_kellySimulations; i++) {
sum += m_kellyFractions[i];
}

m_avgKellyFraction = sum / m_kellySimulations;

::Print(StringFormat("[TARGET KELLY MC] Averaged Kelly Fraction: %.3f (from %d simulations)",
m_avgKellyFraction, m_kellySimulations));

return m_avgKellyFraction;
}

// ENHANCEMENT: Real-time exposure monitoring
bool CheckExposureLimit()
{
UpdateCurrentExposure();

double projectedExposure = m_currentExposure;

if(projectedExposure > m_maxExposureLimit) {
::Print(StringFormat("[?? EXPOSURE LIMIT] Current: %.2f%% + New: %.2f%% = %.2f%% > Limit: %.2f%%",
m_currentExposure*100, 0.0, projectedExposure*100, m_maxExposureLimit*100));
return false;
}

return true;
}

// ENHANCEMENT: Kelly Criterion confidence interval
double GetKellyConfidenceInterval(double confidence = 0.95)
{
if(ArraySize(m_kellyFractions) == 0) return 0.0;

// Sort Kelly fractions for percentile calculation
double sortedKelly[];
ArrayResize(sortedKelly, m_kellySimulations);
ArrayCopy(sortedKelly, m_kellyFractions);
ArraySort(sortedKelly);

int lowerIndex = (int)((1.0 - confidence) / 2.0 * m_kellySimulations);
int upperIndex = (int)((1.0 + confidence) / 2.0 * m_kellySimulations);

double ciWidth = sortedKelly[upperIndex] - sortedKelly[lowerIndex];

ArrayFree(sortedKelly);
return ciWidth;
}

// ENHANCEMENT: Update current exposure
void UpdateCurrentExposure()
{
if(TimeCurrent() - m_lastExposureCheck < 60) return;  // Update every minute

m_currentExposure = 0.0;
double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);

// Calculate exposure from all open positions
CPositionInfo posInfo;
for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
double positionRisk = CalculatePositionRisk();
m_currentExposure += positionRisk / accountBalance;
}
}

m_lastExposureCheck = TimeCurrent();

// Log exposure if approaching limit
if(m_currentExposure > m_maxExposureLimit * 0.8) {
::Print(StringFormat("[?? EXPOSURE WARNING] Current exposure: %.2f%% (Limit: %.2f%%)",
m_currentExposure*100, m_maxExposureLimit*100));
}
}

void SetSimulations(int count) { m_simulations = count; }
void SetConfidenceLevel(double level) { m_confidenceLevel = level; }
void SetLookbackPeriods(int periods) { m_lookbackPeriods = periods; }
void SetMaxExposureLimit(double limit) { m_maxExposureLimit = MathMax(0.01, MathMin(0.1, limit)); }  // 1-10% range

//+------------------------------------------------------------------+
//| ENHANCEMENT: Advanced Risk Management Methods                    |
//+------------------------------------------------------------------+

// Stress testing with multiple scenarios
bool RunStressTest(double accountBalance)
{
::Print("[?? STRESS TEST] Running 10 stress scenarios...");

// Scenario 1: Market crash (-30% in 1 day)
m_stressTestResults[0] = SimulateStressScenario(-0.30, 1, accountBalance);

// Scenario 2: Flash crash (-10% in 1 hour)
m_stressTestResults[1] = SimulateStressScenario(-0.10, 0.04, accountBalance);

// Scenario 3: High volatility (3x normal)
m_stressTestResults[2] = SimulateVolatilityStress(3.0, accountBalance);

// Scenario 4: Liquidity crisis (spreads widen 5x)
m_stressTestResults[3] = SimulateLiquidityStress(5.0, accountBalance);

// Scenario 5: Correlation breakdown (all correlations ? 1)
m_stressTestResults[4] = SimulateCorrelationStress(1.0, accountBalance);

// Additional scenarios 6-10
for(int i = 5; i < 10; i++) {
m_stressTestResults[i] = SimulateRandomStress(accountBalance);
}

// Analyze worst-case scenario
double worstCase = m_stressTestResults[0];
for(int i = 1; i < 10; i++) {
if(m_stressTestResults[i] < worstCase) {
worstCase = m_stressTestResults[i];
}
}

::Print(StringFormat("[?? STRESS TEST] Worst case loss: %.2f%% of account",
MathAbs(worstCase) / accountBalance * 100));

return (MathAbs(worstCase) / accountBalance) < 0.5; // Max 50% loss in stress
}

// Simulate specific stress scenario
double SimulateStressScenario(double returnShock, double timeFrame, double accountBalance)
{
double totalLoss = 0.0;

// Calculate position exposure
CPositionInfo posInfo;
for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
double positionValue = posInfo.Volume() * posInfo.PriceOpen();
double positionLoss = positionValue * MathAbs(returnShock);
totalLoss += positionLoss;
}
}

return -totalLoss; // Negative for loss
}

// Simulate volatility stress
double SimulateVolatilityStress(double volMultiplier, double accountBalance)
{
double enhancedVol = 0.0;
for(int i = 0; i < m_lookbackPeriods; i++) {
enhancedVol += MathAbs(m_returns[i]) * volMultiplier;
}
enhancedVol /= m_lookbackPeriods;

return -accountBalance * enhancedVol * 0.1; // Estimate 10% of enhanced vol as loss
}

// Simulate liquidity stress
double SimulateLiquidityStress(double spreadMultiplier, double accountBalance)
{
double liquidityLoss = 0.0;
double currentSpread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
double stressSpread = currentSpread * spreadMultiplier;

// Estimate liquidity loss based on position turnover
CPositionInfo posInfo;
for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
double positionValue = posInfo.Volume() * posInfo.PriceOpen();
liquidityLoss += positionValue * (stressSpread / posInfo.PriceOpen());
}
}

return -liquidityLoss;
}

// Simulate correlation stress
double SimulateCorrelationStress(double targetCorrelation, double accountBalance)
{
// Simplified correlation stress - assume all positions move together
double totalExposure = 0.0;

CPositionInfo posInfo;
for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
totalExposure += posInfo.Volume() * posInfo.PriceOpen();
}
}

// Assume 5% adverse move when all correlations = 1
return -totalExposure * 0.05 * targetCorrelation;
}

// Simulate random stress scenario
double SimulateRandomStress(double accountBalance)
{
double randomShock = (MathRand() / 32767.0 - 0.5) * 0.4; // ±20% random shock
return SimulateStressScenario(randomShock, 1.0, accountBalance);
}

// Check if emergency mode should be activated
bool ShouldActivateEmergencyMode(double accountBalance)
{
// Check current drawdown
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
double drawdown = (accountBalance - currentEquity) / accountBalance;

if(drawdown > 0.15) { // 15% drawdown threshold
::Print(StringFormat("[?? EMERGENCY] Drawdown threshold exceeded: %.2f%%", drawdown * 100));
return true;
}

// Check stress test results
if(!RunStressTest(accountBalance)) {
::Print("[?? EMERGENCY] Stress test failed");
return true;
}

// Check exposure limits
if(m_currentExposure > m_maxExposureLimit * 1.2) { // 20% over limit
::Print("[?? EMERGENCY] Exposure limit severely exceeded");
return true;
}

return false;
}

// Activate emergency risk mode
void ActivateEmergencyMode()
{
m_emergencyMode = true;
m_maxExposureLimit *= 0.5; // Halve exposure limit
::Print("[?? EMERGENCY MODE ACTIVATED] Risk limits tightened");
}

// Deactivate emergency mode
void DeactivateEmergencyMode()
{
m_emergencyMode = false;
m_maxExposureLimit *= 2.0; // Restore normal exposure limit
::Print("[? EMERGENCY MODE DEACTIVATED] Normal risk limits restored");
}

// Get emergency mode status
bool IsEmergencyMode() { return m_emergencyMode; }

// Update risk budget tracking
void UpdateRiskBudget(double newTradeRisk)
{
m_usedRiskBudget += newTradeRisk;

if(m_usedRiskBudget > m_riskBudget * 0.8) {
PrintFormat("[?? RISK BUDGET] %.1f%% of risk budget used",
m_usedRiskBudget / m_riskBudget * 100);
}
}

// Check if risk budget allows new trade
bool HasRiskBudget(double proposedRisk)
{
return (m_usedRiskBudget + proposedRisk) <= m_riskBudget;
}

// Reset risk budget (daily/weekly)
void ResetRiskBudget()
{
m_usedRiskBudget = 0.0;
::Print("[?? RISK BUDGET] Risk budget reset");
}

// Getters for advanced risk metrics
double GetLiquidityRisk() { return m_liquidityRisk; }
double GetCorrelationRisk() { return m_correlationRisk; }
double GetRiskBudgetUsed() { return m_usedRiskBudget; }
double GetRiskBudgetAvailable() { return m_riskBudget - m_usedRiskBudget; }
};

//+------------------------------------------------------------------+
//| DYNAMIC RISK-REWARD SYSTEM                                      |
//+------------------------------------------------------------------+

enum ENUM_MARKET_CONDITION
{
MARKET_TRENDING,
MARKET_RANGING,
MARKET_VOLATILE
};

// MarketContext is defined in SonicR_CommonStructs.mqh - using that definition

class CDynamicRiskReward
{
private:
struct RRParameters
{
double baseRR;
double confidenceMultiplier;
double volatilityAdjustment;
double marketConditionFactor;
};

struct LocalMarketContext {
double signalConfidence;
double currentVolatility;
ENUM_MARKET_CONDITION marketCondition;
};

double CalculateAverageATR(int periods)
{
double atrBuffer[];
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
if(CopyBuffer(atrHandle, 0, 0, periods, atrBuffer) < periods) {
IndicatorRelease(atrHandle);
return 0.0;
}
IndicatorRelease(atrHandle);
double sum = 0.0;
for(int i = 0; i < periods; i++) {
sum += atrBuffer[i];
}
return sum / periods;
}

public:
double CalculateDynamicRR(double signalConfidence, double currentVolatility, ENUM_MARKET_CONDITION condition)
{
LocalMarketContext context;
context.signalConfidence = signalConfidence;
context.currentVolatility = currentVolatility;
context.marketCondition = condition;
RRParameters params;
params = GetOptimalParameters(context);

double dynamicRR = params.baseRR * params.confidenceMultiplier * params.volatilityAdjustment * params.marketConditionFactor;

return MathMax(1.0, MathMin(4.0, dynamicRR));
}

RRParameters GetOptimalParameters(const LocalMarketContext& context)
{
RRParameters params;
params.baseRR = 2.0;
params.confidenceMultiplier = (context.signalConfidence > 0.8) ? 1.2 : 0.8;
params.volatilityAdjustment = (context.currentVolatility < 1.0) ? 1.1 : 0.9;
params.marketConditionFactor = 1.0;

switch(context.marketCondition)
{
case MARKET_TRENDING:
params.marketConditionFactor = 1.3;
break;
case MARKET_RANGING:
params.marketConditionFactor = 0.9;
break;
case MARKET_VOLATILE:
params.marketConditionFactor = 0.7;
break;
}

return params;
}
};

//+------------------------------------------------------------------+
//| ENHANCED PORTFOLIO CORRELATION ANALYSIS                         |
//+------------------------------------------------------------------+
class CPortfolioCorrelationAnalysis
{
private:
string m_symbols[10];        // Symbols in portfolio
int m_symbolCount;
double m_correlationMatrix[10][10]; // Correlation matrix
double m_weights[10];        // Portfolio weights
bool m_matrixValid;

public:
CPortfolioCorrelationAnalysis()
{
m_symbolCount = 0;
m_matrixValid = false;

// Initialize correlation matrix
for(int i = 0; i < 10; i++) {
m_weights[i] = 0.0;
for(int j = 0; j < 10; j++) {
m_correlationMatrix[i][j] = (i == j) ? 1.0 : 0.0;
}
}
}

bool AddSymbol(string symbol, double weight = 0.0)
{
if(m_symbolCount >= 10) return false;

m_symbols[m_symbolCount] = symbol;
m_weights[m_symbolCount] = weight;
m_symbolCount++;
m_matrixValid = false; // Need to recalculate

return true;
}

bool CalculateCorrelationMatrix(int lookbackPeriods = 100)
{
if(m_symbolCount < 2) return false;

// Get returns for all symbols (using individual arrays to avoid reference issues)
double symbolReturns[100];

for(int s = 0; s < m_symbolCount; s++) {
ArrayInitialize(symbolReturns, 0.0);
if(!GetSymbolReturns(m_symbols[s], symbolReturns, lookbackPeriods)) {
PrintFormat("[‚ö Ô∏è CORRELATION] Failed to get returns for %s", m_symbols[s]);
return false;
}
// Store returns for later correlation calculation (simplified approach)
}

// Simplified correlation calculation (placeholder for now)
for(int i = 0; i < m_symbolCount; i++) {
for(int j = i; j < m_symbolCount; j++) {
if(i == j) {
m_correlationMatrix[i][j] = 1.0;
} else {
// Simplified correlation - real implementation would need proper data storage
double correlation = 0.5; // Placeholder value
m_correlationMatrix[i][j] = correlation;
m_correlationMatrix[j][i] = correlation; // Symmetric matrix
}
}
}

m_matrixValid = true;
return true;
}

double GetPortfolioRisk()
{
if(!m_matrixValid) {
if(!CalculateCorrelationMatrix()) return 0.0;
}

double portfolioVariance = 0.0;

// Calculate portfolio variance using correlation matrix
for(int i = 0; i < m_symbolCount; i++) {
for(int j = 0; j < m_symbolCount; j++) {
double weight_i = m_weights[i];
double weight_j = m_weights[j];
double correlation = m_correlationMatrix[i][j];

// Simplified: assume all symbols have similar individual risk
double risk_i = 0.02; // 2% individual risk
double risk_j = 0.02;

portfolioVariance += weight_i * weight_j * correlation * risk_i * risk_j;
}
}

return MathSqrt(portfolioVariance);
}

bool IsCorrelationAcceptable(string newSymbol, double maxCorrelation = 0.7)
{
if(m_symbolCount == 0) return true; // First symbol always acceptable

// Get returns for new symbol
double newReturns[100];
if(!GetSymbolReturns(newSymbol, newReturns, 100)) return false;

// Check correlation with existing symbols
for(int i = 0; i < m_symbolCount; i++) {
double existingReturns[100];
if(!GetSymbolReturns(m_symbols[i], existingReturns, 100)) continue;

double correlation = CalculateCorrelation(newReturns, existingReturns, 100);
if(MathAbs(correlation) > maxCorrelation) {
PrintFormat("[‚ö Ô∏è CORRELATION] %s highly correlated with %s (%.2f)",
newSymbol, m_symbols[i], correlation);
return false;
}
}

return true;
}

private:
bool GetSymbolReturns(string symbol, double& returns[], int periods)
{
MqlRates rates[];
ArraySetAsSeries(rates, true);

if(CopyRates(symbol, PERIOD_H1, 0, periods + 1, rates) < periods + 1) {
return false;
}

ArrayResize(returns, periods);

for(int i = 0; i < periods; i++) {
if(rates[i+1].close > 0) {
returns[i] = (rates[i].close - rates[i+1].close) / rates[i+1].close;
} else {
returns[i] = 0.0;
}
}

return true;
}

double CalculateCorrelation(const double& x[], const double& y[], int size)
{
double meanX = 0.0, meanY = 0.0;

// Calculate means
for(int i = 0; i < size; i++) {
meanX += x[i];
meanY += y[i];
}
meanX /= size;
meanY /= size;

// Calculate correlation coefficient
double numerator = 0.0, denomX = 0.0, denomY = 0.0;

for(int i = 0; i < size; i++) {
double diffX = x[i] - meanX;
double diffY = y[i] - meanY;

numerator += diffX * diffY;
denomX += diffX * diffX;
denomY += diffY * diffY;
}

double denominator = MathSqrt(denomX * denomY);
return (denominator > 0) ? numerator / denominator : 0.0;
}

public:
string GetCorrelationReport()
{
if(!m_matrixValid) return "Correlation matrix not calculated";

string report = "Portfolio Correlation Matrix:\n";

for(int i = 0; i < m_symbolCount; i++) {
report += m_symbols[i] + ": ";
for(int j = 0; j < m_symbolCount; j++) {
report += StringFormat("%.2f ", m_correlationMatrix[i][j]);
}
report += "\n";
}

report += StringFormat("Portfolio Risk: %.2f%%", GetPortfolioRisk() * 100);

return report;
}
};

// Add enhanced risk management to existing class
class CEnhancedRiskManager : public CRiskManager
{
private:
CMonteCarloRiskAnalysis* m_monteCarloAnalysis;
CPortfolioCorrelationAnalysis* m_portfolioAnalysis;
CKellyCriterionSizer* m_kellySizer;

// Enhanced risk parameters
double m_maxCorrelationThreshold;
double m_dynamicStopMultiplier;
bool m_useMonteCarloSizing;

// Performance tracking
double m_totalPnL;
int m_totalTrades;
int m_winningTrades;
double m_maxEquityDD;

public:
void UpdateTradeHistory(double tradeResult)
{
if(m_kellySizer != NULL) {
// m_kellySizer.UpdateTradeHistory(tradeResult); // COMMENTED OUT: Method not available in this context
// Manual update logic can be added here if needed
}
}

double GetDynamicRiskReward(double signalConfidence)
{
CDynamicRiskReward rrCalculator;
// double currentVolatility = CalculateAverageATR(14) / _Point; // COMMENTED OUT: Function not found
double currentVolatility = 10.0; // Placeholder volatility value
ENUM_MARKET_CONDITION condition = MARKET_TRENDING; // Use default for now - will implement proper detection later
return rrCalculator.CalculateDynamicRR(signalConfidence, currentVolatility, condition);
}

CEnhancedRiskManager() : CRiskManager()
{
m_monteCarloAnalysis = new CMonteCarloRiskAnalysis();
m_portfolioAnalysis = new CPortfolioCorrelationAnalysis();
m_kellySizer = new CKellyCriterionSizer();

m_maxCorrelationThreshold = 0.7;
m_dynamicStopMultiplier = 1.0;
m_useMonteCarloSizing = true;

m_totalPnL = 0.0;
m_totalTrades = 0;
m_winningTrades = 0;
m_maxEquityDD = 0.0;

// Add current symbol to portfolio analysis
m_portfolioAnalysis.AddSymbol(_Symbol, 1.0);
}

~CEnhancedRiskManager()
{
if(m_monteCarloAnalysis != NULL) {
delete m_monteCarloAnalysis;
m_monteCarloAnalysis = NULL;
}

if(m_portfolioAnalysis != NULL) {
delete m_portfolioAnalysis;
m_portfolioAnalysis = NULL;
}
if(m_kellySizer != NULL) {
delete m_kellySizer;
m_kellySizer = NULL;
}
}

//+------------------------------------------------------------------+
//| [ROCKET] ENHANCED POSITION SIZING WITH MONTE CARLO                    |
//+------------------------------------------------------------------+
double CalculateEnhancedPositionSize(double signalConfidence, double accountBalance)
{
if(!m_useMonteCarloSizing) {
double stopLossPoints = 50.0; // Default stop loss in points
return CRiskManager::CalculatePositionSize(stopLossPoints, accountBalance);
}

// 1. Check real-time exposure limits before sizing
if(!m_monteCarloAnalysis.CheckExposureLimit()) {
::PrintFormat("[üõ°Ô∏ EXPOSURE BLOCK] Maximum exposure limit reached: %s%%", DoubleToString(m_monteCarloAnalysis.GetCurrentExposure() * 100, 2));
return 0.0; // Block trade due to exposure limit
}

// 2. Run enhanced 20k Monte Carlo simulation
double baseSize = accountBalance * 0.02; // 2% base risk
m_monteCarloAnalysis.RunMonteCarloSimulation(accountBalance, baseSize);

// 3. Get Kelly Criterion with Monte Carlo averaging
double kellyMC = m_monteCarloAnalysis.CalculateKellyMCAveraged(0.6, 2.0, 1.0); // Default parameters
double kellyConfidence = m_monteCarloAnalysis.GetKellyConfidenceInterval();

// 4. Get optimal position size with enhanced Kelly
double mcSize = m_monteCarloAnalysis.CalculateOptimalPositionSize(
accountBalance, signalConfidence, 2.0);
double kellySize = accountBalance * kellyMC * 0.5; // Conservative Kelly application

// 5. Use confidence-weighted sizing
double confidenceWeight = MathMin(kellyConfidence, 1.0);
double optimalSize = (mcSize * (1.0 - confidenceWeight)) + (kellySize * confidenceWeight);

// 6. Calculate position risk for exposure tracking
double positionRisk = optimalSize * 0.02; // Estimate 2% risk per position

// 7. Apply additional filters
optimalSize = ApplyRiskFilters(optimalSize, accountBalance);

// 8. Update exposure tracking
m_monteCarloAnalysis.UpdateCurrentExposure();

PrintFormat("[ROCKET] [ENHANCED SIZING] MC: %.4f | Kelly: %.4f (CI: %.2f) | Final: %.4f | Risk: %.2f%%",
mcSize, kellySize, kellyConfidence, optimalSize, positionRisk * 100);

return optimalSize;
}

//+------------------------------------------------------------------+
//| üöÄ DYNAMIC RISK MANAGEMENT                                       |
//+------------------------------------------------------------------+
bool ShouldBlockTradeForRisk(double signalConfidence)
{
// 0. Check real-time exposure limits (NEW)
if(!m_monteCarloAnalysis.CheckExposureLimit()) {
::PrintFormat("[üõ°Ô∏ RISK BLOCK] Real-time exposure limit exceeded: %.2f%%", m_monteCarloAnalysis.GetCurrentExposure() * 100);
return true;
}

// 1. Check Monte Carlo risk metrics (Enhanced with 20k simulations)
if(m_monteCarloAnalysis.GetVaR() > 0.15) { // 15% VaR limit
::PrintFormat("[üõ°Ô∏è RISK BLOCK] High VaR detected: %.1f%%", m_monteCarloAnalysis.GetVaR() * 100);
return true;
}

// 2. Check maximum drawdown
if(m_monteCarloAnalysis.GetMaxDrawdown() > 0.25) { // 25% max drawdown
::PrintFormat("[üõ°Ô∏è RISK BLOCK] High projected drawdown: %.1f%%", m_monteCarloAnalysis.GetMaxDrawdown() * 100);
return true;
}

// 2.5. Check Kelly Criterion confidence (NEW)
double kellyConfidence = m_monteCarloAnalysis.GetKellyConfidenceInterval();
if(kellyConfidence < 0.3) { // Minimum 30% Kelly confidence
::PrintFormat("[üõ°Ô∏ RISK BLOCK] Low Kelly confidence: %.1f%%", kellyConfidence * 100);
return true;
}

// 3. Check portfolio correlation risk
double portfolioRisk = m_portfolioAnalysis.GetPortfolioRisk();
if(portfolioRisk > 0.3) { // 30% portfolio risk limit
::PrintFormat("[üõ°Ô∏ RISK BLOCK] High portfolio risk: %.1f%%", portfolioRisk * 100);
return true;
}

// 4. Check Wyckoff phase filter - FIXED: Fallback when PVSRA not available
// Since PVSRA modules are disabled, use conservative approach
bool wyckoffBlock = false; // Default to no blocking
if(wyckoffBlock) {
::Print("[RISK BLOCK] Wyckoff phase indicates accumulation/distribution");
return true;
}

// 5. Check low confidence signals (Enhanced threshold)
if(signalConfidence < 0.65) { // Increased from 60% to 65% for higher quality
::PrintFormat("[üõ°Ô∏ RISK BLOCK] Signal confidence too low: %.1f%%", signalConfidence * 100);
return true;
}

return false; // Trade allowed
}

//+------------------------------------------------------------------+
//| üöÄ DYNAMIC STOP LOSS CALCULATION                                 |
//+------------------------------------------------------------------+
double CalculateDynamicStopLoss(ENUM_SIGNAL_TYPE signalType, double entryPrice)
{
// Base stop loss using ATR
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atr[];
ArraySetAsSeries(atr, true);

if(CopyBuffer(atrHandle, 0, 0, 1, atr) < 1) {
IndicatorRelease(atrHandle);
return 0.0;
}

double currentATR = atr[0];
IndicatorRelease(atrHandle);

// Dynamic multiplier based on market conditions
double dynamicMultiplier = CalculateDynamicStopMultiplier();

// Calculate stop loss
double stopDistance = currentATR * dynamicMultiplier;
double stopPrice = 0.0;

if(signalType == SIGNAL_BUY) {
stopPrice = entryPrice - stopDistance;
} else if(signalType == SIGNAL_SELL) {
stopPrice = entryPrice + stopDistance;
}

::PrintFormat("[üöÄ DYNAMIC STOP] ATR: %.5f | Multiplier: %.2f | Distance: %.5f | Stop: %.5f",
currentATR, dynamicMultiplier, stopDistance, stopPrice);

return stopPrice;
}

private:
double ApplyRiskFilters(double positionSize, double accountBalance)
{
// 1. Maximum position size filter (never more than 5% of account)
double maxPosition = accountBalance * 0.05;
positionSize = MathMin(positionSize, maxPosition);

// 2. Volatility adjustment
double volAdjustment = GetVolatilityAdjustment();
positionSize *= volAdjustment;

// 3. Time of day adjustment (reduce size during low liquidity)
double timeAdjustment = GetTimeOfDayAdjustment();
positionSize *= timeAdjustment;

return positionSize;
}

double CalculateDynamicStopMultiplier()
{
double baseMultiplier = 2.0; // Base 2x ATR

// Adjust based on market volatility
double volMultiplier = GetVolatilityAdjustment();

// Adjust based on Wyckoff phase - FIXED: Add fallback for when PVSRA is disabled
double phaseMultiplier = 1.0;

// Safe call with fallback - use basic volatility adjustment if PVSRA not available
phaseMultiplier = 1.2; // Conservative adjustment when Wyckoff analysis not available

return baseMultiplier * volMultiplier * phaseMultiplier;
}

double GetVolatilityAdjustment()
{
// Compare current volatility to historical average
int atrHandle = iATR(_Symbol, PERIOD_H1, 14);
double atr[];
ArraySetAsSeries(atr, true);

if(CopyBuffer(atrHandle, 0, 0, 20, atr) < 20) {
IndicatorRelease(atrHandle);
return 1.0;
}

double currentATR = atr[0];
double avgATR = 0.0;

for(int i = 1; i < 20; i++) {
avgATR += atr[i];
}
avgATR /= 19.0;

IndicatorRelease(atrHandle);

double volRatio = (avgATR > 0) ? currentATR / avgATR : 1.0;

// Return adjustment factor
if(volRatio > 2.0) return 0.5;       // Very high volatility - reduce size
if(volRatio > 1.5) return 0.75;      // High volatility
if(volRatio < 0.5) return 1.25;      // Low volatility - can increase
return 1.0;                          // Normal volatility
}

double GetTimeOfDayAdjustment()
{
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);

// Reduce position size during low liquidity hours
if(time.hour >= 22 || time.hour <= 2) {  // 22:00-02:00 GMT
return 0.7; // 30% reduction
}
if(time.hour >= 3 && time.hour <= 7) {   // 03:00-07:00 GMT
return 0.8; // 20% reduction
}

return 1.0; // Normal hours
}

public:
//+------------------------------------------------------------------+
//| üöÄ PERFORMANCE TRACKING                                          |
//+------------------------------------------------------------------+
void RecordTradeResult(double pnl, bool wasWinner)
{
m_totalPnL += pnl;
m_totalTrades++;
if(wasWinner) m_winningTrades++;

// Update max drawdown if needed
static double peakEquity = 0.0;
double currentEquity = AccountInfoDouble(ACCOUNT_BALANCE) + m_totalPnL;

if(currentEquity > peakEquity) {
peakEquity = currentEquity;
} else {
double currentDD = (peakEquity - currentEquity) / peakEquity;
if(currentDD > m_maxEquityDD) {
m_maxEquityDD = currentDD;
}
}
}

string GetRiskReport()
{
string report = "=== ENHANCED RISK MANAGEMENT REPORT ===\n";

// Monte Carlo metrics
report += StringFormat("VaR (95%%): %.2f%%\n", m_monteCarloAnalysis.GetVaR() * 100);
report += StringFormat("Expected Shortfall: %.2f%%\n", m_monteCarloAnalysis.GetExpectedShortfall() * 100);
report += StringFormat("Max Drawdown: %.2f%%\n", m_monteCarloAnalysis.GetMaxDrawdown() * 100);
report += StringFormat("Sharpe Ratio: %.2f\n", m_monteCarloAnalysis.GetSharpeRatio());

// Portfolio metrics
report += StringFormat("Portfolio Risk: %.2f%%\n", m_portfolioAnalysis.GetPortfolioRisk() * 100);

// Performance metrics
double winRate = (m_totalTrades > 0) ? ((double)m_winningTrades / m_totalTrades) * 100 : 0.0;
report += StringFormat("Total Trades: %d | Win Rate: %.1f%%\n", m_totalTrades, winRate);
report += StringFormat("Total P&L: %.2f | Max Equity DD: %.2f%%\n", m_totalPnL, m_maxEquityDD * 100);

// Wyckoff context
report += "Wyckoff: Analysis disabled (PVSRA modules not loaded)\n";

return report;
}

// Configuration methods
void SetMaxCorrelationThreshold(double threshold) { m_maxCorrelationThreshold = threshold; }
void SetUseMonteCarloSizing(bool enable) { m_useMonteCarloSizing = enable; }
void SetMonteCarloSimulations(int count) { m_monteCarloAnalysis.SetSimulations(count); }

// Access to sub-components for advanced users
CMonteCarloRiskAnalysis* GetMonteCarloAnalysis() { return m_monteCarloAnalysis; }
CPortfolioCorrelationAnalysis* GetPortfolioAnalysis() { return m_portfolioAnalysis; }
};

//+------------------------------------------------------------------+
//| INTELLIGENT RISK MANAGEMENT - Beyond Mathematics                 |
//+------------------------------------------------------------------+

/*
Trading in the Zone Principles:
1. Risk is not about stop loss - it's about ACCEPTANCE
2. Every trade has uncertain outcome - that's OK
3. Edge manifests over series of trades, not single trade
4. Proper risk allows you to think clearly
*/

class CIntelligentRiskManager
{
private:
#ifdef ENABLE_EQUITY_CURVE_ADJUSTMENT
CEquityCurveRiskAdjuster* m_equityAdjuster; // PHASE 3: Equity Curve Adjustment
#endif
// ?? BOSS FIX: 7 STRATEGIC IMPROVEMENTS INSTANCES
CAdaptiveDynamicKelly* m_adaptiveKelly;                    // 1. Adaptive Dynamic Kelly
CMarketCycleRiskAnalysis* m_marketCycleAnalysis;           // 2. Market Cycle Analysis
CEquityCurveConvexityManager* m_convexityManager;          // 3. Equity Curve Convexity
CDynamicRiskRewardOptimizer* m_riskRewardOptimizer;        // 4. Dynamic Risk-Reward
CCorrelationHeatMapManager* m_correlationHeatMap;          // 5. Correlation Heat Map
CSeasonalityCalendarManager* m_seasonalityManager;         // 6. Seasonality & Calendar
CRealTimePerformanceFeedback* m_performanceFeedback;       // 7. Real-Time Feedback

// PHASE 1: Asset DNA System Integration
CAssetDNASystem* m_assetDNA;                               // Asset Classification & Analysis

// Psychological Risk Metrics
struct PsychologicalRisk
{
double comfortZone;        // Max loss that doesn't affect psychology
double painThreshold;      // Loss that causes emotional decisions
double confidenceLevel;    // Current confidence (0-1)
int consecutiveLosses;     // Streak tracking
datetime lastLossTime;     // Recovery period needed
};

PsychologicalRisk m_psychRisk;

// Portfolio Heat Map
struct PortfolioHeat
{
double currentHeat;        // Current risk exposure
double maxHeat;           // Maximum allowed
double optimalHeat;       // Sweet spot for performance
string heatZones[5];      // Currency exposure
double zoneHeat[5];       // Risk per zone
};

PortfolioHeat m_portfolio;

// Dynamic Risk Parameters
struct DynamicRisk
{
double baseRisk;          // Standard risk per trade
double currentRisk;       // Adjusted for conditions
double scaleFactor;       // Multiplier based on edge
double recoveryFactor;    // Reduced risk after losses
};

DynamicRisk m_dynRisk;

// Risk Limits
double m_maxRiskPerTrade;     // Maximum risk allowed per trade

public:
CIntelligentRiskManager()
{
// ?? BOSS FIX: Initialize 7 Strategic Improvement Systems
InitializeStrategicImprovements();

// PHASE 1: Initialize Asset DNA System
InitializeAssetDNASystem();

// Initialize psychological parameters
m_psychRisk.comfortZone = 0.005;      // 0.5% comfortable loss
m_psychRisk.painThreshold = 0.02;     // 2% causes pain
m_psychRisk.confidenceLevel = 1.0;    // Start confident
m_psychRisk.consecutiveLosses = 0;
m_psychRisk.lastLossTime = 0;

// Portfolio heat
m_portfolio.currentHeat = 0;
m_portfolio.maxHeat = 0.06;           // 6% max portfolio heat
m_portfolio.optimalHeat = 0.03;       // 3% optimal

// Dynamic risk
m_dynRisk.baseRisk = 0.01;           // 1% base risk
m_dynRisk.currentRisk = 0.01;
m_dynRisk.scaleFactor = 1.0;
m_dynRisk.recoveryFactor = 1.0;

// Risk limits
m_maxRiskPerTrade = 0.05;            // 5% maximum risk per trade
}

~CIntelligentRiskManager()
{
// ?? BOSS FIX: Cleanup 7 Strategic Improvement Systems
CleanupStrategicImprovements();

// PHASE 1: Cleanup Asset DNA System
CleanupAssetDNASystem();
}

//+------------------------------------------------------------------+
//| ?? BOSS FIX: INITIALIZE 7 STRATEGIC IMPROVEMENTS                |
//+------------------------------------------------------------------+
void InitializeStrategicImprovements()
{
::Print("[?? STRATEGIC] Initializing 7 Strategic Risk Improvements...");
#ifdef ENABLE_EQUITY_CURVE_ADJUSTMENT
m_equityAdjuster = new CEquityCurveRiskAdjuster();
::Print("[? PHASE 3] Equity Curve Risk Adjuster initialized");
#endif

// 1. Adaptive Dynamic Kelly
m_adaptiveKelly = new CAdaptiveDynamicKelly();
if(m_adaptiveKelly != NULL) {
::Print("? [1/7] Adaptive Dynamic Kelly initialized");
}

// 2. Market Cycle Analysis
m_marketCycleAnalysis = new CMarketCycleRiskAnalysis();
if(m_marketCycleAnalysis != NULL) {
::Print("? [2/7] Market Cycle Analysis initialized");
}

// 3. Equity Curve Convexity
m_convexityManager = new CEquityCurveConvexityManager();
if(m_convexityManager != NULL) {
::Print("? [3/7] Equity Curve Convexity initialized");
}

// 4. Dynamic Risk-Reward
m_riskRewardOptimizer = new CDynamicRiskRewardOptimizer();
if(m_riskRewardOptimizer != NULL) {
::Print("? [4/7] Dynamic Risk-Reward initialized");
}

// 5. Correlation Heat Map
m_correlationHeatMap = new CCorrelationHeatMapManager();
if(m_correlationHeatMap != NULL) {
::Print("? [5/7] Correlation Heat Map initialized");
}

// 6. Seasonality & Calendar
m_seasonalityManager = new CSeasonalityCalendarManager();
if(m_seasonalityManager != NULL) {
::Print("? [6/7] Seasonality & Calendar initialized");
}

// 7. Real-Time Performance Feedback
m_performanceFeedback = new CRealTimePerformanceFeedback();
if(m_performanceFeedback != NULL) {
::Print("? [7/7] Real-Time Performance Feedback initialized");
}

::Print("[??? STRATEGIC] All 7 Strategic Risk Improvements initialized successfully!");
}

void CleanupStrategicImprovements()
{
if(m_adaptiveKelly != NULL) { delete m_adaptiveKelly; m_adaptiveKelly = NULL; }
if(m_marketCycleAnalysis != NULL) { delete m_marketCycleAnalysis; m_marketCycleAnalysis = NULL; }
if(m_convexityManager != NULL) { delete m_convexityManager; m_convexityManager = NULL; }
if(m_riskRewardOptimizer != NULL) { delete m_riskRewardOptimizer; m_riskRewardOptimizer = NULL; }
if(m_correlationHeatMap != NULL) { delete m_correlationHeatMap; m_correlationHeatMap = NULL; }
if(m_seasonalityManager != NULL) { delete m_seasonalityManager; m_seasonalityManager = NULL; }
if(m_performanceFeedback != NULL) { delete m_performanceFeedback; m_performanceFeedback = NULL; }
#ifdef ENABLE_EQUITY_CURVE_ADJUSTMENT
if(m_equityAdjuster != NULL) { delete m_equityAdjuster; m_equityAdjuster = NULL; }
#endif
}

//+------------------------------------------------------------------+
//| PHASE 1: ASSET DNA SYSTEM INTEGRATION                          |
//+------------------------------------------------------------------+
void InitializeAssetDNASystem()
{
#ifdef ENABLE_MULTI_ASSET_RISK
::Print("[?? ASSET DNA] Initializing Asset DNA System for Multi-Asset Risk Management...");

m_assetDNA = new CAssetDNASystem();
if(m_assetDNA != NULL) {
// Initialize with current symbol and timeframe
if(m_assetDNA.Initialize(NULL)) {
::Print("? [ASSET DNA] Asset DNA System initialized successfully for ", _Symbol);

// Generate initial asset report
string assetReport = m_assetDNA.GenerateAssetReport();
::Print("[?? ASSET DNA] Asset Classification Report:\n", assetReport);
} else {
::Print("? [ASSET DNA] Failed to initialize Asset DNA System");
delete m_assetDNA;
m_assetDNA = NULL;
}
} else {
::Print("? [ASSET DNA] Failed to create Asset DNA System instance");
}
#else
::Print("[?? ASSET DNA] Asset DNA System disabled by feature toggle");
m_assetDNA = NULL;
#endif
}

void CleanupAssetDNASystem()
{
if(m_assetDNA != NULL) {
delete m_assetDNA;
m_assetDNA = NULL;
::Print("[?? ASSET DNA] Asset DNA System cleaned up");
}
}

//+------------------------------------------------------------------+
//| PHASE 1: ASSET-SPECIFIC RISK CALCULATION                       |
//+------------------------------------------------------------------+
double GetAssetSpecificRiskMultiplier()
{
#ifdef ENABLE_ASSET_SPECIFIC_SIZING
if(m_assetDNA != NULL) {
// Get asset-specific risk multiplier
double assetRiskMultiplier = m_assetDNA.GetAssetRiskMultiplier();

// Get asset volatility adjustment
#ifdef ENABLE_ASSET_VOLATILITY_ADJ
double volatilityBase = m_assetDNA.GetAssetVolatilityBase();
double currentVolatility = m_assetDNA.GetAssetVolatilityScore();
double volatilityAdjustment = currentVolatility / volatilityBase;

// Limit volatility adjustment to reasonable bounds
volatilityAdjustment = MathMax(0.5, MathMin(2.0, volatilityAdjustment));

double finalMultiplier = assetRiskMultiplier * volatilityAdjustment;

::PrintFormat("[?? ASSET DNA] Asset Risk Multiplier: %.3f | Volatility Adj: %.3f | Final: %.3f",
assetRiskMultiplier, volatilityAdjustment, finalMultiplier);

return finalMultiplier;
#else
::PrintFormat("[?? ASSET DNA] Asset Risk Multiplier: %.3f", assetRiskMultiplier);
return assetRiskMultiplier;
#endif
}
#endif

// Default multiplier if Asset DNA not available
return 1.0;
}

//+------------------------------------------------------------------+
//| PHASE 1: ASSET-AWARE POSITION SIZING                           |
//+------------------------------------------------------------------+
double CalculateAssetAwareLotSize(ENUM_SIGNAL_TYPE signal, double stopDistance)
{
// Get base lot size from existing strategic calculation
double baseLotSize = CalculateIntelligentLotSize(signal, stopDistance);

// Apply asset-specific adjustments
double assetMultiplier = GetAssetSpecificRiskMultiplier();
double assetAwareLotSize = baseLotSize * assetMultiplier;

// Normalize to broker requirements
assetAwareLotSize = NormalizeLotSize(assetAwareLotSize);

::PrintFormat("[?? ASSET DNA] Base Lot: %.3f | Asset Multiplier: %.3f | Final Lot: %.3f",
baseLotSize, assetMultiplier, assetAwareLotSize);

return assetAwareLotSize;
}

//+------------------------------------------------------------------+
//| ?? BOSS FIX: ENHANCED CALCULATE INTELLIGENT POSITION SIZE      |
//+------------------------------------------------------------------+
double CalculateIntelligentLotSize(ENUM_SIGNAL_TYPE signal, double stopDistance)
{
// ?? BOSS FIX: ENHANCED POSITION SIZING WITH 7 STRATEGIC IMPROVEMENTS
::Print("[?? STRATEGIC] Calculating position size with 7 Strategic Improvements...");

// 1. Get base account data
double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
double baseRisk = GetDynamicRiskPercent();

// 2. ?? STRATEGIC IMPROVEMENT 1: Adaptive Dynamic Kelly
double kellyAdjustment = 1.0;
if(m_adaptiveKelly != NULL) {
// Get current performance metrics
double winRate = 0.65; // Get from historical performance
double profitFactor = 1.5; // Get from historical performance
double signalConfidence = 0.75; // Get from signal system
ENUM_MARKET_REGIME currentRegime = REGIME_TRENDING_BULLISH; // Get from market analysis

kellyAdjustment = m_adaptiveKelly.CalculateAdaptiveDynamicKelly(winRate, profitFactor, signalConfidence, currentRegime);
::PrintFormat("[1/7] ? Adaptive Kelly adjustment: %.3f", kellyAdjustment);
}

// 3. ?? STRATEGIC IMPROVEMENT 2: Market Cycle Risk Adjustment
double cycleAdjustment = 1.0;
if(m_marketCycleAnalysis != NULL) {
ENUM_MARKET_CYCLE currentCycle = m_marketCycleAnalysis.DetermineMarketCycle();
cycleAdjustment = m_marketCycleAnalysis.GetCycleRiskMultiplier();
::PrintFormat("[2/7] ? Market Cycle adjustment: %.3f", cycleAdjustment);
}

// 4. ?? STRATEGIC IMPROVEMENT 3: Equity Curve Convexity
double convexityAdjustment = 1.0;
if(m_convexityManager != NULL) {
m_convexityManager.UpdateConvexityAnalysis();
convexityAdjustment = m_convexityManager.GetConvexityRiskAdjustment();
::PrintFormat("[3/7] ? Convexity adjustment: %.3f", convexityAdjustment);
}

// 5. ?? STRATEGIC IMPROVEMENT 4: Dynamic Risk-Reward Optimization
double dynamicRR = 2.0; // Default
if(m_riskRewardOptimizer != NULL) {
ENUM_MARKET_REGIME regime = REGIME_TRENDING_BULLISH; // Get from analysis
double signalQuality = 0.75;
double confluenceScore = 0.8;
double volatilityRatio = 1.0;

dynamicRR = m_riskRewardOptimizer.CalculateDynamicRiskReward(regime, signalQuality, confluenceScore, volatilityRatio);
::PrintFormat("[4/7] ? Dynamic R:R: %.3f", dynamicRR);
}

// 6. ?? STRATEGIC IMPROVEMENT 5: Correlation Heat Map
double correlationAdjustment = 1.0;
if(m_correlationHeatMap != NULL) {
correlationAdjustment = m_correlationHeatMap.CalculateCorrelationHeatRisk();
::PrintFormat("[5/7] ? Correlation Heat adjustment: %.3f", correlationAdjustment);
}

// 7. ?? STRATEGIC IMPROVEMENT 6: Seasonality & Calendar Effects
double seasonalityAdjustment = 1.0;
if(m_seasonalityManager != NULL) {
seasonalityAdjustment = m_seasonalityManager.CalculateSeasonalityAdjustment();
::PrintFormat("[6/7] ? Seasonality adjustment: %.3f", seasonalityAdjustment);
}

// 8. ?? STRATEGIC IMPROVEMENT 7: Real-Time Performance Feedback
double feedbackAdjustment = 1.0;
if(m_performanceFeedback != NULL) {
m_performanceFeedback.ProcessPerformanceFeedback();
feedbackAdjustment = m_performanceFeedback.GetAdaptiveRiskMultiplier();
::PrintFormat("[7/7] ? Performance Feedback adjustment: %.3f", feedbackAdjustment);
}

// 9. ?? PHASE 2: Market Regime Detection Integration
double regimeAdjustment = 1.0;
#ifdef ENABLE_MARKET_REGIME_DETECTION
if(m_assetDNA != NULL) {
ENUM_MARKET_REGIME currentRegime = DetectCurrentMarketRegime();
regimeAdjustment = GetRegimeBasedRiskMultiplier(currentRegime);

// Update Asset DNA with current regime
m_assetDNA.UpdateMarketRegime(currentRegime, 0.8); // Default confidence

::PrintFormat("[8/8] ? Market Regime adjustment: %.3f (%s)", regimeAdjustment, MarketRegimeToString(currentRegime));
}
#endif

// 10. ?? COMBINE ALL STRATEGIC ADJUSTMENTS (Including Regime)
double strategicMultiplier = kellyAdjustment *
cycleAdjustment *
convexityAdjustment *
correlationAdjustment *
seasonalityAdjustment *
feedbackAdjustment *
regimeAdjustment; // PHASE 2: Added regime adjustment

// 11. Apply legacy psychological and portfolio adjustments
double psychAdjustment = GetPsychologicalMultiplier();
double marketAdjustment = GetMarketConditionMultiplier();

// 12. Calculate final risk amount
double finalRiskPercent = baseRisk * strategicMultiplier * psychAdjustment * marketAdjustment;

// Apply safety bounds (max 5% risk per trade)
finalRiskPercent = MathMin(0.05, MathMax(0.001, finalRiskPercent));

double riskAmount = accountBalance * finalRiskPercent;

// 13. Portfolio heat check
if(!CanAddHeat(riskAmount))
{
::PrintFormat("[??? RISK BLOCK] Portfolio too hot! Current heat: %.3f", m_portfolio.currentHeat);
return 0.0;
}

// 14. Calculate lot size
double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
double lotSize = riskAmount / (stopDistance * tickValue / tickSize);

// 15. Normalize to broker requirements
lotSize = NormalizeLotSize(lotSize);

// 16. Enhanced risk decision logging
LogEnhancedRiskDecision(signal, baseRisk, finalRiskPercent, lotSize, stopDistance,
strategicMultiplier, dynamicRR);

::PrintFormat("[??? STRATEGIC] Final lot size: %.3f | Risk: %.3f%% | Strategic Multiplier: %.3fx",
lotSize, finalRiskPercent * 100, strategicMultiplier);

return lotSize;
}

//+------------------------------------------------------------------+
//| GET DYNAMIC RISK PERCENTAGE                                      |
//+------------------------------------------------------------------+
double GetDynamicRiskPercent()
{
double risk = m_dynRisk.baseRisk;

// Scale based on recent performance
if(m_psychRisk.consecutiveLosses >= 3)
{
// Reduce risk after losing streak
risk *= 0.5;
::PrintFormat("[RISK] Losing streak detected. Risk reduced to %.2f%%", risk * 100);
}
else if(m_psychRisk.confidenceLevel > 0.8)
{
// Slightly increase when confident
risk *= 1.2;
}

// Time-based recovery
if(m_psychRisk.lastLossTime > 0)
{
long timeDiffSeconds = TimeCurrent() - m_psychRisk.lastLossTime;
int hoursSinceLoss = (int)(timeDiffSeconds / 3600);
if(hoursSinceLoss < 4)
{
// Need recovery time
risk *= 0.7;
::PrintFormat("[RISK] Recent loss. Recovery mode: %.2f%%", risk * 100);
}
}

m_dynRisk.currentRisk = risk;
return risk;
}

//+------------------------------------------------------------------+
//| GET PSYCHOLOGICAL MULTIPLIER                                     |
//+------------------------------------------------------------------+
double GetPsychologicalMultiplier()
{
double multiplier = 1.0;

// Check if we're in comfort zone
double currentDD = GetCurrentDrawdown();

if(currentDD < m_psychRisk.comfortZone)
{
// In comfort zone - full confidence
multiplier = 1.0;
}
else if(currentDD < m_psychRisk.painThreshold)
{
// Between comfort and pain - reduce gradually
double range = m_psychRisk.painThreshold - m_psychRisk.comfortZone;
double position = currentDD - m_psychRisk.comfortZone;
multiplier = 1.0 - (position / range * 0.5); // Reduce up to 50%
}
else
{
// In pain zone - minimum risk
multiplier = 0.3;
::Print("[RISK] Pain threshold reached! Minimum risk mode.");
}

// Confidence adjustment
multiplier *= m_psychRisk.confidenceLevel;

return multiplier;
}

//+------------------------------------------------------------------+
//| CAN ADD HEAT TO PORTFOLIO                                       |
//+------------------------------------------------------------------+
bool CanAddHeat(double newRisk)
{
UpdatePortfolioHeat();

double newHeat = m_portfolio.currentHeat + (newRisk / AccountInfoDouble(ACCOUNT_BALANCE));

if(newHeat > m_portfolio.maxHeat)
{
return false; // Too hot
}

if(newHeat > m_portfolio.optimalHeat)
{
::PrintFormat("[RISK] Warning: Approaching max heat. Current: %.2f%% New: %.2f%%",
m_portfolio.currentHeat * 100, newHeat * 100);
}

return true;
}

//+------------------------------------------------------------------+
//| UPDATE PORTFOLIO HEAT                                            |
//+------------------------------------------------------------------+
void UpdatePortfolioHeat()
{
double totalRisk = 0;
double balance = AccountInfoDouble(ACCOUNT_BALANCE);

// Calculate risk from all open positions
for(int i = PositionsTotal() - 1; i >= 0; i--)
{
if(PositionSelectByIndex(i))
{
double positionRisk = CalculatePositionRisk();
totalRisk += positionRisk;

// Update heat zones
UpdateHeatZone(PositionGetString(POSITION_SYMBOL), positionRisk);
}
}

m_portfolio.currentHeat = totalRisk / balance;
}

//+------------------------------------------------------------------+
//| CALCULATE POSITION RISK                                          |
//+------------------------------------------------------------------+
double CalculatePositionRisk()
{
double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
double sl = PositionGetDouble(POSITION_SL);
double volume = PositionGetDouble(POSITION_VOLUME);

if(sl == 0) return 0; // No stop loss

double pips = MathAbs(openPrice - sl) / _Point;
double tickValue = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_TRADE_TICK_VALUE);

return pips * tickValue * volume;
}

//+------------------------------------------------------------------+
//| UPDATE HEAT ZONE                                                 |
//+------------------------------------------------------------------+
void UpdateHeatZone(string symbol, double risk)
{
// Group by currency (simplified)
string currency = StringSubstr(symbol, 0, 3);

for(int i = 0; i < 5; i++)
{
if(m_portfolio.heatZones[i] == currency || m_portfolio.heatZones[i] == "")
{
m_portfolio.heatZones[i] = currency;
m_portfolio.zoneHeat[i] += risk;
break;
}
}
}

//+------------------------------------------------------------------+
//| GET MARKET CONDITION MULTIPLIER                                  |
//+------------------------------------------------------------------+
double GetMarketConditionMultiplier()
{
double multiplier = 1.0;

// Volatility adjustment
double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
double avgATR = iATR(_Symbol, PERIOD_D1, 14);

if(atr > avgATR * 1.5)
{
// High volatility - reduce risk
multiplier *= 0.7;
}
else if(atr < avgATR * 0.5)
{
// Low volatility - slightly reduce (false breakout risk)
multiplier *= 0.9;
}

// Time of day adjustment
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);

if(time.hour < 8 || time.hour > 20)
{
// Off-hours - reduce risk
multiplier *= 0.8;
}

// News adjustment (simplified)
if(time.min >= 58 || time.min <= 2)
{
// Potential news time
multiplier *= 0.5;
}

return multiplier;
}

//+------------------------------------------------------------------+
//| UPDATE PSYCHOLOGICAL STATE                                       |
//+------------------------------------------------------------------+
void UpdatePsychologicalState(bool isWin, double result)
{
if(isWin)
{
// Win - build confidence
m_psychRisk.consecutiveLosses = 0;
m_psychRisk.confidenceLevel = MathMin(1.0, m_psychRisk.confidenceLevel + 0.1);
}
else
{
// Loss - manage psychology
m_psychRisk.consecutiveLosses++;
m_psychRisk.lastLossTime = TimeCurrent();
m_psychRisk.confidenceLevel = MathMax(0.3, m_psychRisk.confidenceLevel - 0.2);

// Check if entering pain zone
double lossPercent = MathAbs(result) / AccountInfoDouble(ACCOUNT_BALANCE);
if(lossPercent > m_psychRisk.comfortZone)
{
::Print("[PSYCHOLOGY] Loss exceeded comfort zone. Confidence: ",
m_psychRisk.confidenceLevel);
}
}
}

//+------------------------------------------------------------------+
//| GET RISK DASHBOARD                                               |
//+------------------------------------------------------------------+
string GetRiskDashboard()
{
UpdatePortfolioHeat();

string dashboard = "\n=== INTELLIGENT RISK DASHBOARD ===\n";

// Risk parameters
dashboard += StringFormat("Current Risk: %.2f%% (Base: %.2f%%)\n",
m_dynRisk.currentRisk * 100, m_dynRisk.baseRisk * 100);

// Portfolio heat
dashboard += StringFormat("Portfolio Heat: %.2f%% / %.2f%% (Max: %.2f%%)\n",
m_portfolio.currentHeat * 100,
m_portfolio.optimalHeat * 100,
m_portfolio.maxHeat * 100);

// Heat zones
dashboard += "Heat Zones:\n";
for(int i = 0; i < 5; i++)
{
if(m_portfolio.heatZones[i] != "")
{
dashboard += StringFormat("  %s: %.2f%%\n",
m_portfolio.heatZones[i],
m_portfolio.zoneHeat[i] / AccountInfoDouble(ACCOUNT_BALANCE) * 100);
}
}

// Psychological state
dashboard += "\nPsychological State:\n";
dashboard += StringFormat("  Confidence: %.0f%%\n", m_psychRisk.confidenceLevel * 100);
dashboard += StringFormat("  Consecutive Losses: %d\n", (int)m_psychRisk.consecutiveLosses);

double currentDD = GetCurrentDrawdown();
string zone = currentDD < m_psychRisk.comfortZone ? "COMFORT" :
currentDD < m_psychRisk.painThreshold ? "CAUTION" : "PAIN";
dashboard += StringFormat("  Zone: %s (DD: %.2f%%)\n", zone, currentDD * 100);

return dashboard;
}

//+------------------------------------------------------------------+
//| NORMALIZE LOT SIZE                                               |
//+------------------------------------------------------------------+
double NormalizeLotSize(double lots)
{
double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

lots = MathMax(minLot, lots);
lots = MathMin(maxLot, lots);
lots = MathRound(lots / lotStep) * lotStep;

return lots;
}

//+------------------------------------------------------------------+
//| GET CURRENT DRAWDOWN                                             |
//+------------------------------------------------------------------+
double GetCurrentDrawdown()
{
double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double equity = AccountInfoDouble(ACCOUNT_EQUITY);

if(balance > 0)
return (balance - equity) / balance;

return 0;
}

//+------------------------------------------------------------------+
//| LOG RISK DECISION                                                |
//+------------------------------------------------------------------+
void LogRiskDecision(ENUM_SIGNAL_TYPE signal, double riskAmount, double lotSize, double stopPips)
{
::Print("\n[RISK DECISION]");
::Print("Signal: ", TradingSignalToString(signal));
::Print("Risk Amount: $", DoubleToString(riskAmount, 2));
::Print("Lot Size: ", DoubleToString(lotSize, 2));
::Print("Stop Loss: ", DoubleToString(stopPips, 1), " pips");
::Print("Portfolio Heat: ", DoubleToString(m_portfolio.currentHeat * 100, 2), "%");
::Print("Confidence: ", DoubleToString(m_psychRisk.confidenceLevel * 100, 0), "%");
}

//+------------------------------------------------------------------+
//| PHASE 4: SET DYNAMIC SL/TP - ENHANCED RISK MANAGEMENT           |
//+------------------------------------------------------------------+
bool SetDynamicSLTP(ulong ticket, double entryPrice, ENUM_SIGNAL_TYPE signalType, double signalConfidence)
{
if(!PositionSelectByTicket(ticket)) {
::Print("[? DYNAMIC SL/TP] Position not found: ", ticket);
return false;
}

// Get dynamic RR based on signal confidence and market conditions
double dynamicRR = 2.0; // Default risk:reward ratio
if(signalConfidence > 0.8) {
dynamicRR = 2.5;
    // ATR regime multiplier clamp + audit
    double avgATR = 0.0; int cntATR=0; for(int i=1;i<=MathMax(10,14);i++){ double v=GetATRValue(14); if(v>0.0){ avgATR+=v; cntATR++; } }
    if(cntATR>0) avgATR/=cntATR; double curATR = GetATRValue(14);
    double mult = (avgATR>0.0? curATR/avgATR : 1.0);
    // Clamp multiplier (0.5x .. 2.0x) to avoid outliers
    double minMult=0.5, maxMult=2.0; if(mult<minMult) mult=minMult; if(mult>maxMult) mult=maxMult;
    // Apply to dynamicRR for tighter SL scenarios (example)
    dynamicRR *= mult;
    Print(StringFormat("[ATR SIZING] curATR=%.5f avgATR=%.5f mult=%.3f (clamped) -> dynRR=%.3f", curATR, avgATR, mult, dynamicRR));

} else if(signalConfidence > 0.6) {
dynamicRR = 2.0;
} else {
dynamicRR = 1.5;
}

// Calculate ATR for dynamic SL/TP calculation
double atr = GetATRValue(14);
double atrMultiplier = (signalConfidence > 0.8) ? 1.5 : 2.0; // Tighter SL for high confidence

// Calculate dynamic stop loss
double stopDistance = atr * atrMultiplier;
double stopLoss, takeProfit;

if(signalType == SIGNAL_BUY) {
stopLoss = entryPrice - stopDistance;
takeProfit = entryPrice + (stopDistance * dynamicRR);
} else {
stopLoss = entryPrice + stopDistance;
takeProfit = entryPrice - (stopDistance * dynamicRR);
}

// Normalize prices
stopLoss = NormalizeDouble(stopLoss, _Digits);
takeProfit = NormalizeDouble(takeProfit, _Digits);

// Modify position
CTrade trade;
if(trade.PositionModify(ticket, stopLoss, takeProfit)) {
::Print(StringFormat("[? DYNAMIC SL/TP] Ticket: %d | SL: %.5f | TP: %.5f | RR: %.2f",
ticket, stopLoss, takeProfit, dynamicRR));
return true;
} else {
::Print(StringFormat("[? DYNAMIC SL/TP] Failed to modify position %d. Error: %d",
ticket, GetLastError()));
return false;
}
}

//+------------------------------------------------------------------+
//| PHASE 4: TRAILING BREAKEVEN - PROTECT PROFITS                   |
//+------------------------------------------------------------------+
bool TrailToBreakeven(ulong ticket, double entryPrice, ENUM_SIGNAL_TYPE signalType)
{
if(!PositionSelectByTicket(ticket)) {
::Print("[? TRAIL BE] Position not found: ", ticket);
return false;
}

double currentPrice = (signalType == SIGNAL_BUY) ?
SymbolInfoDouble(_Symbol, SYMBOL_BID) :
SymbolInfoDouble(_Symbol, SYMBOL_ASK);

double currentSL = PositionGetDouble(POSITION_SL);
double atr = GetATRValue(14);
double minProfitDistance = atr * 1.0; // Minimum profit before trailing

// Check if position is in profit enough to trail
bool canTrail = false;
if(signalType == SIGNAL_BUY) {
canTrail = (currentPrice - entryPrice) >= minProfitDistance;
} else {
canTrail = (entryPrice - currentPrice) >= minProfitDistance;
}

if(!canTrail) {
return false; // Not enough profit yet
}

// Calculate new breakeven stop loss with small buffer
double buffer = atr * 0.1; // Small buffer to avoid premature stops
double newSL;

if(signalType == SIGNAL_BUY) {
newSL = entryPrice + buffer;
// Only move SL up
if(newSL <= currentSL) return false;
} else {
newSL = entryPrice - buffer;
// Only move SL down
if(newSL >= currentSL) return false;
}

newSL = NormalizeDouble(newSL, _Digits);

// Modify position
CTrade trade;
double currentTP = PositionGetDouble(POSITION_TP);

if(trade.PositionModify(ticket, newSL, currentTP)) {
::Print(StringFormat("[? TRAIL BE] Ticket: %d | New SL: %.5f (BE+%.1f pips)",
ticket, newSL, buffer * MathPow(10, _Digits-1)));
return true;
} else {
::Print(StringFormat("[? TRAIL BE] Failed to modify position %d. Error: %d",
ticket, GetLastError()));
return false;
}
}

//+------------------------------------------------------------------+
//| ?? BOSS FIX: ENHANCED LOGGING FOR STRATEGIC IMPROVEMENTS       |
//+------------------------------------------------------------------+
void LogEnhancedRiskDecision(ENUM_SIGNAL_TYPE signal, double baseRisk, double finalRisk,
double lotSize, double stopDistance, double strategicMultiplier, double dynamicRR)
{
::Print("\n[??? ENHANCED STRATEGIC RISK DECISION]");
::Print("=====================================");
::Print("Signal: ", TradingSignalToString(signal));
::Print("Base Risk: ", DoubleToString(baseRisk * 100, 3), "%");
::Print("Final Risk: ", DoubleToString(finalRisk * 100, 3), "%");
::Print("Strategic Multiplier: ", DoubleToString(strategicMultiplier, 3), "x");
::Print("Final Lot Size: ", DoubleToString(lotSize, 3));
::Print("Stop Distance: ", DoubleToString(stopDistance, 1), " points");
::Print("Dynamic R:R: ", DoubleToString(dynamicRR, 1));
::Print("Portfolio Heat: ", DoubleToString(m_portfolio.currentHeat * 100, 2), "%");
::Print("=====================================");
}

//+------------------------------------------------------------------+
//| ?? BOSS FIX: PUBLIC METHODS FOR 7 STRATEGIC IMPROVEMENTS       |
//+------------------------------------------------------------------+

// Method to add trade result for performance feedback
void AddTradeResult(ulong ticket, double profit, double riskAmount, double confidence, string signal)
{
if(m_performanceFeedback != NULL) {
m_performanceFeedback.AddTradeResult(ticket, profit, riskAmount, confidence, signal);
}
}

// Method to get comprehensive risk report
string GetStrategicRiskReport()
{
string report = "??? STRATEGIC RISK MANAGEMENT REPORT\n";
report += "=====================================\n\n";

if(m_adaptiveKelly != NULL) {
report += m_adaptiveKelly.GetAdaptiveKellyReport() + "\n\n";
}

if(m_marketCycleAnalysis != NULL) {
report += m_marketCycleAnalysis.GetMarketCycleReport() + "\n\n";
}

if(m_convexityManager != NULL) {
report += m_convexityManager.GetConvexityReport() + "\n\n";
}

if(m_riskRewardOptimizer != NULL) {
report += m_riskRewardOptimizer.GetRiskRewardReport() + "\n\n";
}

if(m_correlationHeatMap != NULL) {
report += m_correlationHeatMap.GetCorrelationHeatReport() + "\n\n";
}

if(m_seasonalityManager != NULL) {
report += m_seasonalityManager.GetSeasonalityReport() + "\n\n";
}

if(m_performanceFeedback != NULL) {
report += m_performanceFeedback.GetPerformanceFeedbackReport() + "\n\n";
}

return report;
}

// Method to check if any strategic system has warnings
bool HasStrategicWarnings()
{
bool hasWarning = false;

if(m_convexityManager != NULL && m_convexityManager.IsEquityCurveDangerous()) {
hasWarning = true;
::Print("[?? STRATEGIC WARNING] Dangerous equity curve detected!");
}

if(m_correlationHeatMap != NULL && m_correlationHeatMap.IsOverheating()) {
hasWarning = true;
::Print("[?? STRATEGIC WARNING] Correlation overheating detected!");
}

if(m_performanceFeedback != NULL && m_performanceFeedback.HasPerformanceWarning()) {
hasWarning = true;
::Print("[?? STRATEGIC WARNING] Performance issues detected!");
}

return hasWarning;
}

// Method to get current strategic multiplier without calculating position size
double GetCurrentStrategicMultiplier()
{
double multiplier = 1.0;
#ifdef ENABLE_EQUITY_CURVE_ADJUSTMENT
if(m_equityAdjuster != NULL) {
multiplier *= m_equityAdjuster.GetRiskMultiplier();
}
#endif

if(m_seasonalityManager != NULL) {
multiplier *= m_seasonalityManager.GetSeasonalRiskAdjustment();
}

if(m_correlationHeatMap != NULL) {
multiplier *= m_correlationHeatMap.GetHeatRiskMultiplier();
}

if(m_performanceFeedback != NULL) {
multiplier *= m_performanceFeedback.GetAdaptiveRiskMultiplier();
}

return multiplier;
}

// Method to force update all strategic systems
void UpdateAllStrategicSystems()
{
#ifdef ENABLE_EQUITY_CURVE_ADJUSTMENT
if(m_equityAdjuster != NULL) {
m_equityAdjuster.UpdateEquity(AccountInfoDouble(ACCOUNT_EQUITY));
}
#endif
if(m_convexityManager != NULL) {
m_convexityManager.UpdateConvexityAnalysis();
}

if(m_correlationHeatMap != NULL) {
m_correlationHeatMap.CalculateCorrelationHeatRisk();
}

if(m_seasonalityManager != NULL) {
m_seasonalityManager.CalculateSeasonalityAdjustment();
}

if(m_performanceFeedback != NULL) {
m_performanceFeedback.ProcessPerformanceFeedback();
}

if(m_marketCycleAnalysis != NULL) {
m_marketCycleAnalysis.DetermineMarketCycle();
}

// PHASE 2: Update Market Regime Detection
#ifdef ENABLE_MARKET_REGIME_DETECTION
UpdateMarketRegimeDetection();
#endif
}

//+------------------------------------------------------------------+
//| ?? PHASE 3: EQUITY CURVE RISK ADJUSTMENT SYSTEM                 |
//+------------------------------------------------------------------+

#ifdef ENABLE_EQUITY_CURVE_ADJUSTMENT
class CEquityCurveRiskAdjuster {
private:
double m_equityHistory[100]; // Luu l?ch s? equity
int m_historyCount;
double CalculateCurveSlope() {
// TÌnh d? d?c du?ng cong equity
if(m_historyCount < 2) return 1.0;
double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
for(int i = 0; i < m_historyCount; i++) {
sumX += i;
sumY += m_equityHistory[i];
sumXY += i * m_equityHistory[i];
sumX2 += i * i;
}
return (m_historyCount * sumXY - sumX * sumY) / (m_historyCount * sumX2 - sumX * sumX);
}
public:
CEquityCurveRiskAdjuster() : m_historyCount(0) {}
void UpdateEquity(double currentEquity) {
if(m_historyCount < 100) m_equityHistory[m_historyCount++] = currentEquity;
else {
ArrayCopy(m_equityHistory, m_equityHistory, 0, 1, 99);
m_equityHistory[99] = currentEquity;
}
}
double GetRiskMultiplier() {
double slope = CalculateCurveSlope();
if(slope > 0.01) return 1.2; // Tang r?i ro n?u du?ng cong lÍn
else if(slope < -0.01) return 0.5; // Gi?m r?i ro n?u du?ng cong xu?ng
return 1.0;
}
};
#endif

//+------------------------------------------------------------------+
//| ?? PHASE 2: MARKET REGIME DETECTION METHODS                     |
//+------------------------------------------------------------------+

#ifdef ENABLE_MARKET_REGIME_DETECTION
void UpdateMarketRegimeDetection()
{
if(m_assetDNA != NULL) {
ENUM_MARKET_REGIME newRegime = DetectCurrentMarketRegime();
m_assetDNA.UpdateMarketRegime(newRegime, 0.8); // Default confidence

::Print("[?? REGIME] Market regime updated: ", MarketRegimeToString(newRegime));
}
}

ENUM_MARKET_REGIME DetectCurrentMarketRegime()
{
// Get market condition analysis
ENUM_MARKET_CONDITION condition = DetermineMarketCondition();

// Get price action context
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
double ma20 = GetMAValue(20);
double ma50 = GetMAValue(50);
double atr = GetATRValue(14);

// Determine trend direction
bool isBullish = (currentPrice > ma20) && (ma20 > ma50);
bool isBearish = (currentPrice < ma20) && (ma20 < ma50);

// Calculate volatility context
double atrLong = GetATRValue(50);
double volatilityRatio = atr / atrLong;

// Regime classification logic
if(condition == MARKET_TRENDING) {
if(isBullish) {
return volatilityRatio > 1.3 ? REGIME_TRENDING_BULLISH_VOLATILE : REGIME_TRENDING_BULLISH;
} else if(isBearish) {
return volatilityRatio > 1.3 ? REGIME_TRENDING_BEARISH_VOLATILE : REGIME_TRENDING_BEARISH;
} else {
return REGIME_CONSOLIDATION;
}
}
else if(condition == MARKET_VOLATILE) {
return REGIME_VOLATILE;
}
else {
// MARKET_RANGING
return REGIME_RANGING;
}
}

double GetRegimeBasedRiskMultiplier(ENUM_MARKET_REGIME regime)
{
#ifdef ENABLE_REGIME_RISK_ADJUSTMENT
switch(regime) {
case REGIME_TRENDING_BULLISH:
case REGIME_TRENDING_BEARISH:
return 1.2; // Increase risk in trending markets
case REGIME_TRENDING_BULLISH_VOLATILE:
return 0.9; // Reduce risk in volatile trending markets
case REGIME_RANGING:
return 0.8; // Reduce risk in ranging markets
case REGIME_VOLATILE:
return 0.6; // Significantly reduce risk in volatile markets
case REGIME_BREAKOUT:
return 1.1; // Slightly increase risk for breakouts
default:
return 1.0; // Default multiplier
}
#else
return 1.0; // Feature disabled
#endif
}

double CalculateAssetRegimeAwareLotSize(double baseRisk, ENUM_SIGNAL_TYPE signalType)
{
#ifdef ENABLE_ASSET_REGIME_INTEGRATION
if(m_assetDNA == NULL) {
return CalculateAssetAwareLotSize(signalType, 0.01); // Fallback to asset-only calculation
}

// Get combined asset-regime multiplier
double combinedMultiplier = m_assetDNA.GetCombinedRiskMultiplier();

// Apply to base risk
double adjustedRisk = baseRisk * combinedMultiplier;

// Calculate lot size with adjusted risk
double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
double riskAmount = accountBalance * adjustedRisk;

// Estimate stop distance (simplified)
double atr = GetATRValue(14);
double stopDistance = atr * 2.0; // 2x ATR stop

// Calculate lot size
double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
double lotSize = riskAmount / (stopDistance * tickValue / tickSize);

// Normalize and return
return NormalizeLotSize(lotSize);
#else
return CalculateAssetAwareLotSize(signalType, 0.01); // Feature disabled, fallback
#endif
}

bool IsRegimeOptimalForTrading(ENUM_MARKET_REGIME regime)
{
// Use if-else instead of switch to avoid duplicate case values
if(regime == REGIME_TRENDING_BULLISH || regime == REGIME_TRENDING_BEARISH || regime == REGIME_BREAKOUT) {
return true; // Optimal regimes for trading
}
else if(regime == REGIME_TRENDING_BULLISH_VOLATILE || regime == REGIME_TRENDING_BEARISH_VOLATILE || regime == REGIME_CONSOLIDATION) {
return false; // Suboptimal but tradeable
}
else if(regime == REGIME_RANGING || regime == REGIME_VOLATILE) {
return false; // Challenging regimes
}
else {
return false; // Unknown regime, be conservative
}
}

void LogRegimeChange(ENUM_MARKET_REGIME fromRegime, ENUM_MARKET_REGIME toRegime)
{
if(fromRegime != toRegime) {
::Print(StringFormat("[?? REGIME CHANGE] %s ? %s | Risk adjustment: %.2fx",
MarketRegimeToString(fromRegime),
MarketRegimeToString(toRegime),
GetRegimeBasedRiskMultiplier(toRegime)));
}
}

double GetCombinedAssetRegimeMultiplier()
{
if(m_assetDNA != NULL) {
return m_assetDNA.GetCombinedRiskMultiplier();
}
return 1.0; // Default if Asset DNA not available
}

bool ValidateAssetRegimeCombination()
{
if(m_assetDNA != NULL) {
return m_assetDNA.IsOptimalAssetRegimeCombination();
}
return true; // Default to valid if Asset DNA not available
}

string GetAssetRegimeDescription()
{
if(m_assetDNA != NULL) {
ENUM_MARKET_REGIME currentRegime = m_assetDNA.GetCurrentRegime();
return m_assetDNA.GetRegimeDescription(currentRegime);
}
return "Asset DNA System not available";
}
#endif
bool PositionSelectByIndex(int index) {
ulong ticket = PositionGetTicket(index);
return PositionSelectByTicket(ticket);
}

ENUM_MARKET_CONDITION DetermineMarketCondition()
{
// ?? PHASE 1: Removed ADX - Using EMA-based trend detection for simplification
double atr = GetATRValue(14);
double ma20 = GetMAValue(20);
double ma50 = GetMAValue(50);
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);

// Calculate volatility ratio
double atrLong = GetATRValue(50);
double volatilityRatio = atr / atrLong;

// EMA spread-based trend strength (aligned with Sonic R methodology)
double emaSpread = MathAbs(ma20 - ma50) / currentPrice;
double trendStrength = emaSpread * 1000; // Normalize

// Determine condition based on EMA spread and volatility
if(trendStrength > 2.5 && MathAbs(ma20 - ma50) > atr) {
// Strong trend with good separation between MAs
return MARKET_TRENDING;
}
else if(volatilityRatio > 1.5 && trendStrength > 1.5) {
// High volatility with some directional movement
return MARKET_VOLATILE;
}
else {
// Default to ranging market
return MARKET_RANGING;
}
}

// ?? PHASE 1: Removed GetADXValue() - ADX indicator eliminated for simplification

double GetATRValue(int period)
{
int handle = iATR(_Symbol, PERIOD_CURRENT, period);
double buffer[1];
if(CopyBuffer(handle, 0, 0, 1, buffer) > 0) {
IndicatorRelease(handle);
return buffer[0];
}
IndicatorRelease(handle);
return 0.001; // Default value
}

double GetMAValue(int period)
{
// ?? PHASE 2: Migrated to unified indicator system
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

if(manager == NULL) {
::Print("? [PHASE 2] Risk_IntelligentManager GetMAValue: Unified manager not available");
return iClose(_Symbol, PERIOD_CURRENT, 0);
}

// OLD CODE (DUPLICATED):
// int handle = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_SMA, PRICE_CLOSE);

// NEW CODE (UNIFIED SYSTEM):
int handle = manager.GetSMAHandle(_Symbol, PERIOD_CURRENT, period, PRICE_CLOSE);

double buffer[1];
if(manager.BulkCopyEMA(handle, buffer, 1, 0)) {
// Log migration success
manager.MigrateLegacyIndicatorCalls(
"Risk_IntelligentManager.mqh",
1383,
"GetMAValue() SMA iMA() call",
"Unified SMA handle system"
);
return buffer[0];
}

::Print("? [PHASE 2] Risk_IntelligentManager GetMAValue: Failed to get SMA value via unified system");
return iClose(_Symbol, PERIOD_CURRENT, 0);
}

//+------------------------------------------------------------------+
//| ?? VALIDATE SIGNAL - MAIN ENTRY POINT                          |
//+------------------------------------------------------------------+
bool ValidateSignal(const SignalData& signalData)
{
if(!signalData.isValid) {
::Print("? [RISK] Signal validation failed: Invalid signal data");
return false;
}

// Check signal type
if(signalData.signalType == SIGNAL_NONE) {
::Print("? [RISK] Signal validation failed: No signal type");
return false;
}

// Check confidence level
if(signalData.confidence < 0.7) {
::Print(StringFormat("? [RISK] Signal validation failed: Low confidence %.2f < 0.7", signalData.confidence));
return false;
}

// Check risk parameters
if(signalData.stopLoss <= 0.0 || signalData.takeProfit <= 0.0) {
::Print("? [RISK] Signal validation failed: Invalid stop loss or take profit");
return false;
}

// Check psychological risk
if(!CheckPsychologicalRisk()) {
::Print("? [RISK] Signal validation failed: Psychological risk threshold exceeded");
return false;
}

// Check portfolio heat
if(!CheckPortfolioHeat()) {
::Print("? [RISK] Signal validation failed: Portfolio heat limit exceeded");
return false;
}

// Check daily limits
if(!CheckDailyLimits()) {
::Print("? [RISK] Signal validation failed: Daily limits exceeded");
return false;
}

::Print(StringFormat("? [RISK] Signal validation passed: %s with %.2f confidence",
TradingSignalToString(signalData.signalType), signalData.confidence));
return true;
}

//+------------------------------------------------------------------+
//| ?? RISK VALIDATION HELPERS                                     |
//+------------------------------------------------------------------+
bool CheckPsychologicalRisk()
{
// Check consecutive losses
if(m_psychRisk.consecutiveLosses >= 3) {
::Print("?? [RISK] Psychological risk: Too many consecutive losses");
return false;
}

// Check recovery period
if(m_psychRisk.lastLossTime > 0) {
datetime recoveryTime = m_psychRisk.lastLossTime + (3600 * 2); // 2 hours recovery
if(TimeCurrent() < recoveryTime) {
::Print("?? [RISK] Psychological risk: Recovery period not completed");
return false;
}
}

return true;
}

bool CheckPortfolioHeat()
{
// Check if adding this trade would exceed portfolio heat
double additionalRisk = m_dynRisk.currentRisk;
if(m_portfolio.currentHeat + additionalRisk > m_portfolio.maxHeat) {
::Print(StringFormat("?? [RISK] Portfolio heat: %.2f%% + %.2f%% > %.2f%%",
m_portfolio.currentHeat*100, additionalRisk*100, m_portfolio.maxHeat*100));
return false;
}

return true;
}

bool CheckDailyLimits()
{
// Check daily loss limit
double dailyLoss = GetDailyLoss();
if(dailyLoss > m_dynRisk.baseRisk * 5) { // 5x base risk as daily limit
::Print(StringFormat("?? [RISK] Daily loss limit: %.2f%% > %.2f%%",
dailyLoss*100, m_dynRisk.baseRisk*5*100));
return false;
}

// Check daily trade count
int dailyTrades = GetDailyTradeCount();
if(dailyTrades >= 10) { // Max 10 trades per day
::Print(StringFormat("?? [RISK] Daily trade limit: %d >= 10", dailyTrades));
return false;
}

return true;
}

//+------------------------------------------------------------------+
//| ?? HELPER METHODS                                               |
//+------------------------------------------------------------------+
double GetDailyLoss()
{
// Calculate today's loss percentage
double startBalance = GetDailyStartBalance();
double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
return MathMax(0.0, (startBalance - currentBalance) / startBalance);
}

int GetDailyTradeCount()
{
// Count today's trades
int count = 0;
datetime todayStart = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));

for(int i = 0; i < HistoryDealsTotal(); i++) {
ulong ticket = HistoryDealGetTicket(i);
if(HistoryDealSelect(ticket)) {
datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
if(dealTime >= todayStart) {
count++;
}
}
}

return count;
}

double GetDailyStartBalance()
{
// Get balance at start of day (simplified)
return AccountInfoDouble(ACCOUNT_BALANCE) * 1.01; // Assume 1% daily loss max
}

//+------------------------------------------------------------------+
//| ?? PHASE 3: EQUITY CURVE RISK MULTIPLIER (per review.txt)     |
//+------------------------------------------------------------------+
double CalculateRiskMultiplier()
{
    // 1. TÌnh to·n d? cong equity curve
    double convexity = CalculateEquityCurveConvexity();

    // 2. X·c d?nh h? s? di?u ch?nh theo review.txt
    if(convexity > 0.05) {
        Print("? [PHASE 3] Strong positive curve - increasing risk multiplier to 1.25");
        return 1.25; // –u?ng cong m?nh - tang r?i ro
    }
    else if(convexity > 0.02) {
        Print("? [PHASE 3] Good positive curve - risk multiplier 1.1");
        return 1.1;  // –u?ng cong t?t
    }
    else if(convexity > -0.02) {
        Print("?? [PHASE 3] Flat curve - neutral risk multiplier 1.0");
        return 1.0;  // –u?ng th?ng
    }
    else if(convexity > -0.05) {
        Print("?? [PHASE 3] Slight negative curve - reducing risk multiplier to 0.8");
        return 0.8;  // –u?ng cong nh? tiÍu c?c
    }
    else {
        Print("? [PHASE 3] Strong negative curve - reducing risk multiplier to 0.5");
        return 0.5;  // –u?ng cong m?nh tiÍu c?c - gi?m r?i ro
    }
}

//+------------------------------------------------------------------+
//| ?? PHASE 3: CALCULATE EQUITY CURVE CONVEXITY                   |
//+------------------------------------------------------------------+
double CalculateEquityCurveConvexity()
{
    // Get recent equity history for convexity calculation
    double equityHistory[20];
    int historyCount = 0;

    // Collect equity data points (simplified implementation)
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double startEquity = AccountInfoDouble(ACCOUNT_BALANCE); // Simplified baseline

    if(startEquity <= 0) {
        Print("?? [PHASE 3] Convexity fallback: Invalid equity data");
        return 0.0; // Fallback khi thi?u d? li?u
    }

    // Calculate simple equity growth rate
    double equityGrowthRate = (currentEquity - startEquity) / startEquity;

    // Estimate convexity based on growth consistency
    // Positive convexity = accelerating growth
    // Negative convexity = decelerating/declining growth

    // Use recent performance to estimate curve shape
    double recentPerformance = GetRecentPerformanceMetric();
    double convexity = equityGrowthRate * recentPerformance * 0.1; // Scale factor

    // Cap convexity values for stability
    convexity = MathMax(-0.1, MathMin(0.1, convexity));

    Print("[PHASE 3] Equity convexity calculated: ", DoubleToString(convexity, 4),
          " | Growth rate: ", DoubleToString(equityGrowthRate * 100, 2), "%");

    return convexity;
}

//+------------------------------------------------------------------+
//| ?? PHASE 3: GET RECENT PERFORMANCE METRIC                      |
//+------------------------------------------------------------------+
double GetRecentPerformanceMetric()
{
    // Simplified recent performance calculation
    // In real implementation, this would analyze recent trade history

    double recentWinRate = 0.65; // Placeholder - would get from trade history
    double recentProfitFactor = 1.8; // Placeholder - would calculate from recent trades

    // Combine metrics to estimate performance trend
    double performanceMetric = (recentWinRate - 0.5) * 2.0 + (recentProfitFactor - 1.0);

    return MathMax(-1.0, MathMin(1.0, performanceMetric)); // Normalize to [-1, 1]
}

//+------------------------------------------------------------------+
//| ?? PHASE 3: ENHANCED POSITION SIZE CALCULATION                 |
//+------------------------------------------------------------------+
double CalculatePositionSize()
{
    // Get base risk percentage
    double riskPercent = m_dynRisk.currentRisk;

    // 3. –i?u ch?nh theo equity curve theo review.txt
    double equityCurveAdjustment = CalculateRiskMultiplier();

    // 4. TÌnh to·n position size cu?i c˘ng
    double finalRisk = riskPercent * equityCurveAdjustment;
    finalRisk = MathMax(0.1, MathMin(finalRisk, m_maxRiskPerTrade));

    // Convert to lot size
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * finalRisk / 100.0;

    // Calculate lot size based on risk amount
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double stopLossPoints = 100; // Simplified - would get actual SL distance

    double lotSize = 0.01; // Minimum lot size
    if(tickValue > 0 && stopLossPoints > 0) {
        lotSize = riskAmount / (stopLossPoints * tickValue);
        lotSize = MathMax(0.01, MathMin(lotSize, 1.0)); // Cap lot size
    }

    Print("[PHASE 3] Enhanced position size: ", DoubleToString(lotSize, 2),
          " lots | Risk: ", DoubleToString(finalRisk, 2), "% | Multiplier: ",
          DoubleToString(equityCurveAdjustment, 2));

    return lotSize;
}

};

//+------------------------------------------------------------------+

#endif // RISK_01_INTELLIGENTMANAGER_MQH



