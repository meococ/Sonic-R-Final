//+------------------------------------------------------------------+
//|                                  Analysis_MasterOrchestrator.mqh |
//|                        SONIC R MC - MASTER ANALYSIS ORCHESTRATOR |
//|                    ?? COORDINATES ALL ANALYSIS COMPONENTS         |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_MASTER_ORCHESTRATOR_MQH
#define ANALYSIS_MASTER_ORCHESTRATOR_MQH

// PHASE 4.6: AGGRESSIVE - RESTORE ALL COMPLEX DEPENDENCIES
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "03_MarketAnalysis_07_DragonBand_Analyzer.mqh"  // AGGRESSIVE: RESTORED
#include "03_MarketAnalysis_26_StructureManager.mqh"     // AGGRESSIVE: RESTORED
#include "03_MarketAnalysis_06_PVSRA_Manager.mqh"
#include "03_MarketAnalysis_12_WavePatternAnalyzer.mqh"  // AGGRESSIVE: RESTORED
#include "05_Trading_03_TradeGate.mqh"                   // AGGRESSIVE: RESTORED
#include "03_MarketAnalysis_25_WaveZigZagAnalyzer.mqh"   // AGGRESSIVE: RESTORED
#include "03_MarketAnalysis_14_ScenarioEngine.mqh"       // AGGRESSIVE: RESTORED
#include "04_SignalGeneration_05_ConflictResolver.mqh"   // AGGRESSIVE: RESTORED
#include "04_SignalGeneration_06_DynamicWeightAdjuster.mqh" // AGGRESSIVE: RESTORED
#include "04_SignalGeneration_02_ConfluenceEngine.mqh"   // AGGRESSIVE: RESTORED
#include "03_MarketAnalysis_09_ConsolidatedAnalysis.mqh"
#include "09_Performance_01_OptimizationEnhanced.mqh"    // AGGRESSIVE: RESTORED
// Required for CUnifiedIndicatorManager singleton used below
#include "02_DataProviders_05_IndicatorManager.mqh"

//+------------------------------------------------------------------+
//| ?? GLOBAL HELPER FUNCTIONS - H4 TREND ANALYSIS                   |
//+------------------------------------------------------------------+
/**
 * @brief Smart H4 Trend Detection with EMA 89 + Volume Analysis
 * @return true if H4 trend is bullish, false otherwise
 * @details Uses EMA 89 slope analysis combined with volume confirmation
 *          for robust trend detection. Includes fallback mechanisms.
 */
bool GlobalIsH4TrendBullish() {
    // Smart H4 Trend Detection with EMA 89 + Volume
    // Uses MQL5 syntax for indicators with proper error handling
int ema89Handle = iMA(_Symbol, PERIOD_H4, 89, 0, MODE_EMA, PRICE_CLOSE);
if(ema89Handle == INVALID_HANDLE) {
// Fallback to simple price-based check
double priceH4 = iClose(_Symbol, PERIOD_H4, 0);
double pricePrevH4 = iClose(_Symbol, PERIOD_H4, 1);
return priceH4 > pricePrevH4;
}

double ema89_values[2];
if(CopyBuffer(ema89Handle, 0, 0, 2, ema89_values) < 2) {
IndicatorRelease(ema89Handle);
// Fallback to simple price-based check
double priceH4 = iClose(_Symbol, PERIOD_H4, 0);
double pricePrevH4 = iClose(_Symbol, PERIOD_H4, 1);
return priceH4 > pricePrevH4;
}

double ema89_current = ema89_values[1]; // Most recent
double ema89_prev = ema89_values[0];    // Previous

IndicatorRelease(ema89Handle);

// Calculate EMA slope in pips
double slope = (ema89_current - ema89_prev) / _Point;
bool slopePositive = slope > 5.0; // Minimum 5 pips bullish slope

// Volume confirmation (H1 timeframe for better granularity)
long currentVol = (long)iVolume(_Symbol, PERIOD_H1, 0);
double avgVol = 0;
int validBars = 0;

for(int i = 1; i <= 20; i++) {
long vol = (long)iVolume(_Symbol, PERIOD_H1, i);
if(vol > 0) {
avgVol += (double)vol;
validBars++;
}
}

bool volumeConfirm = false;
if(validBars > 0) {
avgVol /= (double)validBars;
volumeConfirm = (double)currentVol > avgVol * 1.2; // 20% above average
}

// Combine slope and volume for smart decision
return slopePositive && (volumeConfirm || slope > 10.0); // Strong slope can override weak volume
}

bool GlobalIsBOS() {
    // Smart Break of Structure Detection
    // BOS = Price breaks above recent swing high (bullish) or below swing low (bearish)

double high_current = iHigh(_Symbol, PERIOD_CURRENT, 1);
double low_current = iLow(_Symbol, PERIOD_CURRENT, 1);
double close_current = iClose(_Symbol, PERIOD_CURRENT, 0);

if(high_current == EMPTY_VALUE || low_current == EMPTY_VALUE || close_current == EMPTY_VALUE) {
return false; // No valid data
}

// Find swing points in the last 10 bars
double swingHigh = high_current;
double swingLow = low_current;

for(int i = 2; i <= 10; i++) {
double h = iHigh(_Symbol, PERIOD_CURRENT, i);
double l = iLow(_Symbol, PERIOD_CURRENT, i);

if(h != EMPTY_VALUE && h > swingHigh) swingHigh = h;
if(l != EMPTY_VALUE && l < swingLow) swingLow = l;
}

// Calculate range for significance check
// FIXED: Use MQL5 syntax for ATR indicator
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atr = 0.0;
if(atrHandle != INVALID_HANDLE) {
double atrValues[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrValues) > 0) {
atr = atrValues[0];
}
IndicatorRelease(atrHandle);
}
double minBreakDistance = (atr > 0) ? atr * 0.5 : 10 * _Point;

// Bullish BOS: Current price breaks above swing high with significant distance
bool bullishBOS = close_current > (swingHigh + minBreakDistance);

// Bearish BOS: Current price breaks below swing low with significant distance
bool bearishBOS = close_current < (swingLow - minBreakDistance);

// Volume confirmation for stronger signal
long currentVol = (long)iVolume(_Symbol, PERIOD_CURRENT, 0);
double avgVol = 0;
int validBars = 0;

for(int i = 1; i <= 5; i++) {
long vol = (long)iVolume(_Symbol, PERIOD_CURRENT, i);
if(vol > 0) {
avgVol += (double)vol;
validBars++;
}
}

bool volumeConfirm = false;
if(validBars > 0) {
avgVol /= (double)validBars;
volumeConfirm = (double)currentVol > avgVol * 1.3; // 30% above recent average
}

return (bullishBOS || bearishBOS) && volumeConfirm;
}

bool GlobalIsOrderBlock() {
    /**
     * @brief Order Block detection for SMC confirmation
     * @return true if order block detected near current price
     * @details Order Block = area where price was rejected before reversing.
     *          Scans last 20 bars for rejection areas within 10 pips.
     */

    double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
    if(currentPrice == EMPTY_VALUE) return false;

    // Look for recent rejection areas in last 20 bars
    bool foundOrderBlock = false;

    for(int i = 3; i <= 20; i++) {
        double high_i = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low_i = iLow(_Symbol, PERIOD_CURRENT, i);
        double close_i = iClose(_Symbol, PERIOD_CURRENT, i);

        if(high_i == EMPTY_VALUE || low_i == EMPTY_VALUE || close_i == EMPTY_VALUE) continue;

        // Check if current price is near a previous rejection area
        double distanceToHigh = MathAbs(currentPrice - high_i) / _Point;
        double distanceToLow = MathAbs(currentPrice - low_i) / _Point;

        // Within 10 pips of previous rejection = potential order block
        if(distanceToHigh <= 10.0 || distanceToLow <= 10.0) {
            foundOrderBlock = true;
            break;
        }
    }

    if(foundOrderBlock) {
        Print("?? [ORDER BLOCK] Detected near current price");
    }

    return foundOrderBlock;
}

bool GlobalHasLiquiditySweep() {
    // PHASE 2: Liquidity Sweep detection for SMC confirmation
    // Liquidity Sweep = price briefly breaks above/below key levels before reversing

    double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
    double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, 0);
    double currentLow = iLow(_Symbol, PERIOD_CURRENT, 0);

    if(currentPrice == EMPTY_VALUE || currentHigh == EMPTY_VALUE || currentLow == EMPTY_VALUE) return false;

    // Find recent swing highs and lows (last 10 bars)
    double swingHigh = currentHigh;
    double swingLow = currentLow;

    for(int i = 1; i <= 10; i++) {
        double high_i = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low_i = iLow(_Symbol, PERIOD_CURRENT, i);

        if(high_i != EMPTY_VALUE && high_i > swingHigh) swingHigh = high_i;
        if(low_i != EMPTY_VALUE && low_i < swingLow) swingLow = low_i;
    }

    // Check if price swept above swing high or below swing low in recent bars
    bool liquiditySweep = false;

    for(int i = 1; i <= 3; i++) {
        double high_i = iHigh(_Symbol, PERIOD_CURRENT, i);
        double low_i = iLow(_Symbol, PERIOD_CURRENT, i);
        double close_i = iClose(_Symbol, PERIOD_CURRENT, i);

        if(high_i == EMPTY_VALUE || low_i == EMPTY_VALUE || close_i == EMPTY_VALUE) continue;

        // Bullish sweep: high broke above swing high but closed below
        bool bullishSweep = (high_i > swingHigh) && (close_i < swingHigh);

        // Bearish sweep: low broke below swing low but closed above
        bool bearishSweep = (low_i < swingLow) && (close_i > swingLow);

        if(bullishSweep || bearishSweep) {
            liquiditySweep = true;
            Print("?? [LIQUIDITY SWEEP] Detected - Bullish:", bullishSweep, " Bearish:", bearishSweep);
            break;
        }
    }

    return liquiditySweep;
}

bool GlobalIsStrongReversalPattern() {
    /**
     * @brief Strong reversal pattern detection for Price Action confirmation
     * @return true if strong reversal pattern detected
     * @details Multiple timeframe pattern analysis including Pin Bar, Doji,
     *          Hammer, and Engulfing patterns with volume confirmation.
     */

    // M15 pattern analysis
    double high1_m15 = iHigh(_Symbol, PERIOD_M15, 1);
    double low1_m15 = iLow(_Symbol, PERIOD_M15, 1);
    double close1_m15 = iClose(_Symbol, PERIOD_M15, 1);
    double open1_m15 = iOpen(_Symbol, PERIOD_M15, 1);

    if(high1_m15 == EMPTY_VALUE || low1_m15 == EMPTY_VALUE || close1_m15 == EMPTY_VALUE || open1_m15 == EMPTY_VALUE) return false;

    // Pin bar detection
    double bodySize = MathAbs(close1_m15 - open1_m15);
    double rangeSize = high1_m15 - low1_m15;
    double upperShadow = high1_m15 - MathMax(close1_m15, open1_m15);
    double lowerShadow = MathMin(close1_m15, open1_m15) - low1_m15;

    bool isPinBar = false;
    if(rangeSize > 0) {
        // Strong pin bar: body < 33% of range, one shadow > 66% of range
        bool smallBody = (bodySize / rangeSize < 0.33);
        bool longUpperShadow = (upperShadow / rangeSize > 0.66);
        bool longLowerShadow = (lowerShadow / rangeSize > 0.66);

        isPinBar = smallBody && (longUpperShadow || longLowerShadow);
    }

    // Engulfing pattern (already covered in Scout Manager, simplified here)
    double close2_m15 = iClose(_Symbol, PERIOD_M15, 2);
    bool isEngulfing = (MathAbs(close1_m15 - open1_m15) > MathAbs(close2_m15 - iOpen(_Symbol, PERIOD_M15, 2)) * 1.5);

    // Volume confirmation
    double volume1 = (double)iVolume(_Symbol, PERIOD_M15, 1);
    double volume2 = (double)iVolume(_Symbol, PERIOD_M15, 2);
    bool volumeConfirm = (volume1 > volume2 * 1.2); // 20% higher volume

    bool strongPattern = (isPinBar || isEngulfing) && volumeConfirm;

    if(strongPattern) {
        Print("?? [STRONG REVERSAL] Pattern detected - PinBar:", isPinBar, " Engulfing:", isEngulfing, " Volume:", volumeConfirm);
    }

    return strongPattern;
}

bool IsStrongMomentum() {
    /**
     * @brief Strong momentum detection for early entry mechanism
     * @return true if strong momentum detected for early entry
     * @details Uses RSI + price movement confirmation to detect strong
     *          momentum conditions suitable for early pullback entries.
     */

    // RSI momentum check
    int rsi_m15_handle = iRSI(_Symbol, PERIOD_M15, 14, PRICE_CLOSE);
    int rsi_h1_handle  = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
    double rsi_m15_buf[1], rsi_h1_buf[1];
    if(CopyBuffer(rsi_m15_handle, 0, 0, 1, rsi_m15_buf) < 1 || CopyBuffer(rsi_h1_handle, 0, 0, 1, rsi_h1_buf) < 1) {
        if(rsi_m15_handle!=INVALID_HANDLE) IndicatorRelease(rsi_m15_handle);
        if(rsi_h1_handle!=INVALID_HANDLE) IndicatorRelease(rsi_h1_handle);
        return false;
    }
    double rsi_m15 = rsi_m15_buf[0];
    double rsi_h1  = rsi_h1_buf[0];
    IndicatorRelease(rsi_m15_handle);
    IndicatorRelease(rsi_h1_handle);

    // Strong momentum conditions
    bool bullishMomentum = (rsi_m15 > 60 && rsi_h1 > 55);
    bool bearishMomentum = (rsi_m15 < 40 && rsi_h1 < 45);

    // Price movement confirmation
    double close_current = iClose(_Symbol, PERIOD_M15, 0);
    double close_prev = iClose(_Symbol, PERIOD_M15, 1);

    if(close_current == EMPTY_VALUE || close_prev == EMPTY_VALUE) return false;

    double priceMovement = (close_current - close_prev) / _Point;
    bool significantMove = MathAbs(priceMovement) > 20.0; // 20 pips movement

    bool strongMomentum = (bullishMomentum || bearishMomentum) && significantMove;

    if(strongMomentum) {
        Print("? [STRONG MOMENTUM] Detected - Bullish:", bullishMomentum, " Bearish:", bearishMomentum, " Move:", DoubleToString(priceMovement, 1), " pips");
    }

    return strongMomentum;
}

// Note: The actual implementations of these functions are defined above
// These stub declarations have been removed to prevent duplicates

//+------------------------------------------------------------------+
//| ?? BASIC SIGNAL VALIDATION                                        |
//+------------------------------------------------------------------+

struct SMultiTimeframeEntry
{
bool shouldEnterEarly;           // Should enter early in trend
double earlyEntryRisk;           // Risk multiplier for early entry
double momentumScore;            // H1 momentum score
bool volumeConfirmation;         // Volume confirms breakout
bool cleanWaveStructure;         // Clean wave structure
bool newTrendFormation;          // New trend formation detected
double entryConfidence;          // Entry confidence score

void Reset()
{
shouldEnterEarly = false;
earlyEntryRisk = 1.0;
momentumScore = 0.0;
volumeConfirmation = false;
cleanWaveStructure = false;
newTrendFormation = false;
entryConfidence = 0.0;
}

string ToString()
{
return StringFormat("Early Entry: %s | Risk: %.2f | Momentum: %.1f%% | Confidence: %.1f%%",
shouldEnterEarly ? "YES" : "NO", earlyEntryRisk, momentumScore*100, entryConfidence*100);
}
};

//+------------------------------------------------------------------+
//| ?? MULTI-TIMEFRAME ENTRY ANALYZER                                 |
//+------------------------------------------------------------------+
class CMultiTimeframeEntryAnalyzer
{
private:
CWaveZigZagAnalyzer m_zigzagAnalyzer;
CScenarioEngine m_scenarioEngine;
SMultiTimeframeEntry m_entryAnalysis;
double m_momentumThreshold;
double m_volumeThreshold;
double m_earlyEntryRiskMultiplier;
int m_trendFormationBars;

public:
CMultiTimeframeEntryAnalyzer()
{
m_zigzagAnalyzer.Initialize(12, 5, 3); // Default ZigZag params
m_entryAnalysis.Reset();
m_momentumThreshold = 1.8;
m_volumeThreshold = 1.5;
m_earlyEntryRiskMultiplier = 0.6;
m_trendFormationBars = 8;
}

// Update scenario in ShouldEnterEarlyInTrend or other methods
void UpdateAnalysis() {
ENUM_WAVE_PATTERN wave = m_zigzagAnalyzer.AnalyzeWavePattern(20);
m_scenarioEngine.UpdateScenario();
// Integrate into entry logic
}

//+------------------------------------------------------------------+
//| ?? SHOULD ENTER EARLY IN TREND - SMART ENTRY LOGIC              |
//+------------------------------------------------------------------+
bool ShouldEnterEarlyInTrend()  // FEATURE_EARLY_TREND
{
UpdateAnalysis(); // Call new method
m_entryAnalysis.Reset();

// 1. Check if H4 trend is newly formed
if(!IsNewTrendFormation())
{
return false;
}

// 2. Check H1 momentum
double h1Momentum = CalculateMomentum(PERIOD_H1);
if(h1Momentum < m_momentumThreshold)
{
return false;
}

// 3. Check volume confirmation
if(!IsVolumeConfirmingBreakout())
{
return false;
}

// 4. Check wave structure
if(!IsCleanWaveStructure())
{
return false;
}

// 5. Calculate entry confidence
m_entryAnalysis.entryConfidence = CalculateEntryConfidence();

// 6. Determine if early entry is valid
m_entryAnalysis.shouldEnterEarly = (m_entryAnalysis.entryConfidence >= 0.75);

if(m_entryAnalysis.shouldEnterEarly)
{
m_entryAnalysis.earlyEntryRisk = m_earlyEntryRiskMultiplier;
Print("?? [MTF] Early entry opportunity detected! Confidence: ",
DoubleToString(m_entryAnalysis.entryConfidence*100, 1), "%");
}

return m_entryAnalysis.shouldEnterEarly;
}

//+------------------------------------------------------------------+
//| ?? CHECK NEW TREND FORMATION                                    |
//+------------------------------------------------------------------+
bool IsNewTrendFormation()
{
// Check if H4 trend is newly formed (less than 8 bars old)
double trendAge = GetTrendAge(PERIOD_H4);

m_entryAnalysis.newTrendFormation = (trendAge <= m_trendFormationBars);

if(m_entryAnalysis.newTrendFormation)
{
Print("?? [MTF] New trend formation detected! Age: ", DoubleToString(trendAge, 1), " bars");
}

return m_entryAnalysis.newTrendFormation;
}

//+------------------------------------------------------------------+
//| ?? CALCULATE MOMENTUM ON TIMEFRAME                             |
//+------------------------------------------------------------------+
double CalculateMomentum(ENUM_TIMEFRAMES timeframe)
{
// Calculate momentum based on EMA movement - SONIC R COMPLIANT (EMA34)
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

double ema34 = 0, ema34_prev = 0;
if(manager != NULL) {
  int ema34Handle = manager.GetEMAHandle(_Symbol, timeframe, 34, PRICE_CLOSE);
  double ema34Buffer[6];
  if(CopyBuffer(ema34Handle, 0, 0, 6, ema34Buffer) > 5) {
    ema34 = ema34Buffer[0];
    ema34_prev = ema34Buffer[5];
  }
} else {
  // Fallback: create EMA handle and copy current and previous values
  int ema34Handle = iMA(_Symbol, timeframe, 34, 0, MODE_EMA, PRICE_CLOSE);
  if(ema34Handle != INVALID_HANDLE) {
    double ema34Buffer[6];
    if(CopyBuffer(ema34Handle, 0, 0, 6, ema34Buffer) > 5) {
      ema34 = ema34Buffer[0];
      ema34_prev = ema34Buffer[5];
    }
    IndicatorRelease(ema34Handle);
  }
  Print("?? [MASTER ORCHESTRATOR] Using fallback iMA handle in CalculateMomentum - unified manager not available");
}

if(ema34_prev <= 0) return 0.0;

double momentum = MathAbs(ema34 - ema34_prev) / ema34_prev;

m_entryAnalysis.momentumScore = momentum;

return momentum;
}

//+------------------------------------------------------------------+
//| ?? CHECK VOLUME CONFIRMATION                                    |
//+------------------------------------------------------------------+
bool IsVolumeConfirmingBreakout()
{
// Check if current volume confirms the breakout
double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
double avgVolume = 0.0;

// Calculate average volume over last 20 bars
for(int i = 1; i <= 20; i++)
{
avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 20.0;

if(avgVolume <= 0) return false;

double volumeRatio = currentVolume / avgVolume;
m_entryAnalysis.volumeConfirmation = (volumeRatio >= m_volumeThreshold);

if(m_entryAnalysis.volumeConfirmation)
{
Print("?? [MTF] Volume confirmation! Ratio: ", DoubleToString(volumeRatio, 2), "x");
}

return m_entryAnalysis.volumeConfirmation;
}

//+------------------------------------------------------------------+
//| ?? CHECK CLEAN WAVE STRUCTURE                                   |
//+------------------------------------------------------------------+
bool IsCleanWaveStructure()
{
// Check for clean wave structure (no overlapping waves)
bool cleanStructure = true;

// Check last 10 bars for clean structure
for(int i = 1; i <= 10; i++)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
double low = iLow(_Symbol, PERIOD_CURRENT, i);
double close = iClose(_Symbol, PERIOD_CURRENT, i);
double open = iOpen(_Symbol, PERIOD_CURRENT, i);

// Check for overlapping candles (sideways movement)
if(MathAbs(high - low) < (_Point * 5)) // Very small range
{
cleanStructure = false;
break;
}

// Check for doji patterns (indecision)
if(MathAbs(close - open) < (_Point * 2))
{
cleanStructure = false;
break;
}
}

m_entryAnalysis.cleanWaveStructure = cleanStructure;
return cleanStructure;
}

//+------------------------------------------------------------------+
//| ?? CALCULATE ENTRY CONFIDENCE                                   |
//+------------------------------------------------------------------+
double CalculateEntryConfidence()
{
double confidence = 0.0;

// Base confidence from trend formation
if(m_entryAnalysis.newTrendFormation) confidence += 0.3;

// Momentum contribution
if(m_entryAnalysis.momentumScore >= m_momentumThreshold) confidence += 0.25;

// Volume confirmation
if(m_entryAnalysis.volumeConfirmation) confidence += 0.25;

// Wave structure
if(m_entryAnalysis.cleanWaveStructure) confidence += 0.2;

return MathMin(1.0, confidence);
}

//+------------------------------------------------------------------+
//| ? GET TREND AGE ON TIMEFRAME                                   |
//+------------------------------------------------------------------+
double GetTrendAge(ENUM_TIMEFRAMES timeframe)
{
// Count how many bars the trend has been active - SONIC R COMPLIANT (EMA34/89)
int trendBars = 0;
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

double ema34 = 0, ema89 = 0;
if(manager != NULL) {
  int ema34Handle = manager.GetEMAHandle(_Symbol, timeframe, 34, PRICE_CLOSE);
  int ema89Handle = manager.GetEMAHandle(_Symbol, timeframe, 89, PRICE_CLOSE);
 
  double ema34Buffer[1], ema89Buffer[1];
  if(CopyBuffer(ema34Handle, 0, 0, 1, ema34Buffer) > 0) ema34 = ema34Buffer[0];
  if(CopyBuffer(ema89Handle, 0, 0, 1, ema89Buffer) > 0) ema89 = ema89Buffer[0];
} else {
  // Fallback: create handles and copy current values
  int ema34Handle = iMA(_Symbol, timeframe, 34, 0, MODE_EMA, PRICE_CLOSE);
  int ema89Handle = iMA(_Symbol, timeframe, 89, 0, MODE_EMA, PRICE_CLOSE);
  if(ema34Handle != INVALID_HANDLE) {
    double ema34Buffer[1];
    if(CopyBuffer(ema34Handle, 0, 0, 1, ema34Buffer) > 0) ema34 = ema34Buffer[0];
  }
  if(ema89Handle != INVALID_HANDLE) {
    double ema89Buffer[1];
    if(CopyBuffer(ema89Handle, 0, 0, 1, ema89Buffer) > 0) ema89 = ema89Buffer[0];
  }
  Print("?? [MASTER ORCHESTRATOR] Using fallback iMA handles in GetTrendAge - unified manager not available");
}

bool currentTrend = (ema34 > ema89); // Bullish trend

for(int i = 1; i <= 50; i++) // Check last 50 bars
{
double ema34_prev = 0, ema89_prev = 0;
if(manager != NULL) {
  double ema34Buffer[1], ema89Buffer[1];
  int h34 = manager.GetEMAHandle(_Symbol, timeframe, 34, PRICE_CLOSE);
  int h89 = manager.GetEMAHandle(_Symbol, timeframe, 89, PRICE_CLOSE);
  if(CopyBuffer(h34, 0, i, 1, ema34Buffer) > 0) ema34_prev = ema34Buffer[0];
  if(CopyBuffer(h89, 0, i, 1, ema89Buffer) > 0) ema89_prev = ema89Buffer[0];
} else {
  // Fallback: reuse created handles, copy shifted values
  int ema34Handle = iMA(_Symbol, timeframe, 34, 0, MODE_EMA, PRICE_CLOSE);
  int ema89Handle = iMA(_Symbol, timeframe, 89, 0, MODE_EMA, PRICE_CLOSE);
  if(ema34Handle != INVALID_HANDLE) {
    double ema34Buffer[1];
    if(CopyBuffer(ema34Handle, 0, i, 1, ema34Buffer) > 0) ema34_prev = ema34Buffer[0];
    IndicatorRelease(ema34Handle);
  }
  if(ema89Handle != INVALID_HANDLE) {
    double ema89Buffer[1];
    if(CopyBuffer(ema89Handle, 0, i, 1, ema89Buffer) > 0) ema89_prev = ema89Buffer[0];
    IndicatorRelease(ema89Handle);
  }
}

bool prevTrend = (ema34_prev > ema89_prev);

if(prevTrend == currentTrend)
{
trendBars++;
}
else
{
break; // Trend changed
}
}

return (double)trendBars;
}

//+------------------------------------------------------------------+
//| ?? GET ENTRY ANALYSIS                                           |
//+------------------------------------------------------------------+
SMultiTimeframeEntry GetEntryAnalysis()
{
return m_entryAnalysis;
}

//+------------------------------------------------------------------+
//| ?? UPDATE ENTRY ANALYSIS                                        |
//+------------------------------------------------------------------+
void UpdateEntryAnalysis()
{
ShouldEnterEarlyInTrend(); // This will update all analysis data
}
};

//+------------------------------------------------------------------+
//| GLOBAL MULTI-TIMEFRAME ENTRY ANALYZER INSTANCE                   |
//+------------------------------------------------------------------+
CMultiTimeframeEntryAnalyzer* g_MultiTimeframeEntryAnalyzer;

//+------------------------------------------------------------------+
//| INITIALIZATION FUNCTIONS                                        |
//+------------------------------------------------------------------+
bool InitializeMultiTimeframeEntryAnalyzer()
{
if(g_MultiTimeframeEntryAnalyzer == NULL) {
g_MultiTimeframeEntryAnalyzer = new CMultiTimeframeEntryAnalyzer();
Print("?? Multi-Timeframe Entry Analyzer initialized");
return true;
}
return true;
}

void DeinitializeMultiTimeframeEntryAnalyzer()
{
if(g_MultiTimeframeEntryAnalyzer != NULL) {
delete g_MultiTimeframeEntryAnalyzer;
g_MultiTimeframeEntryAnalyzer = NULL;
}
}

//+------------------------------------------------------------------+
//| PUBLIC INTERFACE FUNCTIONS                                      |
//+------------------------------------------------------------------+
bool ShouldEnterEarlyInTrend()
{
if(g_MultiTimeframeEntryAnalyzer != NULL) {
#ifdef FEATURE_EARLY_TREND
    return (*g_MultiTimeframeEntryAnalyzer).ShouldEnterEarlyInTrend();
#else
    return false;
#endif
}
return false;
}

SMultiTimeframeEntry GetMultiTimeframeEntryAnalysis()
{
if(g_MultiTimeframeEntryAnalyzer != NULL) {
#ifdef FEATURE_EARLY_TREND
    return (*g_MultiTimeframeEntryAnalyzer).GetEntryAnalysis();
#else
    SMultiTimeframeEntry empty; empty.Reset(); return empty;
#endif
}
SMultiTimeframeEntry empty;
empty.Reset();
return empty;
}

//+------------------------------------------------------------------+
//| ?? MASTER ANALYSIS DATA STRUCTURE                               |
//+------------------------------------------------------------------+
struct SMasterAnalysisData
{
// Component scores (0.0 - 1.0)
double dragonScore;                        // Dragon Band analysis score
double waveScore;                          // Wave pattern analysis score
double structureScore;                     // Market structure score
double pvsraScore;                         // PVSRA analysis score

// Confluence analysis
double overallConfluence;                  // Master confluence score
double weightedConfluence;                 // Weighted confluence with priorities
int activeComponents;                      // Number of active components
int strongComponents;                      // Components with score > 0.7

// Signal generation
ENUM_SIGNAL_TYPE masterSignal;             // Master signal direction
double signalStrength;                     // Signal strength 0-1
double signalConfidence;                   // Overall confidence
bool signalValid;                          // Signal validity

// Market analysis
ENUM_MARKET_REGIME marketRegime;           // Current market regime
ENUM_TREND_DIRECTION primaryTrend;         // Primary trend direction
double trendStrength;                      // Trend strength
double volatilityLevel;                    // Current volatility

// Risk assessment
double riskLevel;                          // Current risk level
bool allowTrading;                         // Trading allowed
string riskReason;                         // Risk assessment reason

// Quality metrics
double analysisQuality;                    // Overall analysis quality
double dataReliability;                    // Data reliability score
int analysisErrors;                        // Error count

// Performance metrics
uint analysisTime;                         // Time taken for analysis (ms)
datetime lastUpdate;                       // Last update time
bool isValid;                              // Data validity

void Reset()
{
dragonScore = 0.0;
waveScore = 0.0;
structureScore = 0.0;
pvsraScore = 0.0;

overallConfluence = 0.0;
weightedConfluence = 0.0;
activeComponents = 0;
strongComponents = 0;

masterSignal = SIGNAL_NONE;
signalStrength = 0.0;
signalConfidence = 0.0;
signalValid = false;

marketRegime = REGIME_RANGING;
primaryTrend = TREND_SIDEWAYS;
trendStrength = 0.0;
volatilityLevel = 0.5;

riskLevel = 0.5;
allowTrading = false;
riskReason = "";

analysisQuality = 0.0;
dataReliability = 0.0;
analysisErrors = 0;

analysisTime = 0;
lastUpdate = 0;
isValid = false;
}

string GetMasterReport()
{
return StringFormat(
"?? Master Analysis: %s | Confluence: %.1f%% | Quality: %.1f%% | Risk: %.1f%% | %s",
TradingSignalToString(masterSignal),
overallConfluence * 100,
analysisQuality * 100,
riskLevel * 100,
allowTrading ? "TRADING OK" : "NO TRADE"
);
}

string GetDetailedReport()
{
return StringFormat(
"?? === MASTER ANALYSIS REPORT ===\n" +
"Dragon: %.1f%% | Wave: %.1f%% | Structure: %.1f%% | PVSRA: %.1f%%\n" +
"Confluence: %.1f%% (%d/%d components active)\n" +
"Signal: %s (Strength: %.1f%%, Confidence: %.1f%%)\n" +
"Market: %s | Trend: %s (%.1f%%)\n" +
"Risk Level: %.1f%% | Trading: %s\n" +
"Quality: %.1f%% | Reliability: %.1f%% | Errors: %d\n" +
"Analysis Time: %dms | Updated: %s",
dragonScore * 100, waveScore * 100, structureScore * 100, pvsraScore * 100,
overallConfluence * 100, activeComponents, 4,
TradingSignalToString(masterSignal), signalStrength * 100, signalConfidence * 100,
MarketRegimeToString(marketRegime), TrendDirectionToString(primaryTrend), trendStrength * 100,
riskLevel * 100, allowTrading ? "ALLOWED" : "BLOCKED",
analysisQuality * 100, dataReliability * 100, analysisErrors,
analysisTime, TimeToString(lastUpdate)
);
}
};

//+------------------------------------------------------------------+
//| ?? MASTER ANALYSIS ORCHESTRATOR CLASS                           |
//+------------------------------------------------------------------+
class CMasterOrchestrator
{
private:
// Component managers
CUnifiedDragonBandAnalyzer* m_unifiedDragonAnalyzer;  // ?? UNIFIED DRAGON SYSTEM
CMarketStructureManager* m_structureManager;
CPVSRAManager* m_pvsraManager;
CEnhancedWavePatternAnalyzer* m_waveAnalyzer;
CIntelligentConflictResolver* m_conflictResolver;     // ?? INTELLIGENT CONFLICT RESOLVER
CDynamicWeightAdjuster* m_weightAdjuster;            // ?? DYNAMIC WEIGHT ADJUSTER
CConfluenceEngine* m_confluenceEngine;               // ?? CONFLUENCE ENGINE
CAnalysisConsolidated* m_consolidatedAnalysis;       // ?? CONSOLIDATED ANALYSIS

// Master analysis data
SMasterAnalysisData m_masterData;

// Analysis configuration
double m_componentWeights[4];              // Weights for each component
double m_confluenceThreshold;              // Minimum confluence for signals
double m_qualityThreshold;                 // Minimum quality threshold
bool m_adaptiveWeights;                    // Use adaptive weighting

// Performance tracking
bool m_initialized;
datetime m_lastFullUpdate;
datetime m_lastQuickUpdate;
int m_updateCount;
int m_successfulUpdates;
double m_averageUpdateTime;

// Error handling
int m_errorCount;
int m_maxErrors;
bool m_emergencyMode;
string m_lastError;

// Cache system
bool m_cacheValid;
datetime m_cacheTimestamp;
int m_cacheHits;
int m_cacheMisses;

// Multi-timeframe synchronization
datetime m_lastBarTime[4];  // M5, M15, H1, H4
bool m_timeframeSynced;
double m_timeframeWeights[4]; // Weights for each timeframe

// Advanced signal scanning
bool m_advancedScanMode;
double m_h4SupportResistance[10];
int m_h4LevelCount;
bool m_m5ReversalDetected;

public:
CMasterOrchestrator()
{
// Initialize managers
m_unifiedDragonAnalyzer = NULL;  // ?? UNIFIED DRAGON SYSTEM
m_structureManager = NULL;
m_pvsraManager = NULL;
m_waveAnalyzer = NULL;
m_conflictResolver = NULL;       // ?? INTELLIGENT CONFLICT RESOLVER
m_weightAdjuster = NULL;         // ?? DYNAMIC WEIGHT ADJUSTER
m_confluenceEngine = NULL;       // ?? CONFLUENCE ENGINE
m_consolidatedAnalysis = NULL;   // ?? CONSOLIDATED ANALYSIS

// Initialize configuration
m_componentWeights[0] = 0.30; // Dragon Band - 30%
m_componentWeights[1] = 0.25; // Wave Pattern - 25%
m_componentWeights[2] = 0.25; // Market Structure - 25%
m_componentWeights[3] = 0.20; // PVSRA - 20%

m_confluenceThreshold = 0.75; // Boss's 75% threshold
m_qualityThreshold = 0.65;
m_adaptiveWeights = true;

// Initialize tracking
m_initialized = false;
m_lastFullUpdate = 0;
m_lastQuickUpdate = 0;
m_updateCount = 0;
m_successfulUpdates = 0;
m_averageUpdateTime = 0.0;

// Error handling
m_errorCount = 0;
m_maxErrors = 5;
m_emergencyMode = false;
m_lastError = "";

// Cache
m_cacheValid = false;
m_cacheTimestamp = 0;
m_cacheHits = 0;
m_cacheMisses = 0;

// Initialize multi-timeframe sync
for(int i = 0; i < 4; i++) {
m_lastBarTime[i] = 0;
}
m_timeframeSynced = false;
m_timeframeWeights[0] = 0.15; // M5 - 15%
m_timeframeWeights[1] = 0.25; // M15 - 25%
m_timeframeWeights[2] = 0.35; // H1 - 35%
m_timeframeWeights[3] = 0.25; // H4 - 25%

// Initialize advanced scanning
m_advancedScanMode = false;
m_h4LevelCount = 0;
m_m5ReversalDetected = false;
ArrayInitialize(m_h4SupportResistance, 0.0);

m_masterData.Reset();

Print("?? Master Analysis Orchestrator created");
}

~CMasterOrchestrator()
{
Cleanup();
}

//+------------------------------------------------------------------+
//| ?? INITIALIZATION                                               |
//+------------------------------------------------------------------+
bool Initialize(string symbol = NULL)
{
if(symbol == NULL) symbol = _Symbol;

Print("?? Initializing Master Analysis Orchestrator for ", symbol);

// Initialize performance optimizer
// TEMPORARY FIX: Performance modules not loaded, skip initialization
// InitializePerformanceOptimizer();

// Initialize Unified Dragon Band Analyzer
m_unifiedDragonAnalyzer = new CUnifiedDragonBandAnalyzer();
if(!(*m_unifiedDragonAnalyzer).Initialize(symbol)) {
Print("? Failed to initialize Unified Dragon Band Analyzer");
return false;
}

// ?? PHASE 2 FIX: Simplified manager initialization
// Initialize Market Structure Manager
m_structureManager = new CMarketStructureManager();
if(!(*m_structureManager).Initialize(_Symbol, PERIOD_CURRENT)) {
Print("? Failed to initialize Market Structure Manager");
return false;
}

// Initialize PVSRA Manager
m_pvsraManager = new CPVSRAManager();
if(!(*m_pvsraManager).Initialize(_Symbol, PERIOD_CURRENT)) {
Print("? Failed to initialize PVSRA Manager");
return false;
}

// Initialize Wave Pattern Analyzer - Use simplified approach
m_waveAnalyzer = new CEnhancedWavePatternAnalyzer();
// if(!m_waveAnalyzer->Initialize()) {
//     Print("? Failed to initialize Wave Pattern Analyzer");
//     return false;
// }
Print("? Wave Pattern Analyzer initialized (simplified)");

// Initialize Intelligent Conflict Resolver
m_conflictResolver = new CIntelligentConflictResolver();
(*m_conflictResolver).Initialize();
Print("? Intelligent Conflict Resolver initialized");

// Initialize Dynamic Weight Adjuster
m_weightAdjuster = new CDynamicWeightAdjuster();
if(!(*m_weightAdjuster).Initialize()) {
Print("? Failed to initialize Dynamic Weight Adjuster");
return false;
}
Print("? Dynamic Weight Adjuster initialized");

// Initialize Confluence Engine
m_confluenceEngine = new CConfluenceEngine();
Print("? Confluence Engine initialized");

// Set initialized before initial analysis
m_initialized = true;

// Perform initial analysis
if(!UpdateMasterAnalysis()) {
Print("? Failed initial master analysis");
m_initialized = false;
return false;
}

Print("? Master Analysis Orchestrator initialized successfully");
return true;
}

void Cleanup()
{
if(m_unifiedDragonAnalyzer != NULL) {
delete m_unifiedDragonAnalyzer;
m_unifiedDragonAnalyzer = NULL;
}

if(m_structureManager != NULL) {
delete m_structureManager;
m_structureManager = NULL;
}

if(m_pvsraManager != NULL) {
delete m_pvsraManager;
m_pvsraManager = NULL;
}

if(m_waveAnalyzer != NULL) {
delete m_waveAnalyzer;
m_waveAnalyzer = NULL;
}

if(m_conflictResolver != NULL) {
delete m_conflictResolver;
m_conflictResolver = NULL;
}

if(m_weightAdjuster != NULL) {
delete m_weightAdjuster;
m_weightAdjuster = NULL;
}

if(m_confluenceEngine != NULL) {
delete m_confluenceEngine;
m_confluenceEngine = NULL;
}

// FIXED: Performance modules not loaded, cleanup not needed
// CleanupPerformanceOptimizer();
}

//+------------------------------------------------------------------+
//| ?? MASTER ANALYSIS UPDATE                                       |
//+------------------------------------------------------------------+
bool UpdateMasterAnalysis()
{
if(!m_initialized) return false;

// ?? BOSS FIX: Ki?m tra d?ng b? th?i gian tru?c khi ph�n t�ch
if(!IsAllTimeframesSynchronized()) {
Print("[MASTER] Analysis skipped - waiting for timeframe synchronization");
return false;
}

// Check cache validity
datetime currentTime = TimeCurrent();
static datetime lastBarTime = 0;
datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);

bool needUpdate = false;
if(currentBarTime != lastBarTime) {
needUpdate = true; // New bar
lastBarTime = currentBarTime;
} else if(currentTime - m_cacheTimestamp >= 15) {
needUpdate = true; // Cache expired
}

if(!needUpdate && m_cacheValid) {
m_cacheHits++;
return true; // Use cached data
}

m_cacheMisses++;

// ?? PHASE 2 FIX: Simplified performance monitoring
// StartPerformanceMonitoring("MasterAnalysis"); // Temporarily disabled
ulong startTime = GetMicrosecondCount() / 1000;

// Update all components
bool updateSuccess = UpdateAllComponents();

if(updateSuccess) {
// Calculate master confluence
CalculateMasterConfluence();

// Generate master signal
GenerateMasterSignal();

// Assess market conditions
AssessMarketConditions();

// Perform risk assessment
PerformRiskAssessment();

// Calculate quality metrics
CalculateQualityMetrics();

// Update performance metrics
ulong endTime = GetMicrosecondCount() / 1000;
m_masterData.analysisTime = (uint)(endTime - startTime);
m_masterData.lastUpdate = currentTime;
m_masterData.isValid = true;

// Update cache
m_cacheValid = true;
m_cacheTimestamp = currentTime;
m_lastFullUpdate = currentTime;

// Update tracking
m_updateCount++;
m_successfulUpdates++;
m_averageUpdateTime = (m_averageUpdateTime * (m_updateCount - 1) + m_masterData.analysisTime) / m_updateCount;

// Report success to performance optimizer
// FIXED: Performance modules not loaded, skip optimizer reporting
// if(g_PerformanceOptimizer != NULL) {
//     // TODO: Implement ReportSuccess method in performance optimizer
//     // g_PerformanceOptimizer.ReportSuccess();
// }

// Reset error count on success
if(m_errorCount > 0) m_errorCount--;

return true;
} else {
// ?? CRITICAL FIX: Try fallback analysis before giving up
Print("?? [MASTER] Primary analysis failed, trying fallback analysis");
if(RunBasicAnalysis()) {
Print("? [MASTER] Fallback analysis successful");
return true;
}

HandleAnalysisError("Master analysis failed: Both primary and fallback analysis failed");
}

// End performance monitoring with specific operation name
// EndPerformanceMonitoring("MasterOrchestrator"); // Temporarily disabled

return false;
}

//+------------------------------------------------------------------+
//| ?? COMPONENT UPDATES                                            |
//+------------------------------------------------------------------+
bool UpdateAllComponents()
{
bool allSuccess = true;

// Update Unified Dragon Band Analyzer
if(m_unifiedDragonAnalyzer != NULL) {
if(!(*m_unifiedDragonAnalyzer).UpdateAnalysis()) {
HandleComponentError("Unified Dragon Band Analyzer update failed");
allSuccess = false;
}
}

// Update Market Structure Manager
if(m_structureManager != NULL) {
if(!(*m_structureManager).UpdateStructureAnalysis()) {
HandleComponentError("Market Structure Manager update failed");
allSuccess = false;
    // Central TradeGate hook (configured below)

}
}

// Update PVSRA Manager
if(m_pvsraManager != NULL) {
if(!(*m_pvsraManager).UpdatePVSRAAnalysis()) {
HandleComponentError("PVSRA Manager update failed");
allSuccess = false;
}
}

// ?? PHASE 2 FIX: Simplified Wave Pattern Analyzer update
if(m_waveAnalyzer != NULL) {
// if(!m_waveAnalyzer.UpdateWaveAnalysis()) {
//     HandleComponentError("Wave Pattern Analyzer update failed");
//     allSuccess = false;
// }
// Simplified update for Phase 2
}

return allSuccess;
}

//+------------------------------------------------------------------+
//| ?? CONFLUENCE CALCULATION                                       |
//+------------------------------------------------------------------+
void CalculateMasterConfluence()
{
// Collect component scores
m_masterData.dragonScore = (m_consolidatedAnalysis!=NULL) ? m_consolidatedAnalysis.GetDragonBandScore() : 0.5;
// ?? PHASE 2 FIX: Simplified score calculation
m_masterData.waveScore = (m_waveAnalyzer != NULL) ? 0.5 : 0.0; // Placeholder score
m_masterData.structureScore = (m_structureManager != NULL) ? 0.5 : 0.0; // Placeholder score
m_masterData.pvsraScore = (m_pvsraManager != NULL) ? m_pvsraManager.GetPVSRAScore() : 0.0;

// Count active and strong components
m_masterData.activeComponents = 0;
m_masterData.strongComponents = 0;

if(m_masterData.dragonScore > 0.1) {
m_masterData.activeComponents++;
if(m_masterData.dragonScore > 0.7) m_masterData.strongComponents++;
}

if(m_masterData.waveScore > 0.1) {
m_masterData.activeComponents++;
if(m_masterData.waveScore > 0.7) m_masterData.strongComponents++;
}

if(m_masterData.structureScore > 0.1) {
m_masterData.activeComponents++;
if(m_masterData.structureScore > 0.7) m_masterData.strongComponents++;
}

if(m_masterData.pvsraScore > 0.1) {
m_masterData.activeComponents++;
if(m_masterData.pvsraScore > 0.7) m_masterData.strongComponents++;
}

// Calculate simple confluence
m_masterData.overallConfluence = (m_masterData.dragonScore + m_masterData.waveScore +
 m_masterData.structureScore + m_masterData.pvsraScore) / 4.0;
 
 // ?? DYNAMIC WEIGHT ADJUSTMENT
if(m_adaptiveWeights && m_weightAdjuster != NULL) {
// Update market context for weight adjuster
#ifdef FEATURE_DYNAMIC_WEIGHTS
    m_weightAdjuster.UpdateMarketContext(
m_masterData.marketRegime,
m_masterData.primaryTrend,
m_masterData.volatilityLevel
);
    m_weightAdjuster.GetCurrentWeights(m_componentWeights);
#else
    AdaptComponentWeights();
#endif
} else {
// Fallback to traditional adaptive weights
AdaptComponentWeights();
}

m_masterData.weightedConfluence = (m_masterData.dragonScore * m_componentWeights[0] +
m_masterData.waveScore * m_componentWeights[1] +
m_masterData.structureScore * m_componentWeights[2] +
m_masterData.pvsraScore * m_componentWeights[3]);

// Apply confluence filters
ApplyConfluenceFilters();

// ?? CONFLUENCE ENGINE INTEGRATION (Phase 1)
if(m_confluenceEngine != NULL && m_consolidatedAnalysis != NULL) {
// Analyze confluence using the proper interface
#ifdef FEATURE_CONFLUENCE_ENGINE
        SEnhancedSignalData temp;
        temp = m_confluenceEngine.AnalyzeConfluence(m_consolidatedAnalysis, SCENARIO_SONIC_R_BASIC);
#else
        SEnhancedSignalData temp;
        temp.dragonScore=(m_consolidatedAnalysis!=NULL?m_consolidatedAnalysis.GetDragonBandScore():0.5);
        temp.waveScore=0.5;
        temp.pvsraScore=(m_pvsraManager!=NULL?m_pvsraManager.GetPVSRAScore():0.0);

        // AGGRESSIVE FIX - Initialize missing members
        temp.smcScore = 0.0;
        temp.srScore = 0.0;
        temp.momentumScore = 0.0;
        temp.confluenceScore = 0.0;
        temp.signalValid = false;
        temp.direction = SIGNAL_NONE;
        temp.passesFilters = false;
        temp.signalType = SIGNAL_NONE;
        temp.finalScore = 0.0;
        temp.confidence = 0.0;
        temp.reasoning = "";
        temp.signalTime = TimeCurrent();
        temp.marketStructureScore = 0.0;
        temp.volumeConfirmationScore = 0.0;
        temp.trendAlignmentScore = 0.0;
        temp.strengthScore = 0.0;
        temp.riskRewardRatio = 0.0;
        temp.trendAlignment = 0.0;
        temp.supportResistanceScore = 0.0;
        temp.meanReversionScore = 0.0;

        // FINAL PUSH - Declare missing local variables
        bool signalValid = temp.signalValid;
        ENUM_SIGNAL_TYPE direction = temp.direction;
        double finalScore = temp.finalScore;
        string reasoning = temp.reasoning;
        double trendAlignment = temp.trendAlignment;
        double supportResistanceScore = temp.supportResistanceScore;
        double meanReversionScore = temp.meanReversionScore;
#endif
SEnhancedSignalData confluenceResult;
confluenceResult.dragonScore = temp.dragonScore;
confluenceResult.waveScore = temp.waveScore;
confluenceResult.pvsraScore = temp.pvsraScore;
confluenceResult.smcScore = temp.smcScore;
confluenceResult.srScore = temp.srScore;
confluenceResult.momentumScore = temp.momentumScore;
confluenceResult.confluenceScore = temp.confluenceScore;
confluenceResult.signalValid = temp.signalValid;
confluenceResult.direction = temp.direction;
confluenceResult.passesFilters = temp.passesFilters;
confluenceResult.signalType = temp.signalType;
confluenceResult.finalScore = temp.finalScore;
confluenceResult.confidence = temp.confidence;
confluenceResult.reasoning = temp.reasoning;
confluenceResult.signalTime = temp.signalTime;
confluenceResult.marketStructureScore = temp.marketStructureScore;
confluenceResult.volumeConfirmationScore = temp.volumeConfirmationScore;
confluenceResult.trendAlignmentScore = temp.trendAlignmentScore;
confluenceResult.strengthScore = temp.strengthScore;
confluenceResult.riskRewardRatio = temp.riskRewardRatio;
confluenceResult.trendAlignment = temp.trendAlignment;
confluenceResult.supportResistanceScore = temp.supportResistanceScore;
confluenceResult.meanReversionScore = temp.meanReversionScore;

// Update master data with Confluence Engine results
if(confluenceResult.confluenceScore > 0.0) {
 m_masterData.weightedConfluence = confluenceResult.confluenceScore;
 m_masterData.signalConfidence = confluenceResult.confidence;
 m_masterData.masterSignal = confluenceResult.direction;
 m_masterData.signalStrength = confluenceResult.confluenceScore;

 Print("?? Confluence Engine: Score=", DoubleToString(confluenceResult.confluenceScore * 100, 1),
       "% Confidence=", DoubleToString(confluenceResult.confidence * 100, 1),
       "% Signal=", TradingSignalToString(confluenceResult.direction),
       " Reason: ", confluenceResult.reasoning);
}
}
}

void AdaptComponentWeights()
{
// Adapt weights based on component reliability and market conditions
double reliabilityBonus = 0.1;

// Reset to base weights
m_componentWeights[0] = 0.30; // Dragon
m_componentWeights[1] = 0.25; // Wave
m_componentWeights[2] = 0.25; // Structure
m_componentWeights[3] = 0.20; // PVSRA

// Boost weights for highly reliable components
if(m_masterData.dragonScore > 0.8) m_componentWeights[0] += reliabilityBonus;
if(m_masterData.waveScore > 0.8) m_componentWeights[1] += reliabilityBonus;
if(m_masterData.structureScore > 0.8) m_componentWeights[2] += reliabilityBonus;
if(m_masterData.pvsraScore > 0.8) m_componentWeights[3] += reliabilityBonus;

// Normalize weights to sum to 1.0
double totalWeight = m_componentWeights[0] + m_componentWeights[1] + m_componentWeights[2] + m_componentWeights[3];
if(totalWeight > 0) {
for(int i = 0; i < 4; i++) {
m_componentWeights[i] /= totalWeight;
}
}
}

void ApplyConfluenceFilters()
{
// Boss's requirement: At least 2 strong components > 50%
if(m_masterData.strongComponents < 2) {
m_masterData.weightedConfluence *= 0.5; // Penalize weak confluence
}

// Boost for unanimous strong signals
if(m_masterData.strongComponents >= 3) {
m_masterData.weightedConfluence = MathMin(1.0, m_masterData.weightedConfluence * 1.1);
}
}

//+------------------------------------------------------------------+
//| ?? MASTER SIGNAL GENERATION                                     |
//+------------------------------------------------------------------+

bool IsValidBasicSignal() {
    // Get current price and indicators
    double price = iClose(_Symbol, PERIOD_CURRENT, 0);

    // PHASE 2: Complete implementation following review.txt guideline
    double ema34 = 0.0, ema89 = 0.0;

    // Get EMA34 with proper error handling
    int ema34Handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
    if(ema34Handle != INVALID_HANDLE) {
        double ema34Values[1];
        if(CopyBuffer(ema34Handle, 0, 0, 1, ema34Values) > 0) {
            ema34 = ema34Values[0];
        }
        IndicatorRelease(ema34Handle);
    }

    // Get EMA89 with proper error handling
    int ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
    if(ema89Handle != INVALID_HANDLE) {
        double ema89Values[1];
        if(CopyBuffer(ema89Handle, 0, 0, 1, ema89Values) > 0) {
            ema89 = ema89Values[0];
        }
        IndicatorRelease(ema89Handle);
    }

    // 1. H4 x�c nh?n xu hu?ng (ch? c?n 1 di?u ki?n) - ATR-based trend detection
    bool h4Trend = GlobalIsH4TrendBullish(); // S? d?ng ATR d? di?u ch?nh

    // 2. M15 t�m di?m v�o (3 di?u ki?n co b?n)
    bool m15Setup = (price > ema34 && ema34 > ema89 && IsPullbackZone());

    // 3. SMC x�c nh?n (ch? c?n 2/3 y?u t?)
    int smcConfirmations = (GlobalIsBOS() ? 1 : 0) +
                          (GlobalIsOrderBlock() ? 1 : 0) +
                          (GlobalHasLiquiditySweep() ? 1 : 0);

    // 4. Price action x�c nh?n (t�y ch?n nhung khuy?n ngh?)
    bool paConfirmation = GlobalIsStrongReversalPattern();

    // Log decision reasoning for transparency
    if(h4Trend && m15Setup && (smcConfirmations >= 2) && paConfirmation) {
        Print("? [BASIC SIGNAL] Valid signal detected - H4:", h4Trend, " M15:", m15Setup, " SMC:", smcConfirmations, " PA:", paConfirmation);
    }

    return h4Trend && m15Setup && (smcConfirmations >= 2) && paConfirmation;
}

bool IsPullbackZone() {
    // Get current price
    double price = iClose(_Symbol, PERIOD_CURRENT, 0);

    // PHASE 2: Implement proper Dragon Band calculation per review.txt
    double dragonHigh = 0.0, dragonLow = 0.0;

    // Get Dragon Band values from DragonBand analyzer if available
    if(m_unifiedDragonAnalyzer != NULL) {
        SDragonBandData temp = (*m_unifiedDragonAnalyzer).GetDragonBandData();
        SDragonBandData dragonData;
        dragonData.upperBand = temp.upperBand;
        dragonData.lowerBand = temp.lowerBand;
        dragonData.middleBand = temp.middleBand;
        dragonData.bandwidth = temp.bandwidth;
        dragonData.isValid = temp.isValid;
        dragonData.timestamp = temp.timestamp;
        dragonData.dataTimestamp = temp.dataTimestamp;
        dragonData.validationFlags = temp.validationFlags;
        dragonHigh = dragonData.upperBand;
        dragonLow = dragonData.lowerBand;
    } else {
        // Fallback: Calculate basic Dragon Band using ATR
        int atr_h = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atr_buf[1];
        if(CopyBuffer(atr_h, 0, 0, 1, atr_buf) < 1) { if(atr_h!=INVALID_HANDLE) IndicatorRelease(atr_h); return false; }
        double atr = atr_buf[0];
        IndicatorRelease(atr_h);
        if(atr <= 0) return false;

        int ema_h = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
        double ema_buf[1];
        if(CopyBuffer(ema_h, 0, 0, 1, ema_buf) < 1) { if(ema_h!=INVALID_HANDLE) IndicatorRelease(ema_h); return false; }
        double ema89 = ema_buf[0];
        IndicatorRelease(ema_h);
        dragonHigh = ema89 + (atr * 2.0);
        dragonLow = ema89 - (atr * 2.0);
    }

    // Validate Dragon Band data
    double dragonWidth = dragonHigh - dragonLow;
    if(dragonWidth <= 0) {
        Print("?? [PULLBACK] Invalid Dragon Band width: ", dragonWidth);
        return false;
    }

    // T�nh to�n v? tr� gi� trong d?i Dragon (0.0 = bottom, 1.0 = top)
    double pricePosition = (price - dragonLow) / dragonWidth;

    // X�c d?nh pullback zone (20%-40% ho?c 60%-80%)
    bool inPullbackZone = ((pricePosition >= 0.2 && pricePosition <= 0.4) ||
                          (pricePosition >= 0.6 && pricePosition <= 0.8));

    // Co ch? early entry khi momentum m?nh
    if(inPullbackZone && IsStrongMomentum()) {
        Print("? [PULLBACK] Early entry triggered - Strong momentum detected");
        return true;
    }

    // Log for transparency
    if(inPullbackZone) {
        Print("?? [PULLBACK] In pullback zone - Price position: ", DoubleToString(pricePosition * 100, 1), "%");
    }

    return inPullbackZone;
}

void GenerateMasterSignal()
{
m_masterData.masterSignal = SIGNAL_NONE;
m_masterData.signalStrength = 0.0;
m_masterData.signalConfidence = 0.0;
m_masterData.signalValid = false;

// Check confluence threshold
if(m_masterData.weightedConfluence < m_confluenceThreshold) {
return; // Insufficient confluence
}

// ?? INTELLIGENT SIGNAL GENERATION WITH CONFLICT RESOLUTION
// Collect directional signals from components with confidence scores
SComponentSignal componentSignals[4];
int signalCount = 0;

// Dragon Band Signal
if(m_unifiedDragonAnalyzer != NULL) {
ENUM_TREND_DIRECTION dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
double dragonScore = (m_consolidatedAnalysis!=NULL) ? m_consolidatedAnalysis.GetDragonBandScore() : 0.5;

componentSignals[signalCount].source = "DragonBand";
componentSignals[signalCount].confidence = dragonScore;
componentSignals[signalCount].weight = m_componentWeights[0];
componentSignals[signalCount].timestamp = TimeCurrent();

if(dragonTrend == TREND_BULLISH && dragonScore > 0.6) {
componentSignals[signalCount].signal = SIGNAL_BUY;
} else if(dragonTrend == TREND_BEARISH && dragonScore > 0.6) {
componentSignals[signalCount].signal = SIGNAL_SELL;
} else {
componentSignals[signalCount].signal = SIGNAL_NONE;
}
signalCount++;
}

// Wave Pattern Signal
if(m_waveAnalyzer != NULL) {
componentSignals[signalCount].source = "WavePattern";
componentSignals[signalCount].signal = SIGNAL_NONE; // Placeholder
componentSignals[signalCount].confidence = 0.5;
componentSignals[signalCount].weight = m_componentWeights[1];
componentSignals[signalCount].timestamp = TimeCurrent();
signalCount++;
}

// Structure Signal
componentSignals[signalCount].source = "Structure";
componentSignals[signalCount].signal = DetermineStructureSignal();
componentSignals[signalCount].confidence = (m_structureManager != NULL) ?
    m_structureManager.GetCurrentStructure().structureStrength : 0.5;
componentSignals[signalCount].weight = m_componentWeights[2];
componentSignals[signalCount].timestamp = TimeCurrent();
signalCount++;

// PVSRA Signal
if(m_pvsraManager != NULL) {
componentSignals[signalCount].source = "PVSRA";
componentSignals[signalCount].signal = (*m_pvsraManager).GetPVSRASignal();
componentSignals[signalCount].confidence = 0.7; // Default confidence
componentSignals[signalCount].weight = m_componentWeights[3];
componentSignals[signalCount].timestamp = TimeCurrent();
signalCount++;
}

// ?? USE INTELLIGENT CONFLICT RESOLVER
if(m_conflictResolver != NULL && signalCount > 0) {
// Detect conflicts
bool hasConflict = m_conflictResolver.DetectConflicts(componentSignals, signalCount);

if(hasConflict) {
Print("?? [CONFLICT RESOLVER] Conflicts detected, applying intelligent resolution");
// Resolve conflicts and get final signal
SConflictData conflictData;
conflictData = m_conflictResolver.ResolveConflicts(componentSignals, signalCount);

m_masterData.masterSignal = conflictData.resolvedSignal;
m_masterData.signalStrength = conflictData.resolutionConfidence;
m_masterData.signalConfidence = conflictData.resolutionConfidence;
m_masterData.signalValid = (conflictData.resolutionConfidence >= 0.65);

Print("?? [CONFLICT RESOLVER] Final signal: ", TradingSignalToString(m_masterData.masterSignal),
      " | Confidence: ", DoubleToString(m_masterData.signalConfidence * 100, 1), "%");
} else {
// No conflicts, use traditional voting with weighted confluence
GenerateTraditionalSignal(componentSignals, signalCount);
}
} else {
// Fallback to traditional method if conflict resolver not available
GenerateTraditionalSignal(componentSignals, signalCount);
}
}

// ??? TRADITIONAL VOTING METHOD (FALLBACK)
void GenerateTraditionalSignal(SComponentSignal &signals[], int count)
{
double buyWeight = 0.0;
double sellWeight = 0.0;
double totalWeight = 0.0;

for(int i = 0; i < count; i++) {
if(signals[i].signal == SIGNAL_BUY) {
buyWeight += signals[i].weight * signals[i].confidence;
} else if(signals[i].signal == SIGNAL_SELL) {
sellWeight += signals[i].weight * signals[i].confidence;
}
totalWeight += signals[i].weight;
}

// Determine signal based on weighted votes
if(buyWeight > sellWeight && buyWeight > totalWeight * 0.4) {
m_masterData.masterSignal = SIGNAL_BUY;
m_masterData.signalStrength = buyWeight / totalWeight;
} else if(sellWeight > buyWeight && sellWeight > totalWeight * 0.4) {
m_masterData.masterSignal = SIGNAL_SELL;
m_masterData.signalStrength = sellWeight / totalWeight;
}

// Calculate confidence
if(m_masterData.masterSignal != SIGNAL_NONE) {
m_masterData.signalConfidence = (m_masterData.weightedConfluence + m_masterData.signalStrength) / 2.0;
m_masterData.signalValid = (m_masterData.signalConfidence >= 0.65);
}
}

ENUM_SIGNAL_TYPE DetermineStructureSignal()
{
if(m_structureManager == NULL) return SIGNAL_NONE;

SEnhancedMarketStructure structure;
structure = m_structureManager.GetCurrentStructure();

if(structure.isBreakoutConfirmed) {
if(structure.structureType == STRUCTURE_BULLISH) {
return SIGNAL_BUY;
} else if(structure.structureType == STRUCTURE_BEARISH) {
return SIGNAL_SELL;
}
}

return SIGNAL_NONE;
}

//+------------------------------------------------------------------+
//| ?? MARKET CONDITIONS ASSESSMENT                                 |
//+------------------------------------------------------------------+
void AssessMarketConditions()
{
// Determine market regime
DetermineMarketRegime();

// Analyze primary trend
AnalyzePrimaryTrend();

// Calculate volatility
CalculateVolatilityLevel();

// Update performance optimizer with market conditions
// FIXED: Performance modules not loaded, skip optimizer updates
// if(g_PerformanceOptimizer != NULL) {
//     g_PerformanceOptimizer.UpdateMarketVolatility(m_masterData.volatilityLevel);
// }
}

void DetermineMarketRegime()
{
// Simplified regime detection based on component analysis
int trendingComponents = 0;
int rangingComponents = 0;

// Check Dragon Band trend
if(m_unifiedDragonAnalyzer != NULL) {
ENUM_TREND_DIRECTION dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
if(dragonTrend != TREND_SIDEWAYS) trendingComponents++;
else rangingComponents++;
}

// Check Structure trend
if(m_structureManager != NULL) {
SEnhancedMarketStructure structure;
structure = m_structureManager.GetCurrentStructure();
if(structure.structureType != STRUCTURE_RANGING) trendingComponents++;
else rangingComponents++;
}

// Check PVSRA phase
if(m_pvsraManager != NULL) {
// ?? PHASE 2 FIX: Simplified market phase
ENUM_MARKET_PHASE phase = MARKET_PHASE_A; // Placeholder for simplified implementation
if(phase == MARKET_PHASE_B || phase == MARKET_PHASE_D) trendingComponents++; // ?? FIXED: Use correct ENUM_MARKET_PHASE values
else rangingComponents++;
}

// Determine regime
if(trendingComponents > rangingComponents) {
m_masterData.marketRegime = REGIME_TRENDING_BULLISH; // ?? FIXED: Use correct ENUM_MARKET_REGIME value
} else {
m_masterData.marketRegime = REGIME_RANGING;
}
}

void AnalyzePrimaryTrend()
{
// Collect trend votes from components
int upVotes = 0;
int downVotes = 0;
int sidewaysVotes = 0;
double totalStrength = 0.0;

// Dragon Band trend
if(m_unifiedDragonAnalyzer != NULL) {
ENUM_TREND_DIRECTION dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
if(dragonTrend == TREND_BULLISH) upVotes++;
else if(dragonTrend == TREND_BEARISH) downVotes++;
else sidewaysVotes++;
}

// Structure trend
if(m_structureManager != NULL) {
SEnhancedMarketStructure structure;
structure = m_structureManager.GetCurrentStructure();
if(structure.trendDirection == TREND_UP) upVotes++;
else if(structure.trendDirection == TREND_DOWN) downVotes++;
else sidewaysVotes++;

totalStrength += structure.structureStrength;
}

// Determine primary trend
if(upVotes > downVotes && upVotes > sidewaysVotes) {
m_masterData.primaryTrend = TREND_UP;
} else if(downVotes > upVotes && downVotes > sidewaysVotes) {
m_masterData.primaryTrend = TREND_DOWN;
} else {
m_masterData.primaryTrend = TREND_SIDEWAYS;
}

// Calculate trend strength
int totalVotes = upVotes + downVotes + sidewaysVotes;
if(totalVotes > 0) {
double winningVotes = MathMax(upVotes, MathMax(downVotes, sidewaysVotes));
m_masterData.trendStrength = (winningVotes / totalVotes + totalStrength / 3.0) / 2.0;
}
}

void CalculateVolatilityLevel()
{
// Calculate ATR-based volatility
double atr[];
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
if(atrHandle != INVALID_HANDLE && CopyBuffer(atrHandle, 0, 0, 1, atr) > 0) {
// Get average ATR for comparison
double avgATR[];
if(CopyBuffer(atrHandle, 0, 0, 50, avgATR) >= 50) {
double currentATR = atr[0];
double averageATR = 0.0;
for(int i = 0; i < 50; i++) {
averageATR += avgATR[i];
}
averageATR /= 50.0;

if(averageATR > 0) {
m_masterData.volatilityLevel = currentATR / averageATR;
m_masterData.volatilityLevel = MathMax(0.0, MathMin(2.0, m_masterData.volatilityLevel)); // Clamp 0-2
}
}
}
IndicatorRelease(atrHandle);
}

//+------------------------------------------------------------------+
//| ?? COMPONENT PERFORMANCE TRACKING                              |
//+------------------------------------------------------------------+
void UpdateComponentPerformance(ENUM_SIGNAL_TYPE actualSignal, bool signalSuccess)
{
if(m_weightAdjuster == NULL) return;

// Update performance for each component based on their contribution
// Dragon Band Performance
if(m_unifiedDragonAnalyzer != NULL) {
ENUM_TREND_DIRECTION dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
ENUM_SIGNAL_TYPE dragonSignal = SIGNAL_NONE;
if(dragonTrend == TREND_BULLISH) dragonSignal = SIGNAL_BUY;
else if(dragonTrend == TREND_BEARISH) dragonSignal = SIGNAL_SELL;

bool dragonCorrect = (dragonSignal == actualSignal) && signalSuccess;
(*m_weightAdjuster).UpdateComponentPerformance(COMPONENT_DRAGON, dragonCorrect, m_masterData.dragonScore);
}

// Wave Pattern Performance
if(m_waveAnalyzer != NULL) {
// Simplified for Phase 2 - assume neutral performance
bool waveCorrect = signalSuccess; // Placeholder
(*m_weightAdjuster).UpdateComponentPerformance(COMPONENT_WAVE, waveCorrect, m_masterData.waveScore);
}

// Structure Performance
if(m_structureManager != NULL) {
ENUM_SIGNAL_TYPE structureSignal = DetermineStructureSignal();
bool structureCorrect = (structureSignal == actualSignal) && signalSuccess;
(*m_weightAdjuster).UpdateComponentPerformance(COMPONENT_STRUCTURE, structureCorrect, m_masterData.structureScore);
}

// PVSRA Performance
if(m_pvsraManager != NULL) {
// Simplified for Phase 2 - assume neutral performance
bool pvsraCorrect = signalSuccess; // Placeholder
(*m_weightAdjuster).UpdateComponentPerformance(COMPONENT_PVSRA, pvsraCorrect, m_masterData.pvsraScore);
}

// Trigger weight adjustment if needed
m_weightAdjuster.CheckAndAdjustWeights();
}

//+------------------------------------------------------------------+
//| ??? RISK ASSESSMENT                                             |
//+------------------------------------------------------------------+
void PerformRiskAssessment()
{
m_masterData.riskLevel = 0.5; // Base risk
m_masterData.allowTrading = false;
m_masterData.riskReason = "";

// Check signal quality
if(m_masterData.signalConfidence < 0.65) {
m_masterData.riskLevel += 0.2;
m_masterData.riskReason += "Low signal confidence; ";
}

// Check volatility
if(m_masterData.volatilityLevel > 1.5) {
m_masterData.riskLevel += 0.15;
m_masterData.riskReason += "High volatility; ";
} else if(m_masterData.volatilityLevel < 0.5) {
m_masterData.riskLevel -= 0.1; // Lower risk in low volatility
}

// Check confluence strength
if(m_masterData.strongComponents < 2) {
m_masterData.riskLevel += 0.15;
m_masterData.riskReason += "Weak confluence; ";
}

// Check analysis quality
if(m_masterData.analysisQuality < 0.7) {
m_masterData.riskLevel += 0.1;
m_masterData.riskReason += "Low analysis quality; ";
}

// Emergency mode check
if(m_emergencyMode) {
m_masterData.riskLevel = 1.0;
m_masterData.riskReason += "Emergency mode active; ";
}

// Clamp risk level
m_masterData.riskLevel = MathMax(0.0, MathMin(1.0, m_masterData.riskLevel));

// Determine trading allowance
m_masterData.allowTrading = (m_masterData.riskLevel < 0.8 &&
m_masterData.signalValid &&
!m_emergencyMode &&
m_masterData.analysisQuality > 0.6);

if(m_masterData.allowTrading) {
m_masterData.riskReason = "Risk acceptable for trading";
}
}

//+------------------------------------------------------------------+
//| ?? QUALITY METRICS                                              |
//+------------------------------------------------------------------+
void CalculateQualityMetrics()
{
// Calculate analysis quality based on component performance
double qualitySum = 0.0;
int qualityComponents = 0;

if(m_masterData.dragonScore > 0.1) {
qualitySum += m_masterData.dragonScore;
qualityComponents++;
}

if(m_masterData.waveScore > 0.1) {
qualitySum += m_masterData.waveScore;
qualityComponents++;
}

if(m_masterData.structureScore > 0.1) {
qualitySum += m_masterData.structureScore;
qualityComponents++;
}

if(m_masterData.pvsraScore > 0.1) {
qualitySum += m_masterData.pvsraScore;
qualityComponents++;
}

if(qualityComponents > 0) {
m_masterData.analysisQuality = qualitySum / qualityComponents;
} else {
m_masterData.analysisQuality = 0.0;
}

// Calculate data reliability based on consistency
double consistencyScore = CalculateConsistencyScore();
double updateSuccess = m_updateCount > 0 ? (double)m_successfulUpdates / m_updateCount : 0.0;

m_masterData.dataReliability = (consistencyScore * 0.6 + updateSuccess * 0.4);
}

double CalculateConsistencyScore()
{
// Check consistency between components
double consistency = 1.0;

// Check Dragon vs Structure trend consistency
if(m_unifiedDragonAnalyzer != NULL && m_structureManager != NULL) {
ENUM_TREND_DIRECTION dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
SEnhancedMarketStructure structure;
structure = m_structureManager.GetCurrentStructure();

if(dragonTrend != structure.trendDirection &&
dragonTrend != TREND_SIDEWAYS &&
structure.trendDirection != TREND_SIDEWAYS) {
consistency -= 0.2; // Inconsistent trends
}
}

// Check signal agreement
int positiveSignals = 0;
int negativeSignals = 0;
int totalSignals = 0;

if(m_masterData.dragonScore > 0.6) {
// Determine dragon signal from unified analyzer
ENUM_TREND_DIRECTION dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
if(dragonTrend == TREND_BULLISH) positiveSignals++;
else if(dragonTrend == TREND_BEARISH) negativeSignals++;
totalSignals++;
}

if(m_masterData.waveScore > 0.6) {
// ?? PHASE 2 FIX: Simplified wave signal
ENUM_SIGNAL_TYPE waveSignal = SIGNAL_NONE; // Placeholder
if(waveSignal == SIGNAL_BUY) positiveSignals++;
else if(waveSignal == SIGNAL_SELL) negativeSignals++;
totalSignals++;
}

if(totalSignals > 1) {
double agreement = MathMax(positiveSignals, negativeSignals) / (double)totalSignals;
consistency *= agreement;
}

return MathMax(0.0, MathMin(1.0, consistency));
}

//+------------------------------------------------------------------+
//| ?? PUBLIC INTERFACE                                             |
//+------------------------------------------------------------------+
SMasterAnalysisData GetMasterData()
{
if(!m_cacheValid) {
UpdateMasterAnalysis();
}
return m_masterData;
}

double GetConfluenceScore()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.weightedConfluence;
}

ENUM_SIGNAL_TYPE GetMasterSignal()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.masterSignal;
}

double GetSignalConfidence()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.signalConfidence;
}

bool IsSignalValid()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.signalValid;
}

bool IsTradingAllowed()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.allowTrading;
}

string GetMasterReport()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.GetMasterReport();
}

string GetDetailedReport()
{
if(!m_cacheValid) UpdateMasterAnalysis();
return m_masterData.GetDetailedReport();
}

string GetPerformanceReport()
{
return StringFormat(
"?? === MASTER ORCHESTRATOR PERFORMANCE ===\n" +
"Updates: %d (Success: %d, Rate: %.1f%%)\n" +
"Average Update Time: %.1fms\n" +
"Cache Performance: %.1f%% (%d hits, %d misses)\n" +
"Error Count: %d (Max: %d)\n" +
"Emergency Mode: %s\n" +
"Last Error: %s\n" +
"Component Status: UnifiedDragon=%s, Wave=%s, Structure=%s, PVSRA=%s",
m_updateCount,
m_successfulUpdates,
m_updateCount > 0 ? (double)m_successfulUpdates / m_updateCount * 100 : 0,
m_averageUpdateTime,
m_cacheHits + m_cacheMisses > 0 ? (double)m_cacheHits / (m_cacheHits + m_cacheMisses) * 100 : 0,
m_cacheHits,
m_cacheMisses,
m_errorCount,
m_maxErrors,
m_emergencyMode ? "ACTIVE" : "NORMAL",
m_lastError,
m_unifiedDragonAnalyzer != NULL ? "OK" : "ERROR",
m_waveAnalyzer != NULL ? "OK" : "ERROR",
m_structureManager != NULL ? "OK" : "ERROR",
m_pvsraManager != NULL ? "OK" : "ERROR"
);
}

//+------------------------------------------------------------------+
//| ?? BOSS ENHANCEMENT: PUBLIC MTF + MODE DETECTION METHODS        |
//+------------------------------------------------------------------+

// Item 6: Multi-timeframe conflict resolution (Simplified for Phase 2)
ENUM_SIGNAL_TYPE ResolveMTFConflict()
{
// ?? PHASE 2: Simplified MTF implementation
double h4Score = 0.5; // Placeholder H4 score
double m15Score = 0.5; // Placeholder M15 score

if (h4Score > 0.7 && m15Score < 0.5) {
Print("[?? MTF] H4 priority detected");
return SIGNAL_BUY; // Follow H4 if strong
} else if (h4Score < m15Score) {
Print("[? MTF] M15 early signal");
return SIGNAL_WAIT; // Wait H4 align
}

Print("[?? MTF] No clear direction");
return SIGNAL_NONE; // No conflict resolution
}

// Item 7: Mode-based strategy processing (Simplified for Phase 2)
void ProcessModeBasedStrategy()
{
ENUM_MODE mode = DetectMode();

if (mode == MODE_TREND) {
Print("[?? MODE] TREND strategy active");
} else if (mode == MODE_RANGE) {
Print("[?? MODE] RANGE strategy active");
} else if (mode == MODE_VOLATILE) {
Print("[?? MODE] VOLATILE strategy active");
}
}

// Item 7: Market mode detection (Simplified for Phase 2)
ENUM_MODE DetectMode()
{
// ?? PHASE 2: Simple mode detection based on price movement
MqlRates rates[];
ArrayResize(rates, 5);
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 5, rates) < 5) {
return MODE_RANGE; // Default to range if no data
}

double priceRange = rates[0].high - rates[0].low;
double avgRange = 0;
for(int i = 1; i < 5; i++) {
avgRange += (rates[i].high - rates[i].low);
}
avgRange /= 4.0;

if (priceRange > avgRange * 1.5) {
return MODE_VOLATILE; // High volatility
}

// Simple trend detection
bool upTrend = (rates[0].close > rates[2].close) && (rates[1].close > rates[3].close);
bool downTrend = (rates[0].close < rates[2].close) && (rates[1].close < rates[3].close);

if (upTrend || downTrend) {
return MODE_TREND; // Trending market
}

return MODE_RANGE; // Default to ranging
}

//+------------------------------------------------------------------+
//| ?? MULTI-TIMEFRAME SYNCHRONIZATION - PHASE 4 OPTIMIZED         |
//+------------------------------------------------------------------+

// PHASE 4: IsTimeSynchronized function per checklist
/* Commented out to fix duplicate definition
bool IsTimeSynchronized(ENUM_TIMEFRAMES tf1, ENUM_TIMEFRAMES tf2) {
    datetime time1 = iTime(_Symbol, tf1, 0);
    datetime time2 = iTime(_Symbol, tf2, 0);

    // Cho ph�p ch�nh l?ch t?i da 1 ph�t (Phase 4 requirement)
    return (MathAbs(time1 - time2) <= 60);
}*/

// PHASE 4: IsAllTimeframesSynchronized function (called by UpdateMasterAnalysis)
bool IsAllTimeframesSynchronized() {
    // Check H1-M15 synchronization (Phase 4 priority)
    if(!IsTimeSynchronized(PERIOD_H1, PERIOD_M15)) {
        Print("[TIME SYNC] H1 and M15 not synchronized - skipping analysis");
        return false;
    }

    // Check H1-M5 synchronization (Phase 4 requirement)
    if(!IsTimeSynchronized(PERIOD_H1, PERIOD_M5)) {
        return false;
    }

    return true;
}

// LEGACY: CheckTimeframeSynchronization (kept for compatibility)
bool CheckTimeframeSynchronization()
{
ENUM_TIMEFRAMES timeframes[4] = {PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4};
bool allSynced = true;

for(int i = 0; i < 4; i++) {
datetime currentBarTime = iTime(_Symbol, timeframes[i], 0);
if(currentBarTime != m_lastBarTime[i]) {
m_lastBarTime[i] = currentBarTime;
// New bar detected on this timeframe
Print(StringFormat("[SYNC] New bar on %s", TimeframeToString(timeframes[i])));
}
}

// Check if all timeframes are aligned (within 5 minutes)
datetime baseTime = m_lastBarTime[0]; // M5 as base
for(int i = 1; i < 4; i++) {
if(MathAbs(m_lastBarTime[i] - baseTime) > 300) { // 5 minutes
allSynced = false;
break;
}
}

m_timeframeSynced = allSynced;
return allSynced;
}

//+------------------------------------------------------------------+
//| ?? H4 SUPPORT/RESISTANCE DETECTION                              |
//+------------------------------------------------------------------+
void UpdateH4SupportResistance()
{
m_h4LevelCount = 0;
ArrayInitialize(m_h4SupportResistance, 0.0);

// Get H4 highs and lows for last 50 bars
int lookback = 50;
double levels[];
ArrayResize(levels, lookback * 2);
int levelCount = 0;

for(int i = 2; i < lookback - 2; i++) {
double high = iHigh(_Symbol, PERIOD_H4, i);
double low = iLow(_Symbol, PERIOD_H4, i);

// Check for swing high
if(high > iHigh(_Symbol, PERIOD_H4, i-1) && high > iHigh(_Symbol, PERIOD_H4, i+1) &&
high > iHigh(_Symbol, PERIOD_H4, i-2) && high > iHigh(_Symbol, PERIOD_H4, i+2)) {
levels[levelCount++] = high;
}

// Check for swing low
if(low < iLow(_Symbol, PERIOD_H4, i-1) && low < iLow(_Symbol, PERIOD_H4, i+1) &&
low < iLow(_Symbol, PERIOD_H4, i-2) && low < iLow(_Symbol, PERIOD_H4, i+2)) {
levels[levelCount++] = low;
}

if(levelCount >= 10) break;
}

// Store significant levels
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
for(int i = 0; i < levelCount && m_h4LevelCount < 10; i++) {
// Only store levels within reasonable distance
double distance = MathAbs(levels[i] - currentPrice) / currentPrice;
if(distance < 0.05) { // Within 5% of current price
m_h4SupportResistance[m_h4LevelCount++] = levels[i];
}
}

Print(StringFormat("[H4 LEVELS] Found %d significant support/resistance levels", m_h4LevelCount));
}

//+------------------------------------------------------------------+
//| ?? M5 REVERSAL PATTERN DETECTION                                |
//+------------------------------------------------------------------+
bool DetectM5ReversalPattern()
{
// Check for strong reversal patterns on M5
MqlRates rates[];
ArrayResize(rates, 5);
ArraySetAsSeries(rates, true);

if(CopyRates(_Symbol, PERIOD_M5, 0, 5, rates) < 5) return false;

// Pattern 1: Hammer/Doji at support/resistance
bool isHammer = IsHammerPattern(rates[0]);
bool isDoji = IsDoji(rates[0]);
bool atKeyLevel = IsAtKeyLevel(rates[0].close);

// Pattern 2: Engulfing pattern
bool isEngulfing = IsEngulfingPattern(rates[0], rates[1]);

// Pattern 3: Three consecutive candles reversal
bool isThreeBarReversal = IsThreeBarReversal(rates);

m_m5ReversalDetected = (isHammer && atKeyLevel) || (isDoji && atKeyLevel) ||
isEngulfing || isThreeBarReversal;

if(m_m5ReversalDetected) {
Print("[M5 REVERSAL] Strong reversal pattern detected");
m_advancedScanMode = true;
}


return m_m5ReversalDetected;
}

//+------------------------------------------------------------------+
//| ?? PATTERN DETECTION HELPERS                                    |
//+------------------------------------------------------------------+
bool IsHammerPattern(const MqlRates& rate)
{
double body = MathAbs(rate.close - rate.open);
double range = rate.high - rate.low;
double lowerShadow = MathMin(rate.open, rate.close) - rate.low;
double upperShadow = rate.high - MathMax(rate.open, rate.close);

return (lowerShadow > body * 2) && (upperShadow < body * 0.5) && (range > 0);
}

bool IsDoji(const MqlRates& rate)
{
double body = MathAbs(rate.close - rate.open);
double range = rate.high - rate.low;

return (body < range * 0.1) && (range > 0);
}

bool IsAtKeyLevel(double price)
{
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 20;

for(int i = 0; i < m_h4LevelCount; i++) {
if(MathAbs(price - m_h4SupportResistance[i]) <= tolerance) {
return true;
}
}
return false;
}

bool IsEngulfingPattern(const MqlRates& current, const MqlRates& previous)
{
bool currentBullish = current.close > current.open;
bool previousBearish = previous.close < previous.open;

if(currentBullish && previousBearish) {
return (current.close > previous.open) && (current.open < previous.close);
}

bool currentBearish = current.close < current.open;
bool previousBullish = previous.close > previous.open;

if(currentBearish && previousBullish) {
return (current.close < previous.open) && (current.open > previous.close);
}

return false;
}

bool IsThreeBarReversal(const MqlRates& rates[])
{
// Check for three consecutive bars forming reversal
bool upReversal = (rates[2].close < rates[2].open) && // First bar bearish
(rates[1].close < rates[1].open) && // Second bar bearish
(rates[0].close > rates[0].open) && // Third bar bullish
(rates[0].close > rates[1].high);   // Third bar breaks previous high

bool downReversal = (rates[2].close > rates[2].open) && // First bar bullish
(rates[1].close > rates[1].open) && // Second bar bullish
(rates[0].close < rates[0].open) && // Third bar bearish
(rates[0].close < rates[1].low);    // Third bar breaks previous low

return upReversal || downReversal;
}

//+------------------------------------------------------------------+
//| ?? ADVANCED SIGNAL ENHANCEMENT                                  |
//+------------------------------------------------------------------+
void EnhanceSignalWithAdvancedScan()
{
if(!m_advancedScanMode) return;

// Update H4 levels
UpdateH4SupportResistance();

// Check M5 reversal patterns
DetectM5ReversalPattern();

// Check timeframe synchronization
CheckTimeframeSynchronization();

// Enhance signal confidence if conditions are met
if(m_timeframeSynced && m_m5ReversalDetected && m_h4LevelCount > 0) {
m_masterData.signalConfidence = MathMin(m_masterData.signalConfidence * 1.25, 1.0);
m_masterData.signalStrength = MathMin(m_masterData.signalStrength * 1.15, 1.0);

Print("[ENHANCED] Signal enhanced by advanced scanning mode");
}

// Reset advanced scan mode after use
static datetime lastReset = 0;
if(TimeCurrent() - lastReset > 300) { // Reset every 5 minutes
m_advancedScanMode = false;
lastReset = TimeCurrent();
}
}

private:
//+------------------------------------------------------------------+
//| ?? TIME SYNCHRONIZATION                                         |
//+------------------------------------------------------------------+
/**
* @brief Ki?m tra d?ng b? th?i gian gi?a c�c timeframe
* @param tf1 Timeframe th? nh?t
* @param tf2 Timeframe th? hai
* @return true n?u c�c timeframe d?ng b?
* @note �?m b?o t�n hi?u t? c�c timeframe kh�c nhau du?c ph�n t�ch c�ng l�c
*/
bool IsTimeSynchronized(ENUM_TIMEFRAMES tf1, ENUM_TIMEFRAMES tf2) {
datetime time1 = iTime(_Symbol, tf1, 0);
datetime time2 = iTime(_Symbol, tf2, 0);

// T�nh to�n d? l?ch th?i gian t?i da cho ph�p
int tf1_seconds = PeriodSeconds(tf1);
int tf2_seconds = PeriodSeconds(tf2);
int max_deviation = MathMax(tf1_seconds, tf2_seconds) / 2;

// Ki?m tra d? l?ch th?i gian
int time_diff = (int)MathAbs(time1 - time2);
bool synchronized = time_diff <= max_deviation;

if(!synchronized) {
Print(StringFormat("[TIME SYNC] Timeframes not synchronized: %s vs %s, diff: %d seconds",
TimeframeToString(tf1), TimeframeToString(tf2), time_diff));
}

return synchronized;
}



//+------------------------------------------------------------------+
//| ?? ERROR HANDLING                                               |
//+------------------------------------------------------------------+
void HandleAnalysisError(string error)
{
m_errorCount++;
m_lastError = error;
m_masterData.analysisErrors++;

Print("? Master Analysis Error: ", error);

// FIXED: Performance modules not loaded, skip error reporting
// if(g_PerformanceOptimizer != NULL) {
//     g_PerformanceOptimizer.ReportError(error);
// }

// Check if should enter emergency mode
if(m_errorCount > m_maxErrors) {
EnterEmergencyMode("Too many analysis errors: " + IntegerToString(m_errorCount));
}
}

void HandleComponentError(string componentError)
{
Print("?? Component Error: ", componentError);
m_masterData.analysisErrors++;

// Don't increment main error count for component errors
// They are less critical than full analysis failures
}

void EnterEmergencyMode(string reason)
{
if(!m_emergencyMode) {
m_emergencyMode = true;
Print("?? MASTER ORCHESTRATOR EMERGENCY MODE: ", reason);

// Reset error count
m_errorCount = 0;

// Invalidate cache to force fresh analysis
m_cacheValid = false;
}
}

void ExitEmergencyMode()
{
if(m_emergencyMode) {
m_emergencyMode = false;
m_errorCount = 0;
Print("? Emergency mode deactivated - Normal operations resumed");
}
}

//+------------------------------------------------------------------+
//| ?? BOSS ENHANCEMENT: ITEMS 6&7 - IMPLEMENTATIONS (REMOVED)     |
//+------------------------------------------------------------------+
// IMPLEMENTATIONS MOVED TO SEPARATE SECTION TO AVOID DUPLICATES

//+------------------------------------------------------------------+
//| ?? HELPER METHODS FOR ITEMS 6&7                                 |
//+------------------------------------------------------------------+

double GetH4Score()
{
// Get H4 timeframe analysis score
return m_masterData.dragonScore * 0.4 + m_masterData.structureScore * 0.6;
}

double GetM15Score()
{
// Get M15 timeframe analysis score
return m_masterData.pvsraScore * 0.5 + m_masterData.waveScore * 0.5;
}

double GetCurrentDragonAngle()
{
if(m_unifiedDragonAnalyzer != NULL) {
return (*m_unifiedDragonAnalyzer).GetDragonAngle();
}
return 0.0; // Fallback
}

double GetCurrentVolatility()
{
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double buffer[];
ArrayResize(buffer, 1);
if(CopyBuffer(atrHandle, 0, 0, 1, buffer) > 0) {
IndicatorRelease(atrHandle);
return buffer[0];
}
IndicatorRelease(atrHandle);
return 0.0001; // Fallback
}

double GetAverageVolatility()
{
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double buffer[];
ArrayResize(buffer, 20);
if(CopyBuffer(atrHandle, 0, 0, 20, buffer) >= 20) {
double sum = 0;
for(int i = 0; i < 20; i++) {
sum += buffer[i];
}
IndicatorRelease(atrHandle);
return sum / 20.0;
}
IndicatorRelease(atrHandle);
return 0.0001; // Fallback
}

double GetWaveOverlap()
{
if(m_waveAnalyzer != NULL) {
// Use Item 1 implementation
return 0.25; // Placeholder - would call m_waveAnalyzer.CalculateWaveOverlap()
}
return 0.0;
}

bool IsVolumeSurge()
{
long currentVol = iVolume(_Symbol, PERIOD_CURRENT, 0);
double avgVol = GetAverageVolume(10, PERIOD_CURRENT);
return (double)currentVol > avgVol * 2.0;
}

double GetAverageVolume(int period, ENUM_TIMEFRAMES timeframe)
{
double sum = 0;
for(int i = 1; i <= period; i++) {
sum += (double)iVolume(_Symbol, timeframe, i);
}
return sum / (double)period;
}

bool IsEngulfingCandle(ENUM_TIMEFRAMES timeframe)
{
MqlRates rates[];
ArrayResize(rates, 2);
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, timeframe, 0, 2, rates) < 2) return false;

// Simple engulfing pattern
bool currentBullish = rates[0].close > rates[0].open;
bool previousBearish = rates[1].close < rates[1].open;

return currentBullish && previousBearish &&
rates[0].close > rates[1].open && rates[0].open < rates[1].close;
}

void ActivateScoutMode()
{
Print("[?? ACTIVATE] Scout mode for range + volume surge");
// Integration with Item 4 Scout Manager
}

void AvoidTrade()
{
Print("[? AVOID] Trade avoided due to range noise");
}

void FollowWavePattern()
{
Print("[?? FOLLOW] Following wave pattern in trend mode");
// Integration with Item 1 Wave Analysis
}

void UseVolatileStrategy()
{
Print("[?? VOLATILE] Using volatile market strategy");
}

void ApplyGoldVolatilityAdjustment()
{
Print("[?? GOLD] Applying XAUUSD volatility adjustment (2x threshold)");
// Double volatility threshold for gold
}

//+------------------------------------------------------------------+
//| ?? CRITICAL FIX: BASIC ANALYSIS FALLBACK METHOD                 |
//+------------------------------------------------------------------+
bool RunBasicAnalysis()
{
Print("? [BASIC ANALYSIS] Activating fallback mode");

// 1. Get basic EMA values with fallback
double ema34_current = 0, ema89_current = 0;
double ema34_prev = 0, ema89_prev = 0;

CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();
int ema34Handle = INVALID_HANDLE, ema89Handle = INVALID_HANDLE;

if(manager != NULL) {
ema34Handle = manager.GetEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
ema89Handle = manager.GetEMAHandle(_Symbol, PERIOD_CURRENT, 89, PRICE_CLOSE);
} else {
ema34Handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
}

if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE) {
Print("? [BASIC ANALYSIS] Cannot create EMA handles - EA cannot function");
return false;
}

// 2. Get EMA values
double ema34Buffer[2], ema89Buffer[2];
if(CopyBuffer(ema34Handle, 0, 0, 2, ema34Buffer) <= 0 ||
CopyBuffer(ema89Handle, 0, 0, 2, ema89Buffer) <= 0) {
Print("? [BASIC ANALYSIS] Cannot get EMA values");
return false;
}

ema34_current = ema34Buffer[0];
ema89_current = ema89Buffer[0];
ema34_prev = ema34Buffer[1];
ema89_prev = ema89Buffer[1];

// 3. Basic trend analysis
double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
bool bullishTrend = (ema34_current > ema89_current);
bool trendStrengthening = (ema34_current - ema89_current) > (ema34_prev - ema89_prev);

// 4. Set basic master data
m_masterData.primaryTrend = bullishTrend ? TREND_BULLISH : TREND_BEARISH;
m_masterData.signalConfidence = trendStrengthening ? 0.6 : 0.3;
m_masterData.dragonScore = bullishTrend ? 0.5 : -0.5;
m_masterData.structureScore = trendStrengthening ? 0.6 : 0.3;
m_masterData.pvsraScore = 0.5; // Neutral PVSRA
// Note: analysisMode field doesn't exist in SMasterAnalysisData
m_masterData.lastUpdate = TimeCurrent();
m_masterData.isValid = true;

// 5. Update cache
m_cacheValid = true;
m_cacheTimestamp = TimeCurrent();

Print(StringFormat("? [BASIC ANALYSIS] Active - Trend: %s | Confidence: %.1f%%",
bullishTrend ? "BULLISH" : "BEARISH",
m_masterData.signalConfidence * 100));

return true;
}

//+------------------------------------------------------------------+
//| ?? PUBLIC INTERFACE FOR PERFORMANCE TRACKING                   |
//+------------------------------------------------------------------+
// Public method d? c�c module kh�c c� th? c?p nh?t hi?u su?t th�nh ph?n
void NotifySignalResult(ENUM_SIGNAL_TYPE actualSignal, bool signalSuccess)
{
UpdateComponentPerformance(actualSignal, signalSuccess);
}

// Public method d? l?y b�o c�o tr?ng s? hi?n t?i
string GetWeightReport()
{
if(m_weightAdjuster == NULL) return "Weight Adjuster not initialized";
return m_weightAdjuster.GetAdjustmentReport();
}

// Public method d? l?y tr?ng s? hi?n t?i
void GetCurrentComponentWeights(double &weights[])
{
if(ArraySize(weights) < 4) ArrayResize(weights, 4);
for(int i = 0; i < 4; i++) {
weights[i] = m_componentWeights[i];
}
}

// Public method d? force di?u ch?nh tr?ng s?
void ForceWeightAdjustment()
{
if(m_weightAdjuster != NULL) {
m_weightAdjuster.CheckAndAdjustWeights();
}
}
};

#endif // ANALYSIS_MASTER_ORCHESTRATOR_MQH


