//+------------------------------------------------------------------+
//|                                          Risk_VaRCalculator.mqh  |
//|                  SONIC R MC - Value at Risk Calculator          |
//|                     Phase 4: Institutional Risk Management      |
//+------------------------------------------------------------------+
#ifndef RISK_VAR_CALCULATOR_MQH
#define RISK_VAR_CALCULATOR_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_08_ContextManager.mqh"

//+------------------------------------------------------------------+
//| Local helper: stringify VAR method                               |
//+------------------------------------------------------------------+
string VarMethodToStringLocal(ENUM_VAR_METHOD method)
{
	switch(method)
	{
		case VAR_HISTORICAL:   return "Historical";
		case VAR_PARAMETRIC:   return "Parametric";
		case VAR_MONTE_CARLO:  return "Monte Carlo";
		default:               return "Unknown";
	}
}

//+------------------------------------------------------------------+
//| VaR Calculation Methods                                          |
//+------------------------------------------------------------------+
// ENUM_VAR_METHOD moved to SonicEnums.mqh for proper include order

//+------------------------------------------------------------------+
//| VaR/CVaR Calculator Class                                        |
//+------------------------------------------------------------------+
class CVaRCalculator
{
private:
// Configuration
double              m_confidenceLevel;    // 95% or 99%
int                 m_lookbackPeriod;     // Days for historical data
ENUM_VAR_METHOD     m_method;

// Historical data
double              m_returns[];          // Daily returns
double              m_portfolioValues[];  // Portfolio values
int                 m_dataCount;

// Results
double              m_var1Day;            // 1-day VaR
double              m_var1Week;           // 1-week VaR
double              m_cvar1Day;           // 1-day CVaR (Expected Shortfall)
double              m_cvar1Week;          // 1-week CVaR
datetime            m_lastCalculation;

// Monte Carlo parameters
int                 m_simulations;        // Number of simulations
double              m_drift;              // Mean return
double              m_volatility;         // Standard deviation

public:
CVaRCalculator() : 
m_confidenceLevel(0.95),
m_lookbackPeriod(252),    // 1 year
m_method(VAR_HISTORICAL),
m_dataCount(0),
m_var1Day(0),
m_var1Week(0),
m_cvar1Day(0),
m_cvar1Week(0),
m_lastCalculation(0),
m_simulations(10000),
m_drift(0),
m_volatility(0)
{
ArrayResize(m_returns, m_lookbackPeriod);
ArrayResize(m_portfolioValues, m_lookbackPeriod);
}

~CVaRCalculator() {}

//+------------------------------------------------------------------+
//| Initialize calculator with parameters                            |
//+------------------------------------------------------------------+
bool Initialize(double confidenceLevel = 0.95, int lookback = 252, ENUM_VAR_METHOD method = VAR_HISTORICAL)
{
m_confidenceLevel = confidenceLevel;
m_lookbackPeriod = lookback;
m_method = method;

ArrayResize(m_returns, m_lookbackPeriod);
ArrayResize(m_portfolioValues, m_lookbackPeriod);

// Load historical data
return LoadHistoricalData();
}

//+------------------------------------------------------------------+
//| Load historical returns data                                     |
//+------------------------------------------------------------------+
bool LoadHistoricalData()
{
m_dataCount = 0;

// Get account history
if(!HistorySelect(TimeCurrent() - m_lookbackPeriod * 86400, TimeCurrent()))
return false;

int deals = HistoryDealsTotal();
if(deals == 0) return false;

// Calculate daily returns from closed trades
double previousBalance = AccountInfoDouble(ACCOUNT_BALANCE);
datetime previousDate = 0;
double dailyReturn = 0;

for(int i = 0; i < deals && m_dataCount < m_lookbackPeriod; i++)
{
ulong ticket = HistoryDealGetTicket(i);
if(!HistoryDealSelect(ticket)) continue;

datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
double commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);

// Check if new day
MqlDateTime dt;
TimeToStruct(dealTime, dt);
datetime currentDate = StringToTime(StringFormat("%04d.%02d.%02d", dt.year, dt.mon, dt.day));

if(currentDate != previousDate && previousDate != 0)
{
// Calculate daily return
m_returns[m_dataCount] = dailyReturn / previousBalance;
m_portfolioValues[m_dataCount] = previousBalance;
m_dataCount++;
dailyReturn = 0;
}

dailyReturn += profit + commission + swap;
previousDate = currentDate;
}

// If not enough real data, generate synthetic data
if(m_dataCount < 30)
{
GenerateSyntheticData();
}

return true;
}

//+------------------------------------------------------------------+
//| Generate synthetic returns for testing                           |
//+------------------------------------------------------------------+
void GenerateSyntheticData()
{
// Use typical market parameters
m_drift = 0.0002;      // 0.02% daily return (5% annual)
m_volatility = 0.01;   // 1% daily volatility (16% annual)

MathSrand(GetTickCount());

for(int i = m_dataCount; i < m_lookbackPeriod; i++)
{
// Generate normally distributed returns
double z = GenerateNormalRandom();
m_returns[i] = m_drift + m_volatility * z;

if(i == 0)
m_portfolioValues[i] = AccountInfoDouble(ACCOUNT_BALANCE);
else
m_portfolioValues[i] = m_portfolioValues[i-1] * (1 + m_returns[i]);
}

m_dataCount = m_lookbackPeriod;
}

//+------------------------------------------------------------------+
//| Calculate VaR and CVaR                                           |
//+------------------------------------------------------------------+
bool Calculate()
{
if(m_dataCount < 30) return false;

switch(m_method)
{
case VAR_HISTORICAL:
return CalculateHistoricalVaR();

case VAR_PARAMETRIC:
return CalculateParametricVaR();

case VAR_MONTE_CARLO:
return CalculateMonteCarloVaR();

default:
return false;
}
}

//+------------------------------------------------------------------+
//| Historical simulation method                                     |
//+------------------------------------------------------------------+
bool CalculateHistoricalVaR()
{
// Sort returns
double sortedReturns[];
ArrayResize(sortedReturns, m_dataCount);
ArrayCopy(sortedReturns, m_returns, 0, 0, m_dataCount);
ArraySort(sortedReturns);

// Calculate VaR index
int varIndex = (int)((1 - m_confidenceLevel) * m_dataCount);
if(varIndex >= m_dataCount) varIndex = m_dataCount - 1;
if(varIndex < 0) varIndex = 0;

// 1-day VaR (as positive number)
m_var1Day = -sortedReturns[varIndex];

// 1-week VaR (square root of time)
m_var1Week = m_var1Day * MathSqrt(5);

// Calculate CVaR (Expected Shortfall)
double sumTailLosses = 0;
int tailCount = 0;

for(int i = 0; i <= varIndex; i++)
{
sumTailLosses += sortedReturns[i];
tailCount++;
}

m_cvar1Day = tailCount > 0 ? -sumTailLosses / tailCount : m_var1Day;
m_cvar1Week = m_cvar1Day * MathSqrt(5);

m_lastCalculation = TimeCurrent();

return true;
}

//+------------------------------------------------------------------+
//| Parametric (variance-covariance) method                          |
//+------------------------------------------------------------------+
bool CalculateParametricVaR()
{
// Calculate mean and standard deviation
double mean = 0;
double variance = 0;

for(int i = 0; i < m_dataCount; i++)
{
mean += m_returns[i];
}
mean /= m_dataCount;

for(int i = 0; i < m_dataCount; i++)
{
variance += MathPow(m_returns[i] - mean, 2);
}
variance /= (m_dataCount - 1);
double stdDev = MathSqrt(variance);

// Z-score for confidence level
double zScore = GetZScore(m_confidenceLevel);

// Calculate VaR
m_var1Day = -(mean - zScore * stdDev);
m_var1Week = -(mean * 5 - zScore * stdDev * MathSqrt(5));

// CVaR for normal distribution
double phi = NormalPDF(-zScore);
double cdfInverse = 1 - m_confidenceLevel;
m_cvar1Day = stdDev * phi / cdfInverse - mean;
m_cvar1Week = m_cvar1Day * MathSqrt(5);

m_lastCalculation = TimeCurrent();

return true;
}

//+------------------------------------------------------------------+
//| Monte Carlo simulation method                                    |
//+------------------------------------------------------------------+
bool CalculateMonteCarloVaR()
{
// Calculate drift and volatility from historical data
double mean = 0;
double variance = 0;

for(int i = 0; i < m_dataCount; i++)
{
mean += m_returns[i];
}
mean /= m_dataCount;

for(int i = 0; i < m_dataCount; i++)
{
variance += MathPow(m_returns[i] - mean, 2);
}
variance /= (m_dataCount - 1);
m_volatility = MathSqrt(variance);
m_drift = mean;

// Run simulations
double simulatedReturns[];
ArrayResize(simulatedReturns, m_simulations);

for(int i = 0; i < m_simulations; i++)
{
// Generate random return
double z = GenerateNormalRandom();
simulatedReturns[i] = m_drift + m_volatility * z;
}

// Sort simulated returns
ArraySort(simulatedReturns);

// Calculate VaR
int varIndex = (int)((1 - m_confidenceLevel) * m_simulations);
m_var1Day = -simulatedReturns[varIndex];

// Weekly VaR using multi-day simulation
double weeklyReturns[];
ArrayResize(weeklyReturns, m_simulations);

for(int i = 0; i < m_simulations; i++)
{
double weekReturn = 0;
for(int day = 0; day < 5; day++)
{
double z = GenerateNormalRandom();
weekReturn += m_drift + m_volatility * z;
}
weeklyReturns[i] = weekReturn;
}

ArraySort(weeklyReturns);
m_var1Week = -weeklyReturns[varIndex];

// Calculate CVaR
double sumTailLosses = 0;
int tailCount = 0;

for(int i = 0; i <= varIndex; i++)
{
sumTailLosses += simulatedReturns[i];
tailCount++;
}

m_cvar1Day = tailCount > 0 ? -sumTailLosses / tailCount : m_var1Day;

// Weekly CVaR
sumTailLosses = 0;
for(int i = 0; i <= varIndex; i++)
{
sumTailLosses += weeklyReturns[i];
}
m_cvar1Week = tailCount > 0 ? -sumTailLosses / tailCount : m_var1Week;

m_lastCalculation = TimeCurrent();

return true;
}

//+------------------------------------------------------------------+
//| Helper: Generate normal random number (Box-Muller)              |
//+------------------------------------------------------------------+
double GenerateNormalRandom()
{
static bool hasSpare = false;
static double spare;

if(hasSpare)
{
hasSpare = false;
return spare;
}

hasSpare = true;

double u, v, s;
do
{
u = (MathRand() / 32767.0) * 2.0 - 1.0;
v = (MathRand() / 32767.0) * 2.0 - 1.0;
s = u * u + v * v;
}
while(s >= 1.0 || s == 0.0);

s = MathSqrt(-2.0 * MathLog(s) / s);
spare = v * s;
return u * s;
}

//+------------------------------------------------------------------+
//| Get Z-score for confidence level                                 |
//+------------------------------------------------------------------+
double GetZScore(double confidence)
{
// Common confidence levels
if(confidence == 0.90) return 1.282;
if(confidence == 0.95) return 1.645;
if(confidence == 0.99) return 2.326;

// For other levels, use approximation
return -NormalQuantile(1 - confidence);
}

//+------------------------------------------------------------------+
//| Normal PDF                                                       |
//+------------------------------------------------------------------+
double NormalPDF(double x)
{
return MathExp(-0.5 * x * x) / MathSqrt(2 * M_PI);
}

//+------------------------------------------------------------------+
//| Approximate normal quantile function                             |
//+------------------------------------------------------------------+
double NormalQuantile(double p)
{
// Beasley-Springer-Moro algorithm approximation
double a[4] = {2.50662823884, -18.61500062529, 41.39119773534, -25.44106049637};
double b[4] = {-8.47351093090, 23.08336743743, -21.06224101826, 3.13082909833};
double c[9] = {0.3374754822726147, 0.9761690190917186, 0.1607979714918209,
               0.0276438810333863, 0.0038405729373609, 0.0003951896511919,
               0.0000321767881768, 0.0000002888167364, 0.0000003960315187};

double y = p - 0.5;
double r, x;

if(MathAbs(y) < 0.42)
{
r = y * y;
x = y * (((a[3] * r + a[2]) * r + a[1]) * r + a[0]) /
((((b[3] * r + b[2]) * r + b[1]) * r + b[0]) * r + 1.0);
}
else
{
r = p;
if(y > 0) r = 1 - p;
r = MathLog(-MathLog(r));
x = c[0] + r * (c[1] + r * (c[2] + r * (c[3] + r * (c[4] + r * 
(c[5] + r * (c[6] + r * (c[7] + r * c[8])))))));
if(y < 0) x = -x;
}

return x;
}

//+------------------------------------------------------------------+
//| Get calculated VaR values                                        |
//+------------------------------------------------------------------+
double GetVaR1Day() const { return m_var1Day; }
double GetVaR1Week() const { return m_var1Week; }
double GetCVaR1Day() const { return m_cvar1Day; }
double GetCVaR1Week() const { return m_cvar1Week; }

//+------------------------------------------------------------------+
//| Get VaR in currency terms                                        |
//+------------------------------------------------------------------+
double GetVaR1DayAmount()
{
double portfolioValue = AccountInfoDouble(ACCOUNT_EQUITY);
return portfolioValue * m_var1Day;
}

double GetVaR1WeekAmount()
{
double portfolioValue = AccountInfoDouble(ACCOUNT_EQUITY);
return portfolioValue * m_var1Week;
}

//+------------------------------------------------------------------+
//| Get detailed VaR report                                          |
//+------------------------------------------------------------------+
string GetVaRReport()
{
double equity = AccountInfoDouble(ACCOUNT_EQUITY);

string report = "=== VaR/CVaR REPORT ===\n";
report += StringFormat("Method: %s\n", VarMethodToStringLocal(m_method));
report += StringFormat("Confidence Level: %.0f%%\n", m_confidenceLevel * 100);
report += StringFormat("Data Points: %d\n\n", m_dataCount);

report += "1-Day Risk Metrics:\n";
report += StringFormat("VaR: %.2f%% ($%.2f)\n", m_var1Day * 100, equity * m_var1Day);
report += StringFormat("CVaR: %.2f%% ($%.2f)\n\n", m_cvar1Day * 100, equity * m_cvar1Day);

report += "1-Week Risk Metrics:\n";
report += StringFormat("VaR: %.2f%% ($%.2f)\n", m_var1Week * 100, equity * m_var1Week);
report += StringFormat("CVaR: %.2f%% ($%.2f)\n", m_cvar1Week * 100, equity * m_cvar1Week);

return report;
}

//+------------------------------------------------------------------+
//| Check if current drawdown exceeds VaR                           |
//+------------------------------------------------------------------+
bool IsVaRBreached()
{
double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double equity = AccountInfoDouble(ACCOUNT_EQUITY);
double currentDrawdown = (balance - equity) / balance;

return currentDrawdown > m_var1Day;
}

//+------------------------------------------------------------------+
//| Adjust position size based on VaR                               |
//+------------------------------------------------------------------+
double GetVaRAdjustedPositionSize(double baseSize, double maxVaRPercent = 2.0)
{
// Ensure VaR doesn't exceed maxVaRPercent of equity
double currentVaRAmount = GetVaR1DayAmount();
double maxVaRAmount = AccountInfoDouble(ACCOUNT_EQUITY) * maxVaRPercent / 100;

if(currentVaRAmount > maxVaRAmount)
{
// Reduce position size proportionally
double reductionFactor = maxVaRAmount / currentVaRAmount;
return NormalizeDouble(baseSize * reductionFactor, 2);
}

return baseSize;
}
};

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES DEFINITIONS                                     |
//+------------------------------------------------------------------+
// Define global variables that are declared as extern in other files
CVaRCalculator* g_VaRCalculator = NULL;

#endif // RISK_VAR_CALCULATOR_MQH


