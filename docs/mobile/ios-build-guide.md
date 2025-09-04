# iOS App Store 打包发布完整指南

## 成功配置总结
- App版本: 1.0.9
- Build号: 40
- Bundle ID: cn.datouai.technews
- 团队ID: C43B3NC6ZG
- 签名证书: Apple Distribution: Zhe Feng (C43B3NC6ZG)

## 前置准备

### 1. 证书和配置文件

#### 本地开发
将以下文件放置在 `ios/certs/` 目录：
- **Distribution证书**: `distribution.cer` (Apple Distribution)
- **Provisioning Profile**: `TechNews_AppStore_Profile.mobileprovision` (App Store类型)
- 确保证书已导入到钥匙串
- 配置文件UUID: 84925cd8-b53a-4821-acd3-826b4185316d

#### CI/CD环境
在GitHub Secrets中配置：
- `DISTRIBUTION_CERTIFICATE_BASE64` - Distribution证书的base64编码
- `PROVISIONING_PROFILE_BASE64` - 配置文件的base64编码
- `KEYCHAIN_PASSWORD` - 临时钥匙串密码
- `TEAM_ID` - C43B3NC6ZG

### 2. 项目配置
```bash
# Bundle ID配置
ios/Runner.xcodeproj/project.pbxproj
- PRODUCT_BUNDLE_IDENTIFIER = cn.datouai.technews

# 版本配置
pubspec.yaml
- version: 1.0.9+40
```

## 构建步骤

### 1. 清理并构建应用
```bash
# 清理之前的构建
flutter clean

# 构建iOS Release版本（不签名）
flutter build ios --release --no-codesign --build-number=40
```

### 2. 创建归档结构
```bash
# 创建归档目录
rm -rf build/ios/Runner.xcarchive
mkdir -p build/ios/Runner.xcarchive/Products/Applications
cp -R build/ios/iphoneos/Runner.app build/ios/Runner.xcarchive/Products/Applications/
```

### 3. 创建归档信息文件
创建 `build/ios/Runner.xcarchive/Info.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ApplicationProperties</key>
    <dict>
        <key>ApplicationPath</key>
        <string>Applications/Runner.app</string>
        <key>Architectures</key>
        <array>
            <string>arm64</string>
        </array>
        <key>CFBundleIdentifier</key>
        <string>cn.datouai.technews</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0.9</string>
        <key>CFBundleVersion</key>
        <string>40</string>
        <key>SigningIdentity</key>
        <string>Apple Distribution: Zhe Feng (C43B3NC6ZG)</string>
        <key>Team</key>
        <string>C43B3NC6ZG</string>
    </dict>
    <key>ArchiveVersion</key>
    <integer>2</integer>
    <key>CreationDate</key>
    <date>2025-01-04T03:00:00Z</date>
    <key>Name</key>
    <string>Runner</string>
    <key>SchemeName</key>
    <string>Runner</string>
</dict>
</plist>
```

### 4. 导出选项配置
创建 `ios/ExportOptionsAppStore.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>C43B3NC6ZG</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>cn.datouai.technews</key>
        <string>84925cd8-b53a-4821-acd3-826b4185316d</string>
    </dict>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>embedOnDemandResourcesAssetPacksInBundle</key>
    <true/>
    <key>iCloudContainerEnvironment</key>
    <string>Production</string>
</dict>
</plist>
```

### 5. 导出归档
```bash
xcodebuild -exportArchive \
  -archivePath build/ios/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptionsAppStore.plist
```

### 6. 添加SwiftSupport（关键步骤）
```bash
# 解压导出的IPA
rm -rf temp && mkdir temp
unzip -q build/ios/ipa/github_radar_news.ipa -d temp

# 创建SwiftSupport目录并复制未签名的Swift库
mkdir -p temp/SwiftSupport
for lib in Core CoreAudio CoreFoundation CoreGraphics CoreImage CoreMedia \
           Darwin Dispatch Metal ObjectiveC QuartzCore XPC os simd \
           Foundation UIKit; do
  source="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.0/iphoneos/libswift${lib}.dylib"
  if [ -f "$source" ]; then
    cp "$source" "temp/SwiftSupport/"
  fi
done

# 重新打包IPA
cd temp
zip -r ../TechNews-final.ipa Payload SwiftSupport Symbols -q
cd ..

# 复制到下载目录
cp TechNews-final.ipa ~/Downloads/TechNews-v1.0.9-build40.ipa

# 清理临时文件
rm -rf temp TechNews-final.ipa
```

## 隐私清单配置

创建 `ios/Runner/PrivacyInfo.xcprivacy`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>C617.1</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategorySystemBootTime</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>35F9.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

## 常见问题及解决方案

### 1. Build Number重复
**错误**: The provided entity includes an attribute with a value that has already been used
**解决**: 每次上传都要增加Build Number (如: 1→10→20→30→40)

### 2. SwiftSupport缺失
**错误**: Invalid Swift Support. The SwiftSupport folder is missing
**解决**: 必须手动添加SwiftSupport文件夹，包含未签名的Swift dylib文件

### 3. SwiftSupport签名错误
**错误**: The file libswiftCore.dylib doesn't have the correct code signature
**解决**: SwiftSupport必须使用Xcode原始的未签名库，不能用app内的已签名库

### 4. 隐私清单缺失
**错误**: ITMS-91061: Missing privacy manifest
**解决**: 添加PrivacyInfo.xcprivacy文件声明API使用情况

### 5. 临时包创建失败
**错误**: 无法为App创建临时.itmsp软件包
**解决**: 确保IPA结构正确，Payload在根目录，SwiftSupport与Payload同级

## 加密声明
在App Store Connect提交时选择：
- **不属于上述的任意一种算法** （仅使用HTTPS标准加密）

## 完整构建脚本
```bash
#!/bin/bash
# ios-build.sh

# 设置变量
BUILD_NUMBER=40
VERSION="1.0.9"

# 1. 清理并构建
flutter clean
flutter build ios --release --no-codesign --build-number=$BUILD_NUMBER

# 2. 创建归档
rm -rf build/ios/Runner.xcarchive
mkdir -p build/ios/Runner.xcarchive/Products/Applications
cp -R build/ios/iphoneos/Runner.app build/ios/Runner.xcarchive/Products/Applications/

# 3. 导出IPA
xcodebuild -exportArchive \
  -archivePath build/ios/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptionsAppStore.plist

# 4. 添加SwiftSupport
rm -rf temp && mkdir temp
unzip -q build/ios/ipa/github_radar_news.ipa -d temp
mkdir -p temp/SwiftSupport

for lib in Core CoreAudio CoreFoundation CoreGraphics CoreImage CoreMedia \
           Darwin Dispatch Metal ObjectiveC QuartzCore XPC os simd \
           Foundation UIKit; do
  source="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.0/iphoneos/libswift${lib}.dylib"
  if [ -f "$source" ]; then
    cp "$source" "temp/SwiftSupport/"
  fi
done

cd temp
zip -r ../TechNews-v${VERSION}-build${BUILD_NUMBER}.ipa Payload SwiftSupport Symbols -q
cd ..

# 5. 复制到Downloads
cp TechNews-v${VERSION}-build${BUILD_NUMBER}.ipa ~/Downloads/

# 6. 清理
rm -rf temp TechNews-v${VERSION}-build${BUILD_NUMBER}.ipa

echo "IPA已生成: ~/Downloads/TechNews-v${VERSION}-build${BUILD_NUMBER}.ipa"
```

## 上传到App Store Connect
1. 使用Transporter app上传IPA文件
2. 等待处理完成
3. 在TestFlight中测试
4. 提交App Store审核

## 注意事项
- 每次上传前检查Build Number是否需要增加
- 确保证书和配置文件匹配
- SwiftSupport文件夹必须包含正确的未签名库
- 隐私清单必须声明所有使用的API
- 保持iOS最低版本要求为12.0