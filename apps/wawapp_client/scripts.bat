@echo off
REM Windows batch scripts for development

if "%1"=="sync-hard" (
    powershell -ExecutionPolicy Bypass -File tool/sync/sync_hard.ps1
) else if "%1"=="analyze" (
    flutter analyze
) else if "%1"=="debug" (
    flutter run --debug
) else if "%1"=="release" (
    flutter build apk --release
) else if "%1"=="pack-lib" (
    powershell -ExecutionPolicy Bypass -File tool/pack/pack_lib.ps1
) else (
    echo Available commands:
    echo   scripts sync-hard  - Hard sync with origin/main
    echo   scripts analyze    - Run flutter analyze
    echo   scripts debug      - Run app in debug mode
    echo   scripts release    - Build release APK
    echo   scripts pack-lib   - Pack lib folder for distribution
)