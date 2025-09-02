#ifndef CORE_TIMEMANAGER_MQH
// Helper: auto-detect broker GMT offset
int DetectBrokerGMTOffset()
{
    datetime srv = TimeTradeServer();
    datetime gmt = TimeGMT();
    return (int)MathRound(((double)(srv - gmt))/3600.0);
}

#define CORE_TIMEMANAGER_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_09_SharedDataStructures.mqh"  // FIX: Add include for CEaContext class definition

// MQL5 doesn't support namespaces

class CTimeManager
{
private:
bool                m_initialized;
bool                m_isNewBar;
datetime            m_lastBarTime;
MqlDateTime         m_currentTime;

public:
CTimeManager() :
m_initialized(false),
m_isNewBar(false),
m_lastBarTime(0)
{
ZeroMemory(m_currentTime);
}

~CTimeManager() {}

bool Initialize() {
m_initialized = true;
m_lastBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
TimeToStruct(TimeCurrent(), m_currentTime);
return true;
}

// Overloaded Initialize for compatibility
bool Initialize(CEaContext* context) {
// Can store context if needed in future
return Initialize();
}

void Deinitialize() {
m_initialized = false;
}

bool IsInitialized() const { return m_initialized; }

void OnTick() {
if (!m_initialized) return;

// Update current time
TimeToStruct(TimeCurrent(), m_currentTime);

// Check for new bar
datetime currentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
m_isNewBar = (currentBarTime > m_lastBarTime);
if (m_isNewBar) {
m_lastBarTime = currentBarTime;
}
}

// Getters
bool IsNewBar() const { return m_isNewBar; }
datetime GetCurrentTime() const { return TimeCurrent(); }
int GetCurrentHour() const { return m_currentTime.hour; }
int GetCurrentMinute() const { return m_currentTime.min; }
int GetCurrentDay() const { return m_currentTime.day; }
int GetCurrentMonth() const { return m_currentTime.mon; }
int GetCurrentYear() const { return m_currentTime.year; }

// Session checks
bool IsTradeAllowed() const
{
// Enhanced session check with news filter
if(!IsWithinTradingHours()) return false;
if(IsHighImpactNews()) return false;
return true;
}

bool IsWithinTradingHours() const
{
// Trading hours: avoid weekend and early morning
return (m_currentTime.hour >= 1 && m_currentTime.hour <= 23 &&
m_currentTime.day_of_week >= 1 && m_currentTime.day_of_week <= 5);
}

// ENHANCED: High-impact news detection
bool IsHighImpactNews() const
{
// Major news times (GMT)
// US Session: NFP (8:30), CPI (8:30), FOMC (14:00-14:30)
if((m_currentTime.hour == 8 && m_currentTime.min >= 25 && m_currentTime.min <= 35) ||
(m_currentTime.hour == 14 && m_currentTime.min >= 0 && m_currentTime.min <= 30))
{
return true;
}

// EU Session: ECB (12:45), EU CPI (10:00)
if((m_currentTime.hour == 12 && m_currentTime.min >= 40 && m_currentTime.min <= 50) ||
(m_currentTime.hour == 10 && m_currentTime.min >= 0 && m_currentTime.min <= 10))
{
return true;
}

// Session overlap volatility periods
if((m_currentTime.hour == 7 && m_currentTime.min >= 50) ||  // Pre-London
(m_currentTime.hour == 8 && m_currentTime.min <= 10) ||  // London open
(m_currentTime.hour == 12 && m_currentTime.min >= 50) || // Pre-NY
(m_currentTime.hour == 13 && m_currentTime.min <= 10))   // NY open
{
return true;
}

return false;
}

// ENHANCED: Economic calendar integration stub
bool CheckForexFactoryNews() const
{
// STUB: Integration with Forex Factory calendar
// TODO: Implement DLL or web scraping for real-time news
// For now, return false (manual input via parameters)

// This would integrate with: https://www.forexfactory.com/calendar
// Implementation requires:
// 1. HTTP request to FF API (if available)
// 2. Parse JSON/XML response
// 3. Filter high-impact events
// 4. Time zone conversion

return false; // Placeholder
}

// ENHANCED: News avoidance with buffer zones
bool IsNewsAvoidanceActive() const
{
// 30-minute buffer before and after major news
if(IsHighImpactNews()) return true;

// Check 30-min buffer zones
datetime futureTime = TimeCurrent() + 30*60; // 30 min future
datetime pastTime = TimeCurrent() - 30*60;   // 30 min past

MqlDateTime futureDT, pastDT;
TimeToStruct(futureTime, futureDT);
TimeToStruct(pastTime, pastDT);

// Check if news was recent or upcoming
return (IsTimeInNewsWindow(futureDT) || IsTimeInNewsWindow(pastDT));
}

private:
// Helper method for news window checking
bool IsTimeInNewsWindow(const MqlDateTime &dt) const
{
// Major news times check for any datetime
return ((dt.hour == 8 && dt.min >= 25 && dt.min <= 35) ||
(dt.hour == 14 && dt.min >= 0 && dt.min <= 30) ||
(dt.hour == 12 && dt.min >= 40 && dt.min <= 50) ||
(dt.hour == 10 && dt.min >= 0 && dt.min <= 10));
}
};

#endif // CORE_TIMEMANAGER_MQH


