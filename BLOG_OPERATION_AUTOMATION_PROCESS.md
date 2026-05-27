# TrendFlow Blog Operation Automation Process

TrendFlow is operated as a staged content system, not as a simple daily posting queue. The goal is to build helpful informational content first, then connect the right posts to buying criteria and shopping guides without forcing affiliate links into every article.

## Operating Targets

- Site: https://trend.it.kr/
- Repository: https://github.com/trudia/flowpick-lab
- Workspace: `C:\Users\편돌이\Documents\TrendFlow`
- Default branch: `main`
- Main categories:
  - AI 입문 / AI 생산성
  - 집중 회복 / 집중력 & 웰빙
  - 공간 정리 / 공간 & 미니멀
  - 구매 기준 / 트렌드 쇼핑

## Editorial Identity

TrendFlow should read like a friendly information curation platform. Each post should help the reader make a small but useful decision, not feel like a stiff encyclopedia entry or a forced sales page.

Default writing standard:
- Write around 2,500 to 3,500 Korean characters for normal articles.
- Keep paragraphs short, usually 2 to 4 sentences.
- Use clear subheadings, checklists, comparison blocks, and "what to do next" guidance.
- Prefer practical examples, everyday situations, and reader-friendly explanations.
- When referencing other sites or current materials, use them only for research. Do not copy sentences, article structure, reviews, images, product detail text, or sales claims.
- Every post should have one concrete takeaway the reader can use immediately.

Default article structure follows a soft PASONA flow:
- Problem: name the reader's actual situation or friction.
- Affinity / Agitation: show why the problem matters without exaggerating fear.
- Solution: explain the practical method, 기준, 루틴, or checklist.
- Offer: suggest the most useful next step, article, checklist, or product-selection 기준.
- Narrowing: help the reader choose by situation, budget, space, skill level, or urgency.
- Action: end with a small action, not a pushy command.

Image standard:
- Use a featured image that matches the exact article topic.
- Avoid reusing the same image across unrelated posts.
- Avoid copied product-page images, review images, and irrelevant stock-like images.
- If a generated image is used, make it support the topic clearly and keep it believable.

Short-form reuse:
- For each new article, keep one Shorts/Reels angle in mind: hook, 3 short beats, and a simple ending.
- Prefer article sections that can become a 20 to 40 second video: mistake list, checklist, before/after routine, or "one thing to check before buying."
- Shopping articles should naturally support a later short-form script, but the article must remain useful even without a video.

## Stage 1. Foundation Build

Recommended period: month 0 to month 3.

Goal:
- Build category depth.
- Publish enough helpful posts for visitors to understand the site.
- Keep monetization light and natural.

Weekly rhythm:
- 3 informational posts.
- 1 buying-criteria post.
- 1 shopping guide only when the topic has clear product intent.
- 1 improvement session for internal links, category pages, search, archive, and sitemap.

Daily automation:
1. Check the current category balance.
2. Select one topic from the four main areas.
3. Decide the post type: informational, buying criteria, shopping guide, or update.
4. If the post needs Coupang links, prepare a link request instead of writing fake links.
5. If the post does not need links, draft and publish directly after validation.

## Stage 2. Optimization

Recommended period: month 3 to month 6.

Goal:
- Improve posts that already receive impressions or clicks.
- Add internal links from informational posts to buying criteria and shopping guides.
- Strengthen trust, structure, and user satisfaction.

Weekly rhythm:
- 2 new posts.
- 2 post refreshes.
- 1 internal-link and category-hub improvement.
- 1 shopping guide only when a clear buying query exists.

Automation focus:
- Find posts with weak titles, thin intros, missing next-step links, or unclear category placement.
- Add comparison sections, checklists, and "who this is for / not for" blocks where useful.
- Keep affiliate links only in posts with real product-selection intent.

## Stage 3. Monetization System

Recommended period: month 6 to month 12.

Goal:
- Turn category clusters into monetization paths.
- Build visitor trust before asking for a purchase click.

Weekly rhythm:
- 1 to 2 new posts.
- 2 to 3 refreshes of high-potential posts.
- 1 product guide or comparison post.
- 1 conversion review of CTA placement, affiliate notices, and related links.

Automation focus:
- Connect informational posts to buying-criteria posts.
- Connect buying-criteria posts to shopping guides.
- Keep shopping posts focused on situation-based product choice, not aggressive recommendation.
- Review product cards for correct affiliate attributes.
- Evaluate whether linked products are actually helpful for the reader's situation, value for money, expected use case, maintenance burden, size, noise, durability, and replacement cycle.
- Do not recommend a product group just because an affiliate link is available.

## Stage 4. Long-Term Media Operation

Recommended period: after month 12.

Goal:
- Operate TrendFlow as a compact problem-solving media site.
- Maintain fewer but stronger new posts.
- Refresh old posts before they become stale.

Weekly rhythm:
- 1 new post.
- 3 refreshes or structural improvements.
- 1 data review.
- 1 category-hub or newsletter/checklist asset improvement.

Automation focus:
- Maintain the strongest topic clusters.
- Retire or merge overlapping posts.
- Expand reusable assets such as checklists, templates, and comparison tables.
- Review monetization paths monthly.

## Coupang Link Automation Policy

Codex must not guess, scrape, or fabricate Coupang Partners links. When the user has enabled the official Coupang Partners API and local environment variables are available, Codex may use the approved API workflow below.

Allowed:
- Analyze the topic and identify product groups.
- Search candidate products through the official Coupang Partners API.
- Use product search API partner URLs directly when they are already `link.coupang.com`.
- Convert normal `www.coupang.com` product URLs through the official deep link API when needed.
- Use API-generated Coupang Partners links or links provided by the user.
- Validate every provided affiliate link for required attributes.
- Insert affiliate disclosure and GA4 tracking attributes.
- Explain why each product type is useful, who it fits, and who should skip it.
- Keep value-for-money and practical fit more important than high-price positioning.

API environment variables:

```text
COUPANG_PARTNERS_ACCESS_KEY
COUPANG_PARTNERS_SECRET_KEY
COUPANG_PARTNERS_SUB_ID   optional
```

If the Codex app cannot see newly created environment variables yet, use a local `.env` file in the TrendFlow workspace with the same names. `.env` is ignored by git.

Local API helper:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Test
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Search -Keyword "desk lamp" -Limit 5 -OutputPath ".trendflow-coupang\desk-lamp.json"
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Deeplink -Url "https://www.coupang.com/..." -OutputPath ".trendflow-coupang\deeplink.json"
```

Not allowed:
- Logging into Coupang Partners automatically.
- Scraping product pages, reviews, images, or sales copy.
- Storing Coupang account credentials or private tokens in the repository.

If API credentials are not available or the API call fails, Codex should stop after preparing the article plan and ask the user for links in this format:

```text
주제:
[글 주제]

필요한 쿠팡파트너스 링크:
1. [제품군 / 상황]
2. [제품군 / 상황]
3. [제품군 / 상황]
4. [제품군 / 상황]
5. [제품군 / 상황]

링크를 주시면 글 본문, 비교표, 제품 카드, CTA, 카테고리, 검색, 아카이브, 사이트맵까지 반영해 발행하겠습니다.
```

## Daily Operating Decision Tree

1. Is there a user-provided shopping topic and Coupang links?
   - Yes: publish a shopping guide.
   - No: continue.
2. Is there a shopping topic but no links?
   - Yes: prepare the link request and wait.
   - No: continue.
3. Does a category need more foundation content?
   - Yes: publish an informational post.
   - No: continue.
4. Does an existing post have a weak path to the next article?
   - Yes: refresh internal links and CTA.
   - No: continue.
5. Is there no meaningful update?
   - Report: 오늘은 별도 개선 제안 없음.

## Publishing Validation

Before pushing:
- New or changed post URL exists.
- Home latest or series card points to the correct post.
- Category page is updated.
- Search data is updated.
- Archive is updated.
- Sitemap is updated when a URL is new.
- `version.txt` is updated.
- `deploy-check-v###.html` is added.
- Article body follows the 2,500 to 3,500 Korean character target unless the topic clearly needs a shorter update or longer guide.
- Paragraphs are easy to scan on mobile.
- Featured image matches the article topic and is not duplicated from a mismatched article.
- A short-form reuse angle is recorded when useful.
- Affiliate posts contain disclosure and link attributes.
- No private credentials are committed.

After pushing:
- GitHub Pages build is `built`.
- `https://trend.it.kr/version.txt` shows the expected version.
- New post URL opens.
- Category page opens.
- Sitemap opens.
- Search engine submission is done when a new URL is published.
