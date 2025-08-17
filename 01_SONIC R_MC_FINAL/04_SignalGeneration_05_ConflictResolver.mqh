//+------------------------------------------------------------------+
//|                                    SignalGeneration_ConflictResolver.mqh |
//|                        SONIC R MC - INTELLIGENT CONFLICT RESOLVER        |
//|                    ?? RESOLVES SIGNAL CONFLICTS LIKE A WISE JUDGE         |
//+------------------------------------------------------------------+
#ifndef SIGNAL_GENERATION_CONFLICT_RESOLVER_MQH
#define SIGNAL_GENERATION_CONFLICT_RESOLVER_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"

//+------------------------------------------------------------------+
//| ?? CONFLICT TYPES - PHÂN LO?I XUNG Ð?T                          |
//+------------------------------------------------------------------+
// ENUM_CONFLICT_TYPE moved to SonicEnums.mqh for proper include order

// ENUM_RESOLUTION_STRATEGY moved to SonicEnums.mqh for proper include order

//+------------------------------------------------------------------+
//| ?? CONFLICT DATA STRUCTURE                                      |
//+------------------------------------------------------------------+
struct SConflictData
{
   ENUM_CONFLICT_TYPE conflictType;           // Lo?i xung d?t
   ENUM_RESOLUTION_STRATEGY resolutionStrategy; // Chi?n lu?c gi?i quy?t
   
   // Conflict details
   string conflictDescription;                // Mô t? xung d?t
   double conflictSeverity;                   // M?c d? nghiêm tr?ng (0-1)
   int conflictingComponents;                 // S? component xung d?t
   
   // Resolution details
   ENUM_SIGNAL_TYPE resolvedSignal;           // Signal sau khi gi?i quy?t
   double resolutionConfidence;               // Ð? tin c?y gi?i quy?t
   string resolutionReason;                   // Lý do gi?i quy?t
   
   // Component votes
   ENUM_SIGNAL_TYPE dragonVote;               // Vote c?a Dragon Band
   ENUM_SIGNAL_TYPE waveVote;                 // Vote c?a Wave Analysis
   ENUM_SIGNAL_TYPE structureVote;            // Vote c?a Structure
   ENUM_SIGNAL_TYPE pvsraVote;                // Vote c?a PVSRA
   ENUM_SIGNAL_TYPE smcVote;                  // Vote c?a SMC
   
   // Component weights (dynamic)
   double dragonWeight;                       // Tr?ng s? Dragon Band
   double waveWeight;                         // Tr?ng s? Wave
   double structureWeight;                    // Tr?ng s? Structure
   double pvsraWeight;                        // Tr?ng s? PVSRA
   double smcWeight;                          // Tr?ng s? SMC
   
   void Reset()
   {
      conflictType = CONFLICT_NONE;
      resolutionStrategy = RESOLUTION_NONE;
      conflictDescription = "";
      conflictSeverity = 0.0;
      conflictingComponents = 0;
      resolvedSignal = SIGNAL_NONE;
      resolutionConfidence = 0.0;
      resolutionReason = "";
      
      dragonVote = waveVote = structureVote = pvsraVote = smcVote = SIGNAL_NONE;
      dragonWeight = waveWeight = structureWeight = pvsraWeight = smcWeight = 0.2;
   }
   
   string ToString()
   {
      return StringFormat("Conflict: %s | Severity: %.1f%% | Resolution: %s | Confidence: %.1f%% | Final: %s",
                         ConflictTypeToString(conflictType), conflictSeverity*100,
                         ResolutionStrategyToString(resolutionStrategy), resolutionConfidence*100,
                         SignalTypeToString(resolvedSignal));
   }
};

//+------------------------------------------------------------------+
//| ?? INTELLIGENT CONFLICT RESOLVER CLASS                          |
//+------------------------------------------------------------------+
class CIntelligentConflictResolver
{
private:
   // Configuration
   double m_conflictThreshold;                // Ngu?ng phát hi?n xung d?t
   double m_severityThreshold;                // Ngu?ng nghiêm tr?ng
   double m_abstainThreshold;                 // Ngu?ng t? ch?i giao d?ch
   
   // Historical performance tracking
   double m_componentReliability[5];          // Ð? tin c?y t?ng component
   int m_componentSuccessCount[5];            // S? l?n thành công
   int m_componentTotalCount[5];              // T?ng s? l?n
   
   // Market context weights
   double m_trendingWeights[5];               // Tr?ng s? trong trending market
   double m_rangingWeights[5];                // Tr?ng s? trong ranging market
   double m_volatileWeights[5];               // Tr?ng s? trong volatile market
   
   // Conflict statistics
   int m_totalConflicts;                      // T?ng s? xung d?t
   int m_resolvedConflicts;                   // S? xung d?t dã gi?i quy?t
   int m_abstainedConflicts;                  // S? l?n t? ch?i
   
public:
   CIntelligentConflictResolver()
   {
      Initialize();
   }
   
   void Initialize()
   {
      m_conflictThreshold = 0.3;              // 30% threshold for conflict detection
      m_severityThreshold = 0.7;              // 70% threshold for severe conflict
      m_abstainThreshold = 0.9;               // 90% threshold for abstaining
      
      // Initialize component reliability (equal start)
      for(int i = 0; i < 5; i++) {
         m_componentReliability[i] = 0.5;     // 50% initial reliability
         m_componentSuccessCount[i] = 0;
         m_componentTotalCount[i] = 0;
      }
      
      // Initialize market context weights
      InitializeMarketWeights();
      
      // Reset statistics
      m_totalConflicts = 0;
      m_resolvedConflicts = 0;
      m_abstainedConflicts = 0;
   }
   
   //+------------------------------------------------------------------+
   //| ?? MAIN CONFLICT RESOLUTION FUNCTION                           |
   //+------------------------------------------------------------------+
   SConflictData ResolveConflict(ENUM_SIGNAL_TYPE dragonSignal, ENUM_SIGNAL_TYPE waveSignal,
                                ENUM_SIGNAL_TYPE structureSignal, ENUM_SIGNAL_TYPE pvsraSignal,
                                ENUM_SIGNAL_TYPE smcSignal, ENUM_MARKET_REGIME marketRegime)
   {
      SConflictData conflict;
      conflict.Reset();
      
      // Store component votes
      conflict.dragonVote = dragonSignal;
      conflict.waveVote = waveSignal;
      conflict.structureVote = structureSignal;
      conflict.pvsraVote = pvsraSignal;
      conflict.smcVote = smcSignal;
      
      // Step 1: Detect conflict
      if(!DetectConflict(conflict)) {
         // No conflict - use simple majority
         conflict.resolvedSignal = GetMajorityVote(conflict);
         conflict.resolutionConfidence = 0.8;
         conflict.resolutionReason = "No conflict detected - majority vote";
         return conflict;
      }
      
      m_totalConflicts++;
      
      // Step 2: Analyze conflict severity
      AnalyzeConflictSeverity(conflict);
      
      // Step 3: Choose resolution strategy
      ChooseResolutionStrategy(conflict, marketRegime);
      
      // Step 4: Apply resolution strategy
      ApplyResolutionStrategy(conflict, marketRegime);
      
      // Step 5: Validate resolution
      ValidateResolution(conflict);
      
      if(conflict.resolvedSignal != SIGNAL_NONE) {
         m_resolvedConflicts++;
      } else {
         m_abstainedConflicts++;
      }
      
      return conflict;
   }
   
   //+------------------------------------------------------------------+
   //| ?? COMPATIBILITY FUNCTIONS FOR MASTER ORCHESTRATOR             |
   //+------------------------------------------------------------------+
   bool DetectConflicts(SComponentSignal &signals[], int count)
   {
      if(count < 2) return false;
      
      int buyCount = 0, sellCount = 0;
      double buyConfidence = 0.0, sellConfidence = 0.0;
      
      for(int i = 0; i < count; i++) {
         if(signals[i].signalType == SIGNAL_BUY && signals[i].confidence > 0.6) {
            buyCount++;
            buyConfidence += signals[i].confidence;
         } else if(signals[i].signalType == SIGNAL_SELL && signals[i].confidence > 0.6) {
            sellCount++;
            sellConfidence += signals[i].confidence;
         }
      }
      
      // Conflict if both buy and sell signals with high confidence
      return (buyCount > 0 && sellCount > 0 && 
              buyConfidence > 0.7 && sellConfidence > 0.7);
   }
   
   SConflictData ResolveConflicts(SComponentSignal &signals[], int count)
   {
      SConflictData result;
      result.Reset();
      
      if(count == 0) return result;
      
      // Calculate weighted votes
      double buyWeight = 0.0, sellWeight = 0.0;
      double totalWeight = 0.0;
      
      for(int i = 0; i < count; i++) {
         if(signals[i].signalType == SIGNAL_BUY) {
            buyWeight += signals[i].weight * signals[i].confidence;
         } else if(signals[i].signalType == SIGNAL_SELL) {
            sellWeight += signals[i].weight * signals[i].confidence;
         }
         totalWeight += signals[i].weight;
      }
      
      // Determine final signal
      if(buyWeight > sellWeight && buyWeight > totalWeight * 0.4) {
         result.resolvedSignal = SIGNAL_BUY;
         result.resolutionConfidence = buyWeight / totalWeight;
      } else if(sellWeight > buyWeight && sellWeight > totalWeight * 0.4) {
         result.resolvedSignal = SIGNAL_SELL;
         result.resolutionConfidence = sellWeight / totalWeight;
      } else {
         result.resolvedSignal = SIGNAL_NONE;
         result.resolutionConfidence = 0.0;
      }
      
      return result;
   }
   
   //+------------------------------------------------------------------+
   //| ?? DETECT CONFLICT - PHÁT HI?N XUNG Ð?T                       |
   //+------------------------------------------------------------------+
   bool DetectConflict(SConflictData& conflict)
   {
      ENUM_SIGNAL_TYPE signals[5] = {conflict.dragonVote, conflict.waveVote, 
                                    conflict.structureVote, conflict.pvsraVote, conflict.smcVote};
      
      int buyVotes = 0, sellVotes = 0, noneVotes = 0;
      
      for(int i = 0; i < 5; i++) {
         if(signals[i] == SIGNAL_BUY) buyVotes++;
         else if(signals[i] == SIGNAL_SELL) sellVotes++;
         else noneVotes++;
      }
      
      // Calculate conflict metrics
      int totalActiveVotes = buyVotes + sellVotes;
      if(totalActiveVotes == 0) return false;  // No active signals
      
      double agreement = (double)MathMax(buyVotes, sellVotes) / totalActiveVotes;
      double disagreement = 1.0 - agreement;
      
      // Detect conflict types
      if(disagreement >= m_conflictThreshold) {
         if(buyVotes > 0 && sellVotes > 0) {
            conflict.conflictType = CONFLICT_DIRECTIONAL;
            conflict.conflictDescription = StringFormat("Directional conflict: %d BUY vs %d SELL votes", 
                                                       buyVotes, sellVotes);
         } else if(noneVotes > totalActiveVotes) {
            conflict.conflictType = CONFLICT_STRENGTH;
            conflict.conflictDescription = StringFormat("Strength conflict: %d active vs %d inactive", 
                                                       totalActiveVotes, noneVotes);
         }
         
         conflict.conflictingComponents = MathMin(buyVotes, sellVotes) + noneVotes;
         return true;
      }
      
      return false;
   }
   
   //+------------------------------------------------------------------+
   //| ?? ANALYZE CONFLICT SEVERITY - PHÂN TÍCH M?C Ð? NGHIÊM TR?NG  |
   //+------------------------------------------------------------------+
   void AnalyzeConflictSeverity(SConflictData& conflict)
   {
      double severity = 0.0;
      
      // Base severity from conflicting components
      severity += (double)conflict.conflictingComponents / 5.0 * 0.4;
      
      // Severity from signal distribution
      ENUM_SIGNAL_TYPE signals[5] = {conflict.dragonVote, conflict.waveVote, 
                                    conflict.structureVote, conflict.pvsraVote, conflict.smcVote};
      
      int buyVotes = 0, sellVotes = 0;
      for(int i = 0; i < 5; i++) {
         if(signals[i] == SIGNAL_BUY) buyVotes++;
         else if(signals[i] == SIGNAL_SELL) sellVotes++;
      }
      
      // Perfect split is most severe
      if(buyVotes == sellVotes && buyVotes > 0) {
         severity += 0.4;  // Maximum severity for perfect split
      } else {
         double imbalance = MathAbs(buyVotes - sellVotes) / (double)(buyVotes + sellVotes);
         severity += (1.0 - imbalance) * 0.4;
      }
      
      // Additional severity from high-reliability components disagreeing
      severity += CalculateReliabilityConflictSeverity() * 0.2;
      
      conflict.conflictSeverity = MathMin(severity, 1.0);
   }
   
   //+------------------------------------------------------------------+
   //| ?? CHOOSE RESOLUTION STRATEGY - CH?N CHI?N LU?C GI?I QUY?T     |
   //+------------------------------------------------------------------+
   void ChooseResolutionStrategy(SConflictData& conflict, ENUM_MARKET_REGIME marketRegime)
   {
      // Critical conflicts require abstaining
      if(conflict.conflictSeverity >= m_abstainThreshold) {
         conflict.resolutionStrategy = RESOLUTION_ABSTAIN;
         return;
      }
      
      // Choose strategy based on conflict type and market regime
      switch(conflict.conflictType) {
         case CONFLICT_DIRECTIONAL:
            if(marketRegime == REGIME_TRENDING_BULLISH || marketRegime == REGIME_TRENDING_BEARISH) {
               conflict.resolutionStrategy = RESOLUTION_COMPONENT_RELIABILITY;
            } else {
               conflict.resolutionStrategy = RESOLUTION_WEIGHT_BASED;
            }
            break;
            
         case CONFLICT_STRENGTH:
            conflict.resolutionStrategy = RESOLUTION_MARKET_CONTEXT;
            break;
            
         case CONFLICT_TIMING:
            conflict.resolutionStrategy = RESOLUTION_COMPONENT_RELIABILITY;
            break;
            
         default:
            conflict.resolutionStrategy = RESOLUTION_WEIGHT_BASED;
            break;
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? APPLY RESOLUTION STRATEGY - ÁP D?NG CHI?N LU?C GI?I QUY?T   |
   //+------------------------------------------------------------------+
   void ApplyResolutionStrategy(SConflictData& conflict, ENUM_MARKET_REGIME marketRegime)
   {
      switch(conflict.resolutionStrategy) {
         case RESOLUTION_WEIGHT_BASED:
            ResolveByWeight(conflict, marketRegime);
            break;
            
         case RESOLUTION_COMPONENT_RELIABILITY:
            ResolveByReliability(conflict);
            break;
            
         case RESOLUTION_MARKET_CONTEXT:
            ResolveByMarketContext(conflict, marketRegime);
            break;
            
         case RESOLUTION_HISTORICAL_PERFORMANCE:
            ResolveByHistoricalPerformance(conflict);
            break;
            
         case RESOLUTION_ABSTAIN:
            conflict.resolvedSignal = SIGNAL_NONE;
            conflict.resolutionConfidence = 0.0;
            conflict.resolutionReason = "Conflict too severe - abstaining from trade";
            break;
            
         default:
            conflict.resolvedSignal = SIGNAL_NONE;
            conflict.resolutionConfidence = 0.0;
            conflict.resolutionReason = "Unknown resolution strategy";
            break;
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? RESOLVE BY WEIGHT - GI?I QUY?T THEO TR?NG S?                |
   //+------------------------------------------------------------------+
   void ResolveByWeight(SConflictData& conflict, ENUM_MARKET_REGIME marketRegime)
   {
      // Get market-appropriate weights
      double weights[5];
      GetMarketWeights(weights, marketRegime);
      
      // Store weights in conflict data
      conflict.dragonWeight = weights[0];
      conflict.waveWeight = weights[1];
      conflict.structureWeight = weights[2];
      conflict.pvsraWeight = weights[3];
      conflict.smcWeight = weights[4];
      
      // Calculate weighted votes
      double buyScore = 0.0, sellScore = 0.0;
      ENUM_SIGNAL_TYPE signals[5] = {conflict.dragonVote, conflict.waveVote, 
                                    conflict.structureVote, conflict.pvsraVote, conflict.smcVote};
      
      for(int i = 0; i < 5; i++) {
         if(signals[i] == SIGNAL_BUY) buyScore += weights[i];
         else if(signals[i] == SIGNAL_SELL) sellScore += weights[i];
      }
      
      // Determine winner
      double totalScore = buyScore + sellScore;
      if(totalScore > 0) {
         double winnerScore = MathMax(buyScore, sellScore);
         conflict.resolutionConfidence = winnerScore / totalScore;
         
         if(buyScore > sellScore) {
            conflict.resolvedSignal = SIGNAL_BUY;
            conflict.resolutionReason = StringFormat("Weight-based BUY: %.2f vs %.2f", buyScore, sellScore);
         } else {
            conflict.resolvedSignal = SIGNAL_SELL;
            conflict.resolutionReason = StringFormat("Weight-based SELL: %.2f vs %.2f", sellScore, buyScore);
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? RESOLVE BY RELIABILITY - GI?I QUY?T THEO Ð? TIN C?Y         |
   //+------------------------------------------------------------------+
   void ResolveByReliability(SConflictData& conflict)
   {
      double buyScore = 0.0, sellScore = 0.0;
      ENUM_SIGNAL_TYPE signals[5] = {conflict.dragonVote, conflict.waveVote, 
                                    conflict.structureVote, conflict.pvsraVote, conflict.smcVote};
      
      for(int i = 0; i < 5; i++) {
         if(signals[i] == SIGNAL_BUY) buyScore += m_componentReliability[i];
         else if(signals[i] == SIGNAL_SELL) sellScore += m_componentReliability[i];
      }
      
      double totalScore = buyScore + sellScore;
      if(totalScore > 0) {
         double winnerScore = MathMax(buyScore, sellScore);
         conflict.resolutionConfidence = winnerScore / totalScore;
         
         if(buyScore > sellScore) {
            conflict.resolvedSignal = SIGNAL_BUY;
            conflict.resolutionReason = StringFormat("Reliability-based BUY: %.2f vs %.2f", buyScore, sellScore);
         } else {
            conflict.resolvedSignal = SIGNAL_SELL;
            conflict.resolutionReason = StringFormat("Reliability-based SELL: %.2f vs %.2f", sellScore, buyScore);
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? RESOLVE BY MARKET CONTEXT - GI?I QUY?T THEO NG? C?NH TH? TRU?NG |
   //+------------------------------------------------------------------+
   void ResolveByMarketContext(SConflictData& conflict, ENUM_MARKET_REGIME marketRegime)
   {
      // In trending markets, prioritize trend-following components
      if(marketRegime == REGIME_TRENDING_BULLISH || marketRegime == REGIME_TRENDING_BEARISH) {
         // Dragon Band and Structure are better in trending markets
         if(conflict.dragonVote == conflict.structureVote && conflict.dragonVote != SIGNAL_NONE) {
            conflict.resolvedSignal = conflict.dragonVote;
            conflict.resolutionConfidence = 0.75;
            conflict.resolutionReason = "Trending market - Dragon+Structure agreement";
            return;
         }
      }
      
      // In ranging markets, prioritize mean-reversion components
      if(marketRegime == REGIME_RANGING) {
         // PVSRA and SMC are better in ranging markets
         if(conflict.pvsraVote == conflict.smcVote && conflict.pvsraVote != SIGNAL_NONE) {
            conflict.resolvedSignal = conflict.pvsraVote;
            conflict.resolutionConfidence = 0.75;
            conflict.resolutionReason = "Ranging market - PVSRA+SMC agreement";
            return;
         }
      }
      
      // Fallback to weight-based resolution
      ResolveByWeight(conflict, marketRegime);
   }
   
   //+------------------------------------------------------------------+
   //| ?? UPDATE COMPONENT PERFORMANCE - C?P NH?T HI?U SU?T COMPONENT |
   //+------------------------------------------------------------------+
   void UpdateComponentPerformance(int componentIndex, bool success)
   {
      if(componentIndex < 0 || componentIndex >= 5) return;
      
      m_componentTotalCount[componentIndex]++;
      if(success) m_componentSuccessCount[componentIndex]++;
      
      // Update reliability (with smoothing)
      if(m_componentTotalCount[componentIndex] > 0) {
         double newReliability = (double)m_componentSuccessCount[componentIndex] / m_componentTotalCount[componentIndex];
         m_componentReliability[componentIndex] = m_componentReliability[componentIndex] * 0.8 + newReliability * 0.2;
      }
   }
   
   //+------------------------------------------------------------------+
   //| ?? HELPER METHODS                                              |
   //+------------------------------------------------------------------+
   void InitializeMarketWeights()
   {
      // Trending market weights (favor trend-following)
      m_trendingWeights[0] = 0.35;  // Dragon Band
      m_trendingWeights[1] = 0.25;  // Wave
      m_trendingWeights[2] = 0.25;  // Structure
      m_trendingWeights[3] = 0.10;  // PVSRA
      m_trendingWeights[4] = 0.05;  // SMC
      
      // Ranging market weights (favor mean-reversion)
      m_rangingWeights[0] = 0.15;   // Dragon Band
      m_rangingWeights[1] = 0.20;   // Wave
      m_rangingWeights[2] = 0.20;   // Structure
      m_rangingWeights[3] = 0.25;   // PVSRA
      m_rangingWeights[4] = 0.20;   // SMC
      
      // Volatile market weights (balanced)
      m_volatileWeights[0] = 0.25;  // Dragon Band
      m_volatileWeights[1] = 0.20;  // Wave
      m_volatileWeights[2] = 0.20;  // Structure
      m_volatileWeights[3] = 0.20;  // PVSRA
      m_volatileWeights[4] = 0.15;  // SMC
   }
   
   void GetMarketWeights(double& weights[], ENUM_MARKET_REGIME marketRegime)
   {
      switch(marketRegime) {
         case REGIME_TRENDING_BULLISH:
         case REGIME_TRENDING_BEARISH:
            ArrayCopy(weights, m_trendingWeights);
            break;
         case REGIME_RANGING:
            ArrayCopy(weights, m_rangingWeights);
            break;
         default:
            ArrayCopy(weights, m_volatileWeights);
            break;
      }
   }
   
   ENUM_SIGNAL_TYPE GetMajorityVote(SConflictData& conflict)
   {
      ENUM_SIGNAL_TYPE signals[5] = {conflict.dragonVote, conflict.waveVote, 
                                    conflict.structureVote, conflict.pvsraVote, conflict.smcVote};
      
      int buyVotes = 0, sellVotes = 0;
      for(int i = 0; i < 5; i++) {
         if(signals[i] == SIGNAL_BUY) buyVotes++;
         else if(signals[i] == SIGNAL_SELL) sellVotes++;
      }
      
      if(buyVotes > sellVotes) return SIGNAL_BUY;
      if(sellVotes > buyVotes) return SIGNAL_SELL;
      return SIGNAL_NONE;
   }
   
   double CalculateReliabilityConflictSeverity()
   {
      // Calculate how much high-reliability components disagree
      double severity = 0.0;
      double highReliabilityThreshold = 0.7;
      
      for(int i = 0; i < 5; i++) {
         if(m_componentReliability[i] >= highReliabilityThreshold) {
            severity += 0.2;  // Each high-reliability component adds to severity
         }
      }
      
      return MathMin(severity, 1.0);
   }
   
   void ResolveByHistoricalPerformance(SConflictData& conflict)
   {
      // Find the component with best historical performance
      int bestComponent = 0;
      double bestReliability = m_componentReliability[0];
      
      for(int i = 1; i < 5; i++) {
         if(m_componentReliability[i] > bestReliability) {
            bestReliability = m_componentReliability[i];
            bestComponent = i;
         }
      }
      
      ENUM_SIGNAL_TYPE signals[5] = {conflict.dragonVote, conflict.waveVote, 
                                    conflict.structureVote, conflict.pvsraVote, conflict.smcVote};
      
      conflict.resolvedSignal = signals[bestComponent];
      conflict.resolutionConfidence = bestReliability;
      conflict.resolutionReason = StringFormat("Best performer (Component %d): %.1f%% reliability", 
                                              bestComponent, bestReliability*100);
   }
   
   void ValidateResolution(SConflictData& conflict)
   {
      // Ensure minimum confidence threshold
      if(conflict.resolutionConfidence < 0.6) {
         conflict.resolvedSignal = SIGNAL_NONE;
         conflict.resolutionReason += " - Low confidence, abstaining";
      }
   }
   
   // Getters for statistics
   double GetConflictResolutionRate() { return m_totalConflicts > 0 ? (double)m_resolvedConflicts / m_totalConflicts : 0.0; }
   double GetAbstainRate() { return m_totalConflicts > 0 ? (double)m_abstainedConflicts / m_totalConflicts : 0.0; }
   int GetTotalConflicts() { return m_totalConflicts; }
   double GetComponentReliability(int index) { return (index >= 0 && index < 5) ? m_componentReliability[index] : 0.0; }
};

#endif // SIGNAL_GENERATION_CONFLICT_RESOLVER_MQH