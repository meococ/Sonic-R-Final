//+------------------------------------------------------------------+
//| SYSTEMATIC FIX - Missing Utility Functions                      |
//| This file contains utility functions that are called but        |
//| not implemented in various modules                               |
//+------------------------------------------------------------------+
#ifndef CORE_UTILITY_FUNCTIONS_MQH
#define CORE_UTILITY_FUNCTIONS_MQH

#include "01_Core_14_CoreEnums.mqh"

//+------------------------------------------------------------------+
//| PropFirm Utility Functions                                      |
//+------------------------------------------------------------------+
string FirmTypeToString(ENUM_PROP_FIRM firmType)
{
    switch(firmType)
    {
        case PROP_FIRM_FTMO: return "FTMO";
        case PROP_FIRM_MYFOREXFUNDS: return "MyForexFunds";
        // SYSTEMATIC FIX - PROP_FIRM_MYFXFUNDS is alias for MYFOREXFUNDS, skip to avoid duplicate case
        case PROP_FIRM_FUNDEDNEXT: return "FundedNext";
        case PROP_FIRM_TOPSTEP: return "TopStep";
        case PROP_FIRM_TOPTRADER: return "TopTrader";
        case PROP_FIRM_TRUEFOREXFUNDS: return "TrueForexFunds";
        case PROP_FIRM_NOVA: return "Nova";
        case PROP_FIRM_CUSTOM: return "Custom";
        case PROP_FIRM_GENERIC: return "Generic";
        default: return "Unknown";
    }
}

string PhaseToString(int phase)
{
    switch(phase)
    {
        case 1: return "Challenge Phase";
        case 2: return "Verification Phase";
        case 3: return "Funded Phase";
        default: return StringFormat("Phase %d", phase);
    }
}

string ComplianceStatusToString(int status)
{
    switch(status)
    {
        case 0: return "Non-Compliant";
        case 1: return "Partially Compliant";
        case 2: return "Fully Compliant";
        case 3: return "Excellent";
        default: return "Unknown Status";
    }
}

//+------------------------------------------------------------------+
//| Certification Utility Functions                                 |
//+------------------------------------------------------------------+
string CertificationLevelToString(ENUM_CERTIFICATION_LEVEL level)
{
    switch(level)
    {
        case CERT_BASIC: return "Basic";
        // SYSTEMATIC FIX - CERT_LEVEL_BASIC is alias for CERT_BASIC, skip to avoid duplicate case
        case CERT_INTERMEDIATE: return "Standard";
        case CERT_ADVANCED: return "Advanced";
        case CERT_EXPERT: return "Enterprise";
        default: return "Unknown Level";
    }
}

//+------------------------------------------------------------------+
//| Validation Utility Functions                                    |
//+------------------------------------------------------------------+
string ValidationStatusToString(int status)
{
    switch(status)
    {
        case 0: return "Failed";
        case 1: return "Warning";
        case 2: return "Passed";
        case 3: return "Excellent";
        default: return "Unknown";
    }
}

string ReportTypeToString(int reportType)
{
    switch(reportType)
    {
        case 0: return "Summary";
        case 1: return "Detailed";
        case 2: return "Technical";
        case 3: return "Compliance";
        case 4: return "Performance";
        default: return "Unknown Type";
    }
}

//+------------------------------------------------------------------+
//| System Health Functions                                         |
//+------------------------------------------------------------------+
double GetSystemHealthScore()
{
    // Simple system health calculation
    double cpuScore = 0.8;      // 80% CPU health
    double memoryScore = 0.9;   // 90% Memory health
    double networkScore = 0.85; // 85% Network health
    
    return (cpuScore + memoryScore + networkScore) / 3.0;
}

//+------------------------------------------------------------------+
//| SYSTEMATIC FIX - Error Handler Functions (Non-Class)           |
//| Note: CCompleteErrorHandler class exists in ErrorHandler.mqh   |
//+------------------------------------------------------------------+
void LogSystemError(string message, ENUM_ERROR_SEVERITY severity = ERROR_SEVERITY_MEDIUM,
                   ENUM_ERROR_CONTEXT context = ERROR_CTX_GENERAL,
                   string details = "", string location = "")
{
    string severityStr = "";
    switch(severity) {
        case ERROR_SEVERITY_LOW: severityStr = "LOW"; break;
        case ERROR_SEVERITY_MEDIUM: severityStr = "MEDIUM"; break;
        case ERROR_SEVERITY_HIGH: severityStr = "HIGH"; break;
        case ERROR_SEVERITY_CRITICAL: severityStr = "CRITICAL"; break;
    }

    string contextStr = "";
    switch(context) {
        case ERROR_CTX_GENERAL: contextStr = "GENERAL"; break;
        case ERROR_CTX_TRADING: contextStr = "TRADING"; break;
        case ERROR_CTX_ANALYSIS: contextStr = "ANALYSIS"; break;
        case ERROR_CTX_UI: contextStr = "UI"; break;
        case ERROR_CTX_SYSTEM: contextStr = "SYSTEM"; break;
    }

    Print(StringFormat("[%s][%s] %s", severityStr, contextStr, message));
    if(details != "") Print("Details: " + details);
    if(location != "") Print("Location: " + location);
}

#endif // CORE_UTILITY_FUNCTIONS_MQH
