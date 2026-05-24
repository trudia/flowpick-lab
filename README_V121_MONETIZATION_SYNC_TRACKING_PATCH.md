# V121 Monetization Sync + Tracking Patch

- 홈 최근 글을 최신 수익화 글 5개 + AI 허브 중심으로 재정렬
- 홈 구매 기준 추천 시리즈를 AI 허브 → 미니 제습기 → 보조배터리 → LED 스탠드 순으로 정리
- 쇼핑&리뷰 카테고리 상단 시리즈를 AI 허브 + 5개 상세 수익화 글로 재정렬
- 쇼핑&리뷰 카테고리 글 목록을 최신 수익화 글 중심으로 재정렬
- AI 추천 제품 허브 글은 5개 상세 글 링크 UI 유지
- 5개 상세 글과 AI 허브에 클릭 추적용 data-track 속성 추가
- gtag/dataLayer가 있으면 affiliate_click, hub_to_detail_click, subscribe_form_click 등이 자동 전송되도록 준비 스크립트 삽입
- GA4 측정 ID 자체는 포함하지 않았습니다. 추후 공통 head 또는 GTM/gtag 설치 후 이벤트가 수집됩니다.
