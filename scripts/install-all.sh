#!/usr/bin/env bash
# ==============================================================================
# install-all.sh: 全套开发与 AI 环境一键自动化部署入口
# 适用环境: Ubuntu 22.04/24.04 / WSL2
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}        PandaWiki 现代化开发与 AI Agent 运行时一键初始化工具       ${NC}"
echo -e "${CYAN}================================================================${NC}"

# 0. 准备环境变量模板
if [ ! -f "$HOME/.ai_env" ]; then
    echo -e "${BLUE}[INFO]${NC} 正在生成 ~/.ai_env 环境变量模板..."
    cp "$SCRIPT_DIR/env.template" "$HOME/.ai_env"
    chmod 600 "$HOME/.ai_env"
    echo -e "${GREEN}[SUCCESS]${NC} 已创建 ~/.ai_env (权限 600)"
fi

# 1. 基础系统与依赖
echo -e "\n${BLUE}=== [1/5] 执行基础系统与终端配置 (01-base-system.sh) ===${NC}"
bash "$SCRIPT_DIR/01-base-system.sh"

# 2. 多语言开发运行时与编译器
echo -e "\n${BLUE}=== [2/5] 执行语言运行时与编译工具链配置 (02-dev-runtimes.sh) ===${NC}"
bash "$SCRIPT_DIR/02-dev-runtimes.sh"

# 3. AI Agent 工具链与配置
echo -e "\n${BLUE}=== [3/5] 执行 AI Agent 开发者套件配置 (03-ai-agent-ecosystem.sh) ===${NC}"
bash "$SCRIPT_DIR/03-ai-agent-ecosystem.sh"

# 4. 物联网与嵌入式套件
echo -e "\n${BLUE}=== [4/5] 执行嵌入式与物联网工具配置 (04-embedded-iot-tools.sh) ===${NC}"
bash "$SCRIPT_DIR/04-embedded-iot-tools.sh"

# 5. Skills 软链接同步
echo -e "\n${BLUE}=== [5/5] 执行 AI Skills 软链接同步 (05-skills-sync.sh) ===${NC}"
bash "$SCRIPT_DIR/05-skills-sync.sh"

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}                 🎉 全部开发与 AI 环境初始化完成!                 ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "后续操作提示："
echo -e "1. 编辑 ${YELLOW}~/.ai_env${NC} 填入实际的大模型 API Key / Token"
echo -e "2. 刷新环境变量: ${YELLOW}source ~/.zshrc${NC} 或重新登录终端"
echo -e "3. 验证 AI 工具: 运行 ${YELLOW}claude${NC} 或 ${YELLOW}codex${NC}"
echo -e "${GREEN}================================================================${NC}"
