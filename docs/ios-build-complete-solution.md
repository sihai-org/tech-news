# iOS自动构建完整解决方案

## 概述

本文档记录了在GitHub Actions中实现Flutter iOS应用完整自动构建流程的详细解决方案。经过52个版本的迭代调试（v1.1.1 - v1.1.52），最终实现了从证书导入到IPA生成的完整自动化流程。

## 最终成功架构

### 核心组件
1. **证书导入脚本** - `scripts/import-certificate.sh`
2. **Flutter xcconfig配置** - `mobile/ios/Flutter/Release.xcconfig`
3. **ExportOptions.plist生成** - `scripts/generate-export-options.sh`
4. **GitHub Actions工作流** - `.github/workflows/build-and-release.yml`

### 关键成功要素
- ✅ PKCS#12证书格式的正确导入
- ✅ Flutter项目的xcconfig配置系统
- ✅ Pods依赖的签名配置隔离
- ✅ App Store导出方法的正确配置

## 详细解决方案

### 1. 证书导入问题解决

#### 问题描述
- 初始错误：`SecKeychainItemImport: Unknown format in import`
- Base64编码的证书无法被正确识别和导入

#### 最终解决方案 (v1.1.37)
```bash
# scripts/import-certificate.sh - Method 3: 明确指定PKCS#12格式
if security import distribution.cert -k $KEYCHAIN_NAME -t cert -f pkcs12 -P "$CERT_PASSWORD" -A -T /usr/bin/codesign -T /usr/bin/security; then
    echo "✅ PKCS#12 import successful with explicit format"
    IMPORT_SUCCESS=true
fi
```

**关键点：**
- 使用 `-f pkcs12` 明确指定证书格式
- 添加 `-A -T` 参数允许所有应用访问
- 多种导入方法的fallback机制

### 2. Pods签名配置隔离

#### 问题描述
- 错误：`sqflite does not support provisioning profiles`
- Pods目标继承了主应用的provisioning profile设置

#### 最终解决方案 (v1.1.38)
```yaml
# 清理Pods项目中的签名设置
if [ -f "Pods/Pods.xcodeproj/project.pbxproj" ]; then
    echo "Final cleanup of Pods provisioning profiles..."
    # 删除所有PROVISIONING_PROFILE_SPECIFIER设置
    sed -i '' '/PROVISIONING_PROFILE_SPECIFIER/d' Pods/Pods.xcodeproj/project.pbxproj
    # 强制设置为自动签名
    sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' Pods/Pods.xcodeproj/project.pbxproj
    # 移除CODE_SIGN_IDENTITY
    sed -i '' '/CODE_SIGN_IDENTITY/d' Pods/Pods.xcodeproj/project.pbxproj
fi
```

**关键原则：**
- 绝不在xcodebuild命令中使用全局PROVISIONING_PROFILE_SPECIFIER参数
- 主动清理Pods项目中的所有签名配置
- 让Pods使用自动签名，主应用使用手动签名

### 3. Flutter xcconfig配置系统

#### 问题描述
- 对`project.pbxproj`的修改都无效
- Flutter项目使用不同的构建配置系统

#### 重大发现 (v1.1.48)
Flutter项目使用xcconfig文件系统而不是直接的project.pbxproj配置：

```bash
# 正确的配置位置：Flutter/Release.xcconfig
echo "" >> Flutter/Release.xcconfig
echo "// Code signing settings for distribution" >> Flutter/Release.xcconfig
echo "CODE_SIGN_STYLE = Manual" >> Flutter/Release.xcconfig
echo "DEVELOPMENT_TEAM = $APPLE_TEAM_ID" >> Flutter/Release.xcconfig
echo "PROVISIONING_PROFILE_SPECIFIER = $PROVISIONING_PROFILE_UUID" >> Flutter/Release.xcconfig
```

**关键理解：**
- Flutter使用xcconfig文件管理构建设置
- 不要修改project.pbxproj文件
- Release.xcconfig是Release构建的配置文件

### 4. ExportOptions.plist配置

#### 最终成功配置 (v1.1.51)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>cn.datouai.technews</key>
        <string>$PROVISIONING_PROFILE_UUID</string>
    </dict>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
```

**关键配置：**
- 使用`app-store`方法匹配App Store provisioning profile
- `destination=export`明确指定导出而非上传
- `uploadSymbols=true`用于App Store构建

## 完整工作流程

### GitHub Secrets配置
```
DISTRIBUTION_CERTIFICATE_BASE64  # Apple Distribution证书的Base64编码
PROVISIONING_PROFILE_BASE64       # Provisioning Profile的Base64编码
DISTRIBUTION_CERT_PASSWORD        # 证书密码（PKCS#12需要）
KEYCHAIN_PASSWORD                 # 临时keychain密码
TEAM_ID                          # Apple Developer Team ID
```

### 构建流程步骤

1. **环境准备**
   ```yaml
   - name: Setup iOS Code Signing
     env:
       DISTRIBUTION_CERT_BASE64: ${{ secrets.DISTRIBUTION_CERTIFICATE_BASE64 }}
       PROVISIONING_PROFILE_BASE64: ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
       DISTRIBUTION_CERT_PASSWORD: ${{ secrets.DISTRIBUTION_CERT_PASSWORD }}
       KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
       APPLE_TEAM_ID: ${{ secrets.TEAM_ID }}
   ```

2. **证书导入**
   ```bash
   bash scripts/import-certificate.sh
   ```

3. **ExportOptions生成**
   ```bash
   bash scripts/generate-export-options.sh
   ```

4. **Flutter构建**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install
   ```

5. **xcconfig配置**
   ```bash
   # 添加签名配置到Flutter/Release.xcconfig
   ```

6. **Pods清理**
   ```bash
   # 清理Pods项目中的签名配置
   ```

7. **Archive构建**
   ```bash
   xcodebuild -workspace Runner.xcworkspace \
     -scheme Runner \
     -configuration Release \
     archive
   ```

8. **IPA导出**
   ```bash
   xcodebuild -exportArchive \
     -archivePath Runner.xcarchive \
     -exportOptionsPlist ExportOptions.plist
   ```

## 常见陷阱和避免方法

### ❌ 错误做法

1. **使用全局PROVISIONING_PROFILE_SPECIFIER参数**
   ```bash
   # 错误：这会影响所有目标，包括Pods
   xcodebuild ... PROVISIONING_PROFILE_SPECIFIER="$UUID"
   ```

2. **修改project.pbxproj文件**
   ```bash
   # 错误：Flutter项目不使用project.pbxproj配置
   sed -i '' "s/CODE_SIGN_STYLE = .*/CODE_SIGN_STYLE = Manual/" project.pbxproj
   ```

3. **使用不匹配的导出方法**
   ```xml
   <!-- 错误：App Store profile不能用ad-hoc导出 -->
   <key>method</key>
   <string>ad-hoc</string>
   ```

### ✅ 正确做法

1. **只为主应用配置签名**
   - 在Flutter/Release.xcconfig中配置
   - 清理Pods的签名设置
   - 不使用全局参数

2. **使用正确的证书导入方法**
   - 明确指定PKCS#12格式
   - 提供正确的密码
   - 设置keychain访问权限

3. **匹配导出方法和profile类型**
   - App Store profile → app-store方法
   - Ad Hoc profile → ad-hoc方法
   - Development profile → development方法

## 调试技巧

### 1. 环境变量验证
```bash
echo "=== Environment Variables Status ==="
echo "DISTRIBUTION_CERT_BASE64 length: ${#DISTRIBUTION_CERT_BASE64}"
echo "PROVISIONING_PROFILE_BASE64 length: ${#PROVISIONING_PROFILE_BASE64}"
echo "APPLE_TEAM_ID: $APPLE_TEAM_ID"
```

### 2. 证书导入验证
```bash
security find-identity -v -p codesigning build.keychain
security list-keychains -d user
```

### 3. 配置文件检查
```bash
echo "=== Flutter/Release.xcconfig ==="
cat Flutter/Release.xcconfig
echo "=== ExportOptions.plist ==="
cat ExportOptions.plist
```

### 4. Pods清理验证
```bash
echo "Pods provisioning profiles after cleanup:"
grep -c "PROVISIONING_PROFILE_SPECIFIER" Pods/Pods.xcodeproj/project.pbxproj || echo "None found"
```

## 版本历程总结

| 版本范围 | 主要问题 | 解决方案 | 状态 |
|----------|----------|----------|------|
| v1.1.1-v1.1.37 | 证书导入失败 | PKCS#12 Method 3 | ✅ 解决 |
| v1.1.38 | Pods继承provisioning profile | Pods项目清理 | ✅ 解决 |
| v1.1.39-v1.1.45 | YAML语法错误 | 简化命令语法 | ✅ 解决 |
| v1.1.46 | 项目文件损坏 | 备份恢复机制 | ✅ 解决 |
| v1.1.47 | Pods再次继承 | 移除全局参数 | ✅ 解决 |
| v1.1.48 | Runner配置失效 | **Flutter xcconfig系统** | 🏆 突破 |
| v1.1.49-v1.1.51 | IPA导出失败 | 正确的导出配置 | ✅ 解决 |
| v1.1.52 | 文件路径问题 | 智能文件定位 | 🎯 完成 |

## 最终成果

- ✅ **完整自动化流程**：从代码提交到签名IPA
- ✅ **稳定可靠**：所有边缘情况都已处理
- ✅ **可复用**：配置可直接应用到其他Flutter iOS项目
- ✅ **27MB签名IPA**：包含完整功能的生产就绪应用

## 应用到新项目的检查清单

### 必需文件
- [ ] `scripts/import-certificate.sh` - 证书导入脚本
- [ ] `scripts/generate-export-options.sh` - ExportOptions生成脚本
- [ ] `.github/workflows/build-and-release.yml` - GitHub Actions工作流

### GitHub Secrets配置
- [ ] `DISTRIBUTION_CERTIFICATE_BASE64` - Apple Distribution证书
- [ ] `PROVISIONING_PROFILE_BASE64` - App Store provisioning profile
- [ ] `DISTRIBUTION_CERT_PASSWORD` - 证书密码
- [ ] `KEYCHAIN_PASSWORD` - keychain密码
- [ ] `TEAM_ID` - Apple Developer Team ID

### 项目配置
- [ ] 更新Bundle ID在ExportOptions.plist中
- [ ] 确认Flutter版本兼容性
- [ ] 验证iOS最低版本要求
- [ ] 检查Podfile配置

### 测试验证
- [ ] 本地证书导入测试
- [ ] GitHub Actions workflow验证
- [ ] 生成的IPA安装测试
- [ ] 代码签名验证测试

---

**总结：经过52个版本的迭代，我们成功建立了一个完整、稳定、可复用的Flutter iOS自动构建系统。这套方案解决了证书导入、依赖签名隔离、Flutter配置系统、IPA导出等所有核心问题，为后续项目提供了坚实的基础。**