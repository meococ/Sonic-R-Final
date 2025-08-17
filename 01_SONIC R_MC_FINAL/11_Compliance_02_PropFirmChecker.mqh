//+------------------------------------------------------------------+
//|                                  Compliance_PropFirmChecker.mqh |
//|                  ?? PROP FIRM COMPLIANCE CHECKER                  |
//|                  ? FTMO, FUNDED TRADER, APEX & MORE            |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Compliance Enhancement"
#property version   "4.00"

#ifndef COMPLIANCE_PROPFIRMCHECKER_MQH
#define COMPLIANCE_PROPFIRMCHECKER_MQH

#include "01_Core_22_SonicEnums.mqh"
// #include "01_Core_16_EnumHelpers.mqh" // Already included in MasterIncludes
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_08_ContextManager.mqh"
#include "06_RiskManagement_01_IntelligentManager.mqh"

//+------------------------------------------------------------------+
//| ?? PROP FIRM TYPES & RULES - Using from SonicR_Enums.mqh       |
//+------------------------------------------------------------------+
// ENUM_PROP_FIRM is already defined in SonicR_Enums.mqh

enum ENUM_CHALLENGE_PHASE
{
PHASE_CHALLENGE,        // Initial challenge
PHASE_VERIFICATION,     // Verification phase
PHASE_FUNDED,          // Funded account
PHASE_SCALING          // Scaling plan
};

enum ENUM_COMPLIANCE_STATUS
{
COMPLIANCE_UNKNOWN,     // Not checked yet
COMPLIANCE_PASS,        // All rules passed
COMPLIANCE_WARNING,     // Minor violations
COMPLIANCE_VIOLATION,   // Major violation
COMPLIANCE_CRITICAL     // Account in danger
};

//+------------------------------------------------------------------+
//| ?? PROP FIRM COMPLIANCE STRUCTURES                               |
//+------------------------------------------------------------------+
struct SPropFirmRule
{
string              ruleName;
double              maxDailyLoss;        // % or absolute
double              maxTotalLoss;        // % or absolute
double              profitTarget;        // % or absolute
double              minTradingDays;      // Number of days
double              maxPositionSize;     // % of account
double              maxRiskPerTrade;     // % of account
double              maxCorrelation;      // Max correlation between trades
bool                weekendTradingAllowed;
bool                newsEventsAllowed;
bool                hedgingAllowed;
bool                scalingAllowed;
string              allowedInstruments;  // Comma-separated list

void Reset()
{
ruleName = "";
maxDailyLoss = 5.0;       // Default 5%
maxTotalLoss = 10.0;      // Default 10%
profitTarget = 10.0;      // Default 10%
minTradingDays = 5;       // Default 5 days
maxPositionSize = 10.0;   // Default 10%
maxRiskPerTrade = 2.0;    // Default 2%
maxCorrelation = 0.8;     // Default 80%
weekendTradingAllowed = false;
newsEventsAllowed = true;
hedgingAllowed = false;
scalingAllowed = true;
allowedInstruments = "EURUSD,GBPUSD,USDJPY,USDCHF,AUDUSD,USDCAD,NZDUSD";
}
};

struct SComplianceViolation
{
ENUM_COMPLIANCE_STATUS  severity;
string                  ruleName;
string                  description;
double                  currentValue;
double                  limitValue;
datetime                violationTime;
string                  recommendation;
bool                    canBeCorrected;

void Reset()
{
severity = COMPLIANCE_UNKNOWN;
ruleName = "";
description = "";
currentValue = 0.0;
limitValue = 0.0;
violationTime = 0;
recommendation = "";
canBeCorrected = false;
}
};

struct SComplianceStatus
{
ENUM_PROP_FIRM          firmType;
ENUM_CHALLENGE_PHASE    currentPhase;
ENUM_COMPLIANCE_STATUS  overallStatus;
double                  complianceScore;     // 0-100
int                     violationCount;
double                  dailyLoss;
double                  totalLoss;
double                  currentProfit;
int                     tradingDays;
double                  currentRisk;
bool                    isCompliant;
string                  statusMessage;
datetime                lastCheck;
SComplianceViolation    violations[];

void Reset()
{
firmType = PROP_FIRM_FTMO;
currentPhase = PHASE_CHALLENGE;
overallStatus = COMPLIANCE_UNKNOWN;
complianceScore = 0.0;
violationCount = 0;
dailyLoss = 0.0;
totalLoss = 0.0;
currentProfit = 0.0;
tradingDays = 0;
currentRisk = 0.0;
isCompliant = false;
statusMessage = "";
lastCheck = 0;
ArrayFree(violations);
}
};

//+------------------------------------------------------------------+
//| ?? PROP FIRM COMPLIANCE CHECKER                                  |
//+------------------------------------------------------------------+
class CPropFirmComplianceChecker
{
private:
// Configuration
ENUM_PROP_FIRM              m_firmType;
ENUM_CHALLENGE_PHASE        m_currentPhase;
SPropFirmRule               m_currentRules;

// Status tracking
SComplianceStatus           m_status;
double                      m_accountBalance;
double                      m_accountEquity;
double                      m_startingBalance;
datetime                    m_startDate;
datetime                    m_lastUpdate;

// Risk management integration
CIntelligentRiskManager*    m_riskManager;

// Monitoring
bool                        m_monitoringActive;
int                         m_checkIntervalMinutes;
datetime                    m_lastComplianceCheck;

public:
//+------------------------------------------------------------------+
//| ?? INITIALIZATION                                                |
//+------------------------------------------------------------------+
CPropFirmComplianceChecker()
{
m_firmType = PROP_FIRM_FTMO;
m_currentPhase = PHASE_CHALLENGE;
m_currentRules.Reset();
m_status.Reset();

m_accountBalance = 0.0;
m_accountEquity = 0.0;
m_startingBalance = 0.0;
m_startDate = 0;
m_lastUpdate = 0;

m_riskManager = NULL;

m_monitoringActive = false;
m_checkIntervalMinutes = 15;  // Check every 15 minutes
m_lastComplianceCheck = 0;
}

~CPropFirmComplianceChecker()
{
m_monitoringActive = false;
}

bool Initialize(ENUM_PROP_FIRM firmType, ENUM_CHALLENGE_PHASE phase,
double startingBalance, CIntelligentRiskManager* riskManager)
{
m_firmType = firmType;
m_currentPhase = phase;
m_startingBalance = startingBalance;
m_riskManager = riskManager;

m_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
m_accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_startDate = TimeCurrent();
m_lastUpdate = TimeCurrent();

// Set rules for specific firm
SetRulesForFirm(firmType);

// Initialize status
m_status.Reset();
m_status.firmType = firmType;
m_status.currentPhase = phase;
m_status.overallStatus = COMPLIANCE_PASS;
m_status.isCompliant = true;

m_monitoringActive = true;

Print("? [COMPLIANCE] Initialized for ", FirmTypeToString(firmType), 
" | Phase: ", PhaseToString(phase), " | Balance: ", startingBalance);

return true;
}

//+------------------------------------------------------------------+
//| ?? COMPLIANCE MONITORING                                         |
//+------------------------------------------------------------------+
bool CheckCompliance()
{
if(!m_monitoringActive) return true;

datetime currentTime = TimeCurrent();
if(currentTime < m_lastComplianceCheck + m_checkIntervalMinutes * 60)
return m_status.isCompliant;

m_lastComplianceCheck = currentTime;

// Update account information
UpdateAccountInfo();

// Reset status for fresh check
ArrayResize(m_status.violations, 0);
m_status.violationCount = 0;
m_status.overallStatus = COMPLIANCE_PASS;
m_status.complianceScore = 100.0;

bool isCompliant = true;

// Check all compliance rules
isCompliant &= CheckDailyLossLimit();
isCompliant &= CheckMaxDrawdownLimit();
isCompliant &= CheckProfitTarget();
isCompliant &= CheckTradingDaysRequirement();
isCompliant &= CheckPositionSizeLimits();
isCompliant &= CheckRiskPerTradeLimits();
isCompliant &= CheckTradingInstruments();
isCompliant &= CheckTradingTimeRestrictions();

// Update overall status
m_status.isCompliant = isCompliant;
m_status.lastCheck = currentTime;

if(m_status.violationCount == 0)
{
m_status.overallStatus = COMPLIANCE_PASS;
m_status.statusMessage = "All compliance rules satisfied";
}
else if(m_status.violationCount <= 2)
{
m_status.overallStatus = COMPLIANCE_WARNING;
m_status.statusMessage = "Minor compliance issues detected";
}
else
{
m_status.overallStatus = COMPLIANCE_VIOLATION;
m_status.statusMessage = "Multiple compliance violations detected";
}

// Log compliance status
LogComplianceStatus();

return isCompliant;
}

//+------------------------------------------------------------------+
//| ?? SPECIFIC COMPLIANCE CHECKS                                    |
//+------------------------------------------------------------------+
bool CheckDailyLossLimit()
{
double dailyStartBalance = GetDailyStartBalance();
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
double dailyLoss = dailyStartBalance - currentEquity;
double dailyLossPercent = (dailyLoss / dailyStartBalance) * 100.0;

m_status.dailyLoss = dailyLossPercent;

if(dailyLossPercent > m_currentRules.maxDailyLoss)
{
AddViolation(COMPLIANCE_CRITICAL, "Daily Loss Limit",
StringFormat("Daily loss %.2f%% exceeds limit of %.2f%%",
dailyLossPercent, m_currentRules.maxDailyLoss),
dailyLossPercent, m_currentRules.maxDailyLoss,
"Reduce position sizes or stop trading for today");
return false;
}

if(dailyLossPercent > m_currentRules.maxDailyLoss * 0.8)
{
AddViolation(COMPLIANCE_WARNING, "Daily Loss Warning",
StringFormat("Daily loss %.2f%% approaching limit of %.2f%%",
dailyLossPercent, m_currentRules.maxDailyLoss),
dailyLossPercent, m_currentRules.maxDailyLoss,
"Consider reducing risk exposure");
}

return true;
}

bool CheckMaxDrawdownLimit()
{
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
double totalLoss = m_startingBalance - currentEquity;
double totalLossPercent = (totalLoss / m_startingBalance) * 100.0;

m_status.totalLoss = totalLossPercent;

if(totalLossPercent > m_currentRules.maxTotalLoss)
{
AddViolation(COMPLIANCE_CRITICAL, "Max Drawdown Limit",
StringFormat("Total drawdown %.2f%% exceeds limit of %.2f%%",
totalLossPercent, m_currentRules.maxTotalLoss),
totalLossPercent, m_currentRules.maxTotalLoss,
"Account violation - immediate risk reduction required");
return false;
}

if(totalLossPercent > m_currentRules.maxTotalLoss * 0.8)
{
AddViolation(COMPLIANCE_WARNING, "Max Drawdown Warning",
StringFormat("Total drawdown %.2f%% approaching limit of %.2f%%",
totalLossPercent, m_currentRules.maxTotalLoss),
totalLossPercent, m_currentRules.maxTotalLoss,
"Urgent risk management required");
}

return true;
}

bool CheckProfitTarget()
{
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
double profit = currentEquity - m_startingBalance;
double profitPercent = (profit / m_startingBalance) * 100.0;

m_status.currentProfit = profitPercent;

if(profitPercent >= m_currentRules.profitTarget)
{
if(m_currentPhase == PHASE_CHALLENGE)
{
AddViolation(COMPLIANCE_PASS, "Challenge Target Achieved",
StringFormat("Profit target %.2f%% achieved with %.2f%%",
m_currentRules.profitTarget, profitPercent),
profitPercent, m_currentRules.profitTarget,
"Ready for verification phase");
}
else if(m_currentPhase == PHASE_VERIFICATION)
{
AddViolation(COMPLIANCE_PASS, "Verification Target Achieved",
StringFormat("Verification target %.2f%% achieved with %.2f%%",
m_currentRules.profitTarget, profitPercent),
profitPercent, m_currentRules.profitTarget,
"Ready for funded account");
}
}

return true;
}

bool CheckTradingDaysRequirement()
{
int tradingDays = CalculateTradingDays();
m_status.tradingDays = tradingDays;

if(tradingDays < m_currentRules.minTradingDays)
{
if(m_status.currentProfit >= m_currentRules.profitTarget)
{
AddViolation(COMPLIANCE_WARNING, "Minimum Trading Days",
StringFormat("Only %d trading days completed, minimum %d required",
tradingDays, (int)m_currentRules.minTradingDays),
tradingDays, m_currentRules.minTradingDays,
"Continue trading to meet minimum days requirement");
}
}

return true;
}

bool CheckPositionSizeLimits()
{
double maxPositionValue = 0.0;
double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);

for(int i = 0; i < PositionsTotal(); i++)
{
if(PositionGetTicket(i) > 0)
{
double volume = PositionGetDouble(POSITION_VOLUME);
double contractSize = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_TRADE_CONTRACT_SIZE);
double positionValue = volume * contractSize;

if(positionValue > maxPositionValue)
maxPositionValue = positionValue;
}
}

double positionSizePercent = (maxPositionValue / accountEquity) * 100.0;

if(positionSizePercent > m_currentRules.maxPositionSize)
{
AddViolation(COMPLIANCE_VIOLATION, "Position Size Limit",
StringFormat("Position size %.2f%% exceeds limit of %.2f%%",
positionSizePercent, m_currentRules.maxPositionSize),
positionSizePercent, m_currentRules.maxPositionSize,
"Reduce position sizes immediately");
return false;
}

return true;
}

bool CheckRiskPerTradeLimits()
{
if(m_riskManager == NULL) return true;

// Calculate current risk - fallback if method not available
double currentRisk = 0.0;

// Try to get risk from risk manager or calculate from positions
double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
if(accountEquity > 0)
{
double totalRisk = 0.0;
for(int i = 0; i < PositionsTotal(); i++)
{
if(PositionGetTicket(i) > 0)
{
double volume = PositionGetDouble(POSITION_VOLUME);
double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
double sl = PositionGetDouble(POSITION_SL);

if(sl > 0)
{
double riskAmount = MathAbs(openPrice - sl) * volume;
totalRisk += riskAmount;
}
}
}
currentRisk = (totalRisk / accountEquity) * 100.0;
}

m_status.currentRisk = currentRisk;

if(currentRisk > m_currentRules.maxRiskPerTrade)
{
AddViolation(COMPLIANCE_VIOLATION, "Risk Per Trade Limit",
StringFormat("Risk per trade %.2f%% exceeds limit of %.2f%%",
currentRisk, m_currentRules.maxRiskPerTrade),
currentRisk, m_currentRules.maxRiskPerTrade,
"Reduce risk per trade immediately");
return false;
}

return true;
}

bool CheckTradingInstruments()
{
// This is a simplified check - in practice would be more complex
return true;
}

bool CheckTradingTimeRestrictions()
{
// Check weekend trading if not allowed
if(!m_currentRules.weekendTradingAllowed)
{
MqlDateTime dt;
TimeToStruct(TimeCurrent(), dt);

if(dt.day_of_week == 0 || dt.day_of_week == 6) // Sunday or Saturday
{
if(PositionsTotal() > 0)
{
AddViolation(COMPLIANCE_WARNING, "Weekend Trading",
"Weekend trading detected but not allowed by firm rules",
1, 0,
"Close positions before weekend");
}
}
}

return true;
}

//+------------------------------------------------------------------+
//| ?? PROP FIRM SPECIFIC RULES                                      |
//+------------------------------------------------------------------+
void SetRulesForFirm(ENUM_PROP_FIRM firmType)
{
m_currentRules.Reset();

switch(firmType)
{
case PROP_FIRM_FTMO:
m_currentRules.ruleName = "FTMO Standard Rules";
m_currentRules.maxDailyLoss = 5.0;      // 5% daily loss
m_currentRules.maxTotalLoss = 10.0;     // 10% max drawdown
m_currentRules.profitTarget = 10.0;     // 10% profit target
m_currentRules.minTradingDays = 5;      // 5 minimum trading days
m_currentRules.maxPositionSize = 10.0;  // 10% max position size
m_currentRules.maxRiskPerTrade = 2.0;   // 2% max risk per trade
m_currentRules.weekendTradingAllowed = false;
m_currentRules.newsEventsAllowed = true;
m_currentRules.hedgingAllowed = false;
break;

case PROP_FIRM_MYFXFUNDS:
m_currentRules.ruleName = "MyFXFunds Rules";
m_currentRules.maxDailyLoss = 4.0;      // 4% daily loss
m_currentRules.maxTotalLoss = 8.0;      // 8% max drawdown
m_currentRules.profitTarget = 8.0;      // 8% profit target
m_currentRules.minTradingDays = 5;      // 5 minimum trading days
m_currentRules.maxPositionSize = 8.0;   // 8% max position size
m_currentRules.maxRiskPerTrade = 1.5;   // 1.5% max risk per trade
m_currentRules.weekendTradingAllowed = false;
m_currentRules.newsEventsAllowed = true;
m_currentRules.hedgingAllowed = true;
break;

case PROP_FIRM_TOPTRADER:
m_currentRules.ruleName = "TopTrader Rules";
m_currentRules.maxDailyLoss = 3.0;      // 3% daily loss
m_currentRules.maxTotalLoss = 6.0;      // 6% max drawdown
m_currentRules.profitTarget = 10.0;     // 10% profit target
m_currentRules.minTradingDays = 4;      // 4 minimum trading days
m_currentRules.maxPositionSize = 5.0;   // 5% max position size
m_currentRules.maxRiskPerTrade = 1.0;   // 1% max risk per trade
m_currentRules.weekendTradingAllowed = false;
m_currentRules.newsEventsAllowed = false;
m_currentRules.hedgingAllowed = false;
break;

default:
m_currentRules.ruleName = "Default Conservative Rules";
m_currentRules.maxDailyLoss = 3.0;
m_currentRules.maxTotalLoss = 6.0;
m_currentRules.profitTarget = 8.0;
m_currentRules.minTradingDays = 5;
m_currentRules.maxPositionSize = 5.0;
m_currentRules.maxRiskPerTrade = 1.0;
m_currentRules.weekendTradingAllowed = false;
m_currentRules.newsEventsAllowed = true;
m_currentRules.hedgingAllowed = false;
break;
}

Print("?? [COMPLIANCE] Rules set for ", m_currentRules.ruleName);
Print(StringFormat("   Daily Loss: %.1f%% | Max DD: %.1f%% | Target: %.1f%% | Min Days: %d",
m_currentRules.maxDailyLoss, m_currentRules.maxTotalLoss, 
m_currentRules.profitTarget, (int)m_currentRules.minTradingDays));
}

//+------------------------------------------------------------------+
//| ?? HELPER FUNCTIONS                                              |
//+------------------------------------------------------------------+
void UpdateAccountInfo()
{
m_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
m_accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_lastUpdate = TimeCurrent();
}

double GetDailyStartBalance()
{
// Simplified - in practice would track daily starting balances
return m_accountBalance;
}

int CalculateTradingDays()
{
// Simplified calculation - count days from start
datetime currentTime = TimeCurrent();
int totalDays = (int)((currentTime - m_startDate) / (24 * 3600));

// Approximate trading days (exclude weekends)
return (int)(totalDays * 5.0 / 7.0);
}

void AddViolation(ENUM_COMPLIANCE_STATUS severity, string ruleName, 
string description, double currentValue, double limitValue,
string recommendation)
{
SComplianceViolation violation;
violation.severity = severity;
violation.ruleName = ruleName;
violation.description = description;
violation.currentValue = currentValue;
violation.limitValue = limitValue;
violation.violationTime = TimeCurrent();
violation.recommendation = recommendation;
violation.canBeCorrected = (severity != COMPLIANCE_CRITICAL);

ArrayResize(m_status.violations, ArraySize(m_status.violations) + 1);
m_status.violations[ArraySize(m_status.violations) - 1] = violation;

if(severity >= COMPLIANCE_WARNING)
m_status.violationCount++;

// Adjust compliance score
switch(severity)
{
case COMPLIANCE_WARNING:
m_status.complianceScore -= 10.0;
break;
case COMPLIANCE_VIOLATION:
m_status.complianceScore -= 25.0;
break;
case COMPLIANCE_CRITICAL:
m_status.complianceScore -= 50.0;
break;
}

m_status.complianceScore = MathMax(0.0, m_status.complianceScore);
}

void LogComplianceStatus()
{
Print(StringFormat("?? [COMPLIANCE] Status: %s | Score: %.1f%% | Violations: %d",
ComplianceStatusToString(m_status.overallStatus), 
m_status.complianceScore, 
m_status.violationCount));

if(m_status.violationCount > 0)
{
Print("?? [COMPLIANCE] Violations detected:");
for(int i = 0; i < ArraySize(m_status.violations); i++)
{
Print("   ", m_status.violations[i].ruleName, ": ", 
m_status.violations[i].description);
}
}
}

//+------------------------------------------------------------------+
//| ?? GETTERS                                                       |
//+------------------------------------------------------------------+
SComplianceStatus GetComplianceStatus() const { return m_status; }
SPropFirmRule GetCurrentRules() const { return m_currentRules; }
bool IsCompliant() const { return m_status.isCompliant; }
double GetComplianceScore() const { return m_status.complianceScore; }
ENUM_COMPLIANCE_STATUS GetOverallStatus() const { return m_status.overallStatus; }

string GenerateComplianceReport()
{
string report = "\n=== ?? PROP FIRM COMPLIANCE REPORT ===\n";
report += StringFormat("Firm: %s | Phase: %s\n", 
FirmTypeToString(m_status.firmType),
PhaseToString(m_status.currentPhase));
report += StringFormat("Overall Status: %s (%.1f%%)\n", 
ComplianceStatusToString(m_status.overallStatus),
m_status.complianceScore);
report += StringFormat("Account Balance: %.2f | Equity: %.2f\n",
m_accountBalance, m_accountEquity);
report += StringFormat("Daily Loss: %.2f%% (Limit: %.2f%%)\n",
m_status.dailyLoss, m_currentRules.maxDailyLoss);
report += StringFormat("Total Loss: %.2f%% (Limit: %.2f%%)\n",
m_status.totalLoss, m_currentRules.maxTotalLoss);
report += StringFormat("Profit: %.2f%% (Target: %.2f%%)\n",
m_status.currentProfit, m_currentRules.profitTarget);
report += StringFormat("Trading Days: %d (Min: %d)\n",
m_status.tradingDays, (int)m_currentRules.minTradingDays);

if(ArraySize(m_status.violations) > 0)
{
report += "\n--- VIOLATIONS ---\n";
for(int i = 0; i < ArraySize(m_status.violations); i++)
{
report += StringFormat("%s: %s\n", 
m_status.violations[i].ruleName,
m_status.violations[i].description);
report += StringFormat("  Recommendation: %s\n",
m_status.violations[i].recommendation);
}
}

report += "\n=====================================\n";
return report;
}
};

//+------------------------------------------------------------------+
//| ?? GLOBAL COMPLIANCE CHECKER FUNCTIONS                           |
//+------------------------------------------------------------------+
bool InitializeComplianceChecker(ENUM_PROP_FIRM firmType = PROP_FIRM_FTMO,
ENUM_CHALLENGE_PHASE phase = PHASE_CHALLENGE,
double startingBalance = 0.0)
{
if(startingBalance <= 0.0)
startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);

// Initialize compliance checker
CPropFirmComplianceChecker* checker = new CPropFirmComplianceChecker();
bool result = checker.Initialize(firmType, phase, startingBalance, NULL);

if(result)
{
Print("? [COMPLIANCE] Global compliance checker initialized successfully");
}
else
{
Print("? [COMPLIANCE] Failed to initialize compliance checker");
delete checker;
}

return result;
}

#endif // COMPLIANCE_PROPFIRMCHECKER_MQH


