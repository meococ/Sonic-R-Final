//+------------------------------------------------------------------+
//|                                      Analysis_FairValueGaps.mqh |
//|                           Sonic R MC - Fair Value Gap Analysis |
//|                     ?? PROFESSIONAL FAIR VALUE GAP DETECTOR     |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team"
#property version   "1.00"

#ifndef ANALYSIS_FAIRVALUEGAPS_MQH
#define ANALYSIS_FAIRVALUEGAPS_MQH

// ?? CRITICAL FIX: Add missing MQL5 includes for linter errors
// CONSOLIDATED: #include <Trade/Trade.mqh>
#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| ?? FAIR VALUE GAP STRUCTURE                                     |
//+------------------------------------------------------------------+
struct SFairValueGap
{
double high;
double low;
datetime time;
bool is_filled;
bool is_bullish;
double strength;               // Gap strength 0.0-1.0
int bar_index;                // Bar where gap was formed
double fill_percentage;       // How much of gap is filled (0.0-1.0)

void Reset()
{
high = 0.0;
low = 0.0;
time = 0;
is_filled = false;
is_bullish = false;
strength = 0.0;
bar_index = -1;
fill_percentage = 0.0;
}

string ToString()
{
return StringFormat("FVG: %s | %.5f-%.5f | Strength: %.2f | Filled: %s",
is_bullish ? "BULL" : "BEAR",
low, high, strength,
is_filled ? "YES" : "NO");
}
};

//+------------------------------------------------------------------+
//| ?? FAIR VALUE GAP DETECTOR CLASS                               |
//+------------------------------------------------------------------+
class CFairValueGaps
{
private:
SFairValueGap m_gaps[];
int m_gap_count;
int m_max_gaps;
string m_symbol;
ENUM_TIMEFRAMES m_timeframe;
double m_min_gap_size;         // Minimum gap size in points
int m_lookback_bars;           // How many bars to analyze

public:
CFairValueGaps()
{
m_gap_count = 0;
m_max_gaps = 100;
m_symbol = _Symbol;
m_timeframe = PERIOD_CURRENT;
m_min_gap_size = 10.0;     // 10 points minimum
m_lookback_bars = 500;
ArrayResize(m_gaps, m_max_gaps);
}

~CFairValueGaps()
{
ArrayFree(m_gaps);
}

//+------------------------------------------------------------------+
//| ?? INITIALIZATION                                               |
//+------------------------------------------------------------------+
bool Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
if(symbol != "") m_symbol = symbol;
if(timeframe != PERIOD_CURRENT) m_timeframe = timeframe;

// Validate symbol
if(!SymbolSelect(m_symbol, true))
{
Print("? Failed to select symbol: ", m_symbol);
return false;
}

Print(StringFormat("? Fair Value Gap Detector initialized for %s %s", 
m_symbol, EnumToString(m_timeframe)));

return true;
}

void Deinitialize()
{
ArrayFree(m_gaps);
m_gap_count = 0;
Print("?? Fair Value Gap Detector deinitialized");
}

//+------------------------------------------------------------------+
//| ?? GAP DETECTION METHODS                                        |
//+------------------------------------------------------------------+
bool DetectGaps()
{
if(Bars(m_symbol, m_timeframe) < m_lookback_bars)
{
Print("?? Insufficient bars for FVG detection");
return false;
}

// Clear existing gaps
ClearOldGaps();

// Detect new gaps
int detected = 0;
for(int i = 2; i < m_lookback_bars - 1; i++)
{
if(DetectGapAtBar(i))
{
detected++;
}
}

// Update gap fill status
UpdateGapFillStatus();

Print(StringFormat("?? Detected %d new fair value gaps", detected));
return true;
}

bool DetectGapAtBar(int bar_index)
{
// Get OHLC data for 3 consecutive bars
double high1 = iHigh(m_symbol, m_timeframe, bar_index + 1);
double low1 = iLow(m_symbol, m_timeframe, bar_index + 1);

double high2 = iHigh(m_symbol, m_timeframe, bar_index);
double low2 = iLow(m_symbol, m_timeframe, bar_index);

double high3 = iHigh(m_symbol, m_timeframe, bar_index - 1);
double low3 = iLow(m_symbol, m_timeframe, bar_index - 1);

// Check for bullish FVG: low3 > high1
if(low3 > high1)
{
double gap_size = (low3 - high1) / _Point;
if(gap_size >= m_min_gap_size)
{
return AddGap(high1, low3, iTime(m_symbol, m_timeframe, bar_index), true, gap_size, bar_index);
}
}

// Check for bearish FVG: high3 < low1
if(high3 < low1)
{
double gap_size = (low1 - high3) / _Point;
if(gap_size >= m_min_gap_size)
{
return AddGap(high3, low1, iTime(m_symbol, m_timeframe, bar_index), false, gap_size, bar_index);
}
}

return false;
}

bool AddGap(double low, double high, datetime time, bool is_bullish, double gap_size, int bar_index)
{
if(m_gap_count >= m_max_gaps)
{
// Remove oldest gap to make room
RemoveOldestGap();
}

m_gaps[m_gap_count].low = low;
m_gaps[m_gap_count].high = high;
m_gaps[m_gap_count].time = time;
m_gaps[m_gap_count].is_bullish = is_bullish;
m_gaps[m_gap_count].is_filled = false;
m_gaps[m_gap_count].strength = CalculateGapStrength(gap_size);
m_gaps[m_gap_count].bar_index = bar_index;
m_gaps[m_gap_count].fill_percentage = 0.0;

m_gap_count++;

Print(StringFormat("? Added %s FVG: %.5f-%.5f (Strength: %.2f)",
is_bullish ? "BULLISH" : "BEARISH",
low, high, m_gaps[m_gap_count-1].strength));

return true;
}

double CalculateGapStrength(double gap_size)
{
// Simple strength calculation based on gap size
// Normalize to 0.0-1.0 range
double max_expected_gap = 100.0; // 100 points
return MathMin(1.0, gap_size / max_expected_gap);
}

//+------------------------------------------------------------------+
//| ?? GAP ANALYSIS METHODS                                         |
//+------------------------------------------------------------------+
bool IsFVGLevel(double price, double tolerance = 10.0)
{
double tolerance_points = tolerance * _Point;

// Check if price is near any unfilled FVG
for(int i = 0; i < m_gap_count; i++)
{
if(!m_gaps[i].is_filled)
{
if(price >= m_gaps[i].low - tolerance_points && 
price <= m_gaps[i].high + tolerance_points)
{
return true;
}
}
}
return false;
}

double GetNearestFVGLevel(double price, bool bullish_only = false, bool bearish_only = false)
{
double nearest_level = 0.0;
double min_distance = DBL_MAX;

for(int i = 0; i < m_gap_count; i++)
{
if(m_gaps[i].is_filled) continue;

// Filter by type if requested
if(bullish_only && !m_gaps[i].is_bullish) continue;
if(bearish_only && m_gaps[i].is_bullish) continue;

// Calculate distance to gap center
double gap_center = (m_gaps[i].high + m_gaps[i].low) / 2.0;
double distance = MathAbs(price - gap_center);

if(distance < min_distance)
{
min_distance = distance;
nearest_level = gap_center;
}
}

return nearest_level;
}

int GetUnfilledGapCount(bool bullish_only = false, bool bearish_only = false)
{
int count = 0;

for(int i = 0; i < m_gap_count; i++)
{
if(m_gaps[i].is_filled) continue;

if(bullish_only && !m_gaps[i].is_bullish) continue;
if(bearish_only && m_gaps[i].is_bullish) continue;

count++;
}

return count;
}

//+------------------------------------------------------------------+
//| ?? GAP MAINTENANCE                                              |
//+------------------------------------------------------------------+
void UpdateGapFillStatus()
{
double current_price = SymbolInfoDouble(m_symbol, SYMBOL_BID);

for(int i = 0; i < m_gap_count; i++)
{
if(m_gaps[i].is_filled) continue;

// Check if gap is filled
if(current_price >= m_gaps[i].low && current_price <= m_gaps[i].high)
{
m_gaps[i].is_filled = true;
m_gaps[i].fill_percentage = 1.0;

Print(StringFormat("? FVG FILLED: %s gap at %.5f-%.5f",
m_gaps[i].is_bullish ? "BULLISH" : "BEARISH",
m_gaps[i].low, m_gaps[i].high));
}
else
{
// Calculate partial fill percentage
if(m_gaps[i].is_bullish)
{
// For bullish gaps, check how much price has moved up into the gap
if(current_price > m_gaps[i].low)
{
double gap_range = m_gaps[i].high - m_gaps[i].low;
double filled_range = MathMin(current_price - m_gaps[i].low, gap_range);
m_gaps[i].fill_percentage = filled_range / gap_range;
}
}
else
{
// For bearish gaps, check how much price has moved down into the gap
if(current_price < m_gaps[i].high)
{
double gap_range = m_gaps[i].high - m_gaps[i].low;
double filled_range = MathMin(m_gaps[i].high - current_price, gap_range);
m_gaps[i].fill_percentage = filled_range / gap_range;
}
}
}
}
}

void ClearOldGaps()
{
// Remove gaps older than a certain period
datetime cutoff_time = TimeCurrent() - (7 * 24 * 3600); // 7 days

for(int i = m_gap_count - 1; i >= 0; i--)
{
if(m_gaps[i].time < cutoff_time)
{
RemoveGapAtIndex(i);
}
}
}

void RemoveOldestGap()
{
if(m_gap_count == 0) return;

// Find oldest gap
int oldest_index = 0;
datetime oldest_time = m_gaps[0].time;

for(int i = 1; i < m_gap_count; i++)
{
if(m_gaps[i].time < oldest_time)
{
oldest_time = m_gaps[i].time;
oldest_index = i;
}
}

RemoveGapAtIndex(oldest_index);
}

void RemoveGapAtIndex(int index)
{
if(index < 0 || index >= m_gap_count) return;

// Shift remaining gaps
for(int i = index; i < m_gap_count - 1; i++)
{
m_gaps[i] = m_gaps[i + 1];
}

m_gap_count--;
}

//+------------------------------------------------------------------+
//| ?? REPORTING METHODS                                            |
//+------------------------------------------------------------------+
string GetGapReport()
{
string report = StringFormat("?? FAIR VALUE GAP REPORT (%s)\n", m_symbol);
report += StringFormat("Total Gaps: %d | Unfilled: %d\n", 
m_gap_count, GetUnfilledGapCount());
report += StringFormat("Bullish Unfilled: %d | Bearish Unfilled: %d\n",
GetUnfilledGapCount(true, false),
GetUnfilledGapCount(false, true));

// List recent gaps
report += "Recent Gaps:\n";
int shown = 0;
for(int i = m_gap_count - 1; i >= 0 && shown < 5; i--)
{
report += "  " + m_gaps[i].ToString() + "\n";
shown++;
}

return report;
}

// Getters
int GetGapCount() { return m_gap_count; }
SFairValueGap GetGap(int index) { return (index >= 0 && index < m_gap_count) ? m_gaps[index] : SFairValueGap(); }

// Configuration setters
void SetMinGapSize(double min_size) { m_min_gap_size = min_size; }
void SetLookbackBars(int bars) { m_lookback_bars = bars; }
void SetMaxGaps(int max_gaps) 
{ 
m_max_gaps = max_gaps; 
ArrayResize(m_gaps, m_max_gaps);
}
};

#endif // ANALYSIS_FAIRVALUEGAPS_MQH 


