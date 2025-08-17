//+------------------------------------------------------------------+
//|                              Analysis_WavePatternAnalyzer_Enhanced.mqh |
//|                             ?? SONIC R MC - ENHANCED WAVE PATTERN      |
//|                          ? COMPLETE 4-FACTOR WAVE ANALYSIS SYSTEM      |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_WAVE_PATTERN_ANALYZER_ENHANCED_MQH
#define ANALYSIS_WAVE_PATTERN_ANALYZER_ENHANCED_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| ?? ENHANCED WAVE PATTERN DATA STRUCTURE                         |
//+------------------------------------------------------------------+
struct SEnhancedWavePatternData
{
// Core Wave Structure
double waveStructureScore;         // Factor 1: Structure validation (0-1)
double fibonacciScore;            // Factor 2: Fibonacci levels (0-1)
double volumeConfirmationScore;   // Factor 3: Volume confirmation (0-1)
double momentumAlignmentScore;    // Factor 4: Momentum alignment (0-1)

// Wave Metrics
int currentWaveCount;             // Current Elliott wave count
ENUM_WAVE_TYPE currentWaveType;   // Impulse or corrective
double waveStrength;              // Overall wave strength (0-1)
double waveQuality;               // Wave quality assessment (0-1)

// Fibonacci Analysis
double fibRetrace382;             // 38.2% retracement level
double fibRetrace500;             // 50.0% retracement level
double fibRetrace618;             // 61.8% retracement level
double fibExtension1618;          // 161.8% extension level

// Volume Analysis
double avgWaveVolume;             // Average volume during wave
double volumeTrend;               // Volume trend direction
bool volumeConfirmation;          // Volume confirms wave direction

// Momentum Analysis
double waveAngle;                 // Wave angle in degrees
double momentumDivergence;        // Momentum divergence score
bool momentumAlignment;           // Momentum aligns with wave

// Timing Analysis
int waveDuration;                 // Wave duration in bars
double timeRatio;                 // Current vs historical wave time

// Composite Scores
double overallScore;              // Weighted composite score
double confidence;                // Analysis confidence level
bool isValidWave;                 // Wave meets quality criteria

datetime analysisTime;            // Analysis timestamp
int validationFlags;              // Validation status flags

void Reset()
{
waveStructureScore = 0.0;
fibonacciScore = 0.0;
volumeConfirmationScore = 0.0;
momentumAlignmentScore = 0.0;
currentWaveCount = 0;
currentWaveType = WAVE_IMPULSE;
waveStrength = 0.0;
waveQuality = 0.0;
fibRetrace382 = 0.0;
fibRetrace500 = 0.0;
fibRetrace618 = 0.0;
fibExtension1618 = 0.0;
avgWaveVolume = 0.0;
volumeTrend = 0.0;
volumeConfirmation = false;
waveAngle = 0.0;
momentumDivergence = 0.0;
momentumAlignment = false;
waveDuration = 0;
timeRatio = 0.0;
overallScore = 0.0;
confidence = 0.0;
isValidWave = false;
analysisTime = 0;
validationFlags = 0;
}

string GetDetailedReport()
{
return StringFormat(
"?? Wave Analysis | Structure: %.1f%% | Fib: %.1f%% | Volume: %.1f%% | Momentum: %.1f%% | Overall: %.1f%% | Valid: %s",
waveStructureScore * 100,
fibonacciScore * 100,
volumeConfirmationScore * 100,
momentumAlignmentScore * 100,
overallScore * 100,
isValidWave ? "YES" : "NO"
);
}
};

//+------------------------------------------------------------------+
//| ?? ENHANCED WAVE PATTERN ANALYZER CLASS                         |
//+------------------------------------------------------------------+
class CEnhancedWavePatternAnalyzer
{
private:
// Indicator Handles
int                                 m_handleMACD;       // MACD for momentum
int                                 m_handleATR;        // ATR for normalization

// Data Buffers
double                              m_prices[];         // Price history
long                                m_volumes[];        // Volume history
double                              m_macd[];           // MACD values
double                              m_signal[];         // MACD signal
double                              m_atr[];            // ATR values

// Wave Analysis Configuration
string                              m_symbol;
ENUM_TIMEFRAMES                     m_timeframe;
int                                 m_waveDepth;        // Analysis depth
double                              m_fibTolerance;     // Fibonacci tolerance
double                              m_momentumThreshold; // Momentum threshold

// Analysis State
SEnhancedWavePatternData           m_currentAnalysis;
bool                               m_initialized;
datetime                           m_lastUpdate;
int                                m_analysisCount;

// Wave Points Storage
double                              m_waveHigh;         // Current wave high
double                              m_waveLow;          // Current wave low
int                                 m_waveStartBar;     // Wave start bar
int                                 m_waveEndBar;       // Wave end bar

public:
CEnhancedWavePatternAnalyzer()
{
m_handleMACD = INVALID_HANDLE;
m_handleATR = INVALID_HANDLE;

m_symbol = "";
m_timeframe = PERIOD_CURRENT;
m_waveDepth = 50;
m_fibTolerance = 0.05;
m_momentumThreshold = 0.6;

m_initialized = false;
m_lastUpdate = 0;
m_analysisCount = 0;

m_waveHigh = 0.0;
m_waveLow = 0.0;
m_waveStartBar = 0;
m_waveEndBar = 0;

m_currentAnalysis.Reset();

// Initialize dynamic arrays
ArrayResize(m_prices, 100);
ArrayResize(m_volumes, 100);
ArrayResize(m_macd, 50);
ArrayResize(m_signal, 50);
ArrayResize(m_atr, 20);

ArraySetAsSeries(m_prices, true);
ArraySetAsSeries(m_volumes, true);
ArraySetAsSeries(m_macd, true);
ArraySetAsSeries(m_signal, true);
ArraySetAsSeries(m_atr, true);
}

~CEnhancedWavePatternAnalyzer()
{
if(m_handleMACD != INVALID_HANDLE) IndicatorRelease(m_handleMACD);
if(m_handleATR != INVALID_HANDLE) IndicatorRelease(m_handleATR);
}

//+------------------------------------------------------------------+
//| ?? INITIALIZE ENHANCED WAVE ANALYZER                            |
//+------------------------------------------------------------------+
bool Initialize(string symbol = NULL, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
if(symbol == NULL) symbol = _Symbol;

m_symbol = symbol;
m_timeframe = timeframe;

// Create momentum indicators
m_handleMACD = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
m_handleATR = iATR(symbol, timeframe, 14);

if(m_handleMACD == INVALID_HANDLE || m_handleATR == INVALID_HANDLE)
{
Print("? Failed to create wave pattern indicators for symbol: ", symbol);
return false;
}

m_initialized = true;
Print("? Enhanced Wave Pattern Analyzer initialized successfully for ", symbol);
return true;
}

//+------------------------------------------------------------------+
//| ?? MAIN ENHANCED WAVE ANALYSIS                                   |
//+------------------------------------------------------------------+
bool UpdateEnhancedWaveAnalysis()
{
if(!m_initialized) return false;

// Update all indicator buffers
if(!UpdateIndicatorBuffers()) return false;

// ?? FACTOR 1: Wave Structure Validation (25% weight)
AnalyzeWaveStructure();

// ?? FACTOR 2: Fibonacci Retracement Analysis (25% weight)
AnalyzeFibonacciLevels();

// ?? FACTOR 3: Volume Confirmation Analysis (25% weight)
AnalyzeVolumeConfirmation();

// ?? FACTOR 4: Momentum Alignment Analysis (25% weight)
AnalyzeMomentumAlignment();

// Calculate composite scores
CalculateCompositeScores();

// Validate wave quality
ValidateWaveQuality();

m_currentAnalysis.analysisTime = TimeCurrent();
m_lastUpdate = TimeCurrent();
m_analysisCount++;

return true;
}

//+------------------------------------------------------------------+
//| ?? UPDATE INDICATOR BUFFERS                                     |
//+------------------------------------------------------------------+
bool UpdateIndicatorBuffers()
{
// Copy price and volume data
if(CopyClose(m_symbol, m_timeframe, 0, 100, m_prices) < 100) return false;
if(CopyTickVolume(m_symbol, m_timeframe, 0, 100, m_volumes) < 100) return false;

// Copy momentum indicators
if(CopyBuffer(m_handleMACD, 0, 0, 50, m_macd) < 50) return false;
if(CopyBuffer(m_handleMACD, 1, 0, 50, m_signal) < 50) return false;
if(CopyBuffer(m_handleATR, 0, 0, 20, m_atr) < 20) return false;

return true;
}

//+------------------------------------------------------------------+
//| ?? FACTOR 1: WAVE STRUCTURE VALIDATION                          |
//+------------------------------------------------------------------+
void AnalyzeWaveStructure()
{
// Enhanced structural validation with edge case handling
// Identify swing highs and lows
IdentifyWavePoints();

// Calculate wave characteristics
if(m_waveHigh > 0 && m_waveLow > 0)
{
double waveRange = m_waveHigh - m_waveLow;
m_currentAnalysis.waveDuration = m_waveEndBar - m_waveStartBar;

// Calculate wave angle
if(m_currentAnalysis.waveDuration > 0)
{
double slope = waveRange / m_currentAnalysis.waveDuration;
m_currentAnalysis.waveAngle = MathArctan(slope) * 180.0 / M_PI;
}

// Assess wave structure quality
double structureScore = 0.0;

// Factor 1.1: Wave angle strength (0-40%)
double volMultiplier = CalculateVolumeMultiplier(); // New helper function
double adjustedAngle = m_currentAnalysis.waveAngle * volMultiplier;
double angleScore = MathMin(1.0, MathAbs(adjustedAngle) / 45.0);
structureScore += angleScore * 0.4;

// Factor 1.2: Wave duration appropriateness (0-30%)
double durationScore = CalculateDurationScore();
structureScore += durationScore * 0.3;

// Factor 1.3: Wave range significance (0-30%)
double rangeScore = CalculateRangeScore(waveRange);
structureScore += rangeScore * 0.3;

// Add refinement: Multi-timeframe structure confirmation
double mtfScore = CalculateMTFStructureAlignment();
structureScore += mtfScore * 0.2; // 20% weight for MTF

m_currentAnalysis.waveStructureScore = MathMin(1.0, structureScore);
}
else
{
m_currentAnalysis.waveStructureScore = 0.0;
}
}

//+------------------------------------------------------------------+
//| ?? FACTOR 2: FIBONACCI RETRACEMENT ANALYSIS                     |
//+------------------------------------------------------------------+
/**
* @brief Analyzes Fibonacci retracement levels within the current wave
* @details Calculates key Fibonacci levels (38.2%, 50%, 61.8%, 161.8%) and 
*          evaluates price proximity to these levels. Provides 25% weighting
*          to overall wave pattern score.
* @note Implements Boss's specification for advanced Fibonacci analysis
*/
void AnalyzeFibonacciLevels()
{
if(m_waveHigh <= 0 || m_waveLow <= 0)
{
m_currentAnalysis.fibonacciScore = 0.0;
return;
}

double waveRange = m_waveHigh - m_waveLow;
double currentPrice = m_prices[0];

// Calculate key Fibonacci levels
m_currentAnalysis.fibRetrace382 = m_waveHigh - (waveRange * 0.382);
m_currentAnalysis.fibRetrace500 = m_waveHigh - (waveRange * 0.500);
m_currentAnalysis.fibRetrace618 = m_waveHigh - (waveRange * 0.618);
m_currentAnalysis.fibExtension1618 = m_waveHigh + (waveRange * 0.618);

// Calculate Fibonacci score
double fibScore = 0.0;

// Check proximity to key Fibonacci levels
double tolerance = waveRange * m_fibTolerance;

if(MathAbs(currentPrice - m_currentAnalysis.fibRetrace382) <= tolerance)
{
fibScore += 0.3; // 38.2% retracement
}

if(MathAbs(currentPrice - m_currentAnalysis.fibRetrace500) <= tolerance)
{
fibScore += 0.4; // 50% retracement (strongest)
}

if(MathAbs(currentPrice - m_currentAnalysis.fibRetrace618) <= tolerance)
{
fibScore += 0.35; // 61.8% retracement
}

// Bonus for multiple level alignment
int levelCount = 0;
if(MathAbs(currentPrice - m_currentAnalysis.fibRetrace382) <= tolerance) levelCount++;
if(MathAbs(currentPrice - m_currentAnalysis.fibRetrace500) <= tolerance) levelCount++;
if(MathAbs(currentPrice - m_currentAnalysis.fibRetrace618) <= tolerance) levelCount++;

if(levelCount >= 2) fibScore += 0.2; // Bonus for confluence

m_currentAnalysis.fibonacciScore = MathMin(1.0, fibScore);
}

//+------------------------------------------------------------------+
//| ?? FACTOR 3: VOLUME CONFIRMATION ANALYSIS                       |
//+------------------------------------------------------------------+
/**
* @brief Analyzes volume patterns for wave confirmation
* @details Evaluates volume trend alignment, strength, and consistency
*          to confirm wave validity. Provides 25% weighting to overall score.
* @note Higher volume during wave direction confirms institutional participation
*/
void AnalyzeVolumeConfirmation()
{
// Calculate average volume over wave period
long volumeSum = 0;
int waveLength = MathMin(20, ArraySize(m_volumes));

for(int i = 0; i < waveLength; i++)
{
volumeSum += m_volumes[i];
}

m_currentAnalysis.avgWaveVolume = (double)volumeSum / waveLength;

// Analyze volume trend
double recentVolume = (double)(m_volumes[0] + m_volumes[1] + m_volumes[2]) / 3.0;
double olderVolume = (double)(m_volumes[7] + m_volumes[8] + m_volumes[9]) / 3.0;

m_currentAnalysis.volumeTrend = (recentVolume - olderVolume) / olderVolume;

// Calculate volume confirmation score
double volumeScore = 0.0;

// Factor 3.1: Volume trend alignment (50%)
bool isUpWave = (m_prices[0] > m_prices[10]);
bool volumeIncreasing = (m_currentAnalysis.volumeTrend > 0);

if((isUpWave && volumeIncreasing) || (!isUpWave && !volumeIncreasing))
{
volumeScore += 0.5;
m_currentAnalysis.volumeConfirmation = true;
}

// Factor 3.2: Volume strength (30%)
double volumeStrength = MathMin(1.0, recentVolume / m_currentAnalysis.avgWaveVolume);
volumeScore += volumeStrength * 0.3;

// Factor 3.3: Volume consistency (20%)
double volumeConsistency = CalculateVolumeConsistency();
volumeScore += volumeConsistency * 0.2;

m_currentAnalysis.volumeConfirmationScore = MathMin(1.0, volumeScore);
}

//+------------------------------------------------------------------+
//| ?? FACTOR 4: MOMENTUM ALIGNMENT ANALYSIS                        |
//+------------------------------------------------------------------+
void AnalyzeMomentumAlignment()
{
// Calculate momentum alignment score
double momentumScore = 0.0;

// Factor 4.1: RSI alignment (25%)
double rsiScore = CalculateRSIAlignment();
momentumScore += rsiScore * 0.25;

// Factor 4.2: MACD alignment (60%)
double macdScore = CalculateMACDAlignment();
momentumScore += macdScore * 0.60;

// Factor 4.3: Momentum divergence detection (40%)
double divergenceScore = CalculateMomentumDivergence();
momentumScore += divergenceScore * 0.40;

m_currentAnalysis.momentumAlignmentScore = MathMin(1.0, momentumScore);
m_currentAnalysis.momentumAlignment = (momentumScore > m_momentumThreshold);
}

//+------------------------------------------------------------------+
//| ?? HELPER FUNCTIONS                                             |
//+------------------------------------------------------------------+
void IdentifyWavePoints()
{
// Simple swing high/low identification
double high = 0.0, low = DBL_MAX;
int highBar = 0, lowBar = 0;

for(int i = 5; i < 25; i++)
{
if(m_prices[i] > high)
{
high = m_prices[i];
highBar = i;
}

if(m_prices[i] < low)
{
low = m_prices[i];
lowBar = i;
}
}

m_waveHigh = high;
m_waveLow = low;
m_waveStartBar = MathMin(highBar, lowBar);
m_waveEndBar = MathMax(highBar, lowBar);
}

//+------------------------------------------------------------------+
//| IMPLEMENTATION PRIORITY 3: MISSING WAVE PATTERN FUNCTIONS      |
//| (per SONIC_R_DEVELOPMENT_REPORT_2025.md)                        |
//+------------------------------------------------------------------+

// Detect Swing Points (HH, HL, LH, LL)
bool DetectSwingPoints(int lookback = 50)
{
    if(!m_initialized) return false;

    int availableBars = Bars(m_symbol, m_timeframe);
    if(availableBars < lookback + 10) return false;

    // Clear previous swing points
    ArrayResize(m_swingHighs, 0);
    ArrayResize(m_swingLows, 0);

    // Detect swing highs and lows
    for(int i = 5; i < lookback && i < availableBars - 5; i++) {
        if(IsSwingHigh(i)) {
            int newSize = ArraySize(m_swingHighs);
            ArrayResize(m_swingHighs, newSize + 1);
            m_swingHighs[newSize] = i;
        }

        if(IsSwingLow(i)) {
            int newSize = ArraySize(m_swingLows);
            ArrayResize(m_swingLows, newSize + 1);
            m_swingLows[newSize] = i;
        }
    }

    return (ArraySize(m_swingHighs) > 0 || ArraySize(m_swingLows) > 0);
}

// Classify HH/HL/LH/LL Pattern
ENUM_WAVE_PATTERN ClassifyHH_HL_LH_LL()
{
    if(ArraySize(m_swingHighs) < 2 || ArraySize(m_swingLows) < 2) {
        return WAVE_NONE;
    }

    // Get last two swing highs and lows
    int highCount = ArraySize(m_swingHighs);
    int lowCount = ArraySize(m_swingLows);

    double lastHigh = iHigh(m_symbol, m_timeframe, m_swingHighs[highCount-1]);
    double prevHigh = iHigh(m_symbol, m_timeframe, m_swingHighs[highCount-2]);
    double lastLow = iLow(m_symbol, m_timeframe, m_swingLows[lowCount-1]);
    double prevLow = iLow(m_symbol, m_timeframe, m_swingLows[lowCount-2]);

    // Classify pattern
    bool higherHigh = (lastHigh > prevHigh);
    bool higherLow = (lastLow > prevLow);
    bool lowerHigh = (lastHigh < prevHigh);
    bool lowerLow = (lastLow < prevLow);

    // Bullish patterns
    if(higherHigh && higherLow) {
        return WAVE_HH_HL_BULLISH; // Strong uptrend
    }
    if(higherLow && !lowerHigh) {
        return WAVE_HL_BULLISH; // Bullish correction
    }

    // Bearish patterns
    if(lowerHigh && lowerLow) {
        return WAVE_LH_LL_BEARISH; // Strong downtrend
    }
    if(lowerHigh && !higherLow) {
        return WAVE_LH_BEARISH; // Bearish correction
    }

    // Consolidation
    return WAVE_CONSOLIDATION;
}

// Validate Wave Pattern
bool ValidatePattern(ENUM_WAVE_PATTERN pattern)
{
    if(pattern == WAVE_NONE) return false;

    // SYSTEMATIC FIX - Use ATR handle instead of undefined GetATR function
    // Get current market conditions
    double atr = 0.0;
    double atrBuffer[];
    if(CopyBuffer(m_handleATR, 0, 0, 1, atrBuffer) > 0) {
        atr = atrBuffer[0];
    }
    double currentPrice = iClose(m_symbol, m_timeframe, 0);

    // Validate based on pattern type
    switch(pattern) {
        case WAVE_HH_HL_BULLISH:
        case WAVE_HL_BULLISH:
            // Validate bullish pattern
            return ValidateBullishPattern(atr, currentPrice);

        case WAVE_LH_LL_BEARISH:
        case WAVE_LH_BEARISH:
            // Validate bearish pattern
            return ValidateBearishPattern(atr, currentPrice);

        case WAVE_CONSOLIDATION:
            // Validate consolidation pattern
            return ValidateConsolidationPattern(atr, currentPrice);

        default:
            return false;
    }
}

// Get Wave Pattern Strength
double GetWavePatternStrength()
{
    ENUM_WAVE_PATTERN pattern = ClassifyHH_HL_LH_LL();
    if(!ValidatePattern(pattern)) return 0.0;

    double strength = 0.0;

    // Calculate strength based on pattern clarity
    int swingCount = ArraySize(m_swingHighs) + ArraySize(m_swingLows);
    if(swingCount >= 4) {
        strength += 0.3; // Good swing structure
    }

    // SYSTEMATIC FIX - Use correct member names from SEnhancedWavePatternData structure
    // Add momentum confirmation (use momentumAlignment bool and momentumAlignmentScore)
    if(m_currentAnalysis.momentumAlignment && m_currentAnalysis.momentumAlignmentScore > 0.6) {
        strength += 0.4;
    }

    // Add volume confirmation (use volumeConfirmation bool and volumeConfirmationScore)
    if(m_currentAnalysis.volumeConfirmation && m_currentAnalysis.volumeConfirmationScore > 0.5) {
        strength += 0.3;
    }

    return MathMin(1.0, strength);
}

private:
// Arrays to store swing points
int m_swingHighs[];
int m_swingLows[];

// Helper function to detect swing high
bool IsSwingHigh(int bar)
{
    if(bar < 2 || bar >= Bars(m_symbol, m_timeframe) - 2) return false;

    double high = iHigh(m_symbol, m_timeframe, bar);
    double high1 = iHigh(m_symbol, m_timeframe, bar - 1);
    double high2 = iHigh(m_symbol, m_timeframe, bar - 2);
    double high_1 = iHigh(m_symbol, m_timeframe, bar + 1);
    double high_2 = iHigh(m_symbol, m_timeframe, bar + 2);

    return (high > high1 && high > high2 && high > high_1 && high > high_2);
}

// Helper function to detect swing low
bool IsSwingLow(int bar)
{
    if(bar < 2 || bar >= Bars(m_symbol, m_timeframe) - 2) return false;

    double low = iLow(m_symbol, m_timeframe, bar);
    double low1 = iLow(m_symbol, m_timeframe, bar - 1);
    double low2 = iLow(m_symbol, m_timeframe, bar - 2);
    double low_1 = iLow(m_symbol, m_timeframe, bar + 1);
    double low_2 = iLow(m_symbol, m_timeframe, bar + 2);

    return (low < low1 && low < low2 && low < low_1 && low < low_2);
}

// Validate bullish pattern
bool ValidateBullishPattern(double atr, double currentPrice)
{
    if(ArraySize(m_swingLows) < 2) return false;

    int lowCount = ArraySize(m_swingLows);
    double lastLow = iLow(m_symbol, m_timeframe, m_swingLows[lowCount-1]);
    double prevLow = iLow(m_symbol, m_timeframe, m_swingLows[lowCount-2]);

    // Check if higher low is significant
    double lowDifference = lastLow - prevLow;
    return (lowDifference > atr * 0.5); // At least 0.5 ATR difference
}

// Validate bearish pattern
bool ValidateBearishPattern(double atr, double currentPrice)
{
    if(ArraySize(m_swingHighs) < 2) return false;

    int highCount = ArraySize(m_swingHighs);
    double lastHigh = iHigh(m_symbol, m_timeframe, m_swingHighs[highCount-1]);
    double prevHigh = iHigh(m_symbol, m_timeframe, m_swingHighs[highCount-2]);

    // Check if lower high is significant
    double highDifference = prevHigh - lastHigh;
    return (highDifference > atr * 0.5); // At least 0.5 ATR difference
}

// Validate consolidation pattern
bool ValidateConsolidationPattern(double atr, double currentPrice)
{
    if(ArraySize(m_swingHighs) < 1 || ArraySize(m_swingLows) < 1) return false;

    int highCount = ArraySize(m_swingHighs);
    int lowCount = ArraySize(m_swingLows);

    double lastHigh = iHigh(m_symbol, m_timeframe, m_swingHighs[highCount-1]);
    double lastLow = iLow(m_symbol, m_timeframe, m_swingLows[lowCount-1]);

    // Check if range is tight relative to ATR
    double range = lastHigh - lastLow;
    return (range < atr * 2.0); // Range less than 2 ATR indicates consolidation
}

double CalculateDurationScore()
{
// Assess if wave duration is appropriate
int idealDuration = 15; // Ideal wave duration in bars
double durationRatio = (double)m_currentAnalysis.waveDuration / idealDuration;

if(durationRatio >= 0.5 && durationRatio <= 2.0)
{
return 1.0 - MathAbs(1.0 - durationRatio);
}

return 0.3; // Poor duration
}

double CalculateRangeScore(double waveRange)
{
// Assess wave range significance using ATR
if(ArraySize(m_atr) < 5) return 0.5;

double avgATR = (m_atr[0] + m_atr[1] + m_atr[2] + m_atr[3] + m_atr[4]) / 5.0;
double rangeRatio = waveRange / avgATR;

// Significant wave should be at least 2x ATR
return MathMin(1.0, rangeRatio / 2.0);
}

double CalculateVolumeConsistency()
{
// Calculate volume consistency over recent periods
double variance = 0.0;
double mean = 0.0;

// Calculate mean volume
for(int i = 0; i < 10; i++)
{
mean += (double)m_volumes[i];
}
mean /= 10.0;

for(int i = 0; i < 10; i++)
{
double diff = (double)m_volumes[i] - mean;
variance += diff * diff;
}

variance /= 10.0;
double consistency = 1.0 / (1.0 + variance / (mean * mean));

return consistency;
}

//+------------------------------------------------------------------+
//| ?? VOLUME MULTIPLIER CALCULATION                                |
//+------------------------------------------------------------------+
double CalculateVolumeMultiplier()
{
// Calculate volume multiplier based on recent volume vs average
double recentVolume = (double)(m_volumes[0] + m_volumes[1] + m_volumes[2]) / 3.0;
double avgVolume = 0.0;

// Calculate average volume over longer period
for(int i = 0; i < 10; i++)
{
avgVolume += (double)m_volumes[i];
}
avgVolume /= 10.0;

// Calculate multiplier (1.0 = normal volume, >1.0 = high volume, <1.0 = low volume)
double multiplier = 1.0;
if(avgVolume > 0)
{
multiplier = recentVolume / avgVolume;
}

// Clamp multiplier to reasonable range
multiplier = MathMax(0.5, MathMin(2.0, multiplier));

return multiplier;
}

double CalculateRSIAlignment()
{
// RSI removed - return neutral score
return 0.5; // Neutral alignment
}

double CalculateMACDAlignment()
{
bool isUpWave = (m_prices[0] > m_prices[10]);
bool macdBullish = (m_macd[0] > m_signal[0]);

if((isUpWave && macdBullish) || (!isUpWave && !macdBullish))
{
double macdStrength = MathAbs(m_macd[0] - m_signal[0]);
return MathMin(1.0, macdStrength * 1000.0); // Normalize
}

return 0.1; // Poor alignment
}

double CalculateStochasticAlignment()
{
// Stochastic removed - return neutral score
return 0.5; // Neutral alignment
}

double CalculateMomentumDivergence()
{
// Simplified divergence detection (RSI removed)
bool priceHigher = (m_prices[0] > m_prices[5]);
bool macdHigher = (m_macd[0] > m_macd[5]);

// Positive for convergence, negative for divergence
int alignmentCount = 0;
if(priceHigher == macdHigher) alignmentCount++;

return (double)alignmentCount; // Return 0 or 1
}

// New helper function
double CalculateMTFStructureAlignment() {
    // Multi-timeframe structure alignment check
    double alignmentScore = 0.0;
    
    // Check H1 timeframe alignment
    if(m_timeframe <= PERIOD_H1) {
        double h1High = iHigh(m_symbol, PERIOD_H1, 0);
        double h1Low = iLow(m_symbol, PERIOD_H1, 0);
        double h1Close = iClose(m_symbol, PERIOD_H1, 0);
        double h1Open = iOpen(m_symbol, PERIOD_H1, 0);
        
        // Check if current trend aligns with H1
        bool h1Bullish = (h1Close > h1Open);
        bool currentBullish = (m_prices[0] > m_prices[1]);
        
        if(h1Bullish == currentBullish) {
            alignmentScore += 0.4; // 40% for trend alignment
        }
        
        // Check if price is within H1 range
        if(m_prices[0] >= h1Low && m_prices[0] <= h1High) {
            alignmentScore += 0.3; // 30% for being within range
        }
    }
    
    // Check H4 timeframe alignment for stronger confirmation
    if(m_timeframe <= PERIOD_H4) {
        double h4High = iHigh(m_symbol, PERIOD_H4, 0);
        double h4Low = iLow(m_symbol, PERIOD_H4, 0);
        double h4MA = iMA(m_symbol, PERIOD_H4, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
        
        // Check position relative to H4 MA
        if((m_prices[0] > h4MA && m_waveHigh > h4MA) || 
           (m_prices[0] < h4MA && m_waveLow < h4MA)) {
            alignmentScore += 0.3; // 30% for MA alignment
        }
    }
    
    return MathMin(1.0, alignmentScore);
}

//+------------------------------------------------------------------+
//| ?? COMPOSITE SCORING                                            |
//+------------------------------------------------------------------+
void CalculateCompositeScores()
{
// Calculate weighted composite score (4-factor system)
m_currentAnalysis.overallScore = 
(m_currentAnalysis.waveStructureScore * 0.25) +
(m_currentAnalysis.fibonacciScore * 0.25) +
(m_currentAnalysis.volumeConfirmationScore * 0.25) +
(m_currentAnalysis.momentumAlignmentScore * 0.25);

// Calculate confidence based on score distribution
double scoreVariance = CalculateScoreVariance();
m_currentAnalysis.confidence = 1.0 - scoreVariance;

// Calculate overall wave strength
m_currentAnalysis.waveStrength = m_currentAnalysis.overallScore;

// Quality assessment
m_currentAnalysis.waveQuality = (m_currentAnalysis.overallScore + m_currentAnalysis.confidence) / 2.0;
}

double CalculateScoreVariance()
{
double scores[4] = {
m_currentAnalysis.waveStructureScore,
m_currentAnalysis.fibonacciScore,
m_currentAnalysis.volumeConfirmationScore,
m_currentAnalysis.momentumAlignmentScore
};

double mean = m_currentAnalysis.overallScore;
double variance = 0.0;

for(int i = 0; i < 4; i++)
{
double diff = scores[i] - mean;
variance += diff * diff;
}

return variance / 4.0;
}

//+------------------------------------------------------------------+
//| ?? POST ENTRY CONFIRMATION                                      |
//+------------------------------------------------------------------+
bool PostEntryConfirmation()
{
// Check if current wave analysis supports entry confirmation
// This is a placeholder implementation - should be enhanced with actual confirmation logic
bool priceInRange = (m_prices[0] >= m_waveLow && m_prices[0] <= m_waveHigh);
bool volumeSupportive = (m_volumes[0] > m_volumes[1]); // Recent volume increasing
bool momentumAligned = (m_macd[0] > m_signal[0]); // MACD bullish

// Basic confirmation criteria
bool basicConfirmation = priceInRange && volumeSupportive && momentumAligned;

// Additional confirmation based on wave quality
bool qualityConfirmation = (m_currentAnalysis.waveQuality > 0.6);

return basicConfirmation && qualityConfirmation;
}

void ValidateWaveQuality()
{
// Validation criteria
bool structureOK = (m_currentAnalysis.waveStructureScore > 0.5);
bool fibonacciOK = (m_currentAnalysis.fibonacciScore > 0.3);
bool volumeOK = (m_currentAnalysis.volumeConfirmationScore > 0.4);
bool momentumOK = (m_currentAnalysis.momentumAlignmentScore > 0.5);
bool overallOK = (m_currentAnalysis.overallScore > 0.6);

// In ValidateWaveQuality, add post-confirm
bool postConfirm = PostEntryConfirmation(); // New function
m_currentAnalysis.isValidWave = structureOK && fibonacciOK && volumeOK && momentumOK && overallOK && postConfirm;

// Set validation flags
m_currentAnalysis.validationFlags = 0;
if(structureOK) m_currentAnalysis.validationFlags |= 1;
if(fibonacciOK) m_currentAnalysis.validationFlags |= 2;
if(volumeOK) m_currentAnalysis.validationFlags |= 4;
if(momentumOK) m_currentAnalysis.validationFlags |= 8;
if(overallOK) m_currentAnalysis.validationFlags |= 16;
}

//+------------------------------------------------------------------+
//| ?? PUBLIC ACCESS METHODS                                        |
//+------------------------------------------------------------------+
SEnhancedWavePatternData GetCurrentAnalysis() { return m_currentAnalysis; }
double GetWavePatternScore() { return m_currentAnalysis.overallScore; }
bool IsValidWave() { return m_currentAnalysis.isValidWave; }
double GetWaveStrength() { return m_currentAnalysis.waveStrength; }
double GetConfidence() { return m_currentAnalysis.confidence; }
bool IsInitialized() { return m_initialized; }

string GetDetailedReport()
{
return m_currentAnalysis.GetDetailedReport();
}
};

#endif // ANALYSIS_WAVE_PATTERN_ANALYZER_ENHANCED_MQH


