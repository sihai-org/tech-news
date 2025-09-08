# iOS构建快速参考指南

## 🚀 新项目快速设置

### 1. 复制必要文件
```bash
# 从本项目复制以下文件到新项目：
cp scripts/import-certificate.sh /path/to/new-project/scripts/
cp scripts/generate-export-options.sh /path/to/new-project/scripts/
cp .github/workflows/build-and-release.yml /path/to/new-project/.github/workflows/
```

### 2. 修改Bundle ID
```bash
# 编辑 scripts/generate-export-options.sh
# 将 "cn.datouai.technews" 替换为新的Bundle ID
```

### 3. GitHub Secrets配置
```
DISTRIBUTION_CERTIFICATE_BASE64  # 获取方法见下方
PROVISIONING_PROFILE_BASE64       # 获取方法见下方  
DISTRIBUTION_CERT_PASSWORD        # 证书导出时的密码
KEYCHAIN_PASSWORD                 # 任意安全密码，用于临时keychain
TEAM_ID                          # Apple Developer Team ID
```

## 📱 获取证书和Profile的Base64

### 获取Distribution证书
```bash
# 1. 从Keychain导出证书为.p12格式（设置密码）
# 2. 转换为Base64
base64 -i /path/to/certificate.p12 | pbcopy
# 3. 粘贴到GitHub Secrets的DISTRIBUTION_CERTIFICATE_BASE64
```

### 获取Provisioning Profile
```bash
# 1. 从Apple Developer下载.mobileprovision文件
# 2. 转换为Base64  
base64 -i /path/to/profile.mobileprovision | pbcopy
# 3. 粘贴到GitHub Secrets的PROVISIONING_PROFILE_BASE64
```

## 🔧 核心配置要点

### ✅ 正确做法
1. **使用Flutter xcconfig系统**
   ```bash
   # 在 Flutter/Release.xcconfig 中配置签名
   CODE_SIGN_STYLE = Manual
   DEVELOPMENT_TEAM = YOUR_TEAM_ID
   PROVISIONING_PROFILE_SPECIFIER = YOUR_PROFILE_UUID
   ```

2. **清理Pods签名配置**
   ```bash
   # 删除Pods中的所有签名设置
   sed -i '' '/PROVISIONING_PROFILE_SPECIFIER/d' Pods/Pods.xcodeproj/project.pbxproj
   sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' Pods/Pods.xcodeproj/project.pbxproj
   ```

3. **使用匹配的导出方法**
   ```xml
   <!-- App Store provisioning profile使用app-store方法 -->
   <key>method</key>
   <string>app-store</string>
   ```

### ❌ 避免的错误
1. **不要在xcodebuild中使用全局PROVISIONING_PROFILE_SPECIFIER**
2. **不要修改project.pbxproj文件**（Flutter不使用）
3. **不要让Pods继承主应用的签名设置**

## 🐛 常见问题解决

### 证书导入失败
```bash
# 确保使用PKCS#12格式和正确密码
security import distribution.cert -k build.keychain -t cert -f pkcs12 -P "$PASSWORD"
```

### Pods签名错误
```bash
# 错误：sqflite does not support provisioning profiles
# 解决：清理Pods项目中的签名配置
```

### IPA导出失败
```bash
# 错误：Provisioning profile is not an "iOS Ad Hoc" profile
# 解决：使用匹配的导出方法（app-store/ad-hoc/development）
```

## 📋 验证检查清单

### 构建前检查
- [ ] Bundle ID正确配置
- [ ] 所有GitHub Secrets已设置
- [ ] 证书和Profile未过期
- [ ] Team ID正确

### 构建过程检查
- [ ] 证书导入成功（Method 3）
- [ ] Pods配置清理完成
- [ ] Flutter xcconfig配置正确
- [ ] Archive构建成功
- [ ] IPA导出成功

### 构建后验证
- [ ] IPA文件大小合理（通常20-50MB）
- [ ] 代码签名验证通过
- [ ] 可以安装到测试设备
- [ ] 应用功能正常

## 🎯 成功标志

看到以下日志表示构建成功：
```
** ARCHIVE SUCCEEDED **
** EXPORT SUCCEEDED **
=== Signed IPA Package Info ===
-rw-r--r--  1 runner  staff    27M Sep  6 11:07 github-radar-news-ios-signed.ipa
```

## 📞 需要帮助？

如果遇到问题，参考详细文档：`docs/ios-build-complete-solution.md`

或检查以下关键日志：
- 证书导入：`Method 3: PKCS#12 import with explicit format`
- Pods清理：`✓ Cleaned Pods project configuration`
- 签名配置：`Signing Identity: "Apple Distribution: ..."`
- 导出成功：`Exported Runner to: .../ipa`