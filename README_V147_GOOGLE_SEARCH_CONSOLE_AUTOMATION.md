# TrendFlow v147 Google Search Console Automation

- Date: 2026-06-01
- Version: `v147-google-search-console-automation-2026-06-01`
- Goal: Automate the Google-side tasks that are allowed for normal blog articles.

## What Changed

- Added `scripts/google-search-console.ps1`.
- Added `scripts/submit-search-engines.ps1`.
- Added `.trendflow-google/` to ignored local output paths.
- Updated the operating process so each publication can run IndexNow plus Google sitemap submission from one command.

## What Can Be Automated

- Submit `https://trend.it.kr/sitemap.xml` to Google Search Console through the official Search Console API.
- Inspect Google index status for selected TrendFlow URLs through the URL Inspection API.
- Submit new and updated URLs to Naver and Bing through the existing IndexNow flow.

## What Cannot Be Automated

Google does not provide a general API equivalent of the Search Console "Request indexing" button for normal blog posts. The Google Indexing API is limited to job posting and livestreaming video pages, so TrendFlow should not use it for ordinary articles.

## Required Local Environment

Use either a temporary access token:

```text
GOOGLE_SEARCH_CONSOLE_ACCESS_TOKEN
```

Or an OAuth refresh-token setup:

```text
GOOGLE_SEARCH_CONSOLE_CLIENT_ID
GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET
GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN
```

The token needs this scope for sitemap submission:

```text
https://www.googleapis.com/auth/webmasters
```

For inspection only, the readonly scope is also accepted:

```text
https://www.googleapis.com/auth/webmasters.readonly
```

Store these values in local environment variables or in `.env`. Do not commit Google client secrets or refresh tokens.

## Easier Refresh Token Setup

After creating a Google OAuth Client ID with application type `Desktop app`, put only the client ID and client secret in `.env`:

```text
GOOGLE_SEARCH_CONSOLE_CLIENT_ID="..."
GOOGLE_SEARCH_CONSOLE_CLIENT_SECRET="..."
```

Then run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/get-google-search-console-refresh-token.ps1 -SaveToEnv
```

The helper opens the Google consent page, receives the local redirect on `http://127.0.0.1:53682/`, and saves `GOOGLE_SEARCH_CONSOLE_REFRESH_TOKEN` to `.env`.

## Usage

Test local credentials:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/google-search-console.ps1 -Mode TestConfig
```

Submit the sitemap to Google:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/google-search-console.ps1 -Mode SubmitSitemap
```

TrendFlow uses the Search Console domain property by default:

```text
sc-domain:trend.it.kr
```

If you need to use a URL-prefix property instead, pass it explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/google-search-console.ps1 -Mode SubmitSitemap -SiteUrl "https://trend.it.kr/"
```

Inspect specific URLs:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/google-search-console.ps1 -Mode InspectUrl -Urls "https://trend.it.kr/posts/ai-era-career-skills-map","https://trend.it.kr/posts/why-online-courses-do-not-become-skills" -OutputPath ".trendflow-google\latest-url-inspection.json"
```

Run the combined publication submission flow:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/submit-search-engines.ps1 -Urls "https://trend.it.kr/posts/ai-era-career-skills-map/","https://trend.it.kr/posts/why-online-courses-do-not-become-skills/","https://trend.it.kr/categories/career-education/","https://trend.it.kr/sitemap.xml" -InspectGoogle
```
