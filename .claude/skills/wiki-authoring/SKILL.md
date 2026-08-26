---
name: wiki-authoring
description: PandaWiki 知识库写作与构建规范：定义 Mermaid 图表选型、MDX React 组件使用场景、Claude Editorial 主题风格与文档结构标准。当为 PandaWiki 撰写、修改、重构或新增技术文档时必须严格遵循本规范。
---

# Wiki Authoring Skill Reference

本 Skill 的完整规范权威定义在 **[`.agent/skills/wiki-authoring/SKILL.md`](../../.agent/skills/wiki-authoring/SKILL.md)**。

---

## 快速指引 (Quick Reference)

当在 Claude Code、Anthravity 或其他智能体环境中操作本知识库时，请直接读取并遵循以下核心源文件：

* 📘 **完整写作规范与决策矩阵**：[`.agent/skills/wiki-authoring/SKILL.md`](../../.agent/skills/wiki-authoring/SKILL.md)
* 🌐 **在线公开规范文档**：[`docs/06-about/wiki-authoring-standards.mdx`](../../docs/06-about/wiki-authoring-standards.mdx)

---

## 核心规则摘要 (TL;DR)

1. **可视化选型**：
   * **技术图表首选 Mermaid**：系统架构、调用时序、生命周期、Git 分支统一使用 ` ```mermaid ` 代码块；
   * **动态交互选用 React (MDX)**：复杂状态组件与交互式计算器放在 `src/components/`，在 `.mdx` 中显式 `import`；
   * **手绘草图选用 SVG**：存入 `static/img/`。
2. **主题设计与排版 (Claude Editorial)**：
   * **色彩**：象牙温润白画布（`#FAF9F5`）+ 陶土砖红点缀（`#D97757`）+ 极细发丝暖边（`#E6E2D8`）；
   * **字体**：大标题古典衬线体（`Newsreader`）+ 正文现代无衬线（`Inter`，行高 `1.78`）+ 代码（`JetBrains Mono`）。
3. **自检要求**：
   * 编写完文档后必须运行 `npm run build` 确保通过，保证零破损链接（Broken Links）。
