#!/bin/bash

# Script to import Apple certificates for iOS signing in CI/CD
# This script is used in GitHub Actions to set up code signing

set -e

echo "Setting up iOS code signing..."

# Validate required environment variables
if [ -z "$DISTRIBUTION_CERT_BASE64" ]; then
    echo "Error: DISTRIBUTION_CERT_BASE64 environment variable is not set"
    exit 1
fi

if [ -z "$PROVISIONING_PROFILE_BASE64" ]; then
    echo "Error: PROVISIONING_PROFILE_BASE64 environment variable is not set"
    exit 1
fi

# Create a temporary keychain
KEYCHAIN_NAME="build.keychain"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-temp_password_$(date +%s)}"

# Delete keychain if it exists (suppress error output)
security delete-keychain $KEYCHAIN_NAME 2>/dev/null || true

# Create new keychain
echo "Creating keychain: $KEYCHAIN_NAME"
security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME
security set-keychain-settings -lut 21600 $KEYCHAIN_NAME
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME

# Make it default and add to search list
security default-keychain -s $KEYCHAIN_NAME
security list-keychains -d user -s $KEYCHAIN_NAME login.keychain

# Import distribution certificate
echo "Importing distribution certificate..."

# Decode base64 certificate
echo "$DISTRIBUTION_CERT_BASE64" | base64 --decode > distribution.cert

# Check certificate format using openssl
if openssl x509 -in distribution.cert -text -noout >/dev/null 2>&1; then
    # It's a .cer file (DER format)
    echo "Detected .cer certificate file (DER format)"
    security import distribution.cert -A -t cert -f DER -k $KEYCHAIN_NAME -T /usr/bin/codesign
elif openssl pkcs12 -in distribution.cert -noout >/dev/null 2>&1; then
    # It's a .p12 file
    echo "Detected .p12 certificate file"
    mv distribution.cert distribution.p12
    # Use empty password if DISTRIBUTION_CERT_PASSWORD is not set
    CERT_PASSWORD="${DISTRIBUTION_CERT_PASSWORD:-}"
    security import distribution.p12 -P "$CERT_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_NAME -T /usr/bin/codesign
    rm distribution.p12
else
    # Try to import as PEM format
    echo "Trying to import as PEM certificate format"
    security import distribution.cert -A -t cert -f PEM -k $KEYCHAIN_NAME -T /usr/bin/codesign
fi

rm -f distribution.cert

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