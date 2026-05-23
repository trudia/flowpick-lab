@echo off
chcp 65001 > nul
setlocal

echo.
echo ==========================================
echo TrendFlow V54 No-Param Watcher Fix
echo ==========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_AUTOMATION_FIX.ps1"

echo.
pause
