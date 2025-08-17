//+------------------------------------------------------------------+
//|                                         16_UI_03_PVSRA_Overlay.mqh |
//|                      PVSRA Pattern Visual Overlay System          |
//|                           Professional Volume Analysis Display     |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC EA"
#property version   "2.0"
#property strict

// NOTE: Core includes are handled by MasterIncludes.mqh
// Avoid direct includes to prevent circular dependencies

//+------------------------------------------------------------------+
//| ?? PVSRA VISUAL THEME SYSTEM                                     |
//+------------------------------------------------------------------+
struct SPVSRAVisualTheme {
    // Volume Bar Colors (based on PVSRA classification)
    color VolumeHigh_Bullish;      // #10B981 - High volume bullish
    color VolumeHigh_Bearish;      // #EF4444 - High volume bearish
    color VolumeLow_Bullish;       // #6EE7B7 - Low volume bullish
    color VolumeLow_Bearish;       // #FCA5A5 - Low volume bearish
    color VolumeNormal;            // #9CA3AF - Normal volume
    
    // Pattern Colors
    color Spring_Color;            // #8B5CF6 - Spring action
    color Upthrust_Color;          // #EC4899 - Upthrust action
    color SellingClimax_Color;     // #DC2626 - Selling climax
    color AutomaticRally_Color;    // #059669 - Automatic rally
    color SignOfStrength_Color;    // #0891B2 - Sign of strength
    color SignOfWeakness_Color;    // #EA580C - Sign of weakness
    
    // Support/Resistance Colors
    color Support_Strong;          // #10B981 - Strong support
    color Support_Weak;            // #6EE7B7 - Weak support
    color Resistance_Strong;       // #EF4444 - Strong resistance
    color Resistance_Weak;         // #FCA5A5 - Weak resistance
    
    // Wyckoff Phase Colors
    color Accumulation_Zone;       // #10B981 with 15% opacity
    color Distribution_Zone;       // #EF4444 with 15% opacity
    color Markup_Zone;             // #3B82F6 with 15% opacity
    color Markdown_Zone;           // #F59E0B with 15% opacity
    
    void Initialize() {
        // Volume classification colors
        VolumeHigh_Bullish = C'129,185,16';     // Bright green
        VolumeHigh_Bearish = C'68,68,239';      // Bright red
        VolumeLow_Bullish = C'183,231,110';     // Light green
        VolumeLow_Bearish = C'165,165,252';     // Light red
        VolumeNormal = C'175,163,154';          // Gray
        
        // PVSRA pattern colors
        Spring_Color = C'246,92,139';           // Purple
        Upthrust_Color = C'153,76,236';         // Pink
        SellingClimax_Color = C'38,38,220';     // Dark red
        AutomaticRally_Color = C'105,169,5';    // Dark green
        SignOfStrength_Color = C'178,145,2';    // Cyan
        SignOfWeakness_Color = C'12,116,234';   // Orange
        
        // Support/Resistance strength
        Support_Strong = C'129,185,16';         // Green
        Support_Weak = C'183,231,110';          // Light green
        Resistance_Strong = C'68,68,239';       // Red
        Resistance_Weak = C'165,165,252';       // Light red
        
        // Wyckoff phases
        Accumulation_Zone = C'129,185,16';      // Green zone
        Distribution_Zone = C'68,68,239';       // Red zone
        Markup_Zone = C'246,130,59';            // Blue zone
        Markdown_Zone = C'11,158,245';          // Orange zone
    }
};

//+------------------------------------------------------------------+
//| ?? PVSRA OVERLAY MANAGER CLASS                                   |
//+------------------------------------------------------------------+
class CPVSRAOverlayManager {
private:
    string m_prefix;
    SPVSRAVisualTheme m_theme;
    int m_maxObjects;
    int m_objectCount;
    datetime m_lastUpdate;
    bool m_isEnabled;
    
    // Pattern tracking
    string m_patternObjects[];
    string m_volumeObjects[];
    string m_srObjects[];
    string m_wyckoffObjects[];
    
public:
    CPVSRAOverlayManager() {
        m_prefix = "PVSRA_Overlay_";
        m_theme.Initialize();
        m_maxObjects = InpOverlayMaxObjects;
        m_objectCount = 0;
        m_lastUpdate = 0;
        m_isEnabled = InpEnablePVSRA;
        
        ArrayResize(m_patternObjects, 30);
        ArrayResize(m_volumeObjects, 100);
        ArrayResize(m_srObjects, 40);
        ArrayResize(m_wyckoffObjects, 20);
    }
    
    //+------------------------------------------------------------------+
    //| ?? VOLUME BAR VISUALIZATION                                      |
    //+------------------------------------------------------------------+
    void DrawVolumeBar(int barIndex, double volume, double avgVolume, 
                      double bodyPercent, double closePosition) {
        if(!m_isEnabled) return;
        
        datetime barTime = iTime(_Symbol, PERIOD_CURRENT, barIndex);
        double high = iHigh(_Symbol, PERIOD_CURRENT, barIndex);
        double low = iLow(_Symbol, PERIOD_CURRENT, barIndex);
        double close = iClose(_Symbol, PERIOD_CURRENT, barIndex);
        double open = iOpen(_Symbol, PERIOD_CURRENT, barIndex);
        
        // Classify volume
        double volumeRatio = volume / avgVolume;
        bool isBullish = (close > open);
        bool isHighVolume = (volumeRatio > 1.5);
        bool isLowVolume = (volumeRatio < 0.7);
        
        // Determine color based on PVSRA classification
        color barColor;
        string volumeType;
        
        if(isHighVolume) {
            barColor = isBullish ? m_theme.VolumeHigh_Bullish : m_theme.VolumeHigh_Bearish;
            volumeType = "HIGH_VOL";
        } else if(isLowVolume) {
            barColor = isBullish ? m_theme.VolumeLow_Bullish : m_theme.VolumeLow_Bearish;
            volumeType = "LOW_VOL";
        } else {
            barColor = m_theme.VolumeNormal;
            volumeType = "NORMAL";
        }
        
        // Create volume indicator
        string objName = m_prefix + "VOL_" + IntegerToString(barIndex);
        
        // Draw volume bar as rectangle at bottom of chart
        double chartHeight = ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN);
        double volumeHeight = (volumeRatio * chartHeight * 0.1); // 10% of chart height max
        double volumeBottom = ChartGetDouble(0, CHART_PRICE_MIN);
        
        if(ObjectCreate(0, objName, OBJ_RECTANGLE, 0, barTime, volumeBottom, 
                       barTime + PeriodSeconds(), volumeBottom + volumeHeight)) {
            ObjectSetInteger(0, objName, OBJPROP_COLOR, barColor);
            ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, barColor);
            ObjectSetInteger(0, objName, OBJPROP_FILL, true);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        }
        
        // Add volume info if significant
        if(isHighVolume || isLowVolume) {
            string labelName = objName + "_Label";
            string volumeText = StringFormat("%s %.1fx", volumeType, volumeRatio);
            
            if(ObjectCreate(0, labelName, OBJ_TEXT, 0, barTime, high + 5 * _Point)) {
                ObjectSetString(0, labelName, OBJPROP_TEXT, volumeText);
                ObjectSetInteger(0, labelName, OBJPROP_COLOR, barColor);
                ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 7);
                ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
                ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER);
            }
        }
        
        AddToObjectArray(m_volumeObjects, objName);
        m_objectCount++;
    }
    
    //+------------------------------------------------------------------+
    //| ?? PVSRA PATTERN VISUALIZATION                                   |
    //+------------------------------------------------------------------+
    void DrawPVSRAPattern(ENUM_PVSRA_PATTERN pattern, datetime time, double price, 
                         double confidence, string additionalInfo = "") {
        if(!m_isEnabled || pattern == PVSRA_NONE) return;
        
        string patternName = EnumToString(pattern);
        string objName = m_prefix + "PATTERN_" + patternName + "_" + TimeToString(time, TIME_SECONDS);
        
        // Get pattern-specific visual properties
        color patternColor;
        int symbolCode;
        string patternText;
        
        switch(pattern) {
            case PVSRA_SPRING:
                patternColor = m_theme.Spring_Color;
                symbolCode = 115; // Diamond
                patternText = "?? SPRING";
                break;
            case PVSRA_UPTHRUST:
                patternColor = m_theme.Upthrust_Color;
                symbolCode = 116; // Diamond
                patternText = "? UPTHRUST";
                break;
            case PVSRA_SELLING_CLIMAX:
                patternColor = m_theme.SellingClimax_Color;
                symbolCode = 234; // Down arrow
                patternText = "?? SELLING CLIMAX";
                break;
            case PVSRA_AUTOMATIC_RALLY:
                patternColor = m_theme.AutomaticRally_Color;
                symbolCode = 233; // Up arrow
                patternText = "?? AUTO RALLY";
                break;
            case PVSRA_SIGN_OF_STRENGTH:
                patternColor = m_theme.SignOfStrength_Color;
                symbolCode = 217; // Plus
                patternText = "?? STRENGTH";
                break;
            default:
                patternColor = m_theme.VolumeNormal;
                symbolCode = 159; // Circle
                patternText = "?? PATTERN";
        }
        
        // Create pattern symbol
        if(ObjectCreate(0, objName, OBJ_ARROW, 0, time, price)) {
            ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, symbolCode);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, patternColor);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 4);
            ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        }
        
        // Add pattern label with confidence
        string labelName = objName + "_Label";
        string fullText = StringFormat("%s (%.0f%%)", patternText, confidence * 100);
        if(additionalInfo != "") fullText += "\n" + additionalInfo;
        
        if(ObjectCreate(0, labelName, OBJ_TEXT, 0, time, price + 15 * _Point)) {
            ObjectSetString(0, labelName, OBJPROP_TEXT, fullText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, patternColor);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, labelName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER);
        }
        
        AddToObjectArray(m_patternObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("?? Drew PVSRA Pattern: %s at %.5f (Confidence: %.0f%%)", 
              patternText, price, confidence * 100));
    }
    
    //+------------------------------------------------------------------+
    //| ??? SUPPORT/RESISTANCE VISUALIZATION                             |
    //+------------------------------------------------------------------+
    void DrawSupportResistance(double price, datetime startTime, bool isSupport, 
                              double strength, int touchCount = 1) {
        if(!m_isEnabled) return;
        
        string srType = isSupport ? "SUPPORT" : "RESISTANCE";
        string objName = m_prefix + srType + "_" + DoubleToString(price, _Digits);
        
        // Determine color based on strength
        color srColor;
        int lineWidth;
        
        if(strength > 0.8) {
            srColor = isSupport ? m_theme.Support_Strong : m_theme.Resistance_Strong;
            lineWidth = 3;
        } else {
            srColor = isSupport ? m_theme.Support_Weak : m_theme.Resistance_Weak;
            lineWidth = 2;
        }
        
        // Create horizontal line
        if(ObjectCreate(0, objName, OBJ_HLINE, 0, startTime, price)) {
            ObjectSetInteger(0, objName, OBJPROP_COLOR, srColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, lineWidth);
            ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        }
        
        // Add S/R label
        string labelName = objName + "_Label";
        string srText = StringFormat("%s %.5f (%.0f%% | %d touches)", 
                       srType, price, strength * 100, touchCount);
        
        if(ObjectCreate(0, labelName, OBJ_TEXT, 0, startTime, price)) {
            ObjectSetString(0, labelName, OBJPROP_TEXT, srText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, srColor);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT);
        }
        
        AddToObjectArray(m_srObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("??? Drew %s: %.5f (Strength: %.0f%%, Touches: %d)", 
              srType, price, strength * 100, touchCount));
    }
    
    //+------------------------------------------------------------------+
    //| ?? WYCKOFF PHASE VISUALIZATION                                   |
    //+------------------------------------------------------------------+
    void DrawWyckoffPhase(ENUM_WYCKOFF_PHASE phase, datetime startTime, datetime endTime,
                         double high, double low, double confidence) {
        if(!m_isEnabled || phase == PHASE_UNKNOWN) return;
        
        string phaseName = EnumToString(phase);
        string objName = m_prefix + "WYCKOFF_" + phaseName + "_" + TimeToString(startTime, TIME_SECONDS);
        
        // Get phase-specific color
        color phaseColor;
        string phaseText;
        
        switch(phase) {
            case PHASE_ACCUMULATION:
                phaseColor = m_theme.Accumulation_Zone;
                phaseText = "?? ACCUMULATION";
                break;
            case PHASE_DISTRIBUTION:
                phaseColor = m_theme.Distribution_Zone;
                phaseText = "?? DISTRIBUTION";
                break;
            case PHASE_MARKUP:
                phaseColor = m_theme.Markup_Zone;
                phaseText = "?? MARKUP";
                break;
            case PHASE_MARKDOWN:
                phaseColor = m_theme.Markdown_Zone;
                phaseText = "?? MARKDOWN";
                break;
            default:
                return;
        }
        
        // Create phase zone rectangle
        if(ObjectCreate(0, objName, OBJ_RECTANGLE, 0, startTime, high, endTime, low)) {
            ObjectSetInteger(0, objName, OBJPROP_COLOR, phaseColor);
            ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, phaseColor);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
            ObjectSetInteger(0, objName, OBJPROP_FILL, true);
        }
        
        // Add phase label
        string labelName = objName + "_Label";
        string fullText = StringFormat("%s (%.0f%%)", phaseText, confidence * 100);
        
        if(ObjectCreate(0, labelName, OBJ_TEXT, 0, startTime, (high + low) / 2)) {
            ObjectSetString(0, labelName, OBJPROP_TEXT, fullText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, phaseColor);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
            ObjectSetString(0, labelName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER);
        }
        
        AddToObjectArray(m_wyckoffObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("?? Drew Wyckoff Phase: %s (%.0f%% confidence)", 
              phaseText, confidence * 100));
    }
    
    //+------------------------------------------------------------------+
    //| ?? CLEANUP AND MANAGEMENT                                        |
    //+------------------------------------------------------------------+
    void CleanupOldObjects() {
        if(m_objectCount < m_maxObjects * 0.9) return;
        
        Print("?? Cleaning up old PVSRA overlay objects...");
        
        // Remove oldest objects from each category
        RemoveOldObjectsFromArray(m_patternObjects, 5);
        RemoveOldObjectsFromArray(m_volumeObjects, 20);
        RemoveOldObjectsFromArray(m_srObjects, 8);
        RemoveOldObjectsFromArray(m_wyckoffObjects, 3);
        
        m_objectCount = CountActiveObjects();
        Print(StringFormat("? PVSRA cleanup complete. Active objects: %d", m_objectCount));
    }
    
    void RemoveAllObjects() {
        ObjectsDeleteAll(0, m_prefix);
        ArrayInitialize(m_patternObjects, "");
        ArrayInitialize(m_volumeObjects, "");
        ArrayInitialize(m_srObjects, "");
        ArrayInitialize(m_wyckoffObjects, "");
        m_objectCount = 0;
        Print("?? All PVSRA overlay objects removed");
    }
    
    void SetEnabled(bool enabled) {
        m_isEnabled = enabled;
        if(!enabled) RemoveAllObjects();
        Print(StringFormat("?? PVSRA overlay %s", enabled ? "ENABLED" : "DISABLED"));
    }
    
    void UpdateTheme(SPVSRAVisualTheme &newTheme) {
        m_theme = newTheme;
        Print("?? PVSRA overlay theme updated");
    }
    
private:
    void AddToObjectArray(string &array[], string objName) {
        for(int i = 0; i < ArraySize(array); i++) {
            if(array[i] == "") {
                array[i] = objName;
                return;
            }
        }
    }
    
    void RemoveOldObjectsFromArray(string &array[], int removeCount) {
        int removed = 0;
        for(int i = 0; i < ArraySize(array) && removed < removeCount; i++) {
            if(array[i] != "") {
                ObjectDelete(0, array[i]);
                ObjectDelete(0, array[i] + "_Label");
                array[i] = "";
                removed++;
            }
        }
    }
    
    int CountActiveObjects() {
        return ObjectsTotal(0, 0, OBJ_RECTANGLE) + ObjectsTotal(0, 0, OBJ_HLINE) + 
               ObjectsTotal(0, 0, OBJ_ARROW) + ObjectsTotal(0, 0, OBJ_TEXT);
    }
};

//+------------------------------------------------------------------+
//| ?? GLOBAL PVSRA OVERLAY INSTANCE                                 |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - MQL5 global pointers cannot be initialized with assignment
CPVSRAOverlayManager* g_PVSRAOverlay;

// Helper functions for easy access
void PVSRA_DrawPattern(ENUM_PVSRA_PATTERN pattern, datetime time, double price, double confidence) {
    if(g_PVSRAOverlay != NULL) g_PVSRAOverlay.DrawPVSRAPattern(pattern, time, price, confidence);
}

void PVSRA_DrawVolumeBar(int barIndex, double volume, double avgVolume, double bodyPercent, double closePos) {
    if(g_PVSRAOverlay != NULL) g_PVSRAOverlay.DrawVolumeBar(barIndex, volume, avgVolume, bodyPercent, closePos);
}

void PVSRA_DrawSR(double price, datetime time, bool isSupport, double strength, int touches = 1) {
    if(g_PVSRAOverlay != NULL) g_PVSRAOverlay.DrawSupportResistance(price, time, isSupport, strength, touches);
}

void PVSRA_DrawWyckoffPhase(ENUM_WYCKOFF_PHASE phase, datetime start, datetime end, double high, double low, double confidence) {
    if(g_PVSRAOverlay != NULL) g_PVSRAOverlay.DrawWyckoffPhase(phase, start, end, high, low, confidence);
}
