# FlowPick Lab MVP Static Site

이 파일은 Cloudflare Pages + GitHub에 바로 올릴 수 있는 정적 홈페이지 MVP입니다.

## 파일 구성

- `index.html`: 홈페이지 구조
- `styles.css`: 디자인 CSS
- `README.md`: 안내문

## GitHub 업로드 방법

1. GitHub에서 새 Repository 생성
2. Repository 이름 예시: `flowpick-lab`
3. Public 또는 Private 선택
4. 생성 후 `Add file` → `Upload files`
5. `index.html`, `styles.css`, `README.md` 업로드
6. `Commit changes` 클릭

## Cloudflare Pages 연결 방법

1. Cloudflare → Workers & Pages
2. Create application
3. Pages 선택
4. Connect to Git 선택
5. GitHub 계정 연결
6. `flowpick-lab` 저장소 선택
7. 설정값:
   - Framework preset: None
   - Build command: 비워두거나 `exit 0`
   - Build output directory: `/`
8. Save and Deploy

## 수정할 곳

`index.html`에서 아래 내용을 바꾸면 됩니다.

- FlowPick Lab → 원하는 사이트 이름
- 카테고리명
- 소개 문구
- 제휴 고지 문구
- 버튼 링크
- 쿠팡파트너스 링크
