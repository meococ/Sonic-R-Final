//+------------------------------------------------------------------+
//|                                                   TradeGate.mqh |
//|                     🚀 SONIC R MC - TRADE GATE SYSTEM           |
//|                         Advanced Trade Management                |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Đại Bàng Enhanced"
#property version   "2.00"

#ifndef TRADING_03_TRADE_GATE_MQH
#define TRADING_03_TRADE_GATE_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| TRADE GATE CONFIGURATION STRUCTURE                              |
//+------------------------------------------------------------------+
struct TradeGateConfig
{
    bool enableTrading;                   // Enable trading
    double maxRiskPercent;               // Maximum risk percentage
    double maxDailyLoss;                 // Maximum daily loss
    double maxDrawdown;                  // Maximum drawdown
    int maxPositions;                    // Maximum positions
    bool enableNews;                     // Enable news filter
    bool enableTime;                     // Enable time filter
    bool enablePropRules;                // Enable prop firm rules
    string propPreset;                   // Prop firm preset
    double maxSpreadPips;                // Maximum spread in pips
    int maxTradesPerDay;                 // Maximum trades per day
    double maxDailyDDPct;                // Maximum daily drawdown percentage

    void Reset()
    {
        enableTrading = true;
        maxRiskPercent = 2.0;
        maxDailyLoss = 5.0;
        maxDrawdown = 10.0;
        maxPositions = 3;
        enableNews = true;
        enableTime = true;
        enablePropRules = false;
        propPreset = "";
        maxSpreadPips = 3.0;
        maxTradesPerDay = 10;
        maxDailyDDPct = 5.0;
    }
};

//+------------------------------------------------------------------+
//| TRADE GATE CLASS                                                 |
//+------------------------------------------------------------------+
class CTradeGate
{
private:
    TradeGateConfig m_config;            // Gate configuration
    double m_dailyPnL;                   // Daily P&L
    double m_maxDrawdown;                // Maximum drawdown
    int m_currentPositions;              // Current positions
    bool m_tradingEnabled;               // Trading enabled flag
    datetime m_lastUpdate;               // Last update time
    
public:
    CTradeGate()
    {
        m_config.Reset();
        m_dailyPnL = 0.0;
        m_maxDrawdown = 0.0;
        m_currentPositions = 0;
        m_tradingEnabled = true;
        m_lastUpdate = 0;
    }
    
    ~CTradeGate() {}
    
    // Configuration methods
    void SetConfig(const TradeGateConfig& config) { m_config = config; }
    void Configure(const TradeGateConfig& config) { m_config = config; }
    TradeGateConfig GetConfig() const { return m_config; }
    
    // Gate control methods
    bool IsTradingAllowed()
    {
        UpdateStatus();
        
        if(!m_config.enableTrading) return false;
        if(!m_tradingEnabled) return false;
        if(m_currentPositions >= m_config.maxPositions) return false;
        if(m_dailyPnL <= -m_config.maxDailyLoss) return false;
        if(m_maxDrawdown >= m_config.maxDrawdown) return false;
        
        return true;
    }
    
    bool CanOpenPosition(double riskAmount)
    {
        if(!IsTradingAllowed()) return false;
        
        double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double riskPercent = (riskAmount / accountBalance) * 100.0;
        
        return riskPercent <= m_config.maxRiskPercent;
    }
    
    void OnPositionOpen() { m_currentPositions++; }
    void OnPositionClose() { m_currentPositions = MathMax(0, m_currentPositions - 1); }
    
    // Status methods
    void UpdateStatus()
    {
        datetime currentTime = TimeCurrent();
        if(currentTime - m_lastUpdate < 60) return; // Update every minute
        
        m_lastUpdate = currentTime;
        UpdateDailyPnL();
        UpdateDrawdown();
        UpdatePositionCount();
    }
    
    void EnableTrading() { m_tradingEnabled = true; }
    void DisableTrading() { m_tradingEnabled = false; }
    
    // Getters
    double GetDailyPnL() const { return m_dailyPnL; }
    double GetMaxDrawdown() const { return m_maxDrawdown; }
    int GetCurrentPositions() const { return m_currentPositions; }
    bool IsTradingEnabled() const { return m_tradingEnabled; }
    
private:
    void UpdateDailyPnL()
    {
        // Calculate daily P&L from positions
        m_dailyPnL = 0.0;
        for(int i = 0; i < PositionsTotal(); i++)
        {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0 && PositionSelectByTicket(ticket))
            {
                m_dailyPnL += PositionGetDouble(POSITION_PROFIT);
            }
        }
    }
    
    void UpdateDrawdown()
    {
        double equity = AccountInfoDouble(ACCOUNT_EQUITY);
        double balance = AccountInfoDouble(ACCOUNT_BALANCE);
        double currentDrawdown = ((balance - equity) / balance) * 100.0;
        m_maxDrawdown = MathMax(m_maxDrawdown, currentDrawdown);
    }
    
    void UpdatePositionCount()
    {
        m_currentPositions = PositionsTotal();
    }
};

// CCompleteErrorHandler moved to 01_Core_ErrorHandler.mqh

//+------------------------------------------------------------------+
//| GLOBAL INSTANCES                                                 |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - Declare g_tradeGate here since it's used in this file
CTradeGate* g_tradeGate;
// g_errorHandler is declared in 01_Core_ErrorHandler.mqh

//+------------------------------------------------------------------+
//| INITIALIZATION FUNCTIONS                                         |
//+------------------------------------------------------------------+
bool InitializeTradeGate()
{
    if(g_tradeGate == NULL)
    {
        g_tradeGate = new CTradeGate();
        Print("✅ Trade Gate initialized successfully");
        return true;
    }
    return false;
}

// InitializeErrorHandler() moved to 01_Core_ErrorHandler.mqh

void CleanupTradeGate()
{
    if(g_tradeGate != NULL)
    {
        delete g_tradeGate;
        g_tradeGate = NULL;
    }
    
    if(g_errorHandler != NULL)
    {
        delete g_errorHandler;
        g_errorHandler = NULL;
    }
}

#endif // TRADING_03_TRADE_GATE_MQH
