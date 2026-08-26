import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'PandaWiki',
  tagline: '思考、实践与技术沉淀 · 个人技术知识库',
  favicon: 'img/favicon.ico',

  future: { v4: true },

  url: 'https://Xepanda.github.io',
  baseUrl: '/wiki/',
  organizationName: 'Xepanda',
  projectName: 'wiki',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'zh-Hans',
    locales: ['zh-Hans'],
  },

  headTags: [
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.googleapis.com',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'preconnect',
        href: 'https://fonts.gstatic.com',
        crossorigin: 'anonymous',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'stylesheet',
        href: 'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&family=Newsreader:ital,opsz,wght@0,6..72,400;0,6..72,500;0,6..72,600;1,6..72,400&display=swap',
      },
    },
  ],

  markdown: {
    mermaid: true,
  },
  themes: [
    '@docusaurus/theme-mermaid',
    [
      require.resolve('@easyops-cn/docusaurus-search-local'),
      /** @type {import("@easyops-cn/docusaurus-search-local").PluginOptions} */
      ({
        hashed: true,
        language: ['en', 'zh'],
        highlightSearchTermsOnTargetPage: true,
        explicitSearchResultPath: true,
        docsRouteBasePath: '/',
        indexBlog: false,
      }),
    ],
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'light',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'PandaWiki',
      logo: { alt: 'PandaWiki', src: 'img/logo.svg' },
      items: [
        {
          to: '/intro',
          label: '🏠 导览',
          position: 'left',
        },
        {
          to: '/category/workstation-bootstrap',
          label: '💻 新机装机',
          position: 'left',
        },
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: '📚 全部文档',
        },
        {
          to: '/category/knowledge',
          label: '知识体系',
          position: 'left',
        },
        {
          to: '/category/projects',
          label: '项目实践 ⚡',
          position: 'left',
        },
        {
          to: '/category/resources',
          label: '工具资源',
          position: 'left',
        },
        {
          to: '/about/welcome',
          label: '关于本站',
          position: 'right',
        },
        {
          href: 'https://github.com/Xepanda/wiki',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'light',
      links: [
        {
          title: '核心分区',
          items: [
            { label: '📚 知识体系', to: '/category/knowledge' },
            { label: '🛠️ 项目实践', to: '/category/projects' },
            { label: '🧰 工具资源', to: '/category/resources' },
            { label: '📝 随笔日志', to: '/category/journal' },
          ],
        },
        {
          title: '精选项目',
          items: [
            { label: 'Kindle 墨水屏改造', to: '/category/projects/kindle' },
            { label: '4.2寸多色墨水屏渲染', to: '/category/projects/epaper' },
            { label: '泰山派 All-in-One 智能网关', to: '/category/projects/taishanpi' },
            { label: '双笔记本单屏工作站', to: '/category/projects/dual-laptop-kvm' },
            { label: 'Cloudflare 全栈开发', to: '/category/projects/cloudflare' },
          ],
        },
        {
          title: '关于 & 规范',
          items: [
            { label: '关于 PandaWiki', to: '/about/welcome' },
            { label: '写作与图表规范', to: '/about/wiki-authoring-standards' },
            { label: 'GitHub 仓库', href: 'https://github.com/Xepanda/wiki' },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} PandaWiki · Designed with Claude Editorial Aesthetics · 基于 Docusaurus 构建.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'json', 'typescript', 'powershell', 'yaml', 'markdown'],
    },
    mermaid: {
      theme: { light: 'neutral', dark: 'dark' },
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
