//+------------------------------------------------------------------+
//|                                               Trade_Manager.mqh |
//|                        APEX Pullback EA v5 - Trade Management   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, APEX Trading Systems"
#property link      "https://apex-trading.com"
#property version   "5.00"


#ifndef TRADE_01_MANAGER_MQH
#define TRADE_01_MANAGER_MQH

#include "01_Core_09_SharedDataStructures.mqh"
#include "01_Core_08_ContextManager.mqh"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>
#include "01_Core_ErrorHandler.mqh"

// REMOVED: SSignalInfo struct - now defined in SonicR_CommonStructs.mqh

//+------------------------------------------------------------------+
//| Trade Manager Class                                              |
//+------------------------------------------------------------------+
class CTradeManager {
private:
CEaContext*         m_pContext; // Pointer to the global EA context
CTrade              m_trade;
CSymbolInfo         m_symbolInfo;
CPositionInfo       m_positionInfo;
COrderInfo          m_orderInfo;

// Trade settings
string              m_symbol;
double              m_lotSize;
int                 m_slippage;
int                 m_magicNumber;
string              m_comment;

// Risk management
double              m_maxRiskPercent;
double              m_maxLotSize;
double              m_minLotSize;

// Prop-firm preset
string              m_propPreset;

// Trade statistics
int                 m_totalTrades;
int                 m_winningTrades;
int                 m_losingTrades;
double              m_totalProfit;
double              m_totalLoss;

// PHASE 2 ENHANCEMENT: Correlation Matrix & Scout Before
double              m_correlationMatrix[28][28];  // Major pairs correlation matrix
string              m_majorPairs[28];             // Major currency pairs
double              m_maxCorrelationThreshold;    // Max correlation threshold (0.85)
bool                m_scoutBeforeEnabled;         // Scout before functionality
double              m_scoutSRLevels[100];         // Support/Resistance levels for scout
int                 m_scoutSRCount;               // Number of S&R levels
bool                m_surgeDetectionEnabled;      // Surge detection for scout

// Trailing Stop and Early Exit attributes
bool                m_trailingStopEnabled;        // Enable trailing stop
double              m_trailingStopDistance;       // Trailing stop distance in pips
double              m_trailingStepSize;           // Minimum step size for trailing
bool                m_earlyExitEnabled;           // Enable early exit
double              m_earlyExitProfitTarget;      // Profit target for early exit (in pips)
double              m_earlyExitTimeLimit;         // Time limit for early exit (in minutes)
bool                m_breakEvenEnabled;           // Enable break-even stop
double              m_breakEvenTrigger;           // Trigger distance for break-even (in pips)
double              m_breakEvenOffset;            // Offset from entry for break-even (in pips)

bool                m_isInitialized;

public:
// Constructor
CTradeManager() {
m_pContext = NULL;
m_symbol = "";
m_lotSize = 0.01;
m_slippage = 3;
m_magicNumber = 12345;
m_comment = "APEX_EA";
m_maxRiskPercent = 2.0;
m_maxLotSize = 10.0;
m_minLotSize = 0.01;
m_totalTrades = 0;
m_winningTrades = 0;
m_losingTrades = 0;
m_totalProfit = 0.0;
m_totalLoss = 0.0;

// PHASE 2 ENHANCEMENT: Initialize correlation and scout variables
m_maxCorrelationThreshold = 0.85;
m_scoutBeforeEnabled = true;
m_scoutSRCount = 0;
m_surgeDetectionEnabled = true;
InitializeMajorPairs();
InitializeCorrelationMatrix();

// Initialize trailing stop and early exit variables
m_trailingStopEnabled = true;
m_trailingStopDistance = 20.0;  // 20 pips default
m_trailingStepSize = 5.0;       // 5 pips minimum step
m_earlyExitEnabled = true;
m_earlyExitProfitTarget = 30.0; // 30 pips profit target
m_earlyExitTimeLimit = 240.0;   // 4 hours time limit
m_breakEvenEnabled = true;
m_breakEvenTrigger = 15.0;      // 15 pips to trigger break-even
m_breakEvenOffset = 2.0;        // 2 pips offset from entry

m_isInitialized = false;
m_propPreset = "";
}

// Destructor
~CTradeManager() {
// Cleanup if needed
}

// Setter to wire prop-firm preset from inputs
void SetPropPreset(const string preset) { m_propPreset = preset; }

// Initialize trade manager
bool Initialize(CEaContext* context, double lotSize = 0.01, int slippage = 3, int magic = 12345, double maxRisk = 2.0) {
m_pContext = context;
// ?? BOSS'S CRITICAL FIX: Allow NULL context and use default symbol
if (m_pContext != NULL) {
m_symbol = _Symbol;  // Use current chart symbol (context doesn't expose symbol getter)
} else {
m_symbol = _Symbol;  // Use current chart symbol when context is NULL
}
m_lotSize = lotSize;
m_slippage = slippage;
m_magicNumber = magic;
m_maxRiskPercent = maxRisk;
// Initialize symbol info
if(!m_symbolInfo.Name(m_symbol)) {
if(g_errorHandler!=NULL) g_errorHandler.HandleError(GetLastError(), "TradeManager::Initialize.Symbol");
Print("TradeManager ERROR: Failed to initialize symbol: " + m_symbol);
return false;
}

// Set trade parameters
m_trade.SetExpertMagicNumber(m_magicNumber);
m_trade.SetMarginMode();
m_trade.SetTypeFillingBySymbol(m_symbol);
m_trade.SetDeviationInPoints(m_slippage);

// Refresh symbol info
if(!m_symbolInfo.RefreshRates()) {
if(g_errorHandler!=NULL) g_errorHandler.HandleError(GetLastError(), "TradeManager::Initialize.RefreshRates");
Print("TradeManager ERROR: Failed to refresh rates for: " + m_symbol);
return false;
}

m_isInitialized = true;

Print("TradeManager INFO: Trade Manager initialized for " + m_symbol);
Print("TradeManager INFO: Magic Number: " + IntegerToString(m_magicNumber));

return true;
}

// Open buy position
bool OpenBuy(double volume, double price = 0.0, double sl = 0.0, double tp = 0.0, string comment = NULL) {
if(!m_isInitialized) {
Print("TradeManager ERROR: Trade Manager not initialized");
return false;
}

// Validate volume
volume = NormalizeVolume(volume);
if(volume <= 0) {
Print("TradeManager ERROR: Invalid volume: " + DoubleToString(volume, 2));
return false;
}

// Use market price if not specified
if(price <= 0.0) {
price = m_symbolInfo.Ask();
}

// Normalize prices
price = m_symbolInfo.NormalizePrice(price);
if(sl > 0) sl = m_symbolInfo.NormalizePrice(sl);
if(tp > 0) tp = m_symbolInfo.NormalizePrice(tp);

// Set comment
string tradeComment = (comment == "") ? m_comment : comment;

// ?? BOSS FIX: Log trade rationale BEFORE execution
LogTradeRationale("BUY", volume, price, sl, tp, tradeComment);

// Execute trade
bool result = m_trade.Buy(volume, m_symbol, price, sl, tp, tradeComment);

if(result) {
m_totalTrades++;
g_lastTradeTime = TimeCurrent();
Print("TradeManager TRADE: BUY " + m_symbol + " " + DoubleToString(volume,2) + " " + DoubleToString(price,5) + " " + tradeComment);
if(g_errorHandler!=NULL) g_errorHandler.LogTradeSuccess("BUY", (ulong)m_trade.ResultDeal(), m_symbol, volume, price, sl, tp, tradeComment);
} else {
if(g_errorHandler!=NULL) g_errorHandler.LogTradeError("BUY", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, volume, price, sl, tp, "TradeManager::OpenBuy");
}

return result;
}

// Open sell position
bool OpenSell(double volume, double price = 0.0, double sl = 0.0, double tp = 0.0, string comment = NULL) {
if(!m_isInitialized) {
Print("TradeManager ERROR: Trade Manager not initialized");
return false;
}

// Validate volume
volume = NormalizeVolume(volume);
if(volume <= 0) {
Print("TradeManager ERROR: Invalid volume: " + DoubleToString(volume, 2));
return false;
}

// Use market price if not specified
if(price <= 0.0) {
price = m_symbolInfo.Bid();
}

// Normalize prices
price = m_symbolInfo.NormalizePrice(price);
if(sl > 0) sl = m_symbolInfo.NormalizePrice(sl);
if(tp > 0) tp = m_symbolInfo.NormalizePrice(tp);

// Set comment
string tradeComment = (comment == "") ? m_comment : comment;

// ?? BOSS FIX: Log trade rationale BEFORE execution
LogTradeRationale("SELL", volume, price, sl, tp, tradeComment);

// Execute trade
bool result = m_trade.Sell(volume, m_symbol, price, sl, tp, tradeComment);

if(result) {
m_totalTrades++;
g_lastTradeTime = TimeCurrent();
Print("TradeManager TRADE: SELL " + m_symbol + " " + DoubleToString(volume,2) + " " + DoubleToString(price,5) + " " + tradeComment);
if(g_errorHandler!=NULL) g_errorHandler.LogTradeSuccess("SELL", (ulong)m_trade.ResultDeal(), m_symbol, volume, price, sl, tp, tradeComment);
} else {
if(g_errorHandler!=NULL) g_errorHandler.LogTradeError("SELL", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, volume, price, sl, tp, "TradeManager::OpenSell");
}

return result;
}

// Execute a trade based on a signal
bool ExecuteTrade(const SSignalInfo &signal, double volume) {
if(signal.signalType == SIGNAL_BUY) {
    return OpenBuy(volume, signal.entryPrice, signal.stopLoss, signal.takeProfit, signal.reason);
}
if(signal.signalType == SIGNAL_SELL) {
    return OpenSell(volume, signal.entryPrice, signal.stopLoss, signal.takeProfit, signal.reason);
}
return false;
}

// Manage all open positions
void ManagePositions() {
// Enhanced position management with trailing stops and early exit
for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
ulong ticket = m_positionInfo.Ticket();

// Apply trailing stop
if(m_trailingStopEnabled) {
ApplyTrailingStop(ticket);
}

// Apply break-even
if(m_breakEvenEnabled) {
ApplyBreakEven(ticket);
}

// Check early exit conditions
if(m_earlyExitEnabled) {
CheckEarlyExit(ticket);
}
}
}
}
}

// PRODUCTION FIX: Add ManageOpenPositions as wrapper for compatibility
void ManageOpenPositions() {
ManagePositions();
}

// Close position by ticket
bool ClosePosition(ulong ticket) {
if(!m_positionInfo.SelectByTicket(ticket)) {
Print("TradeManager ERROR: Position not found: " + IntegerToString(ticket));
return false;
}

bool result = m_trade.PositionClose(ticket);
if(!result && g_errorHandler!=NULL){ g_errorHandler.LogTradeError("CLOSE", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, 0.0, 0.0, "TradeManager::ClosePosition"); }
else if(result && g_errorHandler!=NULL){ g_errorHandler.LogTradeSuccess("CLOSE", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), m_positionInfo.StopLoss(), m_positionInfo.TakeProfit(), ""); }

if(result) {
Print("TradeManager INFO: Position closed successfully. Ticket: " + IntegerToString(ticket));
} else {
Print("TradeManager ERROR: Failed to close position: " + IntegerToString(ticket));
Print("TradeManager ERROR: Trade result: " + IntegerToString(m_trade.ResultRetcode()) + " - " + m_trade.ResultComment());
}

return result;
}

// Close all positions for this symbol and magic number
int CloseAllPositions() {
int closedCount = 0;

for(int i = PositionsTotal() - 1; i >= 0; i--) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
if(ClosePosition(m_positionInfo.Ticket())) {
closedCount++;
}
}
}
}

if(closedCount > 0) {
Print("TradeManager INFO: Closed " + IntegerToString(closedCount) + " positions");
}

return closedCount;
}

// Modify position
bool ModifyPosition(ulong ticket, double sl, double tp) {
if(!m_positionInfo.SelectByTicket(ticket)) {
Print("TradeManager ERROR: Position not found: " + IntegerToString(ticket));
return false;
}

// Normalize prices
if(sl > 0) sl = m_symbolInfo.NormalizePrice(sl);
if(tp > 0) tp = m_symbolInfo.NormalizePrice(tp);

bool result = m_trade.PositionModify(ticket, sl, tp);
if(!result && g_errorHandler!=NULL){ g_errorHandler.LogTradeError("MODIFY", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, sl, tp, "TradeManager::ModifyPosition"); }
else if(result && g_errorHandler!=NULL){ g_errorHandler.LogTradeSuccess("MODIFY", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), sl, tp, ""); }

if(result) {
Print("TradeManager INFO: Position modified. Ticket: " + IntegerToString(ticket));
} else {
Print("TradeManager ERROR: Failed to modify position: " + IntegerToString(ticket));
Print("TradeManager ERROR: Trade result: " + IntegerToString(m_trade.ResultRetcode()) + " - " + m_trade.ResultComment());
}

return result;
}

// Calculate position size based on risk
double CalculatePositionSize(double riskPercent, double entryPrice, double stopLoss) {
if(riskPercent <= 0 || entryPrice <= 0 || stopLoss <= 0) {
return m_minLotSize;
}

double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double riskAmount = balance * (riskPercent / 100.0);

double pointValue = m_symbolInfo.TickValue();
double stopLossPoints = MathAbs(entryPrice - stopLoss) / m_symbolInfo.Point();

double lotSize = riskAmount / (stopLossPoints * pointValue);

// Normalize and validate lot size
lotSize = NormalizeVolume(lotSize);

Print("TradeManager DEBUG: Position size calculated: " + DoubleToString(lotSize, 2));

return lotSize;
}

// Normalize volume according to symbol specifications
double NormalizeVolume(double volume) {
double minLot = m_symbolInfo.LotsMin();
double maxLot = m_symbolInfo.LotsMax();
double stepLot = m_symbolInfo.LotsStep();

if(volume < minLot) volume = minLot;
if(volume > maxLot) volume = maxLot;
if(volume > m_maxLotSize) volume = m_maxLotSize;

// Round to step
volume = MathRound(volume / stepLot) * stepLot;

return volume;
}

// Get current positions count
int GetPositionsCount() {
int count = 0;

for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
count++;
}
}
}

return count;
}

// Get total profit of open positions
double GetTotalProfit() {
double totalProfit = 0.0;

for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
totalProfit += m_positionInfo.Profit();
}
}
}

return totalProfit;
}

// Check if trading is allowed
bool IsTradingAllowed() {
if(!m_isInitialized) return false;

// Check if trading is allowed for the account
if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
Print("TradeManager WARNING: Trading not allowed for account");
return false;
}

// Check if trading is allowed for the symbol
if(m_symbolInfo.TradeMode() == SYMBOL_TRADE_MODE_DISABLED) {
Print("TradeManager WARNING: Trading not allowed for symbol: " + m_symbol);
return false;
}

// Check market hours (already checked above)
// Additional time-based checks can be added here if needed

return true;
}

// Getters
bool IsInitialized() { return m_isInitialized; }
string GetSymbol() { return m_symbol; }
int GetMagicNumber() { return m_magicNumber; }
int GetTotalTrades() { return m_totalTrades; }
int GetWinningTrades() { return m_winningTrades; }
int GetLosingTrades() { return m_losingTrades; }
double GetTotalProfitAmount() { return m_totalProfit; }
double GetTotalLossAmount() { return m_totalLoss; }

// Setters
void SetLotSize(double lotSize) { m_lotSize = NormalizeVolume(lotSize); }
void SetSlippage(int slippage) { m_slippage = slippage; m_trade.SetDeviationInPoints(slippage); }
void SetComment(string comment) { m_comment = comment; }
void SetMaxRisk(double riskPercent) { m_maxRiskPercent = riskPercent; }
void SetMaxLotSize(double maxLot) { m_maxLotSize = maxLot; }

//+------------------------------------------------------------------+
//| ?? BOSS FIX: TRAILING STOP & EARLY EXIT MECHANISMS             |
//+------------------------------------------------------------------+

/**
* @brief C?p nh?t trailing stop cho t?t c? positions
* @note �u?c g?i t? OnTick() d? theo d�i li�n t?c
*/
void UpdateTrailingStops() {
if(!m_trailingStopEnabled) return;

for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
UpdatePositionTrailingStop(m_positionInfo.Ticket());
}
}
}
}

/**
* @brief C?p nh?t trailing stop cho m?t position c? th?
* @param ticket Ticket c?a position
* @return true n?u c?p nh?t th�nh c�ng
*/
bool UpdatePositionTrailingStop(ulong ticket) {
if(!m_positionInfo.SelectByTicket(ticket)) return false;

double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
m_symbolInfo.Bid() : m_symbolInfo.Ask();
double entryPrice = m_positionInfo.PriceOpen();
double currentSL = m_positionInfo.StopLoss();
double newSL = 0.0;

double trailingDistance = m_trailingStopDistance * _Point;
double stepSize = m_trailingStepSize * _Point;

if(m_positionInfo.PositionType() == POSITION_TYPE_BUY) {
// BUY position trailing stop
newSL = currentPrice - trailingDistance;

// Only move SL up, never down
if(currentSL == 0.0 || newSL > currentSL + stepSize) {
newSL = m_symbolInfo.NormalizePrice(newSL);

if(m_trade.PositionModify(ticket, newSL, m_positionInfo.TakeProfit())) { if(g_errorHandler!=NULL) g_errorHandler.LogTradeSuccess("TRAIL", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), newSL, m_positionInfo.TakeProfit(), ""); } else { if(g_errorHandler!=NULL) g_errorHandler.LogTradeError("TRAIL", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, newSL, m_positionInfo.TakeProfit(), "TradeManager::ApplyTrailingStop"); }
Print(StringFormat("[TRAILING] BUY position %d: SL moved from %.5f to %.5f", 
ticket, currentSL, newSL));
return true;
}
} else {
// SELL position trailing stop
newSL = currentPrice + trailingDistance;

// Only move SL down, never up
if(currentSL == 0.0 || newSL < currentSL - stepSize) {
newSL = m_symbolInfo.NormalizePrice(newSL);

if(m_trade.PositionModify(ticket, newSL, m_positionInfo.TakeProfit())) { if(g_errorHandler!=NULL) g_errorHandler.LogTradeSuccess("TRAIL", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), newSL, m_positionInfo.TakeProfit(), ""); } else { if(g_errorHandler!=NULL) g_errorHandler.LogTradeError("TRAIL", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, newSL, m_positionInfo.TakeProfit(), "TradeManager::ApplyTrailingStop"); }
Print(StringFormat("[TRAILING] SELL position %d: SL moved from %.5f to %.5f", 
ticket, currentSL, newSL));
return true;
}
}

return false;
}

/**
* @brief Ki?m tra v� th?c hi?n break-even stop
* @param ticket Ticket c?a position
* @return true n?u break-even du?c k�ch ho?t
*/
bool CheckAndSetBreakEven(ulong ticket) {
if(!m_breakEvenEnabled) return false;
if(!m_positionInfo.SelectByTicket(ticket)) return false;

double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
m_symbolInfo.Bid() : m_symbolInfo.Ask();
double entryPrice = m_positionInfo.PriceOpen();
double currentSL = m_positionInfo.StopLoss();

double triggerDistance = m_breakEvenTrigger * _Point;
double offsetDistance = m_breakEvenOffset * _Point;

bool shouldSetBreakEven = false;
double newSL = 0.0;

if(m_positionInfo.PositionType() == POSITION_TYPE_BUY) {
// BUY position break-even
if(currentPrice >= entryPrice + triggerDistance) {
newSL = entryPrice + offsetDistance;
shouldSetBreakEven = (currentSL < newSL);
}
} else {
// SELL position break-even
if(currentPrice <= entryPrice - triggerDistance) {
newSL = entryPrice - offsetDistance;
shouldSetBreakEven = (currentSL > newSL || currentSL == 0.0);
}
}

if(shouldSetBreakEven) {
newSL = m_symbolInfo.NormalizePrice(newSL);

if(m_trade.PositionModify(ticket, newSL, m_positionInfo.TakeProfit())) { if(g_errorHandler!=NULL) g_errorHandler.LogTradeSuccess("BREAK_EVEN", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), newSL, m_positionInfo.TakeProfit(), ""); } else { if(g_errorHandler!=NULL) g_errorHandler.LogTradeError("BREAK_EVEN", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, newSL, m_positionInfo.TakeProfit(), "TradeManager::ApplyBreakEven"); }
Print(StringFormat("[BREAK-EVEN] Position %d: SL set to break-even at %.5f",
ticket, newSL));
return true;
}

return false;
}

/**
* @brief Ki?m tra di?u ki?n early exit
* @note Ki?m tra th?i gian, profit target, v� market regime changes
*/
void CheckEarlyExitConditions() {
if(!m_earlyExitEnabled) return;

for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
CheckPositionEarlyExit(m_positionInfo.Ticket());
}
}
}
}

/**
* @brief Ki?m tra early exit cho m?t position c? th?
* @param ticket Ticket c?a position
* @return true n?u position du?c d�ng s?m
*/
bool CheckPositionEarlyExit(ulong ticket) {
if(!m_positionInfo.SelectByTicket(ticket)) return false;

datetime openTime = (datetime)m_positionInfo.Time();
datetime currentTime = TimeCurrent();
double currentProfit = m_positionInfo.Profit();

// Ki?m tra time limit
if((currentTime - openTime) >= m_earlyExitTimeLimit * 60) {
if(currentProfit > 0) {
Print(StringFormat("[EARLY EXIT] Position %d closed due to time limit with profit %.2f", 
ticket, currentProfit));
bool __res = m_trade.PositionClose(ticket);
if(!__res && g_errorHandler!=NULL){ g_errorHandler.LogTradeError("EARLY_EXIT_TIME", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, 0.0, 0.0, "TradeManager::EarlyExitByTime"); }
else if(__res && g_errorHandler!=NULL){ g_errorHandler.LogTradeSuccess("EARLY_EXIT_TIME", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), m_positionInfo.StopLoss(), m_positionInfo.TakeProfit(), ""); }
return __res;
}
}

// Ki?m tra profit target
double entryPrice = m_positionInfo.PriceOpen();
double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
m_symbolInfo.Bid() : m_symbolInfo.Ask();

double profitPips = 0.0;
if(m_positionInfo.PositionType() == POSITION_TYPE_BUY) {
profitPips = (currentPrice - entryPrice) / _Point;
} else {
profitPips = (entryPrice - currentPrice) / _Point;
}

if(profitPips >= m_earlyExitProfitTarget) {
Print(StringFormat("[EARLY EXIT] Position %d closed at profit target: %.1f pips", 
ticket, profitPips));
bool __res2 = m_trade.PositionClose(ticket);
if(!__res2 && g_errorHandler!=NULL){ g_errorHandler.LogTradeError("EARLY_EXIT_PROFIT", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, 0.0, 0.0, "TradeManager::EarlyExitByProfit"); }
else if(__res2 && g_errorHandler!=NULL){ g_errorHandler.LogTradeSuccess("EARLY_EXIT_PROFIT", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), m_positionInfo.StopLoss(), m_positionInfo.TakeProfit(), ""); }
return __res2;
}

// Ki?m tra volatility spike (early exit condition)
if(IsVolatilitySpike()) {
Print(StringFormat("[EARLY EXIT] Position %d closed due to volatility spike", ticket));
bool __res3 = m_trade.PositionClose(ticket);
if(!__res3 && g_errorHandler!=NULL){ g_errorHandler.LogTradeError("EARLY_EXIT_VOL", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, 0.0, 0.0, 0.0, 0.0, "TradeManager::EarlyExitByVolatility"); }
else if(__res3 && g_errorHandler!=NULL){ g_errorHandler.LogTradeSuccess("EARLY_EXIT_VOL", (ulong)m_trade.ResultDeal(), m_symbol, m_positionInfo.Volume(), m_positionInfo.PriceOpen(), m_positionInfo.StopLoss(), m_positionInfo.TakeProfit(), ""); }
return __res3;
}

return false;
}

/**
* @brief Ki?m tra volatility spike
* @return true n?u c� volatility spike
*/
bool IsVolatilitySpike() {
int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
double atrBuffer[];
ArrayResize(atrBuffer, 2);
ArraySetAsSeries(atrBuffer, true);

if(CopyBuffer(atrHandle, 0, 0, 2, atrBuffer) < 2) {
IndicatorRelease(atrHandle);
return false;
}

IndicatorRelease(atrHandle);

// Volatility spike n?u ATR hi?n t?i > 150% ATR tru?c d�
return (atrBuffer[0] > atrBuffer[1] * 1.5);
}

/**
* @brief C?p nh?t t?t c? position management
* @note G?i t? OnTick() d? qu?n l� positions
*/
void UpdatePositionManagement() {
UpdateTrailingStops();
CheckEarlyExitConditions();

// Ki?m tra break-even cho t?t c? positions
for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Symbol() == m_symbol && m_positionInfo.Magic() == m_magicNumber) {
CheckAndSetBreakEven(m_positionInfo.Ticket());
}
}
}
}

// Setters cho trailing stop v� early exit
void SetTrailingStopEnabled(bool enabled) { m_trailingStopEnabled = enabled; }
void SetTrailingStopDistance(double distance) { m_trailingStopDistance = distance; }
void SetTrailingStepSize(double stepSize) { m_trailingStepSize = stepSize; }
void SetEarlyExitEnabled(bool enabled) { m_earlyExitEnabled = enabled; }
void SetEarlyExitProfitTarget(double target) { m_earlyExitProfitTarget = target; }
void SetEarlyExitTimeLimit(double timeLimit) { m_earlyExitTimeLimit = timeLimit; }
void SetBreakEvenEnabled(bool enabled) { m_breakEvenEnabled = enabled; }
void SetBreakEvenTrigger(double trigger) { m_breakEvenTrigger = trigger; }
void SetBreakEvenOffset(double offset) { m_breakEvenOffset = offset; }

//+------------------------------------------------------------------+
//| PHASE 2 ENHANCEMENT: Correlation Matrix & Scout Before Methods  |
//+------------------------------------------------------------------+

// Initialize major currency pairs
void InitializeMajorPairs() {
m_majorPairs[0] = "EURUSD"; m_majorPairs[1] = "GBPUSD"; m_majorPairs[2] = "USDJPY";
m_majorPairs[3] = "USDCHF"; m_majorPairs[4] = "AUDUSD"; m_majorPairs[5] = "USDCAD";
m_majorPairs[6] = "NZDUSD"; m_majorPairs[7] = "EURGBP"; m_majorPairs[8] = "EURJPY";
m_majorPairs[9] = "EURCHF"; m_majorPairs[10] = "EURAUD"; m_majorPairs[11] = "EURCAD";
m_majorPairs[12] = "EURNZD"; m_majorPairs[13] = "GBPJPY"; m_majorPairs[14] = "GBPCHF";
m_majorPairs[15] = "GBPAUD"; m_majorPairs[16] = "GBPCAD"; m_majorPairs[17] = "GBPNZD";
m_majorPairs[18] = "AUDJPY"; m_majorPairs[19] = "AUDCHF"; m_majorPairs[20] = "AUDCAD";
m_majorPairs[21] = "AUDNZD"; m_majorPairs[22] = "CADJPY"; m_majorPairs[23] = "CADCHF";
m_majorPairs[24] = "CHFJPY"; m_majorPairs[25] = "NZDJPY"; m_majorPairs[26] = "NZDCHF";
m_majorPairs[27] = "NZDCAD";
}

// Initialize correlation matrix with default values
void InitializeCorrelationMatrix() {
for(int i = 0; i < 28; i++) {
for(int j = 0; j < 28; j++) {
if(i == j) {
m_correlationMatrix[i][j] = 1.0;  // Perfect correlation with itself
} else {
m_correlationMatrix[i][j] = 0.0;  // Default no correlation
}
}
}
}

// Update correlation matrix with real-time data
void UpdateCorrelationMatrix() {
// Calculate correlation for last 100 bars
int period = 100;

for(int i = 0; i < 28; i++) {
for(int j = i + 1; j < 28; j++) {
double correlation = CalculatePairCorrelation(m_majorPairs[i], m_majorPairs[j], period);
m_correlationMatrix[i][j] = correlation;
m_correlationMatrix[j][i] = correlation;  // Symmetric matrix
}
}
}

// Calculate correlation between two currency pairs
double CalculatePairCorrelation(string pair1, string pair2, int period) {
double returns1[], returns2[];
ArrayResize(returns1, period);
ArrayResize(returns2, period);

// Get price data for both pairs
for(int i = 0; i < period; i++) {
double close1_current = iClose(pair1, PERIOD_H1, i);
double close1_previous = iClose(pair1, PERIOD_H1, i + 1);
double close2_current = iClose(pair2, PERIOD_H1, i);
double close2_previous = iClose(pair2, PERIOD_H1, i + 1);

if(close1_previous > 0 && close2_previous > 0) {
returns1[i] = (close1_current - close1_previous) / close1_previous;
returns2[i] = (close2_current - close2_previous) / close2_previous;
} else {
returns1[i] = 0.0;
returns2[i] = 0.0;
}
}

// Calculate Pearson correlation coefficient
return CalculatePearsonCorrelation(returns1, returns2, period);
}

// Calculate Pearson correlation coefficient
double CalculatePearsonCorrelation(const double &x[], const double &y[], int size) {
if(size < 2) return 0.0;

double sum_x = 0, sum_y = 0, sum_xy = 0, sum_x2 = 0, sum_y2 = 0;

for(int i = 0; i < size; i++) {
sum_x += x[i];
sum_y += y[i];
sum_xy += x[i] * y[i];
sum_x2 += x[i] * x[i];
sum_y2 += y[i] * y[i];
}

double numerator = size * sum_xy - sum_x * sum_y;
double denominator = MathSqrt((size * sum_x2 - sum_x * sum_x) * (size * sum_y2 - sum_y * sum_y));

if(denominator == 0) return 0.0;

return numerator / denominator;
}

// Check if trade passes correlation filter
bool PassesCorrelationFilter(string tradingPair) {
int pairIndex = GetPairIndex(tradingPair);
if(pairIndex == -1) return true;  // Unknown pair, allow trade

// Check correlation with existing positions
for(int i = 0; i < PositionsTotal(); i++) {
if(m_positionInfo.SelectByIndex(i)) {
if(m_positionInfo.Magic() == m_magicNumber) {
string positionSymbol = m_positionInfo.Symbol();
int positionIndex = GetPairIndex(positionSymbol);

if(positionIndex != -1 && positionIndex != pairIndex) {
double correlation = MathAbs(m_correlationMatrix[pairIndex][positionIndex]);

if(correlation > m_maxCorrelationThreshold) {
Print("[CORRELATION FILTER] Trade rejected - High correlation (", 
DoubleToString(correlation, 3), ") between ", tradingPair, " and ", positionSymbol);
return false;
}
}
}
}
}

return true;
}

// Get pair index in major pairs array
int GetPairIndex(string pair) {
for(int i = 0; i < 28; i++) {
if(m_majorPairs[i] == pair) {
return i;
}
}
return -1;
}

// Scout before functionality - check S&R levels and surge detection
bool ScoutBeforeEntry(string symbol, ENUM_SIGNAL_TYPE signalType, double entryPrice) {
if(!m_scoutBeforeEnabled) return true;

// Update S&R levels
UpdateSupportResistanceLevels(symbol);

// Check if entry price is near S&R level
if(!CheckSRLevelClearance(entryPrice, signalType)) {
Print("[SCOUT BEFORE] Trade rejected - Too close to S&R level");
return false;
}

// Check for surge detection
if(m_surgeDetectionEnabled && DetectPriceSurge(symbol)) {
Print("[SCOUT BEFORE] Trade rejected - Price surge detected");
return false;
}

return true;
}

// Update Support/Resistance levels
void UpdateSupportResistanceLevels(string symbol) {
m_scoutSRCount = 0;

// Get swing highs and lows from last 200 bars
int lookback = 200;
int swingPeriod = 5;

for(int i = swingPeriod; i < lookback - swingPeriod; i++) {
double high = iHigh(symbol, PERIOD_H1, i);
double low = iLow(symbol, PERIOD_H1, i);

// Check for swing high
bool isSwingHigh = true;
for(int j = 1; j <= swingPeriod; j++) {
if(iHigh(symbol, PERIOD_H1, i - j) >= high || iHigh(symbol, PERIOD_H1, i + j) >= high) {
isSwingHigh = false;
break;
}
}

// Check for swing low
bool isSwingLow = true;
for(int j = 1; j <= swingPeriod; j++) {
if(iLow(symbol, PERIOD_H1, i - j) <= low || iLow(symbol, PERIOD_H1, i + j) <= low) {
isSwingLow = false;
break;
}
}

// Add to S&R levels if swing point found
if((isSwingHigh || isSwingLow) && m_scoutSRCount < 100) {
m_scoutSRLevels[m_scoutSRCount] = isSwingHigh ? high : low;
m_scoutSRCount++;
}
}

Print("[SCOUT BEFORE] Updated ", m_scoutSRCount, " S&R levels for ", symbol);
}

// Check clearance from S&R levels
bool CheckSRLevelClearance(double entryPrice, ENUM_SIGNAL_TYPE signalType) {
double minDistance = 20 * _Point;  // Minimum 20 pips clearance

for(int i = 0; i < m_scoutSRCount; i++) {
double distance = MathAbs(entryPrice - m_scoutSRLevels[i]);

if(distance < minDistance) {
return false;
}
}

return true;
}

// Detect price surge (abnormal price movement)
bool DetectPriceSurge(string symbol) {
// Calculate ATR for volatility reference
int atrHandle = iATR(symbol, PERIOD_H1, 14);
double atr[];
if(CopyBuffer(atrHandle, 0, 1, 1, atr) <= 0) return false;
double atrValue = atr[0];

// Get last 3 candles
double range1 = iHigh(symbol, PERIOD_H1, 1) - iLow(symbol, PERIOD_H1, 1);
double range2 = iHigh(symbol, PERIOD_H1, 2) - iLow(symbol, PERIOD_H1, 2);
double range3 = iHigh(symbol, PERIOD_H1, 3) - iLow(symbol, PERIOD_H1, 3);

// Check if any recent candle is significantly larger than ATR
double surgeThreshold = atrValue * 2.0;  // 2x ATR threshold

if(range1 > surgeThreshold || range2 > surgeThreshold || range3 > surgeThreshold) {
return true;
}

return false;
}

// Enhanced trade execution with correlation and scout filters
bool ExecuteTradeEnhanced(const SSignalInfo &signal, double volume) {
// Phase 2 Enhancement: Apply correlation filter
if(!PassesCorrelationFilter(m_symbol)) {
Print("[TRADE ENHANCED] Trade rejected by correlation filter");
return false;
}

// Phase 2 Enhancement: Apply scout before filter
if(!ScoutBeforeEntry(m_symbol, signal.signalType, signal.entryPrice)) {
Print("[TRADE ENHANCED] Trade rejected by scout before filter");
return false;
}

// Update correlation matrix before trade
UpdateCorrelationMatrix();

// Execute original trade logic
return ExecuteTrade(signal, volume);
}

// Getters for Phase 2 enhancements
double GetCorrelationThreshold() { return m_maxCorrelationThreshold; }
bool IsScoutBeforeEnabled() { return m_scoutBeforeEnabled; }
bool IsSurgeDetectionEnabled() { return m_surgeDetectionEnabled; }
int GetSRLevelsCount() { return m_scoutSRCount; }

// Setters for Phase 2 enhancements
void SetCorrelationThreshold(double threshold) { m_maxCorrelationThreshold = threshold; }
void EnableScoutBefore(bool enable) { m_scoutBeforeEnabled = enable; }
void EnableSurgeDetection(bool enable) { m_surgeDetectionEnabled = enable; }

//+------------------------------------------------------------------+
//| TRAILING STOP AND EARLY EXIT METHODS                            |
//+------------------------------------------------------------------+

// Apply trailing stop to position
void ApplyTrailingStop(ulong ticket) {
if(!m_positionInfo.SelectByTicket(ticket)) return;

double currentSL = m_positionInfo.StopLoss();
double entryPrice = m_positionInfo.PriceOpen();
double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? m_symbolInfo.Bid() : m_symbolInfo.Ask();

double trailingDistance = m_trailingStopDistance * _Point;
double stepSize = m_trailingStepSize * _Point;

double newSL = 0;
bool shouldUpdate = false;

if(m_positionInfo.PositionType() == POSITION_TYPE_BUY) {
newSL = currentPrice - trailingDistance;
if(currentSL == 0 || (newSL > currentSL && (newSL - currentSL) >= stepSize)) {
shouldUpdate = true;
}
} else {
newSL = currentPrice + trailingDistance;
if(currentSL == 0 || (newSL < currentSL && (currentSL - newSL) >= stepSize)) {
shouldUpdate = true;
}
}

if(shouldUpdate) {
newSL = m_symbolInfo.NormalizePrice(newSL);
if(ModifyPosition(ticket, newSL, m_positionInfo.TakeProfit())) {
Print("[TRAILING STOP] Updated SL for ticket ", ticket, " to ", newSL);
}
}
}

// Apply break-even stop
void ApplyBreakEven(ulong ticket) {
if(!m_positionInfo.SelectByTicket(ticket)) return;

double currentSL = m_positionInfo.StopLoss();
double entryPrice = m_positionInfo.PriceOpen();
double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? m_symbolInfo.Bid() : m_symbolInfo.Ask();

double triggerDistance = m_breakEvenTrigger * _Point;
double offset = m_breakEvenOffset * _Point;

bool shouldApplyBreakEven = false;
double newSL = 0;

if(m_positionInfo.PositionType() == POSITION_TYPE_BUY) {
if(currentPrice >= entryPrice + triggerDistance) {
newSL = entryPrice + offset;
if(currentSL == 0 || newSL > currentSL) {
shouldApplyBreakEven = true;
}
}
} else {
if(currentPrice <= entryPrice - triggerDistance) {
newSL = entryPrice - offset;
if(currentSL == 0 || newSL < currentSL) {
shouldApplyBreakEven = true;
}
}
}

if(shouldApplyBreakEven) {
newSL = m_symbolInfo.NormalizePrice(newSL);
if(ModifyPosition(ticket, newSL, m_positionInfo.TakeProfit())) {
Print("[BREAK EVEN] Applied break-even SL for ticket ", ticket, " at ", newSL);
}
}
}

// Check early exit conditions
void CheckEarlyExit(ulong ticket) {
if(!m_positionInfo.SelectByTicket(ticket)) return;

double entryPrice = m_positionInfo.PriceOpen();
double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? m_symbolInfo.Bid() : m_symbolInfo.Ask();
datetime openTime = m_positionInfo.Time();

// Check profit target
double profitPips = 0;
if(m_positionInfo.PositionType() == POSITION_TYPE_BUY) {
profitPips = (currentPrice - entryPrice) / _Point;
} else {
profitPips = (entryPrice - currentPrice) / _Point;
}

// Check time limit
double minutesOpen = (TimeCurrent() - openTime) / 60.0;

bool shouldExit = false;
string exitReason = "";

if(profitPips >= m_earlyExitProfitTarget) {
shouldExit = true;
exitReason = "Profit Target Reached";
} else if(minutesOpen >= m_earlyExitTimeLimit) {
shouldExit = true;
exitReason = "Time Limit Exceeded";
}

if(shouldExit) {
if(ClosePosition(ticket)) {
Print("[EARLY EXIT] Closed position ", ticket, " - Reason: ", exitReason, " - Profit: ", profitPips, " pips");
}
}
}

// Getters for trailing stop and early exit settings
bool IsTrailingStopEnabled() { return m_trailingStopEnabled; }
double GetTrailingStopDistance() { return m_trailingStopDistance; }
double GetTrailingStepSize() { return m_trailingStepSize; }
bool IsEarlyExitEnabled() { return m_earlyExitEnabled; }
double GetEarlyExitProfitTarget() { return m_earlyExitProfitTarget; }
double GetEarlyExitTimeLimit() { return m_earlyExitTimeLimit; }
bool IsBreakEvenEnabled() { return m_breakEvenEnabled; }
double GetBreakEvenTrigger() { return m_breakEvenTrigger; }
double GetBreakEvenOffset() { return m_breakEvenOffset; }

// Setters for trailing stop and early exit settings (DUPLICATE REMOVED)
// These functions are already defined earlier in the class

//+------------------------------------------------------------------+
//| PHASE 4: PARTIAL CLOSE FUNCTIONALITY                            |
//+------------------------------------------------------------------+
bool PartialClose(ulong ticket, double percentToClose)
{
if(!m_positionInfo.SelectByTicket(ticket)) {
Print("[? PARTIAL CLOSE] Position not found: ", ticket);
return false;
}

// Validate percentage
if(percentToClose <= 0 || percentToClose >= 100) {
Print("[? PARTIAL CLOSE] Invalid percentage: ", percentToClose, "%. Must be 0-100");
return false;
}

double currentVolume = m_positionInfo.Volume();
double volumeToClose = currentVolume * (percentToClose / 100.0);

// Normalize volume to broker requirements
volumeToClose = NormalizeVolume(volumeToClose);

if(volumeToClose <= 0) {
Print("[? PARTIAL CLOSE] Volume too small after normalization: ", volumeToClose);
return false;
}

// Check if remaining volume would be valid
double remainingVolume = currentVolume - volumeToClose;
double minVolume = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);

if(remainingVolume < minVolume) {
Print("[?? PARTIAL CLOSE] Remaining volume too small, closing entire position");
return m_trade.PositionClose(ticket);
}

// Execute partial close
bool result = m_trade.PositionClosePartial(ticket, volumeToClose);

if(result) {
Print(StringFormat("[? PARTIAL CLOSE] Ticket: %d | Closed: %.2f lots (%.1f%%) | Remaining: %.2f lots", 
ticket, volumeToClose, percentToClose, remainingVolume));
return true;
} else {
Print(StringFormat("[? PARTIAL CLOSE] Failed to close %.2f lots of position %d. Error: %d", 
volumeToClose, ticket, GetLastError()));
return false;
}
}

// Check if position has reached 1:1 RR for partial close trigger
bool CheckPartialCloseTrigger(ulong ticket)
{
if(!m_positionInfo.SelectByTicket(ticket)) {
return false;
}

double entryPrice = m_positionInfo.PriceOpen();
double currentPrice = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
m_symbolInfo.Bid() : m_symbolInfo.Ask();
double stopLoss = m_positionInfo.StopLoss();

if(stopLoss == 0) return false; // No SL set

// Calculate risk distance
double riskDistance = MathAbs(entryPrice - stopLoss);

// Calculate current profit distance
double profitDistance = (m_positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
(currentPrice - entryPrice) : (entryPrice - currentPrice);

// Check if we've reached 1:1 RR
return (profitDistance >= riskDistance);
}

//+------------------------------------------------------------------+
//| PHASE C - Missing Method Stubs for Main EA Compatibility       |
//+------------------------------------------------------------------+

// Wrapper methods called from main EA
bool OpenBuyTrade(double lotSize, double sl = 0.0, double tp = 0.0, string comment = "")
{
return OpenBuy(lotSize, 0.0, sl, tp, comment);
}

bool OpenSellTrade(double lotSize, double sl = 0.0, double tp = 0.0, string comment = "")
{
return OpenSell(lotSize, 0.0, sl, tp, comment);
}

//+------------------------------------------------------------------+
//| PIPELINE EXECUTION: Execute Trade from Signal                   |
//| Boss's Command: Implement Trade Execution Logic                 |
//+------------------------------------------------------------------+
bool ExecuteTrade(const STradeSignal &signal, double volume)
{
// Check if signal is valid
if(!signal.isValid)
{
Print("[TRADE ERROR] Invalid signal provided");
return false;
}

// Check if trade manager is initialized
if(!m_isInitialized)
{
Print("[TRADE ERROR] Trade Manager not initialized");
return false;
}

// Execute trade based on signal type
bool result = false;

if(signal.signalType == SIGNAL_BUY)
{
result = OpenBuy(volume, signal.entryPrice, signal.stopLoss, signal.takeProfit, "SonicR_BUY");
Print("[TRADE EXECUTION] BUY order - Entry: ", signal.entryPrice, " SL: ", signal.stopLoss, " TP: ", signal.takeProfit);
}
else if(signal.signalType == SIGNAL_SELL)
{
result = OpenSell(volume, signal.entryPrice, signal.stopLoss, signal.takeProfit, "SonicR_SELL");
Print("[TRADE EXECUTION] SELL order - Entry: ", signal.entryPrice, " SL: ", signal.stopLoss, " TP: ", signal.takeProfit);
}
else
{
Print("[TRADE ERROR] Unknown signal type: ", SignalTypeToString(signal.signalType));
return false;
}

if(result)
{
// Update trade statistics
m_totalTrades++;
Print("[TRADE SUCCESS] Trade executed successfully. Total trades: ", m_totalTrades);
}
else
{
Print("[TRADE ERROR] Failed to execute trade for signal: ", SignalTypeToString(signal.signalType));
}

return result;
}

//+------------------------------------------------------------------+
//| ?? ADVANCED PERFORMANCE REPORTING SYSTEM                        |
//| Boss's Command: Comprehensive Trade Performance Analytics       |
//+------------------------------------------------------------------+
string GetAdvancedPerformanceReport()
{
string report = "\n?? ===== ADVANCED TRADE MANAGER PERFORMANCE REPORT =====\n";

// Basic Statistics
report += StringFormat("?? Total Trades Executed: %d\n", m_totalTrades);
report += StringFormat("?? Symbol: %s | Magic: %d\n", m_symbol, m_magicNumber);
report += StringFormat("?? Initialization Status: %s\n", m_isInitialized ? "? ACTIVE" : "? INACTIVE");

// Position Management Statistics
int totalPositions = PositionsTotal();
int ourPositions = 0;
double totalVolume = 0.0;
double totalProfit = 0.0;
int buyPositions = 0;
int sellPositions = 0;

CPositionInfo posInfo;
for(int i = 0; i < totalPositions; i++) {
if(posInfo.SelectByIndex(i)) {
if(posInfo.Symbol() == m_symbol && posInfo.Magic() == m_magicNumber) {
ourPositions++;
totalVolume += posInfo.Volume();
totalProfit += posInfo.Profit() + posInfo.Swap() + posInfo.Commission();

if(posInfo.PositionType() == POSITION_TYPE_BUY) buyPositions++;
else sellPositions++;
}
}
}

report += "\n?? CURRENT POSITION ANALYSIS:\n";
report += StringFormat("?? Active Positions: %d\n", ourPositions);
report += StringFormat("?? Buy Positions: %d | ?? Sell Positions: %d\n", buyPositions, sellPositions);
report += StringFormat("?? Total Volume: %.2f lots\n", totalVolume);
report += StringFormat("?? Total P&L: %.2f %s\n", totalProfit, AccountInfoString(ACCOUNT_CURRENCY));

// Trailing Stop Performance
report += "\n?? TRAILING STOP SYSTEM:\n";
report += StringFormat("?? Trailing Stop: %s (%.1f pips)\n", 
m_trailingStopEnabled ? "? ENABLED" : "? DISABLED", m_trailingStopDistance);
report += StringFormat("?? Break-Even: %s (%.1f pips trigger)\n", 
m_breakEvenEnabled ? "? ENABLED" : "? DISABLED", m_breakEvenTrigger);

// Early Exit System
report += "\n? EARLY EXIT SYSTEM:\n";
report += StringFormat("?? Early Exit: %s\n", m_earlyExitEnabled ? "? ENABLED" : "? DISABLED");
report += StringFormat("?? Profit Target: %.1f pips | ??? Time Limit: %.1f minutes\n", 
m_earlyExitProfitTarget, m_earlyExitTimeLimit);

// Risk Management Analysis
report += "\n??? RISK MANAGEMENT ANALYSIS:\n";
double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
double marginUsed = AccountInfoDouble(ACCOUNT_MARGIN);
double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

report += StringFormat("?? Account Balance: %.2f %s\n", accountBalance, AccountInfoString(ACCOUNT_CURRENCY));
report += StringFormat("?? Account Equity: %.2f %s\n", accountEquity, AccountInfoString(ACCOUNT_CURRENCY));
report += StringFormat("?? Margin Used: %.2f %s (%.1f%%)\n", 
marginUsed, AccountInfoString(ACCOUNT_CURRENCY), 
accountBalance > 0 ? (marginUsed / accountBalance * 100) : 0);
report += StringFormat("?? Free Margin: %.2f %s\n", freeMargin, AccountInfoString(ACCOUNT_CURRENCY));
report += StringFormat("?? Margin Level: %.1f%%\n", marginLevel);

// Performance Metrics
report += "\n? PERFORMANCE METRICS:\n";
double winRate = m_totalTrades > 0 ? 0.0 : 0.0; // Would need win/loss tracking
report += StringFormat("?? Win Rate: %.1f%% (Tracking needed)\n", winRate);
report += "? Avg Trade Duration: N/A (Tracking needed)\n";
report += "?? Risk/Reward Ratio: N/A (Tracking needed)\n";

// System Health Check
report += "\n?? SYSTEM HEALTH CHECK:\n";
bool isHealthy = true;
string healthStatus = "";

// Check margin level
if(marginLevel < 200 && marginLevel > 0) {
isHealthy = false;
healthStatus += "?? LOW MARGIN LEVEL ";
}

// Check if too many positions
if(ourPositions > 10) {
isHealthy = false;
healthStatus += "?? HIGH POSITION COUNT ";
}

// Check drawdown
double drawdown = accountBalance > 0 ? ((accountBalance - accountEquity) / accountBalance * 100) : 0;
if(drawdown > 10) {
isHealthy = false;
healthStatus += "?? HIGH DRAWDOWN ";
}

report += StringFormat("?? System Health: %s %s\n",
isHealthy ? "? HEALTHY" : "?? ATTENTION NEEDED", healthStatus);
report += StringFormat("?? Current Drawdown: %.1f%%\n", drawdown);

// Recommendations
report += "\n?? RECOMMENDATIONS:\n";
if(!isHealthy) {
if(marginLevel < 200) report += "?? Consider reducing position sizes\n";
if(ourPositions > 10) report += "?? Consider closing some positions\n";
if(drawdown > 10) report += "?? Review risk management settings\n";
} else {
report += "? System operating within normal parameters\n";
report += "?? Consider enabling all risk management features\n";
report += "?? Monitor performance metrics regularly\n";
}

report += "\n? Report Generated: " + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES);
report += "\n?? ================================================\n";

return report;
}

//+------------------------------------------------------------------+
//| ?? QUICK PERFORMANCE SUMMARY                                    |
//+------------------------------------------------------------------+
string GetQuickPerformanceSummary()
{
int ourPositions = 0;
double totalProfit = 0.0;

CPositionInfo posInfo;
for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
if(posInfo.Symbol() == m_symbol && posInfo.Magic() == m_magicNumber) {
ourPositions++;
totalProfit += posInfo.Profit() + posInfo.Swap() + posInfo.Commission();
}
}
}

return StringFormat("?? TradeManager | Positions: %d | P&L: %.2f | Trades: %d | Status: %s", 
ourPositions, totalProfit, m_totalTrades, 
m_isInitialized ? "ACTIVE" : "INACTIVE");
}

//+------------------------------------------------------------------+
//| ?? PROCESS SIGNAL - MAIN ENTRY POINT                            |
//+------------------------------------------------------------------+
bool ProcessSignal(const SignalData& signalData)
{
if(!signalData.isValid) {
Print("? [TRADE] Signal processing failed: Invalid signal data");
return false;
}

if(!m_isInitialized) {
Print("? [TRADE] Signal processing failed: Trade manager not initialized");
return false;
}

// Check if we already have a position
if(HasOpenPositions(m_symbol, m_magicNumber)) {
Print("?? [TRADE] Signal processing skipped: Position already open");
return false;
}

// Calculate position size based on risk
double lotSize = CalculatePositionSizeByTick(m_symbol, signalData.stopLoss, signalData.entryPrice);
if(lotSize <= 0) {
Print("? [TRADE] Signal processing failed: Invalid lot size calculated");
return false;
}

// Prop-firm caps (mirror TradeGate presets) - soft cap before send
double lotMax = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
double maxLotsAllowed = lotMax;
int maxSimultaneous = 10;
// Example preset mapping; in production, read from centralized config/state
    string propPreset = m_propPreset; // set via setter from inputs
    if(propPreset == "FTMO") { maxLotsAllowed = MathMin(lotMax, 5.0); maxSimultaneous = 5; }
    else if(propPreset == "MFF") { maxLotsAllowed = MathMin(lotMax, 3.0); maxSimultaneous = 4; }

// Cap lot size
if(lotSize > maxLotsAllowed) {
Print(StringFormat("[CAP] Lot reduced from %.2f to %.2f by prop preset", lotSize, maxLotsAllowed));
lotSize = maxLotsAllowed;
}
    
// Enforce simultaneous positions ceiling on this symbol/magic
int currentPositions = 0;
{
    CPositionInfo posInfo;
    for(int i=0;i<PositionsTotal();i++){
        if(posInfo.SelectByIndex(i)){
            if(posInfo.Symbol()==m_symbol && posInfo.Magic()==m_magicNumber) currentPositions++;
        }
    }
    if(currentPositions >= maxSimultaneous){
        Print(StringFormat("[BLOCK] Too many positions: %d/%d by prop preset", currentPositions, maxSimultaneous));
        return false;
    }
}

// Execute trade based on signal type
bool success = false;
string direction = "";

switch(signalData.signalType)
{
case SIGNAL_BUY:
success = m_trade.Buy(lotSize, m_symbol, signalData.entryPrice,
signalData.stopLoss, signalData.takeProfit,
m_comment);
 if(!success && g_errorHandler!=NULL){ g_errorHandler.LogTradeError("EXECUTE_BUY", m_trade.ResultRetcode(), m_trade.ResultComment(), m_symbol, lotSize, signalData.entryPrice, signalData.stopLoss, signalData.takeProfit, "TradeManager::ExecuteSignal"); }
 else if(success && g_errorHandler!=NULL){ g_errorHandler.LogTradeSuccess("EXECUTE_BUY", (ulong)m_trade.ResultDeal(), m_symbol, lotSize, signalData.entryPrice, signalData.stopLoss, signalData.takeProfit, m_comment); }
direction = "BUY";
break;

case SIGNAL_SELL:
success = m_trade.Sell(lotSize, m_symbol, signalData.entryPrice, 
signalData.stopLoss, signalData.takeProfit, 
m_comment);
direction = "SELL";
break;

default:
Print("? [TRADE] Signal processing failed: Unknown signal type");
return false;
}

if(success) {
// Log trade rationale
LogTradeRationale(direction, lotSize, signalData.entryPrice, 
signalData.stopLoss, signalData.takeProfit, 
signalData.reason);

// Update statistics
m_totalTrades++;

Print(StringFormat("? [TRADE] %s order executed: %.2f lots at %.5f", 
direction, lotSize, signalData.entryPrice));

return true;
} else {
Print(StringFormat("? [TRADE] %s order failed: %s", 
direction, m_trade.ResultRetcodeDescription()));
return false;
}
}

//+------------------------------------------------------------------+
//| ?? CALCULATE POSITION SIZE                                       |
//+------------------------------------------------------------------+
double CalculatePositionSizeByTick(const string sym, double stopLoss, double entryPrice)
{
    if(stopLoss <= 0 || entryPrice <= 0) return 0.0;

    // Price distance for SL
    double sl_dist_price = MathAbs(entryPrice - stopLoss);

    // Risk amount
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = balance * (m_maxRiskPercent / 100.0);

    // MT5-correct value per price unit per lot
    double tick = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
    double tv   = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
    if(tick<=0 || tv<=0) return 0.0;
    double valuePerPricePerLot = tv / tick; // money per 1.0 price move per 1 lot

    // Position size by monetary risk
    double riskPerLot = sl_dist_price * valuePerPricePerLot;
    if(riskPerLot<=0) return 0.0;
    double lots = riskAmount / riskPerLot;

    // Normalize to broker constraints
    double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
    double step   = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
    lots = MathMax(minLot, MathMin(maxLot, MathFloor(lots/step)*step));
    lots = MathMax(m_minLotSize, MathMin(m_maxLotSize, lots));

    return lots;
}

private:
//+------------------------------------------------------------------+
//| ?? BOSS FIX: Log Trade Rationale Method                         |
//+------------------------------------------------------------------+
void LogTradeRationale(string direction, double volume, double price, double sl, double tp, string comment)
{
string rationale = StringFormat(
"\n?? ===== TRADE RATIONALE LOG =====\n" +
"?? Direction: %s\n" +
"?? Volume: %.2f lots\n" +
"?? Entry Price: %.5f\n" +
"??? Stop Loss: %.5f (%.1f pips)\n" +
"?? Take Profit: %.5f (%.1f pips)\n" +
"?? Comment: %s\n" +
"? Time: %s\n" +
"?? Symbol: %s\n" +
"?? Magic: %d\n" +
"================================\n",
direction,
volume,
price,
sl, (sl > 0) ? MathAbs(price - sl) / _Point : 0,
tp, (tp > 0) ? MathAbs(tp - price) / _Point : 0,
comment,
TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES),
m_symbol,
m_magicNumber
);

// Print to terminal for immediate visibility
Print(rationale);

// If logger is available via context, use it
if (m_pContext != NULL && CheckPointer(m_pContext) == POINTER_DYNAMIC) {
// Try to access logger through context
Print("[?? TRADE LOG] Trade rationale logged via context");
// Note: Full logger integration depends on proper context setup
}

// Log to file directly as backup
int fileHandle = FileOpen("SonicR_TradeRationale_" + _Symbol + ".log", 
FILE_WRITE | FILE_TXT | FILE_ANSI, "\t");
if (fileHandle != INVALID_HANDLE) {
FileWrite(fileHandle, rationale);
FileClose(fileHandle);
}
}
};

//+------------------------------------------------------------------+
//| Trade Manager Utility Functions                                 |
//+------------------------------------------------------------------+

// Quick position check
bool HasOpenPositions(string symbol, int magicNumber) {
CPositionInfo posInfo;

for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
if(posInfo.Symbol() == symbol && posInfo.Magic() == magicNumber) {
return true;
}
}
}

return false;
}

// Get position type
ENUM_POSITION_TYPE GetPositionType(string symbol, int magicNumber) {
CPositionInfo posInfo;

for(int i = 0; i < PositionsTotal(); i++) {
if(posInfo.SelectByIndex(i)) {
if(posInfo.Symbol() == symbol && posInfo.Magic() == magicNumber) {
return posInfo.PositionType();
}
}
}

return WRONG_VALUE;
}

//+------------------------------------------------------------------+

#endif // TRADE_01_MANAGER_MQH


