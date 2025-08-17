//+------------------------------------------------------------------+
//|                                   Analysis_PatternRecognition.mqh|
//|                    SONIC R MC - Advanced Pattern Recognition      |
//|                             PHASE 3: ANALYTICS POWERHOUSE        |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Phase 3"
#property version   "3.00"
// PRODUCTION FIX: Remove #property strict - MQL4 syntax not supported in MQL5

#ifndef ANALYSIS_PATTERN_RECOGNITION_MQH
#define ANALYSIS_PATTERN_RECOGNITION_MQH


#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_07_CommonStructures.mqh"

// Note: ENUM_HARMONIC_PATTERN is defined in SonicR_Enums.mqh

// Note: ENUM_PATTERN_VALIDATION is defined in SonicR_Enums.mqh

//+------------------------------------------------------------------+
//| HARMONIC PATTERN STRUCTURE                                       |
//+------------------------------------------------------------------+
// PHASE 3.3 FIX: Use HarmonicPattern from SonicR_CommonStructs.mqh to avoid redefinition
// Remove duplicate struct definition

//+------------------------------------------------------------------+
//| STATISTICAL PATTERN DATA                                         |
//+------------------------------------------------------------------+
struct PatternStatistics
{
int                     detectedCount;
int                     successfulCount;
double                  successRate;
double                  avgProfitRatio;
double                  avgTimeToTarget;
double                  reliability;
datetime                lastUpdate;

void Reset()
{
detectedCount = 0;
successfulCount = 0;
successRate = 0.0;
avgProfitRatio = 0.0;
avgTimeToTarget = 0.0;
reliability = 0.0;
lastUpdate = 0;
}
};

//+------------------------------------------------------------------+
//| Global Swing Point Detection Function - PRODUCTION FIX          |
//+------------------------------------------------------------------+
int GetSwingPoints(SwingPoint& points[], int maxPoints)
{
// Global implementation for swing point detection
int count = 0;

// ?? CRITICAL FIX: Validate history availability before pattern detection
int availableBars = Bars(_Symbol, PERIOD_CURRENT);
if(availableBars < 7) { // Need minimum 7 bars for i+2 to i-2 pattern
::Print("WARNING [PATTERN] Insufficient history for swing detection: ", availableBars, " bars");
return 0;
}

// ?? CRITICAL FIX: Adjust loop to respect bounds
int maxSafeIndex = MathMin(50, availableBars - 3); // Ensure i+2 is always valid

// Basic swing point detection using highs/lows
for(int i = 2; i < maxSafeIndex && count < maxPoints; i++)
{
// ?? CRITICAL FIX: Validate all indices before access
if(i + 2 >= availableBars || i - 2 < 0) {
continue; // Skip this iteration if bounds invalid
}

double high2 = iHigh(_Symbol, PERIOD_CURRENT, i+2);
double high1 = iHigh(_Symbol, PERIOD_CURRENT, i+1);
double high0 = iHigh(_Symbol, PERIOD_CURRENT, i);
double high_1 = iHigh(_Symbol, PERIOD_CURRENT, i-1);
double high_2 = iHigh(_Symbol, PERIOD_CURRENT, i-2);

// ?? ADDED: Validate retrieved data
if(high2 <= 0 || high1 <= 0 || high0 <= 0 || high_1 <= 0 || high_2 <= 0) {
::Print("WARNING [PATTERN] Invalid price data at index ", i, " - Skipping");
continue;
}

// Swing high detection
if(high0 > high1 && high0 > high_1 && high0 > high2 && high0 > high_2)
{
if(count < maxPoints)
{
points[count].price = high0;
points[count].time = iTime(_Symbol, PERIOD_CURRENT, i);
points[count].type = ENUM_SWING_TYPE::SWING_HIGH;
points[count].isValid = true;
count++;
}
}

double low2 = iLow(_Symbol, PERIOD_CURRENT, i+2);
double low1 = iLow(_Symbol, PERIOD_CURRENT, i+1);
double low0 = iLow(_Symbol, PERIOD_CURRENT, i);
double low_1 = iLow(_Symbol, PERIOD_CURRENT, i-1);
double low_2 = iLow(_Symbol, PERIOD_CURRENT, i-2);

// Swing low detection
if(low0 < low1 && low0 < low_1 && low0 < low2 && low0 < low_2)
{
if(count < maxPoints)
{
points[count].price = low0;
points[count].time = iTime(_Symbol, PERIOD_CURRENT, i);
points[count].type = ENUM_SWING_TYPE::SWING_LOW;
points[count].isValid = true;
count++;
}
}
}

return count;
}

//+------------------------------------------------------------------+
//| Harmonic Pattern Detector Class                                 |
//+------------------------------------------------------------------+
class CHarmonicPatternDetector
{
private:
HarmonicPattern         m_patterns[20];
PatternStatistics       m_statistics[10];
int                     m_patternCount;

// Missing class members - Boss's fix
SwingPoint              m_swingPoints[100];
int                     m_swingPointCount;

// Fibonacci ratios for pattern validation
double                  m_fibRatios[10];
double                  m_tolerance;

public:
CHarmonicPatternDetector()
{
m_patternCount = 0;
m_swingPointCount = 0;
m_tolerance = 0.02; // 2% tolerance
InitializeFibonacciRatios();
}

bool DetectHarmonicPatterns()
{
// Clear previous patterns
m_patternCount = 0;

// Update swing points first
m_swingPointCount = GetSwingPoints(m_swingPoints, 100);

// Detect different harmonic patterns
// DetectGartleyPattern();
// DetectButterflyPattern();
// DetectBatPattern();
// DetectCrabPattern();
DetectSharkPattern();
DetectCypherPattern();
DetectABCDPattern();
DetectThreeDrivesPattern();

return (m_patternCount > 0);
}

HarmonicPattern GetPattern(int index)
{
if(index >= 0 && index < m_patternCount)
return m_patterns[index];

HarmonicPattern empty;
// AGGRESSIVE FIX - Manual reset instead of Reset() method
empty.type = HARMONIC_NONE;
empty.pointX = 0.0;
empty.pointA = 0.0;
empty.pointB = 0.0;
empty.pointC = 0.0;
empty.pointD = 0.0;
empty.timeX = 0;
empty.timeA = 0;
empty.timeB = 0;
empty.timeC = 0;
empty.timeD = 0;
empty.confidence = 0.0;
empty.isValid = false;
empty.direction = DIRECTION_NEUTRAL;
return empty;
}

int GetPatternCount() { return m_patternCount; }

double GetPatternConfidence(ENUM_HARMONIC_PATTERN type)
{
for(int i = 0; i < m_patternCount; i++)
{
if(m_patterns[i].type == type && m_patterns[i].isActive)
return m_patterns[i].confidence;
}
return 0.0;
}

bool IsInPRDZone(double price)
{
for(int i = 0; i < m_patternCount; i++)
{
if(m_patterns[i].isActive && 
price >= m_patterns[i].prdZoneLow && 
price <= m_patterns[i].prdZoneHigh)
return true;
}
return false;
}

private:
void InitializeFibonacciRatios()
{
m_fibRatios[0] = 0.236;
m_fibRatios[1] = 0.382;
m_fibRatios[2] = 0.500;
m_fibRatios[3] = 0.618;
m_fibRatios[4] = 0.786;
m_fibRatios[5] = 1.000;
m_fibRatios[6] = 1.272;
m_fibRatios[7] = 1.414;
m_fibRatios[8] = 1.618;
m_fibRatios[9] = 2.618;
}

bool DetectGartleyPattern()
{
// XABCD Pattern with specific Fibonacci ratios
// AB = 0.618 of XA
// BC = 0.382 or 0.886 of AB  
// CD = 1.272 or 1.618 of BC
// AD = 0.786 of XA

SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 4; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint X;
X.price = points[i-4].price;
X.time = points[i-4].time;
X.type = points[i-4].type;
X.isValid = points[i-4].isValid;
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateGartleyRatios(X, A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_GARTLEY;
pattern.pointX = X.price;
pattern.pointA = A.price;
pattern.pointB = B.price;
pattern.pointC = C.price;
pattern.pointD = D.price;
pattern.timeX = X.time;
pattern.timeA = A.time;
pattern.timeB = B.time;
pattern.timeC = C.time;
pattern.timeD = D.time;
pattern.isBullish = (D.price < A.price);
pattern.confidence = CalculatePatternConfidence(X, A, B, C, D, HARMONIC_GARTLEY);
pattern.validation = ValidatePattern(pattern);
CalculatePRDZone(pattern);
pattern.isActive = true;

m_patterns[m_patternCount++] = pattern;
return true; // Pattern found
}
}
return false; // No pattern found
}

bool DetectButterflyPattern()
{
// Similar structure for Butterfly pattern
// AB = 0.786 of XA
// BC = 0.382 or 0.886 of AB
// CD = 1.618 or 2.618 of BC
// AD = 1.272 or 1.618 of XA

SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 4; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint X;
X.price = points[i-4].price;
X.time = points[i-4].time;
X.type = points[i-4].type;
X.isValid = points[i-4].isValid;
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateButterflyRatios(X, A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_BUTTERFLY;
FillPatternData(pattern, X, A, B, C, D, HARMONIC_BUTTERFLY);
m_patterns[m_patternCount++] = pattern;
return true; // Pattern found
}
}
return false; // No pattern found
}

bool DetectBatPattern()
{
// Bat pattern ratios
// AB = 0.382 or 0.500 of XA
// BC = 0.382 or 0.886 of AB
// CD = 1.618 or 2.618 of BC
// AD = 0.886 of XA

SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 4; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint X;
X.price = points[i-4].price;
X.time = points[i-4].time;
X.type = points[i-4].type;
X.isValid = points[i-4].isValid;
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateBatRatios(X, A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_BAT;
FillPatternData(pattern, X, A, B, C, D, HARMONIC_BAT);
m_patterns[m_patternCount++] = pattern;
return true; // Pattern found
}
}
return false; // No pattern found
}

bool DetectCrabPattern()
{
// Crab pattern implementation
SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 4; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint X;
X.price = points[i-4].price;
X.time = points[i-4].time;
X.type = points[i-4].type;
X.isValid = points[i-4].isValid;
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateCrabRatios(X, A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_CRAB;
FillPatternData(pattern, X, A, B, C, D, HARMONIC_CRAB);
m_patterns[m_patternCount++] = pattern;
return true; // Pattern found
}
}
return false; // No pattern found
}

void DetectSharkPattern()
{
// Shark pattern implementation
SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 4; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint X;
X.price = points[i-4].price;
X.time = points[i-4].time;
X.type = points[i-4].type;
X.isValid = points[i-4].isValid;
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateSharkRatios(X, A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_SHARK;
FillPatternData(pattern, X, A, B, C, D, HARMONIC_SHARK);
m_patterns[m_patternCount++] = pattern;
}
}
}

void DetectCypherPattern()
{
// Cypher pattern implementation 
SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 4; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint X;
X.price = points[i-4].price;
X.time = points[i-4].time;
X.type = points[i-4].type;
X.isValid = points[i-4].isValid;
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateCypherRatios(X, A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_CYPHER;
FillPatternData(pattern, X, A, B, C, D, HARMONIC_CYPHER);
m_patterns[m_patternCount++] = pattern;
}
}
}

void DetectABCDPattern()
{
// ABCD pattern implementation
SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 3; i < pointCount && m_patternCount < 20; i++)
{
SwingPoint A;
A.price = points[i-3].price;
A.time = points[i-3].time;
A.type = points[i-3].type;
A.isValid = points[i-3].isValid;
SwingPoint B;
B.price = points[i-2].price;
B.time = points[i-2].time;
B.type = points[i-2].type;
B.isValid = points[i-2].isValid;
SwingPoint C;
C.price = points[i-1].price;
C.time = points[i-1].time;
C.type = points[i-1].type;
C.isValid = points[i-1].isValid;
SwingPoint D;
D.price = points[i].price;
D.time = points[i].time;
D.type = points[i].type;
D.isValid = points[i].isValid;

if(ValidateABCDRatios(A, B, C, D))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_AB_CD;
pattern.pointA = A.price;
pattern.pointB = B.price;
pattern.pointC = C.price;
pattern.pointD = D.price;
pattern.timeA = A.time;
pattern.timeB = B.time;
pattern.timeC = C.time;
pattern.timeD = D.time;
pattern.isBullish = (D.price < B.price);
pattern.confidence = CalculateABCDConfidence(A, B, C, D);
pattern.validation = ValidatePattern(pattern);
CalculatePRDZone(pattern);
pattern.isActive = true;

m_patterns[m_patternCount++] = pattern;
}
}
}

void DetectThreeDrivesPattern()
{
// Three Drives pattern implementation
SwingPoint points[100];
int pointCount = GetSwingPoints(points, 100);

for(int i = 6; i < pointCount && m_patternCount < 20; i++)
{
// Three Drives requires 7 points
if(ValidateThreeDrivesPattern(points, i))
{
HarmonicPattern pattern;
pattern.type = HARMONIC_THREE_DRIVES;
FillThreeDrivesData(pattern, points, i);
m_patterns[m_patternCount++] = pattern;
}
}
}

// Helper methods for pattern validation
bool ValidateGartleyRatios(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double XA = MathAbs(A.price - X.price);
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);
double AD = MathAbs(D.price - A.price);

double AB_XA = AB / XA;
double BC_AB = BC / AB;
double CD_BC = CD / BC;
double AD_XA = AD / XA;

return (IsRatioValid(AB_XA, 0.618) &&
(IsRatioValid(BC_AB, 0.382) || IsRatioValid(BC_AB, 0.886)) &&
(IsRatioValid(CD_BC, 1.272) || IsRatioValid(CD_BC, 1.618)) &&
IsRatioValid(AD_XA, 0.786));
}

bool ValidateButterflyRatios(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double XA = MathAbs(A.price - X.price);
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);
double AD = MathAbs(D.price - A.price);

double AB_XA = AB / XA;
double BC_AB = BC / AB;
double CD_BC = CD / BC;
double AD_XA = AD / XA;

return (IsRatioValid(AB_XA, 0.786) &&
(IsRatioValid(BC_AB, 0.382) || IsRatioValid(BC_AB, 0.886)) &&
(IsRatioValid(CD_BC, 1.618) || IsRatioValid(CD_BC, 2.618)) &&
(IsRatioValid(AD_XA, 1.272) || IsRatioValid(AD_XA, 1.618)));
}

bool ValidateBatRatios(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double XA = MathAbs(A.price - X.price);
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);
double AD = MathAbs(D.price - A.price);

double AB_XA = AB / XA;
double BC_AB = BC / AB;
double CD_BC = CD / BC;
double AD_XA = AD / XA;

return ((IsRatioValid(AB_XA, 0.382) || IsRatioValid(AB_XA, 0.500)) &&
(IsRatioValid(BC_AB, 0.382) || IsRatioValid(BC_AB, 0.886)) &&
(IsRatioValid(CD_BC, 1.618) || IsRatioValid(CD_BC, 2.618)) &&
IsRatioValid(AD_XA, 0.886));
}

bool ValidateCrabRatios(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double XA = MathAbs(A.price - X.price);
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);
double AD = MathAbs(D.price - A.price);

double AB_XA = AB / XA;
double BC_AB = BC / AB;
double CD_BC = CD / BC;
double AD_XA = AD / XA;

return ((IsRatioValid(AB_XA, 0.382) || IsRatioValid(AB_XA, 0.618)) &&
(IsRatioValid(BC_AB, 0.382) || IsRatioValid(BC_AB, 0.886)) &&
(IsRatioValid(CD_BC, 2.240) || IsRatioValid(CD_BC, 3.618)) &&
IsRatioValid(AD_XA, 1.618));
}

bool ValidateSharkRatios(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double XA = MathAbs(A.price - X.price);
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double OD = MathAbs(D.price - X.price); // O is same as X in Shark

double AB_XA = AB / XA;
double BC_AB = BC / AB;
double OD_XA = OD / XA;

return ((IsRatioValid(AB_XA, 0.382) || IsRatioValid(AB_XA, 0.618)) &&
(IsRatioValid(BC_AB, 1.130) || IsRatioValid(BC_AB, 1.618)) &&
(IsRatioValid(OD_XA, 0.886) || IsRatioValid(OD_XA, 1.130)));
}

bool ValidateCypherRatios(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double XA = MathAbs(A.price - X.price);
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);

double AB_XA = AB / XA;
double BC_AB = BC / AB;
double CD_BC = CD / BC;

return ((IsRatioValid(AB_XA, 0.382) || IsRatioValid(AB_XA, 0.618)) &&
IsRatioValid(BC_AB, 1.272) &&
IsRatioValid(CD_BC, 0.786));
}

bool ValidateABCDRatios(const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);

double BC_AB = BC / AB;
double CD_AB = CD / AB;

return ((IsRatioValid(BC_AB, 0.382) || IsRatioValid(BC_AB, 0.618) || IsRatioValid(BC_AB, 0.786)) &&
(IsRatioValid(CD_AB, 1.272) || IsRatioValid(CD_AB, 1.618)));
}

bool ValidateThreeDrivesPattern(const SwingPoint& points[], int endIndex)
{
// Validate Three Drives pattern with time and price symmetry
return true; // Simplified for now
}

bool IsRatioValid(double actual, double expected)
{
return (MathAbs(actual - expected) <= m_tolerance);
}

double CalculatePatternConfidence(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D, ENUM_HARMONIC_PATTERN type)
{
double confidence = 0.0;

// Base confidence from ratio accuracy
confidence += CalculateRatioAccuracy(X, A, B, C, D, type) * 0.4;

// Volume confirmation
confidence += CalculateVolumeConfirmation(D) * 0.3;

// Time symmetry
confidence += CalculateTimeSymmetry(X, A, B, C, D) * 0.2;

// Pattern completion quality
confidence += CalculateCompletionQuality(D) * 0.1;

return MathMin(confidence, 1.0);
}

double CalculateABCDConfidence(const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
double confidence = 0.0;

double AB = MathAbs(B.price - A.price);
double BC = MathAbs(C.price - B.price);
double CD = MathAbs(D.price - C.price);

double BC_AB = BC / AB;
double CD_AB = CD / AB;

// Ratio accuracy
if(IsRatioValid(BC_AB, 0.618) && IsRatioValid(CD_AB, 1.618))
confidence += 0.8;
else if(IsRatioValid(BC_AB, 0.786) && IsRatioValid(CD_AB, 1.272))
confidence += 0.7;
else
confidence += 0.5;

// Volume confirmation
confidence += CalculateVolumeConfirmation(D) * 0.2;

return MathMin(confidence, 1.0);
}

double CalculateRatioAccuracy(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D, ENUM_HARMONIC_PATTERN type)
{
// Calculate how accurately the pattern matches ideal ratios
return 0.8; // Simplified
}

double CalculateVolumeConfirmation(const SwingPoint& point)
{
// Check if volume confirms the pattern completion
long currentVolume = iVolume(_Symbol, PERIOD_CURRENT, 0);
long avgVolume = 0;
for(int i = 1; i <= 10; i++)
avgVolume += iVolume(_Symbol, PERIOD_CURRENT, i);
avgVolume /= 10;

return (currentVolume > avgVolume * 1.5) ? 1.0 : 0.5;
}

double CalculateTimeSymmetry(const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D)
{
// Calculate time symmetry between pattern legs
return 0.7; // Simplified
}

double CalculateCompletionQuality(const SwingPoint& point)
{
// Quality of pattern completion
return 0.8; // Simplified
}

ENUM_PATTERN_VALIDATION ValidatePattern(HarmonicPattern &pattern)
{
if(pattern.confidence > 0.9)
return VALIDATION_VERY_STRONG;
else if(pattern.confidence > 0.7)
return VALIDATION_STRONG;
else if(pattern.confidence > 0.5)
return VALIDATION_MODERATE;
else
return VALIDATION_WEAK;
}

void CalculatePRDZone(HarmonicPattern &pattern)
{
// Calculate Potential Reversal Zone
double range = MathAbs(pattern.pointA - pattern.pointD) * 0.05; // 5% range
pattern.prdZoneHigh = pattern.pointD + range;
pattern.prdZoneLow = pattern.pointD - range;
}

void FillPatternData(HarmonicPattern &pattern, const SwingPoint& X, const SwingPoint& A, const SwingPoint& B, const SwingPoint& C, const SwingPoint& D, ENUM_HARMONIC_PATTERN type)
{
pattern.type = type;
pattern.pointX = X.price;
pattern.pointA = A.price;
pattern.pointB = B.price;
pattern.pointC = C.price;
pattern.pointD = D.price;
pattern.timeX = X.time;
pattern.timeA = A.time;
pattern.timeB = B.time;
pattern.timeC = C.time;
pattern.timeD = D.time;
pattern.isBullish = (D.price < A.price);
pattern.confidence = CalculatePatternConfidence(X, A, B, C, D, type);
pattern.validation = ValidatePattern(pattern);
CalculatePRDZone(pattern);
pattern.isActive = true;
}

void FillThreeDrivesData(HarmonicPattern &pattern, const SwingPoint &points[], int endIndex)
{
pattern.type = HARMONIC_THREE_DRIVES;
// Fill specific Three Drives data
pattern.confidence = 0.7; // Simplified
pattern.validation = VALIDATION_MODERATE;
pattern.isActive = true;
}

// PRODUCTION FIX: Safe Harmonic Pattern Detection                 |
// | Enhanced with bounds checking and const reference optimization  |
// | PRODUCTION FIX: Safe array access with bounds checking        |
bool DetectHarmonicPattern(const SwingPoint &points[], HarmonicPattern &pattern)
{
// SAFETY: Validate input array
if(!ValidateSwingPointArray(points, "DetectHarmonicPattern"))
{
// AGGRESSIVE FIX - Manual reset instead of Reset() method
pattern.type = HARMONIC_NONE;
pattern.pointX = 0.0;
pattern.pointA = 0.0;
pattern.pointB = 0.0;
pattern.pointC = 0.0;
pattern.pointD = 0.0;
pattern.timeX = 0;
pattern.timeA = 0;
pattern.timeB = 0;
pattern.timeC = 0;
pattern.timeD = 0;
pattern.confidence = 0.0;
pattern.isValid = false;
pattern.direction = DIRECTION_NEUTRAL;
return false;
}

int validPoints = GetValidSwingPointCount(points);
if(validPoints < 5) // Need minimum 5 points for harmonic patterns
{
// SafeLogWarning(StringFormat("Insufficient valid points for harmonic detection: %d", validPoints), "HARMONIC_DETECTION");
// AGGRESSIVE FIX - Manual reset
pattern.type = HARMONIC_NONE;
pattern.isValid = false;
return false;
}

// BOUNDS CHECK: Safe array access
int size = ArraySize(points);
if(size < 5)
{
// AGGRESSIVE FIX - Manual reset
pattern.type = HARMONIC_NONE;
pattern.isValid = false;
return false;
}

// PRODUCTION FIX: Enhanced pattern detection with error handling (MQL5 compatible)
// Get last 5 significant swing points for pattern analysis
SwingPoint p1, p2, p3, p4, p5;

if(!GetLastFiveSwingPoints(points, p1, p2, p3, p4, p5))
{
// SafeLogWarning("Failed to extract 5 swing points for harmonic analysis", "HARMONIC_DETECTION");
// AGGRESSIVE FIX - Manual reset
pattern.type = HARMONIC_NONE;
pattern.isValid = false;
return false;
}

// Detect specific harmonic patterns
if(DetectGartleyPattern())
{
// SafeLogInfo("Gartley pattern detected", "HARMONIC_DETECTION");
return true;
}

if(DetectButterflyPattern())
{
// SafeLogInfo("Butterfly pattern detected", "HARMONIC_DETECTION");
return true;
}

if(DetectBatPattern())
{
// SafeLogInfo("Bat pattern detected", "HARMONIC_DETECTION");
return true;
}

if(DetectCrabPattern())
{
// SafeLogInfo("Crab pattern detected", "HARMONIC_DETECTION");
return true;
}

// No pattern found
// AGGRESSIVE FIX - Manual reset
pattern.type = HARMONIC_NONE;
pattern.isValid = false;
return false;
}

// PRODUCTION FIX: Safe extraction of last 5 swing points
bool GetLastFiveSwingPoints(const SwingPoint &points[], SwingPoint &p1, SwingPoint &p2, 
SwingPoint &p3, SwingPoint &p4, SwingPoint &p5)
{
int size = ArraySize(points);
if(size < 5) return false;

// Find last 5 valid swing points
int foundCount = 0;
SwingPoint tempPoints[5];

for(int i = size - 1; i >= 0 && foundCount < 5; i--)
{
if(IsValidSwingPoint(points[i]))
{
tempPoints[foundCount] = points[i];
foundCount++;
}
}

if(foundCount < 5) return false;

// Assign in chronological order (oldest first)
p1 = tempPoints[4]; // Oldest
p2 = tempPoints[3];
p3 = tempPoints[2];
p4 = tempPoints[1];
p5 = tempPoints[0]; // Most recent

return true;
}

// PRODUCTION FIX: Comprehensive array validation
bool ValidateSwingPointArray(const SwingPoint &points[], const string arrayName)
{
int size = ArraySize(points);

if(size <= 0)
{
// SafeLogError(StringFormat("Array %s is empty or invalid", arrayName), "ARRAY_VALIDATION");
return false;
}

if(size > 1000) // Sanity check for memory safety
{
// SafeLogWarning(StringFormat("Array %s unusually large: %d elements", arrayName, size), "ARRAY_VALIDATION");
}

// PRODUCTION FIX: Validate first few elements for integrity
int checkCount = MathMin(size, 5);
for(int i = 0; i < checkCount; i++)
{
if(!IsValidSwingPoint(points[i]))
{
// SafeLogError(StringFormat("Array %s contains invalid data at index %d", arrayName, i), "ARRAY_VALIDATION");
return false;
}
}

return true;
}

// PRODUCTION FIX: Enhanced swing point validation
bool IsValidSwingPoint(const SwingPoint &point)
{
// Check price validity
if(point.price <= 0.0 || point.price > 1000000.0) // Reasonable price range
return false;

// Check time validity
if(point.time <= 0 || point.time > TimeCurrent() + 86400) // Not future + 1 day buffer
return false;

// Check type validity
if(point.type != ENUM_SWING_TYPE::SWING_HIGH && point.type != ENUM_SWING_TYPE::SWING_LOW)
return false;

// Check strength range
if(point.strength < 0 || point.strength > 100)
return false;

return true;
}

// PRODUCTION FIX: Get valid swing point count with safety
int GetValidSwingPointCount(const SwingPoint &points[])
{
if(!ValidateSwingPointArray(points, "GetValidSwingPointCount"))
return 0;

int size = ArraySize(points);
int validCount = 0;

for(int i = 0; i < size; i++)
{
if(IsValidSwingPoint(points[i]))
validCount++;
}

return validCount;
}
};

#endif // ANALYSIS_PATTERN_RECOGNITION_MQH



