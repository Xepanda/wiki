#!/usr/bin/env bash
# ==============================================================================
# 03-ai-agent-ecosystem.sh: AI Agent 开发者工具链与配置
# 包括: Claude Code, OpenAI Codex CLI, MCP 服务, 自定义 Provider, Plugins, Hooks
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

log_info ">>> 1. 安装 AI CLI 全局开发工具..."
npm install -g \
    @anthropic-ai/claude-code \
    @openai/codex \
    @pencil.dev/cli \
    opencode-ai \
    wscat \
    || true

# 2. 安装 Cloudflared (Tunnel 客户端)
if ! command -v cloudflared &>/dev/null; then
    log_info "正在下载并安装 Cloudflared..."
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /tmp/cloudflared
    sudo install -m 755 /tmp/cloudflared /usr/local/bin/cloudflared
    rm -f /tmp/cloudflared
fi

# 3. 初始化配置目录
mkdir -p "$HOME/.claude/skills"
mkdir -p "$HOME/.codex/skills"

# 4. 创建轻量级极速状态栏脚本 (~/.claude/statusline-command.sh)
cat << 'EOF' > "$HOME/.claude/statusline-command.sh"
#!/usr/bin/env bash
# Claude Code statusLine command (PS1 + Model + Context usage)
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

if [ -n "$session_part" ]; then
    printf '%s  |  %s' "$ps1_part" "$session_part"
else
    printf '%s' "$ps1_part"
fi
EOF
chmod +x "$HOME/.claude/statusline-command.sh"

# 5. 配置 Claude Code (~/.claude/settings.json)
log_info ">>> 2. 写入 Claude Code 核心配置 (~/.claude/settings.json)..."
cat << 'EOF' > "$HOME/.claude/settings.json"
{
  "env": {
    "ENABLE_TOOL_SEARCH": "true"
  },
  "permissions": {
    "allow": [
      "Bash(rtk *)",
      "Bash(git *)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(find *)",
      "Bash(wc *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(diff *)",
      "Bash(pwd)",
      "Bash(echo *)",
      "Bash(jq *)",
      "Bash(which *)",
      "mcp__pencil"
    ],
    "defaultMode": "auto"
  },
  "model": "sonnet",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Skill",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.ferry/bin/ferry event skill-read --stdin --platform claude-code",
            "timeout": 10,
            "async": true
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "rtk hook claude"
          }
        ]
      }
    ]
  },
  "worktree": {
    "baseRef": "fresh"
  },
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  },
  "enabledPlugins": {
    "clangd-lsp@claude-plugins-official": true,
    "claude-hud@claude-hud": true,
    "code-simplifier@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "ui-ux-pro-max@ui-ux-pro-max-skill": true
  },
  "extraKnownMarketplaces": {
    "claude-hud": {
      "source": {
        "source": "github",
        "repo": "jarrodwatts/claude-hud"
      }
    },
    "ui-ux-pro-max-skill": {
      "source": {
        "source": "github",
        "repo": "nextlevelbuilder/ui-ux-pro-max-skill"
      }
    }
  },
  "effortLevel": "high",
  "skipWorkflowUsageWarning": true,
  "theme": "dark-daltonized",
  "skipAutoPermissionPrompt": true,
  "autoMode": {
    "soft_deny": [
      "$defaults",
      "Bash(rtk:reset*)",
      "Bash(tyx:publish*)"
    ]
  }
}
EOF

# 5. 配置 Claude Code MCP 服务器 (~/.claude.json)
log_info ">>> 3. 配置 MCP 外部联网与增强服务 (~/.claude.json)..."
python3 - << 'PYEOF'
import json, os

claude_json_path = os.path.expanduser('~/.claude.json')
data = {}
if os.path.exists(claude_json_path):
    try:
        with open(claude_json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception:
        data = {}

zhipu_key = os.environ.get('ZHIPU_API_KEY', '${ZHIPU_API_KEY}')
zai_key = os.environ.get('Z_AI_API_KEY', '${Z_AI_API_KEY}')

mcp_servers = data.get('mcpServers', {})
mcp_servers.update({
    "web-reader": {
        "type": "http",
        "url": "https://open.bigmodel.cn/api/mcp/web_reader/mcp",
        "headers": {
            "Authorization": f"Bearer {zhipu_key}" if not zhipu_key.startswith("${") else "Bearer ${ZHIPU_API_KEY}"
        }
    },
    "web-search-prime": {
        "type": "http",
        "url": "https://open.bigmodel.cn/api/mcp/web_search_prime/mcp",
        "headers": {
            "Authorization": f"Bearer {zhipu_key}" if not zhipu_key.startswith("${") else "Bearer ${ZHIPU_API_KEY}"
        }
    },
    "zread": {
        "type": "http",
        "url": "https://open.bigmodel.cn/api/mcp/zread/mcp",
        "headers": {
            "Authorization": f"Bearer {zhipu_key}" if not zhipu_key.startswith("${") else "Bearer ${ZHIPU_API_KEY}"
        }
    },
    "zai-mcp-server": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@z_ai/mcp-server"],
        "env": {
            "Z_AI_API_KEY": zai_key
        }
    }
})

data['mcpServers'] = mcp_servers

with open(claude_json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("  -> MCP 服务器已成功同步至 ~/.claude.json")
PYEOF

# 6. 配置 Codex CLI (~/.codex/config.toml & hooks.json)
log_info ">>> 4. 写入 Codex CLI 核心配置 (~/.codex/config.toml)..."
cat << 'EOF' > "$HOME/.codex/config.toml"
model_provider = "custom"
model = "LongCat-2.0"
disable_response_storage = true
model_reasoning_effort = "medium"
personality = "pragmatic"
model_catalog_json = "cc-switch-model-catalog.json"
web_search = "disabled"
approvals_reviewer = "user"

[model_providers.custom]
name = "longcat"
base_url = "https://api.longcat.chat/openai/v1"
wire_api = "responses"
requires_openai_auth = true

[features]
codex_hooks = true
EOF

cat << 'EOF' > "$HOME/.codex/hooks.json"
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.ferry/bin/ferry event skill-read --stdin --platform codex",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
EOF

log_success "03-ai-agent-ecosystem.sh 执行完毕。"
