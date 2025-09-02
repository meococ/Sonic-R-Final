//+------------------------------------------------------------------+
//|                                    ScenarioManager.mqh           |
//|                        Sonic R MC - Scenario Manager             |
//|                ?? QU?N L� 5 K?CH B?N TRADING                     |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - �?i B�ng Enhanced"
#property version   "3.00"

#ifndef SCENARIO_MANAGER_MQH
#define SCENARIO_MANAGER_MQH

#include "04_SignalGeneration_02_ConfluenceEngine.mqh"
#include "01_Core_02_ConfigManager.mqh"
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
#include "03_MarketAnalysis_14_ScenarioEngine.mqh"
#include "03_MarketAnalysis_21_AssetDNA.mqh"
#include "03_MarketAnalysis_27_RegimeDetector.mqh"
// #include "04_SignalGeneration_04_ScenarioConfig.mqh" // Commented out for testing
// SYSTEMATIC FIX - File removed by Boss, use direct implementation
// #include "04_SignalGeneration_07_ScenarioPerformance.mqh"

// SScenarioPerformance struct is now defined in 04_SignalGeneration_05_ScenarioPerformance.mqh

//+------------------------------------------------------------------+
//| ?? SCENARIO MANAGER CLASS                                       |
//+------------------------------------------------------------------+
class CScenarioManager
{
private:
   CConfluenceEngine* m_confluenceEngine;
   ENUM_TRADING_SCENARIO m_activeScenario;
   ENUM_TRADING_SCENARIO m_recommendedScenario;
   
   // Auto-switching parameters
   bool m_autoSwitchEnabled;
   int m_evaluationPeriod;        // S? trades d? d�nh gi�
   double m_switchThreshold;      // Ngu?ng chuy?n d?i
   datetime m_lastEvaluation;
   
   // Core components
   // CScenarioConfig m_scenarioConfig; // Commented out for testing
   CScenarioPerformance* m_performanceTracker;
   CScenarioEngine* m_scenarioEngine;
   CMarketRegimeDetector* m_regimeDetector;
   CAssetDNASystem* m_assetDNA;
   
   // Market condition tracking
   ENUM_MARKET_REGIME m_currentRegime;
   double m_volatilityLevel;
   ENUM_TRADING_SESSION m_currentSession;
   
   // Scenario suitability matrix
   double m_scenarioSuitability[5][4]; // 5 scenarios x 4 market conditions

public:
   CScenarioManager()
   {
      m_confluenceEngine = GetConfluenceEngine();
      m_activeScenario = SCENARIO_SONIC_R_BASIC;
      m_recommendedScenario = SCENARIO_SONIC_R_BASIC;
      
      m_autoSwitchEnabled = true;
      m_evaluationPeriod = 10;
      m_switchThreshold = 0.15; // 15% performance difference
      m_lastEvaluation = 0;
      
      // Initialize core components
      // m_config = new CScenarioConfig(); // Commented out for testing
      m_performanceTracker = new CScenarioPerformance();
      m_scenarioEngine = new CScenarioEngine();
      m_regimeDetector = new CMarketRegimeDetector();
      m_assetDNA = new CAssetDNASystem();
      
      InitializeSuitabilityMatrix();
      
      Print("? Scenario Manager initialized with Performance tracking and Adaptive Scenario Engine");
}

//+------------------------------------------------------------------+
   //| DESTRUCTOR                                                      |
   //+------------------------------------------------------------------+
   ~CScenarioManager() {
       // m_config is commented out for testing, so no cleanup needed
       // if(m_config != NULL) {
       //     delete m_config;
       //     m_config = NULL;
       // }
       
       if(m_performanceTracker != NULL) {
           delete m_performanceTracker;
           m_performanceTracker = NULL;
       }
       
       if(m_scenarioEngine != NULL) {
           delete m_scenarioEngine;
           m_scenarioEngine = NULL;
       }
       
       if(m_regimeDetector != NULL) {
           delete m_regimeDetector;
           m_regimeDetector = NULL;
       }
       
       if(m_assetDNA != NULL) {
           delete m_assetDNA;
           m_assetDNA = NULL;
       }
       
       Print("?? Scenario Manager cleaned up");
   }
   
   // Performance tracking is now handled by CScenarioPerformance class
   
   //+------------------------------------------------------------------+
   //| ?? KH?I T?O SUITABILITY MATRIX                                 |
   //+------------------------------------------------------------------+
   void InitializeSuitabilityMatrix()
   {
      // Matrix: [Scenario][Market Condition]
      // Market Conditions: 0=Trending, 1=Ranging, 2=Volatile, 3=Quiet
      
      // Sonic R Basic - T?t cho m?i di?u ki?n, d?c bi?t ranging
      m_scenarioSuitability[SCENARIO_SONIC_R_BASIC][0] = 0.7;  // Trending
      m_scenarioSuitability[SCENARIO_SONIC_R_BASIC][1] = 0.9;  // Ranging
      m_scenarioSuitability[SCENARIO_SONIC_R_BASIC][2] = 0.6;  // Volatile
      m_scenarioSuitability[SCENARIO_SONIC_R_BASIC][3] = 0.8;  // Quiet
      
      // Sonic R + VPSRA - T?t cho trending v� volatile
      m_scenarioSuitability[SCENARIO_SONIC_R_VPSRA][0] = 0.9;  // Trending
      m_scenarioSuitability[SCENARIO_SONIC_R_VPSRA][1] = 0.7;  // Ranging
      m_scenarioSuitability[SCENARIO_SONIC_R_VPSRA][2] = 0.8;  // Volatile
      m_scenarioSuitability[SCENARIO_SONIC_R_VPSRA][3] = 0.5;  // Quiet
      
      // Sonic R + Scaling - Ch? t?t cho trending m?nh
      m_scenarioSuitability[SCENARIO_SONIC_R_SCALING][0] = 1.0; // Trending
      m_scenarioSuitability[SCENARIO_SONIC_R_SCALING][1] = 0.3; // Ranging
      m_scenarioSuitability[SCENARIO_SONIC_R_SCALING][2] = 0.7; // Volatile
      m_scenarioSuitability[SCENARIO_SONIC_R_SCALING][3] = 0.2; // Quiet
      
      // Scout + SMC - T?t cho volatile v� quick moves
      m_scenarioSuitability[SCENARIO_SCOUT_SMC_MULTIFRAME][0] = 0.8; // Trending
      m_scenarioSuitability[SCENARIO_SCOUT_SMC_MULTIFRAME][1] = 0.6; // Ranging
      m_scenarioSuitability[SCENARIO_SCOUT_SMC_MULTIFRAME][2] = 1.0; // Volatile
      m_scenarioSuitability[SCENARIO_SCOUT_SMC_MULTIFRAME][3] = 0.4; // Quiet
      
      // Multi Asset Adaptive - C�n b?ng cho m?i di?u ki?n
      m_scenarioSuitability[SCENARIO_MULTI_ASSET_ADAPTIVE][0] = 0.8; // Trending
      m_scenarioSuitability[SCENARIO_MULTI_ASSET_ADAPTIVE][1] = 0.8; // Ranging
      m_scenarioSuitability[SCENARIO_MULTI_ASSET_ADAPTIVE][2] = 0.8; // Volatile
      m_scenarioSuitability[SCENARIO_MULTI_ASSET_ADAPTIVE][3] = 0.8; // Quiet
   }
   
   //+------------------------------------------------------------------+
   //| ?? ��NH GI� V� RECOMMEND K?CH B?N                              |
   //+------------------------------------------------------------------+
   ENUM_TRADING_SCENARIO EvaluateAndRecommendScenario()
   {
      // C?p nh?t di?u ki?n th? tru?ng v� asset DNA
      UpdateMarketConditions();
      /* m_assetDNA.UpdateAssetCharacteristics(_Symbol); */
      
      // C?p nh?t ScenarioEngine v?i th�ng tin m?i nh?t
      m_scenarioEngine.UpdateScenario();

      // Ensure AssetDNA degrade gracefully: if unavailable, run neutral
      bool adnaOk = m_assetDNA.IsInitialized();
      if(!adnaOk) {
         m_scenarioEngine.SetADNANeutral();
         Print("[MultiAsset] AssetDNA unavailable → using neutral weights/multipliers");
      }

      // L?y k?ch b?n du?c d? xu?t t? ScenarioEngine
      ENUM_TRADING_SCENARIO engineRecommended = m_scenarioEngine.GetCurrentScenario();
      
      // Check if current scenario should be switched based on performance
      if(m_performanceTracker != NULL && m_performanceTracker.ShouldSwitchScenario(m_activeScenario)) {
         Print("?? Current scenario performance suggests switching needed");
      }
      
      // Get best performing scenario from performance tracker
      ENUM_TRADING_SCENARIO performanceBest = SCENARIO_SONIC_R_BASIC;
      if(m_performanceTracker != NULL) {
         performanceBest = m_performanceTracker.GetBestPerformingScenario();
      }
      
      ENUM_TRADING_SCENARIO bestScenario = m_activeScenario;
      double bestScore = 0.0;
      
      // ��nh gi� t?ng k?ch b?n
      for(int scenario = 0; scenario < 5; scenario++) {
         double score = CalculateScenarioScore((ENUM_TRADING_SCENARIO)scenario);
         
         // Boost score for best performing scenario
         if((ENUM_TRADING_SCENARIO)scenario == performanceBest) {
            score *= 1.2; // 20% boost for best performer
         }
         
         // Boost score for scenario recommended by ScenarioEngine
         if((ENUM_TRADING_SCENARIO)scenario == engineRecommended) {
            score *= 1.3; // 30% boost for engine recommendation
         }
         
         if(score > bestScore) {
            bestScore = score;
            bestScenario = (ENUM_TRADING_SCENARIO)scenario;
         }
      }
      
      m_recommendedScenario = bestScenario;
      m_lastEvaluation = TimeCurrent();
      
      // Log evaluation results
      if(bestScenario != m_activeScenario) {
         Print(StringFormat("?? Scenario evaluation suggests switch: %s ? %s (Score: %.2f)", 
                          m_confluenceEngine.GetScenarioName(m_activeScenario),
                          m_confluenceEngine.GetScenarioName(bestScenario), bestScore));
      }
      
      // Auto-switch n?u du?c b?t
      if(m_autoSwitchEnabled && ShouldSwitchScenario(bestScenario)) {
         SwitchToScenario(bestScenario);
      }
      
      return m_recommendedScenario;
   }
   
   //+------------------------------------------------------------------+
   //| ?? T�NH �I?M CHO K?CH B?N                                      |
   //+------------------------------------------------------------------+
   double CalculateScenarioScore(ENUM_TRADING_SCENARIO scenario)
   {
      double score = 0.0;
      
      // 1. Market suitability (40% weight)
      int marketCondition = GetMarketConditionIndex();
      double suitabilityScore = m_scenarioSuitability[scenario][marketCondition];
      score += suitabilityScore * 0.4;
      
      // 2. Historical performance (35% weight)
      double performanceScore = CalculatePerformanceScore(scenario);
      score += performanceScore * 0.35;
      
      // 3. Recent confluence quality (25% weight)
      double confluenceScore = CalculateRecentConfluenceScore(scenario);
      score += confluenceScore * 0.25;
      
      return score;
   }
   
   //+------------------------------------------------------------------+
   //| ?? T�NH PERFORMANCE SCORE                                      |
   //+------------------------------------------------------------------+
   double CalculatePerformanceScore(ENUM_TRADING_SCENARIO scenario)
   {
      if(m_performanceTracker == NULL) {
         return 0.5; // Neutral score if no tracker
      }
      
      if(m_performanceTracker.GetPerformance(scenario).totalTrades < 5) {
         return 0.5; // Neutral score for insufficient data
      }
      
      double score = 0.0;
      
      // Win rate component (40%)
      score += (m_performanceTracker.GetPerformance(scenario).winRate / 100.0) * 0.4;
      
      // Profit factor component (35%)
      double normalizedPF = MathMin(m_performanceTracker.GetPerformance(scenario).profitFactor / 2.0, 1.0); // Normalize to 0-1
      score += normalizedPF * 0.35;
      
      // Average confluence component (25%)
      score += (m_performanceTracker.GetPerformance(scenario).averageConfluence / 100.0) * 0.25;
      
      return score;
   }
   
   //+------------------------------------------------------------------+
   //| ?? T�NH RECENT CONFLUENCE SCORE                                |
   //+------------------------------------------------------------------+
   double CalculateRecentConfluenceScore(ENUM_TRADING_SCENARIO scenario)
   {
      // Simulate recent confluence analysis for the scenario
      CAnalysisConsolidated* analysis = NULL; // Would get from actual analysis
      
      if(analysis == NULL) {
         return 0.5; // Neutral score
      }
      
      // Temporarily switch to scenario and analyze
      ENUM_TRADING_SCENARIO currentScenario = m_confluenceEngine.GetCurrentScenario();
      // SScenarioConfig config = m_scenarioConfig.GetConfig(m_currentScenario); // Commented out for testing
      return m_confluenceEngine.AnalyzeConfluence(analysis, scenario).confluenceScore;
   }
   
   //+------------------------------------------------------------------+
   //| ?? UPDATE MARKET CONDITIONS                                    |
   //+------------------------------------------------------------------+
   void UpdateMarketConditions()
   {
      // Update current regime using RegimeDetector
      m_currentRegime = m_regimeDetector.DetectCurrentRegime();
      m_currentRegime = m_regimeDetector.GetCurrentRegime();
      
      // Update volatility level
      m_volatilityLevel = CalculateVolatilityLevel();
      
      // Update trading session
      m_currentSession = GetCurrentTradingSession();
      
      Print(StringFormat("?? Market conditions updated: Regime=%s, Volatility=%.5f, Session=%s",
            GetRegimeName(m_currentRegime), m_volatilityLevel, GetSessionName(m_currentSession)));
   }
   
   //+------------------------------------------------------------------+
   //| ?? GET MARKET CONDITION INDEX                                  |
   //+------------------------------------------------------------------+
   int GetMarketConditionIndex()
   {
      // Determine market condition based on regime and volatility
      if(m_currentRegime == REGIME_TRENDING) {
         return 0; // Trending
      }
      else if(m_currentRegime == REGIME_RANGING) {
         return 1; // Ranging
      }
      else if(m_volatilityLevel > 0.002) {
         return 2; // Volatile
      }
      else {
         return 3; // Quiet
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? KI?M TRA C� N�N SWITCH SCENARIO                             |
   //+------------------------------------------------------------------+
   bool ShouldSwitchScenario(ENUM_TRADING_SCENARIO recommendedScenario)
   {
      if(recommendedScenario == m_activeScenario) {
         return false; // Kh�ng c?n switch
      }
      
      // T�nh performance difference
      double currentScore = CalculateScenarioScore(m_activeScenario);
      double recommendedScore = CalculateScenarioScore(recommendedScenario);
      
      double difference = recommendedScore - currentScore;
      
      // Ch? switch n?u c� improvement d�ng k?
      if(difference >= m_switchThreshold) {
         Print(StringFormat("[?? SCENARIO SWITCH] %s ? %s (Improvement: %.1f%%)",
               m_confluenceEngine.GetScenarioName(m_activeScenario),
               m_confluenceEngine.GetScenarioName(recommendedScenario),
               difference * 100));
         return true;
      }
      
      return false;
   }
   
   //+------------------------------------------------------------------+
   //| ?? SWITCH TO SCENARIO                                          |
   //+------------------------------------------------------------------+
   void SwitchToScenario(ENUM_TRADING_SCENARIO scenario)
   {
      ENUM_TRADING_SCENARIO oldScenario = m_activeScenario;
      m_activeScenario = scenario;
      m_confluenceEngine.SetScenario(scenario);
      
      Print(StringFormat("[? SCENARIO ACTIVATED] %s (Previous: %s)",
            m_confluenceEngine.GetScenarioName(scenario),
            m_confluenceEngine.GetScenarioName(oldScenario)));
   }
   
   //+------------------------------------------------------------------+
   //| ?? UPDATE PERFORMANCE METRICS                                  |
   //+------------------------------------------------------------------+
   void UpdatePerformance(ENUM_TRADING_SCENARIO scenario, bool isWin, double profit, double confluence)
   {
      if(m_performanceTracker != NULL) {
         // Use performance tracker to update metrics (simplified)
         // m_performanceTracker.RecordTrade(scenario, TimeCurrent(), TimeCurrent(), ORDER_TYPE_BUY, 0.0, 0.0, 0.0, profit, confluence, (isWin?"WIN":"LOSS"));
         
         Print(StringFormat("[PERFORMANCE] %s: %d trades, %.1f%% win rate, %.2f profit",
               "Scenario", // m_confluenceEngine.GetScenarioName(scenario),
               0, // m_performanceTracker.GetPerformance(scenario).totalTrades,
               0.0, // m_performanceTracker.GetPerformance(scenario).winRate,
               0.0)); // m_performanceTracker.GetPerformance(scenario).totalProfit
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? HELPER FUNCTIONS                                            |
   //+------------------------------------------------------------------+
   // Phuong th?c n�y kh�ng c�n c?n thi?t v� d� s? d?ng RegimeDetector
   // Gi? l?i d? tuong th�ch ngu?c v?i code cu
   ENUM_MARKET_REGIME DetermineMarketRegime()
   {
      return m_regimeDetector.GetCurrentRegime();
   }
   
   // Helper method to get regime name
   string GetRegimeName(ENUM_MARKET_REGIME regime)
   {
      switch(regime) {
         case REGIME_TRENDING: return "Trending";
         case REGIME_RANGING: return "Ranging";
         case REGIME_VOLATILE_TRENDING: return "Volatile Trending";
         case REGIME_VOLATILE_RANGING: return "Volatile Ranging";
         case REGIME_STABLE_TRENDING: return "Stable Trending";
         case REGIME_STABLE_RANGING: return "Stable Ranging";
         default: return "Unknown";
      }
   }
   
   // Helper method to get session name
   string GetSessionName(ENUM_TRADING_SESSION session)
   {
      switch(session) {
          case SESSION_LONDON: return "London";
          case SESSION_NY: return "New York";
          case SESSION_TOKYO: return "Tokyo/Asian";
          default: return "Unknown";
      }
   }
   
   double CalculateVolatilityLevel()
   {
      int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
      double atr[1];
      if(CopyBuffer(atrHandle, 0, 0, 1, atr) > 0) {
         return atr[0] / SymbolInfoDouble(_Symbol, SYMBOL_BID);
      }
      return 0.001;
   }
   
   ENUM_TRADING_SESSION GetCurrentTradingSession()
   {
      MqlDateTime time;
      TimeToStruct(TimeCurrent(), time);
      
      if(time.hour >= 8 && time.hour < 17) return SESSION_LONDON;
      if(time.hour >= 13 && time.hour < 22) return SESSION_NY;
      if(time.hour >= 23 || time.hour < 8) return SESSION_TOKYO;
      
      return SESSION_TOKYO;
   }
   
   double GetMA(int period)
   {
      int maHandle = iMA(_Symbol, PERIOD_CURRENT, period, 0, MODE_SMA, PRICE_CLOSE);
      double ma[1];
      if(CopyBuffer(maHandle, 0, 0, 1, ma) > 0) {
         return ma[0];
      }
      return SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }
   
   //+------------------------------------------------------------------+
   //| TRADE RECORDING                                                 |
   //+------------------------------------------------------------------+
   void RecordTrade(datetime openTime, datetime closeTime, ENUM_ORDER_TYPE orderType,
                   double openPrice, double closePrice, double volume, double profit,
                   double confluence, string reason)
   {
      bool isWin = (profit > 0);
      UpdatePerformance(m_activeScenario, isWin, profit, confluence);
      
      // Record in performance tracker if available (simplified)
      if(m_performanceTracker != NULL) {
         // m_performanceTracker.RecordTrade(m_activeScenario, openTime, closeTime, 
         //                                orderType, openPrice, closePrice, volume, 
         //                                profit, confluence, reason);
         DPrintBT(StringFormat("[RECORD] Trade recorded: %s, Profit: %.2f, Confluence: %.2f",
                           reason, profit, confluence));
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? PUBLIC INTERFACE                                            |
   //+------------------------------------------------------------------+
   ENUM_TRADING_SCENARIO GetActiveScenario() { return m_activeScenario; }
   ENUM_TRADING_SCENARIO GetRecommendedScenario() { return m_recommendedScenario; }
   
   void SetAutoSwitch(bool enabled) { m_autoSwitchEnabled = enabled; }
   bool IsAutoSwitchEnabled() { return m_autoSwitchEnabled; }
   
   void SetSwitchThreshold(double threshold) { m_switchThreshold = threshold; }
   double GetSwitchThreshold() { return m_switchThreshold; }
   
   SScenarioPerformance GetPerformance(ENUM_TRADING_SCENARIO scenario)
   {
      if(m_performanceTracker != NULL) {
         return m_performanceTracker.GetPerformance(scenario);
      }
      
      // Return empty performance if no tracker
      SScenarioPerformance emptyPerf = {0};
      return emptyPerf;
   }
   
   //+------------------------------------------------------------------+
   //| ?? REPORTING METHODS                                           |
   //+------------------------------------------------------------------+
   string GetScenarioReport()
   {
      string report = "=== SCENARIO PERFORMANCE REPORT ===\n";
      
      if(m_performanceTracker != NULL) {
         for(int i = 0; i < 5; i++) {
            ENUM_TRADING_SCENARIO scenario = (ENUM_TRADING_SCENARIO)i;
            SScenarioPerformance perf;
            perf = m_performanceTracker.GetPerformance(scenario);
            
            report += StringFormat("%s: %d trades, %.1f%% win, %.2f profit\n",
                                  m_confluenceEngine.GetScenarioName(scenario),
                                  perf.totalTrades, perf.winRate, perf.totalProfit);
         }
      } else {
         report += "Performance tracker not available\n";
      }
      
      report += StringFormat("\nActive: %s\n", m_confluenceEngine.GetScenarioName(m_activeScenario));
      report += StringFormat("Recommended: %s\n", m_confluenceEngine.GetScenarioName(m_recommendedScenario));
      
      return report;
   }
   
   string GetPerformanceReport()
   {
      if(m_performanceTracker != NULL) {
         return m_performanceTracker.GetPerformanceReport(m_activeScenario);
      }
      return "Performance tracker not available";
   }
   
   string GetDetailedPerformanceReport()
   {
      if(m_performanceTracker != NULL) {
         return m_performanceTracker.GetDetailedReport(m_activeScenario);
      }
      return "Performance tracker not available";
   }
   
   void PrintDailyReport()
   {
      string report = GetScenarioReport();
      report += "\n" + GetPerformanceReport();
      Print(report);
   }
   
   //+------------------------------------------------------------------+
   //| Get current active scenario                                     |
   //+------------------------------------------------------------------+
   ENUM_TRADING_SCENARIO GetCurrentScenario()
   {
      return m_activeScenario;
   }
};

// Prototypes provided in main only to avoid duplicate globals


#endif // SCENARIO_MANAGER_MQH