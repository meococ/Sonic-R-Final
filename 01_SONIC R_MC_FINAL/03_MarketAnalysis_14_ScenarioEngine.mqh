#ifndef SCENARIO_ENGINE_MQH
#define SCENARIO_ENGINE_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_14_CoreEnums.mqh"
#include "03_MarketAnalysis_27_RegimeDetector.mqh"
#include "03_MarketAnalysis_21_AssetDNA.mqh"

class CScenarioEngine {
private:
    ENUM_TRADING_SCENARIO m_currentScenario;
    CMarketRegimeDetector m_regimeDetector;
    CAssetDNASystem m_assetDNA;

public:
    CScenarioEngine() : m_currentScenario(SCENARIO_SONIC_R_BASIC) {
        m_regimeDetector.Initialize();
        // AssetDNA requires CEaContext* to Initialize; skip here and use internal metrics
    }

    void UpdateScenario() {
        ENUM_MARKET_REGIME regime = m_regimeDetector.DetectCurrentRegime();

        // Internal volatility via ATR% of price
        int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
        double atrBuf[1];
        double atr = (atrHandle!=INVALID_HANDLE && CopyBuffer(atrHandle,0,0,1,atrBuf)>0) ? atrBuf[0] : 0.0;
        double px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double volatility = (px>0.0 && atr>0.0) ? MathMin(1.0, (atr/px)*100.0/2.0) : 0.0;

        // Internal trend via EMA34/89/200 stacking
        int e34 = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
        int e89 = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
        int e200 = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
        double b34[1], b89[1], b200[1];
        bool ok = (CopyBuffer(e34,0,0,1,b34)>0 && CopyBuffer(e89,0,0,1,b89)>0 && CopyBuffer(e200,0,0,1,b200)>0);
        double trend = 0.5;
        if(ok){
            if(b34[0] > b89[0] && b89[0] > b200[0]) trend = 1.0;
            else if(b34[0] < b89[0] && b89[0] < b200[0]) trend = 0.0;
        }

        if (trend > 0.7 && volatility > 0.5) {
            m_currentScenario = SCENARIO_SONIC_R_SCALING;
        } else if (volatility > 0.7) {
            m_currentScenario = SCENARIO_SCOUT_SMC_MULTIFRAME;
        } else if (regime == REGIME_STABLE_TRENDING) {
            m_currentScenario = SCENARIO_SONIC_R_VPSRA;
        } else if (regime == REGIME_STABLE_RANGING) {
            m_currentScenario = SCENARIO_SONIC_R_BASIC;
        } else {
            m_currentScenario = SCENARIO_MULTI_ASSET_ADAPTIVE;
        }
    }

    ENUM_TRADING_SCENARIO GetCurrentScenario() { return m_currentScenario; }
};

#endif


