#ifndef CORE_METRICS_MQH
#define CORE_METRICS_MQH

//+------------------------------------------------------------------+
//| BYPASS METRICS (global, lightweight)                             |
//+------------------------------------------------------------------+

enum eSkip {
   SKIP_NONE=0, SKIP_SESSION, SKIP_SPREAD, SKIP_COOLDOWN, SKIP_DAILY_LOSS, SKIP_MAX_POS,
   SKIP_REGIME, SKIP_MTF, SKIP_WAVE, SKIP_STOPS_TOO_CLOSE, SKIP_NO_MARGIN, SKIP_VOL_TOO_LOW,
   SKIP_BUILD_FAIL, SKIP_PENDING_EXISTS, SKIP_SYMBOL_DISABLED, SKIP_DUPLICATE, SKIP_OTHER,
   SKIP__COUNT
};

struct TStats {
   long skip[SKIP__COUNT];
   long sent, filled, failed;
   long ret_no_money, ret_invalid_stops, ret_other;
   double sumSLpx, sumTPpx;
};

static TStats gStats;

inline string SkipName(int r){
   static string N[SKIP__COUNT] = {
     "None","Session","Spread","Cooldown","DailyLoss","MaxPos",
     "Regime","MTF","Wave","StopsTooClose","NoMargin","VolTooLow",
     "BuildFail","PendingExists","SymbolDisabled","Duplicate","Other"
   };
   return (r>=0 && r<SKIP__COUNT)? N[r] : "NA";
}

inline void ResetStats(){
   for(int i=0;i<SKIP__COUNT;i++) gStats.skip[i]=0;
   gStats.sent=gStats.filled=gStats.failed=gStats.ret_no_money=gStats.ret_invalid_stops=gStats.ret_other=0;
   gStats.sumSLpx=0.0; gStats.sumTPpx=0.0;
}

inline void Stat_Skip(int reason){ if(reason>=0 && reason<SKIP__COUNT) gStats.skip[reason]++; }
inline void Stat_OrderSent(){ gStats.sent++; }
inline void Stat_OrderFilled(){ gStats.filled++; }
inline void Stat_OrderFailed(uint rc){ gStats.failed++; if(rc==TRADE_RETCODE_NO_MONEY) gStats.ret_no_money++; else if(rc==TRADE_RETCODE_INVALID_STOPS) gStats.ret_invalid_stops++; else gStats.ret_other++; }
inline void Stat_AddStops(double slpx, double tppx){ gStats.sumSLpx+=slpx; gStats.sumTPpx+=tppx; }

inline void PrintBypassSummary(){
   Print("========== BYPASS SUMMARY ==========");
   for(int i=1;i<SKIP__COUNT;i++) if(gStats.skip[i]>0) PrintFormat(" - %-16s: %d", SkipName(i), (int)gStats.skip[i]);
   PrintFormat("Orders: sent=%d filled=%d failed=%d | ret(NO_MONEY)=%d ret(INVALID_STOPS)=%d ret(other)=%d",
               (int)gStats.sent,(int)gStats.filled,(int)gStats.failed,(int)gStats.ret_no_money,(int)gStats.ret_invalid_stops,(int)gStats.ret_other);
   int denom = (gStats.sent>0 ? (int)gStats.sent : 1);
   PrintFormat("Avg SL(px)=%.5f  Avg TP(px)=%.5f", gStats.sumSLpx/denom, gStats.sumTPpx/denom);
   Print("====================================");
}

#endif // CORE_METRICS_MQH

