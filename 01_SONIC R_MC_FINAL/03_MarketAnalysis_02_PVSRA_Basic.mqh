//+------------------------------------------------------------------+
//|                                    Analysis_EnhancedPVSRA.mqh   |
//|                     ?? TASK 4: ENHANCED PVSRA & WYCKOFF        |
//|                         Advanced Market Maker Analysis          |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - �?i B�ng Enhanced"
#property version   "2.00"

#ifndef ANALYSIS_ENHANCED_PVSRA_MQH
#define ANALYSIS_ENHANCED_PVSRA_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| ENHANCED WYCKOFF PHASE DETECTION                                |
//+------------------------------------------------------------------+

struct SWyckoffPattern
{
ENUM_WYCKOFF_PHASE phase;
double confidence;           // 0.0-1.0 confidence in phase
datetime phaseStartTime;
int phaseBarCount;
double volumeCharacteristic; // Average volume during phase
double priceRange;          // Price range during phase
bool hasSpring;             // Spring pattern detected
bool hasUpthrust;           // Upthrust pattern detected
double springPrice;         // Price level of spring
double upthrustPrice;       // Price level of upthrust

void Reset()
{
phase = WYCKOFF_UNKNOWN;
confidence = 0.0;
phaseStartTime = 0;
phaseBarCount = 0;
volumeCharacteristic = 0.0;
priceRange = 0.0;
hasSpring = false;
hasUpthrust = false;
springPrice = 0.0;
upthrustPrice = 0.0;
}

string ToString()
{
return StringFormat("Phase: %s | Confidence: %.1f%% | Duration: %d bars%s%s",
WyckoffPhaseToString(phase), confidence*100, phaseBarCount,
hasSpring ? " | SPRING" : "",
hasUpthrust ? " | UPTHRUST" : "");
}
};

//+------------------------------------------------------------------+
//| ?? WYCKOFF ANALYZER - INSTITUTIONAL INTELLIGENCE                |
//+------------------------------------------------------------------+
class CWyckoffAnalyzer
{
private:
ENUM_WYCKOFF_PHASE m_currentPhase;
datetime m_phaseStartTime;
double m_phaseConfidence;
int m_phaseBarCount;

// Volume analysis
double m_averageVolume50;
double m_volumeVariance;
double m_priceRangeVariance;

// Current pattern storage
ENUM_WYCKOFF_PHASE m_currentPatternPhase;
double m_currentPatternConfidence;
datetime m_currentPatternStartTime;
int m_currentPatternBarCount;
double m_currentVolumeCharacteristic;
double m_currentPriceRange;
bool m_currentHasSpring;
bool m_currentHasUpthrust;
double m_currentSpringPrice;
double m_currentUpthrustPrice;

// Pattern history count
int m_patternHistoryCount;

// Thresholds
double m_volumeVarianceThreshold;
double m_priceVarianceThreshold;
double m_springConfidenceThreshold;

public:
CWyckoffAnalyzer()
{
m_currentPhase = PHASE_UNKNOWN;
m_phaseStartTime = 0;
m_phaseConfidence = 0.0;
m_phaseBarCount = 0;
m_averageVolume50 = 0.0;
m_volumeVariance = 0.0;
m_priceRangeVariance = 0.0;
m_patternHistoryCount = 0;
m_volumeVarianceThreshold = 0.3;
m_priceVarianceThreshold = 0.2;
m_springConfidenceThreshold = 0.7;

// Initialize current pattern
m_currentPatternPhase = PHASE_UNKNOWN;
m_currentPatternConfidence = 0.0;
m_currentPatternStartTime = 0;
m_currentPatternBarCount = 0;
m_currentVolumeCharacteristic = 0.0;
m_currentPriceRange = 0.0;
m_currentHasSpring = false;
m_currentHasUpthrust = false;
m_currentSpringPrice = 0.0;
m_currentUpthrustPrice = 0.0;
}

~CWyckoffAnalyzer()
{
// No cleanup needed for primitive types
}

//+------------------------------------------------------------------+
//| ?? WYCKOFF PHASE DETECTION METHODS                             |
//+------------------------------------------------------------------+
ENUM_WYCKOFF_PHASE GetMarketMakerPhase()
{
return m_currentPhase;
}

bool ShouldBlockSignals()
{
// Block signals during uncertain phases
return (m_currentPhase == WYCKOFF_UNKNOWN || m_phaseConfidence < 0.3);
}

bool IsSpringSetup()
{
return m_currentHasSpring;
}

bool IsUpthrustSetup()
{
return m_currentHasUpthrust;
}

string GetPhaseReport()
{
    string phaseStr = "";
    switch(m_currentPatternPhase) {
        case WYCKOFF_ACCUMULATION: phaseStr = "ACCUMULATION"; break;
        case WYCKOFF_MARKUP: phaseStr = "MARKUP"; break;
        case WYCKOFF_DISTRIBUTION: phaseStr = "DISTRIBUTION"; break;
        case WYCKOFF_MARKDOWN: phaseStr = "MARKDOWN"; break;
        default: phaseStr = "UNKNOWN"; break;
    }

    return StringFormat("Phase: %s | Confidence: %.2f | Range: %.5f%s%s",
        phaseStr,
        m_currentPatternConfidence,
        m_currentPriceRange,
        m_currentHasSpring ? " | SPRING" : "",
        m_currentHasUpthrust ? " | UPTHRUST" : "");
}

//+------------------------------------------------------------------+
//| ?? PHASE ANALYSIS METHODS                                      |
//+------------------------------------------------------------------+
private:
void UpdatePhaseAnalysis()
{
// Update volume analysis
UpdateVolumeAnalysis();

// Update price analysis
UpdatePriceAnalysis();

// Determine current phase
DetermineCurrentPhase();

// Update pattern history
UpdatePatternHistory();
}

void UpdateVolumeAnalysis()
{
// Calculate average volume over 50 periods
double totalVolume = 0.0;
for(int i = 1; i <= 50; i++) {
totalVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
m_averageVolume50 = totalVolume / 50.0;

// Calculate volume variance
double varianceSum = 0.0;
for(int i = 1; i <= 20; i++) {
double vol = (double)iVolume(_Symbol, PERIOD_CURRENT, i);
varianceSum += MathPow(vol - m_averageVolume50, 2);
}
m_volumeVariance = varianceSum / 20.0;
}

void UpdatePriceAnalysis()
{
// Calculate price range variance
double varianceSum = 0.0;
double avgRange = 0.0;

// Calculate average range
for(int i = 1; i <= 20; i++) {
MqlRates rates[];
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, PERIOD_CURRENT, i, 1, rates) > 0) {
avgRange += (rates[0].high - rates[0].low);
}
}
avgRange /= 20.0;

// Calculate variance
for(int i = 1; i <= 20; i++) {
MqlRates rates[];
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, PERIOD_CURRENT, i, 1, rates) > 0) {
double range = rates[0].high - rates[0].low;
varianceSum += MathPow(range - avgRange, 2);
}
}
m_priceRangeVariance = varianceSum / 20.0;
}

void DetermineCurrentPhase()
{
// Simple phase determination based on price and volume
MqlRates rates[];
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 10, rates) < 10) {
m_currentPhase = WYCKOFF_UNKNOWN;
return;
}

// Calculate trend direction
double priceChange = rates[0].close - rates[9].close;
double avgVolume = m_averageVolume50;
double currentVolume = (double)rates[0].tick_volume;

// Determine phase based on phase movement and volume
if(priceChange > 0 && currentVolume > avgVolume * 1.2) {
m_currentPhase = WYCKOFF_MARKUP;
m_phaseConfidence = 0.8;
} else if(priceChange < 0 && currentVolume > avgVolume * 1.2) {
m_currentPhase = WYCKOFF_MARKDOWN;
m_phaseConfidence = 0.8;
} else if(MathAbs(priceChange) < avgVolume * 0.1) {
m_currentPhase = WYCKOFF_ACCUMULATION;
m_phaseConfidence = 0.6;
} else {
m_currentPhase = WYCKOFF_UNKNOWN;
m_phaseConfidence = 0.3;
}

// Update current pattern
m_currentPatternPhase = m_currentPhase;
m_currentPatternConfidence = m_phaseConfidence;
m_currentPatternStartTime = rates[0].time;
}

void UpdatePatternHistory()
{
// For now, just track count - pattern history can be implemented later if needed
if(m_patternHistoryCount < 5) {
m_patternHistoryCount++;
}
}

public:
SWyckoffPattern GetCurrentPattern()
{
SWyckoffPattern pattern;
pattern.phase = m_currentPatternPhase;
pattern.confidence = m_currentPatternConfidence;
pattern.phaseStartTime = m_currentPatternStartTime;
pattern.phaseBarCount = m_currentPatternBarCount;
pattern.volumeCharacteristic = m_currentVolumeCharacteristic;
pattern.priceRange = m_currentPriceRange;
pattern.hasSpring = m_currentHasSpring;
pattern.hasUpthrust = m_currentHasUpthrust;
pattern.springPrice = m_currentSpringPrice;
pattern.upthrustPrice = m_currentUpthrustPrice;
return pattern;
}
};

//+------------------------------------------------------------------+
//| ?? ENHANCED PVSRA ANALYZER                                       |
//+------------------------------------------------------------------+
class CEnhancedPVSRA
{
private:
CWyckoffAnalyzer* m_wyckoffAnalyzer;

// PVSRA thresholds
double m_volumeThreshold;
double m_spreadThreshold;
double m_closingThreshold;

// Performance tracking
int m_patternsDetected;
int m_successfulPatterns;

public:
CEnhancedPVSRA()
{
m_wyckoffAnalyzer = new CWyckoffAnalyzer();

m_volumeThreshold = 1.5;     // 1.5x average volume
m_spreadThreshold = 0.7;     // 70% of average spread for narrow
m_closingThreshold = 0.8;    // 80% of range for strong close

m_patternsDetected = 0;
m_successfulPatterns = 0;
}

~CEnhancedPVSRA()
{
if(m_wyckoffAnalyzer != NULL) {
delete m_wyckoffAnalyzer;
m_wyckoffAnalyzer = NULL;
}
}

//+------------------------------------------------------------------+
//| ?? ENHANCED PVSRA SCORING WITH WYCKOFF                          |
//+------------------------------------------------------------------+
double GetEnhancedPVSRAScore()
{
double score = 0.0;

// ?? FACTOR 1: Classic PVSRA Analysis (60%)
double classicScore = AnalyzeClassicPVSRA();
score += classicScore * 0.6;

// ?? FACTOR 2: Wyckoff Context (40%)
double wyckoffScore = AnalyzeWyckoffContext();
score += wyckoffScore * 0.4;

return MathMin(1.0, score);
}

private:
double AnalyzeClassicPVSRA()
{
// Get current candle data
MqlRates rates[];
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates) < 2) {
return 0.0;
}

// Analyze current candle
double bodySize = MathAbs(rates[0].close - rates[0].open);
double totalSize = rates[0].high - rates[0].low;
double bodyPercent = (totalSize > 0) ? bodySize / totalSize : 0;
double currentVolume = (double)rates[0].tick_volume;

// Get average volume
double avgVolume = CalculateAverageVolume(20);
double volumeRatio = (avgVolume > 0) ? currentVolume / avgVolume : 1.0;

// Closing position in range
double closingPos = 0.5; // Default middle
if(totalSize > 0) {
closingPos = (rates[0].close - rates[0].low) / totalSize;
}

// ?? BOSS ENHANCEMENT: Apply PVSRA score first, then check institutional
double pvsraScore = GetBasicPVSRAScore(bodyPercent, volumeRatio, closingPos);
CheckInstitutional(pvsraScore); // Institutional check and SMC integration

return pvsraScore;
}

double AnalyzeWyckoffContext()
{
// Get current Wyckoff phase
ENUM_WYCKOFF_PHASE currentPhase = m_wyckoffAnalyzer.GetMarketMakerPhase();
SWyckoffPattern pattern;
pattern.phase = m_wyckoffAnalyzer.GetCurrentPattern().phase;
pattern.confidence = m_wyckoffAnalyzer.GetCurrentPattern().confidence;
pattern.phaseStartTime = m_wyckoffAnalyzer.GetCurrentPattern().phaseStartTime;
pattern.phaseBarCount = m_wyckoffAnalyzer.GetCurrentPattern().phaseBarCount;
pattern.volumeCharacteristic = m_wyckoffAnalyzer.GetCurrentPattern().volumeCharacteristic;
pattern.priceRange = m_wyckoffAnalyzer.GetCurrentPattern().priceRange;
pattern.hasSpring = m_wyckoffAnalyzer.GetCurrentPattern().hasSpring;
pattern.hasUpthrust = m_wyckoffAnalyzer.GetCurrentPattern().hasUpthrust;
pattern.springPrice = m_wyckoffAnalyzer.GetCurrentPattern().springPrice;
pattern.upthrustPrice = m_wyckoffAnalyzer.GetCurrentPattern().upthrustPrice;

double score = 0.0;

switch(currentPhase) {
case PHASE_ACCUMULATION:
// Look for springs and low volume tests
if(pattern.hasSpring) {
score = 0.9; // Excellent spring setup
} else if(pattern.confidence > 0.7) {
score = 0.3; // Accumulation phase - be patient
}
break;

case PHASE_MARKUP:
// Trending up - look for volume confirmation
if(pattern.confidence > 0.8) {
score = 0.8; // Strong markup phase
} else {
score = 0.6; // Potential markup
}
break;

case PHASE_DISTRIBUTION:
// Look for upthrusts and high volume tests
if(pattern.hasUpthrust) {
score = 0.9; // Excellent upthrust setup
} else if(pattern.confidence > 0.7) {
score = 0.3; // Distribution phase - be cautious
}
break;

case PHASE_MARKDOWN:
// Trending down - look for volume confirmation
if(pattern.confidence > 0.8) {
score = 0.8; // Strong markdown phase
} else {
score = 0.6; // Potential markdown
}
break;

case PHASE_REACCUMULATION:
// Pause in uptrend - look for continuation signals
score = 0.7;
break;

case PHASE_REDISTRIBUTION:
// Pause in downtrend - look for continuation signals
score = 0.7;
break;

default:
score = 0.5; // Unknown phase - neutral
break;
}

return score;
}

double CalculateAverageVolume(int periods)
{
double total = 0.0;
for(int i = 1; i <= periods; i++) {
total += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
return total / periods;
}

public:
//+------------------------------------------------------------------+
//| ?? PUBLIC INTERFACE METHODS                                      |
//+------------------------------------------------------------------+
ENUM_WYCKOFF_PHASE GetCurrentWyckoffPhase()
{
if(m_wyckoffAnalyzer != NULL) {
return m_wyckoffAnalyzer.GetMarketMakerPhase();
}
return PHASE_UNKNOWN;
}

bool ShouldBlockSignals()
{
if(m_wyckoffAnalyzer != NULL) {
return m_wyckoffAnalyzer.ShouldBlockSignals();
}
return false;
}

bool IsSpringSetup()
{
if(m_wyckoffAnalyzer != NULL) {
return m_wyckoffAnalyzer.IsSpringSetup();
}
return false;
}

bool IsUpthrustSetup()
{
if(m_wyckoffAnalyzer != NULL) {
return m_wyckoffAnalyzer.IsUpthrustSetup();
}
return false;
}

string GetWyckoffReport()
{
if(m_wyckoffAnalyzer != NULL) {
return m_wyckoffAnalyzer.GetPhaseReport();
}
return "Wyckoff Analyzer not available";
}

double GetPatternSuccessRate()
{
return m_patternsDetected > 0 ? (double)m_successfulPatterns / m_patternsDetected : 0.0;
}

// Configuration methods
void SetVolumeThreshold(double threshold) { m_volumeThreshold = threshold; }
void SetSpreadThreshold(double threshold) { m_spreadThreshold = threshold; }
void SetClosingThreshold(double threshold) { m_closingThreshold = threshold; }

//+------------------------------------------------------------------+
//| ?? BOSS ENHANCEMENT: BASIC PVSRA SCORE CALCULATION              |
//+------------------------------------------------------------------+
double GetBasicPVSRAScore(double bodyPercent, double volumeRatio, double closingPos)
{
double score = 0.0;

// Volume threshold >2x average (Wyckoff stopping volume criteria)
if(volumeRatio > 2.0) {
score += 0.4; // High volume contribution

// Additional bonus for extreme volume
if(volumeRatio > 3.0) score += 0.2;
}

// Body size analysis
if(bodyPercent > 0.7) {
score += 0.2; // Strong directional move
} else if(bodyPercent < 0.3) {
score += 0.15; // Doji/hammer patterns
}

// Closing position analysis
if(closingPos > 0.8 || closingPos < 0.2) {
score += 0.2; // Extreme closing positions
}

return MathMin(1.0, score);
}

//+------------------------------------------------------------------+
//| ?? BOSS ENHANCEMENT: INSTITUTIONAL CHECK - MINH B?CH WYCKOFF    |
//+------------------------------------------------------------------+
void CheckInstitutional(double &pvsraScore)
{
double smcSignal = GetSMCSignal(); // From SMC module

if(smcSignal > 0.7) {
pvsraScore = 0.8; // High confidence institutional activity
} else {
pvsraScore *= 0.7; // Reduce if no institutional signs
}
}

//+------------------------------------------------------------------+
//| ?? BOSS ENHANCEMENT: HELPER METHODS                             |
//+------------------------------------------------------------------+
bool IsVolumeSurge()
{
long currentVol = iVolume(_Symbol, PERIOD_CURRENT, 0);
double avgVol = CalculateAverageVolume(20);
return currentVol > avgVol * 2.0; // 2x average volume surge
}

bool IsPriceReversal()
{
// Simple reversal detection: close opposite to open with high volume
MqlRates rates[];
ArraySetAsSeries(rates, true);
if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, rates) < 3) return false;

bool currentBullish = rates[0].close > rates[0].open;
bool previousBullish = rates[1].close > rates[1].open;

// Reversal: current candle opposite direction to previous
return currentBullish != previousBullish;
}

double GetSMCSignal()
{
// Integration with SMC - will connect with Item 2 implementation
// For now, placeholder logic
return 0.5; // Neutral signal
}
};

//+------------------------------------------------------------------+
//| ?? ENHANCED SMC & PVSRA QUANTIFICATION SYSTEM                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ?? GROUP 2 FIX: SSMCLevel moved to CommonStructures.mqh        |
//| Preventing duplicate definition error 282                        |
//+------------------------------------------------------------------+
// NOTE: SSMCLevel is now defined in 01_Core_13_CommonStructures.mqh
// Use #include "01_Core_07_CommonStructures.mqh" to access



//+------------------------------------------------------------------+
//| GLOBAL ENHANCED PVSRA INSTANCE                                  |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - MQL5 global pointers cannot be initialized with assignment
CEnhancedPVSRA* g_EnhancedPVSRA;

//+------------------------------------------------------------------+
//| INITIALIZATION FUNCTIONS                                        |
//+------------------------------------------------------------------+
bool InitializeEnhancedPVSRA()
{
if(g_EnhancedPVSRA == NULL) {
g_EnhancedPVSRA = new CEnhancedPVSRA();
Print("?? Enhanced PVSRA with Wyckoff analysis initialized");
return true;
}
return true;
}

void DeinitializeEnhancedPVSRA()
{
if(g_EnhancedPVSRA != NULL) {
delete g_EnhancedPVSRA;
g_EnhancedPVSRA = NULL;
}
}

//+------------------------------------------------------------------+
//| PUBLIC INTERFACE FUNCTIONS                                      |
//+------------------------------------------------------------------+
double GetEnhancedPVSRAScore()
{
if(g_EnhancedPVSRA != NULL) {
return g_EnhancedPVSRA.GetEnhancedPVSRAScore();
}
return 0.0;
}

ENUM_WYCKOFF_PHASE GetCurrentWyckoffPhase()
{
if(g_EnhancedPVSRA != NULL) {
return g_EnhancedPVSRA.GetCurrentWyckoffPhase();
}
return PHASE_UNKNOWN;
}

bool ShouldBlockSignalsDueToWyckoff()
{
if(g_EnhancedPVSRA != NULL) {
return g_EnhancedPVSRA.ShouldBlockSignals();
}
return false;
}

string GetWyckoffAnalysisReport()
{
if(g_EnhancedPVSRA != NULL) {
return g_EnhancedPVSRA.GetWyckoffReport();
}
return "Enhanced PVSRA not initialized";
}

#endif // ANALYSIS_ENHANCED_PVSRA_MQH


