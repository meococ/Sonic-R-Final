//+------------------------------------------------------------------+
//|                    01_Core_07_CoreEnums.mqh                      |
//|                SONIC R MC - Core Enumerations                    |
//|                     �?i B�ng Architecture - Foundation Layer     |
//+------------------------------------------------------------------+
#ifndef CORE_07_CORE_ENUMS_MQH
#define CORE_07_CORE_ENUMS_MQH

//+------------------------------------------------------------------+
//| TRADING SCENARIO ENUMERATIONS                                    |
//+------------------------------------------------------------------+
enum ENUM_TRADING_SCENARIO
{
    SCENARIO_SONIC_R_BASIC = 0,           // Sonic R Basic
    SCENARIO_SONIC_R_ENHANCED = 1,        // Sonic R Enhanced
    SCENARIO_SONIC_R_ADVANCED = 2,        // Sonic R Advanced
    SCENARIO_SONIC_R_EXPERT = 3,          // Sonic R Expert
    SCENARIO_SONIC_R_VPSRA = 4,           // Sonic R + VPSRA
    SCENARIO_SONIC_R_SCALING = 5,         // Sonic R + VPSRA + Scaling
    SCENARIO_SCOUT_SMC_MULTIFRAME = 6,    // Scout + SMC + Multiframe
    SCENARIO_MULTI_ASSET_ADAPTIVE = 7,    // Multi Asset Adaptive
    SCENARIO_BASIC = 0,                   // Alias for SONIC_R_BASIC
    SCENARIO_WITH_VPSRA = 4,              // Alias for SONIC_R_VPSRA
    SCENARIO_SONIC_R_PVSRA_ENHANCED = 4,  // Alias for SONIC_R_VPSRA
    SCENARIO_SCALING_WINNERS = 5,         // Alias for SONIC_R_SCALING
    SCENARIO_SCOUT_RANGE_SMC = 6,         // Alias for SCOUT_SMC_MULTIFRAME
    
    // Additional scenarios found in modules
    SCENARIO_SCOUT_SMC_STRICT = 8,        // Scout SMC Strict mode
};

//+------------------------------------------------------------------+
//| MINIMAL PVSRA PATTERN ENUM (used when analysis disabled)         |
//+------------------------------------------------------------------+
#ifdef HAVE_MINIMAL_PVSRA_ENUM
#ifndef CORE_PVSRA_PATTERN_ENUM
#define CORE_PVSRA_PATTERN_ENUM
enum ENUM_PVSRA_PATTERN
{
    PVSRA_NONE = 0,
    PVSRA_SPRING = 1,
    PVSRA_UPTHRUST = 2,
    PVSRA_SELLING_CLIMAX = 3,
    PVSRA_AUTOMATIC_RALLY = 4,
    PVSRA_SIGN_OF_STRENGTH = 5,
    PVSRA_PATTERN_UNKNOWN = 999
};
#endif
#endif

//+------------------------------------------------------------------+
//| SIGNAL TYPE ENUMERATIONS                                         |
//+------------------------------------------------------------------+
#ifndef ENUM_SIGNAL_TYPE_DEFINED
#define ENUM_SIGNAL_TYPE_DEFINED
enum ENUM_SIGNAL_TYPE
{
    SIGNAL_NONE = 0,                      // No signal
    SIGNAL_BUY = 1,                       // Buy signal
    SIGNAL_SELL = -1,                     // Sell signal (consistent with other files)
    SIGNAL_BUY_STRONG = 3,                // Strong buy signal
    SIGNAL_SELL_STRONG = 4,               // Strong sell signal
    SIGNAL_WAIT = 5,                      // Wait signal
    SIGNAL_EXIT = 6,                      // Exit signal
    SIGNAL_HOLD = 7,                      // Hold signal
    SIGNAL_CLOSE_BUY = 8,                 // Close buy signal
    SIGNAL_CLOSE_SELL = 9,                // Close sell signal
    SIGNAL_UNKNOWN = 10,                  // Unknown signal
};
#endif

//+------------------------------------------------------------------+
//| TRADING SESSION ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_TRADING_SESSION
{
    SESSION_ASIAN = 0,                    // Asian session
    SESSION_LONDON = 1,                   // London session
    SESSION_NEW_YORK = 2,                 // New York session
    // Aliases used in modules
    SESSION_NY = SESSION_NEW_YORK,        // Alias: NY
    SESSION_LDN = SESSION_LONDON,         // Alias: London short
    SESSION_TOKYO = SESSION_ASIAN,        // Alias: Tokyo = Asian session
    SESSION_OVERLAP_LONDON_NY = 3,        // London-NY overlap
    SESSION_UNKNOWN = 4,                  // Unknown session
};

//+------------------------------------------------------------------+
//| CONFLICT RESOLUTION ENUMERATIONS                                 |
//+------------------------------------------------------------------+
enum ENUM_CONFLICT_TYPE
{
    CONFLICT_NONE = 0,                    // No conflict
    CONFLICT_DIRECTIONAL = 1,             // Directional conflict
    CONFLICT_STRENGTH = 2,                // Strength conflict
    CONFLICT_TIMING = 3,                  // Timing conflict
    CONFLICT_UNKNOWN = 4,                 // Unknown conflict
};

enum ENUM_RESOLUTION_STRATEGY
{
    RESOLUTION_NONE = 0,                  // No resolution
    RESOLUTION_ABSTAIN = 1,               // Abstain from trading
    RESOLUTION_WEIGHT_BASED = 2,          // Weight-based resolution
    RESOLUTION_COMPONENT_RELIABILITY = 3, // Component reliability
    RESOLUTION_MARKET_CONTEXT = 4,        // Market context based
    RESOLUTION_TIMEFRAME_PRIORITY = 5,    // Timeframe priority
    RESOLUTION_HISTORICAL_PERFORMANCE = 6, // Historical performance
};

//+------------------------------------------------------------------+
//| WEIGHT STRATEGY ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_WEIGHT_STRATEGY
{
    WEIGHT_EQUAL = 0,                     // Equal weights
    WEIGHT_PERFORMANCE_BASED = 1,         // Performance-based weights
    WEIGHT_MARKET_ADAPTIVE = 2,           // Market-adaptive weights
    WEIGHT_HYBRID = 3,                    // Hybrid strategy
    WEIGHT_CONSERVATIVE = 4,              // Conservative weights
    WEIGHT_AGGRESSIVE = 5,                // Aggressive weights
};

//+------------------------------------------------------------------+
//| LIQUIDITY LEVEL ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_LIQUIDITY_LEVEL
{
    LIQUIDITY_NONE = 0,                   // No liquidity
    LIQUIDITY_DAILY_HIGH = 1,             // Daily high liquidity
    LIQUIDITY_DAILY_LOW = 2,              // Daily low liquidity
    LIQUIDITY_WEEKLY_HIGH = 3,            // Weekly high liquidity
    LIQUIDITY_WEEKLY_LOW = 4,             // Weekly low liquidity
    LIQUIDITY_INSTITUTIONAL = 5,          // Institutional liquidity
};

//+------------------------------------------------------------------+
//| MARKET REGIME ENUMERATIONS                                       |
//+------------------------------------------------------------------+
enum ENUM_MARKET_REGIME
{
    REGIME_TRENDING = 0,                  // Trending market
    REGIME_RANGING = 1,                   // Ranging market
    REGIME_VOLATILE = 2,                  // Volatile market
    REGIME_UNKNOWN = 3,                   // Unknown regime
    
    // Extended regime types for risk management
    REGIME_TRENDING_BULLISH = 4,          // Bullish trending market
    REGIME_TRENDING_BEARISH = 5,          // Bearish trending market
    REGIME_RANGING_TIGHT = 6,             // Tight ranging market
    REGIME_BREAKOUT = 7,                  // Breakout market
    REGIME_VOLATILE_TRENDING = 8,         // Volatile trending market
    REGIME_VOLATILE_RANGING = 9,          // Volatile ranging market
    REGIME_STABLE_TRENDING = 10,          // Stable trending market
    
    // Additional regime types found in modules
    REGIME_QUIET = 11,                    // Quiet market regime
    REGIME_STABLE_RANGING = 12,           // Stable ranging market
    REGIME_CONSOLIDATION = 13,            // Consolidation regime
    REGIME_TRENDING_BULLISH_VOLATILE = 14, // Volatile bullish trending
    REGIME_TRENDING_BEARISH_VOLATILE = 15, // Volatile bearish trending
    REGIME_TRENDING_LOW_VOL = 16,         // Low volatility trending
    REGIME_TRENDING_HIGH_VOL = 17,        // High volatility trending
    REGIME_RANGING_LOW_VOL = 18,          // Low volatility ranging
    REGIME_RANGING_HIGH_VOL = 19,         // High volatility ranging

    // FINAL SPRINT - Additional regime types
    REGIME_TRENDING_WEAK = 20,            // Weak trending market
};

//+------------------------------------------------------------------+
//| TIMEFRAME ENUMERATIONS (Extended)                                |
//+------------------------------------------------------------------+
enum ENUM_TIMEFRAMES_EXTENDED
{
    TIMEFRAME_M1_EXT = PERIOD_M1,         // 1 minute
    TIMEFRAME_M5_EXT = PERIOD_M5,         // 5 minutes
    TIMEFRAME_M15_EXT = PERIOD_M15,       // 15 minutes
    TIMEFRAME_M30_EXT = PERIOD_M30,       // 30 minutes
    TIMEFRAME_H1_EXT = PERIOD_H1,         // 1 hour
    TIMEFRAME_H4_EXT = PERIOD_H4,         // 4 hours
    TIMEFRAME_D1_EXT = PERIOD_D1,         // 1 day
    TIMEFRAME_W1_EXT = PERIOD_W1,         // 1 week
    TIMEFRAME_MN1_EXT = PERIOD_MN1,       // 1 month
};

//+------------------------------------------------------------------+
//| WYCKOFF PHASE ENUMERATIONS                                       |
//+------------------------------------------------------------------+
enum ENUM_WYCKOFF_PHASE
{
    WYCKOFF_ACCUMULATION = 0,             // Accumulation phase
    WYCKOFF_MARKUP = 1,                   // Markup phase
    WYCKOFF_DISTRIBUTION = 2,             // Distribution phase
    WYCKOFF_MARKDOWN = 3,                 // Markdown phase
    WYCKOFF_UNKNOWN = 4,                  // Unknown phase
    
    // Additional phase constants used by PVSRA modules
    PHASE_ACCUMULATION = WYCKOFF_ACCUMULATION,    // Alias
    PHASE_MARKUP = WYCKOFF_MARKUP,                // Alias
    PHASE_DISTRIBUTION = WYCKOFF_DISTRIBUTION,    // Alias
    PHASE_MARKDOWN = WYCKOFF_MARKDOWN,            // Alias
    PHASE_UNKNOWN = WYCKOFF_UNKNOWN,              // Alias
    PHASE_REACCUMULATION = 5,             // Reaccumulation phase
    PHASE_REDISTRIBUTION = 6,             // Redistribution phase
};

//+------------------------------------------------------------------+
//| SESSION TYPE ENUMERATIONS                                        |
//+------------------------------------------------------------------+
enum ENUM_SESSION_TYPE
{
    SESSION_QUIET = 0,                    // Quiet session
    SESSION_ACTIVE = 1,                   // Active session
    SESSION_VOLATILE = 2,                 // Volatile session
    SESSION_OVERLAP = 3,                  // Overlap session
};

//+------------------------------------------------------------------+
//| MARKET CYCLE ENUMERATIONS                                        |
//+------------------------------------------------------------------+
enum ENUM_MARKET_CYCLE
{
    CYCLE_ACCUMULATION = 0,               // Accumulation cycle
    CYCLE_MARKUP = 1,                     // Markup cycle
    CYCLE_DISTRIBUTION = 2,               // Distribution cycle
    CYCLE_MARKDOWN = 3,                   // Markdown cycle
    CYCLE_UNKNOWN = 4,                    // Unknown cycle
};

//+------------------------------------------------------------------+
//| ASSET TYPE ENUMERATIONS                                          |
//+------------------------------------------------------------------+
enum ENUM_ASSET_TYPE
{
    ASSET_FOREX = 0,                      // Forex pairs
    ASSET_METALS = 1,                     // Precious metals
    ASSET_COMMODITIES = 2,                // Commodities
    ASSET_INDICES = 3,                    // Stock indices
    ASSET_CRYPTO = 4,                     // Cryptocurrencies
    ASSET_UNKNOWN = 5,                    // Unknown asset type
    ASSET_COMMODITY = 2,                  // Alias for COMMODITIES
    ASSET_INDEX = 3,                      // Alias for INDICES
    ASSET_BOND = 6,                       // Bonds
};

//+------------------------------------------------------------------+
//| DRAGON STATE ENUMERATIONS                                        |
//+------------------------------------------------------------------+
enum ENUM_DRAGON_STATE
{
    DRAGON_SLEEPING = 0,                  // Dragon sleeping
    DRAGON_AWAKENING = 1,                 // Dragon awakening
    DRAGON_ACTIVE = 2,                    // Dragon active
    DRAGON_HUNTING = 3,                   // Dragon hunting
    DRAGON_RESTING = 4,                   // Dragon resting
    DRAGON_STABLE = 5,                    // Dragon stable
    DRAGON_SQUEEZE = 6,                   // Dragon squeeze
    DRAGON_EXPANSION = 7,                 // Dragon expansion
    DRAGON_UNKNOWN = 8,                   // Unknown state
};

//+------------------------------------------------------------------+
//| TREND DIRECTION ENUMERATIONS                                     |
//+------------------------------------------------------------------+
enum ENUM_TREND_DIRECTION
{
    TREND_UP = 0,                         // Upward trend
    TREND_DOWN = 1,                       // Downward trend
    TREND_SIDEWAYS = 2,                   // Sideways trend
    TREND_BULLISH = 3,                    // Bullish trend
    TREND_BEARISH = 4,                    // Bearish trend
    TREND_UNKNOWN = 5                     // Unknown trend
};

//+------------------------------------------------------------------+
//| WAVE TYPE ENUMERATIONS                                           |
//+------------------------------------------------------------------+
enum ENUM_WAVE_TYPE
{
    WAVE_IMPULSE = 0,                     // Impulse wave
    WAVE_CORRECTIVE = 1,                  // Corrective wave
    WAVE_EXTENSION = 2,                   // Extension wave
    WAVE_UNKNOWN = 3,                     // Unknown wave
    WAVE_NONE = 4,                        // No wave
};

// NOTE: CONFLICT, RESOLUTION, and WEIGHT enums are defined above to avoid duplicates

//+------------------------------------------------------------------+
//| ORDER BLOCK TYPE ENUMERATIONS                                    |
//+------------------------------------------------------------------+
enum ENUM_ORDER_BLOCK_TYPE
{
    ORDER_BLOCK_BULLISH = 0,              // Bullish order block
    ORDER_BLOCK_BEARISH = 1,              // Bearish order block
    ORDER_BLOCK_NEUTRAL = 2,              // Neutral order block
    ORDER_BLOCK_UNKNOWN = 3,              // Unknown order block
};

//+------------------------------------------------------------------+
//| LIQUIDITY TYPE ENUMERATIONS                                      |
//+------------------------------------------------------------------+
enum ENUM_LIQUIDITY_TYPE
{
    LIQUIDITY_BUY = 0,                    // Buy-side liquidity
    LIQUIDITY_SELL = 1,                   // Sell-side liquidity
    LIQUIDITY_EQUAL = 2,                  // Equal liquidity
    LIQUIDITY_UNKNOWN = 3,                // Unknown liquidity
};

//+------------------------------------------------------------------+
//| FAIR VALUE GAP TYPE ENUMERATIONS                                 |
//+------------------------------------------------------------------+
enum ENUM_FVG_TYPE
{
    FVG_BULLISH = 0,                      // Bullish fair value gap
    FVG_BEARISH = 1,                      // Bearish fair value gap
    FVG_NEUTRAL = 2,                      // Neutral fair value gap
    FVG_UNKNOWN = 3,                      // Unknown fair value gap
};

//+------------------------------------------------------------------+
//| PHASE 0 FIX: MISSING MARKET PHASE ENUM                          |
//+------------------------------------------------------------------+
enum ENUM_MARKET_PHASE
{
    MARKET_PHASE_A = 0,                   // Accumulation phase
    MARKET_PHASE_B = 1,                   // Breakout phase  
    MARKET_PHASE_C = 2,                   // Continuation phase
    MARKET_PHASE_D = 3,                   // Distribution phase
    MARKET_PHASE_E = 4,                   // Exhaustion phase
    MARKET_PHASE_UNKNOWN = 5              // Unknown phase
};

//+------------------------------------------------------------------+
//| PHASE 0 FIX: VOLATILITY REGIME STRUCT - REMOVED DUPLICATE      |
//| (VolatilityRegimeData is defined in 01_Core_07_CommonStructures.mqh) |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - Removed duplicate VolatilityRegimeData struct

//+------------------------------------------------------------------+
//| PHASE 0 FIX: COMPONENT TYPE ENUMS                               |
//+------------------------------------------------------------------+
enum ENUM_COMPONENT_TYPE
{
    COMPONENT_DRAGON = 0,                 // Dragon Band component
    COMPONENT_WAVE = 1,                   // Wave Pattern component
    COMPONENT_STRUCTURE = 2,              // SMC Structure component
    COMPONENT_PVSRA = 3,                  // PVSRA component
    COMPONENT_CONFLUENCE = 4,             // Confluence component
    COMPONENT_UNKNOWN = 5                 // Unknown component
};

//+------------------------------------------------------------------+
//| PHASE 0 FIX: STRUCTURE TYPE ENUM FOR SMC                        |
//+------------------------------------------------------------------+
enum ENUM_STRUCTURE_TYPE  
{
    STRUCTURE_ORDER_BLOCK = 0,            // Order block structure
    STRUCTURE_FVG = 1,                    // Fair value gap structure
    STRUCTURE_BOS = 2,                    // Break of structure
    STRUCTURE_CHOCH = 3,                  // Change of character
    STRUCTURE_LIQUIDITY = 4,              // Liquidity zone
    STRUCTURE_SWEEP = 5,                  // Liquidity sweep
    STRUCTURE_UNKNOWN = 6                 // Unknown structure
};

//+------------------------------------------------------------------+
//| SWING POINT TYPE ENUMERATIONS                                    |
//+------------------------------------------------------------------+
enum ENUM_SWING_TYPE
{
    SWING_HIGH = 0,                       // Swing high point
    SWING_LOW = 1,                        // Swing low point
    SWING_UNKNOWN = 2,                    // Unknown swing point
};

//+------------------------------------------------------------------+
//| VOLUME TYPE ENUMERATIONS                                         |
//+------------------------------------------------------------------+
enum ENUM_VOLUME_TYPE
{
    VOLUME_LOW = 0,                       // Low volume
    VOLUME_NORMAL = 1,                    // Normal volume
    VOLUME_HIGH = 2,                      // High volume
    VOLUME_CLIMAX = 3,                    // Climax volume
    VOLUME_UNKNOWN = 4,                   // Unknown volume
};

//+------------------------------------------------------------------+
//| MARKET STRUCTURE ENUMERATIONS                                    |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STRUCTURE
{
    STRUCTURE_BULLISH = 0,                // Bullish market structure
    STRUCTURE_BEARISH = 1,                // Bearish market structure
    STRUCTURE_RANGING = 2,                // Ranging market structure
    STRUCTURE_TRANSITIONAL = 3,           // Transitional structure
    STRUCTURE_MARKET_UNKNOWN = 4,         // SYSTEMATIC FIX - Renamed to avoid conflict
    STRUCTURE_UPTREND = 5,                // Uptrend structure
    STRUCTURE_DOWNTREND = 6,              // Downtrend structure
};

//+------------------------------------------------------------------+
//| ENUM TO STRING UTILITY FUNCTIONS                                 |
//+------------------------------------------------------------------+

/**
 * @brief Convert market regime enum to string
 * @param regime The market regime enum value
 * @return String representation of the regime
 */
string MarketRegimeToString(ENUM_MARKET_REGIME regime) {
    switch(regime) {
        case REGIME_TRENDING: return "Trending";
        case REGIME_RANGING: return "Ranging";
        case REGIME_VOLATILE: return "Volatile";
        case REGIME_TRENDING_BULLISH: return "Trending Bullish";
        case REGIME_TRENDING_BEARISH: return "Trending Bearish";
        case REGIME_RANGING_TIGHT: return "Ranging Tight";
        case REGIME_BREAKOUT: return "Breakout";
        case REGIME_VOLATILE_TRENDING: return "Volatile Trending";
        case REGIME_VOLATILE_RANGING: return "Volatile Ranging";
        case REGIME_STABLE_TRENDING: return "Stable Trending";
        case REGIME_QUIET: return "Quiet";
        case REGIME_STABLE_RANGING: return "Stable Ranging";
        case REGIME_CONSOLIDATION: return "Consolidation";
        case REGIME_TRENDING_BULLISH_VOLATILE: return "Trending Bullish Volatile";
        case REGIME_TRENDING_BEARISH_VOLATILE: return "Trending Bearish Volatile";
        case REGIME_TRENDING_LOW_VOL: return "Trending Low Vol";
        case REGIME_TRENDING_HIGH_VOL: return "Trending High Vol";
        case REGIME_RANGING_LOW_VOL: return "Ranging Low Vol";
        case REGIME_RANGING_HIGH_VOL: return "Ranging High Vol";
        case REGIME_UNKNOWN:
        default: return "Unknown";
    }
}

/**
 * @brief Convert market cycle enum to string
 * @param cycle The market cycle enum value
 * @return String representation of the cycle
 */
string MarketCycleToString(ENUM_MARKET_CYCLE cycle) {
    switch(cycle) {
        case CYCLE_ACCUMULATION: return "Accumulation";
        case CYCLE_MARKUP: return "Markup";
        case CYCLE_DISTRIBUTION: return "Distribution";
        case CYCLE_MARKDOWN: return "Markdown";
        case CYCLE_UNKNOWN:
        default: return "Unknown";
    }
}

/**
 * @brief Convert trading signal enum to string
 * @param signal The trading signal enum value
 * @return String representation of the signal
 */
string TradingSignalToString(ENUM_SIGNAL_TYPE signal) {
    switch(signal) {
        case SIGNAL_NONE: return "None";
        case SIGNAL_BUY: return "Buy";
        case SIGNAL_SELL: return "Sell";
        case SIGNAL_BUY_STRONG: return "Strong Buy";
        case SIGNAL_SELL_STRONG: return "Strong Sell";
        case SIGNAL_WAIT: return "Wait";
        case SIGNAL_EXIT: return "Exit";
        case SIGNAL_HOLD: return "Hold";
        case SIGNAL_CLOSE_BUY: return "Close Buy";
        case SIGNAL_CLOSE_SELL: return "Close Sell";
        case SIGNAL_UNKNOWN:
        default: return "Unknown";
    }
}

/**
 * @brief Convert timeframe enum to compact string (e.g., M1, H4)
 */
string TimeframeToString(ENUM_TIMEFRAMES tf)
{
    switch(tf)
    {
        case PERIOD_M1: return "M1";
        case PERIOD_M2: return "M2";
        case PERIOD_M3: return "M3";
        case PERIOD_M4: return "M4";
        case PERIOD_M5: return "M5";
        case PERIOD_M6: return "M6";
        case PERIOD_M10: return "M10";
        case PERIOD_M12: return "M12";
        case PERIOD_M15: return "M15";
        case PERIOD_M20: return "M20";
        case PERIOD_M30: return "M30";
        case PERIOD_H1: return "H1";
        case PERIOD_H2: return "H2";
        case PERIOD_H3: return "H3";
        case PERIOD_H4: return "H4";
        case PERIOD_H6: return "H6";
        case PERIOD_H8: return "H8";
        case PERIOD_H12: return "H12";
        case PERIOD_D1: return "D1";
        case PERIOD_W1: return "W1";
        case PERIOD_MN1: return "MN1";
        case PERIOD_CURRENT: return "CUR";
        default: return EnumToString(tf);
    }
}

/**
 * @brief Convert Wyckoff phase enum to string
 */
string WyckoffPhaseToString(ENUM_WYCKOFF_PHASE phase)
{
    switch(phase)
    {
        case WYCKOFF_ACCUMULATION: return "Accumulation";
        case WYCKOFF_MARKUP: return "Markup";
        case WYCKOFF_DISTRIBUTION: return "Distribution";
        case WYCKOFF_MARKDOWN: return "Markdown";
        case PHASE_REACCUMULATION: return "Reaccumulation";
        case PHASE_REDISTRIBUTION: return "Redistribution";
        case WYCKOFF_UNKNOWN:
        default: return "Unknown";
    }
}

//+------------------------------------------------------------------+
//| SONIC R SESSION STRUCTURE                                        |
//+------------------------------------------------------------------+
struct SonicRSession
{
    ENUM_TRADING_SESSION session;        // Session type
    datetime startTime;                   // Session start time
    datetime endTime;                     // Session end time
    bool isActive;                        // Session active flag
    double volatility;                    // Session volatility
    string name;                          // Session name
    bool isHighImpact;                    // High impact session flag
};

//+------------------------------------------------------------------+
//| CONFLICT TYPE TO STRING CONVERTER                                |
//+------------------------------------------------------------------+
string ConflictTypeToString(ENUM_CONFLICT_TYPE conflictType)
{
    switch(conflictType)
    {
        case CONFLICT_NONE: return "None";
        case CONFLICT_DIRECTIONAL: return "Directional";
        case CONFLICT_STRENGTH: return "Strength";
        case CONFLICT_TIMING: return "Timing";
        case CONFLICT_UNKNOWN: return "Unknown";
        default: return "Undefined";
    }
}

//+------------------------------------------------------------------+
//| RESOLUTION STRATEGY TO STRING CONVERTER                          |
//+------------------------------------------------------------------+
string ResolutionStrategyToString(ENUM_RESOLUTION_STRATEGY strategy)
{
    switch(strategy)
    {
        case RESOLUTION_NONE: return "None";
        case RESOLUTION_ABSTAIN: return "Abstain";
        case RESOLUTION_WEIGHT_BASED: return "Weight Based";
        case RESOLUTION_COMPONENT_RELIABILITY: return "Component Reliability";
        case RESOLUTION_MARKET_CONTEXT: return "Market Context";
        case RESOLUTION_TIMEFRAME_PRIORITY: return "Timeframe Priority";
        case RESOLUTION_HISTORICAL_PERFORMANCE: return "Historical Performance";
        default: return "Undefined";
    }
}

//+------------------------------------------------------------------+
//| WEIGHT STRATEGY TO STRING CONVERTER                              |
//+------------------------------------------------------------------+
string WeightStrategyToString(ENUM_WEIGHT_STRATEGY strategy)
{
    switch(strategy)
    {
        case WEIGHT_EQUAL: return "Equal";
        case WEIGHT_PERFORMANCE_BASED: return "Performance Based";
        case WEIGHT_MARKET_ADAPTIVE: return "Market Adaptive";
        case WEIGHT_HYBRID: return "Hybrid";
        case WEIGHT_CONSERVATIVE: return "Conservative";
        case WEIGHT_AGGRESSIVE: return "Aggressive";
        default: return "Undefined";
    }
}

//+------------------------------------------------------------------+
//| AGGRESSIVE ADDITION - MISSING CORE ENUMS                        |
//+------------------------------------------------------------------+
enum ENUM_DIRECTION
{
    DIRECTION_UP = 1,
    DIRECTION_DOWN = -1,
    DIRECTION_NEUTRAL = 0,
    DIRECTION_BUY = 1,
    DIRECTION_SELL = -1,
    DIRECTION_BOTH = 2                    // SYSTEMATIC FIX - Added to resolve enum conversion
};

enum ENUM_HARMONIC_PATTERN
{
    HARMONIC_GARTLEY = 0,
    HARMONIC_BUTTERFLY = 1,
    HARMONIC_BAT = 2,
    HARMONIC_CRAB = 3,
    HARMONIC_SHARK = 4,
    HARMONIC_CYPHER = 5,
    HARMONIC_AB_CD = 6,
    HARMONIC_THREE_DRIVES = 7,
    HARMONIC_NONE = 8
};

enum ENUM_PATTERN_VALIDATION
{
    PATTERN_VALID = 0,
    PATTERN_INVALID = 1,
    PATTERN_PENDING = 2,
    PATTERN_EXPIRED = 3
};

enum ENUM_WAVE_PATTERN
{
    WAVE_PATTERN_IMPULSE = 0,
    WAVE_PATTERN_CORRECTIVE = 1,
    WAVE_PATTERN_TRIANGLE = 2,
    WAVE_PATTERN_FLAT = 3,
    WAVE_PATTERN_ZIGZAG = 4,
    WAVE_PATTERN_NONE = 5,

    // SYSTEMATIC FIX - Add missing wave pattern enums used in WavePatternAnalyzer
    WAVE_HH_HL_BULLISH = 6,        // Higher High, Higher Low - Bullish
    WAVE_HL_BULLISH = 7,           // Higher Low - Bullish
    WAVE_LH_LL_BEARISH = 8,        // Lower High, Lower Low - Bearish
    WAVE_LH_BEARISH = 9,           // Lower High - Bearish
    WAVE_CONSOLIDATION = 10        // SYSTEMATIC FIX - Removed duplicate WAVE_PATTERN_NONE
};

enum ENUM_MARKET_STATE
{
    MARKET_STATE_TRENDING = 0,
    MARKET_STATE_RANGING = 1,
    MARKET_STATE_BREAKOUT = 2,
    MARKET_STATE_REVERSAL = 3,
    MARKET_STATE_CONSOLIDATION = 4
};

enum ENUM_MODE
{
    MODE_TREND = 0,
    MODE_RANGE = 1,
    MODE_BREAKOUT = 2,
    MODE_REVERSAL = 3,
    MODE_VOLATILE = 4
};

//+------------------------------------------------------------------+
//| ADDITIONAL MISSING ENUMS - AGGRESSIVE ROUND 2                   |
//+------------------------------------------------------------------+
enum ENUM_VAR_METHOD
{
    VAR_HISTORICAL = 0,
    VAR_PARAMETRIC = 1,
    VAR_MONTE_CARLO = 2
};

enum ENUM_PROP_FIRM
{
    PROP_FIRM_FTMO = 0,
    PROP_FIRM_MYFOREXFUNDS = 1,
    PROP_FIRM_FUNDEDNEXT = 2,
    PROP_FIRM_TOPSTEP = 3,
    PROP_FIRM_GENERIC = 4,

    // SYSTEMATIC FIX - Add missing PropFirm enum values
    PROP_FIRM_MYFXFUNDS = 1,              // Alias for MYFOREXFUNDS
    PROP_FIRM_TOPTRADER = 5,              // TopTrader prop firm
    PROP_FIRM_TRUEFOREXFUNDS = 6,         // TrueForexFunds prop firm
    PROP_FIRM_NOVA = 7,                   // Nova prop firm
    PROP_FIRM_CUSTOM = 8                  // Custom prop firm
};

enum ENUM_CERTIFICATION_LEVEL
{
    CERT_BASIC = 0,
    CERT_INTERMEDIATE = 1,
    CERT_ADVANCED = 2,
    CERT_EXPERT = 3,

    // SYSTEMATIC FIX - Add missing certification level aliases
    CERT_LEVEL_NONE = 0,                 // Alias for CERT_BASIC
    CERT_LEVEL_BASIC = 0,                // Alias for CERT_BASIC
    CERT_LEVEL_STANDARD = 1,             // Alias for CERT_INTERMEDIATE
    CERT_LEVEL_ADVANCED = 2,             // Alias for CERT_ADVANCED
    CERT_LEVEL_ENTERPRISE = 3            // Alias for CERT_EXPERT
};

enum ENUM_CALCULATION_PRECISION
{
    PRECISION_LOW = 0,
    PRECISION_MEDIUM = 1,
    PRECISION_HIGH = 2,
    PRECISION_ULTRA = 3,

    // SYSTEMATIC FIX - Add missing precision values
    PRECISION_FAST = 0,                  // Alias for PRECISION_LOW
    PRECISION_NORMAL = 1                 // Alias for PRECISION_MEDIUM
};

//+------------------------------------------------------------------+
//| AGGRESSIVE ROUND 3 - ADDITIONAL MISSING ENUMS                   |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - ENUM_MARKET_PHASE already defined above, removed duplicate

// SYSTEMATIC FIX - ENUM_COMPONENT_TYPE already defined above, removed duplicate

//+------------------------------------------------------------------+
//| MISSING ENUMS - FINAL COMPLETION                                 |
//+------------------------------------------------------------------+
enum ENUM_HARMONIC_ABCD
{
    HARMONIC_ABCD = 0
};

enum ENUM_VALIDATION_STRENGTH
{
    VALIDATION_WEAK = 0,
    VALIDATION_MODERATE = 1,
    VALIDATION_STRONG = 2,
    VALIDATION_VERY_STRONG = 3
};

enum ENUM_MARKET_STATE_EXTENDED
{
    MARKET_STATE_INACTIVE = 0,
    MARKET_STATE_ACTIVE = 1
};

enum ENUM_VOLATILITY_REGIME
{
    VOLATILITY_REGIME_LOW = 0,
    VOLATILITY_REGIME_NORMAL = 1,
    VOLATILITY_REGIME_HIGH = 2,
    VOLATILITY_REGIME_EXTREME = 3,
    VOLATILITY_REGIME_TRANSITIONAL = 4
};

enum ENUM_REGIME_EXTENDED
{
    REGIME_UNDEFINED = 0,
    REGIME_TRENDING_UP = 1,
    REGIME_TRENDING_DOWN = 2
};

//+------------------------------------------------------------------+
//| FINAL PUSH - CRITICAL MISSING ENUMS                             |
//+------------------------------------------------------------------+
// REMOVED DUPLICATE ENUM - REGIME_SQUEEZE is now part of ENUM_MARKET_REGIME as REGIME_CONSOLIDATION

// REMOVED DUPLICATE ENUM - Already defined in ENUM_ASSET_TYPE above

//+------------------------------------------------------------------+
//| ERROR CONSTANTS - FINAL PUSH                                    |
//+------------------------------------------------------------------+
#define ERR_TRADE_TIMEOUT      4000
#define ERR_REQUOTE            4001
#define ERR_BROKER_BUSY        4002
#define ERR_ACCOUNT_DISABLED   4003
#define ERR_NO_CONNECTION      4004
#define ERR_INVALID_STOPS      4005

// FINAL SPRINT - Standard MQL5 error constants
// NOTE: Use built-in MQL5 error constants to avoid redefinition warnings
// ERR_NOT_ENOUGH_MONEY, ERR_TRADE_DISABLED, ERR_MARKET_CLOSED, ERR_INVALID_PRICE, ERR_INVALID_VOLUME

//+------------------------------------------------------------------+
//| SYSTEMATIC FIX - Missing Error Severity Enums                   |
//+------------------------------------------------------------------+
enum ENUM_ERROR_SEVERITY
{
    ERROR_SEVERITY_LOW = 0,
    ERROR_SEVERITY_MEDIUM = 1,
    ERROR_SEVERITY_HIGH = 2,
    ERROR_SEVERITY_CRITICAL = 3,

    // SYSTEMATIC FIX - Add missing CircuitBreaker severity levels
    ERROR_SEVERITY_MINOR = 0,                // Alias for LOW
    ERROR_SEVERITY_MODERATE = 1,             // Alias for MEDIUM
    ERROR_SEVERITY_FATAL = 3                 // Alias for CRITICAL
};

enum ENUM_ERROR_CONTEXT
{
    ERROR_CTX_GENERAL = 0,
    ERROR_CTX_TRADING = 1,
    ERROR_CTX_ANALYSIS = 2,
    ERROR_CTX_UI = 3,
    ERROR_CTX_SYSTEM = 4
};

// Error severity aliases
#define ERROR_SEV_LOW       ERROR_SEVERITY_LOW
#define ERROR_SEV_MEDIUM    ERROR_SEVERITY_MEDIUM
#define ERROR_SEV_HIGH      ERROR_SEVERITY_HIGH
#define ERROR_SEV_ERROR     ERROR_SEVERITY_HIGH
#define ERROR_SEV_CRITICAL  ERROR_SEVERITY_CRITICAL

#endif // CORE_07_CORE_ENUMS_MQH
