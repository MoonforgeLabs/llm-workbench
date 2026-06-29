# ═══════════════════════════════════════════
# LiteLLM Workbench — Shell Helper 函数
# 三层策略: 复杂→Anthropic, 日常→GPT-5.5, 琐碎→Ollama免费
# ═══════════════════════════════════════════

# ─── 复杂编程: Claude Code + Headroom (上下文压缩) ───
# 用法: claude-hr
claude-hr() {
  headroom install start --profile init-user >/dev/null 2>&1
  ANTHROPIC_BASE_URL="http://127.0.0.1:8787" claude "$@"
}

# ─── 日常任务: Codex + LiteLLM (默认 GPT-5.5) ───
# 用法: codex-ll
codex-ll() {
  if ! curl -s --max-time 1 http://127.0.0.1:4000/health -H "Authorization: Bearer sk-litellm-local" >/dev/null 2>&1; then
    echo "⚠️  LiteLLM proxy 未运行，先启动: ll-start"
    return 1
  fi
  codex -c 'model_providers.custom.base_url="http://127.0.0.1:4000/v1"' "$@"
}

# ─── 琐碎任务: Codex + Ollama 本地模型 (免费) ───
# 用法: codex-free [模型名]
codex-free() {
  local model="${1:-qwen3-coder}"
  if ! curl -s --max-time 1 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "⚠️  Ollama 未运行，先启动: ollama serve"
    return 1
  fi
  echo "🆓 本地模型: ${model}"
  codex --oss --local-provider ollama -c "model=\"${model}\"" "$@"
}

# ═══════════════════════════════════════════
# 快捷别名
# ═══════════════════════════════════════════

# LiteLLM
alias ll-status='curl -s http://127.0.0.1:4000/health -H "Authorization: Bearer sk-litellm-local" 2>/dev/null | python3 -m json.tool || echo "LiteLLM 未运行"'
alias ll-start='bash /Users/alex/Documents/myCode/references/knowledge/litellm-workbench/start-litellm.sh --daemon'
alias ll-stop='kill $(pgrep -f "litellm.*--port 4000") 2>/dev/null && echo "已停止" || echo "未运行"'
alias ll-logs='tail -50 ~/.litellm.log'
alias ll-models='curl -s http://127.0.0.1:4000/v1/models -H "Authorization: Bearer sk-litellm-local" 2>/dev/null | python3 -c "import sys,json; [print(m[\"id\"]) for m in json.load(sys.stdin).get(\"data\",[])]"'

# Headroom
alias hr-status='curl -s http://127.0.0.1:8787/health 2>/dev/null | python3 -m json.tool || echo "Headroom 未运行"'

# Ollama
alias ol-status='ollama list'
alias ol-models='curl -s http://127.0.0.1:11434/api/tags 2>/dev/null | python3 -c "import sys,json; [print(m[\"name\"]) for m in json.load(sys.stdin).get(\"models\",[])]"'
