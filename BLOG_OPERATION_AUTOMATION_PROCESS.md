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

Codex must not create, guess, scrape, or fabricate Coupang Partners links.

Allowed:
- Analyze the topic and identify product groups.
- Prepare a clear request for 3 to 5 Coupang Partners links.
- Use only links provided by the user.
- Validate every provided affiliate link for required attributes.
- Insert affiliate disclosure and GA4 tracking attributes.

Not allowed unless the user later provides an official, approved API workflow:
- Logging into Coupang Partners automatically.
- Creating affiliate links from normal Coupang product URLs.
- Scraping product pages, reviews, images, or sales copy.
- Storing Coupang account credentials or private tokens in the repository.

If a shopping guide needs links, Codex should stop after preparing the article plan and ask the user for links in this format:

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
- Affiliate posts contain disclosure and link attributes.
- No private credentials are committed.

After pushing:
- GitHub Pages build is `built`.
- `https://trend.it.kr/version.txt` shows the expected version.
- New post URL opens.
- Category page opens.
- Sitemap opens.
- Search engine submission is done when a new URL is published.

