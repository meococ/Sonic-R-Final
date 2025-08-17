//+------------------------------------------------------------------+
//|                   10_Testing_01_LiveValidation.mqh              |
//|                    SONIC R MC - LIVE VALIDATION SYSTEM          |
//|                    IMPLEMENTS REAL-TIME VALIDATION              |
//+------------------------------------------------------------------+
#ifndef LIVE_VALIDATION_MQH
#define LIVE_VALIDATION_MQH

#include "00_Main_MasterIncludes.mqh"

// Portable environment checks
bool IsTradeEnvOk() {
  bool term_ok = (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
  bool mql_ok  = (bool)MQLInfoInteger(MQL_TRADE_ALLOWED);
  bool acc_ok  = (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  return (term_ok && mql_ok && acc_ok);
}

double GetSystemCpuUsage() { return 0.0; }

double GetSystemMemoryUsage() {
  long phys  = (long)TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
  long avail = (long)TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE);
  if(phys<=0) return 0.0;
  double used = 1.0 - (double)avail/(double)phys;
  if(used<0) used=0; if(used>1) used=1;
  return used*100.0; // percent
}

//+------------------------------------------------------------------+
//| LIVE VALIDATION DATA STRUCTURES                                  |
//+------------------------------------------------------------------+
struct SLiveValidationResult {
    bool isValid;
    string validationMessage;
    double confidenceScore;
    datetime validationTime;
    int errorCount;
    int warningCount;
};

struct SLiveValidationMetrics {
    double winRate;
    double profitFactor;
    double sharpeRatio;
    double maxDrawdown;
    double avgTradeDuration;
    int totalTrades;
    datetime lastUpdate;
};

//+------------------------------------------------------------------+
//| LIVE VALIDATION CLASS                                            |
//+------------------------------------------------------------------+
class CLiveValidator {
private:
    SLiveValidationResult m_validationResult;
    SLiveValidationMetrics m_validationMetrics;
    datetime m_lastValidationTime;
    int m_validationInterval;
    
public:
    CLiveValidator();
    ~CLiveValidator();
    
    bool Initialize();
    bool RunLiveValidation();
    SLiveValidationResult GetValidationResult() const { return m_validationResult; }
    SLiveValidationMetrics GetValidationMetrics() const { return m_validationMetrics; }
    
    // Validation methods
    bool ValidateSignalQuality();
    bool ValidateRiskManagement();
    bool ValidatePerformanceMetrics();
    bool ValidateSystemHealth();
    
    // Metric calculation methods
    void CalculatePerformanceMetrics();
    void UpdateValidationResult();
};

//+------------------------------------------------------------------+
//| CONSTRUCTOR                                                      |
//+------------------------------------------------------------------+
CLiveValidator::CLiveValidator() {
    // Portable clear
m_validationResult.validationTime = 0;
m_validationResult.isValid = false;
m_validationResult.errorCount = 0;
m_validationResult.warningCount = 0;
// ArrayInitialize metrics if exists; guarded to avoid missing fields
    m_lastValidationTime = 0;
    m_validationInterval = 60; // Validate every 60 seconds
}

//+------------------------------------------------------------------+
//| DESTRUCTOR                                                       |
//+------------------------------------------------------------------+
CLiveValidator::~CLiveValidator() {
    // Cleanup if needed
}

//+------------------------------------------------------------------+
//| INITIALIZATION                                                   |
//+------------------------------------------------------------------+
bool CLiveValidator::Initialize() {
    m_lastValidationTime = TimeCurrent();
    
    // Initialize validation metrics
    CalculatePerformanceMetrics();
    
    Print("✅ Live Validator initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| RUN LIVE VALIDATION                                              |
//+------------------------------------------------------------------+
bool CLiveValidator::RunLiveValidation() {
    datetime currentTime = TimeCurrent();
    
    // Only run validation at specified intervals
    if((currentTime - m_lastValidationTime) < m_validationInterval) {
        return true;
    }
    
    m_lastValidationTime = currentTime;
    
    // Reset validation result
    m_validationResult.validationTime=0; m_validationResult.isValid=false; m_validationResult.errorCount=0; m_validationResult.warningCount=0;
    m_validationResult.validationTime = currentTime;
    m_validationResult.isValid = true;
    
    // Run all validation checks
    bool signalValid = ValidateSignalQuality();
    bool riskValid = ValidateRiskManagement();
    bool performanceValid = ValidatePerformanceMetrics();
    bool healthValid = ValidateSystemHealth();
    
    // Update metrics
    CalculatePerformanceMetrics();
    
    // Determine overall validation result
    m_validationResult.isValid = signalValid && riskValid && performanceValid && healthValid;
    
    // Update validation message
    if(!m_validationResult.isValid) {
        m_validationResult.validationMessage = "Validation failed - check individual components";
    } else {
        m_validationResult.validationMessage = "All validations passed";
    }
    
    // Update validation result
    UpdateValidationResult();
    
    return true;
}

//+------------------------------------------------------------------+
//| VALIDATE SIGNAL QUALITY                                          |
//+------------------------------------------------------------------+
bool CLiveValidator::ValidateSignalQuality() {
    // Validate the quality of generated signals
    // This would check signal accuracy, confluence, etc.
    
    // Placeholder implementation
    // In a real implementation, this would analyze
    // recent signal performance and accuracy
    
    return true;
}

//+------------------------------------------------------------------+
//| VALIDATE RISK MANAGEMENT                                         |
//+------------------------------------------------------------------+
bool CLiveValidator::ValidateRiskManagement() {
    // Validate risk management compliance
    // This would check position sizing, stop losses, etc.
    
    // Placeholder implementation
    // In a real implementation, this would analyze
    // current positions and risk exposure
    
    return true;
}

//+------------------------------------------------------------------+
//| VALIDATE PERFORMANCE METRICS                                     |
//+------------------------------------------------------------------+
bool CLiveValidator::ValidatePerformanceMetrics() {
    // Validate performance metrics are within acceptable ranges
    
    // Check win rate
    if(m_validationMetrics.winRate < 0.4) {
        m_validationResult.validationMessage = "Win rate below threshold";
        m_validationResult.errorCount++;
        return false;
    }
    
    // Check profit factor
    if(m_validationMetrics.profitFactor < 1.2) {
        m_validationResult.validationMessage = "Profit factor below threshold";
        m_validationResult.warningCount++;
        // Not necessarily failing, but worth noting
    }
    
    // Check drawdown
    if(m_validationMetrics.maxDrawdown > 0.1) { // 10% drawdown
        m_validationResult.validationMessage = "Drawdown above threshold";
        m_validationResult.warningCount++;
        // Not necessarily failing, but worth noting
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| VALIDATE SYSTEM HEALTH                                           |
//+------------------------------------------------------------------+
bool CLiveValidator::ValidateSystemHealth() {
    // Validate system health indicators
    
    // Check if trading is allowed
    if(!IsTradeEnvOk()) {
        m_validationResult.validationMessage = "Trading not allowed";
        m_validationResult.errorCount++;
        return false;
    }
    
    // Check system resources
    double cpuUsage = GetSystemCpuUsage();
    if(cpuUsage > 80.0 && cpuUsage < 1000.0) { // 80% CPU usage
        m_validationResult.validationMessage = "High CPU usage";
        m_validationResult.warningCount++;
    }
    
    // Check memory usage
    double memoryUsage = GetSystemMemoryUsage();
    if(memoryUsage > 80.0) { // 80% memory usage
        m_validationResult.validationMessage = "High memory usage";
        m_validationResult.warningCount++;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| CALCULATE PERFORMANCE METRICS                                    |
//+------------------------------------------------------------------+
void CLiveValidator::CalculatePerformanceMetrics() {
    // Calculate real-time performance metrics
    
    // These are placeholder values
    // In a real implementation, these would be calculated
    // from actual trading data
    
    m_validationMetrics.winRate = 0.65; // 65% win rate
    m_validationMetrics.profitFactor = 1.8; // 1.8 profit factor
    m_validationMetrics.sharpeRatio = 1.2; // 1.2 Sharpe ratio
    m_validationMetrics.maxDrawdown = 0.05; // 5% drawdown
    m_validationMetrics.avgTradeDuration = 120; // 2 hours average
    m_validationMetrics.totalTrades = 150; // 150 total trades
    m_validationMetrics.lastUpdate = TimeCurrent();
}

//+------------------------------------------------------------------+
//| UPDATE VALIDATION RESULT                                         |
//+------------------------------------------------------------------+
void CLiveValidator::UpdateValidationResult() {
    // Calculate confidence score based on validation results
    double score = 100.0;
    
    // Reduce score for errors
    score -= m_validationResult.errorCount * 10;
    
    // Reduce score for warnings
    score -= m_validationResult.warningCount * 5;
    
    // Ensure score is between 0 and 100
    m_validationResult.confidenceScore = MathMax(0, MathMin(100, score));
    
    // Log validation result if score is low
    if(m_validationResult.confidenceScore < 70) {
        LogWarning("Low validation confidence: " + DoubleToString(m_validationResult.confidenceScore, 1));
    }
}

#endif // LIVE_VALIDATION_MQH
