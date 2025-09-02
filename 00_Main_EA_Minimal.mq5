//+------------------------------------------------------------------+
//|                                      00_Main_EA_Minimal.mq5    |
//|                                    MINIMAL TEST EA              |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

//+------------------------------------------------------------------+
//| EXPERT INITIALIZATION FUNCTION                                  |
//+------------------------------------------------------------------+
int OnInit() {
    Print("Minimal EA initialized successfully");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| EXPERT DEINITIALIZATION FUNCTION                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Print("Minimal EA deinitialized, reason: ", reason);
}

//+------------------------------------------------------------------+
//| EXPERT TICK FUNCTION                                            |
//+------------------------------------------------------------------+
void OnTick() {
    static int tickCount = 0;
    tickCount++;
    
    if(tickCount % 100 == 0) {
        Print("Tick count: ", tickCount);
    }
}
