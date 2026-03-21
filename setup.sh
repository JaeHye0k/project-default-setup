#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# project-default-setup installer
# https://github.com/JaeHye0k/project-default-setup
# ============================================================

REPO="JaeHye0k/project-default-setup"
TARGET_DIR="$(pwd)"
TEMP_DIR=""
VERSION=""
MODE="auto" # auto | update | install

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
# 인자 파싱
# ============================================================
show_help() {
    cat <<'HELP'
Usage:
  curl -fsSL https://raw.githubusercontent.com/JaeHye0k/project-default-setup/main/setup.sh | bash
  curl -fsSL .../setup.sh | bash -s -- [OPTIONS]

Options:
  --update          강제 업데이트 모드
  --version <ver>   특정 버전 설치 (예: 1.0.0)
  --help            이 도움말 표시
HELP
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --update)  MODE="update"; shift ;;
        --version) VERSION="$2"; shift 2 ;;
        --help)    show_help ;;
        *)         error "알 수 없는 옵션: $1 (--help 참고)" ;;
    esac
done

# ============================================================
# 필수 도구 확인
# ============================================================
for cmd in curl tar node npm; do
    command -v "$cmd" &>/dev/null || error "'$cmd'이(가) 설치되어 있지 않습니다."
done

# ============================================================
# 버전 결정
# ============================================================
if [[ -z "$VERSION" ]]; then
    info "최신 버전 확인 중..."
    VERSION=$(curl -fsSL "https://raw.githubusercontent.com/$REPO/main/VERSION" | tr -d '[:space:]')
fi
info "대상 버전: v${VERSION}"

# ============================================================
# 설치/업데이트 모드 판별
# ============================================================
CURRENT_VERSION=""
if [[ -f "$TARGET_DIR/.setup-version" ]]; then
    CURRENT_VERSION=$(cat "$TARGET_DIR/.setup-version" | tr -d '[:space:]')
    if [[ "$MODE" == "auto" ]]; then
        MODE="update"
    fi
else
    MODE="install"
fi

if [[ "$MODE" == "update" && "$CURRENT_VERSION" == "$VERSION" ]]; then
    ok "이미 최신 버전입니다 (v${VERSION}). 스킵합니다."
    exit 0
fi

if [[ "$MODE" == "update" ]]; then
    info "업데이트: v${CURRENT_VERSION} → v${VERSION}"
else
    info "첫 설치: v${VERSION}"
fi

# ============================================================
# 다운로드 & 압축 해제
# ============================================================
TEMP_DIR=$(mktemp -d)
cleanup() { [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

ARCHIVE_URL="https://github.com/$REPO/archive/refs/tags/v${VERSION}.tar.gz"
info "다운로드 중... ($ARCHIVE_URL)"

if ! curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TEMP_DIR" 2>/dev/null; then
    error "v${VERSION} 버전을 다운로드할 수 없습니다. 태그가 존재하는지 확인해주세요."
fi

# 압축 해제된 디렉토리 찾기 (project-default-setup-1.0.0 형태)
SRC_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
[[ -d "$SRC_DIR" ]] || error "압축 해제 실패"

# ============================================================
# 파일 복사 (덮어쓰기 대상)
# ============================================================
info "설정 파일 복사 중..."

# 디렉토리 단위 복사
COPY_DIRS=(".vscode" ".claude" ".agents" ".github")
for dir in "${COPY_DIRS[@]}"; do
    if [[ -d "$SRC_DIR/$dir" ]]; then
        # 기존 디렉토리 제거 후 복사 (깔끔한 덮어쓰기)
        rm -rf "$TARGET_DIR/$dir"
        cp -R "$SRC_DIR/$dir" "$TARGET_DIR/$dir"
        ok "  $dir/"
    fi
done

# 개별 파일 복사
COPY_FILES=(".eslintrc" ".prettierrc" "skills-lock.json")
for file in "${COPY_FILES[@]}"; do
    if [[ -f "$SRC_DIR/$file" ]]; then
        cp "$SRC_DIR/$file" "$TARGET_DIR/$file"
        ok "  $file"
    fi
done

# ============================================================
# .gitignore 병합
# ============================================================
if [[ -f "$SRC_DIR/.gitignore" ]]; then
    if [[ ! -f "$TARGET_DIR/.gitignore" ]]; then
        cp "$SRC_DIR/.gitignore" "$TARGET_DIR/.gitignore"
        ok "  .gitignore (새로 생성)"
    else
        added=0
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" ]] && continue
            if ! grep -qxF "$line" "$TARGET_DIR/.gitignore"; then
                echo "$line" >> "$TARGET_DIR/.gitignore"
                ((added++))
            fi
        done < "$SRC_DIR/.gitignore"
        if [[ $added -gt 0 ]]; then
            ok "  .gitignore (${added}개 항목 추가)"
        else
            ok "  .gitignore (변경 없음)"
        fi
    fi
fi

# ============================================================
# package.json 스마트 병합
# ============================================================
info "package.json 병합 중..."

if [[ ! -f "$TARGET_DIR/package.json" ]]; then
    # package.json이 없으면 그대로 복사 (setup 전용 필드 제거)
    cp "$SRC_DIR/package.json" "$TARGET_DIR/package.json"
    ok "  package.json (새로 생성)"
else
    # node -e로 스마트 병합
    node -e "
const fs = require('fs');
const existing = JSON.parse(fs.readFileSync('$TARGET_DIR/package.json', 'utf8'));
const setup = JSON.parse(fs.readFileSync('$SRC_DIR/package.json', 'utf8'));

// devDependencies 병합 (셋업 값 우선)
existing.devDependencies = {
    ...(existing.devDependencies || {}),
    ...(setup.devDependencies || {})
};

// scripts 병합 (기존 값 유지, 새 항목만 추가)
existing.scripts = {
    ...(setup.scripts || {}),
    ...(existing.scripts || {})
};

fs.writeFileSync('$TARGET_DIR/package.json', JSON.stringify(existing, null, 4) + '\n');
"
    ok "  package.json (병합 완료)"
fi

# ============================================================
# 버전 기록
# ============================================================
echo "$VERSION" > "$TARGET_DIR/.setup-version"

# ============================================================
# npm install
# ============================================================
info "의존성 설치 중 (npm install)..."
cd "$TARGET_DIR"
npm install --save-dev 2>&1 | tail -1
ok "의존성 설치 완료"

# ============================================================
# .DS_Store 파일 정리
# ============================================================
find "$TARGET_DIR" -name ".DS_Store" -not -path "*/node_modules/*" -delete 2>/dev/null || true

# ============================================================
# 완료
# ============================================================
echo ""
echo -e "${GREEN}========================================${NC}"
if [[ "$MODE" == "update" ]]; then
    echo -e "${GREEN} 업데이트 완료! v${CURRENT_VERSION} → v${VERSION}${NC}"
else
    echo -e "${GREEN} 설치 완료! v${VERSION}${NC}"
fi
echo -e "${GREEN}========================================${NC}"
echo ""
echo "설치된 설정:"
echo "  - ESLint + Prettier"
echo "  - VSCode 설정 (포맷팅, 확장 프로그램)"
echo "  - Claude Code (에이전트, 스킬, 명령어)"
echo "  - GitHub 템플릿 (PR, Issue)"
echo ""
