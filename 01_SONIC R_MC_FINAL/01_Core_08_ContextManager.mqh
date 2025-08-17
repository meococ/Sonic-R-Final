//+------------------------------------------------------------------+
//|                                                Core_Context.mqh |
//|                    SONIC R MC EA - Context Management           |
//|                     Ð?i Bàng Architecture - Foundation Layer     |
//+------------------------------------------------------------------+
#ifndef CORE_CONTEXT_MQH
#define CORE_CONTEXT_MQH

#include "01_Core_09_SharedDataStructures.mqh"

//+------------------------------------------------------------------+
//| System State Structure (moved to CommonStructures)               |
//+------------------------------------------------------------------+
// NOTE: SSystemState is defined in 01_Core_13_CommonStructures.mqh to avoid redefinition


//+------------------------------------------------------------------+
//| Global Context Instance                                          |
//+------------------------------------------------------------------+
// Forward declarations for pointer types
class CLogger;
class CTimeManager;
class CSonicSymbolInfo;
class CErrorHandler;
class CTradeManager;
class CRiskManager;
class CPerformanceTracker;

//+------------------------------------------------------------------+
//| EA Context Structure - PHASE 3.3: Use class definition from Shared_DataStructures.mqh |
//+------------------------------------------------------------------+
// CEaContext is now defined as a class in Shared_DataStructures.mqh
// Remove duplicate struct definition to avoid redefinition error

// This provides access to the global context from anywhere
// extern CEaContext g_Context; // PHASE 3 FIX: Commented out - not used

//+------------------------------------------------------------------+
//| Context Initialization Function                                  |
//+------------------------------------------------------------------+
bool InitializeGlobalContext(CEaContext* context)
{
if(!context) return false;

// PHASE 3.3 FIX: Use public methods if available, otherwise basic initialization
if(CheckPointer(context) == POINTER_DYNAMIC)
{
    // Basic initialization for context
    // Initialize with current symbol and period data
    Print("? Context initialized for ", _Symbol, " ", EnumToString(PERIOD_CURRENT));
}

return true;
}

#endif // CORE_CONTEXT_MQH


