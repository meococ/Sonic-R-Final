//+------------------------------------------------------------------+
//|                                    ConfluenceEngine.mqh          |
//|                        Sonic R MC - Confluence Engine            |
//|                ?? CONFLUENCE ENGINE - 5 K?CH B?N TRADING         |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - �?i B�ng Enhanced"
#property version   "3.00"

#ifndef CONFLUENCE_ENGINE_MQH
#define CONFLUENCE_ENGINE_MQH

#include "01_Core_14_CoreEnums.mqh"              // For ENUM_TRADING_SCENARIO
#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_09_SharedDataStructures.mqh"
// Lightweight build: avoid hard dependency on ConsolidatedAnalysis
// Only include heavy ConsolidatedAnalysis when BOTH flags are explicitly enabled (use nested guards for MQL5)
#ifdef ENABLE_SMC_ANALYSIS_FILES
  #ifdef FEATURE_MASTER_ORCHESTRATOR
    #if FEATURE_MASTER_ORCHESTRATOR==1
      #include "03_MarketAnalysis_09_ConsolidatedAnalysis.mqh"
    #else
      class CAnalysisConsolidated;
    #endif
  #else
    class CAnalysisConsolidated;
  #endif
#else
  // Forward declare to allow pointer usage without full type in lightweight build
  class CAnalysisConsolidated;
#endif

//+------------------------------------------------------------------+
//| ?? CONFLUENCE ENGINE - 5 K?CH B?N TRADING                       |
//| Note: ENUM_TRADING_SCENARIO now defined in 01_Core_14_CoreEnums.mqh|
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ?? CONFLICT STRUCTURE                                           |
//+------------------------------------------------------------------+
struct SConflict
{
   string conflictType;              // Lỗi xung đột
   string component1;                // Component 1
   string component2;                // Component 2
   double severity;                  // Mức độ nghiêm trọng
   double scoreAdjustment;           // Điều chỉnh điểm
   string resolution;                // Cách giải quyết
};

//+------------------------------------------------------------------+
//| ?? CONFLUENCE ENGINE CLASS                                      |
//+------------------------------------------------------------------+
class CConfluenceEngine
{
private:
   ENUM_TRADING_SCENARIO m_currentScenario;
   SEnhancedSignalData m_lastConfluence;
   datetime m_lastAnalysisTime;

   // Scenario Thresholds - FIXED: Increased size to match enum count
   double m_scenarioThresholds[8];  // Support all 8 scenarios (0-7)
   double m_scenarioWeights[8][6];  // 8 scenarios x 6 components

   // Performance Tracking - FIXED: Support all 8 scenarios
   int m_totalSignals[8];
   int m_successfulSignals[8];
   double m_avgConfluence[8];

private:
   // Helper function for safe array access
   int GetSafeScenarioIndex(ENUM_TRADING_SCENARIO scenario)
   {
      int index = (int)scenario;
      if(index < 0 || index >= 8) {
         Print("[CONFLUENCE ENGINE] WARNING: Invalid scenario index ", index, ", using BASIC (0)");
         return 0; // Default to SCENARIO_SONIC_R_BASIC
      }
      return index;
   }

public:
   CConfluenceEngine()
   {
      m_currentScenario = SCENARIO_SONIC_R_BASIC;
      // Initialize last confluence structure
      ZeroMemory(m_lastConfluence);
      m_lastConfluence.signalType = SIGNAL_NONE;
      m_lastConfluence.confidence = 0.0;
      m_lastConfluence.confluenceScore = 0.0;
      m_lastAnalysisTime = 0;

      InitializeScenarioParameters();
      ResetPerformanceMetrics();
   }

   void InitializeScenarioParameters()
   {
      // Initialize all 8 scenario thresholds
      m_scenarioThresholds[(int)SCENARIO_SONIC_R_BASIC] = 0.65;
      m_scenarioThresholds[(int)SCENARIO_SONIC_R_ENHANCED] = 0.68;
      m_scenarioThresholds[(int)SCENARIO_SONIC_R_ADVANCED] = 0.72;
      m_scenarioThresholds[(int)SCENARIO_SONIC_R_EXPERT] = 0.78;
      m_scenarioThresholds[(int)SCENARIO_SONIC_R_VPSRA] = 0.70;
      m_scenarioThresholds[(int)SCENARIO_SONIC_R_SCALING] = 0.75;
      m_scenarioThresholds[(int)SCENARIO_SCOUT_SMC_MULTIFRAME] = 0.80;
      m_scenarioThresholds[(int)SCENARIO_MULTI_ASSET_ADAPTIVE] = 0.72;

      // default balanced weights; UpdateMarketContextEnhanced will adjust
      for(int s=0;s<8;s++){  // FIXED: Loop through all 8 scenarios
         m_scenarioWeights[s][0]=0.25;
         m_scenarioWeights[s][1]=0.25;
         m_scenarioWeights[s][2]=0.20;
         m_scenarioWeights[s][3]=0.15;
         m_scenarioWeights[s][4]=0.10;
         m_scenarioWeights[s][5]=0.05;
      }
   }

   //+------------------------------------------------------------------+
   //| ?? PH�N T�CH CONFLUENCE THEO K?CH B?N                          |
   //+------------------------------------------------------------------+
   SEnhancedSignalData AnalyzeConfluence(CAnalysisConsolidated* analysis, ENUM_TRADING_SCENARIO scenario)
   {
      SEnhancedSignalData confluence;
      // Initialize confluence structure
      ZeroMemory(confluence);
      confluence.signalType = SIGNAL_NONE;
      confluence.confidence = 0.0;
      confluence.confluenceScore = 0.0;

      if(analysis == NULL) {
         confluence.reason = "Analysis not available";
         return confluence;
      }

      m_currentScenario = scenario;

      // Thu thập điểm số từng component
      CollectComponentScores(confluence, analysis);

      // Tính toán confluence theo kịch bản
      CalculateScenarioConfluence(confluence, scenario);

      // Đánh giá market context
      EvaluateMarketContext(confluence, analysis);

      // Xác định signal direction
      DetermineSignalDirection(confluence);

      // Tính toán entry/exit levels
      CalculateEntryExitLevels(confluence);

      // Validate theo kịch bản
      ValidateScenarioRequirements(confluence, scenario);

      m_lastConfluence = confluence;
      m_lastAnalysisTime = TimeCurrent();

      return confluence;
   }

   //+------------------------------------------------------------------+
   //| ?? THU THẬP ĐIỂM SỐ CÁC COMPONENT                              |
   //+------------------------------------------------------------------+
   void CollectComponentScores(SEnhancedSignalData& confluence, CAnalysisConsolidated* analysis)
{
   confluence.dragonScore   = AnalyzeDragonBand();
   confluence.waveScore     = AnalyzePriceAction();
   confluence.pvsraScore    = AnalyzeVolumeProfile();
   confluence.smcScore      = AnalyzeSMC();
   confluence.momentumScore = 0.5; // placeholder
   confluence.srScore       = AnalyzeMultiframe();
   // Respect EC toggles: zero-out when modules disabled
   if(!UsePVSRA()) confluence.pvsraScore = 0.0;
   if(!UseSMC())   confluence.smcScore   = 0.0;
}

   //+------------------------------------------------------------------+
   //| ?? TÍNH TOÁN CONFLUENCE THEO KỊCH BẢN                             |
   //+------------------------------------------------------------------+
   void CalculateScenarioConfluence(SEnhancedSignalData& confluence, ENUM_TRADING_SCENARIO scenario)
   {
      double totalScore = 0.0;
      double weights[6];

      // Lấy trọng số cho kịch bản hiện tại với safe index
      int safeIndex = GetSafeScenarioIndex((ENUM_TRADING_SCENARIO)scenario);
      for(int i = 0; i < 6; i++) {
         weights[i] = m_scenarioWeights[safeIndex][i];
      }

      // Tính tổng điểm có trọng số
      totalScore += confluence.dragonScore * weights[0];
      totalScore += confluence.waveScore * weights[1];
      totalScore += confluence.pvsraScore * weights[2];
      totalScore += 0.0 /*wyckoff*/ * weights[3];
      totalScore += confluence.smcScore * weights[4];
      totalScore += confluence.srScore * weights[5];

      confluence.confluenceScore = totalScore;

   // Tính độ tin cậy theo kịch bản với safe index
   // Preset mode: use scenario threshold; Manual mode: use InpConfluenceThreshold
   double threshold = (InpPresetByStrategy) ? m_scenarioThresholds[safeIndex] : InpConfluenceThreshold;
      confluence.confidence = (totalScore >= threshold) ? (totalScore - threshold) / (1.0 - threshold) : 0.0;

      // Bonus cho perfect alignment (param hoá)
      if(IsPerfectAlignment(confluence)) {
         double bonus = MathMax(0.0, InpAlignBonus);
         confluence.confluenceScore = MathMin(confluence.confluenceScore * (1.0 + bonus), 1.0);
         confluence.confidence = MathMin(confluence.confidence * (1.0 + bonus), 1.0);
      }
   }

   //+------------------------------------------------------------------+
   //| ?? ĐÁNH GIÁ MARKET CONTEXT                                     |
   //+------------------------------------------------------------------+
   void EvaluateMarketContext(SEnhancedSignalData& confluence, CAnalysisConsolidated* analysis)
   {
      // kept minimal - this struct does not carry regime/session fields; context used in weights
      UpdateMarketContextEnhanced(confluence);
   }

   //+------------------------------------------------------------------+
   //| ?? XÁC ĐỊNH HƯỚNG SIGNAL                                       |
   //+------------------------------------------------------------------+
   void DetermineSignalDirection(SEnhancedSignalData& confluence)
   {
      double bullishScore = 0.0;
      double bearishScore = 0.0;

      // đánh giá tổng component
      if(confluence.dragonScore > 0.6) bullishScore += 0.3;
      else if(confluence.dragonScore < 0.4) bearishScore += 0.3;

      if(confluence.waveScore > 0.6) bullishScore += 0.25;
      else if(confluence.waveScore < 0.4) bearishScore += 0.25;

      if(confluence.pvsraScore > 0.6) bullishScore += 0.2;
      else if(confluence.pvsraScore < 0.4) bearishScore += 0.2;

      if(confluence.smcScore > 0.6) bullishScore += 0.15;
      else if(confluence.smcScore < 0.4) bearishScore += 0.15;

      // wyckoffScore omitted in this struct

      // XÁC ĐỊNH signal type
      double difference = MathAbs(bullishScore - bearishScore);
      if(difference >= 0.3) {  // Cần chính lệnh tối thiểu 30%
         if(bullishScore > bearishScore) {
            confluence.signalType = SIGNAL_BUY;
            confluence.reason = StringFormat("BULLISH confluence: %.1f%% vs %.1f%%",
                                                 bullishScore*100, bearishScore*100);
         } else {
            confluence.signalType = SIGNAL_SELL;
            confluence.reason = StringFormat("BEARISH confluence: %.1f%% vs %.1f%%",
                                                 bearishScore*100, bullishScore*100);
         }
      } else {
         confluence.signalType = SIGNAL_NONE;
         confluence.reason = StringFormat("NEUTRAL - insufficient directional bias: %.1f%% vs %.1f%%",
                                               bullishScore*100, bearishScore*100);
      }
   }

   //+------------------------------------------------------------------+
   //| ?? TÍNH TOÁN ENTRY/EXIT LEVELS                                   |
   //+------------------------------------------------------------------+
   void CalculateEntryExitLevels(SEnhancedSignalData& confluence)
   {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double atr = GetATR(14);

      // Levels are not stored in SEnhancedSignalData; keep in reasoning for traceability

      if(confluence.signalType == SIGNAL_BUY) {
         double sl = currentPrice - (atr * 1.5);
         double tp = currentPrice + (atr * 3.0);
         confluence.reason += StringFormat(" | SL=%.5f TP=%.5f RR=2.0", sl, tp);
      }
      else if(confluence.signalType == SIGNAL_SELL) {
         double sl = currentPrice + (atr * 1.5);
         double tp = currentPrice - (atr * 3.0);
         confluence.reason += StringFormat(" | SL=%.5f TP=%.5f RR=2.0", sl, tp);
      }

      // Điều chỉnh R:R theo kịch bản
      // omitted for SEnhancedSignalData
   }

   //+------------------------------------------------------------------+
   //| ?? VALIDATE THEO YÊU CẦU KỊCH BẢN                              |
   //+------------------------------------------------------------------+
   void ValidateScenarioRequirements(SEnhancedSignalData& confluence, ENUM_TRADING_SCENARIO scenario)
   {
      bool isValid = true;
      string validationReason = "";

      switch(scenario) {
         case SCENARIO_SONIC_R_BASIC:
            // Yêu cầu Dragon Band mạnh
            if(confluence.dragonScore < 0.5) {
               isValid = false;
               validationReason = "Dragon Band too weak for Basic scenario";
            }
            break;

         case SCENARIO_SONIC_R_VPSRA:
            // Yêu cầu Volume Profile confirmation
            if(confluence.pvsraScore < 0.6) {
               isValid = false;
               validationReason = "Volume Profile insufficient for VPSRA scenario";
            }
            break;

         case SCENARIO_SONIC_R_SCALING:
            // Yêu cầu trending market
            {
                bool trending = (confluence.dragonScore > 0.6 && confluence.waveScore > 0.6);
                if(!trending) {
                 isValid = false;
                 validationReason = "Non-trending market for Scaling scenario";
                }
            }
            break;

         case SCENARIO_SCOUT_SMC_MULTIFRAME:
            // Yêu cầu SMC mạnh và multiframe alignment
            if(confluence.smcScore < 0.7 || confluence.srScore < 0.6) {
               isValid = false;
               validationReason = "SMC or Multiframe insufficient for Scout scenario";
            }
            break;

         case SCENARIO_MULTI_ASSET_ADAPTIVE:
            // Adaptive - Yêu cầu nghiêm ngặt hơn
            if(confluence.confluenceScore < 0.6) {
               isValid = false;
               validationReason = "Overall confluence too low for Adaptive scenario";
            }
            break;
      }

      if(!isValid) {
         confluence.signalType = SIGNAL_NONE;
         confluence.reason = validationReason;
         confluence.confidence = 0.0;
      }
   }

   //+------------------------------------------------------------------+
   //| ?? ENHANCED CONFLUENCE CALCULATION - THEO PLAN                 |
   //+------------------------------------------------------------------+
   SEnhancedSignalData CalculateEnhancedConfluence(
      double dragonScore, double dragonConfidence,
      double waveScore, double waveConfidence,
      double pvsraScore, double pvsraConfidence,
      double smcScore, double smcConfidence,
      double oscillatorScore, double oscillatorConfidence
   )
   {
      SEnhancedSignalData result;
      // Initialize result structure
      ZeroMemory(result);
      result.signalType = SIGNAL_NONE;
      result.confidence = 0.0;
      result.confluenceScore = 0.0;
      result.signalTime = TimeCurrent();

      // 1. Collect component scores
      result.dragonScore = dragonScore / 100.0;
      result.waveScore = waveScore / 100.0;
      result.pvsraScore = pvsraScore / 100.0;
      result.smcScore = smcScore / 100.0;
      result.srScore = 0.5; // Placeholder

      // 2. Update market context với adaptive weights
      UpdateMarketContextEnhanced(result);

      // 3. Calculate volume delta - THEO PLAN
      double volumeDelta = CalculateVolumeDeltaEnhanced();
      if(volumeDelta < 0.2) {
         result.signalType = SIGNAL_NONE;
         result.reason = "Low volume delta - potential fake signal";
         result.confluenceScore = 0.0;
         result.confidence = 0.0;
         Print("?? [CONFLUENCE] SKIP - Volume delta too low: ", volumeDelta);
         return result;
      }

      // 4. Detect conflicts - THEO PLAN
      DetectConflictsEnhanced(result, dragonConfidence, waveConfidence,
                             pvsraConfidence, smcConfidence, oscillatorConfidence);

      // 5. Calculate weighted confluence score
      CalculateWeightedConfluenceEnhanced(result);

      // 6. Apply conflict resolution (-20 di?m theo plan)
      ResolveConflictsEnhanced(result);

      // 7. Make final decision v?i thresholds
      MakeFinalDecisionEnhanced(result);

      return result;
   }

   //+------------------------------------------------------------------+
   //| ?? UPDATE MARKET CONTEXT ENHANCED                              |
   //+------------------------------------------------------------------+
   void UpdateMarketContextEnhanced(SEnhancedSignalData& confluence)
   {
      // Regime-aware weights mapping based on simplified regime
      double weights[6];
      // Use internal decision to set adaptive weights array

      // Default balanced
      weights[0] = 0.25; // Dragon
      weights[1] = 0.25; // Wave
      weights[2] = 0.20; // PVSRA
      weights[3] = 0.15; // SMC
      weights[4] = 0.10; // Oscillators
      weights[5] = 0.05; // Multiframe

      // Store adaptive weights
      for(int i = 0; i < 6; i++) {
         m_scenarioWeights[m_currentScenario][i] = weights[i];
      }
   }

   //+------------------------------------------------------------------+
   //| ?? CALCULATE VOLUME DELTA ENHANCED                             |
   //+------------------------------------------------------------------+
   double CalculateVolumeDeltaEnhanced()
   {
      long currentVolume = iTickVolume(_Symbol, PERIOD_CURRENT, 0);
      long avgVolume = 0;

      // Calculate average volume over last 20 bars
      for(int i = 1; i <= 20; i++) {
         avgVolume += iTickVolume(_Symbol, PERIOD_CURRENT, i);
      }
      avgVolume /= 20;

      if(avgVolume == 0) return 0.0;

      double volumeRatio = (double)currentVolume / (double)avgVolume;

      // Volume delta simulation (trong th?c t? s? d�ng tick data)
      // Simplified: ratio > 1.5 = strong, < 0.5 = weak
      return volumeRatio;
   }

   //+------------------------------------------------------------------+
   //| ?? DETECT CONFLICTS ENHANCED                                   |
   //+------------------------------------------------------------------+
   void DetectConflictsEnhanced(SEnhancedSignalData& confluence,
                               double dragonConf, double waveConf,
                               double pvsraConf, double smcConf, double oscConf)
   {
      // SEnhancedSignalData does not carry conflict arrays; keep as no-op or extend if needed
   }

   //+------------------------------------------------------------------+
   //| ?? CALCULATE WEIGHTED CONFLUENCE ENHANCED                      |
   //+------------------------------------------------------------------+
   void CalculateWeightedConfluenceEnhanced(SEnhancedSignalData& confluence)
   {
      double weights[6];
      for(int i = 0; i < 6; i++) {
         weights[i] = m_scenarioWeights[m_currentScenario][i];
      }

      double scores[6] = {confluence.dragonScore, confluence.waveScore,
                         confluence.pvsraScore, 0.0,
                         confluence.smcScore, confluence.srScore};

      double weightedSum = 0.0;
      double totalWeight = 0.0;

      for(int i = 0; i < 6; i++) {
         weightedSum += scores[i] * weights[i];
         totalWeight += weights[i];
      }

      if(totalWeight > 0) {
         confluence.confluenceScore = weightedSum / totalWeight;
      } else {
         confluence.confluenceScore = 0.0;
      }

      // Calculate confidence (average of valid components)
      double confidenceSum = 0.0;
      int validComponents = 0;

      if(confluence.dragonScore > 0) { confidenceSum += 80.0; validComponents++; }
      if(confluence.waveScore > 0) { confidenceSum += 75.0; validComponents++; }
      if(confluence.pvsraScore > 0) { confidenceSum += 85.0; validComponents++; }
      if(confluence.smcScore > 0) { confidenceSum += 70.0; validComponents++; }

      confluence.confidence = validComponents > 0 ? confidenceSum / validComponents : 0.0;
   }

   //+------------------------------------------------------------------+
   //| ?? RESOLVE CONFLICTS ENHANCED                                  |
   //+------------------------------------------------------------------+
   void ResolveConflictsEnhanced(SEnhancedSignalData& confluence)
   {
      // SEnhancedSignalData does not carry conflict arrays; keep as no-op or extend if needed
   }

   //+------------------------------------------------------------------+
   //| ?? MAKE FINAL DECISION ENHANCED                                |
   //+------------------------------------------------------------------+
   void MakeFinalDecisionEnhanced(SEnhancedSignalData& confluence)
   {
      double scorePercent = confluence.confluenceScore * 100.0;

      // Determine signal direction
      if(confluence.dragonScore > 0.6 && confluence.waveScore > 0.6) {
         confluence.signalType = SIGNAL_BUY;
      }
      else if(confluence.dragonScore < 0.4 && confluence.waveScore < 0.4) {
         confluence.signalType = SIGNAL_SELL;
      }
      else {
         confluence.signalType = SIGNAL_NONE;
      }

      // Apply thresholds theo plan
      if(scorePercent >= 80.0 && confluence.confidence >= 95.0) {
         // >80 trade standard
         confluence.reason = StringFormat("TRADE - Strong confluence: Score=%.1f%%, Confidence=%.1f%%",
                                               scorePercent, confluence.confidence);
         Print("?? [DECISION] ", confluence.reason);
      }
      else if(scorePercent >= 70.0 && scorePercent < 80.0) {
         // 70-80 scout/reduce size
         confluence.reason = StringFormat("SCOUT - Medium confluence: Score=%.1f%% - Reduce size 50%%",
                                               scorePercent);
         Print("?? [DECISION] ", confluence.reason);
      }
      else {
         // <70 skip
         confluence.signalType = SIGNAL_NONE;
         confluence.reason = StringFormat("SKIP - Weak confluence: Score=%.1f%%", scorePercent);
         Print("?? [DECISION] ", confluence.reason);
      }
   }

   //+------------------------------------------------------------------+
   //| ?? POST-ENTRY MONITORING - THEO PLAN                          |
   //+------------------------------------------------------------------+
   bool MonitorPostEntry(double currentProfit, double riskAmount)
   {
      // Recalculate confluence score
      SEnhancedSignalData currentConfluence;
      currentConfluence.confluenceScore = m_lastConfluence.confluenceScore;
      currentConfluence.confidence = m_lastConfluence.confidence;
      currentConfluence.signalType = m_lastConfluence.signalType;
      currentConfluence.dragonScore = m_lastConfluence.dragonScore;
      currentConfluence.waveScore = m_lastConfluence.waveScore;
      currentConfluence.pvsraScore = m_lastConfluence.pvsraScore;
      currentConfluence.smcScore = m_lastConfluence.smcScore;
      currentConfluence.srScore = m_lastConfluence.srScore;
      currentConfluence.momentumScore = m_lastConfluence.momentumScore;

       // Simplified recalculation (trong th?c t? s? g?i l?i modules)
       double currentScore = currentConfluence.confluenceScore * 100.0;

      // Post-entry confirm: Sau entry, n?u score drop<70 trong 15min, close
      if(currentScore < 70.0 && currentProfit > 0.3 * riskAmount) {
         Print(StringFormat("?? [POST-ENTRY] Confluence dropped to %.1f%% - Exit early (Profit=%.2f)",
                           currentScore, currentProfit));
         return true; // Signal to close
      }

      return false; // Continue holding
   }

   //+------------------------------------------------------------------+
   //| ?? HELPER FUNCTIONS - COMPONENT ANALYSIS                       |
   //+------------------------------------------------------------------+
   double AnalyzeDragonBand()
   {
      // Dragon Band analysis v?i EMA34 H/L/C
      // Get EMA handles for Dragon Band
      int emaHighHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_HIGH);
      int emaLowHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_LOW);
      int emaCloseHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);

      double emaHigh[], emaLow[], emaClose[];
      ArraySetAsSeries(emaHigh, true);
      ArraySetAsSeries(emaLow, true);
      ArraySetAsSeries(emaClose, true);

      CopyBuffer(emaHighHandle, 0, 0, 1, emaHigh);
      CopyBuffer(emaLowHandle, 0, 0, 1, emaLow);
      CopyBuffer(emaCloseHandle, 0, 0, 1, emaClose);

      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      // Score based on position relative to Dragon Band
      if(currentPrice > emaHigh[0]) return 0.8; // Strong bullish
      else if(currentPrice > emaClose[0]) return 0.6; // Moderate bullish
      else if(currentPrice < emaLow[0]) return 0.2; // Strong bearish
      else if(currentPrice < emaClose[0]) return 0.4; // Moderate bearish

      return 0.5; // Neutral
   }

   double AnalyzePriceAction()
   {
      // Wave structure analysis
      double high0 = iHigh(_Symbol, PERIOD_CURRENT, 0);
      double low0 = iLow(_Symbol, PERIOD_CURRENT, 0);
      double high1 = iHigh(_Symbol, PERIOD_CURRENT, 1);
      double low1 = iLow(_Symbol, PERIOD_CURRENT, 1);

      // Simple wave pattern detection
      if(high0 > high1 && low0 > low1) return 0.7; // Higher high, higher low
      else if(high0 < high1 && low0 < low1) return 0.3; // Lower high, lower low

      return 0.5; // Sideways
   }

   double AnalyzeVolumeProfile()
   {
      // VPSRA Volume Profile analysis (standardized thresholds + MTF bias)
      // 1) Base score by volume ratio vs average
      int lookback = 20;
      long currentVol = iTickVolume(_Symbol, PERIOD_CURRENT, 0);
      long sumVol = 0;
      int cnt = 0;
      for(int i = 1; i <= lookback; i++) { long v = iTickVolume(_Symbol, PERIOD_CURRENT, i); if(v>0){ sumVol += v; cnt++; } }
      double avgVol = (cnt>0? (double)sumVol/(double)cnt : 0.0);
      if(avgVol <= 0.0) return 0.5;

      double volRatio = (double)currentVol / avgVol;

      double strongThr   = InpPVSRA_VolumeRatio_Strong;     // e.g., 2.0
      double highThr     = InpPVSRA_VolumeRatio_High;       // e.g., 1.5
      double aboveThr    = InpPVSRA_VolumeRatio_AboveAvg;   // e.g., 1.2
      double normalThr   = InpPVSRA_VolumeRatio_Normal;     // e.g., 0.8

      double score;
      if(volRatio >= strongThr) score = 0.90;
      else if(volRatio >= highThr) score = 0.75;
      else if(volRatio >= aboveThr) score = 0.60;
      else if(volRatio >= normalThr) score = 0.50;
      else if(volRatio >= 0.5) score = 0.40;
      else score = 0.25;

      // 2) MTF directional bias (optional)
      if(InpPVSRA_EnableMTF) {
         // Determine H1/H4 trend using EMA34>EMA89
         ENUM_SIGNAL_TYPE h1Dir = TrendDirectionOnTF(PERIOD_H1);
         ENUM_SIGNAL_TYPE h4Dir = TrendDirectionOnTF(PERIOD_H4);
         // Current bar direction
         double open0 = iOpen(_Symbol, PERIOD_CURRENT, 0);
         double close0 = iClose(_Symbol, PERIOD_CURRENT, 0);
         ENUM_SIGNAL_TYPE barDir = (close0>open0? SIGNAL_BUY : (close0<open0? SIGNAL_SELL : SIGNAL_NONE));
         int aligns = 0; if(h1Dir!=SIGNAL_NONE && h1Dir==barDir) aligns++; if(h4Dir!=SIGNAL_NONE && h4Dir==barDir) aligns++;
         if(aligns>=1) score = MathMin(1.0, score + 0.10);
         else if(InpPVSRA_StrictDirection && barDir!=SIGNAL_NONE) score = MathMax(0.0, score - 0.10);
      }

      return score;
   }

   // Helper: EMA34/EMA89 trend direction on TF
   ENUM_SIGNAL_TYPE TrendDirectionOnTF(ENUM_TIMEFRAMES tf)
   {
      int e34 = iMA(_Symbol, tf, 34, 0, MODE_EMA, PRICE_CLOSE);
      int e89 = iMA(_Symbol, tf, 89, 0, MODE_EMA, PRICE_CLOSE);
      double v34[1], v89[1];
      if(CopyBuffer(e34,0,0,1,v34)>0 && CopyBuffer(e89,0,0,1,v89)>0) {
         if(v34[0]>v89[0]) return SIGNAL_BUY;
         if(v34[0]<v89[0]) return SIGNAL_SELL;
      }
      return SIGNAL_NONE;
   }

   double AnalyzeWyckoff()
   {
      // Simplified Wyckoff phase analysis
      return 0.5; // Placeholder
   }

   double AnalyzeSMC()
   {
      // Smart Money Concepts analysis
      return 0.5; // Placeholder
   }

   double AnalyzeMultiframe()
   {
      // Multi-timeframe alignment
      double score = 0.0;
      // Fix MQL5 iMA usage - get handles and use CopyBuffer
      int emaH1_handle = iMA(_Symbol, PERIOD_H1, 34, 0, MODE_EMA, PRICE_CLOSE);
      int emaH4_handle = iMA(_Symbol, PERIOD_H4, 34, 0, MODE_EMA, PRICE_CLOSE);

      double emaH1_buffer[1], emaH4_buffer[1];
      if(CopyBuffer(emaH1_handle, 0, 0, 1, emaH1_buffer) < 1 ||
         CopyBuffer(emaH4_handle, 0, 0, 1, emaH4_buffer) < 1) {
         IndicatorRelease(emaH1_handle);
         IndicatorRelease(emaH4_handle);
         return 0.0; // Return default if data not available
      }

      double emaH1 = emaH1_buffer[0];
      double emaH4 = emaH4_buffer[0];
      double current = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      int alignments = 0;
      if (current > emaH1) alignments++;
      if (current > emaH4) alignments++;
      score = (double)alignments / 2.0;

      // Clean up handles
      IndicatorRelease(emaH1_handle);
      IndicatorRelease(emaH4_handle);

      return score;
   }

   //+------------------------------------------------------------------+
   //| ?? ENHANCED MARKET REGIME DETECTION                            |
   //+------------------------------------------------------------------+
   ENUM_MARKET_REGIME DetermineMarketRegimeEnhanced()
   {
      double ema89 = iMA(_Symbol, PERIOD_H1, 89, 0, MODE_EMA, PRICE_CLOSE);
      double ema89_prev = iMA(_Symbol, PERIOD_H1, 89, 0, MODE_EMA, PRICE_CLOSE);
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      double slope = (ema89 - ema89_prev) / 5;
      double atr = GetATR(14);

      if(MathAbs(slope) > atr * 0.1) {
         if(slope > 0 && currentPrice > ema89) return (ENUM_MARKET_REGIME)REGIME_TRENDING_BULLISH;
         else if(slope < 0 && currentPrice < ema89) return (ENUM_MARKET_REGIME)REGIME_TRENDING_BEARISH;
      }

      return (ENUM_MARKET_REGIME)REGIME_RANGING;
   }

   //+------------------------------------------------------------------+
   //| ?? HELPER FUNCTIONS - MARKET CONTEXT                           |
   //+------------------------------------------------------------------+
   ENUM_MARKET_REGIME DetermineMarketRegime()
   {
      // Simplified market regime detection
      return (ENUM_MARKET_REGIME)REGIME_TRENDING;
   }

   ENUM_TRADING_SESSION GetCurrentTradingSession()
   {
      MqlDateTime time;
      TimeToStruct(TimeCurrent(), time);

      if(time.hour >= 8 && time.hour < 17) return SESSION_LONDON;
      if(time.hour >= 13 && time.hour < 22) return SESSION_NY;
      if(time.hour >= 23 || time.hour < 8) return SESSION_ASIAN;

      return SESSION_ASIAN;
   }

   double CalculateVolatilityIndex()
   {
      return GetATR(14) / SymbolInfoDouble(_Symbol, SYMBOL_BID);
   }

   double GetATR(int period)
   {
      int atrHandle = iATR(_Symbol, PERIOD_CURRENT, period);
      double atr[1];
      if(CopyBuffer(atrHandle, 0, 0, 1, atr) > 0) {
         return atr[0];
      }
      return 0.001; // Fallback
   }

   void ApplyContextAdjustments(SEnhancedSignalData& confluence)
   {
      // Adjust by current session (local compute)
      ENUM_TRADING_SESSION sess = GetCurrentTradingSession();
      if(sess == SESSION_LONDON || sess == SESSION_NY) {
         confluence.confluenceScore = MathMin(1.0, confluence.confluenceScore * 1.1);
      }

      // Adjust by current volatility (local compute)
      double vix = CalculateVolatilityIndex();
      if(vix > 0.002) {
         confluence.confluenceScore = MathMax(0.0, confluence.confluenceScore * 0.9);
      }
   }

   bool IsPerfectAlignment(const SEnhancedSignalData& confluence)
   {
      int strongComponents = 0;
      if(confluence.dragonScore > 0.7) strongComponents++;
      if(confluence.waveScore > 0.7) strongComponents++;
      if(confluence.pvsraScore > 0.7) strongComponents++;
      if(confluence.smcScore > 0.7) strongComponents++;

      return strongComponents >= 3;
   }

   void AdjustRiskRewardByScenario(SEnhancedSignalData& confluence)
   {
      switch(m_currentScenario) {
         case SCENARIO_SONIC_R_BASIC:
            confluence.riskRewardRatio = 2.0; // Conservative
            break;
         case SCENARIO_SONIC_R_VPSRA:
            confluence.riskRewardRatio = 2.5; // Moderate
            break;
         case SCENARIO_SONIC_R_SCALING:
            confluence.riskRewardRatio = 3.0; // Aggressive for trending
            break;
         case SCENARIO_SCOUT_SMC_MULTIFRAME:
            confluence.riskRewardRatio = 1.5; // Quick scalping
            break;
         case SCENARIO_MULTI_ASSET_ADAPTIVE:
            confluence.riskRewardRatio = 2.2; // Adaptive
            break;
      }
   }

   void ResetPerformanceMetrics()
   {
      for(int i = 0; i < 8; i++) {  // FIXED: Loop through all 8 scenarios
         m_totalSignals[i] = 0;
         m_successfulSignals[i] = 0;
         m_avgConfluence[i] = 0.0;
      }
   }

   //+------------------------------------------------------------------+
   //| ?? PUBLIC INTERFACE METHODS                                     |
   //+------------------------------------------------------------------+
   void SetScenario(ENUM_TRADING_SCENARIO scenario) { m_currentScenario = scenario; }
   ENUM_TRADING_SCENARIO GetCurrentScenario() { return m_currentScenario; }
   SEnhancedSignalData GetLastConfluence() { return m_lastConfluence; }

   string GetScenarioName(ENUM_TRADING_SCENARIO scenario)
   {
      switch(scenario) {
         case SCENARIO_SONIC_R_BASIC: return "Sonic R Basic";
         case SCENARIO_SONIC_R_VPSRA: return "Sonic R + VPSRA";
         case SCENARIO_SONIC_R_SCALING: return "Sonic R + VPSRA + Scaling";
         case SCENARIO_SCOUT_SMC_MULTIFRAME: return "Scout + SMC + Multiframe";
         case SCENARIO_MULTI_ASSET_ADAPTIVE: return "Multi Asset Adaptive";
         default: return "Unknown";
      }
   }

   double GetScenarioThreshold(ENUM_TRADING_SCENARIO scenario)
   {
      int safeIndex = GetSafeScenarioIndex(scenario);
      return m_scenarioThresholds[safeIndex];
   }
};

// Global instance
CConfluenceEngine* g_ConfluenceEngine = NULL;

//+------------------------------------------------------------------+
//| ?? GLOBAL FUNCTIONS                                             |
//+------------------------------------------------------------------+
CConfluenceEngine* GetConfluenceEngine()
{
   if(g_ConfluenceEngine == NULL) {
      g_ConfluenceEngine = new CConfluenceEngine();
   }
   return g_ConfluenceEngine;
}

void CleanupConfluenceEngine()
{
   if(g_ConfluenceEngine != NULL) {
      delete g_ConfluenceEngine;
      g_ConfluenceEngine = NULL;
   }
}

#endif // CONFLUENCE_ENGINE_MQH