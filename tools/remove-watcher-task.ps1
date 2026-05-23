param(
  [string]$TaskName = "TrendFlow Download Watcher"
)

$ErrorActionPreference = "Stop"

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $task) {
  Write-Host "등록된 작업이 없습니다: $TaskName" -ForegroundColor Yellow
  exit 0
}

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
Write-Host "작업 스케줄러 제거 완료: $TaskName" -ForegroundColor Green
