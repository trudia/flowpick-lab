param(
  [string]$RepoPath = (Resolve-Path ".").Path,
  [string]$DownloadsPath = "$env:USERPROFILE\Downloads",
  [switch]$NoPush,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Fail($msg) {
  Write-Host ""
  Write-Host "ERROR: $msg" -ForegroundColor Red
  exit 1
}

$RepoPath = [System.IO.Path]::GetFullPath($RepoPath)

if (-not (Test-Path -LiteralPath $DownloadsPath)) {
  Fail "다운로드 폴더를 찾지 못했습니다: $DownloadsPath"
}

$zips = Get-ChildItem -LiteralPath $DownloadsPath -File -Filter "trendflow_site_v*.zip" |
  Sort-Object LastWriteTime -Descending

if ($zips.Count -eq 0) {
  Fail "다운로드 폴더에서 trendflow_site_v*.zip 파일을 찾지 못했습니다."
}

$latest = $zips[0]
Write-Host ""
Write-Host "가장 최근 업데이트 ZIP:" -ForegroundColor Cyan
Write-Host $latest.FullName -ForegroundColor Yellow
Write-Host ""

$answer = Read-Host "이 파일로 배포할까요? (Y/N)"
if ($answer -notin @("Y","y","YES","yes","예","ㅇ")) {
  Write-Host "취소했습니다." -ForegroundColor Yellow
  exit 0
}

$script = Join-Path $PSScriptRoot "deploy-update.ps1"
if (-not (Test-Path -LiteralPath $script)) {
  Fail "deploy-update.ps1을 찾지 못했습니다: $script"
}

$argsList = @(
  "-ExecutionPolicy", "Bypass",
  "-File", $script,
  "-ZipPath", $latest.FullName,
  "-RepoPath", $RepoPath
)

if ($NoPush) { $argsList += "-NoPush" }
if ($DryRun) { $argsList += "-DryRun" }

& powershell @argsList
