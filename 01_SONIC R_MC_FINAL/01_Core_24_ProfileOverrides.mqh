//+------------------------------------------------------------------+
//|                 01_Core_24_ProfileOverrides.mqh                 |
//|     Runtime helpers to apply profile-based default parameters   |
//|     without modifying Inp* constants at runtime                 |
//+------------------------------------------------------------------+
#ifndef CORE_24_PROFILE_OVERRIDES_MQH
#define CORE_24_PROFILE_OVERRIDES_MQH

#include "01_Core_00_Inputs.mqh"

// Profile-aware getters (fallback to Inp* when profile doesn't override)
inline double PR_GetRR(){
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:     return 2.0;   // default Sonic base
        case PROFILE_SONIC_VPSRA:    return InpRiskReward; // leave to user
        case PROFILE_MULTI_ASSET:    return InpRiskReward; // leave to user
        default: return InpRiskReward;
    }
}

inline double PR_GetSL_ATR(){
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return 1.8;  // tuned baseline
        default: return InpSL_ATR_Multiplier;
    }
}

inline double PR_GetAngleMinDeg(){
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return InpWave_AngleMinDeg; // keep user input
        default: return InpWave_AngleMinDeg;
    }
}

inline double PR_GetRangeATRCapMult(){
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return InpRangeATRCapMult; // keep current tuned default
        default: return InpRangeATRCapMult;
    }
}

// Unified getters for fragmented inputs
inline double PR_GetDailyLossLimitPct(){
    // Use MaxDailyDrawdown parameter
    return InpMaxDailyDrawdown;
}

// Profile-aware getters for feature toggles used by orchestrator
inline bool PR_IsDragonEnabled(){
    if(InpFeatureMode==FEATURE_CUSTOM) return InpEnableDragonBand;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return true;
        case PROFILE_SONIC_VPSRA: return true;
        case PROFILE_MULTI_ASSET: return true;
        default: return InpEnableDragonBand;
    }
}
inline bool PR_IsPVSRAEnabled(){
    if(InpFeatureMode==FEATURE_CUSTOM) return InpEnablePVSRA;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return false;
        case PROFILE_SONIC_VPSRA: return true;
        case PROFILE_MULTI_ASSET: return true;
        default: return InpEnablePVSRA;
    }
}
inline bool PR_IsSMCEnabled(){
    if(InpFeatureMode==FEATURE_CUSTOM) return InpEnableSMC;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return false;
        case PROFILE_SONIC_VPSRA: return false;
        case PROFILE_MULTI_ASSET: return true;
        default: return InpEnableSMC;
    }
}
inline bool PR_IsWyckoffEnabled(){
    if(InpFeatureMode==FEATURE_CUSTOM) return InpEnableWyckoff;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return false;
        case PROFILE_SONIC_VPSRA: return true;
        case PROFILE_MULTI_ASSET: return true;
        default: return InpEnableWyckoff;
    }
}
inline bool PR_IsScoutEnabled(){
    if(InpFeatureMode==FEATURE_CUSTOM) return InpEnableScout;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return false;
        case PROFILE_SONIC_VPSRA: return false;
        case PROFILE_MULTI_ASSET: return false;
        default: return InpEnableScout;
    }
}

inline double PR_GetMinSignalStrength(){
    if(InpFeatureMode==FEATURE_CUSTOM) return InpMinSignalStrength;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:  return 70.0;
        case PROFILE_SONIC_VPSRA: return 65.0;
        case PROFILE_MULTI_ASSET: return 60.0;
        default: return InpMinSignalStrength;
    }
}


// Apply feature auto-toggles based on profile;
// Only mutates non-const globals (not the input declarations themselves)
inline void PR_ApplyFeatureAutoToggles(bool &enableDragon,
                                       bool &enablePVSRA,
                                       bool &enableSMC,
                                       bool &enableScout,
                                       bool &enableWyckoff,
                                       double &minSignalStrength)
{
    if(InpFeatureMode != FEATURE_AUTO) return;
    switch(InpStrategyProfile){
        case PROFILE_SONIC_BASE:
            enableDragon = true;  enablePVSRA = false; enableSMC=false; enableScout=false; enableWyckoff=false;
            minSignalStrength = 70.0;
            break;
        case PROFILE_SONIC_VPSRA:
            enableDragon = true;  enablePVSRA = true;  enableSMC=false; enableScout=false; enableWyckoff=true;
            minSignalStrength = 65.0;
            break;
        case PROFILE_MULTI_ASSET:
            enableDragon = true;  enablePVSRA = true;  enableSMC=true;  enableScout=false; enableWyckoff=true;
            minSignalStrength = 60.0;
            break;
        default: break;
    }
}


#endif // CORE_24_PROFILE_OVERRIDES_MQH

