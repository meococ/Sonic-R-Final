### SONIC R_MC — DEVELOPMENT README (Must Read Before Coding/Compiling)
**Version**: 4.0 Full Implementation Roadmap
**Status**: ⚠️ CRITICAL BUGS IDENTIFIED - See Action Plan Below
**Last Updated**: 2025-08-17

This is the authoritative development guide for Sonic R_MC EA. Read it at the start of each session. Keep this file up to date when flows/tools change.

### Goals
- **IMMEDIATE**: Fix critical bugs (continuous orders, backtesting failures)
- **SHORT-TERM**: Restore 96% missing functionality through 4-phase enhancement
- **PERFORMANCE**: Achieve 68-74% win rate, <8% drawdown targets
- **ARCHITECTURE**: Maintain clean compilation while restoring full modules
- **COMPLIANCE**: Ensure prop firm rules adherence and risk management

### Repository Layout (key paths)
- `01_SONIC R_MC_FINAL/`
  - `00_Main_EA_SonicR.mq5`: Main EA entry (SIMPLIFIED ARCHITECTURE).
  - `00_Main_MasterIncludes.mqh`: Feature toggles (available for future enhancement).
  - `01_Core_00_Inputs.mqh`: Single source of truth (SSOT) for all inputs.
  - `02_DataProviders_07_LightweightIndicatorManager.mqh`: **NEW** - Cached indicator handles (Lightweight).
  - `04_SignalGeneration_01_ConsolidatedSignals.mqh`: **ENHANCED** - Unified signal gateway.
  - `01_Core_21_TradeGate.mqh`: **ACTIVE** - Early gate checking.
  - `01_Core_13_CommonStructures.mqh`: **ENHANCED** - TradingSignal struct.
  - `01_Core_14_SharedDataStructures.mqh`: EA Context management.
- `00_Compile/`
  - `02_Run Compile/quick_compile.bat`, `02_Run Compile/auto_compile.bat`, `compile_all.bat`
  - `sonic_compile.ps1`, `analyze_errors.ps1`, `02_Run Compile/Logs/`
- `02_Chiến Lược/SONIC_R_ULTIMATE_RESEARCH_DOCUMENT.md`: Research.
- `review.md`: Expert review, scenarios, pipeline.

### Current Architecture Status

#### 🔴 CRITICAL ISSUES IDENTIFIED
1. **BUG-001**: Continuous order entry without state management
2. **BUG-002**: Backtesting failures from incomplete signal logic
3. **BUG-003**: 96% functionality missing (Dragon, PVSRA, SMC disabled)

#### Current Implementation Gaps
| Component | Required | Current | Gap |
|-----------|----------|---------|-----|
| **5 Trading Scenarios** | Full | Basic only | 80% missing |
| **Confluence Analysis** | 65-80% | ~40% | Critical |
| **Dragon Band** | Core | Disabled | Missing |
| **PVSRA/SMC** | Essential | Disabled | Missing |
| **Risk Management** | Multi-layer | Basic ATR | 70% missing |

### Feature Flags (for future enhancement)
- 🔄 `FEATURE_EARLY_TREND`: Available in MasterIncludes but not active in simplified version
- 🔄 `FEATURE_DYNAMIC_WEIGHTS`: Available in MasterIncludes but not active in simplified version
- 🔄 `FEATURE_CONFLUENCE_ENGINE`: Partially implemented in ConsolidatedSignals
- 🔄 **Full Module Integration**: Planned for Phase 2-4 of migration roadmap

### 4-PHASE DEVELOPMENT ACTION PLAN

#### PHASE 1: CRITICAL BUG FIXES (Week 1 - IMMEDIATE)
**🔴 Priority**: Fix stability issues
- [ ] **BUG-001**: Add trade state management and cooldown logic
- [ ] **BUG-002**: Complete signal generation initialization
- [ ] **BUG-003**: Implement basic state machine (WAITING→SIGNAL→ORDER→POSITION→COOLDOWN)
- [ ] Add position limit checks (max 1 trade per bar, 5min cooldown)

#### PHASE 2: CORE MODULE RESTORATION (Week 2-3)
**🟠 Priority**: Enable critical analysis
- [ ] Enable Dragon Band (`03_MarketAnalysis_01_DragonBand.mqh`) - 30% signal weight
- [ ] Enable PVSRA Manager (`03_MarketAnalysis_06_PVSRA_Manager.mqh`) - 25% weight
- [ ] Enable SMC Analysis (`03_MarketAnalysis_03_PVSRA_Enhanced.mqh`) - 25% weight
- [ ] Integrate into confluence scoring system

#### PHASE 3: RISK & PERFORMANCE (Week 4-5)
**🟡 Priority**: Implement proper risk management
- [ ] Position sizing based on account risk %
- [ ] Drawdown control and circuit breakers
- [ ] Performance tracking and metrics
- [ ] Prop firm compliance rules

#### PHASE 4: ADVANCED FEATURES (Week 6-8)
**🟢 Priority**: Complete full implementation
- [ ] Enable all 5 trading scenarios
- [ ] UI Dashboard activation
- [ ] AI/ML integration (now enabled in MasterIncludes)
- [ ] Multi-timeframe analysis
- [ ] Performance optimization

### Triage Notes (known hotspots from previous logs)
- `03_MarketAnalysis_03_PVSRA_Enhanced.mqh`: expressions/macros near reported lines (e.g., `> operand expected`). Verify parentheses and symbol scope.
- `03_MarketAnalysis_08_MasterOrchestrator.mqh`: method call signatures and overloads; ensure correct target types and includes.
- `04_SignalGeneration_01_ConsolidatedSignals.mqh`: missing identifiers/filters—use guarded stubs or includes; ensure class scope.
- Warning 63: Don’t call `ArraySetAsSeries` on static arrays.

### Must‑Follow Workflow (Every Session)
1) Sync mental context (read this README and skim key files):
   - `00_Main_EA_SonicR.mq5`, `01_Core_00_Inputs.mqh`, `01_Core_01_Engine.mqh`, `04_SignalGeneration_01_ConsolidatedSignals.mqh`.
2) Clean old logs before compiling:
   - PowerShell:
     ```powershell
     if (Test-Path '.\00_Compile\02_Run Compile\Logs') { Get-ChildItem '.\00_Compile\02_Run Compile\Logs\*.log' -ErrorAction SilentlyContinue | Remove-Item -Force }
     ```
   - CMD:
     ```cmd
     if exist "00_Compile\02_Run Compile\Logs" del /q "00_Compile\02_Run Compile\Logs\*.log"
     ```
3) Compile (choose one):
   - PowerShell (recommended, single line):
     ```powershell
     & "C:\Program Files\MetaTrader 5\metaeditor64.exe" /compile:"$pwd\01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5" /log /inc:"$pwd\01_SONIC R_MC_FINAL"
     ```
   - Batch scripts (PowerShell requires call operator & for paths with spaces):
     ```powershell
     & ".\00_Compile\02_Run Compile\quick_compile.bat"
     # or
     & ".\00_Compile\02_Run Compile\auto_compile.bat"
     ```
4) **⚠️ CRITICAL: Double Verification Process**:
   - **Step 4a**: Inspect automated logs:
     - Main EA log: `00_Compile/02_Run Compile/Logs/00_Main_EA_SonicR.mq5.log` (if created)
     - Timestamped auto log: `00_Compile/02_Run Compile/Logs/compile_YYYYMMDD_HHMMSS.log`
     - Module logs in `00_Compile/02_Run Compile/Logs/*.mqh.log`
     - If errors are many: `.\00_Compile\analyze_errors.ps1`
   - **Step 4b**: **MANDATORY Manual Verification** (Hidden Error Detection):
     - Open MetaEditor directly
     - Compile `01_SONIC R_MC_FINAL\00_Main_EA_SonicR.mq5` manually
     - **Check for errors NOT captured in automated logs**:
       - "function 'ClassName::FunctionName' must have a body"
       - "call non-const method for constant object"
       - Missing implementations even if declarations exist
     - **BOTH automated AND manual compilation must show 0 errors, 0 warnings**

5) Fix by module, recompile frequently. **Always perform double verification after each fix**.
   - Start with modules flagged in logs (PVSRA_Enhanced → Orchestrator → ConsolidatedSignals)
   - **Priority**: Hidden errors → Syntax errors → Warnings
6) Update this README if the flow/tools change.

### Coding Standards (MQL5‑critical)
- Indicator handles:
  - Create → `CopyBuffer` (check return) → `IndicatorRelease` always.
- Arrays:
  - Use dynamic arrays for `ArraySetAsSeries` (avoid warning 63 with static arrays).
  - Example: `double buf[]; ArrayResize(buf, n); ArraySetAsSeries(buf, true);`
- Pointers/objects:
  - Use `->` for class pointers, `.` for objects; when unsure about null, check `CheckPointer(ptr) == POINTER_DYNAMIC` before dereferencing.
- Avoid MQL4‑style calls in MQL5 context. Prefer handles.
- No duplicate enums/structs. Place in SSOT (`01_Core_12_SonicEnums.mqh`, `01_Core_13_CommonStructures.mqh`).
- Performance:
  - Do work only on new bar if possible (`InpUseNewBarMode`).
  - Cache or release indicator handles in the same tick.
  - Avoid iCustom per‑tick; centralize in providers.

### Indicator API Standardization
- Prefer `CUnifiedIndicatorManager->GetEMAHandle(_Symbol, PERIOD_CURRENT, period, PRICE_CLOSE)` for EMA 34/89.
- Handle lifecycle example (fallback direct handles if manager unavailable):
```mql5
int h34 = iMA(_Symbol, PERIOD_CURRENT, 34, 0, MODE_EMA, PRICE_CLOSE);
if(h34 == INVALID_HANDLE) return 0.0;
double ema34[]; ArrayResize(ema34, 3); ArraySetAsSeries(ema34, true);
int copied = CopyBuffer(h34, 0, 0, 3, ema34);
IndicatorRelease(h34);
if(copied < 3) return 0.0;
// use ema34[0..2]
```

### Architecture Spine (Performance Optimized v3.0)
- **Inputs**: `01_Core_00_Inputs.mqh` (strategy selector, risk, scenarios). Key inputs:
  - `InpTradingStrategy` (5 scenarios: Basic, VPSRA, Scout+SMC, Scaling, Multi-Asset)
  - `InpRiskPercent`, `InpMaxSpreadPips`, `InpMaxDailyTrades`, etc.
- **Performance Engine**: Direct OnTick() processing (bypasses CCore for performance)
  - New‑bar detection → Unified Signal Gateway → Early Gate Check → Risk Management → Execute
- **Unified Signal Gateway**: `CConsolidatedSignals.Generate()`
  - M15 Pipeline: H4 context → Dragon → PVSRA/Wave → Scout → Confluence
  - Returns: TradingSignal struct with type, SL/TP, confidence, reason
- **Cached Indicators**: `CIndicatorManager`
  - EMA34/89/200 + ATR handles cached (no create/release per tick)
- **Early Gate**: `CTradeGate.CheckAll()` BEFORE trade preparation
  - Spread/session/daily limits/prop rules validation
- **Risk Management**: ATR‑based SL/TP, proper lot sizing with SYMBOL_VOLUME_STEP
- **Migration Path**: Phase 1 (Current) → Phase 2 (Essential) → Phase 3 (Analysis) → Phase 4 (Advanced)

### Migration Roadmap (Gradual Enhancement)

**Phase 1: Core Functionality (✅ CURRENT - PRODUCTION READY)**
- ✅ Basic EA structure with performance optimization
- ✅ Input parameters and configuration management
- ✅ EA Context management (CEaContext)
- ✅ Cached indicator management (CIndicatorManager)
- ✅ Unified signal gateway (CConsolidatedSignals.Generate())
- ✅ Early gate checking (CTradeGate)
- ✅ Risk management with ATR-based SL/TP
- ✅ Proper lot sizing and normalization

**Phase 2: Essential Modules (NEXT)**
- [ ] Restore CCore engine integration (`01_Core_01_Engine.mqh`)
- [ ] Add Dragon Band analyzer (`03_MarketAnalysis_01_DragonBand.mqh`)
- [ ] Add PVSRA Manager (`03_MarketAnalysis_06_PVSRA_Manager.mqh`)
- [ ] Add SMC Enhanced (`03_MarketAnalysis_03_PVSRA_Enhanced.mqh`)

**Phase 3: Advanced Analysis (FUTURE)**
- [ ] Master Orchestrator (`03_MarketAnalysis_08_MasterOrchestrator.mqh`)
- [ ] Confluence Engine (`04_SignalGeneration_02_ConfluenceEngine.mqh`)
- [ ] Scenario Manager (`04_SignalGeneration_03_ScenarioManager.mqh`)
- [ ] Advanced Risk Management (`06_RiskManagement_*`)

**Phase 4: User Interface & Advanced Features (FINAL)**
- [ ] Dashboard UI (`16_UI_01_Dashboard.mqh`)
- [ ] SMC Overlays (`16_UI_02_SMC_Overlay.mqh`)
- [ ] Performance Analytics (`09_Performance_*`)
- [ ] Full MasterIncludes integration

### Triage Notes (known hotspots from previous logs)
- `03_MarketAnalysis_03_PVSRA_Enhanced.mqh`: expressions/macros near reported lines (e.g., `> operand expected`). Verify parentheses and symbol scope.
- `03_MarketAnalysis_08_MasterOrchestrator.mqh`: method call signatures and overloads; ensure correct target types and includes.
- `04_SignalGeneration_01_ConsolidatedSignals.mqh`: missing identifiers/filters—use guarded stubs or includes; ensure class scope.
- Warning 63: Don’t call `ArraySetAsSeries` on static arrays.

### Clean Build Definition of Done (DoD)
- Compile returns 0 errors. Warnings: review/justify; eliminate warning 63 and deprecated copy‑ctor hints by adding proper constructors if needed.
- No leaked handles on tick path (review for each new handle created).
- Strategy switch behaves deterministically per `InpTradingStrategy`.
- Logs are clean and informative (no spam at INFO unless debugging).

### Backtest/Tester Setup (quick)
- Use `InpUseNewBarMode = true` for faster/saner signals in tester.
- For relaxed exploration: `InpTestingRelaxed = true` (lower thresholds) but never ship with it on.
- UI: `InpShowDashboard = true` only if tester perf allows; otherwise off for speed.

### Log Hygiene
- Before each compile session, clear old logs (see commands above).
- After a failed compile, check: console output → main EA log → module logs → (optional) `analyze_errors.ps1`.

### When You Change the Flow
- Update this README with:
  - New/removed modules or toggles
  - Changes in compile commands/paths
  - New triage steps or known issues
  - Any new scenario API or OnTick routing changes

### Quick Memory (for fast ramp‑up)
- Entry: `00_Main_EA_SonicR.mq5`
- SSOT Inputs: `01_Core_00_Inputs.mqh`
- Engine OnTick: `01_Core_01_Engine.mqh`
- Signals: `04_SignalGeneration_01_ConsolidatedSignals.mqh`
- PVSRA API: `03_MarketAnalysis_06_PVSRA_Manager.mqh`
- Execution: `05_Trading_01_TradeManager.mqh`
- Toggles: `00_Main_MasterIncludes.mqh`
- Compile tools: `00_Compile/` (batch + PowerShell) or MetaEditor CLI

Keep this file accurate. It is the first checkpoint before you code, update, or compile.

### Build Status (latest)
- **Compilation**: ✅ 0 errors, 0 warnings (simplified architecture)
- **Functionality**: ⚠️ 96% missing (modules disabled)
- **Trading**: 🔴 Critical bugs in order management
- **Performance**: ❌ Cannot measure (missing metrics)

### Success Metrics (Targets)
| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| **Win Rate** | 68-74% | Unknown | ❌ |
| **Profit Factor** | 1.84-2.23 | Unknown | ❌ |
| **Max Drawdown** | <8% | Uncontrolled | 🔴 |
| **Daily Trades** | 3-5 | Continuous | 🔴 BUG |

### Fix Lessons (add during triage)
- Naming/Collisions
  - Avoid defining globally generic names that may clash with modules (e.g., `HasLiquiditySweep`). Prefer module‑scoped names: `HasLiquiditySweep_Sonic()`.
  - For free‑functions, prefix with module: `SMC_`, `PVSRA_`, `ORCH_` (e.g., `SMC_IsSRLevelValidForTrading`), to avoid clashing with class methods.
  - If a function exists in analysis modules, call that instead of re‑implementing in main EA.
- Arrays & Series (warning 63)
  - Use dynamic arrays with `ArrayResize` before `ArraySetAsSeries`.
  - Example:
    ```mql5
    double ema34[]; ArrayResize(ema34, 3); ArraySetAsSeries(ema34, true);
    ```
- Indicator handles
  - Always: create → `CopyBuffer` (check) → `IndicatorRelease`.
- Feature isolation
  - When a sub‑module fails (PVSRA_Enhanced / Orchestrator), temporarily disable its include in `00_Main_MasterIncludes.mqh` and gate usages behind macros until fixed.
- ConsolidatedSignals hygiene
  - Keep scenario API simple; avoid referencing non‑existent helper managers. Use direct `iMA`/`CopyBuffer` until the unified indicator manager is proven/stable.
  - Ensure helper functions are within class scope or use explicit `CConsolidatedSignals::` qualifiers. Do not mix global and class methods for related helpers.

### Quick Fix Playbook
- **"operand expected"**: Often missing `;` or `}` or mis‑scoped block. Inspect lines around the error and preceding edits.
- **"object pointer expected"**: Likely used `.` instead of `->` on a pointer. Replace with `->` (and `CheckPointer` if needed).
- **"undeclared identifier"**: Missing include or feature flag gated code. Add include or wrap with `#ifdef`/provide stub.
- **"wrong parameters count"**: Signature mismatch. Open the declaration and adjust the call (or provide the overload in the correct scope).

### Compat shim (recommended)
- `01_Core_98_Compat.mqh`: Map legacy APIs to new ones (e.g., old PVSRA score helpers → `GetVPSRAScore`).
- `01_Core_99_SyntacticGuards.mqh`: Macro guards for feature flags and inline pointer checks (e.g., `REQUIRE_PTR(p)` → early return on null).

### Coding‑from‑Scratch Checklist (to avoid later fixes)
- Before writing:
  - Define feature flags/toggles for any new module.
  - Decide ownership/scope of each helper: class vs free function, avoid name collisions.
- Implement indicators
  - Use MQL5 handles (no MQL4‑style) and release on the same tick unless caching is deliberate.
- Arrays
  - Prefer dynamic arrays; set as series only when needed.
- Cross‑module APIs
  - Introduce interfaces or thin facades; include headers where implementations live. Do not call undeclared functions.
- Logging
  - Centralize via `Logger`; no raw `Print` spam at INFO in hot paths.
- Compile early/often
  - After each logical change, clean logs and compile; fix errors before proceeding to the next module.

### Critical Bug Fix Code Snippets

#### Fix BUG-001: Continuous Order Entry
```mql5
// Add to OnTick() at beginning:
static datetime lastTradeTime = 0;
static int tradesThisBar = 0;
static datetime lastBarTime = 0;

if(Time[0] != lastBarTime) {
    lastBarTime = Time[0];
    tradesThisBar = 0;
}

if(tradesThisBar >= 1) return; // Max 1 trade per bar
if(TimeCurrent() - lastTradeTime < 300) return; // 5min cooldown
```

#### Fix BUG-002: Signal Initialization
```mql5
// Add to OnInit():
if(!g_signalEngine.Initialize()) {
    Print("ERROR: Signal engine initialization failed");
    return INIT_FAILED;
}
```

#### Fix BUG-003: State Management
```mql5
enum ENUM_EA_STATE {
    STATE_WAITING,
    STATE_SIGNAL_DETECTED,
    STATE_ORDER_PENDING,
    STATE_POSITION_OPEN,
    STATE_COOLDOWN
};
ENUM_EA_STATE g_eaState = STATE_WAITING;
```

### Testing Protocol
1. **Unit Tests**: Test each module independently
2. **Integration**: Verify signal pipeline integration
3. **Backtest**: 3 years data (2022-2024) on EURUSD, GBPUSD, XAUUSD
4. **Forward Test**: 4 weeks demo minimum before live

### Reference Documents
- **Full Report**: `SONIC_R_DEVELOPMENT_REPORT_2025.md`
- **Strategy Specs**: `02_Strategy/5 kịch bản.txt`
- **Technical Docs**: `01_SONIC R_MC_FINAL/00_EA_SonicR_Technical_Documentation.md` 