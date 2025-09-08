# iOS构建故障排除指南

## 🔍 问题诊断流程

### 第一步：确定失败阶段
1. **证书导入阶段** - 看到证书相关错误
2. **构建配置阶段** - Pods或provisioning profile错误  
3. **Archive阶段** - xcodebuild archive失败
4. **IPA导出阶段** - xcodebuild exportArchive失败
5. **文件上传阶段** - GitHub Actions工件问题

## 📝 常见错误及解决方案

### 证书导入错误

#### ❌ `SecKeychainItemImport: Unknown format in import`
**原因：** 证书格式识别问题或密码错误

**解决方案：**
```bash
# 1. 检查证书是否为PKCS#12格式
openssl pkcs12 -info -in certificate.p12 -noout

# 2. 验证密码正确
# 3. 使用Method 3导入方法：
security import distribution.cert -k $KEYCHAIN_NAME -t cert -f pkcs12 -P "$CERT_PASSWORD" -A
```

#### ❌ `SecKeychainDelete: The specified keychain could not be found`
**原因：** 尝试删除不存在的keychain

**解决方案：**
```bash
# 添加错误抑制
security delete-keychain build.keychain 2>/dev/null || true
```

### Pods签名配置错误

#### ❌ `sqflite does not support provisioning profiles`
**原因：** Pods目标继承了主应用的provisioning profile设置

**解决方案：**
```bash
# 1. 不要在xcodebuild命令中使用全局PROVISIONING_PROFILE_SPECIFIER
# 2. 清理Pods项目配置：
sed -i '' '/PROVISIONING_PROFILE_SPECIFIER/d' Pods/Pods.xcodeproj/project.pbxproj
sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' Pods/Pods.xcodeproj/project.pbxproj
```

#### ❌ `[target] does not support provisioning profiles`
**原因：** 任何Pods目标都不应该有provisioning profile

**解决方案：**
- 确保只在主应用的xcconfig文件中配置签名
- 彻底清理所有Pods项目中的签名配置

### 主应用签名配置错误

#### ❌ `"Runner" requires a provisioning profile`
**原因：** 主应用缺少provisioning profile配置

**解决方案：**
```bash
# 在Flutter/Release.xcconfig中添加：
echo "CODE_SIGN_STYLE = Manual" >> Flutter/Release.xcconfig
echo "DEVELOPMENT_TEAM = $APPLE_TEAM_ID" >> Flutter/Release.xcconfig  
echo "PROVISIONING_PROFILE_SPECIFIER = $PROVISIONING_PROFILE_UUID" >> Flutter/Release.xcconfig
```

**注意：** 不要修改project.pbxproj文件，Flutter使用xcconfig系统！

### IPA导出错误

#### ❌ `Provisioning profile "XXX" is not an "iOS Ad Hoc" profile`
**原因：** 导出方法与provisioning profile类型不匹配

**解决方案：**
```xml
<!-- App Store profile使用app-store方法 -->
<key>method</key>
<string>app-store</string>

<!-- Ad Hoc profile使用ad-hoc方法 -->  
<key>method</key>
<string>ad-hoc</string>

<!-- Development profile使用development方法 -->
<key>method</key>
<string>development</string>
```

#### ❌ `The project 'Runner' is damaged and cannot be opened`
**原因：** project.pbxproj文件结构被破坏

**解决方案：**
```bash
# 1. 恢复备份文件
cp Runner.xcodeproj/project.pbxproj.backup Runner.xcodeproj/project.pbxproj

# 2. 不要向project.pbxproj文件末尾追加内容
# 3. 使用xcconfig文件而不是修改project.pbxproj
```

### GitHub Actions相关错误

#### ❌ `Artifact not found for name: ios-ipa-signed`
**原因：** IPA文件未成功生成或路径不正确

**解决方案：**
```bash
# 1. 检查IPA导出是否成功
# 2. 验证文件路径：
ls -la mobile/build/ios/ipa/
find . -name "*.ipa"

# 3. 确保文件复制到正确位置：
cp "$IPA_FILE" ../github-radar-news-ios-signed.ipa
```

#### ❌ `Invalid workflow file: YAML syntax error`
**原因：** YAML文件格式错误，通常是多行命令语法问题

**解决方案：**
```yaml
# 避免使用复杂的多行命令
# 错误示例：
sed -i '' '/pattern/a\
    new line content' file.txt

# 正确示例：
echo "new line content" >> file.txt
sed -i '' 's/old/new/g' file.txt
```

## 🔧 调试技巧

### 1. 启用详细日志
```bash
# 在关键步骤添加调试输出
echo "=== Current directory: $(pwd) ==="
echo "=== Available files: ==="
ls -la

echo "=== Environment variables: ==="
echo "APPLE_TEAM_ID: $APPLE_TEAM_ID"
echo "CERT length: ${#DISTRIBUTION_CERT_BASE64}"
```

### 2. 验证证书状态
```bash
# 检查keychain中的证书
security find-identity -v -p codesigning build.keychain
security list-keychains -d user

# 检查证书有效期
security find-certificate -a -p build.keychain | openssl x509 -text | grep -A2 "Validity"
```

### 3. 验证provisioning profile
```bash
# 解码并检查profile内容
security cms -D -i profile.mobileprovision | plutil -p -

# 检查profile的UUID和Team ID
/usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin <<< $(security cms -D -i profile.mobileprovision)
/usr/libexec/PlistBuddy -c "Print :TeamIdentifier:0" /dev/stdin <<< $(security cms -D -i profile.mobileprovision)
```

### 4. 检查项目配置
```bash
# 显示xcconfig文件内容
echo "=== Flutter/Release.xcconfig ==="
cat Flutter/Release.xcconfig

# 显示ExportOptions.plist
echo "=== ExportOptions.plist ==="
cat ExportOptions.plist

# 检查Pods清理结果
echo "Remaining PROVISIONING_PROFILE_SPECIFIER in Pods:"
grep -n "PROVISIONING_PROFILE_SPECIFIER" Pods/Pods.xcodeproj/project.pbxproj || echo "None found ✅"
```

## 📋 系统性排查清单

### 环境检查
- [ ] 所有GitHub Secrets都已正确设置
- [ ] 证书和provisioning profile未过期
- [ ] Team ID正确匹配
- [ ] Bundle ID在profile中已注册

### 配置检查  
- [ ] 使用Flutter xcconfig系统而非project.pbxproj
- [ ] Pods项目已完全清理签名配置
- [ ] ExportOptions.plist方法匹配profile类型
- [ ] 没有使用全局PROVISIONING_PROFILE_SPECIFIER参数

### 构建检查
- [ ] 证书导入成功（Method 3）
- [ ] keychain权限正确设置
- [ ] Archive构建成功
- [ ] IPA导出成功
- [ ] 文件路径正确

### 验证检查
- [ ] 生成的IPA文件存在且大小合理
- [ ] 代码签名验证通过
- [ ] GitHub Actions工件上传成功

## 🆘 求助指南

### 收集诊断信息
当需要求助时，请提供以下信息：

1. **错误信息**
   - 完整的错误日志
   - 失败的构建步骤

2. **环境信息**
   - Flutter版本
   - Xcode版本  
   - iOS最低版本要求

3. **配置信息**
   - Bundle ID
   - 证书类型（Development/Distribution）
   - Profile类型（Development/Ad Hoc/App Store）

4. **关键文件内容**
   - Flutter/Release.xcconfig
   - ExportOptions.plist
   - 相关的工作流YAML片段

### 最后手段：重新开始
如果问题过于复杂，可以考虑：

1. **重新生成证书和profile**
2. **清理所有本地配置文件**  
3. **从工作的模板项目重新开始**
4. **逐步添加配置，每步都进行测试**

---

**记住：iOS构建配置很复杂，但遵循本指南的系统性方法，大多数问题都可以快速定位和解决。**