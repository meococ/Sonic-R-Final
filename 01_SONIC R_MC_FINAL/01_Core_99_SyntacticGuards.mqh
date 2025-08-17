//+------------------------------------------------------------------+
//|                                   01_Core_99_SyntacticGuards.mqh |
//|                 Syntactic guard macros & feature gating          |
//+------------------------------------------------------------------+
#ifndef CORE_SYNTACTIC_GUARDS_MQH
#define CORE_SYNTACTIC_GUARDS_MQH

// Pointer guards
#define REQUIRE_PTR(p)                  do { if((p)==NULL) { Print("[PTR] Null pointer: ", #p); return false; } } while(0)
#define REQUIRE_PTR_MSG(p,msg)          do { if((p)==NULL) { Print("[PTR] ", (msg)); return false; } } while(0)

// Feature gates (documented in README_DEVELOPMENT.md)
#ifndef FEATURE_EARLY_TREND
  // #define FEATURE_EARLY_TREND 1
#endif
#ifndef FEATURE_DYNAMIC_WEIGHTS
  // #define FEATURE_DYNAMIC_WEIGHTS 1
#endif
#ifndef FEATURE_CONFLUENCE_ENGINE
  // #define FEATURE_CONFLUENCE_ENGINE 1
#endif

// Compile-time hints
#define NOT_IMPLEMENTED()               Print(__FUNCTION__, " not implemented")

#endif // CORE_SYNTACTIC_GUARDS_MQH

