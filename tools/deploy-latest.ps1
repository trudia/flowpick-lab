﻿param(
  [string]$RepoPath = (Resolve-Path ".").Path,
  [string]$DownloadsPath = "$env:USERPROFILE\Downloads",
  [switch]$NoPush,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Fail($Message) {
  Write-Host ""
  Write-Host "ERROR: $Message" -ForegroundColor Red
  exit 1
}

function Test-AnswerYes($Answer) {
  if ([string]::IsNullOrWhiteSpace($Answer)) { return $false }
  $Normalized = $Answer.Trim().ToUpperInvariant()
  return ($Normalized -eq "Y" -or $Normalized -eq "YES")
}

$RepoPath = [System.IO.Path]::GetFullPath($RepoPath)

if (-not (Test-Path -LiteralPath $DownloadsPath)) {
  Fail "Downloads folder not found: $DownloadsPath"
}

$Zips = Get-ChildItem -LiteralPath $DownloadsPath -File -Filter "trendflow_site_v*.zip" |
  Sort-Object LastWriteTime -Descending

if ($Zips.Count -eq 0) {
  Fail "No trendflow_site_v*.zip file found in Downloads."
}

$Latest = $Zips[0]
Write-Host ""
Write-Host "Latest update ZIP:" -ForegroundColor Cyan
Write-Host $Latest.FullName -ForegroundColor Yellow
Write-Host ""

$Answer = Read-Host "Deploy this file? Type Y or N"
if (-not (Test-AnswerYes $Answer)) {
  Write-Host "Canceled." -ForegroundColor Yellow
  exit 0
}

$Script = Join-Path $PSScriptRoot "deploy-update.ps1"
if (-not (Test-Path -LiteralPath $Script)) {
  Fail "deploy-update.ps1 not found: $Script"
}

$ArgsList = @(
  "-ExecutionPolicy", "Bypass",
  "-File", $Script,
  "-ZipPath", $Latest.FullName,
  "-RepoPath", $RepoPath
)

if ($NoPush) { $ArgsList += "-NoPush" }
if ($DryRun) { $ArgsList += "-DryRun" }

& powershell @ArgsList
