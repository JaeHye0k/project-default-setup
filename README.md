# Project Default Setup

프로젝트 시작 시 필요한 기본 설정들을 모아놓은 템플릿입니다. 명령어 하나로 설치하고, 업데이트할 수 있습니다.

## 포함된 설정

| 카테고리 | 내용 |
|----------|------|
| **코드 품질** | ESLint + Prettier (`.eslintrc`, `.prettierrc`) |
| **에디터** | VSCode 설정, 추천 확장 프로그램, MCP 서버 (`.vscode/`) |
| **AI 에이전트** | Claude Code 에이전트, 스킬, 슬래시 명령어 (`.claude/`) |
| **성능 가이드** | Vercel React Best Practices 64개 규칙 (`.agents/`) |
| **GitHub** | PR 템플릿, Issue 템플릿 (`.github/`) |
| **Git** | `.gitignore` |

## 설치

새 프로젝트 디렉토리에서 아래 명령어를 실행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/JaeHye0k/project-default-setup/main/setup.sh | bash
```

### 특정 버전 설치

```bash
curl -fsSL https://raw.githubusercontent.com/JaeHye0k/project-default-setup/main/setup.sh | bash -s -- --version 1.0.0
```

## 업데이트

이미 설치된 프로젝트에서 최신 버전으로 업데이트합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/JaeHye0k/project-default-setup/main/setup.sh | bash -s -- --update
```

> 동일 버전이면 자동으로 스킵됩니다.

## 파일 처리 방식

| 방식 | 대상 |
|------|------|
| **덮어쓰기** | `.eslintrc`, `.prettierrc`, `.vscode/*`, `.claude/*`, `.agents/*`, `.github/*`, `skills-lock.json` |
| **스마트 병합** | `package.json` — `devDependencies`와 `scripts`만 추가/업데이트하고 기존 항목 유지 |
| **추가만** | `.gitignore` — 누락된 항목만 append |

## 필수 요구사항

- Node.js / npm
- curl
- tar

## 버전 릴리스 (관리자용)

```bash
# 1. 설정 변경 후 VERSION 파일 수정
echo "1.1.0" > VERSION

# 2. 커밋 & 태그
git add -A
git commit -m "chore: bump version to 1.1.0"
git tag v1.1.0
git push origin main --tags
```
