param(
  [string]$Url = "https://trend.it.kr/version.txt",
  [string]$Expected = ""
)

$ErrorActionPreference = "Stop"

Write-Host "라이브 버전 확인 중: $Url" -ForegroundColor Cyan

try {
  $result = Invoke-WebRequest -Uri ($Url + "?t=" + [DateTimeOffset]::Now.ToUnixTimeSeconds()) -UseBasicParsing -TimeoutSec 20
  $text = $result.Content.Trim()
  $firstLine = ($text -split "`n")[0].Trim()
  Write-Host "라이브 version.txt 첫 줄:" -ForegroundColor Yellow
  Write-Host $firstLine

  if (-not [string]::IsNullOrWhiteSpace($Expected)) {
    if ($firstLine -eq $Expected) {
      Write-Host "정상 반영됨" -ForegroundColor Green
    } else {
      Write-Host "예상 버전과 다릅니다." -ForegroundColor Red
      Write-Host "Expected: $Expected" -ForegroundColor Red
      exit 1
    }
  }
} catch {
  Write-Host "라이브 버전 확인 실패: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
