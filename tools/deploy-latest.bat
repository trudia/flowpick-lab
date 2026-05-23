@echo off
chcp 65001 > nul
setlocal

echo.
echo ================================
echo TrendFlow 최신 ZIP 자동 배포
echo ================================
echo.
echo 다운로드 폴더에서 가장 최근 trendflow_site_v*.zip 파일을 찾아 배포합니다.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy-latest.ps1" -RepoPath "%~dp0.."

echo.
pause
