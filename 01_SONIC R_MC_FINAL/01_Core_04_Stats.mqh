//+------------------------------------------------------------------+
//|                       01_Core_04_Stats.mqh                      |
//|                   BYPASS counters & Trace CSV                   |
//+------------------------------------------------------------------+
#ifndef CORE_04_STATS_MQH
#define CORE_04_STATS_MQH

#include "01_Core_02_ConfigManager.mqh"

enum BYPASS_REASON{
  BP_NONE=0, BP_SESSION, BP_REGIME, BP_MTF, BP_TRENDSTACK, BP_DRAGON_ANGLE,
  BP_OUTSIDE_DRAGON, BP_WAVE_INVALID, BP_LEG2_MISS, BP_SPREAD_CAP,
  BP_STOPSLEVEL, BP_SL_EXCESSIVE, BP_MIN_LOT, BP_RISK, BP_COOLDOWN,
  BP_DUPLICATE, BP_OTHER, BP__COUNT
};
struct BypassStats{ long cnt[BP__COUNT]; long candidates; };
static BypassStats gBP;

// Lightweight accessors for UI and metrics
inline long BP_TotalCandidates(){ return gBP.candidates; }
inline long BP_Count(int r){ return (r>BP_NONE && r<BP__COUNT) ? gBP.cnt[r] : 0; }


void BP_Hit(BYPASS_REASON r){ gBP.candidates++; if(r>BP_NONE && r<BP__COUNT) gBP.cnt[r]++; }

string BP_Name(int r){
  static string N[] = {"None","Session","Regime","MTF","TrendStack","Angle34",
    "Outside34","WaveInvalid","Leg2Miss","SpreadCap","StopsLevel","SLExcess",
    "MinLot","Risk","Cooldown","Duplicate","Other"};
  return (r>=0 && r<ArraySize(N))?N[r]:"NA";
}

void BP_PrintSummary(){
  Print("==== BYPASS SUMMARY ====");
  for(int i=1;i<BP__COUNT;i++) if(gBP.cnt[i]>0)
    PrintFormat(" - %-12s: %d (%.1f%%)", BP_Name(i), (int)gBP.cnt[i], 100.0*gBP.cnt[i]/MathMax(1.0,gBP.candidates));
  Print("========================");
}

#define BP(reason,detail)  { BP_Hit(reason); if(InpDebugMode) PrintFormat("[BP] %s | %s", BP_Name(reason), detail); }

// Trace CSV (rút gọn MVP)
static int gTraceH = INVALID_HANDLE; static int gTraceD=0;
void TraceEnsure(){
  int d = (int)(TimeCurrent()/(24*60*60));
  if(gTraceH!=INVALID_HANDLE && d==gTraceD) return;
  if(gTraceH!=INVALID_HANDLE) FileClose(gTraceH);
  MqlDateTime md; TimeToStruct(TimeCurrent(), md);
  string fn=StringFormat("trace\\%s_%s_%04d%02d%02d.csv", _Symbol, EnumToString(TF_Signal()),
                         md.year, md.mon, md.day);
  gTraceH=FileOpen(fn, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
  if(gTraceH==INVALID_HANDLE){ Print("[TRACE] open failed: ", fn); return; }
  if(FileSize(gTraceH)==0){
    FileWrite(gTraceH,"time;bid;ask;spreadPts;ATR;EMA34;EMA89;EMA200;angle34;wave;leg2;SL;RR;size;G_session;G_spread;G_stops;reason;conf;pvsra");
  }
  gTraceD=d;
}
void TraceLine(const string reason,
               double atr,double ema34,double ema89,double ema200,double angle34,
               const string wave,double leg2,double SL,double RR,double size,
               bool g_session,bool g_spread,bool g_stops,
               double conf=0.0,double pvsra=0.0){
  TraceEnsure(); if(gTraceH==INVALID_HANDLE) return;
  double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID), ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
  int spr=(int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
  FileWrite(gTraceH, TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES), bid, ask, spr,
            atr, ema34, ema89, ema200, angle34, wave, leg2, SL, RR, size,
            (int)g_session,(int)g_spread,(int)g_stops, reason, conf, pvsra);
}

#endif // CORE_04_STATS_MQH


