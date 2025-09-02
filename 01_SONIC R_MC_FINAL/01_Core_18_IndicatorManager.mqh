//+------------------------------------------------------------------+
//|                                            IndicatorManager.mqh |
//|                     ?? SONIC R MC - INDICATOR MANAGER           |
//|                         Advanced Indicator Management            |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - �?i B�ng Enhanced"
#property version   "2.00"

#ifndef CORE_08_INDICATOR_MANAGER_MQH
#define CORE_08_INDICATOR_MANAGER_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| INDICATOR MANAGER CLASS                                          |
//+------------------------------------------------------------------+
class CIndicatorManager
{
private:
    string m_symbol;                     // Symbol
    ENUM_TIMEFRAMES m_timeframe;        // Timeframe
    bool m_initialized;                  // Initialization flag
    
    // Indicator handles
    int m_emaHandle;                     // EMA handle (generic)
    int m_rsiHandle;                     // RSI handle
    int m_macdHandle;                    // MACD handle
    int m_atrHandle;                     // ATR handle
    
    // Common EMA handles used across modules
    int m_ema34Handle;                   // EMA 34 handle
    int m_ema89Handle;                   // EMA 89 handle
    int m_ema200Handle;                  // EMA 200 handle
    
public:
    CIndicatorManager()
    {
        m_symbol = "";
        m_timeframe = PERIOD_CURRENT;
        m_initialized = false;
        m_emaHandle = INVALID_HANDLE;
        m_rsiHandle = INVALID_HANDLE;
        m_macdHandle = INVALID_HANDLE;
        m_atrHandle = INVALID_HANDLE;
    m_ema34Handle = INVALID_HANDLE;
    m_ema89Handle = INVALID_HANDLE;
    m_ema200Handle = INVALID_HANDLE;
    }
    
    ~CIndicatorManager()
    {
        Cleanup();
    }
    
    bool Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
    {
        m_symbol = symbol;
        m_timeframe = timeframe;
        
        // Initialize indicators
        m_emaHandle = iMA(m_symbol, m_timeframe, 20, 0, MODE_EMA, PRICE_CLOSE);
        m_rsiHandle = iRSI(m_symbol, m_timeframe, 14, PRICE_CLOSE);
        m_macdHandle = iMACD(m_symbol, m_timeframe, 12, 26, 9, PRICE_CLOSE);
        m_atrHandle = iATR(m_symbol, m_timeframe, 14);
        
    // Frequently used EMAs
    m_ema34Handle = iMA(m_symbol, m_timeframe, 34, 0, MODE_EMA, PRICE_CLOSE);
    m_ema89Handle = iMA(m_symbol, m_timeframe, 89, 0, MODE_EMA, PRICE_CLOSE);
    m_ema200Handle = iMA(m_symbol, m_timeframe, 200, 0, MODE_EMA, PRICE_CLOSE);
        
        m_initialized = (m_emaHandle != INVALID_HANDLE && 
                        m_rsiHandle != INVALID_HANDLE && 
                        m_macdHandle != INVALID_HANDLE && 
            m_atrHandle != INVALID_HANDLE &&
            m_ema34Handle != INVALID_HANDLE &&
            m_ema89Handle != INVALID_HANDLE &&
            m_ema200Handle != INVALID_HANDLE);
        
        if(m_initialized)
        {
            Print("? Indicator Manager initialized for ", m_symbol, " ", EnumToString(m_timeframe));
        }
        else
        {
            Print("? Failed to initialize Indicator Manager");
        }
        
        return m_initialized;
    }
    
    void Cleanup()
    {
        if(m_emaHandle != INVALID_HANDLE) IndicatorRelease(m_emaHandle);
        if(m_rsiHandle != INVALID_HANDLE) IndicatorRelease(m_rsiHandle);
        if(m_macdHandle != INVALID_HANDLE) IndicatorRelease(m_macdHandle);
        if(m_atrHandle != INVALID_HANDLE) IndicatorRelease(m_atrHandle);
    if(m_ema34Handle != INVALID_HANDLE) IndicatorRelease(m_ema34Handle);
    if(m_ema89Handle != INVALID_HANDLE) IndicatorRelease(m_ema89Handle);
    if(m_ema200Handle != INVALID_HANDLE) IndicatorRelease(m_ema200Handle);
        
        m_emaHandle = INVALID_HANDLE;
        m_rsiHandle = INVALID_HANDLE;
        m_macdHandle = INVALID_HANDLE;
        m_atrHandle = INVALID_HANDLE;
    m_ema34Handle = INVALID_HANDLE;
    m_ema89Handle = INVALID_HANDLE;
    m_ema200Handle = INVALID_HANDLE;
        m_initialized = false;
    }
    
    // Indicator value getters
    double GetEMA(int shift = 0)
    {
        if(!m_initialized || m_emaHandle == INVALID_HANDLE) return 0.0;
        
        double buffer[1];
        if(CopyBuffer(m_emaHandle, 0, shift, 1, buffer) > 0)
            return buffer[0];
        return 0.0;
    }
    
    double GetRSI(int shift = 0)
    {
        if(!m_initialized || m_rsiHandle == INVALID_HANDLE) return 50.0;
        
        double buffer[1];
        if(CopyBuffer(m_rsiHandle, 0, shift, 1, buffer) > 0)
            return buffer[0];
        return 50.0;
    }
    
    double GetMACD(int shift = 0, int buffer_num = 0)
    {
        if(!m_initialized || m_macdHandle == INVALID_HANDLE) return 0.0;
        
        double buffer[1];
        if(CopyBuffer(m_macdHandle, buffer_num, shift, 1, buffer) > 0)
            return buffer[0];
        return 0.0;
    }
    
    double GetATR(int shift = 0)
    {
        if(!m_initialized || m_atrHandle == INVALID_HANDLE) return 0.001;
        
        double buffer[1];
        if(CopyBuffer(m_atrHandle, 0, shift, 1, buffer) > 0)
            return buffer[0];
        return 0.001;
    }
    
    // Convenience wrappers expected by other modules
    bool GetEMAValues(double &ema34, double &ema89, double &ema200, int shift = 0)
    {
        if(!m_initialized) return false;
        double buf[1];
        bool ok = true;
        ema34 = 0.0; ema89 = 0.0; ema200 = 0.0;
        if(m_ema34Handle != INVALID_HANDLE && CopyBuffer(m_ema34Handle, 0, shift, 1, buf) > 0) ema34 = buf[0]; else ok = false;
        if(m_ema89Handle != INVALID_HANDLE && CopyBuffer(m_ema89Handle, 0, shift, 1, buf) > 0) ema89 = buf[0]; else ok = false;
        if(m_ema200Handle != INVALID_HANDLE && CopyBuffer(m_ema200Handle, 0, shift, 1, buf) > 0) ema200 = buf[0]; else ok = false;
        return ok;
    }
    
    bool GetATRValue(double &atrValue, int period = 14, int shift = 0)
    {
        atrValue = 0.0;
        if(!m_initialized) return false;
        
        // Use cached 14-period ATR when requested
        if(period == 14 && m_atrHandle != INVALID_HANDLE)
        {
            double buf[1];
            if(CopyBuffer(m_atrHandle, 0, shift, 1, buf) > 0) { atrValue = buf[0]; return true; }
            return false;
        }
        
        // Fallback: create a temporary handle for other periods
        int h = iATR(m_symbol, m_timeframe, period);
        if(h == INVALID_HANDLE) return false;
        double tmp[1];
        bool ok = (CopyBuffer(h, 0, shift, 1, tmp) > 0);
        if(ok) atrValue = tmp[0];
        IndicatorRelease(h);
        return ok;
    }
    
    // Handle getters
    int GetEMAHandle() const { return m_emaHandle; }
    int GetRSIHandle() const { return m_rsiHandle; }
    int GetMACDHandle() const { return m_macdHandle; }
    int GetATRHandle() const { return m_atrHandle; }
    
    // Status
    bool IsInitialized() const { return m_initialized; }
    string GetSymbol() const { return m_symbol; }
    ENUM_TIMEFRAMES GetTimeframe() const { return m_timeframe; }
};

//+------------------------------------------------------------------+
//| ADVANCED LOGGER CLASS                                            |
//+------------------------------------------------------------------+
class CAdvancedLogger
{
private:
    string m_logFile;                    // Log file name
    bool m_enabled;                      // Logger enabled
    ENUM_LOG_LEVEL m_logLevel;          // Log level
    
public:
    CAdvancedLogger()
    {
        m_logFile = "";
        m_enabled = true;
        m_logLevel = LOG_INFO;
    }
    
    ~CAdvancedLogger() {}
    
    bool Initialize(string logFileName)
    {
        m_logFile = logFileName;
        m_enabled = true;
        
        Log(LOG_INFO, "Advanced Logger initialized: " + m_logFile);
        return true;
    }
    
    void Log(ENUM_LOG_LEVEL level, string message)
    {
        if(!m_enabled || level < m_logLevel) return;
        
        string levelStr = GetLogLevelString(level);
        string timestamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
        string logMessage = StringFormat("[%s] %s: %s", timestamp, levelStr, message);
        
        Print(logMessage);
        
        // Write to file if specified
        if(m_logFile != "")
        {
            int fileHandle = FileOpen(m_logFile, FILE_WRITE | FILE_TXT | FILE_ANSI);
            if(fileHandle != INVALID_HANDLE)
            {
                FileWrite(fileHandle, logMessage);
                FileClose(fileHandle);
            }
        }
    }
    
    void SetLogLevel(ENUM_LOG_LEVEL level) { m_logLevel = level; }
    void Enable() { m_enabled = true; }
    void Disable() { m_enabled = false; }
    
private:
    string GetLogLevelString(ENUM_LOG_LEVEL level)
    {
        switch(level)
        {
            case LOG_DEBUG: return "DEBUG";
            case LOG_INFO: return "INFO";
            case LOG_WARNING: return "WARNING";
            case LOG_ERROR: return "ERROR";
            case LOG_CRITICAL: return "CRITICAL";
            default: return "UNKNOWN";
        }
    }
};

//+------------------------------------------------------------------+
//| GLOBAL INSTANCES                                                 |
//+------------------------------------------------------------------+
CIndicatorManager* g_indicatorManager = NULL;
extern CAdvancedLogger* g_advancedLogger;

//+------------------------------------------------------------------+
//| INITIALIZATION FUNCTIONS                                         |
//+------------------------------------------------------------------+
bool InitializeIndicatorManager(string symbol, ENUM_TIMEFRAMES timeframe)
{
    if(g_indicatorManager == NULL)
    {
        g_indicatorManager = new CIndicatorManager();
    }
    
    return g_indicatorManager.Initialize(symbol, timeframe);
}

bool InitializeAdvancedLogger(string logFileName)
{
    if(g_advancedLogger == NULL)
    {
        g_advancedLogger = new CAdvancedLogger();
    }
    
    return g_advancedLogger.Initialize(logFileName);
}

void CleanupIndicatorManager()
{
    if(g_indicatorManager != NULL)
    {
        delete g_indicatorManager;
        g_indicatorManager = NULL;
    }
    
    if(g_advancedLogger != NULL)
    {
        delete g_advancedLogger;
        g_advancedLogger = NULL;
    }
}

#endif // CORE_08_INDICATOR_MANAGER_MQH
