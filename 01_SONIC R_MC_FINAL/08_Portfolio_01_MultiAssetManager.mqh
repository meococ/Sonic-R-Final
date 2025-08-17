//+------------------------------------------------------------------+
//|                        08_Portfolio_01_MultiAssetManager_V1.0.mqh |
//|                    SONIC R MC - MULTI-ASSET PORTFOLIO MANAGER     |
//|                              ?? ENTERPRISE PORTFOLIO SYSTEM       |
//+------------------------------------------------------------------+

#ifndef PORTFOLIO_MULTIASSETMANAGER_MQH
#define PORTFOLIO_MULTIASSETMANAGER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "03_MarketAnalysis_21_AssetDNA.mqh"
#include "06_RiskManagement_02_BlackSwanDetector.mqh"
#include "06_RiskManagement_03_CircuitBreaker.mqh"
#include "06_RiskManagement_05_CorrelationHeatMap.mqh"

// Forward declaration to break circular dependency
class CMultiAssetBacktest;


//+------------------------------------------------------------------+
//| ?? MULTI-ASSET STRUCTURES                                       |
//+------------------------------------------------------------------+
struct MultiAssetPosition {
string              symbol;
ENUM_ASSET_TYPE     assetType;
double              lotSize;
double              riskPercent;
double              correlationRisk;
double              regimeMultiplier;
bool                isActive;
datetime            openTime;
double              unrealizedPnL;
double              realizedPnL;

void Reset() {
symbol = "";
assetType = ASSET_FOREX;
lotSize = 0.0;
riskPercent = 0.0;
correlationRisk = 0.0;
regimeMultiplier = 1.0;
isActive = false;
openTime = 0;
unrealizedPnL = 0.0;
realizedPnL = 0.0;
}
};

struct AssetClassMetrics {
ENUM_ASSET_TYPE     assetType;
string              assetName;
int                 activePositions;
double              totalRisk;
double              totalPnL;
double              winRate;
double              profitFactor;
double              maxDrawdown;
double              sharpeRatio;
double              avgCorrelation;
double              volatilityScore;
bool                isOverexposed;

void Reset() {
assetType = ASSET_FOREX;
assetName = "";
activePositions = 0;
totalRisk = 0.0;
totalPnL = 0.0;
winRate = 0.0;
profitFactor = 0.0;
maxDrawdown = 0.0;
sharpeRatio = 0.0;
avgCorrelation = 0.0;
volatilityScore = 0.0;
isOverexposed = false;
}
};

struct PortfolioMetrics {
double              totalPortfolioRisk;
double              totalPortfolioPnL;
double              portfolioWinRate;
double              portfolioProfitFactor;
double              portfolioMaxDrawdown;
double              portfolioSharpeRatio;
double              diversificationRatio;
double              correlationRisk;
bool                isBalanced;
datetime            lastUpdate;

void Reset() {
totalPortfolioRisk = 0.0;
totalPortfolioPnL = 0.0;
portfolioWinRate = 0.0;
portfolioProfitFactor = 0.0;
portfolioMaxDrawdown = 0.0;
portfolioSharpeRatio = 0.0;
diversificationRatio = 0.0;
correlationRisk = 0.0;
isBalanced = true;
lastUpdate = 0;
}
};

//+------------------------------------------------------------------+
//| ?? MULTI-ASSET PORTFOLIO MANAGER CLASS                         |
//+------------------------------------------------------------------+
class CMultiAssetPortfolioManager {
private:
// Core data
MultiAssetPosition      m_positions[100];           // Support up to 100 positions
AssetClassMetrics       m_assetMetrics[5];          // 5 asset classes
PortfolioMetrics        m_portfolioMetrics;

// Configuration
double                  m_maxPortfolioRisk;         // Maximum total portfolio risk
double                  m_maxAssetClassRisk;        // Maximum risk per asset class
double                  m_maxCorrelationRisk;       // Maximum correlation risk
double                  m_targetDiversification;    // Target diversification ratio

// Asset allocation weights
double                  m_assetWeights[5];          // Target weights per asset class
double                  m_currentWeights[5];        // Current weights per asset class

// Risk management components
CBlackSwanDetector*     m_blackSwanDetector;
CCircuitBreaker*        m_circuitBreaker;
CCorrelationHeatMapManager*    m_correlationHeatMap;

// Analysis and testing components
CMultiAssetBacktest*    m_backtestEngine;
// CStressTestEngine*      m_stressTestEngine; // TODO: Implement when needed

// Risk management
bool                    m_riskLimitsEnabled;
bool                    m_correlationFilterEnabled;
bool                    m_rebalancingEnabled;

// Performance tracking
int                     m_totalTrades;
int                     m_winningTrades;
double                  m_totalProfit;
double                  m_totalLoss;

// Internal methods
void                    CheckRiskLimits();
void                    CheckRebalancing();
double                  CalculateAssetCorrelation(ENUM_ASSET_TYPE asset1, ENUM_ASSET_TYPE asset2);
double                  CalculateDiversificationRatio();
bool                    IsAssetClassOverexposed(ENUM_ASSET_TYPE assetType);

public:
// Constructor/Destructor
CMultiAssetPortfolioManager() {
    // Initialize positions
    for(int i = 0; i < 100; i++) {
        m_positions[i].Reset();
    }
    
    // Initialize asset metrics
    for(int i = 0; i < 5; i++) {
        m_assetMetrics[i].Reset();
        m_assetWeights[i] = 0.2;        // Equal weight by default
        m_currentWeights[i] = 0.0;
    }
    
    // Set asset types and names
    m_assetMetrics[0].assetType = ASSET_FOREX;
    m_assetMetrics[0].assetName = "Foreign Exchange";
    m_assetMetrics[1].assetType = ASSET_COMMODITY;
    m_assetMetrics[1].assetName = "Commodities";
    m_assetMetrics[2].assetType = ASSET_CRYPTO;
    m_assetMetrics[2].assetName = "Cryptocurrencies";
    m_assetMetrics[3].assetType = ASSET_INDEX;
    m_assetMetrics[3].assetName = "Stock Indices";
    m_assetMetrics[4].assetType = ASSET_BOND;
    m_assetMetrics[4].assetName = "Bonds";
    
    // Initialize portfolio metrics
    m_portfolioMetrics.Reset();
    
    // Initialize risk management components
    m_blackSwanDetector = new CBlackSwanDetector();
    m_circuitBreaker = new CCircuitBreaker();
    m_correlationHeatMap = new CCorrelationHeatMapManager();
    
    // Initialize analysis and testing components  
    m_backtestEngine = NULL;  // Will be created when needed to avoid circular dependency
    // m_stressTestEngine = NULL; // TODO: Initialize when implemented
    
    // Default configuration
    m_maxPortfolioRisk = 0.02;          // 2% max portfolio risk
    m_maxAssetClassRisk = 0.008;        // 0.8% max per asset class
    m_maxCorrelationRisk = 0.7;         // 70% max correlation
    m_targetDiversification = 0.8;      // 80% diversification target
    
    // Enable all features by default
    m_riskLimitsEnabled = true;
    m_correlationFilterEnabled = true;
    m_rebalancingEnabled = true;
    
    // Initialize performance tracking
    m_totalTrades = 0;
    m_winningTrades = 0;
    m_totalProfit = 0.0;
    m_totalLoss = 0.0;
}

~CMultiAssetPortfolioManager() {
    // Cleanup risk management components
    if(m_blackSwanDetector != NULL) {
        delete m_blackSwanDetector;
        m_blackSwanDetector = NULL;
    }
    
    if(m_circuitBreaker != NULL) {
        delete m_circuitBreaker;
        m_circuitBreaker = NULL;
    }
    
    if(m_correlationHeatMap != NULL) {
        delete m_correlationHeatMap;
        m_correlationHeatMap = NULL;
    }
    
    // Clean up analysis and testing components
    if(m_backtestEngine != NULL) {
        delete m_backtestEngine;
        m_backtestEngine = NULL;
    }
    
    // TODO: Cleanup stress test engine when implemented
    /*if(m_stressTestEngine != NULL) {
        delete m_stressTestEngine;
        m_stressTestEngine = NULL;
    }*/
}

// Initialization
bool Initialize(double maxPortfolioRisk = 0.02, 
               double maxAssetRisk = 0.008,
               double maxCorrelationRisk = 0.7) {
    // m_stressTestEngine = new CStressTestEngine(); // TODO: Implement CStressTestEngine class
    m_maxPortfolioRisk = MathMax(0.005, MathMin(0.05, maxPortfolioRisk));
    m_maxAssetClassRisk = MathMax(0.002, MathMin(0.02, maxAssetRisk));
    m_maxCorrelationRisk = MathMax(0.3, MathMin(1.0, maxCorrelationRisk));
    
    // Initialize risk management components
    if(m_blackSwanDetector != NULL) {
        // SYSTEMATIC FIX - Initialize() takes no parameters
        if(!m_blackSwanDetector.Initialize()) {
            Print("[?? MULTI-ASSET] ERROR: Failed to initialize Black Swan Detector");
            return false;
        }
        // Configure thresholds after initialization
        m_blackSwanDetector.SetVolatilityThreshold(3.0);
        m_blackSwanDetector.SetCorrelationThreshold(0.5);
        m_blackSwanDetector.SetLiquidityThreshold(0.3);
    }
    
    if(m_circuitBreaker != NULL) {
        if(!m_circuitBreaker.Initialize()) {
            Print("[?? MULTI-ASSET] ERROR: Failed to initialize Circuit Breaker");
            return false;
        }
    }
    
    if(m_correlationHeatMap != NULL) {
        // SYSTEMATIC FIX - Initialize function not implemented yet
        // if(!m_correlationHeatMap.Initialize(0.7)) {
        //     Print("[?? MULTI-ASSET] ERROR: Failed to initialize Correlation Heat Map");
        //     return false;
        // }
        Print("[?? MULTI-ASSET] Correlation Heat Map created (initialization pending)");
    }
    
    // Initialize portfolio metrics
    // SYSTEMATIC FIX - Function not implemented yet
    // UpdatePortfolioMetrics(0.02, 0.008);
    
    Print(StringFormat("[?? MULTI-ASSET] Portfolio Manager initialized - Max Risk: %.1f%%, Max Asset Risk: %.1f%%, Max Correlation: %.1f%%",
          m_maxPortfolioRisk * 100, m_maxAssetClassRisk * 100, m_maxCorrelationRisk * 100));
    Print("[?? MULTI-ASSET] Crisis protection systems: ACTIVE");
    
    return true;
}

// All methods are already declared in the class and will be implemented separately
// This section was causing duplicate member function errors and has been removed

};

#endif // PORTFOLIO_MULTIASSETMANAGER_MQH
