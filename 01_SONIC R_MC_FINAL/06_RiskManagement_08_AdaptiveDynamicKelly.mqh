//+------------------------------------------------------------------+
//|                                  Risk_AdaptiveDynamicKelly.mqh  |
//|                    SONIC R MC - ADAPTIVE DYNAMIC KELLY SYSTEM    |
//|                    ?? QUY?T Ð?NH S? 1: RISK BREAKTHROUGH         |
//+------------------------------------------------------------------+

#ifndef RISK_ADAPTIVE_DYNAMIC_KELLY_MQH
#define RISK_ADAPTIVE_DYNAMIC_KELLY_MQH

#define MAX_HISTORY_SIZE 50  // Maximum history size for arrays

#include "01_Core_22_SonicEnums.mqh"
#include "06_RiskManagement_10_KellyCriterion.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| Enhanced Market Regime Data for Kelly Calculation               |
//+------------------------------------------------------------------+
struct MarketRegimeKellyData
{
ENUM_MARKET_REGIME currentRegime;
double volatilityRegime;        // 0.5-2.0+ (normal-extreme)
double regimePersistence;       // How stable is current regime (0-1)
datetime regimeStartTime;
int regimeDuration;            // Bars in current regime
double volatilityAdjustment;   // Dynamic volatility multiplier
double convexityAdjustment;    // Equity curve convexity multiplier
double persistenceAdjustment;  // Regime persistence multiplier

void Reset()
{
currentRegime = REGIME_UNKNOWN;
volatilityRegime = 1.0;
regimePersistence = 0.5;
regimeStartTime = 0;
regimeDuration = 0;
volatilityAdjustment = 1.0;
convexityAdjustment = 1.0;
persistenceAdjustment = 1.0;
}
};

//+------------------------------------------------------------------+
//| Equity Curve Convexity Analysis                                 |
//+------------------------------------------------------------------+
struct EquityCurveData
{
double equityHistory[200];     // Last 200 equity points
int historyIndex;
int historyCount;
double currentConvexity;       // Current convexity measure
double convexityTrend;         // Convexity trend (improving/degrading)
double riskAdjustment;         // Risk adjustment based on convexity
bool isDangerous;              // Flag for dangerous equity curve shape

void Initialize()
{
ArrayInitialize(equityHistory, 0.0);
historyIndex = 0;
historyCount = 0;
currentConvexity = 0.0;
convexityTrend = 0.0;
riskAdjustment = 1.0;
isDangerous = false;
}
};

//+------------------------------------------------------------------+
//| ?? ADAPTIVE DYNAMIC KELLY SYSTEM - BOSS'S BREAKTHROUGH          |
//+------------------------------------------------------------------+
class CAdaptiveDynamicKelly : public CKellyCriterionSizer
{
private:
MarketRegimeKellyData m_regimeData;
EquityCurveData m_equityData;

// Enhanced Kelly parameters
double m_fractionalKellyFactor;     // Fractional Kelly safety (0.25-0.5)
double m_maxAllowedKelly;           // Maximum Kelly allowed (5%)
double m_blackSwanProtection;       // Protection against extreme events

// Performance tracking for adaptation
double m_recentEquity[50];          // Recent equity curve
int m_equityIndex;
int m_equityCount;

// Volatility regime tracking
double m_atrHistory[30];            // ATR history for volatility regime
int m_atrIndex;
int m_atrCount;

// Regime persistence tracking
ENUM_MARKET_REGIME m_previousRegime;
int m_regimeChangeCount;
datetime m_lastRegimeChange;

public:
CAdaptiveDynamicKelly();
~CAdaptiveDynamicKelly() {}

//+------------------------------------------------------------------+
//| ?? MAIN ADAPTIVE DYNAMIC KELLY CALCULATION                      |
//+------------------------------------------------------------------+
double CalculateAdaptiveDynamicKelly(double winRate, double profitFactor, 
double signalConfidence, ENUM_MARKET_REGIME currentRegime)
{
// Update regime data
UpdateMarketRegimeData(currentRegime);

// Update equity curve analysis
UpdateEquityCurveAnalysis();

// 1. Calculate base Kelly fraction
if(winRate <= 0.5 || profitFactor <= 1.0) {
Print("[??? ADAPTIVE KELLY] Invalid system metrics - using minimum risk");
return 0.5; // Minimum 0.5% risk
}

double kellyBase = (profitFactor * winRate - (1 - winRate)) / profitFactor;

// 2. QUY?T Ð?NH S? 1: Volatility Regime Adjustment
CalculateVolatilityRegimeAdjustment();

// 3. QUY?T Ð?NH S? 2: Equity Curve Convexity Adjustment  
CalculateEquityCurveConvexityAdjustment();

// 4. QUY?T Ð?NH S? 3: Regime Persistence Adjustment
CalculateRegimePersistenceAdjustment();

// 5. Apply fractional Kelly with all adjustments
double finalKelly = kellyBase * m_fractionalKellyFactor * 
m_regimeData.volatilityAdjustment *
m_regimeData.convexityAdjustment *
m_regimeData.persistenceAdjustment;

// 6. Signal confidence adjustment
finalKelly *= GetSignalConfidenceMultiplier(signalConfidence);

// 7. Apply safety limits and Black Swan protection
finalKelly = ApplySafetyLimits(finalKelly);

// 8. Log detailed analysis
LogKellyAnalysis(kellyBase, finalKelly);

return finalKelly;
}

//+------------------------------------------------------------------+
//| ?? VOLATILITY REGIME ADJUSTMENT (QUY?T Ð?NH S? 1)              |
//+------------------------------------------------------------------+
void CalculateVolatilityRegimeAdjustment()
{
// Calculate current volatility regime
double currentATR = GetCurrentATR();
double avgATR = CalculateAverageATR(20);

m_regimeData.volatilityRegime = (avgATR > 0) ? currentATR / avgATR : 1.0;

// Determine volatility adjustment
if(m_regimeData.volatilityRegime > 1.5) {
// Black Swan territory
m_regimeData.volatilityAdjustment = 0.5;
m_blackSwanProtection = 0.3;
Print("[?? BLACK SWAN] Extreme volatility detected: ", 
DoubleToString(m_regimeData.volatilityRegime, 2), "x normal");
}
else if(m_regimeData.volatilityRegime > 1.2) {
// High volatility
m_regimeData.volatilityAdjustment = 0.7;
m_blackSwanProtection = 0.8;
}
else if(m_regimeData.volatilityRegime < 0.7) {
// Low volatility - can increase position size slightly
m_regimeData.volatilityAdjustment = 1.3;
m_blackSwanProtection = 1.0;
}
else {
// Normal volatility
m_regimeData.volatilityAdjustment = 1.0;
m_blackSwanProtection = 1.0;
}
}

//+------------------------------------------------------------------+
//| ?? EQUITY CURVE CONVEXITY ADJUSTMENT (QUY?T Ð?NH S? 2)         |
//+------------------------------------------------------------------+
void CalculateEquityCurveConvexityAdjustment()
{
if(m_equityData.historyCount < 20) {
m_regimeData.convexityAdjustment = 1.0;
return;
}

// Calculate convexity using second derivative approximation
double convexity = CalculateEquityCurveConvexity();
m_equityData.currentConvexity = convexity;

if(convexity > 0.05) {
// Strong positive convexity (accelerating profits)
m_regimeData.convexityAdjustment = 1.2;
m_equityData.isDangerous = false;
Print("[?? CONVEXITY] Strong positive convexity: +", 
DoubleToString(convexity * 100, 1), "% - Increasing risk");
}
else if(convexity > 0.01) {
// Moderate positive convexity
m_regimeData.convexityAdjustment = 1.1;
m_equityData.isDangerous = false;
}
else if(convexity > -0.02) {
// Neutral to slightly negative
m_regimeData.convexityAdjustment = 1.0;
m_equityData.isDangerous = false;
}
else if(convexity > -0.03) {
// Concerning negative convexity
m_regimeData.convexityAdjustment = 0.6;
m_equityData.isDangerous = true;
Print("[?? CONVEXITY] Negative convexity detected: ", 
DoubleToString(convexity * 100, 1), "% - Reducing risk");
}
else {
// Dangerous concavity - major risk reduction
m_regimeData.convexityAdjustment = 0.4;
m_equityData.isDangerous = true;
Print("[?? DANGER] Dangerous equity concavity: ", 
DoubleToString(convexity * 100, 1), "% - Major risk reduction");
}
}

//+------------------------------------------------------------------+
//| ?? REGIME PERSISTENCE ADJUSTMENT (QUY?T Ð?NH S? 3)             |
//+------------------------------------------------------------------+
void CalculateRegimePersistenceAdjustment()
{
// Calculate how stable/persistent current regime is
double persistence = CalculateRegimePersistence();
m_regimeData.regimePersistence = persistence;

// Adjust based on persistence
if(persistence > 0.8) {
// Very stable regime - can be more aggressive
m_regimeData.persistenceAdjustment = 1.2;
}
else if(persistence > 0.6) {
// Moderately stable
m_regimeData.persistenceAdjustment = 1.1;
}
else if(persistence > 0.4) {
// Average stability
m_regimeData.persistenceAdjustment = 1.0;
}
else if(persistence > 0.2) {
// Low stability
m_regimeData.persistenceAdjustment = 0.9;
}
else {
// Very unstable - reduce risk significantly
m_regimeData.persistenceAdjustment = 0.8;
Print("[??? INSTABILITY] Low regime persistence: ", 
DoubleToString(persistence * 100, 1), "% - Reducing risk");
}
}

//+------------------------------------------------------------------+
//| ?? HELPER CALCULATION METHODS                                   |
//+------------------------------------------------------------------+
double CalculateEquityCurveConvexity()
{
if(m_equityData.historyCount < 20) return 0.0;

// Use recent 20 points for convexity calculation
int points = MathMin(20, m_equityData.historyCount);
double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;

for(int i = 0; i < points; i++) {
double x = i;
double y = m_equityData.equityHistory[(m_equityData.historyIndex - i + 200) % 200];
sumX += x;
sumY += y;
sumXY += x * y;
sumX2 += x * x;
sumY2 += y * y;
}

// Calculate linear regression
double n = points;
double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);

// Calculate second derivative (convexity approximation)
double convexity = 0.0;
if(points >= 10) {
// Compare slope of first half vs second half
double firstHalfSlope = CalculateHalfSlope(0, points/2);
double secondHalfSlope = CalculateHalfSlope(points/2, points);
convexity = (secondHalfSlope - firstHalfSlope) / points;
}

return convexity;
}

double CalculateHalfSlope(int start, int end)
{
double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
int count = end - start;

for(int i = start; i < end; i++) {
double x = i;
double y = m_equityData.equityHistory[(m_equityData.historyIndex - i + 200) % 200];
sumX += x;
sumY += y;
sumXY += x * y;
sumX2 += x * x;
}

if(count > 1) {
return (count * sumXY - sumX * sumY) / (count * sumX2 - sumX * sumX);
}
return 0.0;
}

double CalculateRegimePersistence()
{
if(m_regimeData.regimeDuration <= 0) return 0.0;

// Base persistence on regime duration and stability
double basePersistence = MathMin(1.0, m_regimeData.regimeDuration / 50.0); // 50 bars = full persistence

// Adjust for recent regime changes
if(m_regimeChangeCount > 5) {
basePersistence *= 0.5; // High regime change frequency reduces persistence
}
else if(m_regimeChangeCount > 3) {
basePersistence *= 0.7;
}
else if(m_regimeChangeCount <= 1) {
basePersistence *= 1.2; // Very stable
}

return MathMax(0.0, MathMin(1.0, basePersistence));
}

double GetSignalConfidenceMultiplier(double confidence)
{
// Adjust Kelly based on signal confidence
if(confidence >= 0.9) return 1.2;        // Very high confidence
else if(confidence >= 0.8) return 1.0;   // High confidence
else if(confidence >= 0.7) return 0.9;   // Medium confidence
else if(confidence >= 0.6) return 0.8;   // Lower confidence
else return 0.6;                         // Low confidence
}

double ApplySafetyLimits(double kelly)
{
// Apply Black Swan protection
kelly *= m_blackSwanProtection;

// Ensure within absolute limits
kelly = MathMax(0.002, MathMin(m_maxAllowedKelly, kelly)); // 0.2% min, 5% max

// Additional safety for dangerous equity curves
if(m_equityData.isDangerous) {
kelly = MathMin(kelly, 0.01); // Max 1% in dangerous conditions
}

return kelly;
}

//+------------------------------------------------------------------+
//| ?? DATA UPDATE METHODS                                          |
//+------------------------------------------------------------------+
void UpdateMarketRegimeData(ENUM_MARKET_REGIME newRegime)
{
if(newRegime != m_regimeData.currentRegime) {
m_previousRegime = m_regimeData.currentRegime;
m_regimeData.currentRegime = newRegime;
m_regimeData.regimeStartTime = TimeCurrent();
m_regimeData.regimeDuration = 0;
m_regimeChangeCount++;
m_lastRegimeChange = TimeCurrent();
} else {
m_regimeData.regimeDuration++;
}

// Reset regime change count periodically
if(TimeCurrent() - m_lastRegimeChange > 86400) { // 24 hours
m_regimeChangeCount = MathMax(0, m_regimeChangeCount - 1);
}
}

void UpdateEquityCurveAnalysis()
{
// Add current equity to history
double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
m_equityData.equityHistory[m_equityData.historyIndex] = currentEquity;
m_equityData.historyIndex = (m_equityData.historyIndex + 1) % 200;
if(m_equityData.historyCount < 200) m_equityData.historyCount++;
}

void LogKellyAnalysis(double baseKelly, double finalKelly)
{
Print(StringFormat("[?? ADAPTIVE KELLY] Base: %.3f%% | Vol: %.2fx | Conv: %.2fx | Pers: %.2fx | Final: %.3f%%",
baseKelly * 100,
m_regimeData.volatilityAdjustment,
m_regimeData.convexityAdjustment,
m_regimeData.persistenceAdjustment,
finalKelly * 100));

if(m_equityData.isDangerous) {
Print("[?? KELLY WARNING] Dangerous equity curve detected - risk severely limited");
}
}

// Helper methods for ATR calculation
double CalculateAverageATR(int period)
{
if(m_atrCount < period) {
// Not enough data, use simple ATR
return iATR(_Symbol, PERIOD_CURRENT, 14);
}

double sum = 0.0;
int count = 0;
int start = MathMax(0, m_atrCount - period);

for(int i = start; i < m_atrCount; i++) {
sum += m_atrHistory[i % MAX_HISTORY_SIZE];
count++;
}

return (count > 0) ? sum / count : iATR(_Symbol, PERIOD_CURRENT, 14);
}

double GetCurrentATR()
{
double atr = iATR(_Symbol, PERIOD_CURRENT, 14);

// Add to history
if(m_atrCount < MAX_HISTORY_SIZE) {
m_atrHistory[m_atrCount] = atr;
m_atrCount++;
} else {
m_atrHistory[m_atrIndex] = atr;
m_atrIndex = (m_atrIndex + 1) % MAX_HISTORY_SIZE;
}

return atr;
}

// Public getters
MarketRegimeKellyData GetRegimeData() const { return m_regimeData; }
EquityCurveData GetEquityData() const { return m_equityData; }
bool IsEquityCurveDangerous() const { return m_equityData.isDangerous; }
double GetCurrentConvexity() const { return m_equityData.currentConvexity; }
double GetVolatilityRegime() const { return m_regimeData.volatilityRegime; }

// Configuration methods
void SetFractionalKellyFactor(double factor) { 
m_fractionalKellyFactor = MathMax(0.1, MathMin(0.5, factor)); 
}
void SetMaxAllowedKelly(double maxKelly) { 
m_maxAllowedKelly = MathMax(0.01, MathMin(0.1, maxKelly)); 
}

string GetAdaptiveKellyReport()
{
return StringFormat(
"?? ADAPTIVE DYNAMIC KELLY REPORT\n" +
"Volatility Regime: %.2fx (Adj: %.2fx)\n" +
"Equity Convexity: %.3f%% (Adj: %.2fx)\n" +
"Regime Persistence: %.1f%% (Adj: %.2fx)\n" +
"Fractional Kelly Factor: %.2f\n" +
"Max Allowed Kelly: %.2f%%\n" +
"Equity Status: %s\n" +
"Black Swan Protection: %.2fx",
m_regimeData.volatilityRegime, m_regimeData.volatilityAdjustment,
m_equityData.currentConvexity * 100, m_regimeData.convexityAdjustment,
m_regimeData.regimePersistence * 100, m_regimeData.persistenceAdjustment,
m_fractionalKellyFactor,
m_maxAllowedKelly * 100,
m_equityData.isDangerous ? "DANGEROUS" : "HEALTHY",
m_blackSwanProtection
);
}
};

//+------------------------------------------------------------------+
//| ?? CONSTRUCTOR IMPLEMENTATION                                    |
//+------------------------------------------------------------------+
CAdaptiveDynamicKelly::CAdaptiveDynamicKelly()
{
m_regimeData.Reset();
m_equityData.Initialize();

// Initialize enhanced Kelly parameters
m_fractionalKellyFactor = 0.5;  // Half-Kelly for safety (Boss's conservative approach)
m_maxAllowedKelly = 0.05;       // Maximum 5% risk per trade
m_blackSwanProtection = 1.0;    // No protection initially

// Initialize tracking arrays
ArrayInitialize(m_recentEquity, 0.0);
ArrayInitialize(m_atrHistory, 0.0);
m_equityIndex = 0;
m_equityCount = 0;
m_atrIndex = 0;
m_atrCount = 0;

// Initialize regime tracking
m_previousRegime = REGIME_UNKNOWN;
m_regimeChangeCount = 0;
m_lastRegimeChange = TimeCurrent();

Print("[?? ADAPTIVE KELLY] Adaptive Dynamic Kelly system initialized");
Print("[?? CONFIGURATION] Fractional Factor: ", m_fractionalKellyFactor, 
" | Max Kelly: ", m_maxAllowedKelly * 100, "%");
}

#endif // RISK_ADAPTIVE_DYNAMIC_KELLY_MQH 


