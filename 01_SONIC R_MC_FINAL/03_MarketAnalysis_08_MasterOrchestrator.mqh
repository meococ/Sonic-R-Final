//+------------------------------------------------------------------+
//|                             Analysis_MasterOrchestrator.mqh      |
//|                     SONIC R MC - MASTER ORCHESTRATOR             |
//+------------------------------------------------------------------+
#ifndef ANALYSIS_MASTER_ORCHESTRATOR_MQH
#define ANALYSIS_MASTER_ORCHESTRATOR_MQH

#ifndef FEATURE_MASTER_ORCHESTRATOR
  #define FEATURE_MASTER_ORCHESTRATOR 0
#endif

#if FEATURE_MASTER_ORCHESTRATOR==1 && defined(SONIC_ALLOW_HEAVY)

#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"
#include "03_MarketAnalysis_07_DragonBand_Analyzer.mqh"
#include "03_MarketAnalysis_06_PVSRA_Manager.mqh"
#include "03_MarketAnalysis_26_StructureManager.mqh"
#include "03_MarketAnalysis_12_WavePatternAnalyzer.mqh"

class CMasterOrchestrator
{
private:
    string                        m_symbol;
    bool                          m_initialized;

    // Components (minimal set to keep compilation and functionality)
    CUnifiedDragonBandAnalyzer*   m_unifiedDragonAnalyzer;
    CPVSRAManager*                m_pvsraManager;
    CMarketStructureManager*      m_structureManager;
    CEnhancedWavePatternAnalyzer* m_waveAnalyzer;

    // Master data
    SMasterAnalysisData           m_masterData;
    double                        m_componentWeights[4]; // Dragon/Wave/Structure/PVSRA

public:
    CMasterOrchestrator()
    {
        m_symbol = _Symbol;
        m_initialized = false;
        m_unifiedDragonAnalyzer = NULL;
        m_pvsraManager = NULL;
        m_structureManager = NULL;
        m_waveAnalyzer = NULL;
        m_componentWeights[0]=0.30; // Dragon
        m_componentWeights[1]=0.25; // Wave
        m_componentWeights[2]=0.25; // Structure
        m_componentWeights[3]=0.20; // PVSRA
        ZeroMemory(m_masterData);
        m_masterData.isValid=false;
    }

    ~CMasterOrchestrator(){ Cleanup(); }

    bool Initialize(string symbol="")
    {
        if(StringLen(symbol)>0) m_symbol = symbol; else m_symbol=_Symbol;

        // Dragon
        m_unifiedDragonAnalyzer = new CUnifiedDragonBandAnalyzer();
        if(!(*m_unifiedDragonAnalyzer).Initialize(m_symbol))
        {
            Print("[MASTER] Failed to init DragonBand Analyzer");
            Cleanup();
            return false;
        }
        // PVSRA
        m_pvsraManager = new CPVSRAManager();
        if(!(*m_pvsraManager).Initialize(m_symbol, PERIOD_CURRENT))
        {
            Print("[MASTER] Failed to init PVSRA Manager");
            Cleanup();
            return false;
        }
        // Structure (light)
        m_structureManager = new CMarketStructureManager();
        (*m_structureManager).Initialize(m_symbol, PERIOD_CURRENT);
        // Wave (light)
        m_waveAnalyzer = new CEnhancedWavePatternAnalyzer();
        // (*m_waveAnalyzer).Initialize(); // stubbed no-op

        m_initialized = true;
        return true;
    }

    void Cleanup()
    {
        if(m_unifiedDragonAnalyzer){ delete m_unifiedDragonAnalyzer; m_unifiedDragonAnalyzer=NULL; }
        if(m_pvsraManager){ delete m_pvsraManager; m_pvsraManager=NULL; }
        if(m_structureManager){ delete m_structureManager; m_structureManager=NULL; }
        if(m_waveAnalyzer){ delete m_waveAnalyzer; m_waveAnalyzer=NULL; }
        m_initialized=false;
    }

    bool UpdateMasterAnalysis()
    {
        if(!m_initialized) return false;

        datetime ts = TimeCurrent();
        // Update components
        if(m_unifiedDragonAnalyzer && !(*m_unifiedDragonAnalyzer).UpdateAnalysis())
            Print("[MASTER] DragonBand update failed");
        if(m_structureManager && !(*m_structureManager).UpdateStructureAnalysis())
            Print("[MASTER] Structure update failed");
        if(m_pvsraManager && !(*m_pvsraManager).UpdatePVSRAAnalysis())
            Print("[MASTER] PVSRA update failed");
        // Wave analyzer is stubbed

        // Scores (simple)
        double dragonScore  = 0.5;
        ENUM_TREND_DIRECTION dragonTrend = TREND_UNKNOWN;
        if(m_unifiedDragonAnalyzer){
            dragonTrend = (*m_unifiedDragonAnalyzer).GetTrendDirection();
            dragonScore = (dragonTrend==TREND_BULLISH? 0.8 : dragonTrend==TREND_BEARISH? 0.8 : 0.4);
        }
        double waveScore    = (m_waveAnalyzer? 0.5 : 0.0);
        double structScore  = (m_structureManager? 0.5 : 0.0);
        double pvsraScore   = (m_pvsraManager? m_pvsraManager.GetPVSRAScore() : 0.0);

        double conf = 0.0;
        conf += dragonScore  * m_componentWeights[0];
        conf += waveScore    * m_componentWeights[1];
        conf += structScore  * m_componentWeights[2];
        conf += pvsraScore   * m_componentWeights[3];

        // Populate master data
        ZeroMemory(m_masterData);
        m_masterData.masterSignal     = SIGNAL_NONE;
        m_masterData.signalConfidence = conf;
        m_masterData.dragonScore      = dragonScore;
        m_masterData.waveScore        = waveScore;
        m_masterData.structureScore   = structScore;
        m_masterData.pvsraScore       = pvsraScore;
        m_masterData.lastUpdate       = ts;
        m_masterData.isValid          = true;
        m_masterData.primaryTrend     = (dragonTrend==TREND_BULLISH? TREND_BULLISH : dragonTrend==TREND_BEARISH? TREND_BEARISH : TREND_UNKNOWN);

        // Decide signal direction by Dragon trend when confidence high enough
        if(conf >= MathMax(0.10, MathMin(0.95, InpConfluenceThreshold)))
        {
            if(dragonTrend==TREND_BULLISH) m_masterData.masterSignal = SIGNAL_BUY;
            else if(dragonTrend==TREND_BEARISH) m_masterData.masterSignal = SIGNAL_SELL;
            else m_masterData.masterSignal = SIGNAL_NONE;
        }
        return true;
    }

    SMasterAnalysisData GetMasterData() const { return m_masterData; }
};

#else  // FEATURE_MASTER_ORCHESTRATOR==0

// Stub to keep compilation when feature disabled
class CMasterOrchestrator { public: bool Initialize(string symbol=""){ (void)symbol; return false; } void Cleanup(){} bool UpdateMasterAnalysis(){ return false; } SMasterAnalysisData GetMasterData() const { SMasterAnalysisData d; ZeroMemory(d); d.isValid=false; return d; } };

#endif // FEATURE_MASTER_ORCHESTRATOR

#endif // ANALYSIS_MASTER_ORCHESTRATOR_MQH

