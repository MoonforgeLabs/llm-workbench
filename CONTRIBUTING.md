# Contributing to llm-workbench

感谢你对本项目的关注！以下是参与贡献的指南。

## 开发环境

```bash
# 克隆项目
git clone https://github.com/MoonforgeLabs/llm-workbench.git
cd llm-workbench

# 安装依赖
./install.sh

# 配置环境变量
cp litellm_env.sh.example litellm_env.sh
# 编辑 litellm_env.sh，填入你的 API Key
```

## 提交规范

- 使用清晰的 commit message，说明改动的目的
- 一个 commit 做一件事，避免混合不相关的改动
- **禁止在 commit message 中添加任何 AI agent 的 Co-Authored-By 标记**

## Pull Request 流程

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交改动并推送
4. 创建 Pull Request，说明改动内容和原因

## 报告问题

- 使用 GitHub Issues 报告 bug
- 请提供复现步骤、期望行为和实际行为
- 包含相关的日志或错误信息

## 安全问题

如发现安全漏洞，请**不要**通过公开 Issue 报告。请通过 GitHub 的 Security Advisories 功能私下报告。

## 许可证

本项目采用 [MIT License](LICENSE)。提交贡献即表示你同意你的代码以相同许可证发布。
