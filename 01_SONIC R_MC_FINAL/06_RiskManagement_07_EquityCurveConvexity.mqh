//+------------------------------------------------------------------+
//| ?? BOSS FIX: EQUITY CURVE CONVEXITY MANAGEMENT                 |
//| Strategic Improvement #3 - Equity Curve Shape Analysis         |
//+------------------------------------------------------------------+
#property strict
#include "01_Core_22_SonicEnums.mqh"

#ifndef RISK_EQUITYCURVECONVEXITY_MQH
#define RISK_EQUITYCURVECONVEXITY_MQH

//+------------------------------------------------------------------+
//| Equity Curve Pattern Types                                      |
//+------------------------------------------------------------------+
enum ENUM_EQUITY_PATTERN
{
PATTERN_SMOOTH_GROWTH,     // Healthy upward trajectory
PATTERN_ACCELERATING,      // Accelerating growth
PATTERN_VOLATILE_UP,       // Volatile but upward
PATTERN_SIDEWAYS,          // Flat/sideways movement
PATTERN_VOLATILE_DOWN,     // Volatile downward
PATTERN_DECLINING,         // Steady decline
PATTERN_DANGEROUS_DECLINE, // Rapid dangerous decline
PATTERN_UNKNOWN           // Insufficient data
};

//+------------------------------------------------------------------+
//| Equity Curve Data Point                                         |
//+------------------------------------------------------------------+
struct EquityCurvePoint
{
datetime time;
double equity;
double balance;
double drawdown;
double velocity;    // Rate of change
double acceleration; // Second derivative

void Reset() {
time = 0;
equity = 0.0;
balance = 0.0;
drawdown = 0.0;
velocity = 0.0;
acceleration = 0.0;
}
};

//+------------------------------------------------------------------+
//| Equity Curve Convexity Manager Class                           |
//+------------------------------------------------------------------+
class CEquityCurveConvexityManager
{
private:
EquityCurvePoint m_equityHistory[100];
int m_historyCount;
int m_maxHistorySize;

double m_currentConvexity;
ENUM_EQUITY_PATTERN m_currentPattern;

double m_lastEquity;
datetime m_lastUpdate;

bool m_warningActive;
string m_lastWarningMessage;

public:
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEquityCurveConvexityManager()
{
m_historyCount = 0;
m_maxHistorySize = 100;
m_currentConvexity = 0.0;
m_currentPattern = PATTERN_UNKNOWN;
m_lastEquity = 0.0;
m_lastUpdate = 0;
m_warningActive = false;
m_lastWarningMessage = "";

// Initialize history array
for(int i = 0; i < m_maxHistorySize; i++) {
m_equityHistory[i].Reset();
}
}

//+------------------------------------------------------------------+
//| Add Equity Point                                                |
//+------------------------------------------------------------------+
void AddEquityPoint(double equity, double balance, double drawdown)
{
datetime currentTime = TimeCurrent();

// Add new point to history
if(m_historyCount < m_maxHistorySize) {
m_equityHistory[m_historyCount].time = currentTime;
m_equityHistory[m_historyCount].equity = equity;
m_equityHistory[m_historyCount].balance = balance;
m_equityHistory[m_historyCount].drawdown = drawdown;

// Calculate velocity and acceleration if we have enough data
if(m_historyCount > 0) {
double timeDiff = (double)(currentTime - m_equityHistory[m_historyCount-1].time);
if(timeDiff > 0) {
m_equityHistory[m_historyCount].velocity = 
(equity - m_equityHistory[m_historyCount-1].equity) / timeDiff;
}

if(m_historyCount > 1) {
double prevVelocity = m_equityHistory[m_historyCount-1].velocity;
m_equityHistory[m_historyCount].acceleration = 
(m_equityHistory[m_historyCount].velocity - prevVelocity) / timeDiff;
}
}

m_historyCount++;
} else {
// Shift array and add new point
for(int i = 0; i < m_maxHistorySize - 1; i++) {
m_equityHistory[i] = m_equityHistory[i+1];
}

m_equityHistory[m_maxHistorySize-1].time = currentTime;
m_equityHistory[m_maxHistorySize-1].equity = equity;
m_equityHistory[m_maxHistorySize-1].balance = balance;
m_equityHistory[m_maxHistorySize-1].drawdown = drawdown;

// Calculate velocity and acceleration
double timeDiff = (double)(currentTime - m_equityHistory[m_maxHistorySize-2].time);
if(timeDiff > 0) {
m_equityHistory[m_maxHistorySize-1].velocity = 
(equity - m_equityHistory[m_maxHistorySize-2].equity) / timeDiff;

double prevVelocity = m_equityHistory[m_maxHistorySize-2].velocity;
m_equityHistory[m_maxHistorySize-1].acceleration = 
(m_equityHistory[m_maxHistorySize-1].velocity - prevVelocity) / timeDiff;
}
}

m_lastEquity = equity;
m_lastUpdate = currentTime;

// Update convexity and pattern analysis
UpdateConvexityAnalysis();
}

//+------------------------------------------------------------------+
//| Calculate Current Convexity                                     |
//+------------------------------------------------------------------+
double CalculateConvexity()
{
if(m_historyCount < 10) return 0.0; // Need minimum data points

// Calculate convexity based on second derivative (acceleration)
double totalAcceleration = 0.0;
int validPoints = 0;

int startIndex = MathMax(0, m_historyCount - 20); // Use last 20 points
for(int i = startIndex; i < m_historyCount; i++) {
if(m_equityHistory[i].acceleration != 0.0) {
totalAcceleration += m_equityHistory[i].acceleration;
validPoints++;
}
}

if(validPoints == 0) return 0.0;

double avgAcceleration = totalAcceleration / validPoints;

// Normalize convexity value
m_currentConvexity = MathMax(-1.0, MathMin(1.0, avgAcceleration * 10000.0));

return m_currentConvexity;
}

//+------------------------------------------------------------------+
//| Determine Equity Pattern                                        |
//+------------------------------------------------------------------+
ENUM_EQUITY_PATTERN DetermineEquityPattern()
{
if(m_historyCount < 5) return PATTERN_UNKNOWN;

double convexity = CalculateConvexity();
double recentVelocity = 0.0;
double volatility = 0.0;

// Calculate recent velocity and volatility
int recentPoints = MathMin(10, m_historyCount);
double velocitySum = 0.0;
double velocitySquareSum = 0.0;

for(int i = m_historyCount - recentPoints; i < m_historyCount; i++) {
velocitySum += m_equityHistory[i].velocity;
velocitySquareSum += m_equityHistory[i].velocity * m_equityHistory[i].velocity;
}

recentVelocity = velocitySum / recentPoints;
volatility = MathSqrt(velocitySquareSum / recentPoints - recentVelocity * recentVelocity);

// Determine pattern
if(convexity > 0.05) {
if(recentVelocity > 0) {
m_currentPattern = PATTERN_ACCELERATING;
} else {
m_currentPattern = PATTERN_VOLATILE_UP;
}
} else if(convexity < -0.03) {
if(recentVelocity < 0) {
m_currentPattern = PATTERN_DANGEROUS_DECLINE;
} else {
m_currentPattern = PATTERN_VOLATILE_DOWN;
}
} else {
if(MathAbs(recentVelocity) < 0.001) {
m_currentPattern = PATTERN_SIDEWAYS;
} else if(recentVelocity > 0) {
m_currentPattern = PATTERN_SMOOTH_GROWTH;
} else {
m_currentPattern = PATTERN_DECLINING;
}
}

return m_currentPattern;
}

//+------------------------------------------------------------------+
//| Update Convexity Analysis                                       |
//+------------------------------------------------------------------+
void UpdateConvexityAnalysis()
{
CalculateConvexity();
DetermineEquityPattern();

// Check for warnings
CheckForWarnings();
}

//+------------------------------------------------------------------+
//| Check for Convexity Warnings                                   |
//+------------------------------------------------------------------+
void CheckForWarnings()
{
m_warningActive = false;
m_lastWarningMessage = "";

if(m_currentPattern == PATTERN_DANGEROUS_DECLINE) {
m_warningActive = true;
m_lastWarningMessage = "DANGEROUS EQUITY DECLINE DETECTED - REDUCE RISK IMMEDIATELY";
} else if(m_currentConvexity < -0.05) {
m_warningActive = true;
m_lastWarningMessage = "NEGATIVE CONVEXITY WARNING - EQUITY CURVE DETERIORATING";
} else if(m_currentPattern == PATTERN_VOLATILE_DOWN) {
m_warningActive = true;
m_lastWarningMessage = "VOLATILE DOWNWARD PATTERN - CONSIDER RISK REDUCTION";
}
}

//+------------------------------------------------------------------+
//| Get Risk Adjustment Factor                                      |
//+------------------------------------------------------------------+
double GetConvexityRiskAdjustment()
{
if(m_historyCount < 5) return 1.0; // Default if insufficient data

double adjustment = 1.0;

switch(m_currentPattern) {
case PATTERN_SMOOTH_GROWTH:
adjustment = 1.1; // Slight increase for healthy growth
break;
case PATTERN_ACCELERATING:
adjustment = 1.2; // Higher risk allowed for accelerating growth
break;
case PATTERN_VOLATILE_UP:
adjustment = 0.9; // Reduce risk due to volatility
break;
case PATTERN_SIDEWAYS:
adjustment = 0.8; // Reduce risk during sideways movement
break;
case PATTERN_VOLATILE_DOWN:
adjustment = 0.6; // Significant reduction for volatile decline
break;
case PATTERN_DECLINING:
adjustment = 0.5; // Major reduction for declining equity
break;
case PATTERN_DANGEROUS_DECLINE:
adjustment = 0.2; // Emergency risk reduction
break;
default:
adjustment = 1.0;
}

// Additional adjustment based on convexity value
if(m_currentConvexity > 0.05) {
adjustment *= 1.1; // Boost for positive convexity
} else if(m_currentConvexity < -0.03) {
adjustment *= 0.7; // Penalty for negative convexity
}

return MathMax(0.1, MathMin(2.0, adjustment)); // Limit range
}

//+------------------------------------------------------------------+
//| Public Getters                                                  |
//+------------------------------------------------------------------+
double GetCurrentConvexity() { return m_currentConvexity; }
ENUM_EQUITY_PATTERN GetCurrentPattern() { return m_currentPattern; }
bool HasWarning() { return m_warningActive; }
string GetWarningMessage() { return m_lastWarningMessage; }

// ADDED: Missing IsEquityCurveDangerous method
bool IsEquityCurveDangerous() { 
return (m_currentPattern == PATTERN_DANGEROUS_DECLINE || 
m_currentPattern == PATTERN_DECLINING ||
m_warningActive); 
}

//+------------------------------------------------------------------+
//| Get Status Report                                               |
//+------------------------------------------------------------------+
string GetConvexityReport()
{
string patternName;
switch(m_currentPattern) {
case PATTERN_SMOOTH_GROWTH: patternName = "SMOOTH GROWTH"; break;
case PATTERN_ACCELERATING: patternName = "ACCELERATING"; break;
case PATTERN_VOLATILE_UP: patternName = "VOLATILE UP"; break;
case PATTERN_SIDEWAYS: patternName = "SIDEWAYS"; break;
case PATTERN_VOLATILE_DOWN: patternName = "VOLATILE DOWN"; break;
case PATTERN_DECLINING: patternName = "DECLINING"; break;
case PATTERN_DANGEROUS_DECLINE: patternName = "DANGEROUS DECLINE"; break;
default: patternName = "UNKNOWN"; break;
}

string report = "?? EQUITY CURVE ANALYSIS:\n";
report += StringFormat("Convexity: %.4f\n", m_currentConvexity);
report += StringFormat("Pattern: %s\n", patternName);
report += StringFormat("Risk Adjustment: %.2f\n", GetConvexityRiskAdjustment());
report += StringFormat("Data Points: %d\n", m_historyCount);

if(m_warningActive) {
report += StringFormat("?? WARNING: %s\n", m_lastWarningMessage);
} else {
report += "? Status: HEALTHY\n";
}

return report;
}
};

#endif // RISK_EQUITYCURVECONVEXITY_MQH 


