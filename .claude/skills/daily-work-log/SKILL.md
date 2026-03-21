---
name: daily-work-log
description: "Notion 블록 링크를 받아 당일 git 커밋을 요약하여 Notion 페이지에 작성하는 스킬. 사용자가 Notion 링크와 함께 '오늘 작업 정리', '일일 작업 로그', 'daily work log', '오늘 뭐했는지 정리', '작업 내역 Notion에 써줘' 등을 요청할 때 사용."
---

# Daily Work Log

Notion 블록 링크를 받아 당일 git 커밋을 분석하고, 개조식 글머리 기호로 Notion 페이지에 작성한다.

## Workflow

### 1. 커밋 수집

오늘 날짜 기준으로 현재 리포지토리의 커밋을 수집한다.

```bash
git log --all --oneline --since="$(date +%Y-%m-%d)T00:00:00" --until="$(date -v+1d +%Y-%m-%d)T00:00:00" --format="%h %s (%ad)" --date=iso
```

- stash 자동 커밋(`index on`, `On <branch>:`)은 제외

### 2. 작업 내용 요약

각각의 커밋의 diff를 조회한다.
조회한 diff 와 commit 메시지를 참고하여 작업 내용을 요약한다.

** 꼭 포함되어야할 내용 **

- 작업 내용(what): 무슨 작업을 했는가?
- 작업 이유(why): 해당 작업을 왜 했는가?
- 작업 방법(how): 어떻게 했는가?

만약 정보가 충분하지 않다면 사용자에게 역질문을 해서 맥락을 제공받도록 한다.

**작성 규칙:**

- 글머리 기호(`-`) 사용, 개조식
- 각 항목에 대해 자세히 작성
- `- 커밋 해시: 내용` 이런식으로 작성

### 3. Notion 페이지 조회

Notion MCP의 `notion-fetch`로 대상 페이지를 조회한다.

- `##Activity` 섹션에 다음과 같은 형식으로 글을 삽입한다. (./examples/sample.md 참고)
    ```
    ### 폴더명
    - 커밋 해시: 내용
    - 커밋 해시: 내용
    ```

### 4. Notion 페이지 작성

Notion MCP의 `notion-update-page`로 내용을 작성한다.

- `replace_content_range` 또는 `insert_content_after` 커맨드 사용
- 기존 콘텐츠가 있으면 덮어쓰지 않고 적절한 위치에 삽입
- 빈 섹션(`<empty-block/>`)이 있으면 해당 영역을 대체

### 5. 결과 보고

작성 완료 후 사용자에게 다음을 보고한다:

- 총 커밋 수 및 요약 항목 수
- Notion 페이지 링크
