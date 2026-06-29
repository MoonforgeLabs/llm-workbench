#!/usr/bin/env bash
# LiteLLM Workbench — 一键安装脚本
# 用法: ./install.sh [--autostart]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✅ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }
fail() { echo -e "${RED}❌ $*${NC}"; }

echo "═══════════════════════════════════════"
echo "  LiteLLM Workbench 安装"
echo "═══════════════════════════════════════"
echo ""

# ─── 1. 检查依赖 ───
echo "▸ 检查依赖..."

if command -v litellm &>/dev/null; then
  ok "LiteLLM 已安装: $(litellm --version 2>/dev/null || echo 'installed')"
else
  warn "LiteLLM 未安装，正在安装..."
  pip install 'litellm[proxy]' || pipx install 'litellm[proxy]'
  ok "LiteLLM 安装完成"
fi

if command -v headroom &>/dev/null; then
  ok "Headroom 已安装"
else
  warn "Headroom 未安装 (可选，用于 Claude Code 上下文压缩)"
  echo "   安装: pip install headroom-ai"
fi

echo ""

# ─── 2. 配置环境变量 ───
echo "▸ 配置环境变量..."

if [[ -f "${SCRIPT_DIR}/litellm_env.sh" ]]; then
  ok "litellm_env.sh 已存在"
else
  if [[ -f "${SCRIPT_DIR}/litellm_env.sh.example" ]]; then
    cp "${SCRIPT_DIR}/litellm_env.sh.example" "${SCRIPT_DIR}/litellm_env.sh"
    warn "已创建 litellm_env.sh，请编辑填入你的 API key:"
    echo "   vim ${SCRIPT_DIR}/litellm_env.sh"
  else
    fail "找不到 litellm_env.sh.example"
    exit 1
  fi
fi

echo ""

# ─── 3. 安装 Shell Helper ───
echo "▸ 安装 Shell Helper..."

ZSHRC="${HOME}/.zshrc"
SNIPPET="${SCRIPT_DIR}/shell/zshrc_snippets.sh"

if grep -q "LiteLLM Workbench" "$ZSHRC" 2>/dev/null; then
  ok "Shell Helper 已在 ~/.zshrc 中"
else
  echo "" >> "$ZSHRC"
  cat "$SNIPPET" >> "$ZSHRC"
  ok "已添加到 ~/.zshrc (claude-hr / codex-ll / ll-status 等)"
fi

echo ""

# ─── 4. 创建启动脚本的 symlink ───
echo "▸ 配置启动脚本..."

if [[ -L "${HOME}/.start-litellm.sh" ]] || [[ -f "${HOME}/.start-litellm.sh" ]]; then
  rm -f "${HOME}/.start-litellm.sh"
fi
ln -s "${SCRIPT_DIR}/start-litellm.sh" "${HOME}/.start-litellm.sh"
ok "~/.start-litellm.sh → ${SCRIPT_DIR}/start-litellm.sh"

echo ""

# ─── 5. macOS 开机自启 (可选) ───
if [[ "${1:-}" == "--autostart" ]]; then
  echo "▸ 配置 macOS 开机自启..."

  PLIST_SRC="${SCRIPT_DIR}/launchd/ai.litellm.proxy.plist"
  PLIST_DST="${HOME}/Library/LaunchAgents/ai.litellm.proxy.plist"

  # 替换占位符
  sed "s|__REPO_DIR__|${SCRIPT_DIR}|g; s|__HOME__|${HOME}|g" "$PLIST_SRC" > "$PLIST_DST"

  launchctl unload "$PLIST_DST" 2>/dev/null || true
  launchctl load "$PLIST_DST"
  ok "开机自启已配置 (launchd)"
  echo ""
fi

# ─── 6. 完成 ───
echo "═══════════════════════════════════════"
echo "  安装完成！"
echo "═══════════════════════════════════════"
echo ""
echo "下一步:"
echo "  1. 编辑 API key:  vim ${SCRIPT_DIR}/litellm_env.sh"
echo "  2. 启动 LiteLLM:  ~/.start-litellm.sh --daemon"
echo "  3. 测试:          curl -s http://127.0.0.1:4000/health"
echo "  4. 使用:"
echo "     claude-hr      # Claude Code + Headroom 压缩"
echo "     codex-ll       # Codex + LiteLLM 路由"
echo ""
echo "常用命令:"
echo "     ll-status      # LiteLLM 状态"
echo "     ll-start       # 启动 LiteLLM"
echo "     ll-stop        # 停止 LiteLLM"
echo "     ll-logs        # 查看日志"
echo "     hr-status      # Headroom 状态"