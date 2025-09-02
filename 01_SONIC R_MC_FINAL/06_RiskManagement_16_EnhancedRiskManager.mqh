//+------------------------------------------------------------------+
//| 06_RiskManagement_16_EnhancedRiskManager.mqh                     |
//| Enhanced Risk Manager with Structure-Based Integration          |
//| Combines ATR-based and Structure-based SL/TP calculations       |
//+------------------------------------------------------------------+

#property strict
#include "01_Core_00_Inputs.mqh"
#include "05_Trading_02_StructureBasedRisk.mqh"

// Local safe fallback multiplier to avoid external unresolved refs
// If you integrate IntelligentManager global multiplier, wire it here.
double GetCombinedAssetRegimeMultiplier_Safe(){ return 1.0; }

//+------------------------------------------------------------------+
//| Enhanced Risk Result Structure                                  |
//+------------------------------------------------------------------+
struct SEnhancedRiskResult {
    double stopLoss;
    double takeProfit;
    double riskAmount;
    double rewardAmount;
    double rrRatio;
    double positionSize;
    
    // Calculation details
    double structureSL;
    double structureTP;
    double atrSL;
    double atrTP;
    string calculationMethod;
    bool isValid;
    string rejectionReason;
    
    void Reset() {
        stopLoss = 0.0;
        takeProfit = 0.0;
        riskAmount = 0.0;
        rewardAmount = 0.0;
        rrRatio = 0.0;
        positionSize = 0.0;
        
        structureSL = 0.0;
        structureTP = 0.0;
        atrSL = 0.0;
        atrTP = 0.0;
        calculationMethod = "";
        isValid = false;
        rejectionReason = "";
    }
};

//+------------------------------------------------------------------+
//| Enhanced Risk Calculation Functions                             |
//+------------------------------------------------------------------+

// Calculate ATR-based SL
double CalculateATRBasedSL_Enhanced(ENUM_SIGNAL_TYPE signalType, double entryPrice) {
    int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    if(atrHandle == INVALID_HANDLE) return 0.0;
    
    double atrBuffer[1];
    if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) <= 0) {
        IndicatorRelease(atrHandle);
        return 0.0;
    }
    
    double atr = atrBuffer[0];
    IndicatorRelease(atrHandle);
    
    // Use current optimized ATR multiplier
    double multiplier = InpSL_ATR_Multiplier; // 3.0 from recent optimization
    
    if(signalType == SIGNAL_BUY) {
        return entryPrice - (atr * multiplier);
    } else {
        return entryPrice + (atr * multiplier);
    }
}

// Calculate ATR-based TP
double CalculateATRBasedTP_Enhanced(ENUM_SIGNAL_TYPE signalType, double entryPrice, double stopLoss) {
    if(stopLoss <= 0) return 0.0;
    
    double slDistance = MathAbs(entryPrice - stopLoss);
    double tpDistance = slDistance * InpRiskReward; // Use current R:R setting
    
    if(signalType == SIGNAL_BUY) {
        return entryPrice + tpDistance;
    } else {
        return entryPrice - tpDistance;
    }
}

// Combine SL calculations (use wider for better protection)
double CombineSLCalculations_Enhanced(ENUM_SIGNAL_TYPE signalType, double structureSL, double atrSL) {
    if(structureSL <= 0) return atrSL;
    if(atrSL <= 0) return structureSL;
    
    // Use wider SL for better protection
    if(signalType == SIGNAL_BUY) {
        // For BUY: Lower SL is wider protection
        return MathMin(structureSL, atrSL);
    } else {
        // For SELL: Higher SL is wider protection
        return MathMax(structureSL, atrSL);
    }
}

// Combine TP calculations (use conservative TP for better hit rate)
double CombineTPCalculations_Enhanced(ENUM_SIGNAL_TYPE signalType, double structureTP, double atrTP) {
    if(structureTP <= 0) return atrTP;
    if(atrTP <= 0) return structureTP;
    
    // Use conservative TP (closer to entry) for better hit rate
    if(signalType == SIGNAL_BUY) {
        // For BUY: Lower TP is more conservative
        return MathMin(structureTP, atrTP);
    } else {
        // For SELL: Higher TP is more conservative
        return MathMax(structureTP, atrTP);
    }
}

// Validate R:R ratio and adjust if needed
bool ValidateAndAdjustRR_Enhanced(SEnhancedRiskResult &result, ENUM_SIGNAL_TYPE signalType, double entryPrice) {
    if(result.stopLoss <= 0 || result.takeProfit <= 0) {
        result.isValid = false;
        result.rejectionReason = "Invalid SL or TP values";
        return false;
    }
    
    // Calculate distances and R:R ratio
    result.riskAmount = MathAbs(entryPrice - result.stopLoss);
    result.rewardAmount = MathAbs(result.takeProfit - entryPrice);
    result.rrRatio = result.rewardAmount / result.riskAmount;
    
    // Validate R:R ratio
    double minRR = 1.5; // Minimum R:R ratio
    double maxRR = 4.0; // Maximum R:R ratio
    
    if(result.rrRatio < minRR) {
        result.isValid = false;
        result.rejectionReason = StringFormat("R:R ratio too low: %.2f < %.2f", result.rrRatio, minRR);
        return false;
    }
    
    if(result.rrRatio > maxRR) {
        // Adjust TP to maximum R:R
        double maxReward = result.riskAmount * maxRR;
        if(signalType == SIGNAL_BUY) {
            result.takeProfit = entryPrice + maxReward;
        } else {
            result.takeProfit = entryPrice - maxReward;
        }
        result.rewardAmount = maxReward;
        result.rrRatio = maxRR;
        Print(StringFormat("📈 [ENHANCED RISK] Adjusted TP for max R:R %.1f", maxRR));
    }
    
    return true;
}

// Calculate position size based on risk
double CalculatePositionSize_Enhanced(ENUM_SIGNAL_TYPE signalType, double entryPrice, double stopLoss) {
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    // Base risk from inputs (fallback 1.0%)
    double baseRiskPercent = (InpRiskPercent > 0.0 ? InpRiskPercent : 1.0);

    // Apply AssetDNA combined multiplier (asset type + regime)
    double adnaMul = 1.0;
    // Guard: allow external override if available; otherwise use safe local
    adnaMul = GetCombinedAssetRegimeMultiplier_Safe();
    // Clamp multiplier to safe bounds
    adnaMul = MathMax(0.5, MathMin(1.5, adnaMul));

    double effectiveRiskPercent = baseRiskPercent * adnaMul;
    double riskAmount = accountBalance * effectiveRiskPercent / 100.0;
    
    double stopDistance = MathAbs(entryPrice - stopLoss);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    if(stopDistance <= 0 || tickValue <= 0 || tickSize <= 0) {
        return 0.0;
    }
    
    double positionSize = riskAmount / (stopDistance / tickSize * tickValue);
    
    // Apply volume constraints
    double minVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    positionSize = MathMax(positionSize, minVolume);
    positionSize = MathMin(positionSize, maxVolume);
    positionSize = MathFloor(positionSize / volumeStep) * volumeStep;
    
    return positionSize;
}

//+------------------------------------------------------------------+
//| Main Enhanced Risk Calculation Function                         |
//+------------------------------------------------------------------+
SEnhancedRiskResult CalculateEnhancedRisk(ENUM_SIGNAL_TYPE signalType, double entryPrice, double confidence = 0.7) {
    SEnhancedRiskResult result;
    result.Reset();
    
    // Step 1: Try structure-based calculation
    result.structureSL = StructureRisk_CalculateSL(signalType, entryPrice);
    if(result.structureSL > 0) {
        result.structureTP = StructureRisk_CalculateTP(signalType, entryPrice, result.structureSL);
    }
    
    // Step 2: Calculate ATR-based as validation/fallback
    result.atrSL = CalculateATRBasedSL_Enhanced(signalType, entryPrice);
    result.atrTP = CalculateATRBasedTP_Enhanced(signalType, entryPrice, result.atrSL);
    
    // Step 3: Combine or choose best method
    if(result.structureSL > 0 && result.structureTP > 0) {
        // Structure-based calculation successful
        if(result.atrSL > 0) {
            // Combine structure and ATR
            result.stopLoss = CombineSLCalculations_Enhanced(signalType, result.structureSL, result.atrSL);
            result.takeProfit = CombineTPCalculations_Enhanced(signalType, result.structureTP, result.atrTP);
            result.calculationMethod = "STRUCTURE+ATR";
        } else {
            // Pure structure-based
            result.stopLoss = result.structureSL;
            result.takeProfit = result.structureTP;
            result.calculationMethod = "STRUCTURE";
        }
    }
    else if(result.atrSL > 0) {
        // Fallback to ATR-based
        result.stopLoss = result.atrSL;
        result.takeProfit = result.atrTP;
        result.calculationMethod = "ATR_FALLBACK";
    }
    else {
        // No valid calculation
        result.isValid = false;
        result.rejectionReason = "No valid SL/TP calculation method available";
        return result;
    }
    
    // Step 4: Validate and adjust R:R ratio
    if(!ValidateAndAdjustRR_Enhanced(result, signalType, entryPrice)) {
        return result; // Validation failed
    }
    
    // Step 5: Calculate position size
    result.positionSize = CalculatePositionSize_Enhanced(signalType, entryPrice, result.stopLoss);
    
    result.isValid = true;
    
    Print(StringFormat("📊 [ENHANCED RISK] %s | SL:%.5f TP:%.5f | R:R %.2f | Method: %s", 
                      EnumToString(signalType), result.stopLoss, result.takeProfit, 
                      result.rrRatio, result.calculationMethod));
    
    return result;
}

//+------------------------------------------------------------------+
//| Helper Functions                                                |
//+------------------------------------------------------------------+
string GetEnhancedRiskStatus() {
    return "Enhanced Risk Manager: Active";
}
