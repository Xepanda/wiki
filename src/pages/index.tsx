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
            <Link className="claude-card" to="/category/knowledge">
              <span className="claude-card-icon">📚</span>
              <Heading as="h3">核心知识体系</Heading>
              <p>Linux 系统底层、Git 分支与 Worktree 工作流、AI 与 Agent 生态演进地图</p>
              <div className="claude-card-arrow">查阅知识库 →</div>
            </Link>

            <Link className="claude-card" to="/category/projects/hardware-embedded">
              <span className="claude-card-icon">📟</span>
              <Heading as="h3">硬件与嵌入式改造</Heading>
              <p>Kindle 墨水屏看板、4.2寸多色屏抖动渲染算法、泰山派 All-in-One 智能网关</p>
              <div className="claude-card-arrow">查阅硬件专题 →</div>
            </Link>

            <Link className="claude-card" to="/category/projects/desktop-workflow">
              <span className="claude-card-icon">🖥️</span>
              <Heading as="h3">极客桌面工作流</Heading>
              <p>双笔记本单屏 KVM 方案、Deskflow 跨屏键鼠、DisplaySwitch 信号偷取切屏</p>
              <div className="claude-card-arrow">查阅工作流 →</div>
            </Link>

            <Link className="claude-card" to="/category/projects/cloudflare">
              <span className="claude-card-icon">☁️</span>
              <Heading as="h3">云原生与边缘服务</Heading>
              <p>Cloudflare Pages 静态托管、Workers 边缘函数、Tunnels 零公网穿透与 R2 存储</p>
              <div className="claude-card-arrow">查阅实战 →</div>
            </Link>

            <Link className="claude-card" to="/category/resources">
              <span className="claude-card-icon">🧰</span>
              <Heading as="h3">工具资源与速查</Heading>
              <p>Docker 常用命令备忘单、Windows Terminal + Oh My Posh 终端美化与高效配置</p>
              <div className="claude-card-arrow">查阅速查 →</div>
            </Link>

            <Link className="claude-card" to="/about/welcome">
              <span className="claude-card-icon">ℹ️</span>
              <Heading as="h3">关于本站与设计规范</Heading>
              <p>PandaWiki 建设初衷、Claude Editorial 设计哲学、Mermaid 图表规范与 CI/CD</p>
              <div className="claude-card-arrow">了解本站 →</div>
            </Link>
          </div>
        </section>
      </main>
    </Layout>
  );
}
