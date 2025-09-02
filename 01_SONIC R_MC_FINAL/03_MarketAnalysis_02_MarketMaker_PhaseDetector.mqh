//+------------------------------------------------------------------+
//|                            03_MarketAnalysis_02_MarketMaker_PhaseDetector.mqh |
//|                                        Market Maker Phase Detection Engine |
//|                     Identifies Position Building vs Run for Profits phases |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Development Team"
#property version   "1.00"
#property strict

#ifndef MARKET_MAKER_PHASE_DETECTOR_MQH
#define MARKET_MAKER_PHASE_DETECTOR_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_14_CoreEnums.mqh"

//+------------------------------------------------------------------+
//| Market Maker Phase Types                                         |
//+------------------------------------------------------------------+
enum ENUM_MM_PHASE
{
    MM_PHASE_UNKNOWN = 0,           // Insufficient data
    MM_PHASE_POSITION_BUILDING = 1, // Accumulation/Distribution - AVOID TRADING
    MM_PHASE_RUN_FOR_PROFITS = 2,   // Directional move - HIGH PROBABILITY
    MM_PHASE_TRANSITION = 3         // Phase change in progress
};

//+------------------------------------------------------------------+
//| Market Maker Phase Analysis Structure                           |
//+------------------------------------------------------------------+
struct SMarketMakerPhase
{
    ENUM_MM_PHASE phase;
    double confidence;              // 0.0 to 1.0
    datetime phaseStartTime;
    int phaseDurationBars;
    double volumeVariance;          // Key indicator for phase detection
    double priceEfficiency;         // Price movement vs time efficiency
    string description;
    bool tradingRecommended;
};

//+------------------------------------------------------------------+
//| Market Maker Phase Detection Configuration                      |
//+------------------------------------------------------------------+
struct SMMPhaseConfig
{
    int analysisLookback;           // Bars to analyze for phase detection
    double volumeVarianceThreshold; // High variance = Position Building
    double priceEfficiencyThreshold; // Low efficiency = Position Building
    double confidenceThreshold;    // Minimum confidence for phase change
    bool enablePhaseFiltering;      // Enable/disable phase-based filtering
    int minPhaseDuration;          // Minimum bars for stable phase
};

//+------------------------------------------------------------------+
//| Market Maker Phase Detector Class                               |
//+------------------------------------------------------------------+
class CMarketMakerPhaseDetector
{
private:
    SMMPhaseConfig m_config;
    SMarketMakerPhase m_currentPhase;
    SMarketMakerPhase m_phaseHistory[10]; // Keep last 10 phase changes
    int m_historyIndex;
    bool m_isInitialized;
    
    // Analysis arrays
    double m_volumeArray[];
    double m_priceRangeArray[];
    datetime m_timeArray[];
    
    // Performance tracking
    int m_positionBuildingDetected;
    int m_runForProfitsDetected;
    int m_tradesBlockedByPhase;
    int m_tradesApprovedByPhase;
    
public:
    CMarketMakerPhaseDetector()
    {
        InitializeDefaults();
    }
    
    //+------------------------------------------------------------------+
    //| Initialize Default Configuration                                 |
    //+------------------------------------------------------------------+
    void InitializeDefaults()
    {
        m_config.analysisLookback = 20;
        m_config.volumeVarianceThreshold = 0.3;     // High variance indicates Position Building
        m_config.priceEfficiencyThreshold = 0.6;   // Low efficiency indicates Position Building
        m_config.confidenceThreshold = 0.7;
        m_config.enablePhaseFiltering = true;
        m_config.minPhaseDuration = 3;
        
        // Initialize current phase
        m_currentPhase.phase = MM_PHASE_UNKNOWN;
        m_currentPhase.confidence = 0.0;
        m_currentPhase.phaseStartTime = 0;
        m_currentPhase.phaseDurationBars = 0;
        m_currentPhase.volumeVariance = 0.0;
        m_currentPhase.priceEfficiency = 0.0;
        m_currentPhase.description = "Initializing...";
        m_currentPhase.tradingRecommended = false;
        
        m_historyIndex = 0;
        m_isInitialized = true;
        
        // Reset counters
        m_positionBuildingDetected = 0;
        m_runForProfitsDetected = 0;
        m_tradesBlockedByPhase = 0;
        m_tradesApprovedByPhase = 0;
        
        // Initialize arrays
        ArrayResize(m_volumeArray, m_config.analysisLookback);
        ArrayResize(m_priceRangeArray, m_config.analysisLookback);
        ArrayResize(m_timeArray, m_config.analysisLookback);
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Volume Variance (Key MM Phase Indicator)             |
    //+------------------------------------------------------------------+
    double CalculateVolumeVariance(const double &volumes[], int count)
    {
        if(count < 2) return 0.0;
        
        // Calculate mean volume
        double sum = 0.0;
        for(int i = 0; i < count; i++)
            sum += volumes[i];
        double mean = sum / count;
        
        if(mean == 0.0) return 0.0;
        
        // Calculate variance
        double varianceSum = 0.0;
        for(int i = 0; i < count; i++)
        {
            double deviation = volumes[i] - mean;
            varianceSum += deviation * deviation;
        }
        
        double variance = varianceSum / (count - 1);
        double standardDeviation = MathSqrt(variance);
        
        // Return coefficient of variation (normalized variance)
        return standardDeviation / mean;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Price Movement Efficiency                             |
    //+------------------------------------------------------------------+
    double CalculatePriceEfficiency(const double &prices[], const datetime &times[], int count)
    {
        if(count < 2) return 0.0;
        
        // Calculate total price movement (sum of absolute changes)
        double totalMovement = 0.0;
        for(int i = 1; i < count; i++)
        {
            totalMovement += MathAbs(prices[i] - prices[i-1]);
        }
        
        // Calculate net price movement (start to end)
        double netMovement = MathAbs(prices[count-1] - prices[0]);
        
        if(totalMovement == 0.0) return 0.0;
        
        // Efficiency = Net Movement / Total Movement
        // High efficiency = directional movement (Run for Profits)
        // Low efficiency = choppy movement (Position Building)
        return netMovement / totalMovement;
    }
    
    //+------------------------------------------------------------------+
    //| Analyze Market Maker Phase                                      |
    //+------------------------------------------------------------------+
    void AnalyzeMarketMakerPhase(const double &volumes[], const double &highs[], 
                                const double &lows[], const datetime &times[], int count)
    {
        if(count < m_config.analysisLookback) return;
        
        // Copy data to internal arrays
        for(int i = 0; i < m_config.analysisLookback; i++)
        {
            m_volumeArray[i] = volumes[i];
            m_priceRangeArray[i] = (highs[i] + lows[i]) / 2.0; // Mid-price
            m_timeArray[i] = times[i];
        }
        
        // Calculate key metrics
        double volumeVariance = CalculateVolumeVariance(m_volumeArray, m_config.analysisLookback);
        double priceEfficiency = CalculatePriceEfficiency(m_priceRangeArray, m_timeArray, m_config.analysisLookback);
        
        // Determine phase based on metrics
        ENUM_MM_PHASE detectedPhase = DeterminePhase(volumeVariance, priceEfficiency);
        double confidence = CalculatePhaseConfidence(volumeVariance, priceEfficiency, detectedPhase);
        
        // Update current phase if confidence is sufficient
        if(confidence >= m_config.confidenceThreshold)
        {
            if(detectedPhase != m_currentPhase.phase)
            {
                // Phase change detected
                StorePhaseHistory(m_currentPhase);
                UpdateCurrentPhase(detectedPhase, confidence, volumeVariance, priceEfficiency);
            }
            else
            {
                // Same phase, update duration and metrics
                m_currentPhase.phaseDurationBars++;
                m_currentPhase.volumeVariance = volumeVariance;
                m_currentPhase.priceEfficiency = priceEfficiency;
                m_currentPhase.confidence = confidence;
            }
        }
    }
    
    //+------------------------------------------------------------------+
    //| Determine MM Phase Based on Metrics                            |
    //+------------------------------------------------------------------+
    ENUM_MM_PHASE DeterminePhase(double volumeVariance, double priceEfficiency)
    {
        // Position Building characteristics:
        // - High volume variance (irregular volume patterns)
        // - Low price efficiency (choppy, non-directional movement)
        
        // Run for Profits characteristics:
        // - Low volume variance (consistent volume patterns)
        // - High price efficiency (directional movement)
        
        bool highVolumeVariance = volumeVariance > m_config.volumeVarianceThreshold;
        bool lowPriceEfficiency = priceEfficiency < m_config.priceEfficiencyThreshold;
        
        if(highVolumeVariance && lowPriceEfficiency)
            return MM_PHASE_POSITION_BUILDING;
        else if(!highVolumeVariance && !lowPriceEfficiency)
            return MM_PHASE_RUN_FOR_PROFITS;
        else
            return MM_PHASE_TRANSITION;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Phase Detection Confidence                            |
    //+------------------------------------------------------------------+
    double CalculatePhaseConfidence(double volumeVariance, double priceEfficiency, ENUM_MM_PHASE phase)
    {
        double confidence = 0.0;
        
        switch(phase)
        {
            case MM_PHASE_POSITION_BUILDING:
            {
                // Confidence based on how clearly the metrics indicate Position Building
                double varianceScore = MathMin(volumeVariance / m_config.volumeVarianceThreshold, 2.0) / 2.0;
                double efficiencyScore = MathMin((m_config.priceEfficiencyThreshold - priceEfficiency) / m_config.priceEfficiencyThreshold, 1.0);
                confidence = (varianceScore + efficiencyScore) / 2.0;
            }
            break;
                
            case MM_PHASE_RUN_FOR_PROFITS:
            {
                // Confidence based on how clearly the metrics indicate Run for Profits
                double varianceScore = MathMin((m_config.volumeVarianceThreshold - volumeVariance) / m_config.volumeVarianceThreshold, 1.0);
                double efficiencyScore = MathMin(priceEfficiency / m_config.priceEfficiencyThreshold, 2.0) / 2.0;
                confidence = (varianceScore + efficiencyScore) / 2.0;
            }
            break;
                
            case MM_PHASE_TRANSITION:
                confidence = 0.5; // Moderate confidence for transition phase
                break;
                
            default:
                confidence = 0.0;
        }
        
        return MathMax(0.0, MathMin(1.0, confidence));
    }
    
    //+------------------------------------------------------------------+
    //| Update Current Phase Information                                |
    //+------------------------------------------------------------------+
    void UpdateCurrentPhase(ENUM_MM_PHASE newPhase, double confidence, double volumeVariance, double priceEfficiency)
    {
        m_currentPhase.phase = newPhase;
        m_currentPhase.confidence = confidence;
        m_currentPhase.phaseStartTime = TimeCurrent();
        m_currentPhase.phaseDurationBars = 1;
        m_currentPhase.volumeVariance = volumeVariance;
        m_currentPhase.priceEfficiency = priceEfficiency;
        m_currentPhase.tradingRecommended = (newPhase == MM_PHASE_RUN_FOR_PROFITS);
        
        // Update phase description and statistics
        switch(newPhase)
        {
            case MM_PHASE_POSITION_BUILDING:
                m_currentPhase.description = "Position Building - Market makers accumulating/distributing";
                m_positionBuildingDetected++;
                break;
                
            case MM_PHASE_RUN_FOR_PROFITS:
                m_currentPhase.description = "Run for Profits - Directional movement phase";
                m_runForProfitsDetected++;
                break;
                
            case MM_PHASE_TRANSITION:
                m_currentPhase.description = "Transition - Phase change in progress";
                break;
                
            default:
                m_currentPhase.description = "Unknown phase";
        }
    }
    
    //+------------------------------------------------------------------+
    //| Validate Trade Based on MM Phase                               |
    //+------------------------------------------------------------------+
    bool ValidateTradeByPhase(ENUM_SIGNAL_TYPE signalType, string &reason)
    {
        if(!m_config.enablePhaseFiltering)
        {
            reason = "MM Phase filtering disabled";
            return true;
        }
        
        // Require minimum phase duration for stability
        if(m_currentPhase.phaseDurationBars < m_config.minPhaseDuration)
        {
            reason = StringFormat("Phase too new (%d bars) - waiting for stability", m_currentPhase.phaseDurationBars);
            return false;
        }
        
        switch(m_currentPhase.phase)
        {
            case MM_PHASE_POSITION_BUILDING:
                reason = StringFormat("BLOCKED: Position Building phase detected (Variance: %.3f, Efficiency: %.3f)", 
                                    m_currentPhase.volumeVariance, m_currentPhase.priceEfficiency);
                m_tradesBlockedByPhase++;
                return false;
                
            case MM_PHASE_RUN_FOR_PROFITS:
                reason = StringFormat("APPROVED: Run for Profits phase (Variance: %.3f, Efficiency: %.3f)", 
                                    m_currentPhase.volumeVariance, m_currentPhase.priceEfficiency);
                m_tradesApprovedByPhase++;
                return true;
                
            case MM_PHASE_TRANSITION:
                reason = "CAUTION: Market in transition phase - recommend waiting";
                return false;
                
            default:
                reason = "Unknown MM phase - insufficient data";
                return false;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Store Phase History                                             |
    //+------------------------------------------------------------------+
    void StorePhaseHistory(const SMarketMakerPhase &phase)
    {
        m_phaseHistory[m_historyIndex] = phase;
        m_historyIndex = (m_historyIndex + 1) % ArraySize(m_phaseHistory);
    }
    
    //+------------------------------------------------------------------+
    //| Get Current Phase Information                                   |
    //+------------------------------------------------------------------+
    SMarketMakerPhase GetCurrentPhase() const
    {
        return m_currentPhase;
    }
    
    //+------------------------------------------------------------------+
    //| Get Phase Statistics                                            |
    //+------------------------------------------------------------------+
    void GetPhaseStatistics(int &positionBuilding, int &runForProfits, 
                           int &tradesBlocked, int &tradesApproved)
    {
        positionBuilding = m_positionBuildingDetected;
        runForProfits = m_runForProfitsDetected;
        tradesBlocked = m_tradesBlockedByPhase;
        tradesApproved = m_tradesApprovedByPhase;
    }
    
    //+------------------------------------------------------------------+
    //| Get Trading Recommendation                                      |
    //+------------------------------------------------------------------+
    string GetTradingRecommendation()
    {
        switch(m_currentPhase.phase)
        {
            case MM_PHASE_POSITION_BUILDING:
                return "❌ AVOID TRADING - Market makers building positions";
                
            case MM_PHASE_RUN_FOR_PROFITS:
                return "✅ TRADE RECOMMENDED - Directional movement phase";
                
            case MM_PHASE_TRANSITION:
                return "⏳ WAIT - Phase transition in progress";
                
            default:
                return "❓ UNKNOWN - Insufficient data for analysis";
        }
    }
    
    //+------------------------------------------------------------------+
    //| Reset Statistics                                                |
    //+------------------------------------------------------------------+
    void ResetStatistics()
    {
        m_positionBuildingDetected = 0;
        m_runForProfitsDetected = 0;
        m_tradesBlockedByPhase = 0;
        m_tradesApprovedByPhase = 0;
    }
};

// Global Market Maker Phase Detector instance
CMarketMakerPhaseDetector g_MarketMakerPhaseDetector;

//+------------------------------------------------------------------+
//| Helper Functions for Integration                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Quick MM Phase Validation                                        |
//+------------------------------------------------------------------+
bool IsMarketMakerPhaseGoodForTrading(string &explanation)
{
    return g_MarketMakerPhaseDetector.ValidateTradeByPhase(SIGNAL_BUY, explanation);
}

//+------------------------------------------------------------------+
//| Get Current MM Phase for Dashboard                               |
//+------------------------------------------------------------------+
string GetCurrentMarketMakerPhaseStatus()
{
    return g_MarketMakerPhaseDetector.GetTradingRecommendation();
}

#endif // MARKET_MAKER_PHASE_DETECTOR_MQH

//+------------------------------------------------------------------+
//| END OF MARKET MAKER PHASE DETECTOR                              |
//+------------------------------------------------------------------+
