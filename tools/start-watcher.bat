@echo off
chcp 65001 > nul
setlocal

echo.
echo ==========================================
echo TrendFlow Download Folder Watcher
echo ==========================================
echo.
echo Keep this window open.
echo When a new trendflow_site_v*.zip appears in Downloads, this watcher detects it.
echo It asks Y/N before deployment.
echo Press Ctrl+C to stop.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch-downloads.ps1" -RepoPath "%~dp0.."

pause
