# TrendFlow Shopping Publishing Process

This is the operating playbook for publishing TrendFlow shopping guide posts to the production site.

For the staged daily, weekly, and monthly blog operation flow, also use `BLOG_OPERATION_AUTOMATION_PROCESS.md`.

## Production Targets

- Site: https://trend.it.kr/
- Repository: https://github.com/trudia/flowpick-lab
- Local workspace: `C:\Users\편돌이\Documents\TrendFlow`
- Default branch: `main`
- Current baseline: `v130-laundry-smell-dehumidifier-airflow-patch-2026-05-26`
- Next shopping article patch: `v131`

## Standard Flow

1. Analyze the topic before writing.
   - Main keyword
   - Supporting keywords
   - Search intent
   - Recommended category: `trend-shopping`
   - Post type: problem-solving, comparison, mistake-prevention, seasonal, or set-based
   - Trend value: current trigger, evergreen value, and whether the topic will still help readers later
   - Required Coupang Partners links, usually 3 to 5
   - Expected CTA structure
   - Expected reader benefit and one practical takeaway
   - Who the product helps, who should skip it, and what future-use value it has
   - Short-form video angle, if the topic can become Shorts/Reels content

2. Prepare Coupang Partners links.
   - If the official API credentials are available, search candidate products with `scripts/coupang-partners-api.ps1`.
   - The product search API can return `link.coupang.com` partner URLs that may be used directly after editorial review.
   - Convert normal `www.coupang.com` product URLs with the official deep link API when needed.
   - If API credentials are unavailable or the API call fails, ask the user for 3 to 5 Coupang Partners links.
   - Never generate, guess, scrape, or fabricate affiliate links.
   - Keep product choices type-based rather than brand-locked when possible.
   - Do not copy product detail page images, reviews, or sales copy.
   - Prefer products that solve repeated real problems, not one-time curiosity or short-lived novelty.

3. Create the article using the existing `trend-shopping` UI.
   - Affiliate notice near the top
   - Quick recommendation summary
   - Five body sections
   - Buying checklist
   - Product-fit block: who it helps, who should skip it, long-term value, and AI/review checks
   - Product comparison table
   - Product cards
   - "딱 하나만 고른다면" CTA
   - Previous/next article links
   - Recent posts and recommended series sidebar
   - Topic-matched featured image
   - Reader-friendly body length, usually 2,500 to 3,500 Korean characters

4. Sync every public surface.
   - `_posts/YYYY-MM-DD-slug.md`
   - `posts/slug.html`
   - `posts/slug/index.html`
   - `content/posts.json`
   - `categories/trend-shopping.html`
   - `categories/trend-shopping/index.html`
   - `archive.html`
   - `search.html`
   - `sitemap.xml`
   - `index.html`
   - `version.txt`
   - `deploy-check-v###.html`
   - `README_V###_...md`

5. Validate before upload.
   - Run `powershell -ExecutionPolicy Bypass -File scripts/validate-shopping-post.ps1 -Slug "post-slug" -Version 131`.
   - Fix every failure before committing.
   - Recheck the visible pages locally or in the browser when layout changed.

6. Upload to GitHub.
   - Confirm `git status --short --branch`.
   - Commit only the intended files.
   - Use `Add [topic] shopping guide` for article commits.
   - Push to `main` unless the change is large enough to need a separate PR.
   - On this Windows machine, use `git -c http.sslBackend=openssl ...` if the default Git TLS backend fails.

7. Confirm deployment and search registration.
   - Check `https://trend.it.kr/posts/[slug]`.
   - Check `https://trend.it.kr/categories/trend-shopping`.
   - Check `https://trend.it.kr/sitemap.xml`.
   - Confirm the new post appears on the home latest area.
   - Submit the new URL and sitemap in Google Search Console, Naver Search Advisor, and Bing Webmaster Tools.

## Required Affiliate Rules

## Coupang Partners API Helper

Use the local helper only with environment variables. Never put access keys, secret keys, or generated private working files in the repository.

Required variables:

```text
COUPANG_PARTNERS_ACCESS_KEY
COUPANG_PARTNERS_SECRET_KEY
COUPANG_PARTNERS_SUB_ID   optional
```

The helper also reads a local `.env` file in the TrendFlow workspace. `.env` is ignored by git and must never be committed.

Commands:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Test
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Search -Keyword "desk lamp" -Limit 5 -OutputPath ".trendflow-coupang\desk-lamp.json"
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Deeplink -Url "https://www.coupang.com/..." -OutputPath ".trendflow-coupang\deeplink.json"
```

API product data is research input, not final copy. Product names, prices, and availability can change, so the article should use careful wording and focus on selection criteria.
If the search API returns a `link.coupang.com` product URL, do not send that URL back through the deep link API. Use it as the affiliate URL after checking reader fit. Use deep link conversion for normal Coupang product URLs.

- Required notice:

```text
이 글은 쿠팡파트너스 및 제휴광고 활동의 일환으로, 구매 시 일정액의 수수료를 제공받을 수 있습니다. 구매 가격에는 영향을 주지 않습니다.
```

- Every Coupang link must include:

```html
target="_blank" rel="nofollow noopener sponsored"
```

- Every tracked affiliate CTA should keep the existing GA4 attributes:

```html
data-track="affiliate_click"
data-post-slug="[slug]"
data-product-group="[product_group]"
data-position="product_link_1"
```

## Writing Rules

- Keep the tone close to an information curation platform: useful, warm, practical, and not too stiff.
- Use a soft PASONA flow: problem, empathy, practical solution, selection 기준, narrowed recommendation, and small next action.
- Keep paragraphs short enough to read comfortably on mobile.
- Prefer purchase criteria, failure prevention, and situation-based comparison.
- For every linked product, explain the practical fit: who it helps, what problem it solves, value-for-money, likely tradeoffs, and who should skip it.
- Add a future-value filter: whether the product category will remain useful, whether it supports a recurring habit, and whether the selection criteria can help the reader with later purchases.
- Do not connect a product only because it can be monetized. If the product does not clearly help the reader, leave it out.
- Consider future Shorts/Reels reuse. A good shopping guide should contain at least one simple video-friendly angle such as "3 checks before buying", "common mistake", or "which one fits your room".
- Avoid overclaims such as "무조건 추천", "최저가 보장", "효과 보장", "1위 확정", and "이거 사면 실패 없음".
- Do not copy product detail page images, reviews, or sales copy.
- Do not store Coupang account credentials, passwords, access tokens, or private login information in the repo.

## Reusable Input Template

Use `templates/trend-shopping-input.example.json` as the shape for the next post request. Replace placeholders only after the user provides real topic details and Coupang Partners links.
