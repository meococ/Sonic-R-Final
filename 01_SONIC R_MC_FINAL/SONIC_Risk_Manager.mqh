//+------------------------------------------------------------------+
//|                         SONIC_Risk_Manager.mqh                  |
//|                   INTELLIGENT RISK MANAGEMENT SYSTEM            |
//+------------------------------------------------------------------+
#ifndef SONIC_RISK_MANAGER_H
#define SONIC_RISK_MANAGER_H

#include <Trade/AccountInfo.mqh>
#include <Trade/PositionInfo.mqh>

//+------------------------------------------------------------------+
//| RISK METRICS STRUCTURE                                          |
//+------------------------------------------------------------------+
struct RiskMetrics {
    double daily_pnl;
    double weekly_pnl;
    double max_drawdown;
    double current_drawdown;
    double risk_score;
    int consecutive_losses;
    int consecutive_wins;
    datetime last_update;
};

//+------------------------------------------------------------------+
//| INTELLIGENT RISK MANAGER                                        |
//+------------------------------------------------------------------+
class CRiskManager {
private:
    CAccountInfo    m_account;
    CPositionInfo   m_position;
    
    RiskMetrics     m_metrics;
    double          m_initial_balance;
    double          m_peak_balance;
    
    // Risk limits
    double          m_max_daily_loss;
    double          m_max_drawdown;
    int             m_max_consecutive_losses;
    double          m_risk_per_trade;
    
    // Adaptive parameters
    double          m_dynamic_risk_factor;
    bool            m_emergency_mode;
    
public:
    //+------------------------------------------------------------------+
    CRiskManager() {
        m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_peak_balance = m_initial_balance;
        
        m_max_daily_loss = 500;        // Default $500
        m_max_drawdown = 0.10;          // 10% max drawdown
        m_max_consecutive_losses = 3;
        m_risk_per_trade = 0.01;        // 1% risk
        
        m_dynamic_risk_factor = 1.0;
        m_emergency_mode = false;
        
        ResetMetrics();
    }
    
    //+------------------------------------------------------------------+
    bool Initialize(double max_daily_loss, double risk_percent) {
        m_max_daily_loss = max_daily_loss;
        m_risk_per_trade = risk_percent / 100.0;
        
        UpdateMetrics();
        return true;
    }
    
    //+------------------------------------------------------------------+
    bool CanTrade() {
        UpdateMetrics();
        
        // Check emergency mode
        if(m_emergency_mode) {
            Print("❌ EMERGENCY MODE - Trading disabled");
            return false;
        }
        
        // Check daily loss
        if(m_metrics.daily_pnl < -m_max_daily_loss) {
            Print("❌ Daily loss limit reached: ", m_metrics.daily_pnl);
            return false;
        }
        
        // Check drawdown
        if(m_metrics.current_drawdown > m_max_drawdown) {
            Print("❌ Max drawdown exceeded: ", m_metrics.current_drawdown * 100, "%");
            return false;
        }
        
        // Check consecutive losses
        if(m_metrics.consecutive_losses >= m_max_consecutive_losses) {
            Print("⚠️ Consecutive losses limit - Reducing risk");
            m_dynamic_risk_factor = 0.5;  // Halve risk
        }
        
        // Check margin level
        double margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
        if(margin_level > 0 && margin_level < 200) {
            Print("❌ Low margin level: ", margin_level, "%");
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    double CalculateLotSize(string symbol, double stop_points) {
        if(stop_points <= 0) return 0;
        
        // Get account and symbol info
        double balance = m_account.Balance();
        double risk_amount = balance * m_risk_per_trade * m_dynamic_risk_factor;
        
        // Get symbol specifications
        double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
        double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
        double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
        
        // Calculate lot size
        double lot = risk_amount / (stop_points / point * tick_value / tick_size);
        
        // Normalize lot size
        double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
        
        lot = MathMax(min_lot, lot);
        lot = MathMin(max_lot, lot);
        lot = NormalizeDouble(MathRound(lot / lot_step) * lot_step, 2);
        
        // Apply Kelly Criterion if winning streak
        if(m_metrics.consecutive_wins >= 3) {
            double kelly_factor = CalculateKellyFactor();
            lot = lot * kelly_factor;
            lot = NormalizeDouble(MathRound(lot / lot_step) * lot_step, 2);
        }
        
        return lot;
    }
    
    //+------------------------------------------------------------------+
    void OnTradeClose(double profit) {
        // Update consecutive tracking
        if(profit > 0) {
            m_metrics.consecutive_wins++;
            m_metrics.consecutive_losses = 0;
            
            // Increase risk after wins
            if(m_metrics.consecutive_wins >= 2) {
                m_dynamic_risk_factor = MathMin(1.5, m_dynamic_risk_factor + 0.25);
            }
        }
        else {
            m_metrics.consecutive_losses++;
            m_metrics.consecutive_wins = 0;
            
            // Decrease risk after losses
            if(m_metrics.consecutive_losses >= 2) {
                m_dynamic_risk_factor = MathMax(0.5, m_dynamic_risk_factor - 0.25);
            }
        }
        
        UpdateMetrics();
    }
    
    //+------------------------------------------------------------------+
    void UpdateMetrics() {
        double current_balance = m_account.Balance();
        
        // Update peak balance
        if(current_balance > m_peak_balance) {
            m_peak_balance = current_balance;
        }
        
        // Calculate drawdown
        m_metrics.current_drawdown = (m_peak_balance - current_balance) / m_peak_balance;
        m_metrics.max_drawdown = MathMax(m_metrics.max_drawdown, m_metrics.current_drawdown);
        
        // Calculate daily P&L
        UpdateDailyPnL();
        
        // Calculate risk score (0-100)
        m_metrics.risk_score = CalculateRiskScore();
        
        // Check for emergency conditions
        CheckEmergencyConditions();
        
        m_metrics.last_update = TimeCurrent();
    }
    
    //+------------------------------------------------------------------+
    double GetDynamicStopLoss(string symbol, double atr_multiplier) {
        double atr = GetATR(symbol);
        double base_stop = atr * atr_multiplier;
        
        // Adjust based on risk score
        if(m_metrics.risk_score > 70) {
            base_stop *= 0.8;  // Tighter stop in high risk
        }
        else if(m_metrics.risk_score < 30) {
            base_stop *= 1.2;  // Wider stop in low risk
        }
        
        return base_stop;
    }
    
    //+------------------------------------------------------------------+
    double GetDynamicTakeProfit(string symbol, double atr_multiplier) {
        double atr = GetATR(symbol);
        double base_tp = atr * atr_multiplier;
        
        // Adjust based on consecutive wins/losses
        if(m_metrics.consecutive_wins >= 2) {
            base_tp *= 1.5;  // Larger targets when winning
        }
        else if(m_metrics.consecutive_losses >= 2) {
            base_tp *= 0.75;  // Smaller targets when losing
        }
        
        return base_tp;
    }
    
    //+------------------------------------------------------------------+
    string GetRiskReport() {
        return StringFormat("Risk Score: %.0f | DD: %.1f%% | Daily P&L: %.2f | Risk Factor: %.2f",
                          m_metrics.risk_score,
                          m_metrics.current_drawdown * 100,
                          m_metrics.daily_pnl,
                          m_dynamic_risk_factor);
    }
    
    //+------------------------------------------------------------------+
    bool IsEmergencyMode() { return m_emergency_mode; }
    double GetRiskScore() { return m_metrics.risk_score; }
    double GetDynamicRiskFactor() { return m_dynamic_risk_factor; }
    
private:
    //+------------------------------------------------------------------+
    void ResetMetrics() {
        m_metrics.daily_pnl = 0;
        m_metrics.weekly_pnl = 0;
        m_metrics.max_drawdown = 0;
        m_metrics.current_drawdown = 0;
        m_metrics.risk_score = 0;
        m_metrics.consecutive_losses = 0;
        m_metrics.consecutive_wins = 0;
        m_metrics.last_update = TimeCurrent();
    }
    
    //+------------------------------------------------------------------+
    void UpdateDailyPnL() {
        static datetime last_day = 0;
        static double day_start_balance = 0;
        
        MqlDateTime current_time;
        TimeToStruct(TimeCurrent(), current_time);
        datetime current_day = StringToTime(StringFormat("%04d.%02d.%02d", 
                                          current_time.year, 
                                          current_time.mon, 
                                          current_time.day));
        
        if(current_day != last_day) {
            last_day = current_day;
            day_start_balance = m_account.Balance();
            m_metrics.daily_pnl = 0;
        }
        else {
            m_metrics.daily_pnl = m_account.Balance() - day_start_balance;
        }
    }
    
    //+------------------------------------------------------------------+
    double CalculateRiskScore() {
        double score = 0;
        
        // Drawdown component (40%)
        score += (m_metrics.current_drawdown / m_max_drawdown) * 40;
        
        // Daily loss component (30%)
        if(m_metrics.daily_pnl < 0) {
            score += (MathAbs(m_metrics.daily_pnl) / m_max_daily_loss) * 30;
        }
        
        // Consecutive losses component (20%)
        score += (m_metrics.consecutive_losses / (double)m_max_consecutive_losses) * 20;
        
        // Margin level component (10%)
        double margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
        if(margin_level > 0 && margin_level < 500) {
            score += ((500 - margin_level) / 500) * 10;
        }
        
        return MathMin(100, score);
    }
    
    //+------------------------------------------------------------------+
    void CheckEmergencyConditions() {
        // Activate emergency mode on critical conditions
        if(m_metrics.current_drawdown > m_max_drawdown * 0.8 ||
           m_metrics.consecutive_losses >= m_max_consecutive_losses ||
           m_metrics.risk_score > 80) {
            
            if(!m_emergency_mode) {
                m_emergency_mode = true;
                Print("🚨 EMERGENCY MODE ACTIVATED - Risk Score: ", m_metrics.risk_score);
                
                // Close all positions
                CloseAllPositions();
            }
        }
        // Deactivate when conditions improve
        else if(m_emergency_mode && m_metrics.risk_score < 50) {
            m_emergency_mode = false;
            m_dynamic_risk_factor = 0.5;  // Start with reduced risk
            Print("✅ Emergency mode deactivated - Trading resumed with reduced risk");
        }
    }
    
    //+------------------------------------------------------------------+
    void CloseAllPositions() {
        for(int i = PositionsTotal() - 1; i >= 0; i--) {
            if(m_position.SelectByIndex(i)) {
                CTrade trade;
                trade.PositionClose(m_position.Ticket());
            }
        }
    }
    
    //+------------------------------------------------------------------+
    double CalculateKellyFactor() {
        // Simple Kelly Criterion implementation
        double win_rate = 0.6;  // Assumed 60% win rate
        double avg_win = 2.5;    // Avg R:R on wins
        double avg_loss = 1.0;   // Avg R:R on losses
        
        double kelly = (win_rate * avg_win - (1 - win_rate) * avg_loss) / avg_win;
        
        // Apply Kelly fraction (25% of full Kelly for safety)
        kelly = kelly * 0.25;
        
        return MathMax(0.5, MathMin(1.5, 1.0 + kelly));
    }
    
    //+------------------------------------------------------------------+
    double GetATR(string symbol) {
        double atr[];
        ArraySetAsSeries(atr, true);
        int handle = iATR(symbol, PERIOD_M15, 14);
        
        if(handle != INVALID_HANDLE && CopyBuffer(handle, 0, 0, 1, atr) > 0) {
            IndicatorRelease(handle);
            return atr[0];
        }
        
        return 0;
    }
};

#endif // SONIC_RISK_MANAGER_H
