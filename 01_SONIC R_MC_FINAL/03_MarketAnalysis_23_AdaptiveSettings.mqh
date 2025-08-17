//+------------------------------------------------------------------+
//| PHASE 3: ADAPTIVE SETTINGS MANAGER                              |
//| Dynamically adjusts analysis thresholds based on market regime  |
//| Copyright 2024, Dai Bang Dev                                     |
//+------------------------------------------------------------------+
#ifndef ADAPTIVE_SETTINGS_MQH
#define ADAPTIVE_SETTINGS_MQH

//+------------------------------------------------------------------+
//| Adaptive Settings Structure                                      |
//+------------------------------------------------------------------+
struct SAdaptiveSettings {
    double dragonAngleThreshold;
    double volumeThreshold;
    double confluenceRequired;
    double signalStrengthMin;
    double atr_multiplier;
};

//+------------------------------------------------------------------+
//| Market Regime Enumeration - USE CORE DEFINITION                 |
//+------------------------------------------------------------------+
// PRODUCTION FIX: Removed duplicate ENUM_MARKET_REGIME enum
// Use comprehensive definition from 01_Core_22_SonicEnums.mqh instead
#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| Adaptive Settings Manager Class                                 |
//+------------------------------------------------------------------+
class CAdaptiveSettingsManager {
private:
    SAdaptiveSettings m_currentSettings;
    ENUM_MARKET_REGIME m_lastRegime;
    datetime m_lastUpdate;
    int m_regimeChangeCount;
    int m_adaptationCount;
    double m_averageVolatility;

public:
    CAdaptiveSettingsManager() {
        m_lastRegime = REGIME_UNDEFINED;
        m_lastUpdate = 0;
        m_regimeChangeCount = 0;
        m_adaptationCount = 0;
        m_averageVolatility = 0.0;
        InitializeDefaultSettings();
        UpdateSettings();
    }
    
    SAdaptiveSettings GetCurrentSettings() {
        if(TimeCurrent() - m_lastUpdate > 300 || ShouldForceUpdate()) {
            UpdateSettings();
        }
        return m_currentSettings;
    }
    
    double GetDynamicThreshold() {
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atr = 0.0;
        if(atrHandle != INVALID_HANDLE) {
            double atrBuffer[1];
            if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0) {
                atr = atrBuffer[0];
            }
            IndicatorRelease(atrHandle);
        }
        if(atr == EMPTY_VALUE || atr <= 0) return 2.0;
        
        double atrPips = atr / _Point;
        if(atrPips > 50) return 3.0;
        if(atrPips < 20) return 1.0;
        return 2.0;
    }
    
    ENUM_MARKET_REGIME GetCurrentRegime() {
        return m_lastRegime;
    }
    
    string GetRegimeReport() {
        return StringFormat("Regime: %s | Changes: %d | Adaptations: %d | Avg Volatility: %.1f pips",
                           EnumToString(m_lastRegime), 
                           m_regimeChangeCount,
                           m_adaptationCount,
                           m_averageVolatility / _Point);
    }

private:
    void InitializeDefaultSettings() {
        m_currentSettings.dragonAngleThreshold = 2.0;
        m_currentSettings.volumeThreshold = 1.5;
        m_currentSettings.confluenceRequired = 0.75;
        m_currentSettings.signalStrengthMin = 0.7;
        m_currentSettings.atr_multiplier = 1.0;
    }
    
    void UpdateSettings() {
        ENUM_MARKET_REGIME newRegime = DetectMarketRegime();
        
        if(newRegime != m_lastRegime && m_lastRegime != REGIME_UNDEFINED) {
            m_regimeChangeCount++;
        }
        
        m_lastRegime = newRegime;
        m_lastUpdate = TimeCurrent();
        m_adaptationCount++;
        
        switch(newRegime) {
            case REGIME_TRENDING:
                m_currentSettings.dragonAngleThreshold = 1.5;
                m_currentSettings.confluenceRequired = 0.70;
                m_currentSettings.signalStrengthMin = 0.60;
                m_currentSettings.volumeThreshold = 1.3;
                break;
                
            case REGIME_RANGING:
                m_currentSettings.dragonAngleThreshold = 0.8;
                m_currentSettings.confluenceRequired = 0.85;
                m_currentSettings.signalStrengthMin = 0.80;
                m_currentSettings.volumeThreshold = 1.8;
                break;
                
            case REGIME_BREAKOUT:
                m_currentSettings.dragonAngleThreshold = 2.5;
                m_currentSettings.confluenceRequired = 0.75;
                m_currentSettings.signalStrengthMin = 0.70;
                m_currentSettings.volumeThreshold = 2.0;
                break;
                
            case REGIME_CONSOLIDATION:
                m_currentSettings.dragonAngleThreshold = 0.5;
                m_currentSettings.confluenceRequired = 0.60;
                m_currentSettings.signalStrengthMin = 0.50;
                m_currentSettings.volumeThreshold = 1.2;
                break;
                
            default:
                InitializeDefaultSettings();
        }
        
        UpdateVolatilityAverage();
        
        Print("Adaptive Settings Updated - Regime: ", EnumToString(newRegime), 
              " | Dragon Threshold: ", m_currentSettings.dragonAngleThreshold);
    }
    
    ENUM_MARKET_REGIME DetectMarketRegime() {
        double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
        double emaHigh = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_HIGH);
double emaLow = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_LOW);
double close = iClose(_Symbol, PERIOD_CURRENT, 0);
        
        if(atr == EMPTY_VALUE || emaHigh == EMPTY_VALUE || 
           emaLow == EMPTY_VALUE || close == EMPTY_VALUE) {
            return REGIME_UNDEFINED;
        }
        
        double bandWidth = (emaHigh - emaLow) / atr;
        long currentVol = iVolume(_Symbol, PERIOD_CURRENT, 0);
        double avgVol = CalculateAverageVolume(20);
        double volRatio = (avgVol > 0) ? ((double)currentVol) / avgVol : 1.0;
        
        if(bandWidth < 0.7) {
            return REGIME_CONSOLIDATION;
        }
        
        if(volRatio > 2.0 && bandWidth > 1.5) {
            return REGIME_BREAKOUT;
        }
        
        if(bandWidth > 2.0) {
            return REGIME_TRENDING;
        }
        
        return REGIME_RANGING;
    }
    
    double CalculateAverageVolume(int periods) {
        double totalVol = 0;
        int validBars = 0;
        
        for(int i = 1; i <= periods; i++) {
            long vol = iVolume(_Symbol, PERIOD_CURRENT, i);
            if(vol > 0) {
                totalVol += (double)vol;
                validBars++;
            }
        }
        
        return (validBars > 0) ? totalVol / (double)validBars : 0.0;
    }
    
    bool ShouldForceUpdate() {
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        if(atrHandle == INVALID_HANDLE) return false;
        double atrBuffer[1];
        if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) <= 0) {
            IndicatorRelease(atrHandle);
            return false;
        }
        double currentATR = atrBuffer[0];
        IndicatorRelease(atrHandle);
        if(currentATR <= 0) return false;
        double volatilityChange = MathAbs(currentATR - m_averageVolatility);
        return (volatilityChange > (m_averageVolatility * 0.3));
    }
    
    void UpdateVolatilityAverage() {
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        if(atrHandle != INVALID_HANDLE) {
            double atrBuffer[1];
            if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0) {
                double currentATR = atrBuffer[0];
                if(m_averageVolatility == 0) {
                    m_averageVolatility = currentATR;
                } else {
                    m_averageVolatility = (m_averageVolatility * 0.8) + (currentATR * 0.2);
                }
            }
            IndicatorRelease(atrHandle);
        }
    }
};

#endif

