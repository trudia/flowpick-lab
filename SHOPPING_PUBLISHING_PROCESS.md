# TrendFlow Shopping Publishing Process

TrendFlow 쇼핑/리뷰 글은 제품을 팔기 위한 글이 아니라, 방문자가 `나에게 필요한지 아닌지` 판단하도록 돕는 구매 기준 콘텐츠다. 쿠팡파트너스 API와 제휴 링크는 사용할 수 있지만, 추천의 중심은 항상 독자의 상황과 문제 해결이어야 한다.

## 운영 대상

- Site: https://trend.it.kr/
- Repository: https://github.com/trudia/flowpick-lab
- Local workspace: `C:\Users\편돌이\Documents\TrendFlow`
- Default branch: `main`
- Current public baseline: `v165-centered-home-slider-2026-06-04`
- Next public patch: `v166`부터 사용

단계형 블로그 운영 기준은 `BLOG_OPERATION_AUTOMATION_PROCESS.md`를 함께 따른다.

## 쇼핑 글을 시작하기 전

1. 통합 프로젝트 상태를 확인한다.
   - TrendFlow와 TopClass Coupang을 하나의 운영 흐름으로 본다.
   - 같은 주제의 정보성 글, 구매 기준 글, 쇼핑 글이 이미 있는지 확인한다.
   - 공개 글에 내부 자동화 문구나 제작 메모가 남아 있지 않은지 확인한다.

2. 주제를 분석한다.
   - 핵심 키워드
   - 검색 의도
   - 추천 카테고리: 보통 `trend-shopping`, 필요하면 `creator-side-hustle`와 연결
   - 글 유형: 문제 해결, 비교, 실수 예방, 계절형, 세트형, 구매 전 점검형
   - 과거 신호: 반복된 불편, 실패한 구매, 계절 반복, 후기 피로
   - 현재 맥락: 날씨, 주거, 작업 방식, 플랫폼 변화, 가격 부담
   - 미래 가치: 반짝 유행 뒤에도 남는 기준인지
   - 적합도 경계: 누가 도움을 받고, 누가 건너뛰어도 되는지

3. 쇼핑 글이 맞는지 판단한다.
   - 제품 선택 의도가 분명하면 쇼핑 글로 진행한다.
   - 아직 기준 정리가 먼저라면 정보성 글이나 구매 기준 글로 남긴다.
   - 개인 상황 진단이 더 중요하면 구글폼 CTA를 우선한다.

## 쿠팡파트너스 API 흐름

API 키나 민감정보는 저장소에 커밋하지 않는다. 로컬 `.env` 또는 환경변수만 사용한다.

필수 변수:

```text
COUPANG_PARTNERS_ACCESS_KEY
COUPANG_PARTNERS_SECRET_KEY
COUPANG_PARTNERS_SUB_ID   optional
```

로컬 helper:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Test
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Search -Keyword "desk lamp" -Limit 5 -OutputPath ".trendflow-coupang\desk-lamp.json"
powershell -ExecutionPolicy Bypass -File scripts/coupang-partners-api.ps1 -Mode Deeplink -Url "https://www.coupang.com/..." -OutputPath ".trendflow-coupang\deeplink.json"
```

허용:

- 공식 API로 후보 상품을 검색한다.
- API가 반환한 `link.coupang.com` 파트너 URL을 편집 검토 후 사용한다.
- 일반 `www.coupang.com` 상품 URL은 공식 딥링크 API로 변환한다.
- 제품 데이터는 연구 입력으로만 쓴다.
- 상품명, 가격, 배송 상태는 변동 가능하므로 단정 표현을 피한다.

금지:

- 쿠팡파트너스 링크를 추측하거나 생성한 척하기
- 상품 상세페이지 문구, 리뷰, 이미지 복사
- 제품 페이지 스크래핑
- 계정 정보, 토큰, 테스트 JSON 민감값 커밋
- 제휴 가능성만 보고 제품을 넣기

API가 실패하면 아래 형식으로 사용자에게 링크를 요청한다.

```text
주제:
[글 주제]

필요한 쿠팡파트너스 링크:
1. [제품군 / 필요한 상황]
2. [제품군 / 필요한 상황]
3. [제품군 / 필요한 상황]
4. [제품군 / 필요한 상황]
5. [제품군 / 필요한 상황]

링크를 주시면 본문, 비교표, 제품 카드, CTA, 카테고리, 검색, 아카이브, 사이트맵까지 반영해 발행하겠습니다.
```

## 글 구조

기존 `trend-shopping` UI와 같은 흐름을 유지한다.

- 제휴 고지
- 빠른 추천 요약
- 본문 5섹션
- 구매 체크리스트
- 제품 적합도 블록
  - 도움이 되는 사람
  - 건너뛰어도 되는 사람
  - 장기적으로 남는 가치
  - 후기/AI 추천을 볼 때 주의할 점
- 비교표
- 제품 카드
- `딱 하나만 고른다면` CTA
- 이전/다음 글
- 최근 글 / 추천 시리즈 사이드바

본문은 2,500~3,500자 내외를 기본 목표로 하고, 모바일에서 읽기 좋게 문단을 짧게 나눈다.

## 제휴 링크 규칙

필수 고지:

```text
이 글은 쿠팡파트너스 및 제휴광고 활동의 일환으로, 구매 시 일정액의 수수료를 제공받을 수 있습니다. 구매 가격에는 영향을 주지 않습니다.
```

모든 제휴 링크:

```html
target="_blank" rel="nofollow noopener sponsored"
```

추적 속성:

```html
data-track="affiliate_click"
data-post-slug="[slug]"
data-product-group="[product_group]"
data-position="product_link_1"
```

확인:

- `lptag=AF3446366` 포함 여부
- 새 창 열림
- nofollow / noopener / sponsored 속성
- 상품 카드와 비교표의 링크 일치

## 이미지 기준

- 주제와 맞는 대표 이미지를 사용한다.
- 제품 상세페이지 이미지, 리뷰 이미지, 검색 썸네일, 타 사이트 스크린샷을 복사하지 않는다.
- 생성 이미지, 직접 만든 이미지, 사용 허가된 스톡 이미지를 사용할 수 있다.
- 스톡 이미지는 사용/편집/게시 라이선스를 확인하고, 소스와 편집 내용을 README 또는 감사 노트에 기록한다.

## 공개 파일 반영 범위

새 쇼핑 글을 발행하면 아래 파일을 동기화한다.

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

## 검증

발행 전:

- 새 글 URL이 열린다.
- 홈 최신 글 또는 관련 카드가 새 글로 이어진다.
- 쇼핑 카테고리, 검색, 아카이브, 사이트맵이 갱신됐다.
- 제휴 고지가 있다.
- 모든 제휴 링크 속성이 맞다.
- 민감정보가 포함되지 않았다.
- 대표 이미지가 주제와 맞다.
- 공개 글에 쇼츠 제작 메모나 내부 자동화 문구가 없다.

가능하면 실행:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-shopping-post.ps1 -Slug "post-slug" -Version 166
```

발행 후:

- `https://trend.it.kr/posts/[slug]/`
- `https://trend.it.kr/categories/trend-shopping/`
- `https://trend.it.kr/sitemap.xml`
- 홈 최신 글 영역
- `https://trend.it.kr/version.txt`

## 검색엔진 제출

새 URL이 생기면 배포 확인 후 실행한다.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/submit-search-engines.ps1 -Urls "https://trend.it.kr/posts/[slug]/","https://trend.it.kr/categories/trend-shopping/","https://trend.it.kr/sitemap.xml" -InspectGoogle
```

- Naver / Bing IndexNow 제출
- Google Search Console 사이트맵 제출
- 가능하면 URL Inspection 확인
- 일반 블로그 글의 Search Console `색인 생성 요청` 버튼은 공식 일반 API로 대체하지 않는다.
- Google Indexing API는 일반 TrendFlow 글에 사용하지 않는다.

## 커밋 / 푸시

- 작업 전 `git status --short --branch` 확인
- 의도한 파일만 커밋
- 쇼핑 글 커밋 메시지: `Add [topic] shopping guide`
- 큰 구조 변경이 아니면 `main`에 직접 반영
- Windows Git TLS 문제가 있으면 `git -c http.sslBackend=openssl ...`를 사용
