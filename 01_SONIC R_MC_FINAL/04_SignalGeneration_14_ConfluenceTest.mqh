//+------------------------------------------------------------------+
//|                   04_SignalGeneration_06_ConfluenceTest.mqh    |
//|                    SONIC R MC - CONFLUENCE ENGINE TEST         |
//|                    Test v� validation cho Confluence Engine    |
//+------------------------------------------------------------------+
#ifndef CONFLUENCE_TEST_MQH
#define CONFLUENCE_TEST_MQH

#include "01_Core_22_SonicEnums.mqh"
#include "01_Core_07_CommonStructures.mqh"
#include "04_SignalGeneration_02_ConfluenceEngine.mqh"
#include "04_SignalGeneration_03_ScenarioManager.mqh"
#include "04_SignalGeneration_04_ScenarioConfig.mqh"
// SYSTEMATIC FIX - File removed by Boss, use direct implementation
// #include "04_SignalGeneration_07_ScenarioPerformance.mqh"

//+------------------------------------------------------------------+
//| CONFLUENCE ENGINE TEST CLASS                                    |
//+------------------------------------------------------------------+
class CConfluenceTest {
private:
    CConfluenceEngine* m_confluenceEngine;
    CScenarioManager* m_scenarioManager;
    CScenarioConfig* m_config;
    CScenarioPerformance* m_performance;
    
    // Test results
    int m_totalTests;
    int m_passedTests;
    int m_failedTests;
    
public:
    CConfluenceTest() {
        m_confluenceEngine = new CConfluenceEngine();
        m_scenarioManager = new CScenarioManager();
        m_config = new CScenarioConfig();
        m_performance = new CScenarioPerformance();
        
        m_totalTests = 0;
        m_passedTests = 0;
        m_failedTests = 0;
        
        Print("?? Confluence Test Suite initialized");
    }
    
    ~CConfluenceTest() {
        if(m_confluenceEngine != NULL) {
            delete m_confluenceEngine;
            m_confluenceEngine = NULL;
        }
        
        if(m_scenarioManager != NULL) {
            delete m_scenarioManager;
            m_scenarioManager = NULL;
        }
        
        if(m_config != NULL) {
            delete m_config;
            m_config = NULL;
        }
        
        if(m_performance != NULL) {
            delete m_performance;
            m_performance = NULL;
        }
        
        Print("?? Confluence Test Suite cleaned up");
    }
    
    // Main test methods
    bool RunAllTests() {
        Print("?? Starting Confluence Engine Test Suite...");
        Print("-------------------------------------------");
        
        bool allPassed = true;
        
        // Test individual components
        allPassed &= TestConfluenceEngine();
        allPassed &= TestScenarioManager();
        allPassed &= TestScenarioConfig();
        allPassed &= TestPerformanceTracking();
        
        // Print final results
        PrintTestResults();
        
        return allPassed;
    }
    
    bool TestConfluenceEngine() {
        Print("?? Testing Confluence Engine...");
        
        bool result = true;
        
        // Test 1: Basic confluence calculation
        result &= TestBasicConfluenceCalculation();
        
        // Test 2: Analyze confluence with scenario
        // SEnhancedSignalData testData = {};
SEnhancedSignalData confluenceResult;
confluenceResult = m_confluenceEngine.AnalyzeConfluence(NULL, SCENARIO_SONIC_R_BASIC);
LogTest("Analyze Confluence", confluenceResult.confluenceScore >= 0.0, 
                StringFormat("Confluence: %.2f%%, Signal: %d", confluenceResult.confluenceScore * 100, (int)confluenceResult.signalType));
        
        // Test 3: Entry/exit levels from result
        LogTest("Entry/Exit Levels", 
                confluenceResult.entryPrice > 0 && confluenceResult.stopLoss > 0 && confluenceResult.takeProfit > 0,
                StringFormat("Entry: %.5f, SL: %.5f, TP: %.5f", confluenceResult.entryPrice, confluenceResult.stopLoss, confluenceResult.takeProfit));
        
        return result;
    }
    
    bool TestScenarioManager() {
        Print("?? Testing Scenario Manager...");
        
        bool result = true;
        
        // Test 1: Scenario switching
        result &= TestScenarioSwitching();
        
        // Test 2: Current scenario
        ENUM_TRADING_SCENARIO current = m_scenarioManager.GetCurrentScenario();
        LogTest("Get Current Scenario", current >= 0 && current < 5,
                StringFormat("Current: %d", (int)current));
        
        // Test 3: Scenario evaluation
        ENUM_TRADING_SCENARIO recommended = m_scenarioManager.EvaluateAndRecommendScenario();
        LogTest("Evaluate Scenarios", recommended >= 0 && recommended < 5,
                StringFormat("Recommended: %d", (int)recommended));
        
        return result;
    }
    
    bool TestScenarioConfig() {
        Print("?? Testing Scenario Config...");
        
        bool result = true;
        
        // Test configuration validation
        result &= TestConfigValidation();
        
        // Test getting config for each scenario
        for(int i = 0; i < 5; i++) {
            SScenarioConfig config;
config = m_config.GetConfig((ENUM_TRADING_SCENARIO)i);
            LogTest(StringFormat("Config Scenario %d", i+1), 
                    config.name != "" && config.minConfluenceScore > 0,
                    StringFormat("Name: %s, MinConfluence: %.1f", config.name, config.minConfluenceScore));
        }
        
        return result;
    }
    
    bool TestPerformanceTracking() {
        Print("?? Testing Performance Tracking...");
        
        bool result = true;
        
        // Test performance metrics
        result &= TestPerformanceMetrics();
        
        // Test adding sample trades
        STradeRecord trade;
        trade.openTime = TimeCurrent() - 3600;
        trade.closeTime = TimeCurrent();
        trade.orderType = ORDER_TYPE_BUY;
        trade.openPrice = 1.1000;
        trade.closePrice = 1.1050;
        trade.volume = 0.1;
        trade.profit = 50.0;
        trade.confluence = 85.0;
        trade.reason = "Test trade";
        trade.isWin = true;
        
        m_performance.AddTrade(SCENARIO_SONIC_R_BASIC, trade);
        
        SScenarioPerformance perf;
perf = m_performance.GetPerformance(SCENARIO_SONIC_R_BASIC);
        LogTest("Add Trade", perf.totalTrades > 0,
                StringFormat("Total trades: %d, Net P&L: %.2f", perf.totalTrades, perf.netProfit));
        
        return result;
    }
    
    // Individual test cases
    bool TestBasicConfluenceCalculation() {
        SEnhancedSignalData result;
result = m_confluenceEngine.AnalyzeConfluence(NULL, SCENARIO_SONIC_R_BASIC);
        
        LogTest("Basic Confluence Calculation", 
                result.confluenceScore >= 0.0 && result.confluenceScore <= 1.0,
                StringFormat("Confluence: %.2f%%", result.confluenceScore * 100));
        
        return (result.confluenceScore >= 0.0 && result.confluenceScore <= 1.0);
    }
    
    bool TestScenarioSwitching() {
        ENUM_TRADING_SCENARIO original = m_scenarioManager.GetCurrentScenario();
        
        // Try to switch to different scenario
        ENUM_TRADING_SCENARIO newScenario = (original == SCENARIO_SONIC_R_BASIC) ?
                                           SCENARIO_SONIC_R_PVSRA_ENHANCED : SCENARIO_SONIC_R_BASIC;

        m_scenarioManager.SwitchToScenario(newScenario);
        bool switched = true;
        ENUM_TRADING_SCENARIO current = m_scenarioManager.GetCurrentScenario();
        
        LogTest("Scenario Switching", switched && current == newScenario,
                StringFormat("Switched from %d to %d", (int)original, (int)current));
        
        return switched && current == newScenario;
    }
    
    bool TestPerformanceMetrics() {
        // Add some sample trades for testing
        for(int i = 0; i < 5; i++) {
            STradeRecord trade;
            trade.openTime = TimeCurrent() - (3600 * (i + 1));
            trade.closeTime = TimeCurrent() - (3600 * i);
            trade.orderType = (i % 2 == 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
            trade.openPrice = 1.1000 + (i * 0.001);
            trade.closePrice = trade.openPrice + ((i % 2 == 0) ? 0.0050 : -0.0025);
            trade.volume = 0.1;
            trade.profit = (i % 2 == 0) ? 50.0 : -25.0;
            trade.confluence = 70.0 + (i * 2);
            trade.reason = StringFormat("Test trade %d", i + 1);
            trade.isWin = (i % 2 == 0);
            
            m_performance.AddTrade(SCENARIO_SONIC_R_BASIC, trade);
        }
        
        SScenarioPerformance perf;
perf = m_performance.GetPerformance(SCENARIO_SONIC_R_BASIC);
        
        LogTest("Performance Metrics", 
                perf.totalTrades == 5 && perf.winningTrades == 3 && perf.losingTrades == 2,
                StringFormat("Trades: %d, Wins: %d, Losses: %d, WinRate: %.1f%%", 
                            perf.totalTrades, perf.winningTrades, perf.losingTrades, perf.winRate));
        
        return (perf.totalTrades == 5 && perf.winningTrades == 3);
    }
    
    bool TestConfigValidation() {
        bool allValid = true;
        
        for(int i = 0; i < 5; i++) {
            SScenarioConfig config;
config = m_config.GetConfig((ENUM_TRADING_SCENARIO)i);
            bool valid = m_config.ValidateConfig(config);
            
            LogTest(StringFormat("Config Validation %d", i+1), valid,
                    StringFormat("Scenario: %s", config.name));
            
            allValid &= valid;
        }
        
        return allValid;
    }
    
    // Helper methods
    void PrintTestResults() {
        Print("-------------------------------------------");
        Print("?? TEST RESULTS SUMMARY");
        Print("-------------------------------------------");
        Print(StringFormat("?? Total Tests: %d", m_totalTests));
        Print(StringFormat("? Passed: %d", m_passedTests));
        Print(StringFormat("? Failed: %d", m_failedTests));
        Print(StringFormat("?? Success Rate: %.1f%%", 
              m_totalTests > 0 ? (double)m_passedTests / m_totalTests * 100.0 : 0.0));
        
        if(m_failedTests == 0) {
            Print("?? ALL TESTS PASSED! Confluence Engine is ready for production.");
        } else {
            Print("?? Some tests failed. Please review and fix issues before deployment.");
        }
        
        Print("-------------------------------------------");
    }
    
    void LogTest(string testName, bool result, string details = "") {
        m_totalTests++;
        
        if(result) {
            m_passedTests++;
            Print(StringFormat("? %s - PASSED %s", testName, details));
        } else {
            m_failedTests++;
            Print(StringFormat("? %s - FAILED %s", testName, details));
        }
    }
    
    SConfluenceData CreateTestConfluenceData() { // NOTE: legacy test stub; not used by SEnhancedSignalData
        SConfluenceData data;
        // Manual reset since struct doesn't have Reset() method
        
        // Core Components (using actual SConfluenceData members)
        data.dragonBandScore = 0.75;      // 75%
        data.pvsraScore = 0.80;           // 80%
        data.waveScore = 0.70;            // 70%
        data.smcScore = 0.85;             // 85%
        data.momentumScore = 0.90;        // 90%
        data.overallScore = 0.75;         // 75%
        data.isValid = true;
        data.timestamp = TimeCurrent();
        
        return data;
    }
};



#endif // CONFLUENCE_TEST_MQH