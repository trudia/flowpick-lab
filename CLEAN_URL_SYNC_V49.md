# V49 Clean URL Sync

라이브 사이트에서 `/categories/focus-wellbeing.html` 링크가 `/categories/focus-wellbeing` 형태로 리다이렉트되는 환경을 고려해,
이번 버전은 `.html` 파일과 clean URL 폴더형 `index.html`을 함께 제공합니다.

## 포함된 동기화

- categories/*.html
- categories/<slug>/index.html
- posts/*.html
- posts/<slug>/index.html
- search.html
- search/index.html

이렇게 하면 CDN/GitHub Pages/Cloudflare가 `.html`을 제거해도 최신 페이지가 표시됩니다.
