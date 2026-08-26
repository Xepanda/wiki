#!/usr/bin/env bash
# ==============================================================================
# 02-dev-runtimes.sh: 编程语言、编译器及开发运行时环境
# 包括: Node.js (NVM), Python 3.12 & Pip, Java OpenJDK 11, C/C++ 编译工具链, FFmpeg
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

# 1. C/C++ 编译套件与 CMake, Ninja, GDB
log_info ">>> 1. 安装 C/C++ 编译器、构建工具及调试器..."
sudo apt install -y \
    gcc \
    g++ \
    clang \
    clangd \
    gdb \
    make \
    ninja-build \
    cmake

# 2. 多媒体工具 FFmpeg & 音视频编解码库
log_info ">>> 2. 安装 FFmpeg 及音视频多媒体支持库..."
sudo apt install -y \
    ffmpeg \
    gstreamer1.0-libav \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libswresample-dev

# 3. Java 环境 (OpenJDK 11)
log_info ">>> 3. 安装 Java OpenJDK 11..."
sudo apt install -y openjdk-11-jdk-headless || sudo apt install -y default-jdk

# 4. Python 3 环境与核心模块
log_info ">>> 4. 配置 Python 3 运行时及虚拟环境支持..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    python3-wheel

mkdir -p "$HOME/.local/bin"
# 安装 Python 常用构建、IoT配置与文档工具
python3 -m pip install --break-system-packages --user \
    requests \
    tqdm \
    click \
    click-completion \
    click-option-group \
    anyio \
    cryptography \
    pycryptodome \
    kconfiglib \
    pyserial \
    pyyaml \
    jinja2 \
    cmake \
    ninja \
    sphinx \
    docutils \
    httpx \
    || true

# 安装现代化 Python 快速包管理器 uv (按需)
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh || true
fi

# 5. Node.js 运行时及包管理器 (NVM + Node v22)
log_info ">>> 5. 配置 Node.js 与 NVM 环境..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    log_info "正在安装 NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# 加载 NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_info "安装并启用 Node.js v22 (LTS)..."
nvm install 22
nvm use 22
nvm alias default 22

# 安装全局包管理器
npm install -g corepack yarn pnpm

# 配置 PNPM 环境变量路径
export PNPM_HOME="$HOME/.local/share/pnpm"
mkdir -p "$PNPM_HOME"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

log_success "02-dev-runtimes.sh 执行完毕。"
