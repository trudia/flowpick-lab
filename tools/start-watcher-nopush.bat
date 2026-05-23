@echo off
chcp 65001 > nul
setlocal

set "TRENDFLOW_REPOPATH=%~dp0.."
set "TRENDFLOW_DOWNLOADS=%USERPROFILE%\Downloads"
set "TRENDFLOW_POLL_SECONDS=5"
set "TRENDFLOW_AUTOAPPROVE=0"
set "TRENDFLOW_NOPUSH=1"

echo.
echo ==========================================
echo TrendFlow Watcher Test Mode
echo ==========================================
echo.
echo This mode does not push to remote.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch-downloads.ps1"

pause
