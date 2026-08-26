#!/usr/bin/env bash
# ==============================================================================
# 04-embedded-iot-tools.sh: 物联网与嵌入式硬件开发套件
# 包括: TuyaOpen CLI, Arduino CLI, NFC 工具套件, 串口与硬件访问权限
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

# 确保 NVM / Node 环境可用
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_info ">>> 1. 安装 TuyaOpen 嵌入式开发 CLI..."
npm install -g @tuya/tuyaopen-cli || true

# 2. 安装 Arduino CLI
log_info ">>> 2. 安装与配置 Arduino CLI..."
mkdir -p "$HOME/.local/bin"
if ! command -v arduino-cli &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="$HOME/.local/bin" sh
fi

mkdir -p "$HOME/.arduino15"
cat << 'EOF' > "$HOME/.arduino15/arduino-cli.yaml"
board_manager:
  additional_urls: []
daemon:
  port: "50051"
directories:
  data: ~/.arduino15
  downloads: ~/.arduino15/staging
  user: ~/Arduino
library:
  enable_unsafe_install: false
logging:
  file: ""
  format: text
  level: info
EOF

# 3. 硬件串口与设备访问权限配置 (针对当前用户添加 dialout / plugdev 组)
log_info ">>> 3. 配置串口与 USB 硬件调试权限..."
sudo usermod -a -G dialout "$USER" 2>/dev/null || true
sudo usermod -a -G plugdev "$USER" 2>/dev/null || true

# 4. 初始化 TuyaOpen 目录结构
mkdir -p "$HOME/.tuya"
mkdir -p "$HOME/.tuyaopen"

log_success "04-embedded-iot-tools.sh 执行完毕。"
