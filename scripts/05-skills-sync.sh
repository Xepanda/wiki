#!/usr/bin/env bash
# ==============================================================================
# 05-skills-sync.sh: 自定义 AI Skills 技能库软链接自动同步与管理
# 说明: 将 ~/.agents/skills 与 ~/.ferry/skills 中的所有技能软链接至 Claude Code 与 Codex
# ==============================================================================

set -eo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

log_info ">>> 正在同步 AI Skills 软链接..."

mkdir -p "$HOME/.claude/skills"
mkdir -p "$HOME/.codex/skills"
mkdir -p "$HOME/.agents/skills"
mkdir -p "$HOME/.ferry/skills"

sync_dir() {
    local src="$1"
    if [ -d "$src" ]; then
        for item in "$src"/*; do
            if [ -e "$item" ]; then
                local name
                name="$(basename "$item")"
                ln -sfn "$item" "$HOME/.claude/skills/$name"
                ln -sfn "$item" "$HOME/.codex/skills/$name"
                log_info "  -> 链接技能: $name"
            fi
        done
    fi
}

sync_dir "$HOME/.agents/skills"
sync_dir "$HOME/.ferry/skills"

log_success "AI Skills 软链接同步完成。"
