//+------------------------------------------------------------------+
//|                                Risk_CircuitBreaker.mqh         |
//|                    SONIC R MC - PHASE 4: CIRCUIT BREAKER        |
//|                              🎯 BOSS'S EMERGENCY PROTECTION     |
//+------------------------------------------------------------------+

#ifndef RISK_CIRCUITBREAKER_MQH
#define RISK_CIRCUITBREAKER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "06_RiskManagement_02_BlackSwanDetector.mqh"

//+------------------------------------------------------------------+
//| 🎯 CIRCUIT BREAKER TRIGGER CONDITIONS                           |
//+------------------------------------------------------------------+
enum ENUM_CIRCUIT_BREAKER_TRIGGER {
CB_TRIGGER_NONE,
CB_TRIGGER_DRAWDOWN,           // Maximum drawdown exceeded
CB_TRIGGER_LOSS_STREAK,        // Consecutive losses
CB_TRIGGER_VOLATILITY,         // Extreme volatility
CB_TRIGGER_BLACK_SWAN,         // Black swan event
CB_TRIGGER_CORRELATION,        // Correlation breakdown
CB_TRIGGER_LIQUIDITY,          // Liquidity crisis
CB_TRIGGER_MANUAL,             // Manual activation
CB_TRIGGER_TIME_BASED,         // Time-based restrictions
CB_TRIGGER_NEWS_EVENT          // High-impact news
};

enum ENUM_CIRCUIT_BREAKER_LEVEL {
CB_LEVEL_NONE,
CB_LEVEL_WARNING,              // Warning level - reduce risk
CB_LEVEL_CAUTION,              // Caution level - limit new trades
CB_LEVEL_EMERGENCY,            // Emergency level - stop all trades
CB_LEVEL_LOCKDOWN              // Complete lockdown - close positions
};

//+------------------------------------------------------------------+
//| 🎯 CIRCUIT BREAKER CONFIGURATION                                |
//+------------------------------------------------------------------+
struct CircuitBreakerConfig {
// Drawdown triggers
double                  maxDailyDrawdown;       // Maximum daily drawdown %
double                  maxWeeklyDrawdown;      // Maximum weekly drawdown %
double                  maxMonthlyDrawdown;     // Maximum monthly drawdown %

// Loss streak triggers
int                     maxConsecutiveLosses;   // Maximum consecutive losses
double                  maxLossStreakAmount;    // Maximum loss streak amount

// Volatility triggers
double                  maxVolatilityMultiple;  // Maximum volatility multiple
double                  minLiquidityRatio;      // Minimum liquidity ratio

// Time-based restrictions
bool                    enableNewsFilter;       // Enable news-based restrictions
bool                    enableSessionFilter;    // Enable session-based restrictions

// Recovery settings
int                     cooldownMinutes;        // Cooldown period in minutes
bool                    autoRecovery;           // Enable automatic recovery
double                  recoveryThreshold;      // Recovery threshold

// Emergency settings
bool                    enableEmergencyClose;   // Enable emergency position closing
double                  emergencyCloseThreshold; // Emergency close threshold

void SetDefaults() {
maxDailyDrawdown = 0.05;        // 5% daily drawdown
maxWeeklyDrawdown = 0.10;       // 10% weekly drawdown
maxMonthlyDrawdown = 0.15;      // 15% monthly drawdown
maxConsecutiveLosses = 5;       // 5 consecutive losses
maxLossStreakAmount = 1000.0;   // $1000 loss streak
maxVolatilityMultiple = 3.0;    // 3x normal volatility
minLiquidityRatio = 0.3;        // 30% minimum liquidity
enableNewsFilter = true;
enableSessionFilter = true;
cooldownMinutes = 30;           // 30 minutes cooldown
autoRecovery = true;
recoveryThreshold = 0.5;        // 50% recovery threshold
enableEmergencyClose = true;
emergencyCloseThreshold = 0.08; // 8% emergency close
}
};

struct CircuitBreakerStatus {
ENUM_CIRCUIT_BREAKER_LEVEL  currentLevel;
ENUM_CIRCUIT_BREAKER_TRIGGER triggerType;
datetime                    activationTime;
datetime                    cooldownEnd;
string                      triggerReason;
double                      triggerValue;
int                         tradesBlocked;
int                         positionsClosed;
bool                        isRecovering;
double                      recoveryProgress;

void Reset() {
currentLevel = CB_LEVEL_NONE;
triggerType = CB_TRIGGER_NONE;
activationTime = 0;
cooldownEnd = 0;
triggerReason = "";
triggerValue = 0.0;
tradesBlocked = 0;
positionsClosed = 0;
isRecovering = false;
recoveryProgress = 0.0;
}
};

//+------------------------------------------------------------------+
//| 🎯 CIRCUIT BREAKER CLASS                                        |
//+------------------------------------------------------------------+
class CCircuitBreaker {
protected:
// Configuration
CircuitBreakerConfig    m_config;
CircuitBreakerStatus    m_status;

// Monitoring data
double                  m_dailyDrawdown;
double                  m_weeklyDrawdown;
double                  m_monthlyDrawdown;
int                     m_consecutiveLosses;
double                  m_lossStreakAmount;
double                  m_currentVolatility;
double                  m_currentLiquidity;

// Historical tracking
datetime                m_lastTradeTime;
double                  m_lastEquity;
double                  m_dayStartEquity;
double                  m_weekStartEquity;
double                  m_monthStartEquity;

// Integration
CBlackSwanDetector*     m_blackSwanDetector;

// Internal methods
void                    UpdateDrawdownMetrics() {
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);

// Calculate drawdowns
if(m_dayStartEquity > 0) {
m_dailyDrawdown = (m_dayStartEquity - currentEquity) / m_dayStartEquity;
}

if(m_weekStartEquity > 0) {
m_weeklyDrawdown = (m_weekStartEquity - currentEquity) / m_weekStartEquity;
}

if(m_monthStartEquity > 0) {
m_monthlyDrawdown = (m_monthStartEquity - currentEquity) / m_monthStartEquity;
}

m_lastEquity = currentEquity;
}
void                    UpdateLossStreakMetrics() {
// This method is called from MonitorAndCheck()
// Loss streak is updated in OnTradeResult()
}
void                    UpdateVolatilityMetrics() {
// Get current volatility from market (simplified)
// In real implementation, would calculate from ATR or other indicators
m_currentVolatility = 0.015; // 1.5% example volatility
m_currentLiquidity = 0.8;    // 80% example liquidity
}
bool                    CheckDrawdownTriggers() {
// Check daily drawdown
if(m_dailyDrawdown > m_config.maxDailyDrawdown) {
ENUM_CIRCUIT_BREAKER_LEVEL level = CB_LEVEL_EMERGENCY;
if(m_dailyDrawdown > m_config.emergencyCloseThreshold) {
level = CB_LEVEL_LOCKDOWN;
}

ActivateCircuitBreaker(CB_TRIGGER_DRAWDOWN, level,
StringFormat("Daily drawdown exceeded: %.2f%%", m_dailyDrawdown * 100),
m_dailyDrawdown);
return true;
}

// Check weekly drawdown
if(m_weeklyDrawdown > m_config.maxWeeklyDrawdown) {
ActivateCircuitBreaker(CB_TRIGGER_DRAWDOWN, CB_LEVEL_CAUTION,
StringFormat("Weekly drawdown exceeded: %.2f%%", m_weeklyDrawdown * 100),
m_weeklyDrawdown);
return true;
}

// Check monthly drawdown
if(m_monthlyDrawdown > m_config.maxMonthlyDrawdown) {
ActivateCircuitBreaker(CB_TRIGGER_DRAWDOWN, CB_LEVEL_WARNING,
StringFormat("Monthly drawdown exceeded: %.2f%%", m_monthlyDrawdown * 100),
m_monthlyDrawdown);
return true;
}

return false;
}
bool                    CheckLossStreakTriggers() {
// Check consecutive losses
if(m_consecutiveLosses >= m_config.maxConsecutiveLosses) {
ActivateCircuitBreaker(CB_TRIGGER_LOSS_STREAK, CB_LEVEL_CAUTION,
StringFormat("Consecutive losses exceeded: %d", m_consecutiveLosses),
m_consecutiveLosses);
return true;
}

// Check loss streak amount
if(m_lossStreakAmount >= m_config.maxLossStreakAmount) {
ActivateCircuitBreaker(CB_TRIGGER_LOSS_STREAK, CB_LEVEL_EMERGENCY,
StringFormat("Loss streak amount exceeded: $%.2f", m_lossStreakAmount),
m_lossStreakAmount);
return true;
}

return false;
}
bool                    CheckVolatilityTriggers() {
// Check if volatility exceeds threshold
if(m_currentVolatility > m_config.maxVolatilityMultiple * 0.01) { // 1% base volatility
ActivateCircuitBreaker(CB_TRIGGER_VOLATILITY, CB_LEVEL_CAUTION,
StringFormat("High volatility detected: %.2f%%", m_currentVolatility * 100),
m_currentVolatility);
return true;
}

// Check if liquidity is too low
if(m_currentLiquidity < m_config.minLiquidityRatio) {
ActivateCircuitBreaker(CB_TRIGGER_LIQUIDITY, CB_LEVEL_WARNING,
StringFormat("Low liquidity detected: %.1f%%", m_currentLiquidity * 100),
m_currentLiquidity);
return true;
}

return false;
}
bool                    CheckBlackSwanTriggers() {
if(m_blackSwanDetector == NULL) return false;

if(m_blackSwanDetector.IsBlackSwanActive()) {
BlackSwanEvent currentEvent = m_blackSwanDetector.GetCurrentEvent();

ENUM_CIRCUIT_BREAKER_LEVEL level = CB_LEVEL_WARNING;
if(currentEvent.severity > 0.7) level = CB_LEVEL_EMERGENCY;
else if(currentEvent.severity > 0.4) level = CB_LEVEL_CAUTION;

ActivateCircuitBreaker(CB_TRIGGER_BLACK_SWAN, level,
StringFormat("Black Swan Event: %s", currentEvent.eventName),
currentEvent.severity);
return true;
}

return false;
}
bool                    CheckTimeTriggers() {
// Check for high-impact news times (simplified)
if(m_config.enableNewsFilter) {
MqlDateTime dt;
TimeToStruct(TimeCurrent(), dt);

// Block trading during typical news times (example: 8:30 AM EST)
if(dt.hour == 13 && dt.min >= 25 && dt.min <= 35) { // 8:25-8:35 AM EST in GMT
ActivateCircuitBreaker(CB_TRIGGER_NEWS_EVENT, CB_LEVEL_CAUTION,
"High-impact news time detected", 0.0);
return true;
}
}

return false;
}
void                    ActivateCircuitBreaker(ENUM_CIRCUIT_BREAKER_TRIGGER trigger, 
ENUM_CIRCUIT_BREAKER_LEVEL level, 
string reason, double value) {
// Only activate if new level is higher or first activation
if(IsActive() && level <= m_status.currentLevel) return;

m_status.currentLevel = level;
m_status.triggerType = trigger;
m_status.activationTime = TimeCurrent();
m_status.cooldownEnd = TimeCurrent() + m_config.cooldownMinutes * 60;
m_status.triggerReason = reason;
m_status.triggerValue = value;
m_status.isRecovering = false;
m_status.recoveryProgress = 0.0;

Print(StringFormat("[🔴 CIRCUIT BREAKER] ACTIVATED - Level: %s, Trigger: %s", 
GetLevelName(level), GetTriggerName(trigger)));
Print(StringFormat("[🔴 CIRCUIT BREAKER] Reason: %s", reason));

// Send notification for emergency levels - CRITICAL FIX: SendNotification takes only 1 parameter
if(level >= CB_LEVEL_EMERGENCY) {
SendNotification("CIRCUIT BREAKER EMERGENCY: " + reason);
}
}
void                    ProcessEmergencyActions() {
if(m_status.currentLevel == CB_LEVEL_LOCKDOWN && m_config.enableEmergencyClose) {
// Close all positions in lockdown mode - CRITICAL FIX: Use proper MQL5 position selection
int totalPositions = PositionsTotal();
for(int i = totalPositions - 1; i >= 0; i--) {
string symbol = PositionGetSymbol(i);
if(symbol != "") {
ulong ticket = PositionGetTicket(i);

// Close position
MqlTradeRequest request = {};
MqlTradeResult result = {};

request.action = TRADE_ACTION_DEAL;
request.position = ticket;
request.symbol = symbol;
request.volume = PositionGetDouble(POSITION_VOLUME);
request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
ORDER_TYPE_SELL : ORDER_TYPE_BUY;
request.deviation = 10;

if(OrderSend(request, result)) {
m_status.positionsClosed++;
Print(StringFormat("[🔴 CIRCUIT BREAKER] Emergency close: %s (Ticket: %I64u)", 
symbol, ticket));
}
}
}
}
}
void                    ProcessRecovery() {
if(!m_config.autoRecovery) return;

// Calculate recovery progress based on current metrics
double recoveryScore = 0.0;
int factors = 0;

// Factor 1: Drawdown improvement
if(m_dailyDrawdown < m_config.maxDailyDrawdown * m_config.recoveryThreshold) {
recoveryScore += 0.3;
}
factors++;

// Factor 2: No recent losses
if(m_consecutiveLosses == 0) {
recoveryScore += 0.3;
}
factors++;

// Factor 3: Time passed
int timePassedMinutes = (int)((TimeCurrent() - m_status.activationTime) / 60);
if(timePassedMinutes >= m_config.cooldownMinutes) {
recoveryScore += 0.4;
}
factors++;

m_status.recoveryProgress = recoveryScore;

// Auto-deactivate if recovery threshold met
if(recoveryScore >= 0.8 && TimeCurrent() >= m_status.cooldownEnd) {
Print("[🔴 CIRCUIT BREAKER] Auto-recovery completed - Deactivating");
m_status.Reset();
}
}
string                  GetTriggerName(ENUM_CIRCUIT_BREAKER_TRIGGER trigger) {
switch(trigger) {
case CB_TRIGGER_DRAWDOWN: return "Drawdown";
case CB_TRIGGER_LOSS_STREAK: return "Loss Streak";
case CB_TRIGGER_VOLATILITY: return "Volatility";
case CB_TRIGGER_BLACK_SWAN: return "Black Swan";
case CB_TRIGGER_CORRELATION: return "Correlation";
case CB_TRIGGER_LIQUIDITY: return "Liquidity";
case CB_TRIGGER_MANUAL: return "Manual";
case CB_TRIGGER_TIME_BASED: return "Time Based";
case CB_TRIGGER_NEWS_EVENT: return "News Event";
default: return "Unknown";
}
}
string                  GetLevelName(ENUM_CIRCUIT_BREAKER_LEVEL level) {
switch(level) {
case CB_LEVEL_WARNING: return "WARNING";
case CB_LEVEL_CAUTION: return "CAUTION";
case CB_LEVEL_EMERGENCY: return "EMERGENCY";
case CB_LEVEL_LOCKDOWN: return "LOCKDOWN";
default: return "NONE";
}
}

public:
// Constructor
CCircuitBreaker() {
// Initialize configuration with defaults
m_config.SetDefaults();
// Initialize status
m_status.Reset();
// Initialize monitoring data
m_dailyDrawdown = 0.0;
m_weeklyDrawdown = 0.0;
m_monthlyDrawdown = 0.0;
m_consecutiveLosses = 0;
m_lossStreakAmount = 0.0;
m_currentVolatility = 0.0;
m_currentLiquidity = 1.0;
// Initialize historical tracking
m_lastTradeTime = 0;
m_lastEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_dayStartEquity = m_lastEquity;
m_weekStartEquity = m_lastEquity;
m_monthStartEquity = m_lastEquity;
// Initialize integration
m_blackSwanDetector = NULL;
}
// Destructor
~CCircuitBreaker() {
// Cleanup if needed
}
// Initialization
bool Initialize(CBlackSwanDetector* blackSwanDetector = NULL) {
m_blackSwanDetector = blackSwanDetector;
// Initialize equity baselines
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_lastEquity = currentEquity;
m_dayStartEquity = currentEquity;
m_weekStartEquity = currentEquity;
m_monthStartEquity = currentEquity;
Print("[🔴 CIRCUIT BREAKER] Initialized - Emergency protection active");
Print(StringFormat("[🔴 CIRCUIT BREAKER] Thresholds - Daily: %.1f%%, Weekly: %.1f%%, Monthly: %.1f%%",
m_config.maxDailyDrawdown * 100, m_config.maxWeeklyDrawdown * 100, m_config.maxMonthlyDrawdown * 100));
return true;
}
// Main monitoring
bool MonitorAndCheck() {
// Update all metrics
UpdateDrawdownMetrics();
UpdateLossStreakMetrics();
UpdateVolatilityMetrics();
// Check if already active and in cooldown
if(IsActive() && TimeCurrent() < m_status.cooldownEnd) {
ProcessRecovery();
return true; // Still active
}
// Check all trigger conditions
bool triggered = false;
if(CheckDrawdownTriggers()) triggered = true;
if(CheckLossStreakTriggers()) triggered = true;
if(CheckVolatilityTriggers()) triggered = true;
if(CheckBlackSwanTriggers()) triggered = true;
if(CheckTimeTriggers()) triggered = true;
// Process emergency actions if needed
if(IsActive()) {
ProcessEmergencyActions();
}
return triggered;
}
// Status queries
bool IsActive() const { return m_status.currentLevel != CB_LEVEL_NONE; }
ENUM_CIRCUIT_BREAKER_LEVEL GetCurrentLevel() const { return m_status.currentLevel; }
CircuitBreakerStatus GetStatus() const { return m_status; }

// Trade control
bool ShouldBlockTrade(string symbol, ENUM_ORDER_TYPE orderType) {
if(!IsActive()) return false;

bool shouldBlock = false;

switch(m_status.currentLevel) {
case CB_LEVEL_WARNING:
// Allow trades but with reduced risk
break;

case CB_LEVEL_CAUTION:
// Block new trades, allow closing trades
if(orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_SELL) {
shouldBlock = true;
}
break;

case CB_LEVEL_EMERGENCY:
case CB_LEVEL_LOCKDOWN:
// Block all new trades
shouldBlock = true;
break;
}

if(shouldBlock) {
m_status.tradesBlocked++;
Print(StringFormat("[🔴 CIRCUIT BREAKER] Trade blocked for %s - Level: %s", 
symbol, GetLevelName(m_status.currentLevel)));
}

return shouldBlock;
}
bool ShouldClosePosition(string symbol);
double GetRiskMultiplier() {
if(!IsActive()) return 1.0;

switch(m_status.currentLevel) {
case CB_LEVEL_WARNING:
return 0.5;  // 50% risk reduction

case CB_LEVEL_CAUTION:
return 0.25; // 75% risk reduction

case CB_LEVEL_EMERGENCY:
return 0.1;  // 90% risk reduction

case CB_LEVEL_LOCKDOWN:
return 0.0;  // No new risk

default:
return 1.0;
}
}

// Manual controls
void ForceActivation(ENUM_CIRCUIT_BREAKER_LEVEL level, string reason) {
ActivateCircuitBreaker(CB_TRIGGER_MANUAL, level, "Manual: " + reason, 0.0);
}
void ForceDeactivation() {
Print("[🔴 CIRCUIT BREAKER] Manually deactivated");
m_status.Reset();
}
void ResetCounters() {
m_consecutiveLosses = 0;
m_lossStreakAmount = 0.0;
m_status.tradesBlocked = 0;
m_status.positionsClosed = 0;
Print("[🔴 CIRCUIT BREAKER] Counters reset");
}

// Reporting
string GenerateStatusReport() {
string report = "🔴 CIRCUIT BREAKER STATUS\n";
report += "========================\n";

if(IsActive()) {
report += StringFormat("Status: ACTIVE (%s)\n", GetLevelName(m_status.currentLevel));
report += StringFormat("Trigger: %s\n", GetTriggerName(m_status.triggerType));
report += StringFormat("Reason: %s\n", m_status.triggerReason);
report += StringFormat("Activated: %s\n", TimeToString(m_status.activationTime));
report += StringFormat("Cooldown Ends: %s\n", TimeToString(m_status.cooldownEnd));
report += StringFormat("Trades Blocked: %d\n", m_status.tradesBlocked);
report += StringFormat("Positions Closed: %d\n", m_status.positionsClosed);

if(m_status.isRecovering) {
report += StringFormat("Recovery Progress: %.1f%%\n", m_status.recoveryProgress * 100);
}
} else {
report += "Status: INACTIVE\n";
}

// Current metrics
report += "\n📊 CURRENT METRICS\n";
report += StringFormat("Daily Drawdown: %.2f%% (Max: %.2f%%)\n", 
m_dailyDrawdown * 100, m_config.maxDailyDrawdown * 100);
report += StringFormat("Weekly Drawdown: %.2f%% (Max: %.2f%%)\n", 
m_weeklyDrawdown * 100, m_config.maxWeeklyDrawdown * 100);
report += StringFormat("Monthly Drawdown: %.2f%% (Max: %.2f%%)\n", 
m_monthlyDrawdown * 100, m_config.maxMonthlyDrawdown * 100);
report += StringFormat("Consecutive Losses: %d (Max: %d)\n", 
m_consecutiveLosses, m_config.maxConsecutiveLosses);
report += StringFormat("Loss Streak Amount: $%.2f (Max: $%.2f)\n", 
m_lossStreakAmount, m_config.maxLossStreakAmount);

return report;
}
string GenerateDetailedReport();

// Event handlers
void OnTradeResult(bool isWin, double profit) {
if(isWin) {
// Reset loss streak on win
m_consecutiveLosses = 0;
m_lossStreakAmount = 0.0;
} else {
// Increment loss streak
m_consecutiveLosses++;
m_lossStreakAmount += MathAbs(profit);
}

m_lastTradeTime = TimeCurrent();
}
void OnEquityUpdate(double currentEquity) {
m_lastEquity = currentEquity;
}
void OnNewDay() {
m_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_dailyDrawdown = 0.0;
}
void OnNewWeek() {
m_weekStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_weeklyDrawdown = 0.0;
}
void OnNewMonth() {
m_monthStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_monthlyDrawdown = 0.0;
}

//+------------------------------------------------------------------+
//| ?? VOLATILITY SPIKE DETECTION - PHASE 3 IMPLEMENTATION           |
//+------------------------------------------------------------------+
bool IsVolatilitySpike() {
// Get current volatility (ATR-based)
double currentATR = iATR(_Symbol, PERIOD_M15, 14);
if(currentATR <= 0) return false;

// Get baseline ATR (20-period average)
double baselineATR = 0.0;
for(int i = 1; i <= 20; i++) {
double atr = iATR(_Symbol, PERIOD_M15, 14);
if(atr > 0) baselineATR += atr;
}
baselineATR /= 20.0;
if(baselineATR <= 0) return false;

// Asset-specific volatility thresholds according to review.txt
double spikeThreshold = 2.0; // Default multiplier
string assetClass = "";

// Determine asset class and set specific threshold
if(StringFind(_Symbol, "USD") >= 0 || StringFind(_Symbol, "EUR") >= 0 || 
StringFind(_Symbol, "GBP") >= 0 || StringFind(_Symbol, "JPY") >= 0) {
assetClass = "MAJOR_FOREX";
spikeThreshold = 2.5; // Major pairs - higher threshold
} else if(StringFind(_Symbol, "AUD") >= 0 || StringFind(_Symbol, "NZD") >= 0 || 
StringFind(_Symbol, "CAD") >= 0 || StringFind(_Symbol, "CHF") >= 0) {
assetClass = "MINOR_FOREX";
spikeThreshold = 2.2; // Minor pairs - moderate threshold
} else if(StringFind(_Symbol, "XAU") >= 0 || StringFind(_Symbol, "GOLD") >= 0) {
assetClass = "PRECIOUS_METALS";
spikeThreshold = 1.8; // Gold - lower threshold (more sensitive)
} else if(StringFind(_Symbol, "BTC") >= 0 || StringFind(_Symbol, "ETH") >= 0) {
assetClass = "CRYPTO";
spikeThreshold = 3.0; // Crypto - highest threshold
} else {
assetClass = "OTHER";
spikeThreshold = 2.0; // Default threshold
}

// Calculate volatility ratio
double volatilityRatio = currentATR / baselineATR;

// Check if spike detected
bool isSpike = volatilityRatio > spikeThreshold;

if(isSpike) {
::PrintFormat("[?? VOLATILITY SPIKE] %s detected: %.2fx baseline (threshold: %.1fx)", 
assetClass, volatilityRatio, spikeThreshold);
::PrintFormat("[?? VOLATILITY SPIKE] Current ATR: %.5f, Baseline ATR: %.5f", 
currentATR, baselineATR);

// Activate circuit breaker for volatility spike
ActivateCircuitBreaker(CB_TRIGGER_VOLATILITY, CB_LEVEL_CAUTION, 
StringFormat("Volatility spike: %.2fx threshold", volatilityRatio), 
volatilityRatio);
}

return isSpike;
}

};




























#endif // RISK_CIRCUITBREAKER_MQH
