//+------------------------------------------------------------------+
//| PHASE 4: MARKET NARRATIVE GENERATOR                             |
//| Generates human-readable market analysis stories                 |
//| Copyright 2024, �?i B�ng Dev                                    |
//+------------------------------------------------------------------+
#ifndef NARRATIVE_GENERATOR_MQH
#define NARRATIVE_GENERATOR_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "03_MarketAnalysis_23_AdaptiveSettings.mqh"

//+------------------------------------------------------------------+
//| Market Story Components Structure                                |
//+------------------------------------------------------------------+
struct SMarketStory {
string regime_story;        // Market regime description
string dragon_story;        // Dragon Band analysis
string volume_story;        // Volume analysis
string momentum_story;      // Momentum/trend story
string confluence_story;    // Signal confluence story
string risk_story;         // Risk assessment story
string complete_narrative; // Full market story
double confidence_score;   // Overall confidence 0-1
};

//+------------------------------------------------------------------+
//| Market Narrative Generator Class                                |
//+------------------------------------------------------------------+
class CMarketNarrativeGenerator {
private:
SMarketStory m_lastStory;
datetime m_lastGenerationTime;
int m_storyGenerationCount;

// Story templates and phrases
string m_regimePhrases[5];
string m_dragonPhrases[3];
string m_volumePhrases[3];
string m_momentumPhrases[3];

public:
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketNarrativeGenerator() {
m_lastGenerationTime = 0;
m_storyGenerationCount = 0;
InitializePhrases();
}

//+------------------------------------------------------------------+
//| Generate Complete Market Narrative                              |
//+------------------------------------------------------------------+
SMarketStory GenerateMarketNarrative() {
SMarketStory story;
m_storyGenerationCount++;
m_lastGenerationTime = TimeCurrent();

// Get market data
double dragonAngle = GetDragonAngle();
double waveScore = GetWavePatternScore();
double volumeScore = GetVolumeConfirmationScore();
ENUM_MARKET_REGIME regime = GetMarketRegime();
double atr = 0.0;
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
if(atrHandle == INVALID_HANDLE) atr = 0.0;
else {
double atrBuffer[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) < 1) {
atr = 0.0;
} else {
atr = atrBuffer[0];
}
IndicatorRelease(atrHandle);
}
if(atr == EMPTY_VALUE) atr = 0.0;
double confluence = CalculateConfluenceScore();

// Generate individual story components
story.regime_story = GenerateRegimeStory(regime, atr);
story.dragon_story = GenerateDragonStory(dragonAngle);
story.volume_story = GenerateVolumeStory(volumeScore);
story.momentum_story = GenerateMomentumStory(waveScore, dragonAngle);
story.confluence_story = GenerateConfluenceStory(confluence);
story.risk_story = GenerateRiskStory(regime, volumeScore, confluence);

// Calculate overall confidence
story.confidence_score = CalculateNarrativeConfidence(dragonAngle, volumeScore, confluence);

// Compose complete narrative
story.complete_narrative = ComposeCompleteStory(story);

// Cache the story
m_lastStory = story;

return story;
}

//+------------------------------------------------------------------+
//| Get Quick Market Summary                                        |
//+------------------------------------------------------------------+
string GetQuickMarketSummary() {
ENUM_MARKET_REGIME regime = GetMarketRegime();
double dragonAngle = GetDragonAngle();
double volumeScore = GetVolumeConfirmationScore();

string summary = "?? ";

// Quick regime assessment
switch(regime) {
case REGIME_TRENDING:
summary += "TRENDING";
break;
case REGIME_BREAKOUT:
summary += "BREAKOUT";
break;
case REGIME_RANGING:
summary += "RANGING";
break;
case REGIME_CONSOLIDATION:
summary += "SQUEEZE";
break;
default:
summary += "NEUTRAL";
}

// Quick signal strength
if(MathAbs(dragonAngle) > 2.0 && volumeScore > 0.7) {
summary += " | ?? STRONG";
} else if(MathAbs(dragonAngle) > 1.0 && volumeScore > 0.5) {
summary += " | ? MODERATE";
} else {
summary += " | ?? WEAK";
}

// Direction indicator
if(dragonAngle > 1.0) {
summary += " | ?? BULLISH";
} else if(dragonAngle < -1.0) {
summary += " | ?? BEARISH";
} else {
summary += " | ?? NEUTRAL";
}

return summary;
}

//+------------------------------------------------------------------+
//| Get Trading Recommendation                                      |
//+------------------------------------------------------------------+
string GetTradingRecommendation() {
SMarketStory story;
SMarketStory temp;
temp = this.GenerateMarketNarrative();
story.regime_story = temp.regime_story;
story.dragon_story = temp.dragon_story;
story.volume_story = temp.volume_story;
story.momentum_story = temp.momentum_story;
story.confluence_story = temp.confluence_story;
story.risk_story = temp.risk_story;
story.complete_narrative = temp.complete_narrative;
story.confidence_score = temp.confidence_score;
string recommendation = "?? RECOMMENDATION: ";
ENUM_MARKET_REGIME regime = GetMarketRegime();
double confidence = story.confidence_score;

if(confidence > 0.8) {
switch(regime) {
case REGIME_TRENDING:
recommendation += "Strong trend detected - Follow the momentum with proper risk management";
break;
case REGIME_BREAKOUT:
recommendation += "Breakout in progress - Enter on pullbacks with tight stops";
break;
case REGIME_CONSOLIDATION:
recommendation += "Compression phase - Prepare for potential breakout";
break;
default:
recommendation += "Mixed signals - Wait for clearer direction";
}
} else if(confidence > 0.6) {
recommendation += "Moderate confidence - Consider smaller position sizes";
} else {
recommendation += "Low confidence - Stay on sidelines or reduce exposure";
}

return recommendation;
}

//+------------------------------------------------------------------+
//| Get Statistics Report                                           |
//+------------------------------------------------------------------+
string GetStatisticsReport() {
return StringFormat("?? NARRATIVE STATS: Generated: %d | Last Update: %s | Confidence: %.1f%%",
m_storyGenerationCount,
TimeToString(m_lastGenerationTime, TIME_MINUTES),
m_lastStory.confidence_score * 100);
}

private:
//+------------------------------------------------------------------+
//| Initialize Story Phrases                                        |
//+------------------------------------------------------------------+
void InitializePhrases() {
// Initialize phrase arrays for variety in storytelling
m_regimePhrases[0] = "Market is in a strong";
m_regimePhrases[1] = "We're seeing a clear";
m_regimePhrases[2] = "Current environment shows";
m_regimePhrases[3] = "Market structure indicates";
m_regimePhrases[4] = "Analysis reveals a";
}

//+------------------------------------------------------------------+
//| Generate Regime Story                                           |
//+------------------------------------------------------------------+
string GenerateRegimeStory(ENUM_MARKET_REGIME regime, double atr) {
string story = "?? REGIME: ";
double atrPips = (atr != EMPTY_VALUE && atr > 0) ? atr / _Point : 0;

switch(regime) {
case REGIME_TRENDING:
story += StringFormat("Strong trending market with %.1f pips volatility. Directional momentum is clear.", atrPips);
break;
case REGIME_RANGING:
story += StringFormat("Range-bound market with %.1f pips volatility. Price is consolidating between key levels.", atrPips);
break;
case REGIME_BREAKOUT:
story += StringFormat("Breakout phase with elevated %.1f pips volatility. Expansion is underway.", atrPips);
break;
case REGIME_CONSOLIDATION:
story += StringFormat("Compression phase with reduced %.1f pips volatility. Coiling for next move.", atrPips);
break;
default:
story += StringFormat("Undefined regime with %.1f pips volatility. Mixed signals present.", atrPips);
}

return story;
}

//+------------------------------------------------------------------+
//| Generate Dragon Band Story                                      |
//+------------------------------------------------------------------+
string GenerateDragonStory(double angle) {
string story = "?? DRAGON BANDS: ";

if(angle > 3.0) {
story += StringFormat("Steep bullish angle (%.1f�) - Strong upward momentum driving price higher.", angle);
} else if(angle > 1.0) {
story += StringFormat("Moderate bullish angle (%.1f�) - Upward bias with steady progression.", angle);
} else if(angle < -3.0) {
story += StringFormat("Steep bearish angle (%.1f�) - Strong downward pressure accelerating.", angle);
} else if(angle < -1.0) {
story += StringFormat("Moderate bearish angle (%.1f�) - Downward bias with controlled decline.", angle);
} else {
story += StringFormat("Neutral angle (%.1f�) - Dragon bands are consolidating, preparing for next move.", angle);
}

return story;
}

//+------------------------------------------------------------------+
//| Generate Volume Story                                           |
//+------------------------------------------------------------------+
string GenerateVolumeStory(double volumeScore) {
string story = "?? VOLUME: ";

if(volumeScore > 0.8) {
story += StringFormat("Exceptional participation (%.0f%% above average) - Strong institutional involvement.", volumeScore * 100);
} else if(volumeScore > 0.6) {
story += StringFormat("Good participation (%.0f%% above average) - Decent market interest.", volumeScore * 100);
} else if(volumeScore > 0.4) {
story += StringFormat("Moderate participation (%.0f%% above average) - Average market activity.", volumeScore * 100);
} else {
story += StringFormat("Low participation (%.0f%% above average) - Weak market conviction.", volumeScore * 100);
}

return story;
}

//+------------------------------------------------------------------+
//| Generate Momentum Story                                         |
//+------------------------------------------------------------------+
string GenerateMomentumStory(double waveScore, double dragonAngle) {
string story = "?? MOMENTUM: ";

bool strongMomentum = (MathAbs(dragonAngle) > 2.0 && waveScore > 0.7);
bool moderateMomentum = (MathAbs(dragonAngle) > 1.0 && waveScore > 0.5);

if(strongMomentum) {
story += "Strong momentum alignment - Dragon and Wave patterns confirm direction.";
} else if(moderateMomentum) {
story += "Moderate momentum - Some alignment between indicators.";
} else {
story += "Weak momentum - Conflicting signals between analysis components.";
}

return story;
}

//+------------------------------------------------------------------+
//| Generate Confluence Story                                       |
//+------------------------------------------------------------------+
string GenerateConfluenceStory(double confluence) {
string story = "?? CONFLUENCE: ";

if(confluence > 0.8) {
story += StringFormat("Exceptional alignment (%.0f%%) - Multiple analysis components agree strongly.", confluence * 100);
} else if(confluence > 0.6) {
story += StringFormat("Good alignment (%.0f%%) - Most indicators are in agreement.", confluence * 100);
} else if(confluence > 0.4) {
story += StringFormat("Moderate alignment (%.0f%%) - Some conflicting signals present.", confluence * 100);
} else {
story += StringFormat("Poor alignment (%.0f%%) - Analysis components are conflicted.", confluence * 100);
}

return story;
}

//+------------------------------------------------------------------+
//| Generate Risk Assessment Story                                  |
//+------------------------------------------------------------------+
string GenerateRiskStory(ENUM_MARKET_REGIME regime, double volumeScore, double confluence) {
string story = "?? RISK ASSESSMENT: ";

// Calculate risk level
double riskScore = 0.0;

switch(regime) {
case REGIME_TRENDING:
riskScore = 0.3; // Lower risk in trends
break;
case REGIME_BREAKOUT:
riskScore = 0.7; // Higher risk in breakouts
break;
case REGIME_RANGING:
riskScore = 0.5; // Medium risk in ranges
break;
case REGIME_CONSOLIDATION:
riskScore = 0.6; // Medium-high risk before breakout
break;
default:
riskScore = 0.8; // High risk when undefined
}

// Adjust based on volume and confluence
if(volumeScore > 0.7 && confluence > 0.7) {
riskScore *= 0.7; // Reduce risk with good confirmation
} else if(volumeScore < 0.3 || confluence < 0.3) {
riskScore *= 1.3; // Increase risk with poor confirmation
}

riskScore = MathMin(riskScore, 1.0);

if(riskScore > 0.7) {
story += "HIGH RISK - Use smaller position sizes and tight stops.";
} else if(riskScore > 0.5) {
story += "MODERATE RISK - Standard risk management protocols apply.";
} else {
story += "LOWER RISK - Favorable conditions for position building.";
}

return story;
}

//+------------------------------------------------------------------+
//| Compose Complete Story                                          |
//+------------------------------------------------------------------+
string ComposeCompleteStory(const SMarketStory& story) {
string narrative = StringFormat("?? SONIC R MARKET ANALYSIS - %s\n", TimeToString(TimeCurrent(), TIME_MINUTES));
narrative += "=" + StringPadLeft("", 50, '=') + "\n\n";

narrative += story.regime_story + "\n\n";
narrative += story.dragon_story + "\n\n";
narrative += story.volume_story + "\n\n";
narrative += story.momentum_story + "\n\n";
narrative += story.confluence_story + "\n\n";
narrative += story.risk_story + "\n\n";

narrative += StringFormat("?? OVERALL CONFIDENCE: %.1f%%\n", story.confidence_score * 100);
narrative += GetTradingRecommendation();

return narrative;
}

//+------------------------------------------------------------------+
//| Helper Functions for Market Data                               |
//+------------------------------------------------------------------+
double GetDragonAngle() {
int handle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_HIGH);
if(handle == INVALID_HANDLE) return 0.0;
double buffer[2];
if(CopyBuffer(handle, 0, 0, 2, buffer) < 2) {
IndicatorRelease(handle);
return 0.0;
}
IndicatorRelease(handle);
double emaHigh = buffer[0];
double emaHighPrev = buffer[1];
if(emaHigh == EMPTY_VALUE || emaHighPrev == EMPTY_VALUE) return 0.0;
return MathArctan((emaHigh - emaHighPrev) / _Point) * 180.0 / M_PI;
}

double GetWavePatternScore() {
double range = iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1);
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
if(atrHandle == INVALID_HANDLE) return 0.0;
double atrBuffer[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) < 1) {
IndicatorRelease(atrHandle);
return 0.0;
}
IndicatorRelease(atrHandle);
double atr = atrBuffer[0];
if(atr == EMPTY_VALUE || atr <= 0) return 0.0;
return MathMin(range / atr, 1.0);
}

double GetVolumeConfirmationScore() {
double currentVol = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
double avgVol = 0;
int validBars = 0;

for(int i = 1; i <= 20; i++) {
double vol = (double)iVolume(_Symbol, PERIOD_CURRENT, i);
if(vol > 0) {
avgVol += vol;
validBars++;
}
}

if(validBars == 0 || avgVol == 0) return 0.0;
avgVol /= validBars;

double ratio = currentVol / avgVol;
return MathMin(ratio / 2.0, 1.0);
}

ENUM_MARKET_REGIME GetMarketRegime() {
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
if(atrHandle == INVALID_HANDLE) return REGIME_UNDEFINED;
double atrBuffer[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) < 1) {
IndicatorRelease(atrHandle);
return REGIME_UNDEFINED;
}
IndicatorRelease(atrHandle);
double atr = atrBuffer[0];

int emaHighHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_HIGH);
if(emaHighHandle == INVALID_HANDLE) return REGIME_UNDEFINED;
double emaHighBuffer[1];
if(CopyBuffer(emaHighHandle, 0, 0, 1, emaHighBuffer) < 1) {
IndicatorRelease(emaHighHandle);
return REGIME_UNDEFINED;
}
IndicatorRelease(emaHighHandle);
double emaHigh = emaHighBuffer[0];

int emaLowHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_LOW);
if(emaLowHandle == INVALID_HANDLE) return REGIME_UNDEFINED;
double emaLowBuffer[1];
if(CopyBuffer(emaLowHandle, 0, 0, 1, emaLowBuffer) < 1) {
IndicatorRelease(emaLowHandle);
return REGIME_UNDEFINED;
}
IndicatorRelease(emaLowHandle);
double emaLow = emaLowBuffer[0];

if(atr == EMPTY_VALUE || emaHigh == EMPTY_VALUE || emaLow == EMPTY_VALUE) {
return REGIME_UNDEFINED;
}

double bandWidth = (emaHigh - emaLow) / atr;

if(bandWidth < 0.7) return REGIME_CONSOLIDATION;
if(bandWidth > 2.0) return REGIME_TRENDING;

double volumeScore = GetVolumeConfirmationScore();
if(volumeScore > 0.8) return REGIME_BREAKOUT;

return REGIME_RANGING;
}

double CalculateConfluenceScore() {
double dragonAngle = GetDragonAngle();
double waveScore = GetWavePatternScore();
double volumeScore = GetVolumeConfirmationScore();

// Simple confluence calculation
double dragonWeight = (MathAbs(dragonAngle) > 1.0) ? 0.4 : 0.2;
double waveWeight = (waveScore > 0.5) ? 0.3 : 0.1;
double volumeWeight = (volumeScore > 0.5) ? 0.3 : 0.1;

return dragonWeight + waveWeight + volumeWeight;
}

double CalculateNarrativeConfidence(double dragonAngle, double volumeScore, double confluence) {
double confidence = 0.0;

// Dragon angle contribution (40%)
confidence += MathMin(MathAbs(dragonAngle) / 3.0, 1.0) * 0.4;

// Volume score contribution (30%)
confidence += volumeScore * 0.3;

// Confluence contribution (30%)
confidence += confluence * 0.3;

return MathMin(confidence, 1.0);
}

string StringPadLeft(string str, int length, uchar padChar) {
int currentLength = StringLen(str);
if(currentLength >= length) return str;

string padding = "";
for(int i = 0; i < (length - currentLength); i++) {
padding += CharToString(padChar);
}

return padding + str;
}
};

//+------------------------------------------------------------------+
//| Global Narrative Generator Instance                             |
//+------------------------------------------------------------------+
CMarketNarrativeGenerator* g_NarrativeGenerator;

#endif // NARRATIVE_GENERATOR_MQH


