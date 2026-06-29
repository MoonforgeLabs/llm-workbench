# LiteLLM Workbench

AI Agent 三层省钱工具集。按任务复杂度选模型，最大化省钱。

## 架构

```
┌─ 任意终端 (Ghostty / iTerm2 / ...) ────────────────────────────┐
│                                                                  │
│  claude-hr   ──→  Headroom  ──→  Anthropic    复杂编程/重构     │
│  codex-ll    ──→  LiteLLM   ──→  GPT-5.5      日常任务          │
│  codex-free  ──→  Ollama    ──→  本地模型      琐碎任务 (免费)   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘

三层策略:
  复杂编程  →  Anthropic (Claude)     最强，最贵
  日常任务  →  GPT-5.5 (PPIO)         够用，中等
  琐碎任务  →  Ollama 本地             免费，离线
```

## 快速开始

```bash
# 1. 进入目录
cd /path/to/litellm-workbench

# 2. 创建 env (PPIO key 是占位，CC Switch 自己管)
cp litellm_env.sh.example litellm_env.sh
# 如果要用 Anthropic/DeepSeek，编辑填入 key

# 3. 一键安装
./install.sh --autostart

# 4. 启动 LiteLLM
~/.start-litellm.sh --daemon

# 5. 使用
claude-hr      # 复杂编程 → Anthropic + Headroom 压缩
codex-ll       # 日常任务 → GPT-5.5 (PPIO)
codex-free     # 琐碎任务 → Ollama 本地免费
```

## 命令速查

| 命令 | 场景 | 模型 | 费用 |
|------|------|------|------|
| `claude-hr` | 复杂编程、代码重构 | Anthropic Claude | 💸 贵 |
| `codex-ll` | 日常开发任务 | GPT-5.5 (PPIO) | 💰 中等 |
| `codex-free` | 琐碎任务、小修改 | Ollama 本地 | 🆓 免费 |
| `codex-free qwen3` | 指定本地模型 | Ollama qwen3:32b | 🆓 免费 |
| `codex-pro` | Codex + Anthropic | Claude Sonnet | 💸 贵 |

## Shell Helper 函数

安装后 `~/.zshrc` 中可用：

| 命令 | 作用 |
|------|------|
| `claude-hr` | Claude Code + Headroom 上下文压缩 |
| `codex-ll` | Codex + LiteLLM (GPT-5.5) |
| `codex-free [model]` | Codex + Ollama 本地免费 |
| `codex-pro` | Codex + Anthropic (需 key) |
| `ll-status` | LiteLLM 状态 |
| `ll-start` | 启动 LiteLLM |
| `ll-stop` | 停止 LiteLLM |
| `ll-logs` | LiteLLM 日志 |
| `ll-models` | LiteLLM 可用模型列表 |
| `hr-status` | Headroom 状态 |
| `ol-status` | Ollama 已安装模型 |
| `ol-models` | Ollama 模型列表 |

## 文件结构

```
litellm-workbench/
├── README.md                    # 本文档
├── .gitignore                   # 忽略 litellm_env.sh
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

## 模型路由表

LiteLLM 配置的模型 (`litellm_config.yaml`)：

| 模型名 | 来源 | 用途 | 费用 |
|--------|------|------|------|
| `gpt-5.5` | PPIO (CC Switch) | 日常任务 | 💰 |
| `gpt-4o` | PPIO (CC Switch) | 备选 | 💰 |
| `qwen3-coder` | Ollama 本地 | 编码 (30B) | 🆓 |
| `deepseek-r1` | Ollama 本地 | 推理 (32B) | 🆓 |
| `devstral` | Ollama 本地 | 编码 (15B) | 🆓 |
| `qwen3` | Ollama 本地 | 通用 (32B) | 🆓 |
| `llama3.1` | Ollama 本地 | 轻量 (8B) | 🆓 |
| `ds-chat` | DeepSeek API | 备选便宜 | 💰 |
| `claude-sonnet` | Anthropic | 复杂编程 | 💸 |
| `claude-haiku` | Anthropic | 轻量 Claude | 💰 |

## Ollama 本地模型

已安装的 Ollama 模型：

| 模型 | 大小 | 适合 |
|------|------|------|
| `qwen3-coder:30b` | 18GB | 编码任务 |
| `deepseek-r1:32b` | 19GB | 推理任务 |
| `qwen3:32b` | 20GB | 通用任务 |
| `devstral-small-2` | 15GB | 编码任务 |
| `qwen3:14b` | 9GB | 中等任务 |
| `deepseek-r1:14b` | 8.5GB | 中等推理 |
| `llama3.1:8b` | 5GB | 轻量任务 |
| `qwen2.5:7b` | 4.5GB | 轻量任务 |
| `gemma3:1b` | 1GB | 超轻量 |

## 换电脑迁移

```bash
# 1. 克隆仓库
git clone <repo-url> /path/to/litellm-workbench
cd /path/to/litellm-workbench

# 2. 恢复 API key
cp litellm_env.sh.example litellm_env.sh
vim litellm_env.sh

# 3. 一键安装
./install.sh --autostart

# 4. 确保 Ollama 已安装并有模型
ollama list
```

## 故障排除

```bash
# LiteLLM 启动失败
tail -50 ~/.litellm.log

# Ollama 没运行
ollama serve

# CC Switch 没运行 (PPIO 不可用)
open /Applications/CC\ Switch.app

# Headroom 没运行
headroom install start --profile init-user

# 端口冲突
lsof -i :4000   # LiteLLM
lsof -i :8787   # Headroom
lsof -i :11434  # Ollama
lsof -i :15721  # CC Switch
```

## 依赖

| 组件 | 必需 | 用途 |
|------|------|------|
| [LiteLLM](https://github.com/BerriAI/litellm) | ✅ | 模型路由代理 |
| [Ollama](https://ollama.com) | ✅ | 本地免费模型 |
| [CC Switch](https://ccswitch.app) | ✅ | PPIO 代理 (GPT-5.5) |
| [Headroom](https://github.com/chopratejas/headroom) | 可选 | Claude Code 上下文压缩 |
| 任意终端 | ✅ | Ghostty / iTerm2 / ... |
