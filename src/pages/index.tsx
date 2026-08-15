import type {ReactNode} from 'react';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className="claude-hero">
      <div className="container">
        <div className="claude-kicker">
          <span>✦ 思考、实践与技术沉淀 / THOUGHTS & ARTIFACTS</span>
        </div>
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">
          记录日常开发、系统改造、物联网与 AI 实践中沉淀的思考与技术指南。
        </p>
        <div className="claude-hero__buttons">
          <Link className="claude-btn-primary" to="/intro">
            开始阅读文档库 →
          </Link>
          <Link className="claude-btn-secondary" to="/category/projects/kindle">
            ⚡ Kindle 改造专栏
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} - 思考、实践与技术沉淀`}
      description="PandaWiki 个人技术知识库，涵盖嵌入式系统、Kindle 改造、Git 工作流、Linux/WSL 与现代开发工具">
      <HomepageHeader />
      <main>
        {/* Spotlight Featured Project: Kindle 8 极客改造 */}
        <section className="claude-spotlight-section">
          <Link className="claude-spotlight-card" to="/category/projects/kindle">
            <span className="claude-spotlight-tag">⚡ 专题精选 · FEATURED PROJECT</span>
            <div className="claude-spotlight-title">
              Kindle 8 极客墨水屏改造与嵌入式开发全指南
            </div>
            <p className="claude-spotlight-desc">
              从底层越狱、永久阻断 OTA 升级，到开启纯 Wi-Fi 免密 SSH 远程开发环境；深入解析 LIPC 进程总线、EIPS 墨水屏绘制指令与 RTC 硬件定时唤醒超长续航架构，将吃灰设备打造成极客桌面智能中控。
            </p>
            <div className="claude-spotlight-badges">
              <span className="claude-badge">ARMv7 i.MX6</span>
              <span className="claude-badge">Wi-Fi SSH</span>
              <span className="claude-badge">LIPC & EIPS</span>
              <span className="claude-badge">E-Ink 看板</span>
              <span className="claude-badge">Home Assistant</span>
            </div>
          </Link>
        </section>

        {/* Domain Categories Grid */}
        <section className="claude-features">
          <div className="claude-features-header">
            <div className="claude-features-title">知识体系与实践领域</div>
            <div className="claude-features-subtitle">持续构建与迭代的结构化技术沉淀</div>
          </div>

          <div className="claude-grid">
            <Link className="claude-card" to="/category/projects/kindle">
              <span className="claude-card-icon">📟</span>
              <Heading as="h3">Kindle 墨水屏改造</Heading>
              <p>系统越狱、OTA 阻断、Wi-Fi SSH 调优、LIPC 总线与物联网看板实战</p>
              <div className="claude-card-arrow">查阅专栏 →</div>
            </Link>

            <Link className="claude-card" to="/category/git">
              <span className="claude-card-icon">🌿</span>
              <Heading as="h3">Git 版本控制与工作流</Heading>
              <p>Git 使用技巧、Worktree 高效多分支并行开发、多账号 SSH 路由隔离</p>
              <div className="claude-card-arrow">查阅指南 →</div>
            </Link>

            <Link className="claude-card" to="/category/linux">
              <span className="claude-card-icon">🐧</span>
              <Heading as="h3">Linux 与 WSL 实战</Heading>
              <p>WSL2 高级调优、终端效率工具、Shell 脚本自动化与服务器运维环境</p>
              <div className="claude-card-arrow">查阅笔记 →</div>
            </Link>

            <Link className="claude-card" to="/category/dev-tools">
              <span className="claude-card-icon">🛠️</span>
              <Heading as="h3">开发工具与容器化</Heading>
              <p>Docker 常用命令与容器编排、Neovim/VS Code 效率配置、现代开发工具链</p>
              <div className="claude-card-arrow">查阅速查 →</div>
            </Link>

            <Link className="claude-card" to="/category/pandawiki">
              <span className="claude-card-icon">📚</span>
              <Heading as="h3">知识库构建与部署</Heading>
              <p>Docusaurus 深度定制、GitHub Pages 自动化 CI/CD 部署与写作指南</p>
              <div className="claude-card-arrow">查阅沉淀 →</div>
            </Link>

            <Link className="claude-card" to="/intro">
              <span className="claude-card-icon">💡</span>
              <Heading as="h3">思考与随笔</Heading>
              <p>技术视野探索、软硬件交互思考、系统设计哲学与日常备忘</p>
              <div className="claude-card-arrow">查阅全部 →</div>
            </Link>
          </div>
        </section>
      </main>
    </Layout>
  );
}
