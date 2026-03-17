---
name: create-pr
description: "source 브랜치에서 target 브랜치로 GitHub PR을 생성하는 스킬. 프로젝트의 PR 템플릿(.github/PULL_REQUEST_TEMPLATE.md)을 기반으로 커밋 히스토리를 분석하여 PR 본문을 자동 작성한다. 사용자가 'PR 만들어줘', 'PR 올려줘', 'create PR', 'pull request', 'PR 생성' 등을 요청할 때 사용."
---

# Create PR

source 브랜치에서 target 브랜치로 PR을 생성한다. 프로젝트의 `.github/PULL_REQUEST_TEMPLATE.md`를 기반으로 PR 본문을 자동 작성한다.

## Workflow

### 1. 인자 파싱

사용자 입력에서 source와 target 브랜치를 파싱한다.

- 형식: `/create-pr <source> <target>` 또는 자연어
- source 미지정 시: 현재 브랜치 사용
- target 미지정 시: `main` 사용

### 2. 사전 검증

```bash
# 현재 브랜치 확인
git branch --show-current

# 커밋되지 않은 변경사항 확인
git status

# source 브랜치가 remote에 push 되어있는지 확인
git log origin/<source>..<source> --oneline
```

- 커밋되지 않은 변경사항이 있으면 사용자에게 알리고 계속 진행할지 확인
- push 안 된 커밋이 있으면 push 여부를 사용자에게 확인

### 3. 변경사항 분석

```bash
# target 대비 커밋 히스토리
git log <target>..<source> --oneline

# target 대비 변경된 파일 목록
git diff <target>...<source> --stat

# target 대비 전체 diff (PR 본문 작성용)
git diff <target>...<source>
```

### 4. PR 본문 작성

프로젝트의 `.github/PULL_REQUEST_TEMPLATE.md`를 Read 도구로 읽어 템플릿 구조를 파악한다.

커밋 히스토리와 diff를 분석하여 템플릿의 각 섹션을 채운다:

- **Overview**: 변경의 핵심 목적을 한 문장으로 요약
- **What's Changed**: 변경된 코드를 구체적 불렛 포인트로 정리
- **How to Test**: 검증 방법을 단계별로 설명
- **Screenshots**: UI 변경이 있으면 스크린샷 필요 문구, 없으면 "N/A"
- **Checklist**: 체크리스트 항목 포함

### 5. PR 타이틀 작성

- 70자 이내, 한국어
- 변경의 핵심을 간결하게 표현
- prefix 사용: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:` 등

### 6. 사용자 확인

PR 생성 전 타이틀과 본문을 사용자에게 보여주고 승인을 받는다.

### 7. PR 생성

```bash
gh pr create \
  --base <target> \
  --head <source> \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)"
```

PR URL을 사용자에게 반환한다.
