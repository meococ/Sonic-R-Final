//+------------------------------------------------------------------+
//|                                    08_TradeManagement_01_AdvancedTradeManager.mqh |
//|                        SONIC R MC - ADVANCED TRADE MANAGEMENT   |
//|                    Đại Bàng Enhanced - Smart Trade Management   |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Đại Bàng Enhanced"
#property version   "1.00"

#ifndef ADVANCED_TRADE_MANAGER_MQH
#define ADVANCED_TRADE_MANAGER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Trade Management Configuration                                   |
//+------------------------------------------------------------------+
struct STradeManagementConfig
{
    // Partial Close Settings
    bool enablePartialClose;
    double partialClosePercent1;    // First partial close %
    double partialClosePercent2;    // Second partial close %
    double partialTrigger1;         // Trigger for first partial (R multiple)
    double partialTrigger2;         // Trigger for second partial (R multiple)
    
    // Trailing Stop Settings
    bool enableTrailingStop;
    double trailingStartR;          // Start trailing at R multiple
    double trailingStepR;           // Trailing step in R multiple
    double trailingStopR;           // Trailing stop distance in R multiple
    
    // Break-even Settings
    bool enableBreakEven;
    double breakEvenTriggerR;       // Move to BE at R multiple
    double breakEvenOffsetR;        // BE offset in R multiple
    
    // Risk Management
    double maxRiskPerTrade;         // Max risk per trade %
    double maxDailyRisk;            // Max daily risk %
    int maxConcurrentTrades;        // Max concurrent trades
    
    // Time Management
    bool enableTimeExit;
    int maxHoldingHours;            // Max holding time in hours
    bool enableSessionExit;         // Exit at session end
};

//+------------------------------------------------------------------+
//| Trade State Structure                                            |
//+------------------------------------------------------------------+
struct STradeState
{
    ulong ticket;
    datetime openTime;
    double openPrice;
    double originalSL;
    double originalTP;
    double riskAmount;
    double rMultiple;
    bool partialClose1Done;
    bool partialClose2Done;
    bool breakEvenSet;
    bool trailingActive;
    double currentTrailingSL;
    double highestPrice;    // For long trades
    double lowestPrice;     // For short trades
    ENUM_ORDER_TYPE orderType;
    string symbol;
    double volume;
    double remainingVolume;
};

//+------------------------------------------------------------------+
//| Advanced Trade Manager Class                                     |
//+------------------------------------------------------------------+
class CAdvancedTradeManager
{
private:
    STradeManagementConfig m_config;
    STradeState m_activeTrades[100];  // Track up to 100 trades
    int m_tradeCount;
    CTrade m_trade;
    
public:
    //+------------------------------------------------------------------+
    //| Constructor                                                       |
    //+------------------------------------------------------------------+
    CAdvancedTradeManager()
    {
        m_tradeCount = 0;
        SetDefaultConfig();
        Print("✅ [TRADE MGR] Advanced Trade Manager initialized");
    }
    
    //+------------------------------------------------------------------+
    //| Set Default Configuration                                        |
    //+------------------------------------------------------------------+
    void SetDefaultConfig()
    {
        m_config.enablePartialClose = true;
        m_config.partialClosePercent1 = 50.0;   // Close 50% at 1R
        m_config.partialClosePercent2 = 25.0;   // Close 25% at 2R
        m_config.partialTrigger1 = 1.0;         // 1R profit
        m_config.partialTrigger2 = 2.0;         // 2R profit
        
        m_config.enableTrailingStop = true;
        m_config.trailingStartR = 1.5;          // Start trailing at 1.5R
        m_config.trailingStepR = 0.5;           // Trail every 0.5R
        m_config.trailingStopR = 1.0;           // Keep 1R distance
        
        m_config.enableBreakEven = true;
        m_config.breakEvenTriggerR = 0.8;       // Move to BE at 0.8R
        m_config.breakEvenOffsetR = 0.1;        // 0.1R above BE
        
        m_config.maxRiskPerTrade = 1.0;         // 1% per trade
        m_config.maxDailyRisk = 3.0;            // 3% daily
        m_config.maxConcurrentTrades = 3;       // Max 3 trades
        
        m_config.enableTimeExit = true;
        m_config.maxHoldingHours = 24;          // 24 hours max
        m_config.enableSessionExit = false;     // Don't exit at session end
    }
    
    //+------------------------------------------------------------------+
    //| Execute Trade with Advanced Management                          |
    //+------------------------------------------------------------------+
    bool ExecuteTrade(const TradingSignal &signal)
    {
        // Validate trade
        if(!ValidateTrade(signal)) {
            return false;
        }
        
        // Calculate position size
        double positionSize = CalculatePositionSize(signal);
        if(positionSize <= 0) {
            Print("❌ [TRADE MGR] Invalid position size calculated");
            return false;
        }
        
        // Execute the trade
        bool result = false;
        if(signal.side == ORDER_TYPE_BUY) {
            result = m_trade.Buy(positionSize, _Symbol, 0, signal.sl, signal.tp, "Sonic R MC");
        } else if(signal.side == ORDER_TYPE_SELL) {
            result = m_trade.Sell(positionSize, _Symbol, 0, signal.sl, signal.tp, "Sonic R MC");
        }
        
        if(result) {
            ulong ticket = m_trade.ResultOrder();
            RegisterTrade(ticket, signal, positionSize);
            Print("✅ [TRADE MGR] Trade executed - Ticket: ", ticket, 
                  " Size: ", DoubleToString(positionSize, 2), 
                  " SL: ", DoubleToString(signal.sl, 5), 
                  " TP: ", DoubleToString(signal.tp, 5));
        } else {
            Print("❌ [TRADE MGR] Trade execution failed: ", m_trade.ResultRetcodeDescription());
        }
        
        return result;
    }
    
    //+------------------------------------------------------------------+
    //| Update Trade Management                                          |
    //+------------------------------------------------------------------+
    void UpdateTradeManagement()
    {
        for(int i = 0; i < m_tradeCount; i++) {
            if(m_activeTrades[i].ticket > 0) {
                STradeState trade; trade.ticket = m_activeTrades[i].ticket; trade.rMultiple = m_activeTrades[i].rMultiple; trade.breakEvenSet = m_activeTrades[i].breakEvenSet; trade.trailingActive = m_activeTrades[i].trailingActive; trade.partialClose1Done = m_activeTrades[i].partialClose1Done;
				Print("📊 Ticket: ", trade.ticket, 
				      " R: ", DoubleToString(trade.rMultiple, 2),
				      " BE: ", trade.breakEvenSet ? "YES" : "NO",
				      " Trail: ", trade.trailingActive ? "YES" : "NO",
				      " Partial1: ", trade.partialClose1Done ? "YES" : "NO");
			}
		}
        
        // Clean up closed trades
        CleanupClosedTrades();
    }
    
    //+------------------------------------------------------------------+
    //| Get Configuration                                                |
    //+------------------------------------------------------------------+
    STradeManagementConfig GetConfig() const { return m_config; }
    
    //+------------------------------------------------------------------+
    //| Set Configuration                                                |
    //+------------------------------------------------------------------+
    void SetConfig(const STradeManagementConfig &config) { m_config = config; }
    
    //+------------------------------------------------------------------+
    //| Get Active Trades Count                                          |
    //+------------------------------------------------------------------+
    int GetActiveTradesCount() const { return m_tradeCount; }
    
    //+------------------------------------------------------------------+
    //| Print Trade Status                                               |
    //+------------------------------------------------------------------+
    void PrintTradeStatus()
    {
        Print("📊 [TRADE MGR] Active Trades: ", m_tradeCount);
        for(int i = 0; i < m_tradeCount; i++) {
            if(m_activeTrades[i].ticket > 0) {
                STradeState trade; trade.ticket = m_activeTrades[i].ticket; trade.rMultiple = m_activeTrades[i].rMultiple; trade.breakEvenSet = m_activeTrades[i].breakEvenSet; trade.trailingActive = m_activeTrades[i].trailingActive; trade.partialClose1Done = m_activeTrades[i].partialClose1Done;
				Print("📊 Ticket: ", trade.ticket, 
				      " R: ", DoubleToString(trade.rMultiple, 2),
				      " BE: ", trade.breakEvenSet ? "YES" : "NO",
				      " Trail: ", trade.trailingActive ? "YES" : "NO",
				      " Partial1: ", trade.partialClose1Done ? "YES" : "NO");
			}
		}
    }

private:
    //+------------------------------------------------------------------+
    //| Validate Trade                                                   |
    //+------------------------------------------------------------------+
    bool ValidateTrade(const TradingSignal &signal)
    {
        // Check if we have room for more trades
        if(m_tradeCount >= m_config.maxConcurrentTrades) {
            Print("⚠️ [TRADE MGR] Max concurrent trades reached");
            return false;
        }
        
        // Check signal validity
        if(signal.type == SIGNAL_NONE || signal.sl == 0 || signal.tp == 0) {
            Print("❌ [TRADE MGR] Invalid signal parameters");
            return false;
        }
        
        // Check risk parameters
        double stopDistance = MathAbs(signal.sl - SymbolInfoDouble(_Symbol, SYMBOL_ASK));
        if(stopDistance <= 0) {
            Print("❌ [TRADE MGR] Invalid stop loss distance");
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Position Size                                          |
    //+------------------------------------------------------------------+
    double CalculatePositionSize(const TradingSignal &signal)
    {
        double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double riskAmount = accountBalance * m_config.maxRiskPerTrade / 100.0;
        
        double currentPrice = (signal.side == ORDER_TYPE_BUY) ? 
                             SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                             SymbolInfoDouble(_Symbol, SYMBOL_BID);
        
        double stopDistance = MathAbs(signal.sl - currentPrice);
        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        
        if(stopDistance <= 0 || tickValue <= 0 || tickSize <= 0) {
            return 0;
        }
        
        double positionSize = riskAmount / (stopDistance / tickSize * tickValue);
        
        // Apply volume constraints
        double minVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double maxVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
        
        positionSize = MathMax(positionSize, minVolume);
        positionSize = MathMin(positionSize, maxVolume);
        positionSize = MathFloor(positionSize / volumeStep) * volumeStep;
        
        return positionSize;
    }
    
    //+------------------------------------------------------------------+
    //| Register Trade                                                   |
    //+------------------------------------------------------------------+
    void RegisterTrade(ulong ticket, const TradingSignal &signal, double volume)
    {
        if(m_tradeCount >= 100) return; // Array limit
        
        STradeState trade;
        ZeroMemory(trade);
        
        trade.ticket = ticket;
        trade.openTime = TimeCurrent();
        trade.openPrice = (signal.side == ORDER_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID);
        trade.originalSL = signal.sl;
        trade.originalTP = signal.tp;
        trade.riskAmount = MathAbs(trade.originalSL - trade.openPrice) * volume;
        trade.orderType = signal.side;
        trade.symbol = _Symbol;
        trade.volume = volume;
        trade.remainingVolume = volume;
        trade.highestPrice = trade.openPrice;
        trade.lowestPrice = trade.openPrice;
        
        m_activeTrades[m_tradeCount] = trade;
        m_tradeCount++;
    }

    //+------------------------------------------------------------------+
    //| Update Single Trade                                              |
    //+------------------------------------------------------------------+
    void UpdateSingleTrade(STradeState &trade)
    {
        // Check if position still exists
        if(!PositionSelectByTicket(trade.ticket)) {
            trade.ticket = 0; // Mark for cleanup
            return;
        }

        double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
        double currentProfit = PositionGetDouble(POSITION_PROFIT);

        // Update price tracking
        if(trade.orderType == ORDER_TYPE_BUY) {
            if(currentPrice > trade.highestPrice) {
                trade.highestPrice = currentPrice;
            }
        } else {
            if(currentPrice < trade.lowestPrice) {
                trade.lowestPrice = currentPrice;
            }
        }

        // Calculate current R multiple
        double riskDistance = MathAbs(trade.originalSL - trade.openPrice);
        if(riskDistance > 0) {
            if(trade.orderType == ORDER_TYPE_BUY) {
                trade.rMultiple = (currentPrice - trade.openPrice) / riskDistance;
            } else {
                trade.rMultiple = (trade.openPrice - currentPrice) / riskDistance;
            }
        }

        // Apply trade management rules
        ProcessBreakEven(trade);
        ProcessPartialClose(trade);
        ProcessTrailingStop(trade);
        ProcessTimeExit(trade);
    }

    //+------------------------------------------------------------------+
    //| Process Break-Even                                               |
    //+------------------------------------------------------------------+
    void ProcessBreakEven(STradeState &trade)
    {
        if(!m_config.enableBreakEven || trade.breakEvenSet) return;

        if(trade.rMultiple >= m_config.breakEvenTriggerR) {
            double newSL = trade.openPrice;

            // Add small offset
            double offset = MathAbs(trade.originalSL - trade.openPrice) * m_config.breakEvenOffsetR;
            if(trade.orderType == ORDER_TYPE_BUY) {
                newSL += offset;
            } else {
                newSL -= offset;
            }

            if(m_trade.PositionModify(trade.ticket, newSL, trade.originalTP)) {
                trade.breakEvenSet = true;
                Print("✅ [TRADE MGR] Break-even set for ticket: ", trade.ticket,
                      " New SL: ", DoubleToString(newSL, 5));
            }
        }
    }

    //+------------------------------------------------------------------+
    //| Process Partial Close                                            |
    //+------------------------------------------------------------------+
    void ProcessPartialClose(STradeState &trade)
    {
        if(!m_config.enablePartialClose) return;

        // First partial close
        if(!trade.partialClose1Done && trade.rMultiple >= m_config.partialTrigger1) {
            double closeVolume = trade.remainingVolume * m_config.partialClosePercent1 / 100.0;
            closeVolume = NormalizeVolume(closeVolume, trade.symbol);

            if(closeVolume > 0 && m_trade.PositionClosePartial(trade.ticket, closeVolume)) {
                trade.partialClose1Done = true;
                trade.remainingVolume -= closeVolume;
                Print("✅ [TRADE MGR] Partial close 1 executed for ticket: ", trade.ticket,
                      " Volume: ", DoubleToString(closeVolume, 2));
            }
        }

        // Second partial close
        if(!trade.partialClose2Done && trade.rMultiple >= m_config.partialTrigger2) {
            double closeVolume = trade.remainingVolume * m_config.partialClosePercent2 / 100.0;
            closeVolume = NormalizeVolume(closeVolume, trade.symbol);

            if(closeVolume > 0 && m_trade.PositionClosePartial(trade.ticket, closeVolume)) {
                trade.partialClose2Done = true;
                trade.remainingVolume -= closeVolume;
                Print("✅ [TRADE MGR] Partial close 2 executed for ticket: ", trade.ticket,
                      " Volume: ", DoubleToString(closeVolume, 2));
            }
        }
    }

    //+------------------------------------------------------------------+
    //| Process Trailing Stop                                            |
    //+------------------------------------------------------------------+
    void ProcessTrailingStop(STradeState &trade)
    {
        if(!m_config.enableTrailingStop) return;

        // Start trailing when profit reaches threshold
        if(!trade.trailingActive && trade.rMultiple >= m_config.trailingStartR) {
            trade.trailingActive = true;
            Print("✅ [TRADE MGR] Trailing stop activated for ticket: ", trade.ticket);
        }

        if(trade.trailingActive) {
            double riskDistance = MathAbs(trade.originalSL - trade.openPrice);
            double trailingDistance = riskDistance * m_config.trailingStopR;
            double newSL = 0;

            if(trade.orderType == ORDER_TYPE_BUY) {
                newSL = trade.highestPrice - trailingDistance;
                // Only move SL up
                if(newSL > PositionGetDouble(POSITION_SL)) {
                    trade.currentTrailingSL = newSL;
                }
            } else {
                newSL = trade.lowestPrice + trailingDistance;
                // Only move SL down
                if(newSL < PositionGetDouble(POSITION_SL) || PositionGetDouble(POSITION_SL) == 0) {
                    trade.currentTrailingSL = newSL;
                }
            }

            // Update stop loss if changed
            if(trade.currentTrailingSL != PositionGetDouble(POSITION_SL)) {
                if(m_trade.PositionModify(trade.ticket, trade.currentTrailingSL, trade.originalTP)) {
                    Print("✅ [TRADE MGR] Trailing stop updated for ticket: ", trade.ticket,
                          " New SL: ", DoubleToString(trade.currentTrailingSL, 5));
                }
            }
        }
    }

    //+------------------------------------------------------------------+
    //| Process Time Exit                                                |
    //+------------------------------------------------------------------+
    void ProcessTimeExit(STradeState &trade)
    {
        if(!m_config.enableTimeExit) return;

        datetime currentTime = TimeCurrent();
        int holdingHours = (int)((currentTime - trade.openTime) / 3600);

        if(holdingHours >= m_config.maxHoldingHours) {
            if(m_trade.PositionClose(trade.ticket)) {
                Print("⏰ [TRADE MGR] Time exit executed for ticket: ", trade.ticket,
                      " Holding time: ", holdingHours, " hours");
                trade.ticket = 0; // Mark for cleanup
            }
        }
    }

    //+------------------------------------------------------------------+
    //| Normalize Volume                                                 |
    //+------------------------------------------------------------------+
    double NormalizeVolume(double volume, string symbol)
    {
        double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

        volume = MathMax(volume, minVolume);
        volume = MathMin(volume, maxVolume);
        volume = MathFloor(volume / volumeStep) * volumeStep;

        return volume;
    }

    //+------------------------------------------------------------------+
    //| Cleanup Closed Trades                                            |
    //+------------------------------------------------------------------+
    void CleanupClosedTrades()
    {
        for(int i = m_tradeCount - 1; i >= 0; i--) {
            if(m_activeTrades[i].ticket == 0) {
                // Shift array to remove closed trade
                for(int j = i; j < m_tradeCount - 1; j++) {
                    m_activeTrades[j] = m_activeTrades[j + 1];
                }
                m_tradeCount--;
            }
        }
    }
};

#endif // ADVANCED_TRADE_MANAGER_MQH
