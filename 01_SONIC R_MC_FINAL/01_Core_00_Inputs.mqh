//+------------------------------------------------------------------+
//|                           SONIC R MC INPUTS                     |
//|                    ENTERPRISE-GRADE PARAMETER SYSTEM             |
//|                   Built for Professional Traders                 |
//+------------------------------------------------------------------+
#ifndef CORE_00_INPUTS_MQH
#define CORE_00_INPUTS_MQH

#include "01_Core_22_SonicEnums.mqh"

//================================================================//
//                    ?? H? TH?NG CHI?N LU?C C?T LÕI                     //
//                 L?a ch?n k?ch b?n giao d?ch và c?u hình               //
//================================================================//

// Strategy enum is centralized in 01_Core_22_SonicEnums.mqh
input string            InpSeparator1          = "-----------------------------------------------";
input string            InpTitle1              = "?? L?A CH?N CHI?N LU?C TRADING";
input ENUM_TRADING_STRATEGY InpTradingStrategy  = STRATEGY_SONIC_R; // fallback to defined enum; VPSRA handled via flags  // ?? Chi?n lu?c chính
input bool              InpAdaptiveStrategy     = true;          // ?? T? d?ng chuy?n chi?n lu?c theo Regime

//================================================================//
//                    ??? TRUNG TÂM KI?M SOÁT R?I RO                      //
//              H? th?ng qu?n lý ti?n và r?i ro chuyên nghi?p             //
//================================================================//

input string            InpSeparator2       = "-----------------------------------------------";
input string            InpTitle2           = "??? QU?N TR? R?I RO CHUYÊN NGHI?P";
input double            InpRiskPercent      = 1.0;      // ?? R?i ro m?i l?nh (%) - 0.5 d?n 2.0%
input double            InpRiskReward       = 2.0;      // ?? T? l? R?i ro:L?i nhu?n (R:R) - 1:1.5 d?n 1:3
input int               InpMaxDailyTrades   = 5;        // ?? Gi?i h?n l?nh m?i ngày - 1 d?n 20 l?nh
input double            InpMaxSpreadPips    = 60.0;     // ?? Spread t?i da cho phép (pips) - 5 d?n 50
input double            InpMaxDailyDrawdown = 5.0;      // ?? S?t gi?m hàng ngày t?i da (%) - 2 d?n 10%
input int               InpMCSimulations    = 10000;    // ?? S? l?n mô ph?ng Monte Carlo - 1K d?n 100K

//================================================================//
//                   ?? CÔNG C? PHÂN TÍCH THÔNG MINH                    //
//           B?t/T?t các thành ph?n phân tích nâng cao               //
//================================================================//

input string            InpSeparator3       = "-----------------------------------------------";
input string            InpTitle3           = "?? THÀNH PH?N PHÂN TÍCH CHUYÊN SÂU";
input bool              InpEnableDragonBand = true;     // ?? Dragon Band - Phân tích xu hu?ng c?t lõi
input bool              InpEnablePVSRA      = true;     // ?? PVSRA - Phân tích kh?i lu?ng chuyên sâu
input bool              InpEnableSMC        = true;     // ?? SMC - Khái ni?m Smart Money
input bool              InpEnableScout      = true;     // ?? Scout - Giao d?ch vùng sideway
input bool              InpEnableWyckoff    = true;     // ?? Wyckoff - Phân tích chu k? th? tru?ng
input double            InpMinSignalStrength= 70.0;     // ? Ngu?ng tín hi?u t?i thi?u (%) - 50 d?n 95%
input double            InpConfluenceThreshold = 0.15;  // ?? Ngu?ng h?i t? tín hi?u - gi?m khi test (VD: 0.10)
input double            InpWeightFVG           = 0.15;  // Tr?ng s? FVG (0..1) cho confluence & voting
input double            InpWeightIDM           = 0.15;  // Tr?ng s? IDM (0..1) cho confluence & voting
// Unified PVSRA Engine tuning
input bool              InpUsePVSRAEngine   = true;     // Use unified PVSRA engine
input double            InpPVSRA_ConfluenceWeight = 0.20; // PVSRA weight hint (0.0-0.5)
// MTF weights for confluence (H4/H1/M15/M5)
input double            InpMTFWeight_H4     = 0.25;
input double            InpMTFWeight_H1     = 0.35;
input double            InpMTFWeight_M15    = 0.25;
input double            InpMTFWeight_M5     = 0.15;

//================================================================//
//                   ?? THRESHOLDS & LOGIC GUARDS                 //
//             Chu?n hóa m?i ngu?ng dang vi?t c?ng trong code      //
//================================================================//
// PVSRA thresholds
input double            InpPVSRA_ScoreThreshold              = 0.70;   // Ngu?ng xác nh?n PVSRA (0.0-1.0)
input double            InpPVSRA_VolumeRatio_Strong          = 2.00;   // ratio >= strong
input double            InpPVSRA_VolumeRatio_High            = 1.50;   // ratio >= high
input double            InpPVSRA_VolumeRatio_AboveAvg        = 1.20;   // ratio >= above average
input double            InpPVSRA_VolumeRatio_Normal          = 0.80;   // ratio >= normal
// Support/Resistance distance bands (pips)
input int               InpPVSRA_SupportBand1_Pips           = 10;     // <=10 very close
input int               InpPVSRA_SupportBand2_Pips           = 30;     // <=30 close
input int               InpPVSRA_SupportBand3_Pips           = 50;     // <=50 near
input int               InpPVSRA_SupportBand4_Pips           = 100;    // <=100 moderate
input int               InpPVSRA_ResistBand1_Pips            = 10;     // <=10 very close
input int               InpPVSRA_ResistBand2_Pips            = 30;     // <=30 close
input int               InpPVSRA_ResistBand3_Pips            = 50;     // <=50 near
input int               InpPVSRA_ResistBand4_Pips            = 100;    // <=100 moderate
// Psychological levels & directional confirmation
input double            InpPVSRA_LevelTolerancePips          = 2.0;    // Kho?ng cách t?i da t?i s? tròn/0.25/0.50/0.75 (pips)
input bool              InpPVSRA_UseQuarterLevels            = true;   // B?t các m?c .25/.75
input double            InpPVSRA_WickRatioStrong             = 0.60;   // T? l? wick/biên d? n?n d? coi là h?p th? m?nh
input bool              InpPVSRA_EnableMTF                   = true;   // Ki?m tra EMA d?nh hu?ng trên H1/H4
input bool              InpPVSRA_StrictDirection             = true;   // Yêu c?u bias PVSRA cùng hu?ng v?i BUY/SELL
// Order Block (OB)
input double            InpOB_MaxDistancePips                = 20.0;   // Kho?ng cách t?i da d?n OB (pips)
input double            InpOB_MaxViolationPips               = 30.0;   // Vi ph?m t?i da d? coi OB còn hi?u l?c (pips)
input double            InpOB_VolumeSpikeMultiplier          = 1.30;   // H? s? volume so v?i trung bình d? xác nh?n OB

// Liquidity Sweep (LS)
input int               InpLS_SwingLookbackBars              = 15;     // S? n?n nhìn l?i tìm swing
input int               InpLS_DetectionLookbackBars          = 5;      // S? n?n xét sweep
input double            InpLS_SignificantBreak_ATR_Mult      = 0.30;   // Ph?n tram ATR cho break dáng k?
input double            InpLS_SignificantBreak_FallbackPips  = 5.0;    // Pips fallback n?u ATR=0
input double            InpLS_VolumeSpikeMultiplier          = 1.50;   // H? s? volume xác nh?n sweep

// Pullback & Dragon Band
input double            InpDragon_ATR_Multiplier             = 2.0;    // H? s? ATR t?o d?i Dragon fallback
input double            InpPullback_LowMin                   = 0.20;   // 20%-40% vùng du?i
input double            InpPullback_LowMax                   = 0.40;
input double            InpPullback_HighMin                  = 0.60;   // 60%-80% vùng trên
input double            InpPullback_HighMax                  = 0.80;

// Momentum & Reversal
input int               InpMomentum_RSI_M15_Bull             = 60;     // RSI M15 bullish min
input int               InpMomentum_RSI_H1_Bull              = 55;     // RSI H1 bullish min
input int               InpMomentum_RSI_M15_Bear             = 40;     // RSI M15 bearish max
input int               InpMomentum_RSI_H1_Bear              = 45;     // RSI H1 bearish max
input double            InpMomentum_MinMovePips              = 20.0;   // Bi?n d?ng t?i thi?u (pips)
input double            InpReversal_SmallBodyRatio           = 0.33;   // Thân n?n < 33% range
input double            InpReversal_LongShadowRatio          = 0.66;   // Bóng dài > 66% range
input double            InpReversal_EngulfingRatio           = 1.50;   // T? l? engulfing
input double            InpReversal_VolumeSpikeMultiplier    = 1.20;   // H? s? volume xác nh?n reversal

// Confluence Layers minimums
input double            InpConfluence_L2_MTF_Min             = 0.70;   // L2: MTF score t?i thi?u
input double            InpConfluence_L3_PriceAction_Min     = 0.60;   // L3: PA/Wave t?i thi?u

// ConfluenceEngine defaults (fallback when not using RiskCalculator)
input double            InpCE_DefaultSLPips                  = 50.0;   // SL m?c d?nh (pips)
input double            InpCE_DefaultTPPips                  = 100.0;  // TP m?c d?nh (pips)

//================================================================//
//                    ?? H? TH?NG TH?C THI & SL/TP                     //
//              Công c? Stop Loss & Take Profit thích ?ng             //
//================================================================//

input string            InpSeparator4           = "-----------------------------------------------";
input string            InpTitle4               = "?? H? TH?NG TH?C THI GIAO D?CH";
input bool              InpAutoTrading          = true;         // ?? Ch? d? giao d?ch t? d?ng
input bool              InpUseNewBarMode        = true;         // ?? Ch? x? lý khi có n?n m?i - gi?m nhi?u
input bool              InpUseATRBasedSL        = true;         // ?? Stop Loss d?a trên ATR
input int               InpATRPeriod            = 14;           // ?? Chu k? ATR - 5 d?n 50
input double            InpSL_ATR_Multiplier    = 2.0;          // ?? H? s? nhân ATR cho SL - 1.0 d?n 4.0
input ENUM_TIMEFRAMES   InpATRTimeframe         = PERIOD_M15;   // ? Khung th?i gian ATR
input double            InpMinSLPips            = 10.0;         // ?? Stop Loss t?i thi?u (pips) - 5 d?n 50
input bool              InpUseSpreadPadding     = true;         // ?? Thêm spread vào SL
input bool              InpEnableTrailing       = true;         // ?? Kích ho?t Trailing Stop
input double            InpTrailingStart        = 15.0;         // ?? Ði?m b?t d?u trail (pips) - 10 d?n 50
input double            InpTrailingStep         = 5.0;          // ?? Bu?c trail (pips) - 2 d?n 20
// ATR-based position sizing (volatility-aware)
input bool              InpUseATRPositionSizing      = true;       // Adjust risk% by ATR regime
input ENUM_TIMEFRAMES   InpATRSizeTimeframe          = PERIOD_H1;  // TF for ATR regime
input int               InpATRSizePeriod             = 14;         // ATR period for regime
input int               InpATRSizeRefPeriod          = 50;         // Bars for average ATR
input double            InpATRSizeHighVolThreshold   = 1.5;        // curATR/avgATR >= cut
input double            InpATRSizeLowVolThreshold    = 0.8;        // curATR/avgATR <= boost
input double            InpATRSizeHighVolCut         = 0.70;       // scale risk% in high vol
input double            InpATRSizeLowVolBoost        = 1.20;       // scale risk% in low vol
input double            InpATRSizeMinMultiplier      = 0.50;       // bounds
input double            InpATRSizeMaxMultiplier      = 1.50;

//================================================================//
//                    ??? GIAO DI?N & H? TH?NG GIÁM SÁT                //
//              Dashboard, C?nh báo & Thông báo thông minh           //
//================================================================//

input string            InpSeparator5           = "-----------------------------------------------";
input string            InpTitle5               = "??? GIAO DI?N & H? TH?NG GIÁM SÁT";
input bool              InpShowDashboard        = true;         // ?? Hi?n th? Dashboard trên chart
input bool              InpShowSignals          = true;         // ?? Hi?n th? mui tên tín hi?u
input bool              InpSendAlerts           = false;        // ?? G?i c?nh báo di d?ng
input bool              InpSendEmails           = false;        // ?? G?i email thông báo
input ENUM_LOG_LEVEL    InpLogLevel             = LOGLEVEL_INFO; // ?? M?c d? log - INFO/DEBUG d? xem chi ti?t
input bool              InpDetailedLogs         = false;        // ?? Log chi ti?t nâng cao
input int               InpDashboardRefresh     = 1000;         // ?? T?n su?t làm m?i Dashboard (ms)
// Added: Visual controls
input bool              InpDrawOnlyEMA          = true;         // ??? Ch? v? EMA trên chart (34/89/200)
input bool              InpShowEMA34            = true;         // EMA 34
input bool              InpShowEMA89            = true;         // EMA 89
input bool              InpShowEMA200           = true;         // EMA 200
input bool              InpHideATRIndicator     = true;         // ?n ATR indicator ph? trên chart
input bool              InpShowSonicOverlay     = true;         // ?? V? overlay SMC/SonicR trên chart
input bool              InpDashboardAutoTheme   = true;         // ?? T? d?ng ch?nh giao di?n theo n?n chart
input bool              InpForceDashboard       = true;         // Ép hi?n th? Dashboard c? live/tester n?u module kh? d?ng
input bool              InpPresetByStrategy     = true;         // Ánh x? preset gate theo chi?n lu?c (session/risk/cooldown)

// Dashboard compact controls
input bool              InpDashboardCompact     = true;         // Ch? d? compact (dock g?n góc chart)
input ENUM_BASE_CORNER  InpDashboardCorner      = CORNER_LEFT_UPPER; // Góc neo dashboard
input int               InpDashboardX           = 10;           // Kho?ng cách X t?i góc (px)
input int               InpDashboardY           = 10;           // Kho?ng cách Y t?i góc (px)
input int               InpDashboardW           = 320;          // R?ng (px)
input int               InpDashboardH           = 140;          // Cao (px)
input int               InpDashboardOpacity     = 20;           // Ð? m? n?n (0-100)

// Minimal HUD option
input bool              InpDashboardMinimalHUD   = false;        // HUD t?i gi?n 3 dòng (tester/live)

// SMC/FVG Overlay controls
input bool              InpShowSMCOverlayZones  = true;         // V? vùng SMC (OB, Liquidity, BOS/CHOCH)
input bool              InpShowFVGOverlay       = true;         // V? Fair Value Gaps (FVG)
input bool              InpShowOrderBlocksOverlay = true;       // V? Order Blocks
input bool              InpShowLiquidityOverlay = true;         // V? Liquidity Pools (swing high/low)
input bool              InpShowBOSCHOCHOverlay  = true;         // V? BOS/CHOCH markers
input bool              InpShowPremiumDiscount  = true;         // V? Premium/Discount/Equilibrium Zones
input int               InpPDZLookbackBars      = 200;          // S? bars d? tính PDZ (theo TF hi?n t?i/MTF)
input int               InpPDZOpacity           = 15;           // Ð? m? PDZ (0-100)
input bool              InpMitigationRemove     = true;         // T? xóa OB/FVG khi du?c mitigate/fill
input bool              InpOverlayMTF_H1        = true;         // V? FVG/PDZ MTF H1
input bool              InpOverlayMTF_H4        = false;        // V? FVG/PDZ MTF H4
input int               InpOverlayMaxObjects    = 80;           // Gi?i h?n s? d?i tu?ng overlay
input int               InpOverlayThrottleMs    = 1000;         // Throttle c?p nh?t overlay (ms)
input bool              InpOverlayTesterLightMode = true;       // Ch? d? nh? khi backtest (gi?m v?)
input bool              InpOverlayDebug         = false;        // Hi?n th? self-check overlay
// Overlay glyph customization (BOS/CHOCH/IDM)
input color             InpGlyphBOSColor        = C'16,185,129';  // Màu BOS (m?c d?nh xanh lá)
input int               InpBOSFontSize          = 10;             // C? ch? BOS (glyph/tag)
input color             InpGlyphCHOCHColor      = C'245,158,11';   // Màu CHOCH (m?c d?nh vàng cam)
input int               InpCHOCHFontSize        = 10;             // C? ch? CHOCH (glyph/tag)
input color             InpGlyphIDMColor        = C'100,100,255';  // Màu IDM (m?c d?nh xanh lam)
input int               InpIDMFontSize          = 10;             // C? ch? IDM (glyph/tag)

// SMC structure parameters
input int               InpInternalLookback     = 5;            // Lookback xác d?nh pivot n?i b? (internal)
input int               InpSwingLookback        = 50;           // Lookback xác d?nh pivot swing chính
input bool              InpShowInducement       = true;         // Hi?n th? di?m Inducement (IDM)
input double            InpEqualHLThresholdPips = 2.0;          // Ngu?ng EQH/EQL (pips)
input bool              InpMitigationUseClose   = false;        // Mitigation d?a Close thay vì High/Low

// FVG MTF controls
input bool              InpShowFVG_MTF_H1       = false;        // V? FVG khung H1
input bool              InpShowFVG_MTF_H4       = false;        // V? FVG khung H4

// ?? Thông báo Telegram
input bool              InpTelegramEnabled       = false;        // ?? Kích ho?t Telegram - T?T khi backtest tránh l?i 4014
input bool              InpTelegramImportantOnly = true;         // ?? Ch? g?i c?nh báo quan tr?ng/l?i
input string            InpTelegramBotToken      = "";            // ?? Token bot t? BotFather
input string            InpTelegramChatId        = "";          // ?? Chat ID (VD: -1002378332001)
input bool              InpTelegramSendScreens   = true;         // ?? Ðính kèm ?nh ch?p chart
input int               InpTelegramShotWidth     = 1024;          // ?? Chi?u r?ng ?nh ch?p
input int               InpTelegramShotHeight    = 768;           // ?? Chi?u cao ?nh ch?p

// Economic Calendar (Real-time) controls
input bool              InpUseEconomicCalendar   = true;          // ?? Dùng l?ch kinh t? real-time (n?u broker h? tr?)
input int               InpNewsBufferMinutes     = 30;            // ? Kho?ng c?m tru?c/sau tin (phút)
input int               InpNewsMinImportance     = 1;             // ?? M?c d? quan tr?ng t?i thi?u (0=low,1=med,2=high)
input bool              InpNewsFilterBySymbol    = true;          // ?? Ch? l?c tin theo base/quote symbol
input int               InpNewsLookaheadMinutes  = 120;           // ?? Nhìn tru?c bao nhiêu phút d? ch?n tin

// AI/ML controls
input bool              InpEnableMLPrediction   = false;        // ?? D? doán Machine Learning (Beta)
input double            InpMLWeight             = 0.30;         // T? tr?ng pha tr?n ML vào tín hi?u (0..1)
input bool              InpEnablePerfTuner      = true;          // ?? B?t Perf Analyzer + Adaptive Tuner (an toàn, rate-limit)
input bool              InpShowPerfOnDashboard  = true;          // ?? Hi?n th? N/WR/PF/Weights/dConf trên Dashboard
input int               InpPerfWindowSize       = 500;           // ??? Kích thu?c c?a s? rolling (s? l?nh)
input int               InpPerfMinSamples       = 150;           // ? S? l?nh t?i thi?u tru?c khi g?i ý
input double            InpPerfMaxConfStep      = 0.03;          // ?? Bu?c t?i da di?u ch?nh confluence m?i l?n

// Testing & Simulation Controls
input int               InpRandomSeed            = 0;             // RNG seed for deterministic simulations (0 = default)
// Monte-Carlo modes for performance control
enum ENUM_MC_MODE { MC_OFFLINE, MC_LIVELIGHT, MC_FULL };
input ENUM_MC_MODE      InpMonteCarloMode        = MC_LIVELIGHT;  // MC mode: Offline(heavy)/LiveLight(light)/Full
input int               InpMCIterationsOffline   = 20000;         // Iterations for Offline/Research mode
input int               InpMCIterationsLive      = 2000;          // Iterations for LiveLight mode
input int               InpMCIterationsFull      = 10000;         // Iterations for Full mode
input int               InpMC_LookbackDays       = 365;           // Lookback days to collect historical trades for MC

//================================================================//
//                    ?? KI?M TH? & T?I UU HÓA                      //
//              Phát tri?n, Ki?m th? & Ði?u khi?n Debug            //
//================================================================//

input string            InpSeparator6           = "-----------------------------------------------";
input string            InpTitle6               = "?? KI?M TH? & G? L?I H? TH?NG";
input bool              InpTestingMode          = false;        // ?? Ch? d? ki?m th? nâng cao
input bool              InpTestingRelaxed       = true;         // ?? Ch? d? thu giãn backtest - n?i di?u ki?n + fallback
// Ði?u khi?n thu giãn chi ti?t
input bool              InpRelaxedSpreadBypass  = true;         // ?? Thu giãn: B? qua l?c spread
input bool              InpRelaxedBypassGates   = true;         // ?? Thu giãn: B? qua gate h?p l? & r?i ro
input bool              InpEnableRelaxedFallbackEMA      = true; // ?? Thu giãn: Fallback can ch?nh EMA
input bool              InpEnableRelaxedFallbackLastBar  = true; // ??? Thu giãn: Fallback hu?ng n?n tru?c
input int               InpMinBarsBetweenTrades          = 0;     // ?? S? n?n t?i thi?u gi?a 2 l?nh (cooldown)
input int               InpMinSecondsBetweenTrades       = 0;     // ? Cooldown theo giây - 0 d? t?t
input bool              InpEnableBacktest       = true;         // ?? Kích ho?t ch? d? Backtest
input bool              InpDebugMode            = false;        // ?? Ch? d? Debug chi ti?t
input bool              InpShowDebugInfo        = false;        // ?? Hi?n th? thông tin Debug
input int               InpMaxDebugMessages     = 100;          // ?? S? message Debug t?i da
input int               InpVaRSimulations       = 5000;         // ?? S? l?n mô ph?ng VaR - 2K d?n 50K
// Ngu?ng tín hi?u và ch?t lu?ng
input double            InpSignalValidThreshold       = 0.65;   // ? Ngu?ng tin c?y t?i thi?u dánh d?u tín hi?u h?p l?
input double            InpMinAnalysisQuality         = 0.60;   // ?? Ch?t lu?ng phân tích t?i thi?u yêu c?u
// Override thu giãn khi testing
input double            InpRelaxedSignalValidThreshold = 0.55;  // ?? Thu giãn: Gi?m ngu?ng tín hi?u h?p l?
input double            InpRelaxedMinAnalysisQuality   = 0.50;  // ?? Thu giãn: Gi?m ch?t lu?ng phân tích
//================================================================//
//                    ?? C?U HÌNH NÂNG CAO                           //
//                     Dành cho Expert Users                      //
//================================================================//

input string            InpSeparator7           = "-----------------------------------------------";
input string            InpTitle7               = "?? C?U HÌNH NÂNG CAO - CHUYÊN GIA";
input double            InpVolatilityMultiplier = 1.0;          // ?? B? l?c d? bi?n d?ng - 0.5 d?n 3.0
input int               InpNewsFilterMinutes    = 0;            // ?? Ch?n tin t?c quanh l?nh (phút) - 0=t?t, 15/30=ch?n ±phút
input double            InpCorrelationThreshold = 0.7;          // ?? Ngu?ng tuong quan - 0.3 d?n 0.9
input bool              InpEnableSessionFilter  = false;         // ?? Kích ho?t l?c phiên giao d?ch - nên t?t khi test nhanh
// Broker server time offset vs GMT (hours). Example: broker GMT+2 => set 2. Use 0 if unknown.
input int               InpBrokerGMTOffset     = 0;             // ?? Múi gi? Broker so v?i GMT (gi?)
// Session window gating (server time)
input bool              InpRestrictBySession    = false;         // ?? S? d?ng các lo?i phiên có s?n
input bool              InpAllowAsian           = false;        // ?? Cho phép phiên Châu Á
input bool              InpAllowLondon          = true;         // ???? Cho phép phiên London
input bool              InpAllowNY              = true;         // ???? Cho phép phiên New York
input bool              InpUseOverlapWindow     = false;         // ?? C?a s? giao phiên London/NY
input int               InpOverlapStartHour     = 12;           // ? Gi? b?t d?u giao phiên
input int               InpOverlapEndHour       = 16;           // ? Gi? k?t thúc giao phiên
input bool              InpUseCustomSession     = false;        // ??? Tùy ch?nh c?a s? th?i gian (gi?:phút)
input int               InpSessionStartHour     = 8;            // ?? Gi? b?t d?u phiên tùy ch?nh
input int               InpSessionEndHour       = 22;           // ?? Gi? k?t thúc phiên tùy ch?nh
input int               InpSessionStartMinute   = 0;            // ?? Phút b?t d?u phiên tùy ch?nh
input int               InpSessionEndMinute     = 0;            // ?? Phút k?t thúc phiên tùy ch?nh
input int               InpMinCandleAge         = 3;            // ??? Tu?i n?n t?i thi?u - 1 d?n 10
input double            InpLiquidityThreshold   = 1000000;      // ?? Ngu?ng thanh kho?n t?i thi?u

//================================================================//
//                      SCENARIO PRESETS                          //
//                  Auto-Configure by Strategy                   //
//================================================================//

//  Preset configurations will be applied in ConfigManager based on InpTradingStrategy
// SONIC_R_BASIC:      Conservative, 62.3% WR, R:R 1:2.3, Risk 0.8%
// SONIC_R_WITH_VPSRA: Balanced, 65.7% WR, R:R 1:1.8, Risk 1.0%
// SCALING_WINNERS:    Aggressive, Trend Following, Risk 1.2%
// SCOUT_RANGE:        Range Trading, SMC Focus, Risk 0.5%
// MULTI_ASSET:        Advanced Multi-Symbol, Risk 0.7%

#endif // CORE_00_INPUTS_MQH 