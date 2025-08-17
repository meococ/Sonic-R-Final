//+------------------------------------------------------------------+
//|                       01_Core_ErrorHandler.mqh                   |
//|                    SONIC R MC EA - Error Management              |
//|                     Consolidated Error Handler                   |
//+------------------------------------------------------------------+
#ifndef CORE_ERROR_HANDLER_MQH
#define CORE_ERROR_HANDLER_MQH

//+------------------------------------------------------------------+
//| Error Handler Class                                              |
//+------------------------------------------------------------------+
class CCompleteErrorHandler
{
private:
    int         m_lastError;         // Last error code
    string      m_lastErrorDesc;     // Last error description
    datetime    m_lastErrorTime;     // Last error time
    int         m_errorCount;        // Total error count
    bool        m_criticalError;     // Critical error flag
    
public:
    //+------------------------------------------------------------------+
    //| Constructor                                                       |
    //+------------------------------------------------------------------+
    CCompleteErrorHandler()
    {
        m_lastError = 0;
        m_lastErrorDesc = "";
        m_lastErrorTime = 0;
        m_errorCount = 0;
        m_criticalError = false;
    }
    
    //+------------------------------------------------------------------+
    //| Destructor                                                        |
    //+------------------------------------------------------------------+
    ~CCompleteErrorHandler() {}
    
    //+------------------------------------------------------------------+
    //| Handle Error                                                      |
    //+------------------------------------------------------------------+
    bool HandleError(int errorCode, string context = "")
    {
        m_lastError = errorCode;
        m_lastErrorTime = TimeCurrent();
        
        if(errorCode != 0)
        {
            m_errorCount++;
            m_lastErrorDesc = GetErrorDescription(errorCode);
            
            // Check for critical errors
            if(IsCriticalError(errorCode))
            {
                m_criticalError = true;
                Print("🚨 CRITICAL ERROR [", errorCode, "] in ", context, ": ", m_lastErrorDesc);
                return false;
            }
            else
            {
                Print("⚠️ Error [", errorCode, "] in ", context, ": ", m_lastErrorDesc);
            }
            
            return false;
        }
        
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Check if error is critical                                       |
    //+------------------------------------------------------------------+
    bool IsCriticalError(int errorCode)
    {
        switch(errorCode)
        {
            case 4109: // Trading not allowed
            case 4110: // Longs not allowed
            case 4111: // Shorts not allowed
            case 4112: // Automated trading disabled
            case 10004: // Requote
            case 10006: // Request rejected
            case 10007: // Request canceled by trader
            case 10011: // Request processing error
            case 10012: // Request canceled by timeout
            case 10013: // Invalid request
            case 10014: // Invalid volume
            case 10015: // Invalid price
            case 10016: // Invalid stops
            case 10017: // Trade disabled
            case 10018: // Market closed
            case 10019: // Not enough money
            case 10038: // Request locked
            case 10040: // Long positions only allowed
            case 10041: // Pending order activation request error
            case 10042: // Only modification of order time allowed
                return true;
            default:
                return false;
        }
    }
    
    //+------------------------------------------------------------------+
    //| Get Error Description                                            |
    //+------------------------------------------------------------------+
    string GetErrorDescription(int errorCode)
    {
        switch(errorCode)
        {
            // No error
            case 0: return "No error";
            
            // Common MQL5 errors
            case 4001: return "Unexpected internal error";
            case 4002: return "Wrong parameter";
            case 4003: return "Wrong parameters count";
            case 4004: return "Not enough memory";
            case 4005: return "Wrong struct size";
            case 4006: return "Invalid array";
            case 4007: return "Not enough stack memory";
            case 4008: return "Not enough heap memory";
            case 4009: return "Not initialized string";
            case 4010: return "Invalid date/time";
            case 4011: return "Requested array size exceeds 2GB";
            case 4012: return "Invalid stop";
            case 4013: return "Invalid pointer";
            case 4014: return "Invalid pointer type";
            case 4015: return "Function not allowed in call";
            
            // Terminal errors
            case 4051: return "Invalid function parameter value";
            case 4108: return "Invalid ticket";
            case 4109: return "Trading is not allowed";
            case 4110: return "Longs are not allowed";
            case 4111: return "Shorts are not allowed";
            case 4112: return "Automated trading disabled";
            case 4756: return "Position already closed";
            
            // Trade server return codes
            case 10004: return "Requote";
            case 10006: return "Request rejected";
            case 10007: return "Request canceled by trader";
            case 10008: return "Order placed";
            case 10009: return "Request completed";
            case 10010: return "Only part of request completed";
            case 10011: return "Request processing error";
            case 10012: return "Request canceled by timeout";
            case 10013: return "Invalid request";
            case 10014: return "Invalid volume";
            case 10015: return "Invalid price";
            case 10016: return "Invalid stops";
            case 10017: return "Trade disabled";
            case 10018: return "Market closed";
            case 10019: return "Not enough money";
            case 10020: return "Prices changed";
            case 10021: return "No quotes for processing request";
            case 10022: return "Invalid order expiration date";
            case 10023: return "Order state changed";
            case 10024: return "Too frequent requests";
            case 10025: return "No changes in request";
            case 10026: return "Autotrading disabled by server";
            case 10027: return "Autotrading disabled by client";
            case 10028: return "Request locked";
            case 10029: return "Order or position frozen";
            case 10030: return "Invalid order type";
            case 10031: return "No connection with trade server";
            case 10032: return "Operation allowed only for live accounts";
            case 10033: return "Pending orders limit exceeded";
            case 10034: return "Orders and positions volume limit exceeded";
            case 10038: return "Request locked by another request";
            case 10039: return "Order already closed";
            case 10040: return "Long positions only allowed";
            case 10041: return "Pending order activation error";
            case 10042: return "Only order time modification allowed";
            case 10043: return "Cannot modify order type";
            case 10044: return "Position already closed by SL";
            case 10045: return "Position already closed by TP";
            
            default: return "Unknown error: " + IntegerToString(errorCode);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Clear last error                                                 |
    //+------------------------------------------------------------------+
    void ClearError()
    {
        m_lastError = 0;
        m_lastErrorDesc = "";
        m_lastErrorTime = 0;
        m_criticalError = false;
    }
    
    //+------------------------------------------------------------------+
    //| Reset all                                                        |
    //+------------------------------------------------------------------+
    void Reset()
    {
        m_lastError = 0;
        m_lastErrorDesc = "";
        m_lastErrorTime = 0;
        m_errorCount = 0;
        m_criticalError = false;
    }
    
    //+------------------------------------------------------------------+
    //| Getters                                                          |
    //+------------------------------------------------------------------+
    int         GetLastError()         const { return m_lastError; }
    string      GetLastErrorDesc()     const { return m_lastErrorDesc; }
    datetime    GetLastErrorTime()     const { return m_lastErrorTime; }
    int         GetErrorCount()         const { return m_errorCount; }
    bool        HasCriticalError()     const { return m_criticalError; }
    
    //+------------------------------------------------------------------+
    //| Check for recent errors                                          |
    //+------------------------------------------------------------------+
    bool HasRecentError(int seconds = 60) const
    {
        if(m_lastError == 0) return false;
        return (TimeCurrent() - m_lastErrorTime) <= seconds;
    }
};

//+------------------------------------------------------------------+
//| Global Error Handler Instance                                    |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - MQL5 global pointers cannot be initialized with assignment
CCompleteErrorHandler* g_errorHandler;

//+------------------------------------------------------------------+
//| Initialize Error Handler                                         |
//+------------------------------------------------------------------+
bool InitializeErrorHandler()
{
    // SYSTEMATIC FIX - Initialize pointer first
    if(g_errorHandler == NULL) {
        g_errorHandler = NULL; // Explicit initialization
    }
    if(g_errorHandler == NULL)
    {
        g_errorHandler = new CCompleteErrorHandler();
        if(g_errorHandler != NULL)
        {
            Print("✅ Error Handler initialized successfully");
            return true;
        }
        else
        {
            Print("❌ Failed to initialize Error Handler");
            return false;
        }
    }
    return true; // Already initialized
}

//+------------------------------------------------------------------+
//| Cleanup Error Handler                                            |
//+------------------------------------------------------------------+
void CleanupErrorHandler()
{
    if(g_errorHandler != NULL)
    {
        delete g_errorHandler;
        g_errorHandler = NULL;
        Print("✅ Error Handler cleaned up");
    }
}

#endif // CORE_ERROR_HANDLER_MQH
