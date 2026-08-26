# 🐼 PandaWiki · 个人技术知识库

> 思考、实践与技术沉淀 · 基于 Docusaurus 与 Anthropic Claude Editorial 设计语言构建。

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Xepanda/wiki)
[![Docusaurus v3](https://img.shields.io/badge/Docusaurus-v3.10-orange.svg)](https://docusaurus.io/)
[![Theme](https://img.shields.io/badge/Theme-Claude%20Editorial-d97757.svg)](https://Xepanda.github.io/wiki/)

---

## 📖 知识库架构与导航

本知识库遵循「**顶层分类 + 纵向分层 + 横向领域拆分**」的四层架构，分为 5 大核心分区与 2 大缓冲分区：

* **📚 [知识体系](docs/01-knowledge/)**：操作系统内核与 Linux、Git 版本控制高级工作流、AI 与 Agent 演进地图
* **🛠️ [项目实践](docs/02-projects/)**：
  * 📟 [Kindle 墨水屏改造专栏](docs/02-projects/hardware-embedded/kindle/)：越狱、Wi-Fi SSH、底层控制与 6 大开发方向
  * 🎨 [4.2寸多色墨水屏高品质渲染](docs/02-projects/hardware-embedded/epaper/)：双控制器驱动、抖动渲染算法与 Python 管线
  * 🏠 [泰山派 All-in-One 智能网关](docs/02-projects/hardware-embedded/taishanpi/)：RK3566 硬件评估、OpenWrt 旁路由与 MQTT/HA
  * 🖥️ [双笔记本单屏工作站](docs/02-projects/desktop-workflow/dual-laptop-kvm/)：Deskflow 跨屏键鼠 + DisplaySwitch 信号偷取
  * ☁️ [Cloudflare 开发者全栈实战](docs/02-projects/cloud-and-edge/)：Pages / Workers / Tunnels / R2 边缘服务
  * ⚡ [系统调优与环境实操](docs/02-projects/practical-tutorials/)：生产级 WSL2 环境自动化迁移与 Win11 极限调优
* **🧰 [工具资源](docs/03-resources/)**：Docker 常用命令备忘单、Windows Terminal + Oh My Posh 现代化配置
* **📝 [随笔日志](docs/04-journal/)**：技术思考、架构选型复盘与学习随笔
* **📌 [归档与草稿](docs/05-archive/)**：待写草稿箱与历史旧方案归档隔离区
* **ℹ️ [关于本站](docs/06-about/)**：PandaWiki 介绍、Claude Editorial 设计哲学、写作规范与 GitHub Actions 自动部署

---

## 🎨 视觉设计与技术规范

本项目采用 **Anthropic Claude Editorial 极简设计系统** 与 **双字族排版体系**：
* **色彩体系**：象牙温润白画布（`#FAF9F5`）、标志性陶土砖红（`#D97757`）与板岩暖墨（`#141413`）；
* **排版系统**：古典衬线大标题（`Newsreader`）+ 现代无衬线正文（`Inter`）+ 极客等宽（`JetBrains Mono`）；
* **可视化引擎**：原生集成 **Mermaid** 矢量图表引擎与 **MDX (React 组件)**。

### 🤖 AI Agent 写作规范（Skills）
知识库包含为 AI 智能体打造的专属 Skill 指南，定义了图表选型、设计准则与结构要求：
* **Skill 路径**：[`.agents/skills/wiki-authoring/SKILL.md`](.agents/skills/wiki-authoring/SKILL.md)
* **在线文档**：[`docs/06-about/wiki-authoring-standards.mdx`](docs/06-about/wiki-authoring-standards.mdx)

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
