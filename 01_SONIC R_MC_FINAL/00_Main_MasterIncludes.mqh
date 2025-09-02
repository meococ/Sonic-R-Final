//+------------------------------------------------------------------+
//|                               00_Main_MasterIncludes.mqh      |
//|                    SONIC R MC - MASTER INCLUDE MANAGER         |
//|                    BOSS'S UNIFIED INCLUDE SYSTEM              |
//+------------------------------------------------------------------+
#ifndef MASTER_INCLUDES_MQH
#define MASTER_INCLUDES_MQH

// MQL5 Standard Definitions removed due to conflicts with built-in library

// Include Map & Responsibilities (read-first)
// 1) Core Enums → Sonic Enums → Inputs → Common Structures
// 2) Core runtime (Engine/Logger/Config/Context/Utils/IndicatorManager)
// 3) Signal APIs prototypes → implementations (ConsolidatedSignals)
// 4) Market Analysis (gated by feature flags, light first, heavy under ENABLE_SMC_ANALYSIS_FILES)
// 5) Trading/Risk → UI/Testing → Architecture → Optional modules
// Notes:
// - Preserve this order to avoid include cycles and undeclared identifiers.
// - Add new public types to Enums/Structures and include earlier if cross-module.
// - For experimental modules, add a dedicated FEATURE_* and keep default OFF.

// === LEGACY FACADE ORDER (REMOVED) ===
// The following legacy facades were removed because files do not exist in this repo
// and cause compile cascades. All real modules are included explicitly below.
// Core_Types.mqh / Core_Inputs.mqh / Core_Config.mqh / Core_AutoProfile.mqh
// Data_Providers.mqh / Core_Runtime.mqh / MarketAnalysis_SonicCore.mqh / MarketAnalysis_Ext.mqh
// #include "plugins/PVSRA_Port.mqh"


// Ensure BP() and bypass stats are available to signal/UI layers
#include "01_Core_04_Stats.mqh"
// #include "Signals_Consolidated.mqh"  // removed: no such facade. Real signal modules are included below.

// Deprecated facades removed to avoid missing-file errors; rely on modular includes below
// #include "Trading_StopsAndSizing.mqh"   // removed
// #include "Risk_Management.mqh"          // included via INCLUDE_RISK_MANAGEMENT block
// #include "Trading_Gateway.mqh"          // replaced by 05_Trading_03_TradeGate.mqh in modules
// #include "UI_Min.mqh"                    // removed (use 16_UI_* modules)
// #include "Testing_Debug.mqh"             // removed (testing modules gated)

// === END NEW FACADE ORDER ===

//+------------------------------------------------------------------+
//| MASTER INCLUDE CONTROL SYSTEM                                   |
//+------------------------------------------------------------------+
// Control Matrix (quick reference)
// - Feature flags gate functional families.
// - Module flags gate include groups.
// - For lightweight/testing builds, keep only CORE/DATA/SIGNALS/TRADING minimal.
// - To enable heavy SMC analysis internals, define ENABLE_SMC_ANALYSIS_FILES below.


// === BUILD PROFILES (High-level) ===
// Chọn 1 trong 3 profile: định nghĩa BUILD_PROFILE_ORCH hoặc BUILD_PROFILE_SMC ở lệnh compile hoặc file cấu hình.
// Mặc định nếu không định nghĩa gì → BUILD_PROFILE_LIGHT.
#ifndef BUILD_PROFILE_LIGHT
#ifndef BUILD_PROFILE_ORCH
#ifndef BUILD_PROFILE_SMC
#define BUILD_PROFILE_LIGHT
#endif
#endif
#endif

// === HARD LOCK: Force LIGHT build & disable heavy SMC/MO unless explicitly allowed ===
#ifndef SONIC_ALLOW_HEAVY
  // Force Light profile
  #undef BUILD_PROFILE_ORCH
  #undef BUILD_PROFILE_SMC
  #ifndef BUILD_PROFILE_LIGHT
    #define BUILD_PROFILE_LIGHT
  #endif
  // Ensure heavy features are OFF regardless of external defines
  #undef ENABLE_SMC_ANALYSIS_FILES
  #undef FEATURE_SMC_INTEGRATION
  #undef FEATURE_MASTER_ORCHESTRATOR
#endif


// Profile → Flags mapping (tránh dùng biểu thức số học để né hành vi tiền xử lý MQL5)
#ifdef BUILD_PROFILE_LIGHT
  #undef FEATURE_MASTER_ORCHESTRATOR
  #undef FEATURE_SMC_INTEGRATION
  #undef ENABLE_SMC_ANALYSIS_FILES
  #undef FEATURE_CONFLUENCE_ENGINE
  // Không define INCLUDE_RISK_MANAGEMENT trong Light
#endif

#ifdef BUILD_PROFILE_ORCH
  // Orchestrator only (không bật SMC internals)
  #undef FEATURE_MASTER_ORCHESTRATOR
  #define FEATURE_MASTER_ORCHESTRATOR
  #undef ENABLE_SMC_ANALYSIS_FILES
  #undef FEATURE_SMC_INTEGRATION
  // Không define INCLUDE_RISK_MANAGEMENT ở profile này (giữ nhẹ)
#endif

#ifdef BUILD_PROFILE_SMC
  // Full SMC (bật dần theo cụm sau khi build ổn)
  #undef FEATURE_MASTER_ORCHESTRATOR
  #define FEATURE_MASTER_ORCHESTRATOR
  #undef FEATURE_SMC_INTEGRATION
  #define FEATURE_SMC_INTEGRATION
  // ENABLE_SMC_ANALYSIS_FILES sẽ được bật dần (không bật mặc định)
#endif

// Feature Toggle System (normalized to numeric for consistency)
#define FEATURE_PVSRA_V2           1   // PVSRA analysis stack
// #define FEATURE_SMC_INTEGRATION    1   // Public SMC API + light adapters
#undef FEATURE_SMC_INTEGRATION  // ensure disabled for lightweight build
#define FEATURE_MULTI_TIMEFRAME    1   // MTF helpers enabled
#define FEATURE_DRAGON_BAND        1   // Dragon band + analyzer
// #define FEATURE_WAVE_PATTERN     0   // Wave analyzers (kept off by default)
// #define FEATURE_CONFLUENCE_ENGINE  1   // Confluence weighting/resolve
#undef FEATURE_CONFLUENCE_ENGINE
// #define FEATURE_SCENARIO_MANAGER   0   // Scenario profiles/manager (frozen by refactor)
#define FEATURE_INTELLIGENT_RISK   1   // Advanced risk modules
#include "06_RiskManagement_17_DailyLossAndPositionGates.mqh"

#define FEATURE_DASHBOARD          1   // UI dashboard/overlays
#define FEATURE_COMPLIANCE         1   // Prop-firm compliance layer
// Opt-in: Master Orchestrator (SMC + consolidated analysis) — defined by profile mapping above
// (no default define here to avoid redefinition)

// Heavy SMC internals (structures/fvg/pattern pipelines)
// Enable to allow Master Orchestrator include
// #define ENABLE_SMC_ANALYSIS_FILES
// Explicitly mark we want master orchestrator (stubbed) — only for ORCH/SMC profiles
#ifdef BUILD_PROFILE_ORCH
  #define SONIC_ENABLE_MASTER
  #define SONIC_MASTER_STUB
#endif
#ifdef BUILD_PROFILE_SMC
  #ifndef SONIC_ENABLE_MASTER
    #define SONIC_ENABLE_MASTER
  #endif
  #ifndef SONIC_MASTER_STUB
    #define SONIC_MASTER_STUB
  #endif
#endif

// Module control flags - Enable/Disable include groups
// Comment out a line to DISABLE that module, uncomment to ENABLE
#define INCLUDE_CORE_MODULES        // ENABLED
#define INCLUDE_DATA_PROVIDERS      // ENABLED for overlays
#define INCLUDE_MARKET_ANALYSIS     // ENABLED (minimal features)


#define INCLUDE_SIGNAL_GENERATION   // ENABLED
#define INCLUDE_TRADING_MODULES     // ENABLED
// #define INCLUDE_RISK_MANAGEMENT     // DISABLED for lightweight build
// #define INCLUDE_AI_ML_MODULES       // DISABLED
// #define INCLUDE_PORTFOLIO_MODULES   // DISABLED
// #define INCLUDE_PERFORMANCE_MODULES // DISABLED for lightweight build
// #define INCLUDE_TESTING_MODULES     // DISABLED for production build
// #define INCLUDE_COMPLIANCE_MODULES  // DISABLED for lightweight build
// #define INCLUDE_ARCHITECTURE_MODULES // DISABLED (modules removed)
// #define INCLUDE_RELIABILITY_MODULES // DISABLED
// #define INCLUDE_REPORTS_MODULES     // DISABLED for lightweight build
// #define INCLUDE_NEWS_MODULES        // DISABLED for lightweight build
#define INCLUDE_UI_MODULES          // ENABLED: overlays only

// Provide minimal PVSRA enum when analysis is disabled (for UI overlays)
#ifndef INCLUDE_MARKET_ANALYSIS
#define HAVE_MINIMAL_PVSRA_ENUM 1
#endif

//+------------------------------------------------------------------+
//| MQL5 STANDARD LIBRARY                                            |
//+------------------------------------------------------------------+
#include <Trade/SymbolInfo.mqh>      // Provides CSymbolInfo for symbol data access
#include <Trade/Trade.mqh>           // Provides CTrade for trading operations
#include <Trade/PositionInfo.mqh>    // Provides CPositionInfo for position management
#include <Trade/OrderInfo.mqh>       // Provides COrderInfo for order management
//+------------------------------------------------------------------+
//| 01_CORE - Core System(15 modules)                             |
//+------------------------------------------------------------------+
#ifdef INCLUDE_CORE_MODULES
// ENUMS FIRST - Before any files that use them
#include "01_Core_14_CoreEnums.mqh"               // Core Enums (must be first)
#include "01_Core_22_SonicEnums.mqh"              // Sonic-specific enums

// STRATEGY DOCUMENTATION - NEW: Complete implementation mapping
// Strategy documentation omitted (file not present)

// INPUTS AND STRUCTURES - After enums are defined
#include "01_Core_00_Inputs.mqh"               // SSOT: Centralized Inputs
#include "01_Core_03_DebugHelpers.mqh"       // DPrint/DPrintBT/__isBT helpers
#include "01_Core_23_UtilityFunctions.mqh"     // SYSTEMATIC FIX - Utility functions
#include "01_Core_24_ProfileOverrides.mqh"   // Profile-aware getters
#include "01_Core_25_Metrics.mqh"            // Lightweight metrics

#include "01_Core_07_CommonStructures.mqh"     // Common data structures

// CORE MODULES - After enums and structures
#include "01_Core_18_IndicatorManager.mqh"
#include "01_Core_17_Utils.mqh"
#include "04_SignalGeneration_00_ConsolidatedSignals.api.mqh"  // prototypes first
#include "04_SignalGeneration_01_ConsolidatedSignals.mqh"      // implementations

#include "01_Core_01_Engine.mqh"               // Engine sees prototypes
    #include "01_Core_03_AutoProfile.mqh"           // Auto Profile Engine (APE)
    #include "01_Core_04_Stats.mqh"               // BYPASS stats + trace


#include "01_Core_02_ConfigManager.mqh"        // Core numbering contiguous
#include "01_Core_03_Logger.mqh"
#include "01_Core_ErrorHandler.mqh"         // Consolidated Error Handler
#include "01_Core_21_ErrorConstants_Clean.mqh"    // Clean error constants
#include "01_Core_08_ContextManager.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_19_SecurityHardening.mqh"      // Security hardening
#include "01_Core_16_EnumHelpers.mqh"             // Enum helpers
#endif
    #include "01_Core_98_Compat.mqh"           // Legacy compatibility shims
    #include "01_Core_99_SyntacticGuards.mqh"   // Syntactic guards & feature gates

//+------------------------------------------------------------------+
//| 02_DATA_PROVIDERS - Data Providers(6 modules)                 |
//+------------------------------------------------------------------+
#ifdef INCLUDE_DATA_PROVIDERS
#include "02_DataProviders_01_SymbolInfo_Primary.mqh"
// Removed: 02_DataProviders_02_SymbolInfo_Legacy.mqh - wrapper file
#include "02_DataProviders_03_SessionManager.mqh"
#include "02_DataProviders_04_TimeManager.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"  // Unified Indicator Manager
#include "02_DataProviders_06_SMCConfig.mqh"
#endif
//+------------------------------------------------------------------+
//| 03_MARKET_ANALYSIS - Market Analysis(23 modules)              |
//+------------------------------------------------------------------+
#ifdef INCLUDE_MARKET_ANALYSIS

// PVSRA V2 Module Group
#ifdef FEATURE_PVSRA_V2
	#include "03_MarketAnalysis_02_PVSRA_Basic.mqh"
	#include "03_MarketAnalysis_03_PVSRA_Enhanced.mqh"  // PHASE 4.5: RESTORED
	#include "03_MarketAnalysis_04_PVSRA_Advanced.mqh"
	#include "03_MarketAnalysis_05_PVSRA_Patterns.mqh"
	#include "03_MarketAnalysis_06_PVSRA_Manager.mqh"
#endif // FEATURE_PVSRA_V2

// SonicR MC lightweight analysis modules
// [LIGHT] exclude: #include "03_MarketAnalysis_12_AssetDNA.mqh"
// [LIGHT] exclude: #include "03_MarketAnalysis_14_WaveDetector.mqh"
#include "03_MarketAnalysis_13_SonicBasicGates.mqh"
// Dragon Band Module Group
#ifdef FEATURE_DRAGON_BAND
	#include "03_MarketAnalysis_01_DragonBand.mqh"
	#include "03_MarketAnalysis_07_DragonBand_Analyzer.mqh"
	#include "03_MarketAnalysis_01_DragonAngle_Enforcer.mqh"     // NEW: Strategy angle enforcement
#endif // FEATURE_DRAGON_BAND

// Market Maker Analysis Module Group
#ifdef FEATURE_PVSRA_V2
	// [LIGHT] exclude: #include "03_MarketAnalysis_02_MarketMaker_PhaseDetector.mqh" // NEW: MM phase detection
#endif

// Wave Pattern Module Group
#ifdef FEATURE_WAVE_PATTERN
	#include "03_MarketAnalysis_12_WavePatternAnalyzer.mqh"
#endif // FEATURE_WAVE_PATTERN

// SMC Integration Module Group - PHASE 4.5: GRADUALLY ENABLE
#ifdef FEATURE_SMC_INTEGRATION
	#include "03_MarketAnalysis_99_SMC_PublicAPI.mqh" // Facade: expose SMC API to UI, keep heavy files gated
    // Gradual enablement under feature guard to minimize compile cascades
    // Master Orchestrator disabled in lightweight build
    // #include "03_MarketAnalysis_08_MasterOrchestrator.mqh"
  #ifdef SONIC_ALLOW_HEAVY
        // Heavy SMC internals only — keep Master Orchestrator disabled unless explicitly enabled
        //#include "03_MarketAnalysis_08_MasterOrchestrator.mqh"
		//#include "03_MarketAnalysis_09_ConsolidatedAnalysis.mqh"
		//#include "03_MarketAnalysis_10_SignalProcessing.mqh"
		//#include "03_MarketAnalysis_11_PatternRecognition.mqh"
		//#include "03_MarketAnalysis_13_MarketStructure.mqh"
		//#include "03_MarketAnalysis_26_StructureManager.mqh"
		//#include "03_MarketAnalysis_15_MarketContext.mqh"
		//#include "03_MarketAnalysis_16_MarketMakerPhases.mqh"
		//#include "03_MarketAnalysis_17_MarketProfile.mqh"
		//#include "03_MarketAnalysis_18_FairValueGaps.mqh"
		//#include "03_MarketAnalysis_19_POIScoring.mqh"
		// #include "03_MarketAnalysis_20_BrokerHealth.mqh"
		//#include "03_MarketAnalysis_21_AssetDNA.mqh"
		//#include "03_MarketAnalysis_22_MarketMicrostructure.mqh"
		//#include "03_MarketAnalysis_27_RegimeDetector.mqh"
		// #include "03_MarketAnalysis_23_AdaptiveSettings.mqh"
		// #include "03_MarketAnalysis_24_NarrativeGenerator.mqh"
		#endif
#endif
#ifdef BUILD_PROFILE_ORCH
  // Early-phase: cố định dùng AssetDNA stub (21) cho cả ORCH và SMC để ổn định hiệu năng
  #include "03_MarketAnalysis_21_AssetDNA.mqh"
#endif
#ifdef BUILD_PROFILE_SMC
  // Early-phase: cố định dùng AssetDNA stub (21) cho cả ORCH và SMC để ổn định hiệu năng
  #include "03_MarketAnalysis_21_AssetDNA.mqh"
#endif

  #ifdef FEATURE_MASTER_ORCHESTRATOR
    // Explicitly include Master Orchestrator when enabled in ORCH/SMC profiles only
    // #include "03_MarketAnalysis_08_MasterOrchestrator.mqh"
  #endif
#endif
#endif

//+------------------------------------------------------------------+
//| 04_SIGNAL_GENERATION - Signal Generation Modules                |
//+------------------------------------------------------------------+
// Forward declarations for signal functions - COMMENTED OUT TO AVOID WARNINGS
// ENUM_SIGNAL_TYPE GetSignal_SonicR_Basic();
// ENUM_SIGNAL_TYPE GetSignal_SonicR_VPSRA();
// ENUM_SIGNAL_TYPE GetSignal_Scout_Internal();
// ENUM_SIGNAL_TYPE GetSignal_SonicR_VPSRA_Internal();

// #define INCLUDE_SIGNAL_GENERATION  // Defined via module control flags above (avoid redefinition)
#ifdef INCLUDE_SIGNAL_GENERATION
// #include "04_SignalGeneration_01_ConsolidatedSignals.mqh"  // already included above to expose API/impl once
#ifdef FEATURE_CONFLUENCE_ENGINE
	#include "04_SignalGeneration_02_ConfluenceEngine.mqh"
	#endif
// #include "04_SignalGeneration_11_ScenarioPerformance.mqh"   // Frozen by refactor
// #include "04_SignalGeneration_03_ScenarioManager.mqh"        // Frozen by refactor
// #include "04_SignalGeneration_04_ScenarioConfig.mqh"         // Frozen by refactor
#include "04_SignalGeneration_05_ConflictResolver.mqh"
#include "04_SignalGeneration_06_DynamicWeightAdjuster.mqh"
#ifdef FEATURE_SMC_INTEGRATION
  #include "04_SignalGeneration_08_SMC_Consolidated.mqh"
  #include "04_SignalGeneration_09_SMC_Validator.mqh"
  #include "04_SignalGeneration_10_SMC_Utils.mqh"
#endif
// #include "04_SignalGeneration_12_ScenarioProfiles.mqh"      // Frozen by refactor
#include "04_SignalGeneration_13_ScoutManager.mqh"
// #include "04_SignalGeneration_14_ConfluenceTest.mqh"   // Frozen by refactor
#endif

//+------------------------------------------------------------------+
//| 05_TRADING - Trading Modules                                     |
//+------------------------------------------------------------------+
#ifdef INCLUDE_TRADING_MODULES
#include "05_Trading_01_TradeManager.mqh"
#include "05_Trading_02_StructureBasedRisk.mqh"
#include "05_Trading_02_PositionManager.mqh"
#include "05_Trading_03_TradeGate.mqh"
// PHASE 3: Advanced Trade Management
#include "08_TradeManagement_01_AdvancedTradeManager.mqh"
#endif

//+------------------------------------------------------------------+
//| 06_RISK_MANAGEMENT - Risk Management Modules (14 modules)       |
//+------------------------------------------------------------------+
#ifdef INCLUDE_RISK_MANAGEMENT
#ifndef BUILD_PROFILE_LIGHT
#include "06_RiskManagement_01_IntelligentManager.mqh"
#include "06_RiskManagement_02_BlackSwanDetector.mqh"
#include "06_RiskManagement_03_CircuitBreaker.mqh"
#include "06_RiskManagement_04_CircuitBreaker_Enhanced.mqh"
#include "06_RiskManagement_05_CorrelationHeatMap.mqh"
#include "06_RiskManagement_07_EquityCurveConvexity.mqh"
#include "06_RiskManagement_08_AdaptiveDynamicKelly.mqh"
#include "06_RiskManagement_09_DynamicRiskReward.mqh"
#include "06_RiskManagement_10_KellyCriterion.mqh"
#include "06_RiskManagement_11_MarketCycleAnalysis.mqh"
#include "06_RiskManagement_12_RealTimeFeedback.mqh"
#include "06_RiskManagement_13_SeasonalityCalendar.mqh"
#include "06_RiskManagement_14_VaRCalculator.mqh"
#include "06_RiskManagement_16_EnhancedRiskManager.mqh"
#endif
#endif

//+------------------------------------------------------------------+
//| 07_AI_ML - AI/ML Integration Modules (4 modules)                |
//+------------------------------------------------------------------+
#ifdef INCLUDE_AI_ML_MODULES
#include "07_AI_ML_01_AdaptiveIntelligence.mqh"
#include "07_AI_ML_02_ParameterOptimization.mqh"
#include "07_AI_ML_03_NeuralNetworkConfirmation.mqh"
#include "07_AI_ML_04_MLIntegration.mqh"
#endif

//+------------------------------------------------------------------+
//| 08_PORTFOLIO - Portfolio Management Modules (1 module)          |
//+------------------------------------------------------------------+
#ifdef INCLUDE_PORTFOLIO_MODULES
#include "08_Portfolio_01_MultiAssetManager.mqh"
#endif

//+------------------------------------------------------------------+
//| 09_PERFORMANCE - Performance Optimization Modules (5 modules)   |
//+------------------------------------------------------------------+
#ifdef INCLUDE_PERFORMANCE_MODULES
#include "09_Performance_01_OptimizationEnhanced.mqh"
#include "09_Performance_02_OptimizationPhase3.mqh"
#include "09_Performance_03_SystemUnified.mqh"
#include "09_Performance_04_RealTimeMonitoring.mqh"
#include "09_Performance_05_AdvancedAnalytics.mqh"
#endif

//+------------------------------------------------------------------+
//| 10_TESTING - Testing Framework(2 modules)                      |
//+------------------------------------------------------------------+
// Testing modules disabled for production build
//#ifdef INCLUDE_TESTING_MODULES
//#include "10_Testing_01_LiveValidation.mqh" // ENABLED
//#include "10_Testing_02_WalkForward.mqh" // Walk-Forward Testing Framework
//// PHASE 4: System Integration Test
//#include "13_Testing_01_SystemIntegrationTest.mqh"
//#endif

//+------------------------------------------------------------------+
//| 11_COMPLIANCE - Compliance Modules (5 modules)                  |
//+------------------------------------------------------------------+
#ifdef INCLUDE_COMPLIANCE_MODULES
// Compliance modules removed for lightweight build
#endif

//+------------------------------------------------------------------+
//| 12_ARCHITECTURE - Architecture Modules (2 modules)              |
//+------------------------------------------------------------------+
#ifdef INCLUDE_ARCHITECTURE_MODULES
// Architecture modules disabled/removed
#endif

//+------------------------------------------------------------------+
//| 14_REPORTS - Reports Modules (1 module)                         |
//+------------------------------------------------------------------+
#ifdef INCLUDE_REPORTS_MODULES
// Reports modules removed for lightweight build
#endif

//+------------------------------------------------------------------+
//| 15_NEWS - News Modules (1 module)                               |
//+------------------------------------------------------------------+
#ifdef INCLUDE_NEWS_MODULES
// News module removed for lightweight build
#endif

//+------------------------------------------------------------------+
//| 16_UI - User Interface Modules (4 modules)                      |
//+------------------------------------------------------------------+
#ifdef INCLUDE_UI_MODULES
#include "16_UI_01_Dashboard.mqh"
#include "16_UI_02_SMC_Overlay.mqh"
#include "16_UI_03_PVSRA_Overlay.mqh"
#include "16_UI_04_Unified_Display.mqh"
#include "16_UI_05_EMA_Overlay.mqh" // ENABLED
// PHASE 4: Advanced UI Dashboard
// Dashboard legacy include omitted
#endif

//+------------------------------------------------------------------+
//| CORE STRUCTURES - BASIC DATA STRUCTURES                          |
//+------------------------------------------------------------------+

// GROUP 2 FIX: Basic structs migrated to CommonStructures.mqh
// SSignalData, SConfluenceData, SSystemState now defined in 01_Core_13_CommonStructures.mqh

//+------------------------------------------------------------------+
//| CORE ENUMS - BASIC ENUMERATIONS                                  |
//+------------------------------------------------------------------+
// Note: ENUM_TRADING_SCENARIO already defined in 01_Core_14_CoreEnums.mqh
// Removed duplicate definition to avoid compilation error 282

//+------------------------------------------------------------------+
//| CORE CONSTANTS - BASIC CONSTANTS                                 |
//+------------------------------------------------------------------+

// GROUP 3 FIX: Error constants moved to ErrorConstants.mqh to avoid duplicates
// ERR_SONIC_R_* constants now defined in 01_Core_08_ErrorConstants.mqh

// Basic Configuration Constants (non-error constants only)
#define SONIC_R_MAX_RETRIES 3
#define SONIC_R_TIMEOUT_MS 5000
#define SONIC_R_MIN_SIGNAL_STRENGTH 50.0
#define SONIC_R_MAX_SPREAD_PIPS 50.0

//+------------------------------------------------------------------+
//| CORE UTILITY FUNCTIONS                                            |
//+------------------------------------------------------------------+
namespace SonicRUtils
{
    /**
    * @brief Convert enum to string
    * @param value The enum value
    * @return String representation
    */
    #ifndef DISABLE_SCENARIO_ENUM_TO_STRING
    string EnumToString(ENUM_TRADING_SCENARIO value) {
        switch(value) {
            case SCENARIO_SONIC_R_BASIC: return "Sonic R Basic";
            case SCENARIO_SONIC_R_ENHANCED: return "Sonic R Enhanced";
            case SCENARIO_SONIC_R_ADVANCED: return "Sonic R Advanced";
            case SCENARIO_SONIC_R_EXPERT: return "Sonic R Expert";
            default: return "Unknown";
        }
    }
    #endif

    /**
    * @brief Convert enum to string
    * @param value The enum value
    * @return String representation
    */
    string EnumToString(ENUM_MARKET_REGIME value) {
        switch(value) {
            case REGIME_TRENDING: return "Trending";
            case REGIME_RANGING: return "Ranging";
            case REGIME_VOLATILE: return "Volatile";
            case REGIME_UNKNOWN: return "Unknown";
            default: return "Unknown";
        }
    }

    /**
    * @brief Safe string to double conversion
    * @param str The string to convert
    * @param defaultValue Default value if conversion fails
    * @return Double value
    */
    double SafeStringToDouble(string str, double defaultValue = 0.0) {
        double result = StringToDouble(str);
        if(result == 0.0 && str != "0" && str != "0.0") {
            return defaultValue;
        }
        return result;
    }

    /**
    * @brief Safe string to integer conversion
    * @param str The string to convert
    * @param defaultValue Default value if conversion fails
    * @return Integer value
    */
    int SafeStringToInteger(string str, int defaultValue = 0) {
        long temp = StringToInteger(str);
        int result = (int)MathMin(temp, INT_MAX);
        if(result == 0 && str != "0") {
            return defaultValue;
        }
        return result;
    }

    /**
    * @brief Format double to string with specified digits
    * @param value The double value
    * @param digits Number of digits
    * @return Formatted string
    */
    string FormatDouble(double value, int digits = 5) {
        return DoubleToString(value, digits);
    }

    /**
    * @brief Get current time as string
    * @return Current time string
    */
    string GetCurrentTimeString() {
        return TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
    }

    //+------------------------------------------------------------------+
    //| CORE VALIDATION FUNCTIONS                                         |
    //+------------------------------------------------------------------+

    /**
    * @brief Validate signal data
    * @param signal The signal data to validate
    * @return true if valid
    */
    bool ValidateSignalData(SSignalData &signal) {
        if(!signal.isValid) return false;
        if(signal.confidence < 0 || signal.confidence > 1.0) return false;
        // Note: SSignalData doesn't have confluenceScore member
        return true;
    }

    /**
    * @brief Validate confluence data
    * @param confluence The confluence data to validate
    * @return true if valid
    */
    bool ValidateConfluenceData(SConfluenceData &confluence) {
        if(!confluence.isValid) return false;
        if(confluence.overallScore < 0 || confluence.overallScore > 1.0) return false;
        // Note: SConfluenceData doesn't have confluenceFactors member
        return true;
    }

    //+------------------------------------------------------------------+
    //| CORE LOGGING FUNCTIONS                                            |
    //+------------------------------------------------------------------+

    /**
    * @brief Log info message
    * @param message The message to log
    */
    void LogInfo(string message) {
        Print("[INFO] ", GetCurrentTimeString(), " - ", message);
    }

    /**
    * @brief Log warning message
    * @param message The message to log
    */
    void LogWarning(string message) {
        Print("[WARNING] ", GetCurrentTimeString(), " - ", message);
    }

    /**
    * @brief Log error message
    * @param message The message to log
    */
    void LogError(string message) {
        Print("[ERROR] ", GetCurrentTimeString(), " - ", message);
    }

    /**
    * @brief Log debug message
    * @param message The message to log
    */
    void LogDebug(string message) {
        Print("[DEBUG] ", GetCurrentTimeString(), " - ", message);
    }
}

//+------------------------------------------------------------------+
//| CORE SYSTEM FUNCTIONS                                             |
//+------------------------------------------------------------------+

// Note: IsSystemReady is defined in Core Engine module to avoid redefinition

//+------------------------------------------------------------------+
//| END OF MASTER INCLUDES SYSTEM                                     |
//+------------------------------------------------------------------+

#endif // MASTER_INCLUDES_MQH
