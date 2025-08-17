//+------------------------------------------------------------------+
//|                           Reports_ValidationGenerator.mqh       |
//|                  ?? PHASE 6: VALIDATION REPORT GENERATOR        |
//|                  ?? COMPREHENSIVE VALIDATION & REPORTING        |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team - Phase 6 Enhancement"
#property version   "6.00"
#ifndef REPORTS_VALIDATIONGENERATOR_MQH
#define REPORTS_VALIDATIONGENERATOR_MQH
#include "01_Core_08_ContextManager.mqh"
// SYSTEMATIC FIX - File cleaned up by Boss
// #include "01_Core_06_GlobalDeclarations.mqh"
// #include "01_Core_16_EnumHelpers.mqh" // Already included in MasterIncludes
//+------------------------------------------------------------------+
//| Report Types                                                     |
//+------------------------------------------------------------------+
enum ENUM_REPORT_TYPE
{
    REPORT_TYPE_DAILY = 0,          // Daily validation report
    REPORT_TYPE_WEEKLY = 1,         // Weekly summary report
    REPORT_TYPE_MONTHLY = 2,        // Monthly comprehensive report
    REPORT_TYPE_CUSTOM = 3,         // Custom period report
    REPORT_TYPE_REALTIME = 4,       // Real-time status report
    REPORT_TYPE_COMPLIANCE = 5,     // Compliance validation report
    REPORT_TYPE_PERFORMANCE = 6,    // Performance analysis report
    REPORT_TYPE_ERROR = 7           // Error analysis report
};
//+------------------------------------------------------------------+
//| Report Format                                                    |
//+------------------------------------------------------------------+
enum ENUM_REPORT_FORMAT
{
    REPORT_FORMAT_TEXT = 0,         // Plain text format
    REPORT_FORMAT_HTML = 1,         // HTML format
    REPORT_FORMAT_CSV = 2,          // CSV format
    REPORT_FORMAT_JSON = 3,         // JSON format
    REPORT_FORMAT_XML = 4           // XML format
};
//+------------------------------------------------------------------+
//| Validation Status                                                |
//+------------------------------------------------------------------+
enum ENUM_VALIDATION_STATUS
{
    VALIDATION_PASSED = 0,          // Validation passed
    VALIDATION_WARNING = 1,         // Validation passed with warnings
    VALIDATION_FAILED = 2,          // Validation failed
    VALIDATION_ERROR = 3,           // Validation error
    VALIDATION_STATUS_PENDING = 4   // Validation pending
};
//+------------------------------------------------------------------+
//| Validation Result Structure                                      |
//+------------------------------------------------------------------+
struct SValidationResult
{
    string testName;
    ENUM_VALIDATION_STATUS status;
    double score;
    string description;
    string details;
    datetime timestamp;
    string category;
    int severity; // 1-5 scale
    
    void Initialize()
    {
        testName = "";
        status = VALIDATION_STATUS_PENDING;
        score = 0.0;
        description = "";
        details = "";
        timestamp = TimeCurrent();
        category = "";
        severity = 1;
    }
};
//+------------------------------------------------------------------+
//| Report Configuration Structure                                   |
//+------------------------------------------------------------------+
struct SReportConfig
{
    ENUM_REPORT_TYPE type;
    ENUM_REPORT_FORMAT format;
    string outputPath;
    bool includeCharts;
    bool includeDetails;
    bool autoGenerate;
    int generationInterval; // minutes
    datetime startTime;
    datetime endTime;
    
    void Initialize()
    {
        type = REPORT_TYPE_DAILY;
        format = REPORT_FORMAT_HTML;
        outputPath = "Reports\\";
        includeCharts = true;
        includeDetails = true;
        autoGenerate = false;
        generationInterval = 60;
        startTime = 0;
        endTime = 0;
    }
};
//+------------------------------------------------------------------+
//| Validation Report Generator Class                               |
//+------------------------------------------------------------------+
class CValidationReportGenerator
{
private:
    // Generator state
    bool m_isInitialized;
    bool m_isGenerating;
    
    // Configuration
    SReportConfig m_config;
    
    // Validation results storage
    SValidationResult m_validationResults[];
    int m_resultCount;
    
    // Report statistics
    int m_totalTests;
    int m_passedTests;
    int m_warningTests;
    int m_failedTests;
    int m_errorTests;
    double m_overallScore;
    
    // File handling
    string m_currentReportPath;
    int m_reportCounter;
    
    // Timing
    datetime m_lastReportTime;
    datetime m_nextScheduledReport;
    
public:
    //+------------------------------------------------------------------+
    //| Constructor & Destructor                                        |
    //+------------------------------------------------------------------+
    CValidationReportGenerator()
    {
        m_isInitialized = false;
        m_isGenerating = false;
        m_resultCount = 0;
        m_totalTests = 0;
        m_passedTests = 0;
        m_warningTests = 0;
        m_failedTests = 0;
        m_errorTests = 0;
        m_overallScore = 0.0;
        m_currentReportPath = "";
        m_reportCounter = 0;
        m_lastReportTime = 0;
        m_nextScheduledReport = 0;
        
        m_config.Initialize();
        ArrayResize(m_validationResults, 1000); // Initial capacity
    }
    
    ~CValidationReportGenerator()
    {
        ArrayFree(m_validationResults);
    }
    
    //+------------------------------------------------------------------+
    //| Initialization                                                   |
    //+------------------------------------------------------------------+
    bool Initialize()
    {
        Print("[VALIDATION_REPORTS] Initializing Validation Report Generator...");
        
        if(m_isInitialized)
        {
            Print("[VALIDATION_REPORTS] WARNING: Already initialized");
            return true;
        }
        
        // Create reports directory if it doesn't exist
        CreateReportsDirectory();
        
        // Initialize configuration
        m_config.Initialize();
        m_config.outputPath = "Reports\\ValidationReports\\";
        
        // Reset statistics
        ResetStatistics();
        
        // Set next scheduled report
        if(m_config.autoGenerate)
        {
            m_nextScheduledReport = TimeCurrent() + (m_config.generationInterval * 60);
        }
        
        m_isInitialized = true;
        Print("[VALIDATION_REPORTS] Validation Report Generator initialized successfully");
        
        return true;
    }
    
    void CreateReportsDirectory()
    {
        // Create main reports directory
        string mainDir = "Reports";
        if(!FolderCreate(mainDir, FILE_COMMON))
        {
            // Directory might already exist, which is fine
        }
        
        // Create validation reports subdirectory
        string validationDir = "Reports\\ValidationReports";
        if(!FolderCreate(validationDir, FILE_COMMON))
        {
            // Directory might already exist, which is fine
        }
        
        Print("[VALIDATION_REPORTS] Reports directory structure created");
    }
    
    //+------------------------------------------------------------------+
    //| Validation Result Management                                     |
    //+------------------------------------------------------------------+
    bool AddValidationResult(const SValidationResult& result)
    {
        if(!m_isInitialized)
        {
            Print("[VALIDATION_REPORTS] ERROR: Generator not initialized");
            return false;
        }
        
        // Resize array if needed
        if(m_resultCount >= ArraySize(m_validationResults))
        {
            ArrayResize(m_validationResults, m_resultCount + 500);
        }
        
        // Add result
        m_validationResults[m_resultCount] = result;
        m_resultCount++;
        
        // Update statistics
        UpdateStatistics(result);
        
        return true;
    }
    
    void UpdateStatistics(const SValidationResult& result)
    {
        m_totalTests++;
        
        switch(result.status)
        {
            case VALIDATION_PASSED:
                m_passedTests++;
                break;
            case VALIDATION_WARNING:
                m_warningTests++;
                break;
            case VALIDATION_FAILED:
                m_failedTests++;
                break;
            case VALIDATION_ERROR:
                m_errorTests++;
                break;
        }
        
        // Recalculate overall score
        CalculateOverallScore();
    }
    
    void CalculateOverallScore()
    {
        if(m_totalTests == 0)
        {
            m_overallScore = 0.0;
            return;
        }
        
        double totalScore = 0.0;
        int scoredTests = 0;
        
        for(int i = 0; i < m_resultCount; i++)
        {
            if(m_validationResults[i].status != VALIDATION_STATUS_PENDING)
            {
                totalScore += m_validationResults[i].score;
                scoredTests++;
            }
        }
        
        m_overallScore = (scoredTests > 0) ? (totalScore / scoredTests) : 0.0;
    }
    
    void ResetStatistics()
    {
        m_totalTests = 0;
        m_passedTests = 0;
        m_warningTests = 0;
        m_failedTests = 0;
        m_errorTests = 0;
        m_overallScore = 0.0;
    }
    
    //+------------------------------------------------------------------+
    //| Report Generation                                                |
    //+------------------------------------------------------------------+
    bool GenerateReport(ENUM_REPORT_TYPE reportType = REPORT_TYPE_DAILY, 
                       ENUM_REPORT_FORMAT format = REPORT_FORMAT_HTML)
    {
        if(!m_isInitialized)
        {
            Print("[VALIDATION_REPORTS] ERROR: Generator not initialized");
            return false;
        }
        
        if(m_isGenerating)
        {
            Print("[VALIDATION_REPORTS] WARNING: Report generation already in progress");
            return false;
        }
        
        Print(StringFormat("[VALIDATION_REPORTS] Generating %s report in %s format...", 
              ReportTypeToString(reportType), ReportTypeToString(format)));
        
        m_isGenerating = true;
        
        // Set report configuration
        m_config.type = reportType;
        m_config.format = format;
        
        // Generate filename
        string filename = GenerateFilename(reportType, format);
        m_currentReportPath = m_config.outputPath + filename;
        
        bool success = false;
        
        // Generate report based on format
        switch(format)
        {
            case REPORT_FORMAT_HTML:
                success = GenerateHTMLReport();
                break;
            case REPORT_FORMAT_TEXT:
                success = GenerateTextReport();
                break;
            case REPORT_FORMAT_CSV:
                success = GenerateCSVReport();
                break;
            case REPORT_FORMAT_JSON:
                success = GenerateJSONReport();
                break;
            case REPORT_FORMAT_XML:
                success = GenerateXMLReport();
                break;
        }
        
        if(success)
        {
            m_lastReportTime = TimeCurrent();
            m_reportCounter++;
            Print(StringFormat("[VALIDATION_REPORTS] Report generated successfully: %s", m_currentReportPath));
        }
        else
        {
            Print("[VALIDATION_REPORTS] ERROR: Failed to generate report");
        }
        
        m_isGenerating = false;
        return success;
    }
    
    string GenerateFilename(ENUM_REPORT_TYPE reportType, ENUM_REPORT_FORMAT format)
    {
        string typeStr = "";
        switch(reportType)
        {
            case REPORT_TYPE_DAILY: typeStr = "Daily"; break;
            case REPORT_TYPE_WEEKLY: typeStr = "Weekly"; break;
            case REPORT_TYPE_MONTHLY: typeStr = "Monthly"; break;
            case REPORT_TYPE_CUSTOM: typeStr = "Custom"; break;
            case REPORT_TYPE_REALTIME: typeStr = "RealTime"; break;
            case REPORT_TYPE_COMPLIANCE: typeStr = "Compliance"; break;
            case REPORT_TYPE_PERFORMANCE: typeStr = "Performance"; break;
            case REPORT_TYPE_ERROR: typeStr = "Error"; break;
        }
        
        string extension = "";
        switch(format)
        {
            case REPORT_FORMAT_HTML: extension = ".html"; break;
            case REPORT_FORMAT_TEXT: extension = ".txt"; break;
            case REPORT_FORMAT_CSV: extension = ".csv"; break;
            case REPORT_FORMAT_JSON: extension = ".json"; break;
            case REPORT_FORMAT_XML: extension = ".xml"; break;
        }
        
        string timestamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
        StringReplace(timestamp, ":", "");
        StringReplace(timestamp, " ", "_");
        StringReplace(timestamp, ".", "");
        
        return StringFormat("ValidationReport_%s_%s_%03d%s", 
                           typeStr, timestamp, m_reportCounter, extension);
    }
    
    //+------------------------------------------------------------------+
    //| Format-Specific Report Generation                               |
    //+------------------------------------------------------------------+
    bool GenerateHTMLReport()
    {
        int fileHandle = FileOpen(m_currentReportPath, FILE_WRITE | FILE_TXT | FILE_COMMON);
        if(fileHandle == INVALID_HANDLE)
        {
            Print("[VALIDATION_REPORTS] ERROR: Cannot create HTML report file");
            return false;
        }
        
        // Write HTML header
        FileWrite(fileHandle, "<!DOCTYPE html>");
        FileWrite(fileHandle, "<html>");
        FileWrite(fileHandle, "<head>");
        FileWrite(fileHandle, "<title>SONIC R MC - Validation Report</title>");
        FileWrite(fileHandle, "<style>");
        FileWrite(fileHandle, "body { font-family: Arial, sans-serif; margin: 20px; }");
        FileWrite(fileHandle, "table { border-collapse: collapse; width: 100%; }");
        FileWrite(fileHandle, "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        FileWrite(fileHandle, "th { background-color: #f2f2f2; }");
        FileWrite(fileHandle, ".passed { color: green; }");
        FileWrite(fileHandle, ".warning { color: orange; }");
        FileWrite(fileHandle, ".failed { color: red; }");
        FileWrite(fileHandle, ".error { color: darkred; }");
        FileWrite(fileHandle, "</style>");
        FileWrite(fileHandle, "</head>");
        FileWrite(fileHandle, "<body>");
        
        // Write report header
        FileWrite(fileHandle, "<h1>SONIC R MC - Validation Report</h1>");
        FileWrite(fileHandle, StringFormat("<h2>Report Type: %s</h2>", ReportTypeToString(m_config.type)));
        FileWrite(fileHandle, StringFormat("<p>Generated: %s</p>", TimeToString(TimeCurrent())));
        FileWrite(fileHandle, StringFormat("<p>Report Period: %s to %s</p>", 
                 TimeToString(m_config.startTime), TimeToString(m_config.endTime)));
        
        // Write summary statistics
        WriteHTMLSummary(fileHandle);
        
        // Write detailed results
        WriteHTMLDetails(fileHandle);
        
        // Write HTML footer
        FileWrite(fileHandle, "</body>");
        FileWrite(fileHandle, "</html>");
        
        FileClose(fileHandle);
        return true;
    }
    
    void WriteHTMLSummary(int fileHandle)
    {
        FileWrite(fileHandle, "<h3>Summary Statistics</h3>");
        FileWrite(fileHandle, "<table>");
        FileWrite(fileHandle, "<tr><th>Metric</th><th>Value</th></tr>");
        FileWrite(fileHandle, StringFormat("<tr><td>Total Tests</td><td>%d</td></tr>", m_totalTests));
        FileWrite(fileHandle, StringFormat("<tr><td>Passed</td><td class='passed'>%d</td></tr>", m_passedTests));
        FileWrite(fileHandle, StringFormat("<tr><td>Warnings</td><td class='warning'>%d</td></tr>", m_warningTests));
        FileWrite(fileHandle, StringFormat("<tr><td>Failed</td><td class='failed'>%d</td></tr>", m_failedTests));
        FileWrite(fileHandle, StringFormat("<tr><td>Errors</td><td class='error'>%d</td></tr>", m_errorTests));
        FileWrite(fileHandle, StringFormat("<tr><td>Overall Score</td><td>%.2f%%</td></tr>", m_overallScore));
        FileWrite(fileHandle, "</table>");
    }
    
    void WriteHTMLDetails(int fileHandle)
    {
        FileWrite(fileHandle, "<h3>Detailed Results</h3>");
        FileWrite(fileHandle, "<table>");
        FileWrite(fileHandle, "<tr><th>Test Name</th><th>Status</th><th>Score</th><th>Category</th><th>Timestamp</th><th>Details</th></tr>");
        
        for(int i = 0; i < m_resultCount; i++)
        {
            SValidationResult result = m_validationResults[i];
            string statusClass = "";
            
            switch(result.status)
            {
                case VALIDATION_PASSED: statusClass = "passed"; break;
                case VALIDATION_WARNING: statusClass = "warning"; break;
                case VALIDATION_FAILED: statusClass = "failed"; break;
                case VALIDATION_ERROR: statusClass = "error"; break;
            }
            
            FileWrite(fileHandle, StringFormat("<tr><td>%s</td><td class='%s'>%s</td><td>%.2f</td><td>%s</td><td>%s</td><td>%s</td></tr>",
                     result.testName, statusClass, ValidationStatusToString(result.status), 
                     result.score, result.category, TimeToString(result.timestamp), result.details));
        }
        
        FileWrite(fileHandle, "</table>");
    }
    
    bool GenerateTextReport()
    {
        int fileHandle = FileOpen(m_currentReportPath, FILE_WRITE | FILE_TXT | FILE_COMMON);
        if(fileHandle == INVALID_HANDLE)
        {
            Print("[VALIDATION_REPORTS] ERROR: Cannot create text report file");
            return false;
        }
        
        // Write text header
        FileWrite(fileHandle, "=================================================================");
        FileWrite(fileHandle, "                SONIC R MC - VALIDATION REPORT");
        FileWrite(fileHandle, "=================================================================");
        FileWrite(fileHandle, "");
        FileWrite(fileHandle, StringFormat("Report Type: %s", ReportTypeToString(m_config.type)));
        FileWrite(fileHandle, StringFormat("Generated: %s", TimeToString(TimeCurrent())));
        FileWrite(fileHandle, StringFormat("Report Period: %s to %s", 
                 TimeToString(m_config.startTime), TimeToString(m_config.endTime)));
        FileWrite(fileHandle, "");
        
        // Write summary
        FileWrite(fileHandle, "SUMMARY STATISTICS");
        FileWrite(fileHandle, "-----------------------------------------------------------------");
        FileWrite(fileHandle, StringFormat("Total Tests: %d", m_totalTests));
        FileWrite(fileHandle, StringFormat("Passed: %d", m_passedTests));
        FileWrite(fileHandle, StringFormat("Warnings: %d", m_warningTests));
        FileWrite(fileHandle, StringFormat("Failed: %d", m_failedTests));
        FileWrite(fileHandle, StringFormat("Errors: %d", m_errorTests));
        FileWrite(fileHandle, StringFormat("Overall Score: %.2f%%", m_overallScore));
        FileWrite(fileHandle, "");
        
        // Write detailed results
        FileWrite(fileHandle, "DETAILED RESULTS");
        FileWrite(fileHandle, "-----------------------------------------------------------------");
        
        for(int i = 0; i < m_resultCount; i++)
        {
            SValidationResult result = m_validationResults[i];
            FileWrite(fileHandle, StringFormat("Test: %s", result.testName));
            FileWrite(fileHandle, StringFormat("  Status: %s", ValidationStatusToString(result.status)));
            FileWrite(fileHandle, StringFormat("  Score: %.2f", result.score));
            FileWrite(fileHandle, StringFormat("  Category: %s", result.category));
            FileWrite(fileHandle, StringFormat("  Timestamp: %s", TimeToString(result.timestamp)));
            FileWrite(fileHandle, StringFormat("  Details: %s", result.details));
            FileWrite(fileHandle, "");
        }
        
        FileClose(fileHandle);
        return true;
    }
    
    bool GenerateCSVReport()
    {
        int fileHandle = FileOpen(m_currentReportPath, FILE_WRITE | FILE_TXT | FILE_COMMON);
        if(fileHandle == INVALID_HANDLE)
        {
            Print("[VALIDATION_REPORTS] ERROR: Cannot create CSV report file");
            return false;
        }
        
        // Write CSV header
        FileWrite(fileHandle, "Test Name,Status,Score,Category,Timestamp,Details");
        
        // Write data rows
        for(int i = 0; i < m_resultCount; i++)
        {
            SValidationResult result = m_validationResults[i];
            FileWrite(fileHandle, StringFormat("%s,%s,%.2f,%s,%s,%s",
                     result.testName, ValidationStatusToString(result.status), result.score,
                     result.category, TimeToString(result.timestamp), result.details));
        }
        
        FileClose(fileHandle);
        return true;
    }
    
    bool GenerateJSONReport()
    {
        int fileHandle = FileOpen(m_currentReportPath, FILE_WRITE | FILE_TXT | FILE_COMMON);
        if(fileHandle == INVALID_HANDLE)
        {
            Print("[VALIDATION_REPORTS] ERROR: Cannot create JSON report file");
            return false;
        }
        
        // Write JSON structure
        FileWrite(fileHandle, "{");
        FileWrite(fileHandle, "  \"report\": {");
        FileWrite(fileHandle, StringFormat("    \"type\": \"%s\",", ReportTypeToString(m_config.type)));
        FileWrite(fileHandle, StringFormat("    \"generated\": \"%s\",", TimeToString(TimeCurrent())));
        FileWrite(fileHandle, StringFormat("    \"startTime\": \"%s\",", TimeToString(m_config.startTime)));
        FileWrite(fileHandle, StringFormat("    \"endTime\": \"%s\",", TimeToString(m_config.endTime)));
        FileWrite(fileHandle, "    \"summary\": {");
        FileWrite(fileHandle, StringFormat("      \"totalTests\": %d,", m_totalTests));
        FileWrite(fileHandle, StringFormat("      \"passed\": %d,", m_passedTests));
        FileWrite(fileHandle, StringFormat("      \"warnings\": %d,", m_warningTests));
        FileWrite(fileHandle, StringFormat("      \"failed\": %d,", m_failedTests));
        FileWrite(fileHandle, StringFormat("      \"errors\": %d,", m_errorTests));
        FileWrite(fileHandle, StringFormat("      \"overallScore\": %.2f", m_overallScore));
        FileWrite(fileHandle, "    },");
        FileWrite(fileHandle, "    \"results\": [");
        
        for(int i = 0; i < m_resultCount; i++)
        {
            SValidationResult result = m_validationResults[i];
            FileWrite(fileHandle, "      {");
            FileWrite(fileHandle, StringFormat("        \"testName\": \"%s\",", result.testName));
            FileWrite(fileHandle, StringFormat("        \"status\": \"%s\",", ValidationStatusToString(result.status)));
            FileWrite(fileHandle, StringFormat("        \"score\": %.2f,", result.score));
            FileWrite(fileHandle, StringFormat("        \"category\": \"%s\",", result.category));
            FileWrite(fileHandle, StringFormat("        \"timestamp\": \"%s\",", TimeToString(result.timestamp)));
            FileWrite(fileHandle, StringFormat("        \"details\": \"%s\"", result.details));
            FileWrite(fileHandle, (i < m_resultCount - 1) ? "      }," : "      }");
        }
        
        FileWrite(fileHandle, "    ]");
        FileWrite(fileHandle, "  }");
        FileWrite(fileHandle, "}");
        
        FileClose(fileHandle);
        return true;
    }
    
    bool GenerateXMLReport()
    {
        int fileHandle = FileOpen(m_currentReportPath, FILE_WRITE | FILE_TXT | FILE_COMMON);
        if(fileHandle == INVALID_HANDLE)
        {
            Print("[VALIDATION_REPORTS] ERROR: Cannot create XML report file");
            return false;
        }
        
        // Write XML structure
        FileWrite(fileHandle, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        FileWrite(fileHandle, "<ValidationReport>");
        FileWrite(fileHandle, StringFormat("  <Type>%s</Type>", ReportTypeToString(m_config.type)));
        FileWrite(fileHandle, StringFormat("  <Generated>%s</Generated>", TimeToString(TimeCurrent())));
        FileWrite(fileHandle, StringFormat("  <StartTime>%s</StartTime>", TimeToString(m_config.startTime)));
        FileWrite(fileHandle, StringFormat("  <EndTime>%s</EndTime>", TimeToString(m_config.endTime)));
        FileWrite(fileHandle, "  <Summary>");
        FileWrite(fileHandle, StringFormat("    <TotalTests>%d</TotalTests>", m_totalTests));
        FileWrite(fileHandle, StringFormat("    <Passed>%d</Passed>", m_passedTests));
        FileWrite(fileHandle, StringFormat("    <Warnings>%d</Warnings>", m_warningTests));
        FileWrite(fileHandle, StringFormat("    <Failed>%d</Failed>", m_failedTests));
        FileWrite(fileHandle, StringFormat("    <Errors>%d</Errors>", m_errorTests));
        FileWrite(fileHandle, StringFormat("    <OverallScore>%.2f</OverallScore>", m_overallScore));
        FileWrite(fileHandle, "  </Summary>");
        FileWrite(fileHandle, "  <Results>");
        
        for(int i = 0; i < m_resultCount; i++)
        {
            SValidationResult result = m_validationResults[i];
            FileWrite(fileHandle, "    <Result>");
            FileWrite(fileHandle, StringFormat("      <TestName>%s</TestName>", result.testName));
            FileWrite(fileHandle, StringFormat("      <Status>%s</Status>", ValidationStatusToString(result.status)));
            FileWrite(fileHandle, StringFormat("      <Score>%.2f</Score>", result.score));
            FileWrite(fileHandle, StringFormat("      <Category>%s</Category>", result.category));
            FileWrite(fileHandle, StringFormat("      <Timestamp>%s</Timestamp>", TimeToString(result.timestamp)));
            FileWrite(fileHandle, StringFormat("      <Details>%s</Details>", result.details));
            FileWrite(fileHandle, "    </Result>");
        }
        
        FileWrite(fileHandle, "  </Results>");
        FileWrite(fileHandle, "</ValidationReport>");
        
        FileClose(fileHandle);
        return true;
    }
    
    //+------------------------------------------------------------------+
    //| Periodic Operations                                              |
    //+------------------------------------------------------------------+
    void OnTick()
    {
        if(!m_isInitialized || !m_config.autoGenerate)
            return;
            
        // Check if it's time for scheduled report generation
        if(TimeCurrent() >= m_nextScheduledReport)
        {
            GenerateReport(m_config.type, m_config.format);
            m_nextScheduledReport = TimeCurrent() + (m_config.generationInterval * 60);
        }
    }
    
    //+------------------------------------------------------------------+
    //| Configuration                                                    |
    //+------------------------------------------------------------------+
    void SetReportConfig(const SReportConfig& config)
    {
        m_config = config;
        
        if(m_config.autoGenerate)
        {
            m_nextScheduledReport = TimeCurrent() + (m_config.generationInterval * 60);
        }
    }
    
    SReportConfig GetReportConfig() const
    {
        return m_config;
    }
    
    //+------------------------------------------------------------------+
    //| Getters                                                          |
    //+------------------------------------------------------------------+
    bool IsInitialized() const { return m_isInitialized; }
    bool IsGenerating() const { return m_isGenerating; }
    int GetResultCount() const { return m_resultCount; }
    int GetTotalTests() const { return m_totalTests; }
    int GetPassedTests() const { return m_passedTests; }
    int GetWarningTests() const { return m_warningTests; }
    int GetFailedTests() const { return m_failedTests; }
    int GetErrorTests() const { return m_errorTests; }
    double GetOverallScore() const { return m_overallScore; }
    string GetCurrentReportPath() const { return m_currentReportPath; }
    datetime GetLastReportTime() const { return m_lastReportTime; }
    
    //+------------------------------------------------------------------+
    //| Utility Methods                                                  |
    //+------------------------------------------------------------------+
    void ClearResults()
    {
        m_resultCount = 0;
        ResetStatistics();
        Print("[VALIDATION_REPORTS] Validation results cleared");
    }
    
    void PrintStatus()
    {
        Print("=== VALIDATION REPORT GENERATOR STATUS ===");
        Print(StringFormat("Initialized: %s", m_isInitialized ? "YES" : "NO"));
        Print(StringFormat("Generating: %s", m_isGenerating ? "YES" : "NO"));
        Print(StringFormat("Total Results: %d", m_resultCount));
        Print(StringFormat("Overall Score: %.2f%%", m_overallScore));
        Print(StringFormat("Last Report: %s", TimeToString(m_lastReportTime)));
        Print(StringFormat("Auto Generate: %s", m_config.autoGenerate ? "YES" : "NO"));
        Print("=== END STATUS ===");
    }
};
// Global instance pointer (defined in GlobalDeclarations.mqh)
// CValidationReportGenerator* g_ValidationReportGenerator;
#endif // REPORTS_VALIDATIONGENERATOR_MQH


