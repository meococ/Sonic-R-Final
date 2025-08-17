//+------------------------------------------------------------------+
//|                                        SMC_Consolidated.mqh |
//|                        SONIC R MC - SMC ANALYSIS CONSOLIDATED |
//|                    SMART MONEY CONCEPTS INTEGRATED SYSTEM      |
//+------------------------------------------------------------------+
#ifndef SMC_CONSOLIDATED_MQH
#define SMC_CONSOLIDATED_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
// SYSTEMATIC FIX - Use correct ErrorHandler file
#include "01_Core_ErrorHandler.mqh"

//+------------------------------------------------------------------+
//| SMC ORDER BLOCK STRUCTURE                                        |
//+------------------------------------------------------------------+
struct SOrderBlock
{
datetime timeStart;
datetime timeEnd;
double high;
double low;
double open;
double close;
double volume;
ENUM_ORDER_BLOCK_TYPE type;
double strength;
bool isInstitutional;
bool isValid;

void Reset()
{
timeStart = 0;
timeEnd = 0;
high = 0.0;
low = 0.0;
open = 0.0;
close = 0.0;
volume = 0.0;
type = ORDER_BLOCK_UNKNOWN;
strength = 0.0;
isInstitutional = false;
isValid = false;
}
};

//+------------------------------------------------------------------+
//| SMC LIQUIDITY POOL STRUCTURE                                     |
//+------------------------------------------------------------------+
struct SLiquidityPool
{
datetime time;
double price;
ENUM_LIQUIDITY_TYPE type;
double strength;
bool isValid;

void Reset()
{
time = 0;
price = 0.0;
type = LIQUIDITY_UNKNOWN;
strength = 0.0;
isValid = false;
}
};

//+------------------------------------------------------------------+
//| SMC CONSOLIDATED ANALYZER                                        |
//+------------------------------------------------------------------+
class CSMCConsolidated
{
private:
SOrderBlock m_orderBlocks[];
SLiquidityPool m_liquidityPools[];
int m_orderBlockCount;
int m_liquidityPoolCount;
string m_symbol;
ENUM_TIMEFRAMES m_timeframe;

// Array bounds validation
bool ValidateArrayAccess(int index, int arraySize, string operation)
{
if(index < 0 || index >= arraySize)
{
Print(StringFormat("SMC Array bounds violation: Operation=%s, Index=%d, Size=%d", 
operation, index, arraySize));
return false;
}
return true;
}

bool ValidateHistoryAvailability(int requiredBars)
{
int availableBars = Bars(m_symbol, m_timeframe);
if(availableBars < requiredBars)
{
Print(StringFormat("SMC Insufficient history: Required=%d, Available=%d", 
requiredBars, availableBars));
return false;
}
return true;
}

public:
CSMCConsolidated()
{
m_orderBlockCount = 0;
m_liquidityPoolCount = 0;
m_symbol = _Symbol;
m_timeframe = PERIOD_CURRENT;

// Initialize arrays with safe sizes
ArrayResize(m_orderBlocks, 100);
ArrayResize(m_liquidityPools, 50);
}

//+------------------------------------------------------------------+
//| DETECT IMPULSE ORDER BLOCKS - FIXED ARRAY BOUNDS              |
//+------------------------------------------------------------------+
bool DetectImpulseOrderBlock(int startBar, int endBar)
{
// Validate history availability first
if(!ValidateHistoryAvailability(endBar + 10))
{
return false;
}

// Validate bar indices
if(!ValidateArrayAccess(startBar, Bars(m_symbol, m_timeframe), "DetectImpulseOrderBlock_start"))
{
return false;
}

if(!ValidateArrayAccess(endBar, Bars(m_symbol, m_timeframe), "DetectImpulseOrderBlock_end"))
{
return false;
}

// Safe array access with bounds checking
for(int i = startBar; i <= endBar && i < Bars(m_symbol, m_timeframe); i++)
{
if(!ValidateArrayAccess(i, Bars(m_symbol, m_timeframe), "DetectImpulseOrderBlock_loop"))
{
continue;
}

// Safe price data access
double high = iHigh(m_symbol, m_timeframe, i);
double low = iLow(m_symbol, m_timeframe, i);
double open = iOpen(m_symbol, m_timeframe, i);
double close = iClose(m_symbol, m_timeframe, i);
double volume = (double)iVolume(m_symbol, m_timeframe, i);  // Explicit cast to prevent warning

// Check for impulse characteristics
if(IsImpulseCandle(high, low, open, close, volume))
{
// Create order block
if(m_orderBlockCount < ArraySize(m_orderBlocks))
{
m_orderBlocks[m_orderBlockCount].timeStart = iTime(m_symbol, m_timeframe, i);
m_orderBlocks[m_orderBlockCount].timeEnd = iTime(m_symbol, m_timeframe, i);
m_orderBlocks[m_orderBlockCount].high = high;
m_orderBlocks[m_orderBlockCount].low = low;
m_orderBlocks[m_orderBlockCount].open = open;
m_orderBlocks[m_orderBlockCount].close = close;
m_orderBlocks[m_orderBlockCount].volume = volume;
m_orderBlocks[m_orderBlockCount].type = DetermineOrderBlockType(open, close);
m_orderBlocks[m_orderBlockCount].strength = CalculateOrderBlockStrength(high, low, volume);
m_orderBlocks[m_orderBlockCount].isInstitutional = IsInstitutionalVolume(volume);
m_orderBlocks[m_orderBlockCount].isValid = true;

m_orderBlockCount++;

Print(StringFormat("SMC Order Block detected: Type=%d, Strength=%.2f, Institutional=%s",
m_orderBlocks[m_orderBlockCount-1].type,
m_orderBlocks[m_orderBlockCount-1].strength,
m_orderBlocks[m_orderBlockCount-1].isInstitutional ? "YES" : "NO"));
}
}
}

return true;
}

//+------------------------------------------------------------------+
//| DETECT LIQUIDITY POOLS - SAFE IMPLEMENTATION                  |
//+------------------------------------------------------------------+
bool DetectLiquidityPools(int startBar, int endBar)
{
// Validate history availability
if(!ValidateHistoryAvailability(endBar + 10))
{
return false;
}

// Validate bar indices
if(!ValidateArrayAccess(startBar, Bars(m_symbol, m_timeframe), "DetectLiquidityPools_start"))
{
return false;
}

if(!ValidateArrayAccess(endBar, Bars(m_symbol, m_timeframe), "DetectLiquidityPools_end"))
{
return false;
}

// Safe liquidity detection
for(int i = startBar; i <= endBar && i < Bars(m_symbol, m_timeframe); i++)
{
if(!ValidateArrayAccess(i, Bars(m_symbol, m_timeframe), "DetectLiquidityPools_loop"))
{
continue;
}

double high = iHigh(m_symbol, m_timeframe, i);
double low = iLow(m_symbol, m_timeframe, i);

// Check for daily high/low liquidity
if(IsDailyHighLiquidity(i))
{
if(m_liquidityPoolCount < ArraySize(m_liquidityPools))
{
m_liquidityPools[m_liquidityPoolCount].time = iTime(m_symbol, m_timeframe, i);
m_liquidityPools[m_liquidityPoolCount].price = high;
m_liquidityPools[m_liquidityPoolCount].type = LIQUIDITY_BUY;
m_liquidityPools[m_liquidityPoolCount].strength = 0.8;
m_liquidityPools[m_liquidityPoolCount].isValid = true;

m_liquidityPoolCount++;

Print(StringFormat("SMC Liquidity Pool detected: Type=DAILY_HIGH, Price=%.5f", high));
}
}

if(IsDailyLowLiquidity(i))
{
if(m_liquidityPoolCount < ArraySize(m_liquidityPools))
{
m_liquidityPools[m_liquidityPoolCount].time = iTime(m_symbol, m_timeframe, i);
m_liquidityPools[m_liquidityPoolCount].price = low;
m_liquidityPools[m_liquidityPoolCount].type = LIQUIDITY_SELL;
m_liquidityPools[m_liquidityPoolCount].strength = 0.8;
m_liquidityPools[m_liquidityPoolCount].isValid = true;

m_liquidityPoolCount++;

Print(StringFormat("SMC Liquidity Pool detected: Type=DAILY_LOW, Price=%.5f", low));
}
}
}

return true;
}

//+------------------------------------------------------------------+
//| HELPER FUNCTIONS                                               |
//+------------------------------------------------------------------+

bool IsImpulseCandle(double high, double low, double open, double close, double volume)
{
double bodySize = MathAbs(close - open);
double totalRange = high - low;
double averageVolume = GetAverageVolume(20);

// Impulse criteria
bool strongBody = bodySize > totalRange * 0.6;
bool highVolume = volume > averageVolume * 1.5;
bool significantMove = bodySize > GetATR(14) * 0.5;

return strongBody && highVolume && significantMove;
}




private:
ENUM_ORDER_BLOCK_TYPE DetermineOrderBlockType(double open, double close)
{
if(close > open)
return ORDER_BLOCK_BULLISH;
else
return ORDER_BLOCK_BEARISH;
}

double CalculateOrderBlockStrength(double high, double low, double volume)
{
double averageVolume = GetAverageVolume(20);
double volumeRatio = volume / averageVolume;
double priceRange = high - low;
double atr = GetATR(14);
double rangeRatio = priceRange / atr;

return (volumeRatio + rangeRatio) / 2.0;
}

double GetAverageVolume(int period)
{
double total = 0.0;
for(int i = 1; i <= period; i++) {
total += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
return total / period;
}

double GetATR(int period)
{
// Simplified ATR calculation
double total = 0.0;
for(int i = 1; i <= period; i++) {
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
double low = iLow(_Symbol, PERIOD_CURRENT, i);
total += (high - low);
}
return total / period;
}

bool IsInstitutionalVolume(double volume)
{
double avgVolume = GetAverageVolume(20);
return volume > avgVolume * 2.0; // 2x average = institutional
}

bool IsDailyHighLiquidity(int bar)
{
// Check if this is a daily high point
double currentHigh = iHigh(m_symbol, m_timeframe, bar);
double dailyHigh = iHigh(m_symbol, PERIOD_D1, 0);
return MathAbs(currentHigh - dailyHigh) < _Point * 10;
}

bool IsDailyLowLiquidity(int bar)
{
// Check if this is a daily low point
double currentLow = iLow(m_symbol, m_timeframe, bar);
double dailyLow = iLow(m_symbol, PERIOD_D1, 0);
return MathAbs(currentLow - dailyLow) < _Point * 10;
}

//+------------------------------------------------------------------+
//| IMPLEMENTATION PRIORITY 1: MISSING SMC CORE FUNCTIONS          |
//| (per SONIC_R_DEVELOPMENT_REPORT_2025.md)                        |
//+------------------------------------------------------------------+

// BOS (Break of Structure) Detection
bool DetectBOS(ENUM_DIRECTION direction, int lookback = 50)
{
    if(!ValidateHistoryAvailability(lookback + 10)) return false;

    double currentPrice = (direction == DIRECTION_BUY) ?
                         iHigh(m_symbol, m_timeframe, 0) :
                         iLow(m_symbol, m_timeframe, 0);

    // Look for previous structure high/low being broken
    for(int i = 5; i <= lookback; i++) {
        double structureLevel = (direction == DIRECTION_BUY) ?
                               iHigh(m_symbol, m_timeframe, i) :
                               iLow(m_symbol, m_timeframe, i);

        // Check if structure was significant (swing point)
        bool isSwingPoint = IsSwingPoint(i, direction);
        if(!isSwingPoint) continue;

        // Check if current price broke the structure
        if(direction == DIRECTION_BUY && currentPrice > structureLevel) {
            return true; // Bullish BOS
        }
        if(direction == DIRECTION_SELL && currentPrice < structureLevel) {
            return true; // Bearish BOS
        }
    }
    return false;
}

// CHoCH (Change of Character) Detection
bool DetectCHoCH(ENUM_DIRECTION direction, int strength_threshold = 60)
{
    if(!ValidateHistoryAvailability(50)) return false;

    // Look for trend change pattern
    bool previousTrendBullish = IsTrendBullish(10, 30);
    bool currentTrendBullish = IsTrendBullish(1, 10);

    // CHoCH occurs when trend changes direction
    if(direction == DIRECTION_BUY && !previousTrendBullish && currentTrendBullish) {
        return true; // Bullish CHoCH
    }
    if(direction == DIRECTION_SELL && previousTrendBullish && !currentTrendBullish) {
        return true; // Bearish CHoCH
    }

    return false;
}

// Order Block Detection at specific price
bool IsAtOrderBlock(double price, ENUM_DIRECTION direction, double max_distance_pips = 25)
{
    double pipSize = SymbolInfoDouble(m_symbol, SYMBOL_POINT) * 10;
    if(pipSize == 0) return false;

    double maxDistance = max_distance_pips * pipSize;

    // Check existing order blocks
    for(int i = 0; i < m_orderBlockCount; i++) {
        if(!m_orderBlocks[i].isValid) continue;

        // Check if price is within order block range
        bool withinRange = (price >= m_orderBlocks[i].low - maxDistance &&
                           price <= m_orderBlocks[i].high + maxDistance);

        // Check direction compatibility
        bool directionMatch = ((direction == DIRECTION_BUY && m_orderBlocks[i].type == ORDER_BLOCK_BULLISH) ||
                              (direction == DIRECTION_SELL && m_orderBlocks[i].type == ORDER_BLOCK_BEARISH));

        if(withinRange && directionMatch) {
            return true;
        }
    }
    return false;
}

// Fair Value Gap Detection
bool IsFairValueGap(int bar, ENUM_DIRECTION direction)
{
    if(!ValidateArrayAccess(bar + 2, Bars(m_symbol, m_timeframe), "IsFairValueGap")) return false;

    // Get three consecutive candles
    double high1 = iHigh(m_symbol, m_timeframe, bar + 2);
    double low1 = iLow(m_symbol, m_timeframe, bar + 2);
    double high2 = iHigh(m_symbol, m_timeframe, bar + 1);
    double low2 = iLow(m_symbol, m_timeframe, bar + 1);
    double high3 = iHigh(m_symbol, m_timeframe, bar);
    double low3 = iLow(m_symbol, m_timeframe, bar);

    // Check for gap
    if(direction == DIRECTION_BUY) {
        // Bullish FVG: low3 > high1 (gap between candle 1 and 3)
        return low3 > high1;
    } else {
        // Bearish FVG: high3 < low1 (gap between candle 1 and 3)
        return high3 < low1;
    }
}

private:
// Helper function to identify swing points
bool IsSwingPoint(int bar, ENUM_DIRECTION direction)
{
    if(!ValidateArrayAccess(bar + 2, Bars(m_symbol, m_timeframe), "IsSwingPoint")) return false;

    if(direction == DIRECTION_BUY) {
        // Swing high: higher than 2 bars before and after
        double high = iHigh(m_symbol, m_timeframe, bar);
        double prevHigh = iHigh(m_symbol, m_timeframe, bar + 1);
        double nextHigh = iHigh(m_symbol, m_timeframe, bar - 1);
        return (high > prevHigh && high > nextHigh);
    } else {
        // Swing low: lower than 2 bars before and after
        double low = iLow(m_symbol, m_timeframe, bar);
        double prevLow = iLow(m_symbol, m_timeframe, bar + 1);
        double nextLow = iLow(m_symbol, m_timeframe, bar - 1);
        return (low < prevLow && low < nextLow);
    }
}

// Helper function to determine trend direction
bool IsTrendBullish(int startBar, int endBar)
{
    if(!ValidateHistoryAvailability(endBar + 5)) return false;

    double startPrice = iClose(m_symbol, m_timeframe, endBar);
    double endPrice = iClose(m_symbol, m_timeframe, startBar);

    return endPrice > startPrice;
}

};

#endif // SMC_CONSOLIDATED_MQH



