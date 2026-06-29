# LiteLLM Workbench

AI Agent 终端省钱工具集。通过 LiteLLM 模型路由 + Headroom 上下文压缩，降低 AI 编程 agent 的使用成本。

## 架构

```
┌─ 任意终端 (Ghostty / iTerm2 / Otty / ...) ──────────────────┐
│                                                               │
│  claude-hr  ──→  Headroom (8787)  ──→  上下文压缩 → Provider │
│  codex-ll   ──→  LiteLLM (4000)   ──→  模型路由   → Provider │
│                                                               │
└───────────────────────────────────────────────────────────────┘

省钱效果:
  Headroom 压缩上下文 → 同模型省 30-50% token
  LiteLLM 路由便宜模型 → 省 80-90% 单价
```

两条链路并行，协议不同，不冲突：
- **Headroom** (Anthropic 格式) → 服务 Claude Code
- **LiteLLM** (OpenAI 格式) → 服务 Codex / OpenCode / 其他

## 快速开始

```bash
# 1. 克隆仓库
git clone <your-repo-url> ~/litellm-workbench
cd ~/litellm-workbench

# 2. 一键安装
chmod +x install.sh
./install.sh              # 基础安装
./install.sh --autostart  # 基础 + macOS 开机自启

# 3. 填入 API key
vim litellm_env.sh

# 4. 启动
~/.start-litellm.sh --daemon

# 5. 使用
claude-hr    # Claude Code + 上下文压缩
codex-ll     # Codex + 便宜模型路由
```

## 文件结构

```
litellm-workbench/
├── README.md                    # 本文档
├── .gitignore                   # 忽略 litellm_env.sh (含 key)
├── litellm_config.yaml          # LiteLLM 模型路由配置
├── litellm_env.sh.example       # API key 模板
├── litellm_env.sh               # 你的实际 API key (不提交)
├── start-litellm.sh             # LiteLLM 启动脚本
├── install.sh                   # 一键安装脚本
├── shell/
│   └── zshrc_snippets.sh        # Shell helper 函数
└── launchd/
    └── ai.litellm.proxy.plist   # macOS 开机自启配置
```

## Shell Helper 函数

安装后 `~/.zshrc` 中可用的命令：

| 命令 | 作用 |
|------|------|
| `claude-hr` | Claude Code 走 Headroom (上下文压缩) |
| `codex-ll` | Codex 走 LiteLLM (模型路由) |
| `ll-status` | 查看 LiteLLM 状态 |
| `ll-start` | 启动 LiteLLM |
| `ll-stop` | 停止 LiteLLM |
| `ll-logs` | 查看 LiteLLM 日志 |
| `hr-status` | 查看 Headroom 状态 |

## 模型路由表

LiteLLM 支持的模型 (`litellm_config.yaml`)：

| 模型名 | Provider | 价格 |
|--------|----------|------|
| `deepseek-chat` | DeepSeek | 💰 便宜 |
| `deepseek-reasoner` | DeepSeek | 💰 便宜 |
| `qwen-max` | 阿里云 | 💰 便宜 |
| `qwen-coder-plus` | 阿里云 | 💰 便宜 |
| `gpt-4o` | OpenAI | 💸 贵 |
| `gpt-4.1-mini` | OpenAI | 💰 中等 |
| `claude-sonnet` | Anthropic | 💸 贵 |
| `claude-haiku` | Anthropic | 💰 中等 |

切换模型：编辑 `~/.codex/config.toml` 的 `model` 字段，或在命令中指定。

## Headroom (可选)

Headroom 是上下文压缩代理，服务 Claude Code：

```bash
# 安装
pip install headroom-ai

# 使用 (通过 claude-hr wrapper)
claude-hr

# 检查状态
hr-status
```

不装 Headroom 也能用，`claude` 命令走默认配置即可。

## 换电脑迁移

```bash
# 1. 克隆仓库
git clone <your-repo-url> ~/litellm-workbench

# 2. 恢复 API key (手动创建或从密码管理器复制)
cp litellm_env.sh.example litellm_env.sh
vim litellm_env.sh

# 3. 运行安装
./install.sh --autostart

# 完成
```

## 故障排除

```bash
# LiteLLM 启动失败
tail -50 ~/.litellm.log
# 手动前台启动看报错:
source litellm_env.sh && litellm --config litellm_config.yaml --port 4000

# 端口被占用
lsof -i :4000
kill $(pgrep -f "litellm.*--port 4000")

# claude-hr 报错 (Headroom 没启动)
headroom install start --profile init-user
# 或直接用 claude 跳过 Headroom

# codex-ll 报错 (LiteLLM 没启动)
~/.start-litellm.sh --daemon

# 卸载开机自启
launchctl unload ~/Library/LaunchAgents/ai.litellm.proxy.plist
rm ~/Library/LaunchAgents/ai.litellm.proxy.plist
```

## 依赖

| 组件 | 必需 | 用途 |
|------|------|------|
| [LiteLLM](https://github.com/BerriAI/litellm) | ✅ | 模型路由代理 |
| [Headroom](https://github.com/chopratejas/headroom) | 可选 | Claude Code 上下文压缩 |
| 任意终端 | ✅ | Ghostty / iTerm2 / Otty / Terminal.app |
| Claude Code | 可选 | AI 编程 agent |
| Codex CLI | 可选 | OpenAI 编程 agent |