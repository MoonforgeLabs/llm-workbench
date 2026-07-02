#!/usr/bin/env bash
# LiteLLM Workbench 快速启动脚本
# 用法: ./quick-start.sh [--dashboard]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🧠 LiteLLM Workbench 快速启动"
echo "================================"

# 检查并启动 Headroom
echo "1. 检查 Headroom..."
if curl -s --max-time 2 http://127.0.0.1:8787/health/liveliness >/dev/null 2>&1; then
  echo "   ✅ Headroom 运行中"
else
  echo "   🔄 启动 Headroom..."
  headroom install start --profile init-user >/dev/null 2>&1
  sleep 2
  if curl -s --max-time 2 http://127.0.0.1:8787/health/liveliness >/dev/null 2>&1; then
    echo "   ✅ Headroom 启动成功"
  else
    echo "   ⚠️  Headroom 启动失败，继续..."
  fi
fi

# 检查并启动 LiteLLM
echo "2. 检查 LiteLLM..."
if curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
  echo "   ✅ LiteLLM 运行中"
else
  echo "   🔄 启动 LiteLLM..."
  bash "${SCRIPT_DIR}/start-litellm.sh" --daemon
  sleep 3
  if curl -s --max-time 2 http://127.0.0.1:4000/health/liveliness >/dev/null 2>&1; then
    echo "   ✅ LiteLLM 启动成功"
  else
    echo "   ❌ LiteLLM 启动失败"
    exit 1
  fi
fi

# 检查 Ollama
echo "3. 检查 Ollama..."
if curl -s --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "   ✅ Ollama 运行中"
else
  echo "   ⚠️  Ollama 未运行 (本地模型不可用)"
fi

# 显示统计
echo ""
echo "📊 服务状态:"
echo "   - Headroom: $(curl -s http://127.0.0.1:8787/stats 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'压缩率 {d[\"summary\"][\"compression\"][\"avg_compression_pct\"]:.1f}%')" 2>/dev/null || echo '未知')"
echo "   - LiteLLM: $(curl -s http://127.0.0.1:4000/v1/models 2>/dev/null | python3 -c "import sys,json; print(f'{len(json.load(sys.stdin).get(\"data\",[]))} 个模型')" 2>/dev/null || echo '未知')"
echo "   - Ollama: $(curl -s http://127.0.0.1:11434/api/tags 2>/dev/null | python3 -c "import sys,json; print(f'{len(json.load(sys.stdin).get(\"models\",[]))} 个模型')" 2>/dev/null || echo '未运行')"

echo ""
echo "🚀 可用命令:"
echo "   codex-smart          # 智能模式 (Headroom 压缩 + LiteLLM 路由)"
echo "   codex-free           # 免费自动降级"
echo "   codex-sticky         # 粘性会话"
echo "   ll-dashboard         # 打开管理界面"
echo ""

# 如果指定了 --dashboard 参数，打开管理界面
if [[ "${1:-}" == "--dashboard" ]]; then
  echo "📊 打开管理界面..."
  open "${SCRIPT_DIR}/dashboard.html"
fi
