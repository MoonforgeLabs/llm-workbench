#!/usr/bin/env bash
# LiteLLM 启动脚本 - 支持付费模型开关
# 用法:
#   ./start-litellm.sh              # 默认关闭付费模型
#   ./start-litellm.sh --paid       # 启用付费模型
#   LITELLM_ENABLE_PAID_MODELS=true ./start-litellm.sh  # 环境变量方式

set -euo pipefail

# 加载环境变量
source "$(dirname "$0")/litellm_env.sh"

# 解析参数
ENABLE_PAID="${LITELLM_ENABLE_PAID_MODELS:-false}"
for arg in "$@"; do
  case $arg in
    --paid|--enable-paid)
      ENABLE_PAID="true"
      ;;
    --free|--disable-paid)
      ENABLE_PAID="false"
      ;;
  esac
done

CONFIG_FILE="$(dirname "$0")/litellm_config.yaml"
TMP_CONFIG="/tmp/litellm_config_$$.yaml"

# 替换占位符
if [[ "$ENABLE_PAID" == "true" ]]; then
  echo "💰 启用付费模型"
  PAID_CLAUDE_SONNET="claude-sonnet"
  PAID_CLAUDE_OPUS="claude-opus"
  PAID_GPT_5_5="gpt-5.5"
else
  echo "🔒 禁用付费模型 (默认免费模式)"
  PAID_CLAUDE_SONNET=""   # 空字符串会让 LiteLLM 跳过该降级
  PAID_CLAUDE_OPUS=""
  PAID_GPT_5_5=""
fi

# 生成运行时配置
sed -e "s/\${PAID_CLAUDE_SONNET}/${PAID_CLAUDE_SONNET}/g" \
    -e "s/\${PAID_CLAUDE_OPUS}/${PAID_CLAUDE_OPUS}/g" \
    -e "s/\${PAID_GPT_5_5}/${PAID_GPT_5_5}/g" \
    -e "s/\${SILICONFLOW_API_KEY}/${SILICONFLOW_API_KEY}/g" \
    -e "s/\${ZHIPU_API_KEY}/${ZHIPU_API_KEY}/g" \
    -e "s/\${OPENROUTER_API_KEY}/${OPENROUTER_API_KEY}/g" \
    "$CONFIG_FILE" > "$TMP_CONFIG"

# 启动 LiteLLM
echo "🚀 启动 LiteLLM (端口 4000)..."
litellm --config "$TMP_CONFIG"

# 清理
trap 'rm -f "$TMP_CONFIG"' EXIT
