# Copilot instructions for Sonic-R-Final

Purpose: give an AI coding agent the minimal, actionable knowledge needed to be productive in this repository.

Quick checklist for any task
- Open `00_Main_MasterIncludes.mqh` first — it controls feature flags and include order.
- Identify whether a symbol is defined in `01_Core_*` (engine, context, managers) or `03_MarketAnalysis_*` (analysis modules). Changes often need both places updated.
- Run the project's compile script before large changes to get a full error snapshot: see `00_Compile/*`.

Big-picture architecture (why and where)
- Core engine / context: `01_Core_01_Engine.mqh`, `01_Core_08_ContextManager.mqh`, `CEaContext` and `CCore` are the runtime anchors. Most managers (TradeGate, RiskManager, SignalManager) are created/owned from the core/context.
- Data providers: `02_DataProviders_*` provide symbol/session/time/indicator abstractions. These are expected to be low-level stable APIs.
- Market analysis & signals: `03_MarketAnalysis_*` contains analyzers (DragonBand, PVSRA, WavePattern, MasterOrchestrator). Large files here must parse cleanly — a single stray brace breaks the entire compile.
- EA entry: `00_Main_EA_SonicR.mq5` wires everything together. Treat this as the orchestration code, not the implementation surface.

Build / test / debug workflows (concrete)
- Primary compile helpers live in `00_Compile/`.
  - Quick compile: `00_Compile\quick_compile.bat` (use for fast edit/compile cycles).
  - Auto (production) compile: `00_Compile\auto_compile.bat` (creates timestamped logs under `00_Compile\Logs`).
  - Test/full output: `00_Compile\test_compile.bat` (shows full MetaEditor output).
  - PowerShell wrapper: `00_Compile\sonic_compile.ps1` — recommended invocation on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "00_Compile\sonic_compile.ps1" -Mode quick
```

- Logs: `00_Compile\Logs\00_Main_EA_SonicR.mq5.log` is the first place to look. Auto mode creates `compile_YYYYMMDD_HHMMSS.log`.
- To debug compile cascades: run `test_compile.bat` and inspect last 50 lines of the log; unbalanced braces in `03_MarketAnalysis_*.mqh` are a common root cause.

Project-specific conventions & gotchas
- File numbering: files prefixed with `01_`, `02_`, `03_` indicate logical layers (Core, DataProviders, MarketAnalysis). Prefer adding code into the correct numeric folder.
- Master include: `00_Main_MasterIncludes.mqh` controls include order and defines feature flags — do not change include order lightly; instead add symbols into this file if a new module must be globally visible.
- Globals and allocation style:
  - Many managers are created with `new` and stored as pointers (e.g., `CEaContext* g_eaContext`). Use `->` for pointer method calls and `.` only for stack instances.
  - Objects usually have `Initialize()` / `Deinitialize()` lifecycle methods. Call `Deinitialize()` before `delete` when present.
- Indicator handles:
  - Initialize handles to `INVALID_HANDLE`; Only call `IndicatorRelease(handle)` if `handle != INVALID_HANDLE`.
- Inputs and naming:
  - User inputs are `Inp*` and are defined in `01_Core_00_Inputs.mqh`. Avoid re-declaring them across headers.
- Logging:
  - Modules often write module-specific logs under `00_Compile\Logs\[Module].mqh.log`. When adding logs, follow existing `Print()` and `g_advancedLogger` patterns.
- Error constants: centralized in `01_Core_05_ErrorConstants*.mqh`. Use defined macros for error checks.

Integration points / external tools
- MetaEditor is used for compilation (`metaeditor64.exe`). The compile scripts call it directly.
- A Python dumper for source extraction lives under `00_Compile\03_Tool Dumper_Summary Code EA` — used to produce `00_Compile\Dumps\EA_SOURCE_DUMP_*.txt`.
- No external network dependencies should be used by the agent. Edits are local.

Cross-file patterns an agent must know
- Forward declarations vs includes: large headers depend on each other; prefer adding a forward declaration in a header when possible to avoid include cycles. If a function must be used across modules, expose it in `00_Main_MasterIncludes.mqh` by including the defining header earlier.
- Error cascade: A parse error (unbalanced brace, missing semicolon) in a single `.mqh` often results in dozens of "undeclared identifier" errors downstream. Triage strategy: fix first syntax error reported by compiler, recompile, and repeat.
- Pointer safety: search for `new` allocations and ensure corresponding `delete` + nulling; guard method calls with `if(ptr) ptr->Method()`.

Useful files to open when starting a task
- `00_Main_EA_SonicR.mq5` — orchestrator and high-level flow
- `00_Main_MasterIncludes.mqh` — include order & flags
- `01_Core_01_Engine.mqh`, `01_Core_08_ContextManager.mqh` — core runtime
- `03_MarketAnalysis_08_MasterOrchestrator.mqh` — often the cause of cascade errors
- `01_Core_00_Inputs.mqh` — project inputs
- `00_Compile/README.md` and `00_Compile/*` scripts — compile/test workflow

How to ask for follow-ups from the developer
- If you need to change include order, ask: "Which modules must see my new type at compile time?"
- If an object lifecycle isn't obvious, ask: "Should I call Deinitialize() before delete for X class?"
- For ambiguous naming, ask for the canonical `Inp*` name and whether the input should be global or module-scoped.

If you update this file, keep it concise and include exact file references and commands used. After making changes, always run `quick_compile.bat` and attach the log (or the last 50 lines) so the human reviewer can verify.

---

If any part is unclear or you'd like the agent to include additional examples (e.g., a short checklist for fixing compile cascades), tell me which area to expand.

## Strategy, codebase & development (added guidance)

Purpose: ensure agents can add or refine trading strategies and produce production-quality MQL5 EA code that respects both coding standards and quantitative trading constraints.

- Strategy sources and spec files live in `02_Strategy/` (e.g., `SMC_Specification.md`, `SMC_MQL5_Implementation_Guide.md`, `Sonic_R_Scenarios_Evidence_Based.md`). Read these before implementing or changing an algorithm.
- When adding a new strategy or scenario:
  - Add a new `InpTradingStrategy` option in `01_Core_00_Inputs.mqh` (follow existing naming and SSOT conventions).
  - Implement the strategy in `04_SignalGeneration_*` (or create `04_SignalGeneration_02_<your_strategy>.mqh`) and expose a single simple API (e.g., `GetSignal_<StrategyName>(symbol, tf, &outSignal)`).
  - Wire strategy selection in `00_Main_EA_SonicR.mq5` (or `CCore::OnTick` if integrated) to call the proper generator.
  - Provide a feature flag in `00_Main_MasterIncludes.mqh` if the strategy is experimental.

- Codebase expectations when coding strategies:
  - Deterministic signal generation: prefer `InpUseNewBarMode=true` for logic that must be backtestable.
  - Use cached indicator handles via `02_DataProviders_07_LightweightIndicatorManager.mqh` or `CUnifiedIndicatorManager`.
  - No per-tick creation/release of indicators in hot paths.
  - All public functions must have clear contracts (inputs, outputs, error modes). Add a 1–2 line comment describing them.

## Agent technical & trading capabilities (what we expect from the AI)

An AI agent contributing code here must be able to:
- Write idiomatic, compile-clean MQL5 (class lifecycles, pointer safety, handle lifecycle, `CopyBuffer` checks).
- Implement trading logic that respects risk controls: position sizing by stop distance, max daily trades, spread/session limits, prop‑firm presets.
- Reason about market micro-details: slippage, tick size/value, margin/leverage, partial fills, and order result handling (`MqlTradeResult`).
- Produce small runnable tests/backtests: script or instructions to run a Strategy Tester case using `InpUseNewBarMode` and a small parameter sweep.
- Produce clear documentation for any added strategy: where it's wired, what inputs it uses, and basic expected behavior (edge cases).

If an assumption is required (missing expected helper, missing input name, or ambiguous behavior), the agent must list assumptions before making code changes.

## Actionable checklist when implementing or changing a strategy

1. Read the spec in `02_Strategy/*.md` and update `01_Core_00_Inputs.mqh` with any new `Inp*` entries.
2. Create/modify a generator in `04_SignalGeneration_*` with signature: `bool GetSignal_<Name>(string symbol,int timeframe,TradingSignal &outSignal)`.
3. Use `CUnifiedIndicatorManager->GetEMAHandle` or fallback to guarded `iMA` + `CopyBuffer` pattern (initialize handle in OnInit, release in OnDeinit).
4. Add unit-like smoke test (small Tester setup): provide a `.mq5` test harness that calls your generator for 500 ticks and asserts expected properties (e.g., SL>0 when signal produced).
5. Wire strategy into `00_Main_EA_SonicR.mq5` selection switch and gate with a feature flag if experimental.
6. Add logging points (INFO on signal generation; ERROR on trade failure) and ensure low-volume logs in hot paths.
7. Compile with `00_Compile\test_compile.bat`; attach last 50 lines of `00_Compile\Logs\00_Main_EA_SonicR.mq5.log` for review.

## Quick implementation examples (references)
- Position sizing helper (place in `01_Core_14_SharedDataStructures.mqh` or `05_Trading_01_TradeManager.mqh`): `double CalculatePositionSizeByStop(string symbol,double riskPercent,double stopDistance)` — use `SYMBOL_VOLUME_STEP/MIN/MAX`, tick value/size.
- Safe indicator pattern (use manager or guarded handle usage): initialize handle in `OnInit`, call `CopyBuffer`, check `copied >= needed`, use values, and `IndicatorRelease` only in `OnDeinit` or when handle != INVALID_HANDLE.

## Final notes
- Emphasize: deliver working MQL5 code that compiles, is safe (null-checks, handle checks), and contains explicit risk rules (max daily trades, spread caps, min SL).
- If you'd like, I can now scan specific strategy files in `02_Strategy/` and wire one example end-to-end (inputs → generator → OnTick wiring → test harness). Which strategy should I wire first?
