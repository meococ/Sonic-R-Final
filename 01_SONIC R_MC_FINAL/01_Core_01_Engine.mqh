//+------------------------------------------------------------------+
//|                             01_Core_01_Engine.mqh                |
//|                    SONIC R MC EA - Core Engine                   |
//|                     Ð?i Bàng Architecture - Foundation Layer     |
//+------------------------------------------------------------------+
#ifndef CORE_01_ENGINE_MQH
#define CORE_01_ENGINE_MQH

#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_03_Logger.mqh"
#include "04_SignalGeneration_01_ConsolidatedSignals.mqh"

// Forward declaration for cross-unit function - COMMENTED OUT TO AVOID WARNINGS
// bool IsSystemReady();

// TACTICAL FIX: Define POINTER_VALID constant directly
#ifndef POINTER_VALID
#define POINTER_VALID 1
#endif

//+------------------------------------------------------------------+
//| CCore Class - Main EA Engine                                    |
//| Manages EA lifecycle and core services                          |
//+------------------------------------------------------------------+
class IAnalysisEngine;  // Forward declaration
class CCore
{
private:
CEaContext*         m_pContext;     // Main EA context
bool                m_initialized;  // Initialization flag
// Replace direct deps with interfaces
IAnalysisEngine* m_analysis;  // Loose coupling

public:
CCore();
~CCore();

// Core lifecycle methods
bool                Initialize(CEaContext* context);
void                Deinitialize();
void                OnTick();
void                OnTimer();
void                OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

// Utility methods
bool                IsInitialized() const { return m_initialized; }
CEaContext*         GetContext() { return m_pContext; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCore::CCore()
{
m_pContext = NULL;
m_initialized = false;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCore::~CCore()
{
Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize - Setup core services                                |
//+------------------------------------------------------------------+
bool CCore::Initialize(CEaContext* context)
{
if (m_initialized) return true;
if (context == NULL) return false;

m_pContext = context;

// TACTICAL FIX: Simplified initialization without logger dependency
if (CheckPointer(m_pContext) == POINTER_DYNAMIC)
{
    Print("? Core Engine: Context initialized successfully");
}

// Set initialization flag
m_initialized = true;
// Note: Context initialization is handled by CEaContext class

// Log initialization success
Print("? Core Engine: Initialized successfully");

return true;
}

//+------------------------------------------------------------------+
//| Deinitialize - Cleanup core services                            |
//+------------------------------------------------------------------+
void CCore::Deinitialize()
{
if (!m_initialized) return;

if (CheckPointer(m_pContext) == POINTER_DYNAMIC)
{
    Print("? Core Engine: Shutting down...");
}

// Reset flags
m_initialized = false;
// Note: Context cleanup is handled by CEaContext class

// Note: Individual service cleanup is handled by main EA
m_pContext = NULL;

Print("Core engine deinitialized");
}

//+------------------------------------------------------------------+
//| OnTick - Main tick processing                                   |
//+------------------------------------------------------------------+
void CCore::OnTick()
{
if (!m_initialized || CheckPointer(m_pContext) != POINTER_DYNAMIC) return;

// Update last tick time (handled by CEaContext class internally)

// New-bar gating (optional)
static datetime s_lastBarTime = 0;
MqlRates rates[]; int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates);
if(copied>=2){
datetime curBarTime = rates[0].time;
bool isNewBar = (curBarTime != s_lastBarTime);
if(!InpUseNewBarMode || isNewBar){
s_lastBarTime = curBarTime;

// Pre-flight: basic readiness
if(!IsSystemReady()) return;

// Unified signal decision via ConsolidatedSignals scenario APIs
// Avoid setting doBuy/doSell here; delegate decision to scenario functions

// Forward declarations are at global scope via MasterIncludes

ENUM_SIGNAL_TYPE sig = SIGNAL_NONE;
switch(InpTradingStrategy){
  case STRATEGY_SONIC_R:
    { SignalDecision sd; if(GetSignal_SonicR_Basic(sd, _Symbol, PERIOD_CURRENT)) { sig = sd.signalType; } else { sig = SIGNAL_NONE; } }
    break;
  case STRATEGY_SONIC_R_WITH_VPSRA:
  case STRATEGY_SCALING_WINNERS:
    { SignalDecision sd2; if(GetSignal_SonicR_VPSRA(sd2, _Symbol, PERIOD_CURRENT)) { sig = sd2.signalType; } else { sig = SIGNAL_NONE; } }
    break;
  case STRATEGY_SCOUT_RANGE:
  case STRATEGY_MULTI_ASSET:
  default:
    // Default to Sonic + PVSRA confirmation for safer entries
    { SignalDecision sd3; if(GetSignal_SonicR_VPSRA(sd3, _Symbol, PERIOD_CURRENT)) { sig = sd3.signalType; } else { sig = SIGNAL_NONE; } }
    break;
}

// Gate check (full gate also runs inside Execute*Advanced)
bool gateResult = g_tradeGate_CheckAll();
if(!gateResult){
    // Use simplified logging
    Print("[GATE BLOCK] Trade gate check failed");
    return;
}

// Execute based on unified decision
if(sig == SIGNAL_BUY){ ExecuteBuySignalAdvanced(0.75); }
if(sig == SIGNAL_SELL){ ExecuteSellSignalAdvanced(0.75); }
}
}
// UI update is handled by main OnTick
}

//+------------------------------------------------------------------+
//| OnTimer - Timer event processing                                |
//+------------------------------------------------------------------+
void CCore::OnTimer()
{
if (!m_initialized || m_pContext == NULL) return;

// Timer-based processing
// - UI updates
// - Periodic checks
// - Performance monitoring
}

//+------------------------------------------------------------------+
//| OnChartEvent - Chart event processing                           |
//+------------------------------------------------------------------+
void CCore::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
if (!m_initialized || m_pContext == NULL) return;

// Handle chart events
// - User interactions
// - Object clicks
// - Key presses
}

#endif // CORE_CORE_MQH


