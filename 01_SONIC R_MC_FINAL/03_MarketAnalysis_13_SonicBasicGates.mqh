#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_00_Inputs.mqh"
#include "01_Core_03_DebugHelpers.mqh"
#include "01_Core_04_Stats.mqh"
// #include "Core_Config.mqh"  // removed (facade missing). Use getters from Inputs/ProfileOverrides.
#include "06_RiskManagement_17_DailyLossAndPositionGates.mqh"
// #include "Data_Providers.mqh" // removed (facade missing). Use 02_DataProviders_* includes.
#include "02_DataProviders_05_IndicatorManager.mqh"

extern int g_magicNumber;
double __CoreBalanced_DragonAngleMinDeg(){ return InpMinimalCoreMode ? 1.0 : InpDragonAngleMinDeg; }
double __CoreBalanced_RangeMaxPips2H(){ return InpMinimalCoreMode ? 50.0 : InpRangeMaxPips2H; }
bool   __CoreBalanced_WaveUseConsistency(){ return InpMinimalCoreMode ? false : InpWave_UseConsistency; }
double __CoreBalanced_WaveTolerancePips(){ return InpMinimalCoreMode ? 6.0 : InpWave_TolerancePips; }
double __CoreBalanced_SonicBasicRequireRR(){ return InpMinimalCoreMode ? 1.8 : InpSonicBasicRequireRR; } // keep for backward comp
// Asset-aware minimal SL floor (pip units, normalized to symbol)
double AssetMinSLPips(string sym)
{
    string s = sym;
    StringToUpper(s);
    if(StringFind(s, "XAU") >= 0) return 600.0;   // ~$6.00 on Gold (M15 baseline)
    if(StringFind(s, "XAG") >= 0) return 180.0;   // Silver baseline
    if(StringFind(s, "BTC") >= 0 || StringFind(s, "CRYPTO") >= 0) return 1000.0; // crypto baseline
    return 30.0; // majors default
}

// Trend stack gate: enforce EMA34/89/200 alignment in Sonic spirit
bool Gate_Sonic_TrendStack(bool isLong)
{
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h34 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 34, PRICE_CLOSE);
    int h89 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 89, PRICE_CLOSE);
    int h200= mgr.GetEMAHandle(_Symbol, PERIOD_M15,200, PRICE_CLOSE);
    if(h34==INVALID_HANDLE || h89==INVALID_HANDLE || h200==INVALID_HANDLE) return false;
    double e34[1], e89[1], e200[1];
    if(CopyBuffer(h34,0,0,1,e34)<1 || CopyBuffer(h89,0,0,1,e89)<1 || CopyBuffer(h200,0,0,1,e200)<1) return false;
    bool pass = isLong ? (e34[0]>e89[0] && e89[0]>e200[0]) : (e34[0]<e89[0] && e89[0]<e200[0]);
    if(InpDebugMode) DPrint(StringFormat("[Gate-TrendStack] pass=%d long=%d e34=%.2f e89=%.2f e200=%.2f", (int)pass, (int)isLong, e34[0], e89[0], e200[0]));
    return pass;
}

double __CoreBalanced_MinSLPips()
{
    // In MinimalCore, do NOT floor to tiny value; enforce asset-aware floor
    double base = InpMinSLPips;
    double assetFloor = AssetMinSLPips(_Symbol);
    return MathMax(base, assetFloor);
}
double __CoreBalanced_MaxSpreadPips(){ return InpMinimalCoreMode ? 60.0 : InpMaxSpreadPips; }
bool   __CoreBalanced_UseSessionGate(){ return InpMinimalCoreMode ? true : InpUseSessionGate; }
bool   __CoreBalanced_UseCustomSession(){ return InpMinimalCoreMode ? false : InpUseCustomSession; }


bool Gate_SonicBasic_Regime()
{
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h34 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 34, PRICE_CLOSE);
    if(h34==INVALID_HANDLE) return false;
    double ema34[6]; if(CopyBuffer(h34,0,0,6,ema34)<6) return false;
    double slope34 = ema34[0]-ema34[5];
    double angle = MathArctan(slope34/5.0) * 180.0/M_PI;
    bool passAngle = MathAbs(angle) >= __CoreBalanced_DragonAngleMinDeg();

    // Trend stack 34/89/200 alignment (Sonic spirit)
    int h89 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 89, PRICE_CLOSE);
    int h200= mgr.GetEMAHandle(_Symbol, PERIOD_M15,200, PRICE_CLOSE);
    if(h89==INVALID_HANDLE || h200==INVALID_HANDLE) return false;
    double e89[1], e200[1];
    if(CopyBuffer(h89,0,0,1,e89)<1 || CopyBuffer(h200,0,0,1,e200)<1) return false;
    bool passTrend = ((ema34[0]>e89[0] && e89[0]>e200[0]) || (ema34[0]<e89[0] && e89[0]<e200[0]));

    // 2-hour range: prefer ATR-based cap for robustness on XAU
    int bars2h = MathMax(8, (int)MathRound(120.0/((double)PeriodSeconds(PERIOD_M15))));
    double hi = iHigh(_Symbol, PERIOD_M15, 0);
    double lo = iLow(_Symbol, PERIOD_M15, 0);
    for(int i=1;i<bars2h && i<200;i++){ hi=MathMax(hi, iHigh(_Symbol, PERIOD_M15, i)); lo=MathMin(lo, iLow(_Symbol, PERIOD_M15, i)); }
    double pip = ((_Digits==3||_Digits==5)? 10*_Point : _Point);
    double rangePips = (hi-lo)/pip;

    // ATR-based normalization
    double atr = 0.0;
    double atrCapPips = 0.0;
    {
        CUnifiedIndicatorManager* um = CUnifiedIndicatorManager::GetInstance();
        int atrHandle = INVALID_HANDLE;
        if(um!=NULL) atrHandle = um.GetATRHandle(_Symbol, PERIOD_M15, InpATRPeriod);
        if(atrHandle==INVALID_HANDLE) atrHandle = iATR(_Symbol, PERIOD_M15, InpATRPeriod);
        double atrBuf[1];
        if(atrHandle!=INVALID_HANDLE && CopyBuffer(atrHandle,0,0,1,atrBuf)>0)
        {
            atr = atrBuf[0];
            double atrMult = InpRangeATRCapMult; // new input
            atrCapPips = MathMax(__CoreBalanced_RangeMaxPips2H(), (atr/pip) * atrMult);
        }
        else
        {
            atrCapPips = __CoreBalanced_RangeMaxPips2H();
        }
    }
    bool passRange = (rangePips <= atrCapPips);

    bool needTrend = InpRequireTrendStack;
    bool pass = passAngle && passRange && (needTrend ? passTrend : true);
    if(InpDebugMode && (!pass || false))
        DPrintBT(StringFormat("[Gate-Regime] angle=%.2f passA=%d needTrend=%d trend=%d range2h=%.1f cap=%.1f passR=%d => pass=%d",
                           angle, (int)passAngle, (int)needTrend, (int)passTrend, rangePips, atrCapPips, (int)passRange, (int)pass));
    return pass;
}

bool Gate_SonicBasic_MTF()
{
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h89_M15 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 89, PRICE_CLOSE);
    int h89_H1  = mgr.GetEMAHandle(_Symbol, PERIOD_H1,  89, PRICE_CLOSE);
    int h89_H4  = mgr.GetEMAHandle(_Symbol, PERIOD_H4,  89, PRICE_CLOSE);
    if(h89_M15==INVALID_HANDLE || h89_H1==INVALID_HANDLE || h89_H4==INVALID_HANDLE) return false;
    double e15[1], eH1[1], eH4[1];
    if(CopyBuffer(h89_M15,0,0,1,e15)<1 || CopyBuffer(h89_H1,0,0,1,eH1)<1 || CopyBuffer(h89_H4,0,0,1,eH4)<1) return false;
    double px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double w = 0;
    double scoreLong=0.0, scoreShort=0.0;
            if(PERIOD_M15==PERIOD_M15){
        scoreLong  += InpMTFWeight_M15 * ((px>e15[0])?1:0);
        scoreShort += InpMTFWeight_M15 * ((px<e15[0])?1:0);
        w += InpMTFWeight_M15;
    }
    scoreLong  += InpMTFWeight_H1 * ((px>eH1[0])?1:0);   scoreShort += InpMTFWeight_H1 * ((px<eH1[0])?1:0); w+=InpMTFWeight_H1;
    scoreLong  += InpMTFWeight_H4 * ((px>eH4[0])?1:0);   scoreShort += InpMTFWeight_H4 * ((px<eH4[0])?1:0); w+=InpMTFWeight_H4;
    double confLong  = (w>0? scoreLong/w  : 0);
    double confShort = (w>0? scoreShort/w : 0);
    double conf = MathMax(confLong, confShort);
    if(InpDebugMode && (! (conf>=InpMTFMinConfidence) || false))
        DPrintBT(StringFormat("[Gate-MTF] px=%.2f vs H1=%.2f H4=%.2f confL=%.2f confS=%.2f thr=%.2f", px, eH1[0], eH4[0], confLong, confShort, InpMTFMinConfidence));
    return conf>=InpMTFMinConfidence;
}

bool Gate_SonicBasic_Wave()
{
    CWaveDetectionResult res;
    if(!GetSonicWaveSignal(_Symbol, PERIOD_M15, res)) return false;
    double angMin = InpWave_AngleMinDeg; // human-like threshold
    bool pass = (res.direction!=SIGNAL_NONE) && (MathAbs(res.dragonAngleDeg) >= angMin);

    // MinimalCore: enforce Classic mini conditions (close outside Dragon + EMA89 alignment)
    if(InpMinimalCoreMode){
        CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
        int h34h=mgr.GetEMAHandle(_Symbol, PERIOD_M15, 34, PRICE_HIGH);
        int h34l=mgr.GetEMAHandle(_Symbol, PERIOD_M15, 34, PRICE_LOW);
        if(InpBrokerGMTOffset==0 && InpEnableSessionFilter){
            int autoOff = DetectBrokerGMTOffset();
            if(InpDebugMode) DPrintBT(StringFormat("[Session] Auto GMT offset=%d", autoOff));
        }
        int h34c=mgr.GetEMAHandle(_Symbol, PERIOD_M15, 34, PRICE_CLOSE);
        int h89c=mgr.GetEMAHandle(_Symbol, PERIOD_M15, 89, PRICE_CLOSE);
        double e34h[2], e34l[2], e34c[2], e89c[2];
        bool ok = (h34h!=INVALID_HANDLE&&h34l!=INVALID_HANDLE&&h34c!=INVALID_HANDLE&&h89c!=INVALID_HANDLE
                   && CopyBuffer(h34h,0,0,2,e34h)>=2 && CopyBuffer(h34l,0,0,2,e34l)>=2
                   && CopyBuffer(h34c,0,0,2,e34c)>=2 && CopyBuffer(h89c,0,0,2,e89c)>=2);
        if(ok){
            double c1 = iClose(_Symbol, PERIOD_M15, 1);
            bool outsideLong  = (c1 > e34h[1]);
            bool outsideShort = (c1 < e34l[1]);
            bool trendLong  = (e34c[1] > e89c[1]);
            bool trendShort = (e34c[1] < e89c[1]);
            bool angleOK = (MathAbs(res.dragonAngleDeg) >= InpWave_AngleMinDeg);
            bool passMC = ((res.direction==SIGNAL_BUY  && outsideLong  && trendLong  && angleOK) ||
                           (res.direction==SIGNAL_SELL && outsideShort && trendShort && angleOK));
            pass = pass && passMC;
            if(InpDebugMode && !passMC) DPrintBT("[Gate-Wave-MC] fail Classic-mini conditions");
        }
    }

    if(InpDebugMode && (!pass || false))
        DPrintBT(StringFormat("[Gate-Wave] dir=%d angle=%.2f score=%.2f thr=%.2f", (int)res.direction, res.dragonAngleDeg, res.score, angMin));
    return pass;
}

bool Gate_SonicBasic_SessionSpread()
{
    bool passSession = true;
    if(__CoreBalanced_UseSessionGate())
    {
        // In MinimalCore, allow by default; with custom window we still allow here (we just use relaxed mode)
        passSession = true;
    }
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    double pip = (digits==3||digits==5)? point*10.0 : point;
    double spreadPips = (SymbolInfoDouble(_Symbol, SYMBOL_ASK)-SymbolInfoDouble(_Symbol, SYMBOL_BID))/pip;
    bool passSpread = (spreadPips <= __CoreBalanced_MaxSpreadPips());
    bool pass = passSession && passSpread;
    if(!passSession) Stat_Skip(SKIP_SESSION);
    if(!passSpread)  Stat_Skip(SKIP_SPREAD);
    if(InpDebugMode && (!pass || false))
        DPrintBT(StringFormat("[Gate-SessionSpread] passS=%d spread=%.1f passSpr=%d", (int)passSession, spreadPips, (int)passSpread));
    return pass;
}

bool Gate_SonicBasic_Risk()
{
    // Use planned RR (fixed/adaptive) and realistic SL estimate from ATR to avoid false negatives on XAU
    double pip = ((_Digits==3||_Digits==5)? 10*_Point : _Point);
    double atrVal=0.0; int atr=iATR(_Symbol, PERIOD_M15, InpATRPeriod);
    double ab[1]; if(atr!=INVALID_HANDLE && CopyBuffer(atr,0,0,1,ab)>0) atrVal=ab[0];
    if(atrVal<=0) atrVal = 50.0*pip;
    double slPipsEst = MathMax(__CoreBalanced_MinSLPips(), (InpSL_ATR_Multiplier * (atrVal/pip)));
    double rrPlan = (InpRRMode==RR_FIXED? InpRiskReward : RR_Base());
    double rr = rrPlan; // planned RR used for gate
    bool pass = (rr >= __CoreBalanced_SonicBasicRequireRR());
    // Integrate daily loss and max positions gates (P0)
    if(pass){
        if(!RM_GateDailyLoss(_Symbol, g_magicNumber, InpDailyLossLimitPct)) pass=false;
        if(!RM_GateMaxPositions(_Symbol, g_magicNumber, InpMaxPositionsSymbol)) pass=false;
    }
    if(InpDebugMode && (!pass || false))
        DPrintBT(StringFormat("[Gate-Risk] rrPlan=%.2f slEst=%.1f (ATR=%.1f pips) thr=%.2f pass=%d", rrPlan, slPipsEst, (atrVal/pip), __CoreBalanced_SonicBasicRequireRR(), (int)pass));
    return pass;
}



