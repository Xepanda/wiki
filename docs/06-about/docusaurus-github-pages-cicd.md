---
slug: /about/docusaurus-github-pages-cicd
title: Docusaurus + GitHub Pages 自动化部署体系
sidebar_position: 2
description: 将 Docusaurus 项目部署到 GitHub Pages，通过 GitHub Actions 实现静态站点自动构建与持续发布。
---

# Docusaurus GitHub Pages 部署

## 概述

将 Docusaurus 项目部署到 GitHub Pages，实现静态站点自动构建与发布。

## 第一步：配置 docusaurus.config.ts

修改以下四个参数：

```
url: 'https://.github.io'
baseUrl: '//'
organizationName: ''
projectName: ''
```

## 第二步：创建 GitHub Actions Workflow

项目根目录下创建 `.github/workflows/deploy.yml`，关键配置：

- 触发条件：push master / workflow_dispatch / schedule cron 0 2 * * *
- 权限：contents:read + pages:write + id-token:write
- concurrency 防并发
- build job：checkout → setup-node → npm ci → npm run build → upload artifact
- deploy job：deploy-pages@v4

## 第三步：初始化 Git 并推送

git init → git add . → git commit → gh repo create --push

## 第四步：启用 GitHub Pages（关键）

必须通过 API 设置 build_type=workflow：

```
gh api repos///pages -X POST -F 'build_type=workflow'
```

否则推送后不会触发部署。

## 第五步：验证

```
curl -sI https://.github.io//
```

```
gh run list -R / --workflow=deploy.yml
```

## 踩坑记录

- build_type=workflow 必须手动启用一次，默认不是 workflow
- gh CLI 需先 auth login
- WSL 下需 git config user.email/name
- token 过期用 gh auth refresh

## 常见问题

| 现象 | 原因 | 解决 |
| --- | --- | --- |
| 推送后不部署 | build_type 未设 workflow | gh api ... -F 'build_type=workflow' |
| 页面 404 | baseUrl 错误 | 检查与仓库名是否匹配 |
| 页面空白 | 构建失败 | 查看 Actions build 日志 |
| workflow 无权限 | pages:write 未开启 | Actions settings 开启读写 |
