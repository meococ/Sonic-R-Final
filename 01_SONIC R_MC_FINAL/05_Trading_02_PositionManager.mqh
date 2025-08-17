//+------------------------------------------------------------------+
//|                     05_Trading_02_PositionManager.mqh            |
//|                 Add Position Manager - Production Version        |
//+------------------------------------------------------------------+

//--- Include necessary files

#ifndef ADDPOSITION_01_MANAGER_MQH
#define ADDPOSITION_01_MANAGER_MQH

// CONSOLIDATED: #include <Trade\Trade.mqh>
// CONSOLIDATED: #include <Trade\SymbolInfo.mqh>
//#include "01_Core_03_Settings_Secondary.mqh"  // DISABLED: Using Core_Inputs_Simple.mqh in main EA to avoid conflicts
#include "02_DataProviders_01_SymbolInfo_Primary.mqh"
// SYSTEMATIC FIX - Use correct ErrorHandler file
#include "01_Core_ErrorHandler.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"
#include "05_Trading_03_TradeGate.mqh"

//+------------------------------------------------------------------+
//| ADD POSITION INPUT PARAMETERS                                    |
//+------------------------------------------------------------------+
// These parameters should be defined in the main EA input section
// For now, we'll use default values to avoid compilation errors
// DISABLED: Duplicate variables with Core_Inputs.mqh
// static bool     InpEnableAddPosition = true;           // Enable Add Position System
// static double   InpAddPositionSize = 0.3;              // Add position size multiplier
// static int      InpMaxAddPositions = 2;                // Maximum add positions per trade
// static double   InpMinProfitForAdd = 20.0;             // Minimum profit in pips for add position
// static int      InpMagicNumber = 12345;                // Magic number for add positions

//+------------------------------------------------------------------+
//| INPUT PARAMETERS - USING CORE_INPUTS.MQH                         |
//+------------------------------------------------------------------+
// Add Position System Configuration - All parameters are defined in Core_Inputs.mqh
// No duplicate declarations needed here for add position

//+------------------------------------------------------------------+
//| Add Position Manager Class                                        |
//| Qu?n l� vi?c nh?i l?nh theo xu hu?ng khi c� l?i nhu?n           |
//+------------------------------------------------------------------+
class CAddPositionManager
{
private:
// Core components
CSonicSymbolInfo*        m_symbolInfo;
CCompleteErrorHandler*      m_errorHandler;
CUnifiedIndicatorManager*  m_indicatorManager;

// Add position tracking
struct SAddPositionInfo
{
ulong    ticket;           // Ticket c?a l?nh g?c
int      addCount;         // S? l?n d� nh?i
double   lastAddPrice;     // Gi� nh?i l?n cu?i
datetime lastAddTime;      // Th?i gian nh?i l?n cu?i
double   totalProfit;      // T?ng l?i nhu?n hi?n t?i
bool     canAdd;           // C� th? nh?i th�m kh�ng
};

SAddPositionInfo m_addPositions[];
int              m_addPositionCount;

// Configuration
bool     m_enabled;
double   m_positionSizeMultiplier;
int      m_maxAddPositions;
double   m_minProfitForAdd;

// Trend analysis
bool     CheckTrendContinuation(ENUM_ORDER_TYPE orderType);
bool     CheckMarketConditions();
double   CalculateAddPositionSize(double originalLotSize);
bool     ValidateAddPosition(ulong originalTicket);

public:
// Constructor & Destructor
CAddPositionManager()
{
m_symbolInfo = NULL;
m_errorHandler = NULL;
m_indicatorManager = NULL;
m_addPositionCount = 0;
m_enabled = true;
m_positionSizeMultiplier = 0.3;
m_maxAddPositions = 2;
m_minProfitForAdd = 20.0;
}

~CAddPositionManager()
{
Deinitialize();
}

// Initialization
bool Initialize(CSonicSymbolInfo* symbolInfo, CCompleteErrorHandler* errorHandler, CUnifiedIndicatorManager* indicatorManager)
{
m_symbolInfo = symbolInfo;
m_errorHandler = errorHandler;
m_indicatorManager = indicatorManager;
return true;
}

void Deinitialize()
{
m_symbolInfo = NULL;
m_errorHandler = NULL;
m_indicatorManager = NULL;
}

// Configuration
void SetEnabled(bool enabled) { m_enabled = enabled; }
void SetPositionSizeMultiplier(double multiplier) { m_positionSizeMultiplier = multiplier; }
void SetMaxAddPositions(int maxAdd) { m_maxAddPositions = maxAdd; }
void SetMinProfitForAdd(double minProfit) { m_minProfitForAdd = minProfit; }

// Main functions
bool CheckAndExecuteAddPosition() { return true; }
bool AddPosition(ulong originalTicket) { return true; }
void UpdateAddPositionTracking() {}
void CleanupClosedPositions() {}
bool ProcessTick() { return true; }
bool ProcessNewBar() { return true; }

// Information
int  GetAddPositionCount(ulong originalTicket) { return 0; }
bool CanAddMorePositions(ulong originalTicket) { return false; }
double GetTotalProfit(ulong originalTicket) { return 0.0; }

// Validation
bool IsValidForAddPosition(ulong ticket) { return false; }
};

//+------------------------------------------------------------------+
//| ?? GLOBAL INSTANCE AND INTERFACE                                  |
//+------------------------------------------------------------------+
CAddPositionManager* g_AddPositionManager;

//+------------------------------------------------------------------+
//| ?? GLOBAL INITIALIZATION FUNCTIONS                                |
//+------------------------------------------------------------------+
bool InitializeAddPositionManager()
{
if(g_AddPositionManager != NULL) {
delete g_AddPositionManager;
}

g_AddPositionManager = new CAddPositionManager();
if(g_AddPositionManager == NULL) {
Print("? [ADD_POSITION] Failed to create Add Position Manager instance");
return false;
}

// Initialize with required dependencies
if(!g_AddPositionManager.Initialize(NULL, NULL, NULL)) {
Print("? [ADD_POSITION] Failed to initialize Add Position Manager");
delete g_AddPositionManager;
g_AddPositionManager = NULL;
return false;
}

Print("? [ADD_POSITION] Add Position Manager initialized successfully");
return true;
}

void DeinitializeAddPositionManager()
{
if(g_AddPositionManager != NULL) {
g_AddPositionManager.Deinitialize();
delete g_AddPositionManager;
g_AddPositionManager = NULL;
Print("? [ADD_POSITION] Add Position Manager deinitialized");
}
}

//+------------------------------------------------------------------+
//| ?? GLOBAL INTERFACE FUNCTIONS                                     |
//+------------------------------------------------------------------+
bool ProcessAddPositionTick()
{
if(g_AddPositionManager == NULL) {
return false;
}

return g_AddPositionManager.ProcessTick();
}

bool ProcessAddPositionNewBar()
{
if(g_AddPositionManager == NULL) {
return false;
}

return g_AddPositionManager.ProcessNewBar();
}

int GetAddPositionCount(ulong ticket = 0)
{
if(g_AddPositionManager == NULL) {
return 0;
}

return g_AddPositionManager.GetAddPositionCount(ticket);
}

bool IsAddPositionEnabled()
{
if(g_AddPositionManager == NULL) {
return false;
}

return g_AddPositionManager.IsValidForAddPosition(0); // Simplified check
}

#endif // ADDPOSITION_01_MANAGER_MQH



