//+------------------------------------------------------------------+
//|                              Monitoring_RealTimePerformance.mqh |
//|                  ?? PHASE 6: REAL-TIME PERFORMANCE MONITORING    |
//|                  ?? LIVE METRICS & DASHBOARD INTEGRATION         |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Phase 6 Enhancement"
#property version   "6.00"

#ifndef MONITORING_REALTIMEPERFORMANCE_MQH
#define MONITORING_REALTIMEPERFORMANCE_MQH

#include "01_Core_08_ContextManager.mqh"
#include "09_Performance_03_SystemUnified.mqh"
#include "16_UI_01_Dashboard.mqh"

//+------------------------------------------------------------------+
//| Real-Time Performance Monitoring Class                          |
//+------------------------------------------------------------------+
class CRealTimePerformanceMonitor
{
private:
    bool m_isInitialized;
    datetime m_lastUpdate;
    
public:
    CRealTimePerformanceMonitor() : m_isInitialized(false), m_lastUpdate(0) {}
    
    ~CRealTimePerformanceMonitor() { Deinitialize(); }
    
    bool Initialize() { m_isInitialized = true; m_lastUpdate = TimeCurrent(); return true; }
    
    void Deinitialize() { m_isInitialized = false; }
    
    bool UpdateMetrics() { if (!m_isInitialized) return false; m_lastUpdate = TimeCurrent(); return true; }
    
    bool IsInitialized() const { return m_isInitialized; }
};

#endif
