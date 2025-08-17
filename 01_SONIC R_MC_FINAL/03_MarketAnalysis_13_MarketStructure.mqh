//+------------------------------------------------------------------+
//|                                        Analysis_Structure.mqh   |
//|                        SONIC R MC EA - Structure Analysis       |
//|                     Ð?i Bàng Architecture - Analysis Layer      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Ð?i Bàng"
#property version   "1.00"

#ifndef ANALYSIS_STRUCTURE_MQH
#define ANALYSIS_STRUCTURE_MQH


#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_08_ContextManager.mqh"
#include "01_Core_03_Logger.mqh"

// Forward declaration
class CMarketStructure;

//+------------------------------------------------------------------+
//| Market State Enumeration - Using Core Definition                |
//+------------------------------------------------------------------+
// ENUM_MARKET_STATE is already defined in Core_Defines_Clean.mqh
// No need to redefine it here

//+------------------------------------------------------------------+
//| Structure Analysis Class                                         |
//+------------------------------------------------------------------+
class CStructureAnalysis
{
private:
SwingPoint            m_recentHighs[10];
SwingPoint            m_recentLows[10];
ENUM_MARKET_STATE     m_currentState;
datetime              m_lastUpdate;
bool                  m_initialized;

// Context pointer
CEaContext*           m_context;

public:
//+------------------------------------------------------------------+
//| Constructor/Destructor                                           |
//+------------------------------------------------------------------+
CStructureAnalysis() : m_currentState(MARKET_STATE_INACTIVE), 
m_lastUpdate(0), m_initialized(false), m_context(NULL) {}

~CStructureAnalysis() {}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool Initialize(CEaContext* context)
{
m_context = context;
m_initialized = true;
m_currentState = MARKET_STATE_INACTIVE;
m_lastUpdate = TimeCurrent();

// Initialize arrays
for(int i = 0; i < 10; i++)
{
m_recentHighs[i].Reset();
m_recentLows[i].Reset();
}

// TEMP FIX: Logger access issue - commenting out for now
// if(m_context && m_context.pLogger)
// {
//     m_context.pLogger.LogInfo("Structure Analysis initialized");
// }

return true;
}

//+------------------------------------------------------------------+
//| Main Analysis Update                                             |
//+------------------------------------------------------------------+
void UpdateAnalysis()
{
if(!m_initialized) return;

FindSwingPoints();
AnalyzeMarketStructure();
m_lastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Get Current Market State                                         |
//+------------------------------------------------------------------+
ENUM_MARKET_STATE GetMarketState() const { return m_currentState; }

//+------------------------------------------------------------------+
//| Get Recent High/Low Points                                       |
//+------------------------------------------------------------------+
void GetRecentHighs(SwingPoint& highs[])
{
ArrayResize(highs, 10);
for(int i = 0; i < 10; i++)
{
highs[i] = m_recentHighs[i];
}
}

void GetRecentLows(SwingPoint& lows[])
{
ArrayResize(lows, 10);
for(int i = 0; i < 10; i++)
{
lows[i] = m_recentLows[i];
}
}

//+------------------------------------------------------------------+
//| Check if Structure is Bullish                                   |
//+------------------------------------------------------------------+
bool IsBullishStructure() const
{
return (m_currentState == MARKET_STATE_TRENDING);
}

//+------------------------------------------------------------------+
//| Check if Structure is Bearish                                   |
//+------------------------------------------------------------------+
bool IsBearishStructure() const
{
return (m_currentState == MARKET_STATE_RANGING);
}

private:
//+------------------------------------------------------------------+
//| Find Swing Points                                                |
//+------------------------------------------------------------------+
void FindSwingPoints()
{
const int lookback = 50;
double highs[];
double lows[];
datetime times[];

ArrayResize(highs, lookback);
ArrayResize(lows, lookback);
ArrayResize(times, lookback);

// Copy recent price data
int copiedHigh = CopyHigh(_Symbol, PERIOD_CURRENT, 0, lookback, highs);
int copiedLow = CopyLow(_Symbol, PERIOD_CURRENT, 0, lookback, lows);
int copiedTime = CopyTime(_Symbol, PERIOD_CURRENT, 0, lookback, times);

if(copiedHigh < lookback || copiedLow < lookback || copiedTime < lookback) return;

// Simple swing point detection (can be enhanced)
for(int i = 2; i < lookback - 2; i++)
{
// Check for swing high
if(highs[i] > highs[i-1] && highs[i] > highs[i-2] && 
highs[i] > highs[i+1] && highs[i] > highs[i+2])
{
AddSwingHigh(highs[i], times[i]);
}

// Check for swing low
if(lows[i] < lows[i-1] && lows[i] < lows[i-2] && 
lows[i] < lows[i+1] && lows[i] < lows[i+2])
{
AddSwingLow(lows[i], times[i]);
}
}
}

//+------------------------------------------------------------------+
//| Add Swing High                                                   |
//+------------------------------------------------------------------+
void AddSwingHigh(double price, datetime time)
{
// Shift existing points
for(int i = 9; i > 0; i--)
{
m_recentHighs[i] = m_recentHighs[i-1];
}

// Add new high
m_recentHighs[0].price = price;
m_recentHighs[0].time = time;
m_recentHighs[0].type = SWING_HIGH;
m_recentHighs[0].isValid = true;
}

//+------------------------------------------------------------------+
//| Add Swing Low                                                    |
//+------------------------------------------------------------------+
void AddSwingLow(double price, datetime time)
{
// Shift existing points
for(int i = 9; i > 0; i--)
{
m_recentLows[i] = m_recentLows[i-1];
}

// Add new low
m_recentLows[0].price = price;
m_recentLows[0].time = time;
m_recentLows[0].type = SWING_LOW;
m_recentLows[0].isValid = true;
}

//+------------------------------------------------------------------+
//| Analyze Market Structure                                         |
//+------------------------------------------------------------------+
void AnalyzeMarketStructure()
{
// Simple structure analysis
if(!m_recentHighs[0].isValid || !m_recentLows[0].isValid) 
{
m_currentState = MARKET_STATE_INACTIVE;
return;
}

// Check for higher highs and higher lows (uptrend)
bool higherHighs = (m_recentHighs[0].price > m_recentHighs[1].price);
bool higherLows = (m_recentLows[0].price > m_recentLows[1].price);

if(higherHighs && higherLows)
{
m_currentState = MARKET_STATE_TRENDING;
}
else if(!higherHighs && !higherLows)
{
m_currentState = MARKET_STATE_TRENDING;
}
else
{
m_currentState = MARKET_STATE_RANGING;
}
}
};

//+------------------------------------------------------------------+
//| Enhanced Market Structure Class - PHASE 2 IMPLEMENTATION        |
//+------------------------------------------------------------------+
class CMarketStructure
{
private:
// S/R level arrays
struct SRLevel
{
double price;
int strength;
int touchCount;
datetime firstTouch;
datetime lastTouch;
bool isBroken;
double volumeAtLevel;
};

SRLevel         m_supportLevels[50];
SRLevel         m_resistanceLevels[50];
int             m_supportCount;
int             m_resistanceCount;

// Structure points
SwingPoint      m_swingHighs[100];
SwingPoint      m_swingLows[100];
int             m_swingHighCount;
int             m_swingLowCount;

// Market structure state
ENUM_MARKET_STRUCTURE m_currentStructure;
double          m_lastHigh;
double          m_lastLow;
bool            m_initialized;

public:
CMarketStructure()
{
m_supportCount = 0;
m_resistanceCount = 0;
m_swingHighCount = 0;
m_swingLowCount = 0;
m_currentStructure = STRUCTURE_RANGING;
m_lastHigh = 0;
m_lastLow = 0;
m_initialized = false;
}

bool Initialize()
{
m_initialized = true;
IdentifyKeyLevels();
return true;
}

// ?? PHASE 2: Dynamic S/R Identification
void IdentifyKeyLevels()
{
m_supportCount = 0;
m_resistanceCount = 0;

// Find swing points first
FindSwingPoints();

// Identify resistance levels from swing highs
for(int i = 0; i < m_swingHighCount && m_resistanceCount < 50; i++)
{
double level = m_swingHighs[i].price;
int strength = CalculateLevelStrength(level, true);

if(strength >= 2) // Minimum 2 touches
{
SRLevel resistance;
resistance.price = level;
resistance.strength = strength;
resistance.touchCount = CountTouches(level, true);
resistance.firstTouch = GetFirstTouch(level, true);
resistance.lastTouch = GetLastTouch(level, true);
resistance.isBroken = false;
resistance.volumeAtLevel = CalculateVolumeAtLevel(level);

m_resistanceLevels[m_resistanceCount++] = resistance;
}
}

// Identify support levels from swing lows
for(int i = 0; i < m_swingLowCount && m_supportCount < 50; i++)
{
double level = m_swingLows[i].price;
int strength = CalculateLevelStrength(level, false);

if(strength >= 2) // Minimum 2 touches
{
SRLevel support;
support.price = level;
support.strength = strength;
support.touchCount = CountTouches(level, false);
support.firstTouch = GetFirstTouch(level, false);
support.lastTouch = GetLastTouch(level, false);
support.isBroken = false;
support.volumeAtLevel = CalculateVolumeAtLevel(level);

m_supportLevels[m_supportCount++] = support;
}
}

// Sort by strength
SortLevelsByStrength();

Print(StringFormat("[S/R] Identified %d support and %d resistance levels", m_supportCount, m_resistanceCount));
}

// Check if price is at support
bool IsAtSupport(double price)
{
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;

for(int i = 0; i < m_supportCount; i++)
{
if(!m_supportLevels[i].isBroken && 
MathAbs(price - m_supportLevels[i].price) <= tolerance)
{
return true;
}
}
return false;
}

// Check if price is at resistance
bool IsAtResistance(double price)
{
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;

for(int i = 0; i < m_resistanceCount; i++)
{
if(!m_resistanceLevels[i].isBroken && 
MathAbs(price - m_resistanceLevels[i].price) <= tolerance)
{
return true;
}
}
return false;
}

// Get nearest support
double GetNearestSupport(double price)
{
double nearestSupport = 0;
double minDistance = DBL_MAX;

for(int i = 0; i < m_supportCount; i++)
{
if(!m_supportLevels[i].isBroken && m_supportLevels[i].price < price)
{
double distance = price - m_supportLevels[i].price;
if(distance < minDistance)
{
minDistance = distance;
nearestSupport = m_supportLevels[i].price;
}
}
}

return nearestSupport;
}

// Get nearest resistance
double GetNearestResistance(double price)
{
double nearestResistance = 0;
double minDistance = DBL_MAX;

for(int i = 0; i < m_resistanceCount; i++)
{
if(!m_resistanceLevels[i].isBroken && m_resistanceLevels[i].price > price)
{
double distance = m_resistanceLevels[i].price - price;
if(distance < minDistance)
{
minDistance = distance;
nearestResistance = m_resistanceLevels[i].price;
}
}
}

return nearestResistance;
}

// Get level strength
int GetLevelStrength(double level)
{
// Check support levels
for(int i = 0; i < m_supportCount; i++)
{
if(MathAbs(m_supportLevels[i].price - level) < SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 5)
{
return m_supportLevels[i].strength;
}
}

// Check resistance levels
for(int i = 0; i < m_resistanceCount; i++)
{
if(MathAbs(m_resistanceLevels[i].price - level) < SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 5)
{
return m_resistanceLevels[i].strength;
}
}

return 0;
}

// Update S/R levels dynamically
void UpdateLevels()
{
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

// Check for broken levels
for(int i = 0; i < m_supportCount; i++)
{
if(!m_supportLevels[i].isBroken && currentPrice < m_supportLevels[i].price - SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 20)
{
m_supportLevels[i].isBroken = true;
Print(StringFormat("[S/R] Support broken at %.5f", m_supportLevels[i].price));
}
}

for(int i = 0; i < m_resistanceCount; i++)
{
if(!m_resistanceLevels[i].isBroken && currentPrice > m_resistanceLevels[i].price + SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 20)
{
m_resistanceLevels[i].isBroken = true;
Print(StringFormat("[S/R] Resistance broken at %.5f", m_resistanceLevels[i].price));
}
}

// Re-identify levels every 100 bars
static int updateCounter = 0;
updateCounter++;

if(updateCounter >= 100)
{
updateCounter = 0;
IdentifyKeyLevels();
}
}

// Get current market structure
ENUM_MARKET_STRUCTURE GetCurrentStructure() { return m_currentStructure; }

private:
// Find swing points
void FindSwingPoints()
{
m_swingHighCount = 0;
m_swingLowCount = 0;

for(int i = 5; i < 200 && m_swingHighCount < 100 && m_swingLowCount < 100; i++)
{
if(IsSwingHigh(i))
{
m_swingHighs[m_swingHighCount].price = iHigh(_Symbol, PERIOD_CURRENT, i);
m_swingHighs[m_swingHighCount].time = iTime(_Symbol, PERIOD_CURRENT, i);
m_swingHighs[m_swingHighCount].barIndex = i;
m_swingHighs[m_swingHighCount].type = SWING_HIGH;
m_swingHighs[m_swingHighCount].strength = 1.0;
m_swingHighs[m_swingHighCount].isValid = true;
m_swingHighCount++;
}

if(IsSwingLow(i))
{
m_swingLows[m_swingLowCount].price = iLow(_Symbol, PERIOD_CURRENT, i);
m_swingLows[m_swingLowCount].time = iTime(_Symbol, PERIOD_CURRENT, i);
m_swingLows[m_swingLowCount].barIndex = i;
m_swingLows[m_swingLowCount].type = SWING_LOW;
m_swingLows[m_swingLowCount].strength = 1.0;
m_swingLows[m_swingLowCount].isValid = true;
m_swingLowCount++;
}
}
}

// Check if bar is swing high
bool IsSwingHigh(int bar)
{
// ?? ENHANCED: Better bounds checking with detailed validation
int totalBars = iBars(_Symbol, PERIOD_CURRENT);
if(totalBars < 5) {
Print("?? [STRUCTURE] Insufficient bars for swing analysis: ", totalBars);
return false;
}

if(bar < 2 || bar >= totalBars - 2) {
// Silent return for boundary cases (not an error)
return false;
}

double high = iHigh(_Symbol, PERIOD_CURRENT, bar);
double high_m1 = iHigh(_Symbol, PERIOD_CURRENT, bar-1);
double high_m2 = iHigh(_Symbol, PERIOD_CURRENT, bar-2);
double high_p1 = iHigh(_Symbol, PERIOD_CURRENT, bar+1);
double high_p2 = iHigh(_Symbol, PERIOD_CURRENT, bar+2);

// ?? ADDED: Validate all price data
if(high <= 0 || high_m1 <= 0 || high_m2 <= 0 || high_p1 <= 0 || high_p2 <= 0) {
Print("?? [STRUCTURE] Invalid price data for swing high at bar ", bar);
return false;
}

return (high > high_m1 && high > high_m2 && high > high_p1 && high > high_p2);
}

// Check if bar is swing low
bool IsSwingLow(int bar)
{
// ?? ENHANCED: Better bounds checking with detailed validation
int totalBars = iBars(_Symbol, PERIOD_CURRENT);
if(totalBars < 5) {
Print("?? [STRUCTURE] Insufficient bars for swing analysis: ", totalBars);
return false;
}

if(bar < 2 || bar >= totalBars - 2) {
// Silent return for boundary cases (not an error)
return false;
}

double low = iLow(_Symbol, PERIOD_CURRENT, bar);
double low_m1 = iLow(_Symbol, PERIOD_CURRENT, bar-1);
double low_m2 = iLow(_Symbol, PERIOD_CURRENT, bar-2);
double low_p1 = iLow(_Symbol, PERIOD_CURRENT, bar+1);
double low_p2 = iLow(_Symbol, PERIOD_CURRENT, bar+2);

// ?? ADDED: Validate all price data
if(low <= 0 || low_m1 <= 0 || low_m2 <= 0 || low_p1 <= 0 || low_p2 <= 0) {
Print("?? [STRUCTURE] Invalid price data for swing low at bar ", bar);
return false;
}

return (low < low_m1 && low < low_m2 && low < low_p1 && low < low_p2);
}

// Calculate level strength based on touches and hold time
int CalculateLevelStrength(double level, bool isResistance)
{
int touches = CountTouches(level, isResistance);
double holdTime = CalculateHoldTime(level, isResistance);
double volumeScore = CalculateVolumeScore(level);

// Strength formula: touches * 2 + holdTime score + volume score
int strength = touches * 2;

if(holdTime > 24 * 3600) strength += 2; // Held for more than 24 hours
if(holdTime > 7 * 24 * 3600) strength += 3; // Held for more than a week

if(volumeScore > 1.5) strength += 2; // High volume at level

return strength;
}

// Count how many times price touched the level
int CountTouches(double level, bool isResistance)
{
int touches = 0;
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;

for(int i = 1; i < 500; i++)
{
if(isResistance)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
if(MathAbs(high - level) <= tolerance) touches++;
}
else
{
double low = iLow(_Symbol, PERIOD_CURRENT, i);
if(MathAbs(low - level) <= tolerance) touches++;
}
}

return touches;
}

// Calculate how long the level has held
double CalculateHoldTime(double level, bool isResistance)
{
datetime firstTouch = GetFirstTouch(level, isResistance);
datetime lastTouch = GetLastTouch(level, isResistance);

if(firstTouch == 0 || lastTouch == 0) return 0;

return (double)(lastTouch - firstTouch);
}

// Get first touch time
datetime GetFirstTouch(double level, bool isResistance)
{
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;

for(int i = 499; i >= 1; i--)
{
if(isResistance)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
if(MathAbs(high - level) <= tolerance) 
return iTime(_Symbol, PERIOD_CURRENT, i);
}
else
{
double low = iLow(_Symbol, PERIOD_CURRENT, i);
if(MathAbs(low - level) <= tolerance) 
return iTime(_Symbol, PERIOD_CURRENT, i);
}
}

return 0;
}

// Get last touch time
datetime GetLastTouch(double level, bool isResistance)
{
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;

for(int i = 1; i < 500; i++)
{
if(isResistance)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
if(MathAbs(high - level) <= tolerance) 
return iTime(_Symbol, PERIOD_CURRENT, i);
}
else
{
double low = iLow(_Symbol, PERIOD_CURRENT, i);
if(MathAbs(low - level) <= tolerance) 
return iTime(_Symbol, PERIOD_CURRENT, i);
}
}

return 0;
}

// Calculate volume at level
double CalculateVolumeAtLevel(double level)
{
double totalVolume = 0;
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
int touchCount = 0;

for(int i = 1; i < 200; i++)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
double low = iLow(_Symbol, PERIOD_CURRENT, i);

if((high >= level - tolerance && high <= level + tolerance) ||
(low >= level - tolerance && low <= level + tolerance))
{
totalVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
touchCount++;
}
}

return touchCount > 0 ? totalVolume / touchCount : 0;
}

// Calculate volume score
double CalculateVolumeScore(double level)
{
double volumeAtLevel = CalculateVolumeAtLevel(level);
double avgVolume = 0;

for(int i = 1; i <= 50; i++)
{
avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 50;

return avgVolume > 0 ? volumeAtLevel / avgVolume : 0;
}

// Sort levels by strength
void SortLevelsByStrength()
{
// Sort support levels
for(int i = 0; i < m_supportCount - 1; i++)
{
for(int j = 0; j < m_supportCount - i - 1; j++)
{
if(m_supportLevels[j].strength < m_supportLevels[j + 1].strength)
{
SRLevel temp;
temp.price = m_supportLevels[j].price;
temp.strength = m_supportLevels[j].strength;
temp.touchCount = m_supportLevels[j].touchCount;
temp.firstTouch = m_supportLevels[j].firstTouch;
temp.lastTouch = m_supportLevels[j].lastTouch;
temp.isBroken = m_supportLevels[j].isBroken;
temp.volumeAtLevel = m_supportLevels[j].volumeAtLevel;
m_supportLevels[j] = m_supportLevels[j + 1];
m_supportLevels[j + 1] = temp;
}
}
}

// Sort resistance levels
for(int i = 0; i < m_resistanceCount - 1; i++)
{
for(int j = 0; j < m_resistanceCount - i - 1; j++)
{
if(m_resistanceLevels[j].strength < m_resistanceLevels[j + 1].strength)
{
SRLevel temp;
temp.price = m_resistanceLevels[j].price;
temp.strength = m_resistanceLevels[j].strength;
temp.touchCount = m_resistanceLevels[j].touchCount;
temp.firstTouch = m_resistanceLevels[j].firstTouch;
temp.lastTouch = m_resistanceLevels[j].lastTouch;
temp.isBroken = m_resistanceLevels[j].isBroken;
temp.volumeAtLevel = m_resistanceLevels[j].volumeAtLevel;
m_resistanceLevels[j] = m_resistanceLevels[j + 1];
m_resistanceLevels[j + 1] = temp;
}
}
}
}

double GetSwingVolumeSignificance(int swingIdx, bool isHigh)
{
int totalSwings = m_swingHighCount + m_swingLowCount;
if(swingIdx < 0 || swingIdx >= totalSwings) return 0.0;

int barIndex;
if(isHigh && swingIdx < m_swingHighCount)
{
barIndex = m_swingHighs[swingIdx].barIndex;
}
else if(!isHigh && swingIdx < m_swingLowCount)
{
barIndex = m_swingLows[swingIdx].barIndex;
}
else return 0.0;

// Get volume at swing point  
double volumeAtSwing = (double)iVolume(_Symbol, PERIOD_CURRENT, barIndex);
if(volumeAtSwing <= 0) return 0.0;

// Calculate average volume
double avgVolume = CalculateAverageVolume(20);
if(avgVolume <= 0) return 0.0;

// Volume ratio
double volumeRatio = volumeAtSwing / avgVolume;

// Higher volume at swing points indicates stronger significance
// Normalize to 0-1 range
return MathMin(1.0, volumeRatio / 2.0);
}

// Helper function to calculate average volume
double CalculateAverageVolume(int period)
{
if(period <= 0) return 0.0;

double totalVolume = 0.0;
int validBars = 0;

for(int i = 1; i <= period; i++)
{
long volume = iVolume(_Symbol, PERIOD_CURRENT, i);
if(volume > 0)
{
totalVolume += (double)volume;
validBars++;
}
}

return (validBars > 0) ? (totalVolume / validBars) : 0.0;
}
};

#endif // ANALYSIS_STRUCTURE_MQH


