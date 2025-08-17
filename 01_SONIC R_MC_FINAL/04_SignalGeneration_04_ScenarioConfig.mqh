//+------------------------------------------------------------------+
//|                    04_SignalGeneration_04_ScenarioConfig.mqh   |
//|                    SONIC R MC - SCENARIO CONFIGURATION         |
//|                    C?u hình chi ti?t cho 5 k?ch b?n giao d?ch  |
//+------------------------------------------------------------------+
#ifndef SCENARIO_CONFIG_MQH
#define SCENARIO_CONFIG_MQH

#include "01_Core_14_CoreEnums.mqh"        // For ENUM_TRADING_SCENARIO
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| SCENARIO CONFIGURATION STRUCTURE                                |
//+------------------------------------------------------------------+
struct SScenarioConfig {
    // Basic Configuration
    string name;                        // Tên k?ch b?n
    string description;                 // Mô t? chi ti?t
    double minConfluenceScore;          // Ði?m confluence t?i thi?u
    double riskPercent;                 // % r?i ro m?i l?nh
    double riskReward;                  // T? l? r?i ro/l?i nhu?n
    int maxDailyTrades;                 // S? l?nh t?i da m?i ngày
    
    // Component Requirements
    bool requireDragonBand;             // Yêu c?u Dragon Band
    bool requirePVSRA;                  // Yêu c?u PVSRA
    bool requireSMC;                    // Yêu c?u Smart Money Concepts
    bool requireWavePattern;            // Yêu c?u Wave Pattern
    bool requireMultiTimeframe;         // Yêu c?u Multi Timeframe
    
    // Component Weights
    double dragonBandWeight;            // Tr?ng s? Dragon Band
    double pvsraWeight;                 // Tr?ng s? PVSRA
    double smcWeight;                   // Tr?ng s? SMC
    double wavePatternWeight;           // Tr?ng s? Wave Pattern
    double structureWeight;             // Tr?ng s? Structure
    double volumeWeight;                // Tr?ng s? Volume
    
    // Advanced Settings
    bool enableNhoi;                    // Kích ho?t nh?i l?nh
    bool enableScoutMode;               // Kích ho?t ch? d? Scout
    bool enableMultiAsset;              // Kích ho?t Multi Asset
    int minComponentCount;              // S? thành ph?n t?i thi?u
    double sessionMultiplier;           // H? s? di?u ch?nh phiên
    
    // Performance Thresholds
    double minWinRate;                  // T? l? th?ng t?i thi?u
    double maxDrawdown;                 // Drawdown t?i da
    int evaluationPeriod;               // Chu k? dánh giá (bars)
};

//+------------------------------------------------------------------+
//| SCENARIO CONFIGURATION CLASS                                     |
//+------------------------------------------------------------------+
class CScenarioConfig {
private:
    SScenarioConfig m_configs[5];       // C?u hình cho 5 k?ch b?n
    
public:
    CScenarioConfig() {
        InitializeDefaultConfigs();
    }
    ~CScenarioConfig() {}
    
    // Configuration Methods
    SScenarioConfig GetConfig(ENUM_TRADING_SCENARIO scenario) {
        int index = (int)scenario;
        if(index >= 0 && index < 5) {
            return m_configs[index];
        }
        // Return default config if invalid
        return m_configs[0];
    }
    
    bool LoadConfigurations() { return true; }
    
    void InitializeDefaultConfigs() {
    // 1. SONIC R BASIC
    m_configs[0].name = "Sonic R Basic";
    m_configs[0].description = "Co b?n v?i Dragon Band + EMA89/200";
    m_configs[0].minConfluenceScore = 60.0;
    m_configs[0].riskPercent = 1.0;
    m_configs[0].riskReward = 2.0;
    m_configs[0].maxDailyTrades = 5;
    
    m_configs[0].requireDragonBand = true;
    m_configs[0].requirePVSRA = false;
    m_configs[0].requireSMC = false;
    m_configs[0].requireWavePattern = false;
    m_configs[0].requireMultiTimeframe = false;
    
    m_configs[0].dragonBandWeight = 40.0;
    m_configs[0].pvsraWeight = 0.0;
    m_configs[0].smcWeight = 0.0;
    m_configs[0].wavePatternWeight = 20.0;
    m_configs[0].structureWeight = 20.0;
    m_configs[0].volumeWeight = 20.0;
    
    m_configs[0].enableNhoi = false;
    m_configs[0].enableScoutMode = false;
    m_configs[0].enableMultiAsset = false;
    m_configs[0].minComponentCount = 2;
    m_configs[0].sessionMultiplier = 1.0;
    
    m_configs[0].minWinRate = 55.0;
    m_configs[0].maxDrawdown = 10.0;
    m_configs[0].evaluationPeriod = 100;
    
    // 2. SONIC R + PVSRA
    m_configs[1].name = "Sonic R + PVSRA";
    m_configs[1].description = "Dragon Band + PVSRA Volume Analysis";
    m_configs[1].minConfluenceScore = 70.0;
    m_configs[1].riskPercent = 1.5;
    m_configs[1].riskReward = 2.5;
    m_configs[1].maxDailyTrades = 4;
    
    m_configs[1].requireDragonBand = true;
    m_configs[1].requirePVSRA = true;
    m_configs[1].requireSMC = false;
    m_configs[1].requireWavePattern = false;
    m_configs[1].requireMultiTimeframe = false;
    
    m_configs[1].dragonBandWeight = 35.0;
    m_configs[1].pvsraWeight = 30.0;
    m_configs[1].smcWeight = 0.0;
    m_configs[1].wavePatternWeight = 15.0;
    m_configs[1].structureWeight = 10.0;
    m_configs[1].volumeWeight = 10.0;
    
    m_configs[1].enableNhoi = false;
    m_configs[1].enableScoutMode = false;
    m_configs[1].enableMultiAsset = false;
    m_configs[1].minComponentCount = 3;
    m_configs[1].sessionMultiplier = 1.1;
    
    m_configs[1].minWinRate = 60.0;
    m_configs[1].maxDrawdown = 8.0;
    m_configs[1].evaluationPeriod = 150;
    
    // 3. SONIC R + PVSRA + NH?I
    m_configs[2].name = "Sonic R + PVSRA + Nh?i";
    m_configs[2].description = "Aggressive v?i nh?i l?nh";
    m_configs[2].minConfluenceScore = 75.0;
    m_configs[2].riskPercent = 2.0;
    m_configs[2].riskReward = 3.0;
    m_configs[2].maxDailyTrades = 8;
    
    m_configs[2].requireDragonBand = true;
    m_configs[2].requirePVSRA = true;
    m_configs[2].requireSMC = false;
    m_configs[2].requireWavePattern = true;
    m_configs[2].requireMultiTimeframe = false;
    
    m_configs[2].dragonBandWeight = 30.0;
    m_configs[2].pvsraWeight = 25.0;
    m_configs[2].smcWeight = 0.0;
    m_configs[2].wavePatternWeight = 25.0;
    m_configs[2].structureWeight = 10.0;
    m_configs[2].volumeWeight = 10.0;
    
    m_configs[2].enableNhoi = true;
    m_configs[2].enableScoutMode = false;
    m_configs[2].enableMultiAsset = false;
    m_configs[2].minComponentCount = 4;
    m_configs[2].sessionMultiplier = 1.2;
    
    m_configs[2].minWinRate = 65.0;
    m_configs[2].maxDrawdown = 12.0;
    m_configs[2].evaluationPeriod = 200;
    
    // 4. SCOUT + SMC + MULTIFRAME
    m_configs[3].name = "Scout + SMC + MultiFrame";
    m_configs[3].description = "Advanced v?i SMC và Multi Timeframe";
    m_configs[3].minConfluenceScore = 80.0;
    m_configs[3].riskPercent = 1.2;
    m_configs[3].riskReward = 3.5;
    m_configs[3].maxDailyTrades = 3;
    
    m_configs[3].requireDragonBand = true;
    m_configs[3].requirePVSRA = true;
    m_configs[3].requireSMC = true;
    m_configs[3].requireWavePattern = true;
    m_configs[3].requireMultiTimeframe = true;
    
    m_configs[3].dragonBandWeight = 25.0;
    m_configs[3].pvsraWeight = 20.0;
    m_configs[3].smcWeight = 30.0;
    m_configs[3].wavePatternWeight = 15.0;
    m_configs[3].structureWeight = 5.0;
    m_configs[3].volumeWeight = 5.0;
    
    m_configs[3].enableNhoi = false;
    m_configs[3].enableScoutMode = true;
    m_configs[3].enableMultiAsset = false;
    m_configs[3].minComponentCount = 5;
    m_configs[3].sessionMultiplier = 1.3;
    
    m_configs[3].minWinRate = 70.0;
    m_configs[3].maxDrawdown = 6.0;
    m_configs[3].evaluationPeriod = 250;
    
    // 5. MULTI ASSET
    m_configs[4].name = "Multi Asset";
    m_configs[4].description = "Portfolio v?i nhi?u tài s?n";
    m_configs[4].minConfluenceScore = 85.0;
    m_configs[4].riskPercent = 0.8;
    m_configs[4].riskReward = 4.0;
    m_configs[4].maxDailyTrades = 10;
    
    m_configs[4].requireDragonBand = true;
    m_configs[4].requirePVSRA = true;
    m_configs[4].requireSMC = true;
    m_configs[4].requireWavePattern = true;
    m_configs[4].requireMultiTimeframe = true;
    
    m_configs[4].dragonBandWeight = 20.0;
    m_configs[4].pvsraWeight = 20.0;
    m_configs[4].smcWeight = 25.0;
    m_configs[4].wavePatternWeight = 15.0;
    m_configs[4].structureWeight = 10.0;
    m_configs[4].volumeWeight = 10.0;
    
    m_configs[4].enableNhoi = true;
    m_configs[4].enableScoutMode = true;
    m_configs[4].enableMultiAsset = true;
    m_configs[4].minComponentCount = 6;
    m_configs[4].sessionMultiplier = 1.5;
    
    m_configs[4].minWinRate = 75.0;
    m_configs[4].maxDrawdown = 5.0;
    m_configs[4].evaluationPeriod = 300;
    }
    
    // Validation Methods
    bool ValidateConfig(SScenarioConfig &config) {
    // Validate basic parameters
    if(config.minConfluenceScore < 0.0 || config.minConfluenceScore > 100.0) {
        Print("? Invalid confluence score: ", config.minConfluenceScore);
        return false;
    }
    
    if(config.riskPercent <= 0.0 || config.riskPercent > 10.0) {
        Print("? Invalid risk percent: ", config.riskPercent);
        return false;
    }
    
    if(config.riskReward <= 0.0 || config.riskReward > 10.0) {
        Print("? Invalid risk reward: ", config.riskReward);
        return false;
    }
    
    // Validate weights sum to reasonable total
    double totalWeight = config.dragonBandWeight + config.pvsraWeight + 
                        config.smcWeight + config.wavePatternWeight + 
                        config.structureWeight + config.volumeWeight;
    
    if(totalWeight < 80.0 || totalWeight > 120.0) {
        Print("? Invalid total weight: ", totalWeight, " (should be 80-120)");
        return false;
    }
    
    return true;
    }
    
    string GetConfigSummary(ENUM_TRADING_SCENARIO scenario) {
    SScenarioConfig config;
    config = GetConfig(scenario);
    
    string summary = StringFormat(
        "?? %s\n" +
        "?? Confluence: %.1f%% | Risk: %.1f%% | R:R: %.1f\n" +
        "?? Max Trades: %d | Components: %d\n" +
        "?? Dragon: %.0f%% | PVSRA: %.0f%% | SMC: %.0f%%\n" +
        "?? Nh?i: %s | Scout: %s | MultiAsset: %s",
        config.name,
        config.minConfluenceScore, config.riskPercent, config.riskReward,
        config.maxDailyTrades, config.minComponentCount,
        config.dragonBandWeight, config.pvsraWeight, config.smcWeight,
        (config.enableNhoi ? "ON" : "OFF"),
        (config.enableScoutMode ? "ON" : "OFF"),
        (config.enableMultiAsset ? "ON" : "OFF")
    );
    
    return summary;
    }
};

#endif // SCENARIO_CONFIG_MQH