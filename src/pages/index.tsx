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
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className="claude-hero__buttons">
          <Link className="button button--primary button--lg" to="/intro">
            开始阅读
          </Link>
          <Link className="button button--secondary button--lg" to="/category/git">
            Git 指南
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
      title={`${siteConfig.title} - 个人技术知识库`}
      description="PandaWiki 个人技术知识库，记录 Git、WSL、Docker 等开发笔记">
      <HomepageHeader />
      <main>
        <section className="claude-features">
          <div className="container">
            <div className="row">
              <div className="col col--4">
                <Link className="claude-card" to="/category/git">
                  <Heading as="h3">Git</Heading>
                  <p>Git 使用指南、Worktree 等进阶技巧</p>
                </Link>
              </div>
              <div className="col col--4">
                <Link className="claude-card" to="/category/linux">
                  <Heading as="h3">Linux 与 WSL</Heading>
                  <p>WSL 使用技巧与 Linux 日常操作笔记</p>
                </Link>
              </div>
              <div className="col col--4">
                <Link className="claude-card" to="/category/dev-tools">
                  <Heading as="h3">开发工具</Heading>
                  <p>Docker 常用命令等开发工具速查</p>
                </Link>
              </div>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
