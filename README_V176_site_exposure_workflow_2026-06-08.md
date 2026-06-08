# v176 Site Exposure Workflow

## Summary
- Applied the site exposure workflow to TrendFlow.
- Fixed missing title, description, canonical, viewport, color-scheme, and OG title on the career education category.
- Strengthened support pages for trust signals: about, affiliate notice, terms, and 404.
- Added a local exposure audit script and workflow documentation.
- Updated robots and sitemap rules so visitor-facing pages receive clearer crawl priority.

## Checks
- `scripts/audit-site-exposure.ps1` generates a metadata audit report.
- Career education category now has title, description, canonical, H1, and sitemap coverage.
- Operational files are separated from visitor-facing content in `robots.txt`.
