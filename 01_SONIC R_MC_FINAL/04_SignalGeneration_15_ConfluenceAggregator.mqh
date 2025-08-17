//+------------------------------------------------------------------+
//|                              ConfluenceAggregator.mqh            |
//|                        Sonic R MC - Signal Aggregation           |
//|                    PHASE 2: Confluence Scoring & Aggregation     |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC - Đại Bàng"
#property version   "1.00"

#ifndef CONFLUENCE_AGGREGATOR_MQH
#define CONFLUENCE_AGGREGATOR_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| Signal Component Structure                                       |
//+------------------------------------------------------------------+
struct SSignalComponent
{
    string name;                // Component name (Dragon, Wave, PVSRA, SMC)
    double score;               // Raw score 0-1
    double weight;              // Weight in final calculation
    double contribution;        // weight * score
    bool isActive;             // Whether component is active
    string details;            // Additional details
};

//+------------------------------------------------------------------+
//| Aggregated Signal Result                                         |
//+------------------------------------------------------------------+
struct SAggregatedSignal
{
    ENUM_SIGNAL_TYPE signalType;
    double totalScore;
    double confidence;
    int componentCount;
    SSignalComponent components[10];  // Max 10 components
    datetime timestamp;
    string reasoning;
    bool isValid;
};

//+------------------------------------------------------------------+
//| Confluence Aggregator Class                                      |
//+------------------------------------------------------------------+
class CConfluenceAggregator
{
private:
    // Component weights (configurable)
    double m_dragonWeight;
    double m_waveWeight;
    double m_pvsraWeight;
    double m_smcWeight;
    double m_srWeight;
    double m_momentumWeight;
    double m_volumeWeight;
    double m_trendWeight;
    
    // Thresholds
    double m_minScore;
    double m_strongSignalThreshold;
    
    // State
    SAggregatedSignal m_lastSignal;
    bool m_initialized;
    
public:
    //+------------------------------------------------------------------+
    //| Constructor                                                       |
    //+------------------------------------------------------------------+
    CConfluenceAggregator()
    {
        // Initialize weights (total = 100%)
        m_dragonWeight = 0.25;      // 25% - Dragon Band
        m_waveWeight = 0.20;        // 20% - Wave Pattern
        m_pvsraWeight = 0.20;       // 20% - PVSRA
        m_smcWeight = 0.15;         // 15% - SMC
        m_srWeight = 0.10;          // 10% - Support/Resistance
        m_momentumWeight = 0.05;    // 5% - Momentum
        m_volumeWeight = 0.03;      // 3% - Volume
        m_trendWeight = 0.02;       // 2% - Trend
        
        // Thresholds
        m_minScore = 0.60;          // Minimum 60% for valid signal
        m_strongSignalThreshold = 0.75; // 75%+ is strong signal
        
        m_initialized = true;
    }
    
    //+------------------------------------------------------------------+
    //| Aggregate multiple signal components                             |
    //+------------------------------------------------------------------+
    SAggregatedSignal AggregateSignals(
        double dragonScore,
        double waveScore,
        double pvsraScore,
        double smcScore,
        double srScore,
        double momentumScore,
        double volumeScore,
        double trendScore,
        ENUM_SIGNAL_TYPE baseSignal
    )
    {
        SAggregatedSignal result;
        result.signalType = baseSignal;
        result.timestamp = TimeCurrent();
        result.componentCount = 0;
        result.totalScore = 0.0;
        
        // Add Dragon Band component
        if(dragonScore >= 0) {
            AddComponent(result, "Dragon Band", dragonScore, m_dragonWeight);
        }
        
        // Add Wave Pattern component
        if(waveScore >= 0) {
            AddComponent(result, "Wave Pattern", waveScore, m_waveWeight);
        }
        
        // Add PVSRA component
        if(pvsraScore >= 0) {
            AddComponent(result, "PVSRA", pvsraScore, m_pvsraWeight);
        }
        
        // Add SMC component
        if(smcScore >= 0) {
            AddComponent(result, "SMC", smcScore, m_smcWeight);
        }
        
        // Add S/R component
        if(srScore >= 0) {
            AddComponent(result, "Support/Resistance", srScore, m_srWeight);
        }
        
        // Add Momentum component
        if(momentumScore >= 0) {
            AddComponent(result, "Momentum", momentumScore, m_momentumWeight);
        }
        
        // Add Volume component
        if(volumeScore >= 0) {
            AddComponent(result, "Volume", volumeScore, m_volumeWeight);
        }
        
        // Add Trend component
        if(trendScore >= 0) {
            AddComponent(result, "Trend", trendScore, m_trendWeight);
        }
        
        // Calculate total score (normalize if needed)
        result.totalScore = CalculateTotalScore(result);
        
        // Calculate confidence based on component agreement
        result.confidence = CalculateConfidence(result);
        
        // Validate signal
        result.isValid = ValidateSignal(result);
        
        // Generate reasoning
        result.reasoning = GenerateReasoning(result);
        
        // Store last signal
        m_lastSignal = result;
        
        return result;
    }
    
    //+------------------------------------------------------------------+
    //| Process signals with filtering                                   |
    //+------------------------------------------------------------------+
    bool ProcessSignals(SAggregatedSignal& signal)
    {
        // Apply additional filters
        if(!CheckSpreadFilter()) return false;
        if(!CheckTimeFilter()) return false;
        if(!CheckVolumeFilter()) return false;
        
        // Check minimum score
        if(signal.totalScore < m_minScore) {
            Print(StringFormat("[AGGREGATOR] Signal rejected - Score %.2f < Min %.2f", 
                signal.totalScore, m_minScore));
            return false;
        }
        
        // All checks passed
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Get confluence score for specific signal                         |
    //+------------------------------------------------------------------+
    double GetConfluenceScore(const SAggregatedSignal& signal)
    {
        return signal.totalScore;
    }
    
private:
    //+------------------------------------------------------------------+
    //| Add component to aggregated signal                               |
    //+------------------------------------------------------------------+
    void AddComponent(SAggregatedSignal& signal, string name, double score, double weight)
    {
        if(signal.componentCount >= 10) return;
        
        int idx = signal.componentCount;
        signal.components[idx].name = name;
        signal.components[idx].score = score;
        signal.components[idx].weight = weight;
        signal.components[idx].contribution = score * weight;
        signal.components[idx].isActive = (score > 0.5);
        signal.components[idx].details = StringFormat("%.1f%% (%.2fx%.2f)", 
            score * weight * 100, score, weight);
        
        signal.componentCount++;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate total weighted score                                   |
    //+------------------------------------------------------------------+
    double CalculateTotalScore(const SAggregatedSignal& signal)
    {
        double totalScore = 0.0;
        double totalWeight = 0.0;
        
        for(int i = 0; i < signal.componentCount; i++) {
            totalScore += signal.components[i].contribution;
            totalWeight += signal.components[i].weight;
        }
        
        // Normalize if weights don't sum to 1.0
        if(totalWeight > 0 && totalWeight != 1.0) {
            totalScore = totalScore / totalWeight;
        }
        
        return MathMin(1.0, totalScore);
    }
    
    //+------------------------------------------------------------------+
    //| Calculate confidence based on component agreement                |
    //+------------------------------------------------------------------+
    double CalculateConfidence(const SAggregatedSignal& signal)
    {
        if(signal.componentCount == 0) return 0.0;
        
        int activeComponents = 0;
        double scoreSum = 0.0;
        double scoreSquareSum = 0.0;
        
        for(int i = 0; i < signal.componentCount; i++) {
            if(signal.components[i].isActive) activeComponents++;
            scoreSum += signal.components[i].score;
            scoreSquareSum += signal.components[i].score * signal.components[i].score;
        }
        
        // Calculate variance
        double mean = scoreSum / signal.componentCount;
        double variance = (scoreSquareSum / signal.componentCount) - (mean * mean);
        
        // Lower variance = higher confidence
        double confidence = 1.0 - MathSqrt(variance);
        
        // Boost confidence if many components agree
        double agreementBonus = (double)activeComponents / signal.componentCount * 0.2;
        confidence = MathMin(1.0, confidence + agreementBonus);
        
        return confidence;
    }
    
    //+------------------------------------------------------------------+
    //| Validate aggregated signal                                       |
    //+------------------------------------------------------------------+
    bool ValidateSignal(const SAggregatedSignal& signal)
    {
        // Check minimum components
        if(signal.componentCount < 3) return false;
        
        // Check minimum active components
        int activeCount = 0;
        for(int i = 0; i < signal.componentCount; i++) {
            if(signal.components[i].isActive) activeCount++;
        }
        if(activeCount < 2) return false;
        
        // Check minimum score
        if(signal.totalScore < m_minScore) return false;
        
        // Check confidence
        if(signal.confidence < 0.5) return false;
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Generate signal reasoning                                        |
    //+------------------------------------------------------------------+
    string GenerateReasoning(const SAggregatedSignal& signal)
    {
        string reasoning = StringFormat("Signal: %s | Score: %.1f%% | Confidence: %.1f%%\n",
            EnumToString(signal.signalType),
            signal.totalScore * 100,
            signal.confidence * 100);
        
        reasoning += "Components:\n";
        for(int i = 0; i < signal.componentCount; i++) {
            string status = signal.components[i].isActive ? "✓" : "✗";
            reasoning += StringFormat("  %s %s: %s\n",
                status,
                signal.components[i].name,
                signal.components[i].details);
        }
        
        if(signal.totalScore >= m_strongSignalThreshold) {
            reasoning += "★ STRONG SIGNAL ★";
        }
        
        return reasoning;
    }
    
    //+------------------------------------------------------------------+
    //| Filter functions                                                 |
    //+------------------------------------------------------------------+
    bool CheckSpreadFilter()
    {
        double spread = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - 
                        SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
        return spread <= 3.0; // Max 3 pips
    }
    
    bool CheckTimeFilter()
    {
        MqlDateTime time;
        TimeToStruct(TimeCurrent(), time);
        
        // Avoid Asian session low liquidity
        if(time.hour >= 0 && time.hour < 7) return false;
        
        return true;
    }
    
    bool CheckVolumeFilter()
    {
        // Check if volume is sufficient
        long volume = iVolume(_Symbol, PERIOD_CURRENT, 0);
        long avgVolume = 0;
        
        for(int i = 1; i <= 20; i++) {
            avgVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
        }
        avgVolume /= 20;
        
        return volume >= avgVolume * 0.5; // At least 50% of average
    }
    
public:
    //+------------------------------------------------------------------+
    //| Getters                                                          |
    //+------------------------------------------------------------------+
    SAggregatedSignal GetLastSignal() { return m_lastSignal; }
    bool IsInitialized() { return m_initialized; }
    double GetMinScore() { return m_minScore; }
    double GetStrongThreshold() { return m_strongSignalThreshold; }
    
    //+------------------------------------------------------------------+
    //| Setters for dynamic adjustment                                   |
    //+------------------------------------------------------------------+
    void SetMinScore(double score) { m_minScore = MathMax(0.0, MathMin(1.0, score)); }
    void SetStrongThreshold(double threshold) { m_strongSignalThreshold = MathMax(0.0, MathMin(1.0, threshold)); }
    
    //+------------------------------------------------------------------+
    //| Adjust weights dynamically                                       |
    //+------------------------------------------------------------------+
    void AdjustWeights(double dragon, double wave, double pvsra, double smc)
    {
        double total = dragon + wave + pvsra + smc;
        if(total <= 0) return;
        
        // Normalize to keep total = 1.0
        m_dragonWeight = dragon / total * 0.8;  // 80% for main components
        m_waveWeight = wave / total * 0.8;
        m_pvsraWeight = pvsra / total * 0.8;
        m_smcWeight = smc / total * 0.8;
        
        // Keep 20% for auxiliary components
        // Already set in constructor
    }
};

#endif // CONFLUENCE_AGGREGATOR_MQH
