//+------------------------------------------------------------------+
//|                                    Analysis_EnhancedPVSRA.mqh   |
//|                        SONIC R MC - ENHANCED PVSRA ANALYSIS     |
//|                    �?i B�ng Enhanced - Advanced PVSRA Analysis   |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - �?i B�ng Enhanced"
#property version   "1.00"

#ifndef ANALYSIS_PVSRA_ENHANCED_MQH
#define ANALYSIS_PVSRA_ENHANCED_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| ?? SMC & PVSRA QUANTIFICATION SYSTEM - BOSS'S CRITICAL FIX       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ?? GROUP 2 FIX: SSMCLevel moved to CommonStructures.mqh        |
//| Preventing duplicate definition error 282                        |
//+------------------------------------------------------------------+
// NOTE: SSMCLevel is now defined in 01_Core_13_CommonStructures.mqh
// Use #include "01_Core_07_CommonStructures.mqh" to access
// Structure removed here to avoid duplicate definition. Use SSMCLevel from CommonStructures.

//+------------------------------------------------------------------+
//| ?? SMC STRENGTH CALCULATOR - QUANTIFIED ANALYSIS                 |
//+------------------------------------------------------------------+
class CSMCStrengthCalculator
{
private:
SSMCLevel m_smcLevels[20];
int m_levelCount;
double m_minStrengthThreshold;
double m_volumeMultiplier;
int m_maxLookbackBars;

public:
CSMCStrengthCalculator()
{
m_levelCount = 0;
m_minStrengthThreshold = 0.7;
m_volumeMultiplier = 1.8;
m_maxLookbackBars = 24;

for(int i = 0; i < 20; i++) {
    // AGGRESSIVE FIX - Manual reset instead of Reset() method
    m_smcLevels[i].price = 0.0;
    m_smcLevels[i].time = 0;
    m_smcLevels[i].direction = DIRECTION_NEUTRAL;
    m_smcLevels[i].strength = 0.0;
    m_smcLevels[i].isValid = false;
    m_smcLevels[i].description = "";
}
}

//+------------------------------------------------------------------+
//| ?? CALCULATE S/R STRENGTH - QUANTIFIED METHOD                  |
//+------------------------------------------------------------------+
double CalculateSRStrength(datetime srLevelTime, double srPrice, ENUM_DIRECTION direction)
{
// 1. Count price reactions at this level
int reactionCount = CountPriceReactions(srLevelTime, srPrice, direction, m_maxLookbackBars);

// 2. Measure volume at reaction points
double avgReactionVolume = GetAverageReactionVolume(srLevelTime, srPrice, direction);

// 3. Calculate age factor of S/R level
double ageFactor = CalculateAgeFactor(srLevelTime);

// 4. Calculate momentum factor
double momentumFactor = CalculateMomentumFactor(srPrice, direction);

// 5. Calculate comprehensive strength
double strength = (reactionCount * 0.35) +
(NormalizeVolume(avgReactionVolume) * 0.25) +
(ageFactor * 0.25) +
(momentumFactor * 0.15);

return MathMin(1.0, strength);
}

//+------------------------------------------------------------------+
//| ?? COUNT PRICE REACTIONS AT S/R LEVEL                          |
//+------------------------------------------------------------------+
int CountPriceReactions(datetime srLevelTime, double srPrice, ENUM_DIRECTION direction, int lookbackBars)
{
int reactionCount = 0;
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10; // 10 pips tolerance

for(int i = 1; i <= lookbackBars; i++)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
double low = iLow(_Symbol, PERIOD_CURRENT, i);
double close = iClose(_Symbol, PERIOD_CURRENT, i);

// Check if price touched the S/R level
bool touchedLevel = false;

if(direction == DIRECTION_BUY || direction == DIRECTION_BOTH)
{
// Support level - price bounced from below
if(MathAbs(low - srPrice) <= tolerance && close > srPrice)
{
touchedLevel = true;
}
}

if(direction == DIRECTION_SELL || direction == DIRECTION_BOTH)
{
// Resistance level - price bounced from above
if(MathAbs(high - srPrice) <= tolerance && close < srPrice)
{
touchedLevel = true;
}
}

if(touchedLevel)
{
reactionCount++;
}
}

return reactionCount;
}

//+------------------------------------------------------------------+
//| ?? GET AVERAGE REACTION VOLUME                                  |
//+------------------------------------------------------------------+
double GetAverageReactionVolume(datetime srLevelTime, double srPrice, ENUM_DIRECTION direction)
{
double totalVolume = 0.0;
int volumeCount = 0;
double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;

for(int i = 1; i <= m_maxLookbackBars; i++)
{
double high = iHigh(_Symbol, PERIOD_CURRENT, i);
double low = iLow(_Symbol, PERIOD_CURRENT, i);
double close = iClose(_Symbol, PERIOD_CURRENT, i);
double volume = (double)iTickVolume(_Symbol, PERIOD_CURRENT, i);

bool touchedLevel = false;

if(direction == DIRECTION_BUY || direction == DIRECTION_BOTH)
{
if(MathAbs(low - srPrice) <= tolerance && close > srPrice)
{
touchedLevel = true;
}
}

if(direction == DIRECTION_SELL || direction == DIRECTION_BOTH)
{
if(MathAbs(high - srPrice) <= tolerance && close < srPrice)
{
touchedLevel = true;
}
}

if(touchedLevel)
{
totalVolume += volume;
volumeCount++;
}
}

return (volumeCount > 0) ? totalVolume / volumeCount : 0.0;
}

//+------------------------------------------------------------------+
//| ? CALCULATE AGE FACTOR                                         |
//+------------------------------------------------------------------+
double CalculateAgeFactor(datetime srLevelTime)
{
if(srLevelTime == 0) return 0.5; // Default for unknown age

datetime currentTime = TimeCurrent();
double ageInHours = (double)(currentTime - srLevelTime) / 3600.0;

// Age factor: newer levels are stronger (0-24 hours = 1.0, older = 0.3)
if(ageInHours <= 24.0)
{
return 1.0 - (ageInHours / 24.0) * 0.7; // 1.0 to 0.3 over 24 hours
}
else
{
return 0.3; // Minimum strength for old levels
}
}

//+------------------------------------------------------------------+
//| ?? CALCULATE MOMENTUM FACTOR                                    |
//+------------------------------------------------------------------+
double CalculateMomentumFactor(double srPrice, ENUM_DIRECTION direction)
{
double currentPrice = iClose(_Symbol, PERIOD_CURRENT, 0);
double momentum = 0.0;

if(direction == DIRECTION_BUY || direction == DIRECTION_BOTH)
{
// For support levels, check if price is approaching from above
if(currentPrice > srPrice)
{
double distance = (currentPrice - srPrice) / srPrice;
momentum = MathMax(0.0, 1.0 - distance * 100); // Closer = higher momentum
}
}

if(direction == DIRECTION_SELL || direction == DIRECTION_BOTH)
{
// For resistance levels, check if price is approaching from below
if(currentPrice < srPrice)
{
double distance = (srPrice - currentPrice) / srPrice;
momentum = MathMax(0.0, 1.0 - distance * 100); // Closer = higher momentum
}
}

return MathMin(1.0, momentum);
}

//+------------------------------------------------------------------+
//| ?? NORMALIZE VOLUME                                             |
//+------------------------------------------------------------------+
double NormalizeVolume(double volume)
{
if(volume == 0) return 0.0;

// Get average volume for comparison
double avgVolume = 0.0;
for(int i = 1; i <= 20; i++)
{
avgVolume += (double)iTickVolume(_Symbol, PERIOD_CURRENT, i);
}
avgVolume /= 20;

if(avgVolume == 0) return 0.5;

double volumeRatio = volume / avgVolume;

// Normalize to 0.0-1.0 range
if(volumeRatio >= m_volumeMultiplier) return 1.0;
if(volumeRatio >= 1.5) return 0.8;
if(volumeRatio >= 1.2) return 0.6;
if(volumeRatio >= 1.0) return 0.4;
return 0.2;
}

//+------------------------------------------------------------------+
//| ?? VALIDATE S/R LEVEL FOR TRADING                               |
//+------------------------------------------------------------------+
bool IsSRLevelValidForTrading(double srPrice, ENUM_DIRECTION direction)
{
double strength = CalculateSRStrength(0, srPrice, direction);
return strength >= m_minStrengthThreshold;
}

//+------------------------------------------------------------------+
//| ?? GET SMC LEVELS WITH STRENGTH                                 |
//+------------------------------------------------------------------+
SSMCLevel GetSMCLevels(int& count)
{
count = m_levelCount;
if(m_levelCount > 0) {
return m_smcLevels[0]; // Return first level for now
}
SSMCLevel emptyLevel;
ZeroMemory(emptyLevel);
return emptyLevel;
}

//+------------------------------------------------------------------+
//| ?? UPDATE SMC LEVELS                                            |
//+------------------------------------------------------------------+
void UpdateSMCLevels()
{
// This method would be called to update SMC levels based on current market structure
// Implementation would include BOS/CHOCH detection and level validation
Print("?? [SMC] Updating SMC levels with quantified strength analysis");
}

bool CalculatePVSRA(int shift)  // Added shift parameter
{
// 1. T�nh to�n v? tr� an to�n
int safeShift = MathMin(shift, Bars(_Symbol, PERIOD_CURRENT) - 5);

// 2. Ki?m tra gi?i h?n m?ng
if(safeShift < 0) {
Print("?? [PVSRA] Not enough bars for analysis - using fallback");
// Chuy?n sang ch? d? co b?n thay v� d?ng ho�n to�n
// m_pvsraScore = 0.0;  // Assuming m_pvsraScore is a class member
// m_pvsraConfidence = 0.0;  // Assuming m_pvsraConfidence is a class member
return false;
}

// 3. T�nh to�n PVSRA v?i v? tr� an to�n
int obBarIndex = safeShift + 4;
double obHigh = iHigh(_Symbol, PERIOD_CURRENT, obBarIndex);
double obLow = iLow(_Symbol, PERIOD_CURRENT, obBarIndex);

// 4. Ti?p t?c t�nh to�n PVSRA...
// Add your PVSRA calculation logic here
// For example:
// m_pvsraScore = (obHigh + obLow) / 2.0; // Placeholder

return true;
}
};

//+------------------------------------------------------------------+
//| Enhanced PVSRA Analysis Functions                                |
//+------------------------------------------------------------------+
// NOTE: Public interface functions for Enhanced PVSRA (score, phase, report)
// are defined in `03_MarketAnalysis_02_PVSRA_Basic.mqh` to avoid duplicates.

//+------------------------------------------------------------------+
//| GLOBAL SMC STRENGTH CALCULATOR INSTANCE                          |
//+------------------------------------------------------------------+
CSMCStrengthCalculator* g_SMCStrengthCalculator;

//+------------------------------------------------------------------+
//| INITIALIZATION FUNCTIONS                                        |
//+------------------------------------------------------------------+
bool InitializeSMCStrengthCalculator()
{
if(g_SMCStrengthCalculator == NULL) {
g_SMCStrengthCalculator = new CSMCStrengthCalculator();
Print("?? SMC Strength Calculator initialized with quantified analysis");
return true;
}
return true;
}

void DeinitializeSMCStrengthCalculator()
{
if(g_SMCStrengthCalculator != NULL) {
delete g_SMCStrengthCalculator;
g_SMCStrengthCalculator = NULL;
}
}

//+------------------------------------------------------------------+
//| PUBLIC INTERFACE FUNCTIONS                                      |
//+------------------------------------------------------------------+
// Wrapper to check S/R validity using the global calculator
bool IsSRLevelValidForTrading(double srPrice, ENUM_DIRECTION direction)
{
 if(g_SMCStrengthCalculator == NULL) return false;
 return g_SMCStrengthCalculator.IsSRLevelValidForTrading(srPrice, direction);
}

//+------------------------------------------------------------------+
//| ?? PHASE 2: VPSRA SCORE CALCULATION (per review.txt)           |
//+------------------------------------------------------------------+
// Moved: Use global GetVPSRAScore() in 03_MarketAnalysis_06_PVSRA_Manager.mqh

//+------------------------------------------------------------------+
//| ?? PHASE 2: SMC SCORE CALCULATION (per review.txt)              |
//+------------------------------------------------------------------+
double CalculateSMCScore()
{
    // 1. X�c nh?n liquidity sweep
    double liquidityScore = PVSRA_HasLiquiditySweep() ? 1.0 : 0.0;

    // 2. X�c nh?n order block
    double orderBlockScore = IsAtOrderBlock() ? 1.0 : 0.0;

    // 3. X�c nh?n BOS/CHOCH
    double structureScore = HasBOSorCHOCH() ? 1.0 : 0.0;

    // 4. T?ng h?p theo review.txt
    double smcScore = (liquidityScore * 0.4) +
                     (orderBlockScore * 0.3) +
                     (structureScore * 0.3);

    // Fallback khi kh�ng c� d? li?u theo y�u c?u review.txt
    if(smcScore == 0.0) {
        Print("?? [PHASE 2] SMC fallback: No liquidity/order block/structure data available");
        return 0.1; // Minimal score as fallback
    }

    return smcScore;
}

//+------------------------------------------------------------------+
//| ?? PHASE 2: HELPER FUNCTIONS FOR VPSRA ANALYSIS               |
//+------------------------------------------------------------------+
double CalculateVolumeScore()
{
    double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
    double avgVolume = 0.0;

    // Calculate average volume for comparison
    for(int i = 1; i <= 20; i++) {
        avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
    }
    avgVolume /= 20.0;

    // Score based on volume relative to average
    if(avgVolume <= 0) return 0.0;

    double volumeRatio = currentVolume / avgVolume;
    return MathMin(1.0, volumeRatio / 2.0); // Cap at 1.0, high volume = higher score
}

double CalculatePriceReactionScore()
{
    // Measure price reaction strength at current level
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double previousPrice = iClose(_Symbol, PERIOD_CURRENT, 1);

    if(previousPrice <= 0) return 0.0;

    double priceChange = MathAbs(currentPrice - previousPrice) / previousPrice;
    return MathMin(1.0, priceChange * 100.0); // Convert to percentage and cap
}

double CalculateSRQualityScore()
{
    // Use SMC strength calculator if available
    if(g_SMCStrengthCalculator != NULL) {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        return g_SMCStrengthCalculator.CalculateSRStrength(0, currentPrice, DIRECTION_BOTH);
    }

    // Fallback calculation
    return 0.5; // Medium quality as fallback
}

bool PVSRA_HasLiquiditySweep()
{
    // Simplified liquidity sweep detection (scoped to PVSRA_Enhanced)
    double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double low = iLow(_Symbol, PERIOD_CURRENT, 1);
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    // Check if price swept above/below recent high/low
    return (currentPrice > high * 1.0002 || currentPrice < low * 0.9998);
}

bool IsAtOrderBlock()
{
    // Simplified order block detection
    // Check for significant volume at price level
    double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
    double avgVolume = 0.0;

    for(int i = 1; i <= 10; i++) {
        avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
    }
    avgVolume /= 10.0;

    return (currentVolume > avgVolume * 1.5); // High volume indicates potential order block
}

bool HasBOSorCHOCH()
{
    // Simplified Break of Structure (BOS) or Change of Character (CHOCH) detection
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double support = currentPrice * 0.995;  // Simplified support level
    double resistance = currentPrice * 1.005; // Simplified resistance level

    // Check if price breaks above resistance or below support significantly
    return (currentPrice > resistance || currentPrice < support);
}

//+------------------------------------------------------------------+
//| IMPLEMENTATION PRIORITY 2: MISSING PVSRA CORE FUNCTIONS        |
//| (per SONIC_R_DEVELOPMENT_REPORT_2025.md)                        |
//+------------------------------------------------------------------+

// Volume Spike Detection
bool DetectSpikes(double spike_threshold = 2.0)
{
    double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
    double avgVolume = 0.0;

    // Calculate 20-period average volume
    for(int i = 1; i <= 20; i++) {
        avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
    }
    avgVolume /= 20.0;

    if(avgVolume <= 0) return false;

    // Check if current volume is spike_threshold times above average
    return (currentVolume >= avgVolume * spike_threshold);
}

// Wyckoff Integration Analysis
double WyckoffIntegration()
{
    double wyckoffScore = 0.0;

    // Phase A: Stopping Action (High Volume, Small Price Movement)
    double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
    double avgVolume = 0.0;
    for(int i = 1; i <= 10; i++) {
        avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
    }
    avgVolume /= 10.0;

    double currentRange = iHigh(_Symbol, PERIOD_CURRENT, 0) - iLow(_Symbol, PERIOD_CURRENT, 0);
    double avgRange = 0.0;
    for(int i = 1; i <= 10; i++) {
        avgRange += iHigh(_Symbol, PERIOD_CURRENT, i) - iLow(_Symbol, PERIOD_CURRENT, i);
    }
    avgRange /= 10.0;

    // Wyckoff Principle: High Volume + Small Range = Absorption
    if(avgVolume > 0 && avgRange > 0) {
        double volumeRatio = currentVolume / avgVolume;
        double rangeRatio = currentRange / avgRange;

        // High volume with small range indicates institutional activity
        if(volumeRatio > 1.5 && rangeRatio < 0.8) {
            wyckoffScore += 0.4; // Absorption pattern
        }

        // Phase B: Building Cause (Volume analysis)
        if(volumeRatio > 1.2) {
            wyckoffScore += 0.3; // Building phase
        }

        // Phase C: Test (Low volume test of support/resistance)
        if(volumeRatio < 0.7 && rangeRatio < 0.6) {
            wyckoffScore += 0.3; // Test phase
        }
    }

    return MathMin(1.0, wyckoffScore);
}

// Enhanced Volume Score with PVSRA Classification
double CalculateEnhancedVolumeScore()
{
    double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
    double currentRange = iHigh(_Symbol, PERIOD_CURRENT, 0) - iLow(_Symbol, PERIOD_CURRENT, 0);
    double currentClose = iClose(_Symbol, PERIOD_CURRENT, 0);
    double currentOpen = iOpen(_Symbol, PERIOD_CURRENT, 0);

    // Calculate averages
    double avgVolume = 0.0;
    double avgRange = 0.0;
    for(int i = 1; i <= 20; i++) {
        avgVolume += (double)iVolume(_Symbol, PERIOD_CURRENT, i);
        avgRange += iHigh(_Symbol, PERIOD_CURRENT, i) - iLow(_Symbol, PERIOD_CURRENT, i);
    }
    avgVolume /= 20.0;
    avgRange /= 20.0;

    if(avgVolume <= 0 || avgRange <= 0) return 0.0;

    double volumeRatio = currentVolume / avgVolume;
    double rangeRatio = currentRange / avgRange;
    double bodyRatio = MathAbs(currentClose - currentOpen) / currentRange;

    double score = 0.0;

    // PVSRA Classification
    if(volumeRatio >= 2.0) {
        // Very High Volume
        if(rangeRatio >= 1.5 && bodyRatio >= 0.7) {
            score = 1.0; // Climax volume with strong directional move
        } else if(rangeRatio < 0.8) {
            score = 0.8; // High volume, low range (absorption)
        } else {
            score = 0.9; // High volume with normal range
        }
    } else if(volumeRatio >= 1.5) {
        // High Volume
        score = 0.7;
    } else if(volumeRatio >= 1.2) {
        // Above Average Volume
        score = 0.5;
    } else if(volumeRatio < 0.5) {
        // Low Volume (potential test)
        score = 0.3;
    } else {
        // Normal Volume
        score = 0.4;
    }

    return score;
}

// PVSRA Signal Strength Calculation
double GetPVSRASignalStrength()
{
    double volumeScore = CalculateEnhancedVolumeScore();
    double wyckoffScore = WyckoffIntegration();
    double spikeBonus = DetectSpikes() ? 0.2 : 0.0;

    // Weighted combination
    double totalScore = (volumeScore * 0.5) + (wyckoffScore * 0.3) + spikeBonus;

    return MathMin(1.0, totalScore);
}

#endif // ANALYSIS_PVSRA_ENHANCED_MQH
