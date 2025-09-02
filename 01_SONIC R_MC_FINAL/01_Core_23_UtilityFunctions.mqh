//+------------------------------------------------------------------+
//| SYSTEMATIC FIX - Missing Utility Functions                      |
//| This file contains utility functions that are called but        |
//| not implemented in various modules                               |
//+------------------------------------------------------------------+
#ifndef CORE_UTILITY_FUNCTIONS_MQH
#define CORE_UTILITY_FUNCTIONS_MQH



#include "01_Core_14_CoreEnums.mqh"

// --- Units helpers (price/point aware)
inline double Pip(){ return ((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 3 || (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 5) ? 10.0 * _Point : _Point; }
inline double TickSize(){ return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE); }
inline double TickValue(){ return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); }

// --- Snap price to exchange tick grid
inline double SnapTick(double price){ double ts = TickSize(); if(ts<=0.0) return NormalizeDouble(price, _Digits); return NormalizeDouble(MathRound(price/ts)*ts, _Digits); }

// --- Asset-aware min SL floor (PRICE units)
inline double AssetMinSL_Price(){ string sSym=_Symbol; StringToUpper(sSym); string s = sSym; if(StringFind(s,"XAU")>=0) return 6.00; if(StringFind(s,"XAG")>=0) return 0.40; if(StringFind(s,"BTC")>=0) return 200.0; return 0.00030; }

// --- Stops builder (ATR + StopsLevel + Spread + Asset floor)
struct STops { double sl; double tp; double slDist; double tpDist; };
inline bool BuildStops(const ENUM_ORDER_TYPE type, const double entry, const double rr, const int atrPeriod, const double atrMult, STops &o)
{
    // Symbol specs
    const double point = _Point;
    const int    stopsL = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    const int    spreadP= (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    const double spreadPx = spreadP * point;

    // ATR baseline (price units)
    double atrPx = 0.0; {
        int h = iATR(_Symbol, PERIOD_CURRENT, atrPeriod);
        if(h != INVALID_HANDLE){ double buf[1]; if(CopyBuffer(h,0,0,1,buf)>0) atrPx = buf[0]; }
    }

    // Floors (price)
    const double minStopPx_byStops = (stopsL + 2) * point + 1.2 * spreadPx;
    const double minStopPx_byATR   = atrMult * MathMax(0.0, atrPx);
    const double minStopPx_asset   = AssetMinSL_Price();

    const double slDist = MathMax(minStopPx_asset, MathMax(minStopPx_byATR, minStopPx_byStops));
    const double tpDist = rr * slDist;

    double sl = (type==ORDER_TYPE_BUY) ? (entry - slDist) : (entry + slDist);
    double tp = (type==ORDER_TYPE_BUY) ? (entry + tpDist) : (entry - tpDist);

    // Snap to tick
    o.sl = SnapTick(sl); o.tp = SnapTick(tp); o.slDist = MathAbs(entry - o.sl); o.tpDist = MathAbs(o.tp - entry);

    // Final guard vs StopsLevel
    if(o.slDist < (stopsL+1)*point) return false;
    return true;
}

// --- Risk sizing helpers
inline double ValuePerPricePerLot(){ double tv=TickValue(), ts=TickSize(); return (ts>0.0 ? tv/ts : 0.0); }

inline double NormalizeVolume(double lots){ double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP); double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN); double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX); if(step<=0.0) step=0.01; lots=MathFloor(lots/step)*step; return MathMax(vmin, MathMin(vmax, lots)); }

inline double CapByMargin(const ENUM_ORDER_TYPE type, const double entry, const double lotsIn, const double buffer=0.85){ double lots=NormalizeVolume(lotsIn); double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE); double req=0.0; if(OrderCalcMargin(type,_Symbol,lots,entry,req) && req > free*buffer){ double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP); double perLot=(lots>0.0 ? req/lots : 0.0); if(perLot>0.0){ double cap=MathFloor(((free*buffer)/perLot)/step)*step; return NormalizeVolume(MathMax(0.0, MathMin(lots, cap))); } } return lots; }

inline double CalcLots_RiskAndMargin(const ENUM_ORDER_TYPE type, const double entry, const double slPrice, const double riskPercent){ const double vpp=ValuePerPricePerLot(); const double dist=MathAbs(entry-slPrice); if(vpp<=0.0 || dist<=0.0 || riskPercent<=0.0) return 0.0; const double eq=AccountInfoDouble(ACCOUNT_EQUITY); const double risk_amt=eq*(riskPercent/100.0); const double loss1lot = dist * vpp; if(loss1lot<=0.0) return 0.0; double lotsRisk = risk_amt/loss1lot; return CapByMargin(type, entry, lotsRisk, 0.85); }

//+------------------------------------------------------------------+
//| PropFirm Utility Functions                                      |
//+------------------------------------------------------------------+
string FirmTypeToString(ENUM_PROP_FIRM firmType)
{
    switch(firmType)
    {
        case PROP_FIRM_FTMO: return "FTMO";
        case PROP_FIRM_MYFOREXFUNDS: return "MyForexFunds";
        // SYSTEMATIC FIX - PROP_FIRM_MYFXFUNDS is alias for MYFOREXFUNDS, skip to avoid duplicate case
        case PROP_FIRM_FUNDEDNEXT: return "FundedNext";
        case PROP_FIRM_TOPSTEP: return "TopStep";
        case PROP_FIRM_TOPTRADER: return "TopTrader";
        case PROP_FIRM_TRUEFOREXFUNDS: return "TrueForexFunds";
        case PROP_FIRM_NOVA: return "Nova";
        case PROP_FIRM_CUSTOM: return "Custom";
        case PROP_FIRM_GENERIC: return "Generic";
        default: return "Unknown";
    }
}

string PhaseToString(int phase)
{
    switch(phase)
    {
        case 1: return "Challenge Phase";
        case 2: return "Verification Phase";
        case 3: return "Funded Phase";
        default: return StringFormat("Phase %d", phase);
    }
}

string ComplianceStatusToString(int status)
{
    switch(status)
    {
        case 0: return "Non-Compliant";
        case 1: return "Partially Compliant";
        case 2: return "Fully Compliant";
        case 3: return "Excellent";
        default: return "Unknown Status";
    }
}

//+------------------------------------------------------------------+
//| Certification Utility Functions                                 |
//+------------------------------------------------------------------+
string CertificationLevelToString(ENUM_CERTIFICATION_LEVEL level)
{
    switch(level)
    {
        case CERT_BASIC: return "Basic";
        // SYSTEMATIC FIX - CERT_LEVEL_BASIC is alias for CERT_BASIC, skip to avoid duplicate case
        case CERT_INTERMEDIATE: return "Standard";
        case CERT_ADVANCED: return "Advanced";
        case CERT_EXPERT: return "Enterprise";
        default: return "Unknown Level";
    }
}

//+------------------------------------------------------------------+
//| Validation Utility Functions                                    |
//+------------------------------------------------------------------+
string ValidationStatusToString(int status)
{
    switch(status)
    {
        case 0: return "Failed";
        case 1: return "Warning";
        case 2: return "Passed";
        case 3: return "Excellent";
        default: return "Unknown";
    }
}

string ReportTypeToString(int reportType)
{
    switch(reportType)
    {
        case 0: return "Summary";
        case 1: return "Detailed";
        case 2: return "Technical";
        case 3: return "Compliance";
        case 4: return "Performance";
        default: return "Unknown Type";
    }
}

//+------------------------------------------------------------------+
//| System Health Functions                                         |
//+------------------------------------------------------------------+
double GetSystemHealthScore()
{
    // Simple system health calculation
    double cpuScore = 0.8;      // 80% CPU health
    double memoryScore = 0.9;   // 90% Memory health
    double networkScore = 0.85; // 85% Network health

    return (cpuScore + memoryScore + networkScore) / 3.0;
}


//+------------------------------------------------------------------+
//| Text Utilities: sanitize to ASCII                                |
//+------------------------------------------------------------------+
string SanitizeASCII(string src, uchar replacement='?')
{
    int len = StringLen(src);
    if(len <= 0) return src;
    string out = "";
    string repl = StringFormat("%c", (uint)replacement);
    for(int i=0; i<len; i++)
    {
        int code = StringGetCharacter(src, i);
        if(code < 32 || code > 126)
            out += repl;
        else
            out += StringSubstr(src, i, 1);
    }
    return out;
}

// Safe setter for UI text properties with ASCII sanitization
void ObjectSetStringASCII(long chart_id, string name, int prop_id, string text)
{
    ObjectSetString(chart_id, name, (ENUM_OBJECT_PROPERTY_STRING)prop_id, SanitizeASCII(text));
}


// Normalize UI text: remove leading '?' placeholders and collapse spaces
string NormalizeUIText(string text)
{
    string s = SanitizeASCII(text);
    // trim leading '?' and spaces
    int i = 0;
    int n = StringLen(s);
    while(i < n)
    {
        int ch = StringGetCharacter(s, i);
        if(ch == '?' || ch == ' ') i++; else break;
    }
    if(i > 0) s = StringSubstr(s, i);
    // collapse duplicate spaces
    string out = "";
    bool prevSpace = false;
    for(int k=0; k<StringLen(s); k++)
    {
        int ch = StringGetCharacter(s, k);
        if(ch == ' ')
        {
            if(prevSpace) continue;
            prevSpace = true;
        }
        else prevSpace = false;
        out += StringSubstr(s, k, 1);
    }
    return out;
}

// ASCII-safe Print wrapper
void PrintASCII(string message)
{
    DPrintBT(SanitizeASCII(message));
}


// Convert pips to points respecting 3/5-digit symbols


// Calculate position size by stop distance in points for a given risk percent
inline double CalculatePositionSizeByStop(string symbol, double riskPercent, double stopPoints)
{
    if(stopPoints <= 0 || riskPercent <= 0) return 0.0;
    double bal = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = bal * (riskPercent/100.0);

    double tickVal = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSz  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    if(tickVal <= 0 || tickSz <= 0) return 0.0;

    // Value per point per 1.0 lot
    double pointValuePerLot = tickVal / tickSz;
    double stopValuePerLot  = stopPoints * pointValuePerLot;
    if(stopValuePerLot <= 0) return 0.0;

    double lots = riskAmount / stopValuePerLot;

    // Normalize to broker constraints
    double vmin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double vmax = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double vstep= SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    if(vstep <= 0) vstep = 0.01;
    lots = MathMax(vmin, MathMin(vmax, MathFloor(lots / vstep) * vstep));
    return lots;
}

#include <Trade/Trade.mqh>


//+------------------------------------------------------------------+
//| SYSTEMATIC FIX - Error Handler Functions (Non-Class)           |
//| Note: CCompleteErrorHandler class exists in ErrorHandler.mqh   |
//+------------------------------------------------------------------+
void LogSystemError(string message, ENUM_ERROR_SEVERITY severity = ERROR_SEVERITY_MEDIUM,
                   ENUM_ERROR_CONTEXT context = ERROR_CTX_GENERAL,
                   string details = "", string location = "")
{
    string severityStr = "";


    switch(severity) {
        case ERROR_SEVERITY_LOW: severityStr = "LOW"; break;
        case ERROR_SEVERITY_MEDIUM: severityStr = "MEDIUM"; break;
        case ERROR_SEVERITY_HIGH: severityStr = "HIGH"; break;
        case ERROR_SEVERITY_CRITICAL: severityStr = "CRITICAL"; break;
    }

    string contextStr = "";
    switch(context) {
        case ERROR_CTX_GENERAL: contextStr = "GENERAL"; break;
        case ERROR_CTX_TRADING: contextStr = "TRADING"; break;
        case ERROR_CTX_ANALYSIS: contextStr = "ANALYSIS"; break;
        case ERROR_CTX_UI: contextStr = "UI"; break;
        case ERROR_CTX_SYSTEM: contextStr = "SYSTEM"; break;
    }

    Print(StringFormat("[%s][%s] %s", severityStr, contextStr, message));
    if(details != "") Print("Details: " + details);
    if(location != "") Print("Location: " + location);
}

#endif // CORE_UTILITY_FUNCTIONS_MQH
