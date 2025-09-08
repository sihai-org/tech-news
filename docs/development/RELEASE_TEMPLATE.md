# GitHub Radar News Release Template

## 📋 发布检查清单

### 发布前准备
- [ ] 更新 `mobile/pubspec.yaml` 中的版本号
- [ ] 更新 `cli/package.json` 中的版本号  
- [ ] 更新 README.md 中的版本信息
- [ ] 确保所有 CI 检查通过
- [ ] 在本地测试 Android 和 iOS 构建

### GitHub Secrets 配置
确保在 GitHub 仓库设置中配置了以下 Secrets：

- `SUPABASE_URL`: 你的 Supabase 项目 URL
- `SUPABASE_ANON_KEY`: 你的 Supabase 匿名密钥

### 发布步骤

#### 方法 1: 标签发布（推荐）
```bash
# 创建版本标签
git tag v1.3.0
git push origin v1.3.0
```

#### 方法 2: 手动触发
1. 进入 GitHub Actions 页面
2. 选择 "Build and Release Mobile App" 工作流
3. 点击 "Run workflow"
4. 选择发布类型（beta/release）

### 发布后检查
- [ ] 检查 GitHub Release 页面是否正确创建
- [ ] 验证 APK 和 IPA 文件可以正常下载
- [ ] 测试下载的应用是否可以正常安装和运行
- [ ] 更新项目文档和 README

## 📱 应用分发说明

### Android APK
- **直接安装**: 用户可以直接下载 APK 文件安装
- **要求**: Android 6.0+ (API 23)
- **权限**: 需要启用"未知来源"安装

### iOS IPA  
- **侧载安装**: 需要通过 AltStore、3uTools 等工具
- **TestFlight**: 需要 Apple Developer 账号
- **要求**: iOS 12.0+

### 应用商店发布（可选）
- **Google Play**: 使用 AAB 文件，需要开发者账号
- **App Store**: 需要重新签名和 Apple Developer 账号

## 🚀 自动化功能

### 构建触发条件
1. **标签推送**: 推送 `v*.*.*` 格式的标签
2. **手动触发**: GitHub Actions 页面手动运行

### 构建输出
- `github-radar-news-v*.*.*.android.apk`: Android 安装包
- `github-radar-news-v*.*.*.android.aab`: Android 应用包（Play Store）
- `github-radar-news-v*.*.*.ios.ipa`: iOS 安装包

### 发布内容
- 自动生成的发布说明
- 安装指南和系统要求
- 下载链接和文件说明

## 🔧 故障排除

### 构建失败常见问题
1. **Java 版本**: 确保使用 Java 17
2. **Flutter 版本**: 确保使用指定的 Flutter 版本
3. **依赖问题**: 检查 pubspec.yaml 依赖版本
4. **环境变量**: 确保 GitHub Secrets 配置正确

### iOS 构建问题
1. **代码签名**: 当前配置为无签名构建
2. **证书**: 如需正式发布需要配置开发者证书
3. **设备兼容性**: 检查最低 iOS 版本要求

### Android 构建问题  
1. **SDK 版本**: 确保 compileSdkVersion 正确
2. **Gradle 版本**: 确保与 Java 版本兼容
3. **权限**: 检查 AndroidManifest.xml 权限配置