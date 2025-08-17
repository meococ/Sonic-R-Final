//+------------------------------------------------------------------+
//|                           SONIC_Core_Inputs.mqh                 |
//|                    SIMPLIFIED INPUT PARAMETERS                  |
//+------------------------------------------------------------------+
#ifndef SONIC_CORE_INPUTS_H
#define SONIC_CORE_INPUTS_H

//+------------------------------------------------------------------+
//| TRADING PARAMETERS                                              |
//+------------------------------------------------------------------+
input group "═══ TRADING SETTINGS ═══"
input int      InpMagicNumber        = 123456;    // Magic Number
input double   InpRiskPercent        = 1.0;       // Risk Per Trade (%)
input int      InpMaxPositions       = 3;         // Max Concurrent Positions
input int      InpMaxSpread          = 20;        // Max Spread (points)
input int      InpSlippage           = 10;        // Slippage (points)
input int      InpTradeCooldown      = 15;        // Trade Cooldown (minutes)

//+------------------------------------------------------------------+
//| STRATEGY PARAMETERS                                             |
//+------------------------------------------------------------------+
input group "═══ STRATEGY SETTINGS ═══"
input double   InpStopLossATR        = 1.5;       // Stop Loss (ATR multiplier)
input double   InpTakeProfitATR      = 2.5;       // Take Profit (ATR multiplier)
input double   InpMinConfidence      = 0.65;      // Min Signal Confidence
input bool     InpTradeAllSessions   = false;     // Trade All Sessions

//+------------------------------------------------------------------+
//| RISK MANAGEMENT                                                 |
//+------------------------------------------------------------------+
input group "═══ RISK MANAGEMENT ═══"
input double   InpMaxDailyLoss       = 500;       // Max Daily Loss ($)
input bool     InpUseTrailingStop    = true;      // Use Trailing Stop
input double   InpTrailingStopATR    = 1.0;       // Trailing Stop (ATR)
input bool     InpUseBreakEven       = true;      // Use Break Even
input double   InpBreakEvenATR       = 0.75;      // Break Even Trigger (ATR)

//+------------------------------------------------------------------+
//| PERFORMANCE SETTINGS                                            |
//+------------------------------------------------------------------+
input group "═══ PERFORMANCE ═══"
input bool     InpShowDashboard      = true;      // Show Dashboard
input int      InpUpdateFrequency    = 5;         // Dashboard Update (seconds)
input bool     InpVerboseLogging     = false;     // Verbose Logging

#endif // SONIC_CORE_INPUTS_H
