//+------------------------------------------------------------------+
//|                                           16_UI_02_SMC_Overlay.mqh |
//|                        Smart Money Concepts Visual Overlay System |
//|                                   Professional Chart Visualization |
//+------------------------------------------------------------------+
#ifndef UI_SMC_OVERLAY_MQH
#define UI_SMC_OVERLAY_MQH
#include "01_Core_00_Inputs.mqh"
#property copyright "Sonic R MC EA"
#property version   "2.0"
#property strict

// NOTE: Core includes are handled by MasterIncludes.mqh
// Avoid direct includes to prevent circular dependencies

//+------------------------------------------------------------------+
//| ?? SMC VISUAL THEME SYSTEM                                       |
//+------------------------------------------------------------------+
struct SSMCVisualTheme {
    // Order Block Colors
    color BullishOB_Fill;       // #10B981 with 20% opacity
    color BullishOB_Border;     // #059669 solid
    color BearishOB_Fill;       // #EF4444 with 20% opacity  
    color BearishOB_Border;     // #DC2626 solid
    
    // Liquidity Colors
    color LiquidityBuy_Line;    // #3B82F6 thick line
    color LiquiditySell_Line;   // #F59E0B thick line
    color LiquiditySwept_Line;  // #6B7280 dashed (swept)
    
    // Structure Colors
    color BOS_Bullish;          // #10B981 arrow up
    color BOS_Bearish;          // #EF4444 arrow down
    color CHoCH_Bullish;        // #8B5CF6 diamond up
    color CHoCH_Bearish;        // #EC4899 diamond down
    
    // Fair Value Gap Colors
    color FVG_Bullish_Fill;     // #06B6D4 with 15% opacity
    color FVG_Bearish_Fill;     // #F59E0B with 15% opacity
    color FVG_Border;           // #374151 thin line
    
    // Premium/Discount Zone Colors
    color Premium_Fill;         // #EF4444 with 10% opacity
    color Discount_Fill;        // #10B981 with 10% opacity
    color Equilibrium_Line;     // #6B7280 center line
    
    void Initialize() {
        // Order Blocks - Professional institutional colors
        BullishOB_Fill = C'129,185,16';      // Green with transparency
        BullishOB_Border = C'105,169,5';     // Darker green border
        BearishOB_Fill = C'68,68,239';       // Red with transparency
        BearishOB_Border = C'38,38,220';     // Darker red border
        
        // Liquidity - Clear directional colors
        LiquidityBuy_Line = C'246,130,59';   // Blue for buy liquidity
        LiquiditySell_Line = C'11,158,245';  // Orange for sell liquidity
        LiquiditySwept_Line = C'128,123,107'; // Gray for swept liquidity
        
        // Structure - Distinct markers
        BOS_Bullish = C'129,185,16';         // Green BOS
        BOS_Bearish = C'68,68,239';          // Red BOS
        CHoCH_Bullish = C'246,92,139';       // Purple CHoCH
        CHoCH_Bearish = C'153,76,236';       // Pink CHoCH
        
        // Fair Value Gaps - Subtle but visible
        FVG_Bullish_Fill = C'212,182,6';     // Cyan with transparency
        FVG_Bearish_Fill = C'11,158,245';    // Orange with transparency
        FVG_Border = C'81,65,55';            // Gray border
        
        // Premium/Discount Zones - Market structure
        Premium_Fill = C'68,68,239';         // Light red for premium
        Discount_Fill = C'129,185,16';       // Light green for discount
        Equilibrium_Line = C'128,123,107';   // Gray equilibrium
    }
};

//+------------------------------------------------------------------+
//| ?? SMC OVERLAY MANAGER CLASS                                     |
//+------------------------------------------------------------------+
class CSMCOverlayManager {
private:
    string m_prefix;
    SSMCVisualTheme m_theme;
    int m_maxObjects;
    int m_objectCount;
    datetime m_lastUpdate;
    bool m_isEnabled;
    
    // Object tracking
    string m_orderBlockObjects[];
    string m_liquidityObjects[];
    string m_structureObjects[];
    string m_fvgObjects[];
    
public:
    CSMCOverlayManager() {
        m_prefix = "SMC_Overlay_";
        m_theme.Initialize();
        m_maxObjects = InpOverlayMaxObjects;
        m_objectCount = 0;
        m_lastUpdate = 0;
        m_isEnabled = InpShowSMCOverlayZones;
        
        ArrayResize(m_orderBlockObjects, 50);
        ArrayResize(m_liquidityObjects, 30);
        ArrayResize(m_structureObjects, 20);
        ArrayResize(m_fvgObjects, 40);
    }
    
    //+------------------------------------------------------------------+
    //| ?? ORDER BLOCK VISUALIZATION                                     |
    //+------------------------------------------------------------------+
    void DrawOrderBlock(double high, double low, datetime startTime, bool isBullish, 
                       double strength = 0.8, string label = "") {
        if(!m_isEnabled || !InpShowOrderBlocksOverlay) return;
        
        string objName = m_prefix + "OB_" + TimeToString(startTime, TIME_DATE|TIME_SECONDS);
        
        // Create rectangle for order block
        if(!ObjectCreate(0, objName, OBJ_RECTANGLE, 0, startTime, high, 
                        TimeCurrent() + PeriodSeconds() * 20, low)) {
            Print("? Failed to create Order Block: ", objName);
            return;
        }
        
        // Set visual properties
        color fillColor = isBullish ? m_theme.BullishOB_Fill : m_theme.BearishOB_Fill;
        color borderColor = isBullish ? m_theme.BullishOB_Border : m_theme.BearishOB_Border;
        
        ObjectSetInteger(0, objName, OBJPROP_COLOR, borderColor);
        ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, fillColor);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_FILL, true);
        
        // Add strength indicator
        if(strength > 0.0) {
            string strengthLabel = StringFormat("OB %.0f%%", strength * 100);
            string labelName = objName + "_Label";
            
            if(ObjectCreate(0, labelName, OBJ_TEXT, 0, startTime, high + (high-low) * 0.1)) {
                ObjectSetString(0, labelName, OBJPROP_TEXT, strengthLabel);
                ObjectSetInteger(0, labelName, OBJPROP_COLOR, borderColor);
                ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
                ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
            }
        }
        
        // Track object for cleanup
        AddToObjectArray(m_orderBlockObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("? Drew %s Order Block: %.5f-%.5f (Strength: %.0f%%)", 
              isBullish ? "BULLISH" : "BEARISH", low, high, strength * 100));
    }
    
    //+------------------------------------------------------------------+
    //| ?? LIQUIDITY VISUALIZATION                                       |
    //+------------------------------------------------------------------+
    void DrawLiquidityLevel(double price, datetime time, bool isBuyLiquidity, 
                           bool isSwept = false, double volume = 0.0) {
        if(!m_isEnabled || !InpShowLiquidityOverlay) return;
        
        string objName = m_prefix + "LIQ_" + TimeToString(time, TIME_DATE|TIME_SECONDS) + 
                        "_" + DoubleToString(price, _Digits);
        
        // Create horizontal line for liquidity
        if(!ObjectCreate(0, objName, OBJ_HLINE, 0, time, price)) {
            Print("? Failed to create Liquidity Level: ", objName);
            return;
        }
        
        // Set visual properties based on type and status
        color lineColor;
        int lineStyle;
        int lineWidth;
        
        if(isSwept) {
            lineColor = m_theme.LiquiditySwept_Line;
            lineStyle = STYLE_DASH;
            lineWidth = 1;
        } else {
            lineColor = isBuyLiquidity ? m_theme.LiquidityBuy_Line : m_theme.LiquiditySell_Line;
            lineStyle = STYLE_SOLID;
            lineWidth = 2;
        }
        
        ObjectSetInteger(0, objName, OBJPROP_COLOR, lineColor);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, lineStyle);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, lineWidth);
        ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        
        // Add liquidity label
        string liquidityText = StringFormat("%s LIQ %.5f", 
                              isBuyLiquidity ? "BUY" : "SELL", price);
        if(volume > 0) liquidityText += StringFormat(" (Vol: %.0f)", volume);
        if(isSwept) liquidityText += " [SWEPT]";
        
        string labelName = objName + "_Label";
        if(ObjectCreate(0, labelName, OBJ_TEXT, 0, time, price)) {
            ObjectSetString(0, labelName, OBJPROP_TEXT, liquidityText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, lineColor);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, labelName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT);
        }
        
        // Track object
        AddToObjectArray(m_liquidityObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("?? Drew %s Liquidity: %.5f %s", 
              isBuyLiquidity ? "BUY" : "SELL", price, isSwept ? "[SWEPT]" : ""));
    }
    
    //+------------------------------------------------------------------+
    //| ??? MARKET STRUCTURE VISUALIZATION                               |
    //+------------------------------------------------------------------+
    void DrawStructureBreak(double price, datetime time, bool isBOS, bool isBullish) {
        if(!m_isEnabled || !InpShowBOSCHOCHOverlay) return;
        
        string structureType = isBOS ? "BOS" : "CHoCH";
        string objName = m_prefix + structureType + "_" + TimeToString(time, TIME_DATE|TIME_SECONDS);
        
        // Create arrow for structure break
        int arrowCode = isBullish ? 233 : 234; // Up/Down arrows
        if(!ObjectCreate(0, objName, OBJ_ARROW, 0, time, price)) {
            Print("? Failed to create Structure Break: ", objName);
            return;
        }
        
        // Set visual properties
        color arrowColor;
        if(isBOS) {
            arrowColor = isBullish ? m_theme.BOS_Bullish : m_theme.BOS_Bearish;
        } else {
            arrowColor = isBullish ? m_theme.CHoCH_Bullish : m_theme.CHoCH_Bearish;
        }
        
        ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrowCode);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, arrowColor);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 3);
        ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        
    // Add structure label (clear text)
    string structureText = StringFormat("%s %s", structureType, (isBullish ? "BULL" : "BEAR"));
        string labelName = objName + "_Label";
        
    double pip = ((_Digits==3 || _Digits==5) ? (10*_Point) : _Point);
    int barIndex = iBarShift(_Symbol, PERIOD_CURRENT, time, true);
    double dirOffset = (isBullish ? 1.0 : -1.0);
    double altOffset = (InpOverlayAlternateBarLabels && (barIndex % 2 == 1) ? 1.5 : 1.0);
    double yOffset = dirOffset * altOffset * MathMax(1, InpOverlayLabelOffsetPips) * pip;
    if(ObjectCreate(0, labelName, OBJ_TEXT, 0, time, price + yOffset)) {
            ObjectSetString(0, labelName, OBJPROP_TEXT, structureText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, arrowColor);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
            ObjectSetString(0, labelName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER);
        }
        
        // Track object
        AddToObjectArray(m_structureObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("??? Drew %s %s at %.5f", 
              isBullish ? "BULLISH" : "BEARISH", structureType, price));
    }
    
    //+------------------------------------------------------------------+
    //| ?? FAIR VALUE GAP VISUALIZATION                                  |
    //+------------------------------------------------------------------+
    void DrawFairValueGap(double high, double low, datetime startTime, bool isBullish,
                         double fillPercentage = 0.0, double strength = 0.7) {
        if(!m_isEnabled || !InpShowFVGOverlay) return;
        
        string objName = m_prefix + "FVG_" + TimeToString(startTime, TIME_DATE|TIME_SECONDS);
        
        // Create rectangle for FVG
        datetime endTime = TimeCurrent() + PeriodSeconds() * 15;
        if(!ObjectCreate(0, objName, OBJ_RECTANGLE, 0, startTime, high, endTime, low)) {
            Print("? Failed to create Fair Value Gap: ", objName);
            return;
        }
        
        // Set visual properties
        color fillColor = isBullish ? m_theme.FVG_Bullish_Fill : m_theme.FVG_Bearish_Fill;
        
        ObjectSetInteger(0, objName, OBJPROP_COLOR, m_theme.FVG_Border);
        ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, fillColor);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_FILL, true);
        
    // Add FVG info label (clear text)
    string fvgText = StringFormat("FVG %s %.0f%%", 
            isBullish ? "BULL" : "BEAR", fillPercentage * 100);
        string labelName = objName + "_Label";
        
    if(ObjectCreate(0, labelName, OBJ_TEXT, 0, startTime, (high + low) / 2)) {
            ObjectSetString(0, labelName, OBJPROP_TEXT, fvgText);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, m_theme.FVG_Border);
            ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
            ObjectSetString(0, labelName, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_CENTER);
        }
        
        // Track object
        AddToObjectArray(m_fvgObjects, objName);
        m_objectCount++;
        
        Print(StringFormat("?? Drew %s FVG: %.5f-%.5f (%.0f%% filled)", 
              isBullish ? "BULLISH" : "BEARISH", low, high, fillPercentage * 100));
    }
    
    //+------------------------------------------------------------------+
    //| ?? CLEANUP AND MANAGEMENT                                        |
    //+------------------------------------------------------------------+
    void CleanupOldObjects() {
        if(m_objectCount < m_maxObjects * 0.9) return;
        
        Print("?? Cleaning up old SMC overlay objects...");
        
        // Remove oldest objects from each category
        RemoveOldObjectsFromArray(m_orderBlockObjects, 10);
        RemoveOldObjectsFromArray(m_liquidityObjects, 5);
        RemoveOldObjectsFromArray(m_structureObjects, 3);
        RemoveOldObjectsFromArray(m_fvgObjects, 8);
        
        m_objectCount = CountActiveObjects();
        Print(StringFormat("? Cleanup complete. Active objects: %d", m_objectCount));
    }
    
    void RemoveAllObjects() {
        ObjectsDeleteAll(0, m_prefix);
        for(int i=0;i<ArraySize(m_orderBlockObjects);i++) m_orderBlockObjects[i] = "";
        for(int i=0;i<ArraySize(m_liquidityObjects);i++) m_liquidityObjects[i] = "";
        for(int i=0;i<ArraySize(m_structureObjects);i++) m_structureObjects[i] = "";
        for(int i=0;i<ArraySize(m_fvgObjects);i++) m_fvgObjects[i] = "";
        m_objectCount = 0;
        Print("?? All SMC overlay objects removed");
    }
    
    void UpdateTheme(SSMCVisualTheme &newTheme) {
        m_theme = newTheme;
        Print("?? SMC overlay theme updated");
    }
    
    void SetEnabled(bool enabled) {
        m_isEnabled = enabled;
        if(!enabled) RemoveAllObjects();
        Print(StringFormat("?? SMC overlay %s", enabled ? "ENABLED" : "DISABLED"));
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
//| ?? GLOBAL SMC OVERLAY INSTANCE                                   |
//+------------------------------------------------------------------+
// SYSTEMATIC FIX - MQL5 global pointers cannot be initialized with assignment
CSMCOverlayManager* g_SMCOverlay = NULL;

//+------------------------------------------------------------------+
//| ?? SMC OVERLAY HELPER FUNCTIONS                                   |
//+------------------------------------------------------------------+
// Helper functions for easy access
void SMC_DrawOrderBlock(double high, double low, datetime time, bool bullish, double strength = 0.8) {
    if(g_SMCOverlay != NULL) g_SMCOverlay.DrawOrderBlock(high, low, time, bullish, strength);
}

void SMC_DrawLiquidity(double price, datetime time, bool buyLiq, bool swept = false) {
    if(g_SMCOverlay != NULL) g_SMCOverlay.DrawLiquidityLevel(price, time, buyLiq, swept);
}

void SMC_DrawStructure(double price, datetime time, bool isBOS, bool bullish) {
    if(g_SMCOverlay != NULL) g_SMCOverlay.DrawStructureBreak(price, time, isBOS, bullish);
}

void SMC_DrawFVG(double high, double low, datetime time, bool bullish, double filled = 0.0) {
    if(g_SMCOverlay != NULL) g_SMCOverlay.DrawFairValueGap(high, low, time, bullish, filled);
}

#endif // SMC_OVERLAY_MANAGER_MQH
