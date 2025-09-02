//+------------------------------------------------------------------+
//|                                      00_Main_EA_SonicR.mq5     |
//|                                    SONIC R MC - SIMPLIFIED     |
//|                                  Simplified version for testing |
//+------------------------------------------------------------------+
#property copyright "SONIC R MC"
#property link      ""
#property version   "1.02"
#property strict


// === FORCE LIGHT BUILD (compile hygiene) ===
// Khóa cứng để tránh kéo các module nặng vào build này
#define BUILD_PROFILE_LIGHT
#undef BUILD_PROFILE_ORCH
#undef BUILD_PROFILE_SMC
#undef SONIC_ALLOW_HEAVY
#undef ENABLE_SMC_ANALYSIS_FILES
#undef FEATURE_SMC_INTEGRATION
#undef FEATURE_MASTER_ORCHESTRATOR
#define FEATURE_MASTER_ORCHESTRATOR 0
#undef FEATURE_CONFLUENCE_ENGINE


// Unified master include controls all dependencies and feature flags
#include "00_Main_MasterIncludes.mqh"
#include "05_Trading_03_TradeGate.mqh"


//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                |
//+------------------------------------------------------------------+
// --- Pointers to Core Components
CCoreEngine* g_coreEngine = NULL;
CTradeGate*  g_tradeGate  = NULL; // Definition for extern in TradeGate

// --- Shared magic number for orders (referenced across modules)
int g_magicNumber = 12345;

// --- System State Variables
bool g_system_initialized = false;
int g_eaState = 0; // Simplified state
datetime g_lastTradeTime = 0;
datetime g_lastBarTime = 0;
int g_tradesThisBar = 0;
int g_daily_trades = 0;
datetime g_lastDayReset = 0;

//+------------------------------------------------------------------+
//| EXPERT INITIALIZATION FUNCTION                                  |
//+------------------------------------------------------------------+
int OnInit() {
    Print("=== SONIC R MC EA - INITIALIZING... ===");

    // Timer lifecycle
    EventSetTimer(1); // 1-second timer for maintenance counters and resets

    // 1. Initialize Core Engine
    g_coreEngine = new CCoreEngine();
    if(!g_coreEngine->Initialize()) {
        Print("❌ [INIT] Failed to initialize Core Engine");
        return INIT_FAILED;
    }
    Print("✅ [INIT] Core Engine initialized successfully.");

    // 1b. Initialize Trade Gate (risk/limits)
    InitializeTradeGate();

    // 2. Set up initial state
    g_system_initialized = true;
    g_eaState = 0; // WAITING state
    g_lastTradeTime = 0;
    g_lastBarTime = 0;
    g_tradesThisBar = 0;
    g_daily_trades = 0;
    g_lastDayReset = TimeCurrent();

    Print("=== SONIC R MC EA - INITIALIZATION COMPLETE ===");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| EXPERT DEINITIALIZATION FUNCTION                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("=== SONIC R MC EA - DEINITIALIZING... ===");

    // Timer lifecycle
    EventKillTimer();

    // Cleanup components
    CleanupTradeGate();
    if(g_coreEngine != NULL) {
        delete g_coreEngine;
        g_coreEngine = NULL;
    }

    Print("=== SONIC R MC EA - DEINITIALIZATION COMPLETE ===");
}

// Gateway to session/news filters using TimeManager
bool IsMarketOpen(){
    static CTimeManager tm;
    static bool inited=false;
    if(!inited){ tm.Initialize(); inited=true; }
    tm.OnTick();
    return tm.IsTradeAllowed();
}

//+------------------------------------------------------------------+
//| EXPERT TICK FUNCTION                                            |
//+------------------------------------------------------------------+
void OnTick() {
    // Check if system is initialized
    if(!g_system_initialized) {
        return;
    }

    // Check if we should process this tick
    if(!ShouldProcessTick()) {
        return;
    }

    // Process core engine
    if(g_coreEngine != NULL) {
        g_coreEngine->OnTick();
    }

    // Generate and process basic SonicR signal (lightweight)
    ENUM_SIGNAL_TYPE sig = GetSignal_SonicR_Basic();
    ProcessSignal(sig);
}

//+------------------------------------------------------------------+
//| HELPER FUNCTIONS                                                 |
//+------------------------------------------------------------------+
bool ShouldProcessTick() {
    // Check if market is open via TimeManager gateway
    if(!IsMarketOpen()) {
        return false;
    }

    // Check if we're in cooldown
    if(g_eaState == 1) { // COOLDOWN state
        if(TimeCurrent() - g_lastTradeTime > 300) { // 5 minutes cooldown
            g_eaState = 0; // WAITING state
        } else {
            return false;
        }
    }

    return true;
}

void ProcessSignal(ENUM_SIGNAL_TYPE signal) {
    if(signal == SIGNAL_NONE) {
        return;
    }

    // Check if we can trade
    if(!CanTrade()) {
        if(g_tradeGate != NULL) {
            Print("[TradeGate] Rejected: ", g_tradeGate->GetLastRejectionReason());
        }
        return;
    }

    // Execute trade using Core Engine's TradeExecution namespace
    bool sent = false;
    if(signal == SIGNAL_BUY) {
        Print("[SIGNAL] Buy signal received -> executing...");
        sent = TradeExecution::ExecuteBuyOrder();
    } else if(signal == SIGNAL_SELL) {
        Print("[SIGNAL] Sell signal received -> executing...");
        sent = TradeExecution::ExecuteSellOrder();
    }

    // Update cooldown and counters only on successful placement/execution
    if(sent) {
        g_lastTradeTime = TimeCurrent();
        g_eaState = 1; // COOLDOWN state
        // Counters are updated inside execution routines upon success
    } else {
        // If rejected by TradeGate, reason already printed above; otherwise, keep waiting state
        if(g_tradeGate != NULL && g_tradeGate->GetLastRejectionReason() != "")
            Print("[TRADE] Execution failed: ", g_tradeGate->GetLastRejectionReason());
    }
}

bool CanTrade() {
    // Check daily trade limit
    if(g_daily_trades >= InpMaxDailyTrades) { // Configurable daily limit
        return false;
    }

    // Check trades per bar limit
    if(g_tradesThisBar >= 2) { // Max 2 trades per bar
        return false;
    }

    // Check TradeGate risk/limits if available
    if(g_tradeGate != NULL) {
        if(!g_tradeGate->IsTradingAllowed()) {
            return false;
        }
    }

    // Session & spread gate (align with Sonic basic gate)
    if(!Gate_SonicBasic_SessionSpread()) {
        return false;
    }

    // Check if we have enough balance
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    if(balance < 1000) { // Minimum balance requirement
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| TIMER FUNCTION                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
    // Reset daily trades counter
    datetime currentTime = TimeCurrent();
    if(currentTime - g_lastDayReset > 86400) { // 24 hours
        g_daily_trades = 0;
        g_lastDayReset = currentTime;
    }

    // Reset trades per bar counter using new-bar detection
    datetime barTime = iTime(_Symbol, _Period, 0);
    if(barTime != 0 && barTime != g_lastBarTime) {
        g_tradesThisBar = 0;
        g_lastBarTime = barTime;
    }
}
