//+------------------------------------------------------------------+
//|                                      00_Test_Inputs.mq5        |
//|                                    TEST INPUTS                  |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

#include "01_SONIC R_MC_FINAL\01_Core_14_CoreEnums.mqh"
#include "01_SONIC R_MC_FINAL\01_Core_00_Inputs.mqh"

int OnInit() {
    Print("Inputs test initialized");
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    Print("Inputs test deinitialized");
}

void OnTick() {
    // Test usage
}
