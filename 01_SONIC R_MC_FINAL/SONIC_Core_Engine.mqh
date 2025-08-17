//+------------------------------------------------------------------+
//|                          SONIC_Core_Engine.mqh                  |
//|                    CORE TRADING ENGINE OPTIMIZED                |
//+------------------------------------------------------------------+
#ifndef SONIC_CORE_ENGINE_H
#define SONIC_CORE_ENGINE_H

#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/PositionInfo.mqh>

//+------------------------------------------------------------------+
//| TRADE EXECUTION ENGINE                                          |
//+------------------------------------------------------------------+
class CSonicEngine {
private:
    CTrade          m_trade;
    CSymbolInfo     m_symbol;
    CPositionInfo   m_position;
    
    // Performance metrics
    int             m_total_trades;
    int             m_winning_trades;
    double          m_total_profit;
    double          m_max_drawdown;
    
public:
    //+------------------------------------------------------------------+
    CSonicEngine() {
        m_total_trades = 0;
        m_winning_trades = 0;
        m_total_profit = 0;
        m_max_drawdown = 0;
    }
    
    //+------------------------------------------------------------------+
    bool Initialize(string symbol, int magic) {
        if(!m_symbol.Name(symbol)) return false;
        
        m_trade.SetExpertMagicNumber(magic);
        m_trade.SetDeviationInPoints(10);
        m_trade.SetTypeFilling(ORDER_FILLING_IOC);
        m_trade.SetAsyncMode(false);
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    bool OpenPosition(int type, double lot, double price, double sl, double tp, string comment) {
        bool result = false;
        
        if(type == ORDER_TYPE_BUY) {
            result = m_trade.Buy(lot, m_symbol.Name(), price, sl, tp, comment);
        }
        else if(type == ORDER_TYPE_SELL) {
            result = m_trade.Sell(lot, m_symbol.Name(), price, sl, tp, comment);
        }
        
        if(result) {
            m_total_trades++;
            LogTrade("OPEN", type, lot, price);
        }
        
        return result;
    }
    
    //+------------------------------------------------------------------+
    bool ClosePosition(ulong ticket) {
        if(!m_position.SelectByTicket(ticket)) return false;
        
        bool result = m_trade.PositionClose(ticket);
        
        if(result) {
            double profit = m_position.Profit();
            m_total_profit += profit;
            if(profit > 0) m_winning_trades++;
            
            LogTrade("CLOSE", -1, 0, 0);
        }
        
        return result;
    }
    
    //+------------------------------------------------------------------+
    bool ModifyPosition(ulong ticket, double sl, double tp) {
        return m_trade.PositionModify(ticket, sl, tp);
    }
    
    //+------------------------------------------------------------------+
    int CountPositions(int magic, string symbol) {
        int count = 0;
        for(int i = 0; i < PositionsTotal(); i++) {
            if(m_position.SelectByIndex(i)) {
                if(m_position.Magic() == magic && m_position.Symbol() == symbol) {
                    count++;
                }
            }
        }
        return count;
    }
    
    //+------------------------------------------------------------------+
    double GetTotalProfit(int magic, string symbol) {
        double profit = 0;
        for(int i = 0; i < PositionsTotal(); i++) {
            if(m_position.SelectByIndex(i)) {
                if(m_position.Magic() == magic && m_position.Symbol() == symbol) {
                    profit += m_position.Profit() + m_position.Swap() + m_position.Commission();
                }
            }
        }
        return profit;
    }
    
    //+------------------------------------------------------------------+
    double GetWinRate() {
        if(m_total_trades == 0) return 0;
        return (double)m_winning_trades / m_total_trades * 100;
    }
    
    //+------------------------------------------------------------------+
    string GetStatistics() {
        return StringFormat("Trades: %d | Win Rate: %.1f%% | Profit: %.2f",
                          m_total_trades, GetWinRate(), m_total_profit);
    }
    
private:
    //+------------------------------------------------------------------+
    void LogTrade(string action, int type, double lot, double price) {
        string type_str = (type == ORDER_TYPE_BUY) ? "BUY" : 
                         (type == ORDER_TYPE_SELL) ? "SELL" : "CLOSE";
        Print(StringFormat("[ENGINE] %s %s | Lot: %.2f | Price: %.5f | Stats: %s",
                          action, type_str, lot, price, GetStatistics()));
    }
};

#endif // SONIC_CORE_ENGINE_H
