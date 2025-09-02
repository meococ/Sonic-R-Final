//+------------------------------------------------------------------+
//|             01_Core_09_SharedDataStructures.mqh                  |
//|                SONIC R MC - Shared Data Structures               |
//|                     �?i B�ng Architecture - Context Layer        |
//+------------------------------------------------------------------+
#ifndef CORE_09_SHARED_DATA_STRUCTURES_MQH
#define CORE_09_SHARED_DATA_STRUCTURES_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| EA CONTEXT CLASS                                                 |
//+------------------------------------------------------------------+
class CEaContext
{
private:
    // System state
    bool m_isInitialized;                // Initialization state
    bool m_tradingAllowed;               // Trading allowed flag
    datetime m_lastUpdate;               // Last update time
    string m_symbol;                     // Current symbol
    ENUM_TIMEFRAMES m_timeframe;         // Current timeframe

    // Trading state
    ENUM_TRADING_STRATEGY m_strategy;    // Current strategy
    ENUM_TRADING_SCENARIO m_scenario;    // Current scenario
    double m_riskPercent;                // Risk percentage
    double m_maxDailyDrawdown;           // Max daily drawdown
    int m_maxDailyTrades;                // Max daily trades

    // Performance tracking
    double m_dailyProfit;                // Daily profit
    double m_dailyDrawdown;              // Daily drawdown
    int m_dailyTrades;                   // Daily trade count
    int m_totalTrades;                   // Total trade count
    double m_totalProfit;                // Total profit

    // Error handling
    int m_errorCount;                    // Error count
    string m_lastError;                  // Last error message
    datetime m_lastErrorTime;            // Last error time

public:
    // Constructor/Destructor
    CEaContext()
    {
        m_isInitialized = false;
        m_tradingAllowed = true;
        m_lastUpdate = TimeCurrent();
        m_symbol = _Symbol;
        m_timeframe = PERIOD_M15;
        m_strategy = STRATEGY_SONIC_R;
        m_scenario = SCENARIO_SONIC_R_BASIC;
        m_riskPercent = 1.0;
        m_maxDailyDrawdown = 5.0;
        m_maxDailyTrades = 5;
        m_dailyProfit = 0.0;
        m_dailyDrawdown = 0.0;
        m_dailyTrades = 0;
        m_totalTrades = 0;
        m_totalProfit = 0.0;
        m_errorCount = 0;
        m_lastError = "";
        m_lastErrorTime = 0;
    }

    ~CEaContext() {}

    // Initialization
    bool Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
    {
        m_symbol = symbol;
        m_timeframe = timeframe;
        m_isInitialized = true;
        m_lastUpdate = TimeCurrent();
        return true;
    }

    // Getters
    bool IsInitialized() const { return m_isInitialized; }
    bool IsTradingAllowed() const { return m_tradingAllowed; }
    string GetSymbol() const { return m_symbol; }
    ENUM_TIMEFRAMES GetTimeframe() const { return m_timeframe; }
    ENUM_TRADING_STRATEGY GetStrategy() const { return m_strategy; }
    ENUM_TRADING_SCENARIO GetScenario() const { return m_scenario; }
    double GetRiskPercent() const { return m_riskPercent; }
    double GetMaxDailyDrawdown() const { return m_maxDailyDrawdown; }
    int GetMaxDailyTrades() const { return m_maxDailyTrades; }
    double GetDailyProfit() const { return m_dailyProfit; }
    double GetDailyDrawdown() const { return m_dailyDrawdown; }
    int GetDailyTrades() const { return m_dailyTrades; }
    int GetTotalTrades() const { return m_totalTrades; }
    double GetTotalProfit() const { return m_totalProfit; }
    int GetErrorCount() const { return m_errorCount; }
    string GetLastError() const { return m_lastError; }
    datetime GetLastErrorTime() const { return m_lastErrorTime; }

    // Setters
    void SetTradingAllowed(bool allowed) { m_tradingAllowed = allowed; }
    void SetStrategy(ENUM_TRADING_STRATEGY strategy) { m_strategy = strategy; }
    void SetScenario(ENUM_TRADING_SCENARIO scenario) { m_scenario = scenario; }
    void SetRiskPercent(double risk) { m_riskPercent = risk; }
    void SetMaxDailyDrawdown(double drawdown) { m_maxDailyDrawdown = drawdown; }
    void SetMaxDailyTrades(int trades) { m_maxDailyTrades = trades; }

    // Performance tracking
    void AddTrade(double profit)
    {
        m_dailyTrades++;
        m_totalTrades++;
        m_dailyProfit += profit;
        m_totalProfit += profit;
        if(profit < 0) m_dailyDrawdown += MathAbs(profit);
        m_lastUpdate = TimeCurrent();
    }

    void ResetDaily()
    {
        m_dailyProfit = 0.0;
        m_dailyDrawdown = 0.0;
        m_dailyTrades = 0;
        m_lastUpdate = TimeCurrent();
    }

    // Error handling
    void AddError(string error)
    {
        m_errorCount++;
        m_lastError = error;
        m_lastErrorTime = TimeCurrent();
    }

    void ClearErrors()
    {
        m_errorCount = 0;
        m_lastError = "";
        m_lastErrorTime = 0;
    }

    // Update
    void Update()
    {
        m_lastUpdate = TimeCurrent();
    }
};

//+------------------------------------------------------------------+
//| GLOBAL CONTEXT INSTANCE                                          |
//+------------------------------------------------------------------+
// Wave result primitives stash for cross-layer use (no heavy types)
bool   g_haveLastWavePivots = false;
double g_lastWaveLeg2Price  = 0.0;
int    g_lastWaveDir        = 0; // ENUM_SIGNAL_TYPE as int
datetime g_lastWaveBarTime   = 0;


// Global context instance (defined here)
CEaContext g_Context;

#endif // CORE_09_SHARED_DATA_STRUCTURES_MQH
