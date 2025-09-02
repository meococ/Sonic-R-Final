# Deprecated compile helpers (canonical tool: sonic_compile.ps1)

The project now uses a single, canonical compile tool:
- PowerShell: 00_Compile/02_Run Compile/sonic_compile.ps1
- Batch wrapper (calls the above): 00_Compile/02_Run Compile/quick_compile.bat

Deprecated/legacy items kept only for historical reference and should not be used:
- analyze_errors.ps1 (superseded by sonic_compile.ps1 parsing and summary)
- error_groups.json (output from analyze_errors.ps1; no longer maintained)
- compile_all.bat (kept for convenience menu; will internally call quick_compile wrapper if needed)

Migration notes:
- Use: powershell -ExecutionPolicy Bypass -File "00_Compile\02_Run Compile\sonic_compile.ps1" -Mode quick -Target ea
- Or simply run: 00_Compile\02_Run Compile\quick_compile.bat

Please update any external scripts/CI to rely on sonic_compile.ps1.

