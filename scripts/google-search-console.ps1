[CmdletBinding()]
param(
  [ValidateSet("SubmitSitemap", "InspectUrl", "InspectRecent", "TestConfig")]
  [string]$Mode = "SubmitSitemap",

  [string]$SiteUrl = "https://trend.it.kr/",

  [string]$SitemapUrl = "https://trend.it.kr/sitemap.xml",

  [string[]]$Urls = @(),

  [int]$RecentCount = 5,

  [string]$LanguageCode = "ko-KR",

  [string]$AccessToken = "",

  [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-DotEnvValues {
  if ($script:DotEnvLoaded) {
    return $script:DotEnvValues
  }

  $script:DotEnvLoaded = $true
  $script:DotEnvValues = @{}

  $candidatePaths = @()
  if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $candidatePaths += (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path ".env")
  }
  $candidatePaths += (Join-Path (Resolve-Path ".").Path ".env")

  foreach ($path in ($candidatePaths | Select-Object -Unique)) {
    if (-not (Test-Path -LiteralPath $path)) {
      continue
    }

    foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
      $trimmed = $line.Trim()
      if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
        continue
      }

      $parts = $trimmed -split "=", 2
      if ($parts.Count -ne 2) {
        continue
      }

      $name = $parts[0].Trim()
      $value = $parts[1].Trim()
      if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
        $value = $value.Substring(1, $value.Length - 2)
      }

      if (-not [string]::IsNullOrWhiteSpace($name)) {
        $script:DotEnvValues[$name] = $value
      }
    }
  }

  return $script:DotEnvValues
}

function Get-EnvValue {
  param([string[]]$Names)

  foreach ($name in $Names) {
    foreach ($scope in @("Process", "User", "Machine")) {
      $value = [Environment]::GetEnvironmentVariable($name, $scope)
      if (-not [string]::IsNullOrWhiteSpace($value)) {
        return [PSCustomObject]@{
          Name = $name
          Scope = $scope
          Value = $value
        }
      }
    }

    $dotEnvValues = Get-DotEnvValues
    if ($dotEnvValues.ContainsKey($name) -and -not [string]::IsNullOrWhiteSpace($dotEnvValues[$name])) {
      return [PSCustomObject]@{
        Name = $name
        Scope = ".env"
        Value = $dotEnvValues[$name]
      }
    }
  }

  return $null
}

function Get-GoogleAccessToken {
  if (-not [string]::IsNullOrWhiteSpace($AccessToken)) {
    return [PSCustomObject]@{
      Token = $AccessToken
      Source = "parameter"
    }
  }

  $tokenValue = Get-EnvValue @("GOOGLE_SEARCH_CONSOLE_ACCESS_TOKEN", "GSC_ACCESS_TOKEN")
  if ($null -ne $tokenValue) {
    return [PSCustomObject]@{
      Token = $tokenValue.Value
      Source = "$($tokenValue.Name) [$($tokenValue.Scope)]"
    }
  }

  $clientId = Get-EnvValue @("GOOGLE_SEARCH_CONSOLE_CLIENT_ID", "GSC_CLIENT_ID")
  $clientSecret = Get-EnvValue @("GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET", "GSC_CLIENT_SECRET")
  $refreshToken = Get-EnvValue @("GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN", "GSC_REFRESH_TOKEN")

  if ($null -eq $clientId -or $null -eq $clientSecret -or $null -eq $refreshToken) {
    throw @"
Google Search Console credentials were not found.

Use either a temporary access token:
  GOOGLE_SEARCH_CONSOLE_ACCESS_TOKEN

Or a refresh-token setup:
  GOOGLE_SEARCH_CONSOLE_CLIENT_ID
  GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET
  GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN

The OAuth token needs this scope for sitemap submission:
  https://www.googleapis.com/auth/webmasters

For URL inspection only, this readonly scope is also accepted:
  https://www.googleapis.com/auth/webmasters.readonly

Store these values in local environment variables or in the workspace .env file.
.env is ignored by git. Do not commit Google client secrets or refresh tokens.
"@
  }

  $body = @{
    client_id = $clientId.Value
    client_secret = $clientSecret.Value
    refresh_token = $refreshToken.Value
    grant_type = "refresh_token"
  }

  $response = Invoke-RestMethod `
    -Method Post `
    -Uri "https://oauth2.googleapis.com/token" `
    -ContentType "application/x-www-form-urlencoded" `
    -Body $body `
    -TimeoutSec 30

  if ([string]::IsNullOrWhiteSpace($response.access_token)) {
    throw "Google OAuth token endpoint did not return an access token."
  }

  return [PSCustomObject]@{
    Token = $response.access_token
    Source = "refresh token [$($refreshToken.Scope)]"
  }
}

function Invoke-GoogleApi {
  param(
    [ValidateSet("GET", "POST", "PUT")]
    [string]$Method,
    [string]$Uri,
    [object]$Body = $null
  )

  $access = Get-GoogleAccessToken
  $headers = @{
    Authorization = "Bearer $($access.Token)"
  }

  if ($null -eq $Body) {
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -TimeoutSec 30
  }

  $jsonBody = $Body | ConvertTo-Json -Depth 10 -Compress
  return Invoke-RestMethod `
    -Method $Method `
    -Uri $Uri `
    -Headers $headers `
    -ContentType "application/json; charset=utf-8" `
    -Body $jsonBody `
    -TimeoutSec 30
}

function Submit-GoogleSitemap {
  $site = [System.Uri]::EscapeDataString($SiteUrl)
  $feed = [System.Uri]::EscapeDataString($SitemapUrl)
  $uri = "https://www.googleapis.com/webmasters/v3/sites/$site/sitemaps/$feed"

  Invoke-GoogleApi -Method Put -Uri $uri | Out-Null

  return [PSCustomObject]@{
    action = "submit_sitemap"
    siteUrl = $SiteUrl
    sitemapUrl = $SitemapUrl
    status = "submitted"
  }
}

function Inspect-GoogleUrl {
  param([string]$Url)

  $body = [ordered]@{
    inspectionUrl = $Url
    siteUrl = $SiteUrl
    languageCode = $LanguageCode
  }

  $response = Invoke-GoogleApi `
    -Method Post `
    -Uri "https://searchconsole.googleapis.com/v1/urlInspection/index:inspect" `
    -Body $body

  $indexStatus = $response.inspectionResult.indexStatusResult
  $mobileStatus = $response.inspectionResult.mobileUsabilityResult

  return [PSCustomObject]@{
    action = "inspect_url"
    url = $Url
    verdict = $indexStatus.verdict
    coverageState = $indexStatus.coverageState
    indexingState = $indexStatus.indexingState
    pageFetchState = $indexStatus.pageFetchState
    robotsTxtState = $indexStatus.robotsTxtState
    lastCrawlTime = $indexStatus.lastCrawlTime
    googleCanonical = $indexStatus.googleCanonical
    userCanonical = $indexStatus.userCanonical
    sitemap = if ($indexStatus.sitemap) { ($indexStatus.sitemap -join ", ") } else { "" }
    mobileVerdict = if ($null -ne $mobileStatus) { $mobileStatus.verdict } else { "" }
  }
}

function Get-RecentPostUrls {
  $postsPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path "content\posts.json"
  if (-not (Test-Path -LiteralPath $postsPath)) {
    throw "content/posts.json was not found."
  }

  $posts = Get-Content -LiteralPath $postsPath -Encoding UTF8 -Raw | ConvertFrom-Json
  return @($posts | Select-Object -First $RecentCount | ForEach-Object { "https://trend.it.kr/posts/$($_.slug)" })
}

function Write-StructuredOutput {
  param([object[]]$Results)

  if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent)) {
      New-Item -ItemType Directory -Path $parent | Out-Null
    }

    $Results | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
  }

  $Results | Format-Table -AutoSize
}

$results = New-Object System.Collections.Generic.List[object]

switch ($Mode) {
  "TestConfig" {
    $access = Get-GoogleAccessToken
    $results.Add([PSCustomObject]@{
      action = "test_config"
      status = "ok"
      tokenSource = $access.Source
      siteUrl = $SiteUrl
    })
  }
  "SubmitSitemap" {
    $results.Add((Submit-GoogleSitemap))
  }
  "InspectUrl" {
    if (-not $Urls -or $Urls.Count -eq 0) {
      throw "InspectUrl mode requires at least one -Urls value."
    }

    foreach ($url in $Urls) {
      $results.Add((Inspect-GoogleUrl -Url $url))
    }
  }
  "InspectRecent" {
    foreach ($url in (Get-RecentPostUrls)) {
      $results.Add((Inspect-GoogleUrl -Url $url))
    }
  }
}

Write-StructuredOutput -Results $results
