@echo off
chcp 65001 > nul
setlocal

echo.
echo ==========================================
echo TrendFlow 다운로드 폴더 감시 테스트 모드
echo ==========================================
echo.
echo Git commit은 하지만 push는 하지 않습니다.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch-downloads.ps1" -RepoPath "%~dp0.." -NoPush

pause
