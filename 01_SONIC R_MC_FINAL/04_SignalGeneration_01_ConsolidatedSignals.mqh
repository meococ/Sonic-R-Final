#ifndef CONSOLIDATED_SIGNALS_IMPL_MQH
#define CONSOLIDATED_SIGNALS_IMPL_MQH
// Consolidated Signals (lightweight) - SonicR Basic
// Uses SonicBasic gates (trend/MTF/wave/session-spread) to form a basic direction.

#include "01_Core_14_CoreEnums.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"

// Forward declarations for Sonic basic gates (definitions included later via MasterIncludes)
// Function declarations  
bool Gate_SonicBasic_SessionSpread();
bool Gate_SonicBasic_Regime();
bool Gate_SonicBasic_MTF();
bool Gate_SonicBasic_Wave();

// Decide direction by EMA34 vs EMA89 on M15
ENUM_SIGNAL_TYPE __DirectionByEMAs()
{
    CUnifiedIndicatorManager* mgr = CUnifiedIndicatorManager::GetInstance();
    int h34 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 34, PRICE_CLOSE);
    int h89 = mgr.GetEMAHandle(_Symbol, PERIOD_M15, 89, PRICE_CLOSE);
    double e34[1], e89[1];
    if(h34==INVALID_HANDLE || h89==INVALID_HANDLE) return SIGNAL_NONE;
    if(CopyBuffer(h34,0,0,1,e34)<1 || CopyBuffer(h89,0,0,1,e89)<1) return SIGNAL_NONE;
    if(e34[0] > e89[0]) return SIGNAL_BUY;
    if(e34[0] < e89[0]) return SIGNAL_SELL;
    return SIGNAL_NONE;
}

// Public: Minimal SonicR Basic signal
ENUM_SIGNAL_TYPE GetSignal_SonicR_Basic()
{
    // Hard gates first: session/spread must pass
    if(!Gate_SonicBasic_SessionSpread())
        return SIGNAL_NONE;

    // Regime + MTF + Wave as confluence boosters
    bool passRegime = Gate_SonicBasic_Regime();
    bool passMTF    = Gate_SonicBasic_MTF();
    bool passWave   = Gate_SonicBasic_Wave();

    int passes = (int)passRegime + (int)passMTF + (int)passWave;

    ENUM_SIGNAL_TYPE dir = __DirectionByEMAs();
    if(dir==SIGNAL_NONE) return SIGNAL_NONE;

    // Require at least 2/3 soft gates for a signal
    if(passes >= 2)
        return dir;

    return SIGNAL_NONE;
}

#endif // CONSOLIDATED_SIGNALS_IMPL_MQH

