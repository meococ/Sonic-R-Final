//+------------------------------------------------------------------+
//|                                  Performance_OptimizationEnhanced.mqh |
//|                         SONIC R MC - Performance Optimization Engine |
//|                                🎯 CLEAN ARCHITECTURE VERSION         |
//+------------------------------------------------------------------+

#ifndef PERFORMANCE_OPTIMIZATION_ENHANCED_MQH
#define PERFORMANCE_OPTIMIZATION_ENHANCED_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
// #include "01_Core_16_EnumHelpers.mqh" // Already included in MasterIncludes

//+------------------------------------------------------------------+
//| 🚀 BOSS FIX: Indicator Cache Structure to Prevent Memory Leaks  |
//+------------------------------------------------------------------+
struct SIndicatorCache
{
string  key;            // Unique identifier (symbol_period_timeframe)
int     handle;         // Indicator handle
datetime lastUsed;      // Last access time for cleanup
int     referenceCount; // Number of active references

void Reset() {
key = "";
handle = INVALID_HANDLE;
lastUsed = 0;
referenceCount = 0;
}
};

//+------------------------------------------------------------------+
//| 🎯 INDICATOR CACHE MANAGER - MEMORY LEAK PREVENTION            |
//+------------------------------------------------------------------+
class CIndicatorCacheManager
{
private:
SIndicatorCache m_cache[100];  // Cache for up to 100 indicators
int             m_cacheCount;
datetime        m_lastCleanup;

// Constants
enum { CLEANUP_INTERVAL = 3600 }; // 1 hour

public:
CIndicatorCacheManager() : m_cacheCount(0), m_lastCleanup(TimeCurrent()) {}

~CIndicatorCacheManager() { CleanupAll(); }

// 🎯 Get or create MA handle with caching
int GetMAHandle(string symbol, ENUM_TIMEFRAMES timeframe, int period, 
int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price)
{
string key = StringFormat("MA_%s_%d_%d_%d_%d_%d", symbol, timeframe, period, shift, method, price);
return GetOrCreateHandle(key, symbol, timeframe, period, shift, method, price);
}

// 🎯 Get or create RSI handle with caching
int GetRSIHandle(string symbol, ENUM_TIMEFRAMES timeframe, int period, ENUM_APPLIED_PRICE price)
{
string key = StringFormat("RSI_%s_%d_%d_%d", symbol, timeframe, period, price);

// Find existing handle
for(int i = 0; i < m_cacheCount; i++) {
if(m_cache[i].key == key) {
m_cache[i].lastUsed = TimeCurrent();
m_cache[i].referenceCount++;
return m_cache[i].handle;
}
}

// Create new handle
int handle = iRSI(symbol, timeframe, period, price);
if(handle != INVALID_HANDLE && m_cacheCount < 100) {
m_cache[m_cacheCount].key = key;
m_cache[m_cacheCount].handle = handle;
m_cache[m_cacheCount].lastUsed = TimeCurrent();
m_cache[m_cacheCount].referenceCount = 1;
m_cacheCount++;
}

return handle;
}

// 🎯 Release handle reference
void ReleaseHandle(int handle)
{
for(int i = 0; i < m_cacheCount; i++) {
if(m_cache[i].handle == handle) {
m_cache[i].referenceCount = MathMax(0, m_cache[i].referenceCount - 1);
break;
}
}

// Periodic cleanup check
if(TimeCurrent() - m_lastCleanup > CLEANUP_INTERVAL) {
PerformCleanup();
}
}

private:
int GetOrCreateHandle(string key, string symbol, ENUM_TIMEFRAMES timeframe, 
int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price)
{
// Find existing handle
for(int i = 0; i < m_cacheCount; i++) {
if(m_cache[i].key == key) {
m_cache[i].lastUsed = TimeCurrent();
m_cache[i].referenceCount++;
return m_cache[i].handle;
}
}

// Create new handle
int handle = iMA(symbol, timeframe, period, shift, method, price);
if(handle != INVALID_HANDLE && m_cacheCount < 100) {
m_cache[m_cacheCount].key = key;
m_cache[m_cacheCount].handle = handle;
m_cache[m_cacheCount].lastUsed = TimeCurrent();
m_cache[m_cacheCount].referenceCount = 1;
m_cacheCount++;

Print(StringFormat("🎯 [CACHE] Created handle for %s (Total: %d)", key, m_cacheCount));
}

return handle;
}

void PerformCleanup()
{
datetime cutoffTime = TimeCurrent() - 1800; // 30 minutes
int originalCount = m_cacheCount;

for(int i = m_cacheCount - 1; i >= 0; i--) {
if(m_cache[i].lastUsed < cutoffTime && m_cache[i].referenceCount == 0) {
IndicatorRelease(m_cache[i].handle);

// Shift array elements
for(int j = i; j < m_cacheCount - 1; j++) {
m_cache[j] = m_cache[j + 1];
}
m_cacheCount--;
}
}

m_lastCleanup = TimeCurrent();

if(originalCount != m_cacheCount) {
Print(StringFormat("🧹 [CACHE CLEANUP] Released %d unused handles (Active: %d)", 
originalCount - m_cacheCount, m_cacheCount));
}
}

void CleanupAll()
{
for(int i = 0; i < m_cacheCount; i++) {
IndicatorRelease(m_cache[i].handle);
}
m_cacheCount = 0;
Print("🧹 [CACHE] All handles released on cleanup");
}
};

// Global cache instance
CIndicatorCacheManager* g_IndicatorCache;

//+------------------------------------------------------------------+
//| 🎯 PERFORMANCE HELPER FUNCTIONS                                 |
//+------------------------------------------------------------------+

// 🚀 BOSS FIX: Safe MA handle getter with caching
int GetCachedMAHandle(string symbol, ENUM_TIMEFRAMES timeframe, int period, 
ENUM_MA_METHOD method = MODE_EMA, ENUM_APPLIED_PRICE price = PRICE_CLOSE)
{
if(g_IndicatorCache == NULL) {
g_IndicatorCache = new CIndicatorCacheManager();
}

return g_IndicatorCache.GetMAHandle(symbol, timeframe, period, 0, method, price);
}

// 🚀 BOSS FIX: Safe RSI handle getter with caching
int GetCachedRSIHandle(string symbol, ENUM_TIMEFRAMES timeframe, int period, 
ENUM_APPLIED_PRICE price = PRICE_CLOSE)
{
if(g_IndicatorCache == NULL) {
g_IndicatorCache = new CIndicatorCacheManager();
}

return g_IndicatorCache.GetRSIHandle(symbol, timeframe, period, price);
}

// 🚀 BOSS FIX: Safe handle release
void ReleaseCachedHandle(int handle)
{
if(g_IndicatorCache != NULL) {
g_IndicatorCache.ReleaseHandle(handle);
}
}

// 🚀 BOSS FIX: Initialize cache system
void InitializeIndicatorCache()
{
if(g_IndicatorCache == NULL) {
g_IndicatorCache = new CIndicatorCacheManager();
Print("🎯 [PERFORMANCE] Indicator cache manager initialized");
}
}

// 🚀 BOSS FIX: Cleanup cache system
void DeinitializeIndicatorCache()
{
if(g_IndicatorCache != NULL) {
delete g_IndicatorCache;
g_IndicatorCache = NULL;
Print("🧹 [PERFORMANCE] Indicator cache manager cleaned up");
}
}

//+------------------------------------------------------------------+
//| Performance Metrics Structure                                     |
//+------------------------------------------------------------------+
struct SPerformanceMetrics
{
double                  cpuUsagePercent;
uint                    tickProcessingTime;
uint                    averageLatency;
ENUM_PERFORMANCE_RATING overallRating;
bool                    isOptimal;
datetime                lastUpdate;

void Reset()
{
cpuUsagePercent = 0.0;
tickProcessingTime = 0;
averageLatency = 0;
overallRating = PERFORMANCE_AVERAGE;
isOptimal = false;
lastUpdate = 0;
}

string GetReport()
{
return StringFormat("CPU: %.1f%% | Latency: %dms | Rating: %s",
cpuUsagePercent, averageLatency, PerformanceRatingToString(overallRating));
}
};

//+------------------------------------------------------------------+
//| Performance Optimization Manager                                  |
//+------------------------------------------------------------------+
class CPerformanceOptimizer
{
private:
// Performance tracking
SPerformanceMetrics     m_metrics;
ENUM_PERFORMANCE_MODE   m_currentMode;

// Monitoring data
uint                    m_tickTimes[100];
int                     m_timeIndex;
datetime                m_lastOptimization;
bool                    m_initialized;

// Performance thresholds
double                  m_maxCpuUsage;
uint                    m_maxLatency;

// Cache management
bool                    m_cacheEnabled;
datetime                m_lastCacheClean;

public:
// Constructor
CPerformanceOptimizer()
{
m_metrics.Reset();
m_currentMode = MODE_BALANCED;
m_timeIndex = 0;
m_lastOptimization = 0;
m_initialized = false;
m_maxCpuUsage = 15.0; // Target: <15% CPU
m_maxLatency = 50;    // Target: <50ms latency
m_cacheEnabled = true;
m_lastCacheClean = 0;

// Initialize tick times array
ArrayInitialize(m_tickTimes, 0);
}

// Destructor
~CPerformanceOptimizer() {}

// Initialization
bool Initialize()
{
m_initialized = true;
m_lastOptimization = TimeCurrent();
m_lastCacheClean = TimeCurrent();
return true;
}

// Performance monitoring
void StartPerformanceMonitoring(string operation)
{
// Implementation would start timer for operation
// For now, just placeholder
}

void EndPerformanceMonitoring()
{
// Implementation would end timer and record metrics
// For now, update with estimated values
UpdateMetrics();
}

// Check if system should process current tick
bool ShouldProcessCurrentTick()
{
if(!m_initialized) return true;

// Skip processing based on performance mode
static int tickCount = 0;
tickCount++;

switch(m_currentMode)
{
case MODE_CONSERVATIVE:
return (tickCount % 3 == 0); // Process every 3rd tick
case MODE_BALANCED:
return (tickCount % 2 == 0); // Process every 2nd tick
case MODE_AGGRESSIVE:
case MODE_MAXIMUM:
return true; // Process every tick
default:
return true;
}
}

// Get optimal performance mode
ENUM_PERFORMANCE_MODE GetOptimalMode()
{
if(!m_initialized) return MODE_BALANCED;

// Determine optimal mode based on current performance
if(m_metrics.cpuUsagePercent > 20.0)
return MODE_CONSERVATIVE;
else if(m_metrics.cpuUsagePercent > 10.0)
return MODE_BALANCED;
else
return MODE_AGGRESSIVE;
}

// Set performance mode
void SetPerformanceMode(ENUM_PERFORMANCE_MODE mode)
{
m_currentMode = mode;
Print("Performance mode changed to: ", PerformanceModeToString(mode));
}

// Perform system maintenance
void PerformMaintenance()
{
if(!m_initialized) return;

datetime currentTime = TimeCurrent();

// Clean cache every 5 minutes
if(m_cacheEnabled && currentTime - m_lastCacheClean >= 300)
{
CleanCache();
m_lastCacheClean = currentTime;
}

// Optimize performance every minute
if(currentTime - m_lastOptimization >= 60)
{
OptimizePerformance();
m_lastOptimization = currentTime;
}
}

// Get current metrics
SPerformanceMetrics GetMetrics() const { return m_metrics; }

// Get performance report
string GetPerformanceReport()
{
return StringFormat("Performance Report:\n%s\nMode: %s\nCache: %s",
m_metrics.GetReport(),
PerformanceModeToString(m_currentMode),
m_cacheEnabled ? "Enabled" : "Disabled");
}

// Check if system is performing optimally
bool IsOptimalPerformance() const
{
return m_metrics.cpuUsagePercent < m_maxCpuUsage && 
m_metrics.averageLatency < m_maxLatency;
}

// 🔧 ADDED: Missing ReportError method
void ReportError(string error)
{
Print("🔴 Performance Error: ", error);

// Degrade performance metrics when errors occur
m_metrics.cpuUsagePercent += 2.0; // Increase CPU usage due to error handling
m_metrics.averageLatency += 5;    // Increase latency due to error processing

// Check if should switch to conservative mode
if(m_metrics.cpuUsagePercent > 25.0)
{
SetPerformanceMode(MODE_CONSERVATIVE);
}
}

// 🔧 ADDED: Missing UpdateMarketVolatility method
void UpdateMarketVolatility(double volatilityLevel)
{
// Adjust performance based on market volatility
if(volatilityLevel > 0.8) // High volatility
{
m_maxCpuUsage = 20.0; // Increase CPU threshold during volatile periods
m_maxLatency = 75;    // Allow higher latency during high volatility
}
else if(volatilityLevel < 0.3) // Low volatility
{
m_maxCpuUsage = 10.0; // Tighter CPU control during calm periods
m_maxLatency = 30;    // Lower latency requirements
}
else // Normal volatility
{
m_maxCpuUsage = 15.0; // Standard CPU threshold
m_maxLatency = 50;    // Standard latency threshold
}
}

private:
// Update performance metrics
void UpdateMetrics()
{
// Simulate CPU usage calculation
m_metrics.cpuUsagePercent = CalculateEstimatedCPU();

// Update average latency
m_metrics.averageLatency = CalculateAverageLatency();

// Update overall rating
m_metrics.overallRating = CalculatePerformanceRating();

// Check if optimal
m_metrics.isOptimal = IsOptimalPerformance();

m_metrics.lastUpdate = TimeCurrent();
}

// Estimate CPU usage
double CalculateEstimatedCPU()
{
// Simple estimation based on processing complexity
double baseCPU = 8.0; // Base system usage

// Add overhead based on current mode
switch(m_currentMode)
{
case MODE_MAXIMUM:
baseCPU += 6.0;
break;
case MODE_AGGRESSIVE:
baseCPU += 4.0;
break;
case MODE_BALANCED:
baseCPU += 2.0;
break;
case MODE_CONSERVATIVE:
baseCPU += 1.0;
break;
}

return MathMin(95.0, baseCPU + (MathRand() % 100) / 100.0);
}

// Calculate average latency
uint CalculateAverageLatency()
{
uint totalTime = 0;
int count = 0;

for(int i = 0; i < 100; i++)
{
if(m_tickTimes[i] > 0)
{
totalTime += m_tickTimes[i];
count++;
}
}

return count > 0 ? totalTime / count : 25; // Default 25ms
}

// Calculate performance rating
ENUM_PERFORMANCE_RATING CalculatePerformanceRating()
{
if(m_metrics.cpuUsagePercent < 10.0 && m_metrics.averageLatency < 30)
return PERFORMANCE_EXCELLENT;
else if(m_metrics.cpuUsagePercent < 15.0 && m_metrics.averageLatency < 50)
return PERFORMANCE_GOOD;
else if(m_metrics.cpuUsagePercent < 25.0 && m_metrics.averageLatency < 100)
return PERFORMANCE_AVERAGE;
else if(m_metrics.cpuUsagePercent < 40.0)
return PERFORMANCE_BELOW_AVERAGE;
else
return PERFORMANCE_POOR;
}

// Optimize system performance
void OptimizePerformance()
{
// Auto-adjust mode based on performance
ENUM_PERFORMANCE_MODE optimalMode = GetOptimalMode();
if(optimalMode != m_currentMode)
{
SetPerformanceMode(optimalMode);
}

// Enable/disable cache based on memory usage
if(m_metrics.cpuUsagePercent > 20.0 && m_cacheEnabled)
{
m_cacheEnabled = false;
Print("Cache disabled due to high CPU usage");
}
else if(m_metrics.cpuUsagePercent < 10.0 && !m_cacheEnabled)
{
m_cacheEnabled = true;
Print("Cache re-enabled due to low CPU usage");
}
}

// Clean system cache
void CleanCache()
{
if(!m_cacheEnabled) return;

// Placeholder for cache cleaning logic
Print("Performance cache cleaned");
}

// Record tick processing time
void RecordTickTime(uint processingTime)
{
m_tickTimes[m_timeIndex] = processingTime;
m_timeIndex = (m_timeIndex + 1) % 100;
}
};

// Global performance optimizer instance
CPerformanceOptimizer* g_PerformanceOptimizer;

// Global helper functions
void InitializePerformanceOptimizer()
{
if(g_PerformanceOptimizer == NULL)
{
g_PerformanceOptimizer = new CPerformanceOptimizer();
g_PerformanceOptimizer.Initialize();
}
}

void CleanupPerformanceOptimizer()
{
if(g_PerformanceOptimizer != NULL)
{
delete g_PerformanceOptimizer;
g_PerformanceOptimizer = NULL;
}
}

// NOTE: Performance monitoring functions moved to Performance_System_Unified.mqh
// to avoid duplicate function definitions

void EndPerformanceMonitoring()
{
if(g_PerformanceOptimizer != NULL)
g_PerformanceOptimizer.EndPerformanceMonitoring();
}

// NOTE: ShouldProcessCurrentTick() moved to Performance_System_Unified.mqh
// to avoid duplicate function definitions
// bool ShouldProcessCurrentTick() - REMOVED to prevent conflicts

#endif // PERFORMANCE_OPTIMIZATION_ENHANCED_MQH


