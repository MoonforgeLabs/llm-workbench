# ═══════════════════════════════════════════
# LiteLLM Workbench — Shell Helper 函数
# 借鉴 moonforge 任务分类 + llm-workbench 云端能力
# 策略: 简单任务本地优先，复杂任务云端优先
# ═══════════════════════════════════════════

_codex_litellm_args() {
  local catalog="/Users/alex/Documents/myCode/references/knowledge/llm-workbench/codex_litellm_models.json"
  if [[ ! -f "${catalog}" ]]; then
    python3 /Users/alex/Documents/myCode/references/knowledge/llm-workbench/scripts/build-codex-litellm-model-catalog.py >/dev/null || return 1
  fi
  printf '%s\n' \
    '-c' 'model_provider="litellm"' \
    '-c' 'model_providers.litellm.name="LiteLLM"' \
    '-c' 'model_providers.litellm.base_url="http://127.0.0.1:4000/v1"' \
    '-c' 'model_providers.litellm.wire_api="responses"' \
    '-c' 'model_providers.litellm.requires_openai_auth=false' \
    '-c' "model_catalog_json=\"${catalog}\""
}

# ─── 复杂编程: Claude Code + Headroom (上下文压缩) ───
# 用法: claude-hr
claude-hr() {
  headroom install start --profile init-user >/dev/null 2>&1
  ANTHROPIC_BASE_URL="http://127.0.0.1:8787" claude "$@"
}

# ─── 付费强模型: Codex + LiteLLM (默认 GPT-5.5) ───
# 用法: codex-ll
codex-ll() {
  if ! curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
    echo "⚠️  LiteLLM proxy 未运行，先启动: ll-start"
    return 1
  fi
  local args
  args=(${(@f)$(_codex_litellm_args)}) || return 1
  codex "${args[@]}" "$@"
}

# ─── 免费自动: Codex + LiteLLM → 国内免费 → 海外免费 → 本地 Ollama ───
# 用法: codex-free [模型名]  (默认 free-auto)
codex-free() {
  local model="${1:-free-auto}"
  if ! curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
    echo "⚠️  LiteLLM proxy 未运行，先启动: ll-start"
    return 1
  fi
  echo "🆓 免费自动降级: ${model}"
  local args
  args=(${(@f)$(_codex_litellm_args)}) || return 1
  codex "${args[@]}" -m "${model}" "$@"
}

# ─── 强制本地: Codex + Ollama 本地模型 (离线/兜底) ───
# 用法: codex-local [模型名]
codex-local() {
  local model="${1:-devstral}"
  local catalog="/Users/alex/Documents/myCode/references/knowledge/llm-workbench/codex_oss_models.json"
  if ! curl -s --max-time 1 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "⚠️  Ollama 未运行，先启动: ollama serve"
    return 1
  fi
  if [[ ! -f "${catalog}" ]]; then
    python3 /Users/alex/Documents/myCode/references/knowledge/llm-workbench/scripts/build-codex-oss-model-catalog.py >/dev/null || return 1
  fi
  echo "🆓 本地模型: ${model}"
  codex --oss --local-provider ollama -c "model_catalog_json=\"${catalog}\"" -m "${model}" "$@"
}

# ─── 免费云端: Codex + LiteLLM → 国内免费 / OpenRouter :free ───
# 用法: codex-ff [模型名]  (默认 qwen3-coder-free)
# 国内免费: sf-deepseek-r1, sf-qwen2.5-72b,
#           glm-4-flash, glm-4.7-flash
# 海外免费: qwen3-coder-free, nemotron-ultra-free, gpt-oss-120b-free,
#           gemma4-free, llama3.3-70b-free
codex-ff() {
  local model="${1:-qwen3-coder-free}"
  if ! curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
    echo "⚠️  LiteLLM proxy 未运行，先启动: ll-start"
    return 1
  fi
  echo "🆓☁️  免费云端: ${model}"
  local args
  args=(${(@f)$(_codex_litellm_args)}) || return 1
  codex "${args[@]}" -m "${model}" "$@"
}

# 兼容旧习惯: codex-ff 仍可手动指定某个免费云端模型；日常默认用 codex-free。

# ─── 智能模式: Headroom 压缩 + LiteLLM 路由 + 自动降级 ───
# 用法: codex-smart [模型名]  (默认 free-auto)
codex-smart() {
  local model="${1:-free-auto}"
  # 确保 Headroom 运行
  if ! curl -s --max-time 2 http://127.0.0.1:8787/health/liveliness >/dev/null 2>&1; then
    echo "🔄 启动 Headroom 压缩代理..."
    headroom install start --profile init-user >/dev/null 2>&1
    sleep 2
  fi
  # 确保 LiteLLM 运行
  if ! curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
    echo "🔄 启动 LiteLLM 路由..."
    ll-start
    sleep 3
  fi
  echo "🧠 智能模式: Headroom 压缩 + LiteLLM 路由 + ${model}"
  # 通过 Headroom → LiteLLM 链路
  ANTHROPIC_BASE_URL="http://127.0.0.1:8787" \
    codex -m "${model}" "$@"
}

# ─── 粘性会话: 保持同一模型的多轮对话 ───
# 用法: codex-sticky [模型名]
codex-sticky() {
  local model="${1:-free-auto}"
  local session_file="/tmp/.litellm-sticky-$$.model"

  # 保存模型到会话文件
  echo "$model" > "$session_file"

  # 定义清理函数
  cleanup_sticky() {
    rm -f "$session_file" 2>/dev/null
  }
  trap cleanup_sticky EXIT INT TERM

  echo "🔒 粘性会话: ${model} (整个会话保持同一模型)"
  codex-free "$model" "$@"
}

# ─── 任务路由: 借鉴 moonforge task_mapping，按任务自动选择模型 ───
# 用法: codex-auto [--task coding|general|chinese|english|fast]
# 策略: 简单任务本地优先，复杂任务云端优先
codex-auto() {
  local task="general"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task) task="$2"; shift 2 ;;
      *) break ;;
    esac
  done

  if ! curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
    echo "⚠️  LiteLLM proxy 未运行，先启动: ll-start"
    return 1
  fi

  local model="task-${task}"
  echo "🎯 任务路由: ${task} → ${model}"
  local args
  args=(${(@f)$(_codex_litellm_args)}) || return 1
  codex "${args[@]}" -m "${model}" "$@"
}

# ─── 任务快捷命令 ───
codex-coding() {
  codex-auto --task coding "$@"
}

codex-general() {
  codex-auto --task general "$@"
}

codex-chinese() {
  codex-auto --task chinese "$@"
}

codex-english() {
  codex-auto --task english "$@"
}

codex-fast() {
  codex-auto --task fast "$@"
}

# ═══════════════════════════════════════════
# 快捷别名
# ═══════════════════════════════════════════

# LiteLLM
unalias ll-status ll-start ll-stop ll-restart ll-logs ll-models 2>/dev/null

ll-status() {
  curl -s http://127.0.0.1:4000/health/liveliness 2>/dev/null && echo " — LiteLLM 运行中" || echo "LiteLLM 未运行"
}

ll-start() {
  bash /Users/alex/Documents/myCode/references/knowledge/llm-workbench/start-litellm.sh --daemon
}

ll-stop() {
  pkill -f "litellm.*litellm_config.yaml.*--port 4000" 2>/dev/null && echo "已停止" || echo "未运行"
}

ll-restart() {
  ll-stop
  sleep 1
  ll-start
}

ll-logs() {
  tail -50 ~/.litellm.log
}

ll-models() {
  curl -s http://127.0.0.1:4000/v1/models 2>/dev/null \
    | python3 -c 'import sys,json; [print(m["id"]) for m in json.load(sys.stdin).get("data",[])]'
}

ll-dashboard() {
  open /Users/alex/Documents/myCode/references/knowledge/llm-workbench/dashboard.html
}

ll-dashboard-server() {
  local port="${1:-8080}"
  echo "🚀 启动管理看板 HTTP 服务器..."
  echo "📊 访问地址: http://localhost:${port}"
  echo "按 Ctrl+C 停止"
  bash /Users/alex/Documents/myCode/references/knowledge/llm-workbench/start-dashboard.sh "$port"
}

# Headroom
alias hr-status='curl -s http://127.0.0.1:8787/health 2>/dev/null | python3 -m json.tool || echo "Headroom 未运行"'

# Ollama
alias ol-status='ollama list'
alias ol-models='curl -s http://127.0.0.1:11434/api/tags 2>/dev/null | python3 -c "import sys,json; [print(m[\"name\"]) for m in json.load(sys.stdin).get(\"models\",[])]"'
