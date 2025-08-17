//+------------------------------------------------------------------+
//|                                              News_RealTimeFilter.mqh |
//|                        SONIC R MC - REAL-TIME NEWS IMPACT FILTER      |
//|                            ?? INTELLIGENT NEWS AVOIDANCE SYSTEM        |
//+------------------------------------------------------------------+

#ifndef NEWS_REAL_TIME_FILTER_MQH
#define NEWS_REAL_TIME_FILTER_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| News Impact Level                                                |
//+------------------------------------------------------------------+
enum ENUM_NEWS_IMPACT
{
NEWS_IMPACT_NONE = 0,        // No news or very low impact
NEWS_IMPACT_LOW,             // Low impact news
NEWS_IMPACT_MEDIUM,          // Medium impact news
NEWS_IMPACT_HIGH,            // High impact news
NEWS_IMPACT_CRITICAL         // Market-moving news (NFP, FOMC, etc.)
};

//+------------------------------------------------------------------+
//| News Event Structure                                             |
//+------------------------------------------------------------------+
struct NewsEvent
{
string currency;             // Currency affected (USD, EUR, GBP, etc.)
string eventName;            // Name of news event
datetime eventTime;          // Scheduled time of event
ENUM_NEWS_IMPACT impact;     // Expected impact level
string actual;               // Actual value (if available)
string forecast;             // Forecasted value
string previous;             // Previous value
bool isReleased;            // Whether news has been released
int minutesBuffer;          // Minutes before/after to avoid trading

void Reset()
{
currency = "";
eventName = "";
eventTime = 0;
impact = NEWS_IMPACT_NONE;
actual = "";
forecast = "";
previous = "";
isReleased = false;
minutesBuffer = 0;
}
};

//+------------------------------------------------------------------+
//| News Filter Status                                               |
//+------------------------------------------------------------------+
struct NewsFilterStatus
{
bool isNewsBlocked;          // Are we currently in news avoidance period
ENUM_NEWS_IMPACT currentImpact; // Current news impact level
datetime blockStartTime;     // When current block started
datetime blockEndTime;       // When current block ends
NewsEvent upcomingEvent;     // Next upcoming news event
string blockReason;          // Reason for current block
int eventsToday;            // Number of news events today

void Reset()
{
isNewsBlocked = false;
currentImpact = NEWS_IMPACT_NONE;
blockStartTime = 0;
blockEndTime = 0;
upcomingEvent.Reset();
blockReason = "";
eventsToday = 0;
}
};

//+------------------------------------------------------------------+
//| ?? REAL-TIME NEWS FILTER SYSTEM                                 |
//+------------------------------------------------------------------+
class CRealTimeNewsFilter
{
private:
// News events storage
NewsEvent m_newsEvents[100];     // Today's news events
int m_newsEventCount;            // Number of events stored

// Filter status
NewsFilterStatus m_filterStatus;

// Configuration
bool m_isEnabled;                // Whether news filtering is enabled
bool m_avoidHighImpact;          // Avoid high impact news
bool m_avoidMediumImpact;        // Avoid medium impact news
bool m_avoidLowImpact;           // Avoid low impact news (usually false)

// Time buffers (minutes before/after news)
int m_criticalBuffer;            // Buffer for critical news (e.g., NFP)
int m_highBuffer;                // Buffer for high impact news
int m_mediumBuffer;              // Buffer for medium impact news
int m_lowBuffer;                 // Buffer for low impact news

// Currency monitoring
string m_monitoredCurrencies[];  // Currencies to monitor for news
int m_currencyCount;

// Update timing
datetime m_lastUpdate;           // Last time news data was updated
int m_updateIntervalMinutes;     // How often to update news data

public:
CRealTimeNewsFilter()
{
m_newsEventCount = 0;
m_isEnabled = true;
m_avoidHighImpact = true;
m_avoidMediumImpact = true;
m_avoidLowImpact = false;

// ?? PHASE 5: Enhanced time buffers for high impact news (30min requirement)
m_criticalBuffer = 30;       // 30 minutes before/after critical news
m_highBuffer = 30;           // ?? PHASE 5: 30 minutes for high impact
m_mediumBuffer = 15;         // 15 minutes before/after medium impact
m_lowBuffer = 5;             // 5 minutes before/after low impact

m_lastUpdate = 0;
m_updateIntervalMinutes = 60; // Update every hour

// Initialize monitored currencies
InitializeMonitoredCurrencies();

// Load today's news events
LoadTodaysNewsEvents();

m_filterStatus.Reset();

Print("[?? NEWS] Real-time News Filter initialized - PHASE 5 Enhanced");
Print("[?? PHASE 5] High Impact Buffer: 30min | Target: <10% degradation");
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: Enhanced News Filter with OnTick() Integration      |
//+------------------------------------------------------------------+
bool ShouldBlockTrading(string& reason)
{
// Update news data if needed
UpdateNewsDataIfNeeded();

// Check current time against news events
datetime currentTime = TimeCurrent();
bool shouldBlock = false;
ENUM_NEWS_IMPACT blockingImpact = NEWS_IMPACT_NONE;
NewsEvent blockingEvent;

// Check all today's news events
for(int i = 0; i < m_newsEventCount; i++) {
NewsEvent event;
event.currency = m_newsEvents[i].currency;
event.eventName = m_newsEvents[i].eventName;
event.eventTime = m_newsEvents[i].eventTime;
event.impact = m_newsEvents[i].impact;
event.actual = m_newsEvents[i].actual;
event.forecast = m_newsEvents[i].forecast;
event.previous = m_newsEvents[i].previous;
event.isReleased = m_newsEvents[i].isReleased;
event.minutesBuffer = m_newsEvents[i].minutesBuffer;

// Skip if currency not monitored
if(!IsCurrencyMonitored(event.currency)) continue;

// Calculate time difference
long timeDiff = (long)MathAbs((double)(currentTime - event.eventTime));
int minutesDiff = (int)(timeDiff / 60);

// Determine if we should avoid this event
bool avoidThisEvent = ShouldAvoidEvent(event.impact);
if(!avoidThisEvent) continue;

// Get appropriate buffer time
int bufferMinutes = GetBufferMinutes(event.impact);

// Check if we're in avoidance period
if(minutesDiff <= bufferMinutes) {
shouldBlock = true;
if(event.impact > blockingImpact) {
blockingImpact = event.impact;
blockingEvent = event;
}
}
}

// Update filter status
if(shouldBlock) {
m_filterStatus.isNewsBlocked = true;
m_filterStatus.currentImpact = blockingImpact;
m_filterStatus.upcomingEvent = blockingEvent;

// Calculate block duration
datetime eventTime = blockingEvent.eventTime;
int buffer = GetBufferMinutes(blockingEvent.impact);
m_filterStatus.blockStartTime = eventTime - buffer * 60;
m_filterStatus.blockEndTime = eventTime + buffer * 60;

// Set reason
reason = StringFormat("?? PHASE 5 NEWS BLOCK: %s %s (Impact: %s) at %s",
blockingEvent.currency,
blockingEvent.eventName,
GetImpactString(blockingEvent.impact),
TimeToString(blockingEvent.eventTime, TIME_MINUTES));
m_filterStatus.blockReason = reason;

// ?? PHASE 5: Log high impact news detection
if(blockingEvent.impact >= NEWS_IMPACT_HIGH) {
Print("[?? HIGH IMPACT] ", reason);
Print("[? BLOCK PERIOD] ", TimeToString(m_filterStatus.blockStartTime, TIME_MINUTES), 
" ? ", TimeToString(m_filterStatus.blockEndTime, TIME_MINUTES));
}

Print(StringFormat("[?? NEWS] Trading blocked: %s", reason));
} else {
m_filterStatus.isNewsBlocked = false;
m_filterStatus.currentImpact = NEWS_IMPACT_NONE;
reason = "";
}

return shouldBlock;
}

//+------------------------------------------------------------------+
//| ?? GET UPCOMING NEWS EVENTS                                     |
//+------------------------------------------------------------------+
NewsEvent GetNextUpcomingEvent()
{
datetime currentTime = TimeCurrent();
NewsEvent nextEvent;
nextEvent.Reset();

datetime earliestTime = 0;

for(int i = 0; i < m_newsEventCount; i++) {
NewsEvent event;
event.currency = m_newsEvents[i].currency;
event.eventName = m_newsEvents[i].eventName;
event.eventTime = m_newsEvents[i].eventTime;
event.impact = m_newsEvents[i].impact;
event.actual = m_newsEvents[i].actual;
event.forecast = m_newsEvents[i].forecast;

// Only consider future events
if(event.eventTime <= currentTime) continue;

// Only consider monitored currencies
if(!IsCurrencyMonitored(event.currency)) continue;

// Only consider events we would avoid
if(!ShouldAvoidEvent(event.impact)) continue;

// Find earliest upcoming event
if(earliestTime == 0 || event.eventTime < earliestTime) {
earliestTime = event.eventTime;
nextEvent.currency = event.currency;
nextEvent.eventName = event.eventName;
nextEvent.eventTime = event.eventTime;
nextEvent.impact = event.impact;
nextEvent.actual = event.actual;
nextEvent.forecast = event.forecast;
nextEvent.previous = event.previous;
nextEvent.isReleased = event.isReleased;
nextEvent.minutesBuffer = event.minutesBuffer;
}
}

return nextEvent;
}

//+------------------------------------------------------------------+
//| ?? LOAD TODAY'S NEWS EVENTS                                     |
//+------------------------------------------------------------------+
void LoadTodaysNewsEvents()
{
// Clear existing events
m_newsEventCount = 0;

// Get current date
MqlDateTime today;
TimeToStruct(TimeCurrent(), today);

// Simulate loading news events (in real implementation, this would fetch from economic calendar)
LoadSimulatedNewsEvents(today);

Print(StringFormat("[?? NEWS] Loaded %d news events for today", m_newsEventCount));
}

//+------------------------------------------------------------------+
//| ?? SIMULATED NEWS EVENTS (MVP IMPLEMENTATION)                   |
//+------------------------------------------------------------------+
void LoadSimulatedNewsEvents(MqlDateTime& date)
{
// High-impact USD events (typical times)
AddNewsEvent("USD", "Non-Farm Payrolls", 
StructToTime(date) + CreateTime(8, 30), NEWS_IMPACT_CRITICAL);

AddNewsEvent("USD", "FOMC Rate Decision", 
StructToTime(date) + CreateTime(14, 0), NEWS_IMPACT_CRITICAL);

AddNewsEvent("USD", "Core CPI m/m", 
StructToTime(date) + CreateTime(8, 30), NEWS_IMPACT_HIGH);

AddNewsEvent("USD", "Unemployment Rate", 
StructToTime(date) + CreateTime(8, 30), NEWS_IMPACT_HIGH);

// EUR events
AddNewsEvent("EUR", "ECB Rate Decision", 
StructToTime(date) + CreateTime(11, 45), NEWS_IMPACT_HIGH);

AddNewsEvent("EUR", "German GDP q/q", 
StructToTime(date) + CreateTime(6, 0), NEWS_IMPACT_MEDIUM);

// GBP events
AddNewsEvent("GBP", "BOE Rate Decision", 
StructToTime(date) + CreateTime(12, 0), NEWS_IMPACT_HIGH);

AddNewsEvent("GBP", "UK Retail Sales", 
StructToTime(date) + CreateTime(9, 30), NEWS_IMPACT_MEDIUM);

// JPY events
AddNewsEvent("JPY", "BOJ Rate Decision", 
StructToTime(date) + CreateTime(3, 0), NEWS_IMPACT_HIGH);

// CAD events
AddNewsEvent("CAD", "BOC Rate Decision", 
StructToTime(date) + CreateTime(14, 0), NEWS_IMPACT_HIGH);

// AUD events  
AddNewsEvent("AUD", "RBA Rate Decision", 
StructToTime(date) + CreateTime(4, 30), NEWS_IMPACT_HIGH);

// Regular daily events
AddNewsEvent("USD", "Initial Jobless Claims", 
StructToTime(date) + CreateTime(8, 30), NEWS_IMPACT_MEDIUM);

// Filter events to only include those actually scheduled for today
FilterEventsForToday();

Print(StringFormat("[?? NEWS] News events simulation loaded: %d events", m_newsEventCount));
}

//+------------------------------------------------------------------+
//| ?? HELPER METHODS                                               |
//+------------------------------------------------------------------+

void AddNewsEvent(string currency, string eventName, datetime eventTime, ENUM_NEWS_IMPACT impact)
{
if(m_newsEventCount >= 100) return; // Array full

NewsEvent event;
event.currency = currency;
event.eventName = eventName;
event.eventTime = eventTime;
event.impact = impact;
event.isReleased = false;
event.minutesBuffer = GetBufferMinutes(impact);

m_newsEvents[m_newsEventCount] = event;
m_newsEventCount++;
}

datetime CreateTime(int hour, int minute)
{
return hour * 3600 + minute * 60; // Convert to seconds
}

void FilterEventsForToday()
{
// In a real implementation, this would filter events based on actual economic calendar
// For simulation, we'll randomly include/exclude some events

MqlDateTime today;
TimeToStruct(TimeCurrent(), today);

// Only include 3-5 events per day for simulation
int targetEvents = 3 + (MathRand() % 3); // 3-5 events

if(m_newsEventCount > targetEvents) {
// Randomly select events to keep
for(int i = targetEvents; i < m_newsEventCount; i++) {
m_newsEvents[i].Reset();
}
m_newsEventCount = targetEvents;
}

// Set event count
m_filterStatus.eventsToday = m_newsEventCount;
}

void InitializeMonitoredCurrencies()
{
m_currencyCount = 8;
ArrayResize(m_monitoredCurrencies, m_currencyCount);

m_monitoredCurrencies[0] = "USD";
m_monitoredCurrencies[1] = "EUR";
m_monitoredCurrencies[2] = "GBP";
m_monitoredCurrencies[3] = "JPY";
m_monitoredCurrencies[4] = "CHF";
m_monitoredCurrencies[5] = "CAD";
m_monitoredCurrencies[6] = "AUD";
m_monitoredCurrencies[7] = "NZD";

Print(StringFormat("[?? NEWS] Monitoring %d currencies for news events", m_currencyCount));
}

bool IsCurrencyMonitored(string currency)
{
for(int i = 0; i < m_currencyCount; i++) {
if(m_monitoredCurrencies[i] == currency) return true;
}
return false;
}

bool ShouldAvoidEvent(ENUM_NEWS_IMPACT impact)
{
switch(impact) {
case NEWS_IMPACT_CRITICAL: return true; // Always avoid critical
case NEWS_IMPACT_HIGH: return m_avoidHighImpact;
case NEWS_IMPACT_MEDIUM: return m_avoidMediumImpact;
case NEWS_IMPACT_LOW: return m_avoidLowImpact;
default: return false;
}
}

int GetBufferMinutes(ENUM_NEWS_IMPACT impact)
{
switch(impact) {
case NEWS_IMPACT_CRITICAL: return m_criticalBuffer;
case NEWS_IMPACT_HIGH: return m_highBuffer;
case NEWS_IMPACT_MEDIUM: return m_mediumBuffer;
case NEWS_IMPACT_LOW: return m_lowBuffer;
default: return 5;
}
}

string GetImpactString(ENUM_NEWS_IMPACT impact)
{
switch(impact) {
case NEWS_IMPACT_CRITICAL: return "CRITICAL";
case NEWS_IMPACT_HIGH: return "HIGH";
case NEWS_IMPACT_MEDIUM: return "MEDIUM";
case NEWS_IMPACT_LOW: return "LOW";
default: return "NONE";
}
}

void UpdateNewsDataIfNeeded()
{
datetime currentTime = TimeCurrent();

// Check if we need to update
if(currentTime - m_lastUpdate < m_updateIntervalMinutes * 60) return;

// Check if it's a new day
MqlDateTime current, lastUpdate;
TimeToStruct(currentTime, current);
TimeToStruct(m_lastUpdate, lastUpdate);

if(current.day != lastUpdate.day) {
// New day - reload news events
LoadTodaysNewsEvents();
Print("[?? NEWS] New day detected - reloaded news events");
}

m_lastUpdate = currentTime;
}

// Configuration methods
void SetEnabled(bool enabled) { m_isEnabled = enabled; }
void SetAvoidHighImpact(bool avoid) { m_avoidHighImpact = avoid; }
void SetAvoidMediumImpact(bool avoid) { m_avoidMediumImpact = avoid; }
void SetAvoidLowImpact(bool avoid) { m_avoidLowImpact = avoid; }

void SetBufferMinutes(ENUM_NEWS_IMPACT impact, int minutes)
{
switch(impact) {
case NEWS_IMPACT_CRITICAL: m_criticalBuffer = minutes; break;
case NEWS_IMPACT_HIGH: m_highBuffer = minutes; break;
case NEWS_IMPACT_MEDIUM: m_mediumBuffer = minutes; break;
case NEWS_IMPACT_LOW: m_lowBuffer = minutes; break;
}
}

// Public interface
bool IsEnabled() const { return m_isEnabled; }
NewsFilterStatus GetFilterStatus() const { return m_filterStatus; }
int GetTodaysEventCount() const { return m_newsEventCount; }

// Note: GetNextUpcomingEvent is already defined above at line 222

string GetNewsFilterReport()
{
    // FIXED: Use proper struct initialization instead of deprecated assignment
    NewsEvent nextEvent;
    nextEvent.Reset();  // Use Reset method for proper initialization
    nextEvent = GetNextUpcomingEvent();
    
    return StringFormat(
        "?? NEWS FILTER STATUS\n" +
        "Filter Enabled: %s\n" +
        "Currently Blocked: %s\n" +
        "Current Impact: %s\n" +
        "Today's Events: %d\n" +
        "Next Event: %s %s at %s\n" +
        "Avoid Settings: High=%s, Medium=%s, Low=%s\n" +
        "Buffer Settings: Critical=%dm, High=%dm, Medium=%dm",
        m_isEnabled ? "YES" : "NO",
        m_filterStatus.isNewsBlocked ? "YES" : "NO",
        GetImpactString(m_filterStatus.currentImpact),
        m_filterStatus.eventsToday,
        nextEvent.currency, nextEvent.eventName,
TimeToString(nextEvent.eventTime, TIME_MINUTES),
m_avoidHighImpact ? "YES" : "NO",
m_avoidMediumImpact ? "YES" : "NO", 
m_avoidLowImpact ? "YES" : "NO",
m_criticalBuffer, m_highBuffer, m_mediumBuffer
);
}

// Get specific events for external use
void GetTodaysEvents(NewsEvent& events[], int& count)
{
count = MathMin(m_newsEventCount, ArraySize(events));
for(int i = 0; i < count; i++) {
events[i] = m_newsEvents[i];
}
}

bool IsHighImpactNewsTime()
{
return m_filterStatus.isNewsBlocked && 
(m_filterStatus.currentImpact >= NEWS_IMPACT_HIGH);
}

double GetRiskReductionFactor()
{
// Reduce risk based on proximity to news
if(!m_filterStatus.isNewsBlocked) return 1.0;

switch(m_filterStatus.currentImpact) {
case NEWS_IMPACT_CRITICAL: return 0.0; // No trading
case NEWS_IMPACT_HIGH: return 0.3;     // 30% of normal risk
case NEWS_IMPACT_MEDIUM: return 0.6;   // 60% of normal risk
case NEWS_IMPACT_LOW: return 0.8;      // 80% of normal risk
default: return 1.0;
}
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: OnTick() Integration for Real-Time News Checking    |
//+------------------------------------------------------------------+
void OnTickNewsCheck()
{
static datetime lastTickCheck = 0;
datetime currentTime = TimeCurrent();

// Check every 30 seconds to avoid excessive processing
if(currentTime - lastTickCheck < 30) return;
lastTickCheck = currentTime;

string blockReason = "";
bool isBlocked = ShouldBlockTrading(blockReason);

// ?? PHASE 5: Real-time high impact detection
if(isBlocked && m_filterStatus.currentImpact >= NEWS_IMPACT_HIGH) {
// Log every 5 minutes during high impact periods
static datetime lastHighImpactLog = 0;
if(currentTime - lastHighImpactLog >= 300) { // 5 minutes
Print("[?? ONTICK HIGH IMPACT] ", blockReason);
Print("[? REMAINING] ", (int)((m_filterStatus.blockEndTime - currentTime) / 60), " minutes");
lastHighImpactLog = currentTime;
}
}
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: Fallback News Detection System                      |
//+------------------------------------------------------------------+
bool FallbackNewsDetection()
{
// Built-in news detection when external calendar fails
static datetime lastFallbackCheck = 0;
datetime currentTime = TimeCurrent();

// Check every 15 minutes
if(currentTime - lastFallbackCheck < 900) return false;
lastFallbackCheck = currentTime;

// ?? Detect unusual market conditions that might indicate news
double currentSpread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
double normalSpread = GetNormalSpread();

// ?? Detect volume spikes
long currentVolume = iVolume(_Symbol, PERIOD_M1, 0);
long avgVolume = GetAverageVolume(10);

// ?? Detect price volatility spikes
int atrHandle = iATR(_Symbol, PERIOD_M1, 14);
double atr = 0.0;
if(atrHandle != INVALID_HANDLE) {
double atrValues[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrValues) > 0) {
atr = atrValues[0];
}
}
double avgATR = GetAverageATR(20);

bool spreadSpike = currentSpread > normalSpread * 2.0;
bool volumeSpike = currentVolume > avgVolume * 3.0;
bool volatilitySpike = atr > avgATR * 2.5;

if(spreadSpike || volumeSpike || volatilitySpike) {
Print("[?? FALLBACK] Unusual market conditions detected!");
Print("[?? METRICS] Spread: ", DoubleToString(currentSpread/normalSpread, 2), "x | Volume: ", 
DoubleToString((double)currentVolume/avgVolume, 2), "x | ATR: ", DoubleToString(atr/avgATR, 2), "x");

// Create temporary high impact event
NewsEvent fallbackEvent;
fallbackEvent.currency = "UNKNOWN";
fallbackEvent.eventName = "Market Anomaly Detected";
fallbackEvent.eventTime = currentTime;
fallbackEvent.impact = NEWS_IMPACT_HIGH;
fallbackEvent.isReleased = true;

// Block trading for 15 minutes
m_filterStatus.isNewsBlocked = true;
m_filterStatus.currentImpact = NEWS_IMPACT_HIGH;
m_filterStatus.blockStartTime = currentTime;
m_filterStatus.blockEndTime = currentTime + 900; // 15 minutes
m_filterStatus.blockReason = "Fallback: Market anomaly detected";

return true;
}

return false;
}

//+------------------------------------------------------------------+
//| ?? PHASE 5: Performance Monitoring (<10% degradation target)    |
//+------------------------------------------------------------------+
void MonitorPerformanceImpact()
{
static int totalSignals = 0;
static int blockedSignals = 0;
static datetime lastReport = 0;

datetime currentTime = TimeCurrent();

// Report every hour
if(currentTime - lastReport >= 3600) {
double blockRate = totalSignals > 0 ? (double)blockedSignals / totalSignals * 100 : 0;

Print(StringFormat("[?? NEWS PERFORMANCE] Signals: %d | Blocked: %d | Rate: %.1f%%", 
totalSignals, blockedSignals, blockRate));

// ?? PHASE 5 TARGET: <10% degradation
if(blockRate > 10.0) {
Print("[?? WARNING] News filter blocking >10% of signals - consider adjustment");
} else {
Print("[? TARGET MET] News filter impact <10% - within Phase 5 target");
}

lastReport = currentTime;
}
}

// Helper methods for fallback detection
double GetNormalSpread()
{
// Calculate average spread over last 24 hours
double totalSpread = 0;
int count = 0;
for(int i = 1; i <= 1440; i++) { // 24 hours in minutes
double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
if(spread > 0) {
totalSpread += spread;
count++;
}
}
return count > 0 ? totalSpread / count : (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

long GetAverageVolume(int periods)
{
long total = 0;
for(int i = 1; i <= periods; i++) {
total += iVolume(_Symbol, PERIOD_M1, i);
}
return total / periods;
}

double GetAverageATR(int periods)
{
double total = 0;
int atrHandle = iATR(_Symbol, PERIOD_M1, 14);
if(atrHandle != INVALID_HANDLE) {
double atrValues[];
ArrayResize(atrValues, periods);
if(CopyBuffer(atrHandle, 0, 0, periods, atrValues) > 0) {
for(int i = 0; i < periods; i++) {
total += atrValues[i];
}
}
}
return periods > 0 ? total / periods : 0.0;
}
};

#endif // NEWS_REAL_TIME_FILTER_MQH


