# SONIC R MC - COMPILE SYSTEM (Canonical)

Tài liệu này mô tả quy trình compile chuẩn từ terminal cho dự án.

## Công cụ chính (được hỗ trợ)

- Batch wrapper: 00_Compile\02_Run Compile\quick_compile.bat
- PowerShell: 00_Compile\02_Run Compile\sonic_compile.ps1 (modes: quick | auto | test)

Các script khác được nhắc đến trước đây (auto_compile.bat, test_compile.bat, compile_all.bat, compile_simple.bat, compile_ea.bat, sonic_test.ps1, sonic_status.ps1) hiện đã deprecated và không còn được duy trì. Xem DEPRECATED.md để biết chi tiết.

## Cách dùng nhanh

```bash
# Khuyến nghị
00_Compile\02_Run Compile\quick_compile.bat

# Hoặc gọi trực tiếp PowerShell
powershell -ExecutionPolicy Bypass -File "00_Compile\02_Run Compile\sonic_compile.ps1" -Mode quick -Target ea
```

## Các mode

- quick: compile nhanh, in SUCCESS/FAILED, trả mã thoát chuẩn, in tail log khi lỗi.
- auto: tạo log timestamp (Logs\compile_YYYYMMDD_HHMMSS.log), in tóm tắt thời gian và số lỗi/warning.
- test: in toàn bộ nội dung log ra console, kèm summary (ExitCode, thời gian, lỗi/warning).

## Vị trí log

- 00_Compile\Logs\00_Main_EA_SonicR.mq5.log
- 00_Compile\Logs\compile_YYYYMMDD_HHMMSS.log (chỉ khi dùng mode auto)

## Quy trình debug nhanh

1) Chạy quick để biết pass/fail.
2) Nếu fail: xem tail log đã in; cần chi tiết hơn thì chạy mode test.
3) Với CI hoặc cần lưu vết: chạy mode auto để có timestamped log.

## Hidden Error Detection Protocol

- Luôn double-verify: chạy script compile (quick/auto/test) và compile thủ công trong MetaEditor để phát hiện lỗi bị ẩn.
- Khi ExitCode=0 nhưng log có “error ”, script sẽ cảnh báo “Hidden error suspected”. Cần mở MetaEditor kiểm tra thủ công.

## Tích hợp CI/CD

```bat
call 00_Compile\02_Run Compile\quick_compile.bat
if %ERRORLEVEL% NEQ 0 exit /b 1
```

## Ghi chú

- MetaEditor được tự động dò từ metaeditor64.exe/metaeditor.exe. Có thể override bằng tham số -MetaEditorPath.
- Thời gian compile được in trong summary để theo dõi hiệu năng.
