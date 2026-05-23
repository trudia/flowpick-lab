param(
  [string]$RepoPath = (Resolve-Path ".").Path,
  [string]$DownloadsPath = "$env:USERPROFILE\Downloads",
  [int]$PollSeconds = 5,
  [switch]$AutoApprove,
  [switch]$NoPush
)

$ErrorActionPreference = "Stop"

function Write-Log($msg, $color = "Gray") {
  $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $msg
  Write-Host $line -ForegroundColor $color

  $logDir = Join-Path $RepoPath ".trendflow-logs"
  if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
  }
  Add-Content -LiteralPath (Join-Path $logDir "watcher.log") -Value $line -Encoding UTF8
}

function Fail($msg) {
  Write-Log "ERROR: $msg" "Red"
  exit 1
}

function Is-FileStable($Path) {
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  try {
    $s1 = (Get-Item -LiteralPath $Path).Length
    Start-Sleep -Seconds 2
    $s2 = (Get-Item -LiteralPath $Path).Length
    return ($s1 -eq $s2 -and $s2 -gt 0)
  } catch {
    return $false
  }
}

function Get-VersionFromZip($ZipPath) {
  try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
      $entry = $zip.Entries | Where-Object { $_.FullName -eq "version.txt" } | Select-Object -First 1
      if (-not $entry) { return "" }
      $reader = New-Object System.IO.StreamReader($entry.Open())
      try {
        $first = $reader.ReadLine()
        return $first
      } finally {
        $reader.Dispose()
      }
    } finally {
      $zip.Dispose()
    }
  } catch {
    return ""
  }
}

function Was-Deployed($ZipPath, $StateFile) {
  if (-not (Test-Path -LiteralPath $StateFile)) { return $false }
  $full = [System.IO.Path]::GetFullPath($ZipPath)
  $lines = Get-Content -LiteralPath $StateFile -Encoding UTF8
  return ($lines -contains $full)
}

function Mark-Deployed($ZipPath, $StateFile) {
  $full = [System.IO.Path]::GetFullPath($ZipPath)
  Add-Content -LiteralPath $StateFile -Value $full -Encoding UTF8
}

$RepoPath = [System.IO.Path]::GetFullPath($RepoPath)
$DownloadsPath = [System.IO.Path]::GetFullPath($DownloadsPath)

if (-not (Test-Path -LiteralPath $RepoPath)) {
  Fail "RepoPath를 찾을 수 없습니다: $RepoPath"
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
  Fail "RepoPath가 Git 저장소가 아닙니다: $RepoPath"
}
if (-not (Test-Path -LiteralPath $DownloadsPath)) {
  Fail "DownloadsPath를 찾을 수 없습니다: $DownloadsPath"
}

$deployScript = Join-Path $RepoPath "tools\deploy-update.ps1"
if (-not (Test-Path -LiteralPath $deployScript)) {
  Fail "deploy-update.ps1을 찾을 수 없습니다: $deployScript"
}

$stateDir = Join-Path $RepoPath ".trendflow-state"
if (-not (Test-Path -LiteralPath $stateDir)) {
  New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}
$stateFile = Join-Path $stateDir "deployed-zips.txt"
if (-not (Test-Path -LiteralPath $stateFile)) {
  New-Item -ItemType File -Path $stateFile -Force | Out-Null
}

Write-Log "TrendFlow 다운로드 폴더 감시 시작" "Cyan"
Write-Log "RepoPath: $RepoPath" "Yellow"
Write-Log "DownloadsPath: $DownloadsPath" "Yellow"
Write-Log "PollSeconds: $PollSeconds" "Yellow"
Write-Log "AutoApprove: $AutoApprove" "Yellow"
Write-Log "NoPush: $NoPush" "Yellow"
Write-Log "종료하려면 이 창에서 Ctrl+C를 누르세요." "Cyan"

while ($true) {
  try {
    $zips = Get-ChildItem -LiteralPath $DownloadsPath -File -Filter "trendflow_site_v*.zip" |
      Sort-Object LastWriteTime -Descending

    foreach ($zip in $zips) {
      $fullZip = [System.IO.Path]::GetFullPath($zip.FullName)

      if (Was-Deployed $fullZip $stateFile) { continue }
      if (-not (Is-FileStable $fullZip)) {
        Write-Log "아직 다운로드 중이거나 파일이 안정화되지 않았습니다: $($zip.Name)" "DarkYellow"
        continue
      }

      $version = Get-VersionFromZip $fullZip
      Write-Log "새 업데이트 ZIP 발견: $($zip.Name)" "Cyan"
      if (-not [string]::IsNullOrWhiteSpace($version)) {
        Write-Log "ZIP 버전: $version" "Yellow"
      }

      $shouldDeploy = $false
      if ($AutoApprove) {
        $shouldDeploy = $true
      } else {
        $answer = Read-Host "이 ZIP을 배포할까요? Y/N"
        if ($answer -in @("Y","y","YES","yes","예","ㅇ")) {
          $shouldDeploy = $true
        }
      }

      if (-not $shouldDeploy) {
        Write-Log "사용자가 배포를 취소했습니다: $($zip.Name)" "Yellow"
        Mark-Deployed $fullZip $stateFile
        continue
      }

      Write-Log "배포 시작: $($zip.Name)" "Cyan"

      $argsList = @(
        "-ExecutionPolicy", "Bypass",
        "-File", $deployScript,
        "-ZipPath", $fullZip,
        "-RepoPath", $RepoPath
      )
      if ($NoPush) { $argsList += "-NoPush" }

      & powershell @argsList
      if ($LASTEXITCODE -ne 0) {
        Write-Log "배포 스크립트가 오류로 종료되었습니다. 이 ZIP은 재시도 가능하도록 기록하지 않습니다." "Red"
      } else {
        Write-Log "배포 완료: $($zip.Name)" "Green"
        Mark-Deployed $fullZip $stateFile
      }

      break
    }
  } catch {
    Write-Log "감시 중 오류: $($_.Exception.Message)" "Red"
  }

  Start-Sleep -Seconds $PollSeconds
}
