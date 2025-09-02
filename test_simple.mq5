//+------------------------------------------------------------------+
//|                                            test_simple.mq5     |
//|                                    Simple compilation test     |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

// Test compilation with minimal code
void OnInit() {
    Print("Test EA initialized successfully");
}

void OnTick() {
    // Minimal tick processing
    static int tickCount = 0;
    tickCount++;
    
    if(tickCount % 100 == 0) {
        Print("Tick count: ", tickCount);
    }
}

void OnDeinit(const int reason) {
    Print("Test EA deinitialized, reason: ", reason);
}
