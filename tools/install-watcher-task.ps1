param(
  [string]$RepoPath = (Resolve-Path ".").Path,
  [string]$TaskName = "TrendFlow Download Watcher",
  [switch]$AutoApprove,
  [switch]$NoPush
)

$ErrorActionPreference = "Stop"

$RepoPath = [System.IO.Path]::GetFullPath($RepoPath)
$watchScript = Join-Path $RepoPath "tools\watch-downloads.ps1"

if (-not (Test-Path -LiteralPath $watchScript)) {
  Write-Host "watch-downloads.ps1을 찾지 못했습니다: $watchScript" -ForegroundColor Red
  exit 1
}

$args = "-NoProfile -ExecutionPolicy Bypass -File `"$watchScript`" -RepoPath `"$RepoPath`""
if ($AutoApprove) { $args += " -AutoApprove" }
if ($NoPush) { $args += " -NoPush" }

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $args
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "TrendFlow 업데이트 ZIP 자동 감시 배포" -Force | Out-Null

Write-Host "작업 스케줄러 등록 완료: $TaskName" -ForegroundColor Green
Write-Host "다음 로그인부터 자동 실행됩니다." -ForegroundColor Yellow
Write-Host "지금 바로 시작하려면:" -ForegroundColor Cyan
Write-Host "Start-ScheduledTask -TaskName `"$TaskName`"" -ForegroundColor Cyan
