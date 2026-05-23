# TrendFlow V78 - 추천 시리즈 이미지 강제 축소 업데이트

## 핵심 수정

- 추천 시리즈 영역 이미지가 크게 보이는 문제를 막기 위해 `styles.css` 맨 아래에 강제 오버라이드 CSS 추가
- 홈페이지와 카테고리 페이지에 인라인 critical CSS 추가
- `styles.css?v=78`, `theme.js?v=78`로 캐시 버스터 갱신
- 추천 시리즈 썸네일 높이: 데스크톱 약 38px, 모바일 약 42px
- 카테고리 읽는 순서 썸네일: 약 54×44px

## 업로드 방법

1. ZIP 압축 해제
2. GitHub 저장소 루트에 전체 파일 덮어쓰기
3. GitHub Pages 배포 완료 후 `/deploy-check-v78.html` 확인
4. 브라우저에서 강력 새로고침: Ctrl + F5

## 주의

이전 버전이 계속 보이면 GitHub에 업로드된 파일이 루트가 아니라 하위 폴더에 들어갔을 가능성이 큽니다. ZIP 내부의 `index.html`, `styles.css`, `assets`, `categories`, `posts`가 저장소 루트에 위치해야 합니다.
