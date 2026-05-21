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
