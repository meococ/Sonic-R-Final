// Lightweight Wave Detector with EMA34 (Dragon) context
// Returns wave direction and score without relying on external indicators

#ifndef WAVE_DETECTOR_MQH
#define WAVE_DETECTOR_MQH

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_00_Inputs.mqh"
#include "01_Core_03_DebugHelpers.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"

// NOTE: Requires Core enums (SIGNAL_BUY/SIGNAL_SELL/SIGNAL_NONE) to be included before this file.

class CWaveDetectionResult
{
public:
  ENUM_SIGNAL_TYPE direction; // SIGNAL_BUY / SIGNAL_SELL / SIGNAL_NONE
  double           score;     // 0..1 confidence
  double           dragonAngleDeg; // EMA34 angle
  int              lastPivotIndex[4];
  double           lastPivotPrice[4];
  CWaveDetectionResult(){ ZeroMemory(this); direction = SIGNAL_NONE; }
};

// Optional ZigZag assist: fetch pivots using built-in iCustom ZigZag
bool ComputePivots_ZZ(string symbol, ENUM_TIMEFRAMES tf, int maxBars, int depth, int deviation, int backstep,
                      double minSwingPips, int &outCount, int &outIdx[], double &outPx[])
{
  outCount=0; ArrayInitialize(outIdx,-1); ArrayInitialize(outPx,0.0);
  int zz = iCustom(symbol, tf, "ZigZag", depth, deviation, backstep);
  if(zz==INVALID_HANDLE) return false;
  double zzHigh[], zzLow[];
  // Buffer mapping can vary; try to fetch both
  if(CopyBuffer(zz, 0, 0, maxBars, zzHigh)<=0) return false;
  if(CopyBuffer(zz, 1, 0, maxBars, zzLow)<=0){ ArrayResize(zzLow, maxBars); ArrayInitialize(zzLow, 0.0); }
  double pip = ((int)SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 3 || (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 5) ? 10*SymbolInfoDouble(symbol, SYMBOL_POINT) : SymbolInfoDouble(symbol, SYMBOL_POINT);
  int found=0;
  for(int i=0;i<maxBars && found<10;i++){
    bool isHigh = (zzHigh[i]!=0.0);
    bool isLow  = (zzLow[i]!=0.0);
    if(!(isHigh||isLow)) continue;
    double p = isHigh? zzHigh[i] : zzLow[i];
    if(found>0){ double distPips = MathAbs(outPx[found-1]-p)/pip; if(distPips<minSwingPips) continue; }
    outIdx[found]=i; outPx[found]=p; found++;
  }
  outCount=found;
  return (found>=3);
}

// Compute pivots by simple backstep method with ATR-based min swing filter
bool ComputePivots(string symbol, ENUM_TIMEFRAMES tf, int maxBars, int backstep, double minSwingPips,
                          int &outCount, int &outIdx[], double &outPx[])
{
  ArrayInitialize(outIdx, -1);
  ArrayInitialize(outPx, 0.0);
  int bars = (int)iBars(symbol, tf);
  if(bars < backstep*4+10) return false;
  int limit = MathMin(maxBars, bars-10);
  double pip = ((int)SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 3 || (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 5) ? 10*SymbolInfoDouble(symbol, SYMBOL_POINT) : SymbolInfoDouble(symbol, SYMBOL_POINT);

  int found = 0;
  for(int i=backstep; i<limit && found<10; i++){
    double h = iHigh(symbol, tf, i);
    double l = iLow(symbol, tf, i);
    bool isHigh = true, isLow = true;
    for(int k=1; k<=backstep; k++){
      if(iHigh(symbol, tf, i-k) > h || iHigh(symbol, tf, i+k) > h) isHigh = false;
      if(iLow(symbol, tf, i-k)  < l || iLow(symbol, tf, i+k)  < l) isLow  = false;
      if(!isHigh && !isLow) break;
    }
    if(isHigh || isLow){
      // Filter by minSwing against previous pivot
      if(found>0){
        double distPips = MathAbs(outPx[found-1] - (isHigh? h : l)) / pip;
        if(distPips < minSwingPips) continue;
      }
      outIdx[found] = i;
      outPx[found]  = (isHigh? h : l);
      found++;
    }
  }
  outCount = found;
  return (found>=4);
}

// Main detector
bool GetSonicWaveSignal(string symbol, ENUM_TIMEFRAMES tf, CWaveDetectionResult &out)
{
  out = CWaveDetectionResult();

  CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
  int h34 = mgr.GetEMAHandle(symbol, tf, 34, PRICE_CLOSE);
  if(h34 == INVALID_HANDLE) return false;
  double ema34[6]; if(CopyBuffer(h34, 0, 0, 6, ema34) < 6) return false;
  double slope34 = ema34[0] - ema34[5];
  double angle = MathArctan(slope34/5.0) * 180.0/M_PI;
  out.dragonAngleDeg = angle;

  // ATR for min swing
  int hatr = mgr.GetATRHandle(symbol, tf, 14);
  double atr1[1]; if(hatr==INVALID_HANDLE || CopyBuffer(hatr,0,0,1,atr1)<1) atr1[0]=0;
  double pip = ((int)SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 3 || (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS) == 5) ? 10*SymbolInfoDouble(symbol, SYMBOL_POINT) : SymbolInfoDouble(symbol, SYMBOL_POINT);
  double minSwingPips = MathMax(5.0, 0.6*(atr1[0]/pip));

  // Collect pivots in recent bars
  int idx[16]; double px[16]; int cnt=0;
  bool have = false;
  if(InpUseZigZagAssist && !InpMinimalCoreMode){
    have = ComputePivots_ZZ(symbol, tf, 200, InpZZ_Depth, InpZZ_Deviation, InpZZ_Backstep, minSwingPips, cnt, idx, px);
  }
  if(!have){
    have = ComputePivots(symbol, tf, 150, 3, minSwingPips, cnt, idx, px);
  }
  if(!have){
    if(InpDebugMode) Print("[Wave] Pivot acquisition failed (ZZ+fallback) → treat as neutral, allow other gates to decide");
    return true;
  }

  // Analyze last 4 pivots
  int last4i[4]; double last4p[4];
  int used=0;
  for(int i=0;i<cnt && used<4;i++){ last4i[used]=idx[i]; last4p[used]=px[i]; used++; }
  if(used<3){
    if(InpDebugMode) Print("[Wave] Not enough pivots → neutral");
    return true;
  }

  // Determine type by price relation with tolerance
  bool haveUp = false, haveDn=false;
  if(used>=3){
    double p1=last4p[2], p2=last4p[1], p3=last4p[0];
    double tol = InpWave_TolerancePips * pip;
    // Up: L-H-HL
    if((p2 - p1) > tol && (p3 - p1) > -tol && angle>0.3){ haveUp = true; }
    // Down: H-L-LH
    if((p1 - p2) > tol && (p1 - p3) > -tol && angle<-0.3){ haveDn = true; }
  }

  // Optional consistency check with Dragon EMA34 orientation
  if(InpWave_UseConsistency){
    int n = MathMax(2, MathMin(5, InpWave_ConsistencyPoints));
    int h34c = mgr.GetEMAHandle(symbol, tf, 34, PRICE_CLOSE);
    double e34[6];
    if(h34c!=INVALID_HANDLE && CopyBuffer(h34c,0,0,6,e34)>=n+1){
      int ok=0;
      for(int i=0;i<n;i++){
        double seg = e34[i]-e34[i+1];
        if(haveUp && seg>0) ok++;
        if(haveDn && seg<0) ok++;
      }
      // require most segments aligned
      if(ok < (n-1)) { haveUp=false; haveDn=false; }
    }
  }

  double price = SymbolInfoDouble(symbol, SYMBOL_BID);
  bool upOK = haveUp && price>=MathMin(ema34[0], ema34[2]);
  bool dnOK = haveDn && price<=MathMax(ema34[0], ema34[2]);

  if(upOK){
    out.direction = SIGNAL_BUY;
    double depth = MathAbs(last4p[1]-last4p[2]);
    double pull  = MathAbs(last4p[0]-last4p[2]);
    double comp  = (depth>0? MathMin(1.0, pull/depth) : 0.3);
    out.score = MathMin(1.0, MathMax(0.2, MathAbs(angle)/10.0*0.5 + comp*0.5));
  }
  else if(dnOK){
    out.direction = SIGNAL_SELL;
    double depth = MathAbs(last4p[2]-last4p[1]);
    double pull  = MathAbs(last4p[2]-last4p[0]);
    double comp  = (depth>0? MathMin(1.0, pull/depth) : 0.3);
    out.score = MathMin(1.0, MathMax(0.2, MathAbs(angle)/10.0*0.5 + comp*0.5));
  }

  // Fallback: if no pattern matched but angle is strong, infer direction from Dragon angle
  if(out.direction==SIGNAL_NONE){
    double ang = out.dragonAngleDeg;
    if(MathAbs(ang) >= InpWave_AngleMinDeg){
      out.direction = (ang>0? SIGNAL_BUY : SIGNAL_SELL);
      out.score = MathMin(1.0, MathAbs(ang)/45.0); // normalize 0..1 up to 45°
      if(InpDebugMode && false)
        DPrintBT(StringFormat("[Wave-Fallback] dir=%d angle=%.2f score=%.2f", (int)out.direction, out.dragonAngleDeg, out.score));
    }
  }


  // Logging (guarded)
  bool shouldLog = (!InpWave_LogPassOnly) || (out.direction!=SIGNAL_NONE);
  if(shouldLog){
    Print(StringFormat("[Wave] dir=%d angle=%.2f score=%.2f pivots: %.2f, %.2f, %.2f", (int)out.direction, out.dragonAngleDeg, out.score, last4p[0], (used>1? last4p[1]:0.0), (used>2? last4p[2]:0.0)));
  }

  for(int k=0;k<4;k++){ out.lastPivotIndex[k]=(k<used? last4i[k]:-1); out.lastPivotPrice[k]=(k<used? last4p[k]:0.0); }
  return true;
}

#endif // WAVE_DETECTOR_MQH


