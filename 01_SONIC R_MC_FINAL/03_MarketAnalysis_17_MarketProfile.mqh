//+------------------------------------------------------------------+
//|                                     Analysis_MarketProfile.mqh |
//|                        Copyright 2024, MQL5 Community Forum |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5 Community Forum"
#property link      "https://www.mql5.com"
#property version   "1.00"


// SYSTEMATIC FIX - Remove direct Logger include (already in MasterIncludes)
#include "01_Core_08_ContextManager.mqh"
// #include "01_Core_03_Logger.mqh" // Already included in MasterIncludes

//+------------------------------------------------------------------+
//| CAnalysisMarketProfile Class                                     |
//| Calculates and provides Market Profile data like POC, VA, Regime.|
//+------------------------------------------------------------------+
class CAnalysisMarketProfile
{
private:
CEaContext*     m_pContext;
CLogger*        m_pLogger;
double          m_poc;
double          m_valueAreaHigh;
double          m_valueAreaLow;
ENUM_MARKET_REGIME m_currentRegime;
int             m_profilePeriod;
double          m_valueAreaPercentage;

public:
CAnalysisMarketProfile()
{
m_pContext = NULL;
m_pLogger = NULL;
m_poc = 0.0;
m_valueAreaHigh = 0.0;
m_valueAreaLow = 0.0;
m_currentRegime = REGIME_UNDEFINED;
m_profilePeriod = 240;
m_valueAreaPercentage = 70.0;
}

~CAnalysisMarketProfile()
{
Deinitialize();
}

bool Initialize(CEaContext* pContext, CLogger* pLogger)
{
m_pContext = pContext;
m_pLogger = pLogger;
if(CheckPointer(m_pContext) == POINTER_INVALID || CheckPointer(m_pLogger) == POINTER_INVALID)
{
Print("[ERROR] Invalid context or logger pointer");
return false;
}
Print("[INFO] Market Profile Analysis initialized");
return true;
}

void Deinitialize()
{
m_pContext = NULL;
m_pLogger = NULL;
}

void Update()
{
if(CheckPointer(m_pContext) == POINTER_INVALID) return;
CalculateProfile();
DetermineMarketRegime();
}

double GetPointOfControl() const { return m_poc; }
double GetValueAreaHigh() const { return m_valueAreaHigh; }
double GetValueAreaLow() const { return m_valueAreaLow; }
ENUM_MARKET_REGIME GetCurrentRegime() const { return m_currentRegime; }

private:
void CalculateProfile()
{
if(CheckPointer(m_pContext) == POINTER_INVALID) return;
m_poc = SymbolInfoDouble(_Symbol, SYMBOL_BID);
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atrBuffer[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0)
{
double atr = atrBuffer[0];
m_valueAreaHigh = m_poc + atr * 1.5;
m_valueAreaLow = m_poc - atr * 1.5;
}
else
{
double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
m_valueAreaHigh = m_poc + pipSize * 50;
m_valueAreaLow = m_poc - pipSize * 50;
}
IndicatorRelease(atrHandle);
}

void DetermineMarketRegime()
{
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
if(currentPrice > m_valueAreaHigh)
{
m_currentRegime = REGIME_TRENDING_UP;
}
else if(currentPrice < m_valueAreaLow)
{
m_currentRegime = REGIME_TRENDING_DOWN;
}
else
{
m_currentRegime = REGIME_RANGING_TIGHT;
}
}
};



