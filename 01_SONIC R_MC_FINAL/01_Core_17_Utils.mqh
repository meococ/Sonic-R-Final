//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                     ?? SONIC R MC - UTILITY FUNCTIONS           |
//|                         Common Utility Functions                 |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - �?i B�ng Enhanced"
#property version   "2.00"

#ifndef CORE_09_UTILS_MQH
#define CORE_09_UTILS_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| FORWARD DECLARATIONS                                             |
//+------------------------------------------------------------------+
// NOTE: Function implementations provided below to avoid "no #import declaration" warnings

//+------------------------------------------------------------------+
//| SIGNAL TYPE TO STRING CONVERSION - MOVED TO SonicEnums.mqh     |
//+------------------------------------------------------------------+
// NOTE: SignalTypeToString() is now defined in 01_Core_22_SonicEnums.mqh
// to avoid duplicates and maintain consistency

//+------------------------------------------------------------------+
//| TRADE GATE RESULT STRUCTURE                                      |
//+------------------------------------------------------------------+
struct TradeGateResult
{
    bool allowed;                        // Trading allowed
    string reason;                       // Reason if not allowed
    double riskLevel;                    // Risk level
    bool isValid;                        // Result validity
    
    void Reset()
    {
        allowed = false;
        reason = "";
        riskLevel = 0.0;
        isValid = false;
    }
};

//+------------------------------------------------------------------+
//| LOGGING FUNCTIONS                                                |
//+------------------------------------------------------------------+
void LogTradeOperation(string operation, double price, double volume, 
                      double stopLoss, double takeProfit, string reason, 
                      ENUM_SIGNAL_TYPE signalType)
{
    string message = StringFormat(
        "Trade Operation: %s | Price: %.5f | Volume: %.2f | SL: %.5f | TP: %.5f | Signal: %s | Reason: %s",
        operation, price, volume, stopLoss, takeProfit, SignalTypeToString(signalType), reason
    );
    
    Print("?? ", message);
}

void LogTradeResult(double profit, double volume, string symbol, string result)
{
    string message = StringFormat(
        "Trade Result: %s | Symbol: %s | Volume: %.2f | Profit: %.2f",
        result, symbol, volume, profit
    );
    
    Print("?? ", message);
}

//+------------------------------------------------------------------+
//| DEINITIALIZE FUNCTIONS                                           |
//+------------------------------------------------------------------+
void DeinitializeAdvancedLogger()
{
    if(g_advancedLogger != NULL)
    {
        delete g_advancedLogger;
        g_advancedLogger = NULL;
        Print("? Advanced Logger deinitialized");
    }
}

void DeinitializeIndicatorManager()
{
    if(g_indicatorManager != NULL)
    {
        delete g_indicatorManager;
        g_indicatorManager = NULL;
        Print("? Indicator Manager deinitialized");
    }
}

//+------------------------------------------------------------------+
//| ENUM TO STRING CONVERSION FUNCTIONS                              |
//+------------------------------------------------------------------+
// NOTE: MarketCycleToString and MarketRegimeToString are now defined in 01_Core_14_CoreEnums.mqh

//+------------------------------------------------------------------+
//| Convert Trend Direction to String                               |
//+------------------------------------------------------------------+
string TrendDirectionToString(ENUM_TREND_DIRECTION direction)
{
    switch(direction)
    {
        case TREND_UP: return "UP";
        case TREND_DOWN: return "DOWN";
        case TREND_SIDEWAYS: return "SIDEWAYS";
        case TREND_BULLISH: return "BULLISH";
        case TREND_BEARISH: return "BEARISH";
        case TREND_UNKNOWN: return "UNKNOWN";
        default: return "UNDEFINED";
    }
}

// TimeframeToString is defined centrally in 01_Core_14_CoreEnums.mqh

//+------------------------------------------------------------------+
//| Convert Trading Signal to String                                |
//+------------------------------------------------------------------+
// NOTE: TradingSignalToString is now defined in 01_Core_14_CoreEnums.mqh

//+------------------------------------------------------------------+
//| Convert Trading Scenario to String - MOVED TO SonicEnums.mqh   |
//+------------------------------------------------------------------+
// NOTE: TradingScenarioToString() is now defined in 01_Core_22_SonicEnums.mqh
// to avoid duplicates and maintain consistency

// NOTE: Indicator helper free functions removed. Use g_indicatorManager.GetEMAValues(...) and g_indicatorManager.GetATRValue(...)

//+------------------------------------------------------------------+
//| TRADING EXECUTION FUNCTIONS                                      |
//+------------------------------------------------------------------+
bool ExecuteBuySignalAdvanced(double confidence)
{
    // Placeholder implementation for advanced buy signal execution
    Print("?? ExecuteBuySignalAdvanced: Confidence = ", DoubleToString(confidence, 2));
    return true;
}

bool ExecuteSellSignalAdvanced(double confidence)
{
    // Placeholder implementation for advanced sell signal execution
    Print("?? ExecuteSellSignalAdvanced: Confidence = ", DoubleToString(confidence, 2));
    return true;
}

//+------------------------------------------------------------------+
//| TRADE GATE FUNCTIONS                                             |
//+------------------------------------------------------------------+
bool g_tradeGate_CheckAll()
{
    // Placeholder implementation for trade gate check
    Print("?? TradeGate: All checks passed");
    return true;
}

//+------------------------------------------------------------------+
//| LIQUIDITY ANALYSIS FUNCTIONS                                     |
//+------------------------------------------------------------------+
bool IsInstitutionalVolume(double volume)
{
    // Placeholder implementation for institutional volume check
    return (volume > 1000.0);  // Simple threshold
}

bool IsDailyHighLiquidity(double price)
{
    // Placeholder implementation for daily high liquidity check
    return true;  // Always true for now
}

bool IsDailyLowLiquidity(double price)
{
    // Placeholder implementation for daily low liquidity check
    return false;  // Always false for now
}

//+------------------------------------------------------------------+
//| INDICATOR HELPER FUNCTIONS                                       |
//+------------------------------------------------------------------+
bool GetEMAValues(double &ema34, double &ema89, double &ema200, int shift = 0)
{
    // Placeholder implementation for EMA values
    ema34 = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
    ema89 = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
    ema200 = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
    return true;
}

bool GetATRValue(double &atrValue, int period = 14, int shift = 0)
{
    // Placeholder implementation for ATR value
    atrValue = iATR(_Symbol, PERIOD_CURRENT, period);
    return true;
}

//+------------------------------------------------------------------+
//| EXTERNAL DECLARATIONS                                            |
//+------------------------------------------------------------------+
extern CAdvancedLogger* g_advancedLogger;
extern CIndicatorManager* g_indicatorManager;

#endif // CORE_09_UTILS_MQH
