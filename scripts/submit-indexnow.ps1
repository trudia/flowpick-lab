param(
  [string]$HostName = "trend.it.kr",
  [string]$Key = "6c8e7b92-2b54-4c6f-a111-7f64204dbe5a",
  [string[]]$Urls = @(
    "https://trend.it.kr/posts/desk-cable-small-items-organization-guide/",
    "https://trend.it.kr/posts/fan-vs-circulator-when-to-choose/",
    "https://trend.it.kr/categories/trend-shopping/",
    "https://trend.it.kr/sitemap.xml"
  ),
  [string[]]$Endpoints = @(
    "https://searchadvisor.naver.com/indexnow",
    "https://www.bing.com/indexnow"
  )
)

$ErrorActionPreference = "Stop"

if (-not $Urls -or $Urls.Count -eq 0) {
  throw "At least one URL is required."
}

$keyLocation = "https://$HostName/$Key.txt"
$payload = @{
  host = $HostName
  key = $Key
  keyLocation = $keyLocation
  urlList = $Urls
}

$json = $payload | ConvertTo-Json -Depth 4
$results = New-Object System.Collections.Generic.List[object]

foreach ($endpoint in $Endpoints) {
  try {
    $response = Invoke-WebRequest `
      -Uri $endpoint `
      -Method Post `
      -ContentType "application/json; charset=utf-8" `
      -Body $json `
      -UseBasicParsing `
      -TimeoutSec 30

    $results.Add([pscustomobject]@{
      endpoint = $endpoint
      status = [int]$response.StatusCode
      result = "ok"
    })
  } catch {
    $statusCode = $null
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
      $statusCode = [int]$_.Exception.Response.StatusCode
    }
    $results.Add([pscustomobject]@{
      endpoint = $endpoint
      status = $statusCode
      result = "error"
      message = $_.Exception.Message
    })
  }
}

$results | Format-Table -AutoSize

if ($results.Where({ $_.result -eq "error" }).Count -gt 0) {
  exit 1
}
