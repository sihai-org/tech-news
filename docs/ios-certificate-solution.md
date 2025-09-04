# iOS 代码签名问题解决方案

## 问题总结

通过 v1.1.20 的测试，我们已经确认了问题的根本原因：

**当前状态**：
- ✅ 证书导入脚本工作正常
- ✅ 环境变量配置正确
- ❌ **缺少私钥** - 当前使用的是纯证书文件，无法用于代码签名

**错误信息**：
```
Certificate file type: Certificate, Version=3
Detected certificate file (not PKCS#12)
WARNING: Certificate files without private key cannot be used for code signing
Available signing identities in build.keychain: 0 valid identities found
```

## 解决方案

### 方法一：导出 PKCS#12 文件（推荐）

您需要从 Keychain Access（钥匙串访问）中导出包含私钥的 .p12 文件：

#### 步骤：
1. **打开钥匙串访问**（Keychain Access）
2. **找到您的 Distribution 证书**：
   - 在"登录"钥匙串中查看"证书"类别
   - 找到类似"Apple Distribution: Your Name (Team ID)"的证书
3. **导出 .p12 文件**：
   - 右键点击证书 → 导出
   - 文件格式选择"个人信息交换(.p12)"
   - 设置一个密码（记住这个密码）
   - 保存为 `distribution.p12`

4. **转换为 Base64**：
   ```bash
   base64 -i distribution.p12 -o distribution.p12.base64
   ```

5. **更新 GitHub Secrets**：
   - `DISTRIBUTION_CERTIFICATE_BASE64`: 使用 `distribution.p12.base64` 的内容
   - `DISTRIBUTION_CERT_PASSWORD`: 设置为步骤3中的密码

### 方法二：重新生成完整证书

如果您没有包含私钥的证书，需要重新生成：

1. **在 Apple Developer Portal**：
   - 撤销现有的 Distribution Certificate
   - 创建新的 Distribution Certificate
   - 下载 .cer 文件

2. **在 Mac 上安装证书**：
   - 双击 .cer 文件安装到钥匙串
   - 按照方法一的步骤导出 .p12 文件

## 验证方案

更新证书后，工作流应该显示：
```bash
Certificate file type: data  # 或 PKCS data
Detected PKCS#12 format - importing with password
✓ Certificate imported successfully
Available signing identities: 1 valid identities found
```

## 技术说明

**为什么会出现这个问题？**
- 证书文件（.cer）只包含公钥，用于验证签名
- 代码签名需要私钥来创建签名
- PKCS#12 文件（.p12）包含证书和私钥，是代码签名的完整解决方案

**环境变量映射**：
```yaml
GitHub Secret → 环境变量
DISTRIBUTION_CERTIFICATE_BASE64 → DISTRIBUTION_CERT_BASE64
DISTRIBUTION_CERT_PASSWORD → DISTRIBUTION_CERT_PASSWORD  # 新增
KEYCHAIN_PASSWORD → KEYCHAIN_PASSWORD
TEAM_ID → APPLE_TEAM_ID
```

## 下一步

请选择方法一或方法二来获取包含私钥的 PKCS#12 证书文件，然后：

1. 更新 `DISTRIBUTION_CERTIFICATE_BASE64` secret 为 .p12 文件的 base64 编码
2. 添加 `DISTRIBUTION_CERT_PASSWORD` secret（如果设置了密码）
3. 重新触发构建测试

证书问题解决后，iOS IPA 生成应该能够成功完成。