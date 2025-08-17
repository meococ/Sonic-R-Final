//+------------------------------------------------------------------+
//|                                    Analysis_POIScoring.mqh |
//|                        Copyright 2024, MQL5-SOLUTIONS.IO |
//|                               https://www.mql5-solutions.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MQL5-SOLUTIONS.IO"
#property link      "https://www.mql5-solutions.io"
#property version   "1.00"

#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| POI Score Structure                                              |
//+------------------------------------------------------------------+
struct POIScore
{
double liquiditySweepScore;
double imbalanceScore;
double freshnessScore;
double pdArrayScore;
double volumeProfileScore;
double confluenceScore;
double totalScore;
bool   isValid;

void Reset()
{
liquiditySweepScore = 0.0;
imbalanceScore = 0.0;
freshnessScore = 0.0;
pdArrayScore = 0.0;
volumeProfileScore = 0.0;
confluenceScore = 0.0;
totalScore = 0.0;
isValid = false;
}
};

//+------------------------------------------------------------------+
//| Scoring Criteria Weights (can be made inputs later)              |
//+------------------------------------------------------------------+
#define WEIGHT_LIQUIDITY_SWEEP 25
#define WEIGHT_IMBALANCE 20
#define WEIGHT_FRESHNESS 15
#define WEIGHT_PD_ARRAY 15
#define WEIGHT_VOLUME_PROFILE 10
#define WEIGHT_CONFLUENCE 15



//+------------------------------------------------------------------+
//| POI Scoring Engine Class                                         |
//+------------------------------------------------------------------+
class CPOIScoringEngine
{
private:
int CalculateLiquiditySweepScore(OrderBlock &ob, SwingPoint &structure[])
{
// TODO: Find the swing point that this OB is supposed to have swept.
// For now, placeholder.
return 50; 
}

int CalculateImbalanceScore(OrderBlock &ob, FairValueGap &fvgs[])
{
// Check if the OB is directly followed by or adjacent to an FVG
for(int i = 0; i < ArraySize(fvgs); i++)
{
// Bullish OB: FVG should be right after
if(ob.isBullish && fvgs[i].barIndex == ob.barIndex - 1)
{
// Check if the FVG is significant (e.g., larger than the OB body)
return 100; // High score for clear imbalance
}
// Bearish OB: FVG should be right after
if(!ob.isBullish && fvgs[i].barIndex == ob.barIndex - 1)
{
return 100; // High score for clear imbalance
}
}
return 10; // Low score if no immediate FVG
}

int CalculateFreshnessScore(OrderBlock &ob)
{
// 100 if valid (not mitigated), 0 if invalid (mitigated)
return ob.isValid ? 100 : 0; 
}

int CalculatePDArrayScore(OrderBlock &ob, SwingPoint &leg_start, SwingPoint &leg_end)
{
if(leg_start.time == 0 || leg_end.time == 0) return 50; // Neutral if leg not found

double equilibrium = (leg_start.price + leg_end.price) / 2.0;

// For a Bullish OB (demand), we want it to be in the discount zone.
if(ob.isBullish)
{
if(ob.lowPrice < equilibrium) return 100; // Prime location
else return 20; // Poor location
}
// For a Bearish OB (supply), we want it to be in the premium zone.
else if(!ob.isBullish)
{
if(ob.highPrice > equilibrium) return 100; // Prime location
else return 20; // Poor location
}

return 50; // Should not happen
}

double CalculateVolumeProfileScore(OrderBlock &ob)
{
// TODO: Requires integration with a Volume Profile indicator.
// Check if the OB overlaps with a High Volume Node (HVN) or Point of Control (POC).
return 50.0; // Placeholder - SYSTEMATIC FIX: Changed to double
}

double CalculateConfluenceScore(OrderBlock &ob)
{
// TODO: Check for confluence with other factors like:
// - MTF High/Low levels
// - Major round numbers
// - Other indicator signals (e.g., moving averages)
return 50.0; // Placeholder - SYSTEMATIC FIX: Changed to double
}

public:
POIScore ScoreOrderBlock(OrderBlock &ob, const MqlRates &rates[], SwingPoint &structure[], FairValueGap &fvgs[])
{
POIScore score;

// Find the leg that the OB belongs to for context
SwingPoint leg_start, leg_end;
for(int i = ArraySize(structure) - 2; i >= 0; i--)
{
if(structure[i].time < ob.startTime && structure[i+1].time > ob.startTime)
{
leg_start = structure[i];
leg_end = structure[i+1];
break;
}
}

score.liquiditySweepScore = CalculateLiquiditySweepScore(ob, structure);
score.imbalanceScore = CalculateImbalanceScore(ob, fvgs);
score.freshnessScore = CalculateFreshnessScore(ob);
score.pdArrayScore = CalculatePDArrayScore(ob, leg_start, leg_end);
score.volumeProfileScore = CalculateVolumeProfileScore(ob);
score.confluenceScore = CalculateConfluenceScore(ob);

// Calculate total weighted score
score.totalScore = (score.liquiditySweepScore * WEIGHT_LIQUIDITY_SWEEP +
score.imbalanceScore * WEIGHT_IMBALANCE +
score.freshnessScore * WEIGHT_FRESHNESS +
score.pdArrayScore * WEIGHT_PD_ARRAY +
score.volumeProfileScore * WEIGHT_VOLUME_PROFILE +
score.confluenceScore * WEIGHT_CONFLUENCE) / 100;

return score;
}

// Method to score a Fair Value Gap (can be added later)
// POIScore ScoreFVG(const FairValueGap &fvg);
};


