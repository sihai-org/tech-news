# iOS Code Signing Setup Guide

This guide explains how to set up iOS code signing for the GitHub Actions workflow.

## Prerequisites

- Apple Developer Program paid account ($99/year)
- Access to Apple Developer Portal
- macOS with Xcode installed (for exporting certificates)

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository (Settings → Secrets and variables → Actions → Environment: mobile-env):

### 1. `IOS_DISTRIBUTION_CERT_BASE64`
Your Apple Distribution certificate in base64 format.

**How to export:**
1. Open Keychain Access on macOS
2. Find your "Apple Distribution: Your Name (Team ID)" certificate
3. Right-click → Export
4. Save as .p12 file with a password
5. Convert to base64:
   ```bash
   base64 -i distribution.p12 -o distribution_base64.txt
   ```
6. Copy the content of distribution_base64.txt

### 2. `IOS_DISTRIBUTION_CERT_PASSWORD`
The password you set when exporting the .p12 certificate.

### 3. `IOS_PROVISIONING_PROFILE_BASE64`
Your provisioning profile in base64 format.

**How to export:**
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to Certificates, Identifiers & Profiles → Profiles
3. Create or download an **Ad Hoc** or **App Store** provisioning profile for `cn.datouai.technews`
4. Convert to base64:
   ```bash
   base64 -i YourProfile.mobileprovision -o profile_base64.txt
   ```
5. Copy the content of profile_base64.txt

### 4. `APPLE_TEAM_ID`
Your 10-character Team ID.

**How to find:**
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Click on your account name (top right)
3. Look for "Team ID" in the membership details

## Creating a Provisioning Profile

1. **Create App ID:**
   - Go to Identifiers in Apple Developer Portal
   - Click "+" to register a new App ID
   - Select "App IDs" → Continue
   - Select "App" → Continue
   - Bundle ID: `cn.datouai.technews`
   - Description: "GitHub Radar News"
   - Capabilities: Select what your app needs (at minimum, no special capabilities needed)

2. **Create Provisioning Profile:**
   - Go to Profiles
   - Click "+" to create new profile
   - Select "Ad Hoc" (for testing) or "App Store" (for production)
   - Select your App ID: `cn.datouai.technews`
   - Select your Distribution certificate
   - Name: "GitHub Radar News Ad Hoc" or "GitHub Radar News App Store"
   - Download the profile

## Updating ExportOptions.plist

Edit `mobile/ios/ExportOptions.plist` and update:
- `teamID`: Your Team ID
- `provisioningProfiles`: Update the profile name to match your downloaded profile

## Testing Locally

Before pushing to GitHub Actions, test locally:

```bash
cd mobile
flutter build ios --release
```

## Troubleshooting

### "No signing certificate" error
- Ensure your certificate is properly imported in GitHub Secrets
- Check that the certificate hasn't expired

### "No provisioning profile" error
- Verify the Bundle ID matches exactly: `cn.datouai.technews`
- Ensure the profile includes your distribution certificate
- Check that the profile hasn't expired

### "Team ID not found" error
- Verify your Team ID is correctly set in the secret
- Ensure it's exactly 10 characters (no spaces)

## Security Notes

- Never commit certificates or profiles to the repository
- Use GitHub Secrets for all sensitive data
- Rotate certificates before they expire (typically yearly)
- Keep your certificate passwords secure