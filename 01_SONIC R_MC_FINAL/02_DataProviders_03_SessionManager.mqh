//+------------------------------------------------------------------+
//|                                          Core_SessionManager.mqh |
//|                            Sonic R MC EA - Session Management    |
//|                     Ð?i Bàng Architecture - Clean Dependencies   |
//| Authors: Mèo C?c vs Ð?i Bàng                                     |
//+------------------------------------------------------------------+
#ifndef CORE_SESSIONMANAGER_MQH
#define CORE_SESSIONMANAGER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| Session Manager Class - FIX: Remove namespace wrapper           |
//+------------------------------------------------------------------+
class CSessionManager
{
private:
SonicRSession m_currentSession;
ENUM_SESSION_TYPE m_currentSessionType;
ENUM_TRADING_SESSION m_currentTradingSession;
datetime m_sessionStart;
datetime m_sessionEnd;

public:
CSessionManager()
{
InitializeCurrentSession();
Update();
}

~CSessionManager() {}

SonicRSession GetCurrentSession() const { return m_currentSession; }
ENUM_SESSION_TYPE GetCurrentSessionType() const { return m_currentSessionType; }
ENUM_TRADING_SESSION GetCurrentTradingSession() const { return m_currentTradingSession; }

bool IsSessionActive() const
{
return m_currentSession.isActive;
}

bool IsNewYorkSession() const { return m_currentTradingSession == SESSION_NEW_YORK; }
bool IsLondonSession() const { return m_currentTradingSession == SESSION_LONDON; }
bool IsAsianSession() const { return m_currentTradingSession == SESSION_ASIAN; }

private:
void InitializeCurrentSession()
{
m_currentSession.name = "UNKNOWN";
m_currentSession.startTime = 0;
m_currentSession.endTime = 0;
m_currentSession.isActive = false;
m_currentSession.volatility = 1.0;
m_currentSession.isHighImpact = false;
m_currentSessionType = SESSION_QUIET;
m_currentTradingSession = SESSION_ASIAN;
}

public:
void Update()
{
datetime current = TimeCurrent();
MqlDateTime dt;
TimeToStruct(current, dt);

int hour = dt.hour;

// Session detection logic
if (hour >= 1 && hour < 8) {
m_currentTradingSession = SESSION_ASIAN;
m_currentSessionType = SESSION_QUIET;
m_currentSession.name = "ASIAN";
m_currentSession.volatility = 0.8;
m_currentSession.isHighImpact = false;
}
else if (hour >= 8 && hour < 16) {
m_currentTradingSession = SESSION_LONDON;
m_currentSessionType = SESSION_ACTIVE;
m_currentSession.name = "LONDON";
m_currentSession.volatility = 1.2;
m_currentSession.isHighImpact = true;
}
else if (hour >= 16 && hour < 24) {
m_currentTradingSession = SESSION_NEW_YORK;
m_currentSessionType = SESSION_ACTIVE;
m_currentSession.name = "NEW_YORK";
m_currentSession.volatility = 1.0;
m_currentSession.isHighImpact = true;
}
else {
m_currentTradingSession = SESSION_ASIAN;
m_currentSessionType = SESSION_QUIET;
m_currentSession.name = "QUIET";
m_currentSession.volatility = 0.5;
m_currentSession.isHighImpact = false;
}

m_currentSession.isActive = (m_currentSessionType != SESSION_QUIET);
m_currentSession.startTime = current;
m_currentSession.endTime = current + 3600; // 1 hour duration
}
};

#endif // CORE_SESSIONMANAGER_MQH




