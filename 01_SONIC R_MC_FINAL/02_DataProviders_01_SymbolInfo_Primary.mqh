//+------------------------------------------------------------------+
//|                                            Core_SymbolInfo.mqh   |
//|                            Sonic R MC EA - Symbol Information     |
//|                     ?? PHASE 5: Multi-Pair Optimization          |
//| Authors: Mèo C?c vs Ð?i Bàng                                      |
//+------------------------------------------------------------------+
#ifndef CORE_SYMBOLINFO_MQH
#define CORE_SYMBOLINFO_MQH

//+------------------------------------------------------------------+
//| ?? PHASE 5: Multi-Pair Support Enumeration                      |
//+------------------------------------------------------------------+
enum ENUM_PAIR
{
PAIR_EURUSD = 0,    // EUR/USD - Major pair
PAIR_GBPUSD = 1,    // GBP/USD - Major pair  
PAIR_XAUUSD = 2,    // XAU/USD - Gold
PAIR_UNKNOWN = -1   // Unknown or unsupported pair
};

//+------------------------------------------------------------------+
//| ?? PHASE 5: Pair-Specific Configuration Structure               |
//+------------------------------------------------------------------+
struct PairConfig
{
ENUM_PAIR pairType;
string symbol;
int emaPeriod;              // Optimized EMA period for this pair
double spreadThreshold;     // Maximum allowed spread
double volatilityFactor;    // Volatility adjustment factor
double correlationLimit;    // Correlation threshold with other pairs
bool isActive;              // Whether pair is currently tradeable

void SetDefaults(ENUM_PAIR pair)
{
pairType = pair;
isActive = true;

switch(pair)
{
case PAIR_EURUSD:
symbol = "EURUSD";
emaPeriod = 34;         // Standard EMA for EUR/USD
spreadThreshold = 2.0;   // 2 pips max spread
volatilityFactor = 1.0;  // Standard volatility
correlationLimit = 0.8;  // 80% correlation limit
break;

case PAIR_GBPUSD:
symbol = "GBPUSD";
emaPeriod = 30;         // Faster EMA for GBP volatility
spreadThreshold = 3.0;   // 3 pips max spread (more volatile)
volatilityFactor = 1.2;  // Higher volatility factor
correlationLimit = 0.75; // 75% correlation limit
break;

case PAIR_XAUUSD:
symbol = "XAUUSD";
emaPeriod = 40;         // Slower EMA for Gold
spreadThreshold = 50.0;  // 50 cents max spread
volatilityFactor = 1.5;  // Much higher volatility
correlationLimit = 0.6;  // 60% correlation limit (less correlated)
break;

default:
symbol = "";
emaPeriod = 34;
spreadThreshold = 5.0;
volatilityFactor = 1.0;
correlationLimit = 0.8;
break;
}
}
};

//+------------------------------------------------------------------+
//| ?? PHASE 5: Multi-Pair Performance Tracking                     |
//+------------------------------------------------------------------+
struct PairPerformance
{
ENUM_PAIR pairType;
int totalTrades;
int winningTrades;
double totalProfit;
double winRate;
double profitFactor;
double maxDrawdown;
datetime lastTradeTime;

void Initialize(ENUM_PAIR pair)
{
pairType = pair;
totalTrades = 0;
winningTrades = 0;
totalProfit = 0.0;
winRate = 0.0;
profitFactor = 0.0;
maxDrawdown = 0.0;
lastTradeTime = 0;
}

void UpdateTrade(bool isWin, double profit)
{
totalTrades++;
if(isWin) winningTrades++;
totalProfit += profit;
winRate = totalTrades > 0 ? (double)winningTrades / totalTrades : 0.0;
lastTradeTime = TimeCurrent();

// Update profit factor (simplified)
if(totalTrades > 0) {
profitFactor = totalProfit > 0 ? 1.0 + (totalProfit / 1000.0) : 0.5;
}
}
};

//+------------------------------------------------------------------+
//| Custom Symbol Info Class - RENAMED to avoid MQL5 conflict       |
//+------------------------------------------------------------------+
class CSonicSymbolInfo
{
private:
string m_symbol;
double m_point;
int    m_digits;
double m_tickSize;
double m_tickValue;
double m_lotSize;
double m_minLot;
double m_maxLot;
double m_lotStep;
double m_spread;

// Fallback mechanism for market data
double m_lastValidBid;
double m_lastValidAsk;
datetime m_lastDataUpdate;
bool m_isDataStale;
int m_connectionRetries;

// Market data validation
bool ValidateMarketData(double bid, double ask);

public:
CSonicSymbolInfo()
{
m_symbol = "";
m_point = 0;
m_digits = 0;
m_tickSize = 0;
m_tickValue = 0;
m_lotSize = 0;
m_minLot = 0;
m_maxLot = 0;
m_lotStep = 0;
m_spread = 0;

// Initialize fallback data
m_lastValidBid = 0.0;
m_lastValidAsk = 0.0;
m_lastDataUpdate = 0;
m_isDataStale = false;
m_connectionRetries = 0;
}

CSonicSymbolInfo(string symbol)
{
Name(symbol);
}

~CSonicSymbolInfo() {}

// Set symbol and refresh all properties
bool Name(string symbol)
{
m_symbol = symbol;
return RefreshRates();
}

string Name() const { return m_symbol; }

// Initialize the symbol info
bool Initialize()
{
if(m_symbol == "") {
m_symbol = _Symbol;
}
return RefreshRates();
}

// Deinitialize the symbol info
void Deinitialize()
{
m_symbol = "";
m_isDataStale = true;
m_connectionRetries = 0;
}

bool RefreshRates()
{
if (m_symbol == "") return false;

// Try to get fresh market data
double currentBid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
double currentAsk = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

// Validate market data
if(ValidateMarketData(currentBid, currentAsk)) {
m_lastValidBid = currentBid;
m_lastValidAsk = currentAsk;
m_lastDataUpdate = TimeCurrent();
m_isDataStale = false;
m_connectionRetries = 0;
} else {
m_connectionRetries++;
m_isDataStale = (TimeCurrent() - m_lastDataUpdate) > 60; // 1 minute threshold

if(m_connectionRetries > 3) {
Print(StringFormat("[FALLBACK] %s: Using cached data, retries: %d", 
m_symbol, m_connectionRetries));
}
}

m_point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
m_digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
m_tickSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
m_tickValue = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
m_lotSize = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
m_minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
m_maxLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
m_lotStep = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
m_spread = SymbolInfoInteger(m_symbol, SYMBOL_SPREAD) * m_point;

return true;
}

double Point() const { return m_point; }
int Digits() const { return m_digits; }
double TickSize() const { return m_tickSize; }
double TickValue() const { return m_tickValue; }
double LotSize() const { return m_lotSize; }
double LotsMin() const { return m_minLot; }
double LotsMax() const { return m_maxLot; }
double LotsStep() const { return m_lotStep; }
double Spread() const { return m_spread; }

double NormalizePrice(double price) const
{
return NormalizeDouble(price, m_digits);
}

double Bid() const { return GetBidWithFallback(); }
double Ask() const { return GetAskWithFallback(); }

// Fallback methods
double GetBidWithFallback() const
{
double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
if(bid <= 0) {
return 0.0;
}
return bid;
}

double GetAskWithFallback() const
{
double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
if(ask <= 0) {
return 0.0;
}
return ask;
}
bool IsDataStale() const { return m_isDataStale; }
int GetConnectionRetries() const { return m_connectionRetries; }
};

//+------------------------------------------------------------------+
//| ?? GLOBAL INSTANCE AND INTERFACE                                  |
//+------------------------------------------------------------------+
CSonicSymbolInfo* g_SymbolInfo;

//+------------------------------------------------------------------+
//| ?? GLOBAL INITIALIZATION FUNCTIONS                                |
//+------------------------------------------------------------------+
bool InitializeSymbolInfo()
{
if(g_SymbolInfo != NULL) {
delete g_SymbolInfo;
}

g_SymbolInfo = new CSonicSymbolInfo();
if(g_SymbolInfo == NULL) {
Print("? [SYMBOL] Failed to create Symbol Info instance");
return false;
}

if(!g_SymbolInfo.Initialize()) {
Print("? [SYMBOL] Failed to initialize Symbol Info");
delete g_SymbolInfo;
g_SymbolInfo = NULL;
return false;
}

Print("? [SYMBOL] Symbol Info initialized successfully");
return true;
}

void DeinitializeSymbolInfo()
{
if(g_SymbolInfo != NULL) {
g_SymbolInfo.Deinitialize();
delete g_SymbolInfo;
g_SymbolInfo = NULL;
Print("? [SYMBOL] Symbol Info deinitialized");
}
}

//+------------------------------------------------------------------+
//| ?? GLOBAL INTERFACE FUNCTIONS                                     |
//+------------------------------------------------------------------+
double GetCurrentBid()
{
if(g_SymbolInfo == NULL) {
return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

return g_SymbolInfo.GetBidWithFallback();
}

double GetCurrentAsk()
{
if(g_SymbolInfo == NULL) {
return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
}

return g_SymbolInfo.GetAskWithFallback();
}

bool IsSymbolDataValid()
{
if(g_SymbolInfo == NULL) {
return true; // Assume valid if not initialized
}

return !g_SymbolInfo.IsDataStale();
}

#endif // CORE_SYMBOLINFO_MQH


