[CmdletBinding()]
param(
  [ValidateSet("Test", "Search", "Deeplink")]
  [string]$Mode = "Test",

  [string]$Keyword = "USB",

  [int]$Limit = 5,

  [string[]]$Url = @(),

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

function Get-CoupangCredential {
  $access = Get-EnvValue @("COUPANG_PARTNERS_ACCESS_KEY", "COUPANG_ACCESS_KEY")
  $secret = Get-EnvValue @("COUPANG_PARTNERS_SECRET_KEY", "COUPANG_SECRET_KEY", "COUPANG_SECRET")
  $subId = Get-EnvValue @("COUPANG_PARTNERS_SUB_ID", "COUPANG_SUB_ID")

  if ($null -eq $access -or $null -eq $secret) {
    throw @"
Coupang Partners API keys were not found.

Expected environment variables or .env values:
  COUPANG_PARTNERS_ACCESS_KEY
  COUPANG_PARTNERS_SECRET_KEY
  COUPANG_PARTNERS_SUB_ID   optional

PowerShell example:
  setx COUPANG_PARTNERS_ACCESS_KEY "your-access-key"
  setx COUPANG_PARTNERS_SECRET_KEY "your-secret-key"
  setx COUPANG_PARTNERS_SUB_ID "trendflow"

After setx, restart Codex or the terminal so the new variables are visible.
Alternatively, create a local .env file in the TrendFlow workspace. It is ignored by git.
"@
  }

  return [PSCustomObject]@{
    AccessKey = $access.Value
    AccessKeyName = $access.Name
    AccessKeyScope = $access.Scope
    SecretKey = $secret.Value
    SecretKeyName = $secret.Name
    SecretKeyScope = $secret.Scope
    SubId = if ($null -ne $subId) { $subId.Value } else { "" }
    SubIdName = if ($null -ne $subId) { $subId.Name } else { "" }
    SubIdScope = if ($null -ne $subId) { $subId.Scope } else { "" }
  }
}

function New-CoupangAuthorization {
  param(
    [string]$AccessKey,
    [string]$SecretKey,
    [string]$Method,
    [string]$Path,
    [string]$Query = ""
  )

  $signedDate = [DateTime]::UtcNow.ToString("yyMMddTHHmmssZ", [System.Globalization.CultureInfo]::InvariantCulture)
  $message = "$signedDate$($Method.ToUpperInvariant())$Path$Query"

  $encoding = [System.Text.Encoding]::UTF8
  $hmac = [System.Security.Cryptography.HMACSHA256]::new($encoding.GetBytes($SecretKey))
  try {
    $hash = $hmac.ComputeHash($encoding.GetBytes($message))
  } finally {
    $hmac.Dispose()
  }

  $signature = -join ($hash | ForEach-Object { $_.ToString("x2") })
  return "CEA algorithm=HmacSHA256,access-key=$AccessKey,signed-date=$signedDate,signature=$signature"
}

function Invoke-CoupangPartnersApi {
  param(
    [string]$Method,
    [string]$Path,
    [string]$Query = "",
    [object]$Body = $null
  )

  $credential = Get-CoupangCredential
  $authorization = New-CoupangAuthorization `
    -AccessKey $credential.AccessKey `
    -SecretKey $credential.SecretKey `
    -Method $Method `
    -Path $Path `
    -Query $Query

  $uri = "https://api-gateway.coupang.com$Path"
  if (-not [string]::IsNullOrWhiteSpace($Query)) {
    $uri = "$uri`?$Query"
  }

  $headers = @{
    Authorization = $authorization
  }

  if ($Method.ToUpperInvariant() -eq "GET") {
    return Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
  }

  $jsonBody = if ($null -eq $Body) { "{}" } else { $Body | ConvertTo-Json -Depth 10 -Compress }
  return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json" -Body $jsonBody
}

function Write-ApiOutput {
  param([object]$Value)

  $json = $Value | ConvertTo-Json -Depth 20
  if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent)) {
      New-Item -ItemType Directory -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $OutputPath -Value $json -Encoding UTF8
  }

  Write-Output $json
}

function Invoke-Search {
  $safeKeyword = [System.Uri]::EscapeDataString($Keyword)
  $safeLimit = [Math]::Max(1, [Math]::Min($Limit, 10))
  $path = "/v2/providers/affiliate_open_api/apis/openapi/products/search"
  $query = "keyword=$safeKeyword&limit=$safeLimit"
  return Invoke-CoupangPartnersApi -Method "GET" -Path $path -Query $query
}

function Invoke-Deeplink {
  if ($Url.Count -eq 0) {
    throw "Deeplink mode requires at least one -Url value."
  }

  $credential = Get-CoupangCredential
  $path = "/v2/providers/affiliate_open_api/apis/openapi/v1/deeplink"
  $body = [ordered]@{
    coupangUrls = $Url
  }

  if (-not [string]::IsNullOrWhiteSpace($credential.SubId)) {
    $body.subId = $credential.SubId
  }

  try {
    return Invoke-CoupangPartnersApi -Method "POST" -Path $path -Body $body
  } catch {
    if ($body.Contains("subId")) {
      $body.Remove("subId")
      return Invoke-CoupangPartnersApi -Method "POST" -Path $path -Body $body
    }
    throw
  }
}

$credentialForStatus = Get-CoupangCredential

switch ($Mode) {
  "Test" {
    $response = Invoke-Search
    $count = 0
    if ($null -ne $response.data -and $null -ne $response.data.productData) {
      $count = @($response.data.productData).Count
    }

    Write-ApiOutput ([ordered]@{
      ok = $true
      mode = "Test"
      credential = [ordered]@{
        accessKeyName = $credentialForStatus.AccessKeyName
        accessKeyScope = $credentialForStatus.AccessKeyScope
        secretKeyName = $credentialForStatus.SecretKeyName
        secretKeyScope = $credentialForStatus.SecretKeyScope
        subIdSet = -not [string]::IsNullOrWhiteSpace($credentialForStatus.SubId)
      }
      keyword = $Keyword
      productCount = $count
    })
  }
  "Search" {
    Write-ApiOutput (Invoke-Search)
  }
  "Deeplink" {
    Write-ApiOutput (Invoke-Deeplink)
  }
}
