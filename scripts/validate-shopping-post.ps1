[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Slug,

  [int]$Version = 0,

  [string]$Root = "",

  [switch]$AllowMissingAffiliateLinks,

  [string]$ExpectedTrackingTag = "AF3446366"
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
  if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
  } else {
    $Root = (Resolve-Path ".").Path
  }
} else {
  $Root = (Resolve-Path $Root).Path
}

$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $failures.Add($Message) | Out-Null
}

function Add-Warning {
  param([string]$Message)
  $warnings.Add($Message) | Out-Null
}

function Read-Text {
  param([string]$Path)
  return Get-Content -Raw -LiteralPath $Path -Encoding UTF8
}

function Test-File {
  param([string]$Path, [string]$Label)
  if (-not (Test-Path -LiteralPath $Path)) {
    Add-Failure "$Label missing: $Path"
    return $false
  }
  return $true
}

function Test-SurfaceContainsSlug {
  param([string]$RelativePath)
  $path = Join-Path $Root $RelativePath
  if (Test-File $path $RelativePath) {
    $text = Read-Text $path
    if ($text -notlike "*$Slug*") {
      Add-Failure "$RelativePath does not reference slug '$Slug'"
    }
  }
}

$postHtmlPath = Join-Path $Root "posts\$Slug.html"
$postIndexPath = Join-Path $Root "posts\$Slug\index.html"
$postsJsonPath = Join-Path $Root "content\posts.json"
$postsDir = Join-Path $Root "_posts"

Test-File $postHtmlPath "post html" | Out-Null
Test-File $postIndexPath "post index html" | Out-Null
Test-File $postsJsonPath "content posts json" | Out-Null
Test-File $postsDir "_posts directory" | Out-Null

if (Test-Path -LiteralPath $postsDir) {
  $markdownMatches = @(Get-ChildItem -LiteralPath $postsDir -File -Filter "*-$Slug.md")
  if ($markdownMatches.Count -eq 0) {
    Add-Failure "_posts does not contain markdown for slug '$Slug'"
  }
}

$surfaces = @(
  "index.html",
  "categories\trend-shopping.html",
  "categories\trend-shopping\index.html",
  "archive.html",
  "search.html",
  "search\index.html",
  "sitemap.xml"
)

foreach ($surface in $surfaces) {
  Test-SurfaceContainsSlug $surface
}

if (Test-Path -LiteralPath $postsJsonPath) {
  try {
    $posts = Read-Text $postsJsonPath | ConvertFrom-Json
    $entry = @($posts | Where-Object { $_.slug -eq $Slug })
    if ($entry.Count -eq 0) {
      Add-Failure "content/posts.json does not contain slug '$Slug'"
    } elseif ($entry[0].category -ne "trend-shopping") {
      Add-Failure "content/posts.json entry for '$Slug' is not category trend-shopping"
    }
  } catch {
    Add-Failure "content/posts.json is not valid JSON: $($_.Exception.Message)"
  }
}

if (Test-Path -LiteralPath $postHtmlPath) {
  $html = Read-Text $postHtmlPath

  $coupangPattern = "\uCFE0\uD321|\uD30C\uD2B8\uB108\uC2A4"
  $commissionPattern = "\uC218\uC218\uB8CC"
  if ($html -notmatch $coupangPattern -or $html -notmatch $commissionPattern) {
    Add-Failure "post html is missing a visible Coupang Partners affiliate notice"
  }

  $requiredUiMarkers = @(
    "container feature-article-shell",
    "feature-breadcrumb",
    "feature-hero-img",
    "feature-insight-box affiliate-notice-box",
    "quick-reco-v107",
    "tf-checklist-v116",
    "topclass-product-fit-v139",
    "product-link-guide-v102",
    "product-link-card-v102",
    "one-pick-v107",
    "feature-side-card feature-subscribe-card enhanced-subscribe-v104"
  )

  foreach ($marker in $requiredUiMarkers) {
    if ($html -notlike "*$marker*") {
      Add-Failure "post html is missing UI marker '$marker'"
    }
  }

  $forbiddenUiMarkers = @(
    "container feature-article-layout",
    "feature-article-kicker",
    "feature-hero-figure",
    "feature-affiliate-notice"
  )

  foreach ($marker in $forbiddenUiMarkers) {
    if ($html -like "*$marker*") {
      Add-Failure "post html uses non-standard shopping UI marker '$marker'"
    }
  }

  $affiliateLinks = [regex]::Matches($html, '<a\b[^>]*href="https://link\.coupang\.com/[^"]*"[^>]*>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($affiliateLinks.Count -eq 0 -and -not $AllowMissingAffiliateLinks) {
    Add-Failure "post html has no Coupang affiliate links"
  }

  foreach ($match in $affiliateLinks) {
    $tag = $match.Value
    $href = ""
    if ($tag -match 'href="([^"]+)"') {
      $href = [System.Net.WebUtility]::HtmlDecode($Matches[1])
    }

    if ($tag -notmatch 'target="_blank"') {
      Add-Failure "affiliate link is missing target _blank: $tag"
    }
    if ($tag -notmatch 'rel="[^"]*nofollow' -or $tag -notmatch 'rel="[^"]*noopener' -or $tag -notmatch 'rel="[^"]*sponsored') {
      Add-Failure "affiliate link rel must contain nofollow, noopener, and sponsored: $tag"
    }
    if ($tag -notmatch 'data-track="affiliate_click"') {
      Add-Failure "affiliate link is missing data-track affiliate_click: $tag"
    }
    if ($tag -notmatch "data-post-slug=`"$([regex]::Escape($Slug))`"") {
      Add-Failure "affiliate link is missing matching data-post-slug: $tag"
    }
    if ($tag -notmatch 'data-product-group="[^"]+"') {
      Add-Failure "affiliate link is missing data-product-group: $tag"
    }
    if ($tag -notmatch 'data-position="[^"]+"') {
      Add-Failure "affiliate link is missing data-position: $tag"
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedTrackingTag)) {
      if ($href -notmatch '(?:\?|&)lptag=([^&]+)') {
        Add-Failure "affiliate link is missing Coupang lptag tracking parameter: $tag"
      } elseif ($Matches[1] -ne $ExpectedTrackingTag) {
        Add-Failure "affiliate link lptag '$($Matches[1])' does not match expected '$ExpectedTrackingTag': $tag"
      }
    }
  }

  $forbiddenPatterns = @(
    "\uBB34\uC870\uAC74\s*\uCD94\uCC9C",
    "\uCD5C\uC800\uAC00\s*\uBCF4\uC7A5",
    "\uD6A8\uACFC\s*\uBCF4\uC7A5",
    "1\uC704\s*\uD655\uC815",
    "\uC774\uAC70\s*\uC0AC\uBA74\s*\uC2E4\uD328\s*\uC5C6\uC74C"
  )

  foreach ($pattern in $forbiddenPatterns) {
    if ($html -match $pattern) {
      Add-Failure "post html contains a forbidden overclaim pattern: $pattern"
    }
  }

  $sensitivePatterns = @(
    "password\s*[:=]",
    "passwd\s*[:=]",
    "\uBE44\uBC00\uBC88\uD638\s*[:=]",
    "COUPANG_SECRET",
    "ACCESS_TOKEN",
    "SECRET_KEY"
  )

  foreach ($pattern in $sensitivePatterns) {
    if ($html -match $pattern) {
      Add-Failure "post html may contain sensitive information matching '$pattern'"
    }
  }
}

if ((Test-Path -LiteralPath $postHtmlPath) -and (Test-Path -LiteralPath $postIndexPath)) {
  $postHtml = Read-Text $postHtmlPath
  $postIndexHtml = Read-Text $postIndexPath
  if ($postHtml -ne $postIndexHtml) {
    Add-Warning "posts/$Slug.html and posts/$Slug/index.html are not identical"
  }
}

if ($Version -gt 0) {
  Test-File (Join-Path $Root "deploy-check-v$Version.html") "deploy check" | Out-Null

  $readmeMatches = @(Get-ChildItem -LiteralPath $Root -File -Filter "README_V$Version*.md")
  if ($readmeMatches.Count -eq 0) {
    Add-Failure "README_V$Version*.md is missing"
  }

  $versionPath = Join-Path $Root "version.txt"
  if (Test-File $versionPath "version.txt") {
    $versionText = Read-Text $versionPath
    if ($versionText -notlike "*v$Version*") {
      Add-Failure "version.txt does not contain v$Version"
    }
  }
}

if ($warnings.Count -gt 0) {
  Write-Host "Warnings:" -ForegroundColor Yellow
  foreach ($warning in $warnings) {
    Write-Host " - $warning" -ForegroundColor Yellow
  }
}

if ($failures.Count -gt 0) {
  Write-Host "Validation failed for '$Slug':" -ForegroundColor Red
  foreach ($failure in $failures) {
    Write-Host " - $failure" -ForegroundColor Red
  }
  exit 1
}

Write-Host "Validation passed for '$Slug'." -ForegroundColor Green
