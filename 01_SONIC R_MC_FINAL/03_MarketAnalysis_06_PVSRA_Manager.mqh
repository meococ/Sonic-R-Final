//+------------------------------------------------------------------+
//|                                     Analysis_PVSRAManager.mqh    |
//|                        SONIC R MC - PVSRA MANAGER               |
//|                    Ð?i Bàng Enhanced - PVSRA Analysis            |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Ð?i Bàng Enhanced"
#property version   "1.00"

#ifndef ANALYSIS_PVSRA_MANAGER_MQH
#define ANALYSIS_PVSRA_MANAGER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| PVSRA Manager Class                                              |
//+------------------------------------------------------------------+
class CPVSRAManager
{
private:
bool                    m_initialized;
string                  m_symbol;
ENUM_TIMEFRAMES        m_timeframe;

// PVSRA Analysis data
double                  m_currentPVSRAScore;
ENUM_SIGNAL_TYPE       m_lastSignal;
datetime               m_lastAnalysisTime;
int                    m_analysisCount;

// Volume analysis
double                  m_averageVolume;
double                  m_volumeThreshold;

// Array bounds validation

public:
CPVSRAManager()
{
m_initialized = false;
m_symbol = "";
m_timeframe = PERIOD_CURRENT;
m_currentPVSRAScore = 0.0;
m_lastSignal = SIGNAL_NONE;
m_lastAnalysisTime = 0;
m_analysisCount = 0;
m_averageVolume = 0.0;
m_volumeThreshold = 1.5;
}

~CPVSRAManager()
{
Deinitialize();
}

// Utility Methods
bool                   IsInitialized() { return m_initialized; }
string                 GetSymbol() { return m_symbol; }
ENUM_TIMEFRAMES       GetTimeframe() { return m_timeframe; }

bool Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
{
if(m_initialized) return true;

if(symbol == "" || symbol == NULL) {
symbol = _Symbol;
}

m_symbol = symbol;
m_timeframe = timeframe;

// Calculate average volume
double totalVolume = 0.0;
int volumePeriod = 20;

for(int i = 1; i <= volumePeriod; i++) {
totalVolume += (double)iVolume(m_symbol, m_timeframe, i);
}

m_averageVolume = totalVolume / volumePeriod;
m_lastAnalysisTime = TimeCurrent();

m_initialized = true;
return true;
}

void Deinitialize()
{
m_initialized = false;
}

bool UpdatePVSRAAnalysis()
{
if(!m_initialized) return false;

if(!ValidateArrayBounds(m_timeframe, 2)) return false;

// Calculate current PVSRA score
m_currentPVSRAScore = CalculateCandleScore(1);

// Determine signal based on PVSRA analysis
if(m_currentPVSRAScore > 0.7 && IsPVSRACandle(1)) {
double open = iOpen(m_symbol, m_timeframe, 1);
double close = iClose(m_symbol, m_timeframe, 1);

if(close > open) {
m_lastSignal = SIGNAL_BUY;
} else {
m_lastSignal = SIGNAL_SELL;
}
} else {
m_lastSignal = SIGNAL_NONE;
}

m_lastAnalysisTime = TimeCurrent();
m_analysisCount++;

return true;
}

double GetPVSRAScore()
{
return m_currentPVSRAScore;
}

ENUM_SIGNAL_TYPE GetPVSRASignal()
{
return m_lastSignal;
}

bool IsPVSRACandle(int shift = 0)
{
if(!m_initialized) return false;

// Check if candle has high volume and significant price action
bool highVolume = IsHighVolumeCandle(shift);
double candleScore = CalculateCandleScore(shift);

return (highVolume && candleScore > 0.6);
}

double CalculateCandleScore(int shift = 0)
{
if(!m_initialized) return 0.0;

// ?? CRITICAL FIX: Safe shift calculation d? tránh array bounds error
int totalBars = iBars(m_symbol, m_timeframe);
int safeShift = MathMin(shift, totalBars - 5); // Ð?m b?o có ít nh?t 5 bars buffer

if(safeShift < 0) {
Print("? [PVSRA] Not enough bars for analysis, using fallback score");
return 0.2; // Fallback score thay vì 0
}

// Validate array bounds v?i safe shift
if(!ValidateArrayBounds(m_timeframe, safeShift + 1)) {
Print("? [PVSRA] Array bounds validation failed, using safe fallback");
return 0.2; // Fallback score
}

double open = iOpen(m_symbol, m_timeframe, safeShift);
double high = iHigh(m_symbol, m_timeframe, safeShift);
double low = iLow(m_symbol, m_timeframe, safeShift);
double close = iClose(m_symbol, m_timeframe, safeShift);
long volume = iVolume(m_symbol, m_timeframe, safeShift);

// Calculate candle body and range
double body = MathAbs(close - open);
double range = high - low;
double bodyRatio = (range > 0) ? body / range : 0.0;

// Calculate volume score
double volumeScore = (m_averageVolume > 0) ? (double)volume / m_averageVolume : 1.0;
volumeScore = MathMin(volumeScore / 2.0, 1.0); // Normalize to 0-1

// Combine factors
double score = (bodyRatio * 0.6 + volumeScore * 0.4);
return MathMin(score, 1.0);
}

// Volume Analysis
bool IsHighVolumeCandle(int shift = 0)
{
if(!m_initialized) return false;

// ?? CRITICAL FIX: Safe shift calculation
int totalBars = iBars(m_symbol, m_timeframe);
int safeShift = MathMin(shift, totalBars - 2);

if(safeShift < 0) {
return false; // Safe fallback
}

long volume = iVolume(m_symbol, m_timeframe, safeShift);
return ((double)volume > m_averageVolume * m_volumeThreshold);
}

double GetVolumeRatio(int shift = 0)
{
if(!m_initialized) return 1.0;

// ?? CRITICAL FIX: Safe shift calculation
int totalBars = iBars(m_symbol, m_timeframe);
int safeShift = MathMin(shift, totalBars - 2);

if(safeShift < 0) {
return 1.0; // Safe fallback
}

long volume = iVolume(m_symbol, m_timeframe, safeShift);
return (m_averageVolume > 0) ? (double)volume / m_averageVolume : 1.0;
}

// Validate Array Bounds - ENHANCED WITH BETTER ERROR HANDLING
bool ValidateArrayBounds(ENUM_TIMEFRAMES tf, int requiredBars)
{
    int totalBars = iBars(m_symbol, tf);
    if(totalBars < requiredBars) {
        Print(StringFormat("[ARRAY BOUNDS] Not enough bars: %d/%d for %s", totalBars, requiredBars, TimeframeToString(tf)));
        return false;
    }

    // ?? CRITICAL FIX: Thêm ki?m tra buffer safety
    if(totalBars < 10) {
        Print(StringFormat("[ARRAY BOUNDS] Insufficient data buffer: %d bars", totalBars));
        return false;
    }

    return true;
}

// Unified facade for external modules to fetch a consistent PVSRA score
// Prefer using the manager's safe scoring routine; minimal overhead with static instance
double GetUnifiedPVSRAScore(const string symbol=NULL, ENUM_TIMEFRAMES tf=PERIOD_CURRENT, int shift=1)
{
    static CPVSRAManager s_mgr;
    static string s_sym = "";
    static ENUM_TIMEFRAMES s_tf = PERIOD_CURRENT;
    string useSym = (symbol==NULL || symbol=="") ? _Symbol : symbol;
    ENUM_TIMEFRAMES useTf = tf;
    if(!s_mgr.IsInitialized() || s_sym!=useSym || s_tf!=useTf)
    {
        s_mgr.Deinitialize();
        s_mgr.Initialize(useSym, useTf);
        s_sym = useSym; s_tf = useTf;
    }
    // Update internal state (graceful if already fresh)
    s_mgr.UpdatePVSRAAnalysis();
    // Use the manager's candle score at requested shift to ensure alignment with caches
    double sc = s_mgr.CalculateCandleScore(shift);
    if(sc<0.0) sc=0.0; if(sc>1.0) sc=1.0;
    return sc;
}

};

//+------------------------------------------------------------------+
//| Global PVSRA score wrapper (single source of truth)              |
//+------------------------------------------------------------------+
/**
 * @brief Get unified PVSRA score (0.0 - 1.0) with safe guards
 */
double GetVPSRAScore(const string symbol=NULL, ENUM_TIMEFRAMES tf=PERIOD_CURRENT, int shift=1)
{
	static CPVSRAManager s_mgr;
	static string s_sym = "";
	static ENUM_TIMEFRAMES s_tf = PERIOD_CURRENT;

	string useSym = (symbol==NULL || symbol=="") ? _Symbol : symbol;
	ENUM_TIMEFRAMES useTf = tf;

	if(!s_mgr.IsInitialized() || s_sym!=useSym || s_tf!=useTf)
	{
		s_mgr.Deinitialize();
		s_mgr.Initialize(useSym, useTf);
		s_sym = useSym; s_tf = useTf;
	}

	// Refresh internal analysis state (graceful if already fresh)
	s_mgr.UpdatePVSRAAnalysis();

	// Use manager's safe scoring routine for the requested shift
	double sc = s_mgr.CalculateCandleScore(shift);
	if(sc<0.0) sc=0.0; if(sc>1.0) sc=1.0;
	return sc;
}

#endif // ANALYSIS_PVSRA_MANAGER_MQH


