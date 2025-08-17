#ifndef CONSOLIDATED_SIGNALS_API_MQH
#define CONSOLIDATED_SIGNALS_API_MQH
// ===== Consolidated Signals API (declarations only) =====
// This header intentionally contains only function declarations.
// No #import is required; warnings 46 can be safely ignored by the compiler.
#include "01_Core_07_CommonStructures.mqh"  // for SignalDecision

// NOTE: Wrappers are defined in ConsolidatedSignals.mqh; no standalone prototypes here to avoid '#import' warnings.

#define FEATURE_SONICR_BASIC   1
#define FEATURE_SONICR_VPSRA   1
#define FEATURE_SCOUT          1
#endif // CONSOLIDATED_SIGNALS_API_MQH 