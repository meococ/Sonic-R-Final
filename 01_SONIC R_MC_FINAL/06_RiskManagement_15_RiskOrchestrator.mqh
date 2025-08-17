//+------------------------------------------------------------------+
//|                              RiskOrchestrator.mqh                |
//|                   Sonic R MC - Risk Management System            |
//|                 PHASE 4: Complete Risk Implementation             |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC - Đại Bàng"
#property version   "1.00"

#ifndef RISK_ORCHESTRATOR_MQH
#define RISK_ORCHESTRATOR_MQH

#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_14_CoreEnums.mqh"

//+------------------------------------------------------------------+
//| Risk Parameters Structure                                        |
//+------------------------------------------------------------------+
struct SRiskParameters
{
    double riskPercent;           // Risk per trade (%)
    double maxDrawdown;           // Maximum drawdown allowed (%)
    double riskRewardRatio;       // Target R:R ratio
    double maxDailyLoss;          // Max daily loss (%)
    double maxOpenPositions;      // Max concurrent positions
    bool useKellyCriterion;       // Use Kelly for position sizing
    bool useMonteCarloSim;       // Use Monte Carlo for validation
    bool useBlackSwanProtection; // Enable black swan detection
    bool useCircuitBreaker;      // Enable circuit breaker
    bool useAdaptiveRisk;        // Enable adaptive risk sizing
};

//+------------------------------------------------------------------+
//| Trade Risk Calculation Structure                                 |
//+------------------------------------------------------------------+
struct STradeRisk
{
    double lotSize;               // Calculated lot size
    double stopLossDistance;      // SL distance in pips
    double takeProfitDistance;    // TP distance in pips
    double riskAmount;            // Risk amount in account currency
    double potentialProfit;       // Potential profit amount
    double rrRatio;               // Risk/Reward ratio
    double winProbability;        // Estimated win probability
    double kellyFraction;         // Kelly criterion fraction
    bool isValid;                 // Is trade valid based on risk
    string rejectionReason;       // Why trade was rejected
};

//+------------------------------------------------------------------+
//| Account Risk Status Structure                                    |
//+------------------------------------------------------------------+
struct SAccountRiskStatus
{
    double currentDrawdown;       // Current drawdown (%)
    double dailyLoss;            // Today's loss (%)
    double weeklyLoss;           // This week's loss (%)
    double monthlyLoss;          // This month's loss (%)
    int openPositions;           // Current open positions
    double totalExposure;        // Total market exposure
    double marginUsed;           // Margin utilization (%)
    double riskScore;            // Overall risk score (0-100)
    bool tradingAllowed;         // Is trading allowed
    string restrictions;         // Current restrictions
};

//+------------------------------------------------------------------+
//| Risk Orchestrator Class                                          |
//+------------------------------------------------------------------+
class CRiskOrchestrator
{
private:
    SRiskParameters m_params;
    SAccountRiskStatus m_status;
    double m_accountBalance;
    double m_accountEquity;
    double m_peakBalance;
    datetime m_lastUpdateTime;
    
    // Historical data for calculations
    double m_dailyStartBalance;
    double m_weeklyStartBalance;
    double m_monthlyStartBalance;
    datetime m_dailyStartTime;
    datetime m_weeklyStartTime;
    datetime m_monthlyStartTime;
    
    // Kelly Criterion parameters
    double m_winRate;
    double m_avgWin;
    double m_avgLoss;
    
    // Circuit breaker state
    bool m_circuitBreakerActive;
    datetime m_circuitBreakerEndTime;
    
public:
    //+------------------------------------------------------------------+
    //| Constructor                                                       |
    //+------------------------------------------------------------------+
    CRiskOrchestrator()
    {
        // Initialize default parameters
        m_params.riskPercent = 1.0;
        m_params.maxDrawdown = 10.0;
        m_params.riskRewardRatio = 2.0;
        m_params.maxDailyLoss = 3.0;
        m_params.maxOpenPositions = 3;
        m_params.useKellyCriterion = false;
        m_params.useMonteCarloSim = false;
        m_params.useBlackSwanProtection = true;
        m_params.useCircuitBreaker = true;
        m_params.useAdaptiveRisk = true;
        
        // Initialize account data
        UpdateAccountData();
        
        // Initialize historical tracking
        InitializePeriodTracking();
        
        // Initialize Kelly parameters
        m_winRate = 0.65;  // Default 65% win rate
        m_avgWin = 2.0;     // Default 2:1 avg win
        m_avgLoss = 1.0;    // Default 1 avg loss
        
        // Circuit breaker state
        m_circuitBreakerActive = false;
        m_circuitBreakerEndTime = 0;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Trade Risk                                             |
    //+------------------------------------------------------------------+
    STradeRisk CalculateTradeRisk(ENUM_SIGNAL_TYPE signalType, 
                                  double entryPrice,
                                  double stopLossPrice,
                                  double takeProfitPrice,
                                  double confidence = 0.7)
    {
        STradeRisk risk;
        
        // Update account data
        UpdateAccountData();
        
        // Calculate distances
        risk.stopLossDistance = MathAbs(entryPrice - stopLossPrice) / _Point / 10;
        risk.takeProfitDistance = MathAbs(takeProfitPrice - entryPrice) / _Point / 10;
        
        // Calculate R:R ratio
        risk.rrRatio = risk.takeProfitDistance / risk.stopLossDistance;
        
        // Check minimum R:R requirement
        if(risk.rrRatio < 1.5) {
            risk.isValid = false;
            risk.rejectionReason = "Risk/Reward ratio too low (<1.5)";
            return risk;
        }
        
        // Calculate base risk amount
        double baseRiskPercent = m_params.riskPercent;
        
        // Apply adaptive risk sizing
        if(m_params.useAdaptiveRisk) {
            baseRiskPercent = CalculateAdaptiveRisk(confidence);
        }
        
        // Calculate risk amount
        risk.riskAmount = m_accountBalance * baseRiskPercent / 100;
        
        // Apply Kelly Criterion if enabled
        if(m_params.useKellyCriterion) {
            risk.kellyFraction = CalculateKellyFraction();
            risk.riskAmount *= risk.kellyFraction;
        }
        
        // Calculate lot size
        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        double pipValue = tickValue * _Point / tickSize;
        
        risk.lotSize = risk.riskAmount / (risk.stopLossDistance * pipValue * 10);
        
        // Normalize lot size
        risk.lotSize = NormalizeLotSize(risk.lotSize);
        
        // Calculate potential profit
        risk.potentialProfit = risk.lotSize * risk.takeProfitDistance * pipValue * 10;
        
        // Estimate win probability based on confidence and R:R
        risk.winProbability = EstimateWinProbability(confidence, risk.rrRatio);
        
        // Validate against risk limits
        risk.isValid = ValidateRiskLimits(risk);
        
        return risk;
    }
    
    //+------------------------------------------------------------------+
    //| Validate Risk Limits                                             |
    //+------------------------------------------------------------------+
    bool ValidateRiskLimits(STradeRisk &risk)
    {
        // Check circuit breaker
        if(m_circuitBreakerActive && TimeCurrent() < m_circuitBreakerEndTime) {
            risk.isValid = false;
            risk.rejectionReason = "Circuit breaker active";
            return false;
        }
        
        // Check max drawdown
        if(m_status.currentDrawdown >= m_params.maxDrawdown) {
            risk.isValid = false;
            risk.rejectionReason = "Maximum drawdown reached";
            return false;
        }
        
        // Check daily loss limit
        if(m_status.dailyLoss >= m_params.maxDailyLoss) {
            risk.isValid = false;
            risk.rejectionReason = "Daily loss limit reached";
            return false;
        }
        
        // Check open positions limit
        if(m_status.openPositions >= m_params.maxOpenPositions) {
            risk.isValid = false;
            risk.rejectionReason = "Maximum open positions reached";
            return false;
        }
        
        // Check margin requirements
        double requiredMargin = CalculateRequiredMargin(risk.lotSize);
        double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        
        if(requiredMargin > freeMargin * 0.5) {  // Use max 50% of free margin
            risk.isValid = false;
            risk.rejectionReason = "Insufficient free margin";
            return false;
        }
        
        // Check black swan conditions
        if(m_params.useBlackSwanProtection && DetectBlackSwanConditions()) {
            risk.isValid = false;
            risk.rejectionReason = "Black swan conditions detected";
            return false;
        }
        
        risk.isValid = true;
        risk.rejectionReason = "";
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Adaptive Risk                                          |
    //+------------------------------------------------------------------+
    double CalculateAdaptiveRisk(double confidence)
    {
        double baseRisk = m_params.riskPercent;
        
        // Adjust based on confidence (0.5 to 1.5x)
        double confidenceFactor = 0.5 + confidence;
        
        // Adjust based on current drawdown (reduce risk as DD increases)
        double drawdownFactor = 1.0 - (m_status.currentDrawdown / m_params.maxDrawdown) * 0.5;
        
        // Adjust based on recent performance
        double performanceFactor = CalculatePerformanceFactor();
        
        // Combine factors
        double adaptiveRisk = baseRisk * confidenceFactor * drawdownFactor * performanceFactor;
        
        // Clamp to reasonable range
        adaptiveRisk = MathMax(baseRisk * 0.25, MathMin(baseRisk * 2.0, adaptiveRisk));
        
        return adaptiveRisk;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Kelly Fraction                                         |
    //+------------------------------------------------------------------+
    double CalculateKellyFraction()
    {
        // Kelly formula: f = (p*b - q) / b
        // where p = win probability, q = loss probability, b = win/loss ratio
        
        double p = m_winRate;
        double q = 1 - p;
        double b = m_avgWin / m_avgLoss;
        
        double kellyFraction = (p * b - q) / b;
        
        // Apply Kelly divisor for safety (typically 4-10)
        kellyFraction /= 4.0;
        
        // Clamp to safe range
        kellyFraction = MathMax(0.0, MathMin(0.25, kellyFraction));
        
        return kellyFraction;
    }
    
    //+------------------------------------------------------------------+
    //| Estimate Win Probability                                         |
    //+------------------------------------------------------------------+
    double EstimateWinProbability(double confidence, double rrRatio)
    {
        // Base probability from historical win rate
        double baseProbability = m_winRate;
        
        // Adjust based on confidence
        double confidenceAdjustment = (confidence - 0.5) * 0.2;
        
        // Adjust based on R:R ratio (higher R:R slightly reduces probability)
        double rrAdjustment = -0.05 * (rrRatio - 2.0);
        
        double probability = baseProbability + confidenceAdjustment + rrAdjustment;
        
        // Clamp to valid range
        return MathMax(0.1, MathMin(0.9, probability));
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Performance Factor                                     |
    //+------------------------------------------------------------------+
    double CalculatePerformanceFactor()
    {
        // Calculate recent performance (last 20 trades)
        int totalTrades = 0;
        int winningTrades = 0;
        double totalProfit = 0;
        
        // Get trade history
        if(HistorySelect(TimeCurrent() - 7 * 24 * 3600, TimeCurrent())) {
            int deals = HistoryDealsTotal();
            for(int i = MathMax(0, deals - 20); i < deals; i++) {
                ulong ticket = HistoryDealGetTicket(i);
                if(ticket > 0) {
                    double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                    if(profit != 0) {
                        totalTrades++;
                        totalProfit += profit;
                        if(profit > 0) winningTrades++;
                    }
                }
            }
        }
        
        if(totalTrades == 0) return 1.0;
        
        // Calculate performance metrics
        double recentWinRate = (double)winningTrades / totalTrades;
        double profitFactor = totalProfit > 0 ? 1.2 : 0.8;
        
        // Combine factors
        double performanceFactor = 0.5 + recentWinRate * 0.5 * profitFactor;
        
        return MathMax(0.5, MathMin(1.5, performanceFactor));
    }
    
    //+------------------------------------------------------------------+
    //| Detect Black Swan Conditions                                     |
    //+------------------------------------------------------------------+
    bool DetectBlackSwanConditions()
    {
        // Check for extreme volatility
        double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrMA = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
        
        if(atr > atrMA * 3.0) {
            Print("Black Swan Alert: Extreme volatility detected");
            return true;
        }
        
        // Check for rapid equity decline
        double equityDropPercent = (m_peakBalance - m_accountEquity) / m_peakBalance * 100;
        if(equityDropPercent > 5.0) {  // 5% rapid drop
            Print("Black Swan Alert: Rapid equity decline");
            return true;
        }
        
        // Check for market gaps
        double gap = MathAbs(iOpen(_Symbol, PERIOD_CURRENT, 0) - iClose(_Symbol, PERIOD_CURRENT, 1));
        double avgRange = atr;
        
        if(gap > avgRange * 2.0) {
            Print("Black Swan Alert: Market gap detected");
            return true;
        }
        
        return false;
    }
    
    //+------------------------------------------------------------------+
    //| Activate Circuit Breaker                                         |
    //+------------------------------------------------------------------+
    void ActivateCircuitBreaker(int durationMinutes = 30)
    {
        m_circuitBreakerActive = true;
        m_circuitBreakerEndTime = TimeCurrent() + durationMinutes * 60;
        Print("Circuit Breaker ACTIVATED for ", durationMinutes, " minutes");
    }
    
    //+------------------------------------------------------------------+
    //| Update Account Data                                              |
    //+------------------------------------------------------------------+
    void UpdateAccountData()
    {
        m_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
        
        // Update peak balance for drawdown calculation
        if(m_accountBalance > m_peakBalance) {
            m_peakBalance = m_accountBalance;
        }
        
        // Calculate current drawdown
        m_status.currentDrawdown = (m_peakBalance - m_accountEquity) / m_peakBalance * 100;
        
        // Update period losses
        UpdatePeriodLosses();
        
        // Count open positions
        m_status.openPositions = PositionsTotal();
        
        // Calculate total exposure
        m_status.totalExposure = CalculateTotalExposure();
        
        // Calculate margin usage
        double marginUsed = AccountInfoDouble(ACCOUNT_MARGIN);
        double marginFree = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        m_status.marginUsed = marginUsed / (marginUsed + marginFree) * 100;
        
        // Calculate risk score
        m_status.riskScore = CalculateRiskScore();
        
        // Determine if trading is allowed
        m_status.tradingAllowed = DetermineTradingAllowed();
        
        m_lastUpdateTime = TimeCurrent();
    }
    
    //+------------------------------------------------------------------+
    //| Update Period Losses                                             |
    //+------------------------------------------------------------------+
    void UpdatePeriodLosses()
    {
        datetime currentTime = TimeCurrent();
        
        // Check for new day
        if(TimeDay(currentTime) != TimeDay(m_dailyStartTime)) {
            m_dailyStartBalance = m_accountBalance;
            m_dailyStartTime = currentTime;
        }
        
        // Check for new week
        if(TimeDayOfWeek(currentTime) < TimeDayOfWeek(m_weeklyStartTime)) {
            m_weeklyStartBalance = m_accountBalance;
            m_weeklyStartTime = currentTime;
        }
        
        // Check for new month
        if(TimeMonth(currentTime) != TimeMonth(m_monthlyStartTime)) {
            m_monthlyStartBalance = m_accountBalance;
            m_monthlyStartTime = currentTime;
        }
        
        // Calculate period losses
        m_status.dailyLoss = MathMax(0, (m_dailyStartBalance - m_accountBalance) / m_dailyStartBalance * 100);
        m_status.weeklyLoss = MathMax(0, (m_weeklyStartBalance - m_accountBalance) / m_weeklyStartBalance * 100);
        m_status.monthlyLoss = MathMax(0, (m_monthlyStartBalance - m_accountBalance) / m_monthlyStartBalance * 100);
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Total Exposure                                         |
    //+------------------------------------------------------------------+
    double CalculateTotalExposure()
    {
        double totalExposure = 0;
        
        for(int i = 0; i < PositionsTotal(); i++) {
            if(PositionSelectByTicket(PositionGetTicket(i))) {
                double positionVolume = PositionGetDouble(POSITION_VOLUME);
                double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                totalExposure += positionVolume * positionPrice;
            }
        }
        
        return totalExposure;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Risk Score                                             |
    //+------------------------------------------------------------------+
    double CalculateRiskScore()
    {
        double score = 0;
        
        // Drawdown component (0-30 points)
        score += (m_status.currentDrawdown / m_params.maxDrawdown) * 30;
        
        // Daily loss component (0-20 points)
        score += (m_status.dailyLoss / m_params.maxDailyLoss) * 20;
        
        // Position count component (0-20 points)
        score += ((double)m_status.openPositions / m_params.maxOpenPositions) * 20;
        
        // Margin usage component (0-20 points)
        score += (m_status.marginUsed / 100) * 20;
        
        // Volatility component (0-10 points)
        double currentATR = iATR(_Symbol, PERIOD_CURRENT, 14);
        double avgATR = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
        if(avgATR > 0) {
            score += MathMin(10, (currentATR / avgATR - 1) * 10);
        }
        
        return MathMin(100, score);
    }
    
    //+------------------------------------------------------------------+
    //| Determine Trading Allowed                                        |
    //+------------------------------------------------------------------+
    bool DetermineTradingAllowed()
    {
        m_status.restrictions = "";
        
        // Check circuit breaker
        if(m_circuitBreakerActive && TimeCurrent() < m_circuitBreakerEndTime) {
            m_status.restrictions = "Circuit breaker active";
            return false;
        }
        
        // Check risk score
        if(m_status.riskScore > 80) {
            m_status.restrictions = "Risk score too high";
            return false;
        }
        
        // Check drawdown
        if(m_status.currentDrawdown >= m_params.maxDrawdown) {
            m_status.restrictions = "Maximum drawdown reached";
            return false;
        }
        
        // Check daily loss
        if(m_status.dailyLoss >= m_params.maxDailyLoss) {
            m_status.restrictions = "Daily loss limit reached";
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Initialize Period Tracking                                       |
    //+------------------------------------------------------------------+
    void InitializePeriodTracking()
    {
        datetime currentTime = TimeCurrent();
        
        m_dailyStartBalance = m_accountBalance;
        m_weeklyStartBalance = m_accountBalance;
        m_monthlyStartBalance = m_accountBalance;
        
        m_dailyStartTime = currentTime;
        m_weeklyStartTime = currentTime;
        m_monthlyStartTime = currentTime;
        
        m_peakBalance = m_accountBalance;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Required Margin                                        |
    //+------------------------------------------------------------------+
    double CalculateRequiredMargin(double lotSize)
    {
        double marginRequired = 0;
        
        if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, 
                           SymbolInfoDouble(_Symbol, SYMBOL_ASK), marginRequired)) {
            return marginRequired;
        }
        
        // Fallback calculation
        return lotSize * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE) * 
               SymbolInfoDouble(_Symbol, SYMBOL_ASK) / 
               AccountInfoInteger(ACCOUNT_LEVERAGE);
    }
    
    //+------------------------------------------------------------------+
    //| Normalize Lot Size                                               |
    //+------------------------------------------------------------------+
    double NormalizeLotSize(double lots)
    {
        double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
        
        lots = MathMax(minLot, MathMin(maxLot, lots));
        lots = MathRound(lots / stepLot) * stepLot;
        
        return NormalizeDouble(lots, 2);
    }
    
public:
    //+------------------------------------------------------------------+
    //| Public Getters                                                   |
    //+------------------------------------------------------------------+
    SRiskParameters GetParameters() { return m_params; }
    SAccountRiskStatus GetStatus() { return m_status; }
    bool IsTradingAllowed() { return m_status.tradingAllowed; }
    double GetRiskScore() { return m_status.riskScore; }
    double GetCurrentDrawdown() { return m_status.currentDrawdown; }
    
    //+------------------------------------------------------------------+
    //| Public Setters                                                   |
    //+------------------------------------------------------------------+
    void SetRiskPercent(double percent) { m_params.riskPercent = percent; }
    void SetMaxDrawdown(double percent) { m_params.maxDrawdown = percent; }
    void SetMaxDailyLoss(double percent) { m_params.maxDailyLoss = percent; }
    void SetMaxPositions(int positions) { m_params.maxOpenPositions = positions; }
    void SetUseKelly(bool use) { m_params.useKellyCriterion = use; }
    void SetUseAdaptive(bool use) { m_params.useAdaptiveRisk = use; }
    
    //+------------------------------------------------------------------+
    //| Update Kelly Parameters                                          |
    //+------------------------------------------------------------------+
    void UpdateKellyParameters(double winRate, double avgWin, double avgLoss)
    {
        m_winRate = MathMax(0.1, MathMin(0.9, winRate));
        m_avgWin = MathMax(0.1, avgWin);
        m_avgLoss = MathMax(0.1, avgLoss);
    }
    
    //+------------------------------------------------------------------+
    //| Get Risk Report                                                  |
    //+------------------------------------------------------------------+
    string GetRiskReport()
    {
        string report = "=== RISK MANAGEMENT REPORT ===\n";
        report += StringFormat("Trading Allowed: %s\n", m_status.tradingAllowed ? "YES" : "NO");
        
        if(!m_status.tradingAllowed) {
            report += StringFormat("Restrictions: %s\n", m_status.restrictions);
        }
        
        report += StringFormat("Risk Score: %.1f/100\n", m_status.riskScore);
        report += StringFormat("Current Drawdown: %.2f%%\n", m_status.currentDrawdown);
        report += StringFormat("Daily Loss: %.2f%%\n", m_status.dailyLoss);
        report += StringFormat("Open Positions: %d/%d\n", m_status.openPositions, m_params.maxOpenPositions);
        report += StringFormat("Margin Used: %.1f%%\n", m_status.marginUsed);
        report += StringFormat("Total Exposure: %.2f\n", m_status.totalExposure);
        
        if(m_params.useKellyCriterion) {
            report += StringFormat("Kelly Fraction: %.3f\n", CalculateKellyFraction());
        }
        
        if(m_circuitBreakerActive) {
            int minutesRemaining = (int)((m_circuitBreakerEndTime - TimeCurrent()) / 60);
            report += StringFormat("Circuit Breaker: ACTIVE (%d min remaining)\n", minutesRemaining);
        }
        
        return report;
    }
};

#endif // RISK_ORCHESTRATOR_MQH
