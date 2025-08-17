//+------------------------------------------------------------------+
//|                     01_Core_02_ConfigManager.mqh                 |
//|                 SONIC R MC - Configuration Manager               |
//|              Centralized feature toggles & settings              |
//+------------------------------------------------------------------+
#ifndef CORE_02_CONFIG_MANAGER_MQH
#define CORE_02_CONFIG_MANAGER_MQH

#include "01_Core_09_SharedDataStructures.mqh"   // For CEaContext and dependencies

//+------------------------------------------------------------------+
//| ?? PHASE 1: MULTI-ASSET RISK MANAGEMENT FEATURE TOGGLES         |
//+------------------------------------------------------------------+
#define ENABLE_MULTI_ASSET_RISK         true    // Enable multi-asset risk management
#define ENABLE_ASSET_SPECIFIC_SIZING    true    // Enable asset-specific position sizing
#define ENABLE_ASSET_VOLATILITY_ADJ     true    // Enable asset volatility adjustments

//+------------------------------------------------------------------+
//| ?? PHASE 2: MARKET REGIME DETECTION FEATURE TOGGLES             |
//+------------------------------------------------------------------+
#define ENABLE_MARKET_REGIME_DETECTION  true    // Enable market regime detection
#define ENABLE_ASSET_REGIME_INTEGRATION true    // Enable asset-regime integration
#define ENABLE_REGIME_RISK_ADJUSTMENT   true    // Enable regime-based risk adjustment
#define ENABLE_ADAPTIVE_REGIME_PARAMS   true    // Enable adaptive regime parameters

//+------------------------------------------------------------------+
//| ?? PHASE 3: ADVANCED SIGNAL FILTERING FEATURES                  |
//+------------------------------------------------------------------+
#define ENABLE_REGIME_AWARE_FILTERING       true
#define ENABLE_ASSET_REGIME_SIGNAL_VALIDATION  true
#define ENABLE_DYNAMIC_SIGNAL_THRESHOLDS    true
#define ENABLE_CONTEXT_AWARE_CONFLUENCE     true
#define ENABLE_ADAPTIVE_SIGNAL_SCORING      true

// Phase 3 Features (Future Implementation)
#define ENABLE_ASSET_CORRELATION_RISK   false   // Asset correlation risk (Phase 3)

//+------------------------------------------------------------------+
//| CSettings - Loads and provides access to EA settings.            |
//+------------------------------------------------------------------+
class CSettings
{
public:
    CSettings() {}
    ~CSettings() {}

    bool Initialize();
    void Deinitialize();
    bool IsInitialized() const { return true; }
    void OnTick() {}

    // Settings getters (placeholder implementations)
    double GetLotSize() const { return 0.01; }
    int GetMagicNumber() const { return 12345; }
    string GetExpertName() const { return "SonicR_EA"; }
};

#endif // CORE_02_CONFIG_MANAGER_MQH

