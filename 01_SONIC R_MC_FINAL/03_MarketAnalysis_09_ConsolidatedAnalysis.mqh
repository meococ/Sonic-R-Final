//+------------------------------------------------------------------+
//| Analysis_Consolidated.mqh                                          |
//| Consolidated Analysis System for Sonic R MC EA                    |
//| Copyright 2024, Ð?i Bàng Dev                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Ð?i Bàng Dev"
#property link      "https://sonicr.mc"
#property version   "3.00"

#ifndef ANALYSIS_CONSOLIDATED_MQH
#define ANALYSIS_CONSOLIDATED_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
#include "06_RiskManagement_01_IntelligentManager.mqh"  // For ENUM_MARKET_CONDITION

//+------------------------------------------------------------------+
//| Consolidated Analysis Class                                        |
//+------------------------------------------------------------------+
class CAnalysisConsolidated
{
private:
// Analysis state
bool                        m_initialized;
datetime                    m_lastUpdate;

// Analysis components
double                      m_dragonBandScore;
double                      m_wavePatternScore;
double                      m_smcScore;
double                      m_pvsraScore;
double                      m_marketStructureScore;
double                      m_volumeConfirmationScore;
double                      m_trendAlignmentScore;

// Market context
ENUM_MARKET_REGIME          m_currentRegime;
ENUM_MARKET_CONDITION       m_marketCondition;
double                      m_volatility;
double                      m_trendStrength;

public:
// Constructor
CAnalysisConsolidated()
{
m_initialized = false;
m_lastUpdate = 0;

// Initialize scores
m_dragonBandScore = 0.0;
m_wavePatternScore = 0.0;
m_smcScore = 0.0;
m_pvsraScore = 0.0;
m_marketStructureScore = 0.0;
m_volumeConfirmationScore = 0.0;
m_trendAlignmentScore = 0.0;

// Initialize market context
m_currentRegime = REGIME_UNKNOWN;
m_marketCondition = MARKET_RANGING;
m_volatility = 0.0;
m_trendStrength = 0.0;
}

// Destructor
~CAnalysisConsolidated() {}

//+------------------------------------------------------------------+
//| ?? INITIALIZATION                                                |
//+------------------------------------------------------------------+
bool Initialize()
{
if(m_initialized) return true;

::Print("?? [ANALYSIS] Initializing Consolidated Analysis System...");

m_initialized = true;
m_lastUpdate = TimeCurrent();

::Print("? [ANALYSIS] Consolidated Analysis System initialized");
return true;
}

//+------------------------------------------------------------------+
//| ?? ANALYSIS UPDATE                                               |
//+------------------------------------------------------------------+
bool UpdateAnalysis()
{
if(!m_initialized) return false;

// Update market context
UpdateMarketContext();

// Update analysis scores (simplified for now)
m_dragonBandScore = CalculateDragonBandScore();
m_wavePatternScore = CalculateWavePatternScore();
m_smcScore = CalculateSMCScore();
m_pvsraScore = CalculatePVSRAScore();
m_marketStructureScore = CalculateMarketStructureScore();
m_volumeConfirmationScore = CalculateVolumeConfirmationScore();
m_trendAlignmentScore = CalculateTrendAlignmentScore();

m_lastUpdate = TimeCurrent();
return true;
}

//+------------------------------------------------------------------+
//| ?? SCORE GETTERS                                                 |
//+------------------------------------------------------------------+
double GetDragonBandScore() const { return m_dragonBandScore; }
double GetWavePatternScore() const { return m_wavePatternScore; }
double GetSMCScore() const { return m_smcScore; }
double GetPVSRAScore() const { return m_pvsraScore; }
double GetMarketStructureScore() const { return m_marketStructureScore; }
double GetVolumeConfirmationScore() const { return m_volumeConfirmationScore; }
double GetTrendAlignmentScore() const { return m_trendAlignmentScore; }

//+------------------------------------------------------------------+
//| ?? MARKET CONTEXT GETTERS                                        |
//+------------------------------------------------------------------+
ENUM_MARKET_REGIME GetCurrentRegime() const { return m_currentRegime; }
ENUM_MARKET_CONDITION GetMarketCondition() const { return m_marketCondition; }
double GetVolatility() const { return m_volatility; }
double GetTrendStrength() const { return m_trendStrength; }

//+------------------------------------------------------------------+
//| ?? ANALYSIS CALCULATIONS                                         |
//+------------------------------------------------------------------+
private:
void UpdateMarketContext()
{
// Simplified market context update
// In a real implementation, this would use actual market analysis

// Calculate volatility (simplified)
double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
double close = iClose(_Symbol, PERIOD_CURRENT, 1);
m_volatility = (atr / close) * 100.0;

// Determine market regime based on volatility
if(m_volatility > 2.0) {
m_currentRegime = REGIME_VOLATILE_RANGING;
} else if(m_volatility > 1.0) {
m_currentRegime = REGIME_STABLE_TRENDING;
} else {
m_currentRegime = REGIME_STABLE_RANGING;
}

// Calculate trend strength - SONIC R COMPLIANT (EMA34/89)
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

double ema34 = 0, ema89 = 0;
if(manager != NULL) {
int ema34Handle = manager.GetEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
int ema89Handle = manager.GetEMAHandle(_Symbol, PERIOD_CURRENT, 89, PRICE_CLOSE);

double ema34Buffer[1], ema89Buffer[1];
if(CopyBuffer(ema34Handle, 0, 0, 1, ema34Buffer) > 0) ema34 = ema34Buffer[0];
if(CopyBuffer(ema89Handle, 0, 0, 1, ema89Buffer) > 0) ema89 = ema89Buffer[0];
} else {
// Fallback with Sonic R periods
ema34 = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
ema89 = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
::Print("?? [ANALYSIS CONSOLIDATED] Using fallback iMA call - unified manager not available");
}

m_trendStrength = MathAbs(ema34 - ema89) / close * 1000.0;

// Determine market condition
if(m_trendStrength > 2.0) {
m_marketCondition = MARKET_TRENDING;
} else if(m_volatility > 1.5) {
m_marketCondition = MARKET_VOLATILE;
} else {
m_marketCondition = MARKET_RANGING;
}
}

double CalculateDragonBandScore()
{
// Simplified Dragon Band score calculation
// In a real implementation, this would use actual Dragon Band analysis
double score = 0.5 + (MathRand() % 50) / 100.0; // Random score between 0.5 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}

double CalculateWavePatternScore()
{
// Simplified Wave Pattern score calculation
double score = 0.4 + (MathRand() % 60) / 100.0; // Random score between 0.4 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}

double CalculateSMCScore()
{
// Simplified SMC score calculation
double score = 0.3 + (MathRand() % 70) / 100.0; // Random score between 0.3 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}

double CalculatePVSRAScore()
{
// Simplified PVSRA score calculation
double score = 0.6 + (MathRand() % 40) / 100.0; // Random score between 0.6 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}

double CalculateMarketStructureScore()
{
// Simplified Market Structure score calculation
double score = 0.5 + (MathRand() % 50) / 100.0; // Random score between 0.5 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}

double CalculateVolumeConfirmationScore()
{
// Simplified Volume Confirmation score calculation
double score = 0.4 + (MathRand() % 60) / 100.0; // Random score between 0.4 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}

double CalculateTrendAlignmentScore()
{
// Simplified Trend Alignment score calculation
double score = 0.5 + (MathRand() % 50) / 100.0; // Random score between 0.5 and 1.0
return MathMin(1.0, MathMax(0.0, score));
}
};

//+------------------------------------------------------------------+
//| ?? GLOBAL ANALYSIS INSTANCE                                        |
//+------------------------------------------------------------------+
// Global instance for use across the system - REMOVED STATIC
// Use singleton pattern instead
CAnalysisConsolidated* g_GlobalAnalysisConsolidated;

//+------------------------------------------------------------------+
//| ?? INITIALIZATION FUNCTIONS                                        |
//+------------------------------------------------------------------+
bool InitializeAnalysisConsolidated()
{
if(g_GlobalAnalysisConsolidated == NULL) {
g_GlobalAnalysisConsolidated = new CAnalysisConsolidated();
if(g_GlobalAnalysisConsolidated == NULL) {
::Print("? [ANALYSIS] Failed to create Analysis Consolidated instance");
return false;
}
}

return g_GlobalAnalysisConsolidated.Initialize();
}

void DeinitializeAnalysisConsolidated()
{
if(g_GlobalAnalysisConsolidated != NULL) {
delete g_GlobalAnalysisConsolidated;
g_GlobalAnalysisConsolidated = NULL;
::Print("?? [ANALYSIS] Analysis Consolidated deinitialized");
}
}

//+------------------------------------------------------------------+
//| ?? GLOBAL ACCESS FUNCTION                                          |
//+------------------------------------------------------------------+
CAnalysisConsolidated* GetAnalysisConsolidated()
{
if(g_GlobalAnalysisConsolidated == NULL) {
InitializeAnalysisConsolidated();
}
return g_GlobalAnalysisConsolidated;
}

#endif // ANALYSIS_CONSOLIDATED_MQH


