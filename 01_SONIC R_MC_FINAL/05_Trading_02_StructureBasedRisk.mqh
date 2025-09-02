//+------------------------------------------------------------------+
//| 05_Trading_02_StructureBasedRisk.mqh                             |
//| Structure-Based Risk Management for Sonic R EA                  |
//| Calculates SL/TP based on swing highs/lows and market structure |
//+------------------------------------------------------------------+

#property strict

// Note: ENUM_SWING_TYPE already defined in core files

//+------------------------------------------------------------------+
//| Structure-Based Risk Parameters                                  |
//+------------------------------------------------------------------+
struct SStructureRiskParams {
    // Swing Detection Parameters
    int SwingLookback;              // Bars to look back for swing detection
    int MinSwingBars;               // Minimum bars between swings
    double SwingStrengthFilter;     // Minimum swing strength (0.0-1.0)
    
    // SL/TP Calculation Parameters
    double StructureBuffer;         // Buffer beyond structure level (pips)
    double MinSLDistance;           // Minimum SL distance (pips)
    double MaxSLDistance;           // Maximum SL distance (pips)
    double MinRRRatio;              // Minimum Risk:Reward ratio
    double MaxRRRatio;              // Maximum Risk:Reward ratio
    
    // ATR Integration
    bool UseATRValidation;          // Validate with ATR-based calculations
    double ATRMultiplierMin;        // Minimum ATR multiplier
    double ATRMultiplierMax;        // Maximum ATR multiplier
    
    void SetDefaults() {
        SwingLookback = 50;
        MinSwingBars = 3;
        SwingStrengthFilter = 0.3;
        
        StructureBuffer = 5.0;      // 5 pips buffer
        MinSLDistance = 20.0;       // 20 pips minimum
        MaxSLDistance = 150.0;      // 150 pips maximum
        MinRRRatio = 1.5;           // 1:1.5 minimum
        MaxRRRatio = 4.0;           // 1:4 maximum
        
        UseATRValidation = true;
        ATRMultiplierMin = 1.5;
        ATRMultiplierMax = 4.0;
    }
};

//+------------------------------------------------------------------+
//| Swing Point Structure                                           |
//+------------------------------------------------------------------+
struct SSwingPoint {
    datetime time;
    double price;
    ENUM_SWING_TYPE type;           // SWING_HIGH or SWING_LOW
    double strength;                // Swing strength (0.0-1.0)
    int barIndex;                   // Bar index when swing occurred
    bool isValid;
    
    void Reset() {
        time = 0;
        price = 0.0;
        type = SWING_HIGH;
        strength = 0.0;
        barIndex = -1;
        isValid = false;
    }
};

//+------------------------------------------------------------------+
//| Structure-Based Risk Calculator Class                           |
//+------------------------------------------------------------------+
class CStructureBasedRisk
{
private:
    SStructureRiskParams m_params;
    string m_symbol;
    ENUM_TIMEFRAMES m_timeframe;
    
    // Swing point arrays
    SSwingPoint m_swingHighs[];
    SSwingPoint m_swingLows[];
    int m_swingHighCount;
    int m_swingLowCount;
    
    // Performance tracking
    datetime m_lastUpdate;
    int m_updateThrottleMs;
    
public:
    CStructureBasedRisk(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) {
        m_symbol = (symbol == "") ? _Symbol : symbol;
        m_timeframe = timeframe;
        m_params.SetDefaults();
        
        ArrayResize(m_swingHighs, 0);
        ArrayResize(m_swingLows, 0);
        m_swingHighCount = 0;
        m_swingLowCount = 0;
        
        m_lastUpdate = 0;
        m_updateThrottleMs = 5000; // Update every 5 seconds
        
        Print(StringFormat("✅ [STRUCTURE RISK] Initialized for %s %s", m_symbol, EnumToString(m_timeframe)));
    }
    
    ~CStructureBasedRisk() {
        ArrayFree(m_swingHighs);
        ArrayFree(m_swingLows);
    }
    
    //+------------------------------------------------------------------+
    //| Update Swing Points Detection                                   |
    //+------------------------------------------------------------------+
    bool UpdateSwingPoints() {
        // Throttle updates for performance
        datetime currentTime = TimeCurrent();
        if(currentTime - m_lastUpdate < m_updateThrottleMs / 1000) return true;
        m_lastUpdate = currentTime;
        
        // Clear previous swing points
        ArrayResize(m_swingHighs, 0);
        ArrayResize(m_swingLows, 0);
        m_swingHighCount = 0;
        m_swingLowCount = 0;
        
        int availableBars = Bars(m_symbol, m_timeframe);
        if(availableBars < m_params.SwingLookback + 10) {
            Print("⚠️ [STRUCTURE RISK] Insufficient bars for swing detection");
            return false;
        }
        
        // Detect swing points
        for(int i = m_params.MinSwingBars; i < m_params.SwingLookback && i < availableBars - m_params.MinSwingBars; i++) {
            // Check for swing high
            if(IsSwingHigh(i)) {
                SSwingPoint swing;
                swing.time = iTime(m_symbol, m_timeframe, i);
                swing.price = iHigh(m_symbol, m_timeframe, i);
                swing.type = SWING_HIGH;
                swing.strength = CalculateSwingStrength(i, true);
                swing.barIndex = i;
                swing.isValid = (swing.strength >= m_params.SwingStrengthFilter);
                
                if(swing.isValid) {
                    int newSize = ArraySize(m_swingHighs);
                    ArrayResize(m_swingHighs, newSize + 1);
                    m_swingHighs[newSize] = swing;
                    m_swingHighCount++;
                }
            }
            
            // Check for swing low
            if(IsSwingLow(i)) {
                SSwingPoint swing;
                swing.time = iTime(m_symbol, m_timeframe, i);
                swing.price = iLow(m_symbol, m_timeframe, i);
                swing.type = SWING_LOW;
                swing.strength = CalculateSwingStrength(i, false);
                swing.barIndex = i;
                swing.isValid = (swing.strength >= m_params.SwingStrengthFilter);
                
                if(swing.isValid) {
                    int newSize = ArraySize(m_swingLows);
                    ArrayResize(m_swingLows, newSize + 1);
                    m_swingLows[newSize] = swing;
                    m_swingLowCount++;
                }
            }
        }
        
        Print(StringFormat("📊 [STRUCTURE RISK] Updated: %d swing highs, %d swing lows", 
                          m_swingHighCount, m_swingLowCount));
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Structure-Based Stop Loss                             |
    //+------------------------------------------------------------------+
    double CalculateStructureSL(ENUM_SIGNAL_TYPE signalType, double entryPrice) {
        if(!UpdateSwingPoints()) return 0.0;
        
        double structureSL = 0.0;
        double currentPrice = SymbolInfoDouble(m_symbol, SYMBOL_BID);
        
        if(signalType == SIGNAL_BUY) {
            // For BUY: Find nearest swing low below entry
            double nearestSwingLow = FindNearestSwingLow(entryPrice);
            if(nearestSwingLow > 0) {
                structureSL = nearestSwingLow - (m_params.StructureBuffer * _Point);
            }
        }
        else if(signalType == SIGNAL_SELL) {
            // For SELL: Find nearest swing high above entry
            double nearestSwingHigh = FindNearestSwingHigh(entryPrice);
            if(nearestSwingHigh > 0) {
                structureSL = nearestSwingHigh + (m_params.StructureBuffer * _Point);
            }
        }
        
        // Validate SL distance
        if(structureSL > 0) {
            double slDistance = MathAbs(entryPrice - structureSL) / _Point;
            
            // Check minimum/maximum distance
            if(slDistance < m_params.MinSLDistance) {
                Print(StringFormat("⚠️ [STRUCTURE RISK] SL too close: %.1f pips, adjusting to minimum", slDistance));
                if(signalType == SIGNAL_BUY) {
                    structureSL = entryPrice - (m_params.MinSLDistance * _Point);
                } else {
                    structureSL = entryPrice + (m_params.MinSLDistance * _Point);
                }
            }
            else if(slDistance > m_params.MaxSLDistance) {
                Print(StringFormat("⚠️ [STRUCTURE RISK] SL too far: %.1f pips, adjusting to maximum", slDistance));
                if(signalType == SIGNAL_BUY) {
                    structureSL = entryPrice - (m_params.MaxSLDistance * _Point);
                } else {
                    structureSL = entryPrice + (m_params.MaxSLDistance * _Point);
                }
            }
        }
        
        // ATR validation if enabled
        if(m_params.UseATRValidation && structureSL > 0) {
            double atrSL = CalculateATRBasedSL(signalType, entryPrice);
            if(atrSL > 0) {
                // Use wider of the two for better protection
                if(signalType == SIGNAL_BUY) {
                    structureSL = MathMin(structureSL, atrSL); // Lower SL for BUY
                } else {
                    structureSL = MathMax(structureSL, atrSL); // Higher SL for SELL
                }
            }
        }
        
        return SymbolInfoDouble(m_symbol, SYMBOL_BID) > 0 ? NormalizeDouble(structureSL, _Digits) : 0.0;
    }
    
    //+------------------------------------------------------------------+
    //| Calculate Structure-Based Take Profit                           |
    //+------------------------------------------------------------------+
    double CalculateStructureTP(ENUM_SIGNAL_TYPE signalType, double entryPrice, double stopLoss) {
        if(!UpdateSwingPoints()) return 0.0;
        
        double structureTP = 0.0;
        double slDistance = MathAbs(entryPrice - stopLoss);
        
        if(signalType == SIGNAL_BUY) {
            // For BUY: Find next resistance level above entry
            double nextResistance = FindNextResistanceLevel(entryPrice);
            if(nextResistance > 0) {
                structureTP = nextResistance - (m_params.StructureBuffer * _Point);
            }
        }
        else if(signalType == SIGNAL_SELL) {
            // For SELL: Find next support level below entry
            double nextSupport = FindNextSupportLevel(entryPrice);
            if(nextSupport > 0) {
                structureTP = nextSupport + (m_params.StructureBuffer * _Point);
            }
        }
        
        // Validate R:R ratio
        if(structureTP > 0 && stopLoss > 0) {
            double tpDistance = MathAbs(structureTP - entryPrice);
            double rrRatio = tpDistance / slDistance;
            
            if(rrRatio < m_params.MinRRRatio) {
                // Adjust TP to meet minimum R:R
                tpDistance = slDistance * m_params.MinRRRatio;
                if(signalType == SIGNAL_BUY) {
                    structureTP = entryPrice + tpDistance;
                } else {
                    structureTP = entryPrice - tpDistance;
                }
                Print(StringFormat("📈 [STRUCTURE RISK] Adjusted TP for min R:R %.1f", m_params.MinRRRatio));
            }
            else if(rrRatio > m_params.MaxRRRatio) {
                // Adjust TP to maximum R:R
                tpDistance = slDistance * m_params.MaxRRRatio;
                if(signalType == SIGNAL_BUY) {
                    structureTP = entryPrice + tpDistance;
                } else {
                    structureTP = entryPrice - tpDistance;
                }
                Print(StringFormat("📈 [STRUCTURE RISK] Adjusted TP for max R:R %.1f", m_params.MaxRRRatio));
            }
        }
        
        return SymbolInfoDouble(m_symbol, SYMBOL_BID) > 0 ? NormalizeDouble(structureTP, _Digits) : 0.0;
    }

    //+------------------------------------------------------------------+
    //| Helper Functions for Swing Detection                            |
    //+------------------------------------------------------------------+
private:
    bool IsSwingHigh(int barIndex) {
        if(barIndex < m_params.MinSwingBars || barIndex >= Bars(m_symbol, m_timeframe) - m_params.MinSwingBars) {
            return false;
        }

        double centerHigh = iHigh(m_symbol, m_timeframe, barIndex);

        // Check bars before and after
        for(int i = 1; i <= m_params.MinSwingBars; i++) {
            double leftHigh = iHigh(m_symbol, m_timeframe, barIndex + i);
            double rightHigh = iHigh(m_symbol, m_timeframe, barIndex - i);

            if(centerHigh <= leftHigh || centerHigh <= rightHigh) {
                return false;
            }
        }
        return true;
    }

    bool IsSwingLow(int barIndex) {
        if(barIndex < m_params.MinSwingBars || barIndex >= Bars(m_symbol, m_timeframe) - m_params.MinSwingBars) {
            return false;
        }

        double centerLow = iLow(m_symbol, m_timeframe, barIndex);

        // Check bars before and after
        for(int i = 1; i <= m_params.MinSwingBars; i++) {
            double leftLow = iLow(m_symbol, m_timeframe, barIndex + i);
            double rightLow = iLow(m_symbol, m_timeframe, barIndex - i);

            if(centerLow >= leftLow || centerLow >= rightLow) {
                return false;
            }
        }
        return true;
    }

    double CalculateSwingStrength(int barIndex, bool isHigh) {
        // Calculate swing strength based on price movement and volume
        double strength = 0.0;

        if(isHigh) {
            double high = iHigh(m_symbol, m_timeframe, barIndex);
            double prevHigh = iHigh(m_symbol, m_timeframe, barIndex + 1);
            double nextHigh = iHigh(m_symbol, m_timeframe, barIndex - 1);

            // Strength based on price difference
            double leftDiff = high - prevHigh;
            double rightDiff = high - nextHigh;
            strength = (leftDiff + rightDiff) / (2.0 * _Point);
        } else {
            double low = iLow(m_symbol, m_timeframe, barIndex);
            double prevLow = iLow(m_symbol, m_timeframe, barIndex + 1);
            double nextLow = iLow(m_symbol, m_timeframe, barIndex - 1);

            // Strength based on price difference
            double leftDiff = prevLow - low;
            double rightDiff = nextLow - low;
            strength = (leftDiff + rightDiff) / (2.0 * _Point);
        }

        // Normalize strength to 0.0-1.0 range
        return MathMin(1.0, MathMax(0.0, strength / 50.0)); // 50 pips = max strength
    }

    double FindNearestSwingLow(double referencePrice) {
        double nearestLow = 0.0;
        double minDistance = DBL_MAX;

        for(int i = 0; i < m_swingLowCount; i++) {
            if(m_swingLows[i].price < referencePrice) {
                double distance = referencePrice - m_swingLows[i].price;
                if(distance < minDistance) {
                    minDistance = distance;
                    nearestLow = m_swingLows[i].price;
                }
            }
        }

        return nearestLow;
    }

    double FindNearestSwingHigh(double referencePrice) {
        double nearestHigh = 0.0;
        double minDistance = DBL_MAX;

        for(int i = 0; i < m_swingHighCount; i++) {
            if(m_swingHighs[i].price > referencePrice) {
                double distance = m_swingHighs[i].price - referencePrice;
                if(distance < minDistance) {
                    minDistance = distance;
                    nearestHigh = m_swingHighs[i].price;
                }
            }
        }

        return nearestHigh;
    }

    double FindNextResistanceLevel(double referencePrice) {
        // Find next significant swing high above reference price
        double nextResistance = 0.0;
        double minDistance = DBL_MAX;

        for(int i = 0; i < m_swingHighCount; i++) {
            if(m_swingHighs[i].price > referencePrice && m_swingHighs[i].strength >= 0.5) {
                double distance = m_swingHighs[i].price - referencePrice;
                if(distance < minDistance) {
                    minDistance = distance;
                    nextResistance = m_swingHighs[i].price;
                }
            }
        }

        return nextResistance;
    }

    double FindNextSupportLevel(double referencePrice) {
        // Find next significant swing low below reference price
        double nextSupport = 0.0;
        double minDistance = DBL_MAX;

        for(int i = 0; i < m_swingLowCount; i++) {
            if(m_swingLows[i].price < referencePrice && m_swingLows[i].strength >= 0.5) {
                double distance = referencePrice - m_swingLows[i].price;
                if(distance < minDistance) {
                    minDistance = distance;
                    nextSupport = m_swingLows[i].price;
                }
            }
        }

        return nextSupport;
    }

    double CalculateATRBasedSL(ENUM_SIGNAL_TYPE signalType, double entryPrice) {
        // Get ATR for validation
        int atrHandle = iATR(m_symbol, m_timeframe, 14);
        if(atrHandle == INVALID_HANDLE) return 0.0;

        double atrBuffer[1];
        if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) <= 0) {
            IndicatorRelease(atrHandle);
            return 0.0;
        }

        double atr = atrBuffer[0];
        IndicatorRelease(atrHandle);

        // Calculate ATR-based SL
        double atrMultiplier = (m_params.ATRMultiplierMin + m_params.ATRMultiplierMax) / 2.0;

        if(signalType == SIGNAL_BUY) {
            return entryPrice - (atr * atrMultiplier);
        } else {
            return entryPrice + (atr * atrMultiplier);
        }
    }

public:
    //+------------------------------------------------------------------+
    //| Public Interface Functions                                      |
    //+------------------------------------------------------------------+
    void SetParameters(SStructureRiskParams &params) {
        m_params = params;
        Print("🔧 [STRUCTURE RISK] Parameters updated");
    }

    SStructureRiskParams GetParameters() {
        return m_params;
    }

    int GetSwingHighCount() { return m_swingHighCount; }
    int GetSwingLowCount() { return m_swingLowCount; }

    string GetStatus() {
        return StringFormat("Structure Risk: %s | Swings: %dH/%dL | Last Update: %s",
                          m_symbol,
                          m_swingHighCount, m_swingLowCount,
                          TimeToString(m_lastUpdate, TIME_SECONDS));
    }
};

//+------------------------------------------------------------------+
//| Global Structure-Based Risk Instance                            |
//+------------------------------------------------------------------+
CStructureBasedRisk* g_StructureRisk = NULL;

//+------------------------------------------------------------------+
//| Structure Risk Helper Functions                                 |
//+------------------------------------------------------------------+
void StructureRisk_Initialize() {
    if(g_StructureRisk == NULL) {
        g_StructureRisk = new CStructureBasedRisk(_Symbol, PERIOD_CURRENT);
    }
}

double StructureRisk_CalculateSL(ENUM_SIGNAL_TYPE signalType, double entryPrice) {
    if(g_StructureRisk != NULL) {
        return g_StructureRisk.CalculateStructureSL(signalType, entryPrice);
    }
    return 0.0;
}

double StructureRisk_CalculateTP(ENUM_SIGNAL_TYPE signalType, double entryPrice, double stopLoss) {
    if(g_StructureRisk != NULL) {
        return g_StructureRisk.CalculateStructureTP(signalType, entryPrice, stopLoss);
    }
    return 0.0;
}

void StructureRisk_Cleanup() {
    if(g_StructureRisk != NULL) {
        delete g_StructureRisk;
        g_StructureRisk = NULL;
    }
}

string StructureRisk_GetStatus() {
    if(g_StructureRisk != NULL) {
        return g_StructureRisk.GetStatus();
    }
    return "Structure Risk: Not initialized";
}
