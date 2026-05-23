$ErrorActionPreference = "Stop"

$RepoPath = (Resolve-Path ".").Path
$TaskName = "TrendFlow Download Watcher"
$BatPath = Join-Path $RepoPath "tools\start-watcher.bat"

if (-not (Test-Path -LiteralPath $BatPath)) {
  Write-Host "start-watcher.bat was not found: $BatPath" -ForegroundColor Red
  exit 1
}

$Action = New-ScheduledTaskAction -Execute $BatPath
$Trigger = New-ScheduledTaskTrigger -AtLogOn
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "TrendFlow update ZIP download watcher" -Force | Out-Null

Write-Host "Scheduled task installed: $TaskName" -ForegroundColor Green
