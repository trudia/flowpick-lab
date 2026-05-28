# Coupang Partners API Workflow

TrendFlow can now use the official Coupang Partners API for shopping and review articles.

## What Changed

- Added `scripts/coupang-partners-api.ps1` for API tests, product search, and deep link conversion.
- Added `.env` and `.trendflow-coupang/` to `.gitignore` so local secrets and API test output are not committed.
- Updated the shopping publishing process to use API-generated affiliate links when available.
- Updated the long-term blog operation plan to treat API data as research input, not final article copy.
- Updated the daily improvement automation instructions to consider shopping/review opportunities through the API workflow.

## Operating Rule

API product data helps shortlist candidates, but final shopping content must still be reader-first:

- Explain who the product type fits.
- Explain who should skip it.
- Compare practical tradeoffs and value-for-money.
- Avoid copied product-page text, reviews, images, and exaggerated claims.
- Keep every affiliate link disclosure, `sponsored` relation, and GA4 tracking attribute.
- Keep every Coupang Partners link on the verified TrendFlow tracking tag: `AF3446366`.

## Publishing UI Guard

Shopping posts must reuse the existing TrendFlow shopping article shell. Do not introduce a new article wrapper just because a new API workflow is used.

- Use `container feature-article-shell`, `feature-breadcrumb`, and `feature-hero-img`.
- Use the existing affiliate notice block: `feature-insight-box affiliate-notice-box`.
- Keep the existing shopping modules: `quick-reco-v107`, `tf-checklist-v116`, `product-link-guide-v102`, `product-link-card-v102`, and `one-pick-v107`.
- Run `scripts/validate-shopping-post.ps1` before committing. The validator now fails when a shopping post uses non-standard markers such as `feature-article-layout`, `feature-article-kicker`, `feature-hero-figure`, or `feature-affiliate-notice`.
- The validator also fails when a Coupang affiliate URL is missing `lptag=AF3446366` or uses another tracking tag.

## API Notes

- Product search can return `link.coupang.com` partner URLs that can be used directly after editorial review.
- Normal `www.coupang.com` product URLs should be converted through the deep link API.
- API keys stay only in local environment variables or the local `.env` file.
