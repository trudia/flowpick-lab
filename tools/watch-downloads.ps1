﻿﻿param(
  [string]$RepoPath = (Resolve-Path ".").Path,
  [string]$DownloadsPath = "$env:USERPROFILE\Downloads",
  [int]$PollSeconds = 5,
  [switch]$AutoApprove,
  [switch]$NoPush
)

$ErrorActionPreference = "Stop"

function Write-Log($Message, $Color = "Gray") {
  $Line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
  Write-Host $Line -ForegroundColor $Color

  $LogDir = Join-Path $RepoPath ".trendflow-logs"
  if (-not (Test-Path -LiteralPath $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
  }
  Add-Content -LiteralPath (Join-Path $LogDir "watcher.log") -Value $Line -Encoding UTF8
}

function Fail($Message) {
  Write-Log "ERROR: $Message" "Red"
  exit 1
}

function Test-AnswerYes($Answer) {
  if ([string]::IsNullOrWhiteSpace($Answer)) { return $false }
  $Normalized = $Answer.Trim().ToUpperInvariant()
  return ($Normalized -eq "Y" -or $Normalized -eq "YES")
}

function Is-FileStable($Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  try {
    $S1 = (Get-Item -LiteralPath $Path).Length
    Start-Sleep -Seconds 2
    $S2 = (Get-Item -LiteralPath $Path).Length
    return ($S1 -eq $S2 -and $S2 -gt 0)
  } catch {
    return $false
  }
}

function Get-VersionFromZip($ZipPath) {
  try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    $Zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
      $Entry = $Zip.Entries | Where-Object { $_.FullName -eq "version.txt" } | Select-Object -First 1
      if (-not $Entry) { return "" }
      $Reader = New-Object System.IO.StreamReader($Entry.Open())
      try {
        return $Reader.ReadLine()
      } finally {
        $Reader.Dispose()
      }
    } finally {
      $Zip.Dispose()
    }
  } catch {
    return ""
  }
}

function Was-Deployed($ZipPath, $StateFile) {
  if (-not (Test-Path -LiteralPath $StateFile)) { return $false }
  $Full = [System.IO.Path]::GetFullPath($ZipPath)
  $Lines = Get-Content -LiteralPath $StateFile -Encoding UTF8
  return ($Lines -contains $Full)
}

function Mark-Deployed($ZipPath, $StateFile) {
  $Full = [System.IO.Path]::GetFullPath($ZipPath)
  Add-Content -LiteralPath $StateFile -Value $Full -Encoding UTF8
}

$RepoPath = [System.IO.Path]::GetFullPath($RepoPath)
$DownloadsPath = [System.IO.Path]::GetFullPath($DownloadsPath)

if (-not (Test-Path -LiteralPath $RepoPath)) {
  Fail "RepoPath not found: $RepoPath"
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
  Fail "RepoPath is not a Git repository: $RepoPath"
}
if (-not (Test-Path -LiteralPath $DownloadsPath)) {
  Fail "DownloadsPath not found: $DownloadsPath"
}

$DeployScript = Join-Path $RepoPath "tools\deploy-update.ps1"
if (-not (Test-Path -LiteralPath $DeployScript)) {
  Fail "deploy-update.ps1 not found: $DeployScript"
}

$StateDir = Join-Path $RepoPath ".trendflow-state"
if (-not (Test-Path -LiteralPath $StateDir)) {
  New-Item -ItemType Directory -Path $StateDir -Force | Out-Null
}
$StateFile = Join-Path $StateDir "deployed-zips.txt"
if (-not (Test-Path -LiteralPath $StateFile)) {
  New-Item -ItemType File -Path $StateFile -Force | Out-Null
}

Write-Log "TrendFlow download watcher started" "Cyan"
Write-Log "RepoPath: $RepoPath" "Yellow"
Write-Log "DownloadsPath: $DownloadsPath" "Yellow"
Write-Log "PollSeconds: $PollSeconds" "Yellow"
Write-Log "AutoApprove: $AutoApprove" "Yellow"
Write-Log "NoPush: $NoPush" "Yellow"
Write-Log "Press Ctrl+C in this window to stop." "Cyan"

while ($true) {
  try {
    $Zips = Get-ChildItem -LiteralPath $DownloadsPath -File -Filter "trendflow_site_v*.zip" |
      Sort-Object LastWriteTime -Descending

    foreach ($Zip in $Zips) {
      $FullZip = [System.IO.Path]::GetFullPath($Zip.FullName)

      if (Was-Deployed $FullZip $StateFile) { continue }
      if (-not (Is-FileStable $FullZip)) {
        Write-Log "File is still downloading or unstable: $($Zip.Name)" "DarkYellow"
        continue
      }

      $Version = Get-VersionFromZip $FullZip
      Write-Log "New update ZIP detected: $($Zip.Name)" "Cyan"
      if (-not [string]::IsNullOrWhiteSpace($Version)) {
        Write-Log "ZIP version: $Version" "Yellow"
      }

      $ShouldDeploy = $false
      if ($AutoApprove) {
        $ShouldDeploy = $true
      } else {
        $Answer = Read-Host "Deploy this ZIP? Type Y or N"
        if (Test-AnswerYes $Answer) {
          $ShouldDeploy = $true
        }
      }

      if (-not $ShouldDeploy) {
        Write-Log "Deployment skipped by user: $($Zip.Name)" "Yellow"
        Mark-Deployed $FullZip $StateFile
        continue
      }

      Write-Log "Deployment started: $($Zip.Name)" "Cyan"

      $ArgsList = @(
        "-ExecutionPolicy", "Bypass",
        "-File", $DeployScript,
        "-ZipPath", $FullZip,
        "-RepoPath", $RepoPath
      )
      if ($NoPush) { $ArgsList += "-NoPush" }

      & powershell @ArgsList
      if ($LASTEXITCODE -ne 0) {
        Write-Log "Deployment script exited with an error. This ZIP was not marked as deployed." "Red"
        Write-Log "Waiting 30 seconds before retrying the same ZIP." "Yellow"
        Start-Sleep -Seconds 30
      } else {
        Write-Log "Deployment completed: $($Zip.Name)" "Green"
        Mark-Deployed $FullZip $StateFile
      }

      break
    }
  } catch {
    Write-Log "Watcher error: $($_.Exception.Message)" "Red"
  }

  Start-Sleep -Seconds $PollSeconds
}
