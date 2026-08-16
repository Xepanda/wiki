# 🐼 PandaWiki · 个人技术知识库

> 思考、实践与技术沉淀 · 基于 Docusaurus 与 Anthropic Claude Editorial 设计语言构建。

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Xepanda/wiki)
[![Docusaurus v3](https://img.shields.io/badge/Docusaurus-v3.10-orange.svg)](https://docusaurus.io/)
[![Theme](https://img.shields.io/badge/Theme-Claude%20Editorial-d97757.svg)](https://Xepanda.github.io/wiki/)

---

## 📖 知识库专题导航

* **📟 [Kindle 墨水屏改造与嵌入式开发](docs/projects/kindle/)**：越狱、OTA阻断、Wi-Fi SSH 调优、LIPC/EIPS 底层接口与 6 大开发实战
* **🌿 [Git 版本控制与工作流](docs/git/)**：高效分支模型、Worktree 多分支并行、多账号 SSH 路由隔离
* **🐧 [Linux 与 WSL 实战](docs/linux/)**：WSL2 深度调优、Shell 脚本与极客运维环境
* **🛠️ [开发工具与容器化](docs/dev-tools/)**：Docker 常用命令与容器编排、现代工具链
* **📚 [知识库构建与部署](docs/pandawiki/)**：Docusaurus 主题定制、GitHub Pages 自动化 CI/CD

---

## 🎨 视觉设计与技术规范

本项目采用 **Anthropic Claude Editorial 极简设计系统** 与 **双字族排版体系**：
* **色彩体系**：象牙温润白画布（`#FAF9F5`）、标志性陶土砖红（`#D97757`）与板岩暖墨（`#141413`）；
* **排版系统**：古典衬线大标题（`Newsreader`）+ 现代无衬线正文（`Inter`）+ 极客等宽（`JetBrains Mono`）；
* **可视化引擎**：原生集成 **Mermaid** 矢量图表引擎与 **MDX (React 组件)**。

### 🤖 AI Agent 写作规范（Skills）
知识库包含为 AI 智能体打造的专属 Skill 指南，定义了图表选型、设计准则与结构要求：
* **Skill 路径**：[`.agents/skills/wiki-authoring/SKILL.md`](.agents/skills/wiki-authoring/SKILL.md)
* **在线文档**：[`docs/pandawiki/skills/wiki-authoring-standards.mdx`](docs/pandawiki/skills/wiki-authoring-standards.mdx)

---

## 🛠️ 本地开发与构建

```bash
# 1. 安装依赖
npm install

# 2. 启动本地实时预览服务器
npm start

# 3. 生产环境静态打包构建
npm run build

# 4. 本地预览打包产物
npm run serve
```

---

## 📄 License
MIT © [Xepanda](https://github.com/Xepanda)
