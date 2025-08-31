# GitHub Radar CLI

GitHub Open Source Radar 的命令行工具和数据收集服务，用于发现趋势项目、快速增长项目和新发布的仓库。

## 功能特性

- **趋势发现**: 发现指定语言和时间窗口内的趋势项目
- **快速增长监测**: 找出增长最快的项目（按星标增长速度）
- **新项目追踪**: 监控新发布的有潜力的项目
- **AI 分析**: 使用 AI 深度分析项目并生成报告
- **数据存储**: 支持 Supabase 数据库存储分析结果
- **微信发布**: 自动发布分析报告到微信公众号草稿

## 安装和配置

### 1. 安装依赖
```bash
cd cli
npm install
```

### 2. 环境配置
复制 `.env.example` 到 `.env` 并配置所需的环境变量：

```bash
cp .env.example .env
# 编辑 .env 文件，填入相应的配置
```

### 3. 数据库设置
如果使用 Supabase 存储，需要在 Supabase SQL Editor 中运行 `../shared/database/schema.sql` 创建必要的表结构。

### 4. 配置文件
修改 `../shared/config/radar-config.json` 配置雷达收集策略。

## 使用方法

### 基本命令

```bash
# 构建项目
npm run build

# 交互式搜索
npm run dev search

# 运行每日雷达
npm run daily

# 分析单个仓库
npm run dev analyze owner/repo

# 分析各类别的顶级项目
npm run analyze-top

# 发布到微信公众号
npm run publish-wechat --latest
```

### 详细命令说明

#### 1. 搜索命令 (`search`)
交互式搜索模式，支持多种过滤选项：

```bash
github-radar search --language Python --trending-days 7 --min-stars 50
```

#### 2. 每日雷达 (`daily`)
基于配置文件运行每日趋势收集：

```bash
github-radar daily --config ../shared/config/radar-config.json
```

#### 3. 分析命令 (`analyze`)
分析单个仓库并生成 AI 报告：

```bash
github-radar analyze microsoft/vscode --output ./reports --format markdown
```

#### 4. 批量分析 (`analyze-top`)
分析每个收集类别的顶级项目：

```bash
github-radar analyze-top --config ../shared/config/radar-config.json --delay 5000
```

#### 5. 微信发布 (`publish-wechat`)
发布分析报告到微信公众号：

```bash
github-radar publish-wechat --latest    # 发布最新分析
github-radar publish-wechat --id 123    # 发布指定分析
github-radar publish-wechat --list      # 列出可用分析
```

## 开发和构建

```bash
# 开发模式运行
npm run dev

# 类型检查
npm run typecheck

# 构建生产版本
npm run build

# 运行构建后的版本
npm start
```

## 项目结构

```
cli/
├── src/
│   ├── commands/          # CLI 命令实现
│   ├── core/              # 核心功能
│   ├── services/          # 外部服务集成
│   ├── types/             # TypeScript 类型定义
│   └── utils/             # 工具函数
├── dist/                  # 构建输出
├── package.json
├── tsconfig.json
└── README.md
```

## 核心依赖

- **@supabase/supabase-js**: 数据库操作
- **axios**: HTTP 请求
- **commander**: CLI 框架
- **openai**: AI 分析（通过 DeepSeek）
- **canvas**: 图像生成
- **form-data**: 微信文件上传

## 注意事项

1. **GitHub API 限制**: 没有 GitHub Token 时会有严格的速率限制
2. **AI 分析成本**: DeepSeek API 调用会产生费用
3. **微信发布**: 需要微信公众号的相应权限
4. **数据库**: 推荐使用 Supabase 的免费层进行开发测试