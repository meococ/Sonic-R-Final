#ifndef CORE_ERROR_CONSTANTS_CLEAN_MQH
#define CORE_ERROR_CONSTANTS_CLEAN_MQH

// MQL5 Error Codes
#define ERR_NO_ERROR                    0
#define ERR_UNKNOWN_COMMAND             4014
#define ERR_CUSTOM_INDICATOR_ERROR      4036
#define ERR_INDICATOR_CANNOT_INIT       4052
#define ERR_INDICATOR_CANNOT_LOAD       4053
#define ERR_NO_HISTORY_DATA             4054

// SONIC R Custom Errors
#define ERR_DRAGON_BAND_INVALID_HANDLE  5001
#define ERR_DRAGON_BAND_NO_DATA         5002
#define ERR_CIRCUIT_BREAKER_ACTIVATED   5005

string GetErrorDescription(int errorCode)
{
switch(errorCode)
{
case ERR_NO_ERROR: return "No error";
case ERR_UNKNOWN_COMMAND: return "Invalid request (4014)";
case ERR_CUSTOM_INDICATOR_ERROR: return "Custom indicator error";
case ERR_INDICATOR_CANNOT_INIT: return "Indicator cannot initialize";
case ERR_NO_HISTORY_DATA: return "No history data";
case ERR_DRAGON_BAND_INVALID_HANDLE: return "Dragon Band invalid handle";
default: return "Unknown error";
}
}

#endif // CORE_ERROR_CONSTANTS_CLEAN_MQH 


