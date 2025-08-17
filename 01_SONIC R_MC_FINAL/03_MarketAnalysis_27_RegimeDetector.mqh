//+------------------------------------------------------------------+
//| Market Regime Detector - PHASE 3 Component                        |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC - Market Regime Detection"
#property version   "3.0"
#property strict


#ifndef MARKET_REGIMEDETECTOR_MQH
#define MARKET_REGIMEDETECTOR_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"    // CRITICAL FIX: Add for CUnifiedIndicatorManager

//+------------------------------------------------------------------+
//| Market Regime Detector Class                                      |
//+------------------------------------------------------------------+
class CMarketRegimeDetector
{
private:
// Configuration
int                     m_lookbackPeriod;
double                  m_volatilityThreshold;
double                  m_trendThreshold;

// State tracking
ENUM_MARKET_REGIME      m_currentRegime;
datetime               m_lastUpdateTime;

public:
// Constructor
CMarketRegimeDetector()
{
m_lookbackPeriod = 20;
m_volatilityThreshold = 0.02;
m_trendThreshold = 0.6;
m_currentRegime = REGIME_UNKNOWN;
m_lastUpdateTime = 0;
}

// Destructor
~CMarketRegimeDetector() {}

// Initialize
bool Initialize()
{
m_currentRegime = REGIME_UNKNOWN;
m_lastUpdateTime = 0;
return true;
}

// Detect current market regime
ENUM_MARKET_REGIME DetectCurrentRegime()
{
if(TimeCurrent() - m_lastUpdateTime < 60) // Update every minute
return m_currentRegime;

// Calculate volatility
double volatility = CalculateVolatility();

// Calculate trend strength
double trendStrength = CalculateTrendStrength();

// Determine regime based on volatility and trend
if(volatility > m_volatilityThreshold)
{
if(trendStrength > m_trendThreshold)
m_currentRegime = ENUM_MARKET_REGIME::REGIME_VOLATILE_TRENDING;
else
m_currentRegime = ENUM_MARKET_REGIME::REGIME_VOLATILE_RANGING;
}
else
{
if(trendStrength > m_trendThreshold)
m_currentRegime = ENUM_MARKET_REGIME::REGIME_STABLE_TRENDING;
else
m_currentRegime = ENUM_MARKET_REGIME::REGIME_STABLE_RANGING;
}

m_lastUpdateTime = TimeCurrent();
return m_currentRegime;
}

// Get current regime
ENUM_MARKET_REGIME GetCurrentRegime() const
{
return m_currentRegime;
}

//+------------------------------------------------------------------+
//| ?? VALIDATE SIGNAL FOR CURRENT REGIME                           |
//+------------------------------------------------------------------+
bool IsSignalValidForCurrentRegime(const SignalData& signalData)
{
// Update regime detection
ENUM_MARKET_REGIME currentRegime = DetectCurrentRegime();

// Check if signal is valid for current regime
switch(currentRegime)
{
case REGIME_VOLATILE_TRENDING:
// In volatile trending markets, prefer trend-following signals
if(signalData.signalType == SIGNAL_BUY || signalData.signalType == SIGNAL_SELL) {
return signalData.confidence >= 0.8; // Higher confidence required
}
break;

case REGIME_VOLATILE_RANGING:
// In volatile ranging markets, be more conservative
if(signalData.signalType == SIGNAL_BUY || signalData.signalType == SIGNAL_SELL) {
return signalData.confidence >= 0.85; // Very high confidence required
}
break;

case REGIME_STABLE_TRENDING:
// In stable trending markets, standard validation
if(signalData.signalType == SIGNAL_BUY || signalData.signalType == SIGNAL_SELL) {
return signalData.confidence >= 0.7; // Standard confidence
}
break;

case REGIME_STABLE_RANGING:
// In stable ranging markets, prefer mean reversion signals
if(signalData.signalType == SIGNAL_BUY || signalData.signalType == SIGNAL_SELL) {
return signalData.confidence >= 0.75; // Moderate confidence
}
break;

case REGIME_UNKNOWN:
default:
// Unknown regime - be conservative
return signalData.confidence >= 0.8;
}

return false;
}

private:
// Calculate market volatility
double CalculateVolatility()
{
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atr[1];
if(CopyBuffer(atrHandle, 0, 1, 1, atr) > 0) {
IndicatorRelease(atrHandle);
double close = iClose(_Symbol, PERIOD_CURRENT, 1);
return (atr[0] / close) * 100;
}
IndicatorRelease(atrHandle);
return 0.0;
}

// Calculate trend strength - SONIC R COMPLIANT (EMA34/89)
double CalculateTrendStrength()
{
// Get unified manager for Sonic R compliant EMAs
// ?? CRITICAL FIX: Ki?m tra manager null và t?o fallback
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();
int ema34Handle, ema89Handle;  // Declare local variables

if(manager == NULL) {
Print("? [REGIME] Unified Indicator Manager not available, using fallback");
ema34Handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
} else {
ema34Handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
ema89Handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 89, PRICE_CLOSE);
}

// Validate handles
if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE) {
Print("? [REGIME] Failed to create EMA handles");
Print("EMA34: ", (ema34Handle != INVALID_HANDLE ? "?" : "?"));
Print("EMA89: ", (ema89Handle != INVALID_HANDLE ? "?" : "?"));
return false;
}

double ema34[1], ema89[1]; 
double ema34Value = 0, ema89Value = 0;

if(CopyBuffer(ema34Handle, 0, 1, 1, ema34) > 0) {
ema34Value = ema34[0];
}
if(CopyBuffer(ema89Handle, 0, 1, 1, ema89) > 0) {
ema89Value = ema89[0];
}

// Only release handles if not using unified manager cache
if(manager == NULL) {
IndicatorRelease(ema34Handle);
IndicatorRelease(ema89Handle);
}

double close = iClose(_Symbol, PERIOD_CURRENT, 1);

// Calculate trend alignment (Sonic R: price vs EMA34 vs EMA89)
double trendAlignment = 0;
if(close > ema34Value && ema34Value > ema89Value)
trendAlignment = 1.0;
else if(close < ema34Value && ema34Value < ema89Value)
trendAlignment = -1.0;
else
trendAlignment = 0.5;

return MathAbs(trendAlignment);
}
}; 

#endif // MARKET_REGIMEDETECTOR_MQH



