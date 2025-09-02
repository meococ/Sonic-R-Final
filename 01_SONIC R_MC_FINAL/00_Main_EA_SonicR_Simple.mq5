//+------------------------------------------------------------------+
//|                                      00_Main_EA_SonicR_Simple.mq5 |
//|                                    SONIC R MC - MINIMAL VERSION  |
//|                                  For compilation testing          |
//+------------------------------------------------------------------+
#property copyright "SONIC R MC"
#property link      ""
#property version   "1.00"
#property strict

// Minimal includes only
#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_00_Inputs.mqh"

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                |
//+------------------------------------------------------------------+
int g_magicNumber = 12345;
bool g_system_initialized = false;

//+------------------------------------------------------------------+
//| EXPERT INITIALIZATION FUNCTION                                  |
//+------------------------------------------------------------------+
int OnInit() {
    Print("=== SONIC R MC EA - SIMPLE VERSION INITIALIZING... ===");
    g_system_initialized = true;
    Print("=== SONIC R MC EA - INITIALIZATION COMPLETE ===");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| EXPERT DEINITIALIZATION FUNCTION                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("=== SONIC R MC EA - DEINITIALIZING... ===");
    g_system_initialized = false;
    Print("=== SONIC R MC EA - DEINITIALIZATION COMPLETE ===");
}

//+------------------------------------------------------------------+
//| EXPERT TICK FUNCTION                                            |
//+------------------------------------------------------------------+
void OnTick() {
    if(!g_system_initialized) {
        return;
    }
    
    // Simple tick processing
    static int tickCount = 0;
    tickCount++;
    
    if(tickCount % 1000 == 0) {
        Print("[SONIC-SIMPLE] Processed ", tickCount, " ticks");
    }
}

//+------------------------------------------------------------------+
//| TIMER FUNCTION                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
    // Timer processing
}
