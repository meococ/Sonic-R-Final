//+------------------------------------------------------------------+
//|                        01_Core_19_SecurityHardening.mqh         |
//|                    Consolidated Security Hardening             |
//+------------------------------------------------------------------+
#ifndef CORE_19_SECURITY_HARDENING_MQH
#define CORE_19_SECURITY_HARDENING_MQH

#include "01_Core_14_CoreEnums.mqh"

//+------------------------------------------------------------------+
//| Security Hardening Class                                        |
//+------------------------------------------------------------------+
class CSecurityHardening
{
private:
    bool m_initialized;
    bool m_securityEnabled;
    string m_allowedSymbols[];
    
public:
    CSecurityHardening() : m_initialized(false), m_securityEnabled(true) {}
    ~CSecurityHardening() { Deinitialize(); }
    
    bool Initialize()
    {
        m_initialized = true;
        ArrayResize(m_allowedSymbols, 1);
        m_allowedSymbols[0] = _Symbol;
        return true;
    }
    
    void Deinitialize()
    {
        if(m_initialized)
        {
            ArrayFree(m_allowedSymbols);
            m_initialized = false;
        }
    }
    
    bool IsSymbolAllowed(string symbol)
    {
        if(!m_securityEnabled) return true;
        
        for(int i = 0; i < ArraySize(m_allowedSymbols); i++)
        {
            if(m_allowedSymbols[i] == symbol)
                return true;
        }
        return false;
    }
    
    bool ValidateTradeParameters(double volume, double stopLoss, double takeProfit)
    {
        if(volume <= 0 || volume > 10.0) return false;
        if(stopLoss < 0 || takeProfit < 0) return false;
        return true;
    }
    
    void EnableSecurity(bool enable) { m_securityEnabled = enable; }
    bool IsSecurityEnabled() const { return m_securityEnabled; }
    bool IsInitialized() const { return m_initialized; }
};

#endif // CORE_19_SECURITY_HARDENING_MQH
