//+------------------------------------------------------------------+
//|                            Analysis_DragonBandAnalyzer_Enhanced.mqh |
//|                          SONIC R MC - ENHANCED DRAGON ANALYZER       |
//|                    ?? COMPLETE DRAGON SQUEEZE + ANGLE ANALYSIS       |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_DRAGON_BAND_ANALYZER_ENHANCED_MQH
#define ANALYSIS_DRAGON_BAND_ANALYZER_ENHANCED_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"

#include "01_Core_17_Utils.mqh"
//+------------------------------------------------------------------+
//| ?? ENHANCED DRAGON BAND DATA STRUCTURE                          |
//+------------------------------------------------------------------+
struct SEnhancedDragonBandData
{
// Core Dragon Band Values (3-EMA System)
double emaHigh;                        // EMA 34 on HIGH
double emaLow;                         // EMA 34 on LOW
double emaClose;                       // EMA 34 on CLOSE
double emaTrend89;                     // EMA 89 trend filter

// Dragon Metrics
double dragonAngle;                    // EMA Close angle (-90 to +90 degrees)
double dragonSlope;                    // Price change per bar
double bandWidth;                      // Distance between High and Low EMAs
double bandWidthPercent;               // Band width as percentage of price
double bandWidthNormalized;            // Normalized against 20-period average

// ?? ENHANCED: Dragon Squeeze Detection (Missing from original)
bool isDragonSqueeze;                  // Bands contracting = breakout imminent
double squeezeIntensity;               // 0.0 = no squeeze, 1.0 = maximum squeeze
int squeezeBars;                       // How many bars squeeze has lasted
double squeezeQuality;                 // Quality of squeeze setup (0-1)
ENUM_DRAGON_STATE dragonState;         // Current Dragon state

// Trend Analysis
ENUM_TREND_DIRECTION trendDirection;   // Current trend direction
double trendStrength;                  // 0.0 - 1.0 trend strength
bool isBreakoutReady;                  // Ready for major breakout
double breakoutProbability;            // Probability of breakout (0-1)

// Price Position Analysis
double pricePosition;                  // Position within Dragon Band (0-1)
bool isPullbackZone;                   // Price in pullback zone
double pullbackQuality;                // Quality of pullback setup

// Analysis Metadata
datetime analysisTime;
bool isValid;
double confidence;                     // Overall analysis confidence

void Reset()
{
emaHigh = 0.0;
emaLow = 0.0;
emaClose = 0.0;
emaTrend89 = 0.0;

dragonAngle = 0.0;
dragonSlope = 0.0;
bandWidth = 0.0;
bandWidthPercent = 0.0;
bandWidthNormalized = 0.0;

isDragonSqueeze = false;
squeezeIntensity = 0.0;
squeezeBars = 0;
squeezeQuality = 0.0;
dragonState = DRAGON_STABLE;

trendDirection = TREND_SIDEWAYS;
trendStrength = 0.0;
isBreakoutReady = false;
breakoutProbability = 0.0;

pricePosition = 0.5;
isPullbackZone = false;
pullbackQuality = 0.0;

analysisTime = 0;
isValid = false;
confidence = 0.0;
}

string GetDetailedReport()
{
return StringFormat(
"?? Dragon Analysis | Angle: %.1f� | Trend: %s | Squeeze: %s (%.1f%%) | Breakout: %s",
dragonAngle,
TrendDirectionToString(trendDirection),
isDragonSqueeze ? "YES" : "NO",
squeezeIntensity * 100,
isBreakoutReady ? "READY" : "NOT READY"
);
}
};

//+------------------------------------------------------------------+
//| ?? ENHANCED DRAGON BAND ANALYZER CLASS                          |
//+------------------------------------------------------------------+
class CEnhancedDragonBandAnalyzer
{
private:
// Indicator Handles (3-EMA System as per Sonic R)
int m_handleHigh;                      // EMA 34 on HIGH prices
int m_handleLow;                       // EMA 34 on LOW prices
int m_handleClose;                     // EMA 34 on CLOSE prices
int m_handleTrend89;                   // EMA 89 for trend filter

// Indicator Buffers - ?? FIXED: Convert to dynamic arrays to fix ArraySetAsSeries warnings
double m_emaHigh[];
double m_emaLow[];
double m_emaClose[];
double m_emaTrend89[];

// Dragon Parameters
int m_dragonPeriod;                    // EMA period (default 34)
int m_trendPeriod;                     // Trend EMA period (default 89)
double m_angleThreshold;               // Minimum angle for trend (default 2.0�)

// ?? SQUEEZE DETECTION PARAMETERS (Boss's missing feature)
double m_normalBandWidth;              // Average band width over 20 bars
double m_squeezeThreshold;             // Threshold for squeeze detection (default 0.7)
int m_minSqueezeBars;                  // Minimum bars for valid squeeze (default 3)
int m_maxSqueezeBars;                  // Maximum squeeze duration (default 20)
double m_bandWidthHistory[50];         // Historical band width data
int m_bandHistoryCount;

// Analysis State
SEnhancedDragonBandData m_currentAnalysis;
datetime m_lastUpdate;
bool m_initialized;

// Squeeze tracking
int m_currentSqueezeBars;
double m_squeezeStartWidth;
double m_squeezeMinWidth;
bool m_wasSqueezing;

// Performance tracking
int m_analysisCount;
double m_averageConfidence;
int m_breakoutSuccessCount;
int m_breakoutTotalCount;

// ?? PHASE 2: MIGRATE TO UNIFIED INDICATOR SYSTEM                 |
string m_symbol;
ENUM_TIMEFRAMES m_timeframe;
datetime m_lastAnalysisTime;

public:
CEnhancedDragonBandAnalyzer()
{
m_dragonPeriod = 34;
m_trendPeriod = 89;
m_angleThreshold = 2.0;              // Boss's 2-degree threshold
m_squeezeThreshold = 0.7;            // 30% contraction = squeeze
m_minSqueezeBars = 3;
m_maxSqueezeBars = 20;

m_handleHigh = INVALID_HANDLE;
m_handleLow = INVALID_HANDLE;
m_handleClose = INVALID_HANDLE;
m_handleTrend89 = INVALID_HANDLE;

m_lastUpdate = 0;
m_initialized = false;
m_bandHistoryCount = 0;
m_normalBandWidth = 0.0;
m_currentSqueezeBars = 0;
m_squeezeStartWidth = 0.0;
m_squeezeMinWidth = DBL_MAX;
m_wasSqueezing = false;

m_analysisCount = 0;
m_averageConfidence = 0.0;
m_breakoutSuccessCount = 0;
m_breakoutTotalCount = 0;

m_currentAnalysis.Reset();

// ?? FIXED: Resize dynamic arrays before setting series flag
ArrayResize(m_emaHigh, 50);
ArrayResize(m_emaLow, 50);
ArrayResize(m_emaClose, 50);
ArrayResize(m_emaTrend89, 50);

ArraySetAsSeries(m_emaHigh, true);
ArraySetAsSeries(m_emaLow, true);
ArraySetAsSeries(m_emaClose, true);
ArraySetAsSeries(m_emaTrend89, true);
ArrayInitialize(m_bandWidthHistory, 0.0);

Print("?? Enhanced Dragon Band Analyzer initialized");
}

~CEnhancedDragonBandAnalyzer()
{
if(m_handleHigh != INVALID_HANDLE) IndicatorRelease(m_handleHigh);
if(m_handleLow != INVALID_HANDLE) IndicatorRelease(m_handleLow);
if(m_handleClose != INVALID_HANDLE) IndicatorRelease(m_handleClose);
if(m_handleTrend89 != INVALID_HANDLE) IndicatorRelease(m_handleTrend89);
}

//+------------------------------------------------------------------+
//| ?? PHASE 2: MIGRATE TO UNIFIED INDICATOR SYSTEM                 |
//+------------------------------------------------------------------+
bool Initialize(string symbol = NULL, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
if(symbol == NULL) symbol = _Symbol;

m_symbol = symbol;
m_timeframe = timeframe;

// ?? PHASE 2: Replace duplicate iMA() calls with unified system
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

if(manager == NULL) {
Print("? [PHASE 2 MIGRATION] Failed to get unified indicator manager");
return false;
}

// OLD CODE (DUPLICATED):
// m_handleHigh = iMA(symbol, PERIOD_CURRENT, m_dragonPeriod, 0, MODE_EMA, PRICE_HIGH);
// m_handleLow = iMA(symbol, PERIOD_CURRENT, m_dragonPeriod, 0, MODE_EMA, PRICE_LOW);
// m_handleClose = iMA(symbol, PERIOD_CURRENT, m_dragonPeriod, 0, MODE_EMA, PRICE_CLOSE);
// m_handleTrend89 = iMA(symbol, PERIOD_CURRENT, m_trendPeriod, 0, MODE_EMA, PRICE_CLOSE);

// NEW CODE (UNIFIED SYSTEM):
bool success = manager.SetupDragonBandIndicators(symbol, timeframe,
m_handleHigh, m_handleLow,
m_handleClose, m_handleTrend89);

if(!success) {
Print("? Failed to setup Dragon Band indicators via unified system");
return false;
}

// Log migration success
manager.MigrateLegacyIndicatorCalls(
"Analysis_DragonBandAnalyzer_Enhanced.mqh",
208,
"4x iMA() calls for Dragon Band setup",
"SetupDragonBandIndicators() unified call"
);

m_initialized = true;
m_lastAnalysisTime = 0;

Print("? [PHASE 2] Dragon Band Enhanced migrated to unified system - 4 duplicate calls eliminated");
return true;
}

//+------------------------------------------------------------------+
//| ?? MAIN ENHANCED ANALYSIS FUNCTION                              |
//+------------------------------------------------------------------+
bool UpdateEnhancedAnalysis()
{
if(!m_initialized) return false;

// Update indicator buffers
if(!UpdateIndicatorBuffers()) return false;

// Calculate basic Dragon Band metrics
CalculateDragonMetrics();

// ?? ENHANCED: Detect Dragon Squeeze (Boss's missing feature)
DetectEnhancedDragonSqueeze();

// Analyze trend direction and strength
AnalyzeTrendDirection();

// Analyze price position and pullback zones
AnalyzePricePosition();

// Detect breakout readiness
DetectBreakoutReadiness();

// Calculate overall confidence
CalculateOverallConfidence();

m_currentAnalysis.analysisTime = TimeCurrent();
m_currentAnalysis.isValid = true;
m_lastUpdate = TimeCurrent();
m_analysisCount++;

return true;
}

//+------------------------------------------------------------------+
//| ?? UPDATE INDICATOR BUFFERS                                     |
//+------------------------------------------------------------------+
bool UpdateIndicatorBuffers()
{
// Copy EMA buffers with more history for squeeze detection
if(CopyBuffer(m_handleHigh, 0, 0, 50, m_emaHigh) <= 0) return false;
if(CopyBuffer(m_handleLow, 0, 0, 50, m_emaLow) <= 0) return false;
if(CopyBuffer(m_handleClose, 0, 0, 50, m_emaClose) <= 0) return false;
if(CopyBuffer(m_handleTrend89, 0, 0, 50, m_emaTrend89) <= 0) return false;

return true;
}

//+------------------------------------------------------------------+
//| ?? CALCULATE ENHANCED DRAGON METRICS                            |
//+------------------------------------------------------------------+
void CalculateDragonMetrics()
{
if(ArraySize(m_emaClose) < 10) return;

// Current Dragon Band values
m_currentAnalysis.emaHigh = m_emaHigh[0];
m_currentAnalysis.emaLow = m_emaLow[0];
m_currentAnalysis.emaClose = m_emaClose[0];
m_currentAnalysis.emaTrend89 = m_emaTrend89[0];

// Calculate Dragon Angle (slope of EMA Close) - Boss's key metric
double deltaPrice = m_emaClose[0] - m_emaClose[4];
double deltaBars = 4.0;
m_currentAnalysis.dragonSlope = deltaPrice / deltaBars;

// Convert to angle in degrees using Sonic R formula
double pixelsPerBar = 5.0;
double pixelsPerPrice = 100000.0;
m_currentAnalysis.dragonAngle = MathArctan(m_currentAnalysis.dragonSlope * pixelsPerPrice / pixelsPerBar) * 180.0 / M_PI;

// Normalize angle between -90 and 90
if(m_currentAnalysis.dragonAngle > 90) m_currentAnalysis.dragonAngle = 90;
if(m_currentAnalysis.dragonAngle < -90) m_currentAnalysis.dragonAngle = -90;

// Calculate band width metrics
m_currentAnalysis.bandWidth = m_emaHigh[0] - m_emaLow[0];
double currentPrice = (m_emaHigh[0] + m_emaLow[0]) / 2.0;
if(currentPrice > 0)
m_currentAnalysis.bandWidthPercent = (m_currentAnalysis.bandWidth / currentPrice) * 100.0;

// Normalize band width against historical average
if(m_normalBandWidth > 0)
m_currentAnalysis.bandWidthNormalized = m_currentAnalysis.bandWidth / m_normalBandWidth;

// Update band width history for squeeze detection
UpdateBandWidthHistory();
}

//+------------------------------------------------------------------+
//| ?? ENHANCED DRAGON SQUEEZE DETECTION (Boss's Missing Feature)   |
//+------------------------------------------------------------------+
void DetectEnhancedDragonSqueeze()
{
if(ArraySize(m_emaHigh) < 20 || ArraySize(m_emaLow) < 20) return;

// Calculate current band contraction
double currentWidth = m_currentAnalysis.bandWidth;
double avgWidth = CalculateAverageBandWidth(10); // 10-period average

// Enhanced squeeze detection criteria
bool isContracting = (currentWidth < avgWidth * m_squeezeThreshold);
bool hasMinimumContraction = (currentWidth < m_normalBandWidth * 0.6); // 40% below normal
bool isVolatilityLow = CheckLowVolatilityCondition();

// Update squeeze state
if(isContracting && hasMinimumContraction && isVolatilityLow) {
if(!m_currentAnalysis.isDragonSqueeze) {
// New squeeze detected
m_currentSqueezeBars = 1;
m_squeezeStartWidth = currentWidth;
m_squeezeMinWidth = currentWidth;
m_currentAnalysis.dragonState = DRAGON_SQUEEZE;

Print("?? NEW DRAGON SQUEEZE DETECTED | Width: ", DoubleToString(currentWidth, 5));
} else {
// Continuing squeeze
m_currentSqueezeBars++;
if(currentWidth < m_squeezeMinWidth) {
m_squeezeMinWidth = currentWidth;
}
}

m_currentAnalysis.isDragonSqueeze = true;
m_currentAnalysis.squeezeBars = m_currentSqueezeBars;

// Calculate squeeze intensity (0-1)
if(m_normalBandWidth > 0) {
m_currentAnalysis.squeezeIntensity = 1.0 - (currentWidth / m_normalBandWidth);
m_currentAnalysis.squeezeIntensity = MathMax(0.0, MathMin(1.0, m_currentAnalysis.squeezeIntensity));
}

// Calculate squeeze quality
CalculateSqueezeQuality();

} else {
// Check for squeeze breakout
if(m_currentAnalysis.isDragonSqueeze && m_currentSqueezeBars >= m_minSqueezeBars) {
// Squeeze breakout detected
DetectSqueezeBreakout();
}

// Reset squeeze state
m_currentAnalysis.isDragonSqueeze = false;
m_currentAnalysis.squeezeIntensity = 0.0;
m_currentSqueezeBars = 0;
m_currentAnalysis.dragonState = DRAGON_STABLE;
}

m_wasSqueezing = m_currentAnalysis.isDragonSqueeze;
}

//+------------------------------------------------------------------+
//| ?? CALCULATE SQUEEZE QUALITY                                     |
//+------------------------------------------------------------------+
void CalculateSqueezeQuality()
{
double quality = 0.0;

// Factor 1: Duration (30% weight)
double durationScore = 0.0;
if(m_currentSqueezeBars >= m_minSqueezeBars && m_currentSqueezeBars <= m_maxSqueezeBars) {
durationScore = (double)m_currentSqueezeBars / m_maxSqueezeBars;
}
quality += durationScore * 0.3;

// Factor 2: Intensity (40% weight)
quality += m_currentAnalysis.squeezeIntensity * 0.4;

// Factor 3: Trend alignment (20% weight)
double trendScore = 0.0;
if(MathAbs(m_currentAnalysis.dragonAngle) < 1.0) { // Low angle = good for squeeze
trendScore = 1.0 - (MathAbs(m_currentAnalysis.dragonAngle) / 5.0);
}
quality += trendScore * 0.2;

// Factor 4: Price position (10% weight)
double positionScore = 0.0;
if(m_currentAnalysis.pricePosition > 0.3 && m_currentAnalysis.pricePosition < 0.7) {
positionScore = 1.0; // Price in middle of band = good
}
quality += positionScore * 0.1;

m_currentAnalysis.squeezeQuality = MathMax(0.0, MathMin(1.0, quality));
}

//+------------------------------------------------------------------+
//| ?? DETECT SQUEEZE BREAKOUT                                       |
//+------------------------------------------------------------------+
void DetectSqueezeBreakout()
{
double currentWidth = m_currentAnalysis.bandWidth;
double expansionRatio = currentWidth / m_squeezeMinWidth;

// Breakout criteria: 50% expansion from minimum width
if(expansionRatio > 1.5) {
m_currentAnalysis.dragonState = DRAGON_EXPANSION;
m_currentAnalysis.isBreakoutReady = true;
m_breakoutTotalCount++;

// Determine breakout direction based on price position and angle
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double midpoint = (m_emaHigh[0] + m_emaLow[0]) / 2.0;

if(currentPrice > midpoint && m_currentAnalysis.dragonAngle > 0) {
Print("?? BULLISH DRAGON BREAKOUT | Angle: ", DoubleToString(m_currentAnalysis.dragonAngle, 1), "�");
} else if(currentPrice < midpoint && m_currentAnalysis.dragonAngle < 0) {
Print("?? BEARISH DRAGON BREAKOUT | Angle: ", DoubleToString(m_currentAnalysis.dragonAngle, 1), "�");
}
}
}

//+------------------------------------------------------------------+
//| ?? ANALYZE TREND DIRECTION AND STRENGTH                         |
//+------------------------------------------------------------------+
void AnalyzeTrendDirection()
{
if(ArraySize(m_emaClose) < 5) return;

// Determine trend based on Dragon Angle (Boss's 2-degree threshold)
if(m_currentAnalysis.dragonAngle > m_angleThreshold)
{
m_currentAnalysis.trendDirection = TREND_UP;
m_currentAnalysis.trendStrength = MathMin(MathAbs(m_currentAnalysis.dragonAngle) / 15.0, 1.0);
}
else if(m_currentAnalysis.dragonAngle < -m_angleThreshold)
{
m_currentAnalysis.trendDirection = TREND_DOWN;
m_currentAnalysis.trendStrength = MathMin(MathAbs(m_currentAnalysis.dragonAngle) / 15.0, 1.0);
}
else
{
m_currentAnalysis.trendDirection = TREND_SIDEWAYS;
m_currentAnalysis.trendStrength = 0.2; // Weak sideways movement
}

// Enhance trend strength with EMA 89 confirmation
double emaCloseVsTrend = m_currentAnalysis.emaClose - m_currentAnalysis.emaTrend89;
double trendConfirmation = 0.0;

if((m_currentAnalysis.trendDirection == TREND_UP && emaCloseVsTrend > 0) ||
(m_currentAnalysis.trendDirection == TREND_DOWN && emaCloseVsTrend < 0))
{
trendConfirmation = 0.3; // Trend confirmed by longer-term EMA
}

m_currentAnalysis.trendStrength = MathMin(m_currentAnalysis.trendStrength + trendConfirmation, 1.0);
}

//+------------------------------------------------------------------+
//| ?? ANALYZE PRICE POSITION AND PULLBACK ZONES (PHASE 2 ENHANCED) |
//+------------------------------------------------------------------+
void AnalyzePricePosition()
{
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double bandRange = m_currentAnalysis.bandWidth;

if(bandRange > 0) {
// Calculate position within Dragon Band (0 = bottom, 1 = top)
m_currentAnalysis.pricePosition = (currentPrice - m_emaLow[0]) / bandRange;
m_currentAnalysis.pricePosition = MathMax(0.0, MathMin(1.0, m_currentAnalysis.pricePosition));
}

// ?? PHASE 2: Enhanced Pullback Zone Logic per review.txt
bool inPullbackZone = IsPullbackZoneEnhanced();
double pullbackQuality = CalculatePullbackQuality();

m_currentAnalysis.isPullbackZone = inPullbackZone;
m_currentAnalysis.pullbackQuality = pullbackQuality;
}

//+------------------------------------------------------------------+
//| ?? PHASE 2: ENHANCED PULLBACK ZONE DETECTION (per review.txt)   |
//+------------------------------------------------------------------+
bool IsPullbackZoneEnhanced()
{
    // T�nh to�n v? tr� gi� trong d?i Dragon
    double dragonWidth = m_currentAnalysis.emaHigh - m_currentAnalysis.emaLow;
    if(dragonWidth <= 0) {
        Print("?? [PHASE 2] Dragon width invalid, fallback: no pullback zone");
        return false; // Fallback khi thi?u d? li?u
    }

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double pricePosition = (currentPrice - m_currentAnalysis.emaLow) / dragonWidth;

    // X�c d?nh pullback zone (20%-40% ho?c 60%-80%) theo review.txt
    bool inPullbackZone = ((pricePosition >= 0.2 && pricePosition <= 0.4) ||
                          (pricePosition >= 0.6 && pricePosition <= 0.8));

    // Co ch? early entry khi momentum m?nh
    if(inPullbackZone && IsStrongMomentum()) {
        Print("? [PHASE 2] Early entry: Strong momentum + pullback zone at ", DoubleToString(pricePosition*100, 1), "%");
        return true;
    }

    // Log l� do v�o l?nh theo y�u c?u review.txt
    if(inPullbackZone) {
        Print("? [PHASE 2] Pullback zone detected at ", DoubleToString(pricePosition*100, 1), "% of Dragon Band");
    }

    return inPullbackZone;
}

//+------------------------------------------------------------------+
//| ?? PHASE 2: CALCULATE PULLBACK QUALITY                          |
//+------------------------------------------------------------------+
double CalculatePullbackQuality()
{
    if(!m_currentAnalysis.isPullbackZone) return 0.0;

    double quality = 0.5; // Base quality

    // Factor 1: Price position within optimal zones
    double pricePos = m_currentAnalysis.pricePosition;
    if((pricePos >= 0.2 && pricePos <= 0.4) || (pricePos >= 0.6 && pricePos <= 0.8)) {
        quality += 0.3;
    }

    // Factor 2: Trend strength confirmation
    if(m_currentAnalysis.trendStrength > 0.6) {
        quality += 0.2;
    }

    return MathMin(1.0, quality);
}

//+------------------------------------------------------------------+
//| ?? PHASE 2: STRONG MOMENTUM DETECTION                           |
//+------------------------------------------------------------------+
bool IsStrongMomentum()
{
    // Strong Dragon angle indicates momentum
    bool strongAngle = (MathAbs(m_currentAnalysis.dragonAngle) > 8.0);

    // EMA confirmation
    bool emaConfirmation = false;
    if(m_currentAnalysis.trendDirection == TREND_UP && m_currentAnalysis.emaClose > m_currentAnalysis.emaTrend89) {
        emaConfirmation = true;
    }
    else if(m_currentAnalysis.trendDirection == TREND_DOWN && m_currentAnalysis.emaClose < m_currentAnalysis.emaTrend89) {
        emaConfirmation = true;
    }

    return strongAngle && emaConfirmation;
}

//+------------------------------------------------------------------+
//| ?? DETECT BREAKOUT READINESS                                     |
//+------------------------------------------------------------------+
void DetectBreakoutReadiness()
{
// Criteria for breakout readiness
bool hasSqueezeHistory = (m_currentSqueezeBars >= m_minSqueezeBars || m_wasSqueezing);
bool hasGoodAngle = (MathAbs(m_currentAnalysis.dragonAngle) > m_angleThreshold);
bool hasVolumeIncrease = CheckVolumeIncrease();
bool hasTrendConfirmation = (m_currentAnalysis.trendStrength > 0.5);

// Calculate breakout probability
double probability = 0.0;
if(hasSqueezeHistory) probability += 0.4;
if(hasGoodAngle) probability += 0.3;
if(hasVolumeIncrease) probability += 0.2;
if(hasTrendConfirmation) probability += 0.1;

m_currentAnalysis.breakoutProbability = probability;
m_currentAnalysis.isBreakoutReady = (probability >= 0.7); // 70% threshold
}

//+------------------------------------------------------------------+
//| ?? CALCULATE OVERALL CONFIDENCE                                  |
//+------------------------------------------------------------------+
void CalculateOverallConfidence()
{
double confidence = 0.5; // Base confidence

// Factor 1: Trend clarity (25%)
confidence += (m_currentAnalysis.trendStrength * 0.25);

// Factor 2: Dragon angle strength (25%)
double angleScore = MathMin(MathAbs(m_currentAnalysis.dragonAngle) / 10.0, 1.0);
confidence += (angleScore * 0.25);

// Factor 3: Squeeze quality (25%)
if(m_currentAnalysis.isDragonSqueeze) {
confidence += (m_currentAnalysis.squeezeQuality * 0.25);
} else {
confidence += 0.125; // Neutral if no squeeze
}

// Factor 4: EMA 89 confirmation (25%)
double emaConfirmation = 0.0;
if((m_currentAnalysis.emaClose > m_currentAnalysis.emaTrend89 && m_currentAnalysis.trendDirection == TREND_UP) ||
(m_currentAnalysis.emaClose < m_currentAnalysis.emaTrend89 && m_currentAnalysis.trendDirection == TREND_DOWN)) {
emaConfirmation = 1.0;
}
confidence += (emaConfirmation * 0.25);

m_currentAnalysis.confidence = MathMax(0.0, MathMin(1.0, confidence));

// Update average confidence tracking
if(m_analysisCount > 0) {
m_averageConfidence = ((m_averageConfidence * (m_analysisCount - 1)) + m_currentAnalysis.confidence) / m_analysisCount;
}
}

//+------------------------------------------------------------------+
//| ?? HELPER FUNCTIONS                                              |
//+------------------------------------------------------------------+

void CalculateNormalBandWidth()
{
// Calculate average band width over longer period for normalization
if(ArraySize(m_emaHigh) < 20 || ArraySize(m_emaLow) < 20) return;

double totalWidth = 0.0;
int count = 0;

for(int i = 1; i < 20; i++) { // Skip current bar
double width = m_emaHigh[i] - m_emaLow[i];
if(width > 0) {
totalWidth += width;
count++;
}
}

if(count > 0) {
m_normalBandWidth = totalWidth / count;
}
}

void UpdateBandWidthHistory()
{
// Shift history array
for(int i = 49; i > 0; i--) {
m_bandWidthHistory[i] = m_bandWidthHistory[i-1];
}

// Add current width
m_bandWidthHistory[0] = m_currentAnalysis.bandWidth;

if(m_bandHistoryCount < 50) m_bandHistoryCount++;
}

double CalculateAverageBandWidth(int period)
{
if(ArraySize(m_emaHigh) < period || ArraySize(m_emaLow) < period) return 0.0;

double total = 0.0;
for(int i = 1; i <= period; i++) {
total += (m_emaHigh[i] - m_emaLow[i]);
}

return total / period;
}

bool CheckLowVolatilityCondition()
{
// Check if recent volatility is low (supporting squeeze condition)
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atr[];
ArraySetAsSeries(atr, true);

if(CopyBuffer(atrHandle, 0, 0, 10, atr) < 10) {
IndicatorRelease(atrHandle);
return false;
}

double currentATR = atr[0];
double avgATR = 0.0;
for(int i = 1; i < 10; i++) avgATR += atr[i];
avgATR /= 9;

IndicatorRelease(atrHandle);

return (currentATR < avgATR * 0.8); // Current ATR 20% below average
}

bool CheckVolumeIncrease()
{
// Check for volume increase (supporting breakout)
long volumes[];
ArraySetAsSeries(volumes, true);

if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 5, volumes) < 5) {
return false;
}

double currentVol = (double)volumes[0];
double avgVol = 0.0;
for(int i = 1; i < 5; i++) avgVol += (double)volumes[i]; // ?? FIXED: Cast long to double explicitly
avgVol /= 4;

return (currentVol > avgVol * 1.2); // 20% volume increase
}

//+------------------------------------------------------------------+
//| ?? PUBLIC GETTERS AND ANALYSIS RESULTS                          |
//+------------------------------------------------------------------+

// Get Dragon Band score for main EA
double GetDragonBandScore()
{
if(!m_currentAnalysis.isValid) return 0.0;

double score = m_currentAnalysis.confidence;

// Boost score for squeeze conditions
if(m_currentAnalysis.isDragonSqueeze && m_currentAnalysis.squeezeQuality > 0.6) {
score = MathMin(1.0, score + 0.2);
}

// Boost score for breakout readiness
if(m_currentAnalysis.isBreakoutReady) {
score = MathMin(1.0, score + 0.1);
}

return score;
}

// Get current analysis
SEnhancedDragonBandData GetCurrentAnalysis() { return m_currentAnalysis; }



string GetDetailedReport()
{
return m_currentAnalysis.GetDetailedReport();
}

// Reset analysis (call when market conditions change significantly)
void Reset()
{
m_currentAnalysis.Reset();
m_currentSqueezeBars = 0;
m_wasSqueezing = false;
Print("?? Dragon Band analysis reset");
}

// Check specific conditions
bool IsDragonSqueeze() { return m_currentAnalysis.isDragonSqueeze; }
bool IsBreakoutReady() { return m_currentAnalysis.isBreakoutReady; }
bool IsPullbackZone() { return m_currentAnalysis.isPullbackZone; }
ENUM_TREND_DIRECTION GetTrendDirection() { return m_currentAnalysis.trendDirection; }
double GetDragonAngle() { return m_currentAnalysis.dragonAngle; }
double GetTrendStrength() { return m_currentAnalysis.trendStrength; }
};

#endif // ANALYSIS_DRAGON_BAND_ANALYZER_ENHANCED_MQH


