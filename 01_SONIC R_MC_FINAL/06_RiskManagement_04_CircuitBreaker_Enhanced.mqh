//+------------------------------------------------------------------+
//|                         Risk_CircuitBreaker_Enhanced.mqh       |
//|              SONIC R MC - ENHANCED CIRCUIT BREAKER              |
//|                    ?? ERROR 4014 RESILIENT SYSTEM              |
//+------------------------------------------------------------------+
#ifndef RISK_CIRCUITBREAKER_ENHANCED_MQH
#define RISK_CIRCUITBREAKER_ENHANCED_MQH

#include "06_RiskManagement_03_CircuitBreaker.mqh"
#include "01_Core_21_ErrorConstants_Clean.mqh"

//+------------------------------------------------------------------+
//| ?? ERROR CLASSIFICATION SYSTEM                                  |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - ENUM_ERROR_SEVERITY is now defined in CoreEnums.mqh
// Removed duplicate enum definition to avoid conflicts

//+------------------------------------------------------------------+
//| ?? ENHANCED CIRCUIT BREAKER WITH ERROR RESILIENCE               |
//+------------------------------------------------------------------+
class CEnhancedCircuitBreaker : public CCircuitBreaker
{
private:
int m_minorErrorCount;
int m_moderateErrorCount;
datetime m_lastMinorErrorTime;
double m_baseSystemHealth;
bool m_fallbackModeActive;

public:
CEnhancedCircuitBreaker() : CCircuitBreaker()
{
m_minorErrorCount = 0;
m_moderateErrorCount = 0;
m_lastMinorErrorTime = 0;
m_baseSystemHealth = 100.0;
m_fallbackModeActive = false;
}

//+------------------------------------------------------------------+
//| ?? CLASSIFY ERROR SEVERITY                                      |
//+------------------------------------------------------------------+
ENUM_ERROR_SEVERITY ClassifyError(int errorCode)
{
switch(errorCode)
{
// Minor errors - Don't stop trading
case ERR_UNKNOWN_COMMAND:           // 4014 - Dragon Band issue
case ERR_NO_HISTORY_DATA:           // 4054 - Data loading
case ERR_CUSTOM_INDICATOR_ERROR:    // 4036 - Indicator issue
case ERR_INDICATOR_CANNOT_INIT:     // 4052 - Init issue
return ERROR_SEVERITY_MINOR;

// Moderate errors - Reduce risk but continue
case ERR_TRADE_TIMEOUT:
case ERR_REQUOTE:
case ERR_BROKER_BUSY:
return ERROR_SEVERITY_MODERATE;

// Critical errors - Stop new trades
case 134: // ERR_NOT_ENOUGH_MONEY
case ERR_INVALID_STOPS:
case ERR_TRADE_DISABLED:
return ERROR_SEVERITY_CRITICAL;

// Fatal errors - Full stop
case ERR_ACCOUNT_DISABLED:
case ERR_NO_CONNECTION:
return ERROR_SEVERITY_CRITICAL;

default:
return ERROR_SEVERITY_MODERATE;
}
}

//+------------------------------------------------------------------+
//| ?? HANDLE ERROR WITH SMART RESPONSE                             |
//+------------------------------------------------------------------+
void HandleSmartError(int errorCode, string context)
{
ENUM_ERROR_SEVERITY severity = ClassifyError(errorCode);

switch(severity)
{
case ERROR_SEVERITY_MINOR:
HandleMinorError(errorCode, context);
break;

case ERROR_SEVERITY_MODERATE:
HandleModerateError(errorCode, context);
break;

case ERROR_SEVERITY_CRITICAL:
HandleCriticalError(errorCode, context);
break;
}
}

//+------------------------------------------------------------------+
//| ?? HANDLE MINOR ERRORS (Like Dragon Band 4014)                 |
//+------------------------------------------------------------------+
void HandleMinorError(int errorCode, string context)
{
m_minorErrorCount++;
m_lastMinorErrorTime = TimeCurrent();

// Reduce health slightly but don't stop trading
m_baseSystemHealth = MathMax(70.0, m_baseSystemHealth - 2.0); // Minimum 70%

Print("?? [MINOR ERROR] ", errorCode, " in ", context, " - Health: ", m_baseSystemHealth, "%");

// Only activate warning level for many consecutive minor errors
if(m_minorErrorCount >= 20) {
Print("?? [WARNING] Many minor errors detected - Activating warning level");
ActivateCircuitBreaker(CB_TRIGGER_VOLATILITY, CB_LEVEL_WARNING, 
"Multiple minor errors: " + context, errorCode);
m_fallbackModeActive = true;
} else {
Print("? [CONTINUE] Minor error handled - Trading continues with fallback");
}
}

//+------------------------------------------------------------------+
//| ?? HANDLE MODERATE ERRORS                                       |
//+------------------------------------------------------------------+
void HandleModerateError(int errorCode, string context)
{
m_moderateErrorCount++;
m_baseSystemHealth = MathMax(50.0, m_baseSystemHealth - 5.0);

Print("?? [MODERATE ERROR] ", errorCode, " in ", context, " - Health: ", m_baseSystemHealth, "%");

if(m_moderateErrorCount >= 5) {
ActivateCircuitBreaker(CB_TRIGGER_VOLATILITY, CB_LEVEL_CAUTION, 
"Multiple moderate errors: " + context, errorCode);
}
}

//+------------------------------------------------------------------+
//| ?? HANDLE CRITICAL ERRORS                                       |
//+------------------------------------------------------------------+
void HandleCriticalError(int errorCode, string context)
{
m_baseSystemHealth = MathMax(25.0, m_baseSystemHealth - 10.0);

Print("?? [CRITICAL ERROR] ", errorCode, " in ", context, " - Health: ", m_baseSystemHealth, "%");

ActivateCircuitBreaker(CB_TRIGGER_VOLATILITY, CB_LEVEL_EMERGENCY, 
"Critical error: " + context, errorCode);
}

//+------------------------------------------------------------------+
//| ? HANDLE FATAL ERRORS                                           |
//+------------------------------------------------------------------+
void HandleFatalError(int errorCode, string context)
{
m_baseSystemHealth = 0.0;

Print("? [FATAL ERROR] ", errorCode, " in ", context, " - SYSTEM SHUTDOWN");

ActivateCircuitBreaker(CB_TRIGGER_MANUAL, CB_LEVEL_LOCKDOWN, 
"Fatal error: " + context, errorCode);
}

//+------------------------------------------------------------------+
//| ?? ENHANCED TRADE PERMISSION CHECK                              |
//+------------------------------------------------------------------+
bool ShouldAllowTradeEnhanced(string symbol, ENUM_ORDER_TYPE orderType, int lastError = 0)
{
// If we have a recent error, classify it
if(lastError != 0) {
ENUM_ERROR_SEVERITY severity = ClassifyError(lastError);

// Allow trading even with minor errors
if(severity == ERROR_SEVERITY_MINOR) {
Print("? [ENHANCED CB] Allowing trade despite minor error ", lastError);
return true;
}
}

// Use original circuit breaker logic for other cases
return !ShouldBlockTrade(symbol, orderType);
}

//+------------------------------------------------------------------+
//| ?? GET ENHANCED SYSTEM HEALTH                                   |
//+------------------------------------------------------------------+
double GetEnhancedSystemHealth()
{
double health = m_baseSystemHealth;

// Recovery bonus for fallback mode
if(m_fallbackModeActive) {
health = MathMin(100.0, health + 15.0); // Bonus for successful fallback
}

// Time-based recovery
if(m_lastMinorErrorTime > 0) {
int minutesSinceError = (int)((TimeCurrent() - m_lastMinorErrorTime) / 60);
if(minutesSinceError > 10) {
health = MathMin(100.0, health + (minutesSinceError * 0.5)); // Gradual recovery
}
}

return health;
}

//+------------------------------------------------------------------+
//| ?? RESET MINOR ERROR COUNTERS                                   |
//+------------------------------------------------------------------+
void ResetMinorErrors()
{
m_minorErrorCount = 0;
m_baseSystemHealth = MathMax(m_baseSystemHealth, 80.0);
Print("?? [RECOVERY] Minor error counters reset - Health boosted to ", m_baseSystemHealth, "%");
}

//+------------------------------------------------------------------+
//| ?? STATUS REPORT WITH ERROR DETAILS                             |
//+------------------------------------------------------------------+
string GetEnhancedStatusReport()
{
string report = "\n=== ENHANCED CIRCUIT BREAKER STATUS ===\n";
report += StringFormat("System Health: %.1f%%\n", GetEnhancedSystemHealth());
report += StringFormat("Minor Errors: %d\n", m_minorErrorCount);
report += StringFormat("Moderate Errors: %d\n", m_moderateErrorCount);
report += StringFormat("Fallback Mode: %s\n", m_fallbackModeActive ? "ACTIVE" : "INACTIVE");
report += StringFormat("Level: %s\n", GetLevelName(m_status.currentLevel));
report += "==========================================\n";
return report;
}

private:
string GetLevelName(ENUM_CIRCUIT_BREAKER_LEVEL level)
{
switch(level) {
case CB_LEVEL_NONE: return "NORMAL";
case CB_LEVEL_WARNING: return "WARNING";
case CB_LEVEL_CAUTION: return "CAUTION";
case CB_LEVEL_EMERGENCY: return "EMERGENCY";
case CB_LEVEL_LOCKDOWN: return "LOCKDOWN";
default: return "UNKNOWN";
}
}
};

#endif // RISK_CIRCUITBREAKER_ENHANCED_MQH



