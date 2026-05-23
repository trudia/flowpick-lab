@echo off
chcp 65001 > nul
setlocal

echo.
echo ==========================================
echo TrendFlow Watcher Test Mode
echo ==========================================
echo.
echo This mode does not push to remote.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch-downloads.ps1" -RepoPath "%~dp0.." -NoPush

pause
