# MQL5 Modern Standards & Best Practices (2025)
**Version**: 2.0  
**Target**: MQL5 Build 4170+ (MetaTrader 5)  
**Updated**: 2025-08-15  

---

## 1. Language Evolution & Modern Features

### 1.1 MQL5 vs MQL4 Key Differences
**Object-Oriented Programming**:
- **Classes & Inheritance**: Full OOP support with constructors, destructors, virtual functions
- **Access Modifiers**: private, protected, public for proper encapsulation
- **Polymorphism**: Virtual functions and method overriding

**Memory Management**:
- **Dynamic Arrays**: Automatic memory management, no manual allocation
- **Object Lifecycle**: Automatic constructor/destructor calls
- **Garbage Collection**: Automatic cleanup of unused objects

**Multi-Asset & Multi-Timeframe**:
- **Symbol Management**: Work with multiple symbols simultaneously
- **Timeframe Independence**: Access any timeframe data from any chart
- **Event-Driven**: OnTick, OnTimer, OnTrade, OnBookEvent handlers

### 1.2 Modern MQL5 Features (Build 4170+)
```cpp
// Enhanced string operations
string text = "EURUSD";
text += " M15";  // String concatenation
bool contains = StringFind(text, "USD") >= 0;

// Improved array operations
double prices[];
ArrayResize(prices, 100);
ArraySetAsSeries(prices, true);  // Time series indexing
ArrayFill(prices, 0, 100, 0.0);  // Bulk initialization

// Modern loop constructs
for(int i = 0; i < ArraySize(prices); i++) {
    prices[i] = NormalizeDouble(prices[i], _Digits);
}

// Enhanced error handling
int error_code = GetLastError();
string error_desc = ErrorDescription(error_code);
Print("Error: ", error_code, " - ", error_desc);
```

---

## 2. Architecture Patterns for Trading EAs

### 2.1 Singleton Pattern for Managers
```cpp
class CIndicatorManager {
private:
    static CIndicatorManager* m_instance;
    int m_ema_handles[];
    
    CIndicatorManager() {}  // Private constructor
    
public:
    static CIndicatorManager* GetInstance() {
        if(m_instance == NULL) {
            m_instance = new CIndicatorManager();
        }
        return m_instance;
    }
    
    int GetEMAHandle(string symbol, ENUM_TIMEFRAMES tf, int period) {
        // Handle caching logic
        string key = symbol + "_" + EnumToString(tf) + "_" + IntegerToString(period);
        // Return cached or create new handle
    }
    
    ~CIndicatorManager() {
        // Release all handles
        for(int i = 0; i < ArraySize(m_ema_handles); i++) {
            if(m_ema_handles[i] != INVALID_HANDLE) {
                IndicatorRelease(m_ema_handles[i]);
            }
        }
    }
};
```

### 2.2 Strategy Pattern for Signal Generation
```cpp
// Abstract base class
class CSignalStrategy {
public:
    virtual ENUM_SIGNAL_TYPE GenerateSignal() = 0;
    virtual double GetConfidence() = 0;
    virtual string GetDescription() = 0;
};

// Concrete implementations
class CSonicRStrategy : public CSignalStrategy {
public:
    ENUM_SIGNAL_TYPE GenerateSignal() override {
        // Sonic R specific logic
        double ema34 = GetEMAValue(34);
        double ema89 = GetEMAValue(89);
        
        if(ema34 > ema89) return SIGNAL_BUY;
        if(ema34 < ema89) return SIGNAL_SELL;
        return SIGNAL_NONE;
    }
    
    double GetConfidence() override {
        return CalculateEMAConfluence();
    }
    
    string GetDescription() override {
        return "Sonic R Dragon Band Strategy";
    }
};

class CPVSRAStrategy : public CSignalStrategy {
public:
    ENUM_SIGNAL_TYPE GenerateSignal() override {
        // PVSRA specific logic
        double volume_score = CalculateVolumeScore();
        double sr_score = CalculateSRScore();
        
        if(volume_score > 0.7 && sr_score > 0.7) {
            return DetermineDirection();
        }
        return SIGNAL_NONE;
    }
};
```

### 2.3 Observer Pattern for UI Updates
```cpp
class CMarketObserver {
public:
    virtual void OnPriceUpdate(double price) = 0;
    virtual void OnSignalGenerated(ENUM_SIGNAL_TYPE signal) = 0;
    virtual void OnTradeExecuted(int ticket) = 0;
};

class CDashboard : public CMarketObserver {
public:
    void OnPriceUpdate(double price) override {
        UpdatePriceDisplay(price);
    }
    
    void OnSignalGenerated(ENUM_SIGNAL_TYPE signal) override {
        UpdateSignalIndicator(signal);
        if(signal != SIGNAL_NONE) {
            PlayAlert();
        }
    }
    
    void OnTradeExecuted(int ticket) override {
        UpdateTradeHistory(ticket);
        UpdateAccountInfo();
    }
};
```

---

## 3. Performance Optimization Techniques

### 3.1 Efficient Data Access
```cpp
// ❌ Inefficient: Multiple indicator calls
double ema34_current = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
double ema34_previous = iMA(_Symbol, PERIOD_CURRENT, 34, 1, MODE_EMA, PRICE_CLOSE);

// ✅ Efficient: Single handle with buffer copy
class CEMACalculator {
private:
    int m_handle;
    double m_buffer[];
    
public:
    bool Initialize(string symbol, ENUM_TIMEFRAMES tf, int period) {
        m_handle = iMA(symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
        ArraySetAsSeries(m_buffer, true);
        return (m_handle != INVALID_HANDLE);
    }
    
    bool Update() {
        return (CopyBuffer(m_handle, 0, 0, 3, m_buffer) > 0);
    }
    
    double GetValue(int shift = 0) {
        return (shift < ArraySize(m_buffer)) ? m_buffer[shift] : 0.0;
    }
};
```

### 3.2 Memory Management Best Practices
```cpp
// ✅ Proper dynamic array usage
class CDataManager {
private:
    double m_prices[];
    datetime m_times[];
    
public:
    bool LoadHistoricalData(int bars_count) {
        // Resize arrays efficiently
        ArrayResize(m_prices, bars_count);
        ArrayResize(m_times, bars_count);
        
        // Set time series indexing
        ArraySetAsSeries(m_prices, true);
        ArraySetAsSeries(m_times, true);
        
        // Copy data in single operations
        int copied_prices = CopyClose(_Symbol, PERIOD_CURRENT, 0, bars_count, m_prices);
        int copied_times = CopyTime(_Symbol, PERIOD_CURRENT, 0, bars_count, m_times);
        
        return (copied_prices == bars_count && copied_times == bars_count);
    }
    
    void Cleanup() {
        ArrayFree(m_prices);
        ArrayFree(m_times);
    }
};
```

### 3.3 Tick Processing Optimization
```cpp
class CTickProcessor {
private:
    datetime m_last_bar_time;
    bool m_new_bar_mode;
    
public:
    bool IsNewBar() {
        if(!m_new_bar_mode) return true;
        
        datetime current_bar_time = iTime(_Symbol, PERIOD_CURRENT, 0);
        if(current_bar_time != m_last_bar_time) {
            m_last_bar_time = current_bar_time;
            return true;
        }
        return false;
    }
    
    void ProcessTick() {
        // Light processing on every tick
        UpdateCurrentPrice();
        
        // Heavy processing only on new bars
        if(IsNewBar()) {
            PerformAnalysis();
            CheckSignals();
            UpdateUI();
        }
    }
};
```

---

## 4. Error Handling & Logging

### 4.1 Structured Error Handling
```cpp
enum ENUM_ERROR_LEVEL {
    ERROR_LEVEL_INFO,
    ERROR_LEVEL_WARNING,
    ERROR_LEVEL_ERROR,
    ERROR_LEVEL_CRITICAL
};

class CErrorHandler {
private:
    string m_log_file;
    
public:
    void LogError(ENUM_ERROR_LEVEL level, string message, string context = "") {
        string timestamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
        string level_str = EnumToString(level);
        
        string log_entry = StringFormat("[%s] %s: %s", timestamp, level_str, message);
        if(context != "") {
            log_entry += " (Context: " + context + ")";
        }
        
        // Write to file
        int file_handle = FileOpen(m_log_file, FILE_WRITE | FILE_TXT | FILE_ANSI);
        if(file_handle != INVALID_HANDLE) {
            FileWriteString(file_handle, log_entry + "\n");
            FileClose(file_handle);
        }
        
        // Also print to terminal
        Print(log_entry);
        
        // Critical errors trigger alerts
        if(level == ERROR_LEVEL_CRITICAL) {
            Alert("CRITICAL ERROR: ", message);
        }
    }
    
    bool HandleIndicatorError(int handle, string indicator_name) {
        if(handle == INVALID_HANDLE) {
            int error = GetLastError();
            LogError(ERROR_LEVEL_ERROR, 
                    StringFormat("Failed to create %s indicator. Error: %d", indicator_name, error),
                    "Indicator Initialization");
            return false;
        }
        return true;
    }
};
```

### 4.2 Graceful Degradation
```cpp
class CRobustEA {
private:
    bool m_indicators_ready;
    bool m_fallback_mode;
    
public:
    void OnTick() {
        if(!m_indicators_ready) {
            if(!InitializeIndicators()) {
                EnableFallbackMode();
            }
        }
        
        if(m_fallback_mode) {
            ProcessTickFallback();
        } else {
            ProcessTickNormal();
        }
    }
    
private:
    void EnableFallbackMode() {
        m_fallback_mode = true;
        Print("⚠️ EA running in fallback mode - limited functionality");
    }
    
    void ProcessTickFallback() {
        // Simple price-based logic without indicators
        double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double previous_price = iClose(_Symbol, PERIOD_CURRENT, 1);
        
        if(current_price > previous_price * 1.001) {
            // Simple bullish signal
        }
    }
};
```

---

## 5. Testing & Quality Assurance

### 5.1 Unit Testing Framework
```cpp
class CUnitTest {
private:
    int m_tests_run;
    int m_tests_passed;
    
public:
    void RunTest(string test_name, bool condition) {
        m_tests_run++;
        if(condition) {
            m_tests_passed++;
            Print("✅ ", test_name, " - PASSED");
        } else {
            Print("❌ ", test_name, " - FAILED");
        }
    }
    
    void PrintResults() {
        double pass_rate = (m_tests_run > 0) ? (m_tests_passed * 100.0 / m_tests_run) : 0.0;
        Print("📊 Test Results: ", m_tests_passed, "/", m_tests_run, 
              " (", DoubleToString(pass_rate, 1), "%)");
    }
};

// Usage example
void TestEMACalculations() {
    CUnitTest tester;
    
    CEMACalculator ema;
    tester.RunTest("EMA Initialization", ema.Initialize(_Symbol, PERIOD_CURRENT, 34));
    tester.RunTest("EMA Update", ema.Update());
    tester.RunTest("EMA Value Range", ema.GetValue() > 0);
    
    tester.PrintResults();
}
```

### 5.2 Performance Profiling
```cpp
class CProfiler {
private:
    ulong m_start_time;
    string m_operation_name;
    
public:
    void StartTiming(string operation) {
        m_operation_name = operation;
        m_start_time = GetMicrosecondCount();
    }
    
    void EndTiming() {
        ulong end_time = GetMicrosecondCount();
        ulong duration = end_time - m_start_time;
        
        Print("⏱️ ", m_operation_name, " took ", duration, " microseconds");
        
        if(duration > 10000) {  // > 10ms
            Print("⚠️ Performance warning: ", m_operation_name, " is slow");
        }
    }
};

// Usage
void AnalyzeMarket() {
    CProfiler profiler;
    
    profiler.StartTiming("PVSRA Analysis");
    PerformPVSRAAnalysis();
    profiler.EndTiming();
    
    profiler.StartTiming("SMC Analysis");
    PerformSMCAnalysis();
    profiler.EndTiming();
}
```

---

## 6. Deployment & Production Readiness

### 6.1 Configuration Management
```cpp
class CConfiguration {
private:
    string m_config_file;
    
public:
    bool LoadConfiguration() {
        int file_handle = FileOpen(m_config_file, FILE_READ | FILE_TXT | FILE_ANSI);
        if(file_handle == INVALID_HANDLE) {
            CreateDefaultConfiguration();
            return false;
        }
        
        while(!FileIsEnding(file_handle)) {
            string line = FileReadString(file_handle);
            ParseConfigurationLine(line);
        }
        
        FileClose(file_handle);
        return true;
    }
    
private:
    void ParseConfigurationLine(string line) {
        if(StringFind(line, "=") > 0) {
            string parts[];
            StringSplit(line, '=', parts);
            if(ArraySize(parts) == 2) {
                string key = StringTrimLeft(StringTrimRight(parts[0]));
                string value = StringTrimLeft(StringTrimRight(parts[1]));
                SetConfigValue(key, value);
            }
        }
    }
};
```

### 6.2 Health Monitoring
```cpp
class CHealthMonitor {
private:
    datetime m_last_tick_time;
    int m_error_count;
    double m_memory_usage;
    
public:
    void OnTick() {
        m_last_tick_time = TimeCurrent();
        CheckSystemHealth();
    }
    
private:
    void CheckSystemHealth() {
        // Check for stale ticks
        if(TimeCurrent() - m_last_tick_time > 300) {  // 5 minutes
            Print("⚠️ No ticks received for 5 minutes");
        }
        
        // Monitor error rate
        if(m_error_count > 10) {
            Print("🚨 High error rate detected: ", m_error_count, " errors");
            m_error_count = 0;  // Reset counter
        }
        
        // Memory usage check (if available)
        CheckMemoryUsage();
    }
    
    void CheckMemoryUsage() {
        // Platform-specific memory monitoring
        // Log warnings if memory usage is high
    }
};
```

---

## 7. Compliance & Standards Checklist

### 7.1 Code Quality Standards
- [ ] **Clean Compile**: 0 errors, 0 warnings
- [ ] **Naming Convention**: PascalCase for classes, camelCase for variables
- [ ] **Documentation**: All public methods documented
- [ ] **Error Handling**: All functions return error codes or throw exceptions
- [ ] **Memory Management**: No memory leaks, proper array handling
- [ ] **Performance**: No operations taking >10ms in OnTick()

### 7.2 Trading Standards
- [ ] **Risk Management**: Maximum risk per trade enforced
- [ ] **Position Sizing**: Proper lot size calculations
- [ ] **Slippage Control**: Realistic slippage assumptions
- [ ] **Drawdown Protection**: Maximum drawdown limits
- [ ] **Prop Trading Compliance**: No martingale, hedging restrictions

### 7.3 Production Readiness
- [ ] **Logging**: Structured logging with levels
- [ ] **Monitoring**: Health checks and alerts
- [ ] **Configuration**: External configuration files
- [ ] **Testing**: Unit tests and integration tests
- [ ] **Documentation**: Complete technical documentation
- [ ] **Backup**: Code versioning and backup procedures
