# GitHub Radar Mobile

Flutter 移动应用，用于浏览 GitHub Radar CLI 生成的 AI 项目分析报告。

## 功能特性

- **直连数据库**: 直接连接 Supabase，无需中间 API 服务器
- **新闻浏览**: 以新闻形式展示 AI 生成的项目分析报告
- **分类筛选**: 按编程语言和收集类型筛选内容
- **搜索功能**: 搜索特定的分析报告
- **下拉刷新**: 获取最新分析内容
- **无限滚动**: 分页加载更多内容
- **离线缓存**: 支持基本的离线阅读
- **实时更新**: 利用 Supabase 实时功能（可扩展）

## 环境要求

```bash
# 确保已安装 Flutter SDK
flutter --version

# 确保版本 >= 3.2.4
```

## 安装和配置

### 1. 安装依赖
```bash
cd mobile
flutter pub get
```

### 2. 配置 Supabase 连接
Flutter 应用直接连接到 Supabase 数据库，无需中间 API 服务器。

**推荐方式：使用 .env 文件**
```bash
# 1. 复制环境变量模板
cp .env.example .env

# 2. 编辑 .env 文件，填入你的 Supabase 配置
# SUPABASE_URL=https://your-project-id.supabase.co
# SUPABASE_ANON_KEY=your-supabase-anon-key-here
```

**替代方式：命令行参数**
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### 3. 数据库设置
确保已在 Supabase 中运行了 `../shared/database/schema.sql` 创建必要的表结构。

## 使用方法

### 开发运行
```bash
# 开发模式运行（需要连接设备或启动模拟器）
flutter run

# 热重载开发
# 在运行中按 'r' 进行热重载
# 在运行中按 'R' 进行热重启
```

### 构建发布版本
```bash
# 构建 APK (Android)
flutter build apk --release

# 构建 iOS 应用 (需要 macOS)
flutter build ios --release

# 构建 iOS IPA 文件
flutter build ipa --release
```

### 代码生成
```bash
# 生成 JSON 序列化代码
flutter packages pub run build_runner build

# 监听文件变化并自动生成代码
flutter packages pub run build_runner watch
```

## 应用功能

- **首页**: 展示所有分析报告，支持按语言和类型筛选
- **搜索**: 搜索特定的分析报告
- **详情页**: 查看完整的分析内容，支持 Markdown 渲染
- **下拉刷新**: 获取最新内容
- **无限滚动**: 自动加载更多内容

## 项目结构

```
mobile/
├── lib/
│   ├── config/            # 应用配置
│   ├── models/            # 数据模型
│   ├── services/          # 服务层
│   ├── providers/         # 状态管理
│   ├── screens/           # 页面
│   └── widgets/           # UI 组件
├── ios/                   # iOS 平台文件
├── android/              # Android 平台文件
├── pubspec.yaml
└── README.md
```

## 故障排除

### 常见问题

#### 类型转换错误
**问题**: `type 'List<dynamic>' is not a subtype of type 'List<Analysis>'`

**解决方案**: 此问题已在应用中修复。如遇到类似问题：
1. 确保使用最新版本的应用
2. 检查 Supabase 数据库中的 DateTime 字段格式
3. 查看应用日志中的详细错误信息

#### Supabase 连接问题
1. 确认 `.env` 文件配置正确
2. 检查 Supabase URL 和 Key 的有效性
3. 验证网络连接
4. 确保 Supabase 项目中的 RLS 策略允许匿名访问

#### Flutter 环境问题
```bash
# 检查 Flutter 环境
flutter doctor

# 清理项目
flutter clean
flutter pub get
```

## 核心依赖

- **supabase_flutter**: Supabase 数据库连接
- **provider**: 状态管理
- **flutter_markdown**: Markdown 渲染
- **cached_network_image**: 图片缓存
- **pull_to_refresh**: 下拉刷新
- **shared_preferences**: 本地存储
- **flutter_dotenv**: 环境变量管理

## 注意事项

1. **数据库连接**: 应用直接连接 Supabase，确保网络连接稳定
2. **iOS 构建**: iOS 构建需要 macOS 环境和 Xcode
3. **Android 签名**: 发布 Android 应用需要配置签名
4. **权限设置**: 确保应用有网络访问权限