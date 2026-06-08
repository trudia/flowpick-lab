param(
  [string]$Root = (Get-Location).Path,
  [string]$SiteUrl = "https://trend.it.kr",
  [string]$ReportPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FirstMatch {
  param(
    [string]$Text,
    [string[]]$Patterns
  )
  foreach ($pattern in $Patterns) {
    $match = [regex]::Match($Text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) {
      return $match.Groups[1].Value.Trim()
    }
  }
  return ""
}

function Get-PlainTextLength {
  param([string]$Html)
  $withoutScripts = [regex]::Replace($Html, "<script[\s\S]*?</script>", " ", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  $withoutStyles = [regex]::Replace($withoutScripts, "<style[\s\S]*?</style>", " ", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  $plain = [regex]::Replace($withoutStyles, "<[^>]+>", " ")
  $plain = [regex]::Replace($plain, "\s+", " ").Trim()
  return $plain.Length
}

function Test-OperationalFile {
  param([string]$RelativePath)
  return (
    $RelativePath -eq "404.html" -or
    $RelativePath -like "deploy-check-*.html" -or
    $RelativePath -like "README_*.md" -or
    $RelativePath -like "naver*.html" -or
    $RelativePath -like "BingSiteAuth.xml"
  )
}

function Test-SupportFile {
  param([string]$RelativePath)
  return (
    $RelativePath -eq "about.html" -or
    $RelativePath -eq "affiliate.html" -or
    $RelativePath -eq "terms.html" -or
    $RelativePath -eq "privacy.html" -or
    $RelativePath -eq "search.html" -or
    $RelativePath -eq "search/index.html"
  )
}

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$skipPattern = [regex]::Escape([IO.Path]::DirectorySeparatorChar + ".git" + [IO.Path]::DirectorySeparatorChar)
$htmlFiles = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Filter "*.html" |
  Where-Object {
    $_.FullName -notmatch $skipPattern -and
    $_.FullName -notlike "*\.git2\*" -and
    $_.FullName -notlike "*\node_modules\*"
  }

$robotsPath = Join-Path $resolvedRoot "robots.txt"
$sitemapPath = Join-Path $resolvedRoot "sitemap.xml"
$robots = if (Test-Path -LiteralPath $robotsPath) { Get-Content -LiteralPath $robotsPath -Raw -Encoding UTF8 } else { "" }
$sitemap = if (Test-Path -LiteralPath $sitemapPath) { Get-Content -LiteralPath $sitemapPath -Raw -Encoding UTF8 } else { "" }

$results = @()
foreach ($file in $htmlFiles) {
  $relative = $file.FullName.Substring($resolvedRoot.Length).TrimStart("\", "/").Replace("\", "/")
  $html = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
  $isOperational = Test-OperationalFile -RelativePath $relative
  $isSupport = Test-SupportFile -RelativePath $relative
  $isRedirect = $html -match 'http-equiv=["'']refresh["'']'

  $title = Get-FirstMatch -Text $html -Patterns @("<title[^>]*>([\s\S]*?)</title>")
  $description = Get-FirstMatch -Text $html -Patterns @(
    '<meta[^>]+name=["'']description["''][^>]+content=["'']([^"'']*)["'']',
    '<meta[^>]+content=["'']([^"'']*)["''][^>]+name=["'']description["'']'
  )
  $canonical = Get-FirstMatch -Text $html -Patterns @(
    '<link[^>]+rel=["'']canonical["''][^>]+href=["'']([^"'']*)["'']',
    '<link[^>]+href=["'']([^"'']*)["''][^>]+rel=["'']canonical["'']'
  )
  $robotsMeta = Get-FirstMatch -Text $html -Patterns @(
    '<meta[^>]+name=["'']robots["''][^>]+content=["'']([^"'']*)["'']',
    '<meta[^>]+content=["'']([^"'']*)["''][^>]+name=["'']robots["'']'
  )
  $h1Count = ([regex]::Matches($html, "<h1\b", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
  $bodyLength = Get-PlainTextLength -Html $html

  $issues = New-Object System.Collections.Generic.List[string]
  if (-not $isOperational -and -not $isRedirect) {
    if ([string]::IsNullOrWhiteSpace($title)) { $issues.Add("missing_title") }
    if ([string]::IsNullOrWhiteSpace($description)) { $issues.Add("missing_description") }
    if ([string]::IsNullOrWhiteSpace($canonical)) { $issues.Add("missing_canonical") }
    if ($h1Count -ne 1) { $issues.Add("h1_count_$h1Count") }
    if ($bodyLength -lt 500 -and -not $isSupport) { $issues.Add("thin_body") }
    if ($robotsMeta -match "noindex") { $issues.Add("noindex_public_page") }
    if (-not [string]::IsNullOrWhiteSpace($canonical) -and $sitemap -notmatch [regex]::Escape($canonical)) {
      $issues.Add("canonical_not_in_sitemap")
    }
  }

  if ($issues.Count -gt 0) {
    $results += [pscustomobject]@{
      Path = $relative
      Title = $title
      DescriptionLength = $description.Length
      Canonical = $canonical
      H1Count = $h1Count
      BodyLength = $bodyLength
      Robots = $robotsMeta
      Issues = ($issues -join ",")
    }
  }
}

$summary = [pscustomobject]@{
  SiteUrl = $SiteUrl
  CheckedHtmlFiles = $htmlFiles.Count
  IssuePages = $results.Count
  HasRobotsTxt = -not [string]::IsNullOrWhiteSpace($robots)
  HasSitemap = -not [string]::IsNullOrWhiteSpace($sitemap)
  RobotsMentionsSitemap = $robots -match [regex]::Escape("$SiteUrl/sitemap.xml")
}

if (-not [string]::IsNullOrWhiteSpace($ReportPath)) {
  $reportFullPath = if ([IO.Path]::IsPathRooted($ReportPath)) { $ReportPath } else { Join-Path $resolvedRoot $ReportPath }
  $reportDir = Split-Path -Parent $reportFullPath
  if (-not (Test-Path -LiteralPath $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir | Out-Null
  }
  $lines = @()
  $lines += "# TrendFlow Site Exposure Audit"
  $lines += ""
  $lines += "- Site: $SiteUrl"
  $lines += "- Checked HTML files: $($summary.CheckedHtmlFiles)"
  $lines += "- Pages with issues: $($summary.IssuePages)"
  $lines += "- robots.txt present: $($summary.HasRobotsTxt)"
  $lines += "- sitemap.xml present: $($summary.HasSitemap)"
  $lines += "- robots.txt sitemap line: $($summary.RobotsMentionsSitemap)"
  $lines += ""
  $lines += "## Issue Pages"
  if ($results.Count -eq 0) {
    $lines += ""
    $lines += "No public page metadata issues found."
  } else {
    $lines += ""
    $lines += "| Path | Issues | H1 | Body chars |"
    $lines += "| --- | --- | ---: | ---: |"
    foreach ($row in $results) {
      $lines += "| $($row.Path) | $($row.Issues) | $($row.H1Count) | $($row.BodyLength) |"
    }
  }
  Set-Content -LiteralPath $reportFullPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
}

[pscustomobject]@{
  Summary = $summary
  Issues = $results
} | ConvertTo-Json -Depth 5
