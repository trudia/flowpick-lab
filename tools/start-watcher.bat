@echo off
chcp 65001 > nul
setlocal

echo.
echo ==========================================
echo TrendFlow 다운로드 폴더 자동 감시 배포
echo ==========================================
echo.
echo 이 창을 켜두면 Downloads 폴더에 새 trendflow_site_v*.zip 파일이 생길 때 감지합니다.
echo 기본값은 배포 전에 Y/N 확인을 받습니다.
echo 종료하려면 이 창에서 Ctrl+C를 누르세요.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch-downloads.ps1" -RepoPath "%~dp0.." 

pause
