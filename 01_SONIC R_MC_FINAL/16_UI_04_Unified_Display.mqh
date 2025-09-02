//+------------------------------------------------------------------+
//|                                      16_UI_04_Unified_Display.mqh |
//|                           Unified PVSRA & SMC Display System      |
//|                              Clean, Professional, Organized       |
//+------------------------------------------------------------------+
#ifndef UI_UNIFIED_DISPLAY_MQH
#define UI_UNIFIED_DISPLAY_MQH
#include "01_Core_14_CoreEnums.mqh"
#include "01_Core_00_Inputs.mqh"
// #include "Data_Providers.mqh" // removed facade; individual modules already included via MasterIncludes
#ifdef FEATURE_CONFLUENCE_ENGINE
  #include "04_SignalGeneration_02_ConfluenceEngine.mqh"
#else
  // Lightweight stub so UI compiles when ConfluenceEngine is disabled
  struct SEnhancedSignalData { double confluenceScore; ENUM_SIGNAL_TYPE signalType; double confidence; };
  class CConfluenceEngine {
    public:
      SEnhancedSignalData GetLastConfluence(){ SEnhancedSignalData s; ZeroMemory(s); s.signalType=SIGNAL_NONE; s.confluenceScore=0.0; s.confidence=0.0; return s; }
      SEnhancedSignalData AnalyzeConfluence(void* /*analysis*/, ENUM_TRADING_SCENARIO /*scenario*/){ return GetLastConfluence(); }
      ENUM_TRADING_SCENARIO GetCurrentScenario(){ return SCENARIO_SONIC_R_BASIC; }
  };
  CConfluenceEngine* GetConfluenceEngine(){ return NULL; }
#endif
#property copyright "Sonic R MC EA"
#property version   "2.0"
#property strict

#ifdef FEATURE_DASHBOARD
#ifndef UI_DASHBOARD_COMPLETE_MQH
// Minimal state struct placeholder when full dashboard header is not included
struct SCompleteDashboardState { double netProfit; double accountEquity; double currentRisk; int totalTrades; int winningTrades; int losingTrades; ENUM_SIGNAL_TYPE masterSignal; double signalConfidence; double dragonBandScore; double smcScore; double pvsraScore; double wavePatternScore; double structureScore; double confluenceScore; bool hasBOS; bool hasCHoCH; bool hasOrderBlock; bool hasLiquiditySweep; double volumeScore; double reactionScore; double srScore; ENUM_WYCKOFF_PHASE wyckoffPhase; ENUM_MARKET_REGIME marketRegime; string currentSession; double volatilityLevel; double systemHealthScore; double cpuUsage; double memoryUsage; uint averageLatency; double currentPrice; double priceChange24h; double priceChangePercent; };
class CCompleteDashboard { public: bool Initialize(int xPos=20,int yPos=50,int width=380,int height=600); void Update(); void SetCompactMode(bool compact); void Hide(); void UpdateState(const SCompleteDashboardState &state); };
#endif
#endif
#include "16_UI_02_SMC_Overlay.mqh"
#include "16_UI_03_PVSRA_Overlay.mqh"

//+------------------------------------------------------------------+
//| 🎛️ UNIFIED UI CONTROL CENTER                                     |
//+------------------------------------------------------------------+
class CUnifiedDisplayManager {
private:
#ifdef FEATURE_DASHBOARD
	CCompleteDashboard* m_dashboard;
#endif
	CSMCOverlayManager* m_smcOverlay;
	CPVSRAOverlayManager* m_pvsraOverlay;
	
	bool m_isInitialized;
	bool m_compactMode;
	datetime m_lastUpdate;
	int m_updateThrottleMs;
	
	// UI State tracking
#ifdef FEATURE_DASHBOARD
	bool m_showDashboard;
#endif
	bool m_showSMCOverlay;
	bool m_showPVSRAOverlay;
	bool m_showVolumeProfile;

	// Minimal HUD fallback (simple text panel)
	string m_hudPrefix;
	bool m_showMinimalHUD;
	
public:
	CUnifiedDisplayManager() {
#ifdef FEATURE_DASHBOARD
		m_dashboard = NULL;
#endif
		m_smcOverlay = NULL;
		m_pvsraOverlay = NULL;
		m_isInitialized = false;
#ifdef FEATURE_DASHBOARD
		m_compactMode = InpDashboardCompact;
#else
		m_compactMode = false;
#endif
		m_lastUpdate = 0;
		m_updateThrottleMs = InpOverlayThrottleMs;
		
		// UI visibility settings
#ifdef FEATURE_DASHBOARD
		m_showDashboard = InpShowDashboard;
#endif
		m_showSMCOverlay = InpShowSMCOverlayZones;
		m_showPVSRAOverlay = InpEnablePVSRA;
		m_showVolumeProfile = true;

		m_hudPrefix = "HUD_";
		m_showMinimalHUD = InpShowMinimalHUD; // input toggle
	}
	
	//+------------------------------------------------------------------+
	//| 🚀 INITIALIZATION                                                |
	//+------------------------------------------------------------------+
	bool Initialize() {
		if(m_isInitialized) return true;
		
		Print("🎛️ Initializing Unified Display Manager...");
		
#ifdef FEATURE_DASHBOARD
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
#endif
		
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
			// g_PVSRAOverlay = m_pvsraOverlay; // Commented out - duplicate declaration
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
		
		// Throttle updates for performance (500ms accurate via microseconds)
		static ulong s_lastUsec = 0;
		ulong now = GetMicrosecondCount();
		if(now - s_lastUsec < (ulong)m_updateThrottleMs * 1000) return;
		s_lastUsec = now;

#ifdef FEATURE_DASHBOARD
		// Update Dashboard
		if(m_dashboard != NULL && m_showDashboard) {
			UpdateDashboardData();
			m_dashboard.Update();
		}
#endif
		
		// Update overlays (they handle their own throttling)
		UpdateOverlays();

		// Minimal HUD update
		if(m_showMinimalHUD) UpdateMinimalHUD();
		
		m_lastUpdate = TimeCurrent();
	}
	
#ifdef FEATURE_DASHBOARD
	//+------------------------------------------------------------------+
	//| 📊 DASHBOARD DATA INTEGRATION                                   |
	//+------------------------------------------------------------------+
	void UpdateDashboardData() {
		if(m_dashboard == NULL) return;
		SCompleteDashboardState state;
		// Account + basic stats
		state.netProfit = AccountInfoDouble(ACCOUNT_PROFIT);
		state.accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
		state.currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
		state.totalTrades = 0; state.winningTrades = 0; state.losingTrades = 0; // will be filled by dashboard internals

		// Pull consolidated analysis scores (authoritative component scores)
		CAnalysisConsolidated* analysis = NULL;
		#ifdef FEATURE_SMC_INTEGRATION
		analysis = GetAnalysisConsolidated();
		#endif
		if(analysis != NULL) {
			// Light update to keep scores fresh
			analysis.UpdateAnalysis();
			state.dragonBandScore    = analysis.GetDragonBandScore();
			state.smcScore           = analysis.GetSMCScore();
			state.pvsraScore         = analysis.GetPVSRAScore();
			state.wavePatternScore   = analysis.GetWavePatternScore();
			state.structureScore     = analysis.GetMarketStructureScore();
			state.volatilityLevel    = analysis.GetVolatility();
			state.marketRegime       = analysis.GetCurrentRegime();
		} else {
			// Fallbacks
			state.dragonBandScore = 0.5;
			state.smcScore = 0.5;
			state.pvsraScore = 0.5;
			state.wavePatternScore = 0.5;
			state.structureScore = 0.5;
			state.volatilityLevel = 0.0;
			state.marketRegime = REGIME_UNKNOWN;
		}

		// Get confluence result for overall score and signal
		SEnhancedSignalData conf;
		ZeroMemory(conf);
		CConfluenceEngine* ce = GetConfluenceEngine();
		if(ce != NULL) {
			if(analysis != NULL) conf = ce.AnalyzeConfluence(analysis, SCENARIO_SONIC_R_BASIC);
			else conf = ce.GetLastConfluence();
			state.confluenceScore  = conf.confluenceScore;
			state.masterSignal     = conf.signalType;
			state.signalConfidence = conf.confidence * 100.0; // percent
		} else {
			state.confluenceScore  = 0.0;
			state.masterSignal     = SIGNAL_NONE;
			state.signalConfidence = 0.0;
		}

		// Defaults for fields not populated above
		state.currentRisk = 0.0;
		state.hasBOS = false;
		state.hasCHoCH = false;
		state.hasOrderBlock = false;
		state.hasLiquiditySweep = false;
		state.volumeScore = 0.0;
		state.reactionScore = 0.0;
		state.srScore = 0.0;
		state.wyckoffPhase = PHASE_UNKNOWN;

		// System health placeholders (real values filled elsewhere)
		state.systemHealthScore = 100.0;
		state.cpuUsage = 0.0; state.memoryUsage = 0.0; state.averageLatency = 0;
		state.priceChange24h = 0.0; state.priceChangePercent = 0.0;
		state.currentSession = "UNKNOWN";

		m_dashboard.UpdateState(state);
	}
#endif
	
	//+------------------------------------------------------------------+
	//| 🎨 OVERLAY MANAGEMENT                                           |
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

	void UpdateMinimalHUD() {
		// Simple panel: current price, spread, live SMC/PVSRA/Dragon scores and direction
		string objBg = m_hudPrefix + "BG";
		string objText = m_hudPrefix + "TEXT";
		int x = InpDashboardX; int y = InpDashboardY; int w = 260; int h = 90;
		// Background rectangle
		if(!ObjectFind(0, objBg)) {
			ObjectCreate(0, objBg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
			ObjectSetInteger(0, objBg, OBJPROP_CORNER, InpDashboardCorner);
			ObjectSetInteger(0, objBg, OBJPROP_XDISTANCE, x);
			ObjectSetInteger(0, objBg, OBJPROP_YDISTANCE, y);
			ObjectSetInteger(0, objBg, OBJPROP_BGCOLOR, (color)0x201F1F);
			ObjectSetInteger(0, objBg, OBJPROP_COLOR, (color)0x404040);
			ObjectSetInteger(0, objBg, OBJPROP_BACK, false);
		}
		ObjectSetInteger(0, objBg, OBJPROP_XSIZE, w);
		ObjectSetInteger(0, objBg, OBJPROP_YSIZE, h);

		// Text label
		double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
		double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
		double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
		int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
		double pip = (digits==3 || digits==5) ? point*10.0 : point;
		double spreadPips = pip>0? (ask-bid)/pip : 0.0;
		string line1 = StringFormat("%s  Price: %.%df  Spread: %.1f pips", _Symbol, digits, bid, spreadPips);
		// Try to fetch last SMC cache if available
		string line2 = "SMC/PVSRA/Dragon: n/a";
		// Authoritative scores from consolidated analysis + confluence direction
		CAnalysisConsolidated* analysis = NULL;
		#ifdef FEATURE_SMC_INTEGRATION
		analysis = GetAnalysisConsolidated();
		#endif
		double smcScore = 0.0, pvsraScore = 0.0, dragonScore = 0.0;
		if(analysis!=NULL) {
			analysis.UpdateAnalysis();
			smcScore    = analysis.GetSMCScore();
			pvsraScore  = analysis.GetPVSRAScore();
			dragonScore = analysis.GetDragonBandScore();
		}
		// Direction from confluence engine if available; fallback to EMA34/89
		ENUM_SIGNAL_TYPE dir = SIGNAL_NONE;
		CConfluenceEngine* ce = GetConfluenceEngine();
		if(ce!=NULL) {
			SEnhancedSignalData last; last = ce.GetLastConfluence();
			if(last.signalType!=SIGNAL_NONE) dir = last.signalType;
		}
		if(dir==SIGNAL_NONE) {
			CUnifiedIndicatorManager* _mgr = CUnifiedIndicatorManager::GetInstance();
			int e34=_mgr.GetEMAHandle(_Symbol, InpSignalTimeframe, 34, PRICE_CLOSE);
			int e89=_mgr.GetEMAHandle(_Symbol, InpSignalTimeframe, 89, PRICE_CLOSE);
			double v34[1], v89[1];
			if(e34!=INVALID_HANDLE && e89!=INVALID_HANDLE && CopyBuffer(e34,0,0,1,v34)>0 && CopyBuffer(e89,0,0,1,v89)>0) {
				dir = (v34[0]>v89[0]? SIGNAL_BUY : (v34[0]<v89[0]? SIGNAL_SELL : SIGNAL_NONE));
			}
		}
		line2 = StringFormat("SMC:%.0f  PVSRA:%.0f  Dragon:%.0f  Dir:%s", smcScore*100.0, pvsraScore*100.0, dragonScore*100.0, EnumToString(dir));
		string line3 = StringFormat("TF: %s  UI:%s/%s", EnumToString(InpSignalTimeframe), (InpShowSonicOverlay?"Sonic":"-"), (InpEnablePVSRA?"PVSRA":"-"));
		string text = line1 + "\n" + line2 + "\n" + line3;
		if(!ObjectFind(0, objText)) {
			ObjectCreate(0, objText, OBJ_LABEL, 0, 0, 0);
			ObjectSetInteger(0, objText, OBJPROP_CORNER, InpDashboardCorner);
			ObjectSetInteger(0, objText, OBJPROP_XDISTANCE, x+10);
			ObjectSetInteger(0, objText, OBJPROP_YDISTANCE, y+10);
		}
		ObjectSetString(0, objText, OBJPROP_TEXT, text);
		ObjectSetInteger(0, objText, OBJPROP_COLOR, (color)0xEDEDED);
		ObjectSetInteger(0, objText, OBJPROP_FONTSIZE, 9);
		ObjectSetString(0, objText, OBJPROP_FONT, "Consolas");
	}
	
	void UpdateSMCOverlays() {
#ifdef FEATURE_SMC_INTEGRATION
		// Draw new order blocks if detected
		if(InpShowOrderBlocksOverlay && HasNewOrderBlock()) {
			SOrderBlockData ob; { SOrderBlockData _tmp; _tmp = GetLatestOrderBlock(); ob.high=_tmp.high; ob.low=_tmp.low; ob.time=_tmp.time; ob.isBullish=_tmp.isBullish; ob.strength=_tmp.strength; }
			m_smcOverlay.DrawOrderBlock(ob.high, ob.low, ob.time, ob.isBullish, ob.strength);
		}
		
		// Draw liquidity levels
		if(InpShowLiquidityOverlay && HasNewLiquidityLevel()) {
			SLiquidityData liq; { SLiquidityData _tmp; _tmp = GetLatestLiquidity(); liq.price=_tmp.price; liq.time=_tmp.time; liq.isBuyLiquidity=_tmp.isBuyLiquidity; liq.isSwept=_tmp.isSwept; liq.volume=_tmp.volume; }
			m_smcOverlay.DrawLiquidityLevel(liq.price, liq.time, liq.isBuyLiquidity, liq.isSwept);
		}
		
		// Draw structure breaks
		if(InpShowBOSCHOCHOverlay && HasNewStructureBreak()) {
			SStructureData structure; { SStructureData _tmp; _tmp = GetLatestStructure(); structure.price=_tmp.price; structure.time=_tmp.time; structure.isBOS=_tmp.isBOS; structure.isBullish=_tmp.isBullish; }
			m_smcOverlay.DrawStructureBreak(structure.price, structure.time, structure.isBOS, structure.isBullish);
		}
		
		// Draw Fair Value Gaps
		if(InpShowFVGOverlay && HasNewFVG()) {
			SFVGData fvg; { SFVGData _tmp; _tmp = GetLatestFVG(); fvg.high=_tmp.high; fvg.low=_tmp.low; fvg.time=_tmp.time; fvg.isBullish=_tmp.isBullish; fvg.fillPercentage=_tmp.fillPercentage; }
			m_smcOverlay.DrawFairValueGap(fvg.high, fvg.low, fvg.time, fvg.isBullish, fvg.fillPercentage);
		}
#else
		// SMC is disabled in this build
		return;
#endif
	}
	
	void UpdatePVSRAOverlays() {
#ifdef FEATURE_PVSRA_V2
		// Draw volume analysis for recent bars (minimal, no external helpers)
		if(m_showVolumeProfile) {
			int avgPeriod = 20;
			for(int i = 1; i <= 5; i++) {
				double volume = (double)iVolume(_Symbol, PERIOD_CURRENT, i);
				double sum = 0.0; int count = 0;
				for(int k=1; k<=avgPeriod; k++){ double v=(double)iVolume(_Symbol, PERIOD_CURRENT, k); if(v>0){sum+=v;count++;}}
				double avgVolume = (count>0? sum/count : 0.0);
				if(avgVolume<=0) continue;
				if(volume > avgVolume * 1.3 || volume < avgVolume * 0.7) {
					double open=iOpen(_Symbol, PERIOD_CURRENT, i);
					double close=iClose(_Symbol, PERIOD_CURRENT, i);
					double high=iHigh(_Symbol, PERIOD_CURRENT, i);
					double low=iLow(_Symbol, PERIOD_CURRENT, i);
					double bodyPercent = (high!=low? MathAbs(close-open)/MathMax(1e-9, high-low) : 0.0);
					double closePosition = (high!=low? (close-low)/MathMax(1e-9, high-low) : 0.0);
					m_pvsraOverlay.DrawVolumeBar(i, volume, avgVolume, bodyPercent, closePosition);
				}
			}
		}
#else
		return;
#endif
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
	//| ⚙️ CONFIGURATION MANAGEMENT                                     |
	//+------------------------------------------------------------------+
	void SetCompactMode(bool compact) {
		m_compactMode = compact;
#ifdef FEATURE_DASHBOARD
		if(m_dashboard != NULL) {
			m_dashboard.SetCompactMode(compact);
		}
#endif
	}
	
#ifdef FEATURE_DASHBOARD
	void SetDashboardVisibility(bool visible) {
		m_showDashboard = visible;
		if(m_dashboard != NULL && !visible) {
			m_dashboard.Hide();
		}
	}
#endif
	
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
	//| 🧹 CLEANUP                                                      |
	//+------------------------------------------------------------------+
	void Deinitialize() {
		if(!m_isInitialized) return;
		
		Print("🧹 Deinitializing Unified Display Manager...");
		
#ifdef FEATURE_DASHBOARD
		if(m_dashboard != NULL) {
			delete m_dashboard;
			m_dashboard = NULL;
		}
#endif
		
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
			// g_PVSRAOverlay = NULL; // Commented out - duplicate assignment
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
CUnifiedDisplayManager* g_UnifiedDisplay = NULL;

//+------------------------------------------------------------------+
//| 🌐 UNIFIED DISPLAY HELPER FUNCTIONS                               |
//+------------------------------------------------------------------+
bool InitializeUnifiedDisplay() {
	if(g_UnifiedDisplay != NULL) return true;
	
	g_UnifiedDisplay = new CUnifiedDisplayManager();
	if(g_UnifiedDisplay == NULL) {
		Print("❌ Failed to create Unified Display Manager");
		return false;
	}
	
	return g_UnifiedDisplay.Initialize();
}

void UpdateUnifiedDisplay() {
	if(g_UnifiedDisplay != NULL) {
		g_UnifiedDisplay.Update();
	}
}

void DeinitializeUnifiedDisplay() {
	if(g_UnifiedDisplay != NULL) {
		delete g_UnifiedDisplay;
		g_UnifiedDisplay = NULL;
	}
}

#endif // UI_UNIFIED_DISPLAY_MQH




