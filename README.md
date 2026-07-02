# LLM Workbench

> **llm-workbench** 是 [LiteLLM](https://github.com/BerriAI/litellm) 的预配置模板，专为中国开发者设计，提供任务分类路由、国内免费源聚合、Shell 工具集等开箱即用功能。

**核心价值**：
- 🎯 **任务分类路由** — coding/chinese/general/english/fast 自动选择最优模型
- 🆓 **国内免费源聚合** — SiliconFlow、智谱开箱即用，无需翻墙
- 🏠 **本地优先策略** — 简单任务本地 Ollama，复杂任务云端付费
- 💰 **省钱工具集** — 免费模型优先 + Token 压缩 (Headroom)
- 🛠️ **Shell 工具** — codex-coding、codex-chinese 等快捷命令

**策略**: 简单任务本地优先，复杂任务云端优先。

## 架构

```
┌─ 任意终端 (Ghostty / iTerm2 / ...) ──────────────────────────────────────────┐
│                                                                                │
│  codex-auto   ──→  LiteLLM      ──→  按任务自动选择模型    借鉴 moonforge     │
│  codex-coding ──→  LiteLLM      ──→  devstral→qwen3-coder→claude  编码        │
│  codex-chinese──→  LiteLLM      ──→  qwen3→sf-qwen2.5→claude    中文         │
│  codex-fast   ──→  LiteLLM      ──→  deepseek-r1-14b→sf→glm     快速         │
│  codex-smart  ──→  Headroom     ──→  LiteLLM      ──→  压缩+路由             │
│  codex-free   ──→  LiteLLM      ──→  海外免费→国内免费→本地    兼容旧命令     │
│  codex-ll     ──→  LiteLLM      ──→  GPT-5.5/Claude/Gemini      付费强模型   │
│                                                                                │
│  策略: 简单任务本地优先，复杂任务云端优先                                      │
└────────────────────────────────────────────────────────────────────────────────┘
```

核心策略 (借鉴 moonforge):

- **任务路由**: `codex-auto --task coding` 按任务自动选择最优模型
- **本地优先**: 简单任务 (coding/general/chinese/english/fast) 本地 Ollama 优先
- **云端兜底**: 本地失败 → 国内免费 → 海外免费 → 付费模型
- **兼容旧命令**: `codex-free`、`codex-ll` 等保持不变

## 快速开始

```bash
# 1. 配置 API Key
cd /path/to/llm-workbench
cp litellm_env.sh.example litellm_env.sh
vim litellm_env.sh   # 填入实际 key

# 2. 一键安装
./install.sh --autostart

# 3. 启动 LiteLLM
~/.start-litellm.sh --daemon

# 配置修改后重载
ll-restart

# 4. 验证
curl -s http://127.0.0.1:4000/health | python3 -m json.tool
```

> LiteLLM 只监听 `127.0.0.1`，启动脚本默认会 `unset LITELLM_MASTER_KEY`，不启用本地代理 auth。这是为了兼容 Codex 0.142.x 的 `/v1/responses` 调用；如果给本地代理开启 master key 但不配置数据库，Codex 会遇到 `No connected db`。如确需开启 auth，先配置 LiteLLM 数据库，再用 `LITELLM_ENABLE_AUTH=1 ll-start`。


## 每日推荐命令

借鉴 moonforge 任务分类，按任务选择模型:

```bash
# 🎯 任务路由 — 按任务自动选择最优模型 (推荐)
codex-auto --task coding    # 编码: devstral → qwen3-coder → claude-sonnet
codex-auto --task chinese   # 中文: qwen3 → sf-qwen2.5-72b → claude-sonnet
codex-auto --task general   # 通用: gemma4 → nemotron → claude-sonnet
codex-auto --task english   # 英文: ornith-35b → nemotron → claude-opus
codex-auto --task fast      # 快速: deepseek-r1-14b → sf-deepseek-r1

# 🎯 快捷命令
codex-coding                # 等同于 codex-auto --task coding
codex-chinese               # 等同于 codex-auto --task chinese
codex-fast                  # 等同于 codex-auto --task fast

# 🆓 免费自动 — 海外免费 → 国内免费 → 本地 (兼容旧命令)
codex-free

# 💸 付费最强 — 复杂任务才用
codex-ll --model claude-opus
```

**日常推荐 `codex-auto --task coding`**，本地 devstral 优先，失败自动降级到云端免费，最后兜底付费。

## 命令速查

### 🎯 任务路由 (借鉴 moonforge)

| 命令 | 场景 | 本地模型 | 云端降级 | 费用 |
|------|------|----------|----------|------|
| `codex-auto --task coding` | 编码 | devstral | qwen3-coder → claude-sonnet | 免费 |
| `codex-auto --task general` | 通用 | gemma4 | nemotron → claude-sonnet | 免费 |
| `codex-auto --task chinese` | 中文 | qwen3 | sf-qwen2.5-72b → claude-sonnet | 免费 |
| `codex-auto --task english` | 英文 | ornith-35b | nemotron → claude-opus | 免费 |
| `codex-auto --task fast` | 快速 | deepseek-r1-14b | sf-deepseek-r1 → glm-4-flash | 免费 |
| `codex-coding` | 编码快捷命令 | devstral | 同上 | 免费 |
| `codex-chinese` | 中文快捷命令 | qwen3 | 同上 | 免费 |
| `codex-fast` | 快速快捷命令 | deepseek-r1-14b | 同上 | 免费 |

### 🧠 其他命令

| 命令 | 场景 | 模型层 | 费用 |
|------|------|--------|------|
| `codex-smart` | 🧠 智能模式 (Headroom 压缩 + LiteLLM 路由) | 自动选择 | 最优 |
| `claude-hr` | 复杂编程、代码重构 | 第一层 (Anthropic + Headroom) | 最高 |
| `codex-ll` | 付费强模型任务 | 第一层 (默认 GPT-5.5) | 中等 |
| `codex-ll --model claude-opus` | 最强推理 | 第一层 (Claude Opus) | 最高 |
| `codex-free` | 免费自动降级 | 海外免费 → 国内免费 → 本地 | 免费 |
| `codex-local` | 强制本地、离线兜底 | 第四层 (Ollama) | 免费 |
| `codex-sticky` | 🔒 粘性会话 (保持同一模型) | 指定模型 | 按模型 |

> `codex-local` 会自动给 Codex 传入 `codex_oss_models.json`，为常用 Ollama 模型补齐 metadata。
> 如果升级 Codex 后再次出现 `Model metadata ... not found`，运行:
> `python3 references/knowledge/llm-workbench/scripts/build-codex-oss-model-catalog.py`。

## 完整模型清单 (33 个)

### 第一层: 付费模型 (7 个)

| 模型名 | 来源 | 说明 |
|--------|------|------|
| `gpt-5.5` | PPIO (CC Switch) | 通过本地 CC Switch 代理 (端口 15721) |
| `claude-sonnet` | OpenRouter | Claude Sonnet 4 |
| `claude-opus` | OpenRouter | Claude Opus 4 |
| `claude-haiku` | OpenRouter | Claude Haiku 4.5 |
| `gemini-flash` | OpenRouter | Gemini 2.0 Flash (OpenRouter 中转，大陆不可直连 Google) |
| `gemini-pro` | OpenRouter | Gemini 2.5 Pro |
| `llama4-maverick` | OpenRouter | Llama 4 Maverick |

### 第二层: 国内免费 (4 个)

**SiliconFlow 硅基流动** (2 个) — 注册: https://cloud.siliconflow.cn
免费模型会轮换，以下为当前可用:

| 模型名 | 底层模型 | 特点 |
|--------|----------|------|
| `sf-deepseek-r1` | DeepSeek-R1-Distill-Qwen-7B | 推理 |
| `sf-qwen2.5-72b` | Qwen2.5-72B-Instruct | 最大最强，推荐 |

**智谱 Zhipu** (2 个) — 注册: https://open.bigmodel.cn

| 模型名 | 特点 |
|--------|------|
| `glm-4-flash` | GLM-4-Flash，永久免费 |
| `glm-4.7-flash` | GLM-4.7-Flash，更新版 |

### 第三层: 海外免费 OpenRouter :free (5 个)

限流: 每模型 20 RPM / 200 RPD。注册: https://openrouter.ai

| 模型名 | 底层模型 | 特点 |
|--------|----------|------|
| `qwen3-coder-free` | Qwen3-Coder | 编码首选 |
| `nemotron-ultra-free` | Nemotron-3-Ultra-550B | 最大参数 |
| `gpt-oss-120b-free` | GPT-OSS-120B | 通用 |
| `gemma4-free` | Gemma-4-31B | Google 系 |
| `llama3.3-70b-free` | Llama-3.3-70B | Meta 系 |

### 第四层: Ollama 本地免费 (20 个已安装)

| 模型名 | 大小 | 强项 |
|--------|------|------|
| `ornith-35b` | 21 GB | **本地最强编码** |
| `deepseek-r1` | 19 GB | 推理/debug |
| `qwen3` | 20 GB | 通用/写作/中文 |
| `qwen3-coder` | 18 GB | 编码 |
| `qwen3.6` | 17 GB | 通用 (最新版) |
| `gemma4` | 17 GB | Google 系 |
| `devstral-large` | 14 GB | Mistral 编码 |
| `devstral` | 15 GB | Mistral 编码 (small-2 版) |
| `qwen3-14b` | 9.3 GB | 中等，可与 30B 同跑 |
| `deepseek-r1-14b` | 9.0 GB | 中等推理 |
| `qwen2.5-14b` | 9.0 GB | 中等通用 |
| `gemma3-12b` | 8.1 GB | 中等 |
| `phi3-14b` | 7.9 GB | 微软，编码好 |
| `ornith-9b` | 5.6 GB | 轻量编码 |
| `llama3.1` | 4.9 GB | 轻量通用 |
| `deepseek-r1-7b` | 4.7 GB | 轻量推理 |
| `qwen2.5-7b` | 4.7 GB | 轻量中文 |

其他已安装 (未在 config 中): `bge-m3` (embedding), `gemma3:1b-it-qat`, `qwen2.5-coder:1.5b-base`

### 内存规划 (48GB RAM)

| 模型规模 | 内存占用 | 并发能力 |
|----------|---------|---------|
| 32B-35B (ornith/qwen3/deepseek-r1) | ~20 GB | 单独跑 |
| 26B-30B (gemma4/qwen3-coder/qwen3.6) | ~17 GB | 单独跑 |
| 14B (qwen3-14b/deepseek-r1-14b/phi3) | ~9 GB | 可与其他模型同跑 |
| 7B-9B (ornith-9b/llama3.1/qwen2.5-7b) | ~5 GB | 随便跑 |

Ollama 默认闲置 5 分钟自动卸载模型，不用手动管理内存。

## Fallback 降级链

LiteLLM 自动按优先级降级，主模型失败时无感切换备用:

```
free-auto: 国内免费 → 海外免费(:free) → 本地 Ollama
付费模型: 付费 → 国内免费 → 海外免费(:free) → 本地 Ollama
```

具体链路示例:
- `free-auto` 失败 → `sf-deepseek-r1` → `glm-4-flash` → `qwen3-coder-free` → `nemotron-ultra-free` → `qwen3-coder` → `ornith-35b`
- `gpt-5.5` 失败 → `claude-sonnet` → `sf-qwen2.5-72b` → `qwen3-coder-free` → `ornith-35b`
- `sf-deepseek-r1` 失败 → `sf-qwen2.5-72b` → `glm-4-flash` → `qwen3-coder-free` → `deepseek-r1`
- `qwen3-coder-free` 失败 → `nemotron-ultra-free` → `gpt-oss-120b-free` → `ornith-35b`

## 场景用法

### 大规模代码重构

```bash
claude-hr                                    # 最强: Claude + Headroom
codex-ll --model claude-sonnet               # 次选: Claude Sonnet
codex-free                                   # 免费自动: 国内→海外→本地
codex-local ornith:35b                       # 离线: 本地最强编码
```

### 文档撰写

```bash
codex-free                                   # 推荐: 免费自动降级
codex-ll --model claude-haiku                # 中文: Claude Haiku (轻量)
codex-ff glm-4-flash                         # 免费: 智谱 GLM-4-Flash
codex-local qwen3                            # 离线: 本地 qwen3:32b
```

### 日常开发

```bash
codex-free                                   # 默认: 免费自动降级
codex-ff sf-deepseek-r1                      # 手动指定免费国内 (SiliconFlow)
codex-ff qwen3-coder-free                    # 手动指定海外免费 (OpenRouter)
codex-local                                  # 强制本地 (Ollama qwen3-coder)
codex-ll                                     # 付费默认 (GPT-5.5)
```

## API Key 注册

| Provider | 注册地址 | 免费额度 | 用途 |
|----------|----------|----------|------|
| **SiliconFlow** | https://cloud.siliconflow.cn | 注册送余额，免费模型会轮换 | 国内免费层 |
| **智谱 Zhipu** | https://open.bigmodel.cn | 注册送 20M tokens (永久) | 国内免费层 |
| **OpenRouter** | https://openrouter.ai | `:free` 模型免费，20 RPM | 海外免费层 + 付费中转 |
| **PPIO** | CC Switch 自带 | - | 付费层 GPT-5.5 |

注册后将 API Key 填入 `litellm_env.sh`:

```bash
export SILICONFLOW_API_KEY="sk-xxx"    # SiliconFlow
export ZHIPU_API_KEY="xxx.xxx.xxx"     # 智谱 (JWT 格式)
export OPENROUTER_API_KEY="sk-or-xxx"  # OpenRouter
```

## 验证命令

```bash
# LiteLLM 状态
ll-status

# 查看 LiteLLM 已注册模型
ll-models

# Ollama 已安装模型
ol-status

# 测试某个模型是否可用 (替换 MODEL_NAME)
curl -s http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"MODEL_NAME","messages":[{"role":"user","content":"hi"}],"max_tokens":20}'

# 快速测试: 国内免费层
curl -s http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"sf-qwen2.5-72b","messages":[{"role":"user","content":"你好"}],"max_tokens":10}'

# 快速测试: 海外免费层
curl -s http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3-coder-free","messages":[{"role":"user","content":"hi"}],"max_tokens":10}'

# 快速测试: 本地 Ollama
curl -s http://127.0.0.1:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3-coder","messages":[{"role":"user","content":"hi"}],"max_tokens":10}'
```

## Ollama 本地模型的其他使用方式

除了通过 `codex-local` 在 Codex 里强制使用 Ollama，还有几种直接用本地模型写代码的方式:

### Codex metadata 提醒

Codex 的 OSS/Ollama 模式不会自动知道每个本地模型的上下文长度、工具能力等 metadata。
本仓库用 `codex_oss_models.json` 补齐 `qwen3-coder:30b`、`ornith:35b`、`deepseek-r1` 等常用本地模型，`codex-local` 会自动加载它。
如果你新增本地模型，先编辑 `scripts/build-codex-oss-model-catalog.py` 的 `MODELS`，再运行脚本重建 catalog。

### 1. aider (推荐，最接近 Claude Code 体验)

```bash
uv tool install aider-chat
aider --model ollama/ornith:35b         # 本地最强编码
aider --model ollama/qwen3-coder
aider --model ollama/deepseek-r1        # 推理/debug
```

aider 能读代码库、改文件、跑命令，交互模式和 Claude Code 最像。

### 2. Continue (VS Code / JetBrains 插件)

VS Code 里安装 Continue 插件，配置 Ollama 作为 provider:

```yaml
# ~/.continue/config.yaml
models:
  - name: ornith:35b
    provider: ollama
    model: ornith:35b
  - name: qwen3-coder
    provider: ollama
    model: qwen3-coder
```

### 3. claude-code-proxy (用 Claude Code UI 跑本地模型)

```bash
git clone https://github.com/1rgs/claude-code-proxy.git
cd claude-code-proxy
cp .env.example .env
# 编辑 .env: BIG_MODEL=ollama/ornith:35b, SMALL_MODEL=ollama/ornith:9b
uv run uvicorn server:app --host 0.0.0.0 --port 8082
# 另一个终端:
ANTHROPIC_BASE_URL=http://localhost:8082 claude
```

注意: 工具调用协议为 Claude 优化，小模型可能不兼容。建议用 ornith:35b。

### 对比

| 工具 | 形态 | 适合场景 | 兼容性 |
|------|------|----------|--------|
| `codex-free` | Shell 函数 | 日常默认，免费自动降级 | Codex + LiteLLM |
| `codex-local` | Shell 函数 | 强制本地，离线兜底 | Codex + Ollama |
| `aider` | CLI | 日常 coding | 原生 Ollama |
| `Continue` | IDE 插件 | IDE 内补全/对话 | 原生 Ollama |
| `claude-code-proxy` | 代理 | 用 Claude Code UI 跑本地模型 | 工具调用可能不稳定 |

## Shell Helper 完整列表

### 🎯 任务路由 (借鉴 moonforge)

| 命令 | 作用 |
|------|------|
| `codex-auto [--task TYPE]` | 🎯 按任务自动选择模型 (coding/general/chinese/english/fast) |
| `codex-coding` | 编码任务: devstral → qwen3-coder → claude-sonnet |
| `codex-general` | 通用任务: gemma4 → nemotron → claude-sonnet |
| `codex-chinese` | 中文任务: qwen3 → sf-qwen2.5-72b → claude-sonnet |
| `codex-english` | 英文任务: ornith-35b → nemotron → claude-opus |
| `codex-fast` | 快速任务: deepseek-r1-14b → sf-deepseek-r1 → glm-4-flash |

### 🧠 其他命令

| 命令 | 作用 |
|------|------|
| `codex-smart [model]` | 🧠 智能模式: Headroom 压缩 + LiteLLM 路由 |
| `codex-sticky [model]` | 🔒 粘性会话: 保持同一模型的多轮对话 |
| `claude-hr` | Claude Code + Headroom 上下文压缩 |
| `codex-free [model]` | 免费自动降级 (兼容旧命令) |
| `codex-ff [model]` | 手动指定免费云端 (国内/海外) |
| `codex-local [model]` | 强制本地 Ollama |
| `codex-ll` | 付费强模型 (默认 GPT-5.5) |
| `ll-status` | LiteLLM 状态 |
| `ll-start` | 启动 LiteLLM |
| `ll-stop` | 停止 LiteLLM |
| `ll-restart` | 重启 LiteLLM 并加载最新配置 |
| `ll-logs` | LiteLLM 日志 |
| `ll-models` | LiteLLM 可用模型列表 |
| `ll-dashboard` | 打开管理界面 |
| `ll-dashboard-server [port]` | 启动管理看板 HTTP 服务器 |
| `./start-dashboard-server.sh [port]` | 启动管理看板后端服务器（支持配置读写） |
| `hr-status` | Headroom 状态 |
| `ol-status` | Ollama 已安装模型 |
| `ol-models` | Ollama 模型 (API 方式) |

## 用量与额度查看

各 Provider 的免费额度和查看方式:

| Provider | 免费额度 | 查看入口 |
|----------|----------|----------|
| **SiliconFlow** | 注册送余额 (会消耗) | https://cloud.siliconflow.cn/account/ak — 登录后看「费用中心」 |
| **智谱 Zhipu** | 注册送 20M tokens (永久) | https://open.bigmodel.cn/usercenter/apikeys — 看 API 调用统计 |
| **OpenRouter** | `:free` 模型 20 RPM / 200 RPD | https://openrouter.ai/activity — 看请求量和限流状态 |
| **Ollama** | 无限制 | 本地运行，不消耗任何云端额度 |

```bash
# 查看 LiteLLM 缓存命中率 (本地缓存减少重复调用)
tail -100 ~/.litellm.log | grep -i cache

# OpenRouter 实时测试 key 是否还有效
curl -s https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $(grep OPENROUTER_API_KEY ~/Documents/myCode/references/knowledge/llm-workbench/litellm_env.sh | cut -d'"' -f2)" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'OpenRouter 可用模型数: {len(d.get(\"data\",[]))}')"

# SiliconFlow 余额 (浏览器打开)
# https://cloud.siliconflow.cn/account/ak

# 智谱 token 用量 (浏览器打开)
# https://open.bigmodel.cn/usercenter/apikeys
```

**省钱技巧**:
- LiteLLM 已开启本地缓存 (5 分钟 TTL)，相同请求不会重复计费
- 优先用 `codex-ff` 走免费通道，失败再降级到本地
- SiliconFlow 免费模型会轮换，如果某天不可用，去官网看最新免费列表然后更新 `litellm_config.yaml`
- OpenRouter `:free` 模型也会轮换，某个模型报错时换一个试试

## 管理界面

管理看板提供可视化监控和配置管理功能。

### 启动管理看板

```bash
# 方式 1: 启动后端服务器（支持配置读写，推荐）
./start-dashboard-server.sh 8080
./start-dashboard-server.sh 8080 --daemon  # 后台模式

# 方式 2: 启动 HTTP 服务器（只读，不支持保存配置）
./start-dashboard.sh 8080

# 方式 3: 快速启动所有服务 + 管理看板
./quick-start.sh --dashboard

# 方式 4: 直接打开（部分功能受限）
ll-dashboard
```

**推荐使用方式 1**：后端服务器支持配置读写，所有功能正常工作。

### 管理界面功能

- 📊 **服务状态**: Headroom、LiteLLM、Ollama 运行状态
- 💰 **Token 节省统计**: 压缩率、已节省 tokens、请求数
- 🤖 **可用模型列表**: 34 个模型按层级分类展示
- 📝 **实时日志**: 最近的请求和压缩日志
- ⚙️ **服务控制**: 重启/停止服务（显示命令行指令）
- 🤖 **模型配置**: 添加新模型（生成配置代码）
- 📝 **配置编辑**: 编辑 litellm_config.yaml（支持读取和保存）
- 🔄 **自动刷新**: 每 30 秒自动更新数据

### 配置编辑器能改什么

配置编辑器可以编辑 `litellm_config.yaml` 中的所有配置：

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `model_list` | 模型列表 | 添加/删除/修改模型 |
| `router_settings` | 路由策略 | fallback 链、重试次数、超时时间 |
| `general_settings` | 通用设置 | 端口、主机、master_key |
| `litellm_settings` | LiteLLM 设置 | 缓存、参数调整 |

**具体可修改内容**：
- 添加新模型（OpenRouter、SiliconFlow、智谱、Ollama 等）
- 修改 fallback 降级链
- 调整重试次数和超时时间
- 启用/禁用缓存
- 修改端口和监听地址

### 命令行修改配置

除了管理界面，还可以通过命令行修改配置：

```bash
# 编辑配置文件
vim litellm_config.yaml

# 使用 yq 命令行工具（需要安装）
# 添加模型
yq -i '.model_list += [{"model_name": "new-model", "litellm_params": {"model": "openai/gpt-4"}}]' litellm_config.yaml

# 修改路由策略
yq -i '.router_settings.num_retries = 5' litellm_config.yaml

# 查看配置
yq '.model_list[].model_name' litellm_config.yaml

# 重启 LiteLLM 使配置生效
ll-restart
```

**配置文件位置**：
```
/Users/alex/Documents/myCode/references/knowledge/llm-workbench/litellm_config.yaml
```

## Headroom Token 压缩集成

通过 `codex-smart` 命令自动启用 Headroom 压缩:

```bash
# 智能模式: Headroom 压缩 + LiteLLM 路由
codex-smart                          # 默认 free-auto
codex-smart sf-qwen2.5-72b          # 指定模型
codex-smart claude-sonnet            # 付费模型

# 查看压缩效果
headroom agent-savings --check-perf --hours 24
```

压缩效果 (根据 Headroom 统计):
- 平均压缩率: 14.3%
- 最佳压缩: 26% (14,411 → 10,665 tokens)
- 已节省: 5M+ tokens

## 粘性会话

使用 `codex-sticky` 保持多轮对话的模型一致性:

```bash
# 粘性会话: 整个会话保持同一模型
codex-sticky                         # 默认 free-auto
codex-sticky sf-qwen2.5-72b         # 指定模型
```

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

## 文件结构

```
llm-workbench/
├── README.md                    # 本文档
├── .gitignore                   # 忽略 litellm_env.sh
├── dashboard.html               # 管理界面 (浏览器打开)
├── litellm_config.yaml          # LiteLLM 模型路由配置 (34 个模型)
├── litellm_env.sh.example       # API key 模板
├── litellm_env.sh               # 你的实际 API key (不提交)
├── start-litellm.sh             # LiteLLM 启动脚本
├── install.sh                   # 一键安装脚本
├── shell/
│   └── zshrc_snippets.sh        # Shell helper 函数
├── scripts/
│   ├── build-codex-litellm-model-catalog.py  # Codex LiteLLM 模型目录
│   └── build-codex-oss-model-catalog.py      # Codex OSS 模型目录
└── launchd/
    └── ai.litellm.proxy.plist   # macOS 开机自启配置
```

## 换电脑迁移

```bash
git clone <repo-url> /path/to/llm-workbench
cd /path/to/llm-workbench
cp litellm_env.sh.example litellm_env.sh
vim litellm_env.sh
./install.sh --autostart
```
