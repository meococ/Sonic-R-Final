//+------------------------------------------------------------------+
//|                01_Core_07_CommonStructures.mqh                   |
//|                SONIC R MC - Common Data Structures               |
//|                     �?i B�ng Architecture - Data Layer           |
//+------------------------------------------------------------------+
#ifndef CORE_07_COMMON_STRUCTURES_MQH
#define CORE_07_COMMON_STRUCTURES_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_22_SonicEnums.mqh"

//+------------------------------------------------------------------+
//| BASIC SIGNAL DATA STRUCTURE                                      |
//+------------------------------------------------------------------+
struct SSignalData
{
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double confidence;                   // Signal confidence (0-1)
    datetime timestamp;                  // Signal timestamp
    bool isValid;                        // Signal validity
    double entryPrice;                   // Entry price
    double stopLoss;                     // Stop loss level
    double takeProfit;                   // Take profit level
    string reason;                       // Signal reason
};

//+------------------------------------------------------------------+
//| ENHANCED SIGNAL DATA STRUCTURE                                   |
//+------------------------------------------------------------------+
struct SEnhancedSignalData
{
    // Basic signal info
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double confidence;                   // Overall confidence (0-1)
    datetime signalTime;                 // Signal timestamp
    bool isValid;                        // Signal validity

    // Entry and exit levels
    double entryPrice;                   // Entry price
    double stopLoss;                     // Stop loss level
    double takeProfit;                   // Take profit level
    double riskReward;                   // Risk-reward ratio

    // Component scores
    double dragonScore;                  // Dragon Band score
    double waveScore;                    // Wave pattern score
    double pvsraScore;                   // PVSRA score
    double smcScore;                     // SMC score
    double srScore;                      // Support/Resistance score
    double momentumScore;                // Momentum score
    double confluenceScore;              // Overall confluence score

    // Additional validation scores
    double marketStructureScore;         // Market structure score
    double volumeConfirmationScore;      // Volume confirmation score
    double trendAlignmentScore;          // Trend alignment score
    double strengthScore;                // Overall strength score

    // Filter and validation
    bool passesFilters;                  // Passes all filters
    ENUM_SIGNAL_TYPE type;               // Signal type (alias for signalType)
    double strength;                     // Signal strength (alias for confidence)
    double riskRewardRatio;              // Risk reward ratio

    // Additional info
    string reason;                       // Signal reason
    string tags;                         // Signal tags
    bool isScout;                        // Is scout signal
    ENUM_TRADING_SCENARIO scenario;      // Trading scenario

    // FINAL SPRINT - Missing members for MasterOrchestrator
    bool signalValid;                    // Signal validity
    ENUM_SIGNAL_TYPE direction;          // Signal direction
    double finalScore;                   // Final score
    string reasoning;                    // Signal reasoning
    double trendAlignment;               // Trend alignment
    double supportResistanceScore;       // Support resistance score
    double meanReversionScore;           // Mean reversion score
};

//+------------------------------------------------------------------+
//| TRADING SIGNAL STRUCTURE                                         |
//+------------------------------------------------------------------+
struct TradingSignal
{
    ENUM_SIGNAL_TYPE type;               // Signal type
    ENUM_ORDER_TYPE side;                // Order side (BUY/SELL)
    double sl;                           // Stop loss
    double tp;                           // Take profit
    double confidence;                   // Signal confidence
    string reason;                       // Signal reason
    bool is_scout;                       // Is scout signal
    datetime timestamp;                  // Signal timestamp
    double entry_price;                  // Entry price
    double risk_reward;                  // Risk-reward ratio
};

//+------------------------------------------------------------------+
//| CONFLUENCE DATA STRUCTURE                                        |
//+------------------------------------------------------------------+
struct SConfluenceData
{
    double dragonBandScore;              // Dragon Band confluence
    double pvsraScore;                   // PVSRA confluence
    double waveScore;                    // Wave pattern confluence
    double smcScore;                     // SMC confluence
    double momentumScore;                // Momentum confluence
    double overallScore;                 // Overall confluence score
    bool isValid;                        // Confluence validity
    datetime timestamp;                  // Confluence timestamp

    // AGGRESSIVE ADDITION - Missing members for MasterOrchestrator
    double srScore;                      // Support/Resistance score
    double confluenceScore;              // Confluence score
    bool signalValid;                    // Signal validity
    ENUM_SIGNAL_TYPE direction;          // Signal direction
    bool passesFilters;                  // Passes filters
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double finalScore;                   // Final score
    double confidence;                   // Confidence level
    string reasoning;                    // Reasoning string
    datetime signalTime;                 // Signal time
    double marketStructureScore;         // Market structure score
    double volumeConfirmationScore;      // Volume confirmation score
    double trendAlignmentScore;          // Trend alignment score
    double strengthScore;                // Strength score
    double riskRewardRatio;              // Risk reward ratio
    double trendAlignment;               // Trend alignment
    double supportResistanceScore;       // Support resistance score
    double meanReversionScore;           // Mean reversion score
};

//+------------------------------------------------------------------+
//| SYSTEM STATE STRUCTURE                                           |
//+------------------------------------------------------------------+
struct SSystemState
{
    bool isActive;                       // System active state
    bool tradingAllowed;                 // Trading allowed flag
    datetime lastUpdate;                 // Last update time
    int errorCount;                      // Error count
    string lastError;                    // Last error message
    double systemHealth;                 // System health (0-1)
};

//+------------------------------------------------------------------+
//| SIGNAL DATA STRUCTURE (Alias for compatibility)                  |
//+------------------------------------------------------------------+
struct SignalData
{
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double confidence;                   // Signal confidence (0-1)
    datetime timestamp;                  // Signal timestamp
    bool isValid;                        // Signal validity
    double entryPrice;                   // Entry price
    double stopLoss;                     // Stop loss level
    double takeProfit;                   // Take profit level
    string reason;                       // Signal reason
};

//+------------------------------------------------------------------+
//| SIGNAL DECISION STRUCTURE                                        |
//+------------------------------------------------------------------+
struct SignalDecision
{
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double confidence;                   // Signal confidence (0-1)
    datetime timestamp;                  // Signal timestamp
    bool isValid;                        // Signal validity
    double entryPrice;                   // Entry price
    double stopLoss;                     // Stop loss level
    double takeProfit;                   // Take profit level
    string reason;                       // Signal reason
    ENUM_TRADING_SCENARIO scenario;      // Trading scenario
    double riskReward;                   // Risk-reward ratio
    bool isScout;                        // Is scout signal
};

//+------------------------------------------------------------------+
//| COMPONENT SIGNAL STRUCTURE                                       |
//+------------------------------------------------------------------+
struct SComponentSignal
{
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double confidence;                   // Signal confidence (0-1)
    datetime timestamp;                  // Signal timestamp
    bool isValid;                        // Signal validity
    string component;                    // Component name
    double weight;                       // Component weight

    // AGGRESSIVE ADDITION - Missing members for MasterOrchestrator
    string source;                       // Signal source
    ENUM_SIGNAL_TYPE signal;             // Signal enum
};

//+------------------------------------------------------------------+
//| ORDER BLOCK STRUCTURE                                            |
//+------------------------------------------------------------------+
struct OrderBlock
{
    ENUM_ORDER_BLOCK_TYPE type;          // Order block type
    double price;                        // Order block price
    datetime timestamp;                  // Order block timestamp
    double volume;                       // Order block volume
    bool isValid;                        // Order block validity
    double strength;                     // Order block strength

    // AGGRESSIVE ADDITION - Missing members for POIScoring
    bool isBullish;                      // Is bullish order block
    int barIndex;                        // Bar index

    // FINAL PUSH - Additional missing members
    double lowPrice;                     // Low price of order block
    double highPrice;                    // High price of order block
    datetime startTime;                  // Start time of order block
};

//+------------------------------------------------------------------+
//| DRAGON BAND DATA STRUCTURE                                       |
//+------------------------------------------------------------------+
struct SDragonBandData
{
    double upperBand;                    // Upper dragon band
    double lowerBand;                    // Lower dragon band
    double middleBand;                   // Middle dragon band
    ENUM_DRAGON_STATE state;             // Dragon state
    ENUM_TREND_DIRECTION trend;          // Trend direction
    double strength;                     // Band strength
    bool isValid;                        // Data validity
    datetime timestamp;                  // Data timestamp

    // AGGRESSIVE ADDITION - Missing members for MasterOrchestrator
    double bandwidth;                    // Band width
    datetime dataTimestamp;              // Data timestamp
    int validationFlags;                 // Validation flags
};

//+------------------------------------------------------------------+
//| FAIR VALUE GAP STRUCTURE                                         |
//+------------------------------------------------------------------+
struct FairValueGap
{
    ENUM_FVG_TYPE type;                  // Fair value gap type
    double upperLevel;                   // Upper level of gap
    double lowerLevel;                   // Lower level of gap
    datetime startTime;                  // Gap start time
    datetime endTime;                    // Gap end time
    bool isValid;                        // Gap validity
    bool isFilled;                       // Gap filled status
    double fillPrice;                    // Fill price
    datetime fillTime;                   // Fill time
    double strength;                     // Gap strength

    // AGGRESSIVE ADDITION - Missing members for POIScoring
    int barIndex;                        // Bar index

    void Reset()
    {
        type = FVG_UNKNOWN;
        upperLevel = 0.0;
        lowerLevel = 0.0;
        startTime = 0;
        endTime = 0;
        isValid = false;
        isFilled = false;
        fillPrice = 0.0;
        fillTime = 0;
        strength = 0.0;
    }
};

//+------------------------------------------------------------------+
//| LIQUIDITY POOL STRUCTURE                                         |
//+------------------------------------------------------------------+
struct LiquidityPool
{
    ENUM_LIQUIDITY_TYPE type;            // Liquidity type
    double price;                        // Liquidity price level
    double volume;                       // Liquidity volume
    datetime timestamp;                  // Liquidity timestamp
    bool isValid;                        // Liquidity validity
    bool isSwept;                        // Swept status
    datetime sweptTime;                  // Swept time
    double strength;                     // Liquidity strength

    void Reset()
    {
        type = LIQUIDITY_UNKNOWN;
        price = 0.0;
        volume = 0.0;
        timestamp = 0;
        isValid = false;
        isSwept = false;
        sweptTime = 0;
        strength = 0.0;
    }
};

// NOTE: SwingPoint struct is defined below with ENUM_SWING_TYPE

//+------------------------------------------------------------------+
//| SIGNAL INFO STRUCTURE                                            |
//+------------------------------------------------------------------+
struct SSignalInfo
{
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    double confidence;                   // Signal confidence (0-1)
    datetime timestamp;                  // Signal timestamp
    bool isValid;                        // Signal validity
    double entryPrice;                   // Entry price
    double stopLoss;                     // Stop loss level
    double takeProfit;                   // Take profit level
    string reason;                       // Signal reason
    ENUM_TRADING_SCENARIO scenario;      // Trading scenario
    double riskReward;                   // Risk-reward ratio
    bool isScout;                        // Is scout signal
};

//+------------------------------------------------------------------+
//| TRADE SIGNAL STRUCTURE                                           |
//+------------------------------------------------------------------+
struct STradeSignal
{
    ENUM_SIGNAL_TYPE signalType;         // Signal type
    ENUM_ORDER_TYPE orderType;           // Order type
    double entryPrice;                   // Entry price
    double stopLoss;                     // Stop loss
    double takeProfit;                   // Take profit
    double lotSize;                      // Lot size
    double confidence;                   // Signal confidence
    string reason;                       // Signal reason
    datetime timestamp;                  // Signal timestamp
    bool isValid;                        // Signal validity
};

//+------------------------------------------------------------------+
//| SWING POINT STRUCTURE                                            |
//+------------------------------------------------------------------+
struct SwingPoint
{
    ENUM_SWING_TYPE type;                // Swing point type
    double price;                        // Swing point price
    datetime timestamp;                  // Swing point timestamp
    int barIndex;                        // Bar index
    bool isValid;                        // Swing point validity
    double strength;                     // Swing point strength

    // AGGRESSIVE ADDITION - Missing members for PatternRecognition
    datetime time;                       // Alternative time field

    void Reset()
    {
        type = SWING_UNKNOWN;
        price = 0.0;
        timestamp = 0;
        time = 0;
        barIndex = -1;
        isValid = false;
        strength = 0.0;
    }
};

//+------------------------------------------------------------------+
//| ENUMS MOVED TO CORE_ENUMS - NO DUPLICATES                       |
//+------------------------------------------------------------------+
// NOTE: All enums moved to 01_Core_14_CoreEnums.mqh to avoid duplicates

//+------------------------------------------------------------------+
//| MISSING STRUCTURES - AGGRESSIVE ADDITION                        |
//+------------------------------------------------------------------+
struct SSMCLevel
{
    double price;
    datetime time;
    ENUM_DIRECTION direction;
    double strength;
    bool isValid;
    string description;
};

struct HarmonicPattern
{
    ENUM_HARMONIC_PATTERN type;
    double pointX;
    double pointA;
    double pointB;
    double pointC;
    double pointD;
    datetime timeX;
    datetime timeA;
    datetime timeB;
    datetime timeC;
    datetime timeD;
    double confidence;
    bool isValid;
    ENUM_DIRECTION direction;

    // AGGRESSIVE ADDITION - Missing members for PatternRecognition
    bool isBullish;                      // Pattern direction
    ENUM_PATTERN_VALIDATION validation;  // Pattern validation
    bool isActive;                       // Pattern active status
    double prdZoneLow;                   // PRD zone low
    double prdZoneHigh;                  // PRD zone high
};

struct SEnhancedMarketStructure
{
    ENUM_MARKET_STRUCTURE type;
    double strength;
    datetime time;
    double price;
    bool isValid;
    string description;
    double confidence;
    datetime lastUpdate;
    ENUM_MARKET_STRUCTURE structureType;

    // AGGRESSIVE ADDITION - Missing members for MasterOrchestrator
    ENUM_TREND_DIRECTION trendDirection;
    double structureStrength;
    bool isBreakoutConfirmed;
};

//+------------------------------------------------------------------+
//| AGGRESSIVE ROUND 3 - COMPLEX MISSING STRUCTS                    |
//+------------------------------------------------------------------+
struct VolatilityRegimeData
{
    ENUM_MARKET_REGIME regime;
    double realizedVolatility;
    double impliedVolatility;
    double volatilityRatio;
    datetime timestamp;
    bool isTransitioning;
    double confidence;

    // FINAL PUSH - Missing members for MarketContext
    ENUM_VOLATILITY_REGIME currentRegime;
    double atrPercentile;
};

// DUPLICATE STRUCTS REMOVED - Already defined above in lines 173-327

#endif // CORE_07_COMMON_STRUCTURES_MQH
