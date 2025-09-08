# GitHub Radar News

🤖 AI 驱动的 GitHub 项目发现与分析平台，帮助开发者发现优质开源项目

[![iOS App Store](https://img.shields.io/badge/App%20Store-TestFlight-blue)](https://testflight.apple.com/join/your-link)
[![GitHub Actions](https://github.com/yourusername/news-gh/workflows/CI/badge.svg)](https://github.com/yourusername/news-gh/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.2.4+-blue)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Database-green)](https://supabase.com/)

## ✨ 项目亮点

- 🔍 **智能发现**: AI 驱动的 GitHub 项目自动收集和推荐
- 📱 **移动优先**: Flutter 跨平台应用，已在 App Store 发布
- 🚀 **完整 CI/CD**: 经过 52 个版本迭代的成熟自动化构建流程
- 🤖 **深度分析**: GPT-4 和 DeepSeek 生成专业项目分析报告
- 📊 **实时数据**: Supabase 驱动的云数据存储和同步

## 🏗️ 项目结构

```
📦 news-gh/
├── 🔧 core/                 # Node.js 后端服务
├── 📱 mobile/               # Flutter 移动应用  
├── 📚 docs/                 # 完整项目文档
├── 🗃️ shared/              # 共享资源和数据库
└── ⚙️ .github/workflows/   # CI/CD 自动化
```

## 🚀 快速开始

### 开发者快速启动

```bash
# 1. 克隆项目
git clone https://github.com/yourusername/news-gh.git
cd news-gh

# 2. 启动后端服务
cd core && npm install && npm run daily

# 3. 启动移动应用  
cd mobile && flutter pub get && flutter run
```

### 新项目 iOS CI/CD 设置

如果你想为自己的 Flutter 项目添加 iOS 自动构建：

```bash
# 复制我们的成熟构建脚本
cp -r scripts/ /path/to/your/project/
cp -r .github/workflows/ /path/to/your/project/.github/

# 参考快速设置指南
open docs/mobile/ios/ios-build-quick-reference.md
```

## 📚 完整文档中心

### 🎯 [**文档主页**](docs/README.md)
> 📖 完整的文档索引和快速导航

### 📱 移动端开发
- 🏗️ [**iOS构建完整解决方案**](docs/mobile/ios/ios-build-complete-solution.md) - 52版本迭代经验总结
- ⚡ [**iOS构建快速参考**](docs/mobile/ios/ios-build-quick-reference.md) - 新项目5分钟设置
- 🔧 [**iOS构建故障排除**](docs/mobile/ios/ios-build-troubleshooting.md) - 问题诊断指南
- 🔐 [**证书和签名配置**](docs/mobile/ios/) - 完整的证书管理方案

### 🖥️ 后端开发
- 📊 [**CLI工具使用指南**](docs/cli/) - 命令行工具和分析器
- 🚀 [**部署文档**](docs/deployment/) - 应用发布和分发

### 👨‍💻 开发流程  
- 🔄 [**开发文档**](docs/development/) - 发布流程和安全指南

## 📈 开发状态

- ✅ **核心功能完整**: AI 驱动的项目收集和分析系统
- ✅ **移动应用发布**: Flutter 跨平台应用，支持 iOS TestFlight 分发
- ✅ **成熟 CI/CD**: 经过 52 版本迭代的自动化构建和发布流程
- ✅ **完整文档体系**: 从快速入门到故障排除的全面指南
- 🚧 Android Google Play 发布准备中
- 📋 Web 版本规划中

## 🤝 贡献指南

欢迎提交 Pull Request 和 Issue！开发前请阅读 [开发文档](docs/development/)。

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

**GitHub Radar News** - 让 AI 帮你发现优质开源项目 🚀