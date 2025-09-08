# 环境变量映射说明

## GitHub Secrets → 工作流环境变量映射

| GitHub Secret 名称 | 工作流环境变量名称 | 用途 |
|-------------------|------------------|------|
| `DISTRIBUTION_CERTIFICATE_BASE64` | `DISTRIBUTION_CERT_BASE64` | Distribution 证书的 Base64 编码 |
| `PROVISIONING_PROFILE_BASE64` | `PROVISIONING_PROFILE_BASE64` | Provisioning Profile 的 Base64 编码 |
| `DISTRIBUTION_CERT_PASSWORD` | `DISTRIBUTION_CERT_PASSWORD` | 证书密码（可选，.cer 文件通常不需要） |
| `KEYCHAIN_PASSWORD` | `KEYCHAIN_PASSWORD` | 临时 keychain 密码 |
| `TEAM_ID` | `APPLE_TEAM_ID` | Apple Developer Team ID |

## 工作流配置示例

```yaml
env:
  DISTRIBUTION_CERT_BASE64: ${{ secrets.DISTRIBUTION_CERTIFICATE_BASE64 }}
  PROVISIONING_PROFILE_BASE64: ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
  DISTRIBUTION_CERT_PASSWORD: ${{ secrets.DISTRIBUTION_CERT_PASSWORD }}
  KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
  APPLE_TEAM_ID: ${{ secrets.TEAM_ID }}  # 注意：GitHub Secret 是 TEAM_ID，映射到 APPLE_TEAM_ID
```

## 使用说明

1. **在 GitHub 仓库设置中配置的 Secret 名称**使用左列的名称
2. **在脚本中访问的环境变量名称**使用右列的名称
3. **`TEAM_ID` → `APPLE_TEAM_ID` 的映射**是为了在脚本中更清楚地表示这是 Apple 相关的 Team ID

## 当前配置状态

基于最新的工作流配置，所有环境变量映射都是正确的，没有混用问题。