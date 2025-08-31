# GitHub Radar

GitHub Open Source Radar - 发现趋势项目、快速增长项目和新发布的仓库的 CLI 工具和移动应用。

## 项目概述

这是一个完整的 GitHub 项目趋势监控和分析解决方案，包含后端 CLI 工具和移动端应用。主要功能包括：

### 后端 CLI 工具 (TypeScript)
- **趋势发现**: 发现指定语言和时间窗口内的趋势项目
- **快速增长监测**: 找出增长最快的项目（按星标增长速度）
- **新项目追踪**: 监控新发布的有潜力的项目
- **AI 分析**: 使用 AI 深度分析项目并生成报告
- **数据存储**: 支持 Supabase 数据库存储分析结果
- **微信发布**: 自动发布分析报告到微信公众号草稿

### 移动端应用 (Flutter)
- **直连数据库**: 直接连接 Supabase，无需中间 API 服务器
- **新闻浏览**: 以新闻形式展示 AI 生成的项目分析报告
- **分类筛选**: 按编程语言和收集类型筛选内容
- **搜索功能**: 搜索特定的分析报告
- **下拉刷新**: 获取最新分析内容
- **无限滚动**: 分页加载更多内容
- **离线缓存**: 支持基本的离线阅读
- **实时更新**: 利用 Supabase 实时功能（可扩展）

## 项目架构

### 后端 CLI 工具结构
```
src/
├── commands/          # CLI 命令实现
│   ├── search.ts      # 交互式搜索命令
│   ├── daily.ts       # 每日雷达命令
│   ├── analyze.ts     # 单个仓库分析
│   ├── analyze-top.ts # 批量分析顶级项目
│   └── publish-wechat.ts # 微信发布命令
├── core/              # 核心功能
│   ├── github-api.ts  # GitHub API 封装
│   ├── github-content.ts # GitHub 内容获取
│   ├── radar.ts       # 雷达核心逻辑
│   └── analyzer.ts    # AI 分析器
├── services/          # 外部服务集成
│   ├── supabase.ts    # 数据库服务
│   ├── deepseek.ts    # DeepSeek AI 服务
│   ├── wechat.ts      # 微信 API 服务
│   ├── storage.ts     # 存储抽象层
│   └── image-generator.ts # 图像生成
├── types/             # TypeScript 类型定义
│   ├── index.ts       # 通用类型
│   ├── radar.ts       # 雷达相关类型
│   └── analysis.ts    # 分析相关类型
└── utils/             # 工具函数
    ├── config.ts      # 配置管理
    ├── markdown.ts    # Markdown 处理
    └── title-extractor.ts # 标题提取
```

### 移动端应用结构
```
mobile_app/lib/
├── config/            # 应用配置
│   ├── app_config.dart    # 应用配置常量
│   └── app_theme.dart     # 主题配置
├── models/            # 数据模型
│   ├── analysis.dart      # 分析数据模型
│   ├── repository.dart    # 仓库数据模型
│   ├── collection.dart    # 收集数据模型
│   └── api_response.dart  # API 响应模型
├── services/          # 服务层
│   ├── http_client.dart   # HTTP 客户端
│   ├── analysis_service.dart # 分析数据服务
│   └── cache_service.dart # 缓存服务
├── providers/         # 状态管理
│   └── analysis_provider.dart # 分析数据状态管理
├── screens/           # 页面
│   ├── home_screen.dart   # 主页面
│   └── analysis_detail_screen.dart # 详情页面
└── widgets/           # UI 组件
    ├── analysis_card.dart     # 分析卡片组件
    ├── filter_bar.dart       # 筛选栏组件
    ├── loading_widget.dart    # 加载组件
    ├── error_widget.dart      # 错误组件
    ├── repository_info_card.dart # 仓库信息卡片
    └── analysis_metadata.dart # 分析元数据组件
```

## 安装和配置

### 1. 安装依赖
```bash
npm install
```

### 2. 环境配置
复制 `.env.example` 到 `.env` 并配置所需的环境变量：

```bash
GITHUB_TOKEN=your_github_token_here          # GitHub API Token
SUPABASE_URL=your_supabase_project_url       # Supabase 项目 URL
SUPABASE_ANON_KEY=your_supabase_anon_key     # Supabase 匿名密钥
DEEPSEEK_API_KEY=your_deepseek_api_key       # DeepSeek AI API 密钥
WECHAT_APP_ID=your_wechat_app_id             # 微信 App ID
WECHAT_APP_SECRET=your_wechat_app_secret     # 微信 App Secret
```

### 3. 数据库设置
如果使用 Supabase 存储，需要在 Supabase SQL Editor 中运行 `database-schema.sql` 创建必要的表结构。

### 4. 配置文件
修改 `radar-config.json` 配置雷达收集策略：

```json
{
  "collections": [
    {
      "name": "trending_typescript",
      "type": "trending",
      "language": "TypeScript", 
      "days": 7,
      "minStars": 5
    }
  ],
  "output": {
    "type": "supabase",
    "directory": "./data",
    "format": "json"
  }
}
```

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
github-radar daily --config ./radar-config.json
```

#### 3. 分析命令 (`analyze`)
分析单个仓库并生成 AI 报告：

```bash
github-radar analyze microsoft/vscode --output ./reports --format markdown
```

#### 4. 批量分析 (`analyze-top`)
分析每个收集类别的顶级项目：

```bash
github-radar analyze-top --config ./radar-config.json --delay 5000
```

#### 5. 微信发布 (`publish-wechat`)
发布分析报告到微信公众号：

```bash
github-radar publish-wechat --latest    # 发布最新分析
github-radar publish-wechat --id 123    # 发布指定分析
github-radar publish-wechat --list      # 列出可用分析
```

### Flutter 移动应用使用

#### 1. 环境要求
```bash
# 确保已安装 Flutter SDK
flutter --version

# 安装依赖
cd mobile_app
flutter pub get
```

#### 2. 运行应用
```bash
# 开发模式运行（需要连接设备或启动模拟器）
flutter run

# 构建 APK (Android)
flutter build apk --release

# 构建 iOS 应用 (需要 macOS)
flutter build ios --release
```

#### 3. 配置 Supabase 连接
Flutter 应用直接连接到 Supabase 数据库，无需中间 API 服务器。

**推荐方式：使用 .env 文件**
```bash
# 1. 复制环境变量模板
cp mobile_app/.env.example mobile_app/.env

# 2. 编辑 .env 文件，填入你的 Supabase 配置
# SUPABASE_URL=https://your-project-id.supabase.co
# SUPABASE_ANON_KEY=your-supabase-anon-key-here

# 3. 运行应用
cd mobile_app
flutter run
```

**替代方式：命令行参数**
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

详细配置指南请查看：`mobile_app/SUPABASE_SETUP.md`

#### 4. 应用功能
- **首页**: 展示所有分析报告，支持按语言和类型筛选
- **搜索**: 搜索特定的分析报告
- **详情页**: 查看完整的分析内容，支持 Markdown 渲染
- **下拉刷新**: 获取最新内容
- **无限滚动**: 自动加载更多内容

## 数据库结构

项目使用 Supabase 作为数据库，包含三个主要表：

- `github_radar_collections`: 存储收集任务信息
- `github_radar_repositories`: 存储发现的仓库数据
- `github_radar_analyses`: 存储 AI 分析结果

详细结构参见 `database-schema.sql`。

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

## 开发工作流

**⚠️ 重要：每次完成开发任务后，必须执行以下步骤：**

### 1. 提交代码变更
```bash
git add .
git commit -m "描述性的提交信息"
```

### 2. 更新文档
- 如果添加了新功能，更新 README.md 中的相关章节
- 如果修改了 API 或配置，更新对应的使用说明
- 如果有重大变更，更新版本号和更新记录

### 3. 验证构建
```bash
# 确保项目能正常构建和类型检查
npm run build
npm run typecheck
```

### Claude Code 开发助手注意事项：
- 完成任何开发任务后，自动执行上述工作流
- 提交信息应该简洁明确，包含变更类型（feat/fix/refactor/docs等）
- 如有必要，同步更新 README.md 和其他相关文档
- 确保所有变更都有适当的文档记录

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

## 故障排除

### Flutter 应用常见问题

#### 类型转换错误
**问题**: `type 'List<dynamic>' is not a subtype of type 'List<Analysis>'`

**解决方案**: 此问题已在 v1.2.2 中修复。如遇到类似问题：
1. 确保使用最新版本的应用
2. 检查 Supabase 数据库中的 DateTime 字段格式
3. 查看应用日志中的详细错误信息

**技术说明**: Supabase 返回的 DateTime 字段可能不是标准字符串格式，需要在 JSON 序列化前进行格式转换。

#### Supabase 连接问题
1. 确认 `.env` 文件配置正确
2. 检查 Supabase URL 和 Key 的有效性
3. 验证网络连接

## 更新记录

- **v1.0.0**: 初始版本，基础雷达功能
- **v1.1.0**: 模块化重构，添加数据库支持和 AI 分析功能
- **v1.2.0**: 新增 Flutter 移动应用，支持跨平台新闻浏览体验
- **v1.2.1**: 优化架构，Flutter 应用直连 Supabase 数据库
- **v1.2.2**: 修复 Flutter 应用中的类型转换错误，提升 DateTime 字段处理的稳定性