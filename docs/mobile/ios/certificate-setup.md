# iOS 证书和配置文件

## 重要说明
证书和配置文件包含敏感信息，**不应该提交到Git仓库**。

## 所需文件

### 本地开发
请将以下文件放置在此目录：

1. **distribution.cer** - Apple Distribution证书
   - 用于App Store发布的分发证书
   - 签名标识: Apple Distribution: Zhe Feng (C43B3NC6ZG)
   
2. **TechNews_AppStore_Profile.mobileprovision** - 配置文件
   - Bundle ID: cn.datouai.technews
   - Team ID: C43B3NC6ZG
   - Profile UUID: 84925cd8-b53a-4821-acd3-826b4185316d

### CI/CD 配置
证书已配置在GitHub Secrets中：
- `DISTRIBUTION_CERTIFICATE_BASE64` - Distribution证书的base64编码
- `PROVISIONING_PROFILE_BASE64` - 配置文件的base64编码
- `KEYCHAIN_PASSWORD` - 临时钥匙串密码
- `TEAM_ID` - C43B3NC6ZG

## 获取方式
1. 从Apple Developer Portal下载
2. 或从项目管理员处获取
3. 保存到本目录但不要提交到Git

## 转换为base64（用于CI/CD）
```bash
# 转换证书
base64 -i distribution.cer -o distribution_cert.base64

# 转换配置文件
base64 -i TechNews_AppStore_Profile.mobileprovision -o provisioning_profile.base64
```

## 证书安装
```bash
# 导入证书到钥匙串
security import distribution.cer -k ~/Library/Keychains/login.keychain-db

# 安装配置文件
cp TechNews_AppStore_Profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
```

## 证书信息
- 签名标识: Apple Distribution: Zhe Feng (C43B3NC6ZG)
- 团队ID: C43B3NC6ZG

## 注意事项
- 证书有效期请定期检查
- 配置文件过期前需要更新
- 不同环境（开发/发布）需要不同证书