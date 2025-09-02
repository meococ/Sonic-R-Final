// Lightweight stub for Wave ZigZag Analyzer used by Orchestrator
#ifndef MARKET_ANALYSIS_WAVE_ZIGZAG_ANALYZER_MQH
#define MARKET_ANALYSIS_WAVE_ZIGZAG_ANALYZER_MQH

#include "01_Core_14_CoreEnums.mqh"

class CWaveZigZagAnalyzer
{
public:
    CWaveZigZagAnalyzer() {}
    void Initialize(const int depth, const int deviation, const int backstep) { (void)depth; (void)deviation; (void)backstep; }
    ENUM_WAVE_PATTERN AnalyzeWavePattern(const int lookbackBars)
    {
        (void)lookbackBars;
        return WAVE_PATTERN_NONE;
    }
};

#endif // MARKET_ANALYSIS_WAVE_ZIGZAG_ANALYZER_MQH

