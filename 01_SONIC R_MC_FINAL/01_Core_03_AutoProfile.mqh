//+------------------------------------------------------------------+
//|                       01_Core_03_AutoProfile.mqh                 |
//|                   Auto Profile Engine (APE) - MVP                 |
//+------------------------------------------------------------------+
#ifndef CORE_03_AUTOPROFILE_MQH
#define CORE_03_AUTOPROFILE_MQH

#include "01_Core_00_Inputs.mqh"
#include "01_Core_02_ConfigManager.mqh"

struct SymbolDNA {
  string sym; ENUM_TIMEFRAMES tf;
  // stats
  double spread_p50_pts, spread_p80_pts;
  double atr_p50_px, atr_p80_px;
  int    stops_level_pts, freeze_level_pts;
  double tick_size, tick_value;

  // derived (persist for reference)
  double sl_floor_px, spread_cap_pts;
  double wave_angle_min_deg, mtf_conf_min, rr_base;
  datetime last_updated;
};

// naive loader using key=value lines (INI-like); json skipped for MVP
bool LoadDNA(const string key, SymbolDNA &d){
  string fn = StringFormat("profiles\\%s.json", key);
  if(!FileIsExist(fn)) return false;
  int h=FileOpen(fn, FILE_READ|FILE_TXT|FILE_ANSI);
  if(h==INVALID_HANDLE) return false;
  while(!FileIsEnding(h)){
    string line=FileReadString(h);
    int p=StringFind(line, "=");
    if(p<=0) continue;
    string k=StringSubstr(line,0,p);
    string v=StringSubstr(line,p+1);
    if(k=="sym") d.sym=v;
    else if(k=="tf") d.tf=(ENUM_TIMEFRAMES)StringToInteger(v);
    else if(k=="spread_p50_pts") d.spread_p50_pts=StringToDouble(v);
    else if(k=="spread_p80_pts") d.spread_p80_pts=StringToDouble(v);
    else if(k=="atr_p50_px") d.atr_p50_px=StringToDouble(v);
    else if(k=="atr_p80_px") d.atr_p80_px=StringToDouble(v);
    else if(k=="stops_level_pts") d.stops_level_pts=(int)StringToInteger(v);
    else if(k=="freeze_level_pts") d.freeze_level_pts=(int)StringToInteger(v);
    else if(k=="tick_size") d.tick_size=StringToDouble(v);
    else if(k=="tick_value") d.tick_value=StringToDouble(v);
    else if(k=="sl_floor_px") d.sl_floor_px=StringToDouble(v);
    else if(k=="spread_cap_pts") d.spread_cap_pts=StringToDouble(v);
    else if(k=="wave_angle_min_deg") d.wave_angle_min_deg=StringToDouble(v);
    else if(k=="mtf_conf_min") d.mtf_conf_min=StringToDouble(v);
    else if(k=="rr_base") d.rr_base=StringToDouble(v);
    else if(k=="last_updated") d.last_updated=(datetime)StringToInteger(v);
  }
  FileClose(h);
  return true;
}

void SaveDNA(const string key, const SymbolDNA &d){
  string dir="profiles";
  // Create folder if missing (MQL can't create folders directly; assume exists)
  string fn = StringFormat("%s\\%s.json", dir, key);
  int h=FileOpen(fn, FILE_WRITE|FILE_TXT|FILE_ANSI);
  if(h==INVALID_HANDLE){ Print("[APE] SaveDNA failed: ", fn); return; }
  FileWrite(h, StringFormat("sym=%s", d.sym));
  FileWrite(h, StringFormat("tf=%d", (int)d.tf));
  FileWrite(h, StringFormat("spread_p50_pts=%.5f", d.spread_p50_pts));
  FileWrite(h, StringFormat("spread_p80_pts=%.5f", d.spread_p80_pts));
  FileWrite(h, StringFormat("atr_p50_px=%.5f", d.atr_p50_px));
  FileWrite(h, StringFormat("atr_p80_px=%.5f", d.atr_p80_px));
  FileWrite(h, StringFormat("stops_level_pts=%d", d.stops_level_pts));
  FileWrite(h, StringFormat("freeze_level_pts=%d", d.freeze_level_pts));
  FileWrite(h, StringFormat("tick_size=%.10f", d.tick_size));
  FileWrite(h, StringFormat("tick_value=%.5f", d.tick_value));
  FileWrite(h, StringFormat("sl_floor_px=%.5f", d.sl_floor_px));
  FileWrite(h, StringFormat("spread_cap_pts=%.2f", d.spread_cap_pts));
  FileWrite(h, StringFormat("wave_angle_min_deg=%.2f", d.wave_angle_min_deg));
  FileWrite(h, StringFormat("mtf_conf_min=%.2f", d.mtf_conf_min));
  FileWrite(h, StringFormat("rr_base=%.2f", d.rr_base));
  FileWrite(h, StringFormat("last_updated=%I64d", (long)d.last_updated));
  FileClose(h);
}



// Percentile helper (0..1), requires ArraySetAsSeries(arr,true)
double Percentile(double &arr[], int n, double p){
  if(n<=0) return 0.0;
  double tmp[]; ArrayResize(tmp, n);
  for(int i=0;i<n;i++) tmp[i]=arr[i];
  ArraySetAsSeries(tmp, false);
  ArraySort(tmp);
  double idx = p*(n-1);
  int i = (int)idx; double frac = idx - i;
  if(i<0) return tmp[0]; if(i>=n-1) return tmp[n-1];
  return tmp[i]*(1.0-frac) + tmp[i+1]*frac;
}

bool BuildDNA(SymbolDNA &d){
  d.sym=_Symbol; d.tf=TF_Signal();
  d.tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  d.tick_value= SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  d.stops_level_pts  = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
  d.freeze_level_pts = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);

  // Collect ~60 days on M15 (or TF_Signal)
  MqlRates rates[]; ArraySetAsSeries(rates, true);
  int need= 60*24* (TF_Signal()==PERIOD_M15?4: (TF_Signal()==PERIOD_H1?1:4));
  int n=CopyRates(_Symbol, TF_Signal(), 0, need, rates);
  if(n<500) { Print("[APE] Not enough rates: ", n); return false; }

  // ATR(14)
  double atr[]; ArraySetAsSeries(atr, true); ArrayResize(atr, n);
  int handle = iATR(_Symbol, TF_Signal(), 14);
  if(handle!=INVALID_HANDLE){
    int copied = CopyBuffer(handle, 0, 0, n, atr);
    IndicatorRelease(handle);
    if(copied<=100) { Print("[APE] ATR copy failed: ", copied); return false; }
  } else { return false; }

  double atr_med = Percentile(atr, n, 0.50);
  double atr_p80 = Percentile(atr, n, 0.80);

  // Spread snapshots (rough)
  double sp_sum=0; int K=200;
  for(int i=0;i<K;i++){ sp_sum += (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD); }
  double sp_avg = sp_sum/K;

  d.spread_p50_pts = sp_avg;
  d.spread_p80_pts = sp_avg*1.2;
  d.atr_p50_px=atr_med; d.atr_p80_px=atr_p80;
  d.last_updated=TimeCurrent();
  return true;
}

void DeriveFromDNA(const SymbolDNA &d){
  // spread cap points (clamped by asset pack bounds already in ValidateInputs)
  double cap = (d.spread_p80_pts>0? d.spread_p80_pts*1.2 : MathMax(EC.spreadCapPoints, 20));
  EC.spreadCapPoints = (int)MathRound(cap);

  // SL floor/ATR multiplier
  double sl_by_stops = (d.stops_level_pts + (int)(1.2*d.spread_p80_pts)) * _Point;
  double sl_by_atr   = MathMax(ATR_SL_Mult(), 1.25) * d.atr_p50_px; // ensure min safety
  double asset_floor = EC.slFloorPx;
  EC.atrSLMult = MathMax(EC.atrSLMult, sl_by_atr / MathMax(1e-9, d.atr_p50_px));
  double sl_floor_px = MathMax(asset_floor, MathMax(sl_by_stops, sl_by_atr));

  // wave/mtf thresholds
  double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  double vol_ratio = (price>0.0) ? (d.atr_p50_px / price) : 0.001;
  double rr = 2.2 + 2.0*(vol_ratio-0.001);
  EC.rrBase = MathMax(1.8, MathMin(3.0, rr));

  // persist derived for HUD/reference
  // Note: we do not persist back to DNA by design here; SaveDNA persists when recalculated externally
}

#endif // CORE_03_AUTOPROFILE_MQH

