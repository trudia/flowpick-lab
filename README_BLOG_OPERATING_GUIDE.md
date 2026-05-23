# TrendFlow V59 Jekyll/Markdown 블로그 운영형

이 버전의 목적은 **앞으로 글을 추가할 때 사이트 전체 ZIP을 만들지 않아도 되게 하는 것**입니다.

## 처음 한 번만 할 일

이 V59 ZIP을 기존 GitHub 저장소에 전체 반영하세요.

## 이후 새 글 추가 방법

새 글을 추가할 때는 기본적으로 아래 2개만 추가하면 됩니다.

```text
_posts/2026-05-23-example-title.md
assets/featured/example-title.webp
```

그러면 GitHub Pages/Jekyll이 자동으로:

```text
홈 최신 글
카테고리 글 목록
검색 페이지
글 상세 페이지
```

에 반영합니다.

## 글 파일 예시

```markdown
---
title: "AI로 블로그 글 초안을 30분 안에 만드는 루틴"
date: 2026-05-23
category: ai-productivity
summary: "키워드 하나를 글감, 목차, 본문 초안, 제목 후보까지 연결해 블로그 글 작성 시간을 줄이는 AI 활용 루틴입니다."
image: "/assets/featured/ai-blog-draft-30min-routine.webp"
tags: [AI, 블로그, 생산성]
---

## 이 글이 필요한 상황

본문을 작성하세요.
```

## 카테고리 값

```text
ai-productivity
focus-wellbeing
minimal-space
trend-shopping
```

## 이미지 경로

대표 이미지는 아래에 넣으세요.

```text
assets/featured/파일명.webp
```

글의 front matter에는 이렇게 입력합니다.

```text
image: "/assets/featured/파일명.webp"
```

## 기존 방식과의 차이

이전에는 글 하나를 추가해도 홈, 카테고리, 검색, 글 상세 HTML을 모두 갱신해야 했습니다.

V59부터는 `_posts/*.md` 파일이 원본이고, Jekyll이 목록과 상세 페이지를 자동 생성합니다.
