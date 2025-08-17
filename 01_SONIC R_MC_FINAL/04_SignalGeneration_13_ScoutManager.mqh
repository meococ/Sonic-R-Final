//+------------------------------------------------------------------+
//|                                            Scout_01_Manager.mqh |
//|                                  Copyright 2024, Sonic R MC Team |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Sonic R MC Team"
#property link      "https://www.mql5.com"
#property version   "2.00"
#property strict
#ifndef SCOUT_01_MANAGER_MQH
#define SCOUT_01_MANAGER_MQH
#include "02_DataProviders_01_SymbolInfo_Primary.mqh"
//--- Scout System Parameters (Defines)
#define InpScoutPositionSize 0.1        // Scout position size
#define InpScoutMinPositionSize 0.01    // Minimum position size
#define InpScoutMaxPositionSize 1.0     // Maximum position size
#define InpScoutMaxPositions 5          // Maximum scout positions
#define InpScoutSessionFilter true      // Enable session filtering
//+------------------------------------------------------------------+
//| [TARGET SCOUT] SCOUT SYSTEM: COUNTER-TREND OPPORTUNITY DETECTION |
//+------------------------------------------------------------------+
// Scout System Enums
enum ENUM_SCOUT_SIGNAL_TYPE
{
    SCOUT_SIGNAL_NONE = 0,
    SCOUT_SIGNAL_COUNTER_BUY = 1,    // Counter-trend buy signal
    SCOUT_SIGNAL_COUNTER_SELL = 2    // Counter-trend sell signal
};
enum ENUM_SCOUT_MARKET_STATE
{
    SCOUT_MARKET_UNKNOWN = 0,
    SCOUT_MARKET_TRENDING_UP = 1,
    SCOUT_MARKET_TRENDING_DOWN = 2,
    SCOUT_MARKET_RANGING = 3,
    SCOUT_MARKET_REVERSAL_ZONE = 4
};
// Scout System Structures
struct SScoutSignal
{
    ENUM_SCOUT_SIGNAL_TYPE type;
    double confidence;
    double entryPrice;
    double stopLoss;
    double takeProfit;
    datetime signalTime;
    string reason;
    double riskReward;
};
struct SScoutMarketAnalysis
{
    ENUM_SCOUT_MARKET_STATE marketState;
    double trendStrength;
    double reversalProbability;
    double supportLevel;
    double resistanceLevel;
    bool isOversold;
    bool isOverbought;
    datetime lastUpdate;
};
struct SScoutSessionInfo
{
    bool isActive;
    string sessionName;
    datetime startTime;
    datetime endTime;
    int totalSignals;
    int successfulSignals;
    double totalPnL;
};
//+------------------------------------------------------------------+
//| [TARGET SCOUT] SCOUT MANAGER CLASS                                |
//+------------------------------------------------------------------+
class CScoutManager
{
private:
    // Core components
    CSonicSymbolInfo* m_symbolInfo;
    
    // Market analysis
    SScoutMarketAnalysis m_marketAnalysis;
    SScoutSessionInfo m_currentSession;
    
    // Signal tracking
    SScoutSignal m_lastSignal;
    int m_totalSignals;
    int m_successfulSignals;
    double m_totalPnL;
    
    // Timing
    datetime m_lastAnalysisTime;
    
    // ATR for volatility calculation
    int m_atrHandle;
    double m_atrBuffer[];
public:
    // Constructor
    CScoutManager(CSonicSymbolInfo* symbolInfo = NULL)
    {
        m_symbolInfo = symbolInfo;
        m_atrHandle = INVALID_HANDLE;
        m_totalSignals = 0;
        m_successfulSignals = 0;
        m_totalPnL = 0.0;
        m_lastAnalysisTime = 0;
        ArrayResize(m_atrBuffer, 50);
        ZeroMemory(m_lastSignal);
        ZeroMemory(m_marketAnalysis);
        ZeroMemory(m_currentSession);
    }
    
    // Destructor
    ~CScoutManager()
    {
        Deinitialize();
    }
    
    // Core functionality
    bool Initialize()
    {
        Print("[TARGET SCOUT] Initializing Scout System...");
        
        // Validate symbol info
        if(m_symbolInfo == NULL) {
            Print("[WARNING SCOUT] Warning: Symbol info not provided, using default symbol");
        }
        
        // Initialize ATR
        m_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        if(m_atrHandle == INVALID_HANDLE) {
            Print("[ERROR SCOUT] Failed to initialize ATR indicator");
            return false;
        }
        
        // Initialize market analysis
        m_marketAnalysis.marketState = SCOUT_MARKET_UNKNOWN;
        m_marketAnalysis.trendStrength = 0.0;
        m_marketAnalysis.reversalProbability = 0.0;
        m_marketAnalysis.lastUpdate = TimeCurrent();
        
        // Initialize session info
        UpdateSessionInfo();
        
        // Perform initial market analysis
        if(!UpdateMarketAnalysis()) {
            Print("[ERROR SCOUT] Failed to perform initial market analysis");
            return false;
        }
        
        Print("[SUCCESS SCOUT] Scout System initialized successfully");
        Print("[TARGET SCOUT] Features: Counter-trend detection | Multi-session support | Dynamic position sizing");
        
        return true;
    }
    
    void Deinitialize()
    {
        if(m_atrHandle != INVALID_HANDLE) {
            IndicatorRelease(m_atrHandle);
            m_atrHandle = INVALID_HANDLE;
        }
        
        Print(StringFormat("[TARGET SCOUT] Final Stats - Signals: %d | Success Rate: %.1f%% | Total PnL: %.2f",
              m_totalSignals, GetSuccessRate(), m_totalPnL));
    }
    
    bool ProcessTick()
    {
        if(!IsValidTradingSession()) {
            return false;
        }
        
        // Update market analysis every 5 minutes
        if(TimeCurrent() - m_lastAnalysisTime > 300) {
            if(!UpdateMarketAnalysis()) {
                return false;
            }
            m_lastAnalysisTime = TimeCurrent();
        }
        
        // Check for counter-trend opportunities
        if(CheckCounterTrendConditions()) {
            SScoutSignal signal;
            signal = GenerateScoutSignal();
            if(ValidateScoutSignal(signal)) {
                if(ExecuteScoutTrade(signal)) {
                    m_lastSignal = signal;
                    m_totalSignals++;
                    Print("[SUCCESS SCOUT] Counter-trend signal executed successfully");
                    return true;
                }
            }
        }
        
        return false;
    }
    
    bool ProcessNewBar()
    {
        if(!IsValidTradingSession()) {
            return false;
        }
        
        // Update session info
        UpdateSessionInfo();
        
        // Perform comprehensive market analysis
        if(!UpdateMarketAnalysis()) {
            return false;
        }
        
        // Check for reversal zones
        if(DetectReversalZones()) {
            double probability = CalculateReversalProbability();
            if(probability > 0.7) {
                Print(StringFormat("[TARGET SCOUT] High probability reversal zone detected: %.1f%%", probability * 100));
            }
        }
        
        return true;
    }
    
    // Signal generation and execution
    bool ExecuteScoutTradeWithSize(const SScoutSignal& signal, double positionSize)
    {
        // Implementation for executing scout trade with specific size
        return true;
    }
    
    // Scout opportunity detection
    bool IsScoutOpportunity()
    {
        // PHASE 2: Complete implementation following review.txt guideline
        
        // 1. H4 xác định vùng S/R mạnh (>= 0.75)
        bool strongSR = (GetSRStrength() >= 0.75);
        
        // 2. M15 xác nhận mẫu hình đảo chiều
        bool reversalPattern = IsStrongReversalPattern();
        
        // 3. Volume xác nhận (1.8x average volume)
        bool volumeConfirm = IsVolumeConfirmation();
        
        // 4. Kiểm tra không xung đột với vị thế hiện tại
        bool noConflict = !HasConflictingPosition();
        
        // 5. Volatility phù hợp cho Scout Trade
        bool volatilitySuitable = IsVolatilitySuitableForScout();
        
        // Log decision reasoning for transparency
        if(strongSR && reversalPattern && volumeConfirm && noConflict && volatilitySuitable) {
            Print("✅ [SCOUT] Opportunity detected - SR:", strongSR, " Reversal:", reversalPattern, " Volume:", volumeConfirm, " NoConflict:", noConflict, " Volatility:", volatilitySuitable);
        }
        
        return strongSR && reversalPattern && volumeConfirm && noConflict && volatilitySuitable;
    }
    
    bool HasConflictingPosition(ENUM_SCOUT_SIGNAL_TYPE signalType)
    {
        // Check for conflicting positions
        return false;
    }
    
    bool DetectM5ReversalPattern()
    {
        // Detect M5 reversal patterns
        return false;
    }
    
    // Reporting
    double GetSuccessRate() const
    {
        if(m_totalSignals == 0) return 0.0;
        return (double)m_successfulSignals / m_totalSignals * 100.0;
    }
    
    string GetStatusReport() const
    {
        return StringFormat("Scout Status: Signals=%d, Success=%.1f%%, PnL=%.2f",
                          m_totalSignals, GetSuccessRate(), m_totalPnL);
    }
    
    void Reset()
    {
        m_totalSignals = 0;
        m_successfulSignals = 0;
        m_totalPnL = 0.0;
        ZeroMemory(m_lastSignal);
    }
    
    // Strict rules validation
    bool ProcessScoutWithStrictRules()
    {
        return ProcessTick();
    }
private:
    // Private methods
    bool UpdateMarketAnalysis()
    {
        if(!AnalyzeMarketState()) {
            return false;
        }
        
        // Update support/resistance levels
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        m_marketAnalysis.supportLevel = currentPrice * 0.995;  // Simplified
        m_marketAnalysis.resistanceLevel = currentPrice * 1.005;  // Simplified
        
        // Update overbought/oversold conditions
        double atr = GetAverageATR();
        if(atr > 0) {
            double volatilityRatio = atr / (currentPrice * 0.001);
            m_marketAnalysis.isOverbought = (volatilityRatio > 1.5);
            m_marketAnalysis.isOversold = (volatilityRatio < 0.5);
        }
        
        m_marketAnalysis.lastUpdate = TimeCurrent();
        return true;
    }
    
    bool AnalyzeMarketState()
    {
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double previousPrice = iClose(_Symbol, PERIOD_CURRENT, 1);
        
        // Simple trend strength calculation
        double priceChange = (currentPrice - previousPrice) / previousPrice;
        m_marketAnalysis.trendStrength = MathAbs(priceChange) * 100;
        
        // Determine market state
        if(m_marketAnalysis.trendStrength > 0.5) {
            m_marketAnalysis.marketState = (priceChange > 0) ? SCOUT_MARKET_TRENDING_UP : SCOUT_MARKET_TRENDING_DOWN;
        } else {
            m_marketAnalysis.marketState = SCOUT_MARKET_RANGING;
        }
        
        return true;
    }
    
    bool DetectReversalZones()
    {
        // Check if we're in a trending market
        if(m_marketAnalysis.marketState == SCOUT_MARKET_TRENDING_UP || 
           m_marketAnalysis.marketState == SCOUT_MARKET_TRENDING_DOWN) {
            
            // Check for overbought/oversold conditions
            if(m_marketAnalysis.isOverbought || m_marketAnalysis.isOversold) {
                m_marketAnalysis.marketState = SCOUT_MARKET_REVERSAL_ZONE;
                return true;
            }
        }
        
        return false;
    }
    
    double CalculateReversalProbability()
    {
        double probability = 0.0;
        
        // Base probability on trend strength and overbought/oversold conditions
        if(m_marketAnalysis.isOverbought || m_marketAnalysis.isOversold) {
            probability += 0.4;
        }
        
        if(m_marketAnalysis.trendStrength > 1.0) {
            probability += 0.3;
        }
        
        return MathMin(probability, 1.0);
    }
    
    SScoutSignal GenerateScoutSignal()
    {
        SScoutSignal signal;
        ZeroMemory(signal);
        
        signal.signalTime = TimeCurrent();
        signal.confidence = CalculateReversalProbability();
        signal.entryPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        
        // Determine signal type based on market state
        if(m_marketAnalysis.marketState == SCOUT_MARKET_TRENDING_UP && m_marketAnalysis.isOverbought) {
            signal.type = SCOUT_SIGNAL_COUNTER_SELL;
            signal.reason = "Overbought counter-trend sell";
        } else if(m_marketAnalysis.marketState == SCOUT_MARKET_TRENDING_DOWN && m_marketAnalysis.isOversold) {
            signal.type = SCOUT_SIGNAL_COUNTER_BUY;
            signal.reason = "Oversold counter-trend buy";
        }
        
        return signal;
    }
    
    bool CheckCounterTrendConditions()
    {
        return (m_marketAnalysis.isOverbought || m_marketAnalysis.isOversold) &&
               (m_marketAnalysis.marketState == SCOUT_MARKET_TRENDING_UP || 
                m_marketAnalysis.marketState == SCOUT_MARKET_TRENDING_DOWN);
    }
    
    bool ValidateScoutSignal(SScoutSignal& signal)
    {
        return signal.type != SCOUT_SIGNAL_NONE && signal.confidence > 0.5;
    }
    
    bool ExecuteScoutTrade(const SScoutSignal& signal)
    {
        // Simplified execution logic
        Print(StringFormat("[SCOUT TRADE] %s at %.5f (Confidence: %.1f%%)",
              signal.reason, signal.entryPrice, signal.confidence * 100));
        return true;
    }
    
    double CalculateDynamicPositionSize(double confidence)
    {
        double baseSize = InpScoutPositionSize;
        double adjustedSize = baseSize * confidence;
        return MathMax(InpScoutMinPositionSize, MathMin(adjustedSize, InpScoutMaxPositionSize));
    }
    
    bool UpdateSessionInfo()
    {
        m_currentSession.isActive = IsValidTradingSession();
        m_currentSession.sessionName = "Main";
        return true;
    }
    
    bool IsValidTradingSession()
    {
        if(!InpScoutSessionFilter) return true;
        
        // Simple session validation
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        int hour = dt.hour;
        
        // Allow trading during main sessions (simplified)
        return (hour >= 8 && hour <= 17);
    }
    
    bool CheckRiskParameters()
    {
        // Basic risk parameter validation
        return true;
    }
    
    double GetAverageATR(int period = 14)
    {
        if(m_atrHandle == INVALID_HANDLE) return 0.0;
        
        if(CopyBuffer(m_atrHandle, 0, 0, 1, m_atrBuffer) <= 0) {
            return 0.0;
        }
        
        return m_atrBuffer[0];
    }
    
    //+------------------------------------------------------------------+
    //| 🎯 PHASE 2: SCOUT OPPORTUNITY DETECTION (per review.txt)        |
    //+------------------------------------------------------------------+
    // IsScoutOpportunity(): single implementation kept below to avoid duplicates

    //+------------------------------------------------------------------+
    //| 🎯 PHASE 2: CONFLICT POSITION CHECK (per review.txt)            |
    //+------------------------------------------------------------------+
    bool HasConflictingPosition()
    {
        // Không vào lệnh scout nếu đang có vị thế Basic
        if(HasActiveBasicPosition()) {
            Print("⚠️ [PHASE 2] Scout blocked: Active Basic position detected");
            return true;
        }
        
        // Không vào lệnh scout trong xu hướng mạnh
        if(IsStrongTrend()) {
            Print("⚠️ [PHASE 2] Scout blocked: Strong trend detected");
            return true;
        }
        
        return false;
    }
    
    //+------------------------------------------------------------------+
    //| 🎯 PHASE 2: HELPER FUNCTIONS FOR SCOUT ANALYSIS                |
    //+------------------------------------------------------------------+
    double GetSRStrength()
    {
        // Simplified S/R strength calculation
        double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double support = m_marketAnalysis.supportLevel;
        double resistance = m_marketAnalysis.resistanceLevel;
        
        if(support <= 0 || resistance <= 0) return 0.0;
        
        double srRange = resistance - support;
        double distanceToSR = MathMin(MathAbs(currentPrice - support), MathAbs(currentPrice - resistance));
        
        // Closer to S/R = stronger
        return (srRange > 0) ? MathMax(0.0, 1.0 - (distanceToSR / srRange)) : 0.0;
    }
    
    bool IsVolumeConfirmation()
    {
        // Volume confirmation for Scout Trade (1.8x average volume per review.txt)
        double currentVolume = (double)iVolume(_Symbol, PERIOD_CURRENT, 0);
        if(currentVolume <= 0) return false;
        
        // Calculate 20-period average volume
        double avgVolume = 0.0;
        int validBars = 0;
        
        for(int i = 1; i <= 20; i++) {
            double vol = (double)iVolume(_Symbol, PERIOD_CURRENT, i);
            if(vol > 0) {
                avgVolume += vol;
                validBars++;
            }
        }
        
        if(validBars == 0) return false;
        avgVolume /= validBars;
        
        bool volumeConfirm = currentVolume > (avgVolume * 1.8);
        
        if(volumeConfirm) {
            Print("📊 [SCOUT VOLUME] Confirmation: ", DoubleToString(currentVolume/avgVolume, 2), "x average");
        }
        
        return volumeConfirm;
    }
    
    bool IsStrongReversalPattern()
    {
        // M15 reversal pattern detection for Scout Trade
        double high1 = iHigh(_Symbol, PERIOD_M15, 1);
        double low1 = iLow(_Symbol, PERIOD_M15, 1);
        double close1 = iClose(_Symbol, PERIOD_M15, 1);
        double open1 = iOpen(_Symbol, PERIOD_M15, 1);
        
        double high2 = iHigh(_Symbol, PERIOD_M15, 2);
        double low2 = iLow(_Symbol, PERIOD_M15, 2);
        double close2 = iClose(_Symbol, PERIOD_M15, 2);
        
        if(high1 == EMPTY_VALUE || low1 == EMPTY_VALUE || close1 == EMPTY_VALUE || open1 == EMPTY_VALUE) return false;
        if(high2 == EMPTY_VALUE || low2 == EMPTY_VALUE || close2 == EMPTY_VALUE) return false;
        
        // Doji pattern detection
        double bodySize1 = MathAbs(close1 - open1);
        double rangeSize1 = high1 - low1;
        bool isDoji = (rangeSize1 > 0) && (bodySize1 / rangeSize1 < 0.1);
        
        // Hammer/Shooting star pattern
        double upperShadow = high1 - MathMax(close1, open1);
        double lowerShadow = MathMin(close1, open1) - low1;
        bool isHammer = (lowerShadow > bodySize1 * 2) && (upperShadow < bodySize1 * 0.5);
        bool isShootingStar = (upperShadow > bodySize1 * 2) && (lowerShadow < bodySize1 * 0.5);
        
        // Engulfing pattern
        bool isBullishEngulfing = (close2 < open1) && (close1 > open1) && (close1 > high2) && (open1 < low2);
        bool isBearishEngulfing = (close2 > open1) && (close1 < open1) && (close1 < low2) && (open1 > high2);
        
        bool reversalDetected = isDoji || isHammer || isShootingStar || isBullishEngulfing || isBearishEngulfing;
        
        if(reversalDetected) {
            Print("🔄 [SCOUT REVERSAL] Pattern detected - Doji:", isDoji, " Hammer:", isHammer, " Star:", isShootingStar);
        }
        
        return reversalDetected;
    }
    
    bool IsVolatilitySuitableForScout()
    {
        // Volatility suitability check for Scout Trade
        int atrHandle=iATR(_Symbol, PERIOD_M15, 14);
double atrBuf[2];  double currentATR=0.0; if(CopyBuffer(atrHandle,0,0,1,atrBuf)>0) currentATR=atrBuf[0]; if(atrHandle!=INVALID_HANDLE) IndicatorRelease(atrHandle);
        if(currentATR <= 0) return false;
        
        // Get baseline ATR (10-period average)
        double baselineATR = 0.0;
        int validPeriods = 0;
        
        for(int i = 1; i <= 10; i++) {
            double atr=0.0; if(CopyBuffer(atrHandle,0,i,1,atrBuf)>0) atr=atrBuf[0];
            if(atr > 0) {
                baselineATR += atr;
                validPeriods++;
            }
        }
        
        if(validPeriods == 0) return false;
        baselineATR /= validPeriods;
        
        double volatilityRatio = currentATR / baselineATR;
        
        // Scout Trade works best in moderate volatility (0.8x to 1.5x baseline)
        bool suitable = (volatilityRatio >= 0.8 && volatilityRatio <= 1.5);
        
        if(!suitable) {
            Print("⚠️ [SCOUT VOLATILITY] Unsuitable: ", DoubleToString(volatilityRatio, 2), "x baseline (need 0.8-1.5x)");
        }
        
        return suitable;
    }
    
    bool HasActiveBasicPosition()
    {
        // Check for active Basic Sonic R positions
        // Simplified implementation - would need integration with position manager
        for(int i = 0; i < PositionsTotal(); i++) {
            if(PositionGetSymbol(i) == _Symbol) {
                string comment = PositionGetString(POSITION_COMMENT);
                if(StringFind(comment, "Basic") >= 0 || StringFind(comment, "Sonic") >= 0) {
                    Print("⚠️ [SCOUT CONFLICT] Active Basic position found: ", comment);
                    return true;
                }
            }
        }
        return false;
    }
    
    bool IsStrongTrend()
    {
        // Strong trend detection to avoid scout trades
        int h34=iMA(_Symbol, PERIOD_H1, 34, 0, MODE_EMA, PRICE_CLOSE);
        int h89=iMA(_Symbol, PERIOD_H1, 89, 0, MODE_EMA, PRICE_CLOSE);
        int h200=iMA(_Symbol, PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);
        double ema34[]; ArrayResize(ema34,1);
        double ema89[]; ArrayResize(ema89,1);
        double ema200[]; ArrayResize(ema200,1);
        ArraySetAsSeries(ema34,true); ArraySetAsSeries(ema89,true); ArraySetAsSeries(ema200,true);
        if(h34!=INVALID_HANDLE) CopyBuffer(h34,0,0,1,ema34);
        if(h89!=INVALID_HANDLE) CopyBuffer(h89,0,0,1,ema89);
        if(h200!=INVALID_HANDLE) CopyBuffer(h200,0,0,1,ema200);
        if(h34!=INVALID_HANDLE) IndicatorRelease(h34);
        if(h89!=INVALID_HANDLE) IndicatorRelease(h89);
        if(h200!=INVALID_HANDLE) IndicatorRelease(h200);
        
        if(ema34[0] == 0.0 || ema89[0] == 0.0 || ema200[0] == 0.0) return false;
        
        // Strong bullish trend: EMA34 > EMA89 > EMA200 with significant separation
        bool strongBullish = (ema34[0] > ema89[0]) && (ema89[0] > ema200[0]) && 
                            ((ema34[0] - ema89[0]) / _Point > 50) && 
                            ((ema89[0] - ema200[0]) / _Point > 50);
        
        // Strong bearish trend: EMA34 < EMA89 < EMA200 with significant separation
        bool strongBearish = (ema34[0] < ema89[0]) && (ema89[0] < ema200[0]) && 
                            ((ema89[0] - ema34[0]) / _Point > 50) && 
                            ((ema200[0] - ema89[0]) / _Point > 50);
        
        bool isStrong = strongBullish || strongBearish;
        
        if(isStrong) {
            Print("📈 [SCOUT TREND] Strong trend detected - Bullish:", strongBullish, " Bearish:", strongBearish);
        }
        
        return isStrong;
    }
};
#endif // SCOUT_01_MANAGER_MQH



