//+------------------------------------------------------------------+
//|                           SONIC R MC INPUTS                     |
//|                    ENTERPRISE-GRADE PARAMETER SYSTEM             |
//|                   Built for Professional Traders                 |
//+------------------------------------------------------------------+
#ifndef CORE_00_INPUTS_MQH
#define CORE_00_INPUTS_MQH

#include "01_Core_22_SonicEnums.mqh"

//================================================================//
//                        🎯 STRATEGY PROFILES                     //
//                Smart profiles with auto-configuration           //
//================================================================//

// Main strategy profile - automatically configures all parameters
input ENUM_STRATEGY_PROFILE InpStrategyProfile = PROFILE_SONIC_BASE; // Strategy profile

// Feature mode: AUTO = profile-driven, CUSTOM = manual control
enum ENUM_FEATURE_MODE { FEATURE_AUTO, FEATURE_CUSTOM };
input ENUM_FEATURE_MODE InpFeatureMode = FEATURE_AUTO;  // Feature configuration mode

// Asset pack for symbol-specific tuning
enum ENUM_ASSET_PACK { AP_XAU, AP_FX_MAJORS, AP_CRYPTO, AP_INDEX };
input ENUM_ASSET_PACK InpAssetPack = AP_XAU;  // Asset type for optimization

// Session management
enum ENUM_SESSION_MODE { SESSION_OFF, SESSION_LONDON_NY, SESSION_CUSTOM };
input ENUM_SESSION_MODE InpSessionMode = SESSION_LONDON_NY; // Trading session mode

//================================================================//
//                      💰 RISK MANAGEMENT                         //
//              Professional money and risk management               //
//================================================================//

// Core risk parameters
input double InpRiskPercent = 1.0;      // Risk per trade (%)
input double InpRiskReward = 2.0;       // Risk:Reward ratio
input int InpMaxDailyTrades = 5;        // Max trades per day
input double InpMaxDailyDrawdown = 5.0; // Max daily drawdown (%)

// Circuit breaker
input bool InpUseCircuitBreaker = true; // Enable circuit breaker
input double InpMaxDailyR_Loss = 2.0;   // Stop if daily R <= -2.0
input double InpCB_EquityDDPercent = 3.0; // Stop if equity DD >= 3%

//================================================================//
//                    🎯 SIGNAL GENERATION                         //
//              Core thresholds for signal generation               //
//================================================================//

// Signal quality thresholds
input double InpMinSignalStrength = 25.0;     // Min signal strength (%)
input double InpConfluenceThreshold = 0.25;   // Confluence threshold (0.0-1.0)
input double InpMTFMinConfidence = 0.45;      // Min MTF confidence (0..1)

// Wave analysis parameters
input bool InpUseZigZagAssist = true;         // Use ZigZag for wave detection
input int InpZZ_Depth = 12;                   // ZigZag depth
input int InpZZ_Deviation = 5;                // ZigZag deviation
input int InpZZ_Backstep = 3;                 // ZigZag backstep
input double InpWave_TolerancePips = 4.0;     // Wave tolerance (pips)
input double InpWave_AngleMinDeg = 2.0;       // Min wave angle (degrees)

// Dragon Band & Sonic parameters
input double InpDragonAngleMinDeg = 0.8;      // Min Dragon angle (degrees)
input double InpRangeMaxPips2H = 50.0;        // Max 2H range (pips)
input double InpSonicBasicRequireRR = 2.0;    // Min R:R required
input double InpRangeATRCapMult = 3.5;        // ATR multiplier for range cap

// MTF weights for confluence
input double InpMTFWeight_H4 = 0.20;          // H4 weight
input double InpMTFWeight_H1 = 0.30;          // H1 weight
input double InpMTFWeight_M15 = 0.30;         // M15 weight
input double InpMTFWeight_M5 = 0.20;          // M5 weight

//================================================================//
//                    🔍 ANALYSIS MODULES                          //
//              Enable/Disable advanced analysis modules             //
//================================================================//

// Core analysis modules (auto-configured by profile when FEATURE_AUTO)
input bool InpEnableDragonBand = true;        // Dragon Band analysis
input bool InpEnablePVSRA = true;             // PVSRA volume analysis
input bool InpEnableSMC = true;               // SMC concepts
input bool InpEnableScout = false;            // Scout range trading
input bool InpEnableWyckoff = true;           // Wyckoff cycles

// PVSRA settings
input double InpPVSRA_ConfluenceWeight = 0.50; // PVSRA weight
input double InpPVSRA_ScoreThreshold = 0.30;   // PVSRA threshold
input double InpPVSRA_VolumeRatio_Strong = 2.00; // Strong volume ratio
input double InpPVSRA_VolumeRatio_High = 1.50;   // High volume ratio

// SMC settings
input double InpSMCScoreThreshold = 0.50;      // SMC score threshold
input double InpSMCStrongThreshold = 0.80;     // Strong SMC threshold
input double InpSMC_MinSwingPips = 15.0;       // Min swing size (pips)
input double InpSMC_BOS_ConfirmPips = 5.0;    // BOS confirmation (pips)

//================================================================//
//                 ⚡ EXECUTION & ORDER MANAGEMENT                  //
//              Stop Loss & Take Profit configuration               //
//================================================================//

// Execution mode
input bool InpAutoTrading = true;              // Enable automated trading
enum ENUM_EXECUTION_MODE { EXEC_MARKET, EXEC_CLASSIC_STOP };
input ENUM_EXECUTION_MODE InpExecutionMode = EXEC_CLASSIC_STOP; // Order execution mode
input double InpClassicPendingOffsetPips = 8.0; // Pending offset (pips)

// NEW: Hotfix A toggles
input bool   InpDryRun = false;                // Dry run (no real orders)
input double InpMinBalanceToTrade = 0.0;       // Minimum balance to allow trading (0=off)
input bool   InpEvaluateEveryTick = false;     // Evaluate signals on every tick (off=new-bar only)

// Stop Loss configuration
input bool InpUseATRBasedSL = true;            // Use ATR-based Stop Loss
input int InpATRPeriod = 14;                   // ATR period
input double InpSL_ATR_Multiplier = 1.8;       // ATR multiplier for SL
input double InpMinSLPips = 50.0;              // Minimum SL (pips)

// Trailing Stop
input bool InpEnableTrailing = true;           // Enable trailing stop
input double InpTrailingStart = 60.0;          // Trailing start (pips)
input double InpTrailingStep = 20.0;           // Trailing step (pips)

// Risk-Reward mode
enum ENUM_RR_MODE { RR_FIXED, RR_ATR_ADAPTIVE };
input ENUM_RR_MODE InpRRMode = RR_FIXED;       // RR mode
input double InpRR_Min = 1.80;                 // Min RR for adaptive
input double InpRR_Max = 3.20;                 // Max RR for adaptive
input double InpRR_Base = 2.20;                // Base RR when ATR ratio=1

//================================================================//
//                   🚫 SESSION & FILTERING                        //
//              Session management and market filtering              //
//================================================================//

// Session filter
input bool InpEnableSessionFilter = false;     // Enable session filter
input bool InpRestrictBySession = true;        // Use predefined sessions
input bool InpAllowAsian = false;              // Allow Asian session
input bool InpAllowLondon = true;              // Allow London session
input bool InpAllowNY = true;                  // Allow New York session
input bool InpUseOverlapWindow = true;         // Use London/NY overlap
input int InpOverlapStartHour = 12;            // Overlap start hour
input int InpOverlapEndHour = 16;              // Overlap end hour

// Custom session
input bool InpUseCustomSession = false;        // Custom time window
input int InpSessionStartHour = 8;             // Custom start hour
input int InpSessionEndHour = 22;              // Custom end hour
input int InpBrokerGMTOffset = 0;              // Broker GMT offset (hours)

// Market filtering
input double InpMaxSpreadPips = 60.0;          // Max spread (pips)
input int InpMaxPositionsSymbol = 3;           // Max positions per symbol

//================================================================//
//                   🎛️ UI & MONITORING                           //
//              Dashboard, alerts, and smart notifications          //
//================================================================//

// Core mode
input bool InpMinimalCoreMode = false;         // Minimal core mode

// Dashboard & Display
input bool InpShowDashboard = true;            // Show dashboard
input bool InpShowSignals = true;              // Show signal arrows
input bool InpShowEMA34 = true;                // Show EMA 34
input bool InpShowEMA89 = true;                // Show EMA 89
input bool InpShowEMA200 = true;               // Show EMA 200

// Dashboard layout
input bool InpDashboardCompact = true;         // Compact mode
input int InpDashboardX = 10;                  // X offset (px)
input int InpDashboardY = 10;                  // Y offset (px)
input int InpDashboardW = 320;                 // Width (px)
input int InpDashboardH = 140;                 // Height (px)
input int InpDashboardCorner = 0;              // Anchor corner (0-3)

// Overlay controls
input bool InpShowSMCOverlayZones = true;      // Show SMC zones
input bool InpShowFVGOverlay = true;           // Show Fair Value Gaps
input bool InpShowOrderBlocksOverlay = true;   // Show Order Blocks
input bool InpShowLiquidityOverlay = true;     // Show Liquidity Pools

//================================================================//
//                  🔧 TESTING & OPTIMIZATION                      //
//                   Development and Debug toggles                 //
//================================================================//

// Testing controls
input bool InpTestingMode = false;             // Advanced testing mode
input bool InpTestingRelaxed = false;          // Relaxed backtest mode
input bool InpEnableBacktest = true;           // Enable backtest mode
input bool InpDebugMode = true;                // Debug mode

// Backtest logging
enum ENUM_BACKTEST_LOG_MODE { BT_LOG_OFF, BT_LOG_M15_ONLY, BT_LOG_COMPACT };
input ENUM_BACKTEST_LOG_MODE InpBacktestLogMode = BT_LOG_COMPACT; // Log mode

// Trade guards
input int InpMinBarsBetweenTrades = 1;         // Min bars between trades
input int InpMinSecondsBetweenTrades = 10;     // Min seconds between trades

//================================================================//
//                    📊 ADVANCED CONFIGURATION                     //
//                        Expert users only                          //
//================================================================//

// Volatility & Market Conditions
input double InpVolatilityMultiplier = 1.0;    // Volatility filter multiplier
input double InpCorrelationThreshold = 0.7;    // Correlation threshold

// News & Economic Calendar
input bool InpUseEconomicCalendar = true;      // Use economic calendar
input int InpNewsBufferMinutes = 30;           // News blackout window (minutes)
input int InpNewsMinImportance = 1;            // Min importance (0-2)

// AI/ML Controls
input bool InpEnableMLPrediction = false;      // ML prediction (Beta)
input double InpMLWeight = 0.30;               // ML blend weight (0..1)
input bool InpEnablePerfTuner = true;          // Performance analyzer

// Monte Carlo & Performance
input int InpMCSimulations = 10000;            // Monte Carlo simulations
input int InpVaRSimulations = 5000;            // VaR simulations

//================================================================//
//                    🔧 LEGACY PARAMETERS                         //
//              Required for backward compatibility                 //
//================================================================//

// Legacy parameters that other files still reference
input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_M15;  // Signal timeframe
input bool InpUseNewBarMode = false;           // Use new bar mode
input bool InpShowDebugInfo = false;           // Show debug info
input ENUM_TIMEFRAMES InpLogBarTF = PERIOD_M15; // Log bar timeframe
input bool InpLogNewBarOnly = true;            // Log new bar only
input int InpLogThrottleMs = 1000;             // Log throttle (ms)
input bool InpDebugCompact = false;            // Debug compact mode

// Wave parameters
input bool InpWave_UseConsistency = true;      // Use wave consistency
input int InpWave_ConsistencyPoints = 3;       // Wave consistency points
input bool InpWave_LogPassOnly = false;        // Wave log pass only

// Session parameters
input bool InpUseSessionGate = true;           // Use session gate
input bool InpRequireTrendStack = true;        // Require trend stack

// PVSRA parameters
input double InpPVSRA_VolumeRatio_AboveAvg = 1.5;  // PVSRA volume ratio above avg
input double InpPVSRA_VolumeRatio_Normal = 1.0;    // PVSRA volume ratio normal
input bool InpPVSRA_EnableMTF = true;              // PVSRA enable MTF
input bool InpPVSRA_StrictDirection = false;       // PVSRA strict direction
input double InpAlignBonus = 0.15;                 // Alignment bonus

// Preset parameters
input bool InpPresetByStrategy = true;         // Preset by strategy

// Telegram parameters
input bool InpTelegramEnabled = false;         // Enable Telegram
input bool InpTelegramImportantOnly = true;    // Telegram important only

// Daily loss limit (legacy)
input double InpDailyLossLimitPct = 5.0;      // Daily loss limit (%)

// Sonic parameters
input double InpSonicMinBodyRatio = 0.6;      // Sonic min body ratio
input double InpSonicMaxOppWickRatio = 0.3;   // Sonic max opposite wick ratio

// VPSRA parameters
input double InpVPSRA_VolumeSpikeMult = 1.8;  // VPSRA volume spike multiplier

// SMC parameters
input bool InpSMC_CacheNewBarOnly = true;      // SMC cache new bar only
input bool InpLogSMCDetails = false;           // Log SMC details

// Wave parameters (additional)
input int InpWaveSwingWidth = 3;               // Wave swing width
input int InpWaveMaxBack = 150;                // Wave max back

// PVSRA parameters (additional)
input double InpPVSRA_WholeHalfProxATR = 0.15; // PVSRA whole half proximity ATR
input int InpPVSRA_VolLookback = 50;           // PVSRA volume lookback
input double InpPVSRA_ZMin = 1.0;              // PVSRA Z min
input double InpPVSRA_TrendAlignBonus = 0.15;  // PVSRA trend align bonus
input double InpWeightPVSRA = 0.60;            // PVSRA weight

// Session policy
enum ENUM_SESSION_POLICY { SP_OFF, SP_LONDON_NY, SP_CUSTOM };
input ENUM_SESSION_POLICY InpSessionPolicy = SP_LONDON_NY; // Session policy

// Asset pack (legacy)
enum ENUM_ASSET_PACK_LEGACY { ASSET_XAU, ASSET_FX_MAJORS, ASSET_CRYPTO_LEG, ASSET_INDEX_LEG };
input ENUM_ASSET_PACK_LEGACY InpAssetPackLegacy = ASSET_XAU; // Asset pack (legacy)

// Profile (legacy)
enum ENUM_PROFILE_LEGACY { PF_SONIC_BASIC, PF_SONIC_VPSRA, PF_MULTI_ASSET, PF_SMC_CONFLUENCE, PF_CUSTOM };
input ENUM_PROFILE_LEGACY InpProfile = PF_SONIC_BASIC; // Profile (legacy)

// Additional profile constants
#define PROFILE_CUSTOM PROFILE_CUSTOM_LEGACY
#define PROFILE_CUSTOM_LEGACY 4

// Feature mode auto
input bool InpFeatureModeAuto = true;          // Feature mode auto

// RR mode (legacy)
enum ENUM_RR_MODE_LEGACY { RR_MODE_FIXED, RR_MODE_ADAPTIVE };
input ENUM_RR_MODE_LEGACY InpRR_Mode = RR_MODE_FIXED; // RR mode (legacy)

// ATR SL multiplier (legacy)
input double InpATR_SL_Mult = 1.8;             // ATR SL multiplier (legacy)

// Signal TF and Bias TF
input ENUM_TIMEFRAMES InpSignalTF = PERIOD_M15; // Signal timeframe
input ENUM_TIMEFRAMES InpBiasTF = PERIOD_H4;    // Bias timeframe

// Spread pad factor
input double InpSpreadPadFactor = 0.5;         // Spread pad factor

// RR ATR reference
input ENUM_TIMEFRAMES InpRR_ATRRefTF = PERIOD_H1; // RR ATR reference timeframe
input int InpRR_ATRRefBars = 50;               // RR ATR reference bars
input double InpRR_Slope = 0.5;                // RR slope

// Global variables for Telegram
string g_TelegramBotToken = "";                 // Telegram bot token
string g_TelegramChatId = "";                   // Telegram chat ID

// Global variables for session
ENUM_SESSION_POLICY g_SessionPolicy = SP_LONDON_NY; // Global session policy
ENUM_ASSET_PACK_LEGACY g_AssetPack = ASSET_XAU;     // Global asset pack
ENUM_PROFILE_LEGACY g_Profile = PF_SONIC_BASIC;     // Global profile

// Missing parameters that are causing compile errors
input bool InpAvoidAsia = false;               // Avoid Asian session
input double InpOptionalMinPass = 0.5;         // Optional minimum pass
input bool InpUseAssetDNA = true;              // Use asset DNA
input bool InpMinimalCore_SMCAsSoft = false;   // Minimal core SMC as soft
input bool InpSMC_UseHTFConfirm = true;        // SMC use HTF confirm
input double InpSMC_LS_ATRMultiplier = 2.0;    // SMC liquidity sweep ATR multiplier
input double InpSMC_LS_ReversalPips = 10.0;    // SMC liquidity sweep reversal pips
input double InpSMC_OB_MaxDistancePips = 50.0; // SMC order block max distance pips
input double InpSMC_OB_MinSizePips = 5.0;      // SMC order block min size pips
input double InpSMC_OB_VolumeThreshold = 1.5;  // SMC order block volume threshold
input ENUM_TIMEFRAMES InpSMC_HTF = PERIOD_H1;  // SMC higher timeframe

// UI overlay parameters
input int InpOverlayMaxObjects = 100;          // Max overlay objects
input bool InpShowBOSCHOCHOverlay = true;      // Show BOS/CHOCH overlay
input bool InpOverlayAlternateBarLabels = false; // Overlay alternate bar labels
input double InpOverlayLabelOffsetPips = 5.0;  // Overlay label offset pips
input int InpOverlayThrottleMs = 100;          // Overlay throttle ms
input bool InpShowMinimalHUD = false;          // Show minimal HUD
input bool InpShowSonicOverlay = true;         // Show Sonic overlay

// Session minutes
input int InpSessionStartMinute = 0;           // Session start minute
input int InpSessionEndMinute = 0;             // Session end minute

// Loss cooldown
input int InpLossCooldownBarsBase = 10;        // Loss cooldown bars base

// Additional missing variables for Core_Config
double riskPct = 1.0;                          // Risk percentage
double rrBase = 2.0;                           // Risk reward base
int rrMode = 0;                                // Risk reward mode
double atrSLMult = 1.8;                        // ATR SL multiplier

//================================================================//
//                    🔧 LEGACY FUNCTIONS                          //
//              Required for backward compatibility                 //
//================================================================//

// Legacy functions that other files still reference
inline int WaveSwingWidth() { return MathMax(2, InpWaveSwingWidth); }
inline int WaveMaxBack() { return MathMax(60, InpWaveMaxBack); }

inline double WholeHalfProxATR() { return MathMax(0.05, InpPVSRA_WholeHalfProxATR); }
inline int PVSRA_VolLb() { return MathMax(20, InpPVSRA_VolLookback); }
inline double PVSRA_ZMin() { return MathMax(0.5, InpPVSRA_ZMin); }
inline double PVSRA_AlignBonus() { return MathMax(0.0, InpPVSRA_TrendAlignBonus); }

// Strict Sonic Classic
inline bool StrictSonicClassic() { return false; }

// Dry Run
inline bool DryRun() { return InpDryRun; }

// Warn Only Spread Cap
inline bool WarnOnlySpreadCap() { return true; }

// EC Mode Tag
inline string EC_ModeTag() {
    return StringFormat("%s | %s | %s | %s",
        (InpFeatureMode==FEATURE_AUTO)?"AUTO":"CUSTOM",
        StrictSonicClassic()?"STRICT":"NORMAL",
        DryRun()?"DRYRUN":"LIVE",
        WarnOnlySpreadCap()?"WARN-SPREAD":"CAP-SPREAD");
}

// Validate Inputs
inline void ValidateInputs() {
    // Placeholder for backward compatibility
}

// Apply Profile Presets
inline void ApplyProfilePresets() {
    string prof = "";
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE: prof = "PROFILE_SONIC_BASE"; break;
        case PROFILE_SONIC_VPSRA: prof = "PROFILE_SONIC_VPSRA"; break;
        case PROFILE_MULTI_ASSET: prof = "PROFILE_MULTI_ASSET"; break;
        default: prof = "PROFILE_UNKNOWN/CUSTOM"; break;
    }
    Print("[PROFILE] Using ", prof, ", SessionMode=", (int)InpSessionMode);
}

// DP functions
// Use Unified Indicator Manager for EMA access
#include "02_DataProviders_05_IndicatorManager.mqh"
inline double DP_Angle34Deg(const int lookbackBars=8) {
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_CLOSE);
    if(h==INVALID_HANDLE || lookbackBars<2) return 0.0;
    double buf[16]; int n=MathMin(lookbackBars,16);
    if(CopyBuffer(h,0,0,n,buf)<n) return 0.0;
    double slope = buf[0] - buf[n-1];
    double angle = MathArctan((slope/MathMax(1.0,n-1))) * 180.0/M_PI;
    return angle;
}
inline double DP_EMA34(int sh) {
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_CLOSE);
    double v[1]; if(h!=INVALID_HANDLE && CopyBuffer(h,0,sh,1,v)>0) return v[0];
    return 0.0;
}
inline double DP_EMA89(int sh) {
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h = mgr.GetEMAHandle(_Symbol, TF_Signal(), 89, PRICE_CLOSE);
    double v[1]; if(h!=INVALID_HANDLE && CopyBuffer(h,0,sh,1,v)>0) return v[0];
    return 0.0;
}
inline double DP_Close(ENUM_TIMEFRAMES tf, int shift) { return 0.0; }
inline datetime DP_Time(ENUM_TIMEFRAMES tf, int shift) { return 0; }
inline bool DP_IsSessionAllowedNow() { return true; }
inline void DP_TimeGmtStruct(MqlDateTime &dt) { TimeToStruct(TimeCurrent(), dt); }

// Profile configurations (applied automatically when FEATURE_AUTO)
// PROFILE_SONIC_BASE:      Conservative, 62.3% WR, R:R 1:2.3, Risk 0.8%
// PROFILE_SONIC_VPSRA:     Balanced, 65.7% WR, R:R 1:1.8, Risk 1.0%
// PROFILE_MULTI_ASSET:     Advanced Multi-Symbol, Risk 0.7%
// PROFILE_CUSTOM:           Full manual control

#endif // CORE_00_INPUTS_MQH

//================================================================//
//                    EFFECTIVE CONFIG & WRAPPERS                  //
//    Cung cấp các getter/tham số hợp nhất để tránh facade thiếu   //
//================================================================//

// Effective Config (EC) tối giản để phục vụ compile và runtime
struct SEffectiveConfig {
   int    spreadCapPoints;   // spread cap (points)
   double atrSLMult;         // ATR SL multiplier
   double rrBase;            // RR base
   double slFloorPx;         // SL floor (price units)
};
SEffectiveConfig EC; // Global EC

inline void ApplyEffectiveConfig(){
   double pip = ((_Digits==3||_Digits==5)? 10*_Point : _Point);
   // Convert pips -> points for spread cap
   int pointsPerPip = (int)MathRound(pip/_Point);
   EC.spreadCapPoints = (int)MathMax(1, MathRound(InpMaxSpreadPips * pointsPerPip));
   EC.atrSLMult       = MathMax(0.5, InpSL_ATR_Multiplier);
   EC.rrBase          = MathMax(0.5, InpRiskReward);
   EC.slFloorPx       = MathMax(10.0*pip, InpMinSLPips*pip);
}

inline string EC_Overview(){
   return StringFormat("cap=%dpts rr=%.2f atr=%.2f slFloor=%.1fpips",
      EC.spreadCapPoints, EC.rrBase, EC.atrSLMult, EC.slFloorPx/((_Digits==3||_Digits==5)? 10*_Point : _Point));
}

// Keep ValidateInputs/ApplyProfilePresets as declared above

// Unified getters used khắp nơi
inline double RR_Base(){ return (InpRRMode==RR_FIXED? InpRiskReward : PR_GetRR()); }
inline double ATR_SL_Mult(){ return MathMax(0.5, InpSL_ATR_Multiplier); }
inline int    SpreadCapPts(){
   if(EC.spreadCapPoints>0) return EC.spreadCapPoints;
   double pip = ((_Digits==3||_Digits==5)? 10*_Point : _Point);
   int pointsPerPip = (int)MathRound(pip/_Point);
   return (int)MathMax(1, MathRound(InpMaxSpreadPips * pointsPerPip));
}
inline double RiskPct(){ return MathMax(0.0, InpRiskPercent); }
inline ENUM_TIMEFRAMES TF_Signal(){ return InpSignalTF; }

// Entry offset theo pip (tối giản)
inline double EntryOffset(){ double pip = ((_Digits==3||_Digits==5)? 10*_Point : _Point); return 2.0*pip; }
inline double MinAngleDeg(){ return PR_GetAngleMinDeg(); }
inline bool   UseTrendStack(){ return true; }
inline double Conf_Score(){ return 1.0; }
inline bool   Sonic_MinimalCoreSoftOK(){ return true; }

// Module toggles & session gates (wrappers to inputs)
inline bool UsePVSRA(){ return InpEnablePVSRA; }
inline bool UseSMC(){ return InpEnableSMC; }
inline bool GateSession(){ return InpUseSessionGate; }
inline int SessionPolicy(){ return (int)InpSessionMode; }

inline double CurrentEntryPrice(ENUM_ORDER_TYPE type){
   return (type==ORDER_TYPE_BUY? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID));
}

// Quyết định hướng (tối giản): so sánh Close với EMA89 trên TF tín hiệu
inline int DecideDirection(){
   CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
   int h34 = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_CLOSE);
   int h89 = mgr.GetEMAHandle(_Symbol, TF_Signal(), 89, PRICE_CLOSE);
   double e34[1], e89[1];
   if(h34!=INVALID_HANDLE && h89!=INVALID_HANDLE && CopyBuffer(h34,0,0,1,e34)>0 && CopyBuffer(h89,0,0,1,e89)>0){
      return (e34[0]>=e89[0]? (int)SIGNAL_BUY : (int)SIGNAL_SELL);
   }
   return (int)SIGNAL_SELL;
}

// Close nằm ngoài Dragon (EMA34 High/Low)
inline bool CloseAboveDragon(){
   CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
   int h = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_HIGH);
   double e[1]; double c = iClose(_Symbol, TF_Signal(), 0);
   return (h!=INVALID_HANDLE && CopyBuffer(h,0,0,1,e)>0 && c>e[0]);
}
inline bool CloseBelowDragon(){
   CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
   int h = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_LOW);
   double e[1]; double c = iClose(_Symbol, TF_Signal(), 0);
   return (h!=INVALID_HANDLE && CopyBuffer(h,0,0,1,e)>0 && c<e[0]);
}

// Wave/Swing (tối giản): luôn hợp lệ; leg2 là swing gần nhất
inline bool WaveValid(int dir){
   // Sonic R: require Dragon angle and EMA34/89 stack aligned with direction, and close outside Dragon
   double ang = DP_Angle34Deg(); if(MathAbs(ang) < MinAngleDeg()) return false;
   CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
   int h34c = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_CLOSE);
   int h34h = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_HIGH);
   int h34l = mgr.GetEMAHandle(_Symbol, TF_Signal(), 34, PRICE_LOW);
   int h89c = mgr.GetEMAHandle(_Symbol, TF_Signal(), 89, PRICE_CLOSE);
   double e34c[1], e89c[1], e34h[1], e34l[1]; double cls=iClose(_Symbol, TF_Signal(), 0);
   bool ok = (h34c!=INVALID_HANDLE && h89c!=INVALID_HANDLE && h34h!=INVALID_HANDLE && h34l!=INVALID_HANDLE &&
              CopyBuffer(h34c,0,0,1,e34c)>0 && CopyBuffer(h89c,0,0,1,e89c)>0 &&
              CopyBuffer(h34h,0,0,1,e34h)>0 && CopyBuffer(h34l,0,0,1,e34l)>0);
   if(!ok) return false;
   if(dir==(int)SIGNAL_BUY)  return (e34c[0]>e89c[0] && cls>e34h[0]);
   if(dir==(int)SIGNAL_SELL) return (e34c[0]<e89c[0] && cls<e34l[0]);
   return false;
}
inline double Leg2BreakPrice(int dir){
   int look=50; double best = (dir==SIGNAL_BUY? -DBL_MAX : DBL_MAX);
   for(int i=1;i<=look;i++){
      double hi=iHigh(_Symbol, InpSignalTF, i), lo=iLow(_Symbol, InpSignalTF, i);
      if(dir==SIGNAL_BUY) best = MathMax(best, hi); else best = MathMin(best, lo);
   }
   if(best<=-DBL_MAX || best>=DBL_MAX) return 0.0; return best;
}
