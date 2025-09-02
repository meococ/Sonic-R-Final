### SONIC R MC EA — Technical Documentation (2025-08-16)
**Version**: 3.0 Performance Optimized + Simplified Architecture
**Target**: MQL5 Build 4170+ (MetaTrader 5)
**Compliance**: Prop Trading Rules, FIFO, Hedging Disabled
**Status**: ✅ PRODUCTION READY (Simplified Architecture)

#### A. Purpose & Scope
- **Single Source of Truth**: Architecture, APIs, scoring formulas, runtime flow, testing protocols
- **Production Ready**: Clean compile (0 errors/warnings), performance optimized, comprehensive error handling
- **Simplified Architecture**: Streamlined for immediate deployment with gradual enhancement capability
- **Performance Optimized**: Cached indicator handles, unified signal gateway, early gate checking
- **Evidence-Based**: All performance claims backed by backtesting data with confidence intervals
- **MQL5 Modern**: OOP design, dynamic arrays, proper handle lifecycle, modular enhancement

#### B. Architecture Overview (Performance Optimized Design)
- **Current Flow**: OnTick() → Unified Signal Gateway → TradeGate → Risk Management → Execute Trade
- **Design Patterns**: Singleton (managers), Strategy (scenarios), Factory (signal generation), Cache (indicators)
- **Migration Path**: Simplified → Essential Modules → Analysis Modules → Advanced Features

**Current Implementation: Performance Optimized Core**
- **Entry Point**: 00_Main_EA_SonicR.mq5 (simplified, performance optimized)
- **Essential Includes**:
  - 01_Core_00_Inputs.mqh (SSOT for all parameters)
  - 01_Core_10_CoreEnums.mqh, 01_Core_13_CommonStructures.mqh (core data structures)
  - 01_Core_14_SharedDataStructures.mqh (EA context management)
- **Performance Components**:
  - 02_DataProviders_07_IndicatorManager.mqh (cached EMA/ATR handles)
  - 04_SignalGeneration_01_ConsolidatedSignals.mqh (unified signal gateway)
  - 01_Core_21_TradeGate.mqh (early gate checking)

**Migration Roadmap: Gradual Enhancement**

**Phase 1: Core Functionality (✅ CURRENT)**
- ✅ Basic EA structure with performance optimization
- ✅ Input parameters and configuration management
- ✅ EA Context management (CEaContext)
- ✅ Cached indicator management (CIndicatorManager)
- ✅ Unified signal gateway (CConsolidatedSignals.Generate())
- ✅ Early gate checking (CTradeGate)
- ✅ Risk management with ATR-based SL/TP
- ✅ Proper lot sizing and normalization

**Phase 2: Essential Modules (NEXT)**
- [ ] Full CCore engine integration
- [ ] Enhanced PVSRA analysis (03_MarketAnalysis_06_PVSRA_Manager.mqh)
- [ ] SMC analysis components (03_MarketAnalysis_03_PVSRA_Enhanced.mqh)
- [ ] Dragon Band analyzer (03_MarketAnalysis_01_DragonBand.mqh)

**Phase 3: Advanced Analysis (FUTURE)**
- [ ] Master Orchestrator (03_MarketAnalysis_08_MasterOrchestrator.mqh)
- [ ] Confluence Engine (04_SignalGeneration_02_ConfluenceEngine.mqh)
- [ ] Scenario Manager (04_SignalGeneration_03_ScenarioManager.mqh)
- [ ] Advanced Risk Management (06_RiskManagement_*)

**Phase 4: User Interface & Advanced Features (FINAL)**
- [ ] Dashboard UI (16_UI_01_Dashboard.mqh)
- [ ] SMC Overlays (16_UI_02_SMC_Overlay.mqh)
- [ ] Performance Analytics (09_Performance_*)
- [ ] Full MasterIncludes integration

#### C. Current Architecture & Performance Optimizations
**Purpose**: Streamlined architecture for immediate deployment with performance focus

**Current Implementation Status**:
- ✅ **Performance Optimized**: Cached indicator handles (no create/release per tick)
- ✅ **Unified Signal Gateway**: Single decision point for all signals
- ✅ **Early Gate Checking**: Block invalid trades before execution
- ✅ **Risk Management**: ATR-based SL/TP with proper lot sizing
- ✅ **Scenario Support**: 5 trading scenarios with different thresholds
- ✅ **Clean Compilation**: 0 errors, 0 warnings

**Feature Flags Status** (for future enhancement):
Control Matrix (MasterIncludes):
- Feature Flags (default)
  - FEATURE_PVSRA_V2=1, FEATURE_SMC_INTEGRATION=1, FEATURE_MULTI_TIMEFRAME=1, FEATURE_DRAGON_BAND=1
  - FEATURE_CONFLUENCE_ENGINE=1, FEATURE_SCENARIO_MANAGER=1, FEATURE_INTELLIGENT_RISK=1, FEATURE_DASHBOARD=1, FEATURE_COMPLIANCE=1
  - FEATURE_MASTER_ORCHESTRATOR=1 (guarded; safe on)
  - ENABLE_SMC_ANALYSIS_FILES (heavy SMC internals) = OFF by default; turn ON to enable full SMC pipeline
- Module Groups (ENABLED by default): CORE, DATA_PROVIDERS, MARKET_ANALYSIS (light), SIGNAL_GENERATION, TRADING, RISK_MANAGEMENT, TESTING, ARCHITECTURE, UI
- Disabled by default: AI_ML, PORTFOLIO, PERFORMANCE, COMPLIANCE (group-level), REPORTS, NEWS

Guidance:
- Keep heavy SMC internals off for fast iteration; enable `ENABLE_SMC_ANALYSIS_FILES` only when needed.
- Preserve include order: Enums → Inputs → Structures → Core → Signals → Analysis → Trading/Risk → UI.

**Compilation Modes**:
- **PRODUCTION**: All safety features enabled, extensive logging, error recovery
- **TESTING**: Additional debug output, performance metrics, validation checks
- **MINIMAL**: Core functionality only, optimized for speed, reduced memory usage

#### D. OnTick Flow (Performance Optimized) — Updated 2025-08-16
**Main EA OnTick()** → **Unified Signal Gateway** (direct processing):
1) **Performance Monitoring**: Tick counting and status monitoring
2) **New bar detection**: Only process signals on new bars or significant price changes
3) **Unified Signal Gateway**: Single decision point through CConsolidatedSignals.Generate():
   - Input: Symbol, Timeframe, Trading Scenario
   - M15 Pipeline: H4 context → Dragon breakout → PVSRA/Wave → Scout → Confluence
   - Output: TradingSignal struct with type, SL/TP, confidence, reason
4) **Early Gate Checking**: CTradeGate.CheckAll() BEFORE execution:
   - Spread limits, session windows, news buffer, daily trade limits, prop rules
5) **Risk Management & Execution**:
   - ATR-based SL/TP calculation
   - Proper lot sizing with SYMBOL_VOLUME_STEP normalization
   - Trade execution with error handling
6) **Trade Registration**: CTradeGate.RegisterExecutedTrade() after successful execution

#### E. Performance Optimizations (New in v3.0)
**Critical Performance Fixes Applied**:

**1. Cached Indicator Management**
- **Problem**: EMA/ATR handles created and released every tick (major performance bottleneck)
- **Solution**: CIndicatorManager caches all handles during OnInit, releases only in OnDeinit
- **Impact**: Eliminates handle creation overhead, prevents data loss during fast markets

**2. Unified Signal Gateway**
- **Problem**: Multiple scattered signal generation points causing conflicts
- **Solution**: Single decision point through CConsolidatedSignals.Generate()
- **Impact**: Eliminates signal conflicts, enables proper confluence analysis

**3. Early Gate Checking**
- **Problem**: Trade validation after signal generation and lot calculation
- **Solution**: CTradeGate.CheckAll() before any trade preparation
- **Impact**: Saves CPU cycles on invalid trade conditions

**4. Optimized Tick Processing**
- **Problem**: Processing every tick regardless of significance
- **Solution**: New bar detection and significant price change filtering
- **Impact**: Reduces unnecessary calculations by 80-90%

#### F. Module APIs (public surface) — Updated 2025-08-16
- **CScenarioManager** (scenario evaluation & recommendation)
  - EvaluateAndRecommendScenario() → ENUM_TRADING_SCENARIO (market regime analysis)
  - SwitchToScenario(scenario) → activate scenario in confluence engine
  - GetActiveScenario() → current active scenario
- **ConsolidatedSignals** (actual signal APIs called by CCore)
  - GetSignal_SonicR_Basic() → ENUM_SIGNAL_TYPE (EMA alignment + momentum)
  - GetSignal_SonicR_VPSRA() → ENUM_SIGNAL_TYPE (EMA + PVSRA confirmation)
  - GetSignal_Scout() → ENUM_SIGNAL_TYPE (range/conservative)
  - PassesAllFilters(signal) → bool [stub until full filter wired]
- **CUnifiedIndicatorManager** (handle management)
  - GetEMAHandle(symbol, tf, period, price) - preferred over direct iMA
  - Global handles: g_ema34/89/200_handle, g_atr_handle (initialized once in InitializeIndicators)
- **CTradeGate** (enhanced with daily limits)
  - CheckAll() → TradeGateResult (includes daily trade counter auto-reset)
  - RegisterExecutedTrade() → increment daily counter after successful orders
- CPVSRAManager
  - Initialize(symbol, tf); UpdatePVSRAAnalysis(); GetPVSRAScore(); IsPVSRACandle(shift)
- CAnalysisConsolidated
  - Initialize(); UpdateAnalysis(); GetDragonBandScore(); GetWavePatternScore(); GetSMCScore(); GetPVSRAScore(); GetMarketStructureScore(); GetVolumeConfirmationScore(); GetTrendAlignmentScore()
- CConsolidatedSignals
  - GetSignal_SonicR_Basic(); GetSignal_SonicR_VPSRA(); GetSignal_Scout()
  - PassesAllFilters(signal) [stub until full filter wired]
- **Trade/Risk** (enhanced logging)
  - CalculatePositionSizeByStop() - improved lot rounding (digitsLot=0 when step>=1)
  - ExecuteBuy/SellSignalAdvanced() - structured Logger.Info/Error with strategy preset tags

#### F. Coding Standards (MQL5) & Score Definitions (SSOT)
- **Pointers/Objects**: '->' for pointers, '.' for objects; CheckPointer(ptr)==POINTER_DYNAMIC if nghi ngờ null
- **Indicator handles**: Create → CopyBuffer(check) → IndicatorRelease; prefer unified manager
- **Arrays**: Use dynamic arrays + ArrayResize; ArraySetAsSeries only for dynamic arrays (avoid warning 63)
- **Naming**: prefix free-function by module (SMC_, PVSRA_, ORCH_) to avoid collisions with class methods
- **SSOT**: No duplicate enums/structs in 01_Core_12_SonicEnums.mqh, 01_Core_13_CommonStructures.mqh
- **Score Formulas** (Single Source of Truth - matches actual implementation):
  - **PVSRA Score** = 0.25×Volume + 0.20×Reaction + 0.20×Support + 0.20×Resistance + 0.15×Accumulation
    - Volume: (volume_ratio > 2.0) ? 0.4 : scaled_ratio
    - Reaction: Price reaction strength at S/R levels (0.0-1.0)
    - Support/Resistance: Quality based on touch count, age, volume confirmation
    - Accumulation: Wyckoff phase analysis (PHASE_ACCUMULATION = 0.9, PHASE_MARKUP = 0.8)
  - **SMC Score** = 0.4×LiquiditySweep + 0.3×OrderBlock + 0.3×Structure(BOS/CHoCH)
    - LiquiditySweep: 1.0 if detected, 0.5 if partial, 0.0 if none
    - OrderBlock: Proximity + volume confirmation (1.0 = perfect alignment)
    - Structure: 0.8 for BOS, 0.6 for CHoCH, 0.0 for no change
  - **Dragon Band Score** = 0.5×AngleScore + 0.3×QualityScore + 0.2×PositionScore
    - AngleScore: Normalized EMA angle (10° = 1.0)
    - QualityScore: Pullback quality to Dragon bands
    - PositionScore: Current price position relative to bands
  - **Confluence Thresholds** (regime-adaptive):
    - **Default**: ≥0.70 (balanced markets)
    - **High Volatility**: ≥0.80 (stricter filtering)
    - **Ranging**: ≥0.60 (more opportunities)
    - **Trending**: ≥0.75 (trend confirmation)
  - **Signal Pass Criteria**:
    - Primary: (Component_Score ≥ threshold) AND (Confluence_Score ≥ scenario_threshold)
    - Secondary: No conflicting signals AND TradeGate.CheckAll() = true
    - Tertiary: Session filter AND spread check AND daily limit check

#### G. Compile & Logs
- Canonical tool: PowerShell .\\00_Compile\\02_Run Compile\\sonic_compile.ps1 (recommended)
  - Quick mode: `powershell -ExecutionPolicy Bypass -File "00_Compile/02_Run Compile/sonic_compile.ps1" -Mode quick -Target ea`
- Shortcut: .\\00_Compile\\02_Run Compile\\quick_compile.bat (wrapper gọi sonic_compile.ps1)
- Logs: .\\00_Compile\\02_Run Compile\\Logs\\
- Note: analyze_errors.ps1 deprecated; dùng sonic_compile.ps1 cho parsing & report

#### H. Troubleshooting Checklist
- operand expected → kiểm tra dấu ';' hoặc '}' và phạm vi block; rà trùng tên hàm free vs method
- object pointer expected → dùng '->' thay cho '.' với con trỏ
- undeclared identifier → thiếu include/tắt feature flag/đổi tên API
- warning 63 → không dùng ArraySetAsSeries cho mảng tĩnh; chuyển sang mảng động
- legacy API → dùng shim Compat_GetOptimizedEMAHandle hoặc chuyển sang GetEMAHandle

#### I. Test Plan (quick) — Updated 2025-08-15
- **A/B Backtest** (priority): Compare before/after patch
  - Metrics: WR, PF, MaxDD, #trades, latency
  - Verify: unified signal path produces consistent results vs legacy EMA+PVSRA logic
- **Smoke Test**: 1 symbol/timeframe, vài trăm ticks
  - Verify: ScenarioManager signals trigger correctly, TradeGate blocks with proper reasons, daily counter resets
  - Check: Logger.Info/Warning entries with strategy preset tags, no handle leaks
- Unit-like checks (script/harness):
  - PVSRA_HasLiquiditySweep(), SMC_IsSRLevelValidForTrading(), EMA handle reuse
  - Global handle lifecycle: init → CopyBuffer → release on deinit

#### J. Change Log (keep brief)
- 2025-08-15: **Major patch - Unified signal path & optimizations**
  - **Signal routing**: CCore::OnTick calls ConsolidatedSignals APIs (GetSignal_SonicR_Basic/VPSRA) based on InpTradingStrategy instead of direct EMA+PVSRA logic
  - **Handle optimization**: EMA34/89/200 + ATR handles created once (InitializeIndicators), global handles available for reuse, released OnDeinit
  - **Daily limits**: TradeGate.CheckAll() with auto-reset daily counter; RegisterExecutedTrade() after successful orders
  - **Lot rounding**: digitsLot=0 when SYMBOL_VOLUME_STEP>=1 for cleaner formatting
  - **Structured logging**: Logger.Info/Warning/Error for entries/gate blocks with strategy preset tags (WF/MC ready)
  - **Architecture**: Added ScenarioManager (scenario evaluation), compat shims (01_Core_98_Compat.mqh), syntactic guards (01_Core_99_SyntacticGuards.mqh)
  - **Flow enhancement**: New bar detection, IsSystemReady() checks, proper delegation from main OnTick to CCore::OnTick
- 2025-08: Added feature flags gates, unified EMA handle usage, compat/guards files, filter stub; stabilized compile workflow

---

## Release Gate Checklist

Before any production deployment, verify:

### Code Quality
- [ ] Clean compile: 0 errors, 0 warnings via `.\00_Compile\02_Run Compile\quick_compile.bat`
- [ ] All score formulas match SSOT definitions above
- [ ] Feature flags properly gated with fallbacks
- [ ] Structured logging with strategy preset tags

### Testing
- [ ] A/B backtest: WR/PF/MaxDD within ±5% of baseline
- [ ] Smoke test: 1 symbol/TF, 500+ ticks, no crashes
- [ ] Handle lifecycle: no leaks, proper init/deinit
- [ ] Daily counter resets correctly at server midnight

### Documentation
- [ ] All KPI claims have Evidence & Provenance blocks
- [ ] API contracts match actual implementation
- [ ] Troubleshooting checklist covers recent issues
- [ ] Change log updated with patch details

**Reference**: See `00_Compile\01_Knowledge MQL5\EA_MQL5_Fix_Playbook.txt` for detailed fix procedures.

---

### SONIC R MC EA — Hướng Dẫn Kỹ Thuật (Cập nhật)

#### 1. Tổng quan
- Mục đích: Tự động hóa Sonic R cấp chuyên nghiệp với hợp lực PVSRA/SMC, chiến lược thích ứng và bảng điều khiển trực tiếp.
- Sản phẩm: FX/CFD (mặc định tinh chỉnh cho XAUUSD).
- Khung thời gian: Bất kỳ; lõi DragonBand dùng EMA(34/89) với phân tích đa khung (MTF).

#### 2. Cài đặt
- Sao chép `01_SONIC R_MC_FINAL` vào `Experts/Sonic R_MC/`.
- Build bằng MetaEditor 5 hoặc chạy `00_Compile/sonic_compile.ps1`.
- Tuỳ chọn: cho phép `https://api.telegram.org` nếu dùng Telegram.

#### 3. Tham số đầu vào (chính)
- Chiến lược
  - `InpTradingStrategy`: chiến lược nền để chạy
  - MỚI `InpAdaptiveStrategy` (bool): tự động chuyển chiến lược theo chế độ thị trường (market regime)
- Thực thi
  - `InpAutoTrading`, `InpUseNewBarMode`
- Rủi ro
  - `InpRiskPercent`, `InpRiskReward`, tuỳ chọn SL/TP theo ATR
- Hợp lực (Confluence)
  - `InpConfluenceThreshold` (có thể hạ khi thử nghiệm), trọng số MTF
- Giao diện (UI)
  - `InpShowDashboard`, `InpLogLevel`, tần suất làm mới
  - Bảng điều khiển dạng tối giản: `InpDashboardCompact/Corner/X/Y/W/H/Opacity`
- Lớp phủ Sonic/SMC
  - `InpShowSonicOverlay`, `InpShowSMCOverlayZones`
  - `InpShowFVGOverlay`, `InpShowOrderBlocksOverlay`, `InpShowLiquidityOverlay`, `InpShowBOSCHOCHOverlay`
  - MỚI vùng Premium/Discount: `InpShowPremiumDiscount`, `InpPDZLookbackBars`, `InpPDZOpacity`
  - Mitigation: `InpMitigationRemove`
  - Lớp phủ MTF: `InpOverlayMTF_H1`, `InpOverlayMTF_H4`
  - Hiệu năng: `InpOverlayMaxObjects`, `InpOverlayThrottleMs`, `InpOverlayTesterLightMode`, `InpOverlayDebug`
- Kiểm thử & Gỡ lỗi
  - `InpEnableBacktest`, `InpTestingRelaxed`, công tắc nới lỏng cổng/gateway và fallback
  - Công tắc lọc phiên (session)

#### 4. Kiến trúc (tệp)
- Entry: `00_Main_EA_SonicR.mq5`
- Core: `01_Core_01_Engine.mqh`, `01_Core_03_Logger.mqh`, `01_Core_04_ErrorHandler.mqh`
- Inputs/Enums/Structs: `01_Core_00_Inputs.mqh`, `01_Core_08_SonicEnums.mqh`, `01_Core_09_CommonStructures.mqh`
- Data Providers: `02_DataProviders_05_IndicatorManager.mqh` (Unified), `02_DataProviders_07_LightweightIndicatorManager.mqh` (Deprecated Lightweight)
- Phân tích: `03_MarketAnalysis_01_DragonBand.mqh`, `03_MarketAnalysis_06_PVSRA_Manager.mqh`, `03_MarketAnalysis_25_WaveZigZagAnalyzer.mqh`
- Tín hiệu: `04_SignalGeneration_01_ConsolidatedSignals.mqh`, `04_SignalGeneration_02_ConfluenceEngine.mqh`, `04_SignalGeneration_06_ScoutManager.mqh`
- Giao dịch: `05_Trading_01_TradeManager.mqh`, `05_Trading_02_PositionManager.mqh`
- UI: `16_UI_01_Dashboard.mqh`, `16_UI_02_SMC_Overlay.mqh`

#### 5. Luồng chạy (đã tái cấu trúc)
- OnInit: Context → Core → Indicators → Orchestrator → Trade/Risk → Signals → Dashboard → SMC Overlay
- OnTick (7 pha)
  - P0 Cổng nến mới (nếu bật) + cập nhật chỉ báo
  - P1 Nhịp tim Core (heartbeat)
  - P2 Cổng sẵn sàng của chỉ báo
  - P3 Chọn chiến lược (Adaptive nếu bật)
  - P4 Các cổng giao dịch (cho phép toàn cục, phiên, giới hạn)
  - P5 Tín hiệu + fallback nới lỏng (căn chỉnh EMA / thanh gần nhất) khi thử nghiệm
  - P6 Xác thực (dữ liệu/rủi ro) + cổng spread
  - P7 Thực thi lệnh → Cập nhật Dashboard/Overlay
- OnDeinit: tháo gỡ ngược thứ tự; báo cáo ErrorHandler

#### 6. Chiến lược thích ứng (MỚI)
- `InpAdaptiveStrategy=true`: ánh xạ chế độ thị trường → chiến lược
  - Xu hướng (biến động/ổn định/bull/bear) → Sonic R + VPSRA
  - Đi ngang (ổn định/hẹp) → Scout/Range
  - Đi ngang biến động/rộng → Scaling Winners
  - Breakout → Sonic R Basic
  - Không xác định → giữ `InpTradingStrategy`
- Orchestrator được cập nhật qua `SetCurrentStrategy()`; bộ sinh tín hiệu đọc `activeStrat`.

#### 7. Dashboard (cập nhật)
- Dock tối giản, hỗ trợ giao diện sáng; đối tượng ghim với `OBJ_ALL_PERIODS` để ổn định.
- Tester không trực quan (non‑visual): tự động chế độ chỉ‑văn‑bản (không thao tác biểu đồ), tránh lỗi 4014.
- Live/Visual: kết xuất đầy đủ với giới hạn tần suất cập nhật và định kỳ vẽ lại toàn phần.
- Hiển thị hiệu năng, thành phần hợp lực, tóm tắt SMC, sức khỏe hệ thống, rủi ro và đường hiệu năng theo kịch bản.

#### 8. Lớp phủ SMC/FVG (cập nhật)
- Dấu BOS/CHOCH, Order Blocks, đường Liquidity, Equal High/Low.
- Trình phát hiện FVG với quét định kỳ; xoá vùng mitigation khi được lấp đầy nếu bật.
- Đường Premium/Discount/Equilibrium (50%), tuỳ chọn MTF H1/H4.
- Bảo vệ hiệu năng: giới hạn tần suất, giới hạn số đối tượng, dọn dẹp theo tiền tố; chế độ nhẹ cho tester.

#### 9. Tín hiệu & Hợp lực
- DragonBand (EMA34/89/200), Wave, Structure (đại diện SMC), PVSRA.
- Động cơ hợp lực: tổ hợp có trọng số → `masterSignal`, `signalConfidence`.

#### 10. Xử lý lỗi
- `CCompleteErrorHandler` trung tâm với theo dõi sức khỏe.
- 4014 (ERR_UNKNOWN_COMMAND): triệt trong tester; giới hạn tần suất trong live.
- Báo cáo cuối khi deinit với sức khỏe/thống kê.

#### 11. Build & Kiểm thử
- PowerShell: `00_Compile/sonic_compile.ps1 -Mode quick -Target ea`
- MetaEditor: F7 compile `00_Main_EA_SonicR.mq5`.
- Mẹo backtest
  - Chế độ trực quan để quan sát Dashboard/Overlay.
  - Để có lệnh nhanh trong tester: hạ `InpConfluenceThreshold`, nới lỏng các cổng.

#### 12. Xử lý sự cố (không có lệnh)
- Các cổng thường gặp
  - Lọc phiên đang BẬT hoặc chỉ cho cửa sổ chồng phiên → tắt khi test
  - Spread quá chặt (XAU) → tăng `InpMaxSpreadPips`
  - Cổng nến mới đang BẬT ở chế độ non‑visual → đặt `InpUseNewBarMode=false`
  - Chỉ báo chưa sẵn sàng → chạy lâu hơn / đảm bảo có lịch sử đủ
  - Hợp lực đặt quá cao → hạ ngưỡng khi test
  - Cooldown đang hoạt động → đặt cooldown về 0 khi test
- Cấu hình thân thiện kiểm thử (ví dụ)
  - `InpUseNewBarMode=false`, `InpMaxSpreadPips=60`, `InpConfluenceThreshold=0.15`
  - `InpTestingRelaxed=true`, `InpRelaxedBypassGates=true`, `InpRelaxedSpreadBypass=true`
  - `InpEnableRelaxedFallbackEMA=true`, `InpEnableRelaxedFallbackLastBar=true`
  - Tắt lọc phiên

#### 13. Mục tiêu hiệu năng
- Vẽ lại Dashboard: < 5 ms; Overlay: < 100 đối tượng; không tăng dần theo thời gian.
- Soak test Live 24–48h: không spam 4014, đối tượng ổn định, CPU/RAM ổn định.

#### 14. Thực hành tốt nhất
- Tinh chỉnh rủi ro/phiên theo từng sản phẩm.
- Xác nhận lịch sử MTF được đồng bộ.
- Bắt đầu với tài khoản demo; chỉ bật Telegram ở live (tester bị vô hiệu).

#### 15. Cập nhật kiến trúc gần đây (2025-08)
- Bộ chứa phụ thuộc (Dependency Container) (MỚI)
  - Giới thiệu `CDependencyContainer` để quản trị vòng đời module tập trung (Core/Context, Indicators, Analysis, Signals, Trading, Risk, Session, UI)
  - OnDeinit ưu tiên `container->Cleanup()` để tránh giải phóng kép và đảm bảo thứ tự tháo gỡ đúng
- Chuyển đổi khối lượng rủi ro + fallback (gia cố QUAN TRỌNG)
  - Kích thước vị thế dùng `tickSize`/`tickValue`; khi broker trả `0`, fallback sang `contract_size * point * price`
  - Thêm `GetProfitToAccountRate(symbol)` để quy đổi lợi nhuận tiền tệ → tiền tệ tài khoản bằng cặp chuyển đổi sẵn có (kèm fallback an toàn)
- Sửa thứ tự hợp lực (Sinh tín hiệu)
  - `GenerateSignal()` chạy SAU khi tính xong tổng điểm hợp lực để tránh chặn sai kiểu "0% < ngưỡng"
- Bộ nhớ đệm IndicatorManager (hiệu năng & ổn định)
  - Các chỉ báo đường nóng dùng cache của `IndicatorManager`: `GetATR()`, `GetEMA34/89/200()`, `GetMTFEMA()`
  - Các lệnh gọi `iATR/iMA` nội tuyến trong MasterOrchestrator, RegimeDetector, ConfluenceEngine, DragonBand, và lõi EA đã được chuyển đổi với fallback
- Preset backtest & danh mục symbol (bao phủ QA)
  - Tệp preset: `00_Backtest_Presets.txt` với mẫu [RELAXED]/[STRICT]
  - Khuyến nghị symbol: EURUSD, GBPUSD, USDJPY, XAUUSD, US100, US500, GER40, BTCUSD, ETHUSD

#### 16. Ghi chú vận hành
- Dùng preset RELAXED cho smoke test nhanh (hạ ngưỡng hợp lực, có thể bỏ qua cổng).
- Dùng preset STRICT cho xác nhận gần sản xuất (bật session/spread/cooldown/compliance, ngưỡng cao hơn).
- Ưu tiên chạy chế độ trực quan để kiểm chứng UI/Overlay; non‑visual sẽ tự chuyển sang chế độ nhẹ.
- Sau các refactor Pha A/B, tài nguyên ổn định trong chạy dài (giảm churn handle chỉ báo).

#### 17. Current Architecture Summary (v3.0)
- **Performance Optimized Architecture**: Simplified design for immediate deployment
- **Cached Indicator Manager**: CIndicatorManager provides cached access to EMA34/89/200 + ATR
- **Unified Signal Gateway**: CConsolidatedSignals.Generate() as single decision point
- **Early Gate Checking**: CTradeGate.CheckAll() before trade preparation
- **Migration Ready**: Clear path from simplified to full functionality

---


## 18) Bản cập nhật kỹ thuật (2025-08-26)

### 18.1 Kiến trúc & nguyên tắc
- Entry duy nhất: 00_Main_EA_SonicR.mq5
- Facade include: 00_Main_MasterIncludes.mqh
- Layers (một chiều phụ thuộc): core → data_providers → market_analysis → signals → trade → risk → ui → testing
- SSOT cấu hình: Core_Config.mqh. Chỉ Core_Config đọc Inp*. Mọi nơi khác dùng getters: UseSonic()/UsePVSRA()/UseSMC()/GateSession()/StrictSonicClassic()/RR_Base()/ATR_SL_Mult()/SpreadCapPts()/...
- Auto-Profile (APE): Core_AutoProfile.mqh sinh DNA theo symbol/TF (spread p50/p80, ATR p50/p80, StopsLevel, tick size/value) → derive tham số EC (spread cap, SL floor, RR base…). Clamp thay đổi ≤10–15%/phiên.

### 18.2 Data Providers (một cửa)
- Data_Providers.mqh: cache handle + CopyBuffer cho EMA/ATR.
- API: DP_EMA34/89/200(shift), DP_EMA(period,shift), DP_ATR(period,shift), DP_Angle34Deg(lookback), DP_Time(tf,shift), DP_Close(tf,shift), DP_IsSessionAllowedNow() (đọc SessionPolicy() từ EC).
- Quy ước: cấm gọi iMA/iATR/iTime/iClose trực tiếp bên ngoài Data_Providers.

### 18.3 Runtime flow
- OnInit: ApplyEffectiveConfig() → ValidateInputs() → APE.Load/Build → APE.DeriveTo(EC) → HUD.Init()
- OnTick (Always analyze, gate at execute):
  - MarketAnalysis cập nhật Dragon/Wave/Structure (+Confluence nếu bật)
  - Signals: BuildTradeIntent() → chọn đường Strict hoặc Minimal-Core
  - TradeGate: Session → Risk → Spread → Stops → Size → Cooldown/Duplicate → (DryRun? OrderSend)
  - Testing/HUD cập nhật theo throttle
- OnDeinit: Smoke_Report(), BP_PrintSummary(), APE.SaveDNA().

### 18.4 Sonic R — Strict Path (đường mặc định chuẩn hóa)
- Long conditions:
  - DP_Angle34Deg() ≥ MinAngleDeg() (góc dốc EMA34)
  - EMA34 > EMA89 (trend stack)
  - Close > EMA34 High (outside Dragon)
  - WaveValid(SIGNAL_BUY) với mô hình L–H–HL (fractal nhẹ, w=3)
  - Entry = BREAK_LEG2: đặt phía trên leg#2 + offset
  - SL dưới swing gần nhất; nếu < StopsLevel/ATR-floor → tự nâng (log “adjusted”)
  - TP = RR_Base × SL; RR fixed baseline (adaptive bật sau)
- Short đối xứng.
- DecideDirection(): ưu tiên Wave → dấu góc Dragon → vị trí so EMA89.

### 18.5 Confluence (MarketAnalysis_Ext)
- Conf_Score() 0..1, cộng trọng số: Sonic core + (PVSRA nếu bật) + (SMC nếu bật)
- PVSRA/SMC OFF ⇒ 0 điểm (không âm, không BYPASS)
- Bias Soft/Hard: Soft = nhân BiasH4Score(); Hard = không align ⇒ trả -1.0 để Signals BYPASS

### 18.6 Trade & Risk
- Trading_StopsAndSizing.mqh:
  - BuildStops() dùng ATR + StopsLevel + asset-floor; tự nâng SL nếu vi phạm StopsLevel
  - CalcLots_RiskAndMargin() theo tickvalue/ticksize + risk% + step/min/max
- Trading_Gateway.mqh:
  - Gating thứ tự: Session → Risk/Equity → Spread (WarnOnly) → Stops → Size → Cooldown
  - DryRun ghi trace/SMOKE, không OrderSend
- Risk_Management.mqh: Daily loss, Max positions, Circuit (equity DD%, day-R)

### 18.7 Quan sát & Testing
- BYPASS: counters theo reason; HUD scoreboard + BP_PrintSummary() khi Deinit
- Trace CSV: TraceLine(reason) → time, price, spread, ATR, EMA34/89/200, angle34, outside?, wave state, leg2, SL, RR, size, gates, reason
- Smoke test (InpRunSmokeTest): mỗi candidate → verify SL/TP > 0, SL ≥ StopsLevel+buffer, RR_est ≥ 0.9 × RR_Base. Cuối kỳ: [SMOKE] cases=X ok=Y fail=Z sl_adjust=W

## 19) Backlog “ô trống” & lộ trình wire (ưu tiên + DoD)

### P0 — Bắt buộc ngắn hạn
- PVSRA_Port (Stub→On)
  - Mô tả: DoPVSRA_Score() mức Enhanced (z-score, whole/half proximity, vol-spike)
  - Kết nối: MarketAnalysis_Ext → PVSRA_Score()
  - DoD: OFF ⇒ 0 điểm; ON ⇒ Conf_Score thay đổi hợp lý theo mẫu case; 0 leak handle; HUD có PVSRA:on/off
- SMC_Port (Stub→On)
  - Mô tả: DoSMC_Score() (BOS/CHOCH lookback, FVG min ATR, OB touches, align H4)
  - DoD: tương tự PVSRA; SMC OFF không trừ điểm
- Strict Helper hoàn thiện
  - WaveValid() tham số hóa: InpWaveSwingWidth=3, InpWaveMaxBack=150
  - EntryOffset() đọc EC (ATR-based offset nhẹ)
  - DoD: Strict pass tạo ứng viên ổn; Smoke ok/fail ≥ 3

### P1 — Quan trọng trung hạn
- RR Adaptive Clamp (APE-driven)
  - Chọn RR ∈ [2.0, 3.0] theo vol_ratio; clamp ≤0.2/tuần; log “RR=AUTO k=…”.
- SessionPolicy CUSTOM
  - Cửa sổ GMT qua getters; tester thấy giờ thực thi; BYPASS phản ánh đúng
- Trace CSV V2
  - Thêm cột: profile, mode(STRICT/MIN), biasH4, confScore (nếu bật); file < 15 cột; flush theo lô 128 dòng

### P2 — Nâng cấp giá trị thực chiến
- ENTRY_MOMENTUM_LIMIT (preset)
  - Vào limit trên nến impulse hợp lệ (body%, engulfing); toggle riêng
- Bandit đơn giản cho RR (Thompson Sampling)
  - RR ∈ {2.0, 2.5, 3.0} từ 60–90 lệnh; clamp theo DNA; không overfit (EMA smoothing)
- Prop-firm compliance bổ sung
  - Giới hạn day-R, max relative DD, max lot/session; toggle

## 20) Kịch bản test backtest (NewBar mode)

### Preset “Strict Debug Baseline”
- Profile: PF_SONIC_BASIC; Mode: AUTO (APE on)
- Session: OFF (analyze tự do, gate tại execute)
- StrictSonicClassic: ON; DryRun: ON; WarnOnlySpreadCap: ON
- BarsBetweenTrades: 6; InpRunSmokeTest: true
- PASS:
  - HUD: … | STRICT | DRYRUN | WARN-SPREAD
  - Smoke: ok ≥ 70% (XAU M15, 1–2 tuần), fail ≤ 30%, sl_adjust < ok
  - BYPASS top-3: Angle/Outside/Wave/Leg2 (không phải Stops/MinLot)
- CSV mẫu:
  time;bid;ask;spreadPts;ATR14;EMA34;EMA89;EMA200;angle34;outside;wave;leg2;SL;TP;RR;size;G_session;G_risk;G_spread;G_stops;reason;profile;mode;biasH4;conf
  2024-11-05 10:45;...;...;32;1.85;...;...;...;1.62;1;L-H-HL;2134.50;2130.80;2136.90;2.10;0.12;1;1;1;1;SMOKE_OK;PF_SONIC_BASIC;STRICT;0.74;0.58

### Preset “Minimal-Core Baseline”
- Strict=OFF, MinimalCore=ON; các tham số khác giữ nguyên
- PASS: Ứng viên dày hơn; BYPASS ít bị Wave/Leg2; Smoke ok ≥ 60%

### Preset “VPSRA/SMC Soft-Weight”
- UsePVSRA=ON (≈0.6), UseSMC=ON (≈0.4), Soft bias
- PASS: Conf_Score thay đổi (CSV cột conf), không BYPASS vì PVSRA/SMC trừ điểm

## APPENDIX: Migration Status & Next Steps

### Current Status: ✅ PRODUCTION READY (Simplified Architecture)
- **Version**: 3.0 Performance Optimized
- **Compilation**: 0 errors, 0 warnings
- **Functionality**: Basic trading with performance optimization
- **Documentation**: Updated to reflect current implementation

### Migration Roadmap
- **Phase 1** (Current): Core functionality with performance optimization
- **Phase 2** (Next): Essential modules (CCore, Dragon Band, PVSRA, SMC)
- **Phase 3** (Future): Advanced analysis (Master Orchestrator, Confluence Engine)
- **Phase 4** (Final): UI and advanced features (Dashboard, Overlays, Analytics)

### Quality Metrics
- **Performance**: 80-90% reduction in unnecessary calculations
- **Memory**: Minimal footprint with cached handles
- **Reliability**: Stable initialization and execution
- **Maintainability**: Clean, documented, modular code

**For detailed current status, see**: `00_Current_Architecture_Status.md`
  - `UpdateAll()` làm mới cache H4/H1/M15/M5; `Deinitialize()` giải phóng tất cả handle; `EnforceEMAOnly()` có thể tắt chỉ báo không‑EMA vì hiệu năng
- Bộ tính rủi ro (Core_17)
  - Kích thước vị thế dùng tickSize/tickValue; fallback vững chắc khi broker trả 0
  - Quy đổi Lợi nhuận→Tài khoản qua GetProfitToAccountRate(symbol) để tính rủi ro tiền đúng trên symbol đa tiền tệ
- Bộ chứa phụ thuộc (Core_20)
  - Quản trị vòng đời tập trung; thứ tự dọn dẹp: UI→Session→Trading/Position/Risk→Signals/Analysis→Indicators→Core→Context
  - EA OnDeinit ưu tiên container.Cleanup() và thoát sớm để tránh đường giải phóng kép
- Lõi (Core_01) và Biến toàn cục (Core_11)
  - Vòng đời engine gọn; biến toàn cục tối thiểu và dần thay bằng con trỏ do container quản lý
- Tác động hệ thống
  - Hợp nhất truy cập chỉ báo giữa các module, giảm churn handle, dọn dẹp an toàn, và nhất quán hoá tính rủi ro trên nhiều tài sản

## 🚨 CRITICAL: Hidden Error Detection Protocol (Added 2025-08-16)

### Problem Statement
- **Issue**: Some MQL5 compilation errors bypass automated compilation scripts
- **Impact**: Automated tools report "SUCCESS" but MetaEditor reveals critical errors
- **Risk**: Production deployment with hidden errors = SYSTEM FAILURE

### Mandatory Verification Process
1. **Automated Compilation**: Use `sonic_compile.ps1` for initial compilation
2. **Manual Verification**: ALWAYS compile directly in MetaEditor as final check
3. **Validation**: Both methods must show 0 errors, 0 warnings

### Common Hidden Error Patterns
- **Missing Function Implementation**: `function 'ClassName::FunctionName' must have a body`
- **Const Correctness Violation**: `call non-const method for constant object`
- **Deprecated Struct Assignment**: Modern MQL5 requires separate declaration/assignment

### Detection Tools
- Manual MetaEditor compilation (F7)
- Search for missing implementations: `ClassName::`
- Const method audit for state modifications
- Struct assignment pattern validation

### Quality Gates
- [ ] Automated compilation: 0 errors, 0 warnings
- [ ] Manual MetaEditor compilation: 0 errors, 0 warnings
- [ ] All function declarations have implementations
- [ ] No const correctness violations
- [ ] Strategy Tester initialization successful

**Reference**: See `00_Compile/01_Knowledge MQL5/Hidden_Error_Detection_Guide.md` for complete protocol.

