//+------------------------------------------------------------------+
//|                                   03_MarketAnalysis_01_DragonAngle_Enforcer.mqh |
//|                                             Dragon Angle Threshold Enforcement |
//|                          Implements precise angle-based trade filtering system |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Development Team"
#property version   "1.00"
#property strict

#ifndef DRAGON_ANGLE_ENFORCER_MQH
#define DRAGON_ANGLE_ENFORCER_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_14_CoreEnums.mqh"

//+------------------------------------------------------------------+
//| Dragon Angle Classification Enum                                 |
//+------------------------------------------------------------------+
enum ENUM_DRAGON_MOMENTUM_CLASS
{
    DRAGON_MOMENTUM_WEAK = 0,      // 0-1 degrees - AVOID TRADING
    DRAGON_MOMENTUM_MODERATE = 1,   // 1-2 degrees - CAUTION REQUIRED  
    DRAGON_MOMENTUM_STRONG = 2,     // 2-4 degrees - GOOD FOR TRADING
    DRAGON_MOMENTUM_VERY_STRONG = 3 // 4+ degrees - POTENTIAL CLIMAX
};

//+------------------------------------------------------------------+
//| Dragon Angle Threshold Configuration                             |
//+------------------------------------------------------------------+
struct SDragonAngleConfig
{
    double weakThreshold;        // Weak momentum upper limit (degrees)
    double moderateThreshold;    // Moderate momentum upper limit (degrees)  
    double strongThreshold;      // Strong momentum upper limit (degrees)
    double climaxThreshold;      // Very strong momentum threshold (degrees)
    bool   enforceThresholds;    // Enable/disable angle enforcement
    bool   allowModerateEntry;   // Allow trades in moderate momentum
    bool   blockWeakMomentum;    // Block all weak momentum trades
    double positionScaling;      // Position size scaling for strong momentum
};

//+------------------------------------------------------------------+
//| Dragon Angle Enforcer Class                                     |
//+------------------------------------------------------------------+
class CDragonAngleEnforcer
{
private:
    SDragonAngleConfig m_config;
    double m_lastAngle;
    ENUM_DRAGON_MOMENTUM_CLASS m_currentMomentumClass;
    datetime m_lastCalculationTime;
    bool m_isInitialized;
    
    // Performance tracking
    int m_weakSignalsBlocked;
    int m_moderateSignalsWarned;
    int m_strongSignalsApproved;
    int m_climaxSignalsDetected;
    
public:
    CDragonAngleEnforcer()
    {
        InitializeDefaults();
    }
    
    //+------------------------------------------------------------------+
    //| Initialize Default Configuration                                 |
    //+------------------------------------------------------------------+
    void InitializeDefaults()
    {
        m_config.weakThreshold = 1.0;      // 0-1 degrees = weak
        m_config.moderateThreshold = 2.0;  // 1-2 degrees = moderate
        m_config.strongThreshold = 4.0;    // 2-4 degrees = strong  
        m_config.climaxThreshold = 4.0;    // 4+ degrees = very strong
        m_config.enforceThresholds = true;
        m_config.allowModerateEntry = false; // Conservative default
        m_config.blockWeakMomentum = true;
        m_config.positionScaling = 1.2; // 20% increase for strong momentum
        
        m_lastAngle = 0.0;
        m_currentMomentumClass = DRAGON_MOMENTUM_WEAK;
        m_lastCalculationTime = 0;
        m_isInitialized = true;
        
        // Reset performance counters
        m_weakSignalsBlocked = 0;
        m_moderateSignalsWarned = 0;
        m_strongSignalsApproved = 0;
        m_climaxSignalsDetected = 0;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Dragon Angle (Strategy-Compliant Method)              |
    //+------------------------------------------------------------------+
    double CalculateDragonAngle(const double &ema_close[], int periods = 5)
    {
        if(ArraySize(ema_close) < periods + 1)
            return 0.0;
            
        // Strategy formula: arctan((EMA_Close(t) - EMA_Close(t-n)) / n) × 180 / π
        double currentEMA = ema_close[0];
        double previousEMA = ema_close[periods];
        
        if(previousEMA == 0.0) return 0.0;
        
        double slope = (currentEMA - previousEMA) / periods;
        double angleRadians = MathArctan(slope);
        double angleDegrees = angleRadians * 180.0 / M_PI;
        
        m_lastAngle = MathAbs(angleDegrees); // Use absolute value for classification
        m_lastCalculationTime = TimeCurrent();
        
        return angleDegrees; // Return signed angle for directional analysis
    }
    
    //+------------------------------------------------------------------+
    //| Classify Dragon Momentum Based on Angle                         |
    //+------------------------------------------------------------------+
    ENUM_DRAGON_MOMENTUM_CLASS ClassifyMomentum(double angle)
    {
        double absAngle = MathAbs(angle);
        
        if(absAngle <= m_config.weakThreshold)
            return DRAGON_MOMENTUM_WEAK;
        else if(absAngle <= m_config.moderateThreshold)
            return DRAGON_MOMENTUM_MODERATE;
        else if(absAngle <= m_config.strongThreshold)
            return DRAGON_MOMENTUM_STRONG;
        else
            return DRAGON_MOMENTUM_VERY_STRONG;
    }
    
    //+------------------------------------------------------------------+
    //| Validate Trade Entry Based on Dragon Angle                      |
    //+------------------------------------------------------------------+
    bool ValidateTradeEntry(double dragonAngle, ENUM_SIGNAL_TYPE signalType, string &reason)
    {
        if(!m_config.enforceThresholds)
        {
            reason = "Dragon angle enforcement disabled";
            return true;
        }
        
        m_currentMomentumClass = ClassifyMomentum(dragonAngle);
        
        switch(m_currentMomentumClass)
        {
            case DRAGON_MOMENTUM_WEAK:
                if(m_config.blockWeakMomentum)
                {
                    reason = StringFormat("BLOCKED: Weak momentum (%.2f°) - Strategy requires ≥%.1f° for trading", 
                                        MathAbs(dragonAngle), m_config.weakThreshold);
                    m_weakSignalsBlocked++;
                    return false;
                }
                break;
                
            case DRAGON_MOMENTUM_MODERATE:
                if(!m_config.allowModerateEntry)
                {
                    reason = StringFormat("CAUTION: Moderate momentum (%.2f°) - Entry not recommended", 
                                        MathAbs(dragonAngle));
                    m_moderateSignalsWarned++;
                    return false;
                }
                reason = StringFormat("MODERATE: Acceptable momentum (%.2f°) with caution", MathAbs(dragonAngle));
                break;
                
            case DRAGON_MOMENTUM_STRONG:
                reason = StringFormat("APPROVED: Strong momentum (%.2f°) - Good for trading", MathAbs(dragonAngle));
                m_strongSignalsApproved++;
                return true;
                
            case DRAGON_MOMENTUM_VERY_STRONG:
                reason = StringFormat("CLIMAX: Very strong momentum (%.2f°) - Potential climax warning", 
                                    MathAbs(dragonAngle));
                m_climaxSignalsDetected++;
                return true; // Allow but with warning
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Get Position Size Scaling Based on Dragon Angle                 |
    //+------------------------------------------------------------------+
    double GetPositionSizeMultiplier(double dragonAngle)
    {
        ENUM_DRAGON_MOMENTUM_CLASS momentumClass = ClassifyMomentum(dragonAngle);
        
        switch(momentumClass)
        {
            case DRAGON_MOMENTUM_WEAK:
                return 0.5; // Reduced size for weak momentum (if allowed)
                
            case DRAGON_MOMENTUM_MODERATE:
                return 0.8; // Slightly reduced size for caution
                
            case DRAGON_MOMENTUM_STRONG:
                return m_config.positionScaling; // Enhanced size for strong momentum
                
            case DRAGON_MOMENTUM_VERY_STRONG:
                return 1.0; // Normal size due to climax risk
        }
        
        return 1.0; // Default multiplier
    }
    
    //+------------------------------------------------------------------+
    //| Get Momentum Class Description                                   |
    //+------------------------------------------------------------------+
    string GetMomentumClassDescription(ENUM_DRAGON_MOMENTUM_CLASS momentumClass)
    {
        switch(momentumClass)
        {
            case DRAGON_MOMENTUM_WEAK:      return "WEAK (Range/Consolidation)";
            case DRAGON_MOMENTUM_MODERATE:  return "MODERATE (Building Momentum)"; 
            case DRAGON_MOMENTUM_STRONG:    return "STRONG (Trending Market)";
            case DRAGON_MOMENTUM_VERY_STRONG: return "VERY STRONG (Climax Risk)";
        }
        return "UNKNOWN";
    }
    
    //+------------------------------------------------------------------+
    //| Update Configuration                                             |
    //+------------------------------------------------------------------+
    void UpdateConfiguration(SDragonAngleConfig &newConfig)
    {
        m_config = newConfig;
    }
    
    //+------------------------------------------------------------------+
    //| Get Current Momentum Statistics                                  |
    //+------------------------------------------------------------------+
    void GetMomentumStatistics(int &weakBlocked, int &moderateWarned, 
                              int &strongApproved, int &climaxDetected)
    {
        weakBlocked = m_weakSignalsBlocked;
        moderateWarned = m_moderateSignalsWarned;
        strongApproved = m_strongSignalsApproved;
        climaxDetected = m_climaxSignalsDetected;
    }
    
    //+------------------------------------------------------------------+
    //| Get Dragon Angle Trading Recommendation                         |
    //+------------------------------------------------------------------+
    string GetTradingRecommendation(double angle)
    {
        ENUM_DRAGON_MOMENTUM_CLASS momentumClass = ClassifyMomentum(angle);
        
        switch(momentumClass)
        {
            case DRAGON_MOMENTUM_WEAK:
                return "❌ AVOID TRADING - Wait for stronger momentum";
                
            case DRAGON_MOMENTUM_MODERATE:
                return "⚠️ CAUTION - Consider waiting for confirmation";
                
            case DRAGON_MOMENTUM_STRONG:
                return "✅ GOOD TO TRADE - Strong momentum detected";
                
            case DRAGON_MOMENTUM_VERY_STRONG:
                return "🔥 VERY STRONG - Watch for climax/reversal signs";
        }
        
        return "❓ UNKNOWN MOMENTUM";
    }
    
    //+------------------------------------------------------------------+
    //| Reset Performance Counters                                      |
    //+------------------------------------------------------------------+
    void ResetCounters()
    {
        m_weakSignalsBlocked = 0;
        m_moderateSignalsWarned = 0;
        m_strongSignalsApproved = 0;
        m_climaxSignalsDetected = 0;
    }
    
    //+------------------------------------------------------------------+
    //| Get Last Calculated Angle                                       |
    //+------------------------------------------------------------------+
    double GetLastAngle() const { return m_lastAngle; }
    
    //+------------------------------------------------------------------+
    //| Get Current Momentum Class                                       |
    //+------------------------------------------------------------------+
    ENUM_DRAGON_MOMENTUM_CLASS GetCurrentMomentumClass() const 
    { 
        return m_currentMomentumClass; 
    }
    
    //+------------------------------------------------------------------+
    //| Check if Angle Calculation is Fresh                             |
    //+------------------------------------------------------------------+
    bool IsAngleDataFresh(int maxAgeSeconds = 60)
    {
        return (TimeCurrent() - m_lastCalculationTime) <= maxAgeSeconds;
    }
};

// Global Dragon Angle Enforcer instance
CDragonAngleEnforcer g_DragonAngleEnforcer;

//+------------------------------------------------------------------+
//| Helper Functions for Integration                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Quick Dragon Angle Validation Function                          |
//+------------------------------------------------------------------+
bool IsDragonAngleSufficientForTrading(double angle, string &explanation)
{
    return g_DragonAngleEnforcer.ValidateTradeEntry(angle, SIGNAL_BUY, explanation);
}

//+------------------------------------------------------------------+
//| Get Dragon Momentum Based Position Size Adjustment              |
//+------------------------------------------------------------------+
double GetDragonMomentumPositionMultiplier(double angle)
{
    return g_DragonAngleEnforcer.GetPositionSizeMultiplier(angle);
}

//+------------------------------------------------------------------+
//| Get Current Dragon Trading Status for Dashboard                 |
//+------------------------------------------------------------------+
string GetDragonTradingStatus(double currentAngle)
{
    return g_DragonAngleEnforcer.GetTradingRecommendation(currentAngle);
}

#endif // DRAGON_ANGLE_ENFORCER_MQH

//+------------------------------------------------------------------+
//| END OF DRAGON ANGLE ENFORCER                                    |
//+------------------------------------------------------------------+
