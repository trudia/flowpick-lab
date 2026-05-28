# TrendFlow v143 IndexNow Automation

- Date: 2026-05-29
- Version: `v143-indexnow-automation-2026-05-29`
- Goal: Notify IndexNow-compatible search engines when new TrendFlow pages are published or updated.

## What Changed

- Added an IndexNow ownership key file at the site root.
- Added a reusable PowerShell submission helper.
- Added a deploy check page for the IndexNow setup.
- Updated `version.txt`.

## Public Key File

```text
https://trend.it.kr/6c8e7b92-2b54-4c6f-a111-7f64204dbe5a.txt
```

The file content must exactly match:

```text
6c8e7b92-2b54-4c6f-a111-7f64204dbe5a
```

## Submission Helper

Run after a successful deploy:

```powershell
.\scripts\submit-indexnow.ps1
```

Default URLs:

```text
https://trend.it.kr/posts/desk-cable-small-items-organization-guide/
https://trend.it.kr/posts/fan-vs-circulator-when-to-choose/
https://trend.it.kr/categories/trend-shopping/
https://trend.it.kr/sitemap.xml
```

