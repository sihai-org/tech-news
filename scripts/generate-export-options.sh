#!/bin/bash

# Generate ExportOptions.plist with environment variables
# This script is used in CI/CD to generate the export options dynamically

cat > mobile/ios/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>release-testing</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>cn.datouai.technews</key>
        <string>$PROVISIONING_PROFILE_UUID</string>
    </dict>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

echo "Generated ExportOptions.plist with Team ID: $APPLE_TEAM_ID"