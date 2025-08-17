//+------------------------------------------------------------------+
//|                                      16_UI_04_Unified_Display.mqh |
//|                           Unified PVSRA & SMC Display System      |
//|                              Clean, Professional, Organized       |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC EA"
#property version   "2.0"
#property strict

#include "16_UI_01_Dashboard.mqh"
#include "16_UI_02_SMC_Overlay.mqh"
#include "16_UI_03_PVSRA_Overlay.mqh"

//+------------------------------------------------------------------+
//| 🎛️ UNIFIED UI CONTROL CENTER                                     |
//+------------------------------------------------------------------+
class CUnifiedDisplayManager {
private:
    CCompleteDashboard* m_dashboard;
    CSMCOverlayManager* m_smcOverlay;
    CPVSRAOverlayManager* m_pvsraOverlay;
    
    bool m_isInitialized;
    bool m_compactMode;
    datetime m_lastUpdate;
    int m_updateThrottleMs;
    
    // UI State tracking
    bool m_showDashboard;
    bool m_showSMCOverlay;
    bool m_showPVSRAOverlay;
    bool m_showVolumeProfile;
    
public:
    CUnifiedDisplayManager() {
        m_dashboard = NULL;
        m_smcOverlay = NULL;
        m_pvsraOverlay = NULL;
        m_isInitialized = false;
        m_compactMode = InpDashboardCompact;
        m_lastUpdate = 0;
        m_updateThrottleMs = InpOverlayThrottleMs;
        
        // UI visibility settings
        m_showDashboard = InpShowDashboard;
        m_showSMCOverlay = InpShowSMCOverlayZones;
        m_showPVSRAOverlay = InpEnablePVSRA;
        m_showVolumeProfile = true;
    }
    
    //+------------------------------------------------------------------+
    //| 🚀 INITIALIZATION                                                |
    //+------------------------------------------------------------------+
    bool Initialize() {
        if(m_isInitialized) return true;
        
        Print("🎛️ Initializing Unified Display Manager...");
        
        // Initialize Dashboard
        if(m_showDashboard) {
            m_dashboard = new CCompleteDashboard();
            if(m_dashboard == NULL) {
                Print("❌ Failed to create dashboard");
                return false;
            }
            
            if(!m_dashboard.Initialize()) {
                Print("❌ Failed to initialize dashboard");
                delete m_dashboard;
                m_dashboard = NULL;
                return false;
            }
        }
        
        // Initialize SMC Overlay
        if(m_showSMCOverlay) {
            m_smcOverlay = new CSMCOverlayManager();
            if(m_smcOverlay == NULL) {
                Print("❌ Failed to create SMC overlay");
                return false;
            }
            g_SMCOverlay = m_smcOverlay; // Set global reference
        }
        
        // Initialize PVSRA Overlay
        if(m_showPVSRAOverlay) {
            m_pvsraOverlay = new CPVSRAOverlayManager();
            if(m_pvsraOverlay == NULL) {
                Print("❌ Failed to create PVSRA overlay");
                return false;
            }
            g_PVSRAOverlay = m_pvsraOverlay; // Set global reference
        }
        
        m_isInitialized = true;
        Print("✅ Unified Display Manager initialized successfully");
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| 🔄 UPDATE SYSTEM                                                 |
    //+------------------------------------------------------------------+
    void Update() {
        if(!m_isInitialized) return;
        
        // Throttle updates for performance
        datetime currentTime = TimeCurrent();
        if(currentTime - m_lastUpdate < m_updateThrottleMs / 1000) return;
        
        // Update Dashboard
        if(m_dashboard != NULL && m_showDashboard) {
            UpdateDashboardData();
            m_dashboard.Update();
        }
        
        // Update overlays (they handle their own throttling)
        UpdateOverlays();
        
        m_lastUpdate = currentTime;
    }
    
    //+------------------------------------------------------------------+
    //| 📊 DASHBOARD DATA INTEGRATION                                     |
    //+------------------------------------------------------------------+
    void UpdateDashboardData() {
        if(m_dashboard == NULL) return;
        
        // Get current analysis data
        SDashboardState state;
        
        // Performance metrics
        state.netProfit = AccountInfoDouble(ACCOUNT_PROFIT);
        state.accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
        state.currentRisk = CalculateCurrentRisk();
        state.totalTrades = GetTotalTrades();
        state.winningTrades = GetWinningTrades();
        state.losingTrades = state.totalTrades - state.winningTrades;
        
        // Signal analysis
        state.masterSignal = GetCurrentSignal();
        state.signalConfidence = GetSignalConfidence();
        state.dragonBandScore = GetDragonBandScore();
        state.smcScore = GetSMCScore();
        state.pvsraScore = GetPVSRAScore();
        state.wavePatternScore = GetWavePatternScore();
        state.structureScore = GetStructureScore();
        state.confluenceScore = GetConfluenceScore();
        
        // SMC component details
        state.hasBOS = HasBOS();
        state.hasCHoCH = HasCHoCH();
        state.hasOrderBlock = HasOrderBlock();
        state.hasLiquiditySweep = HasLiquiditySweep();
        
        // PVSRA component details
        state.volumeScore = GetVolumeScore();
        state.reactionScore = GetReactionScore();
        state.srScore = GetSRScore();
        state.wyckoffPhase = GetWyckoffPhase();
        
        // Market context
        state.marketRegime = GetMarketRegime();
        state.currentSession = GetCurrentSession();
        state.volatilityLevel = GetVolatilityLevel();
        
        // System health
        state.systemHealthScore = GetSystemHealthScore();
        state.cpuUsage = GetCPUUsage();
        state.memoryUsage = GetMemoryUsage();
        state.averageLatency = GetAverageLatency();
        
        // Market overview
        state.currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        state.priceChange24h = GetPriceChange24h();
        state.priceChangePercent = GetPriceChangePercent();
        
        // Update dashboard with new data
        m_dashboard.UpdateState(state);
    }
    
    //+------------------------------------------------------------------+
    //| 🎨 OVERLAY MANAGEMENT                                             |
    //+------------------------------------------------------------------+
    void UpdateOverlays() {
        // Update SMC overlays based on current analysis
        if(m_smcOverlay != NULL && m_showSMCOverlay) {
            UpdateSMCOverlays();
        }
        
        // Update PVSRA overlays
        if(m_pvsraOverlay != NULL && m_showPVSRAOverlay) {
            UpdatePVSRAOverlays();
        }
        
        // Cleanup old objects if needed
        CleanupOverlays();
    }
    
    void UpdateSMCOverlays() {
        // Draw new order blocks if detected
        if(InpShowOrderBlocksOverlay && HasNewOrderBlock()) {
            SOrderBlockData ob = GetLatestOrderBlock();
            m_smcOverlay.DrawOrderBlock(ob.high, ob.low, ob.time, ob.isBullish, ob.strength);
        }
        
        // Draw liquidity levels
        if(InpShowLiquidityOverlay && HasNewLiquidityLevel()) {
            SLiquidityData liq = GetLatestLiquidity();
            m_smcOverlay.DrawLiquidityLevel(liq.price, liq.time, liq.isBuyLiquidity, liq.isSwept);
        }
        
        // Draw structure breaks
        if(InpShowBOSCHOCHOverlay && HasNewStructureBreak()) {
            SStructureData structure = GetLatestStructure();
            m_smcOverlay.DrawStructureBreak(structure.price, structure.time, structure.isBOS, structure.isBullish);
        }
        
        // Draw Fair Value Gaps
        if(InpShowFVGOverlay && HasNewFVG()) {
            SFVGData fvg = GetLatestFVG();
            m_smcOverlay.DrawFairValueGap(fvg.high, fvg.low, fvg.time, fvg.isBullish, fvg.fillPercentage);
        }
    }
    
    void UpdatePVSRAOverlays() {
        // Draw PVSRA patterns
        if(HasNewPVSRAPattern()) {
            SPVSRAPatternData pattern = GetLatestPVSRAPattern();
            m_pvsraOverlay.DrawPVSRAPattern(pattern.type, pattern.time, pattern.price, pattern.strength);
        }
        
        // Draw volume analysis for recent bars
        if(m_showVolumeProfile) {
            for(int i = 1; i <= 5; i++) { // Last 5 bars
                double volume = iVolume(_Symbol, PERIOD_CURRENT, i);
                double avgVolume = GetAverageVolume(20);
                if(volume > avgVolume * 1.3 || volume < avgVolume * 0.7) {
                    double bodyPercent = GetBodyPercent(i);
                    double closePosition = GetClosePosition(i);
                    m_pvsraOverlay.DrawVolumeBar(i, volume, avgVolume, bodyPercent, closePosition);
                }
            }
        }
        
        // Draw support/resistance levels
        if(HasNewSRLevel()) {
            SSRData sr = GetLatestSR();
            m_pvsraOverlay.DrawSupportResistance(sr.price, sr.time, sr.isSupport, sr.strength, sr.touchCount);
        }
        
        // Draw Wyckoff phases
        if(HasNewWyckoffPhase()) {
            SWyckoffData wyckoff = GetLatestWyckoff();
            m_pvsraOverlay.DrawWyckoffPhase(wyckoff.phase, wyckoff.startTime, wyckoff.endTime, 
                                          wyckoff.high, wyckoff.low, wyckoff.confidence);
        }
    }
    
    void CleanupOverlays() {
        static datetime lastCleanup = 0;
        datetime currentTime = TimeCurrent();
        
        // Cleanup every 5 minutes
        if(currentTime - lastCleanup > 300) {
            if(m_smcOverlay != NULL) m_smcOverlay.CleanupOldObjects();
            if(m_pvsraOverlay != NULL) m_pvsraOverlay.CleanupOldObjects();
            lastCleanup = currentTime;
        }
    }
    
    //+------------------------------------------------------------------+
    //| ⚙️ CONFIGURATION MANAGEMENT                                       |
    //+------------------------------------------------------------------+
    void SetCompactMode(bool compact) {
        m_compactMode = compact;
        if(m_dashboard != NULL) {
            m_dashboard.SetCompactMode(compact);
        }
    }
    
    void SetDashboardVisibility(bool visible) {
        m_showDashboard = visible;
        if(m_dashboard != NULL && !visible) {
            m_dashboard.Hide();
        }
    }
    
    void SetSMCOverlayVisibility(bool visible) {
        m_showSMCOverlay = visible;
        if(m_smcOverlay != NULL) {
            m_smcOverlay.SetEnabled(visible);
        }
    }
    
    void SetPVSRAOverlayVisibility(bool visible) {
        m_showPVSRAOverlay = visible;
        if(m_pvsraOverlay != NULL) {
            m_pvsraOverlay.SetEnabled(visible);
        }
    }
    
    void SetUpdateThrottle(int milliseconds) {
        m_updateThrottleMs = milliseconds;
    }
    
    //+------------------------------------------------------------------+
    //| 🧹 CLEANUP                                                        |
    //+------------------------------------------------------------------+
    void Deinitialize() {
        if(!m_isInitialized) return;
        
        Print("🧹 Deinitializing Unified Display Manager...");
        
        if(m_dashboard != NULL) {
            delete m_dashboard;
            m_dashboard = NULL;
        }
        
        if(m_smcOverlay != NULL) {
            m_smcOverlay.RemoveAllObjects();
            delete m_smcOverlay;
            m_smcOverlay = NULL;
            g_SMCOverlay = NULL;
        }
        
        if(m_pvsraOverlay != NULL) {
            m_pvsraOverlay.RemoveAllObjects();
            delete m_pvsraOverlay;
            m_pvsraOverlay = NULL;
            g_PVSRAOverlay = NULL;
        }
        
        m_isInitialized = false;
        Print("✅ Unified Display Manager deinitialized");
    }
    
    ~CUnifiedDisplayManager() {
        Deinitialize();
    }
};

//+------------------------------------------------------------------+
//| 🌐 GLOBAL UNIFIED DISPLAY INSTANCE                               |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - MQL5 global pointers cannot be initialized with assignment
CUnifiedDisplayManager* g_UnifiedDisplay;

// Initialization function for main EA
bool InitializeUnifiedDisplay() {
    if(g_UnifiedDisplay != NULL) return true;
    
    g_UnifiedDisplay = new CUnifiedDisplayManager();
    if(g_UnifiedDisplay == NULL) {
        Print("❌ Failed to create Unified Display Manager");
        return false;
    }
    
    return g_UnifiedDisplay.Initialize();
}

// Update function for main EA OnTick
void UpdateUnifiedDisplay() {
    if(g_UnifiedDisplay != NULL) {
        g_UnifiedDisplay.Update();
    }
}

// Cleanup function for main EA OnDeinit
void DeinitializeUnifiedDisplay() {
    if(g_UnifiedDisplay != NULL) {
        delete g_UnifiedDisplay;
        g_UnifiedDisplay = NULL;
    }
}
