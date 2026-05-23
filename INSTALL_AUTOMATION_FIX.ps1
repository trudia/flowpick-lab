$ErrorActionPreference = "Stop"

$DefaultRepo = "C:\Users\편돌이\Documents\GitHub\flowpick-lab"
$RepoPath = $DefaultRepo

if (-not (Test-Path -LiteralPath $RepoPath)) {
  $RepoPath = Read-Host "Paste your GitHub repository path"
}

$RepoPath = [System.IO.Path]::GetFullPath($RepoPath)

if (-not (Test-Path -LiteralPath $RepoPath)) {
  Write-Host "RepoPath not found: $RepoPath" -ForegroundColor Red
  exit 1
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
  Write-Host "RepoPath is not a Git repository: $RepoPath" -ForegroundColor Red
  exit 1
}

$PatchRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceTools = Join-Path $PatchRoot "tools"
$TargetTools = Join-Path $RepoPath "tools"

if (-not (Test-Path -LiteralPath $TargetTools)) {
  New-Item -ItemType Directory -Path $TargetTools -Force | Out-Null
}

$Files = @(
  "watch-downloads.ps1",
  "start-watcher.bat",
  "start-watcher-nopush.bat",
  "install-watcher-task.ps1"
)

foreach ($File in $Files) {
  $Src = Join-Path $SourceTools $File
  if (Test-Path -LiteralPath $Src) {
    Copy-Item -LiteralPath $Src -Destination (Join-Path $TargetTools $File) -Force
    Write-Host "[OK] tools\$File" -ForegroundColor Green
  } else {
    Write-Host "[MISS] tools\$File" -ForegroundColor Red
  }
}

$RootStart = Join-Path $PatchRoot "start-watcher.bat"
if (Test-Path -LiteralPath $RootStart) {
  Copy-Item -LiteralPath $RootStart -Destination (Join-Path $RepoPath "start-watcher.bat") -Force
  Write-Host "[OK] start-watcher.bat" -ForegroundColor Green
}

Write-Host ""
Write-Host "V54 watcher patch installed." -ForegroundColor Green
Write-Host "Close old watcher windows and run tools\start-watcher.bat again." -ForegroundColor Cyan
