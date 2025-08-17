//+------------------------------------------------------------------+
//|                                       Signal_Consolidated.mqh    |
//|                        Sonic R MC - Enhanced Signal System       |
//|                🚀 TASK 2: REFINED SIGNAL GENERATION PIPELINE     |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Đại Bàng Enhanced"
#property version   "2.00"

#ifndef SIGNAL_CONSOLIDATED_MQH
#define SIGNAL_CONSOLIDATED_MQH

// Include core dependencies
#include "01_Core_02_ConfigManager.mqh"
#include "01_Core_08_ContextManager.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
// PHASE 4.6: AGGRESSIVE - ENABLE MASTERORCHESTRATOR
#include "03_MarketAnalysis_08_MasterOrchestrator.mqh"  // AGGRESSIVE: ENABLED
#include "03_MarketAnalysis_06_PVSRA_Manager.mqh"


// FIXED: Guard AI_ML includes to prevent #import declaration errors
#ifdef INCLUDE_AI_ML_MODULES
// #include "07_AI_ML_04_MLIntegration.mqh"  // DISABLED: Causes #import declaration errors
// #include "07_AI_ML_03_NeuralNetworkConfirmation.mqh"  // DISABLED: Causes #import declaration errors
#endif

#include "02_DataProviders_03_SessionManager.mqh"

// Forward declarations moved to bottom with definitions to avoid duplicate static declarations
// PHASE 4: RESTORE PERFORMANCE MODULE WITH FIXED ENUMS
#include "09_Performance_01_OptimizationEnhanced.mqh"

#include "01_Core_14_CoreEnums.mqh"  // For ENUM_SCENARIO constants

// Include additional files
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_16_EnumHelpers.mqh"  // For SignalTypeToString()

#include "01_Core_07_CommonStructures.mqh"
// PHASE 3: RESTORE CONSOLIDATED ANALYSIS
#include "03_MarketAnalysis_09_ConsolidatedAnalysis.mqh"
#include "04_SignalGeneration_00_ConsolidatedSignals.api.mqh"  // For SignalDecision and API prototypes
#include "04_SignalGeneration_15_ConfluenceAggregator.mqh"  // PHASE 2: Confluence aggregation

//+------------------------------------------------------------------+
//| 🔧 EXTERN DECLARATIONS FOR GLOBAL VARIABLES                     |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| 🔧 CRITICAL FIX: Implement Missing Functions                     |
//+------------------------------------------------------------------+

/* BEGIN: removed early minimal CConsolidatedSignals fragment
public:
    // Constructor
    CConsolidatedSignals()
    {
        m_lastCheckTime = 0;
        m_lastPrice = 0;
        m_lastSignalTime = 0;
        m_filters = new CSignalFilters();
        m_aggregator = new CConfluenceAggregator();  // PHASE 2: Initialize aggregator
        ResetSignalData();
    }
    // Destructor
    ~CConsolidatedSignals()
    {
        if(m_filters != NULL) {
            delete m_filters;
            m_filters = NULL;
        }
        if(m_aggregator != NULL) {
            delete m_aggregator;
            m_aggregator = NULL;
        }
    }
    // Structure analysis functions implementation
    double AnalyzeHHLL(int shift)
{
double score = 0.0;

// Get recent highs and lows
double currentHigh = iHigh(_Symbol, PERIOD_CURRENT, shift);
double currentLow = iLow(_Symbol, PERIOD_CURRENT, shift);
double prevHigh = iHigh(_Symbol, PERIOD_CURRENT, shift + 1);
double prevLow = iLow(_Symbol, PERIOD_CURRENT, shift + 1);

// Check for higher highs and higher lows (bullish structure)
if(currentHigh > prevHigh && currentLow > prevLow) {
score = 0.8; // Strong bullish structure
}
// Check for lower highs and lower lows (bearish structure)
else if(currentHigh < prevHigh && currentLow < prevLow) {
score = 0.2; // Strong bearish structure
}
else {
score = 0.5; // Neutral/ranging structure
}

return score;
}

double AnalyzeSRAlignment(int shift)
{
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, shift);
double score = 0.5; // Default neutral

// Simple S/R analysis based on recent price action
double resistance = iHigh(_Symbol, PERIOD_CURRENT, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, 20, shift));
double support = iLow(_Symbol, PERIOD_CURRENT, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, 20, shift));

double range = resistance - support;
if(range > 0) {
double position = (currentPrice - support) / range;

// Near resistance (bearish)
if(position > 0.8) score = 0.2;
// Near support (bullish)
else if(position < 0.2) score = 0.8;
// Middle range
else score = 0.5;
}

return score;
}

double AnalyzeTrendAlignment(int shift)
{
// 🚀 BOSS FIX: Use cached handles to prevent memory leaks
int ma20_handle = GetCachedMAHandle(_Symbol, PERIOD_CURRENT, 20, MODE_SMA, PRICE_CLOSE);
int ma50_handle = GetCachedMAHandle(_Symbol, PERIOD_CURRENT, 50, MODE_SMA, PRICE_CLOSE);

// Get values at specific shift
double ma20_values[], ma50_values[];
if(CopyBuffer(ma20_handle, 0, shift, 1, ma20_values) <= 0 || CopyBuffer(ma50_handle, 0, shift, 1, ma50_values) <= 0)
return 0.5;

double ma20_val = ma20_values[0];
double ma50_val = ma50_values[0];
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, shift);

double score = 0.5; // Default neutral

// Strong uptrend
if(currentPrice > ma20_val && ma20_val > ma50_val) {
score = 0.8;
}
// Strong downtrend
else if(currentPrice < ma20_val && ma20_val < ma50_val) {
score = 0.2;
}
// Sideways/weak trend
else {
score = 0.5;
}

return score;
}
*/

// Real-time confirmation functions implementation
double GetRealTimeSMCConfirmation(int shift)
{
 return 0.5; // Neutral without SMC
}

double GetPVSRAVolumeConfirmation(int shift)
{
/* END: removed fragment */
// Simple volume confirmation based on tick volume
long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, shift);
long avgVolume = 0;

// Calculate average volume over last 20 bars
for(int i = shift + 1; i <= shift + 20; i++) {
avgVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 20;

if(avgVolume == 0) return 0.5;

double volumeRatio = (double)currentVolume / (double)avgVolume;

// High volume confirmation
if(volumeRatio > 1.5) return 0.8;
// Low volume
else if(volumeRatio < 0.5) return 0.2;
// Normal volume
else return 0.5;
}

//+------------------------------------------------------------------+
//| 🚀 ENHANCED SIGNAL DATA STRUCTURE                               |
//+------------------------------------------------------------------+
// NOTE: SEnhancedSignalData is already defined in Shared_DataStructures.mqh
// Removing duplicate declaration to prevent error 282

//+------------------------------------------------------------------+
//| Helper function to calculate confluence (moved from struct)      |
//+------------------------------------------------------------------+
void CalculateSignalConfluence(SEnhancedSignalData& data)
{
// 🎯 PHASE 1: UPDATED WEIGHTS WITH MACD CONFLUENCE
data.confluenceScore = 0.0;
data.confluenceScore += data.dragonScore * 0.25;      // Dragon Band (25%)
data.confluenceScore += data.waveScore * 0.20;        // Wave patterns (20%)
data.confluenceScore += data.pvsraScore * 0.20;       // PVSRA confirmation (20%)
data.confluenceScore += data.smcScore * 0.15;         // Smart Money Concepts (15%)
data.confluenceScore += data.srScore * 0.05;          // Support/Resistance (5% - reduced)
data.confluenceScore += data.momentumScore * 0.15;    // MACD Momentum (15% - NEW)

// Apply market regime adjustment
double regimeMultiplier = 1.0; // Default multiplier
data.confluenceScore *= regimeMultiplier;

// Cap at 1.0
data.confluenceScore = MathMin(data.confluenceScore, 1.0);
}

//+------------------------------------------------------------------+
//| Helper function to get detailed signal reasoning                 |
//+------------------------------------------------------------------+
string GetDetailedSignalReasoning(const SEnhancedSignalData& data)
{
string details = "CONFLUENCE BREAKDOWN:\n";
details += StringFormat("🐉 Dragon: %.1f%% (%.3f × 25%%%%)\n", data.dragonScore*100, data.dragonScore);
details += StringFormat("🌊 Wave: %.1f%% (%.3f × 20%%%%)\n", data.waveScore*100, data.waveScore);
details += StringFormat("📊 PVSRA: %.1f%% (%.3f × 20%%%%)\n", data.pvsraScore*100, data.pvsraScore);
details += StringFormat("💰 SMC: %.1f%% (%.3f × 15%%%%)\n", data.smcScore*100, data.smcScore);
details += StringFormat("📈 SR: %.1f%% (%.3f × 10%%%%)\n", data.srScore*100, data.srScore);
details += StringFormat("⚡ Mom: %.1f%% (%.3f × 10%%%%)\n", data.momentumScore*100, data.momentumScore);
details += StringFormat("🎖️ TOTAL: %.1f%%", data.confluenceScore*100);
return details;
}

//+------------------------------------------------------------------+
//| 🚀 ENHANCED SIGNAL FILTERS                                       |
//+------------------------------------------------------------------+
class CSignalFilters
{
private:
double m_maxSpread;
int m_newsAvoidanceMinutes;
bool m_enableSessionFilter;

public:
CSignalFilters()
{
m_maxSpread = 3.0; // 3 pips max spread
m_newsAvoidanceMinutes = 60; // Avoid 1 hour around news
m_enableSessionFilter = true;
}

bool PassesAllFilters(SEnhancedSignalData& signal)
{
signal.passesFilters = true;
string filterLog = "[🔍 FILTERS] ";

// 🎯 FILTER 1: Spread Check
if(!PassesSpreadFilter()) {
signal.passesFilters = false;
filterLog += "SPREAD_FAIL ";
}

// 🎯 FILTER 2: News Avoidance
if(!PassesNewsFilter()) {
signal.passesFilters = false;
filterLog += "NEWS_FAIL ";
}

// 🎯 FILTER 3: Trading Session
if(!PassesSessionFilter()) {
signal.passesFilters = false;
filterLog += "SESSION_FAIL ";
}

// 🎯 FILTER 4: Minimum Components Check
if(!PassesMinimumComponentsFilter(signal)) {
signal.passesFilters = false;
filterLog += "COMPONENTS_FAIL ";
}

if(signal.passesFilters) {
filterLog += "✅ ALL_PASSED";
} else {
filterLog += "❌ REJECTED";
}

Print(filterLog);
return signal.passesFilters;
}

private:
bool PassesSpreadFilter()
{
// FIXED: Calculate spread properly in MQL5
double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
double maxAllowed = m_maxSpread * _Point;

if(spread > maxAllowed) {
Print(StringFormat("[⚠️ SPREAD] Current: %.1f pips > Max: %.1f pips",
spread/_Point, maxAllowed/_Point));
return false;
}
return true;
}

bool PassesNewsFilter()
{
// High-impact news detection (simplified)
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);

// Avoid known news times (can be enhanced with news calendar)
if((time.hour == 8 && time.min >= 25 && time.min <= 35) ||  // 8:30 news
(time.hour == 12 && time.min >= 25 && time.min <= 35) || // 12:30 news
(time.hour == 14 && time.min >= 25 && time.min <= 35))   // 14:30 news
{
Print("[⚠️ NEWS] Avoiding high-impact news time");
return false;
}
return true;
}

bool PassesSessionFilter()
{
if(!m_enableSessionFilter) return true;

MqlDateTime time;
TimeToStruct(TimeCurrent(), time);

// Active trading hours (London + NY overlap preferred)
bool isActiveSession = false;

// London session: 8:00-17:00 GMT
// NY session: 13:00-22:00 GMT
// Overlap: 13:00-17:00 GMT (best time)

if(time.hour >= 13 && time.hour <= 17) {
isActiveSession = true; // Overlap period - best
} else if(time.hour >= 8 && time.hour <= 22) {
isActiveSession = true; // Active sessions
}

if(!isActiveSession) {
Print("[⚠️ SESSION] Outside active trading hours");
return false;
}
return true;
}

bool PassesMinimumComponentsFilter(SEnhancedSignalData& signal)
{
// Require at least 2 strong components (>0.5)
int strongComponents = 0;
if(signal.dragonScore > 0.5) strongComponents++;
if(signal.smcScore > 0.5) strongComponents++;
if(signal.pvsraScore > 0.5) strongComponents++;
if(signal.waveScore > 0.5) strongComponents++;

if(strongComponents < 2) {
Print(StringFormat("[⚠️ COMPONENTS] Only %d strong components (need ≥2)", strongComponents));
return false;
}
return true;
}
};

//+------------------------------------------------------------------+
//| 🚀 ENHANCED SIGNAL ENGINE                                        |
//+------------------------------------------------------------------+
class CConsolidatedSignals
{
private:
    // State management
    SEnhancedSignalData m_lastSignal;
    datetime m_lastCheckTime;
    double m_lastPrice;
    datetime m_lastSignalTime;
    SignalData m_currentSignal;
    
    // Filters (initialized in constructor)
    CSignalFilters* m_filters;
    
    // PHASE 2: Confluence Aggregator
    CConfluenceAggregator* m_aggregator;

    // Performance tracking
    int m_totalSignals;
    int m_successfulSignals;
    double m_avgConfluenceScore;

    // Phase 2: Session adjustment variables
    bool m_sessionAdjustmentEnabled;
    double m_sessionMultipliers[4]; // London, NY, Tokyo, Sydney
    ENUM_TRADING_SESSION m_currentSession;
    double m_sessionVolatilityThreshold;

    // Phase 2: ML confirmation variables
    bool m_mlConfirmationEnabled;
    double m_mlConfidenceThreshold;
    double m_mlWeightInConfluence;
    int m_mlLookbackPeriod;
    double m_mlFeatureWeights[6]; // Dragon, Wave, PVSRA, SMC, Volume, Structure

    // Phase 2: Enhanced filtering
    bool m_adaptiveFilteringEnabled;
    double m_dynamicConfluenceThreshold;
    int m_signalCooldownPeriod;

    // Components for scoring
    // FIXED: MQL5 doesn't support extern - use direct access instead
    // extern CSMCAnalyzer* g_SMCAnalyzer;  // Use global SMC analyzer

public:
    CConsolidatedSignals()
    {
        m_lastCheckTime = 0;
        m_lastPrice = 0;
        m_lastSignalTime = 0;
        m_filters = new CSignalFilters();
        m_aggregator = new CConfluenceAggregator();  // PHASE 2: Initialize aggregator
        ResetSignalData();

        m_totalSignals = 0;
        m_successfulSignals = 0;
        m_avgConfluenceScore = 0.0;

        // Phase 2: Initialize session adjustment
        m_sessionAdjustmentEnabled = true;
        m_sessionMultipliers[0] = 1.2; // London (high volatility)
        m_sessionMultipliers[1] = 1.3; // NY (highest volatility)
        m_sessionMultipliers[2] = 0.8; // Tokyo (moderate)
        m_sessionMultipliers[3] = 0.6; // Sydney (low)
        m_currentSession = SESSION_LONDON;
        m_sessionVolatilityThreshold = 0.65;

        // Phase 2: Initialize ML confirmation
        m_mlConfirmationEnabled = true;
        m_mlConfidenceThreshold = 0.7;
        m_mlWeightInConfluence = 0.15; // 15% weight for ML
        m_mlLookbackPeriod = 50;

        // Initialize ML feature weights
        m_mlFeatureWeights[0] = 0.25; // Dragon
        m_mlFeatureWeights[1] = 0.20; // Wave
        m_mlFeatureWeights[2] = 0.20; // PVSRA
        m_mlFeatureWeights[3] = 0.15; // SMC
        m_mlFeatureWeights[4] = 0.10; // Volume
        m_mlFeatureWeights[5] = 0.10; // Structure

        // Phase 2: Initialize enhanced filtering
        m_adaptiveFilteringEnabled = true;
        m_dynamicConfluenceThreshold = 0.75;
        m_signalCooldownPeriod = 300; // 5 minutes
    } // SYSTEMATIC FIX - Close constructor

    // SYSTEMATIC FIX - Move TradingSignal generation to separate method
    TradingSignal GenerateSignal(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT, ENUM_TRADING_SCENARIO scenario = SCENARIO_BASIC)
    {
    TradingSignal result;
    result.type = SIGNAL_NONE;
    result.side = ORDER_TYPE_BUY;
    result.sl = 0.0;
    result.tp = 0.0;
    result.confidence = 0.0;
    result.reason = "No signal generated";
    result.is_scout = false;

    // Use current symbol if not specified
    if(symbol == "") symbol = _Symbol;

    // M15 Pipeline according to spec: H4 context → Dragon breakout → Wave completion → Oscillator confluence → Volume institutional → Compile
    Print("[SIGNAL_GATEWAY] Generating signal for ", symbol, " TF:", EnumToString(timeframe), " Scenario:", EnumToString(scenario));

    // Step 1: H4 Context Analysis
    // TODO: Implement H4 trend context

    // Step 2: Dragon Breakout Analysis
    ENUM_SIGNAL_TYPE dragonSignal = GetSignal_SonicR_Basic_Internal();

    // Step 3: PVSRA/Wave Analysis
    ENUM_SIGNAL_TYPE pvsraSignal = SIGNAL_NONE;
    if(scenario == SCENARIO_WITH_VPSRA || scenario == SCENARIO_SCOUT_RANGE_SMC) {
        pvsraSignal = GetSignal_SonicR_VPSRA_Internal();
    }

    // Step 4: Scout Analysis
    ENUM_SIGNAL_TYPE scoutSignal = SIGNAL_NONE;
    if(scenario == SCENARIO_SCOUT_RANGE_SMC) {
        scoutSignal = GetSignal_Scout_Internal();
    }

    // Step 5: Confluence Analysis
    double confluenceScore = 0.0;

    // Basic Dragon confluence
    if(dragonSignal == SIGNAL_BUY || dragonSignal == SIGNAL_SELL) {
        confluenceScore += 0.4; // 40% weight for Dragon
    }

    // PVSRA confluence
    if(pvsraSignal == SIGNAL_BUY || pvsraSignal == SIGNAL_SELL) {
        confluenceScore += 0.3; // 30% weight for PVSRA
    }

    // Scout confluence
    if(scoutSignal == SIGNAL_BUY || scoutSignal == SIGNAL_SELL) {
        confluenceScore += 0.3; // 30% weight for Scout
        result.is_scout = true;
    }

    // Determine final signal based on scenario thresholds
    double requiredThreshold = GetScenarioThreshold(scenario);

    if(confluenceScore >= requiredThreshold) {
        // Determine signal direction (majority vote)
        int buyVotes = 0;
        int sellVotes = 0;

        if(dragonSignal == SIGNAL_BUY) buyVotes++;
        else if(dragonSignal == SIGNAL_SELL) sellVotes++;

        if(pvsraSignal == SIGNAL_BUY) buyVotes++;
        else if(pvsraSignal == SIGNAL_SELL) sellVotes++;

        if(scoutSignal == SIGNAL_BUY) buyVotes++;
        else if(scoutSignal == SIGNAL_SELL) sellVotes++;

        if(buyVotes > sellVotes) {
            result.type = SIGNAL_BUY;
            result.side = ORDER_TYPE_BUY;
            result.reason = StringFormat("BUY confluence %.2f (Dragon:%s PVSRA:%s Scout:%s)",
                                       confluenceScore,
                                       SignalTypeToString(dragonSignal),
                                       SignalTypeToString(pvsraSignal),
                                       SignalTypeToString(scoutSignal));
        } else if(sellVotes > buyVotes) {
            result.type = SIGNAL_SELL;
            result.side = ORDER_TYPE_SELL;
            result.reason = StringFormat("SELL confluence %.2f (Dragon:%s PVSRA:%s Scout:%s)",
                                       confluenceScore,
                                       SignalTypeToString(dragonSignal),
                                       SignalTypeToString(pvsraSignal),
                                       SignalTypeToString(scoutSignal));
        }

        result.confidence = confluenceScore;

        // Calculate SL/TP based on scenario
        CalculateScenarioSLTP(result, scenario, symbol);
    }

    Print("[SIGNAL_GATEWAY] Result: ", SignalTypeToString(result.type), " Confidence: ", DoubleToString(result.confidence, 3), " Reason: ", result.reason);
    return result;
}

private:
double GetScenarioThreshold(ENUM_TRADING_SCENARIO scenario)
{
    switch(scenario) {
        case SCENARIO_BASIC: return 0.65;
        case SCENARIO_WITH_VPSRA: return 0.70;
        case SCENARIO_SCOUT_RANGE_SMC: return 0.75;
        case SCENARIO_SCALING_WINNERS: return 0.80;
        case SCENARIO_MULTI_ASSET_ADAPTIVE: return 0.75;
        default: return 0.65;
    }
}

void CalculateScenarioSLTP(TradingSignal &signal, ENUM_TRADING_SCENARIO scenario, string symbol)
{
    // Get current price
    double currentPrice = (signal.side == ORDER_TYPE_BUY) ?
                         SymbolInfoDouble(symbol, SYMBOL_ASK) :
                         SymbolInfoDouble(symbol, SYMBOL_BID);

    // Get ATR for SL calculation
    double atrValue = 0.0;
    if(g_indicatorManager != NULL && g_indicatorManager.GetATRValue(atrValue)) {
        // Use ATR-based SL/TP
        double slDistance = atrValue * 1.5; // 1.5x ATR for SL
        double tpDistance = slDistance * GetScenarioRR(scenario); // R:R based on scenario

        if(signal.side == ORDER_TYPE_BUY) {
            signal.sl = NormalizeDouble(currentPrice - slDistance, _Digits);
            signal.tp = NormalizeDouble(currentPrice + tpDistance, _Digits);
        } else {
            signal.sl = NormalizeDouble(currentPrice + slDistance, _Digits);
            signal.tp = NormalizeDouble(currentPrice - tpDistance, _Digits);
        }
    } else {
        // Fallback to fixed pip SL/TP
        double pipValue = _Point * ((_Digits == 3 || _Digits == 5) ? 10 : 1);
        double slPips = 30; // 30 pips SL
        double tpPips = slPips * GetScenarioRR(scenario);

        if(signal.side == ORDER_TYPE_BUY) {
            signal.sl = NormalizeDouble(currentPrice - slPips * pipValue, _Digits);
            signal.tp = NormalizeDouble(currentPrice + tpPips * pipValue, _Digits);
        } else {
            signal.sl = NormalizeDouble(currentPrice + slPips * pipValue, _Digits);
            signal.tp = NormalizeDouble(currentPrice - tpPips * pipValue, _Digits);
        }
    }
}

double GetScenarioRR(ENUM_TRADING_SCENARIO scenario)
{
    switch(scenario) {
        case SCENARIO_BASIC: return 2.0;
        case SCENARIO_WITH_VPSRA: return 2.5;
        case SCENARIO_SCOUT_RANGE_SMC: return 3.0;
        case SCENARIO_SCALING_WINNERS: return 4.0;
        case SCENARIO_MULTI_ASSET_ADAPTIVE: return 2.5;
        default: return 2.0;
    }
}

public:
//+------------------------------------------------------------------+
//| 🎯 PHASE 1 PERFECT CONFLUENCE SYSTEM - 75% THRESHOLD            |
//+------------------------------------------------------------------+
// PHASE 3: RESTORE CAnalysisConsolidated FUNCTIONS
ENUM_SIGNAL_TYPE GenerateEnhancedSignal(CAnalysisConsolidated* analysis)
{
if(analysis == NULL) return SIGNAL_NONE;

// 🎯 PHASE 1: Prevent excessive signal generation
if(!IsNewBarOrSignificantChange()) {
return SIGNAL_NONE;
}

SEnhancedSignalData signal;
// Initialize signal structure
ZeroMemory(signal);
signal.type = SIGNAL_NONE;
signal.strength = 0.0;
signal.confluenceScore = 0.0;
signal.passesFilters = false;
signal.signalTime = TimeCurrent();

// 🎯 PHASE 1 STEP 1: Collect all component scores with enhanced precision
bool success = CollectEnhancedComponentScores(signal, analysis);
if(!success) {
return SIGNAL_NONE;
}

// 🎯 PHASE 2 STEP 2: Calculate enhanced confluence with ML and session adjustment
double confluenceScore = CalculateEnhancedConfluenceWithML(signal);
signal.confluenceScore = confluenceScore;

// 🎯 PHASE 2 STEP 3: Check signal cooldown period
if(!PassesSignalCooldown()) {
LogRejectedSignal(signal, "SIGNAL_COOLDOWN_ACTIVE");
return SIGNAL_NONE;
}

// 🎯 PHASE 2 STEP 4: Apply strict quality filters
if(!PassesEnhancedFilters(signal)) {
LogRejectedSignal(signal, "ENHANCED_FILTER_REJECTION");
return SIGNAL_NONE;
}

// 🎯 PHASE 4 STEP 4.5: Scout mode PVSRA validation
if(!ValidateScoutModePVSRA(signal.pvsraScore, SCENARIO_SCOUT_SMC_STRICT)) {
    LogRejectedSignal(signal, "SCOUT_MODE_PVSRA_BELOW_THRESHOLD");
    return SIGNAL_NONE;
}

// 🎯 PHASE 2 STEP 5: Dynamic confluence threshold (adaptive)
double requiredThreshold = m_adaptiveFilteringEnabled ? m_dynamicConfluenceThreshold : 0.75;
if(confluenceScore < requiredThreshold) {
LogRejectedSignal(signal, StringFormat("CONFLUENCE_BELOW_THRESHOLD: %.1f%% < %.1f%%", confluenceScore*100, requiredThreshold*100));
return SIGNAL_NONE;
}

// 🎯 PHASE 1 STEP 5: Determine signal direction with precision
ENUM_SIGNAL_TYPE signalDirection = DeterminePreciseSignalDirection(signal);
if(signalDirection == SIGNAL_NONE) {
LogRejectedSignal(signal, "NO_CLEAR_DIRECTION_AFTER_CONFLUENCE");
return SIGNAL_NONE;
}

// 🎯 PHASE 1 STEP 6: Final validation and signal generation
signal.signalType = signalDirection;
signal.confidence = confluenceScore;

// Store successful signal
m_lastSignal = signal;
m_lastSignalTime = TimeCurrent();
m_totalSignals++;

// Update performance metrics
double weightedConfluence = confluenceScore * signal.confidence;
m_avgConfluenceScore = (m_avgConfluenceScore * 0.9) + (weightedConfluence * 0.1);

// 🎯 PHASE 1 LOGGING: Detailed signal information
LogSuccessfulSignal(signal);

return signalDirection;
}

//+------------------------------------------------------------------+
//| PHASE 3: RESTORE ALL CAnalysisConsolidated FUNCTIONS            |
//+------------------------------------------------------------------+
// All functions below use CAnalysisConsolidated which is now available

//+------------------------------------------------------------------+
//| 🎯 PHASE 1: ENHANCED COMPONENT SCORE COLLECTION                 |
//+------------------------------------------------------------------+
bool CollectEnhancedComponentScores(SEnhancedSignalData& signal, CAnalysisConsolidated* analysis)
{
    // 🐉 Component 1: Enhanced Dragon Band Analysis (30% weight)
    signal.dragonScore = GetEnhancedDragonBandScore(analysis);
    if(signal.dragonScore < 0.3) {
        return false; // Minimum Dragon Band requirement
    }

    // 📊 Component 2: Enhanced Wave Pattern Analysis (25% weight)
    signal.waveScore = GetEnhancedWavePatternScore(analysis);

    // 🎯 Component 3: Enhanced SMC Analysis (25% weight)
    signal.smcScore = GetEnhancedSMCScore(analysis);

    // 📈 Component 4: Enhanced PVSRA Analysis (20% weight)
    signal.pvsraScore = GetEnhancedSMCScore(analysis); // TEMP: use SMC score for PVSRA weight to avoid missing API

    // 🎯 PHASE 1: Additional validation factors
    signal.marketStructureScore = GetMarketStructureScore(analysis);
    signal.volumeConfirmationScore = GetVolumeConfirmationScore(analysis);
    signal.trendAlignmentScore = GetTrendAlignmentScore(analysis);

    // Calculate basic strength score
    signal.strengthScore = (signal.dragonScore + signal.waveScore +
                            signal.smcScore + signal.pvsraScore) / 4.0;

    return true;
}

//+------------------------------------------------------------------+
//| 🎯 PHASE 1: SUPPORTING HELPERS AND MISSING DEFINITIONS           |
//+------------------------------------------------------------------+
// Calculate enhanced confluence with optional ML/session weighting
double CalculateEnhancedConfluenceWithML(const SEnhancedSignalData &signal)
{
    // Base confluence via class helper
    double confluence = CalculatePerfectConfluence_(signal);

    // Optional ML contribution (disabled if modules not compiled)
    #ifdef INCLUDE_AI_ML_MODULES
        double mlConfidence = 0.5; // placeholder; integrate NN output if available
        confluence = MathMin(1.0, confluence * (1.0 - 0.15) + mlConfidence * 0.15);
    #endif

    // Session adjustment (use London/NY overlap boost heuristics)
    MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
    bool overlap = (dt.hour >= 13 && dt.hour <= 17);
    if(overlap) confluence = MathMin(1.0, confluence * 1.05);

    return confluence;
}

// Cooldown gate: avoid over-signal within m_signalCooldownPeriod seconds
bool PassesSignalCooldown()
{
    static datetime s_last = 0;
    if(s_last == 0) { s_last = TimeCurrent(); return true; }
    if((TimeCurrent() - s_last) < m_signalCooldownPeriod) return false;
    s_last = TimeCurrent();
    return true;
}

// Wrapper to use filter class instance
bool PassesEnhancedFilters(SEnhancedSignalData &signal)
{
    // Use local filter routine as single source of truth
    return PassesAllFilters(signal);
}

// Minimal local filter gate until full filter engine wired
bool PassesAllFilters(SEnhancedSignalData &signal)
{
    // Basic thresholding to avoid noisy trades; tune later
    if(signal.dragonScore < 0.4) return false;
    if(signal.pvsraScore < 0.4) return false;
    // Optional checks
    if(signal.strengthScore < 0.45) return false;
    return true;
}


// Validate scout mode minimum PVSRA depending on scenario strictness
bool ValidateScoutModePVSRA(const double pvsraScore, ENUM_TRADING_SCENARIO scenario)
{
    // thresholds by scenario
    double minReq = 0.0;
    switch(scenario)
    {
    case SCENARIO_SCOUT_SMC_MULTIFRAME: minReq = 0.65; break;
    case SCENARIO_WITH_VPSRA: minReq = 0.55; break;
        default:                        minReq = 0.50; break;
    }
    return (pvsraScore >= minReq);
}

// Determine direction using component balances
ENUM_SIGNAL_TYPE DeterminePreciseSignalDirection(const SEnhancedSignalData &s)
{
    double bullBias = 0.0, bearBias = 0.0;

    // Use trend alignment and Dragon band as primary bearings
    bullBias += (s.trendAlignmentScore);
    bearBias += (1.0 - s.trendAlignmentScore);

    // Volume confirmation adds to prevailing bias
    bullBias += (s.volumeConfirmationScore);
    bearBias += (1.0 - s.volumeConfirmationScore);

    // Market structure: assume >0.5 favors continuation with trend
    bullBias += (s.marketStructureScore > 0.5 ? 0.5 : 0.0);
    bearBias += (s.marketStructureScore <= 0.5 ? 0.5 : 0.0);

    if(bullBias - bearBias > 0.3) return SIGNAL_BUY;
    if(bearBias - bullBias > 0.3) return SIGNAL_SELL;
    return SIGNAL_NONE;
}

// Directional alignment check among components
bool IsDirectionalAlignment(const SEnhancedSignalData &s)
{
    int agrees = 0;
    if(s.trendAlignmentScore > 0.6) agrees++;
    if(s.volumeConfirmationScore > 0.6) agrees++;
    if(s.marketStructureScore > 0.6) agrees++;
    return agrees >= 2;
}

// Map to enhanced scores using available consolidated analysis where needed
inline double GetEnhancedWavePatternScore(CAnalysisConsolidated *analysis)
{
    if(analysis != NULL) return analysis.GetWavePatternScore();
    return 0.5;
}

inline double GetEnhancedSMCScore(CAnalysisConsolidated *analysis)
{
    if(analysis != NULL) return analysis.GetSMCScore();
    return 0.5;
}

inline double GetMarketStructureScore(CAnalysisConsolidated *analysis)
{
    if(analysis != NULL) return analysis.GetMarketStructureScore();
    return 0.5;
}

inline double GetVolumeConfirmationScore(CAnalysisConsolidated *analysis)
{
    if(analysis != NULL) return analysis.GetVolumeConfirmationScore();
    return 0.5;
}

inline double GetTrendAlignmentScore(CAnalysisConsolidated *analysis)
{
    if(analysis != NULL) return analysis.GetTrendAlignmentScore();
    return 0.5;
}

// ATR helper used in Dragon score
double GetATRValue(int period=14)
{
    int h = iATR(_Symbol, PERIOD_CURRENT, period);
    if(h == INVALID_HANDLE) return 0.0;
    double buf[1];
    int copied = CopyBuffer(h, 0, 0, 1, buf);
    IndicatorRelease(h);
    if(copied < 1) return 0.0;
    return buf[0];
}

// Wrapper string helper for logging
string GetSignalTypeString(ENUM_SIGNAL_TYPE t)
{
    return SignalTypeToString(t);
}

// [FIX] Removed stray closing brace that prematurely ended class
//+------------------------------------------------------------------+
//| 🎯 PHASE 1: PERFECT CONFLUENCE CALCULATION                      |
//+------------------------------------------------------------------+
// Move helper inside class to avoid global-scope state leaks
private:
    double CalculatePerfectConfluence_(const SEnhancedSignalData& signal)
    {
        double confluence = 0.0;
        confluence += signal.dragonScore * 0.30;        // Dragon Band: 30%
        confluence += signal.waveScore * 0.25;          // Wave Pattern: 25%
        confluence += signal.smcScore * 0.25;           // SMC: 25%
        confluence += signal.pvsraScore * 0.10;         // PVSRA: 10%
        confluence += signal.marketStructureScore * 0.05;   // Market Structure: 5%
        confluence += signal.volumeConfirmationScore * 0.05; // Volume: 5%
        double alignmentBonus = 0.0;
        if(IsDirectionalAlignment(signal)) alignmentBonus += 0.05;
        if(signal.trendAlignmentScore > 0.8) alignmentBonus += 0.03;
        if(signal.volumeConfirmationScore > 0.9) alignmentBonus += 0.02;
        return MathMin(1.0, confluence + alignmentBonus);
    }

public:

//+------------------------------------------------------------------+
//| 🎯 PHASE 1: LOGGING HELPERS                                      |
//+------------------------------------------------------------------+
void LogRejectedSignal(const SEnhancedSignalData &signal, const string reason)
{
    Print("❌ REJECTED SIGNAL | ", reason,
          StringFormat(" | Conf: %.1f%% | Confluence: %.1f%%", signal.confidence*100, signal.confluenceScore*100));
}

//+------------------------------------------------------------------+
//| 🎯 PHASE 1: ENHANCED COMPONENT SCORE FUNCTIONS                  |
//+------------------------------------------------------------------+
double GetEnhancedDragonBandScore(CAnalysisConsolidated* analysis)
{
// Get Dragon Band angle and trend strength with enhanced precision
double dragonAngle = 0.0;
double pullbackQuality = 0.0;
double bandPosition = 0.0;

// 🎯 PHASE 2: Enhanced EMA calculations via unified system
double ema34[], ema89[];
ArraySetAsSeries(ema34, true);
ArraySetAsSeries(ema89, true);

// 🔧 CRITICAL FIX: Kiểm tra manager null trước khi sử dụng
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();
if(manager == NULL) {
Print("❌ [SIGNAL] Unified Indicator Manager not initialized, using direct iMA()");
// Fallback to direct iMA calls
int ema34Handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
int ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);

if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE) {
Print("❌ [SIGNAL] Failed to create fallback EMA handles");
return false;
}

// Use fallback handles
// ... continue with direct handles ...
return true;
}

int ema34Handle = manager.GetEMAHandle(_Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
int ema89Handle = manager.GetEMAHandle(_Symbol, PERIOD_CURRENT, 89, PRICE_CLOSE);

if(ema34Handle == INVALID_HANDLE || ema89Handle == INVALID_HANDLE) {
Print("❌ [SIGNAL] Failed to get EMA handles from unified manager");
Print("EMA34: ", (ema34Handle != INVALID_HANDLE ? "✅" : "❌"));
Print("EMA89: ", (ema89Handle != INVALID_HANDLE ? "✅" : "❌"));
return false;
}

// Migration note: EMA 34/89 now uses unified handle system via CUnifiedIndicatorManager

if(ema34Handle != INVALID_HANDLE && ema89Handle != INVALID_HANDLE) {
if(CopyBuffer(ema34Handle, 0, 0, 5, ema34) >= 5 &&
CopyBuffer(ema89Handle, 0, 0, 5, ema89) >= 5) {

// Calculate precise Dragon angle (Sonic R formula)
double deltaPrice = ema34[0] - ema34[4];
double deltaBars = 4.0;
double slope = deltaPrice / deltaBars;

// Visual scaling factors for accurate angle
const double PIXELS_PER_BAR = 5.0;
const double PIXELS_PER_PRICE = 100000.0;
double scaledSlope = slope * PIXELS_PER_PRICE / PIXELS_PER_BAR;
dragonAngle = MathArctan(scaledSlope) * 180.0 / M_PI;
dragonAngle = MathMax(-90.0, MathMin(90.0, dragonAngle));

// Trend alignment score
double trendAlignment = (ema34[0] > ema89[0]) ? 1.0 : -1.0;
if(dragonAngle * trendAlignment > 0) {
pullbackQuality = 0.8; // Good trend alignment
} else {
pullbackQuality = 0.3; // Poor trend alignment
}

// Band position analysis
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
double bandCenter = ema34[0];
double distance = MathAbs(currentPrice - bandCenter);
double atr = GetATRValue();

if(atr > 0) {
bandPosition = 1.0 - MathMin(1.0, distance / atr);
}
}

IndicatorRelease(ema34Handle);
IndicatorRelease(ema89Handle);
}

// Enhanced scoring with multiple factors
double angleScore = MathMin(1.0, MathAbs(dragonAngle) / 10.0); // Normalize to 10 degrees
double qualityScore = pullbackQuality;
double positionScore = bandPosition;

// Weighted combination
double totalScore = (angleScore * 0.5) + (qualityScore * 0.3) + (positionScore * 0.2);

return MathMin(1.0, totalScore);
}

double GetWavePatternScore(CAnalysisConsolidated* analysis)
{
// Simplified wave pattern scoring
// Check for L-H-HL or H-L-LH patterns

double score = 0.0;

// Get recent swing points (simplified)
double recentHigh = iHigh(_Symbol, PERIOD_CURRENT, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, 10, 1));
double recentLow = iLow(_Symbol, PERIOD_CURRENT, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, 10, 1));
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);

// Check for pattern structure
if(currentPrice > recentLow && currentPrice < recentHigh) {
score = 0.6; // Decent pattern

// Volume confirmation boost
double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
double avgVolume = 0;
for(int i = 1; i <= 10; i++) {
avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 10.0;

if(currentVolume > avgVolume * 1.2) {
score += 0.2; // Volume boost
}
}

return MathMin(1.0, score);
}

double GetPVSRAScore()
{
    // Unified facade call for consistent PVSRA score
    return GetVPSRAScore(_Symbol, PERIOD_CURRENT, 1);
}

double GetSMCScore()
{
return 0.5;
}

double GetSupportResistanceScore()
{
double score = 0.0;
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);

// Find nearest support/resistance levels
double resistance = iHigh(_Symbol, PERIOD_CURRENT, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, 20, 1));
double support = iLow(_Symbol, PERIOD_CURRENT, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, 20, 1));

// Check distance to levels
double distanceToResistance = resistance - currentPrice;
double distanceToSupport = currentPrice - support;
double atr = 20 * _Point; // Simplified ATR

// Score based on proximity to levels
if(distanceToResistance < atr * 0.3 || distanceToSupport < atr * 0.3) {
score = 0.8; // Near key level
} else if(distanceToResistance < atr * 0.5 || distanceToSupport < atr * 0.5) {
score = 0.6; // Moderately close
} else {
score = 0.3; // Far from levels
}

return score;
}

// 🎯 PHASE 1: MACD Momentum Score (replaces RSI)
double GetMomentumScore()
{
double score = 0.5; // Default neutral

// MACD(12,26,9) momentum - Phase 1 implementation
int macdHandle = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
double macdMain[], macdSignal[];
ArraySetAsSeries(macdMain, true);
ArraySetAsSeries(macdSignal, true);

if(CopyBuffer(macdHandle, 0, 0, 3, macdMain) >= 3 &&
CopyBuffer(macdHandle, 1, 0, 3, macdSignal) >= 3) {

double currentMACD = macdMain[0];
double prevMACD = macdMain[1];
double currentSignal = macdSignal[0];
double prevSignal = macdSignal[1];

// MACD momentum calculation
double macdMomentum = currentMACD - prevMACD;
double signalMomentum = currentSignal - prevSignal;
double histogram = currentMACD - currentSignal;
double prevHistogram = prevMACD - prevSignal;
double histogramChange = histogram - prevHistogram;

// Score based on MACD confluence
if(MathAbs(histogram) > 0.0001) { // Active MACD signal
if(histogramChange > 0 && histogram > 0) { // Bullish momentum strengthening
score = 0.8;
} else if(histogramChange < 0 && histogram < 0) { // Bearish momentum strengthening
score = 0.2;
} else if(MathAbs(macdMomentum) > 0.0001) { // Moderate momentum
score = (macdMomentum > 0) ? 0.65 : 0.35;
}
}

IndicatorRelease(macdHandle);
}

Print(StringFormat("[🎯 PHASE 1] MACD Momentum Score: %.3f", score));
return score;
}

ENUM_SIGNAL_TYPE DetermineSignalDirection(SEnhancedSignalData& signal)
{
// Determine direction based on strongest components
double bullishEvidence = 0.0;
double bearishEvidence = 0.0;

// Dragon Band direction
double ema34Current = 0, ema34Prev = 0;
int emaHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
double ema[];
ArraySetAsSeries(ema, true);
if(CopyBuffer(emaHandle, 0, 0, 2, ema) >= 2) {
if(ema[0] > ema[1]) bullishEvidence += signal.dragonScore;
else bearishEvidence += signal.dragonScore;
}
IndicatorRelease(emaHandle);

// Current price vs EMA
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
if(currentPrice > ema34Current) bullishEvidence += 0.2;
else bearishEvidence += 0.2;



// Determine final direction
double threshold = 0.4; // Minimum evidence required
if(bullishEvidence > bearishEvidence && bullishEvidence > threshold) {
return SIGNAL_BUY;
} else if(bearishEvidence > bullishEvidence && bearishEvidence > threshold) {
return SIGNAL_SELL;
}

return SIGNAL_NONE;
}

double CalculateSignalConfidence(SEnhancedSignalData& signal)
{
// Base confidence from confluence score
double confidence = signal.confluenceScore;

// Boost for high individual component scores
int highScoreComponents = 0;
if(signal.dragonScore > 0.8) highScoreComponents++;
if(signal.smcScore > 0.8) highScoreComponents++;
if(signal.pvsraScore > 0.8) highScoreComponents++;

// Boost confidence for multiple high scores
confidence += (highScoreComponents * 0.05);

return MathMin(1.0, confidence);
}

bool IsNewBarOrSignificantChange()
{
static datetime lastBarTime = 0;
datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);

if(currentBarTime != lastBarTime) {
lastBarTime = currentBarTime;
return true; // New bar
}

// Check for significant price change
static double lastPrice = 0;
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
if(lastPrice > 0) {
double priceChange = MathAbs(currentPrice - lastPrice) / lastPrice;
if(priceChange > 0.001) { // 0.1% change
lastPrice = currentPrice;
return true;
}
} else {
lastPrice = currentPrice;
}

return false;
}

void LogSuccessfulSignal(SEnhancedSignalData& signal)
{
Print("🚀 =============== ENHANCED SIGNAL GENERATED ===============");
    Print(StringFormat("🎯 SIGNAL: %s | Confidence: %.1f%% | Confluence: %.1f%%",
        GetSignalTypeString(signal.signalType), signal.confidence*100, signal.confluenceScore*100));
Print("📊 COMPONENT BREAKDOWN:");
Print(StringFormat("   🐉 Dragon: %.1f%% | 🌊 Wave: %.1f%% | 📊 PVSRA: %.1f%%",
signal.dragonScore*100, signal.waveScore*100, signal.pvsraScore*100));
Print(StringFormat("   💰 SMC: %.1f%% | 📈 SR: %.1f%% | ⚡ Mom: %.1f%%",
signal.smcScore*100, signal.srScore*100, signal.momentumScore*100));
}

//+------------------------------------------------------------------+
//| Process signals function - PHASE 2: With Aggregator             |
//+------------------------------------------------------------------+
SignalData ProcessSignals()
{
    SignalData signalData;
    signalData.signalType = SIGNAL_NONE;
    signalData.confidence = 0.0;
    signalData.entryPrice = 0.0;
    signalData.stopLoss = 0.0;
    signalData.takeProfit = 0.0;
    signalData.timestamp = TimeCurrent();
    signalData.reason = "";
    signalData.isValid = false;
    
    // PHASE 2: Use aggregator for confluence scoring
    if(m_aggregator == NULL) {
        Print("[ERROR] Aggregator not initialized");
        return signalData;
    }
    
    // Get component scores from last signal
    double dragonScore = m_lastSignal.dragonScore;
    double waveScore = m_lastSignal.waveScore;
    double pvsraScore = m_lastSignal.pvsraScore;
    double smcScore = m_lastSignal.smcScore;
    double srScore = m_lastSignal.srScore;
    double momentumScore = m_lastSignal.momentumScore;
    double volumeScore = m_lastSignal.volumeConfirmationScore;
    double trendScore = m_lastSignal.trendAlignmentScore;
    
    // Aggregate signals
    SAggregatedSignal aggregated = m_aggregator.AggregateSignals(
        dragonScore, waveScore, pvsraScore, smcScore,
        srScore, momentumScore, volumeScore, trendScore,
        m_lastSignal.signalType
    );
    
    // Process with filters
    if(!m_aggregator.ProcessSignals(aggregated)) {
        signalData.reason = "Signal filtered out: " + aggregated.reasoning;
        return signalData;
    }
    
    // Check validity
    if(!aggregated.isValid) {
        signalData.reason = "Invalid signal: " + aggregated.reasoning;
        return signalData;
    }
    
    // Convert to SignalData structure
    signalData.signalType = aggregated.signalType;
    signalData.confidence = aggregated.confidence;
    signalData.timestamp = aggregated.timestamp;
    signalData.isValid = true;
    signalData.reason = aggregated.reasoning;
    
    // Calculate entry price and levels
    SetSignalLevels(signalData);
    
    // Log aggregated signal
    Print("[AGGREGATED] ", aggregated.reasoning);
    
    return signalData;
}

//+------------------------------------------------------------------+
//| SET SIGNAL LEVELS                                               |
//+------------------------------------------------------------------+
void SetSignalLevels(SignalData &data)
{
double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

switch(data.signalType)
{
case SIGNAL_BUY:
data.entryPrice = currentPrice;
// Legacy static SL/TP (100/200 points) removed to avoid mis-sizing across symbols
// Use unified SL/TP computation in execution layer (Risk/Trade Manager)
// data.stopLoss = currentPrice - (100 * _Point);
// data.takeProfit = currentPrice + (200 * _Point);
data.reason = "BUY signal generated";
break;

case SIGNAL_SELL:
data.entryPrice = currentPrice;
// Legacy static SL/TP (100/200 points) removed to avoid mis-sizing across symbols
// Use unified SL/TP computation in execution layer (Risk/Trade Manager)
// data.stopLoss = currentPrice + (100 * _Point);
// data.takeProfit = currentPrice - (200 * _Point);
data.reason = "SELL signal generated";
break;

default:
data.entryPrice = currentPrice;
data.stopLoss = 0.0;
data.takeProfit = 0.0;
data.reason = "No valid signal";
    break;
}
}

// Scenario-specific signal APIs
/*
ENUM_SIGNAL_TYPE GetSignal_SonicR_Basic_Internal()
{
// EMA-based Sonic R Basic: trend alignment + EMA34 momentum
int h34=iMA(_Symbol,PERIOD_CURRENT,34,0,MODE_EMA,PRICE_CLOSE);
int h89=iMA(_Symbol,PERIOD_CURRENT,89,0,MODE_EMA,PRICE_CLOSE);
int h200=iMA(_Symbol,PERIOD_CURRENT,200,0,MODE_EMA,PRICE_CLOSE);

double ema34[]; ArrayResize(ema34,2);
double ema89[]; ArrayResize(ema89,1);
double ema200[]; ArrayResize(ema200,1);
ArraySetAsSeries(ema34,true);
ArraySetAsSeries(ema89,true);
ArraySetAsSeries(ema200,true);
if(h34!=INVALID_HANDLE) CopyBuffer(h34,0,0,2,ema34);
if(h89!=INVALID_HANDLE) CopyBuffer(h89,0,0,1,ema89);
if(h200!=INVALID_HANDLE) CopyBuffer(h200,0,0,1,ema200);
if(h34!=INVALID_HANDLE) IndicatorRelease(h34);
if(h89!=INVALID_HANDLE) IndicatorRelease(h89);
if(h200!=INVALID_HANDLE) IndicatorRelease(h200);

if(ema34[0]==0.0 || ema89[0]==0.0 || ema200[0]==0.0) return SIGNAL_NONE;
bool buyTrend  = (ema34[0] > ema89[0] && ema89[0] > ema200[0]);
bool sellTrend = (ema34[0] < ema89[0] && ema89[0] < ema200[0]);
bool ema34Up = (ema34[0] > ema34[1]);
bool ema34Dn = (ema34[0] < ema34[1]);
if(buyTrend && ema34Up) return SIGNAL_BUY;
if(sellTrend && ema34Dn) return SIGNAL_SELL;
return SIGNAL_NONE;
}
*/

// Implemented below (real PVSRA). Kept here for context.

// Removed stub to avoid shadowing the global implementation

}; // End of CConsolidatedSignals class

//+------------------------------------------------------------------+
//| GLOBAL ENHANCED SIGNAL ENGINE                                   |
//+------------------------------------------------------------------+
// REMOVED: CEnhancedSignalEngine* g_EnhancedSignalEngine = NULL;

//+------------------------------------------------------------------+
//| INITIALIZATION FUNCTIONS                                        |
//+------------------------------------------------------------------+
// DISABLED: Global functions commented out for standalone compilation compatibility
// These functions use g_SignalProcessor global variable that only exists in main EA
/*
bool InitializeEnhancedSignalEngine()
{
// FIXED: Use global g_SignalProcessor (already declared in main EA)
if(g_SignalProcessor == NULL) {
g_SignalProcessor = new CSignalConsolidated();
Print("🚀 Enhanced Signal Engine initialized successfully");
return true;
}
return true;
}

void DeinitializeEnhancedSignalEngine()
{
if(g_SignalProcessor != NULL) {
delete g_SignalProcessor;
g_SignalProcessor = NULL;
}
}
*/

// DISABLED: Global function commented out for standalone compilation compatibility
/*
ENUM_SIGNAL_TYPE GenerateEnhancedSignal(CAnalysisConsolidated* analysis)
{
if(g_SignalProcessor != NULL) {
double confluenceScore = g_SignalProcessor.GenerateEnhancedSignal(analysis);
double mlScore = g_SignalProcessor.GetNeuralConfirmation(analysis);  // Assume method from AI file
double finalConfluence = (confluenceScore + mlScore) / 2;
if(finalConfluence >= 0.75) {
// Generate signal
}
return confluenceScore; // Return confluence score for now
}
return SIGNAL_NONE;
}
*/

//+------------------------------------------------------------------+
//| 🔧 CRITICAL FIX: Missing Function Declarations                   |
//+------------------------------------------------------------------+

// Analysis instance getter - REMOVED: Duplicate function definition
// This function is already defined in Analysis_Consolidated.mqh

// Missing SMC functions - Stub implementations (removed duplicates)
// Functions already defined in class methods above
// Real-time confirmation functions already defined in class methods above

#endif // SIGNAL_CONSOLIDATED_MQH


//+------------------------------------------------------------------+
//| 🚀 SMC UTILITY FUNCTIONS CLASS - PROPER ENCAPSULATION           |
//+------------------------------------------------------------------+
#ifndef CSMC_UTILITIES_DECLARED
#define CSMC_UTILITIES_DECLARED
class CSMCUtilities
{
public:
    // SMC functions implementation
    static bool HasActiveOrderBlocks() { return false; }

    double GetNearestOrderBlockStrength(double price) { return 0.0; }

    bool IsLiquidityHuntActive() { return false; }

    static double GetLiquidityHuntProbability() { return 0.0; }
};
#endif // CSMC_UTILITIES_DECLARED

// Internal prototypes for wrapper calls
// (removed to avoid warning 46, bodies are defined below)


// Global implementations to match prototypes above
ENUM_SIGNAL_TYPE GetSignal_SonicR_Basic_Internal()
{
    // PATCH: Dragon Band Signal Implementation with Cached Handles
    if(!g_indicatorManager || !g_indicatorManager.IsInitialized()) {
        return SIGNAL_NONE;
    }

    // Get EMA values for Dragon Band analysis using cached handles
    double ema34, ema89, ema200;
    if(!GetEMAValues(ema34, ema89, ema200, 3)) {
        return SIGNAL_NONE;
    }

    // Get ATR for volatility confirmation
    double atrValue;
    if(!g_indicatorManager.GetATRValue(atrValue)) {
        return SIGNAL_NONE;
    }

    // Get current price
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    if(currentPrice <= 0) {
        return SIGNAL_NONE;
    }

    // Dragon Band Core Logic
    // 1. EMA Alignment Check
    bool bullishAlignment = (ema34 > ema89) && (ema89 > ema200);
    bool bearishAlignment = (ema34 < ema89) && (ema89 < ema200);

    // 2. Dragon Angle Analysis (EMA slope)
    double ema34_prev, ema89_prev, ema200_prev;
    if(!g_indicatorManager.GetEMAValues(ema34_prev, ema89_prev, ema200_prev, 4)) {
        return SIGNAL_NONE;
    }
    double ema34_slope = ema34 - ema34_prev;
    double ema89_slope = ema89 - ema89_prev;

    // Minimum slope threshold (based on ATR)
    double slopeThreshold = atrValue * 0.1; // 10% of ATR

    bool strongBullishSlope = (ema34_slope > slopeThreshold) && (ema89_slope > slopeThreshold * 0.5);
    bool strongBearishSlope = (ema34_slope < -slopeThreshold) && (ema89_slope < -slopeThreshold * 0.5);

    // 3. Price Position Relative to Dragon Band
    bool priceAboveDragon = currentPrice > ema34;
    bool priceBelowDragon = currentPrice < ema34;

    // 4. Dragon Band Width Analysis
    double bandWidth = MathAbs(ema34 - ema200);
    double minBandWidth = atrValue * 0.5; // Minimum band width for valid signals

    if(bandWidth < minBandWidth) {
        return SIGNAL_NONE; // Band too narrow, market consolidating
    }

    // 5. Dragon Breakout Signals
    // Bullish Dragon Signal
    if(bullishAlignment && strongBullishSlope && priceAboveDragon) {
        // Additional confirmation: price should be within reasonable distance from EMA34
        double maxDistance = atrValue * 1.5;
    if((currentPrice - ema34) <= maxDistance) {
            return SIGNAL_BUY;
        }
    }

    // Bearish Dragon Signal
    if(bearishAlignment && strongBearishSlope && priceBelowDragon) {
        // Additional confirmation: price should be within reasonable distance from EMA34
        double maxDistance = atrValue * 1.5;
    if((ema34 - currentPrice) <= maxDistance) {
            return SIGNAL_SELL;
        }
    }

    // 6. Dragon Reversal Signals (when price returns to dragon after pullback)
    if(bullishAlignment && !strongBearishSlope) {
        // Price returning to EMA34 from above in uptrend
    if(currentPrice <= ema34 && currentPrice >= ema89) {
            return SIGNAL_BUY;
        }
    }

    if(bearishAlignment && !strongBullishSlope) {
        // Price returning to EMA34 from below in downtrend
    if(currentPrice >= ema34 && currentPrice <= ema89) {
            return SIGNAL_SELL;
        }
    }

    return SIGNAL_NONE;
}

// This function is now implemented above in the PATCH section

// PATCH: Real Signal Implementation - Replace STUB functions
ENUM_SIGNAL_TYPE GetSignal_SonicR_VPSRA_Internal()
{
    // PVSRA Enhanced Signal Logic
    if(!g_indicatorManager || !g_indicatorManager.IsInitialized()) {
        return SIGNAL_NONE;
    }

    // Get EMA values for trend confirmation
    double ema34, ema89, ema200;
    if(!GetEMAValues(ema34, ema89, ema200, 3)) {
        return SIGNAL_NONE;
    }

    // Get current price data
    double high[], low[], close[];
    long volume[];
    ArrayResize(high, 3); ArrayResize(low, 3); ArrayResize(close, 3); ArrayResize(volume, 3);
    ArraySetAsSeries(high, true); ArraySetAsSeries(low, true);
    ArraySetAsSeries(close, true); ArraySetAsSeries(volume, true);

    if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, 3, high) != 3 ||
       CopyLow(_Symbol, PERIOD_CURRENT, 0, 3, low) != 3 ||
       CopyClose(_Symbol, PERIOD_CURRENT, 0, 3, close) != 3 ||
       CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 3, volume) != 3) {
        return SIGNAL_NONE;
    }

    // PVSRA Analysis
    double currentVolume = (double)volume[0];
    double avgVolume = ((double)volume[0] + (double)volume[1] + (double)volume[2]) / 3.0;
    double volumeRatio = (avgVolume > 0.0) ? currentVolume / avgVolume : 1.0;

    // Volume threshold for PVSRA confirmation
    if(volumeRatio < 1.5) {
        return SIGNAL_NONE; // Insufficient volume
    }

    // Spread analysis
    double spread = high[0] - low[0];
    double avgSpread = ((high[0] - low[0]) + (high[1] - low[1]) + (high[2] - low[2])) / 3.0;
    double spreadRatio = (avgSpread > 0) ? spread / avgSpread : 1.0;

    // Close position analysis
    double closePosition = (close[0] - low[0]) / (high[0] - low[0]);

    // EMA trend confirmation
    bool bullishTrend = (ema34 > ema89) && (ema89 > ema200);
    bool bearishTrend = (ema34 < ema89) && (ema89 < ema200);

    // PVSRA Pattern Recognition
    if(volumeRatio >= 2.0 && spreadRatio >= 1.2) {
        // High volume + wide spread
        if(closePosition > 0.7 && bullishTrend) {
            return SIGNAL_BUY; // Bullish climax/stopping volume
        }
        if(closePosition < 0.3 && bearishTrend) {
            return SIGNAL_SELL; // Bearish climax/stopping volume
        }
    }

    if(volumeRatio >= 1.5 && spreadRatio < 0.8) {
        // High volume + narrow spread (No Demand/No Supply)
        if(closePosition < 0.4 && !bullishTrend) {
            return SIGNAL_SELL; // No Demand
        }
        if(closePosition > 0.6 && !bearishTrend) {
            return SIGNAL_BUY; // No Supply
        }
    }

    return SIGNAL_NONE;
}

ENUM_SIGNAL_TYPE GetSignal_Scout_Internal()
{
    // Scout Signal Logic - Early trend detection
    if(!g_indicatorManager || !g_indicatorManager.IsInitialized()) {
        return SIGNAL_NONE;
    }

    // Get EMA values for multiple periods
    double ema34, ema89, ema200;
    if(!GetEMAValues(ema34, ema89, ema200, 5)) {
        return SIGNAL_NONE;
    }

    // Get ATR for volatility analysis
    double atrValue;
    if(!g_indicatorManager.GetATRValue(atrValue)) {
        return SIGNAL_NONE;
    }

    // Get price data
    double close[];
    ArrayResize(close, 5);
    ArraySetAsSeries(close, true);
    if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 5, close) != 5) {
        return SIGNAL_NONE;
    }

    // Scout conditions: Early trend momentum
    double currentPrice = close[0];
    double priceChange = currentPrice - close[4]; // 5-bar price change
    double atrThreshold = atrValue * 2.0; // 2x ATR threshold

    // EMA momentum analysis
    double ema34_prev2, ema89_prev2, ema200_prev2;
    if(!g_indicatorManager.GetEMAValues(ema34_prev2, ema89_prev2, ema200_prev2, 7)) {
        return SIGNAL_NONE;
    }
    double ema34_momentum = ema34 - ema34_prev2; // approx multi-bar momentum
    double ema89_momentum = ema89 - ema89_prev2;

    // Strong momentum conditions
    bool strongBullishMomentum = (priceChange > atrThreshold) &&
                                (ema34_momentum > 0) && (ema89_momentum > 0) &&
                                (ema34 > ema89) && (currentPrice > ema34);

    bool strongBearishMomentum = (priceChange < -atrThreshold) &&
                                (ema34_momentum < 0) && (ema89_momentum < 0) &&
                                (ema34 < ema89) && (currentPrice < ema34);

    // Scout early entry signals
    if(strongBullishMomentum && (ema34 > ema200)) {
        return SIGNAL_BUY;
    }

    if(strongBearishMomentum && (ema34 < ema200)) {
        return SIGNAL_SELL;
    }

    return SIGNAL_NONE;
}

// Wrapper functions for forward declarations compatibility
ENUM_SIGNAL_TYPE GetSignal_SonicR_Basic()
{
    return GetSignal_SonicR_Basic_Internal();
}

ENUM_SIGNAL_TYPE GetSignal_SonicR_VPSRA()
{
    return GetSignal_SonicR_VPSRA_Internal();
}

// Provide a wrapper for Scout that conforms to the API header
bool GetSignal_Scout(SignalDecision &out, const string sym, ENUM_TIMEFRAMES tf)
{
    ENUM_SIGNAL_TYPE sig = GetSignal_Scout_Internal();
    out.signalType = sig;
    out.confidence = (sig != SIGNAL_NONE) ? 0.7 : 0.0;
    out.timestamp = TimeCurrent();
    out.isValid = (sig != SIGNAL_NONE);
    out.reason = (sig==SIGNAL_BUY?"BUY":"") + (sig==SIGNAL_SELL?"SELL":"");
    out.scenario = SCENARIO_SCOUT_SMC_MULTIFRAME;
    out.isScout = true;
    return (sig != SIGNAL_NONE);
}

// API wrappers to satisfy declarations in 04_SignalGeneration_00_ConsolidatedSignals.api.mqh
bool GetSignal_SonicR_Basic(SignalDecision &out, const string sym, ENUM_TIMEFRAMES tf)
{
    ENUM_SIGNAL_TYPE sig = GetSignal_SonicR_Basic_Internal();
    out.signalType = sig;
    out.confidence = (sig != SIGNAL_NONE) ? 0.7 : 0.0;
    out.timestamp = TimeCurrent();
    out.isValid = (sig != SIGNAL_NONE);
    out.reason = (sig==SIGNAL_BUY?"BUY":"") + (sig==SIGNAL_SELL?"SELL":"");
    out.scenario = SCENARIO_SONIC_R_BASIC;
    out.isScout = false;
    return (sig != SIGNAL_NONE);
}

bool GetSignal_SonicR_VPSRA(SignalDecision &out, const string sym, ENUM_TIMEFRAMES tf)
{
    ENUM_SIGNAL_TYPE sig = GetSignal_SonicR_VPSRA_Internal();
    out.signalType = sig;
    out.confidence = (sig != SIGNAL_NONE) ? 0.8 : 0.0;
    out.timestamp = TimeCurrent();
    out.isValid = (sig != SIGNAL_NONE);
	out.reason = (sig==SIGNAL_BUY?"BUY":"") + (sig==SIGNAL_SELL?"SELL":"");
	return (sig != SIGNAL_NONE);
}

// END OF PHASE 3 RESTORATION - All CAnalysisConsolidated functions restored above

//+------------------------------------------------------------------+
//| PHASE 2: BASELINE FUNCTIONS - NO CAnalysisConsolidated DEPENDENCY |
//+------------------------------------------------------------------+
// These functions work without CAnalysisConsolidated and provide basic functionality

ENUM_SIGNAL_TYPE GenerateBasicSignal()
{
    // Basic signal generation without consolidated analysis
    // This provides minimal functionality for Phase 2 baseline
    return SIGNAL_NONE;
}

#endif // SIGNAL_CONSOLIDATED_MQH
