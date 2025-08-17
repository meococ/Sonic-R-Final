//+------------------------------------------------------------------+
//|                                  Analysis_MarketMakerPhases.mqh |
//|                    SONIC R MC - MARKET MAKER PHASE DETECTION     |
//|                       ??? WYCKOFF INSTITUTIONAL ANALYSIS          |
//+------------------------------------------------------------------+

#ifndef ANALYSIS_MARKET_MAKER_PHASES_MQH
#define ANALYSIS_MARKET_MAKER_PHASES_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| Market Maker Phase Enumeration - Enhanced Wyckoff                |
//+------------------------------------------------------------------+
enum ENUM_MM_PHASE
{
MM_UNKNOWN = 0,                 // Cannot determine phase
MM_ACCUMULATION_PHASE_A,        // Initial selling climax
MM_ACCUMULATION_PHASE_B,        // Building cause  
MM_ACCUMULATION_PHASE_C,        // Spring action / Last point of support
MM_ACCUMULATION_PHASE_D,        // Signs of strength
MM_ACCUMULATION_PHASE_E,        // Last point of support
MM_MARKUP_PHASE,                // Price advancement
MM_DISTRIBUTION_PHASE_A,        // Preliminary supply
MM_DISTRIBUTION_PHASE_B,        // Buying climax
MM_DISTRIBUTION_PHASE_C,        // Upthrust after distribution
MM_DISTRIBUTION_PHASE_D,        // Signs of weakness
MM_DISTRIBUTION_PHASE_E,        // Last point of supply
MM_MARKDOWN_PHASE               // Price decline
};

//+------------------------------------------------------------------+
//| Market Maker Phase Data Structure                                |
//+------------------------------------------------------------------+
struct MarketMakerPhaseData
{
ENUM_MM_PHASE       currentPhase;
ENUM_MM_PHASE       previousPhase;
double              phaseConfidence;    // 0-1 confidence in phase identification
datetime            phaseStartTime;
datetime            lastUpdate;

// Phase characteristics
double              volumeProfile;      // Average volume during phase
double              priceRange;         // Price range during phase
double              effortVsResult;     // Effort vs result analysis
bool                isBreakoutReady;    // Ready for breakout

// Key levels
double              supportLevel;
double              resistanceLevel;
double              springLevel;        // For accumulation
double              upthrustLevel;      // For distribution

void Reset()
{
currentPhase = MM_UNKNOWN;
previousPhase = MM_UNKNOWN;
phaseConfidence = 0.0;
phaseStartTime = 0;
lastUpdate = 0;
volumeProfile = 0.0;
priceRange = 0.0;
effortVsResult = 0.0;
isBreakoutReady = false;
supportLevel = 0.0;
resistanceLevel = 0.0;
springLevel = 0.0;
upthrustLevel = 0.0;
}
};

//+------------------------------------------------------------------+
//| Volume Analysis Data                                             |
//+------------------------------------------------------------------+
struct VolumeAnalysisData
{
double climaxVolume;        // Highest volume bar
double avgVolume;           // Average volume
double dryUpVolume;         // Low volume during consolidation
double testVolume;          // Volume on tests of support/resistance
bool   isClimaxDetected;    // Selling/Buying climax detected
bool   isDryUpDetected;     // Volume dry up detected

void Reset()
{
climaxVolume = 0.0;
avgVolume = 0.0;
dryUpVolume = 0.0;
testVolume = 0.0;
isClimaxDetected = false;
isDryUpDetected = false;
}
};

//+------------------------------------------------------------------+
//| ??? MARKET MAKER PHASE DETECTOR - INSTITUTIONAL ANALYSIS        |
//+------------------------------------------------------------------+
class CMarketMakerPhaseDetector
{
private:
MarketMakerPhaseData    m_currentPhase;
VolumeAnalysisData      m_volumeData;

// Analysis parameters
int                     m_lookbackBars;     // Bars to analyze
double                  m_volumeThreshold;  // Volume spike threshold
double                  m_rangeThreshold;   // Price range threshold
int                     m_minPhaseDuration; // Minimum bars for phase

// Data arrays
double                  m_highs[200];
double                  m_lows[200];
double                  m_closes[200];
double                  m_volumes[200];
int                     m_dataSize;

// Phase detection state
datetime                m_lastAnalysis;
bool                    m_phaseChanged;

public:
CMarketMakerPhaseDetector()
{
m_currentPhase.Reset();
m_volumeData.Reset();

m_lookbackBars = 100;
m_volumeThreshold = 1.5;    // 150% of average volume
m_rangeThreshold = 1.2;     // 120% of average range
m_minPhaseDuration = 10;    // Minimum 10 bars for phase

m_dataSize = 0;
m_lastAnalysis = 0;
m_phaseChanged = false;

// Initialize arrays
ArrayFill(m_highs, 0, 200, 0.0);
ArrayFill(m_lows, 0, 200, 0.0);
ArrayFill(m_closes, 0, 200, 0.0);
ArrayFill(m_volumes, 0, 200, 0.0);

Print("[??? MM PHASE] Market Maker Phase Detector initialized");
}

//+------------------------------------------------------------------+
//| ?? MAIN PHASE DETECTION METHOD                                   |
//+------------------------------------------------------------------+
ENUM_MM_PHASE DetectCurrentPhase()
{
// Update market data
if(!UpdateMarketData()) return MM_UNKNOWN;

// Analyze volume patterns
AnalyzeVolumePatterns();

// Detect current phase
ENUM_MM_PHASE detectedPhase = AnalyzePhasePattern();

// Validate phase transition
if(ValidatePhaseTransition(detectedPhase)) {
if(detectedPhase != m_currentPhase.currentPhase) {
m_currentPhase.previousPhase = m_currentPhase.currentPhase;
m_currentPhase.currentPhase = detectedPhase;
m_currentPhase.phaseStartTime = TimeCurrent();
m_phaseChanged = true;

Print(StringFormat("[??? MM PHASE] Phase transition: %s . %s (Confidence: %.1f%%)",
GetPhaseString(m_currentPhase.previousPhase),
GetPhaseString(m_currentPhase.currentPhase),
m_currentPhase.phaseConfidence * 100));
}
}

// Update phase data
UpdatePhaseCharacteristics();
m_currentPhase.lastUpdate = TimeCurrent();

return m_currentPhase.currentPhase;
}

//+------------------------------------------------------------------+
//| ?? ANALYZE PHASE PATTERN                                         |
//+------------------------------------------------------------------+
ENUM_MM_PHASE AnalyzePhasePattern()
{
if(m_dataSize < 50) return MM_UNKNOWN;

// Calculate key metrics
double priceDirection = CalculatePriceDirection();
double volumeTrend = CalculateVolumeTrend();
double volatilityLevel = CalculateVolatility();
double rangeBound = CalculateRangeBound();

// Phase detection logic
ENUM_MM_PHASE phase = MM_UNKNOWN;
double confidence = 0.0;

// ?? ACCUMULATION PHASES
if(DetectAccumulationPhase(priceDirection, volumeTrend, volatilityLevel, rangeBound, phase, confidence)) {
m_currentPhase.phaseConfidence = confidence;
return phase;
}

// ?? DISTRIBUTION PHASES  
if(DetectDistributionPhase(priceDirection, volumeTrend, volatilityLevel, rangeBound, phase, confidence)) {
m_currentPhase.phaseConfidence = confidence;
return phase;
}

// ?? MARKUP/MARKDOWN PHASES
if(DetectTrendPhase(priceDirection, volumeTrend, volatilityLevel, phase, confidence)) {
m_currentPhase.phaseConfidence = confidence;
return phase;
}

m_currentPhase.phaseConfidence = 0.3; // Low confidence unknown phase
return MM_UNKNOWN;
}

//+------------------------------------------------------------------+
//| ?? DETECT ACCUMULATION PHASES                                    |
//+------------------------------------------------------------------+
bool DetectAccumulationPhase(double priceDir, double volTrend, double volatility, double rangeBound, 
ENUM_MM_PHASE& phase, double& confidence)
{
// Look for accumulation characteristics
bool isRangebound = (rangeBound > 0.7);           // Price contained in range
bool isLowVolatility = (volatility < 0.6);        // Low volatility
bool isSellingClimaxPresent = m_volumeData.isClimaxDetected && (priceDir < -0.3);
bool isVolumeDecreasing = (volTrend < -0.2);       // Volume decreasing

// Phase A: Selling Climax
if(isSellingClimaxPresent && !isRangebound) {
phase = MM_ACCUMULATION_PHASE_A;
confidence = 0.8;
return true;
}

// Phase B: Building Cause
if(isRangebound && isLowVolatility && MathAbs(priceDir) < 0.2) {
// Check for tests of lows with lower volume
if(DetectTestsOfSupport()) {
phase = MM_ACCUMULATION_PHASE_B;
confidence = 0.7;
return true;
}
}

// Phase C: Spring/Last Point of Support
if(isRangebound && DetectSpringAction()) {
phase = MM_ACCUMULATION_PHASE_C;
confidence = 0.9;
return true;
}

// Phase D: Signs of Strength
if(isRangebound && DetectSignsOfStrength()) {
phase = MM_ACCUMULATION_PHASE_D;
confidence = 0.8;
return true;
}

return false;
}

//+------------------------------------------------------------------+
//| ?? DETECT DISTRIBUTION PHASES                                    |
//+------------------------------------------------------------------+
bool DetectDistributionPhase(double priceDir, double volTrend, double volatility, double rangeBound,
ENUM_MM_PHASE& phase, double& confidence)
{
// Look for distribution characteristics
bool isRangebound = (rangeBound > 0.7);           // Price contained in range
bool isHighVolatility = (volatility > 0.8);       // High volatility
bool isBuyingClimaxPresent = m_volumeData.isClimaxDetected && (priceDir > 0.3);
bool isVolumeDecreasing = (volTrend < -0.2);       // Volume decreasing after climax

// Phase A: Preliminary Supply
if(priceDir > 0.5 && volTrend > 0.3 && !isRangebound) {
if(DetectPreliminarySupply()) {
phase = MM_DISTRIBUTION_PHASE_A;
confidence = 0.7;
return true;
}
}

// Phase B: Buying Climax
if(isBuyingClimaxPresent && isHighVolatility) {
phase = MM_DISTRIBUTION_PHASE_B;
confidence = 0.8;
return true;
}

// Phase C: Upthrust After Distribution
if(isRangebound && DetectUpthrustAction()) {
phase = MM_DISTRIBUTION_PHASE_C;
confidence = 0.9;
return true;
}

// Phase D: Signs of Weakness
if(isRangebound && DetectSignsOfWeakness()) {
phase = MM_DISTRIBUTION_PHASE_D;
confidence = 0.8;
return true;
}

return false;
}

//+------------------------------------------------------------------+
//| ?? DETECT TREND PHASES                                           |
//+------------------------------------------------------------------+
bool DetectTrendPhase(double priceDir, double volTrend, double volatility,
ENUM_MM_PHASE& phase, double& confidence)
{
// Markup Phase: Strong uptrend with confirming volume
if(priceDir > 0.6 && volTrend > 0.2 && volatility > 0.5) {
if(DetectMarkupCharacteristics()) {
phase = MM_MARKUP_PHASE;
confidence = 0.8;
return true;
}
}

// Markdown Phase: Strong downtrend with confirming volume
if(priceDir < -0.6 && volTrend > 0.2 && volatility > 0.5) {
if(DetectMarkdownCharacteristics()) {
phase = MM_MARKDOWN_PHASE;
confidence = 0.8;
return true;
}
}

return false;
}

//+------------------------------------------------------------------+
//| ?? SPECIFIC PATTERN DETECTION METHODS                           |
//+------------------------------------------------------------------+
bool DetectSpringAction()
{
// Look for break below support followed by quick recovery
for(int i = 5; i < 20 && i < m_dataSize; i++) {
double supportLevel = FindRecentSupport(i + 10);
if(supportLevel > 0) {
// Check for break below support
if(m_lows[i] < supportLevel) {
// Check for quick recovery above support
for(int j = i - 1; j >= 0; j--) {
if(m_closes[j] > supportLevel) {
m_currentPhase.springLevel = m_lows[i];
return true;
}
}
}
}
}
return false;
}

bool DetectUpthrustAction()
{
// Look for break above resistance followed by quick rejection
for(int i = 5; i < 20 && i < m_dataSize; i++) {
double resistanceLevel = FindRecentResistance(i + 10);
if(resistanceLevel > 0) {
// Check for break above resistance
if(m_highs[i] > resistanceLevel) {
// Check for quick rejection below resistance
for(int j = i - 1; j >= 0; j--) {
if(m_closes[j] < resistanceLevel) {
m_currentPhase.upthrustLevel = m_highs[i];
return true;
}
}
}
}
}
return false;
}

bool DetectSignsOfStrength()
{
// Look for higher lows with increasing volume
int signCount = 0;
for(int i = 1; i < 10 && i < m_dataSize - 1; i++) {
if(m_lows[i] > m_lows[i + 1] && m_volumes[i] > m_volumes[i + 1]) {
signCount++;
}
}
return signCount >= 3;
}

bool DetectSignsOfWeakness()
{
// Look for lower highs with increasing volume
int signCount = 0;
for(int i = 1; i < 10 && i < m_dataSize - 1; i++) {
if(m_highs[i] < m_highs[i + 1] && m_volumes[i] > m_volumes[i + 1]) {
signCount++;
}
}
return signCount >= 3;
}

bool DetectTestsOfSupport()
{
double supportLevel = FindRecentSupport(20);
if(supportLevel <= 0) return false;

int testCount = 0;
for(int i = 0; i < 15 && i < m_dataSize; i++) {
if(MathAbs(m_lows[i] - supportLevel) < (supportLevel * 0.01)) { // Within 1%
testCount++;
}
}
return testCount >= 2;
}

bool DetectPreliminarySupply()
{
// Look for first signs of supply pressure after uptrend
return (CalculatePriceDirection() > 0.3 && m_volumeData.climaxVolume > m_volumeData.avgVolume * 2.0);
}

bool DetectMarkupCharacteristics()
{
// Strong uptrend with healthy pullbacks
double trendStrength = CalculateTrendStrength();
return (trendStrength > 0.7 && CalculateVolumeTrend() > 0.1);
}

bool DetectMarkdownCharacteristics()
{
// Strong downtrend with high volume
double trendStrength = CalculateTrendStrength();
return (trendStrength < -0.7 && CalculateVolumeTrend() > 0.1);
}

//+------------------------------------------------------------------+
//| ?? HELPER CALCULATION METHODS                                    |
//+------------------------------------------------------------------+
double CalculatePriceDirection()
{
if(m_dataSize < 20) return 0.0;

double startPrice = m_closes[19];
double endPrice = m_closes[0];
return (endPrice - startPrice) / startPrice;
}

double CalculateVolumeTrend()
{
if(m_dataSize < 20) return 0.0;

double recentVol = 0, oldVol = 0;
for(int i = 0; i < 10; i++) recentVol += m_volumes[i];
for(int i = 10; i < 20; i++) oldVol += m_volumes[i];

recentVol /= 10;
oldVol /= 10;

return (oldVol > 0) ? (recentVol - oldVol) / oldVol : 0.0;
}

double CalculateVolatility()
{
if(m_dataSize < 20) return 0.0;

double avgRange = 0;
for(int i = 0; i < 20; i++) {
avgRange += (m_highs[i] - m_lows[i]);
}
avgRange /= 20;

double recentRange = (m_highs[0] - m_lows[0]);
return (avgRange > 0) ? recentRange / avgRange : 0.0;
}

double CalculateRangeBound()
{
if(m_dataSize < 30) return 0.0;

double highest = m_highs[0];
double lowest = m_lows[0];

for(int i = 0; i < 30; i++) {
if(m_highs[i] > highest) highest = m_highs[i];
if(m_lows[i] < lowest) lowest = m_lows[i];
}

double range = highest - lowest;
double currentRange = m_highs[0] - m_lows[0];

return (range > 0) ? 1.0 - (currentRange / range) : 0.0;
}

double CalculateTrendStrength()
{
// Simplified trend strength calculation
return CalculatePriceDirection();
}

double FindRecentSupport(int lookback)
{
if(m_dataSize < lookback) return 0.0;

double support = m_lows[0];
for(int i = 1; i < lookback; i++) {
if(m_lows[i] < support) support = m_lows[i];
}
return support;
}

double FindRecentResistance(int lookback)
{
if(m_dataSize < lookback) return 0.0;

double resistance = m_highs[0];
for(int i = 1; i < lookback; i++) {
if(m_highs[i] > resistance) resistance = m_highs[i];
}
return resistance;
}

//+------------------------------------------------------------------+
//| ?? DATA MANAGEMENT METHODS                                       |
//+------------------------------------------------------------------+
bool UpdateMarketData()
{
// Get recent OHLCV data
double highs[], lows[], closes[];
long volumes[];

ArraySetAsSeries(highs, true);
ArraySetAsSeries(lows, true);
ArraySetAsSeries(closes, true);
ArraySetAsSeries(volumes, true);

int copied = MathMin(200, CopyHigh(_Symbol, PERIOD_H1, 0, 200, highs));
if(copied < 50) return false;

CopyLow(_Symbol, PERIOD_H1, 0, copied, lows);
CopyClose(_Symbol, PERIOD_H1, 0, copied, closes);
CopyTickVolume(_Symbol, PERIOD_H1, 0, copied, volumes);

// Update internal arrays
m_dataSize = copied;
for(int i = 0; i < copied; i++) {
m_highs[i] = highs[i];
m_lows[i] = lows[i];
m_closes[i] = closes[i];
m_volumes[i] = (double)volumes[i];
}

return true;
}

void AnalyzeVolumePatterns()
{
if(m_dataSize < 20) return;

// Calculate average volume
m_volumeData.avgVolume = 0;
for(int i = 0; i < 20; i++) {
m_volumeData.avgVolume += m_volumes[i];
}
m_volumeData.avgVolume /= 20;

// Find climax volume
m_volumeData.climaxVolume = m_volumes[0];
for(int i = 1; i < 20; i++) {
if(m_volumes[i] > m_volumeData.climaxVolume) {
m_volumeData.climaxVolume = m_volumes[i];
}
}

// Check for climax
m_volumeData.isClimaxDetected = (m_volumeData.climaxVolume > m_volumeData.avgVolume * m_volumeThreshold);

// Check for volume dry up
double recentAvgVol = 0;
for(int i = 0; i < 5; i++) recentAvgVol += m_volumes[i];
recentAvgVol /= 5;

m_volumeData.isDryUpDetected = (recentAvgVol < m_volumeData.avgVolume * 0.7);
m_volumeData.dryUpVolume = recentAvgVol;
}

bool ValidatePhaseTransition(ENUM_MM_PHASE newPhase)
{
// Basic validation - can add more sophisticated logic
if(newPhase == m_currentPhase.currentPhase) return false;

// Must maintain phase for minimum duration
datetime currentTime = TimeCurrent();
if(currentTime - m_currentPhase.phaseStartTime < m_minPhaseDuration * PeriodSeconds(PERIOD_H1)) {
return false;
}

return true;
}

void UpdatePhaseCharacteristics()
{
m_currentPhase.volumeProfile = m_volumeData.avgVolume;
m_currentPhase.priceRange = CalculateRangeBound();
m_currentPhase.supportLevel = FindRecentSupport(30);
m_currentPhase.resistanceLevel = FindRecentResistance(30);

// Check if ready for breakout
m_currentPhase.isBreakoutReady = (
(m_currentPhase.currentPhase == MM_ACCUMULATION_PHASE_D || 
m_currentPhase.currentPhase == MM_DISTRIBUTION_PHASE_D) &&
m_volumeData.isDryUpDetected
);
}

string GetPhaseString(ENUM_MM_PHASE phase)
{
switch(phase) {
case MM_ACCUMULATION_PHASE_A: return "Accumulation A";
case MM_ACCUMULATION_PHASE_B: return "Accumulation B";
case MM_ACCUMULATION_PHASE_C: return "Spring/LPS";
case MM_ACCUMULATION_PHASE_D: return "Signs of Strength";
case MM_MARKUP_PHASE: return "Markup";
case MM_DISTRIBUTION_PHASE_A: return "Distribution A";
case MM_DISTRIBUTION_PHASE_B: return "Buying Climax";
case MM_DISTRIBUTION_PHASE_C: return "Upthrust";
case MM_DISTRIBUTION_PHASE_D: return "Signs of Weakness";
case MM_MARKDOWN_PHASE: return "Markdown";
default: return "Unknown";
}
}

// Public interface
MarketMakerPhaseData GetCurrentPhaseData() const { return m_currentPhase; }
VolumeAnalysisData GetVolumeData() const { return m_volumeData; }
bool HasPhaseChanged() const { return m_phaseChanged; }
void ResetPhaseChanged() { m_phaseChanged = false; }

string GetPhaseReport()
{
return StringFormat(
"??? MARKET MAKER PHASE ANALYSIS\nCurrent Phase: %s (%.1f%% confidence)\n",
GetPhaseString(m_currentPhase.currentPhase),
m_currentPhase.phaseConfidence * 100
);
}
}
;
#endif
