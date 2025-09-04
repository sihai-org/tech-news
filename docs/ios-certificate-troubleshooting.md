# iOS 证书导入问题排查指南

本文档记录了 iOS 证书导入在 GitHub Actions 中遇到的问题和解决方案。

## 问题历程

### 问题 1: Keychain 删除错误
**错误信息**: `SecKeychainDelete: The specified keychain could not be found.`
**解决方案**: 添加错误抑制 `2>/dev/null || true`

### 问题 2: 证书数据解码错误  
**错误信息**: `SecKeychainItemImport: Unable to decode the provided data.`
**原因**: 未定义的 `DISTRIBUTION_CERT_PASSWORD` 环境变量
**解决方案**: 添加密码验证和默认空密码处理

### 问题 3: 证书格式检测错误
**错误信息**: 检测为 PEM 格式但实际是 DER 格式
**原因**: OpenSSL 命令缺少 `-inform DER` 参数
**解决方案**: 明确指定证书格式进行检测

### 问题 4: security import 参数错误
**错误信息**: `Usage: import inputfile [-k keychain] [-t type] [-f format]...`
**原因**: 参数顺序不正确
**解决方案**: 调整参数顺序为 `-k keychain -t type -f format`

### 问题 5: 不支持的格式参数
**错误信息**: 同上，但 `DER` 和 `PEM` 不在支持列表中
**原因**: security 命令不支持 DER/PEM 作为格式参数
**解决方案**: 使用正确的格式映射：
- DER → `raw`
- PEM → `openssl`
- PKCS#12 → `pkcs12`

### 问题 6: 功能未实现错误
**错误信息**: `SecKeychainItemImport: Function or operation not implemented.`
**原因**: 复杂的参数组合导致系统调用失败
**解决方案**: 采用渐进式导入策略，从简单参数开始尝试

## 最终解决方案

采用**渐进式证书导入策略**：

1. **第一次尝试**: 最简单的导入
   ```bash
   security import distribution.cert -k $KEYCHAIN_NAME -A
   ```

2. **第二次尝试**: 添加 codesign 访问权限
   ```bash
   security import distribution.cert -k $KEYCHAIN_NAME -T /usr/bin/codesign
   ```

3. **第三次尝试**: 仅指定 keychain
   ```bash
   security import distribution.cert -k $KEYCHAIN_NAME
   ```

4. **最后尝试**: 格式特定导入
   - 检测证书格式
   - 使用对应的格式参数导入

## 关键经验

1. **简化参数**: 避免一次性使用过多参数
2. **渐进式尝试**: 从简单到复杂逐步尝试
3. **格式映射**: 了解 security 命令的格式参数对应关系
4. **错误抑制**: 对预期的错误进行适当抑制
5. **详细日志**: 添加足够的调试信息帮助排查

## 支持的证书格式

| 证书格式 | OpenSSL 检测 | Security 格式参数 |
|---------|-------------|------------------|
| DER     | `-inform DER` | `raw` |
| PEM     | `-inform PEM` | `openssl` |
| PKCS#12 | `pkcs12 -noout` | `pkcs12` |

## GitHub Secrets 配置

必需的 Secrets：
- `DISTRIBUTION_CERTIFICATE_BASE64` - 证书的 Base64 编码
- `PROVISIONING_PROFILE_BASE64` - 配置文件的 Base64 编码
- `KEYCHAIN_PASSWORD` - 临时 keychain 密码
- `TEAM_ID` - Apple Team ID

可选的 Secrets：
- `DISTRIBUTION_CERT_PASSWORD` - 仅当使用 .p12 格式证书时需要

### 问题 7: 证书导入成功但无有效签名身份（最终发现）
**错误信息**: `0 valid identities found` 尽管 `1 certificate imported`
**原因**: 使用的是证书文件（.cer）而非 PKCS#12 文件，缺少私钥
**解决方案**: 需要导出包含私钥的 .p12 文件并重新编码

## 最终诊断结果

通过 v1.1.20 的详细检测发现了根本问题：

**证书类型检测**:
```bash
Certificate file type: Certificate, Version=3
Detected certificate file (not PKCS#12)
WARNING: Certificate files without private key cannot be used for code signing
```

**关键发现**：
- 证书导入成功（`1 certificate imported`）
- 但无有效签名身份（`0 valid identities found`）
- 原因：.cer 文件只包含公钥证书，缺少代码签名必需的私钥

## 版本历史

- v1.1.1: 初始修复尝试
- v1.1.2: 参数顺序修复  
- v1.1.3: 格式检测改进
- v1.1.4: 格式参数修复
- v1.1.5-v1.1.19: 渐进式导入策略和脚本优化
- v1.1.20: **最终诊断** - 发现私钥缺失问题并提供解决方案