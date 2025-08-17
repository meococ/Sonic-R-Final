//+------------------------------------------------------------------+
//|                                    Compliance_PropFirm.mqh      |
//|                     SONIC R MC - Prop Firm Compliance Module    |
//|                        Production-Grade Standards                |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Production Grade"
#property version   "1.00"
// PRODUCTION FIX: Remove #property strict - MQL4 syntax not supported in MQL5

#ifndef COMPLIANCE_PROPFIRM_MQH
#define COMPLIANCE_PROPFIRM_MQH


#include "01_Core_03_Logger.mqh"
#include "01_Core_07_CommonStructures.mqh"
// Removed duplicate ENUM_PROP_FIRM - using from SonicR_Enums.mqh

// TEMPORARY FIX: Add SafeLog function stubs as static
void SafeLogInfo(string message, string category = NULL) { Print("[", category, "] ", message); }
void SafeLogWarning(string message, string category = NULL) { Print("[WARNING][", category, "] ", message); }
void SafeLogError(string message, string category = NULL) { Print("[ERROR][", category, "] ", message); }
//+------------------------------------------------------------------+
//| PROP FIRM COMPLIANCE STANDARDS                                  |
//| Designed for FTMO, MyForexFunds, FundedNext, etc.              |
//+------------------------------------------------------------------+

struct PropFirmLimits
{
double maxDailyDrawdown;        // 5% for most firms
double maxTotalDrawdown;        // 10% for most firms  
double profitTarget;            // 8-10% for most firms
int maxDailyTrades;             // Some firms limit this
int minHoldTimeSeconds;         // Anti-HFT rule
double maxSlippagePips;         // Slippage monitoring
bool requireWeekendGap;         // Some firms require weekend gaps
bool allowScalping;             // Some firms prohibit scalping
bool allowNews;                 // News trading restrictions
bool allowWeekends;             // Weekend trading

void SetFTMO()
{
maxDailyDrawdown = 5.0;
maxTotalDrawdown = 10.0;
profitTarget = 10.0;
maxDailyTrades = 0; // No limit
minHoldTimeSeconds = 0; // No minimum
maxSlippagePips = 5.0;
requireWeekendGap = false;
allowScalping = true;
allowNews = true;
allowWeekends = false;
}

void SetMyForexFunds()
{
maxDailyDrawdown = 5.0;
maxTotalDrawdown = 12.0;
profitTarget = 8.0;
maxDailyTrades = 0; // No limit
minHoldTimeSeconds = 60; // 1 minute minimum
maxSlippagePips = 3.0;
requireWeekendGap = true;
allowScalping = false; // Prohibited
allowNews = false;     // Prohibited
allowWeekends = false;
}

void SetDefault()
{
maxDailyDrawdown = 4.0;  // Conservative
maxTotalDrawdown = 8.0;  // Conservative
profitTarget = 10.0;
maxDailyTrades = 10;     // Conservative limit
minHoldTimeSeconds = 30; // 30 seconds minimum
maxSlippagePips = 2.0;   // Tight slippage control
requireWeekendGap = true;
allowScalping = true;
allowNews = false;       // Conservative
allowWeekends = false;
}
};

//+------------------------------------------------------------------+
//| Prop Firm Compliance Manager                                    |
//+------------------------------------------------------------------+
class CPropFirmCompliance
{
private:
PropFirmLimits        m_limits;

// Daily tracking
double                m_dailyStartEquity;
double                m_dailyPeakEquity;
double                m_dailyMaxDD;
int                   m_dailyTradeCount;
datetime              m_lastDailyReset;

// Total tracking
double                m_totalStartEquity;
double                m_totalPeakEquity;
double                m_totalMaxDD;
double                m_totalProfit;
int                   m_totalTradeCount;

// Slippage tracking
double                m_totalSlippage;
int                   m_slippageTradeCount;
double                m_averageSlippage;
int                   m_excessiveSlippageCount;

// Compliance flags
bool                  m_tradingAllowed;
bool                  m_dailyLimitReached;
bool                  m_totalLimitReached;
bool                  m_challengePassed;

// Violation tracking
int                   m_violationCount;
string                m_lastViolation;
datetime              m_lastViolationTime;

public:
CPropFirmCompliance()
{
Reset();
m_limits.SetDefault(); // Conservative defaults
}

void Initialize(ENUM_PROP_FIRM firm)
{
switch(firm)
{
case PROP_FIRM_FTMO:
m_limits.SetFTMO();
break;
case PROP_FIRM_MYFXFUNDS:
m_limits.SetMyForexFunds();
break;
default:
m_limits.SetDefault();
break;
}

m_totalStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_totalPeakEquity = m_totalStartEquity;
ResetDaily();

// TEMPORARY FIX: Replace SafeLogInfo with Print
Print(StringFormat("[COMPLIANCE] Prop Firm Compliance initialized - Max DD: %.1f%% | Profit Target: %.1f%%", 
m_limits.maxDailyDrawdown, m_limits.profitTarget));
}

void ResetDaily()
{
m_dailyStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_dailyPeakEquity = m_dailyStartEquity;
m_dailyMaxDD = 0.0;
m_dailyTradeCount = 0;
m_lastDailyReset = TimeCurrent();
m_dailyLimitReached = false;

// TEMPORARY FIX: Replace SafeLogInfo with Print
Print("[COMPLIANCE] Daily compliance reset completed");
}

bool CheckCompliance()
{
// Check if daily reset needed
if(NeedsDailyReset())
{
ResetDaily();
}

// Update current metrics
UpdateMetrics();

// Check daily drawdown
if(!CheckDailyDrawdown())
{
LogViolation("Daily drawdown limit exceeded");
return false;
}

// Check total drawdown  
if(!CheckTotalDrawdown())
{
LogViolation("Total drawdown limit exceeded");
return false;
}

// Check daily trade limit
if(!CheckDailyTradeLimit())
{
LogViolation("Daily trade limit exceeded");
return false;
}

// Check slippage compliance
CheckSlippageCompliance();

return m_tradingAllowed;
}

bool ValidateTradeEntry()
{
if(!m_tradingAllowed) return false;

// Check trading hours
if(!IsValidTradingTime()) return false;

// Check news filter
if(!m_limits.allowNews && IsNewsTime()) return false;

// Check weekend gaps
if(m_limits.requireWeekendGap && !HasWeekendGap()) return false;

// Increment trade count
m_dailyTradeCount++;
m_totalTradeCount++;

return true;
}

void RecordSlippage(double requestedPrice, double executedPrice, ENUM_ORDER_TYPE orderType)
{
double slippagePoints = 0.0;

if(orderType == ORDER_TYPE_BUY)
{
slippagePoints = (executedPrice - requestedPrice) / _Point;
}
else if(orderType == ORDER_TYPE_SELL)
{
slippagePoints = (requestedPrice - executedPrice) / _Point;
}

double slippagePips = NormalizeDouble(slippagePoints / 10.0, 1);

// Update statistics
m_totalSlippage += MathAbs(slippagePips);
m_slippageTradeCount++;
m_averageSlippage = m_totalSlippage / m_slippageTradeCount;

// Check excessive slippage
if(MathAbs(slippagePips) > m_limits.maxSlippagePips)
{
m_excessiveSlippageCount++;
SafeLogWarning(StringFormat("Excessive slippage: %.1f pips (limit: %.1f)", 
MathAbs(slippagePips), m_limits.maxSlippagePips), "SLIPPAGE");
}

// Log for audit trail
// TEMPORARY FIX: Replace SafeLogInfo with Print
Print(StringFormat("[SLIPPAGE] Slippage recorded: %.1f pips | Average: %.1f pips", 
MathAbs(slippagePips), m_averageSlippage));
}

bool IsMinHoldTimeMet(ulong positionTicket)
{
if(m_limits.minHoldTimeSeconds <= 0) return true;

if(PositionSelectByTicket(positionTicket))
{
datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
double holdTime = (double)(TimeCurrent() - openTime);

if(holdTime < m_limits.minHoldTimeSeconds)
{
SafeLogWarning(StringFormat("Position %I64u held for %.0f seconds, minimum required: %d", 
positionTicket, holdTime, m_limits.minHoldTimeSeconds), "HOLD_TIME");
return false;
}
}

return true;
}

string GetComplianceReport()
{
string report = "\n=== PROP FIRM COMPLIANCE REPORT ===\n";
report += StringFormat("Daily DD: %.2f%% / %.1f%% (%.1f%% remaining)\n", 
GetCurrentDailyDD(), m_limits.maxDailyDrawdown, 
m_limits.maxDailyDrawdown - GetCurrentDailyDD());

report += StringFormat("Total DD: %.2f%% / %.1f%% (%.1f%% remaining)\n", 
GetCurrentTotalDD(), m_limits.maxTotalDrawdown,
m_limits.maxTotalDrawdown - GetCurrentTotalDD());

report += StringFormat("Daily Trades: %d", m_dailyTradeCount);
if(m_limits.maxDailyTrades > 0)
report += StringFormat(" / %d", m_limits.maxDailyTrades);
report += "\n";

report += StringFormat("Average Slippage: %.1f pips (limit: %.1f pips)\n", 
m_averageSlippage, m_limits.maxSlippagePips);

report += StringFormat("Excessive Slippage Events: %d\n", m_excessiveSlippageCount);

report += StringFormat("Trading Allowed: %s\n", m_tradingAllowed ? "YES" : "NO");

if(m_violationCount > 0)
{
report += StringFormat("Violations: %d | Last: %s at %s\n", 
m_violationCount, m_lastViolation, 
TimeToString(m_lastViolationTime));
}

report += "====================================\n";
return report;
}

// Getters
double GetCurrentDailyDD() 
{ 
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
if(m_dailyStartEquity > 0)
return NormalizeDouble((m_dailyStartEquity - currentEquity) / m_dailyStartEquity * 100.0, 2);
return 0.0;
}

double GetCurrentTotalDD()
{
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
if(m_totalPeakEquity > 0)
return NormalizeDouble((m_totalPeakEquity - currentEquity) / m_totalPeakEquity * 100.0, 2);
return 0.0;
}

bool IsTradingAllowed() { return m_tradingAllowed; }
int GetDailyTradeCount() { return m_dailyTradeCount; }
double GetAverageSlippage() { return m_averageSlippage; }
int GetViolationCount() { return m_violationCount; }

private:
void Reset()
{
m_dailyStartEquity = 0.0;
m_dailyPeakEquity = 0.0;
m_dailyMaxDD = 0.0;
m_dailyTradeCount = 0;
m_lastDailyReset = 0;

m_totalStartEquity = 0.0;
m_totalPeakEquity = 0.0;
m_totalMaxDD = 0.0;
m_totalProfit = 0.0;
m_totalTradeCount = 0;

m_totalSlippage = 0.0;
m_slippageTradeCount = 0;
m_averageSlippage = 0.0;
m_excessiveSlippageCount = 0;

m_tradingAllowed = true;
m_dailyLimitReached = false;
m_totalLimitReached = false;
m_challengePassed = false;

m_violationCount = 0;
m_lastViolation = "";
m_lastViolationTime = 0;
}

bool NeedsDailyReset()
{
MqlDateTime current, lastReset;
TimeToStruct(TimeCurrent(), current);
TimeToStruct(m_lastDailyReset, lastReset);

return (current.day_of_year != lastReset.day_of_year || 
current.year != lastReset.year);
}

void UpdateMetrics()
{
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);

// Update peaks
if(currentEquity > m_dailyPeakEquity)
m_dailyPeakEquity = currentEquity;

if(currentEquity > m_totalPeakEquity)
m_totalPeakEquity = currentEquity;

// Update max drawdowns
double dailyDD = GetCurrentDailyDD();
if(dailyDD > m_dailyMaxDD)
m_dailyMaxDD = dailyDD;

double totalDD = GetCurrentTotalDD();
if(totalDD > m_totalMaxDD)
m_totalMaxDD = totalDD;
}

bool CheckDailyDrawdown()
{
double currentDD = GetCurrentDailyDD();

if(currentDD > m_limits.maxDailyDrawdown)
{
m_tradingAllowed = false;
m_dailyLimitReached = true;
return false;
}

// Warning at 80% of limit
if(currentDD > m_limits.maxDailyDrawdown * 0.8)
{
SafeLogWarning(StringFormat("Daily DD approaching limit: %.2f%% / %.1f%%", 
currentDD, m_limits.maxDailyDrawdown), "COMPLIANCE");
}

return true;
}

bool CheckTotalDrawdown()
{
double currentDD = GetCurrentTotalDD();

if(currentDD > m_limits.maxTotalDrawdown)
{
m_tradingAllowed = false;
m_totalLimitReached = true;
return false;
}

// Warning at 80% of limit
if(currentDD > m_limits.maxTotalDrawdown * 0.8)
{
SafeLogWarning(StringFormat("Total DD approaching limit: %.2f%% / %.1f%%", 
currentDD, m_limits.maxTotalDrawdown), "COMPLIANCE");
}

return true;
}

bool CheckDailyTradeLimit()
{
if(m_limits.maxDailyTrades <= 0) return true; // No limit

if(m_dailyTradeCount >= m_limits.maxDailyTrades)
{
m_tradingAllowed = false;
return false;
}

// Warning at 80% of limit
if(m_dailyTradeCount >= (int)(m_limits.maxDailyTrades * 0.8))
{
SafeLogWarning(StringFormat("Daily trades approaching limit: %d / %d", 
m_dailyTradeCount, m_limits.maxDailyTrades), "COMPLIANCE");
}

return true;
}

void CheckSlippageCompliance()
{
// Check if excessive slippage rate is too high
if(m_slippageTradeCount > 10)
{
double excessiveRate = (double)m_excessiveSlippageCount / m_slippageTradeCount * 100.0;

if(excessiveRate > 20.0) // More than 20% of trades have excessive slippage
{
SafeLogWarning(StringFormat("High excessive slippage rate: %.1f%% of trades", 
excessiveRate), "SLIPPAGE");
}
}
}

bool IsValidTradingTime()
{
if(m_limits.allowWeekends) return true;

MqlDateTime dt;
TimeToStruct(TimeCurrent(), dt);

// Check weekend
if(dt.day_of_week == 0 || dt.day_of_week == 6) // Sunday or Saturday
{
return false;
}

return true;
}

bool IsNewsTime()
{
// Simplified news check - would integrate with economic calendar
MqlDateTime dt;
TimeToStruct(TimeCurrent(), dt);

// Check high-impact news hours (example: 8:30, 10:00, 14:00, 15:30 GMT)
if((dt.hour == 8 && dt.min >= 25 && dt.min <= 35) ||
(dt.hour == 10 && dt.min >= 0 && dt.min <= 5) ||
(dt.hour == 14 && dt.min >= 0 && dt.min <= 5) ||
(dt.hour == 15 && dt.min >= 25 && dt.min <= 35))
{
return true;
}

return false;
}

bool HasWeekendGap()
{
if(!m_limits.requireWeekendGap) return true;

// Check if there was a significant weekend gap
double fridayClose = iClose(_Symbol, PERIOD_D1, 1);
double mondayOpen = iOpen(_Symbol, PERIOD_D1, 0);

if(fridayClose > 0 && mondayOpen > 0)
{
double gapPips = MathAbs(mondayOpen - fridayClose) / (_Point * 10);
return gapPips >= 10.0; // Minimum 10 pip gap required
}

return true; // If can't determine, allow
}

void LogViolation(string violation)
{
m_violationCount++;
m_lastViolation = violation;
m_lastViolationTime = TimeCurrent();

SafeLogError(StringFormat("COMPLIANCE VIOLATION #%d: %s", m_violationCount, violation), "VIOLATION");
}
};

#endif // COMPLIANCE_PROPFIRM_MQH


