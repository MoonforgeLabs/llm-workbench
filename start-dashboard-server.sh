#!/usr/bin/env bash
# 启动管理看板后端服务器（支持配置读写）
# 用法: ./start-dashboard-server.sh [端口] [--daemon]

set -euo pipefail

PORT="${1:-8080}"
DAEMON_MODE="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
URL="http://localhost:${PORT}/dashboard.html"
PID_FILE="${SCRIPT_DIR}/logs/dashboard-server-${PORT}.pid"
LOG_FILE="${SCRIPT_DIR}/logs/dashboard-server-${PORT}.log"

# 创建日志目录
mkdir -p "${SCRIPT_DIR}/logs"

# 检查是否已在运行
is_running() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

# 停止服务器
stop_server() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null
      rm -f "$PID_FILE"
      echo "✅ 服务器已停止"
    else
      rm -f "$PID_FILE"
    fi
  fi
}

# 如果已经在运行，先停止
if is_running; then
  echo "⚠️  服务器已在运行，先停止..."
  stop_server
  sleep 1
fi

echo "🚀 启动 LiteLLM Workbench 管理看板服务器"
echo "========================================"
echo ""
echo "📊 管理看板地址: ${URL}"
echo "📝 日志文件: ${LOG_FILE}"
echo ""

if [[ "$DAEMON_MODE" == "--daemon" ]]; then
  # 后台模式
  echo "🔄 后台模式启动中..."
  echo ""

  # 后台启动
  cd "$SCRIPT_DIR"
  nohup python3 dashboard-server.py > "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"

  # 等待服务器启动
  sleep 2

  if is_running; then
    echo "✅ 服务器已启动 (PID: $(cat "$PID_FILE"))"
    echo ""
    echo "正在打开浏览器..."
    open "$URL"
    echo ""
    echo "📋 管理命令:"
    echo "   停止: kill $(cat "$PID_FILE")"
    echo "   日志: tail -f $LOG_FILE"
    echo "   状态: curl -s http://localhost:${PORT}/dashboard.html > /dev/null && echo '运行中' || echo '未运行'"
  else
    echo "❌ 服务器启动失败，查看日志: cat $LOG_FILE"
    exit 1
  fi
else
  # 前台模式
  echo "正在打开浏览器..."
  echo "按 Ctrl+C 停止服务器"
  echo ""

  # 打开浏览器
  open "$URL"

  # 启动 Python 后端服务器
  cd "$SCRIPT_DIR"
  python3 dashboard-server.py
fi
