//+------------------------------------------------------------------+
//|                                                     SMC_Utils.mqh |
//|                        SONIC R MC EA - SMC Utilities             |
//|                     Ð?i Bàng Architecture - SMC Helper Functions |
//+------------------------------------------------------------------+
#ifndef SMC_UTILS_MQH
#define SMC_UTILS_MQH


#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_14_CoreEnums.mqh"
#include "02_DataProviders_06_SMCConfig.mqh"

//+------------------------------------------------------------------+
//| SMC Utility Functions                                            |
//+------------------------------------------------------------------+
class CSMCUtils
{
public:
// Order Block Utilities
static bool IsValidOrderBlock(const SOrderBlock& ob);
static double CalculateOrderBlockStrength(const SOrderBlock& ob);
static bool IsOrderBlockActive(const SOrderBlock& ob);
static bool IsOrderBlockMitigated(const SOrderBlock& ob, double currentPrice);

// Fair Value Gap Utilities
static bool IsValidFairValueGap(const FairValueGap& fvg);
static double CalculateFVGStrength(const FairValueGap& fvg);
static bool IsFVGFilled(const FairValueGap& fvg, double currentPrice);
static bool IsFVGPartiallyFilled(const FairValueGap& fvg, double currentPrice);

// Liquidity Pool Utilities
static bool IsValidLiquidityPool(const LiquidityPool& pool);
static double CalculateLiquidityStrength(const LiquidityPool& pool);
static bool IsLiquiditySwept(const LiquidityPool& pool, double currentPrice);

// Support/Resistance Utilities
static bool IsAtSupportLevel(double price, double supportLevel, double tolerance = 0.0001);
static bool IsAtResistanceLevel(double price, double resistanceLevel, double tolerance = 0.0001);
static double GetNearestSupportResistance(double price, const double &levels[], int levelCount);

// Price Action Utilities
static bool IsEngulfingCandle(int index);
static bool IsDoji(int index, double threshold = 0.1);
static bool IsHammer(int index);
static bool IsPinBar(int index);
static bool IsInsideBar(int index);

// Volume Analysis
static bool IsHighVolume(double volume, double averageVolume, double threshold = 1.5);
static bool IsClimaxVolume(double volume, double averageVolume, double threshold = 3.0);
static ENUM_VOLUME_TYPE ClassifyVolume(double volume, double averageVolume);

// Market Structure Utilities
static bool IsStructuralBreak(const SwingPoint& previous, const SwingPoint& current);
static bool IsChanceOfCharacter(const SwingPoint &points[], int count);
static ENUM_MARKET_STRUCTURE DetermineMarketStructure(const SwingPoint &points[], int count);

// Time and Session Utilities
static bool IsInSession(const SonicRSession& session);
static bool IsHighImpactTime();
static double GetSessionVolatilityMultiplier(const SonicRSession& session);

// Conversion Utilities
static double PipsToPrice(double pips);
static double PriceToPips(double price);
static string OrderBlockTypeToString(ENUM_ORDER_BLOCK_TYPE type);
static string FVGTypeToString(ENUM_FVG_TYPE type);
static string VolumeTypeToString(ENUM_VOLUME_TYPE type);

private:
static double GetAverageVolume(int period = 20);
static double GetATR(int period = 14);
};

//+------------------------------------------------------------------+
//| SMC UTILITIES IMPLEMENTATIONS - REMOVED DUPLICATE CLASS         |
//+------------------------------------------------------------------+
// Note: CSMCUtils class already exists at line 16 with prototypes
// Implementations should be provided separately if needed

//+------------------------------------------------------------------+
//| Calculate Order Block Strength                                   |
//+------------------------------------------------------------------+
double CalculateOrderBlockStrength(const SOrderBlock& ob)
{
// TEMPORARY FIX: Skip order block validation
// if(!IsValidOrderBlock(ob)) return 0.0;
if(ob.high <= ob.low) return 0.0; // Basic validation inline

double strength = 0.5; // Base strength

// Factor 1: Size of order block
double sizePips = PriceToPips(ob.high - ob.low);
strength += (sizePips / 50.0) * 0.2; // Larger blocks get higher strength

// Factor 2: Age of order block (newer = stronger)
long ageSeconds = TimeCurrent() - ob.timeStart;
double ageFactor = 1.0 - (double)ageSeconds / (24 * 3600); // 24 hours timeout
strength += ageFactor * 0.2;

// Factor 3: Volume factor
if(ob.volume > 0) {
    double volumeFactor = MathMin(ob.volume / 1000.0, 1.0); // Normalize volume
    strength += volumeFactor * 0.1;
}

return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| Check if Order Block is Active                                   |
//+------------------------------------------------------------------+
bool IsOrderBlockActive(const SOrderBlock& ob)
{
// TEMPORARY FIX: Skip order block validation
// return IsValidOrderBlock(ob) && !ob.hasBeenTested;
return (ob.high > ob.low) && ob.isValid; // Basic validation inline
}

//+------------------------------------------------------------------+
//| Fair Value Gap Validation                                        |
//+------------------------------------------------------------------+
bool IsValidFairValueGap(const FairValueGap& fvg)
{
if(fvg.upperLevel <= fvg.lowerLevel) return false;
if(fvg.startTime <= 0) return false;

double sizePips = PriceToPips(fvg.upperLevel - fvg.lowerLevel);
if(sizePips < 5.0) return false; // Minimum 5 pips

// Check if FVG hasn't expired (24 hours)
datetime currentTime = TimeCurrent();
if(currentTime - fvg.startTime > 24 * 3600) return false;

return true;
}

//+------------------------------------------------------------------+
//| Check if FVG is Filled                                          |
//+------------------------------------------------------------------+
bool IsFVGFilled(const FairValueGap& fvg, double currentPrice)
{
if(!IsValidFairValueGap(fvg)) return true;

if(fvg.type == FVG_BULLISH)
{
return currentPrice <= fvg.lowerLevel;
}
else if(fvg.type == FVG_BEARISH)
{
return currentPrice >= fvg.upperLevel;
}

return false;
}

//+------------------------------------------------------------------+
//| Volume Classification                                            |
//+------------------------------------------------------------------+
ENUM_VOLUME_TYPE ClassifyVolume(double volume, double averageVolume)
{
if(volume >= averageVolume * 3.0) return VOLUME_CLIMAX;
if(volume >= averageVolume * 1.5) return VOLUME_HIGH;
if(volume <= averageVolume * 0.5) return VOLUME_LOW;
return VOLUME_NORMAL;
}

//+------------------------------------------------------------------+
//| Price Action - Engulfing Candle                                 |
//+------------------------------------------------------------------+
bool IsEngulfingCandle(int index)
{
if(index < 1) return false;

double current_open = iOpen(_Symbol, PERIOD_CURRENT, index);
double current_close = iClose(_Symbol, PERIOD_CURRENT, index);
double previous_open = iOpen(_Symbol, PERIOD_CURRENT, index + 1);
double previous_close = iClose(_Symbol, PERIOD_CURRENT, index + 1);

// Bullish engulfing
if(current_close > current_open && previous_close < previous_open)
{
return (current_open < previous_close && current_close > previous_open);
}

// Bearish engulfing
if(current_close < current_open && previous_close > previous_open)
{
return (current_open > previous_close && current_close < previous_open);
}

return false;
}

//+------------------------------------------------------------------+
//| Price Action - Doji Detection                                   |
//+------------------------------------------------------------------+
bool IsDoji(int index, double threshold)
{
double open = iOpen(_Symbol, PERIOD_CURRENT, index);
double close = iClose(_Symbol, PERIOD_CURRENT, index);
double high = iHigh(_Symbol, PERIOD_CURRENT, index);
double low = iLow(_Symbol, PERIOD_CURRENT, index);

double bodySize = MathAbs(close - open);
double totalRange = high - low;

if(totalRange == 0) return false;

double bodyPercentage = bodySize / totalRange;
return bodyPercentage <= threshold;
}

//+------------------------------------------------------------------+
//| Market Structure - Structural Break Detection                   |
//+------------------------------------------------------------------+
bool IsStructuralBreak(const SwingPoint& previous, const SwingPoint& current)
{
if(previous.type != current.type) return false;

if(previous.type == SWING_HIGH)
{
return current.price > previous.price; // Higher high
}
else if(previous.type == SWING_LOW)
{
return current.price < previous.price; // Lower low
}

return false;
}

//+------------------------------------------------------------------+
//| Utility Functions - Conversion                                  |
//+------------------------------------------------------------------+
double PipsToPrice(double pips)
{
double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

if(digits == 5 || digits == 3)
return pips * point * 10;
else
return pips * point;
}

double PriceToPips(double price)
{
double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

if(digits == 5 || digits == 3)
return price / (point * 10);
else
return price / point;
}

//+------------------------------------------------------------------+
//| Get Average Volume                                               |
//+------------------------------------------------------------------+
double GetAverageVolume(int period)
{
double sum = 0.0;
int count = 0;

for(int i = 1; i <= period; i++)
{
long volume = iVolume(_Symbol, PERIOD_CURRENT, i);
if(volume > 0)
{
sum += (double)volume;
count++;
}
}

return count > 0 ? sum / count : 0.0;
}

//+------------------------------------------------------------------+
//| Get ATR                                                          |
//+------------------------------------------------------------------+
double GetATR(int period)
{
int atr_handle = iATR(_Symbol, PERIOD_CURRENT, period);
if(atr_handle == INVALID_HANDLE) return 0.0;

double atr_buffer[];
if(CopyBuffer(atr_handle, 0, 0, 1, atr_buffer) <= 0)
{
IndicatorRelease(atr_handle);
return 0.0;
}

double atr = atr_buffer[0];
IndicatorRelease(atr_handle);
return atr;
}

//+------------------------------------------------------------------+
//| String Conversion Functions                                      |
//+------------------------------------------------------------------+
string OrderBlockTypeToString(ENUM_ORDER_BLOCK_TYPE type)
{
switch(type)
{
case ORDER_BLOCK_BULLISH: return "BULLISH";
case ORDER_BLOCK_BEARISH: return "BEARISH";
case ORDER_BLOCK_NEUTRAL: return "NEUTRAL";
default: return "UNKNOWN";
}
}

string FVGTypeToString(ENUM_FVG_TYPE type)
{
switch(type)
{
case FVG_BULLISH: return "BULLISH";
case FVG_BEARISH: return "BEARISH";
case FVG_NEUTRAL: return "NEUTRAL";
default: return "UNKNOWN";
}
}

string VolumeTypeToString(ENUM_VOLUME_TYPE type)
{
switch(type)
{
case VOLUME_NORMAL: return "NORMAL";
case VOLUME_HIGH: return "HIGH";
case VOLUME_LOW: return "LOW";
case VOLUME_CLIMAX: return "CLIMAX";
default: return "UNKNOWN";
}
}

#endif // SMC_UTILS_MQH


