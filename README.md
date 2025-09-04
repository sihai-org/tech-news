# GitHub Radar News

AI 驱动的 GitHub 项目发现与分析平台，自动收集、分析并生成 GitHub 优质项目的深度报告。

## 项目简介

GitHub Radar News 是一个自动化的 GitHub 项目发现与分析平台，通过 AI 技术帮助开发者发现有价值的开源项目。系统每天自动收集热门仓库，使用 AI 生成深度分析报告，并通过移动应用展示给用户。

## 主要功能

- 🔍 **智能收集**: 自动从多个维度收集 GitHub 优质项目（每日趋势、新发布、特定语言等）
- 🤖 **AI 分析**: 使用 GPT-4 和 DeepSeek 对项目进行深度分析，生成专业报告
- 📱 **移动应用**: Flutter 跨平台应用，已发布到 App Store (TestFlight)
- 🚀 **自动化工作流**: GitHub Actions 驱动的全自动化流程，每日定时运行
- 📊 **数据持久化**: Supabase 提供可靠的云数据存储
- 🌐 **多语言支持**: 覆盖主流编程语言的项目分析

## 项目结构

```
news-gh/
├── core/              # 核心服务（收集、分析、API）
│   ├── collectors/    # 数据收集器
│   ├── analyzers/     # AI 分析器
│   └── scripts/       # 运行脚本
├── mobile/            # Flutter 移动应用
│   ├── lib/          # 应用源码
│   ├── ios/          # iOS 平台配置
│   └── android/      # Android 平台配置
├── shared/            # 共享资源
│   └── database/     # 数据库 Schema
├── docs/              # 项目文档
│   ├── mobile/       # 移动端文档
│   └── setup-guide.md # 配置指南
└── .github/           # GitHub 配置
    └── workflows/     # 自动化工作流
```

## 技术栈

- **后端**: Node.js, TypeScript
- **移动端**: Flutter 3.2.4+, Dart
- **数据库**: Supabase (PostgreSQL)
- **AI**: OpenAI GPT-4, DeepSeek
- **CI/CD**: GitHub Actions
- **平台**: iOS 12.0+, Android, Web

## 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/yourusername/news-gh.git
cd news-gh
```

### 2. 配置环境
参考 [环境配置指南](docs/setup-guide.md) 设置必要的环境变量和密钥。

### 3. 运行核心服务
```bash
cd core
npm install
npm run daily  # 运行每日收集和分析任务
```

### 4. 运行移动应用
```bash
cd mobile
flutter pub get
flutter run
```

详细说明请查看 [核心服务文档](core/README.md) 和 [移动应用文档](mobile/README.md)。

## 文档索引

### 核心文档
- [核心服务 README](core/README.md) - 收集器和分析器详细说明
- [移动应用 README](mobile/README.md) - Flutter 应用开发指南
- [环境配置指南](docs/setup-guide.md) - 完整的环境配置说明

### 移动应用文档
- [iOS 构建指南](docs/mobile/ios-build-guide.md) - iOS 打包发布完整流程
- [iOS 签名配置](docs/mobile/ios-signing-setup.md) - 证书和签名设置
- [Supabase 配置](docs/mobile/supabase-setup.md) - 数据库连接配置

### 证书管理
- [本地证书管理](mobile/ios/certs/README.md) - 开发环境证书配置
- [GitHub Secrets 配置](mobile/ios/certs/setup-github-secrets.md) - CI/CD 证书设置

### 数据库
- [数据库 Schema](shared/database/schema.sql) - 完整的数据库结构

### CI/CD
- [自动化工作流](.github/workflows/build-and-release.yml) - GitHub Actions 配置
- [每日任务工作流](.github/workflows/daily-github-radar.yml) - 定时收集任务

## 版本历史

### v1.1.5 (2025-01-04)
- ✅ 完全重构 iOS 证书导入逻辑
- ✅ 使用渐进式导入策略（从简单到复杂）
- ✅ 修复 security import 命令格式参数问题
- ✅ 改进错误处理和调试输出
- ✅ 支持多种证书格式检测和导入

### v1.1.1-1.1.4 (2025-01-04)
- 🔧 iOS 证书导入问题修复历程
- 🔧 证书格式检测优化
- 🔧 security 命令参数调整

### v1.0.9 (2025-01-04)
- ✅ iOS App Store 发布成功（TestFlight）
- ✅ 修复 SwiftSupport 和隐私清单问题
- ✅ 完善文档结构和 CI/CD 配置

### v1.0.8 (2025-01-03)
- 修复 Android 网络权限问题
- 更新 iOS Bundle ID 为 `cn.datouai.technews`
- 配置 iOS Distribution 证书

### v1.0.7
- 添加每日 GitHub Radar 收集工作流
- 实现可配置的收集限制
- 修复 DeepSeek 服务初始化问题

## 开发状态

- ✅ 核心收集和分析功能
- ✅ Flutter 移动应用
- ✅ iOS App Store 发布
- ✅ 自动化工作流
- 🚧 Android Google Play 发布
- 📋 Web 版本开发

## 贡献指南

欢迎提交 Pull Request 和 Issue。开发前请阅读相关文档。

## 许可证

MIT

---

### 详细架构文档（原内容保留供参考）

<details>
<summary>后端 CLI 工具结构</summary>
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

## 快速开始

### 🚀 一键安装和配置
```bash
# 克隆项目
git clone <repository-url>
cd github-radar

# 运行安装脚本（会自动安装所有依赖）
./scripts/setup.sh
```

### ✋ 手动安装步骤

#### 1. 环境要求
- **Node.js** >= 16.x
- **Flutter** >= 3.2.4
- **npm** 或 **yarn**

#### 2. 安装 CLI 工具
```bash
cd cli
npm install
cp .env.example .env
# 编辑 .env 文件配置你的 API 密钥
npm run build
```

#### 3. 安装移动应用
```bash
cd mobile
flutter pub get
cp .env.example .env
# 编辑 .env 文件配置你的 Supabase 连接
flutter packages pub run build_runner build
```

#### 4. 数据库设置
在 Supabase SQL Editor 中运行 `shared/database/schema.sql` 创建必要的表结构。

#### 5. 配置文件
修改 `shared/config/radar-config.json` 配置雷达收集策略。

### 📋 环境变量配置

**CLI 工具** (`cli/.env`):
```bash
GITHUB_TOKEN=your_github_token_here          # GitHub API Token
SUPABASE_URL=your_supabase_project_url       # Supabase 项目 URL
SUPABASE_ANON_KEY=your_supabase_anon_key     # Supabase 匿名密钥
DEEPSEEK_API_KEY=your_deepseek_api_key       # DeepSeek AI API 密钥
WECHAT_APP_ID=your_wechat_app_id             # 微信 App ID
WECHAT_APP_SECRET=your_wechat_app_secret     # 微信 App Secret
```

**移动应用** (`mobile/.env`):
```bash
SUPABASE_URL=your_supabase_project_url       # Supabase 项目 URL
SUPABASE_ANON_KEY=your_supabase_anon_key     # Supabase 匿名密钥
APP_NAME=GitHub Radar News                   # 应用名称
APP_VERSION=1.2.2                            # 应用版本
```

## 使用方法

### 🔧 构建和开发

### 本地开发构建

```bash
# 构建所有项目
./scripts/build-all.sh

# 单独构建 CLI
cd cli && npm run build

# 单独构建移动应用
cd mobile && flutter build apk --release
```

### GitHub Actions 自动构建

项目配置了完整的 CI/CD 流水线，支持自动构建和发布移动应用。

#### 🚀 自动发布流程

**方法 1: 标签发布（推荐）**
```bash
# 创建并推送版本标签
git tag v1.3.0
git push origin v1.3.0
```

**方法 2: 手动触发**
1. 进入 GitHub Actions 页面
2. 选择 "Build and Release Mobile App" 工作流
3. 点击 "Run workflow" 手动触发

#### 📱 构建产物

自动构建会生成以下文件：
- **Android APK**: `github-radar-news-v*.*.*.android.apk` - 直接安装使用
- **Android AAB**: `github-radar-news-v*.*.*.android.aab` - Google Play Store 发布
- **iOS IPA**: `github-radar-news-v*.*.*.ios.ipa` - 侧载安装或 TestFlight 分发

#### ⚙️ GitHub Secrets 配置

在 GitHub 仓库设置中需要配置以下 Secrets：

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 💻 CLI 工具使用

```bash
cd cli

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

### 📱 移动应用开发

```bash
cd mobile

# 开发模式运行
flutter run

# 生成代码
flutter packages pub run build_runner build

# 构建 APK
flutter build apk --release

# 构建 iOS (需要 macOS)
flutter build ios --release
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

</details>