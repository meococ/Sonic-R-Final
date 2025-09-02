

// Lightweight Asset DNA calculator
bool CalcAssetDNA(string symbol, ENUM_TIMEFRAMES tf, double &volScore, double &trendScore, double &momentumScore, double &liquidityScore)
{
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h34 = mgr.GetEMAHandle(symbol, tf, 34, PRICE_CLOSE);
    int h89 = mgr.GetEMAHandle(symbol, tf, 89, PRICE_CLOSE);
    int hatr = mgr.GetATRHandle(symbol, tf, InpATRPeriod);
    if(h34==INVALID_HANDLE || h89==INVALID_HANDLE || hatr==INVALID_HANDLE) return false;

    double ema34[6], ema89[6], atr1[1];
    if(CopyBuffer(h34,0,0,6,ema34)<6 || CopyBuffer(h89,0,0,6,ema89)<6 || CopyBuffer(hatr,0,0,1,atr1)<1) return false;

    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double pip = ((_Digits==3||_Digits==5)? 10*_Point : _Point);
    double spread = (SymbolInfoDouble(symbol, SYMBOL_ASK)-SymbolInfoDouble(symbol, SYMBOL_BID))/pip;

    // volScore: ATR relative to price (scaled)
    double atrRel = (price>0? (atr1[0]/price) : 0.0);
    volScore = MathMin(1.0, MathMax(0.0, 50.0*atrRel));

    // trendScore: EMA89 slope normalized by price
    double slope89 = ema89[0]-ema89[5];
    trendScore = MathMin(1.0, MathMax(0.0, MathAbs(slope89)/(0.002*price)));

    // momentumScore: Dragon (EMA34) angle over 5 bars
    double slope34 = ema34[0]-ema34[5];
    double angle = MathArctan(slope34/5.0) * 180.0/M_PI;
    momentumScore = MathMin(1.0, MathMax(0.0, MathAbs(angle)/10.0));

    // liquidityScore: inverse of spread (capped)
    liquidityScore = MathMin(1.0, MathMax(0.0, 10.0/MathMax(spread, 0.1)));
    return true;
}

