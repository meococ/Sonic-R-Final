//+------------------------------------------------------------------+
//| SMC Signal Validator - PHASE 3 Component                          |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC - SMC Signal Validation"
#property version   "3.0"
#property strict


#ifndef SMC_SIGNALVALIDATOR_MQH
#define SMC_SIGNALVALIDATOR_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"    // CRITICAL FIX: Add for CUnifiedIndicatorManager

//+------------------------------------------------------------------+
//| SMC Signal Validator Class                                        |
//+------------------------------------------------------------------+
class CSMCSignalValidator
{
private:
// Configuration
double                  m_minVolumeThreshold;
double                  m_minPriceActionThreshold;
double                  m_minStructureThreshold;

// State tracking
datetime               m_lastValidationTime;

public:
// Constructor
CSMCSignalValidator()
{
m_minVolumeThreshold = 1.5;
m_minPriceActionThreshold = 0.7;
m_minStructureThreshold = 0.6;
m_lastValidationTime = 0;
}

// Destructor
~CSMCSignalValidator() {}

// Initialize
bool Initialize()
{
m_lastValidationTime = 0;
return true;
}

// Validate SMC signal
bool ValidateSMCSignal(ENUM_SIGNAL_TYPE signalType, double confidence = 0.0)
{
if(TimeCurrent() - m_lastValidationTime < 30) // Validate every 30 seconds
return true;

// Check volume confirmation
bool volumeValid = ValidateVolume();

// Check price action
bool priceActionValid = ValidatePriceAction();

// Check market structure
bool structureValid = ValidateMarketStructure();

// Overall validation
bool isValid = volumeValid && priceActionValid && structureValid;

m_lastValidationTime = TimeCurrent();
return isValid;
}

// Get validation score
double GetValidationScore()
{
double volumeScore = GetVolumeScore();
double priceActionScore = GetPriceActionScore();
double structureScore = GetStructureScore();

return (volumeScore + priceActionScore + structureScore) / 3.0;
}

//+------------------------------------------------------------------+
//| ?? VALIDATE SIGNAL - MAIN ENTRY POINT                          |
//+------------------------------------------------------------------+
bool ValidateSignal(const SignalData& signalData)
{
if(!signalData.isValid) {
Print("? [SMC] Signal validation failed: Invalid signal data");
return false;
}

// Check signal type
if(signalData.signalType == SIGNAL_NONE) {
Print("? [SMC] Signal validation failed: No signal type");
return false;
}

// Validate SMC components
bool volumeValid = ValidateVolume();
bool priceActionValid = ValidatePriceAction();
bool structureValid = ValidateMarketStructure();

// Overall validation
bool isValid = volumeValid && priceActionValid && structureValid;

if(isValid) {
Print(StringFormat("? [SMC] Signal validation passed: %s with %.2f confidence", 
EnumToString(signalData.signalType), signalData.confidence));
} else {
Print("? [SMC] Signal validation failed: SMC components not valid");
}

return isValid;
}

private:
// Validate volume
bool ValidateVolume()
{
double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 1);
double avgVolume = 0;

// Calculate average volume over last 20 bars
for(int i = 1; i <= 20; i++)
{
avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 20;

return currentVolume > (avgVolume * m_minVolumeThreshold);
}

// Validate price action
bool ValidatePriceAction()
{
double currentRange = iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1);
double avgRange = 0;

// Calculate average range over last 20 bars
for(int i = 1; i <= 20; i++)
{
avgRange += (iHigh(_Symbol, PERIOD_CURRENT, i) - iLow(_Symbol, PERIOD_CURRENT, i));
}
avgRange /= 20;

return currentRange > (avgRange * m_minPriceActionThreshold);
}

// Validate market structure - SONIC R COMPLIANT (EMA34/89)
bool ValidateMarketStructure()
{
// Get unified manager for Sonic R compliant EMAs
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

int ema34Handle, ema89Handle;
if(manager != NULL) {
ema34Handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
ema89Handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 89, PRICE_CLOSE);
} else {
// Fallback to direct iMA calls with Sonic R periods
ema34Handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
Print("?? [SMC VALIDATOR] Using fallback iMA call - unified manager not available");
}

// ?? CRITICAL FIX: Validate handles tru?c khi s? d?ng
if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE) {
Print("? [SMC VALIDATOR] Failed to create EMA handles");
Print("EMA34: ", (ema34Handle != INVALID_HANDLE ? "?" : "?"));
Print("EMA89: ", (ema89Handle != INVALID_HANDLE ? "?" : "?"));
return false; // Return false khi không th? t?o handles
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

// Check if price is above/below EMAs consistently (Sonic R: 34/89)
bool structureValid = false;
if(close > ema34Value && ema34Value > ema89Value)
structureValid = true;
else if(close < ema34Value && ema34Value < ema89Value)
structureValid = true;

return structureValid;
}

// Get volume score
double GetVolumeScore()
{
double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 1);
double avgVolume = 0;

for(int i = 1; i <= 20; i++)
{
avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 20;

return MathMin(currentVolume / avgVolume, 3.0) / 3.0;
}

// Get price action score
double GetPriceActionScore()
{
double currentRange = iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1);
double avgRange = 0;

for(int i = 1; i <= 20; i++)
{
avgRange += (iHigh(_Symbol, PERIOD_CURRENT, i) - iLow(_Symbol, PERIOD_CURRENT, i));
}
avgRange /= 20;

return MathMin(currentRange / avgRange, 2.0) / 2.0;
}

// Get structure score - SONIC R COMPLIANT (EMA34/89)
double GetStructureScore()
{
// Get unified manager for Sonic R compliant EMAs
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

int ema34Handle, ema89Handle;
if(manager != NULL) {
ema34Handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
ema89Handle = manager.GetOptimizedEMAHandle(_Symbol, PERIOD_CURRENT, 89, PRICE_CLOSE);
} else {
// Fallback to direct iMA calls with Sonic R periods
ema34Handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
Print("?? [SMC VALIDATOR] Using fallback iMA call in GetStructureScore - unified manager not available");
}

// ?? CRITICAL FIX: Validate handles tru?c khi s? d?ng
if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE) {
Print("? [SMC VALIDATOR] Failed to create EMA handles in GetStructureScore");
Print("EMA34: ", (ema34Handle != INVALID_HANDLE ? "?" : "?"));
Print("EMA89: ", (ema89Handle != INVALID_HANDLE ? "?" : "?"));
return 0.0; // Return 0.0 khi không th? t?o handles
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

// Sonic R EMA alignment check (34 above 89 for bullish, below for bearish)
if(close > ema34Value && ema34Value > ema89Value)
return 1.0;
else if(close < ema34Value && ema34Value < ema89Value)
return 1.0;
else
return 0.5;
}
}; 

#endif // SMC_SIGNALVALIDATOR_MQH



