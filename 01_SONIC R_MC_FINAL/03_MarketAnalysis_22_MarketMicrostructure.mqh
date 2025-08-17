//+------------------------------------------------------------------+
//|                  03_MarketAnalysis_22_MarketMicrostructure.mqh |
//|                    SONIC R MC - MARKET MICROSTRUCTURE ANALYSIS |
//|                    IMPLEMENTS ADVANCED MARKET ANALYSIS         |
//+------------------------------------------------------------------+
#ifndef MARKET_MICROSTRUCTURE_MQH
#define MARKET_MICROSTRUCTURE_MQH

#include "00_Main_MasterIncludes.mqh"

//+------------------------------------------------------------------+
//| MARKET MICROSTRUCTURE DATA STRUCTURES                            |
//+------------------------------------------------------------------+
struct SMarketMicroData {
    double orderFlowImbalance;
    double volumeDelta;
    double pricePressure;
    double liquidityLevels;
    double marketDepthRatio;
    datetime analysisTime;
    bool isValid;
};

//+------------------------------------------------------------------+
//| MARKET MICROSTRUCTURE ANALYZER CLASS                            |
//+------------------------------------------------------------------+
class CMarketMicrostructureAnalyzer {
private:
    SMarketMicroData m_microData;
    int m_tickVolumeHandle;
    int m_bookDepthHandle;
    
public:
    CMarketMicrostructureAnalyzer();
    ~CMarketMicrostructureAnalyzer();
    
    bool Initialize();
    bool UpdateMicrostructure();
    SMarketMicroData GetMicroData() const { return m_microData; }
    
    // Analysis methods
    double CalculateOrderFlowImbalance();
    double CalculateVolumeDelta();
    double CalculatePricePressure();
    double CalculateLiquidityLevels();
    double CalculateMarketDepthRatio();
    
    // Decision methods
    bool IsInstitutionalActivity();
    bool IsLiquiditySqueeze();
    bool IsOrderFlowAnomalous();
};

//+------------------------------------------------------------------+
//| CONSTRUCTOR                                                      |
//+------------------------------------------------------------------+
CMarketMicrostructureAnalyzer::CMarketMicrostructureAnalyzer() {
    m_bookDepthHandle = INVALID_HANDLE;
    m_microData.orderFlowImbalance = 0.0;
    m_microData.volumeDelta = 0.0;
    m_microData.pricePressure = 0.0;
    m_microData.liquidityLevels = 0.0;
    m_microData.marketDepthRatio = 0.0;
    m_microData.analysisTime = 0;
    m_microData.isValid = false;
}

//+------------------------------------------------------------------+
//| DESTRUCTOR                                                       |
//+------------------------------------------------------------------+
CMarketMicrostructureAnalyzer::~CMarketMicrostructureAnalyzer() {
    if(m_bookDepthHandle != INVALID_HANDLE) {
        IndicatorRelease(m_bookDepthHandle);
    }
}

//+------------------------------------------------------------------+
//| INITIALIZATION                                                   |
//+------------------------------------------------------------------+
bool CMarketMicrostructureAnalyzer::Initialize() {
    // Note: No tick volume handle needed, using direct CopyTickVolume
    
    // Initialize market depth (if available)
    // Note: Market depth requires special broker permissions
    m_bookDepthHandle = INVALID_HANDLE;
    
    Print("✅ Market Microstructure Analyzer initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| UPDATE MARKET MICROSTRUCTURE                                     |
//+------------------------------------------------------------------+
bool CMarketMicrostructureAnalyzer::UpdateMicrostructure() {
    // Calculate all microstructure metrics
    m_microData.orderFlowImbalance = CalculateOrderFlowImbalance();
    m_microData.volumeDelta = CalculateVolumeDelta();
    m_microData.pricePressure = CalculatePricePressure();
    m_microData.liquidityLevels = CalculateLiquidityLevels();
    m_microData.marketDepthRatio = CalculateMarketDepthRatio();
    m_microData.analysisTime = TimeCurrent();
    m_microData.isValid = true;
    
    return true;
}

//+------------------------------------------------------------------+
//| CALCULATE ORDER FLOW IMBALANCE                                   |
//+------------------------------------------------------------------+
double CMarketMicrostructureAnalyzer::CalculateOrderFlowImbalance() {
    // Simplified calculation - in a full implementation
    // this would analyze bid/ask volume distribution
    double buyVolume = 0;
    double sellVolume = 0;
    
    // Get recent tick data
    // This is a placeholder - actual implementation
    // would require more sophisticated data access
    
    if(buyVolume + sellVolume == 0) return 0;
    
    return (buyVolume - sellVolume) / (buyVolume + sellVolume);
}

//+------------------------------------------------------------------+
//| CALCULATE VOLUME DELTA                                           |
//+------------------------------------------------------------------+
double CMarketMicrostructureAnalyzer::CalculateVolumeDelta() {
    // Calculate the difference between buying and selling volume
    double volumeDelta = 0;
    
    // Get volume data for recent periods
    long volumes[];
    ArraySetAsSeries(volumes, true);
    
    if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 10, volumes) <= 0) {
        return 0;
    }
    
    // Simple delta calculation
    if(ArraySize(volumes) >= 2) {
        volumeDelta = (double)(volumes[0] - volumes[1]);
    }
    
    return volumeDelta;
}

//+------------------------------------------------------------------+
//| CALCULATE PRICE PRESSURE                                         |
//+------------------------------------------------------------------+
double CMarketMicrostructureAnalyzer::CalculatePricePressure() {
    // Calculate price pressure based on recent price movements
    double pricePressure = 0;
    
    // Get recent price data
    double prices[];
    ArraySetAsSeries(prices, true);
    
    if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 5, prices) <= 0) {
        return 0;
    }
    
    // Simple pressure calculation
    if(ArraySize(prices) >= 2) {
        pricePressure = (prices[0] - prices[1]) / prices[1];
    }
    
    return pricePressure;
}

//+------------------------------------------------------------------+
//| CALCULATE LIQUIDITY LEVELS                                       |
//+------------------------------------------------------------------+
double CMarketMicrostructureAnalyzer::CalculateLiquidityLevels() {
    // Calculate liquidity levels based on volume and spread
    double liquidityLevel = 0;
    
    // Get current spread
    double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    if(point > 0) {
        liquidityLevel = spread / point;
    }
    
    return liquidityLevel;
}

//+------------------------------------------------------------------+
//| CALCULATE MARKET DEPTH RATIO                                     |
//+------------------------------------------------------------------+
double CMarketMicrostructureAnalyzer::CalculateMarketDepthRatio() {
    // Calculate market depth ratio (simplified)
    double depthRatio = 1.0;
    
    // In a full implementation, this would analyze
    // the order book depth and calculate ratios
    
    return depthRatio;
}

//+------------------------------------------------------------------+
//| INSTITUTIONAL ACTIVITY DETECTION                                 |
//+------------------------------------------------------------------+
bool CMarketMicrostructureAnalyzer::IsInstitutionalActivity() {
    // Detect institutional activity based on volume patterns
    bool institutionalActivity = false;
    
    // Check for large volume spikes
    long volumes[];
    ArraySetAsSeries(volumes, true);
    
    if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 20, volumes) > 0) {
        // Calculate average volume
        double avgVolume = 0;
        for(int i = 0; i < ArraySize(volumes); i++) {
            avgVolume += (double)volumes[i];
        }
        avgVolume /= (double)ArraySize(volumes);
        
        // Check if current volume is significantly higher
        if((double)volumes[0] > avgVolume * 2.0) {
            institutionalActivity = true;
        }
    }
    
    return institutionalActivity;
}

//+------------------------------------------------------------------+
//| LIQUIDITY SQUEEZE DETECTION                                      |
//+------------------------------------------------------------------+
bool CMarketMicrostructureAnalyzer::IsLiquiditySqueeze() {
    // Detect liquidity squeeze based on microstructure data
    bool liquiditySqueeze = false;
    
    // Check for low liquidity conditions
    double spread = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    if(point > 0 && spread > point * 10) {
        liquiditySqueeze = true;
    }
    
    return liquiditySqueeze;
}

//+------------------------------------------------------------------+
//| ORDER FLOW ANOMALY DETECTION                                     |
//+------------------------------------------------------------------+
bool CMarketMicrostructureAnalyzer::IsOrderFlowAnomalous() {
    // Detect anomalous order flow patterns
    bool anomalousFlow = false;
    
    // Check for unusual volume patterns
    long volumes[];
    ArraySetAsSeries(volumes, true);
    
    if(CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 10, volumes) > 0) {
        // Calculate volume volatility
        double avgVolume = 0;
        double variance = 0;
        
        for(int i = 0; i < ArraySize(volumes); i++) {
            avgVolume += (double)volumes[i];
        }
        avgVolume /= (double)ArraySize(volumes);
        
        for(int i = 0; i < ArraySize(volumes); i++) {
            variance += MathPow((double)volumes[i] - avgVolume, 2);
        }
        variance /= (double)ArraySize(volumes);
        
        // If current volume is significantly different from average
        if(MathAbs((double)volumes[0] - avgVolume) > MathSqrt(variance) * 2.0) {
            anomalousFlow = true;
        }
    }
    
    return anomalousFlow;
}

#endif // MARKET_MICROSTRUCTURE_MQH
