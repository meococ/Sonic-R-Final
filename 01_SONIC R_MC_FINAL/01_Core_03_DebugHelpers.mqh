//+------------------------------------------------------------------+
//|                        01_Core_03_DebugHelpers.mqh              |
//|  Centralized debug/log throttling helpers for EA & modules      |
//+------------------------------------------------------------------+
#ifndef CORE_DEBUG_HELPERS_MQH
#define CORE_DEBUG_HELPERS_MQH

#include "01_Core_00_Inputs.mqh"

// Determine if running in Strategy Tester or Optimization
inline bool __isBT(){
  // Use MQL_TESTER / MQL_OPTIMIZATION flags
  bool inTester = (bool)MQLInfoInteger(MQL_TESTER);
  bool inOpt    = (bool)MQLInfoInteger(MQL_OPTIMIZATION);
  return (inTester || inOpt);
}

// Lightweight debug throttler (shared)
static datetime __dbg_lastBarTime=0;
static ulong    __dbg_lastUsec=0;
inline bool DebugPermit(){
  if(!InpDebugMode) return false;
  if(InpLogNewBarOnly){ datetime bt=iTime(_Symbol,PERIOD_CURRENT,0); if(bt==__dbg_lastBarTime) return false; __dbg_lastBarTime=bt; }
  if(InpLogThrottleMs>0){ ulong now=GetMicrosecondCount(); if(now-__dbg_lastUsec < (ulong)InpLogThrottleMs*1000ULL) return false; __dbg_lastUsec=now; }
  return true;
}

// Backtest-aware logging filters
inline bool __bt_IsLogAllowed(){
  if(!InpDebugMode) return false;
  if(!__isBT()) return DebugPermit();
  if(InpBacktestLogMode==BT_LOG_OFF) return false;
  if(InpBacktestLogMode==BT_LOG_COMPACT) return DebugPermit();
  if(InpBacktestLogMode==BT_LOG_M15_ONLY){
    datetime bt = iTime(_Symbol, InpLogBarTF, 0);
    static datetime __last=0; if(bt==__last) return false; __last=bt; return true;
  }
  return true;
}

inline void DPrintBT(const string msg){ if(__bt_IsLogAllowed()) Print(msg); }
inline void DPrint(const string msg){
  if(!InpDebugMode) return;
  if(__isBT()) { DPrintBT(msg); return; }
  if(InpDebugCompact){ if(DebugPermit()) Print(msg);} else { Print(msg);} 
}

#endif // CORE_DEBUG_HELPERS_MQH


