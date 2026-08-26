#!/usr/bin/env bash
# ==============================================================================
# 01-base-system.sh: 基础系统包、APT 软件源、Zsh 终端环境及 Samba 共享服务
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

log_info ">>> 正在初始化基础系统包与依赖..."

# 1. APT 软件源更新与基础编译、网络、系统调试工具安装
sudo apt update -y
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    zsh \
    tmux \
    vim \
    nano \
    jq \
    htop \
    atop \
    tree \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    pkg-config \
    libssl-dev \
    libffi-dev \
    samba \
    libnfc-bin \
    libnfc-dev \
    libnfc-examples

log_success "基础系统工具安装完成。"

# 2. Oh My Zsh 与插件配置
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "正在安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 安装 zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log_info "安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# 安装 zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log_info "安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 配置 ~/.zshrc 核心配置
if [ -f "$HOME/.zshrc" ]; then
    # 替换 plugins 列表
    sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting z extract web-search)/' "$HOME/.zshrc" || true
    
    # 注入 PATH 与环境加载
    if ! grep -q "source ~/.ai_env" "$HOME/.zshrc"; then
        cat << 'EOF' >> "$HOME/.zshrc"

# ==================== 自定义开发环境与工具链 PATH ====================
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.ferry/bin:$PATH"
export PATH="$HOME/.clix/bin:$PATH"

# 自动加载 AI 环境变量
[ -f "$HOME/.ai_env" ] && source "$HOME/.ai_env"
EOF
    fi
fi

# 3. Samba 共享目录配置 (/home/share/samba)
log_info "配置 Samba 共享目录..."
sudo mkdir -p /home/share/samba
sudo chmod -R 777 /home/share/samba

SAMBA_CONF="/etc/samba/smb.conf"
if [ -f "$SAMBA_CONF" ]; then
    if ! grep -q "\[share\]" "$SAMBA_CONF"; then
        sudo tee -a "$SAMBA_CONF" << 'EOF'

[share]
    comment = Development Shared Directory
    path = /home/share/samba
    browsable = yes
    read only = no
    guest ok = yes
    create mask = 0777
    directory mask = 0777
EOF
        sudo systemctl restart smbd 2>/dev/null || sudo service smbd restart 2>/dev/null || true
        log_success "Samba 共享配置已添加并重启服务。"
    fi
fi

log_success "01-base-system.sh 执行完毕。"
