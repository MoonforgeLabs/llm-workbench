# ═══════════════════════════════════════════
# LiteLLM Workbench — Shell Helper 函数
# 添加到 ~/.zshrc 末尾
# ═══════════════════════════════════════════

# Claude Code + Headroom (上下文压缩)
# 用法: claude-hr
claude-hr() {
  headroom install start --profile init-user >/dev/null 2>&1
  ANTHROPIC_BASE_URL="http://127.0.0.1:8787" claude "$@"
}

# Codex + LiteLLM (模型路由到便宜 provider)
# 用法: codex-ll
codex-ll() {
  if ! curl -s --max-time 1 http://127.0.0.1:4000/health >/dev/null 2>&1; then
    echo "⚠️  LiteLLM proxy 未运行，先启动: ~/.start-litellm.sh --daemon"
    return 1
  fi
  OPENAI_BASE_URL="http://127.0.0.1:4000/v1" codex "$@"
}

# LiteLLM 快捷操作
# 用法: ll-status / ll-start / ll-stop / ll-logs
alias ll-status='curl -s http://127.0.0.1:4000/health 2>/dev/null | python3 -m json.tool || echo "LiteLLM 未运行"'
alias ll-start='~/.start-litellm.sh --daemon'
alias ll-stop='kill $(pgrep -f "litellm.*--port 4000") 2>/dev/null && echo "已停止" || echo "未运行"'
alias ll-logs='tail -50 ~/.litellm.log'

# Headroom 快捷操作
alias hr-status='curl -s http://127.0.0.1:8787/health 2>/dev/null | python3 -m json.tool || echo "Headroom 未运行"'