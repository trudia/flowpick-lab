# 트렌드플로우 v20 Editor Mode 사용법

## 목적
v20은 사용자가 직접 글/사진/쿠팡파트너스 링크를 수정할 수 있도록 편집 가능한 원본 파일을 분리한 버전입니다.

## 직접 수정할 수 있는 파일

### 1. 글 원본
`content/posts.json`

- title: 글 제목
- summary: 글 요약
- image: 글 대표 이미지
- sections: 본문 섹션

### 2. 카테고리 원본
`content/categories.json`

- 카테고리명
- 설명
- 대표 이미지
- 추천 읽기 순서

### 3. 쿠팡파트너스 링크
`content/affiliate-products.json`

- product_url의 `수정예정`을 실제 쿠팡파트너스 링크로 교체하세요.

### 4. 직접 올리는 이미지
`assets/uploads/`

권장:
- 파일명: 영어/숫자/하이픈
- 예: desk-before-after.webp
- 크기: 1280x720
- 용량: 300KB 이하

## 새 글 만들기
브라우저에서 `/editor.html`을 열어 글 정보를 입력하면 HTML을 생성할 수 있습니다.

생성된 HTML은 GitHub에서 `posts/파일명.html`로 새 파일을 만들어 붙여넣으면 됩니다.

## 운영 추천
처음에는 내가 만든 글 구조를 유지하고,
네가 직접 고칠 부분은 다음 3개로 제한하는 것이 좋습니다.

1. 제목/요약
2. 실제 경험 한두 줄
3. 직접 찍은 이미지 또는 쿠팡 링크
