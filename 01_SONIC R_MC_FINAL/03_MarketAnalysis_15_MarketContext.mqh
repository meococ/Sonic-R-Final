//+------------------------------------------------------------------+
//|                                    Analysis_MarketContext.mqh   |
//|                  SONIC R MC - Advanced Market Context Analysis  |
//|                             PHASE 3: MARKET INTELLIGENCE        |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Phase 3"
#property version   "3.00"
// PRODUCTION FIX: Remove #property strict - MQL4 syntax not supported in MQL5

#ifndef ANALYSIS_MARKET_CONTEXT_MQH
#define ANALYSIS_MARKET_CONTEXT_MQH


#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_07_CommonStructures.mqh"

// Note: ENUM_VOLATILITY_REGIME is defined in SonicR_Enums.mqh

// Note: ENUM_MICROSTRUCTURE_STATE is defined in SonicR_Enums.mqh

//+------------------------------------------------------------------+
//| CORRELATION DATA STRUCTURE                                      |
//+------------------------------------------------------------------+
struct CorrelationData
{
string                  asset1;
string                  asset2;
double                  correlation;
double                  beta;
ENUM_TIMEFRAMES         timeframe;
int                     period;
double                  rsquared;
bool                    isValid;
datetime                lastUpdate;

void Reset()
{
asset1 = "";
asset2 = "";
correlation = 0.0;
beta = 0.0;
timeframe = PERIOD_CURRENT;
period = 50;
rsquared = 0.0;
isValid = false;
lastUpdate = 0;
}
};

//+------------------------------------------------------------------+
//| VOLATILITY REGIME DATA                                          |
//+------------------------------------------------------------------+
// PHASE 3.3 FIX: Use VolatilityRegimeData from SonicR_CommonStructs.mqh to avoid redefinition
// Remove duplicate struct definition

// MicrostructureData struct is defined in SonicR_CommonStructs.mqh

//+------------------------------------------------------------------+
//| ADVANCED VOLATILITY REGIME ANALYZER - PHASE 3                  |
//+------------------------------------------------------------------+
class CVolatilityRegimeAnalyzer
{
private:
VolatilityRegimeData    m_regimeData;
double                  m_atrHistory[100];
double                  m_rvHistory[50];
int                     m_atrIndex;
int                     m_rvIndex;

// Handles for indicators
int                     m_atrHandle;
int                     m_atrLongHandle;

// AGGRESSIVE ADDITION - Missing variables for MarketContext
ENUM_VOLATILITY_REGIME  currentRegime;
ENUM_VOLATILITY_REGIME  previousRegime;
double                  atrPercentile;
datetime                regimeStartTime;
double                  regimeDuration;
double                  volatilityTrend;
double                  volatilityMean;
double                  volatilityStdDev;

// FINAL SPRINT - Additional missing variables
bool                    m_useDLL;
bool                    m_usePipe;

public:
CVolatilityRegimeAnalyzer()
{
m_atrIndex = 0;
m_rvIndex = 0;
ArrayInitialize(m_atrHistory, 0.0);
ArrayInitialize(m_rvHistory, 0.0);

// Initialize indicators
m_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
m_atrLongHandle = iATR(_Symbol, PERIOD_CURRENT, 50);
}

~CVolatilityRegimeAnalyzer()
{
if(m_atrHandle != INVALID_HANDLE) IndicatorRelease(m_atrHandle);
if(m_atrLongHandle != INVALID_HANDLE) IndicatorRelease(m_atrLongHandle);
}

VolatilityRegimeData AnalyzeVolatilityRegime()
{
    // Update ATR data
    UpdateATRHistory();

    // Calculate realized volatility
    CalculateRealizedVolatility();

    // Determine current regime
    DetermineVolatilityRegime();

    // Check for regime transitions
    CheckRegimeTransition();

    // Update statistics
    UpdateVolatilityStatistics();

    m_regimeData.timestamp = TimeCurrent();
    return m_regimeData;
}

private:
    // AGGRESSIVE FIX - Remove duplicate function declarations
    // Functions already implemented below

bool IsHighVolatilityRegime()
{
return (m_regimeData.currentRegime == VOLATILITY_REGIME_HIGH || 
m_regimeData.currentRegime == VOLATILITY_REGIME_EXTREME);
}

bool IsLowVolatilityRegime()
{
return (m_regimeData.currentRegime == VOLATILITY_REGIME_LOW);
}

double GetVolatilityPercentile()
{
return m_regimeData.atrPercentile;
}

double GetRegimeAdjustment()
{
// Return risk adjustment factor based on volatility regime
switch(m_regimeData.currentRegime)
{
case VOLATILITY_REGIME_LOW:
return 1.2; // Increase position size in low vol
case VOLATILITY_REGIME_HIGH:
return 0.7; // Decrease position size in high vol
case VOLATILITY_REGIME_EXTREME:
return 0.5; // Significantly reduce in extreme vol
case VOLATILITY_REGIME_TRANSITIONAL:
return 0.8; // Cautious during transitions
default:
return 1.0; // Normal volatility
}
}

private:
void UpdateATRHistory()
{
double atrBuffer[];
if(CopyBuffer(m_atrHandle, 0, 0, 1, atrBuffer) > 0)
{
m_atrHistory[m_atrIndex] = atrBuffer[0];
m_atrIndex = (m_atrIndex + 1) % 100;
}
}

void CalculateRealizedVolatility()
{
// Calculate realized volatility using price returns
double returns[20];
for(int i = 0; i < 20; i++)
{
double price1 = iClose(_Symbol, PERIOD_CURRENT, i);
double price2 = iClose(_Symbol, PERIOD_CURRENT, i+1);
returns[i] = MathLog(price1 / price2);
}

// Calculate standard deviation
double mean = 0.0;
for(int i = 0; i < 20; i++)
mean += returns[i];
mean /= 20.0;

double variance = 0.0;
for(int i = 0; i < 20; i++)
variance += MathPow(returns[i] - mean, 2);
variance /= 19.0;

m_regimeData.realizedVolatility = MathSqrt(variance) * MathSqrt(252); // Annualized

// Store in history
m_rvHistory[m_rvIndex] = m_regimeData.realizedVolatility;
m_rvIndex = (m_rvIndex + 1) % 50;
}

void DetermineVolatilityRegime()
{
// Calculate ATR percentile
double currentATR = m_atrHistory[(m_atrIndex - 1 + 100) % 100];
double sortedATR[100];
ArrayCopy(sortedATR, m_atrHistory);
ArraySort(sortedATR);

int rank = 0;
for(int i = 0; i < 100; i++)
{
if(sortedATR[i] <= currentATR)
rank++;
}

m_regimeData.atrPercentile = (double)rank;

// Determine regime based on percentile
if(m_regimeData.atrPercentile < 20)
m_regimeData.currentRegime = VOLATILITY_REGIME_LOW;
else if(m_regimeData.atrPercentile < 40)
m_regimeData.currentRegime = VOLATILITY_REGIME_NORMAL;
else if(m_regimeData.atrPercentile < 80)
m_regimeData.currentRegime = VOLATILITY_REGIME_HIGH;
else
m_regimeData.currentRegime = VOLATILITY_REGIME_EXTREME;
}

void CheckRegimeTransition()
{
static ENUM_VOLATILITY_REGIME previousRegime = VOLATILITY_REGIME_NORMAL;

if(previousRegime != m_regimeData.currentRegime)
{
m_regimeData.isTransitioning = true;
regimeStartTime = TimeCurrent();
regimeDuration = 0;
}
else
{
m_regimeData.isTransitioning = false;
regimeDuration = (int)((TimeCurrent() - regimeStartTime) / 3600); // Hours
}

previousRegime = m_regimeData.currentRegime;
}

void UpdateVolatilityStatistics()
{
// Calculate volatility trend
double recentVol = 0.0, olderVol = 0.0;
int count = 0;

for(int i = 0; i < 10; i++)
{
int idx = (m_rvIndex - 1 - i + 50) % 50;
if(m_rvHistory[idx] > 0)
{
if(count < 5)
recentVol += m_rvHistory[idx];
else
olderVol += m_rvHistory[idx];
count++;
}
}

if(count >= 10)
{
recentVol /= 5.0;
olderVol /= 5.0;
volatilityTrend = (recentVol - olderVol) / olderVol;
}

// Calculate mean and std dev
double sum = 0.0, sumSq = 0.0;
count = 0;
for(int i = 0; i < 50; i++)
{
if(m_rvHistory[i] > 0)
{
sum += m_rvHistory[i];
sumSq += m_rvHistory[i] * m_rvHistory[i];
count++;
}
}

if(count > 1)
{
volatilityMean = sum / count;
volatilityStdDev = MathSqrt(sumSq / count - volatilityMean * volatilityMean);
}
}
};

//+------------------------------------------------------------------+
//| ADVANCED CORRELATION ANALYZER - PHASE 3                        |
//+------------------------------------------------------------------+
class CCorrelationAnalyzer
{
private:
CorrelationData         m_correlations[10];
int                     m_correlationCount;
string                  m_correlatedAssets[10];

public:
CCorrelationAnalyzer()
{
m_correlationCount = 0;
InitializeCorrelatedAssets();
}

bool AnalyzeCorrelations()
{
m_correlationCount = 0;

for(int i = 0; i < ArraySize(m_correlatedAssets); i++)
{
if(m_correlatedAssets[i] != "" && m_correlatedAssets[i] != _Symbol)
{
CorrelationData corr; corr = CalculateCorrelation(_Symbol, m_correlatedAssets[i], 50);
if(corr.isValid)
{
m_correlations[m_correlationCount++] = corr;
}
}
}

return (m_correlationCount > 0);
}

double GetStrongestCorrelation()
{
double strongest = 0.0;
for(int i = 0; i < m_correlationCount; i++)
{
if(MathAbs(m_correlations[i].correlation) > MathAbs(strongest))
strongest = m_correlations[i].correlation;
}
return strongest;
}

bool HasHighCorrelation(double threshold = 0.7)
{
for(int i = 0; i < m_correlationCount; i++)
{
if(MathAbs(m_correlations[i].correlation) > threshold)
return true;
}
return false;
}

double GetMarketRiskFactor()
{
// Calculate market risk based on correlations
double avgCorrelation = 0.0;
int count = 0;

for(int i = 0; i < m_correlationCount; i++)
{
avgCorrelation += MathAbs(m_correlations[i].correlation);
count++;
}

if(count > 0)
{
avgCorrelation /= count;
return avgCorrelation; // Higher correlation = higher market risk
}

return 0.5; // Default moderate risk
}

private:
void InitializeCorrelatedAssets()
{
// Initialize with major currency pairs and indices
string currentSymbol = _Symbol;

if(StringFind(currentSymbol, "EUR") >= 0)
{
m_correlatedAssets[0] = "EURUSD";
m_correlatedAssets[1] = "EURGBP";
m_correlatedAssets[2] = "EURJPY";
m_correlatedAssets[3] = "EURCHF";
}
else if(StringFind(currentSymbol, "GBP") >= 0)
{
m_correlatedAssets[0] = "GBPUSD";
m_correlatedAssets[1] = "EURGBP";
m_correlatedAssets[2] = "GBPJPY";
m_correlatedAssets[3] = "GBPCHF";
}
else if(StringFind(currentSymbol, "USD") >= 0)
{
m_correlatedAssets[0] = "EURUSD";
m_correlatedAssets[1] = "GBPUSD";
m_correlatedAssets[2] = "USDJPY";
m_correlatedAssets[3] = "USDCHF";
}

// Add major indices
m_correlatedAssets[4] = "US30";
m_correlatedAssets[5] = "SPX500";
m_correlatedAssets[6] = "NAS100";
}

CorrelationData CalculateCorrelation(string asset1, string asset2, int period)
{
CorrelationData corr;
corr.Reset();

corr.asset1 = asset1;
corr.asset2 = asset2;
corr.period = period;

// Get price data for both assets
double prices1[], prices2[];
if(!GetPriceData(asset1, prices1, period) || !GetPriceData(asset2, prices2, period))
{
return corr;
}

// Calculate correlation coefficient
double mean1 = 0.0, mean2 = 0.0;
for(int i = 0; i < period; i++)
{
mean1 += prices1[i];
mean2 += prices2[i];
}
mean1 /= period;
mean2 /= period;

double numerator = 0.0, denominator1 = 0.0, denominator2 = 0.0;
for(int i = 0; i < period; i++)
{
double diff1 = prices1[i] - mean1;
double diff2 = prices2[i] - mean2;

numerator += diff1 * diff2;
denominator1 += diff1 * diff1;
denominator2 += diff2 * diff2;
}

double denominator = MathSqrt(denominator1 * denominator2);
if(denominator > 0)
{
corr.correlation = numerator / denominator;
corr.isValid = true;
}

// Calculate beta (asset1 vs asset2)
if(denominator2 > 0)
{
corr.beta = numerator / denominator2;
}

// Calculate R-squared
corr.rsquared = corr.correlation * corr.correlation;

corr.lastUpdate = TimeCurrent();
return corr;
}

bool GetPriceData(string symbol, double &prices[], int period)
{
ArrayResize(prices, period);

for(int i = 0; i < period; i++)
{
prices[i] = iClose(symbol, PERIOD_CURRENT, i);
if(prices[i] <= 0)
return false;
}

return true;
}
};

// CMarketMicrostructureAnalyzer class is defined in SonicR_CommonStructs.mqh
/*
{
private:
MicrostructureData      m_microstructure;
double                  m_tickData[100];
int                     m_tickIndex;

public:
CMarketMicrostructureAnalyzer()
{
m_tickIndex = 0;
ArrayInitialize(m_tickData, 0.0);
}

MicrostructureData AnalyzeMicrostructure()
{
// Update tick data
UpdateTickData();

// Calculate bid-ask spread
CalculateBidAskSpread();

// Analyze order flow
AnalyzeOrderFlow();

// Calculate tick direction bias
CalculateTickDirection();

// Determine microstructure state
DetermineMicrostructureState();

m_microstructure.lastUpdate = TimeCurrent();
return m_microstructure;
}

bool IsBuyPressure()
{
return (m_microstructure.state == MICROSTRUCTURE_BUY_PRESSURE ||
m_microstructure.state == MICROSTRUCTURE_ACCUMULATION);
}

bool IsSellPressure()
{
return (m_microstructure.state == MICROSTRUCTURE_SELL_PRESSURE ||
m_microstructure.state == MICROSTRUCTURE_DISTRIBUTION);
}

double GetAggressionLevel()
{
return m_microstructure.aggression;
}

private:
void UpdateTickData()
{
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
m_tickData[m_tickIndex] = currentPrice;
m_tickIndex = (m_tickIndex + 1) % 100;
}

void CalculateBidAskSpread()
{
double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
m_microstructure.bidAskSpread = ask - bid;
}

void AnalyzeOrderFlow()
{
// Simple order flow analysis based on price and volume
long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, 0);
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
double previousPrice = iClose(_Symbol, PERIOD_CURRENT, 1);

if(currentPrice > previousPrice)
m_microstructure.orderFlow += currentVolume;
else if(currentPrice < previousPrice)
m_microstructure.orderFlow -= currentVolume;

// Normalize order flow
m_microstructure.orderFlow *= 0.9; // Decay factor
}

void CalculateTickDirection()
{
int upTicks = 0, downTicks = 0;

for(int i = 1; i < 50; i++)
{
int idx1 = (m_tickIndex - i + 100) % 100;
int idx2 = (m_tickIndex - i - 1 + 100) % 100;

if(m_tickData[idx1] > m_tickData[idx2])
upTicks++;
else if(m_tickData[idx1] < m_tickData[idx2])
downTicks++;
}

int totalTicks = upTicks + downTicks;
if(totalTicks > 0)
{
m_microstructure.tickDirection = (double)(upTicks - downTicks) / totalTicks;
}
}

void DetermineMicrostructureState()
{
// Determine state based on multiple factors
double orderFlowThreshold = 1000.0; // Adjust based on symbol

if(m_microstructure.orderFlow > orderFlowThreshold && m_microstructure.tickDirection > 0.3)
m_microstructure.state = MICROSTRUCTURE_BUY_PRESSURE;
else if(m_microstructure.orderFlow < -orderFlowThreshold && m_microstructure.tickDirection < -0.3)
m_microstructure.state = MICROSTRUCTURE_SELL_PRESSURE;
else if(m_microstructure.orderFlow > orderFlowThreshold * 2)
m_microstructure.state = MICROSTRUCTURE_ACCUMULATION;
else if(m_microstructure.orderFlow < -orderFlowThreshold * 2)
m_microstructure.state = MICROSTRUCTURE_DISTRIBUTION;
else
m_microstructure.state = MICROSTRUCTURE_BALANCED;

// Calculate aggression level
m_microstructure.aggression = MathAbs(m_microstructure.orderFlow) / (orderFlowThreshold * 2);
m_microstructure.aggression = MathMin(m_microstructure.aggression, 1.0);
}
};
*/

// CMarketContextAnalyzer class is defined in SonicR_CommonStructs.mqh
// The following class definition is commented out to avoid duplication
/*
class CMarketContextAnalyzer
{
private:
CVolatilityRegimeAnalyzer*      m_volatilityAnalyzer;
CCorrelationAnalyzer*           m_correlationAnalyzer;
CMarketMicrostructureAnalyzer*  m_microstructureAnalyzer;

// Missing member variables - Phase 2 Fix
VolatilityRegimeData            m_regimeData;
double                          m_rvHistory[100];      // RV history array
int                             m_rvIndex;             // Current RV index
double                          m_atrHistory[100];     // ATR history array
int                             m_correlationCount;    // Correlation count
string                          m_correlatedAssets[10]; // Correlated assets array

public:
CMarketContextAnalyzer()
{
m_volatilityAnalyzer = new CVolatilityRegimeAnalyzer();
m_correlationAnalyzer = new CCorrelationAnalyzer();
m_microstructureAnalyzer = new CMarketMicrostructureAnalyzer();
}

~CMarketContextAnalyzer()
{
delete m_volatilityAnalyzer;
delete m_correlationAnalyzer;
delete m_microstructureAnalyzer;
}

bool AnalyzeMarketContext()
{
// Analyze all components
m_volatilityAnalyzer.AnalyzeVolatilityRegime();
m_correlationAnalyzer.AnalyzeCorrelations();
m_microstructureAnalyzer.AnalyzeMicrostructure();

return true;
}

double GetContextRiskAdjustment()
{
double volatilityAdj = m_volatilityAnalyzer.GetRegimeAdjustment();
double correlationAdj = 1.0 - (m_correlationAnalyzer.GetMarketRiskFactor() * 0.3);

MicrostructureData micro = m_microstructureAnalyzer.AnalyzeMicrostructure();
double microAdj = 1.0;
if(micro.state == MICROSTRUCTURE_BALANCED)
microAdj = 1.1; // Slight boost for balanced markets

return volatilityAdj * correlationAdj * microAdj;
}

bool IsHighRiskEnvironment()
{
return (m_volatilityAnalyzer.IsHighVolatilityRegime() ||
m_correlationAnalyzer.HasHighCorrelation(0.8));
}

bool IsLowRiskEnvironment()
{
return (m_volatilityAnalyzer.IsLowVolatilityRegime() &&
!m_correlationAnalyzer.HasHighCorrelation(0.5));
}

// Getters for individual analyzers
CVolatilityRegimeAnalyzer* GetVolatilityAnalyzer() { return m_volatilityAnalyzer; }
CCorrelationAnalyzer* GetCorrelationAnalyzer() { return m_correlationAnalyzer; }
CMarketMicrostructureAnalyzer* GetMicrostructureAnalyzer() { return m_microstructureAnalyzer; }

// BOSS REQUEST: Export market context data for Python visualization
bool ExportMarketContextDataToCSV(string filename = "")
{
if(filename == "")
filename = "MarketContext_" + _Symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE) + ".csv";

int fileHandle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
if(fileHandle == INVALID_HANDLE)
{
return false;
}

// SYSTEMATIC FIX - Close incomplete comment and class
// Write CSV header
string csvHeader = "Timestamp,Symbol,VolatilityRegime,ATRPercentile,Correlation,MicrostructureState\n";
FileWriteString(fileHandle, csvHeader);

// Write current data
string dataLine = StringFormat("%s,%s,%d,%.2f,%.3f,%d\n",
    TimeToString(TimeCurrent()),
    _Symbol,
    (int)m_volatilityAnalyzer.GetVolatilityPercentile(),
    m_volatilityAnalyzer.GetVolatilityPercentile(),
    m_correlationAnalyzer.GetStrongestCorrelation(),
    0  // Placeholder for microstructure state
);
FileWriteString(fileHandle, dataLine);

FileClose(fileHandle);
return true;
}
}; // SYSTEMATIC FIX - Close CMarketContextAnalyzer class
*/

#endif // ANALYSIS_MARKET_CONTEXT_MQH

