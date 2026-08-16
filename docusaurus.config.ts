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
  themes: ['@docusaurus/theme-mermaid'],

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
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: '全部文档',
        },
        {
          to: '/category/projects/kindle',
          label: 'Kindle 改造 ⚡',
          position: 'left',
        },
        {
          to: '/category/git',
          label: 'Git 指南',
          position: 'left',
        },
        {
          to: '/category/linux',
          label: 'Linux & WSL',
          position: 'left',
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
          title: '专题与项目',
          items: [
            { label: 'Kindle 墨水屏改造', to: '/category/projects/kindle' },
            { label: 'Git 工作流与进阶', to: '/category/git' },
            { label: 'Linux 与 WSL 实战', to: '/category/linux' },
            { label: '开发工具速查', to: '/category/dev-tools' },
          ],
        },
        {
          title: '关于 & 链接',
          items: [
            { label: 'GitHub 仓库', href: 'https://github.com/Xepanda/wiki' },
            { label: 'Docusaurus 官方', href: 'https://docusaurus.io/' },
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
