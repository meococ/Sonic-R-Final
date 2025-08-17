//+------------------------------------------------------------------+
//|                            PropFirm_AutoOptimizer.mqh           |
//|               SONIC R MC - PROP FIRM AUTO-OPTIMIZATION ENGINE    |
//|                       Ð?i Bàng Compliance Revolution            |
//+------------------------------------------------------------------+
#ifndef PROP_FIRM_AUTO_OPTIMIZER_MQH
#define PROP_FIRM_AUTO_OPTIMIZER_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| PRODUCTION FIX: Removed duplicate ENUM_PROP_FIRM enum          |
//| Using definition from SonicR_Enums.mqh to avoid conflicts     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Prop Firm Rules Structure                                       |
//+------------------------------------------------------------------+
struct PropFirmRules {
string firmName;

// Risk Limits
double maxDailyLossPercent;    // Max daily loss %
double maxTotalLossPercent;    // Max total loss %
double minTradingDays;         // Min trading days
double maxTradingDays;         // Max trading days for evaluation

// Position Limits
double maxRiskPerTrade;        // Max risk per trade %
double maxLotSize;             // Max lot size
int maxOpenPositions;          // Max concurrent positions

// Time Restrictions
int minHoldTimeSeconds;        // Min position hold time
bool allowWeekendHolding;      // Can hold over weekend
bool allowNewsTrading;         // Can trade during news

// Consistency Rules
double minWinRate;             // Minimum win rate required
double minProfitFactor;        // Minimum profit factor
bool requireConsistency;       // Consistency rule enforcement

// Scaling Rules
bool allowScaling;             // Can scale position size
double maxCorrelatedRisk;      // Max risk on correlated pairs

void SetDefaults() {
firmName = "Custom";
maxDailyLossPercent = 5.0;
maxTotalLossPercent = 10.0;
minTradingDays = 4;
maxTradingDays = 30;
maxRiskPerTrade = 2.0;
maxLotSize = 20.0;
maxOpenPositions = 10;
minHoldTimeSeconds = 0;
allowWeekendHolding = true;
allowNewsTrading = true;
minWinRate = 0.0;
minProfitFactor = 1.0;
requireConsistency = false;
allowScaling = true;
maxCorrelatedRisk = 10.0;
}
};

//+------------------------------------------------------------------+
//| Optimized Settings Structure                                    |
//+------------------------------------------------------------------+
struct OptimizedSettings {
// Trading Parameters
double riskPerTrade;
double maxDailyRisk;
int maxDailyTrades;
double spreadLimit;

// Signal Quality
double minSignalProbability;
double minRiskReward;

// Time Management
int minHoldTime;
bool enableNewsFilter;

// Position Management
bool enableScaling;
double maxPosition;

string optimizationReason;
};

//+------------------------------------------------------------------+
//| Prop Firm Auto-Optimizer                                       |
//+------------------------------------------------------------------+
class CPropFirmOptimizer {
private:
ENUM_PROP_FIRM m_currentFirm;
PropFirmRules m_rules;
OptimizedSettings m_settings;

// Performance Tracking
double m_currentDailyLoss;
double m_currentTotalLoss;
int m_tradingDaysCount;
int m_todayTradeCount;

// Compliance Status
bool m_isCompliant;
string m_complianceIssues;

public:
CPropFirmOptimizer() {
m_currentFirm = PROP_FIRM_CUSTOM;
m_rules.SetDefaults();
m_currentDailyLoss = 0.0;
m_currentTotalLoss = 0.0;
m_tradingDaysCount = 0;
m_todayTradeCount = 0;
m_isCompliant = true;
m_complianceIssues = "";
}

// ?? BREAKTHROUGH: Auto-Configure for Prop Firm
bool ConfigureForPropFirm(ENUM_PROP_FIRM firmType) {
m_currentFirm = firmType;

switch(firmType) {
case PROP_FIRM_FTMO:
ConfigureFTMO();
break;
case PROP_FIRM_MYFXFUNDS:
ConfigureMyForexFunds();
break;
case PROP_FIRM_TOPTRADER:
ConfigureTopTrader();
break;
case PROP_FIRM_TRUEFOREXFUNDS:
ConfigureTrueForexFunds();
break;
case PROP_FIRM_NOVA:
ConfigureNova();
break;
default:
m_rules.SetDefaults();
break;
}

// Optimize settings based on rules
OptimizeSettingsForCompliance();

Print("[?? PROP OPTIMIZER] Configured for ", m_rules.firmName);
PrintOptimizedSettings();

return true;
}

// ?? BREAKTHROUGH: Real-time Compliance Monitoring
bool CheckCompliance() {
m_isCompliant = true;
m_complianceIssues = "";

// Check daily loss limit
if(m_currentDailyLoss > m_rules.maxDailyLossPercent) {
m_isCompliant = false;
m_complianceIssues += "Daily loss limit exceeded; ";
}

// Check total loss limit
if(m_currentTotalLoss > m_rules.maxTotalLossPercent) {
m_isCompliant = false;
m_complianceIssues += "Total loss limit exceeded; ";
}

// Check trading days
if(m_tradingDaysCount < m_rules.minTradingDays) {
m_complianceIssues += StringFormat("Need %d more trading days; ", 
(int)(m_rules.minTradingDays - m_tradingDaysCount));
}

// Check max trading days
if(m_tradingDaysCount > m_rules.maxTradingDays) {
m_isCompliant = false;
m_complianceIssues += "Exceeded maximum trading days; ";
}

if(!m_isCompliant) {
Print("[?? COMPLIANCE ALERT] ", m_complianceIssues);
}

return m_isCompliant;
}

// ?? BREAKTHROUGH: Dynamic Risk Adjustment
double GetOptimizedRiskForTrade() {
if(!CheckCompliance()) {
return 0.0; // No trading if not compliant
}

double baseRisk = m_settings.riskPerTrade;

// Reduce risk if approaching limits
double remainingDailyRisk = m_rules.maxDailyLossPercent - m_currentDailyLoss;
double remainingTotalRisk = m_rules.maxTotalLossPercent - m_currentTotalLoss;

// Use the most restrictive limit
double maxAllowedRisk = MathMin(remainingDailyRisk, remainingTotalRisk);
double adjustedRisk = MathMin(baseRisk, maxAllowedRisk * 0.5); // Use 50% of remaining

// Additional safety for end of evaluation period
if(m_tradingDaysCount > m_rules.maxTradingDays * 0.8) {
adjustedRisk *= 0.7; // 30% reduction in final phase
}

return MathMax(0.1, adjustedRisk); // Minimum 0.1% risk
}

// ?? Update Performance Metrics
void UpdatePerformanceMetrics(double tradeResult) {
if(tradeResult < 0) {
double lossPercent = MathAbs(tradeResult) / AccountInfoDouble(ACCOUNT_BALANCE) * 100;
m_currentDailyLoss += lossPercent;
m_currentTotalLoss += lossPercent;
}

m_todayTradeCount++;
}

void OnNewDay() {
if(m_todayTradeCount > 0) {
m_tradingDaysCount++;
}
m_currentDailyLoss = 0.0;
m_todayTradeCount = 0;
}

// Getters
OptimizedSettings GetOptimizedSettings() const { return m_settings; }
PropFirmRules GetCurrentRules() const { return m_rules; }
bool IsCompliant() const { return m_isCompliant; }
string GetComplianceIssues() const { return m_complianceIssues; }

private:
void ConfigureFTMO() {
m_rules.firmName = "FTMO";
m_rules.maxDailyLossPercent = 5.0;
m_rules.maxTotalLossPercent = 10.0;
m_rules.minTradingDays = 4;
m_rules.maxTradingDays = 30;
m_rules.maxRiskPerTrade = 2.0;
m_rules.minHoldTimeSeconds = 0;
m_rules.allowWeekendHolding = true;
m_rules.allowNewsTrading = true;
m_rules.requireConsistency = false;
}

void ConfigureMyForexFunds() {
m_rules.firmName = "MyForexFunds";
m_rules.maxDailyLossPercent = 5.0;
m_rules.maxTotalLossPercent = 12.0;
m_rules.minTradingDays = 3;
m_rules.maxTradingDays = 30;
m_rules.maxRiskPerTrade = 1.5;
m_rules.minHoldTimeSeconds = 180; // 3 minutes minimum
m_rules.allowWeekendHolding = false;
m_rules.allowNewsTrading = false;
m_rules.requireConsistency = true;
}

void ConfigureTopTrader() {
m_rules.firmName = "TopTrader";
m_rules.maxDailyLossPercent = 4.0;
m_rules.maxTotalLossPercent = 8.0;
m_rules.minTradingDays = 5;
m_rules.maxTradingDays = 60;
m_rules.maxRiskPerTrade = 1.5;
m_rules.minHoldTimeSeconds = 300; // 5 minutes minimum
m_rules.allowWeekendHolding = false;
m_rules.allowNewsTrading = true;
m_rules.requireConsistency = true;
}

void ConfigureTrueForexFunds() {
m_rules.firmName = "TrueForexFunds";
m_rules.maxDailyLossPercent = 6.0;
m_rules.maxTotalLossPercent = 10.0;
m_rules.minTradingDays = 3;
m_rules.maxTradingDays = 45;
m_rules.maxRiskPerTrade = 2.5;
m_rules.minHoldTimeSeconds = 0;
m_rules.allowWeekendHolding = true;
m_rules.allowNewsTrading = true;
m_rules.requireConsistency = false;
}

void ConfigureNova() {
m_rules.firmName = "Nova";
m_rules.maxDailyLossPercent = 3.0;
m_rules.maxTotalLossPercent = 6.0;
m_rules.minTradingDays = 5;
m_rules.maxTradingDays = 30;
m_rules.maxRiskPerTrade = 1.0;
m_rules.minHoldTimeSeconds = 600; // 10 minutes minimum
m_rules.allowWeekendHolding = false;
m_rules.allowNewsTrading = false;
m_rules.requireConsistency = true;
}

void OptimizeSettingsForCompliance() {
// Conservative base settings
m_settings.riskPerTrade = MathMin(1.5, m_rules.maxRiskPerTrade * 0.8);
m_settings.maxDailyRisk = m_rules.maxDailyLossPercent * 0.6;
m_settings.maxDailyTrades = CalculateOptimalDailyTrades();

// Signal quality based on risk tolerance
if(m_rules.maxRiskPerTrade <= 1.0) {
m_settings.minSignalProbability = 0.8; // Very selective
m_settings.minRiskReward = 2.0;
} else if(m_rules.maxRiskPerTrade <= 1.5) {
m_settings.minSignalProbability = 0.75;
m_settings.minRiskReward = 1.8;
} else {
m_settings.minSignalProbability = 0.7;
m_settings.minRiskReward = 1.5;
}

// Time management
m_settings.minHoldTime = m_rules.minHoldTimeSeconds;
m_settings.enableNewsFilter = !m_rules.allowNewsTrading;

// Position management
m_settings.enableScaling = m_rules.allowScaling;
m_settings.maxPosition = m_rules.maxLotSize;

// Spread limits (tighter for stricter firms)
if(m_rules.maxRiskPerTrade <= 1.0) {
m_settings.spreadLimit = 1.5; // Very tight
} else {
m_settings.spreadLimit = 2.5; // Standard
}

m_settings.optimizationReason = StringFormat("Optimized for %s compliance", m_rules.firmName);
}

int CalculateOptimalDailyTrades() {
// Calculate safe daily trade count
double avgRiskPerTrade = m_settings.riskPerTrade;
double maxDailyRisk = m_rules.maxDailyLossPercent * 0.6; // Use 60% of limit

int maxTrades = (int)(maxDailyRisk / avgRiskPerTrade);
return MathMax(1, MathMin(maxTrades, 8)); // Cap at 8 trades per day
}

void PrintOptimizedSettings() {
Print("[?? OPTIMIZED SETTINGS]");
Print("  Risk per trade: ", DoubleToString(m_settings.riskPerTrade, 1), "%");
Print("  Max daily trades: ", m_settings.maxDailyTrades);
Print("  Min signal probability: ", DoubleToString(m_settings.minSignalProbability * 100, 0), "%");
Print("  Min R:R ratio: ", DoubleToString(m_settings.minRiskReward, 1));
Print("  Min hold time: ", m_settings.minHoldTime, " seconds");
Print("  News filter: ", m_settings.enableNewsFilter ? "ENABLED" : "DISABLED");
Print("  Spread limit: ", DoubleToString(m_settings.spreadLimit, 1), " pips");
}
};

#endif // PROP_FIRM_AUTO_OPTIMIZER_MQH 


