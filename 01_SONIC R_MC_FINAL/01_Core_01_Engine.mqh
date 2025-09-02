//+------------------------------------------------------------------+
//|                                                    01_Core_01_Engine.mqh |
//|                                    SONIC R MC - Core Engine Implementation |
//|                                                           Äáº¡i BÃ ng Architecture |
//+------------------------------------------------------------------+
#ifndef CORE_01_ENGINE_MQH
#define CORE_01_ENGINE_MQH

#include "01_Core_00_Inputs.mqh"
#include "05_Trading_03_TradeGate.mqh"

extern CTradeGate* g_tradeGate;

// Forward declaration for optional signal generator tracker
// Optional signal generator (guarded)
#define HAVE_SIGNAL_GENERATOR 0
class CSignalGenerator;
#if HAVE_SIGNAL_GENERATOR
extern CSignalGenerator* g_SignalGenerator;
#endif



//+------------------------------------------------------------------+
//| CORE ENGINE CLASS                                                |
//+------------------------------------------------------------------+
class CCoreEngine
{
private:
    bool m_initialized;
    bool m_useNewBarMode;

    // Simple performance counters
    int m_tickCount;
    int m_processedTicks;
    datetime m_lastProcessTime;

public:
    CCoreEngine() : m_initialized(false), m_useNewBarMode(true),
                    m_tickCount(0), m_processedTicks(0), m_lastProcessTime(0) {}
    ~CCoreEngine() { Deinitialize(); }

    bool Initialize()
    {
        m_initialized = true;
        m_tickCount = 0;
        m_processedTicks = 0;
        m_lastProcessTime = 0;
        if(!__isBT() || InpBacktestLogMode!=BT_LOG_OFF) Print("âœ… [CORE] Engine initialized - Performance monitoring enabled");
        return true;
    }

    void Deinitialize()
    {
        if(!m_initialized) return;

        // Print performance summary
        if(!__isBT() || InpBacktestLogMode!=BT_LOG_OFF) PrintPerformanceStats();

        // Reset flags
        m_initialized = false;
        if(!__isBT() || InpBacktestLogMode!=BT_LOG_OFF) Print("âœ… [CORE] Engine deinitialized");
    }

    void OnTick()
    {
        if (!m_initialized) return;

        m_tickCount++;
        datetime currentTime = TimeCurrent();

        // Simple throttling: minimum 1 second between processing
        if(currentTime - m_lastProcessTime < 1) {
            return;
        }

        // New-bar gating (optional)
        static datetime s_lastBarTime = 0;
        MqlRates rates[];
        int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 2, rates);
        if(copied >= 2)
        {
            datetime curBarTime = rates[0].time;
            bool isNewBar = (curBarTime != s_lastBarTime);
            if(!m_useNewBarMode || isNewBar)
            {
                s_lastBarTime = curBarTime;
                m_processedTicks++;
                m_lastProcessTime = currentTime;

                // Pre-flight: basic readiness
                if(!IsSystemReady()) return;

                // Signal generation and execution are handled in Main EA pipeline to avoid duplicate entries
                // (Engine retains performance monitoring only)
                // ENUM_SIGNAL_TYPE sig = SIGNAL_NONE;
                // if(g_SignalGenerator != NULL) {
                //     sig = g_SignalGenerator.GenerateSignal();
                // }
                // if(sig == SIGNAL_BUY) { /* handled in Main */ }
                // else if(sig == SIGNAL_SELL) { /* handled in Main */ }

                // Periodic performance logging (every 100 processed ticks)
                if(m_processedTicks % 100 == 0 && m_processedTicks > 0) {
                    PrintPerformanceStats();
                }
            }
        }
    }

    void OnTimer()
    {
        if (!m_initialized) return;

        // Timer-based operations
        Print("[CORE] Timer event processed");
    }

    bool IsInitialized() const { return m_initialized; }
    void SetNewBarMode(bool useNewBar) { m_useNewBarMode = useNewBar; }

    // Performance monitoring
    int GetTickCount() const { return m_tickCount; }
    int GetProcessedTicks() const { return m_processedTicks; }
    double GetProcessRatio() const {
        return m_tickCount > 0 ? (double)m_processedTicks / m_tickCount * 100 : 0;
    }

    void PrintPerformanceStats() {
        Print("[PERF] Ticks: ", m_tickCount, " | Processed: ", m_processedTicks,
              " | Ratio: ", DoubleToString(GetProcessRatio(), 1), "%");
    }

private:
    bool IsSystemReady()
    {
        if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return false;
        if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return false;
        if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return false;
        return true;
    }
};

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| RR Adaptive helper (global scope)                               |
//+------------------------------------------------------------------+
double ComputeAdaptiveRR(){
    if(InpRRMode==RR_FIXED) return PR_GetRR();
            int h_cur = iATR(_Symbol, PERIOD_M15, InpATRPeriod);
            int h_ref = iATR(_Symbol, PERIOD_H1, InpATRPeriod);
            double c[1], rbuf[]; ArrayResize(rbuf, 50);
    double cur=0, avg=0; if(h_cur!=INVALID_HANDLE && CopyBuffer(h_cur,0,0,1,c)>0) cur=c[0];
            int copied=(h_ref!=INVALID_HANDLE? CopyBuffer(h_ref,0,0,50,rbuf):0);
    if(copied>0){ for(int i=0;i<copied;i++) avg+=rbuf[i]; avg/=copied; }
    if(cur<=0 || avg<=0) return PR_GetRR();
    double ratio = cur/avg;
            double rr = InpRR_Base + 0.5*(ratio-1.0);
    return MathMax(InpRR_Min, MathMin(InpRR_Max, rr));
}

//| TRADE EXECUTION NAMESPACE                                        |
//+------------------------------------------------------------------+
namespace TradeExecution
{

    // Helper structures and functions for robust sizing and stops
    struct STPTrade { double sl; double tp; double sl_dist; double tp_dist; };

    double LossPerLotByDistance(const string sym, double dist_price){
        double tick = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
        double tv   = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
        if(tick<=0 || tv<=0) return 0.0;
        return (dist_price / tick) * tv;
    }
        // Cap volume by available margin with headroom buffer
        double CapByMargin(const string sym, ENUM_ORDER_TYPE typ, double price, double vol_in, double buffer)
        {
            double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
            double vmin = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
            double vmax = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
            if(step<=0) step=0.01;
            double vol = MathMax(vmin, MathMin(vmax, MathFloor(vol_in/step)*step));
            double free = AccountInfoDouble(ACCOUNT_MARGIN_FREE) * buffer;
            double margin=0.0;
            if(OrderCalcMargin(typ, sym, vol, price, margin) && margin<=free) return vol;
            // Estimate margin per lot and scale down
            double perLot = 0.0;
            if(OrderCalcMargin(typ, sym, MathMax(vmin,step), price, margin) && MathMax(vmin,step)>0) perLot = margin/MathMax(vmin,step);
            if(perLot>0.0){
                double cap = MathFloor((free/perLot)/step)*step;
                cap = MathMax(0.0, MathMin(vol, cap));
                return cap;
            }
            // Fallback decrement loop
            for(int i=0;i<200;i++){
                if(!OrderCalcMargin(typ, sym, vol, price, margin)) break;
                if(margin<=free) return vol;
                vol -= step; if(vol < vmin) break;
            }
            return 0.0;
        }

        // --- Sonic Classic helpers: recent swing high/low for leg #2 breakout ---
        bool FindRecentSwingHigh(const string sym, ENUM_TIMEFRAMES tf, int backstep, int lookbackBars, double &outPrice)
        {
            int avail = (int)Bars(sym, tf);
            if(avail < backstep+5) return false;
            int limit = MathMin(lookbackBars, avail-5);
            for(int i=backstep; i<limit; i++){
                double h = iHigh(sym, tf, i);
                bool isHigh=true;
                for(int k=1; k<=backstep; k++){
                    if(iHigh(sym, tf, i-k) >= h || iHigh(sym, tf, i+k) >= h){ isHigh=false; break; }
                }
                if(isHigh){ outPrice = h; return true; }
            }
            return false;
        }
        bool FindRecentSwingLow(const string sym, ENUM_TIMEFRAMES tf, int backstep, int lookbackBars, double &outPrice)
        {
            int avail = (int)Bars(sym, tf);
            if(avail < backstep+5) return false;
            int limit = MathMin(lookbackBars, avail-5);
            for(int i=backstep; i<limit; i++){
                double l = iLow(sym, tf, i);
                bool isLow=true;
                for(int k=1; k<=backstep; k++){
                    if(iLow(sym, tf, i-k) <= l || iLow(sym, tf, i+k) <= l){ isLow=false; break; }
                }
                if(isLow){ outPrice = l; return true; }
            }
            return false;
        }


        bool VolumeByRisk(const string sym, ENUM_ORDER_TYPE typ, double risk_money,
                             double sl_dist_price, double price, double &vol_out)
    {
        double eq = AccountInfoDouble(ACCOUNT_EQUITY);
        double riskPercent = (eq>0 ? (risk_money/eq)*100.0 : 0.0);
        double lots = CalcLots_RiskAndMargin(typ, price, (typ==ORDER_TYPE_BUY? price-sl_dist_price: price+sl_dist_price), riskPercent);
        if(lots<=0.0) return false;
        vol_out = lots;
        return true;
    }

    void BuildStops(const string sym, bool isBuy, double entry, double atr_price,
                           double rr, double min_sl_price, STPTrade &o)
    {
        double point = SymbolInfoDouble(sym, SYMBOL_POINT);
        int    stops_pt = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
        double stop_min = stops_pt * point;
        double spread_px = (double)SymbolInfoInteger(sym, SYMBOL_SPREAD) * point;
        double sl_floor = MathMax(min_sl_price, MathMax(atr_price, stop_min + 0.5*spread_px));
        o.sl_dist = sl_floor; o.tp_dist = rr * sl_floor;
        o.sl = isBuy? (entry - o.sl_dist) : (entry + o.sl_dist);
        o.tp = isBuy? (entry + o.tp_dist) : (entry - o.tp_dist);
        double tick = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
        if(tick>0){ o.sl = MathRound(o.sl/tick)*tick; o.tp = MathRound(o.tp/tick)*tick; }
    }

    bool ExecuteBuyOrder()
    {
        // Check trade gate
        if(g_tradeGate != NULL && !g_tradeGate->IsTradingAllowed()) {
            Print("[TRADE] Trade blocked by gate: ", g_tradeGate->GetLastRejectionReason());
            return false;
        }

        // Dynamic SL/TP via standardized BuildStops (ATR + StopsLevel + Spread + Asset floor)
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        double rr_use = ComputeAdaptiveRR();
        STops st={0};
        if(!::BuildStops(ORDER_TYPE_BUY, ask, rr_use, InpATRPeriod, InpSL_ATR_Multiplier, st)){
            Print("[TRADE] Reject BUY: BuildStops failed (stops too close)");
            return false;
        }

        // Prepare trade request
        MqlTradeRequest request = {}; MqlTradeResult result = {};
        // Stats: record planned SL/TP distances
        Stat_AddStops(st.slDist, st.tpDist);
        Stat_OrderSent();

        request.action = TRADE_ACTION_DEAL; request.symbol = _Symbol; request.type = ORDER_TYPE_BUY;
        request.price = ask; request.sl = st.sl; request.tp = st.tp; request.deviation = 5;
        request.magic = g_magicNumber; request.comment = "SonicR MC Buy";

        // Risk sizing by monetary risk with margin preflight
        double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * (InpRiskPercent/100.0);
        double vol=0.0;
        // Audit pre-calcs
        double loss1lot_BUY = LossPerLotByDistance(_Symbol, st.slDist);
        double step_BUY = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
        double vmin_BUY = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double vmax_BUY = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        if(step_BUY<=0) step_BUY=0.01;
        double vol_risk_BUY = (loss1lot_BUY>0? riskMoney/loss1lot_BUY : 0.0);
        vol_risk_BUY = MathMax(vmin_BUY, MathMin(vmax_BUY, MathFloor(vol_risk_BUY/step_BUY)*step_BUY));
        double free_BUY = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        double req_BUY = 0.0; if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, MathMax(vmin_BUY, vol_risk_BUY), request.price, req_BUY)) req_BUY=0.0;
        double vol_cap_BUY = CapByMargin(_Symbol, ORDER_TYPE_BUY, request.price, vol_risk_BUY, 0.85);
        PrintFormat("[AUDIT] BUY risk=%.2f$ loss1lot=%.2f vol_risk=%.2f vol_cap=%.2f free=%.2f req@risk=%.2f",
                    riskMoney, loss1lot_BUY, vol_risk_BUY, vol_cap_BUY, free_BUY, req_BUY);
        if(!VolumeByRisk(_Symbol, ORDER_TYPE_BUY, riskMoney, st.slDist, request.price, vol)){
            PrintFormat("[BYPASS] BUY volume calc failed: risk=%.2f slDist=%.2f loss1lot=%.2f step=%.2f free=%.2f", riskMoney, st.slDist, loss1lot_BUY, step_BUY, free_BUY);
            return false;
        }
        request.volume = vol;

        // Preflight Stops/Freeze levels sanity
        int stops_pt = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
        int freeze_pt= (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
        double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
        double stops_px = stops_pt*point, freeze_px=freeze_pt*point;
        if((request.price - request.sl) < (stops_px+point) || (request.tp - request.price) < (stops_px+point)){
            Print("[TRADE] Reject BUY: stops too close (StopsLevel)"); Stat_Skip(SKIP_STOPS_TOO_CLOSE); return false;
        }
        if((request.price - request.sl) < (freeze_px+point) || (request.tp - request.price) < (freeze_px+point)){
            Print("[TRADE] Reject BUY: stops too close (FreezeLevel)"); Stat_Skip(SKIP_STOPS_TOO_CLOSE); return false;
        }

        // Execution mode: send market or place Sonic Classic pending stop
        bool sent = false;
        if(InpExecutionMode == EXEC_MARKET) {
            sent = OrderSend(request, result);
        } else {
            // Classic: place pending stop beyond leg #2 (use recent swing high + offset)
            // If pivot stale or from different bar, ignore
            if(g_haveLastWavePivots && g_lastWaveBarTime!=iTime(_Symbol, PERIOD_M15, 0)) { g_haveLastWavePivots=false; }

            double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            double pip = (digits==3||digits==5)? 10.0*point : point;
            double off = InpClassicPendingOffsetPips * pip;
            double swingHigh=0.0; bool haveHigh=false;
            if(g_haveLastWavePivots && g_lastWaveLeg2Price>0.0){ swingHigh=g_lastWaveLeg2Price; haveHigh=true; }
            else { haveHigh=FindRecentSwingHigh(_Symbol, PERIOD_M15, 3, 80, swingHigh); }
            if(InpDebugMode) Print(StringFormat("[ClassicPending-BUY] leg2=%.2f have=%d off=%.1f pend=%.2f (stale=%d)",
                swingHigh, (int)haveHigh, InpClassicPendingOffsetPips, (haveHigh? MathMax(swingHigh+off, request.price+off): request.price+off), (int)!g_haveLastWavePivots));

            double pendPrice = (haveHigh? MathMax(swingHigh+off, request.price+off) : request.price+off);
            MqlTradeRequest preq = request; preq.action = TRADE_ACTION_PENDING; preq.type = ORDER_TYPE_BUY_STOP;
            preq.price = pendPrice;
            sent = OrderSend(preq, result);
        }
        PrintFormat("[TRADE] BUY send=%d rc=%u deal=%I64u order=%I64u comment=%s",
                    (int)sent, result.retcode, result.deal, result.order, result.comment);
        if(sent && (result.retcode == TRADE_RETCODE_DONE || result.retcode==TRADE_RETCODE_PLACED)) {
            // success: mark filled
            Stat_OrderFilled();
        if(result.retcode==TRADE_RETCODE_NO_MONEY){
            double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
            double tickVal=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
                Stat_OrderSent();

            PrintFormat("[EXEC|NO_MONEY] BUY vol=%.2f slDist=%.2f tickVal=%.2f free=%.2f", request.volume, st.slDist, tickVal, free);
        }

            Print("âœ… [TRADE] BUY executed | Ticket: ", result.order,
                  " | Size: ", DoubleToString(request.volume, 2),
                  " | Price: ", DoubleToString(ask, _Digits));
            g_daily_trades++;
            g_tradesThisBar++;
            if(g_tradeGate != NULL) g_tradeGate->OnPositionOpen();
            #if HAVE_SIGNAL_GENERATOR
            if(g_SignalGenerator != NULL) g_SignalGenerator->UpdateSignalResult(true);
            #endif
        } else {
            #if HAVE_SIGNAL_GENERATOR
            if(g_SignalGenerator != NULL) g_SignalGenerator->UpdateSignalResult(false);
            #endif
            // Auto-retry when stops invalid: widen to FreezeLevel + buffer and retry once
            if(result.retcode==TRADE_RETCODE_INVALID_STOPS)
            {
                int freeze = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
                double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                double widen = MathMax(st.slDist, freeze*point + 2*point);
                // Rebuild stops by increasing ATR multiplier slightly (fallback)
                STops st_retry={0}; double rr_retry=ComputeAdaptiveRR();
                if(::BuildStops(ORDER_TYPE_BUY, ask, rr_retry, InpATRPeriod, InpSL_ATR_Multiplier*1.10, st_retry)){
                    request.sl = st_retry.sl; request.tp = st_retry.tp;
                }
                MqlTradeResult r2 = {};
                bool s2 = OrderSend(request, r2);
                PrintFormat("[TRADE] BUY retry send=%d rc=%u deal=%I64u order=%I64u comment=%s",(int)s2,r2.retcode,r2.deal,r2.order,r2.comment);
                if(s2 && (r2.retcode==TRADE_RETCODE_DONE || r2.retcode==TRADE_RETCODE_PLACED)){
                        Stat_OrderFilled();
                    Print("âœ… [TRADE] BUY executed (retry) | Ticket: ", r2.order,
                          " | Size: ", DoubleToString(request.volume, 2),
                          " | Price: ", DoubleToString(ask, _Digits));
                    g_daily_trades++; g_tradesThisBar++;
                    if(g_tradeGate != NULL) g_tradeGate->OnPositionOpen();
                    #if HAVE_SIGNAL_GENERATOR
                    if(g_SignalGenerator != NULL) g_SignalGenerator->UpdateSignalResult(true);
                    #endif
                    return true;
                }
            }
            // Retry with downsize if NO_MONEY
            if(result.retcode==TRADE_RETCODE_NO_MONEY)
            {
                double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
                double cap = CapByMargin(_Symbol, ORDER_TYPE_BUY, request.price, request.volume, 0.80);
                if(cap>=vmin && cap<request.volume){
                    request.volume = cap;
                    MqlTradeResult r3={}; bool s3=OrderSend(request,r3);
                    PrintFormat("[TRADE] BUY retry(no-money) send=%d rc=%u vol=%.2f",(int)s3,r3.retcode,request.volume);
                    if(s3 && (r3.retcode==TRADE_RETCODE_DONE || r3.retcode==TRADE_RETCODE_PLACED)){
                        Stat_OrderFilled();
                        g_daily_trades++; g_tradesThisBar++; if(g_tradeGate!=NULL) g_tradeGate->OnPositionOpen();
                        #if HAVE_SIGNAL_GENERATOR
                        if(g_SignalGenerator!=NULL) g_SignalGenerator->UpdateSignalResult(true);
                        #endif
                        return true;
                    } else {
                        Stat_OrderFailed(r3.retcode);
                    }
                }
            }

        }
            return (sent && (result.retcode == TRADE_RETCODE_DONE || result.retcode==TRADE_RETCODE_PLACED));
    }

    bool ExecuteSellOrder()
    {
        // Check trade gate
        if(g_tradeGate != NULL && !g_tradeGate->IsTradingAllowed()) {
            Print("[TRADE] Trade blocked by gate: ", g_tradeGate->GetLastRejectionReason());
            return false;
        }

        // SELL path: robust sizing and dynamic stops will be set below
        // Prepare trade request structure for SELL
        MqlTradeRequest request = {};
        MqlTradeResult  result  = {};
        Stat_OrderSent();
        request.action   = TRADE_ACTION_DEAL;
        request.symbol   = _Symbol;
        request.type     = ORDER_TYPE_SELL;
        request.deviation= 5;
        request.magic    = g_magicNumber;
        request.comment  = "SonicR MC Sell";


        // Dynamic SL/TP via ATR + StopsLevel + Spread buffer (SELL)
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double point2 = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
        int    digits2 = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
        double pip2 = (digits2==3||digits2==5)? 10.0*point2 : point2;
        double rr_use2 = ComputeAdaptiveRR();
        STops st2={0};
        if(!::BuildStops(ORDER_TYPE_SELL, bid, rr_use2, InpATRPeriod, InpSL_ATR_Multiplier, st2)){
            Print("[TRADE] Reject SELL: BuildStops failed (stops too close)");
            return false;
        }
        request.price = bid; request.sl = st2.sl; request.tp = st2.tp;

        double riskMoney2=AccountInfoDouble(ACCOUNT_BALANCE)*(InpRiskPercent/100.0); double vol2=0.0;
        // Audit pre-calcs
        double loss1lot_SELL = LossPerLotByDistance(_Symbol, st2.slDist);
        double step_SELL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
        double vmin_SELL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double vmax_SELL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        if(step_SELL<=0) step_SELL=0.01;
        double vol_risk_SELL = (loss1lot_SELL>0? riskMoney2/loss1lot_SELL : 0.0);
        vol_risk_SELL = MathMax(vmin_SELL, MathMin(vmax_SELL, MathFloor(vol_risk_SELL/step_SELL)*step_SELL));
        double free_SELL = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        double req_SELL = 0.0; if(!OrderCalcMargin(ORDER_TYPE_SELL, _Symbol, MathMax(vmin_SELL, vol_risk_SELL), request.price, req_SELL)) req_SELL=0.0;
        double vol_cap_SELL = CapByMargin(_Symbol, ORDER_TYPE_SELL, request.price, vol_risk_SELL, 0.85);
        PrintFormat("[AUDIT] SELL risk=%.2f$ loss1lot=%.2f vol_risk=%.2f vol_cap=%.2f free=%.2f req@risk=%.2f",
                    riskMoney2, loss1lot_SELL, vol_risk_SELL, vol_cap_SELL, free_SELL, req_SELL);
        if(!VolumeByRisk(_Symbol, ORDER_TYPE_SELL, riskMoney2, st2.slDist, request.price, vol2)){
            Print("[TRADE] Reject SELL: insufficient margin for minimal volume by risk"); return false; }
        request.volume = vol2;

        int stops_pt2=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL); int freeze_pt2=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL); double stops_px2=stops_pt2*point2, freeze_px2=freeze_pt2*point2;
        if((request.sl - request.price) < (stops_px2+point2) || (request.price - request.tp) < (stops_px2+point2)){ Print("[TRADE] Reject SELL: stops too close (StopsLevel)"); Stat_Skip(SKIP_STOPS_TOO_CLOSE); return false; }
        if((request.sl - request.price) < (freeze_px2+point2) || (request.price - request.tp) < (freeze_px2+point2)){ Print("[TRADE] Reject SELL: stops too close (FreezeLevel)"); Stat_Skip(SKIP_STOPS_TOO_CLOSE); return false; }

        bool sent2=false;
            // If pivot stale or from different bar, ignore
            if(g_haveLastWavePivots && g_lastWaveBarTime!=iTime(_Symbol, PERIOD_M15, 0)) { g_haveLastWavePivots=false; }

        if(InpExecutionMode == EXEC_MARKET){
            sent2=OrderSend(request,result);
        } else {
            double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            double pip = (digits==3||digits==5)? 10.0*point : point;
            double off = InpClassicPendingOffsetPips * pip;

            double swingLow=0.0; bool haveLow=false;
            if(g_haveLastWavePivots && g_lastWaveLeg2Price>0.0){ swingLow=g_lastWaveLeg2Price; haveLow=true; }
            else { haveLow=FindRecentSwingLow(_Symbol, PERIOD_M15, 3, 80, swingLow); }
            if(InpDebugMode) Print(StringFormat("[ClassicPending-SELL] leg2=%.2f have=%d off=%.1f pend=%.2f (stale=%d)",
                swingLow, (int)haveLow, InpClassicPendingOffsetPips, (haveLow? MathMin(swingLow-off, request.price-off): request.price-off), (int)!g_haveLastWavePivots));

            // off already defined above
            double pendPrice = (haveLow? MathMin(swingLow-off, request.price-off) : request.price-off);
            MqlTradeRequest preq = request; preq.action = TRADE_ACTION_PENDING; preq.type = ORDER_TYPE_SELL_STOP;
            preq.price = pendPrice;
            sent2=OrderSend(preq,result);
        }
        PrintFormat("[TRADE] SELL send=%d rc=%u deal=%I64u order=%I64u comment=%s",(int)sent2,result.retcode,result.deal,result.order,result.comment);
    if(result.retcode==TRADE_RETCODE_NO_MONEY){
            double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
            double tickVal=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
            PrintFormat("[EXEC|NO_MONEY] SELL vol=%.2f slDist=%.2f tickVal=%.2f free=%.2f", request.volume, st2.slDist, tickVal, free);
            Stat_OrderFailed(result.retcode);
        }

        if(!sent2 || (result.retcode!=TRADE_RETCODE_DONE && result.retcode!=TRADE_RETCODE_PLACED))
        {
            // Auto-retry for INVALID_STOPS by widening to FreezeLevel + small buffer
            if(result.retcode==TRADE_RETCODE_INVALID_STOPS)
            {
                int freeze = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
                double freezePx = freeze*point2;
                double widen = MathMax(st2.slDist, freezePx + 2*point2);
                STops st2_retry={0}; double rr_retry2=ComputeAdaptiveRR();
                if(::BuildStops(ORDER_TYPE_SELL, bid, rr_retry2, InpATRPeriod, InpSL_ATR_Multiplier*1.10, st2_retry)){
                    request.sl = st2_retry.sl; request.tp = st2_retry.tp;
                }
                MqlTradeResult result2 = {};
                bool sentRetry = OrderSend(request, result2);
                PrintFormat("[TRADE] SELL retry send=%d rc=%u deal=%I64u order=%I64u comment=%s",(int)sentRetry,result2.retcode,result2.deal,result2.order,result2.comment);
                if(sentRetry && (result2.retcode==TRADE_RETCODE_DONE || result2.retcode==TRADE_RETCODE_PLACED)){
                    Stat_OrderFilled();
                    Print("… [TRADE] SELL executed (retry) | Ticket: ", result2.order, " | Size: ", DoubleToString(request.volume,2), " | Price: ", DoubleToString(request.price,_Digits));
                    g_daily_trades++; g_tradesThisBar++; if(g_tradeGate!=NULL) g_tradeGate->OnPositionOpen();
                    #if HAVE_SIGNAL_GENERATOR
                    if(g_SignalGenerator!=NULL) g_SignalGenerator->UpdateSignalResult(true);
                    #endif
                    return true;
                } else {
                    Stat_OrderFailed(result2.retcode);
                }
            }
            // Retry with downsize if NO_MONEY
            if(result.retcode==TRADE_RETCODE_NO_MONEY)
            {
                double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
                double cap = CapByMargin(_Symbol, ORDER_TYPE_SELL, request.price, request.volume, 0.80);
                if(cap>=vmin && cap<request.volume){
                    request.volume = cap;
                    MqlTradeResult r3={}; bool s3=OrderSend(request,r3);
                    PrintFormat("[TRADE] SELL retry(no-money) send=%d rc=%u vol=%.2f",(int)s3,r3.retcode,request.volume);
                    if(s3 && (r3.retcode==TRADE_RETCODE_DONE || r3.retcode==TRADE_RETCODE_PLACED)){
                        Stat_OrderFilled();
                        g_daily_trades++; g_tradesThisBar++; if(g_tradeGate!=NULL) g_tradeGate->OnPositionOpen();
                        #if HAVE_SIGNAL_GENERATOR
                        if(g_SignalGenerator!=NULL) g_SignalGenerator->UpdateSignalResult(true);
                        #endif
                        return true;
                    } else {
                        Stat_OrderFailed(r3.retcode);
                    }
                }
            }
            #if HAVE_SIGNAL_GENERATOR
            if(g_SignalGenerator!=NULL) g_SignalGenerator->UpdateSignalResult(false);
            #endif
            return false;
        }

        // success first-shot
        Print("âœ… [TRADE] SELL executed | Ticket: ", result.order, " | Size: ", DoubleToString(request.volume,2), " | Price: ", DoubleToString(request.price,_Digits));
    g_daily_trades++; g_tradesThisBar++; if(g_tradeGate!=NULL) g_tradeGate->OnPositionOpen();
    #if HAVE_SIGNAL_GENERATOR
    if(g_SignalGenerator!=NULL) g_SignalGenerator->UpdateSignalResult(true);
    #endif
            return true;

    }
} // namespace TradeExecution

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES DECLARATIONS                                    |
//+------------------------------------------------------------------+
// Ownership of g_coreEngine is standardized in Main EA. Use extern here.
extern CCoreEngine* g_coreEngine;

#endif // CORE_01_ENGINE_MQH
