[CmdletBinding()]
param(
  [string]$ClientId = "",

  [string]$ClientSecret = "",

  [int]$Port = 53682,

  [string]$Scope = "https://www.googleapis.com/auth/webmasters",

  [switch]$SaveToEnv
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-DotEnvValues {
  $values = @{}
  $path = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path ".env"

  if (-not (Test-Path -LiteralPath $path)) {
    return $values
  }

  foreach ($line in (Get-Content -LiteralPath $path -Encoding UTF8)) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#") -or -not $trimmed.Contains("=")) {
      continue
    }

    $parts = $trimmed -split "=", 2
    $name = $parts[0].Trim()
    $value = $parts[1].Trim()
    if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
      $value = $value.Substring(1, $value.Length - 2)
    }

    if (-not [string]::IsNullOrWhiteSpace($name)) {
      $values[$name] = $value
    }
  }

  return $values
}

function Get-EnvOrDotEnvValue {
  param(
    [string[]]$Names
  )

  foreach ($name in $Names) {
    foreach ($scopeName in @("Process", "User", "Machine")) {
      $value = [Environment]::GetEnvironmentVariable($name, $scopeName)
      if (-not [string]::IsNullOrWhiteSpace($value)) {
        return $value
      }
    }
  }

  $dotEnv = Get-DotEnvValues
  foreach ($name in $Names) {
    if ($dotEnv.ContainsKey($name) -and -not [string]::IsNullOrWhiteSpace($dotEnv[$name])) {
      return $dotEnv[$name]
    }
  }

  return ""
}

function Set-DotEnvValue {
  param(
    [string]$Name,
    [string]$Value
  )

  $path = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path ".env"
  $lines = @()
  if (Test-Path -LiteralPath $path) {
    $lines = @(Get-Content -LiteralPath $path -Encoding UTF8)
  }

  $escaped = $Value.Replace('"', '\"')
  $newLine = "$Name=`"$escaped`""
  $updated = $false
  $next = foreach ($line in $lines) {
    if ($line -match "^\s*$([regex]::Escape($Name))\s*=") {
      $updated = $true
      $newLine
    } else {
      $line
    }
  }

  if (-not $updated) {
    $next += $newLine
  }

  Set-Content -LiteralPath $path -Value $next -Encoding UTF8
}

$ClientId = if ([string]::IsNullOrWhiteSpace($ClientId)) {
  Get-EnvOrDotEnvValue @("GOOGLE_SEARCH_CONSOLE_CLIENT_ID", "GSC_CLIENT_ID")
} else {
  $ClientId
}

$ClientSecret = if ([string]::IsNullOrWhiteSpace($ClientSecret)) {
  Get-EnvOrDotEnvValue @("GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET", "GSC_CLIENT_SECRET")
} else {
  $ClientSecret
}

if ([string]::IsNullOrWhiteSpace($ClientId) -or [string]::IsNullOrWhiteSpace($ClientSecret)) {
  throw @"
Google OAuth client values were not found.

Create an OAuth Client ID in Google Cloud Console:
  Application type: Desktop app

Then put these values in local .env or environment variables:
  GOOGLE_SEARCH_CONSOLE_CLIENT_ID
  GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET

.env is ignored by git.
"@
}

$redirectUri = "http://127.0.0.1:$Port/"
$stateBytes = New-Object byte[] 18
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
  $rng.GetBytes($stateBytes)
} finally {
  $rng.Dispose()
}
$state = [Convert]::ToBase64String($stateBytes).Replace("+", "-").Replace("/", "_").TrimEnd("=")

$query = @{
  client_id = $ClientId
  redirect_uri = $redirectUri
  response_type = "code"
  scope = $Scope
  access_type = "offline"
  prompt = "consent"
  state = $state
} | ForEach-Object { $_ }

$queryString = ($query.GetEnumerator() | ForEach-Object {
  "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString([string]$_.Value))"
}) -join "&"

$authUrl = "https://accounts.google.com/o/oauth2/v2/auth?$queryString"
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($redirectUri)

try {
  $listener.Start()
} catch {
  throw "Could not start local redirect listener at $redirectUri. Try another -Port value. $($_.Exception.Message)"
}

Write-Host "Opening Google authorization page..."
Write-Host "If the browser does not open, paste this URL into Chrome:"
Write-Host $authUrl

Start-Process $authUrl | Out-Null

try {
  $context = $listener.GetContext()
  $request = $context.Request
  $response = $context.Response

  $code = $request.QueryString["code"]
  $returnedState = $request.QueryString["state"]
  $authError = $request.QueryString["error"]

  $html = "<!doctype html><meta charset='utf-8'><title>TrendFlow Google OAuth</title><body style='font-family:sans-serif;padding:32px'><h1>TrendFlow Google OAuth</h1><p>인증이 완료되었습니다. 이 창은 닫아도 됩니다.</p></body>"
  if (-not [string]::IsNullOrWhiteSpace($authError)) {
    $html = "<!doctype html><meta charset='utf-8'><title>TrendFlow Google OAuth</title><body style='font-family:sans-serif;padding:32px'><h1>인증 실패</h1><p>$authError</p></body>"
  }

  $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
  $response.ContentType = "text/html; charset=utf-8"
  $response.ContentLength64 = $buffer.Length
  $response.OutputStream.Write($buffer, 0, $buffer.Length)
  $response.OutputStream.Close()

  if (-not [string]::IsNullOrWhiteSpace($authError)) {
    throw "Google authorization failed: $authError"
  }

  if ([string]::IsNullOrWhiteSpace($code)) {
    throw "Google did not return an authorization code."
  }

  if ($returnedState -ne $state) {
    throw "OAuth state mismatch. Please retry."
  }

  $tokenBody = @{
    code = $code
    client_id = $ClientId
    client_secret = $ClientSecret
    redirect_uri = $redirectUri
    grant_type = "authorization_code"
  }

  try {
    $tokenResponse = Invoke-RestMethod `
      -Method Post `
      -Uri "https://oauth2.googleapis.com/token" `
      -ContentType "application/x-www-form-urlencoded" `
      -Body $tokenBody `
      -TimeoutSec 30
  } catch {
    $details = $_.Exception.Message
    if ($_.Exception.Response) {
      try {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = [System.IO.StreamReader]::new($stream)
        $responseBody = $reader.ReadToEnd()
        if (-not [string]::IsNullOrWhiteSpace($responseBody)) {
          $details = "$details $responseBody"
        }
      } catch {
        $details = $_.Exception.Message
      }
    }

    throw "Google token exchange failed. Check that CLIENT_ID and CLIENT_SECRET are from the same Desktop app OAuth client. Details: $details"
  }

  if ([string]::IsNullOrWhiteSpace($tokenResponse.refresh_token)) {
    throw "Google did not return a refresh token. Re-run with consent prompt, or remove the app's prior access from your Google account and retry."
  }

  if ($SaveToEnv) {
    Set-DotEnvValue -Name "GOOGLE_SEARCH_CONSOLE_CLIENT_ID" -Value $ClientId
    Set-DotEnvValue -Name "GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET" -Value $ClientSecret
    Set-DotEnvValue -Name "GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN" -Value $tokenResponse.refresh_token
    Write-Host "Saved Google Search Console OAuth values to local .env."
  } else {
    Write-Host "Refresh token created. Re-run with -SaveToEnv to store it in .env, or copy it manually into:"
    Write-Host "GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN"
  }

  [PSCustomObject]@{
    status = "ok"
    savedToEnv = [bool]$SaveToEnv
    scope = $Scope
    tokenType = $tokenResponse.token_type
    expiresIn = $tokenResponse.expires_in
  } | Format-Table -AutoSize
} finally {
  if ($listener.IsListening) {
    $listener.Stop()
  }
  $listener.Close()
}
