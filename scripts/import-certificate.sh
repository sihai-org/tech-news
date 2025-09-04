#!/bin/bash

# Script to import Apple certificates for iOS signing in CI/CD
# This script is used in GitHub Actions to set up code signing

set -e

echo "Setting up iOS code signing..."

# Create a temporary keychain
KEYCHAIN_NAME="build.keychain"
KEYCHAIN_PASSWORD="temp_password_$(date +%s)"

# Delete keychain if it exists
security delete-keychain $KEYCHAIN_NAME || true

# Create new keychain
security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME
security set-keychain-settings -lut 21600 $KEYCHAIN_NAME
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME

# Make it default and add to search list
security default-keychain -s $KEYCHAIN_NAME
security list-keychains -d user -s $KEYCHAIN_NAME login.keychain

# Import distribution certificate
echo "Importing distribution certificate..."
echo "$DISTRIBUTION_CERT_BASE64" | base64 --decode > distribution.cer

# Check if it's a .cer or .p12 file
if file distribution.cer | grep -q "certificate"; then
    # It's a .cer file
    echo "Detected .cer certificate file"
    security import distribution.cer -A -t cert -f DER -k $KEYCHAIN_NAME
else
    # Assume it's a .p12 file
    echo "Detected .p12 certificate file"
    mv distribution.cer distribution.p12
    security import distribution.p12 -P "$DISTRIBUTION_CERT_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_NAME
    rm distribution.p12
fi

rm -f distribution.cer

# Set key partition list to allow codesign to access the certificate
security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME

# Install provisioning profile
echo "Installing provisioning profile..."
PROVISION_PROFILE_PATH="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$PROVISION_PROFILE_PATH"

echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > profile.mobileprovision

# Get UUID from profile
PROFILE_UUID=$(/usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin <<< $(security cms -D -i profile.mobileprovision))
echo "Provisioning Profile UUID: $PROFILE_UUID"

# Copy profile to proper location
cp profile.mobileprovision "$PROVISION_PROFILE_PATH/$PROFILE_UUID.mobileprovision"
rm profile.mobileprovision

echo "iOS code signing setup completed!"