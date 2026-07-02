#!/usr/bin/env bash
# 启动 LiteLLM Proxy
# 用法: start-litellm.sh [--daemon]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${SCRIPT_DIR}/litellm_config.yaml"
ENV_FILE="${SCRIPT_DIR}/litellm_env.sh"
PORT=4000
HOST=127.0.0.1
LOG="${HOME}/.litellm.log"

is_running() {
  curl -s --max-time 1 "http://${HOST}:${PORT}/health/liveliness" >/dev/null 2>&1
}

# 加载环境变量
if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
else
  echo "❌ 未找到 litellm_env.sh，先创建:"
  echo "   cp litellm_env.sh.example litellm_env.sh"
  echo "   vim litellm_env.sh  # 填入你的 API key"
  exit 1
fi

# LITELLM_MASTER_KEY 用于 UI 登录（admin / sk-litellm-local）
# 无数据库时 UI 可登录但不支持虚拟 key 管理
:

if [[ "${1:-}" == "--daemon" ]]; then
  if is_running; then
    echo "✅ LiteLLM proxy 已在 ${HOST}:${PORT} 运行"
    echo "如需加载最新配置，先执行: ll-restart"
    exit 0
  fi
  echo "🚀 Starting LiteLLM proxy on ${HOST}:${PORT} (daemon mode)"
  nohup litellm --config "$CONFIG" --host "$HOST" --port "$PORT" > "$LOG" 2>&1 &
  echo "PID: $!"
  echo "Log: ${LOG}"
  echo "URL: http://${HOST}:${PORT}"
  echo ""
  echo "测试: curl -s http://${HOST}:${PORT}/health | python3 -m json.tool"
else
  if is_running; then
    echo "✅ LiteLLM proxy 已在 ${HOST}:${PORT} 运行"
    echo "如需加载最新配置，先执行: ll-restart"
    exit 0
  fi
  echo "🚀 Starting LiteLLM proxy on ${HOST}:${PORT}"
  litellm --config "$CONFIG" --host "$HOST" --port "$PORT"
fi
