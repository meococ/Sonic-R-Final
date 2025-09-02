//+------------------------------------------------------------------+
//|                                                  Core_Logger.mqh |
//|                SONIC R MC EA - Professional Logging System       |
//|                     �?i B�ng Architecture - Foundation Layer     |
//+------------------------------------------------------------------+
#ifndef CORE_LOGGER_MQH
#define CORE_LOGGER_MQH

// SYSTEMATIC FIX - Remove conflicting include guard
// PRODUCTION FIX: Comment out Object.mqh include to fix dependency issue

#include "01_Core_22_SonicEnums.mqh"
// #include "01_Core_16_EnumHelpers.mqh" // Already included in MasterIncludes after all enums
#include "01_Core_08_ContextManager.mqh" // For CEaContext
#include "01_Core_03_DebugHelpers.mqh"   // For __isBT/DebugPermit

// External reference to global context
// extern CEaContext g_Context; // PHASE 3 FIX: Commented out - not used

//+------------------------------------------------------------------+
//| CLogger Class - Professional Logging for EA                     |
//+------------------------------------------------------------------+
class CLogger
{
private:
// --- Internal Configuration & State ---
ENUM_LOG_LEVEL      m_log_level;
int                 m_log_output;           // 1=FILE, 2=CONSOLE, 3=BOTH
bool                m_enable_telegram;
bool                m_telegram_important_only;
string              m_telegram_bot_token;
string              m_telegram_chat_id;
string              m_order_comment;

string              m_symbol_name;          // Symbol name storage
string              m_log_file_name;        // Full log file name
int                 m_log_file_handle;      // Log file handle
bool                m_initialized;          // Initialization flag

// --- Internal Unified Methods ---
void                WriteToFile(const string& formatted_message) const;
bool                SendTelegramMessage(const string& formatted_message, const bool important) const;
string              GetLogLevelString(const ENUM_LOG_LEVEL level) const;

// --- Telegram queue & backoff ---
string              m_tgQueue[10];
bool                m_tgImportant[10];
int                 m_tgHead;
int                 m_tgTail;
datetime            m_tgNextAllowed;
int                 m_tgBackoffSec;

void                EnqueueTelegram(const string &msg, bool important) {
	int next = (m_tgTail + 1) % 10;
	if(next == m_tgHead) {
		// queue full: drop non-important or oldest
		if(!important) return;
		m_tgHead = (m_tgHead + 1) % 10;
	}
	m_tgQueue[m_tgTail] = msg;
	m_tgImportant[m_tgTail] = important;
	m_tgTail = next;
}

void                ProcessTelegramQueue()
{
	if(!m_enable_telegram) return;
	if(TimeCurrent() < m_tgNextAllowed) return;
	if(m_tgHead == m_tgTail) return; // empty
	string msg = m_tgQueue[m_tgHead];
	bool important = m_tgImportant[m_tgHead];
	bool ok = SendTelegramMessage(msg, important);
	if(ok) {
		m_tgHead = (m_tgHead + 1) % 10;
		m_tgBackoffSec = 1;
		m_tgNextAllowed = TimeCurrent();
	} else {
		m_tgBackoffSec = MathMin(120, MathMax(2, m_tgBackoffSec * 2));
		m_tgNextAllowed = TimeCurrent() + m_tgBackoffSec;
	}
}

public:
// --- Constructor & Destructor ---
CLogger() :
m_log_level(LOGLEVEL_INFO),
m_log_output(2), // Console output
m_enable_telegram(false),
m_telegram_important_only(true),
m_telegram_bot_token(""),
m_telegram_chat_id(""),
m_order_comment("SONIC_R_MC_EA"),
m_symbol_name(""),
m_log_file_name(""),
m_log_file_handle(INVALID_HANDLE),
m_initialized(false)
{
	m_tgHead = 0; m_tgTail = 0; m_tgNextAllowed = 0; m_tgBackoffSec = 1;
}

~CLogger()
{
Deinitialize();
}

// --- Initialization & Cleanup Methods ---
bool                Initialize()
{
if (m_initialized) return true;

// Setup default configuration
m_log_level = LOGLEVEL_INFO;
m_log_output = 2; // Console output
m_enable_telegram = false;
m_order_comment = "SONIC_R_MC_EA";

m_symbol_name = Symbol();

// Setup file logging if needed
if (m_log_output == 1 || m_log_output == 3) // FILE or BOTH
{
string date_str = TimeToString(TimeCurrent(), TIME_DATE);
StringReplace(date_str, ".", "");
m_log_file_name = "Logs" + m_order_comment + "_" + m_symbol_name + "_" + date_str + ".log";

m_log_file_handle = FileOpen(m_log_file_name, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_SHARE_READ);

if (m_log_file_handle == INVALID_HANDLE)
{
PrintFormat("LOGGER WARNING: Cannot open log file '%s', error: %d. File logging disabled.", m_log_file_name, GetLastError());
}
else
{
FileSeek(m_log_file_handle, 0, SEEK_END);
}
}

m_initialized = true;

Info("Logger initialized successfully");
return true;
}

void                Deinitialize()
{
    if (!m_initialized) return;

    Info("Logger deinitializing...");

    // Close file handle if open
    if (m_log_file_handle != INVALID_HANDLE)
    {
        FileClose(m_log_file_handle);
        m_log_file_handle = INVALID_HANDLE;
    }

    // Clear telegram queue
    m_tgHead = 0;
    m_tgTail = 0;
    for(int i = 0; i < 10; i++) {
        m_tgQueue[i] = "";
        m_tgImportant[i] = false;
    }

    m_initialized = false;

    Print("Logger deinitialized successfully");
}
bool                IsInitialized() const { return m_initialized; }
void                OnTick() { ProcessTelegramQueue(); }

// --- Main Logging Methods ---
void                Log(const ENUM_LOG_LEVEL level, const string message, const string tags = NULL)
{
    if (!m_initialized) return;
    if (level < m_log_level) return; // Skip if below current log level

    // Backtest log guard: honor EA backtest logging mode
    if(__isBT()){
        if(InpBacktestLogMode==BT_LOG_OFF) return;
        if(InpBacktestLogMode==BT_LOG_M15_ONLY){
            datetime bt=iTime(_Symbol, InpLogBarTF, 0);
            static datetime __last=0; if(bt==__last) return; __last=bt;
        } else if(InpBacktestLogMode==BT_LOG_COMPACT){
            if(!DebugPermit()) return;
        }
    }

    // Format timestamp
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);

    // Format log level
    string level_str = GetLogLevelString(level);

    // Format tags
    string tag_str = (tags != NULL && tags != "") ? "[" + tags + "] " : "";

    // Create formatted message
    string formatted_message = StringFormat("[%s] %s %s%s",
                                          timestamp,
                                          level_str,
                                          tag_str,
                                          message);

    // Output to console (always)
    if (m_log_output == 2 || m_log_output == 3) // CONSOLE or BOTH
    {
        Print(formatted_message);
    }

    // Output to file
    if (m_log_output == 1 || m_log_output == 3) // FILE or BOTH
    {
        WriteToFile(formatted_message);
    }

    // Send to Telegram if enabled and important enough
    if (m_enable_telegram)
    {
        bool is_important = (level >= LOGLEVEL_WARNING) || !m_telegram_important_only;
        if (is_important)
        {
            string telegram_msg = StringFormat("%s %s%s",
                                             level_str,
                                             tag_str,
                                             message);
            EnqueueTelegram(telegram_msg, level >= LOGLEVEL_ERROR);
        }
    }
}
void                Info(const string message, const string tags = NULL) { Log(LOGLEVEL_INFO, message, tags); }
void                Debug(const string message, const string tags = NULL) { Log(LOGLEVEL_DEBUG, message, tags); }
void                Warning(const string message, const string tags = NULL) { Log(LOGLEVEL_WARNING, message, tags); }
void                Error(const string message, const string tags = NULL) { Log(LOGLEVEL_ERROR, message, tags); }

// --- Alias Methods for Compatibility ---
void                LogInfo(const string message, const string tags = "") { Info(message, tags); }
void                LogDebug(const string message, const string tags = "") { Debug(message, tags); }
void                LogWarning(const string message, const string tags = "") { Warning(message, tags); }
void                LogError(const string message, const string tags = "") { Error(message, tags); }

// --- Utility Methods ---
string              GetLogFileName() const { return m_log_file_name; }
void                SetLogLevel(const ENUM_LOG_LEVEL level) { m_log_level = level; }
ENUM_LOG_LEVEL      GetLogLevel() const { return m_log_level; }

// --- Telegram controls ---
void                EnableTelegram(bool enable) { m_enable_telegram = enable; }
void                SetTelegramCredentials(const string bot, const string chat) { m_telegram_bot_token = bot; m_telegram_chat_id = chat; }
void                QueueTelegram(const string &msg, bool important=false) { EnqueueTelegram(msg, important); }

// Safe setter using global config if provided
void                ApplyGlobalTelegramConfig()
{
  if(StringLen(g_TelegramBotToken)>0 && StringLen(g_TelegramChatId)>0)
  {
    m_enable_telegram = InpTelegramEnabled; // still controlled by input enable
    m_telegram_important_only = InpTelegramImportantOnly;
    m_telegram_bot_token = g_TelegramBotToken;
    m_telegram_chat_id = g_TelegramChatId;
  }
}

};

#endif // CORE_LOGGER_MQH