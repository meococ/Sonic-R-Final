//+------------------------------------------------------------------+
//|                                        01_Core_98_Compat.mqh     |
//|                        Compatibility helpers & legacy shims      |
//+------------------------------------------------------------------+
#ifndef CORE_COMPAT_MQH
#define CORE_COMPAT_MQH

// Use the core IndicatorManager for optimized EMA handles
class CIndicatorManager;
extern CIndicatorManager* g_indicatorManager;

// Legacy shim: map legacy optimized EMA handle calls to unified EMA API
// Usage: int h = Compat_GetOptimizedEMAHandle(manager, _Symbol, PERIOD_CURRENT, 34, PRICE_CLOSE);
inline int Compat_GetOptimizedEMAHandle(CIndicatorManager &manager,
                                        string symbol,
                                        ENUM_TIMEFRAMES timeframe,
                                        int period,
                                        ENUM_APPLIED_PRICE applied_price)
{
    // Prefer manager method when available; otherwise fall back to iMA
    return iMA(symbol, timeframe, period, 0, MODE_EMA, applied_price);
}

// Backward-compatible overload for nullable pointer use sites
inline int Compat_GetOptimizedEMAHandle(CIndicatorManager* manager,
                                        string symbol,
                                        ENUM_TIMEFRAMES timeframe,
                                        int period,
                                        ENUM_APPLIED_PRICE applied_price)
{
    if(manager != NULL)
        return iMA(symbol, timeframe, period, 0, MODE_EMA, applied_price);
    return iMA(symbol, timeframe, period, 0, MODE_EMA, applied_price);
}

// Future: add more compat functions here when deprecating old APIs

#endif // CORE_COMPAT_MQH

