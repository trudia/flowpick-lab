@echo off
chcp 65001 > nul
setlocal
echo.
echo ================================
echo TrendFlow 자동 배포 실행기
echo ================================
echo.
set /p ZIPPATH=업데이트 ZIP 파일 경로를 붙여넣으세요: 
if "%ZIPPATH%"=="" (
  echo ZIP 경로가 입력되지 않았습니다.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy-update.ps1" -ZipPath "%ZIPPATH%" -RepoPath "%~dp0.."
echo.
pause
