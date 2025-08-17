//+------------------------------------------------------------------+
//|                                  Risk_CorrelationHeatMap.mqh    |
//|                SONIC R MC - CORRELATION HEAT MAP MANAGEMENT      |
//|                   🎯 QUYẾT ĐỊNH SỐ 7: CORRELATION BREAKTHROUGH   |
//+------------------------------------------------------------------+

#ifndef RISK_CORRELATION_HEAT_MAP_MQH
#define RISK_CORRELATION_HEAT_MAP_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| Currency Index Enumeration                                       |
//+------------------------------------------------------------------+
enum ENUM_CURRENCY_INDEX
{
CURRENCY_USD = 0,    // US Dollar
CURRENCY_EUR = 1,    // Euro
CURRENCY_GBP = 2,    // British Pound
CURRENCY_JPY = 3,    // Japanese Yen
CURRENCY_CHF = 4,    // Swiss Franc
CURRENCY_AUD = 5,    // Australian Dollar
CURRENCY_CAD = 6,    // Canadian Dollar
CURRENCY_NZD = 7,    // New Zealand Dollar
CURRENCY_COUNT = 8   // Total number of currencies
};

//+------------------------------------------------------------------+
//| Correlation Heat Data Structure                                  |
//+------------------------------------------------------------------+
struct CorrelationHeatData
{
// Correlation matrix [from][to]
double correlationMatrix[8][8];    // 8x8 matrix for major currencies

// Heat levels per currency
double currencyHeat[8];            // Heat level for each currency
double totalPortfolioHeat;         // Overall portfolio heat
double maxAllowedHeat;             // Maximum allowed heat level

// Exposure tracking
double currencyExposure[8];        // Current exposure per currency
double maxCurrencyExposure;        // Maximum allowed per currency

// Risk assessment
double heatRiskMultiplier;         // Risk multiplier based on heat
bool overheatingWarning;           // Warning flag for overheating
ENUM_CURRENCY_INDEX hottestCurrency; // Most overexposed currency

// Time-based analysis
datetime lastUpdateTime;
int heatDuration[8];               // How long each currency has been hot

void Reset()
{
// Initialize correlation matrix
for(int i = 0; i < 8; i++) {
for(int j = 0; j < 8; j++) {
if(i == j) correlationMatrix[i][j] = 1.0; // Perfect self-correlation
else correlationMatrix[i][j] = 0.0;
}
currencyHeat[i] = 0.0;
currencyExposure[i] = 0.0;
heatDuration[i] = 0;
}

totalPortfolioHeat = 0.0;
maxAllowedHeat = 0.7;           // 70% max heat
maxCurrencyExposure = 0.4;      // 40% max per currency
heatRiskMultiplier = 1.0;
overheatingWarning = false;
hottestCurrency = CURRENCY_USD;
lastUpdateTime = 0;
}
};

//+------------------------------------------------------------------+
//| Currency Pair Information                                        |
//+------------------------------------------------------------------+
struct CurrencyPairInfo
{
string symbol;
ENUM_CURRENCY_INDEX baseCurrency;
ENUM_CURRENCY_INDEX quoteCurrency;
double lotSize;
bool isLong;               // True for long position, false for short
double riskWeight;         // Risk weight of this position
};

//+------------------------------------------------------------------+
//| 🎯 CORRELATION HEAT MAP MANAGEMENT SYSTEM                       |
//+------------------------------------------------------------------+
class CCorrelationHeatMapManager
{
private:
CorrelationHeatData m_heatData;

// Active positions tracking
CurrencyPairInfo m_activePositions[50];    // Track up to 50 positions
int m_positionCount;

// Historical correlation data
double m_correlationHistory[8][8][30];     // 30-day correlation history
int m_historyIndex;
int m_historyDays;

// Heat calculation parameters
double m_correlationLookback;              // Days for correlation calculation
double m_heatSensitivity;                  // Sensitivity of heat calculation
bool m_dynamicThresholds;                  // Whether to use dynamic thresholds

// Warning system
string m_warningMessages[10];              // Store warning messages
int m_warningCount;

public:
CCorrelationHeatMapManager() {
m_heatData.Reset();

// Initialize arrays
for(int i = 0; i < 50; i++) {
m_activePositions[i].symbol = "";
m_activePositions[i].baseCurrency = CURRENCY_COUNT;
m_activePositions[i].quoteCurrency = CURRENCY_COUNT;
m_activePositions[i].lotSize = 0.0;
m_activePositions[i].isLong = true;
m_activePositions[i].riskWeight = 1.0;
}

m_positionCount = 0;

// Initialize correlation history
for(int i = 0; i < CURRENCY_COUNT; i++) {
for(int j = 0; j < CURRENCY_COUNT; j++) {
for(int k = 0; k < 30; k++) {
m_correlationHistory[i][j][k] = 0.0;
}
}
}

m_historyIndex = 0;
m_historyDays = 0;

// Initialize parameters
m_correlationLookback = 20.0;
m_heatSensitivity = 1.0;
m_dynamicThresholds = true;

// Initialize warnings
for(int i = 0; i < 10; i++) {
m_warningMessages[i] = "";
}
m_warningCount = 0;

::Print("[CORRELATION HEAT] Correlation Heat Map Management system initialized");
::Print("[CONFIGURATION] Max Heat: ", m_heatData.maxAllowedHeat * 100, "% | Max Per Currency: ", m_heatData.maxCurrencyExposure * 100, "%");
}
~CCorrelationHeatMapManager() {}

//+------------------------------------------------------------------+
//| 🎯 MAIN CORRELATION HEAT CALCULATION                           |
//+------------------------------------------------------------------+
double CalculateCorrelationHeatRisk()
{
// Update current positions
UpdateActivePositions();

// Calculate real-time correlations
CalculateRealTimeCorrelations();

// Calculate currency exposures
CalculateCurrencyExposures();

// Calculate heat levels
CalculateCorrelationHeat();

// Assess risk multiplier
AssessHeatRiskMultiplier();

// Update warning system
UpdateHeatWarnings();

// Log heat analysis
LogHeatAnalysis();

return m_heatData.heatRiskMultiplier;
}

//+------------------------------------------------------------------+
//| 🎯 REAL-TIME CORRELATION CALCULATION                           |
//+------------------------------------------------------------------+
void CalculateRealTimeCorrelations()
{
// Define major currency pairs for correlation analysis
string pairs[] = {
"EURUSD", "GBPUSD", "USDJPY", "USDCHF", 
"AUDUSD", "USDCAD", "NZDUSD", "EURJPY",
"GBPJPY", "EURGBP", "AUDCAD", "AUDCHF"
};

int pairCount = ArraySize(pairs);
int lookbackPeriods = 20; // 20 periods for correlation

// Calculate correlations between currency pairs
for(int i = 0; i < pairCount; i++) {
for(int j = i + 1; j < pairCount; j++) {
double correlation = CalculatePairCorrelation(pairs[i], pairs[j], lookbackPeriods);

// Map pair correlations to currency correlations
UpdateCurrencyCorrelationFromPairs(pairs[i], pairs[j], correlation);
}
}

// Update correlation history
UpdateCorrelationHistory();
}

//+------------------------------------------------------------------+
//| 🎯 PAIR CORRELATION CALCULATION                                |
//+------------------------------------------------------------------+
double CalculatePairCorrelation(string symbol1, string symbol2, int periods)
{
// Get price data for both symbols
double prices1[], prices2[];
ArraySetAsSeries(prices1, true);
ArraySetAsSeries(prices2, true);

if(CopyClose(symbol1, PERIOD_H1, 0, periods, prices1) < periods ||
CopyClose(symbol2, PERIOD_H1, 0, periods, prices2) < periods) {
return 0.0; // Return neutral correlation if data unavailable
}

// Calculate returns
double returns1[], returns2[];
ArrayResize(returns1, periods - 1);
ArrayResize(returns2, periods - 1);

for(int i = 0; i < periods - 1; i++) {
if(prices1[i + 1] > 0) returns1[i] = (prices1[i] - prices1[i + 1]) / prices1[i + 1];
if(prices2[i + 1] > 0) returns2[i] = (prices2[i] - prices2[i + 1]) / prices2[i + 1];
}

// Calculate correlation coefficient
return CalculateCorrelationCoefficient(returns1, returns2, periods - 1);
}

//+------------------------------------------------------------------+
//| 🎯 CORRELATION COEFFICIENT CALCULATION                         |
//+------------------------------------------------------------------+
double CalculateCorrelationCoefficient(const double& array1[], const double& array2[], int size)
{
if(size < 2) return 0.0;

// Calculate means
double mean1 = 0.0, mean2 = 0.0;
for(int i = 0; i < size; i++) {
mean1 += array1[i];
mean2 += array2[i];
}
mean1 /= size;
mean2 /= size;

// Calculate correlation components
double numerator = 0.0;
double sum1Sq = 0.0, sum2Sq = 0.0;

for(int i = 0; i < size; i++) {
double diff1 = array1[i] - mean1;
double diff2 = array2[i] - mean2;

numerator += diff1 * diff2;
sum1Sq += diff1 * diff1;
sum2Sq += diff2 * diff2;
}

double denominator = MathSqrt(sum1Sq * sum2Sq);
if(denominator == 0.0) return 0.0;

double correlation = numerator / denominator;
return MathMax(-1.0, MathMin(1.0, correlation)); // Ensure [-1, 1] range
}

//+------------------------------------------------------------------+
//| 🎯 CURRENCY EXPOSURE CALCULATION                               |
//+------------------------------------------------------------------+
void CalculateCurrencyExposures()
{
// Reset exposures
for(int i = 0; i < CURRENCY_COUNT; i++) {
m_heatData.currencyExposure[i] = 0.0;
}

// Calculate exposures from active positions
for(int i = 0; i < m_positionCount; i++) {
CurrencyPairInfo pos;
pos = m_activePositions[i];
double exposure = pos.lotSize * pos.riskWeight;

if(pos.isLong) {
// Long position: Long base currency, short quote currency
m_heatData.currencyExposure[pos.baseCurrency] += exposure;
m_heatData.currencyExposure[pos.quoteCurrency] -= exposure;
} else {
// Short position: Short base currency, long quote currency
m_heatData.currencyExposure[pos.baseCurrency] -= exposure;
m_heatData.currencyExposure[pos.quoteCurrency] += exposure;
}
}

// Convert to absolute exposure percentages
double totalExposure = 0.0;
for(int i = 0; i < CURRENCY_COUNT; i++) {
totalExposure += MathAbs(m_heatData.currencyExposure[i]);
}

if(totalExposure > 0) {
for(int i = 0; i < CURRENCY_COUNT; i++) {
m_heatData.currencyExposure[i] = MathAbs(m_heatData.currencyExposure[i]) / totalExposure;
}
}
}

//+------------------------------------------------------------------+
//| 🎯 CORRELATION HEAT CALCULATION                                |
//+------------------------------------------------------------------+
void CalculateCorrelationHeat()
{
// Calculate heat for each currency
for(int i = 0; i < CURRENCY_COUNT; i++) {
m_heatData.currencyHeat[i] = 0.0;

// Sum correlation-weighted exposures with other currencies
for(int j = 0; j < CURRENCY_COUNT; j++) {
if(i != j) {
double correlation = MathAbs(m_heatData.correlationMatrix[i][j]);
double otherExposure = m_heatData.currencyExposure[j];
m_heatData.currencyHeat[i] += correlation * otherExposure;
}
}

// Apply own exposure
m_heatData.currencyHeat[i] += m_heatData.currencyExposure[i];

// Normalize heat
m_heatData.currencyHeat[i] = MathMin(1.0, m_heatData.currencyHeat[i]);
}

// Calculate total portfolio heat
m_heatData.totalPortfolioHeat = 0.0;
for(int i = 0; i < CURRENCY_COUNT; i++) {
m_heatData.totalPortfolioHeat += m_heatData.currencyHeat[i];
}
m_heatData.totalPortfolioHeat /= CURRENCY_COUNT;

// Find hottest currency
double maxHeat = 0.0;
for(int i = 0; i < CURRENCY_COUNT; i++) {
if(m_heatData.currencyHeat[i] > maxHeat) {
maxHeat = m_heatData.currencyHeat[i];
m_heatData.hottestCurrency = (ENUM_CURRENCY_INDEX)i;
}
}
}

//+------------------------------------------------------------------+
//| 🎯 HEAT RISK ASSESSMENT                                        |
//+------------------------------------------------------------------+
void AssessHeatRiskMultiplier()
{
double totalHeat = m_heatData.totalPortfolioHeat;

if(totalHeat < 0.3) {
// Low heat - normal trading
m_heatData.heatRiskMultiplier = 1.0;
}
else if(totalHeat < 0.5) {
// Moderate heat - slight caution
m_heatData.heatRiskMultiplier = 0.9;
}
else if(totalHeat < 0.7) {
// High heat - reduce risk
m_heatData.heatRiskMultiplier = 0.7;
}
else if(totalHeat < 0.9) {
// Very high heat - significant risk reduction
m_heatData.heatRiskMultiplier = 0.4;
}
else {
// Critical heat - minimal trading
m_heatData.heatRiskMultiplier = 0.2;
}

// Additional penalty for individual currency overexposure
double maxCurrencyHeat = m_heatData.currencyHeat[m_heatData.hottestCurrency];
if(maxCurrencyHeat > 0.8) {
m_heatData.heatRiskMultiplier *= 0.5; // Additional 50% penalty
}
}

//+------------------------------------------------------------------+
//| 🎯 WARNING SYSTEM                                              |
//+------------------------------------------------------------------+
void UpdateHeatWarnings()
{
m_warningCount = 0;
m_heatData.overheatingWarning = false;

// Check total portfolio heat
if(m_heatData.totalPortfolioHeat > m_heatData.maxAllowedHeat) {
m_heatData.overheatingWarning = true;
AddWarning(StringFormat("Portfolio overheating: %.1f%% (Max: %.1f%%)", 
m_heatData.totalPortfolioHeat * 100, 
m_heatData.maxAllowedHeat * 100));
}

// Check individual currency heat
for(int i = 0; i < CURRENCY_COUNT; i++) {
if(m_heatData.currencyHeat[i] > 0.8) {
AddWarning(StringFormat("%s overexposure: %.1f%%", 
CurrencyIndexToString((ENUM_CURRENCY_INDEX)i),
m_heatData.currencyHeat[i] * 100));
m_heatData.heatDuration[i]++;
} else {
m_heatData.heatDuration[i] = 0;
}
}

// Check correlation clustering
double highCorrelationCount = 0;
for(int i = 0; i < CURRENCY_COUNT; i++) {
for(int j = i + 1; j < CURRENCY_COUNT; j++) {
if(MathAbs(m_heatData.correlationMatrix[i][j]) > 0.7) {
highCorrelationCount++;
}
}
}

if(highCorrelationCount > 10) { // Threshold for too many high correlations
AddWarning("High correlation clustering detected");
}
}

//+------------------------------------------------------------------+
//| 🎯 HELPER METHODS                                              |
//+------------------------------------------------------------------+
void UpdateActivePositions()
{
m_positionCount = 0;

// Scan all open positions
for(int i = PositionsTotal() - 1; i >= 0; i--) {
ulong ticket = PositionGetTicket(i);
if(PositionSelectByTicket(ticket)) {
string symbol = PositionGetString(POSITION_SYMBOL);
double lotSize = PositionGetDouble(POSITION_VOLUME);
ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

// Parse currency pair
ENUM_CURRENCY_INDEX baseCurr, quoteCurr;
if(ParseCurrencyPair(symbol, baseCurr, quoteCurr)) {
m_activePositions[m_positionCount].symbol = symbol;
m_activePositions[m_positionCount].baseCurrency = baseCurr;
m_activePositions[m_positionCount].quoteCurrency = quoteCurr;
m_activePositions[m_positionCount].lotSize = lotSize;
m_activePositions[m_positionCount].isLong = (posType == POSITION_TYPE_BUY);
m_activePositions[m_positionCount].riskWeight = 1.0; // Default weight

m_positionCount++;
if(m_positionCount >= 50) break; // Array limit
}
}
}
}

bool ParseCurrencyPair(string symbol, ENUM_CURRENCY_INDEX& baseCurr, ENUM_CURRENCY_INDEX& quoteCurr)
{
// Extract first 6 characters for currency pair
if(StringLen(symbol) < 6) return false;

string base = StringSubstr(symbol, 0, 3);
string quote = StringSubstr(symbol, 3, 3);

baseCurr = StringToCurrencyIndex(base);
quoteCurr = StringToCurrencyIndex(quote);

return (baseCurr != CURRENCY_COUNT && quoteCurr != CURRENCY_COUNT);
}

ENUM_CURRENCY_INDEX StringToCurrencyIndex(string currency)
{
if(currency == "USD") return CURRENCY_USD;
else if(currency == "EUR") return CURRENCY_EUR;
else if(currency == "GBP") return CURRENCY_GBP;
else if(currency == "JPY") return CURRENCY_JPY;
else if(currency == "CHF") return CURRENCY_CHF;
else if(currency == "AUD") return CURRENCY_AUD;
else if(currency == "CAD") return CURRENCY_CAD;
else if(currency == "NZD") return CURRENCY_NZD;
else return CURRENCY_COUNT; // Invalid currency
}

string CurrencyIndexToString(ENUM_CURRENCY_INDEX index)
{
switch(index) {
case CURRENCY_USD: return "USD";
case CURRENCY_EUR: return "EUR";
case CURRENCY_GBP: return "GBP";
case CURRENCY_JPY: return "JPY";
case CURRENCY_CHF: return "CHF";
case CURRENCY_AUD: return "AUD";
case CURRENCY_CAD: return "CAD";
case CURRENCY_NZD: return "NZD";
default: return "UNKNOWN";
}
}

void UpdateCurrencyCorrelationFromPairs(string pair1, string pair2, double correlation)
{
// This is a simplified mapping - in reality, you'd need more sophisticated
// analysis to convert pair correlations to currency correlations

ENUM_CURRENCY_INDEX base1, quote1, base2, quote2;
if(ParseCurrencyPair(pair1, base1, quote1) && 
ParseCurrencyPair(pair2, base2, quote2)) {

// Update correlation matrix (simplified)
if(base1 == base2 || quote1 == quote2) {
// Pairs share a currency - positive correlation possible
m_heatData.correlationMatrix[base1][base2] = correlation;
m_heatData.correlationMatrix[base2][base1] = correlation;
}
}
}

void UpdateCorrelationHistory()
{
// Store current correlations in history
for(int i = 0; i < CURRENCY_COUNT; i++) {
for(int j = 0; j < CURRENCY_COUNT; j++) {
m_correlationHistory[i][j][m_historyIndex] = m_heatData.correlationMatrix[i][j];
}
}

m_historyIndex = (m_historyIndex + 1) % 30;
if(m_historyDays < 30) m_historyDays++;
}

void AddWarning(string message)
{
if(m_warningCount < 10) {
m_warningMessages[m_warningCount] = message;
m_warningCount++;
::Print("[CORRELATION HEAT] ", message);
}
}

void LogHeatAnalysis()
{
static datetime lastLog = 0;
if(TimeCurrent() - lastLog < 1800) return; // Log every 30 minutes

::Print(StringFormat("[HEAT MAP] Total Heat: %.1f%% | Hottest: %s (%.1f%%) | Risk Multiplier: %.2f",
m_heatData.totalPortfolioHeat * 100,
CurrencyIndexToString(m_heatData.hottestCurrency),
m_heatData.currencyHeat[m_heatData.hottestCurrency] * 100,
m_heatData.heatRiskMultiplier));

lastLog = TimeCurrent();
}

// Public interface methods
double GetHeatRiskMultiplier() const { return m_heatData.heatRiskMultiplier; }
CorrelationHeatData GetHeatData() const { return m_heatData; }
bool IsOverheating() const { return m_heatData.overheatingWarning; }
double GetCurrencyHeat(ENUM_CURRENCY_INDEX currency) const 
{ 
return (currency < CURRENCY_COUNT) ? m_heatData.currencyHeat[currency] : 0.0; 
}

void SetMaxAllowedHeat(double maxHeat) 
{ 
m_heatData.maxAllowedHeat = MathMax(0.3, MathMin(1.0, maxHeat)); 
}

void SetHeatSensitivity(double sensitivity) 
{ 
m_heatSensitivity = MathMax(0.5, MathMin(2.0, sensitivity)); 
}

string GetCorrelationHeatReport()
{
string report = "CORRELATION HEAT MAP ANALYSIS\n";
report += StringFormat("Total Portfolio Heat: %.1f%% (Max: %.1f%%)\n", 
m_heatData.totalPortfolioHeat * 100, 
m_heatData.maxAllowedHeat * 100);
report += StringFormat("Risk Multiplier: %.2fx\n", m_heatData.heatRiskMultiplier);
report += StringFormat("Overheating Warning: %s\n", m_heatData.overheatingWarning ? "YES" : "NO");
report += "Currency Heat Levels:\n";

for(int i = 0; i < CURRENCY_COUNT; i++) {
if(m_heatData.currencyHeat[i] > 0.1) { // Only show significant heat
report += StringFormat("  %s: %.1f%%", 
CurrencyIndexToString((ENUM_CURRENCY_INDEX)i),
m_heatData.currencyHeat[i] * 100);
if(i == m_heatData.hottestCurrency) report += " (HOTTEST)";
report += "\n";
}
}

if(m_warningCount > 0) {
report += "Active Warnings:\n";
for(int i = 0; i < m_warningCount; i++) {
report += "  " + m_warningMessages[i] + "\n";
}
}

return report;
}
};


#endif // RISK_CORRELATION_HEAT_MAP_MQH


