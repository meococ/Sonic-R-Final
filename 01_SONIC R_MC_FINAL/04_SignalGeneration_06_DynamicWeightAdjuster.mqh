//+------------------------------------------------------------------+
//| ?? DYNAMIC WEIGHT ADJUSTER                                      |
//| Ði?u ch?nh tr?ng s? thông minh cho các chuyên gia               |
//+------------------------------------------------------------------+
#property copyright "Sonic R_MC"
#property version   "1.00"
#property strict

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| ?? PERFORMANCE TRACKING STRUCTURES                              |
//+------------------------------------------------------------------+
struct SComponentPerformance
{
    string componentName;           // Tên component
    double accuracy;               // Ð? chính xác (0.0 - 1.0)
    double reliability;            // Ð? tin c?y (0.0 - 1.0)
    double consistency;            // Tính nh?t quán (0.0 - 1.0)
    int totalSignals;             // T?ng s? tín hi?u
    int correctSignals;           // S? tín hi?u dúng
    int falsePositives;           // Tín hi?u sai (false positive)
    int falseNegatives;           // B? l? tín hi?u (false negative)
    double avgResponseTime;       // Th?i gian ph?n h?i trung bình
    datetime lastUpdate;          // L?n c?p nh?t cu?i
    double recentPerformance[10]; // Hi?u su?t 10 l?n g?n nh?t
    int recentIndex;              // Index cho m?ng recent
    
    void Reset()
    {
        componentName = "";
        accuracy = 0.5;
        reliability = 0.5;
        consistency = 0.5;
        totalSignals = 0;
        correctSignals = 0;
        falsePositives = 0;
        falseNegatives = 0;
        avgResponseTime = 0.0;
        lastUpdate = 0;
        ArrayInitialize(recentPerformance, 0.5);
        recentIndex = 0;
    }
    
    void UpdatePerformance(bool wasCorrect, double responseTime)
    {
        totalSignals++;
        if(wasCorrect) correctSignals++;
        else falsePositives++;
        
        // Update accuracy
        accuracy = (totalSignals > 0) ? (double)correctSignals / totalSignals : 0.5;
        
        // Update response time
        avgResponseTime = (avgResponseTime * (totalSignals - 1) + responseTime) / totalSignals;
        
        // Update recent performance
        recentPerformance[recentIndex] = wasCorrect ? 1.0 : 0.0;
        recentIndex = (recentIndex + 1) % 10;
        
        // Calculate consistency (based on recent performance)
        double recentSum = 0.0;
        for(int i = 0; i < 10; i++) {
            recentSum += recentPerformance[i];
        }
        consistency = recentSum / 10.0;
        
        // Calculate reliability (combination of accuracy and consistency)
        reliability = (accuracy * 0.7 + consistency * 0.3);
        
        lastUpdate = TimeCurrent();
    }
};

//+------------------------------------------------------------------+
//| ?? MARKET CONTEXT STRUCTURES                                    |
//+------------------------------------------------------------------+
struct SMarketContext
{
    ENUM_MARKET_REGIME regime;      // Ch? d? th? tru?ng
    ENUM_TREND_DIRECTION trend;     // Hu?ng xu hu?ng
    double volatility;              // Ð? bi?n d?ng
    double volume;                  // Kh?i lu?ng
    ENUM_TRADING_SESSION session;   // Phiên giao d?ch
    bool isNewsTime;               // Có ph?i th?i gian tin t?c
    double marketStrength;         // S?c m?nh th? tru?ng
    
    void Reset()
    {
        regime = REGIME_RANGING;
        trend = TREND_SIDEWAYS;
        volatility = 0.5;
        volume = 0.5;
        session = SESSION_ASIAN;
        isNewsTime = false;
        marketStrength = 0.5;
    }
};

//+------------------------------------------------------------------+
//| ?? WEIGHT ADJUSTMENT STRATEGIES                                 |
//+------------------------------------------------------------------+
// ENUM_WEIGHT_STRATEGY moved to SonicEnums.mqh for proper include order

//+------------------------------------------------------------------+
//| ?? DYNAMIC WEIGHT ADJUSTER CLASS                               |
//+------------------------------------------------------------------+
class CDynamicWeightAdjuster
{
private:
    // Performance tracking
    SComponentPerformance m_componentPerformance[4]; // Dragon, Wave, Structure, PVSRA
    SMarketContext m_marketContext;
    
    // Weight management
    double m_currentWeights[4];     // Tr?ng s? hi?n t?i
    double m_baseWeights[4];        // Tr?ng s? co b?n
    double m_minWeights[4];         // Tr?ng s? t?i thi?u
    double m_maxWeights[4];         // Tr?ng s? t?i da
    
    // Configuration
    ENUM_WEIGHT_STRATEGY m_strategy;
    double m_adaptationRate;        // T?c d? thích ?ng (0.0 - 1.0)
    double m_performanceThreshold;  // Ngu?ng hi?u su?t
    bool m_enableAdaptation;        // B?t/t?t thích ?ng
    
    // Statistics
    int m_adjustmentCount;
    datetime m_lastAdjustment;
    double m_totalAdjustment;
    
public:
    CDynamicWeightAdjuster()
    {
        // Initialize base weights
        m_baseWeights[0] = 0.30; // Dragon Band - 30%
        m_baseWeights[1] = 0.25; // Wave Pattern - 25%
        m_baseWeights[2] = 0.25; // Market Structure - 25%
        m_baseWeights[3] = 0.20; // PVSRA - 20%
        
        // Set weight limits
        m_minWeights[0] = 0.15; m_maxWeights[0] = 0.45; // Dragon: 15-45%
        m_minWeights[1] = 0.10; m_maxWeights[1] = 0.40; // Wave: 10-40%
        m_minWeights[2] = 0.10; m_maxWeights[2] = 0.40; // Structure: 10-40%
        m_minWeights[3] = 0.05; m_maxWeights[3] = 0.35; // PVSRA: 5-35%
        
        // Copy base to current
        ArrayCopy(m_currentWeights, m_baseWeights);
        
        // Initialize configuration
        m_strategy = WEIGHT_HYBRID;
        m_adaptationRate = 0.1; // 10% adaptation rate
        m_performanceThreshold = 0.6;
        m_enableAdaptation = true;
        
        // Initialize statistics
        m_adjustmentCount = 0;
        m_lastAdjustment = 0;
        m_totalAdjustment = 0.0;
        
        // Initialize performance tracking
        for(int i = 0; i < 4; i++) {
            m_componentPerformance[i].Reset();
        }
        m_componentPerformance[0].componentName = "DragonBand";
        m_componentPerformance[1].componentName = "WavePattern";
        m_componentPerformance[2].componentName = "Structure";
        m_componentPerformance[3].componentName = "PVSRA";
        
        m_marketContext.Reset();
        
        Print("?? Dynamic Weight Adjuster initialized");
    }
    
    //+------------------------------------------------------------------+
    //| ?? INITIALIZATION                                               |
    //+------------------------------------------------------------------+
    bool Initialize()
    {
        Print("?? Initializing Dynamic Weight Adjuster");
        
        // Validate configuration
        if(!ValidateConfiguration()) {
            Print("? Invalid configuration for Dynamic Weight Adjuster");
            return false;
        }
        
        Print("? Dynamic Weight Adjuster initialized successfully");
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| ?? PERFORMANCE TRACKING                                         |
    //+------------------------------------------------------------------+
    void UpdateComponentPerformance(int componentIndex, bool wasCorrect, double responseTime = 0.0)
    {
        if(componentIndex < 0 || componentIndex >= 4) return;
        
        m_componentPerformance[componentIndex].UpdatePerformance(wasCorrect, responseTime);
        
        // Trigger weight adjustment if needed
        if(m_enableAdaptation) {
            CheckAndAdjustWeights();
        }
    }
    
    void UpdateMarketContext(ENUM_MARKET_REGIME regime, ENUM_TREND_DIRECTION trend, 
                           double volatility, double volume = 0.5)
    {
        m_marketContext.regime = regime;
        m_marketContext.trend = trend;
        m_marketContext.volatility = volatility;
        m_marketContext.volume = volume;
        m_marketContext.session = GetCurrentTradingSession();
        m_marketContext.isNewsTime = IsNewsTime();
        m_marketContext.marketStrength = CalculateMarketStrength();
        
        // Trigger weight adjustment for market changes
        if(m_enableAdaptation) {
            CheckAndAdjustWeights();
        }
    }
    
    //+------------------------------------------------------------------+
    //| ?? WEIGHT ADJUSTMENT LOGIC                                      |
    //+------------------------------------------------------------------+
    void CheckAndAdjustWeights()
    {
        if(!m_enableAdaptation) return;
        
        // Check if adjustment is needed
        if(!ShouldAdjustWeights()) return;
        
        double newWeights[4];
        ArrayCopy(newWeights, m_currentWeights);
        
        switch(m_strategy) {
            case WEIGHT_PERFORMANCE_BASED:
                AdjustByPerformance(newWeights);
                break;
                
            case WEIGHT_MARKET_ADAPTIVE:
                AdjustByMarketContext(newWeights);
                break;
                
            case WEIGHT_HYBRID:
                AdjustByHybridMethod(newWeights);
                break;
                
            case WEIGHT_CONSERVATIVE:
                AdjustConservatively(newWeights);
                break;
                
            case WEIGHT_AGGRESSIVE:
                AdjustAggressively(newWeights);
                break;
        }
        
        // Apply adjustments with rate limiting
        ApplyWeightAdjustments(newWeights);
        
        m_adjustmentCount++;
        m_lastAdjustment = TimeCurrent();
        
        Print("?? [WEIGHT ADJUSTER] Weights adjusted: Dragon=", DoubleToString(m_currentWeights[0]*100, 1),
              "% Wave=", DoubleToString(m_currentWeights[1]*100, 1),
              "% Structure=", DoubleToString(m_currentWeights[2]*100, 1),
              "% PVSRA=", DoubleToString(m_currentWeights[3]*100, 1), "%");
    }
    
    //+------------------------------------------------------------------+
    //| ?? ADJUSTMENT STRATEGIES                                        |
    //+------------------------------------------------------------------+
    void AdjustByPerformance(double &weights[])
    {
        // Tang tr?ng s? cho component có hi?u su?t t?t
        for(int i = 0; i < 4; i++) {
            double performance = m_componentPerformance[i].reliability;
            
            if(performance > 0.7) {
                // Hi?u su?t t?t - tang tr?ng s?
                weights[i] += (performance - 0.7) * m_adaptationRate;
            } else if(performance < 0.4) {
                // Hi?u su?t kém - gi?m tr?ng s?
                weights[i] -= (0.4 - performance) * m_adaptationRate;
            }
        }
    }
    
    void AdjustByMarketContext(double &weights[])
    {
        // Ði?u ch?nh d?a trên di?u ki?n th? tru?ng
        if(m_marketContext.regime == REGIME_TRENDING_BULLISH || m_marketContext.regime == REGIME_TRENDING_BEARISH) {
            // Th? tru?ng trending - tang tr?ng s? Dragon và Structure
            weights[0] += 0.05; // Dragon Band
            weights[2] += 0.03; // Structure
            weights[1] -= 0.04; // Wave (ít hi?u qu? trong trending)
            weights[3] -= 0.04; // PVSRA
        } else if(m_marketContext.regime == REGIME_RANGING) {
            // Th? tru?ng ranging - tang tr?ng s? Wave và PVSRA
            weights[1] += 0.05; // Wave Pattern
            weights[3] += 0.03; // PVSRA
            weights[0] -= 0.04; // Dragon Band
            weights[2] -= 0.04; // Structure
        }
        
        // Ði?u ch?nh theo volatility
        if(m_marketContext.volatility > 0.7) {
            // High volatility - tang tr?ng s? Structure và PVSRA
            weights[2] += 0.03;
            weights[3] += 0.02;
            weights[0] -= 0.025;
            weights[1] -= 0.025;
        }
    }
    
    void AdjustByHybridMethod(double &weights[])
    {
        // K?t h?p performance và market context
        double performanceWeights[4];
        double marketWeights[4];
        
        ArrayCopy(performanceWeights, weights);
        ArrayCopy(marketWeights, weights);
        
        AdjustByPerformance(performanceWeights);
        AdjustByMarketContext(marketWeights);
        
        // K?t h?p v?i t? l? 60% performance, 40% market
        for(int i = 0; i < 4; i++) {
            weights[i] = weights[i] * 0.0 + performanceWeights[i] * 0.6 + marketWeights[i] * 0.4;
        }
    }
    
    void AdjustConservatively(double &weights[])
    {
        // Ði?u ch?nh nh? nhàng, uu tiên ?n d?nh
        double adjustmentFactor = m_adaptationRate * 0.5; // Gi?m t?c d? thích ?ng
        
        for(int i = 0; i < 4; i++) {
            double performance = m_componentPerformance[i].reliability;
            double deviation = performance - 0.5;
            weights[i] += deviation * adjustmentFactor;
        }
    }
    
    void AdjustAggressively(double &weights[])
    {
        // Ði?u ch?nh m?nh m?, ph?n ?ng nhanh
        double adjustmentFactor = m_adaptationRate * 2.0; // Tang t?c d? thích ?ng
        
        for(int i = 0; i < 4; i++) {
            double performance = m_componentPerformance[i].reliability;
            
            if(performance > 0.8) {
                weights[i] += 0.1; // Tang m?nh cho performance xu?t s?c
            } else if(performance < 0.3) {
                weights[i] -= 0.1; // Gi?m m?nh cho performance kém
            }
        }
    }
    
    //+------------------------------------------------------------------+
    //| ?? UTILITY FUNCTIONS                                           |
    //+------------------------------------------------------------------+
    void ApplyWeightAdjustments(double &newWeights[])
    {
        // Normalize weights to ensure sum = 1.0
        NormalizeWeights(newWeights);
        
        // Apply limits
        for(int i = 0; i < 4; i++) {
            newWeights[i] = MathMax(m_minWeights[i], MathMin(m_maxWeights[i], newWeights[i]));
        }
        
        // Re-normalize after applying limits
        NormalizeWeights(newWeights);
        
        // Apply with adaptation rate
        for(int i = 0; i < 4; i++) {
            double change = newWeights[i] - m_currentWeights[i];
            m_currentWeights[i] += change * m_adaptationRate;
            m_totalAdjustment += MathAbs(change);
        }
        
        // Final normalization
        NormalizeWeights(m_currentWeights);
    }
    
    void NormalizeWeights(double &weights[])
    {
        double sum = 0.0;
        for(int i = 0; i < 4; i++) {
            sum += weights[i];
        }
        
        if(sum > 0.0) {
            for(int i = 0; i < 4; i++) {
                weights[i] /= sum;
            }
        }
    }
    
    bool ShouldAdjustWeights()
    {
        // Check time since last adjustment
        if(TimeCurrent() - m_lastAdjustment < 300) return false; // Min 5 minutes
        
        // Check if any component has significant performance change
        for(int i = 0; i < 4; i++) {
            if(m_componentPerformance[i].totalSignals >= 5) {
                double performance = m_componentPerformance[i].reliability;
                if(performance > 0.8 || performance < 0.3) {
                    return true; // Significant performance detected
                }
            }
        }
        
        return false;
    }
    
    bool ValidateConfiguration()
    {
        // Check weight limits
        double minSum = 0.0, maxSum = 0.0;
        for(int i = 0; i < 4; i++) {
            minSum += m_minWeights[i];
            maxSum += m_maxWeights[i];
            if(m_minWeights[i] >= m_maxWeights[i]) return false;
        }
        
        return (minSum <= 1.0 && maxSum >= 1.0);
    }
    
    ENUM_TRADING_SESSION GetCurrentTradingSession()
    {
        // Simplified session detection
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        int hour = dt.hour;
        
        if(hour >= 0 && hour < 9) return SESSION_ASIAN;
        else if(hour >= 9 && hour < 17) return SESSION_LONDON;
        else return SESSION_NY;
    }
    
    bool IsNewsTime()
    {
        // Simplified news time detection
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        // Assume news times: 8:30, 10:00, 14:30, 16:00 GMT
        int minute = dt.hour * 60 + dt.min;
        int newsTimes[] = {510, 600, 870, 960}; // In minutes
        
        for(int i = 0; i < 4; i++) {
            if(MathAbs(minute - newsTimes[i]) <= 30) return true;
        }
        
        return false;
    }
    
    double CalculateMarketStrength()
    {
        // Simplified market strength calculation
        return (m_marketContext.volatility + m_marketContext.volume) / 2.0;
    }
    
    //+------------------------------------------------------------------+
    //| ?? GETTERS                                                      |
    //+------------------------------------------------------------------+
    void GetCurrentWeights(double &weights[])
    {
        ArrayCopy(weights, m_currentWeights);
    }
    
    double GetComponentWeight(int index)
    {
        if(index >= 0 && index < 4) return m_currentWeights[index];
        return 0.0;
    }
    
    SComponentPerformance GetComponentPerformance(int index)
    {
        if(index >= 0 && index < 4) return m_componentPerformance[index];
        SComponentPerformance empty;
        empty.Reset();
        return empty;
    }
    
    string GetAdjustmentReport()
    {
        return StringFormat(
            "?? Weight Adjuster Report:\n" +
            "Strategy: %s | Adjustments: %d | Total Change: %.3f\n" +
            "Dragon: %.1f%% (Perf: %.1f%%) | Wave: %.1f%% (Perf: %.1f%%)\n" +
            "Structure: %.1f%% (Perf: %.1f%%) | PVSRA: %.1f%% (Perf: %.1f%%)",
            WeightStrategyToString(m_strategy), m_adjustmentCount, m_totalAdjustment,
            m_currentWeights[0]*100, m_componentPerformance[0].reliability*100,
            m_currentWeights[1]*100, m_componentPerformance[1].reliability*100,
            m_currentWeights[2]*100, m_componentPerformance[2].reliability*100,
            m_currentWeights[3]*100, m_componentPerformance[3].reliability*100
        );
    }
    
    //+------------------------------------------------------------------+
    //| ?? CONFIGURATION                                               |
    //+------------------------------------------------------------------+
    void SetStrategy(ENUM_WEIGHT_STRATEGY strategy) { m_strategy = strategy; }
    void SetAdaptationRate(double rate) { m_adaptationRate = MathMax(0.01, MathMin(1.0, rate)); }
    void EnableAdaptation(bool enable) { m_enableAdaptation = enable; }
    void ResetToBaseWeights() { ArrayCopy(m_currentWeights, m_baseWeights); }
};