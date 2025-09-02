#ifndef DAILY_LOSS_AND_POSITION_GATES_MQH
#define DAILY_LOSS_AND_POSITION_GATES_MQH
#include "01_Core_00_Inputs.mqh"
#include "01_Core_04_Stats.mqh"

// Minimal, local helpers for daily loss gate and max positions gate

static datetime g_dayStartTS = 0;
static double   g_dayStartEquity = 0.0;

inline void RM_ResetDayStart(){
    datetime now = TimeCurrent();
    MqlDateTime ds; TimeToStruct(now, ds);
    MqlDateTime d0 = ds; d0.hour=0; d0.min=0; d0.sec=0;
    g_dayStartTS = StructToTime(d0);
    g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
}

inline double RM_GetTodayRealizedPnL(string sym, long magic){
    if(g_dayStartTS==0) RM_ResetDayStart();
    datetime start = g_dayStartTS; datetime end = start + 24*60*60;
    HistorySelect(start, end);
    double pnl=0.0;
    int total = (int)HistoryDealsTotal();
    for(int i=total-1; i>=0; --i){
        ulong id = HistoryDealGetTicket(i);
        if((string)HistoryDealGetString(id, DEAL_SYMBOL) != sym) continue;
        if((long)HistoryDealGetInteger(id, DEAL_MAGIC) != magic) continue;
        int type = (int)HistoryDealGetInteger(id, DEAL_TYPE);
        if(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL){
            pnl += HistoryDealGetDouble(id, DEAL_PROFIT)
                 + HistoryDealGetDouble(id, DEAL_SWAP)
                 + HistoryDealGetDouble(id, DEAL_COMMISSION);
        }
    }
    return pnl;
}

inline bool RM_GateDailyLoss(string sym, long magic, double limitPct){
    if(limitPct<=0) return true;
    // Reset when day rolls
    MqlDateTime dsNow, dsStart; TimeToStruct(TimeCurrent(), dsNow); TimeToStruct(g_dayStartTS, dsStart);
    if(g_dayStartTS==0 || dsNow.day!=dsStart.day || dsNow.mon!=dsStart.mon || dsNow.year!=dsStart.year) RM_ResetDayStart();
    double realized = RM_GetTodayRealizedPnL(sym, magic);
    double lossPct = (realized<0 && g_dayStartEquity>0) ? (-realized / g_dayStartEquity * 100.0) : 0.0;
    if(lossPct > limitPct){ if(InpDebugMode) Print("[Gate-DailyLoss] Blocked: ", DoubleToString(lossPct,2), "% > ", DoubleToString(limitPct,2), "%"); Stat_Skip(SKIP_DAILY_LOSS); return false; }
    return true;
}

inline int RM_CountOpenPositions(string sym, long magic){
    int n=0; for(int i=0;i<PositionsTotal();++i){
        ulong t = PositionGetTicket(i);
        if(PositionSelectByTicket(t)){
            if(PositionGetString(POSITION_SYMBOL)==sym && PositionGetInteger(POSITION_MAGIC)==magic) n++;
        }
    }
    return n;
}

inline bool RM_GateMaxPositions(string sym, long magic, int maxPos){
    if(maxPos<=0) return true;
    int cur = RM_CountOpenPositions(sym, magic);
    if(cur >= maxPos){ if(InpDebugMode) Print("[Gate-MaxPos] Blocked: cur=", cur, " max=", maxPos); Stat_Skip(SKIP_MAX_POS); return false; }
    return true;
}

#endif // RM_DAILYLOSS_AND_POSITIONS_GATES_MQH

