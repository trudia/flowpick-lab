@echo off
chcp 65001 > nul
setlocal

echo.
echo ================================
echo TrendFlow Latest ZIP Deploy
echo ================================
echo.
echo This finds the latest trendflow_site_v*.zip in Downloads and deploys it.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy-latest.ps1" -RepoPath "%~dp0.."

echo.
pause
