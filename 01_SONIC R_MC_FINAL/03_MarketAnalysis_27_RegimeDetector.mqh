// Lightweight stub for Market Regime Detector
#ifndef MARKET_ANALYSIS_REGIME_DETECTOR_MQH
#define MARKET_ANALYSIS_REGIME_DETECTOR_MQH

#include "01_Core_14_CoreEnums.mqh"

class CMarketRegimeDetector
{
public:
    bool Initialize(){ return true; }
    ENUM_MARKET_REGIME DetectCurrentRegime(){ return REGIME_STABLE_RANGING; }
};

#endif // MARKET_ANALYSIS_REGIME_DETECTOR_MQH

