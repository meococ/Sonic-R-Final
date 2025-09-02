//+------------------------------------------------------------------+
//|                    01_Core_06_SonicEnums.mqh                     |
//|                SONIC R MC - Sonic Specific Enumerations          |
//|                     �?i B�ng Architecture - Sonic Layer          |
//+------------------------------------------------------------------+
#ifndef CORE_06_SONIC_ENUMS_MQH
#define CORE_06_SONIC_ENUMS_MQH

#include "01_Core_14_CoreEnums.mqh"

//+------------------------------------------------------------------+
//| TRADING STRATEGY ENUMERATIONS                                    |
//+------------------------------------------------------------------+
enum ENUM_TRADING_STRATEGY
{
    STRATEGY_SONIC_R = 0,                 // Pure Sonic R strategy
    STRATEGY_SONIC_R_WITH_VPSRA = 1,      // Sonic R + VPSRA analysis
    STRATEGY_SCALING_WINNERS = 2,         // Scaling winning positions
    STRATEGY_SCOUT_RANGE = 3,             // Scout range trading
    STRATEGY_MULTI_ASSET = 4,             // Multi-asset adaptive
    STRATEGY_CUSTOM = 5,                  // Custom strategy
    STRATEGY_NONE = 6,                    // Debug only: no strategy forced / no selection
};

// High-level profile selector for Minimal Core UI
enum ENUM_STRATEGY_PROFILE
{
    PROFILE_AUTO = 0,           // Use existing mapping (InpTradingStrategy → scenario)
    PROFILE_BASIC = 1,          // Kịch bản 5 làm cơ bản (Multi-Asset Balanced)
    PROFILE_SONIC_BASE = 2,     // Kịch bản 1: Sonic Base
    PROFILE_SONIC_VPSRA = 3,    // Kịch bản 2: Sonic + VPSRA
    PROFILE_SCOUT = 4,          // Kịch bản 3: Scout
    PROFILE_MULTI_ASSET = 5     // Kịch bản 5: Multi-Asset Adaptive đầy đủ
};


// PROP FIRM TYPES already defined in 01_Core_14_CoreEnums.mqh as ENUM_PROP_FIRM
// Use ENUM_PROP_FIRM instead of ENUM_PROP_FIRM_TYPE to avoid duplicates

//+------------------------------------------------------------------+
//| LOG LEVEL ENUMERATIONS                                           |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVEL
{
    LOG_DEBUG = 0,                        // Debug level
    LOG_INFO = 1,                         // Information level
    LOG_WARNING = 2,                      // Warning level
    LOG_ERROR = 3,                        // Error level
    LOG_CRITICAL = 4,                     // Critical level
    LOGLEVEL_DEBUG = 0,                   // Alias for compatibility
    LOGLEVEL_INFO = 1,                    // Alias for compatibility
    LOGLEVEL_WARNING = 2,                 // Alias for compatibility
    LOGLEVEL_ERROR = 3,                   // Alias for compatibility
    LOGLEVEL_CRITICAL = 4,                // Alias for compatibility
};

//+------------------------------------------------------------------+
//| CONFLUENCE COMPONENT ENUMERATIONS                                |
//+------------------------------------------------------------------+
enum ENUM_CONFLUENCE_COMPONENT
{
    COMPONENT_DRAGON_BAND = 0,            // Dragon Band component
    COMPONENT_PVSRA_CONFLUENCE = 1,       // SYSTEMATIC FIX - Renamed to avoid conflict
    COMPONENT_WAVE_PATTERN = 2,           // Wave pattern component
    COMPONENT_MARKET_STRUCTURE = 3,       // Market structure component
    COMPONENT_VOLUME = 4,                 // Volume component
    COMPONENT_SMC = 5,                    // Smart Money Concepts
    COMPONENT_SCOUT = 6,                  // Scout component
    COMPONENT_REGIME = 7,                 // Market regime component
};

//+------------------------------------------------------------------+
//| SIGNAL STRENGTH ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_STRENGTH
{
    STRENGTH_WEAK = 0,                    // Weak signal
    STRENGTH_MODERATE = 1,                // Moderate signal
    STRENGTH_STRONG = 2,                  // Strong signal
    STRENGTH_VERY_STRONG = 3,             // Very strong signal
};

//+------------------------------------------------------------------+
//| TRADE DIRECTION ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_TRADE_DIRECTION
{
    DIRECTION_NONE = 0,                   // No direction
    DIRECTION_LONG = 1,                   // Long direction
    DIRECTION_SHORT = 2,                  // Short direction
    // SYSTEMATIC FIX - DIRECTION_BOTH moved to CoreEnums to avoid duplicate
};

//+------------------------------------------------------------------+
//| RISK MANAGEMENT ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_RISK_MODE
{
    RISK_FIXED = 0,                       // Fixed risk
    RISK_PERCENTAGE = 1,                  // Percentage risk
    RISK_ADAPTIVE = 2,                    // Adaptive risk
    RISK_VOLATILITY_BASED = 3,            // Volatility-based risk
};

//+------------------------------------------------------------------+
//| PERFORMANCE ENUMERATIONS                                         |
//+------------------------------------------------------------------+
enum ENUM_PERFORMANCE_RATING
{
    PERFORMANCE_POOR = 0,
    PERFORMANCE_BELOW_AVERAGE = 1,
    PERFORMANCE_AVERAGE = 2,
    PERFORMANCE_GOOD = 3,
    PERFORMANCE_EXCELLENT = 4
};

enum ENUM_PERFORMANCE_MODE
{
    MODE_CONSERVATIVE = 0,
    MODE_BALANCED = 1,
    MODE_AGGRESSIVE = 2,
    MODE_MAXIMUM = 3
};

//+------------------------------------------------------------------+
//| PERFORMANCE HELPER FUNCTIONS                                     |
//+------------------------------------------------------------------+
string PerformanceRatingToString(ENUM_PERFORMANCE_RATING rating)
{
    switch(rating)
    {
        case PERFORMANCE_POOR: return "POOR";
        case PERFORMANCE_BELOW_AVERAGE: return "BELOW_AVERAGE";
        case PERFORMANCE_AVERAGE: return "AVERAGE";
        case PERFORMANCE_GOOD: return "GOOD";
        case PERFORMANCE_EXCELLENT: return "EXCELLENT";
        default: return "UNKNOWN";
    }
}

string PerformanceModeToString(ENUM_PERFORMANCE_MODE mode)
{
    switch(mode)
    {
        case MODE_CONSERVATIVE: return "CONSERVATIVE";
        case MODE_BALANCED: return "BALANCED";
        case MODE_AGGRESSIVE: return "AGGRESSIVE";
        case MODE_MAXIMUM: return "MAXIMUM";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| SIGNAL TYPE HELPER FUNCTIONS                                    |
//+------------------------------------------------------------------+
string SignalTypeToString(ENUM_SIGNAL_TYPE signalType)
{
    switch(signalType)
    {
        case SIGNAL_BUY: return "BUY";
        case SIGNAL_SELL: return "SELL";
        case SIGNAL_HOLD: return "HOLD";
        case SIGNAL_CLOSE_BUY: return "CLOSE_BUY";
        case SIGNAL_CLOSE_SELL: return "CLOSE_SELL";
        case SIGNAL_NONE: return "NONE";
        default: return "UNKNOWN";
    }
}

string TradingScenarioToString(ENUM_TRADING_SCENARIO scenario)
{
    switch(scenario)
    {
        case SCENARIO_SONIC_R_BASIC: return "SONIC_R_BASIC";
        case SCENARIO_SONIC_R_ENHANCED: return "SONIC_R_ENHANCED";
        case SCENARIO_SONIC_R_ADVANCED: return "SONIC_R_ADVANCED";
        case SCENARIO_SONIC_R_EXPERT: return "SONIC_R_EXPERT";
        case SCENARIO_SONIC_R_VPSRA: return "SONIC_R_VPSRA";
        case SCENARIO_SONIC_R_SCALING: return "SONIC_R_SCALING";
        case SCENARIO_SCOUT_SMC_MULTIFRAME: return "SCOUT_SMC_MULTIFRAME";
        case SCENARIO_MULTI_ASSET_ADAPTIVE: return "MULTI_ASSET_ADAPTIVE";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| AGGRESSIVE ADDITION - MISSING ENUM HELPERS                      |
//+------------------------------------------------------------------+
string DirectionToString(ENUM_DIRECTION direction)
{
    switch(direction)
    {
        case DIRECTION_UP: return "UP";
        case DIRECTION_DOWN: return "DOWN";
        case DIRECTION_NEUTRAL: return "NEUTRAL";
        default: return "UNKNOWN";
    }
}

string HarmonicPatternToString(ENUM_HARMONIC_PATTERN pattern)
{
    switch(pattern)
    {
        case HARMONIC_GARTLEY: return "GARTLEY";
        case HARMONIC_BUTTERFLY: return "BUTTERFLY";
        case HARMONIC_BAT: return "BAT";
        case HARMONIC_CRAB: return "CRAB";
        case HARMONIC_SHARK: return "SHARK";
        case HARMONIC_CYPHER: return "CYPHER";
        case HARMONIC_AB_CD: return "AB_CD";
        case HARMONIC_THREE_DRIVES: return "THREE_DRIVES";
        case HARMONIC_NONE: return "NONE";
        default: return "UNKNOWN";
    }
}

string PatternValidationToString(ENUM_PATTERN_VALIDATION validation)
{
    switch(validation)
    {
        case PATTERN_VALID: return "VALID";
        case PATTERN_INVALID: return "INVALID";
        case PATTERN_PENDING: return "PENDING";
        case PATTERN_EXPIRED: return "EXPIRED";
        default: return "UNKNOWN";
    }
}

#endif // CORE_06_SONIC_ENUMS_MQH
