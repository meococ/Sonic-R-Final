//+------------------------------------------------------------------+
//|                                      00_Test_SonicEnums.mq5    |
//|                                    TEST SONIC ENUMS             |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

#include "01_SONIC R_MC_FINAL\01_Core_22_SonicEnums.mqh"

int OnInit() {
    Print("Sonic Enums test initialized");
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    Print("Sonic Enums test deinitialized");
}

void OnTick() {
    // Test usage
}
