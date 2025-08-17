//+------------------------------------------------------------------+
//|                    04_SignalGeneration_05_ScenarioProfiles.mqh  |
//|                                    SONIC R MC - SCENARIO PROFILES |
//|                                  Default configurations for 5 scenarios |
//+------------------------------------------------------------------+
#ifndef SCENARIO_PROFILES_MQH
#define SCENARIO_PROFILES_MQH

//+------------------------------------------------------------------+
//| Strategy->Scenario mapping (consistency with docs)               |
//+------------------------------------------------------------------+
ENUM_TRADING_SCENARIO MapStrategyToScenario(const ENUM_TRADING_STRATEGY strat)
{
    switch(strat)
    {
        case STRATEGY_SONIC_R:               return SCENARIO_BASIC;
        case STRATEGY_SONIC_R_WITH_VPSRA:    return SCENARIO_WITH_VPSRA;
        case STRATEGY_SCALING_WINNERS:       return SCENARIO_SCALING_WINNERS;
        case STRATEGY_SCOUT_RANGE:           return SCENARIO_SCOUT_RANGE_SMC;
        case STRATEGY_MULTI_ASSET:           return SCENARIO_MULTI_ASSET_ADAPTIVE;
        default:                             return SCENARIO_BASIC;
    }
}

//+------------------------------------------------------------------+
//| Scenario Configuration Structure                                 |
//+------------------------------------------------------------------+
struct ScenarioProfile {
    // Basic Settings
    ENUM_TRADING_SCENARIO scenario;
    string name;
    string description;
    
    // Signal Thresholds
    double confluenceThreshold;
    double pvsraThreshold;
    double dragonThreshold;
    double scoutThreshold;
    
    // Risk Management
    double riskPercent;
    double riskReward;
    double maxDailyTrades;
    double maxDailyDrawdown;
    double maxSpreadPips;
    
    // Component Weights
    double dragonWeight;
    double pvsraWeight;
    double scoutWeight;
    double smcWeight;
    
    // Advanced Settings
    bool enableEarlyTrend;
    bool enableDynamicWeights;
    bool enableSMC;
    bool enablePVSRA;
    bool enableScout;
    
    // Session Settings
    bool enableLondonSession;
    bool enableNewYorkSession;
    bool enableAsianSession;
    
    // Constructor
    ScenarioProfile() {
        scenario = SCENARIO_BASIC;
        name = "";
        description = "";
        confluenceThreshold = 0.65;
        pvsraThreshold = 1.5;
        dragonThreshold = 0.5;
        scoutThreshold = 0.7;
        riskPercent = 1.0;
        riskReward = 2.0;
        maxDailyTrades = 5;
        maxDailyDrawdown = 5.0;
        maxSpreadPips = 3.0;
        dragonWeight = 0.4;
        pvsraWeight = 0.3;
        scoutWeight = 0.3;
        smcWeight = 0.0;
        enableEarlyTrend = false;
        enableDynamicWeights = false;
        enableSMC = false;
        enablePVSRA = false;
        enableScout = false;
        enableLondonSession = true;
        enableNewYorkSession = true;
        enableAsianSession = false;
    }
    
    // Copy constructor to satisfy compiler deprecation warnings
    ScenarioProfile(const ScenarioProfile &o) {
        scenario = o.scenario;
        name = o.name;
        description = o.description;
        confluenceThreshold = o.confluenceThreshold;
        pvsraThreshold = o.pvsraThreshold;
        dragonThreshold = o.dragonThreshold;
        scoutThreshold = o.scoutThreshold;
        riskPercent = o.riskPercent;
        riskReward = o.riskReward;
        maxDailyTrades = o.maxDailyTrades;
        maxDailyDrawdown = o.maxDailyDrawdown;
        maxSpreadPips = o.maxSpreadPips;
        dragonWeight = o.dragonWeight;
        pvsraWeight = o.pvsraWeight;
        scoutWeight = o.scoutWeight;
        smcWeight = o.smcWeight;
        enableEarlyTrend = o.enableEarlyTrend;
        enableDynamicWeights = o.enableDynamicWeights;
        enableSMC = o.enableSMC;
        enablePVSRA = o.enablePVSRA;
        enableScout = o.enableScout;
        enableLondonSession = o.enableLondonSession;
        enableNewYorkSession = o.enableNewYorkSession;
        enableAsianSession = o.enableAsianSession;
    }
};

//+------------------------------------------------------------------+
//| Scenario Profile Manager                                         |
//+------------------------------------------------------------------+
class CScenarioProfileManager {
private:
    ScenarioProfile m_profiles[5];
    bool m_initialized;
    
public:
    CScenarioProfileManager() {
        m_initialized = false;
        InitializeProfiles();
    }
    
    void InitializeProfiles() {
        // Profile 1: SCENARIO_BASIC
        m_profiles[0].scenario = SCENARIO_BASIC;
        m_profiles[0].name = "Sonic R Basic";
        m_profiles[0].description = "Conservative Dragon Band only strategy";
        m_profiles[0].confluenceThreshold = 0.65;
        m_profiles[0].riskPercent = 1.0;
        m_profiles[0].riskReward = 2.0;
        m_profiles[0].maxDailyTrades = 3;
        m_profiles[0].maxDailyDrawdown = 3.0;
        m_profiles[0].maxSpreadPips = 2.5;
        m_profiles[0].dragonWeight = 1.0;
        m_profiles[0].pvsraWeight = 0.0;
        m_profiles[0].scoutWeight = 0.0;
        m_profiles[0].smcWeight = 0.0;
        m_profiles[0].enablePVSRA = false;
        m_profiles[0].enableScout = false;
        m_profiles[0].enableSMC = false;
        
        // Profile 2: SCENARIO_WITH_VPSRA
        m_profiles[1].scenario = SCENARIO_WITH_VPSRA;
        m_profiles[1].name = "Sonic R + PVSRA Enhanced";
        m_profiles[1].description = "Dragon Band with PVSRA volume confirmation";
        m_profiles[1].confluenceThreshold = 0.70;
        m_profiles[1].pvsraThreshold = 1.5;
        m_profiles[1].riskPercent = 1.5;
        m_profiles[1].riskReward = 2.5;
        m_profiles[1].maxDailyTrades = 4;
        m_profiles[1].maxDailyDrawdown = 4.0;
        m_profiles[1].maxSpreadPips = 3.0;
        m_profiles[1].dragonWeight = 0.6;
        m_profiles[1].pvsraWeight = 0.4;
        m_profiles[1].scoutWeight = 0.0;
        m_profiles[1].smcWeight = 0.0;
        m_profiles[1].enablePVSRA = true;
        m_profiles[1].enableScout = false;
        m_profiles[1].enableSMC = false;
        
        // Profile 3: SCENARIO_SCOUT_RANGE_SMC
        m_profiles[2].scenario = SCENARIO_SCOUT_RANGE_SMC;
        m_profiles[2].name = "Scout + SMC Advanced";
        m_profiles[2].description = "Early trend detection with SMC confluence";
        m_profiles[2].confluenceThreshold = 0.75;
        m_profiles[2].pvsraThreshold = 1.8;
        m_profiles[2].scoutThreshold = 0.8;
        m_profiles[2].riskPercent = 2.0;
        m_profiles[2].riskReward = 3.0;
        m_profiles[2].maxDailyTrades = 5;
        m_profiles[2].maxDailyDrawdown = 5.0;
        m_profiles[2].maxSpreadPips = 3.5;
        m_profiles[2].dragonWeight = 0.4;
        m_profiles[2].pvsraWeight = 0.3;
        m_profiles[2].scoutWeight = 0.3;
        m_profiles[2].smcWeight = 0.4;
        m_profiles[2].enablePVSRA = true;
        m_profiles[2].enableScout = true;
        m_profiles[2].enableSMC = true;
        m_profiles[2].enableEarlyTrend = true;
        
        // Profile 4: SCENARIO_SCALING_WINNERS
        m_profiles[3].scenario = SCENARIO_SCALING_WINNERS;
        m_profiles[3].name = "Scaling Winners";
        m_profiles[3].description = "High confidence scaling strategy";
        m_profiles[3].confluenceThreshold = 0.80;
        m_profiles[3].pvsraThreshold = 2.0;
        m_profiles[3].scoutThreshold = 0.9;
        m_profiles[3].riskPercent = 1.0; // Start conservative, scale up
        m_profiles[3].riskReward = 4.0;
        m_profiles[3].maxDailyTrades = 6;
        m_profiles[3].maxDailyDrawdown = 6.0;
        m_profiles[3].maxSpreadPips = 4.0;
        m_profiles[3].dragonWeight = 0.3;
        m_profiles[3].pvsraWeight = 0.3;
        m_profiles[3].scoutWeight = 0.4;
        m_profiles[3].smcWeight = 0.3;
        m_profiles[3].enablePVSRA = true;
        m_profiles[3].enableScout = true;
        m_profiles[3].enableSMC = true;
        m_profiles[3].enableEarlyTrend = true;
        m_profiles[3].enableDynamicWeights = true;
        
        // Profile 5: SCENARIO_MULTI_ASSET_ADAPTIVE
        m_profiles[4].scenario = SCENARIO_MULTI_ASSET_ADAPTIVE;
        m_profiles[4].name = "Multi-Asset Adaptive";
        m_profiles[4].description = "Adaptive strategy for multiple assets";
        m_profiles[4].confluenceThreshold = 0.75;
        m_profiles[4].pvsraThreshold = 1.6;
        m_profiles[4].scoutThreshold = 0.75;
        m_profiles[4].riskPercent = 1.5;
        m_profiles[4].riskReward = 2.5;
        m_profiles[4].maxDailyTrades = 8;
        m_profiles[4].maxDailyDrawdown = 7.0;
        m_profiles[4].maxSpreadPips = 4.0;
        m_profiles[4].dragonWeight = 0.35;
        m_profiles[4].pvsraWeight = 0.25;
        m_profiles[4].scoutWeight = 0.25;
        m_profiles[4].smcWeight = 0.15;
        m_profiles[4].enablePVSRA = true;
        m_profiles[4].enableScout = true;
        m_profiles[4].enableSMC = true;
        m_profiles[4].enableEarlyTrend = true;
        m_profiles[4].enableDynamicWeights = true;
        m_profiles[4].enableAsianSession = true;
        
        m_initialized = true;
    }
    
    ScenarioProfile GetProfile(ENUM_TRADING_SCENARIO scenario) {
        if(!m_initialized) InitializeProfiles();
        
        for(int i = 0; i < 5; i++) {
            if(m_profiles[i].scenario == scenario) {
                return m_profiles[i];
            }
        }
        
        // Return default profile if not found
        return m_profiles[0];
    }
    
    ScenarioProfile GetProfileByIndex(int index) {
        if(!m_initialized) InitializeProfiles();
        
        if(index >= 0 && index < 5) {
            return m_profiles[index];
        }
        
        return m_profiles[0];
    }
    
    string GetScenarioName(ENUM_TRADING_SCENARIO scenario) {
        ScenarioProfile profile = GetProfile(scenario);
        return profile.name;
    }
    
    string GetScenarioDescription(ENUM_TRADING_SCENARIO scenario) {
        ScenarioProfile profile = GetProfile(scenario);
        return profile.description;
    }
    
    void ApplyProfileToInputs(ENUM_TRADING_SCENARIO scenario) {
        ScenarioProfile profile = GetProfile(scenario);
        
        // Note: This would require global input variables to be modifiable
        // In practice, this is used for validation and reporting
        Print("[SCENARIO PROFILE] Applied: ", profile.name);
        Print("  Confluence Threshold: ", DoubleToString(profile.confluenceThreshold, 3));
        Print("  Risk Percent: ", DoubleToString(profile.riskPercent, 2));
        Print("  Risk Reward: ", DoubleToString(profile.riskReward, 1));
        Print("  Max Daily Trades: ", IntegerToString((int)profile.maxDailyTrades));
        Print("  PVSRA Enabled: ", (profile.enablePVSRA ? "YES" : "NO"));
        Print("  Scout Enabled: ", (profile.enableScout ? "YES" : "NO"));
        Print("  SMC Enabled: ", (profile.enableSMC ? "YES" : "NO"));
    }
    
    bool IsInitialized() const { return m_initialized; }
};

// SYSTEMATIC FIX - MQL5 global pointers cannot be initialized with assignment
// Global instance
CScenarioProfileManager* g_scenarioProfileManager;

// Helper functions
bool InitializeScenarioProfiles() {
    if(g_scenarioProfileManager == NULL) {
        g_scenarioProfileManager = new CScenarioProfileManager();
    }
    return g_scenarioProfileManager.IsInitialized();
}

void DeinitializeScenarioProfiles() {
    if(g_scenarioProfileManager != NULL) {
        delete g_scenarioProfileManager;
        g_scenarioProfileManager = NULL;
    }
}

ScenarioProfile GetCurrentScenarioProfile() {
    if(g_scenarioProfileManager == NULL) {
        InitializeScenarioProfiles();
    }
    ENUM_TRADING_SCENARIO sc = MapStrategyToScenario(InpTradingStrategy);
    return g_scenarioProfileManager.GetProfile(sc);
}

string GetCurrentScenarioName() {
    if(g_scenarioProfileManager == NULL) {
        InitializeScenarioProfiles();
    }
    ENUM_TRADING_SCENARIO sc = MapStrategyToScenario(InpTradingStrategy);
    return g_scenarioProfileManager.GetScenarioName(sc);
}

#endif // SCENARIO_PROFILES_MQH
