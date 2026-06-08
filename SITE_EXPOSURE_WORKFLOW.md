# TrendFlow Site Exposure Workflow

이 문서는 `C:\Users\편돌이\Documents\사이트 노출 AI\reports\trend-it-kr-workflow.md`의 노출 점검 흐름을 TrendFlow 운영 기준에 맞게 고정한 것이다.

## 실행 설정

- Site URL: `https://trend.it.kr/`
- Repository: `trudia/flowpick-lab`
- Workspace: `C:\Users\편돌이\Documents\TrendFlow`
- 필요한 사람: AI, 집중, 공간, 커리어, 구매 기준에서 “내 상황에 맞는 판단 기준”을 찾는 방문자
- 검색 의도: 유행이나 후기보다 먼저 실패 원인, 선택 기준, 실행 조건을 확인하고 싶은 문제 해결형 검색
- 우선 노출 채널: Google, Bing, Naver, Daum/Kakao, communities, social

## 매번 확인할 순서

1. 최소 정보 정리
   - 글 또는 페이지의 대상 방문자를 한 문장으로 적는다.
   - 검색 의도는 `정보 탐색`, `비교`, `구매 전 점검`, `실행 실패 원인`, `도구 활용법` 중 어디에 가까운지 정한다.
   - 대표 키워드와 보조 키워드를 나눈다.

2. 정중한 크롤링
   - `robots.txt`와 `sitemap.xml`을 확인한다.
   - 공개 HTML만 점검한다.
   - 배포 확인 파일, 운영 보고서, 내부 문서는 방문자용 콘텐츠로 다루지 않는다.

3. 색인/노출 진단
   - title, description, canonical, H1, 본문량, noindex를 확인한다.
   - canonical URL이 sitemap에 들어가는지 확인한다.
   - 새 글, 카테고리, 홈, 검색, 아카이브의 내부 링크 흐름을 확인한다.

4. 키워드와 콘텐츠 기회 정리
   - 이미 반영된 키워드와 빠진 키워드를 나눈다.
   - 방문자가 바로 얻어갈 수 있는 기준이 있는지 본다.
   - 쇼핑/리뷰 글은 제품명보다 상황, 비용, 관리 부담, 맞는 사람과 아닌 사람을 먼저 정리한다.

5. 플랫폼별 제출/배포
   - 새 URL이 생기면 `scripts/submit-search-engines.ps1`로 IndexNow와 Google sitemap 제출을 실행한다.
   - 일반 블로그 글의 Google Search Console 색인 생성 요청 버튼은 자동 API로 대체하지 않는다.
   - Google OAuth 값이 없거나 일일 할당량이 끝났으면 제출 가능 범위와 보류 범위를 분리한다.

6. 성과 추적
   - Search Console의 노출, 클릭, 쿼리, 색인 여부를 주간 단위로 본다.
   - 클릭은 없지만 노출이 생기는 글은 제목과 상단 요약을 보강한다.
   - 구매 전환이 필요한 글은 정보성 글에서 구매 기준 글로 자연스럽게 이어지는지 확인한다.

## 로컬 진단 명령

```powershell
powershell -ExecutionPolicy Bypass -File scripts/audit-site-exposure.ps1 -ReportPath reports/trend-it-kr-exposure-audit-v176.md
```

## 공개 글 기준

- 공개 글에는 자동화 문구, 제작 메모, 쇼츠 전환 포인트를 넣지 않는다.
- 방문자가 불필요한 구매를 피하거나, 필요한 경우 자신의 조건에 맞게 좁힐 수 있어야 한다.
- 빠른 결론, 맞는 사람/아닌 사람, 확인 기준, 다음 행동을 분리한다.
- 제휴 링크가 있는 글은 고지와 링크 속성을 확인한다.
