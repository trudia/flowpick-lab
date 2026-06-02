[CmdletBinding()]
param(
  [string[]]$Urls = @(
    "https://trend.it.kr/sitemap.xml"
  ),

  [switch]$SkipIndexNow,

  [switch]$SkipGoogle,

  [switch]$InspectGoogle,

  [string]$GoogleSiteUrl = "sc-domain:trend.it.kr",

  [string]$GoogleReportPath = ".trendflow-google\latest-url-inspection.json"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Normalize-UrlList {
  param([string[]]$Values)

  $normalized = New-Object System.Collections.Generic.List[string]
  foreach ($value in $Values) {
    if ([string]::IsNullOrWhiteSpace($value)) {
      continue
    }

    foreach ($part in ($value -split ",")) {
      $trimmed = $part.Trim()
      if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
        $normalized.Add($trimmed)
      }
    }
  }

  return @($normalized | Select-Object -Unique)
}

$Urls = Normalize-UrlList -Values $Urls
$summary = New-Object System.Collections.Generic.List[object]

if (-not $SkipIndexNow) {
  try {
    & (Join-Path $PSScriptRoot "submit-indexnow.ps1") -Urls $Urls
    $summary.Add([PSCustomObject]@{
      target = "indexnow"
      status = "ok"
      detail = "Submitted URL list to Naver and Bing IndexNow endpoints."
    })
  } catch {
    $summary.Add([PSCustomObject]@{
      target = "indexnow"
      status = "error"
      detail = $_.Exception.Message
    })
  }
}

if (-not $SkipGoogle) {
  try {
    & (Join-Path $PSScriptRoot "google-search-console.ps1") -Mode SubmitSitemap -SiteUrl $GoogleSiteUrl
    $summary.Add([PSCustomObject]@{
      target = "google_sitemap"
      status = "ok"
      detail = "Submitted sitemap to Google Search Console API."
    })
  } catch {
    $summary.Add([PSCustomObject]@{
      target = "google_sitemap"
      status = "needs_setup"
      detail = $_.Exception.Message
    })
  }

  if ($InspectGoogle) {
    $inspectUrls = @($Urls | Where-Object { $_ -match "^https://trend\.it\.kr/(posts|categories)/" })
    if ($inspectUrls.Count -gt 0) {
      try {
        & (Join-Path $PSScriptRoot "google-search-console.ps1") `
          -Mode InspectUrl `
          -SiteUrl $GoogleSiteUrl `
          -Urls $inspectUrls `
          -OutputPath $GoogleReportPath

        $summary.Add([PSCustomObject]@{
          target = "google_url_inspection"
          status = "ok"
          detail = "Saved Google URL inspection report to $GoogleReportPath."
        })
      } catch {
        $summary.Add([PSCustomObject]@{
          target = "google_url_inspection"
          status = "needs_setup"
          detail = $_.Exception.Message
        })
      }
    }
  }
}

$summary | Format-Table -AutoSize

$errors = @($summary | Where-Object { $_.status -eq "error" })
if ($errors.Count -gt 0) {
  exit 1
}
