//+------------------------------------------------------------------+
//|                                  Risk_SeasonalityCalendar.mqh   |
//|                SONIC R MC - SEASONALITY & CALENDAR EFFECTS       |
//|                   🎯 QUYẾT ĐỊNH S�? 8: SEASONALITY BREAKTHROUGH   |
//+------------------------------------------------------------------+

#ifndef RISK_SEASONALITY_CALENDAR_MQH
#define RISK_SEASONALITY_CALENDAR_MQH

#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| Calendar Effect Types                                            |
//+------------------------------------------------------------------+
enum ENUM_CALENDAR_EFFECT
{
CALENDAR_MONTHLY_CYCLE,      // Monthly pattern effects
CALENDAR_QUARTERLY_CYCLE,    // Quarterly business cycles
CALENDAR_YEARLY_CYCLE,       // Annual seasonal patterns
CALENDAR_WEEK_IN_MONTH,      // Week position in month
CALENDAR_HOLIDAY_EFFECT,     // Holiday impact
CALENDAR_ECONOMIC_EVENTS,    // Economic calendar events
CALENDAR_OPTIONS_EXPIRY,     // Options expiry effects
CALENDAR_TAX_EFFECTS        // Tax season effects
};

//+------------------------------------------------------------------+
//| Seasonality Analysis Data                                        |
//+------------------------------------------------------------------+
struct SeasonalityData
{
// Monthly effects (12 months)
double monthlyEffects[12];           // Effect strength per month
double monthlyVolatility[12];        // Volatility per month
double monthlyRiskAdjustment[12];    // Risk adjustment per month

// Weekly effects within month
double weeklyEffects[5];             // Effect for each week of month
double weeklyVolatility[5];          // Volatility per week

// Daily effects within month
double dailyEffects[31];             // Effect for each day of month

// Current assessments
double currentSeasonalEffect;        // Current seasonal effect
double currentRiskAdjustment;        // Current risk adjustment
ENUM_CALENDAR_EFFECT dominantEffect; // Most significant current effect

// Pattern recognition
bool isPositiveSeasonPeriod;         // Whether in positive season
bool isHighVolatilityPeriod;         // Whether in high volatility period
bool isTaxSeasonEffect;              // Tax season impact
bool isHolidayPeriod;               // Holiday period impact

void Initialize()
{
// Initialize monthly effects with historical patterns
// Based on general forex seasonal patterns
monthlyEffects[0] = 0.015;   // January - New Year momentum
monthlyEffects[1] = 0.012;   // February - Moderate
monthlyEffects[2] = 0.018;   // March - Quarter end
monthlyEffects[3] = 0.009;   // April - Tax season
monthlyEffects[4] = 0.005;   // May - "Sell in May"
monthlyEffects[5] = 0.003;   // June - Summer doldrums start
monthlyEffects[6] = 0.010;   // July - Mid-year adjustment
monthlyEffects[7] = 0.012;   // August - Summer recovery
monthlyEffects[8] = 0.008;   // September - Volatility return
monthlyEffects[9] = 0.015;   // October - Autumn momentum
monthlyEffects[10] = 0.017;  // November - Pre-holiday push
monthlyEffects[11] = 0.020;  // December - Year-end effects

// Initialize volatility patterns
for(int i = 0; i < 12; i++) {
if(i >= 4 && i <= 6) {
monthlyVolatility[i] = 0.8; // Lower volatility in summer
} else if(i == 0 || i >= 9) {
monthlyVolatility[i] = 1.2; // Higher volatility in winter/autumn
} else {
monthlyVolatility[i] = 1.0; // Normal volatility
}
}

// Initialize weekly effects
for(int i = 0; i < 5; i++) {
weeklyEffects[i] = 0.0;
weeklyVolatility[i] = 1.0;
}

// Initialize daily effects
for(int i = 0; i < 31; i++) {
dailyEffects[i] = 0.0;
}

currentSeasonalEffect = 0.0;
currentRiskAdjustment = 1.0;
dominantEffect = CALENDAR_MONTHLY_CYCLE;
isPositiveSeasonPeriod = false;
isHighVolatilityPeriod = false;
isTaxSeasonEffect = false;
isHolidayPeriod = false;
}

void CalculateRiskAdjustments()
{
for(int i = 0; i < 12; i++) {
if(monthlyEffects[i] > 0.015) {
monthlyRiskAdjustment[i] = 1.2; // Increase risk in good months
} else if(monthlyEffects[i] > 0.010) {
monthlyRiskAdjustment[i] = 1.0; // Normal risk
} else if(monthlyEffects[i] > 0.005) {
monthlyRiskAdjustment[i] = 0.9; // Slight reduction
} else {
monthlyRiskAdjustment[i] = 0.6; // Significant reduction in bad months
}

// Adjust for volatility
monthlyRiskAdjustment[i] *= (2.0 - monthlyVolatility[i]);
}
}
};

//+------------------------------------------------------------------+
//| Holiday and Economic Event Calendar                             |
//+------------------------------------------------------------------+
struct CalendarEventData
{
// Major holidays affecting markets
bool isNewYear;
bool isEasterWeek;
bool isThanksgivingWeek;
bool isChristmasWeek;
bool isNationalHoliday;

// Economic events
bool isNFPWeek;              // Non-Farm Payroll week
bool isFOMCWeek;             // Federal Reserve meeting
bool isECBWeek;              // European Central Bank meeting
bool isOptionsExpiryWeek;    // Major options expiry
bool isQuarterEnd;           // End of quarter
bool isYearEnd;              // End of year

// Tax periods
bool isTaxSeasonUS;          // US tax season (Mar-Apr)
bool isTaxSeasonEU;          // EU tax periods
bool isTaxSeasonJP;          // Japan tax period

// Market-specific events
bool isEarningsSeasonPeak;   // Peak earnings season
bool isDividendMonth;        // High dividend month
bool isRebalancingPeriod;    // Index rebalancing

void Reset()
{
isNewYear = false;
isEasterWeek = false;
isThanksgivingWeek = false;
isChristmasWeek = false;
isNationalHoliday = false;
isNFPWeek = false;
isFOMCWeek = false;
isECBWeek = false;
isOptionsExpiryWeek = false;
isQuarterEnd = false;
isYearEnd = false;
isTaxSeasonUS = false;
isTaxSeasonEU = false;
isTaxSeasonJP = false;
isEarningsSeasonPeak = false;
isDividendMonth = false;
isRebalancingPeriod = false;
}
};

//+------------------------------------------------------------------+
//| 🎯 SEASONALITY & CALENDAR EFFECTS MANAGER                       |
//+------------------------------------------------------------------+
class CSeasonalityCalendarManager
{
private:
SeasonalityData m_seasonalData;
CalendarEventData m_calendarEvents;

// Historical performance tracking by time period
double m_monthlyPerformance[12][3];      // [month][year_offset] - 3 years of data
double m_weeklyPerformance[53][2];       // [week][year_offset] - 2 years of data
double m_dailyPerformance[366];          // Day of year performance

// Current time analysis
int m_currentMonth;
int m_currentWeek;
int m_currentDay;
int m_currentDayOfYear;
int m_currentQuarter;
int m_weekInMonth;
double m_dayInMonthPercent;

// Seasonality parameters
bool m_enableSeasonalAdjustment;
double m_seasonalSensitivity;            // How much to adjust for seasonality
bool m_enableCalendarEffects;
double m_calendarSensitivity;            // How much to adjust for calendar events

public:
CSeasonalityCalendarManager() {
m_seasonalData.Initialize();
m_seasonalData.CalculateRiskAdjustments();
m_calendarEvents.Reset();

// Initialize performance tracking arrays
for(int i = 0; i < 12; i++) {
for(int j = 0; j < 3; j++) {
m_monthlyPerformance[i][j] = 0.0;
}
}

for(int i = 0; i < 53; i++) {
for(int j = 0; j < 2; j++) {
m_weeklyPerformance[i][j] = 0.0;
}
}

for(int i = 0; i < 366; i++) {
m_dailyPerformance[i] = 0.0;
}

// Initialize time variables
m_currentMonth = 0;
m_currentWeek = 0;
m_currentDay = 0;
m_currentDayOfYear = 0;
m_currentQuarter = 0;
m_weekInMonth = 0;
m_dayInMonthPercent = 0.0;

// Initialize parameters
m_enableSeasonalAdjustment = true;
m_seasonalSensitivity = 1.0;
m_enableCalendarEffects = true;
m_calendarSensitivity = 1.0;

::Print("[SEASONALITY] Seasonality & Calendar Effects Manager initialized");
::Print("[CONFIGURATION] Seasonal Sensitivity: ", m_seasonalSensitivity, " | Calendar Effects: ", m_enableCalendarEffects ? "ON" : "OFF");
};
~CSeasonalityCalendarManager() {}

//+------------------------------------------------------------------+
//| 🎯 MAIN SEASONALITY ADJUSTMENT CALCULATION                     |
//+------------------------------------------------------------------+
double CalculateSeasonalityAdjustment()
{
// Update current time data
UpdateCurrentTimeData();

// Analyze calendar events
AnalyzeCalendarEvents();

// Calculate seasonal effects
CalculateSeasonalEffects();

// Calculate calendar event effects
CalculateCalendarEventEffects();

// Combine all effects
CombineSeasonalAndCalendarEffects();

// Update risk adjustment
UpdateRiskAdjustment();

// Log seasonal analysis
LogSeasonalAnalysis();

return m_seasonalData.currentRiskAdjustment;
}

//+------------------------------------------------------------------+
//| 🎯 CURRENT TIME DATA UPDATE                                    |
//+------------------------------------------------------------------+
void UpdateCurrentTimeData()
{
MqlDateTime timeStruct;
TimeToStruct(TimeCurrent(), timeStruct);

m_currentMonth = timeStruct.mon - 1;        // 0-11 for array indexing
m_currentDay = timeStruct.day;
m_currentDayOfYear = timeStruct.day_of_year;

// Calculate week of year
datetime yearStart = StringToTime(IntegerToString(timeStruct.year) + ".01.01 00:00");
m_currentWeek = (int)((TimeCurrent() - yearStart) / (7 * 24 * 3600));

// Calculate quarter
m_currentQuarter = (m_currentMonth / 3) + 1;

// Calculate week within month
m_weekInMonth = ((m_currentDay - 1) / 7) + 1;

// Calculate day position within month
int daysInMonth = GetDaysInMonth(timeStruct.mon, timeStruct.year);
m_dayInMonthPercent = (double)m_currentDay / daysInMonth;
}

//+------------------------------------------------------------------+
//| 🎯 CALENDAR EVENTS ANALYSIS                                    |
//+------------------------------------------------------------------+
void AnalyzeCalendarEvents()
{
m_calendarEvents.Reset();

MqlDateTime timeStruct;
TimeToStruct(TimeCurrent(), timeStruct);

// Check for major holidays
CheckMajorHolidays(timeStruct);

// Check for economic events
CheckEconomicEvents(timeStruct);

// Check for tax periods
CheckTaxPeriods(timeStruct);

// Check for market-specific events
CheckMarketEvents(timeStruct);
}

void CheckMajorHolidays(const MqlDateTime& timeStruct)
{
// New Year period (late December to early January)
if((timeStruct.mon == 12 && timeStruct.day >= 25) || 
(timeStruct.mon == 1 && timeStruct.day <= 7)) {
m_calendarEvents.isNewYear = true;
}

// Christmas week
if(timeStruct.mon == 12 && timeStruct.day >= 20) {
m_calendarEvents.isChristmasWeek = true;
}

// Thanksgiving week (4th Thursday of November in US)
if(timeStruct.mon == 11 && timeStruct.day >= 22 && timeStruct.day <= 28) {
m_calendarEvents.isThanksgivingWeek = true;
}

// Easter week (simplified - typically March/April)
if((timeStruct.mon == 3 || timeStruct.mon == 4) && 
(timeStruct.day_of_week >= 0 && timeStruct.day_of_week <= 1)) {
m_calendarEvents.isEasterWeek = true;
}
}

void CheckEconomicEvents(const MqlDateTime& timeStruct)
{
// Non-Farm Payroll (first Friday of month)
if(timeStruct.day <= 7 && timeStruct.day_of_week == 5) {
m_calendarEvents.isNFPWeek = true;
}

// FOMC meetings (approximately 8 times per year, specific dates)
// Simplified check for typical FOMC months
if((timeStruct.mon == 1 || timeStruct.mon == 3 || timeStruct.mon == 5 || 
timeStruct.mon == 6 || timeStruct.mon == 9 || timeStruct.mon == 11 || timeStruct.mon == 12) &&
(timeStruct.day >= 15 && timeStruct.day <= 25)) {
m_calendarEvents.isFOMCWeek = true;
}

// Options expiry (third Friday of month)
if(timeStruct.day >= 15 && timeStruct.day <= 21 && timeStruct.day_of_week == 5) {
m_calendarEvents.isOptionsExpiryWeek = true;
}

// Quarter end
if((timeStruct.mon == 3 || timeStruct.mon == 6 || timeStruct.mon == 9 || timeStruct.mon == 12) &&
timeStruct.day >= 25) {
m_calendarEvents.isQuarterEnd = true;
}

// Year end
if(timeStruct.mon == 12 && timeStruct.day >= 15) {
m_calendarEvents.isYearEnd = true;
}
}

void CheckTaxPeriods(const MqlDateTime& timeStruct)
{
// US tax season (March-April)
if(timeStruct.mon == 3 || timeStruct.mon == 4) {
m_calendarEvents.isTaxSeasonUS = true;
}

// EU tax periods (varies by country, but often Q1)
if(timeStruct.mon >= 1 && timeStruct.mon <= 3) {
m_calendarEvents.isTaxSeasonEU = true;
}

// Japan tax year end (March)
if(timeStruct.mon == 3) {
m_calendarEvents.isTaxSeasonJP = true;
}
}

void CheckMarketEvents(const MqlDateTime& timeStruct)
{
// Earnings season peak (typically January, April, July, October)
if(timeStruct.mon == 1 || timeStruct.mon == 4 || timeStruct.mon == 7 || timeStruct.mon == 10) {
if(timeStruct.day >= 15 && timeStruct.day <= 31) {
m_calendarEvents.isEarningsSeasonPeak = true;
}
}

// High dividend months (typically March, June, September, December)
if(timeStruct.mon == 3 || timeStruct.mon == 6 || timeStruct.mon == 9 || timeStruct.mon == 12) {
m_calendarEvents.isDividendMonth = true;
}

// Index rebalancing (typically quarter ends)
if(m_calendarEvents.isQuarterEnd) {
m_calendarEvents.isRebalancingPeriod = true;
}
}

//+------------------------------------------------------------------+
//| 🎯 SEASONAL EFFECTS CALCULATION                                |
//+------------------------------------------------------------------+
void CalculateSeasonalEffects()
{
// Monthly effect
double monthlyEffect = m_seasonalData.monthlyEffects[m_currentMonth];

// Weekly effect within month
double weeklyEffect = 0.0;
if(m_weekInMonth >= 1 && m_weekInMonth <= 5) {
weeklyEffect = m_seasonalData.weeklyEffects[m_weekInMonth - 1];
}

// Day of month effect
double dailyEffect = CalculateDayOfMonthEffect();

// Combine seasonal effects
m_seasonalData.currentSeasonalEffect = monthlyEffect + weeklyEffect + dailyEffect;

// Determine seasonal characteristics
m_seasonalData.isPositiveSeasonPeriod = (monthlyEffect > 0.010);
m_seasonalData.isHighVolatilityPeriod = (m_seasonalData.monthlyVolatility[m_currentMonth] > 1.1);
}

double CalculateDayOfMonthEffect()
{
// Day of month patterns
if(m_dayInMonthPercent < 0.2) {
return -0.005; // Beginning of month - typically bearish (bill paying)
} else if(m_dayInMonthPercent < 0.4) {
return 0.002;  // Early-mid month
} else if(m_dayInMonthPercent < 0.6) {
return 0.008;  // Mid month - typically bullish (salary payments)
} else if(m_dayInMonthPercent < 0.8) {
return 0.003;  // Late-mid month
} else {
return -0.007; // End of month - typically bearish (portfolio rebalancing)
}
}

//+------------------------------------------------------------------+
//| 🎯 CALENDAR EVENT EFFECTS CALCULATION                          |
//+------------------------------------------------------------------+
void CalculateCalendarEventEffects()
{
double calendarEffect = 0.0;

// Holiday effects (generally reduce volatility and activity)
if(m_calendarEvents.isNewYear) calendarEffect -= 0.015;
if(m_calendarEvents.isChristmasWeek) calendarEffect -= 0.020;
if(m_calendarEvents.isThanksgivingWeek) calendarEffect -= 0.010;
if(m_calendarEvents.isEasterWeek) calendarEffect -= 0.008;

// Economic event effects (generally increase volatility)
if(m_calendarEvents.isNFPWeek) calendarEffect += 0.012;
if(m_calendarEvents.isFOMCWeek) calendarEffect += 0.015;
if(m_calendarEvents.isECBWeek) calendarEffect += 0.010;
if(m_calendarEvents.isOptionsExpiryWeek) calendarEffect += 0.008;

// Period-end effects
if(m_calendarEvents.isQuarterEnd) calendarEffect += 0.010;
if(m_calendarEvents.isYearEnd) calendarEffect += 0.015;

// Tax effects (vary by region)
if(m_calendarEvents.isTaxSeasonUS) calendarEffect -= 0.005;
if(m_calendarEvents.isTaxSeasonJP) calendarEffect -= 0.008;

// Market event effects
if(m_calendarEvents.isEarningsSeasonPeak) calendarEffect += 0.005;
if(m_calendarEvents.isRebalancingPeriod) calendarEffect += 0.007;

// Update calendar flags
m_seasonalData.isHolidayPeriod = (m_calendarEvents.isNewYear || m_calendarEvents.isChristmasWeek || 
m_calendarEvents.isThanksgivingWeek || m_calendarEvents.isEasterWeek);
m_seasonalData.isTaxSeasonEffect = (m_calendarEvents.isTaxSeasonUS || m_calendarEvents.isTaxSeasonEU || 
m_calendarEvents.isTaxSeasonJP);

// Store calendar effect (could be used for further analysis)
// m_calendarEventEffect = calendarEffect; // If we had this member variable
}

//+------------------------------------------------------------------+
//| 🎯 COMBINE EFFECTS AND CALCULATE RISK ADJUSTMENT               |
//+------------------------------------------------------------------+
void CombineSeasonalAndCalendarEffects()
{
// Base seasonal effect
double totalEffect = m_seasonalData.currentSeasonalEffect;

// Apply calendar event modifications
// (This is simplified - in reality you'd want more sophisticated combining)

// Adjust for dominant effect type
if(m_seasonalData.isHolidayPeriod) {
m_seasonalData.dominantEffect = CALENDAR_HOLIDAY_EFFECT;
} else if(m_seasonalData.isTaxSeasonEffect) {
m_seasonalData.dominantEffect = CALENDAR_TAX_EFFECTS;
} else if(m_calendarEvents.isQuarterEnd) {
m_seasonalData.dominantEffect = CALENDAR_QUARTERLY_CYCLE;
} else if(m_calendarEvents.isNFPWeek || m_calendarEvents.isFOMCWeek) {
m_seasonalData.dominantEffect = CALENDAR_ECONOMIC_EVENTS;
} else {
m_seasonalData.dominantEffect = CALENDAR_MONTHLY_CYCLE;
}

// Update total seasonal effect
m_seasonalData.currentSeasonalEffect = totalEffect;
}

void UpdateRiskAdjustment()
{
// Start with monthly base adjustment
double adjustment = m_seasonalData.monthlyRiskAdjustment[m_currentMonth];

// Apply seasonal effect modifications
if(m_seasonalData.currentSeasonalEffect > 0.015) {
adjustment *= 1.2; // Increase risk in very positive periods
} else if(m_seasonalData.currentSeasonalEffect > 0.010) {
adjustment *= 1.0; // Normal risk in good periods
} else if(m_seasonalData.currentSeasonalEffect > 0.005) {
adjustment *= 0.9; // Slight reduction in average periods
} else if(m_seasonalData.currentSeasonalEffect > 0.000) {
adjustment *= 0.8; // Reduce risk in weak periods
} else {
adjustment *= 0.6; // Significantly reduce in negative periods
}

// Apply calendar event adjustments
if(m_seasonalData.isHolidayPeriod) {
adjustment *= 0.7; // Reduce risk during holidays
}

if(m_seasonalData.isTaxSeasonEffect) {
adjustment *= 0.8; // Reduce risk during tax seasons
}

if(m_calendarEvents.isNFPWeek || m_calendarEvents.isFOMCWeek) {
adjustment *= 0.9; // Slightly reduce risk during major events
}

if(m_calendarEvents.isYearEnd) {
adjustment *= 1.1; // Slightly increase for year-end momentum
}

// Apply sensitivity factor
double neutralAdjustment = 1.0;
adjustment = neutralAdjustment + (adjustment - neutralAdjustment) * m_seasonalSensitivity;

// Ensure reasonable bounds
m_seasonalData.currentRiskAdjustment = MathMax(0.4, MathMin(1.5, adjustment));
}

//+------------------------------------------------------------------+
//| 🎯 HELPER METHODS                                              |
//+------------------------------------------------------------------+
int GetDaysInMonth(int month, int year)
{
int daysInMonth[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

// Check for leap year in February
if(month == 2) {
if((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
return 29; // Leap year
}
}

return daysInMonth[month - 1];
}

void LogSeasonalAnalysis()
{
static datetime lastLog = 0;
if(TimeCurrent() - lastLog < 86400) return; // Log once per day

::Print(StringFormat("[SEASONALITY] Month: %d | Effect: %.3f | Adjustment: %.2fx | Dominant: %s",
m_currentMonth + 1,
m_seasonalData.currentSeasonalEffect,
m_seasonalData.currentRiskAdjustment,
CalendarEffectToString(m_seasonalData.dominantEffect)));

if(m_seasonalData.isHolidayPeriod) {
::Print("[SEASONALITY] Holiday period detected - reducing risk");
}

if(m_seasonalData.isTaxSeasonEffect) {
::Print("[SEASONALITY] Tax season effect active - adjusting risk");
}

lastLog = TimeCurrent();
}

string CalendarEffectToString(ENUM_CALENDAR_EFFECT effect)
{
switch(effect) {
case CALENDAR_MONTHLY_CYCLE: return "MONTHLY";
case CALENDAR_QUARTERLY_CYCLE: return "QUARTERLY";
case CALENDAR_YEARLY_CYCLE: return "YEARLY";
case CALENDAR_WEEK_IN_MONTH: return "WEEKLY";
case CALENDAR_HOLIDAY_EFFECT: return "HOLIDAY";
case CALENDAR_ECONOMIC_EVENTS: return "ECONOMIC";
case CALENDAR_OPTIONS_EXPIRY: return "OPTIONS";
case CALENDAR_TAX_EFFECTS: return "TAX";
default: return "UNKNOWN";
}
}

// Public interface methods
double GetSeasonalRiskAdjustment() const { return m_seasonalData.currentRiskAdjustment; }
SeasonalityData GetSeasonalData() const { return m_seasonalData; }
CalendarEventData GetCalendarEvents() const { return m_calendarEvents; }
bool IsHolidayPeriod() const { return m_seasonalData.isHolidayPeriod; }
bool IsPositiveSeasonPeriod() const { return m_seasonalData.isPositiveSeasonPeriod; }

void SetSeasonalSensitivity(double sensitivity) 
{ 
m_seasonalSensitivity = MathMax(0.0, MathMin(2.0, sensitivity)); 
}

void EnableSeasonalAdjustment(bool enable) { m_enableSeasonalAdjustment = enable; }
void EnableCalendarEffects(bool enable) { m_enableCalendarEffects = enable; }

string GetSeasonalityReport()
{
return StringFormat(
"SEASONALITY & CALENDAR EFFECTS\n" +
"Current Month: %d (%s)\n" +
"Seasonal Effect: %.3f\n" +
"Risk Adjustment: %.2fx\n" +
"Dominant Effect: %s\n" +
"Holiday Period: %s\n" +
"Tax Season: %s\n" +
"Positive Season: %s\n" +
"High Volatility Period: %s\n" +
"Day in Month: %.1f%% | Week in Month: %d",
m_currentMonth + 1,
GetMonthName(m_currentMonth + 1),
m_seasonalData.currentSeasonalEffect,
m_seasonalData.currentRiskAdjustment,
CalendarEffectToString(m_seasonalData.dominantEffect),
m_seasonalData.isHolidayPeriod ? "YES" : "NO",
m_seasonalData.isTaxSeasonEffect ? "YES" : "NO",
m_seasonalData.isPositiveSeasonPeriod ? "YES" : "NO",
m_seasonalData.isHighVolatilityPeriod ? "YES" : "NO",
m_dayInMonthPercent * 100,
m_weekInMonth
);
}

string GetMonthName(int month)
{
string months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", 
"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
if(month >= 1 && month <= 12) return months[month - 1];
return "Unknown";
}
};


#endif // RISK_SEASONALITY_CALENDAR_MQH


