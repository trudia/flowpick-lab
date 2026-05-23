# TrendFlow V77 Redeploy - Compact Series Thumbnails

이 업데이트는 V76의 추천 시리즈 축소 UI가 실제 사이트에 반영되지 않은 경우를 대비한 재배포용 전체 ZIP입니다.

## 반영 내용

- 추천 시리즈 영역에서 `카테고리 보기` 버튼 제거
- `1단계~5단계 + 긴 설명` 구조 제거
- 홈 추천 시리즈를 `작은 이미지 + 짧은 제목` 썸네일형으로 변경
- 각 카테고리의 읽는 순서 영역도 작은 이미지 카드형으로 변경
- `styles.css`, `index.html`, `categories/*`, `posts/*`, `archive/*`, `search/*`, `content/posts.json`, `sitemap.xml` 전체 포함
- `theme.js?v=77` 캐시 버스터 반영
- `/version.txt`, `/deploy-check-v77.html` 배포 확인용 파일 추가

## 업로드 방법

1. ZIP 압축을 풉니다.
2. 압축을 푼 파일과 폴더 전체를 GitHub 저장소 루트에 덮어씁니다.
3. 특히 아래 파일들이 실제 저장소에 바뀌었는지 확인합니다.
   - `index.html`
   - `styles.css`
   - `categories/focus-wellbeing/index.html`
   - `categories/ai-productivity/index.html`
   - `version.txt`
4. GitHub Pages 배포 후 `/deploy-check-v77.html` 또는 `/version.txt` 접속으로 반영 여부를 확인합니다.

## 확인 포인트

홈의 추천 시리즈가 아래처럼 보여야 합니다.

- AI 입문
- 집중 회복
- 공간 정리
- 구매 기준

각 시리즈 내부는 긴 설명 없이 작은 이미지 썸네일과 짧은 제목만 표시됩니다.
