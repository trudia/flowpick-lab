# V55 Route Sync Stabilization

현재 라이브에서 일부 카테고리 페이지가 예전 `Category Hub` 구조로 보이는 문제를 해결하기 위한 버전입니다.

## 핵심 조치

- categories/*.html 전체 재생성
- categories/<slug>/index.html 전체 재생성
- 루트의 ai-productivity.html / focus-wellbeing.html / minimal-space.html / trend-shopping.html은 canonical 카테고리로 리다이렉트
- posts/*.html 과 posts/<slug>/index.html 동기화 유지
- search.html 과 search/index.html 동기화 유지

## 이유

정적 호스팅/CDN 환경에서 `.html` 경로와 clean URL 경로가 서로 다른 파일을 보여주면,
홈은 최신인데 특정 카테고리만 예전 UI로 보일 수 있습니다.
V55는 해당 경로들을 모두 최신 구조로 동기화합니다.
