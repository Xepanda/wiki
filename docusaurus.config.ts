import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'PandaWiki',
  tagline: '个人技术知识库',
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
    colorMode: { respectPrefersColorScheme: true },
    navbar: {
      title: 'PandaWiki',
      logo: { alt: 'PandaWiki', src: 'img/logo.svg' },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: '文档',
        },
        {
          href: 'https://github.com/Xepanda/wiki',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: '文档',
          items: [
            { label: 'Git', to: '/category/git' },
            { label: 'Linux 与 WSL', to: '/category/linux' },
            { label: '开发工具', to: '/category/开发工具' },
          ],
        },
        {
          title: '更多',
          items: [
            { label: 'AI 与大模型', to: '/category/ai' },
            { label: '项目', to: '/category/项目' },
            { label: '笔记', to: '/category/笔记' },
          ],
        },
        {
          title: '关于',
          items: [
            { label: 'GitHub', href: 'https://github.com/Xepanda/wiki' },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} PandaWiki. 基于 Docusaurus 构建.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
