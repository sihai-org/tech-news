# GitHub Secrets 配置指南

## Base64文件已生成
- `distribution_cert.base64` - Distribution证书的base64编码
- `provisioning_profile.base64` - 配置文件的base64编码

## 配置GitHub Secrets

### 1. 进入GitHub仓库设置
1. 打开 GitHub 仓库页面
2. 点击 Settings → Secrets and variables → Actions
3. 点击 "New repository secret"

### 2. 添加以下Secrets

#### DISTRIBUTION_CERTIFICATE_BASE64
- Name: `DISTRIBUTION_CERTIFICATE_BASE64`
- Value: 复制 `distribution_cert.base64` 文件的全部内容

#### PROVISIONING_PROFILE_BASE64  
- Name: `PROVISIONING_PROFILE_BASE64`
- Value: 复制 `provisioning_profile.base64` 文件的全部内容

#### 其他必要的Secrets
- `KEYCHAIN_PASSWORD`: 任意密码（CI环境临时钥匙串密码）
- `TEAM_ID`: C43B3NC6ZG

#### 可选的Secrets
- `DISTRIBUTION_CERT_PASSWORD`: 证书密码（仅当使用.p12格式证书时需要，.cer格式证书无需此项）

## 在GitHub Actions中使用

```yaml
- name: Install Apple Certificate
  env:
    DISTRIBUTION_CERTIFICATE_BASE64: ${{ secrets.DISTRIBUTION_CERTIFICATE_BASE64 }}
    KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
  run: |
    # 创建临时钥匙串
    security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security set-keychain-settings -lut 21600 build.keychain
    
    # 导入证书
    echo "$DISTRIBUTION_CERTIFICATE_BASE64" | base64 --decode > distribution.cer
    security import distribution.cer -k build.keychain -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" build.keychain

- name: Install Provisioning Profile
  env:
    PROVISIONING_PROFILE_BASE64: ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
  run: |
    # 解码配置文件
    echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > profile.mobileprovision
    
    # 获取UUID
    PROFILE_UUID=$(security cms -D -i profile.mobileprovision | grep -A1 "UUID" | grep -o "[0-9a-f\-]*" | tail -1)
    
    # 安装配置文件
    mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_UUID.mobileprovision
```

## 获取base64内容的命令
```bash
# 查看证书base64内容（用于复制到GitHub Secrets）
cat ios/certs/distribution_cert.base64

# 查看配置文件base64内容（用于复制到GitHub Secrets）
cat ios/certs/provisioning_profile.base64
```

## 安全注意事项
1. **不要提交base64文件到Git**
2. base64文件仅用于配置GitHub Secrets
3. 配置完成后可以删除本地的base64文件
4. 定期更新证书和配置文件

## 清理命令
配置完GitHub Secrets后，删除base64文件：
```bash
rm ios/certs/*.base64
```