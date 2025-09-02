//+------------------------------------------------------------------+
//| 16_UI_05_EMA_Overlay.mqh                                         |
//| EMA Visualization Overlay for Sonic R EA                        |
//| Displays EMA 34, 89, 200 lines on chart                         |
//+------------------------------------------------------------------+

#property strict

#ifndef UI_EMA_OVERLAY_MQH
#define UI_EMA_OVERLAY_MQH
#include "01_Core_00_Inputs.mqh"

// Compat shim for testers that lack ascii api
#ifndef ObjectSetStringASCII
#define ObjectSetStringASCII(chart, name, prop, value) ObjectSetString(chart, name, prop, value)
#endif

//+------------------------------------------------------------------+
//| EMA Visual Theme System                                          |
//+------------------------------------------------------------------+
struct SEMAVisualTheme {
    // Dragon Band (EMA34 on High/Close/Low)
    color DragonHighColor;      // High line color (lighter red)
    color DragonCloseColor;     // Close line color (main red)
    color DragonLowColor;       // Low line color (lighter red)
    // Trend EMAs
    color EMA89_Color;          // Blue - Medium term trend
    color EMA200_Color;         // Yellow - Long term trend

    // Line Properties
    int LineWidth;              // Default thickness
    ENUM_LINE_STYLE LineStyle;  // Default line style
    bool ShowLabels;            // Show EMA labels

    // Dragon specific styling
    int DragonCloseWidth;       // Thicker center line
    int DragonEdgeWidth;        // Thinner edge lines
    ENUM_LINE_STYLE DragonCloseStyle; // Solid
    ENUM_LINE_STYLE DragonEdgeStyle;  // Dashed

    void SetDefault() {
        // Colors
        DragonCloseColor = clrRed;
        DragonHighColor  = (color)C'255,120,120';
        DragonLowColor   = (color)C'255,180,180';
        EMA89_Color = clrBlue;
        EMA200_Color = clrGold;

        // Defaults
        LineWidth = 2;
        LineStyle = STYLE_SOLID;
        ShowLabels = false;

        // Dragon styles
        DragonCloseWidth = 3;
        DragonEdgeWidth = 1;
        DragonCloseStyle = STYLE_SOLID;
        DragonEdgeStyle = STYLE_DASH;
    }
};

//+------------------------------------------------------------------+
//| EMA Overlay Manager Class                                        |
//+------------------------------------------------------------------+
class CEMAOverlay
{
private:
    string m_prefix;
    bool m_isEnabled;
    SEMAVisualTheme m_theme;
    long m_chartId;

    // EMA Handles
    // Dragon Band (EMA 34 on High/Close/Low)
    int m_ema34HighHandle;
    int m_ema34CloseHandle;
    int m_ema34LowHandle;
    // Trend/Long-term EMAs (Close)
    int m_ema89Handle;
    int m_ema200Handle;

    // Object tracking
    string m_emaObjects[];
    int m_objectCount;
    int m_maxObjects;

    // Performance tracking
    datetime m_lastUpdate;
    int m_updateThrottleMs;


        // Segment reuse tracking per polyline base
        string m_segBases[];
        int    m_segCounts[];

public:
    CEMAOverlay() {
        m_prefix = "SONIC_EMA_";
        m_isEnabled = InpShowEMA34 || InpShowEMA89 || InpShowEMA200;
        m_theme.SetDefault();
        m_chartId = ChartID();

        m_ema34HighHandle = INVALID_HANDLE;
        m_ema34CloseHandle = INVALID_HANDLE;
        m_ema34LowHandle = INVALID_HANDLE;
        m_ema89Handle = INVALID_HANDLE;
        m_ema200Handle = INVALID_HANDLE;

        ArrayResize(m_emaObjects, 0);
        m_objectCount = 0;
        m_maxObjects = 500; // Limit for performance

        m_lastUpdate = 0;
        m_updateThrottleMs = InpOverlayThrottleMs;
        }
    // Draw EMA as a single polyline spanning the visible chart region
    void DrawEMAPolyline(int handle, const string name, color clr, int width, ENUM_LINE_STYLE style) {
        if(handle == INVALID_HANDLE) return;

        // Determine visible range
        long first_visible = (long)ChartGetInteger(m_chartId, CHART_FIRST_VISIBLE_BAR);
        long visible_bars  = (long)ChartGetInteger(m_chartId, CHART_VISIBLE_BARS);
        if(visible_bars <= 1) return;

        int start = (int)first_visible;
        int count = (int)visible_bars + 1; // +1 to ensure continuity

        // Copy EMA values and times in left->right order
        double vals[]; ArraySetAsSeries(vals, false);
        datetime times[]; ArraySetAsSeries(times, false);
        int copied1 = CopyBuffer(handle, 0, start, count, vals);
        int copied2 = CopyTime(_Symbol, PERIOD_CURRENT, start, count, times);
        int n = MathMin(copied1, copied2);
        if(n <= 1) return;

        // Create polyline object if missing
        // ensure clean base: no creation here; we draw segmented OBJ_TREND across visible bars

        // Update style each call (in case theme changed)
        ObjectSetInteger(m_chartId, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(m_chartId, name, OBJPROP_WIDTH, width);
        ObjectSetInteger(m_chartId, name, OBJPROP_STYLE, style);

        // Update points: OBJ_POLYGON only supports 2 points visually as a segment,
        // so fallback to segmented OBJ_TREND lines for full width (efficiently)
        string segBase = name + "_SEG_";
        // Reuse existing segments: create/update up to required count
        int segCount = n - 1;
        for(int i=1; i<=segCount; i++) {
            string sname = segBase + IntegerToString(i);
            datetime t1 = times[i];
            datetime t0 = times[i-1];
            double p1 = vals[i];
            double p0 = vals[i-1];
            if(p0 <= 0 || p1 <= 0) continue;
            if(ObjectFind(m_chartId, sname) < 0) {
                ObjectCreate(m_chartId, sname, OBJ_TREND, 0, t1, p1, t0, p0);
                ObjectSetInteger(m_chartId, sname, OBJPROP_BACK, true);
                ObjectSetInteger(m_chartId, sname, OBJPROP_SELECTABLE, false);
                AddToObjectArray(sname);
            } else {
                ObjectMove(m_chartId, sname, 0, t1, p1);
                ObjectMove(m_chartId, sname, 1, t0, p0);
            }
            ObjectSetInteger(m_chartId, sname, OBJPROP_COLOR, clr);
            ObjectSetInteger(m_chartId, sname, OBJPROP_WIDTH, width);
            ObjectSetInteger(m_chartId, sname, OBJPROP_STYLE, style);
            ObjectSetInteger(m_chartId, sname, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(m_chartId, sname, OBJPROP_RAY_LEFT, false);
        }

        // Periodic cleanup of excess segments when viewport shrinks
        segBase = name + "_SEG_";  // Reuse existing variable
        int idx = -1;
        int nbase = ArraySize(m_segBases);
        for(int bi=0; bi<nbase; bi++) { if(m_segBases[bi] == segBase) { idx = bi; break; } }
        if(idx < 0) { ArrayResize(m_segBases, nbase+1); m_segBases[nbase] = segBase; idx = nbase; ArrayResize(m_segCounts, nbase+1); m_segCounts[idx] = 0; }
        int prevCount = m_segCounts[idx];
        if(prevCount > segCount) {
            for(int j = segCount + 1; j <= prevCount; j++) {
                string del = segBase + IntegerToString(j);
                if(ObjectFind(m_chartId, del) >= 0) { ObjectDelete(m_chartId, del); }
            }
        }
        m_segCounts[idx] = segCount;

    }

    ~CEMAOverlay() {

        RemoveAllObjects();
        ReleaseHandles();
    }

    //+------------------------------------------------------------------+
    //| Initialize EMA Overlay System                                   |
    //+------------------------------------------------------------------+
    bool Initialize() {
        if(!m_isEnabled) return true;

        // Create EMA handles
        if(InpShowEMA34) {
            // Dragon Band: EMA34 on High/Close/Low
            m_ema34HighHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_HIGH);
            m_ema34CloseHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
            m_ema34LowHandle = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_LOW);
            if(m_ema34HighHandle == INVALID_HANDLE || m_ema34CloseHandle == INVALID_HANDLE || m_ema34LowHandle == INVALID_HANDLE) {
                Print("[EMA OVERLAY][ERROR] Failed to create EMA 34 Dragon handles (H/C/L)");
                return false;
            }
        }

        if(InpShowEMA89) {
            m_ema89Handle = iMA(_Symbol, PERIOD_CURRENT, 89, 0, MODE_EMA, PRICE_CLOSE);
            if(m_ema89Handle == INVALID_HANDLE) {
                Print("[EMA OVERLAY][ERROR] Failed to create EMA 89 handle");
                return false;
            }
        }

        if(InpShowEMA200) {
            m_ema200Handle = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_EMA, PRICE_CLOSE);
            if(m_ema200Handle == INVALID_HANDLE) {
                Print("[EMA OVERLAY][ERROR] Failed to create EMA 200 handle");
                return false;
            }
        }

        Print("[EMA OVERLAY] Initialized successfully");
        return true;
    }

    //+------------------------------------------------------------------+
    //| Update EMA Lines on Chart                                       |
    //+------------------------------------------------------------------+
    void UpdateEMALines() {
        if(!m_isEnabled) return;

        // Throttle updates for performance
        datetime currentTime = TimeCurrent();
        if(currentTime - m_lastUpdate < m_updateThrottleMs / 1000) return;
        m_lastUpdate = currentTime;

        // Clear old lines if too many objects
        if(m_objectCount > m_maxObjects * 0.8) {
            CleanupOldObjects();
        }

        // Draw EMA lines across the entire visible chart (no text labels)
        if(InpShowEMA34) {
            if(m_ema34HighHandle  != INVALID_HANDLE) DrawEMAPolyline(m_ema34HighHandle,  m_prefix+"DRAGON_H_PL", m_theme.DragonHighColor,  m_theme.DragonEdgeWidth,  m_theme.DragonEdgeStyle);
            if(m_ema34CloseHandle != INVALID_HANDLE) DrawEMAPolyline(m_ema34CloseHandle, m_prefix+"DRAGON_C_PL", m_theme.DragonCloseColor, m_theme.DragonCloseWidth, m_theme.DragonCloseStyle);
            if(m_ema34LowHandle   != INVALID_HANDLE) DrawEMAPolyline(m_ema34LowHandle,   m_prefix+"DRAGON_L_PL", m_theme.DragonLowColor,   m_theme.DragonEdgeWidth,  m_theme.DragonEdgeStyle);
        }

        if(InpShowEMA89 && m_ema89Handle != INVALID_HANDLE) {
            DrawEMAPolyline(m_ema89Handle,  m_prefix+"EMA89_PL",  m_theme.EMA89_Color,  m_theme.LineWidth, m_theme.LineStyle);
        }

        if(InpShowEMA200 && m_ema200Handle != INVALID_HANDLE) {
            DrawEMAPolyline(m_ema200Handle, m_prefix+"EMA200_PL", m_theme.EMA200_Color, m_theme.LineWidth, m_theme.LineStyle);
        }
    }

    //+------------------------------------------------------------------+
    //| Draw Individual EMA Line (reusable segments, low clutter)       |
    //+------------------------------------------------------------------+
    void DrawEMALine(int period, int handle, color lineColor) {
        if(handle == INVALID_HANDLE) return;

        const int K = 48; // segments to show
        int bars_total = Bars(_Symbol, PERIOD_CURRENT);
        if(bars_total < 2) return;
        int bars = MathMin(K + 1, bars_total);

        double ema[]; ArraySetAsSeries(ema, true);
        if(CopyBuffer(handle, 0, 0, bars, ema) <= 1) return;

        for(int i = 1; i < bars; i++) {
            string seg = StringFormat("%sEMA%d_SEG_%d", m_prefix, period, i);
            datetime t1 = iTime(_Symbol, PERIOD_CURRENT, i);
            datetime t0 = iTime(_Symbol, PERIOD_CURRENT, i-1);
            double p1 = ema[i];
            double p0 = ema[i-1];
            if(p0 <= 0 || p1 <= 0) continue;
            if(ObjectFind(m_chartId, seg) < 0) {
                ObjectCreate(m_chartId, seg, OBJ_TREND, 0, t1, p1, t0, p0);
                ObjectSetInteger(m_chartId, seg, OBJPROP_BACK, true);
                ObjectSetInteger(m_chartId, seg, OBJPROP_SELECTABLE, false);
                AddToObjectArray(seg);
            } else {
                ObjectMove(m_chartId, seg, 0, t1, p1);
                ObjectMove(m_chartId, seg, 1, t0, p0);
            }
            ObjectSetInteger(m_chartId, seg, OBJPROP_COLOR, lineColor);
            ObjectSetInteger(m_chartId, seg, OBJPROP_WIDTH, m_theme.LineWidth);
            ObjectSetInteger(m_chartId, seg, OBJPROP_STYLE, m_theme.LineStyle);
            ObjectSetInteger(m_chartId, seg, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(m_chartId, seg, OBJPROP_RAY_LEFT, false);
        }

        // labels disabled for clean overlay
    }

    //+------------------------------------------------------------------+
    //| Draw EMA Period Label                                           |
    //+------------------------------------------------------------------+
    void DrawEMALabel(int period, double currentValue, color labelColor) {
        string objName = StringFormat("%sEMA%d_LABEL", m_prefix, period);

        // Remove old label
        ObjectDelete(m_chartId, objName);

        // Create new label
        datetime currentTime = TimeCurrent();
        if(ObjectCreate(m_chartId, objName, OBJ_TEXT, 0, currentTime, currentValue)) {
            string labelText = StringFormat("EMA%d (%.5f)", period, currentValue);
            ObjectSetStringASCII(m_chartId, objName, OBJPROP_TEXT, labelText);
            ObjectSetInteger(m_chartId, objName, OBJPROP_COLOR, labelColor);
            ObjectSetInteger(m_chartId, objName, OBJPROP_FONTSIZE, 9);
            ObjectSetString(m_chartId, objName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(m_chartId, objName, OBJPROP_ANCHOR, ANCHOR_LEFT);



            AddToObjectArray(objName);
        }
    }

    //+------------------------------------------------------------------+
    //| Object Management Functions                                     |
    //+------------------------------------------------------------------+
    void AddToObjectArray(string objName) {
        int newSize = ArraySize(m_emaObjects);
        ArrayResize(m_emaObjects, newSize + 1);
        m_emaObjects[newSize] = objName;
        m_objectCount++;
    }

    void CleanupOldObjects() {
        // Soft cleanup: keep only known stable object prefixes, remove legacy segments
        for(int i = ArraySize(m_emaObjects) - 1; i >= 0; i--) {
            string name = m_emaObjects[i];
            bool keep = StringFind(name, "_PL") >= 0 || StringFind(name, "_LBL") >= 0;
            if(!keep) {
                ObjectDelete(m_chartId, name);
                // remove from array
                for(int j = i; j < ArraySize(m_emaObjects) - 1; j++) m_emaObjects[j] = m_emaObjects[j+1];
                ArrayResize(m_emaObjects, ArraySize(m_emaObjects) - 1);
            }
        }
        m_objectCount = ArraySize(m_emaObjects);
        Print(StringFormat("[EMA OVERLAY] Cleanup complete. Objects: %d", m_objectCount));
    }

    void RemoveAllObjects() {
        ObjectsDeleteAll(m_chartId, m_prefix);
        ArrayResize(m_emaObjects, 0);
        m_objectCount = 0;
        Print("[EMA OVERLAY] All objects removed");
    }

    void ReleaseHandles() {
        // Release Dragon Band EMA34 handles
        if(m_ema34HighHandle != INVALID_HANDLE) { IndicatorRelease(m_ema34HighHandle); m_ema34HighHandle = INVALID_HANDLE; }
        if(m_ema34CloseHandle != INVALID_HANDLE) { IndicatorRelease(m_ema34CloseHandle); m_ema34CloseHandle = INVALID_HANDLE; }
        if(m_ema34LowHandle != INVALID_HANDLE) { IndicatorRelease(m_ema34LowHandle); m_ema34LowHandle = INVALID_HANDLE; }
        if(m_ema89Handle != INVALID_HANDLE) {
            IndicatorRelease(m_ema89Handle);
            m_ema89Handle = INVALID_HANDLE;
        }
        if(m_ema200Handle != INVALID_HANDLE) {
            IndicatorRelease(m_ema200Handle);
            m_ema200Handle = INVALID_HANDLE;
        }
    }

    //+------------------------------------------------------------------+
    //| Control Functions                                               |
    //+------------------------------------------------------------------+
    void SetEnabled(bool enabled) {
        m_isEnabled = enabled;
        if(!enabled) RemoveAllObjects();
        Print(StringFormat("[EMA OVERLAY] %s", enabled ? "ENABLED" : "DISABLED"));
    }

    void UpdateTheme(SEMAVisualTheme &newTheme) {
        m_theme = newTheme;
        Print("🎨 [EMA OVERLAY] Theme updated");
    }

    string GetStatus() {
        return StringFormat("EMA Overlay: %s | Objects: %d/%d | EMA34(H/C/L):%s/%s/%s EMA89:%s EMA200:%s",
                          m_isEnabled ? "ON" : "OFF",
                          m_objectCount, m_maxObjects,
                          (m_ema34HighHandle != INVALID_HANDLE) ? "✓" : "✗",
                          (m_ema34CloseHandle != INVALID_HANDLE) ? "✓" : "✗",
                          (m_ema34LowHandle != INVALID_HANDLE) ? "✓" : "✗",
                          (m_ema89Handle != INVALID_HANDLE) ? "✓" : "✗",
                          (m_ema200Handle != INVALID_HANDLE) ? "✓" : "✗");
    }
};

//+------------------------------------------------------------------+
//| Global EMA Overlay Instance                                      |
//+------------------------------------------------------------------+
CEMAOverlay* g_EMAOverlay = NULL;

//+------------------------------------------------------------------+
//| EMA Overlay Helper Functions                                     |
//+------------------------------------------------------------------+
void EMA_Initialize() {
    if(g_EMAOverlay == NULL) {
        g_EMAOverlay = new CEMAOverlay();
    }
    if(g_EMAOverlay != NULL) {
        g_EMAOverlay.Initialize();
    }
}

void EMA_Update() {
    if(g_EMAOverlay != NULL) {
        g_EMAOverlay.UpdateEMALines();
    }
}

void EMA_Cleanup() {
    if(g_EMAOverlay != NULL) {
        delete g_EMAOverlay;
        g_EMAOverlay = NULL;
    }
}

string EMA_GetStatus() {
    if(g_EMAOverlay != NULL) {
        return g_EMAOverlay.GetStatus();
    }
    return "EMA Overlay: Not initialized";
}

#endif // UI_EMA_OVERLAY_MQH
