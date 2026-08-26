#!/usr/bin/env bash
# ==============================================================================
# PandaWiki - WSL2 Linux 全套开发环境一键初始化脚本 (setup-wsl.sh)
# 适用环境: Ubuntu 22.04 / 24.04 / WSL2
# 特点: 单脚本自闭环，无外部碎文件依赖，支持全自动化流水线部署
# ==============================================================================

set -eo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "\n${CYAN}================================================================${NC}\n${CYAN}>>> $1${NC}\n${CYAN}================================================================${NC}"; }

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}     🚀 PandaWiki - WSL2 Linux 生产级开发环境一键初始化流水线     ${NC}"
echo -e "${CYAN}================================================================${NC}"

# 0. 准备环境变量文件 (~/.ai_env)
if [ ! -f "$HOME/.ai_env" ]; then
    log_info "正在生成默认 ~/.ai_env 环境变量模板..."
    cat << 'EOF' > "$HOME/.ai_env"
# PandaWiki - AI & 开发者环境变量配置
# 请在此处填入你的实际 API Key 与 Token (权限建议保持 600)

export ANTHROPIC_API_KEY=""
export OPENAI_API_KEY=""
export GEMINI_API_KEY=""
export CLAUDE_DEFAULT_MODEL="sonnet"
EOF
    chmod 600 "$HOME/.ai_env"
    log_success "已创建 ~/.ai_env (权限 600)"
fi

# ------------------------------------------------------------------------------
# 1. 基础系统与终端环境
# ------------------------------------------------------------------------------
log_step "[1/5] 📦 正在安装基础系统依赖与 Zsh/p10k 终端环境..."

sudo apt update -y
sudo apt install -y \
    build-essential curl wget git zsh tmux vim nano jq \
    htop atop tree unzip zip ca-certificates gnupg lsb-release \
    software-properties-common pkg-config libssl-dev libffi-dev \
    samba libnfc-bin libnfc-dev libnfc-examples

# 安装 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 安装 zsh 自动建议与语法高亮插件
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 配置 ~/.zshrc
if [ -f "$HOME/.zshrc" ]; then
    sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting z extract web-search)/' "$HOME/.zshrc" || true
    
    if ! grep -q "PANDAWIKI_CONFIG" "$HOME/.zshrc"; then
        cat << 'EOF' >> "$HOME/.zshrc"

# ==================== PANDAWIKI_CONFIG ====================
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# 极速秒关机别名
alias off='wsl.exe --shutdown'

# 自动加载 AI 环境变量
[ -f "$HOME/.ai_env" ] && source "$HOME/.ai_env"
EOF
    fi
fi
log_success "基础系统依赖与终端配置就绪！"

# ------------------------------------------------------------------------------
# 2. 多语言开发运行时与编译器
# ------------------------------------------------------------------------------
log_step "[2/5] ⚡ 正在配置多语言开发运行时 (Node, Python, C/C++, Java, Docker)..."

# C/C++ 与构建工具
sudo apt install -y gcc g++ clang clangd gdb make ninja-build cmake ffmpeg openjdk-11-jdk-headless || true

# Python 3 运行时
sudo apt install -y python3 python3-pip python3-venv python3-dev python3-setuptools python3-wheel
mkdir -p "$HOME/.local/bin"
python3 -m pip install --break-system-packages --user requests tqdm click anyio cryptography httpx pyyaml jinja2 || true

# 现代化 Python 快速管理器 uv
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh || true
fi

# Node.js 与 NVM
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    log_info "安装 NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_info "安装 Node.js LTS (v22)..."
nvm install 22
nvm use 22
nvm alias default 22
npm install -g corepack yarn pnpm
log_success "全栈开发运行时配置完成！"

# ------------------------------------------------------------------------------
# 3. AI Agent 开发者套件与状态栏
# ------------------------------------------------------------------------------
log_step "[3/5] 🤖 正在安装与配置 AI Agent CLI 工具链..."

npm install -g @anthropic-ai/claude-code @openai/codex @pencil.dev/cli opencode-ai wscat || true

# Cloudflared (Tunnel)
if ! command -v cloudflared &>/dev/null; then
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
    sudo install -m 755 /tmp/cloudflared /usr/local/bin/cloudflared
    rm -f /tmp/cloudflared
fi

# 创建极速轻量状态栏脚本 (~/.claude/statusline-command.sh)
mkdir -p "$HOME/.claude/skills" "$HOME/.codex/skills"
cat << 'EOF' > "$HOME/.claude/statusline-command.sh"
#!/usr/bin/env bash
input=$(cat)
user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$cwd" ] && cwd=$(pwd)
cwd="${cwd/#$HOME/~}"
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ps1_part=$(printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m' "$user" "$host" "$cwd")
session_part=""
[ -n "$model" ] && session_part="$model"
[ -n "$used" ] && session_part="$session_part ctx:$(printf '%.0f' "$used")%"
if [ -n "$session_part" ]; then printf '%s  |  %s' "$ps1_part" "$session_part"; else printf '%s' "$ps1_part"; fi
EOF
chmod +x "$HOME/.claude/statusline-command.sh"
log_success "AI Agent 生态工具配置完成！"

# ------------------------------------------------------------------------------
# 4. 物联网与嵌入式开发工具
# ------------------------------------------------------------------------------
log_step "[4/5] 🔌 正在配置嵌入式硬件与物联网套件..."

npm install -g @tuya/tuyaopen-cli || true

if ! command -v arduino-cli &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="$HOME/.local/bin" sh || true
fi

# 串口与硬件访问组权限
sudo usermod -a -G dialout "$USER" 2>/dev/null || true
sudo usermod -a -G plugdev "$USER" 2>/dev/null || true
log_success "嵌入式与串口硬件支持就绪！"

# ------------------------------------------------------------------------------
# 5. AI Skills 技能库同步
# ------------------------------------------------------------------------------
log_step "[5/5] 🧠 正在同步 AI Skills 技能库..."

mkdir -p "$HOME/.agents/skills" "$HOME/.ferry/skills"

sync_skills() {
    local src="$1"
    if [ -d "$src" ]; then
        for item in "$src"/*; do
            if [ -e "$item" ]; then
                local name
                name="$(basename "$item")"
                ln -sfn "$item" "$HOME/.claude/skills/$name"
                ln -sfn "$item" "$HOME/.codex/skills/$name"
            fi
        done
    fi
}
sync_skills "$HOME/.agents/skills"
sync_skills "$HOME/.ferry/skills"

log_step "🎉 恭喜！WSL2 Linux 全套开发环境已全部装好！"
echo -e "💡 提示："
echo -e "  1. 填入 API Key: 运行 ${YELLOW}nano ~/.ai_env${NC}"
echo -e "  2. 立即生效配置: 运行 ${YELLOW}source ~/.zshrc${NC} 或重新登录终端"
echo -e "  3. 终端极速关机: 在任意 Linux 命令行输入 ${YELLOW}off${NC} 即可秒关机并释放内存！"
echo -e "${GREEN}================================================================${NC}"
