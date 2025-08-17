//+------------------------------------------------------------------+
//|                       SONIC_Signal_Generator.mqh                |
//|                  OPTIMIZED SIGNAL GENERATION ENGINE             |
//+------------------------------------------------------------------+
#ifndef SONIC_SIGNAL_GENERATOR_H
#define SONIC_SIGNAL_GENERATOR_H

//+------------------------------------------------------------------+
//| SIGNAL TYPES                                                    |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE {
    SIGNAL_NONE = 0,
    SIGNAL_BUY = 1,
    SIGNAL_SELL = -1
};

//+------------------------------------------------------------------+
//| SIGNAL DATA STRUCTURE                                           |
//+------------------------------------------------------------------+
struct SignalData {
    ENUM_SIGNAL_TYPE type;
    double entry_price;
    double stop_loss;
    double take_profit;
    double lot_size;
    double confidence;
    string strategy_name;
    datetime signal_time;
    
    void Reset() {
        type = SIGNAL_NONE;
        entry_price = 0;
        stop_loss = 0;
        take_profit = 0;
        lot_size = 0;
        confidence = 0;
        strategy_name = "";
        signal_time = 0;
    }
};

//+------------------------------------------------------------------+
//| MULTI-STRATEGY SIGNAL GENERATOR                                 |
//+------------------------------------------------------------------+
class CSignalGenerator {
private:
    // Cached indicator values
    double m_ema34[], m_ema89[], m_ema200[];
    double m_atr[], m_rsi[], m_volume[];
    
    // H4 trend analysis
    double m_h4_ema34, m_h4_ema89, m_h4_ema200;
    
    // Performance tracking
    int m_signals_generated;
    int m_signals_executed;
    double m_avg_confidence;
    
public:
    //+------------------------------------------------------------------+
    CSignalGenerator() {
        m_signals_generated = 0;
        m_signals_executed = 0;
        m_avg_confidence = 0;
    }
    
    //+------------------------------------------------------------------+
    SignalData GenerateSignal(double &ema34[], double &ema89[], double &ema200[],
                             double &atr[], double &rsi[], string symbol) {
        SignalData signal;
        signal.Reset();
        
        // Copy arrays
        ArrayCopy(m_ema34, ema34);
        ArrayCopy(m_ema89, ema89);
        ArrayCopy(m_ema200, ema200);
        ArrayCopy(m_atr, atr);
        ArrayCopy(m_rsi, rsi);
        
        // Run multi-strategy analysis
        SignalData sonic_signal = GenerateSonicSignal(symbol);
        SignalData scout_signal = GenerateScoutSignal(symbol);
        SignalData vpsra_signal = GenerateVPSRASignal(symbol);
        
        // Select best signal based on confidence
        signal = SelectBestSignal(sonic_signal, scout_signal, vpsra_signal);
        
        if(signal.type != SIGNAL_NONE) {
            m_signals_generated++;
            m_avg_confidence = (m_avg_confidence * (m_signals_generated - 1) + signal.confidence) / m_signals_generated;
            signal.signal_time = TimeCurrent();
        }
        
        return signal;
    }
    
    //+------------------------------------------------------------------+
    // SONIC R STRATEGY - 5 LAYER VALIDATION
    //+------------------------------------------------------------------+
    SignalData GenerateSonicSignal(string symbol) {
        SignalData signal;
        signal.Reset();
        signal.strategy_name = "SONIC_R";
        
        // Layer 1: Trend alignment
        bool uptrend = m_ema34[0] > m_ema89[0] && m_ema89[0] > m_ema200[0];
        bool downtrend = m_ema34[0] < m_ema89[0] && m_ema89[0] < m_ema200[0];
        
        if(!uptrend && !downtrend) return signal;
        
        // Layer 2: Pullback detection
        double current_price = SymbolInfoDouble(symbol, SYMBOL_BID);
        bool pullback_buy = uptrend && current_price < m_ema34[0] && current_price > m_ema89[0];
        bool pullback_sell = downtrend && current_price > m_ema34[0] && current_price < m_ema89[0];
        
        if(!pullback_buy && !pullback_sell) return signal;
        
        // Layer 3: RSI momentum
        bool rsi_buy = m_rsi[0] > 40 && m_rsi[0] < 60 && m_rsi[0] > m_rsi[1];
        bool rsi_sell = m_rsi[0] < 60 && m_rsi[0] > 40 && m_rsi[0] < m_rsi[1];
        
        // Layer 4: Volume confirmation
        double avg_volume = CalculateAverageVolume(symbol, 20);
        double current_volume = iVolume(symbol, PERIOD_M15, 0);
        bool volume_confirm = current_volume > avg_volume * 1.2;
        
        // Layer 5: H4 trend confirmation
        UpdateH4Trend(symbol);
        bool h4_uptrend = m_h4_ema34 > m_h4_ema89 && m_h4_ema89 > m_h4_ema200;
        bool h4_downtrend = m_h4_ema34 < m_h4_ema89 && m_h4_ema89 < m_h4_ema200;
        
        // Generate signal
        if(pullback_buy && rsi_buy && volume_confirm && h4_uptrend) {
            signal.type = SIGNAL_BUY;
            signal.entry_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
            signal.stop_loss = signal.entry_price - m_atr[0] * 1.5;
            signal.take_profit = signal.entry_price + m_atr[0] * 2.5;
            signal.confidence = CalculateSonicConfidence(true, volume_confirm);
        }
        else if(pullback_sell && rsi_sell && volume_confirm && h4_downtrend) {
            signal.type = SIGNAL_SELL;
            signal.entry_price = SymbolInfoDouble(symbol, SYMBOL_BID);
            signal.stop_loss = signal.entry_price + m_atr[0] * 1.5;
            signal.take_profit = signal.entry_price - m_atr[0] * 2.5;
            signal.confidence = CalculateSonicConfidence(false, volume_confirm);
        }
        
        return signal;
    }
    
    //+------------------------------------------------------------------+
    // SCOUT STRATEGY - SIDEWAYS MARKET
    //+------------------------------------------------------------------+
    SignalData GenerateScoutSignal(string symbol) {
        SignalData signal;
        signal.Reset();
        signal.strategy_name = "SCOUT";
        
        // Check for ranging market
        double trend_strength = MathAbs(m_ema34[0] - m_ema200[0]) / m_atr[0];
        if(trend_strength > 2.0) return signal; // Too trendy
        
        // Identify support/resistance
        double high_20 = iHigh(symbol, PERIOD_M15, iHighest(symbol, PERIOD_M15, MODE_HIGH, 20, 1));
        double low_20 = iLow(symbol, PERIOD_M15, iLowest(symbol, PERIOD_M15, MODE_LOW, 20, 1));
        double range = high_20 - low_20;
        
        if(range < m_atr[0] * 2) return signal; // Range too small
        
        double current_price = SymbolInfoDouble(symbol, SYMBOL_BID);
        
        // Buy at support
        if(current_price - low_20 < m_atr[0] * 0.3 && m_rsi[0] < 35) {
            signal.type = SIGNAL_BUY;
            signal.entry_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
            signal.stop_loss = low_20 - m_atr[0] * 0.5;
            signal.take_profit = signal.entry_price + range * 0.7;
            signal.confidence = 0.65;
        }
        // Sell at resistance
        else if(high_20 - current_price < m_atr[0] * 0.3 && m_rsi[0] > 65) {
            signal.type = SIGNAL_SELL;
            signal.entry_price = SymbolInfoDouble(symbol, SYMBOL_BID);
            signal.stop_loss = high_20 + m_atr[0] * 0.5;
            signal.take_profit = signal.entry_price - range * 0.7;
            signal.confidence = 0.65;
        }
        
        return signal;
    }
    
    //+------------------------------------------------------------------+
    // VPSRA STRATEGY - VOLUME ANALYSIS
    //+------------------------------------------------------------------+
    SignalData GenerateVPSRASignal(string symbol) {
        SignalData signal;
        signal.Reset();
        signal.strategy_name = "VPSRA";
        
        // Volume analysis
        double avg_volume = CalculateAverageVolume(symbol, 10);
        double current_volume = iVolume(symbol, PERIOD_M15, 0);
        double prev_volume = iVolume(symbol, PERIOD_M15, 1);
        
        // Climactic volume detection
        bool climactic_volume = current_volume > avg_volume * 2.5;
        if(!climactic_volume) return signal;
        
        // Price action analysis
        double close = iClose(symbol, PERIOD_M15, 0);
        double open = iOpen(symbol, PERIOD_M15, 0);
        double high = iHigh(symbol, PERIOD_M15, 0);
        double low = iLow(symbol, PERIOD_M15, 0);
        double range = high - low;
        
        // Bullish reversal
        if(close > open && close > (low + range * 0.7)) {
            signal.type = SIGNAL_BUY;
            signal.entry_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
            signal.stop_loss = low - m_atr[0] * 0.5;
            signal.take_profit = signal.entry_price + m_atr[0] * 3.0;
            signal.confidence = 0.70;
        }
        // Bearish reversal
        else if(close < open && close < (high - range * 0.7)) {
            signal.type = SIGNAL_SELL;
            signal.entry_price = SymbolInfoDouble(symbol, SYMBOL_BID);
            signal.stop_loss = high + m_atr[0] * 0.5;
            signal.take_profit = signal.entry_price - m_atr[0] * 3.0;
            signal.confidence = 0.70;
        }
        
        return signal;
    }
    
    //+------------------------------------------------------------------+
    // SELECT BEST SIGNAL
    //+------------------------------------------------------------------+
    SignalData SelectBestSignal(SignalData &sonic, SignalData &scout, SignalData &vpsra) {
        SignalData best_signal;
        best_signal.Reset();
        
        // Select highest confidence signal
        double max_confidence = 0;
        
        if(sonic.confidence > max_confidence && sonic.type != SIGNAL_NONE) {
            best_signal = sonic;
            max_confidence = sonic.confidence;
        }
        
        if(scout.confidence > max_confidence && scout.type != SIGNAL_NONE) {
            best_signal = scout;
            max_confidence = scout.confidence;
        }
        
        if(vpsra.confidence > max_confidence && vpsra.type != SIGNAL_NONE) {
            best_signal = vpsra;
            max_confidence = vpsra.confidence;
        }
        
        // Confluence boost
        int signal_count = 0;
        if(sonic.type != SIGNAL_NONE) signal_count++;
        if(scout.type != SIGNAL_NONE) signal_count++;
        if(vpsra.type != SIGNAL_NONE) signal_count++;
        
        if(signal_count >= 2) {
            best_signal.confidence = MathMin(best_signal.confidence * 1.2, 0.95);
        }
        
        return best_signal;
    }
    
private:
    //+------------------------------------------------------------------+
    double CalculateSonicConfidence(bool is_buy, bool volume_confirm) {
        double confidence = 0.5; // Base confidence
        
        // Trend strength
        double trend_score = MathAbs(m_ema34[0] - m_ema200[0]) / m_atr[0];
        confidence += MathMin(trend_score * 0.1, 0.2);
        
        // RSI position
        if(is_buy && m_rsi[0] > 45 && m_rsi[0] < 55) confidence += 0.1;
        if(!is_buy && m_rsi[0] < 55 && m_rsi[0] > 45) confidence += 0.1;
        
        // Volume confirmation
        if(volume_confirm) confidence += 0.15;
        
        // H4 alignment
        bool h4_aligned = (is_buy && m_h4_ema34 > m_h4_ema200) ||
                         (!is_buy && m_h4_ema34 < m_h4_ema200);
        if(h4_aligned) confidence += 0.1;
        
        return MathMin(confidence, 0.85);
    }
    
    //+------------------------------------------------------------------+
    double CalculateAverageVolume(string symbol, int periods) {
        double sum = 0;
        for(int i = 1; i <= periods; i++) {
            sum += iVolume(symbol, PERIOD_M15, i);
        }
        return sum / periods;
    }
    
    //+------------------------------------------------------------------+
    void UpdateH4Trend(string symbol) {
        double h4_ema34[], h4_ema89[], h4_ema200[];
        ArraySetAsSeries(h4_ema34, true);
        ArraySetAsSeries(h4_ema89, true);
        ArraySetAsSeries(h4_ema200, true);
        
        int h4_handle34 = iMA(symbol, PERIOD_H4, 34, 0, MODE_EMA, PRICE_CLOSE);
        int h4_handle89 = iMA(symbol, PERIOD_H4, 89, 0, MODE_EMA, PRICE_CLOSE);
        int h4_handle200 = iMA(symbol, PERIOD_H4, 200, 0, MODE_EMA, PRICE_CLOSE);
        
        if(CopyBuffer(h4_handle34, 0, 0, 1, h4_ema34) > 0) m_h4_ema34 = h4_ema34[0];
        if(CopyBuffer(h4_handle89, 0, 0, 1, h4_ema89) > 0) m_h4_ema89 = h4_ema89[0];
        if(CopyBuffer(h4_handle200, 0, 0, 1, h4_ema200) > 0) m_h4_ema200 = h4_ema200[0];
        
        IndicatorRelease(h4_handle34);
        IndicatorRelease(h4_handle89);
        IndicatorRelease(h4_handle200);
    }
    
public:
    //+------------------------------------------------------------------+
    string GetPerformanceReport() {
        return StringFormat("Signals: %d | Executed: %d | Avg Confidence: %.1f%%",
                          m_signals_generated, m_signals_executed, m_avg_confidence * 100);
    }
    
    void MarkSignalExecuted() { m_signals_executed++; }
};

#endif // SONIC_SIGNAL_GENERATOR_H
