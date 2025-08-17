//+------------------------------------------------------------------+
//|                                      00_Main_EA_SonicR.mq5     |
//|                                    SONIC R MC - SIMPLIFIED     |
//|                                  Simplified version for testing |
//+------------------------------------------------------------------+
#property copyright "SONIC R MC"
#property link      ""
#property version   "1.00"
#property strict

// SYSTEMATIC FIX - Input declarations MUST come before includes in MQL5
input string    InpPropFirmPreset = "FTMO";      // Prop firm preset: FTMO | MFF | PROP_X
// InpDebugMode is already defined in 01_Core_00_Inputs.mqh - avoid duplicate

// Unified master include controls all dependencies and feature flags
#include "00_Main_MasterIncludes.mqh"

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES - PERFORMANCE OPTIMIZED                        |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - MQL5 global variables cannot be initialized with assignment
// Runtime trade timestamps for cooldown
datetime g_lastTradeTime;
datetime g_lastTradeBarOpen;

// Essential EA Context only
CEaContext* g_eaContext;

// Performance optimized components
CConsolidatedSignals* g_signalEngine;
CTradeGate* g_tradeGate;

// Trading state
int g_daily_trades;
datetime g_last_trade_date;
bool g_system_initialized;

// System State (simplified)
bool g_trading_allowed;
bool g_emergency_mode;
datetime g_last_analysis_time;

//+------------------------------------------------------------------+
//| EXPERT INITIALIZATION FUNCTION - SIMPLIFIED                     |
//+------------------------------------------------------------------+
int OnInit() {
    Print("=== SONIC R MC EA - SIMPLIFIED DEBUG VERSION ===");
    Print("[INIT] Starting simplified initialization...");

    // SYSTEMATIC FIX - Initialize global variables
    g_lastTradeTime = 0;
    g_lastTradeBarOpen = 0;
    g_daily_trades = 0;
    g_last_trade_date = 0;
    g_system_initialized = false;
    g_trading_allowed = true;
    g_emergency_mode = false;
    g_last_analysis_time = 0;

    // Basic validation first
    Print("[INIT] Basic validation...");
    if(iBars(_Symbol, PERIOD_CURRENT) < 10) {
        Print("❌ [INIT] Insufficient bars: ", iBars(_Symbol, PERIOD_CURRENT));
        return INIT_FAILED;
    }
    Print("✅ [INIT] Basic validation passed");

    // Test input parameters
    Print("[INIT] Testing input parameters...");
    Print("InpRiskPercent: ", InpRiskPercent);
    Print("InpDebugMode: ", InpDebugMode);
    Print("✅ [INIT] Input parameters OK");

    // 🎯 STEP 1: Initialize EA Context
    Print("[INIT] Step 1: Initializing EA Context...");
    g_eaContext = new CEaContext();
    if(!g_eaContext) {
        Print("❌ [INIT] Failed to create EA Context object");
        return INIT_FAILED;
    }
    if(!g_eaContext.Initialize(_Symbol, PERIOD_CURRENT)) {
        Print("❌ [INIT] Failed to initialize EA Context");
        delete g_eaContext;
        g_eaContext = NULL;
        return INIT_FAILED;
    }
    Print("✅ [INIT] EA Context initialized successfully");

    // 🎯 STEP 2: Initialize Performance Optimized Indicator Manager
    Print("[INIT] Step 2: Initializing Indicator Manager...");
    if(!InitializeIndicatorManager(_Symbol, PERIOD_CURRENT)) {
        Print("❌ [INIT] Failed to initialize Indicator Manager");
        return INIT_FAILED;
    }
    Print("✅ [INIT] Indicator Manager initialized successfully");

    // 🎯 STEP 3: Initialize Signal Engine
    Print("[INIT] Step 3: Initializing Signal Engine...");
    g_signalEngine = new CConsolidatedSignals();
    if(!g_signalEngine) {
        Print("❌ [INIT] Failed to create Signal Engine");
        return INIT_FAILED;
    }
    Print("✅ [INIT] Signal Engine initialized successfully");

    // 🎯 STEP 4: Initialize Scenario Profiles
    Print("[INIT] Step 4: Initializing Scenario Profiles...");
    if(!InitializeScenarioProfiles()) {
        Print("❌ [INIT] Failed to initialize Scenario Profiles");
        return INIT_FAILED;
    }

    // Apply current scenario profile
    ScenarioProfile currentProfile = GetCurrentScenarioProfile();
    Print("✅ [INIT] Scenario Profile loaded: ", currentProfile.name);

    // 🎯 STEP 5: Initialize Advanced Logger
    Print("[INIT] Step 5: Initializing Advanced Logger...");
    if(!InitializeAdvancedLogger(currentProfile.name)) {
        Print("❌ [INIT] Failed to initialize Advanced Logger");
        return INIT_FAILED;
    }
    Print("✅ [INIT] Advanced Logger initialized successfully");

    // 🎯 STEP 6: Initialize Trade Gate
    Print("[INIT] Step 6: Initializing Trade Gate...");
    g_tradeGate = new CTradeGate();
    if(!g_tradeGate) {
        Print("❌ [INIT] Failed to create Trade Gate");
        return INIT_FAILED;
    }

    // Configure Trade Gate from scenario profile
    TradeGateConfig gateConfig;
    gateConfig.enablePropRules = (InpPropFirmPreset != "");
    gateConfig.propPreset = InpPropFirmPreset;
    gateConfig.maxSpreadPips = currentProfile.maxSpreadPips;
    gateConfig.maxTradesPerDay = (int)currentProfile.maxDailyTrades;
    gateConfig.maxDailyDDPct = currentProfile.maxDailyDrawdown;
    g_tradeGate.Configure(gateConfig);
    Print("✅ [INIT] Trade Gate configured with scenario profile");

    Print("✅ [INIT] ENHANCED EA WITH SCENARIO PROFILES initialized successfully");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| EXPERT DEINITIALIZATION FUNCTION - PERFORMANCE OPTIMIZED       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("=== SONIC R MC EA - PERFORMANCE OPTIMIZED DEINITIALIZATION ===");
    Print("Deinit reason: ", reason);

    // Cleanup Signal Engine
    if(g_signalEngine) {
        delete g_signalEngine;
        g_signalEngine = NULL;
        Print("✅ Signal Engine cleaned up");
    }

    // Cleanup Trade Gate
    if(g_tradeGate) {
        delete g_tradeGate;
        g_tradeGate = NULL;
        Print("✅ Trade Gate cleaned up");
    }

    // Cleanup Scenario Profiles
    DeinitializeScenarioProfiles();
    Print("✅ Scenario Profiles cleaned up");

    // Cleanup Advanced Logger (generates final report)
    DeinitializeAdvancedLogger();
    Print("✅ Advanced Logger cleaned up and report generated");

    // Cleanup Indicator Manager (releases all handles)
    DeinitializeIndicatorManager();
    Print("✅ Indicator Manager cleaned up");

    // Cleanup EA Context
    if(g_eaContext) {
        delete g_eaContext;
        g_eaContext = NULL;
        Print("✅ EA Context cleaned up");
    }
}

//+------------------------------------------------------------------+
//| EXPERT TICK FUNCTION - UNIFIED SIGNAL GATEWAY                   |
//+------------------------------------------------------------------+
void OnTick() {
	// Performance optimized tick processing with unified signal gateway
	static int tickCount = 0;
	static datetime lastSignalTime = 0;
	tickCount++;

	// Basic status monitoring
	if(tickCount % 1000 == 0) {
		Print("[UNIFIED TICK] #", tickCount, " - Signal Engine: ",
				(g_signalEngine ? "OK" : "NULL"), " Trade Gate: ", (g_tradeGate ? "OK" : "NULL"));
	}

	// Only process signals on new bars or significant price changes
	datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
	if(currentBarTime <= lastSignalTime) {
		return; // Skip this tick
	}

	// 🎯 UNIFIED SIGNAL GATEWAY - SINGLE DECISION POINT
	if(g_signalEngine && g_tradeGate) {
		// Map strategy -> scenario per spec for Generate()
		ENUM_TRADING_SCENARIO scenario = MapStrategyToScenario(InpTradingStrategy);

		// Generate signal through unified gateway (use a variable, not assignment from temporary)
		TradingSignal signal;
		signal = g_signalEngine.Generate(_Symbol, PERIOD_CURRENT, scenario);

		if(signal.type != SIGNAL_NONE) {
			// SYSTEMATIC FIX - CRITICAL MISSING LOGIC: Confidence threshold check
			// This is the core logic Boss mentioned - filter weak signals
			if(signal.confidence < InpConfluenceThreshold) {
				if(g_advancedLogger) {
					g_advancedLogger.Log(LOG_DEBUG, StringFormat("Signal REJECTED - Low confidence: %.3f < %.3f",
																 signal.confidence, InpConfluenceThreshold));
				}
				Print("[SIGNAL FILTER] Rejected: Confidence ", DoubleToString(signal.confidence, 3),
					  " < Threshold ", DoubleToString(InpConfluenceThreshold, 3));
				return; // Exit early - signal filtered out
			}

			// Log signal generation (only for signals that pass confidence filter)
			if(g_advancedLogger) {
				g_advancedLogger.Log(LOG_INFO, StringFormat("Signal ACCEPTED: %s Confidence: %.3f Reason: %s",
															 SignalTypeToString(signal.type), signal.confidence, signal.reason));
			}

			Print("[SIGNAL] Accepted: ", SignalTypeToString(signal.type),
				  " Confidence: ", DoubleToString(signal.confidence, 3),
				  " Reason: ", signal.reason);

			// Gate check BEFORE execution
			bool tradingAllowed = g_tradeGate.IsTradingAllowed();
			if(tradingAllowed) {
				// Execute trade
				ExecuteSignal(signal);

				// Register executed trade with gate
				g_tradeGate.OnPositionOpen();
				lastSignalTime = currentBarTime;
			} else {
				if(g_advancedLogger) {
					g_advancedLogger.Log(LOG_WARNING, "Trade blocked by gate");
				}
				Print("[GATE BLOCK] Trading not allowed");
			}
		}
	}
}

//+------------------------------------------------------------------+
//| Execute Signal with Risk Management                              |
//+------------------------------------------------------------------+
void ExecuteSignal(TradingSignal &signal)
{
    // Calculate position size based on risk
    double riskAmount = AccountInfoDouble(ACCOUNT_BALANCE) * InpRiskPercent / 100.0;
    double slDistance = MathAbs(signal.sl - ((signal.side == ORDER_TYPE_BUY) ?
                                           SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                                           SymbolInfoDouble(_Symbol, SYMBOL_BID)));

    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

    double lotSize = 0.01; // Default minimum
    if(tickValue > 0 && tickSize > 0 && slDistance > 0) {
        lotSize = riskAmount / (slDistance * (tickValue / tickSize));

        // Normalize lot size
        double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

        lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
        if(lotStep > 0) {
            lotSize = MathRound(lotSize / lotStep) * lotStep;
        }

        // Round according to lot step
        int digitsLot = 2;
        if(lotStep >= 1.0) {
            digitsLot = 0;
        } else if(lotStep > 0.0) {
            double p = MathLog10(lotStep);
            if(p < 0) digitsLot = (int)MathRound(-p);
        }
        lotSize = NormalizeDouble(lotSize, digitsLot);
    }

    // Log trade operation
    if(g_advancedLogger) {
        string operation = (signal.side == ORDER_TYPE_BUY) ? "BUY" : "SELL";
        double currentPrice = (signal.side == ORDER_TYPE_BUY) ?
                             SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                             SymbolInfoDouble(_Symbol, SYMBOL_BID);

        LogTradeOperation(operation, currentPrice, lotSize,
                         signal.sl, signal.tp, signal.reason,
                         signal.type);
    }

    // Execute trade
    CTrade trade;
    bool result = false;

    if(signal.side == ORDER_TYPE_BUY) {
        result = trade.Buy(lotSize, _Symbol, 0, signal.sl, signal.tp,
                          StringFormat("Sonic R %s", signal.reason));
    } else {
        result = trade.Sell(lotSize, _Symbol, 0, signal.sl, signal.tp,
                           StringFormat("Sonic R %s", signal.reason));
    }

    if(result) {
        g_daily_trades++;

        // Log successful trade
        if(g_advancedLogger) {
            g_advancedLogger.Log(LOG_INFO, StringFormat("Trade executed successfully: %s Lot: %.2f Confidence: %.3f",
                                (signal.side == ORDER_TYPE_BUY ? "BUY" : "SELL"),
                                lotSize, signal.confidence));
        }

        Print("✅ Trade executed - ", (signal.side == ORDER_TYPE_BUY ? "BUY" : "SELL"),
              " Lot: ", DoubleToString(lotSize, 2),
              " SL: ", DoubleToString(signal.sl, 5),
              " TP: ", DoubleToString(signal.tp, 5),
              " Confidence: ", DoubleToString(signal.confidence, 3));
    } else {
        // Log failed trade
        if(g_advancedLogger) {
            g_advancedLogger.Log(LOG_ERROR, StringFormat("Trade execution failed: Error %d", GetLastError()));
        }

        Print("❌ Trade execution failed - Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Trade Event Handlers for KPI Tracking                           |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                       const MqlTradeRequest& request,
                       const MqlTradeResult& result)
{
    // Track trade results for KPI calculation
    if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
        // Get deal information
        if(HistoryDealSelect(trans.deal)) {
            double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
            double volume = HistoryDealGetDouble(trans.deal, DEAL_VOLUME);
            string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
            string comment = HistoryDealGetString(trans.deal, DEAL_COMMENT);

            // Only track our EA's trades
            if(StringFind(comment, "Sonic R") >= 0 && symbol == _Symbol) {
                bool isWin = (profit > 0);

                // Extract confidence from comment if available
                double confidence = 0.5; // Default confidence
                // TODO: Parse confidence from comment if stored

                // Extract signal type from comment
                string signalType = "UNKNOWN";
                if(StringFind(comment, "BUY") >= 0) signalType = "BUY_SIGNAL";
                if(StringFind(comment, "SELL") >= 0) signalType = "SELL_SIGNAL";

                // Log trade result for KPI tracking
                if(g_advancedLogger) {
                    LogTradeResult(profit, volume, _Symbol, (isWin ? "WIN" : "LOSS"));
                }

                Print("[TRADE RESULT] P/L: ", DoubleToString(profit, 2),
                      " Win: ", (isWin ? "YES" : "NO"),
                      " Volume: ", DoubleToString(volume, 2));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Timer Event for Periodic KPI Updates                            |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Generate periodic KPI updates during backtesting
    static datetime lastKPIUpdate = 0;
    datetime currentTime = TimeCurrent();

    // Update KPI every hour during backtesting
    if(currentTime - lastKPIUpdate >= 3600) {
        if(g_advancedLogger) {
            // This will update internal metrics and log current status
            string status = StringFormat("Periodic KPI Update - Balance: %.2f Equity: %.2f",
                                       AccountInfoDouble(ACCOUNT_BALANCE),
                                       AccountInfoDouble(ACCOUNT_EQUITY));
            g_advancedLogger.Log(LOG_INFO, status);
        }
        lastKPIUpdate = currentTime;
    }
}

//+------------------------------------------------------------------+
//| END OF ENHANCED EA WITH KPI TRACKING                            |
//+------------------------------------------------------------------+
