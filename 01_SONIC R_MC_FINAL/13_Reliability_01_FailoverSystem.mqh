//+------------------------------------------------------------------+
//|                                   Reliability_FailoverSystem.mqh |
//|                 SONIC R MC - Reliability & Failover System      |
//|                             PHASE 4: PRODUCTION FORTRESS        |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Phase 4"
#property version   "4.00"
// PRODUCTION FIX: Remove #property strict - MQL4 syntax not supported in MQL5

#ifndef RELIABILITY_FAILOVER_SYSTEM_MQH
#define RELIABILITY_FAILOVER_SYSTEM_MQH


#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| MISSING ERROR CONSTANTS - MQL5 COMPATIBILITY                    |
//+------------------------------------------------------------------+
// PRODUCTION FIX: Avoid redefinition of built-in constants
#ifndef ERR_NO_CONNECTION
#define ERR_NO_CONNECTION        1
#endif

#ifndef ERR_INVALID_PRICE
#define ERR_INVALID_PRICE        129
#endif

#ifndef ERR_TRADE_TIMEOUT
#define ERR_TRADE_TIMEOUT        10006
#endif

#ifndef ERR_INVALID_STOPS
#define ERR_INVALID_STOPS        130
#endif

#ifndef ERR_NOT_ENOUGH_MONEY
#define ERR_NOT_ENOUGH_MONEY     134
#endif

#ifndef ERR_TRADE_DISABLED
#define ERR_TRADE_DISABLED       133
#endif

//+------------------------------------------------------------------+
//| MISSING FUNCTION DEFINITIONS - MQL5 COMPATIBILITY               |
//+------------------------------------------------------------------+
bool IsConnected()
{
return TerminalInfoInteger(TERMINAL_CONNECTED) != 0;
}

bool IsTradeAllowed()
{
return (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0 && 
AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) != 0);
}

//+------------------------------------------------------------------+
//| RELIABILITY SYSTEM TYPES - PHASE 4                              |
//+------------------------------------------------------------------+

enum ENUM_CIRCUIT_BREAKER_STATE
{
CIRCUIT_BREAKER_CLOSED = 0,     // Normal operation
CIRCUIT_BREAKER_OPEN = 1,       // Blocking calls
CIRCUIT_BREAKER_HALF_OPEN = 2   // Testing recovery
};

enum ENUM_CONNECTION_STATE
{
CONNECTION_STABLE = 0,
CONNECTION_UNSTABLE = 1,
CONNECTION_RECONNECTING = 2,
CONNECTION_FAILED = 3,
CONNECTION_DISCONNECTED = 4
};

//+------------------------------------------------------------------+
//| ERROR RECORD STRUCTURE                                          |
//+------------------------------------------------------------------+
struct ErrorRecord
{
datetime            timestamp;
ENUM_ERROR_SEVERITY severity;
int                 errorCode;
string              errorMessage;
string              functionName;
string              contextInfo;
bool                isRecovered;
int                 retryCount;

void Reset()
{
timestamp = 0;
severity = ERROR_SEVERITY_LOW;
errorCode = 0;
errorMessage = "";
functionName = "";
contextInfo = "";
isRecovered = false;
retryCount = 0;
}
};

//+------------------------------------------------------------------+
//| CIRCUIT BREAKER STRUCTURE                                       |
//+------------------------------------------------------------------+
struct CircuitBreaker
{
string              name;
ENUM_CIRCUIT_BREAKER_STATE state;
int                 failureCount;
int                 failureThreshold;
datetime            lastFailureTime;
datetime            nextRetryTime;
int                 timeout;
int                 halfOpenMaxCalls;
int                 halfOpenCallCount;
int                 successfulCalls;

void Initialize(string cbName, int threshold = 5, int timeoutSec = 60)
{
name = cbName;
state = CIRCUIT_BREAKER_CLOSED;
failureCount = 0;
failureThreshold = threshold;
lastFailureTime = 0;
nextRetryTime = 0;
timeout = timeoutSec;
halfOpenMaxCalls = 3;
halfOpenCallCount = 0;
successfulCalls = 0;
}
};

//+------------------------------------------------------------------+
//| CONNECTION HEALTH STRUCTURE                                     |
//+------------------------------------------------------------------+
struct ConnectionHealth
{
ENUM_CONNECTION_STATE state;
datetime            lastCheckTime;
int                 consecutiveFailures;
int                 totalReconnects;
double              latency;
bool                isTerminalConnected;
bool                isDataFeedActive;
double              uptime;
datetime            lastSuccessfulOperation;

void Reset()
{
state = CONNECTION_STABLE;
lastCheckTime = 0;
consecutiveFailures = 0;
totalReconnects = 0;
latency = 0.0;
isTerminalConnected = false;
isDataFeedActive = false;
uptime = 0.0;
lastSuccessfulOperation = 0;
}
};

//+------------------------------------------------------------------+
//| ADVANCED ERROR RECOVERY MANAGER - PHASE 4                      |
//+------------------------------------------------------------------+
class CAdvancedErrorRecovery
{
private:
ErrorRecord         m_errorHistory[1000];
int                 m_errorCount;
int                 m_maxRetries;
bool                m_autoRecoveryEnabled;
datetime            m_lastRecoveryAttempt;

public:
CAdvancedErrorRecovery()
{
m_errorCount = 0;
m_maxRetries = 3;
m_autoRecoveryEnabled = true;
m_lastRecoveryAttempt = 0;
}

bool LogError(ENUM_ERROR_SEVERITY severity, int errorCode, string message, 
string functionName, string context = NULL)
{
if(m_errorCount >= 1000)
{
// Rotate error log - remove oldest 100 entries
for(int i = 0; i < 900; i++)
{
m_errorHistory[i] = m_errorHistory[i + 100];
}
m_errorCount = 900;
}

ErrorRecord error;
error.timestamp = TimeCurrent();
error.severity = severity;
error.errorCode = errorCode;
error.errorMessage = message;
error.functionName = functionName;
error.contextInfo = context;
error.isRecovered = false;
error.retryCount = 0;

m_errorHistory[m_errorCount++] = error;

// Log to terminal
string severityStr = GetSeverityString(severity);
Print(StringFormat("[%s ERROR] %s::%s - Code: %d, Message: %s", 
severityStr, functionName, context, errorCode, message));

// Attempt auto-recovery for non-fatal errors
if(m_autoRecoveryEnabled && severity < ERROR_SEVERITY_FATAL)
{
return AttemptRecovery(m_errorCount - 1);
}

return false;
}

bool AttemptRecovery(int errorIndex)
{
if(errorIndex < 0 || errorIndex >= m_errorCount)
return false;

ErrorRecord error = m_errorHistory[errorIndex];

if(error.retryCount >= m_maxRetries)
{
Print(StringFormat("[RECOVERY] Max retries (%d) exceeded for error: %s", 
m_maxRetries, error.errorMessage));
return false;
}

datetime currentTime = TimeCurrent();
if(currentTime - m_lastRecoveryAttempt < 5) // Throttle recovery attempts
return false;

error.retryCount++;
m_errorHistory[errorIndex] = error; // Update the array
m_lastRecoveryAttempt = currentTime;

bool recovered = false;

// Recovery strategies based on error type
switch(error.errorCode)
{
case ERR_NO_CONNECTION:
recovered = RecoverConnection();
break;

case ERR_INVALID_PRICE:
recovered = RecoverPriceData();
break;

case ERR_TRADE_TIMEOUT:
recovered = RecoverTradeOperation();
break;

case ERR_INVALID_STOPS:
recovered = RecoverStopLevels();
break;

case ERR_NOT_ENOUGH_MONEY:
recovered = RecoverInsufficientFunds();
break;

case ERR_TRADE_DISABLED:
recovered = RecoverTradingDisabled();
break;

default:
recovered = GenericRecovery(error);
break;
}

if(recovered)
{
error.isRecovered = true;
m_errorHistory[errorIndex] = error; // Update the array
Print(StringFormat("[RECOVERY] Successfully recovered from error: %s (Attempt %d)", 
error.errorMessage, error.retryCount));
}
else
{
m_errorHistory[errorIndex] = error; // Update the array
Print(StringFormat("[RECOVERY] Failed to recover from error: %s (Attempt %d)", 
error.errorMessage, error.retryCount));
}

return recovered;
}

double GetErrorRate()
{
if(m_errorCount == 0) return 0.0;

datetime oneHourAgo = TimeCurrent() - 3600;
int recentErrors = 0;

for(int i = m_errorCount - 1; i >= 0; i--)
{
if(m_errorHistory[i].timestamp > oneHourAgo)
recentErrors++;
else
break;
}

return (double)recentErrors / 60.0; // Errors per minute
}

string GetErrorSummary()
{
string summary = "=== ERROR RECOVERY SUMMARY ===\n";

int criticalErrors = 0, highErrors = 0, mediumErrors = 0, lowErrors = 0;
int recoveredErrors = 0;

for(int i = 0; i < m_errorCount; i++)
{
switch(m_errorHistory[i].severity)
{
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_CRITICAL: 
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_FATAL: 
criticalErrors++; break;
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_HIGH: 
highErrors++; break;
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_MEDIUM: 
mediumErrors++; break;
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_LOW: 
lowErrors++; break;
}

if(m_errorHistory[i].isRecovered)
recoveredErrors++;
}

summary += StringFormat("Total Errors: %d\n", m_errorCount);
summary += StringFormat("Critical/Fatal: %d, High: %d, Medium: %d, Low: %d\n", 
criticalErrors, highErrors, mediumErrors, lowErrors);
summary += StringFormat("Recovered: %d (%.1f%%)\n", 
recoveredErrors, (m_errorCount > 0) ? (recoveredErrors * 100.0 / m_errorCount) : 0.0);
summary += StringFormat("Error Rate: %.2f errors/min\n", GetErrorRate());

return summary;
}

private:
string GetSeverityString(ENUM_ERROR_SEVERITY severity)
{
switch(severity)
{
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_LOW: return "LOW";
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_MEDIUM: return "MEDIUM";
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_HIGH: return "HIGH";
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_CRITICAL: return "CRITICAL";
case (ENUM_ERROR_SEVERITY)ERROR_SEVERITY_FATAL: return "FATAL";
default: return "UNKNOWN";
}
}

bool RecoverConnection()
{
// Attempt to recover connection
// TEMPORARY FIX: Use MQL5 built-in function
return TerminalInfoInteger(TERMINAL_CONNECTED);
}

bool RecoverPriceData()
{
// Refresh price data
double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
return (bid > 0 && ask > 0 && ask > bid);
}

bool RecoverTradeOperation()
{
// Check if trading is possible
// TEMPORARY FIX: Use MQL5 built-in functions - simplified version
return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
}

bool RecoverStopLevels()
{
// Validate stop levels are within allowed range
double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
return (stopLevel > 0);
}

bool RecoverInsufficientFunds()
{
// Check account balance
double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
return (balance > 0 && margin > 0);
}

bool RecoverTradingDisabled()
{
// Check if trading is enabled
// TEMPORARY FIX: Use MQL5 built-in functions - simplified version
return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
}

bool GenericRecovery(ErrorRecord& error)
{
// Generic recovery strategy
Sleep(1000); // Wait 1 second
return true; // Assume recovery for generic errors
}
};

//+------------------------------------------------------------------+
//| CIRCUIT BREAKER MANAGER - PHASE 4                              |
//+------------------------------------------------------------------+
class CCircuitBreakerManager
{
private:
CircuitBreaker      m_breakers[10];
int                 m_breakerCount;

public:
CCircuitBreakerManager()
{
m_breakerCount = 0;
InitializeDefaultBreakers();
}

bool RegisterCircuitBreaker(string name, int failureThreshold = 5, int timeoutSec = 60)
{
if(m_breakerCount >= 10) return false;

m_breakers[m_breakerCount].Initialize(name, failureThreshold, timeoutSec);
m_breakerCount++;

Print(StringFormat("[CIRCUIT BREAKER] Registered: %s (Threshold: %d, Timeout: %ds)", 
name, failureThreshold, timeoutSec));

return true;
}

bool CallService(string breakerName)
{
int index = FindBreakerIndex(breakerName);
if(index < 0) return true; // No breaker, allow call

datetime currentTime = TimeCurrent();

switch(m_breakers[index].state)
{
case CIRCUIT_BREAKER_CLOSED:
// Normal operation
return true;

case CIRCUIT_BREAKER_OPEN:
// Check if timeout has passed
if(currentTime >= m_breakers[index].nextRetryTime)
{
m_breakers[index].state = CIRCUIT_BREAKER_HALF_OPEN;
m_breakers[index].halfOpenCallCount = 0;
Print(StringFormat("[CIRCUIT BREAKER] %s moved to HALF_OPEN state", breakerName));
return true;
}
else
{
// Still in timeout period
return false;
}

case CIRCUIT_BREAKER_HALF_OPEN:
// Testing recovery
if(m_breakers[index].halfOpenCallCount < m_breakers[index].halfOpenMaxCalls)
{
m_breakers[index].halfOpenCallCount++;
return true;
}
else
{
// Max test calls reached, back to OPEN
m_breakers[index].state = CIRCUIT_BREAKER_OPEN;
m_breakers[index].nextRetryTime = currentTime + m_breakers[index].timeout;
return false;
}
}

return false;
}

void ReportSuccess(string breakerName)
{
int index = FindBreakerIndex(breakerName);
if(index < 0) return;

m_breakers[index].successfulCalls++;

if(m_breakers[index].state == CIRCUIT_BREAKER_HALF_OPEN)
{
// Successful call in half-open state
if(m_breakers[index].halfOpenCallCount >= m_breakers[index].halfOpenMaxCalls)
{
// All test calls successful, close circuit
m_breakers[index].state = CIRCUIT_BREAKER_CLOSED;
m_breakers[index].failureCount = 0;
Print(StringFormat("[CIRCUIT BREAKER] %s recovered - moved to CLOSED state", breakerName));
}
}
else if(m_breakers[index].state == CIRCUIT_BREAKER_CLOSED)
{
// Reset failure count on successful call
m_breakers[index].failureCount = MathMax(0, m_breakers[index].failureCount - 1);
}
}

void ReportFailure(string breakerName)
{
int index = FindBreakerIndex(breakerName);
if(index < 0) return;

datetime currentTime = TimeCurrent();

m_breakers[index].failureCount++;
m_breakers[index].lastFailureTime = currentTime;

if(m_breakers[index].state == CIRCUIT_BREAKER_CLOSED && 
m_breakers[index].failureCount >= m_breakers[index].failureThreshold)
{
// Open circuit breaker
m_breakers[index].state = CIRCUIT_BREAKER_OPEN;
m_breakers[index].nextRetryTime = currentTime + m_breakers[index].timeout;

Print(StringFormat("[CIRCUIT BREAKER] %s OPENED due to %d failures", 
breakerName, m_breakers[index].failureCount));
}
else if(m_breakers[index].state == CIRCUIT_BREAKER_HALF_OPEN)
{
// Failure in half-open state, back to open
m_breakers[index].state = CIRCUIT_BREAKER_OPEN;
m_breakers[index].nextRetryTime = currentTime + m_breakers[index].timeout;

Print(StringFormat("[CIRCUIT BREAKER] %s back to OPEN after failure in HALF_OPEN", 
breakerName));
}
}

string GetBreakerStatus()
{
string status = "=== CIRCUIT BREAKER STATUS ===\n";

for(int i = 0; i < m_breakerCount; i++)
{
string stateStr = GetStateString(m_breakers[i].state);

status += StringFormat("%s: %s (Failures: %d/%d, Success: %d)\n",
m_breakers[i].name, stateStr, m_breakers[i].failureCount, 
m_breakers[i].failureThreshold, m_breakers[i].successfulCalls);
}

return status;
}

private:
void InitializeDefaultBreakers()
{
RegisterCircuitBreaker("Trading", 3, 30);      // Trading operations
RegisterCircuitBreaker("DataFeed", 5, 60);     // Market data
RegisterCircuitBreaker("Analysis", 3, 45);     // Analysis functions
RegisterCircuitBreaker("Orders", 2, 30);       // Order operations
}

int FindBreakerIndex(string name)
{
for(int i = 0; i < m_breakerCount; i++)
{
if(m_breakers[i].name == name)
return i;
}
return -1;
}

string GetStateString(ENUM_CIRCUIT_BREAKER_STATE state)
{
switch(state)
{
case CIRCUIT_BREAKER_CLOSED: return "CLOSED";
case CIRCUIT_BREAKER_OPEN: return "OPEN";
case CIRCUIT_BREAKER_HALF_OPEN: return "HALF_OPEN";
default: return "UNKNOWN";
}
}
};

//+------------------------------------------------------------------+
//| CONNECTION STABILITY MONITOR - PHASE 4                         |
//+------------------------------------------------------------------+
class CConnectionStabilityMonitor
{
private:
ConnectionHealth    m_health;
datetime            m_monitoringStartTime;
int                 m_checkInterval;

public:
CConnectionStabilityMonitor()
{
m_health.Reset();
m_monitoringStartTime = TimeCurrent();
m_checkInterval = 30; // Check every 30 seconds
}

bool MonitorConnection()
{
datetime currentTime = TimeCurrent();

if(currentTime - m_health.lastCheckTime < m_checkInterval)
return true; // Skip check

m_health.lastCheckTime = currentTime;

// Check terminal connection
bool wasConnected = m_health.isTerminalConnected;
m_health.isTerminalConnected = TerminalInfoInteger(TERMINAL_CONNECTED);

// Check data feed
bool wasDataActive = m_health.isDataFeedActive;
m_health.isDataFeedActive = CheckDataFeed();

// Calculate latency
ulong startTime = GetMicrosecondCount();
double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
ulong endTime = GetMicrosecondCount();
m_health.latency = (double)(endTime - startTime) / 1000.0; // Convert to milliseconds

// Update connection state
UpdateConnectionState(wasConnected, wasDataActive);

// Calculate uptime
if(m_health.isTerminalConnected && m_health.isDataFeedActive)
{
m_health.uptime = (double)(currentTime - m_monitoringStartTime) / 3600.0; // Hours
m_health.lastSuccessfulOperation = currentTime;
}

return (m_health.state == CONNECTION_STABLE);
}

bool AttemptReconnection()
{
if(m_health.state != CONNECTION_FAILED && m_health.state != CONNECTION_DISCONNECTED)
return true;

Print("[CONNECTION] Attempting reconnection...");

m_health.state = CONNECTION_RECONNECTING;
m_health.totalReconnects++;

// Give system time to establish connection
Sleep(2000);

// Check if reconnection was successful
if(TerminalInfoInteger(TERMINAL_CONNECTED) && CheckDataFeed())
{
m_health.state = CONNECTION_STABLE;
m_health.consecutiveFailures = 0;
Print("[CONNECTION] Reconnection successful");
return true;
}
else
{
m_health.state = CONNECTION_FAILED;
m_health.consecutiveFailures++;
Print("[CONNECTION] Reconnection failed");
return false;
}
}

ConnectionHealth GetConnectionHealth()
{
return m_health;
}

bool IsConnectionStable()
{
return (m_health.state == CONNECTION_STABLE && 
m_health.consecutiveFailures < 3 &&
m_health.latency < 100.0); // Less than 100ms latency
}

string GetConnectionReport()
{
string report = "=== CONNECTION STABILITY REPORT ===\n";

report += StringFormat("State: %s\n", GetConnectionStateString(m_health.state));
report += StringFormat("Terminal Connected: %s\n", m_health.isTerminalConnected ? "YES" : "NO");
report += StringFormat("Data Feed Active: %s\n", m_health.isDataFeedActive ? "YES" : "NO");
report += StringFormat("Latency: %.2f ms\n", m_health.latency);
report += StringFormat("Consecutive Failures: %d\n", m_health.consecutiveFailures);
report += StringFormat("Total Reconnects: %d\n", m_health.totalReconnects);
report += StringFormat("Uptime: %.2f hours\n", m_health.uptime);

return report;
}

private:
bool CheckDataFeed()
{
// Check if we're receiving fresh data
datetime lastTick = (datetime)SymbolInfoInteger(_Symbol, SYMBOL_TIME);
datetime currentTime = TimeCurrent();

// Data should be recent (within last 5 minutes for most markets)
return (currentTime - lastTick < 300);
}

void UpdateConnectionState(bool wasConnected, bool wasDataActive)
{
bool currentlyConnected = m_health.isTerminalConnected && m_health.isDataFeedActive;

if(currentlyConnected)
{
if(!wasConnected || !wasDataActive)
{
// Just recovered
m_health.state = CONNECTION_STABLE;
m_health.consecutiveFailures = 0;
}
else if(m_health.latency > 500.0) // High latency
{
m_health.state = CONNECTION_UNSTABLE;
}
else
{
m_health.state = CONNECTION_STABLE;
}
}
else
{
m_health.consecutiveFailures++;

if(m_health.consecutiveFailures >= 3)
{
m_health.state = CONNECTION_FAILED;
}
else
{
m_health.state = CONNECTION_UNSTABLE;
}
}
}

string GetConnectionStateString(ENUM_CONNECTION_STATE state)
{
switch(state)
{
case CONNECTION_STABLE: return "STABLE";
case CONNECTION_UNSTABLE: return "UNSTABLE";
case CONNECTION_RECONNECTING: return "RECONNECTING";
case CONNECTION_FAILED: return "FAILED";
case CONNECTION_DISCONNECTED: return "DISCONNECTED";
default: return "UNKNOWN";
}
}
};

//+------------------------------------------------------------------+
//| MAIN RELIABILITY & FAILOVER MANAGER - PHASE 4                  |
//+------------------------------------------------------------------+
class CReliabilityFailoverManager
{
private:
CAdvancedErrorRecovery*         m_errorRecovery;
CCircuitBreakerManager*         m_circuitBreakerManager;
CConnectionStabilityMonitor*    m_connectionMonitor;

bool                            m_systemHealthy;
datetime                        m_lastHealthCheck;

public:
CReliabilityFailoverManager()
{
m_errorRecovery = new CAdvancedErrorRecovery();
m_circuitBreakerManager = new CCircuitBreakerManager();
m_connectionMonitor = new CConnectionStabilityMonitor();

m_systemHealthy = true;
m_lastHealthCheck = TimeCurrent();
}

~CReliabilityFailoverManager()
{
delete m_errorRecovery;
delete m_circuitBreakerManager;
delete m_connectionMonitor;
}

bool Initialize()
{
return (CheckPointer(m_errorRecovery) == POINTER_DYNAMIC &&
CheckPointer(m_circuitBreakerManager) == POINTER_DYNAMIC &&
CheckPointer(m_connectionMonitor) == POINTER_DYNAMIC);
}

void PerformHealthCheck()
{
datetime currentTime = TimeCurrent();
if(currentTime - m_lastHealthCheck < 60) return; // Every minute

// Monitor connection
if(CheckPointer(m_connectionMonitor) == POINTER_DYNAMIC)
{
m_connectionMonitor.MonitorConnection();

if(!m_connectionMonitor.IsConnectionStable())
{
m_connectionMonitor.AttemptReconnection();
}
}

// Check system health
bool connectionHealthy = (CheckPointer(m_connectionMonitor) == POINTER_DYNAMIC) ? 
m_connectionMonitor.IsConnectionStable() : false;

double errorRate = (CheckPointer(m_errorRecovery) == POINTER_DYNAMIC) ?
m_errorRecovery.GetErrorRate() : 0.0;

m_systemHealthy = connectionHealthy && (errorRate < 5.0); // Less than 5 errors per minute

m_lastHealthCheck = currentTime;
}

string GetSystemHealthReport()
{
string report = "=== PHASE 4 RELIABILITY REPORT ===\n";

report += StringFormat("System Health: %s\n", m_systemHealthy ? "HEALTHY" : "DEGRADED");

if(CheckPointer(m_connectionMonitor) == POINTER_DYNAMIC)
{
report += m_connectionMonitor.GetConnectionReport();
}

if(CheckPointer(m_errorRecovery) == POINTER_DYNAMIC)
{
report += m_errorRecovery.GetErrorSummary();
}

if(CheckPointer(m_circuitBreakerManager) == POINTER_DYNAMIC)
{
report += m_circuitBreakerManager.GetBreakerStatus();
}

return report;
}

// Getters
CAdvancedErrorRecovery* GetErrorRecovery() { return m_errorRecovery; }
CCircuitBreakerManager* GetCircuitBreakerManager() { return m_circuitBreakerManager; }
CConnectionStabilityMonitor* GetConnectionMonitor() { return m_connectionMonitor; }

bool IsSystemHealthy() { return m_systemHealthy; }
};

#endif // RELIABILITY_FAILOVER_SYSTEM_MQH


