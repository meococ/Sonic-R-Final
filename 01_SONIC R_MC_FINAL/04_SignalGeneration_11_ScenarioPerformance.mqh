//+------------------------------------------------------------------+
//|                 04_SignalGeneration_05_ScenarioPerformance.mqh |
//|                    SONIC R MC - SCENARIO PERFORMANCE           |
//|                    Theo dõi hi?u su?t t?ng k?ch b?n            |
//+------------------------------------------------------------------+
#ifndef SCENARIO_PERFORMANCE_MQH
#define SCENARIO_PERFORMANCE_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
// #include "04_SignalGeneration_04_ScenarioConfig.mqh" // Commented out for testing

//+------------------------------------------------------------------+
//| SCENARIO PERFORMANCE DATA                                       |
//+------------------------------------------------------------------+
struct SScenarioPerformance {
    // Basic Stats
    int totalTrades;                    // T?ng s? l?nh
    int winningTrades;                  // S? l?nh th?ng
    int losingTrades;                   // S? l?nh thua
    double totalProfit;                 // T?ng l?i nhu?n
    double totalLoss;                   // T?ng l?
    double netProfit;                   // L?i nhu?n ròng
    
    // Performance Metrics
    double winRate;                     // T? l? th?ng (%)
    double profitFactor;                // H? s? l?i nhu?n
    double averageWin;                  // L?i nhu?n trung bình
    double averageLoss;                 // L? trung bình
    double maxDrawdown;                 // Drawdown t?i da
    double currentDrawdown;             // Drawdown hi?n t?i
    
    // Risk Metrics
    double sharpeRatio;                 // T? l? Sharpe
    double sortinoRatio;                // T? l? Sortino
    double maxConsecutiveLosses;        // S? l?nh thua liên ti?p t?i da
    double currentConsecutiveLosses;    // S? l?nh thua liên ti?p hi?n t?i
    
    // Time-based Stats
    datetime firstTradeTime;            // Th?i gian l?nh d?u tiên
    datetime lastTradeTime;             // Th?i gian l?nh cu?i cùng
    double tradesPerDay;                // S? l?nh m?i ngày
    int activeDays;                     // S? ngày ho?t d?ng
    
    // Quality Metrics
    double averageConfluence;           // Confluence trung bình
    double bestConfluence;              // Confluence t?t nh?t
    double worstConfluence;             // Confluence t? nh?t
    int highQualitySignals;             // S? tín hi?u ch?t lu?ng cao
    
    // Recent Performance (last 20 trades)
    double recentWinRate;               // T? l? th?ng g?n dây
    double recentProfitFactor;          // H? s? l?i nhu?n g?n dây
    double recentDrawdown;              // Drawdown g?n dây
    
    // Status
    bool isActive;                      // K?ch b?n có dang ho?t d?ng
    datetime lastUpdateTime;            // Th?i gian c?p nh?t cu?i
    string statusMessage;               // Thông báo tr?ng thái
};

//+------------------------------------------------------------------+
//| TRADE RECORD FOR PERFORMANCE TRACKING                          |
//+------------------------------------------------------------------+
struct STradeRecord {
    datetime openTime;                  // Th?i gian m? l?nh
    datetime closeTime;                 // Th?i gian dóng l?nh
    ENUM_ORDER_TYPE orderType;          // Lo?i l?nh
    double openPrice;                   // Giá m?
    double closePrice;                  // Giá dóng
    double volume;                      // Kh?i lu?ng
    double profit;                      // L?i nhu?n
    double confluence;                  // Ði?m confluence
    string reason;                      // Lý do vào l?nh
    bool isWin;                         // L?nh th?ng/thua
};

//+------------------------------------------------------------------+
//| SCENARIO PERFORMANCE MANAGER                                    |
//+------------------------------------------------------------------+
class CScenarioPerformance {
private:
    SScenarioPerformance m_performance[5];  // Hi?u su?t 5 k?ch b?n
    STradeRecord m_recentTrades[5][20];     // 20 l?nh g?n nh?t m?i k?ch b?n
    int m_tradeIndex[5];                    // Index l?nh hi?n t?i
    
    // Helper methods
    void CalculateMetrics(ENUM_TRADING_SCENARIO scenario) {
        // body of CalculateMetrics
        int index = (int)scenario;
        if(index < 0 || index >= 5) return;
        
        // Fix: Use direct array access instead of reference
        // SScenarioPerformance &perf = m_performance[index]; // REMOVED - causes Error 229
        
        // Win rate
        if(m_performance[index].totalTrades > 0) {
            m_performance[index].winRate = (double)m_performance[index].winningTrades / m_performance[index].totalTrades * 100.0;
        }
        
        // Profit factor
        if(m_performance[index].totalLoss > 0) {
            m_performance[index].profitFactor = m_performance[index].totalProfit / m_performance[index].totalLoss;
        } else {
            m_performance[index].profitFactor = (m_performance[index].totalProfit > 0) ? 999.0 : 0.0;
        }

        // Average win/loss
        if(m_performance[index].winningTrades > 0) {
            m_performance[index].averageWin = m_performance[index].totalProfit / m_performance[index].winningTrades;
        }
        if(m_performance[index].losingTrades > 0) {
            m_performance[index].averageLoss = m_performance[index].totalLoss / m_performance[index].losingTrades;
        }

        // Drawdown
        m_performance[index].currentDrawdown = CalculateDrawdown(scenario);
        if(m_performance[index].currentDrawdown > m_performance[index].maxDrawdown) {
            m_performance[index].maxDrawdown = m_performance[index].currentDrawdown;
        }
        
        // Sharpe ratio
        m_performance[index].sharpeRatio = CalculateSharpeRatio(scenario);

        // Trades per day
        if(m_performance[index].firstTradeTime > 0 && m_performance[index].lastTradeTime > 0) {
            int daysDiff = (int)((m_performance[index].lastTradeTime - m_performance[index].firstTradeTime) / 86400) + 1;
            m_performance[index].activeDays = daysDiff;
            m_performance[index].tradesPerDay = (double)m_performance[index].totalTrades / daysDiff;
        }
    }
    void UpdateRecentPerformance(ENUM_TRADING_SCENARIO scenario) {
        // body of UpdateRecentPerformance
        int index = (int)scenario;
        if(index < 0 || index >= 5) return;
        
        int recentCount = MathMin(20, m_performance[index].totalTrades);
        if(recentCount == 0) return;
        
        int wins = 0;
        double profit = 0.0, loss = 0.0;
        
        // Calculate recent performance from last 20 trades
        for(int i = 0; i < recentCount; i++) {
            int tradeIdx = (m_tradeIndex[index] - 1 - i + 20) % 20;
            if(m_recentTrades[index][tradeIdx].openTime == 0) continue;
            
            if(m_recentTrades[index][tradeIdx].profit > 0) {
                wins++;
                profit += m_recentTrades[index][tradeIdx].profit;
            } else {
                loss += MathAbs(m_recentTrades[index][tradeIdx].profit);
            }
        }
        
        m_performance[index].recentWinRate = (double)wins / recentCount * 100.0;
        m_performance[index].recentProfitFactor = (loss > 0) ? profit / loss : 999.0;
    }
    double CalculateSharpeRatio(ENUM_TRADING_SCENARIO scenario) {
        // body of CalculateSharpeRatio
        int index = (int)scenario;
        if(index < 0 || index >= 5) return 0.0;
        
        if(m_performance[index].totalTrades < 10) return 0.0;
        
        // Simple Sharpe calculation based on profit consistency
        double avgReturn = m_performance[index].netProfit / m_performance[index].totalTrades;
        
        // Calculate standard deviation of returns
        double variance = 0.0;
        int count = MathMin(20, m_performance[index].totalTrades);
        
        for(int i = 0; i < count; i++) {
            int tradeIdx = (m_tradeIndex[index] - 1 - i + 20) % 20;
            if(m_recentTrades[index][tradeIdx].openTime == 0) continue;
            
            double deviation = m_recentTrades[index][tradeIdx].profit - avgReturn;
            variance += deviation * deviation;
        }
        
        if(count > 1) {
            variance /= (count - 1);
            double stdDev = MathSqrt(variance);
            
            if(stdDev > 0) {
                return avgReturn / stdDev;
            }
        }
        
        return 0.0;
    }
    double CalculateDrawdown(ENUM_TRADING_SCENARIO scenario) {
        // body of CalculateDrawdown
        int index = (int)scenario;
        if(index < 0 || index >= 5) return 0.0;
        
        if(m_performance[index].totalTrades < 2) return 0.0;
        
        double peak = 0.0;
        double currentEquity = 0.0;
        double maxDD = 0.0;
        
        // Calculate running equity and find maximum drawdown
        int count = MathMin(20, m_performance[index].totalTrades);
        for(int i = count - 1; i >= 0; i--) {
            int tradeIdx = (m_tradeIndex[index] - 1 - i + 20) % 20;
            if(m_recentTrades[index][tradeIdx].openTime == 0) continue;
            
            currentEquity += m_recentTrades[index][tradeIdx].profit;
            
            if(currentEquity > peak) {
                peak = currentEquity;
            }
            
            double drawdown = peak - currentEquity;
            if(drawdown > maxDD) {
                maxDD = drawdown;
            }
        }
        
        return maxDD;
    }
public:
    CScenarioPerformance() {
        // existing constructor body
    }
    ~CScenarioPerformance() {}
    
    // FIXED: Implement missing RecordTrade method to resolve Warning 95
    void RecordTrade(ENUM_TRADING_SCENARIO scenario, datetime openTime, datetime closeTime, 
                    ENUM_ORDER_TYPE orderType, double openPrice, double closePrice, 
                    double volume, double profit, double confluence, string reason)
    {
        // Create trade record
        STradeRecord trade;
        trade.openTime = openTime;
        trade.closeTime = closeTime;
        trade.orderType = orderType;
        trade.openPrice = openPrice;
        trade.closePrice = closePrice;
        trade.volume = volume;
        trade.profit = profit;
        trade.confluence = confluence;
        trade.reason = reason;
        trade.isWin = (profit > 0);
        
        // Use existing AddTrade method
        AddTrade(scenario, trade);
    }
    
    // Main Methods
    void AddTrade(ENUM_TRADING_SCENARIO scenario, STradeRecord &trade) {
        // body of AddTrade
        int index = (int)scenario;
        if(index < 0 || index >= 5) return;
        
        // Add to recent trades (circular buffer)
        int tradeIdx = m_tradeIndex[index] % 20;
        m_recentTrades[index][tradeIdx] = trade;
        m_tradeIndex[index]++;
        
        // Update basic stats
        m_performance[index].totalTrades++;
        m_performance[index].lastTradeTime = trade.closeTime;
        
        if(m_performance[index].firstTradeTime == 0) {
            m_performance[index].firstTradeTime = trade.openTime;
        }
        
        // Update profit/loss
        if(trade.profit > 0) {
            m_performance[index].winningTrades++;
            m_performance[index].totalProfit += trade.profit;
            m_performance[index].currentConsecutiveLosses = 0;
        } else {
            m_performance[index].losingTrades++;
            m_performance[index].totalLoss += MathAbs(trade.profit);
            m_performance[index].currentConsecutiveLosses++;
            
            if(m_performance[index].currentConsecutiveLosses > m_performance[index].maxConsecutiveLosses) {
                m_performance[index].maxConsecutiveLosses = m_performance[index].currentConsecutiveLosses;
            }
        }
        
        m_performance[index].netProfit = m_performance[index].totalProfit - m_performance[index].totalLoss;
        
        // Update confluence stats
        if(m_performance[index].totalTrades == 1) {
            m_performance[index].averageConfluence = trade.confluence;
            m_performance[index].bestConfluence = trade.confluence;
            m_performance[index].worstConfluence = trade.confluence;
        } else {
            m_performance[index].averageConfluence = 
                (m_performance[index].averageConfluence * (m_performance[index].totalTrades - 1) + trade.confluence) / 
                m_performance[index].totalTrades;
            
            if(trade.confluence > m_performance[index].bestConfluence) {
                m_performance[index].bestConfluence = trade.confluence;
            }
            if(trade.confluence < m_performance[index].worstConfluence) {
                m_performance[index].worstConfluence = trade.confluence;
            }
        }
        
        if(trade.confluence >= 80.0) {
            m_performance[index].highQualitySignals++;
        }
        
        // Recalculate all metrics
        CalculateMetrics(scenario);
        UpdateRecentPerformance(scenario);
        
        m_performance[index].lastUpdateTime = TimeCurrent();
    }

    SScenarioPerformance GetPerformance(ENUM_TRADING_SCENARIO scenario) {
        int index = (int)scenario;
        if(index < 0 || index >= 5) 
        {
            SScenarioPerformance empty;
            // empty.Reset(); // if Reset is a method
            return empty;
        }
        
        return m_performance[index];
    }
    
    // Analysis Methods
    ENUM_TRADING_SCENARIO GetBestPerformingScenario() {
        // body of GetBestPerformingScenario
        double bestScore = -999999.0;
        ENUM_TRADING_SCENARIO bestScenario = SCENARIO_SONIC_R_BASIC;
        
        for(int i = 0; i < 5; i++) {
            if(m_performance[i].totalTrades < 5) continue; // C?n ít nh?t 5 l?nh
            
            // Composite score: Win Rate + Profit Factor + Sharpe - Drawdown
            double score = m_performance[i].recentWinRate + 
                          (m_performance[i].recentProfitFactor * 10.0) + 
                          (m_performance[i].sharpeRatio * 20.0) - 
                          (m_performance[i].currentDrawdown * 2.0);
            
            if(score > bestScore) {
                bestScore = score;
                bestScenario = (ENUM_TRADING_SCENARIO)i;
            }
        }
        
        return bestScenario;
    }
    ENUM_TRADING_SCENARIO GetWorstPerformingScenario() {
        double worstScore = 1e9;
        ENUM_TRADING_SCENARIO worstScenario = SCENARIO_SONIC_R_BASIC;
        for(int i=0;i<5;i++){
            double score = m_performance[i].recentWinRate + (m_performance[i].recentProfitFactor*10.0) + (m_performance[i].sharpeRatio*20.0) - (m_performance[i].currentDrawdown*2.0);
            if(score < worstScore){ worstScore = score; worstScenario=(ENUM_TRADING_SCENARIO)i; }
        }
        return worstScenario;
    }
    bool ShouldSwitchScenario(ENUM_TRADING_SCENARIO current) {
        // body of ShouldSwitchScenario
        int currentIndex = (int)current;
        if(currentIndex < 0 || currentIndex >= 5) return false;
        
        // Don't switch if not enough data
        if(m_performance[currentIndex].totalTrades < 10) return false;
        
        // Switch if recent performance is poor
        if(m_performance[currentIndex].recentWinRate < 40.0 && m_performance[currentIndex].recentProfitFactor < 1.0) {
            return true;
        }
        
        // Switch if consecutive losses exceed threshold
        if(m_performance[currentIndex].currentConsecutiveLosses >= 5) {
            return true;
        }
        
        // Switch if drawdown is excessive
        if(m_performance[currentIndex].currentDrawdown > m_performance[currentIndex].netProfit * 0.3) {
            return true;
        }
        
        return false;
    }
    
    // Reporting Methods
    string GetPerformanceReport(ENUM_TRADING_SCENARIO scenario) {
        // body of GetPerformanceReport (use one, remove duplicate)
        int index = (int)scenario;
        if(index < 0 || index >= 5) return "Invalid scenario";
        
        string report = StringFormat(
            "?? SCENARIO %d PERFORMANCE\n" +
            "---------------------------\n" +
            "?? Trades: %d (W:%d L:%d)\n" +
            "?? Net P&L: %.2f\n" +
            "?? Win Rate: %.1f%% (Recent: %.1f%%)\n" +
            "?? Profit Factor: %.2f (Recent: %.2f)\n" +
            "?? Max DD: %.2f (Current: %.2f)\n" +
            "?? Sharpe: %.2f\n" +
            "?? Avg Confluence: %.1f\n" +
            "?? High Quality: %d/%d\n" +
            "?? Trades/Day: %.1f\n" +
            "? Last Update: %s",
            index + 1,
            m_performance[index].totalTrades, m_performance[index].winningTrades, m_performance[index].losingTrades,
            m_performance[index].netProfit,
            m_performance[index].winRate, m_performance[index].recentWinRate,
            m_performance[index].profitFactor, m_performance[index].recentProfitFactor,
            m_performance[index].maxDrawdown, m_performance[index].currentDrawdown,
            m_performance[index].sharpeRatio,
            m_performance[index].averageConfluence,
            m_performance[index].highQualitySignals, m_performance[index].totalTrades,
            m_performance[index].tradesPerDay,
            TimeToString(m_performance[index].lastUpdateTime)
        );
        
        return report;
    }
    string GetComparisonReport() {
        // body of GetComparisonReport
        string report = "?? SCENARIO COMPARISON\n";
        report += "-----------------------\n";
        
        for(int i = 0; i < 5; i++) {
            string status = "??";
            if(m_performance[i].isActive) status = "??";
            else if(m_performance[i].totalTrades > 0) status = "??";
            
            report += StringFormat(
                "%s S%d: %dT %.1f%% PF:%.2f P&L:%.2f\n",
                status, i+1, m_performance[i].totalTrades, m_performance[i].winRate, 
                m_performance[i].profitFactor, m_performance[i].netProfit
            );
        }
        
        ENUM_TRADING_SCENARIO best = GetBestPerformingScenario();
        report += StringFormat("\n?? Best: Scenario %d", (int)best + 1);
        
        return report;
    }
    void PrintDailyReport() {
        // Add body if defined
    }
    
    // Reset Methods
    void ResetPerformance(ENUM_TRADING_SCENARIO scenario) {
        // Add body if defined
    }
    void ResetAllPerformance() {
        // Add body if defined
    }
    
    //+------------------------------------------------------------------+
    //| Get detailed report for specific scenario                       |
    //+------------------------------------------------------------------+
    string GetDetailedReport(ENUM_TRADING_SCENARIO scenario) {
        int index = (int)scenario;
        if(index < 0 || index >= 5) {
            return "Invalid scenario";
        }
        
        string report = "\n=== SCENARIO PERFORMANCE REPORT ===\n";
        report += "Scenario: " + TradingScenarioToString(scenario) + "\n";
        report += "Total Trades: " + IntegerToString(m_performance[index].totalTrades) + "\n";
        report += "Win Rate: " + DoubleToString(m_performance[index].winRate, 2) + "%\n";
        report += "Recent Win Rate: " + DoubleToString(m_performance[index].recentWinRate, 2) + "%\n";
        report += "Profit Factor: " + DoubleToString(m_performance[index].profitFactor, 2) + "\n";
        report += "Recent Profit Factor: " + DoubleToString(m_performance[index].recentProfitFactor, 2) + "\n";
        report += "Total Profit: " + DoubleToString(m_performance[index].totalProfit, 2) + "\n";
        report += "Max Drawdown: " + DoubleToString(m_performance[index].maxDrawdown, 2) + "%\n";
        report += "Current Drawdown: " + DoubleToString(m_performance[index].currentDrawdown, 2) + "%\n";
        report += "Sharpe Ratio: " + DoubleToString(m_performance[index].sharpeRatio, 2) + "\n";
        report += "Best Confluence: " + DoubleToString(m_performance[index].bestConfluence, 1) + "\n";
        report += "Worst Confluence: " + DoubleToString(m_performance[index].worstConfluence, 1) + "\n";
        report += "High Quality Signals: " + IntegerToString(m_performance[index].highQualitySignals) + "\n";
        report += "Recent Score: " + DoubleToString(m_performance[index].recentProfitFactor*10.0, 2) + "\n";
        report += "================================\n";
        
        return report;
    }
};

#endif // SCENARIO_PERFORMANCE_MQH