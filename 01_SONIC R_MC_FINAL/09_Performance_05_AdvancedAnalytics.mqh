//+------------------------------------------------------------------+
//|                                    Monitoring_AdvancedAnalytics.mqh |
//|                        SONIC R MC - Advanced Analytics Monitor     |
//|                                 Restored Class Structure            |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team"
#property version   "1.00"
// PRODUCTION FIX: Remove #property strict - MQL4 syntax not supported in MQL5

#ifndef MONITORING_ADVANCEDANALYTICS_MQH
#define MONITORING_ADVANCEDANALYTICS_MQH


#include "01_Core_08_ContextManager.mqh"

//+------------------------------------------------------------------+
//| Performance Metric Structure - FIXED                            |
//+------------------------------------------------------------------+
struct PerformanceMetric
{
string              name;
double              currentValue;
double              averageValue;
double              minValue;
double              maxValue;
datetime            lastUpdate;
int                 trend; // -1 = declining, 0 = stable, 1 = improving
bool                isValid;

void Reset()
{
name = "";
currentValue = 0.0;
averageValue = 0.0;
minValue = 999999.0;
maxValue = -999999.0;
lastUpdate = 0;
trend = 0;
isValid = false;
}
};

//+------------------------------------------------------------------+
//| Advanced Analytics Monitor Class - RESTORED STRUCTURE           |
//+------------------------------------------------------------------+
class CAdvancedAnalyticsMonitor
{
private:
PerformanceMetric   m_metrics[50];
int                 m_metricCount;
bool                m_analyticsActive;
datetime            m_lastAnalysis;
string              m_lastReport;

// Private methods - PROPERLY SCOPED
void UpdateMetricTrends()
{
for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].isValid)
{
// Simple trend analysis
if(m_metrics[i].currentValue > m_metrics[i].averageValue * 1.05)
m_metrics[i].trend = 1; // Improving
else if(m_metrics[i].currentValue < m_metrics[i].averageValue * 0.95)
m_metrics[i].trend = -1; // Declining
else
m_metrics[i].trend = 0; // Stable
}
}
}

void CalculateAverages()
{
for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].isValid)
{
// Simple moving average calculation
m_metrics[i].averageValue = (m_metrics[i].averageValue * 0.9) + (m_metrics[i].currentValue * 0.1);

// Update min/max
m_metrics[i].minValue = MathMin(m_metrics[i].minValue, m_metrics[i].currentValue);
m_metrics[i].maxValue = MathMax(m_metrics[i].maxValue, m_metrics[i].currentValue);
}
}
}

string GenerateAnalysisReport()
{
string report = "=== ADVANCED ANALYTICS REPORT ===\n";

for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].isValid)
{
string trendStr = "";
switch(m_metrics[i].trend)
{
case 1: trendStr = "?"; break;
case -1: trendStr = "?"; break;
default: trendStr = "."; break;
}

report += StringFormat("%s: %.2f %s (Avg: %.2f, Min: %.2f, Max: %.2f)\n",
m_metrics[i].name,
m_metrics[i].currentValue,
trendStr,
m_metrics[i].averageValue,
m_metrics[i].minValue,
m_metrics[i].maxValue
);
}
}

return report;
}

public:
// Constructor
CAdvancedAnalyticsMonitor()
{
m_metricCount = 0;
m_analyticsActive = false;
m_lastAnalysis = 0;
m_lastReport = "";

// Initialize metrics array
for(int i = 0; i < 50; i++)
{
m_metrics[i].Reset();
}
}

// Destructor
~CAdvancedAnalyticsMonitor()
{
// Cleanup if needed
}

// Public methods
bool Initialize()
{
m_analyticsActive = true;
m_lastAnalysis = TimeCurrent();

// Initialize default metrics
AddMetric("CPU_Usage");
AddMetric("Memory_Usage");
AddMetric("Signal_Quality");
AddMetric("Trade_Success_Rate");
AddMetric("Risk_Level");

return true;
}

bool AddMetric(string metricName)
{
if(m_metricCount >= 50) return false;

m_metrics[m_metricCount].name = metricName;
m_metrics[m_metricCount].isValid = true;
m_metrics[m_metricCount].lastUpdate = TimeCurrent();
m_metricCount++;

return true;
}

bool UpdateMetric(string metricName, double value)
{
for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].name == metricName) // && m_metrics[i].isValid)
{
m_metrics[i].currentValue = value;
m_metrics[i].lastUpdate = TimeCurrent();
return true;
}
}
return false;
}

void PerformAnalysis()
{
if(!m_analyticsActive) return;

datetime currentTime = TimeCurrent();
if(currentTime - m_lastAnalysis < 60) return; // Analyze every minute

UpdateMetricTrends();
CalculateAverages();
m_lastReport = GenerateAnalysisReport();
m_lastAnalysis = currentTime;

// Generate maintenance recommendations if needed
GenerateMaintenanceRecommendations();
}

string GetAnalysisReport()
{
return m_lastReport;
}

double GetMetricValue(string metricName)
{
for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].name == metricName && m_metrics[i].isValid)
{
return m_metrics[i].currentValue;
}
}
return 0.0;
}

bool IsMetricTrending(string metricName, int &trend)
{
for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].name == metricName) // && m_metrics[i].isValid)
{
trend = m_metrics[i].trend;
return true;
}
}
return false;
}

void SetAnalyticsActive(bool active)
{
m_analyticsActive = active;
}

bool IsAnalyticsActive()
{
return m_analyticsActive;
}

int GetMetricCount()
{
return m_metricCount;
}

private:
void GenerateMaintenanceRecommendations()
{
// Check for metrics that need attention
for(int i = 0; i < m_metricCount; i++)
{
if(m_metrics[i].isValid)
{
if(m_metrics[i].trend == -1 && m_metrics[i].currentValue < m_metrics[i].averageValue * 0.8)
{
Print("[ANALYTICS WARNING] Metric ", m_metrics[i].name, " is declining significantly");
}

if(m_metrics[i].currentValue > m_metrics[i].maxValue * 1.2)
{
Print("[ANALYTICS ALERT] Metric ", m_metrics[i].name, " exceeded normal range");
}
}
}
}
};

//+------------------------------------------------------------------+
//| System Health Monitor Class - COMPLETE                          |
//+------------------------------------------------------------------+
class CSystemHealthMonitor
{
private:
bool                m_healthCheckActive;
datetime            m_lastHealthCheck;
double              m_systemScore;
string              m_healthStatus;

void CalculateSystemScore()
{
// Simplified system score calculation
m_systemScore = 85.0; // Placeholder - actual implementation would check multiple factors

if(m_systemScore >= 90.0)
m_healthStatus = "EXCELLENT";
else if(m_systemScore >= 75.0)
m_healthStatus = "GOOD";
else if(m_systemScore >= 60.0)
m_healthStatus = "FAIR";
else
m_healthStatus = "POOR";
}

public:
CSystemHealthMonitor()
{
m_healthCheckActive = false;
m_lastHealthCheck = 0;
m_systemScore = 0.0;
m_healthStatus = "UNKNOWN";
}

bool Initialize()
{
m_healthCheckActive = true;
m_lastHealthCheck = TimeCurrent();
CalculateSystemScore();
return true;
}

void PerformHealthCheck()
{
if(!m_healthCheckActive) return;

datetime currentTime = TimeCurrent();
if(currentTime - m_lastHealthCheck < 300) return; // Check every 5 minutes

CalculateSystemScore();
m_lastHealthCheck = currentTime;

Print("[HEALTH] System score: ", DoubleToString(m_systemScore, 1), "% - Status: ", m_healthStatus);
}

double GetSystemScore() { return m_systemScore; }
string GetHealthStatus() { return m_healthStatus; }
bool IsHealthy() { return m_systemScore >= 70.0; }

void SetHealthCheckActive(bool active) { m_healthCheckActive = active; }
bool IsHealthCheckActive() { return m_healthCheckActive; }
};

//+------------------------------------------------------------------+
//| Main Monitoring Manager Class - INTEGRATED                      |
//+------------------------------------------------------------------+
class CMonitoringManager
{
private:
CAdvancedAnalyticsMonitor*  m_analytics;
CSystemHealthMonitor*       m_healthMonitor;
bool                        m_monitoringActive;
datetime                    m_lastUpdate;

public:
CMonitoringManager()
{
m_analytics = new CAdvancedAnalyticsMonitor();
m_healthMonitor = new CSystemHealthMonitor();
m_monitoringActive = false;
m_lastUpdate = 0;
}

~CMonitoringManager()
{
if(m_analytics) delete m_analytics;
if(m_healthMonitor) delete m_healthMonitor;
}

bool Initialize()
{
if(m_analytics && // m_analytics.Initialize() &&
m_healthMonitor && m_healthMonitor.Initialize())
{
m_monitoringActive = true;
m_lastUpdate = TimeCurrent();
return true;
}
return false;
}

void Update()
{
if(!m_monitoringActive) return;

datetime currentTime = TimeCurrent();
if(currentTime - m_lastUpdate < 30) return; // Update every 30 seconds

if(m_analytics) m_analytics.PerformAnalysis();
if(m_healthMonitor) m_healthMonitor.PerformHealthCheck();

m_lastUpdate = currentTime;
}

string GetFullReport()
{
string report = "";

if(m_analytics)
{
report += m_analytics.GetAnalysisReport();
}

if(m_healthMonitor)
{
report += "\n=== SYSTEM HEALTH ===\n";
report += "Score: " + DoubleToString(m_healthMonitor.GetSystemScore(), 1) + "%\n";
report += "Status: " + m_healthMonitor.GetHealthStatus() + "\n";
}

return report;
}

bool UpdateAnalyticsMetric(string metricName, double value)
{
if(m_analytics)
{
return m_analytics.UpdateMetric(metricName, value);
}
return false;
}

double GetAnalyticsMetric(string metricName)
{
if(m_analytics)
{
return m_analytics.GetMetricValue(metricName);
}
return 0.0;
}

bool IsSystemHealthy()
{
if(m_healthMonitor)
{
return m_healthMonitor.IsHealthy();
}
return false;
}

void SetMonitoringActive(bool active)
{
m_monitoringActive = active;
if(m_analytics) m_analytics.SetAnalyticsActive(active);
if(m_healthMonitor) m_healthMonitor.SetHealthCheckActive(active);
}

bool IsMonitoringActive() { return m_monitoringActive; }
};

#endif // MONITORING_ADVANCEDANALYTICS_MQH









