# TrendFlow Shopping Publishing Process

This is the operating playbook for publishing TrendFlow shopping guide posts to the production site.

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
   - Required Coupang Partners links, usually 3 to 5
   - Expected CTA structure

2. Ask the user for Coupang Partners links.
   - Only use links the user provides.
   - Do not generate, guess, or scrape affiliate links.
   - Keep product choices type-based rather than brand-locked when possible.

3. Create the article using the existing `trend-shopping` UI.
   - Affiliate notice near the top
   - Quick recommendation summary
   - Five body sections
   - Buying checklist
   - Product comparison table
   - Product cards
   - "딱 하나만 고른다면" CTA
   - Previous/next article links
   - Recent posts and recommended series sidebar

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

- Prefer purchase criteria, failure prevention, and situation-based comparison.
- Avoid overclaims such as "무조건 추천", "최저가 보장", "효과 보장", "1위 확정", and "이거 사면 실패 없음".
- Do not copy product detail page images, reviews, or sales copy.
- Do not store Coupang account credentials, passwords, access tokens, or private login information in the repo.

## Reusable Input Template

Use `templates/trend-shopping-input.example.json` as the shape for the next post request. Replace placeholders only after the user provides real topic details and Coupang Partners links.
