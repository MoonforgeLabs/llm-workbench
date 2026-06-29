# LiteLLM Workbench

AI Agent 三层省钱工具集。按任务复杂度选模型，最大化省钱。

## 架构

```
┌─ 任意终端 (Ghostty / iTerm2 / ...) ────────────────────────────┐
│                                                                  │
│  claude-hr   ──→  Headroom  ──→  Mimo/Anthropic  复杂编程/重构  │
│  codex-ll    ──→  LiteLLM   ──→  GPT-5.5/Mimo    日常任务       │
│  codex-free  ──→  Ollama    ──→  本地模型         琐碎任务(免费) │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘

三层策略:
  复杂编程  →  Mimo Pro / Anthropic Claude    最强
  日常任务  →  GPT-5.5 (PPIO) / Mimo          够用，中等
  琐碎任务  →  Ollama 本地                     免费，离线
```

## 实际可用模型 (已验证)

### 第一层: 付费模型

| 模型 | 来源 | 命令 | 状态 |
|------|------|------|------|
| `gpt-5.5` | PPIO (CC Switch) | `codex-ll` 默认 | ✅ 已验证 |
| `mimo` | 小米代理 | `codex-ll --model mimo` | ✅ 已验证 |
| `mimo-pro` | 小米代理 | `codex-ll --model mimo-pro` | ✅ 已验证 |
| `claude-hr` | Headroom → 小米代理 | `claude-hr` | ✅ 已验证 |

### 第二层: Ollama 本地免费

| 模型 | 大小 | 强项 | 命令 |
|------|------|------|------|
| `qwen3-coder` | 18GB | 编码 | `codex-free` (默认) |
| `deepseek-r1` | 19GB | 推理 | `codex-free deepseek-r1` |
| `devstral` | 15GB | 编码 | `codex-free devstral` |
| `qwen3` | 20GB | 通用/写作 | `codex-free qwen3` |
| `qwen3-14b` | 9GB | 中等 | `codex-free qwen3-14b` |
| `llama3.1` | 5GB | 轻量 | `codex-free llama3.1` |
| `qwen2.5-7b` | 4.5GB | 轻量中文 | `codex-free qwen2.5-7b` |

## 命令速查

| 命令 | 场景 | 模型 | 费用 |
|------|------|------|------|
| `claude-hr` | 复杂编程、代码重构 | Mimo/Anthropic + Headroom 压缩 | 💸 |
| `codex-ll` | 日常开发任务 | GPT-5.5 (PPIO) | 💰 |
| `codex-ll --model mimo` | 日常任务 (中文好) | Mimo (小米代理) | 💰 |
| `codex-ll --model mimo-pro` | 复杂任务 (Mimo 最强) | Mimo Pro | 💰 |
| `codex-free` | 琐碎任务、小修改 | Ollama qwen3-coder | 🆓 |
| `codex-free qwen3` | 文档撰写 | Ollama qwen3:32b | 🆓 |
| `codex-free deepseek-r1` | 推理/debug | Ollama deepseek-r1:32b | 🆓 |

## 你的场景用法

### 大规模代码重构

```bash
# 最强: Claude Code + Headroom 上下文压缩
claude-hr

# 次选: Codex + Mimo Pro
codex-ll --model mimo-pro

# 免费: Codex + 本地 qwen3-coder (30B)
codex-free qwen3-coder
```

### 文档撰写

```bash
# 推荐: Codex + GPT-5.5 (写作质量好)
codex-ll

# 中文文档: Codex + Mimo (中文强)
codex-ll --model mimo

# 免费: Codex + 本地 qwen3 (32B, 写作不错)
codex-free qwen3
```

### 日常开发

```bash
# 默认: Codex + GPT-5.5
codex-ll

# 免费: Codex + 本地模型
codex-free
```

## 快速开始

```bash
# 1. 进入目录
cd /path/to/litellm-workbench

# 2. 创建 env
cp litellm_env.sh.example litellm_env.sh
# PPIO key 是占位，CC Switch 自己管，不用改

# 3. 一键安装
./install.sh --autostart

# 4. 启动 LiteLLM
~/.start-litellm.sh --daemon

# 5. 测试
curl -s http://127.0.0.1:4000/health | python3 -m json.tool
```

## 当前进度

- [x] LiteLLM 配置完成
- [x] Shell helper 函数完成 (claude-hr / codex-ll / codex-free)
- [x] Ollama 模型已安装 (7 个可用)
- [x] CC Switch PPIO 已配置 (gpt-5.5)
- [x] 小米代理 Mimo 已验证 (mimo / mimo-pro)
- [ ] 运行 `install.sh` 安装到系统
- [ ] 启动 LiteLLM proxy
- [ ] 填入 API key (如需 DeepSeek/Anthropic 直连)

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

## Shell Helper 函数

| 命令 | 作用 |
|------|------|
| `claude-hr` | Claude Code + Headroom 上下文压缩 |
| `codex-ll` | Codex + LiteLLM (默认 GPT-5.5) |
| `codex-free [model]` | Codex + Ollama 本地免费 |
| `ll-status` | LiteLLM 状态 |
| `ll-start` | 启动 LiteLLM |
| `ll-stop` | 停止 LiteLLM |
| `ll-logs` | LiteLLM 日志 |
| `ll-models` | LiteLLM 可用模型列表 |
| `hr-status` | Headroom 状态 |
| `ol-status` | Ollama 已安装模型 |

## 内存规划 (48GB RAM)

| 模型 | 内存占用 | 并发能力 |
|------|---------|---------|
| qwen3:32b / deepseek-r1:32b | ~20GB | 单独跑没问题 |
| qwen3-coder:30b / devstral | ~18GB | 单独跑没问题 |
| qwen3:14b / deepseek-r1:14b | ~9GB | 可与 30B 同时跑 |
| llama3.1:8b / qwen2.5:7b | ~5GB | 随便跑 |

Ollama 默认闲置 5 分钟自动卸载模型，不用担心内存爆。

## Ollama 本地模型的其他使用方式

除了通过 `codex-free` 在 Codex 里用 Ollama，还有几种直接用本地模型写代码的方式：

### 1. aider（推荐，最接近 Claude Code 体验）

```bash
# 安装
uv tool install aider-chat

# 用 ornith:35b（coding 专精）
aider --model ollama/ornith:35b

# 用 qwen3-coder
aider --model ollama/qwen3-coder

# 用 deepseek-r1（推理/debug）
aider --model ollama/deepseek-r1
```

aider 能读代码库、改文件、跑命令，交互模式和 Claude Code 最像。

### 2. Continue（VS Code / JetBrains 插件）

```bash
# VS Code 里安装 Continue 插件
# 然后在设置里配置 Ollama 作为 provider
```

配置示例（`~/.continue/config.yaml`）：

```yaml
models:
  - name: ornith:35b
    provider: ollama
    model: ornith:35b
  - name: qwen3-coder
    provider: ollama
    model: qwen3-coder
```

适合在 IDE 里直接补全和对话，不需要切终端。

### 3. OpenHands（自动化/多 agent）

```bash
npm install -g @openhands/agent-canvas
agent-canvas
```

Web UI 操作台，可以配置 Ollama 作为后端。适合跑自动化任务（自动分解 issue、定时代码审查等），个人日常开发用不上。

### 4. claude-code-proxy（用 Claude Code 跑本地模型）

项目地址：https://github.com/1rgs/claude-code-proxy

原理：拦截 Claude Code 的 Anthropic API 请求，通过 LiteLLM 翻译成 OpenAI/Ollama 格式，转发给本地模型。

```
Claude Code → Anthropic API → claude-code-proxy → LiteLLM → Ollama 本地模型
```

```bash
# 克隆
git clone https://github.com/1rgs/claude-code-proxy.git
cd claude-code-proxy

# 配置 .env
cp .env.example .env
# 编辑 .env：
#   BIG_MODEL=ollama/ornith:35b
#   SMALL_MODEL=ollama/ornith:9b

# 启动代理
uv run uvicorn server:app --host 0.0.0.0 --port 8082

# 用 Claude Code 连接代理（另一个终端）
ANTHROPIC_BASE_URL=http://localhost:8082 claude
```

**注意：** Claude Code 的工具调用协议是为 Claude 优化的，本地小模型可能理解不了工具调用格式，导致频繁出错。建议先用 `ornith:35b` 试试，9B 模型基本跑不通。

**优势：** 保留 Claude Code 的完整 UI 和工作流，只是后端换成本地模型。
**劣势：** 工具调用兼容性不稳定，取决于模型能力。

### 对比

| 工具 | 形态 | 适合场景 | 安装复杂度 | 兼容性 |
|------|------|----------|-----------|--------|
| `codex-free` | Shell 函数 | 琐碎任务，快速小改 | 已有 | ✅ Codex 格式 |
| `aider` | CLI | 日常 coding，替代 Claude Code | 简单 | ✅ 原生支持 Ollama |
| `Continue` | IDE 插件 | IDE 内补全/对话 | 简单 | ✅ 原生支持 Ollama |
| `claude-code-proxy` | 代理 | 用 Claude Code UI 跑本地模型 | 中等 | ⚠️ 工具调用可能不稳定 |
| `OpenHands` | Web UI | 自动化、多 agent | 较复杂 | ✅ 支持 Ollama |

### 推荐 ornith 模型（coding 专精）

```bash
ollama pull ornith:9b     # 轻量，快速
ollama pull ornith:35b    # 更强，推荐 48GB RAM
```

ornith 是专门为 coding agent 训练的开源模型，同体量下 coding 能力最强。

## 故障排除

```bash
# LiteLLM 启动失败
tail -50 ~/.litellm.log

# Ollama 没运行
ollama serve

# CC Switch 没运行
open /Applications/CC\ Switch.app

# Headroom 没运行
headroom install start --profile init-user

# 端口占用
lsof -i :4000   # LiteLLM
lsof -i :8787   # Headroom
lsof -i :11434  # Ollama
lsof -i :15721  # CC Switch
```

## 换电脑迁移

```bash
git clone <repo-url> /path/to/litellm-workbench
cd /path/to/litellm-workbench
cp litellm_env.sh.example litellm_env.sh
vim litellm_env.sh
./install.sh --autostart
```
