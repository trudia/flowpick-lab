# 트렌드플로우 v7-2026-05-22

개선 내용:
- 4개 카테고리 전체를 허브형 페이지로 통일
- AI 생산성 / 집중력 & 웰빙 / 공간 & 미니멀 / 트렌드 쇼핑 모두 상황별 선택 카드 추가
- 모든 글에 선택 기준 비교표와 실패 패턴 추가
- 소개 페이지 about.html 추가
- 제휴 안내 affiliate.html 추가
- CSS 캐시 버스터 v7 적용
- sitemap.xml 최신화

업로드:
1. 압축 해제
2. GitHub 저장소에서 Add file → Upload files
3. 모든 파일과 폴더를 전체 덮어쓰기
4. Commit changes
5. Cloudflare Pages 배포 확인
6. 시크릿 창 또는 Ctrl+F5로 확인


## v8 minimal hub update

반영 내용:
- 공간 & 미니멀 카테고리의 아이템 섹션을 설명 + 버튼 구조로 변경
- Before / After 섹션 추가
- 아이템별 구매 전 체크리스트 구체화
- 사이드바의 순서와 링크를 분리
- SEO용 설명 문단 추가
- CSS 캐시 버스터 v8 적용

확인 경로:
- /categories/minimal-space.html
- /categories/minimal-space


## v9 homepage update

반영 내용:
- 메인 문구를 '생활 트렌드를 콘텐츠와 실용 조합으로 바꿉니다'로 강화
- 이번 주 업데이트에 날짜 표시 추가
- 새로 정리한 가이드를 4개 카테고리 균형형으로 재배치
- 상황별 추천 조합을 문제 상황 중심으로 변경
- 트렌드플로우 큐레이션 기준 섹션 추가
- 많이 찾는 주제 키워드 섹션 추가
- 푸터 소개 / 제휴 안내 유지
- CSS 캐시 버스터 v9 적용

확인 경로:
- /
- /index.html


## v10-2026-05-22 sync fix

확인 결과:
- 홈페이지 v9는 정상 반영되어 있음.
- 공간 & 미니멀 카테고리에는 v8에서 추가했던 Before / After, 아이템별 설명, 아이템별 구매 전 체크리스트, 사이드바 분리 구조가 누락되어 있음.

이번 v10 반영:
- categories/minimal-space.html을 v10 최종본으로 강제 교체
- styles.css에 v10 전용 CSS 재추가
- 모든 HTML의 CSS 캐시 버스터를 v10으로 변경
- version.txt 추가

업로드 시 주의:
1. 반드시 categories/minimal-space.html을 덮어쓰기
2. 반드시 styles.css도 덮어쓰기
3. Cloudflare Pages 배포 후 Ctrl+F5 또는 시크릿 창에서 확인
4. /version.txt가 v10으로 보이면 업로드 성공


## v11-2026-05-22 deep category update

현재 상태 분석:
- 홈페이지 v9 정상 반영.
- 공간 & 미니멀 v10 정상 반영.
- 다음 병목은 AI 생산성, 집중력 & 웰빙, 트렌드 쇼핑 카테고리의 깊이가 공간 & 미니멀보다 약한 점.

이번 업데이트:
- AI 생산성 카테고리 심화 허브화
- 집중력 & 웰빙 카테고리 심화 허브화
- 트렌드 쇼핑 카테고리 심화 허브화
- 각 카테고리에 SEO 설명, Before/After, 아이템 설명+버튼, 선택 전 체크리스트, 분리형 사이드바 추가
- 사진 적용 계획 페이지 photo-plan.html 추가
- CSS 캐시 버스터 v11 적용
- version.txt v11 적용

사진 적용 권장:
- 지금은 자체 SVG 유지
- 글 20~30개, 제품군, 쿠팡파트너스 링크 구조가 확정된 후 직접 촬영 사진/통일 이미지 적용


## v12-fixed-2026-05-22

중요:
- 이전 v12는 최소 구조로 생성되어 업로드하면 기존 디자인이 깨질 수 있었음.
- 이번 v12-fixed는 v11 안정 버전을 기준으로 개선사항만 병합한 안전 패치.

반영:
1. 홈페이지 메시지 유지/강화
2. 검색 페이지 추가
3. 허브 글 5개 추가
4. 내부 링크 구조 강화
5. FAQ 추가
6. 쇼츠 연결 구조 추가
7. CTA 검색/허브 연결 개선
8. 이미지 전략은 SVG 유지 + 추후 WebP 전환
9. 모바일 속도: SVG 유지, 외부 라이브러리 미사용
10. version.txt로 배포 확인


## v13 real content update
- 카테고리별 실제 글 3개씩 총 12개 추가
- AI 생성 실사형 대표 이미지 4개 추가
- 각 카테고리 페이지에 실전 글 섹션 추가
- 홈페이지에 실사용 리뷰 섹션 추가
- 이미지 우선순위 가이드 보강
- 검색 페이지 확장


## v14 category posts + images update
- 카테고리별 실제 글 3개씩 유지 및 이미지 개별 적용
- 신규 12개 글에 추천 우선순위 박스 추가
- 카테고리 페이지에 추천 읽기 우선순위 및 트렌드 비교 분석 표 추가
- 홈페이지에 카테고리별 추천 읽기 순서 섹션 추가
- 글 카드 UI를 이미지 중심으로 보강


## v15-full-sync-2026-05-22

v15 full sync 반영 내용:
- v14의 실제 글 12개, 이미지, 추천 우선순위, 트렌드 비교 분석 구조 유지
- 홈페이지에 전환 흐름 섹션과 v15 full sync 표시 추가
- 카테고리 페이지 4개에 상품 비교 박스 동기화
- 전체 글에 구매 전 비교 박스, 다음 행동 CTA, 제휴 고지 동기화
- 정책/제휴/검색 페이지의 헤더 문구 일관성 보강
- data/affiliate-links-template.json 추가
- version.txt로 배포 확인 가능

업로드 후 확인:
- /
- /categories/trend-shopping.html
- /posts/sidehustle-gear-priority.html
- /affiliate.html
- /version.txt
