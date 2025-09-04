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

# Import certificate using simplified approach
echo "Importing certificate..."

# Try to import certificate with minimal parameters first
if security import distribution.cert -k $KEYCHAIN_NAME -A; then
    echo "Successfully imported certificate with basic import"
elif security import distribution.cert -k $KEYCHAIN_NAME -T /usr/bin/codesign; then
    echo "Successfully imported certificate with codesign access"
elif security import distribution.cert -k $KEYCHAIN_NAME; then
    echo "Successfully imported certificate with keychain-only access"
else
    echo "All import attempts failed. Trying with format specification..."
    
    # Check certificate format and try format-specific import
    if openssl x509 -in distribution.cert -text -noout -inform DER >/dev/null 2>&1; then
        echo "Detected DER format certificate - trying with explicit format"
        if security import distribution.cert -k $KEYCHAIN_NAME -t cert -f raw -A; then
            echo "Successfully imported DER certificate with raw format"
        else
            echo "Failed to import DER certificate"
            exit 1
        fi
    elif openssl x509 -in distribution.cert -text -noout -inform PEM >/dev/null 2>&1; then
        echo "Detected PEM format certificate - trying with explicit format"
        if security import distribution.cert -k $KEYCHAIN_NAME -t cert -f openssl -A; then
            echo "Successfully imported PEM certificate with openssl format"
        else
            echo "Failed to import PEM certificate"
            exit 1
        fi
    else
        echo "Error: Cannot determine certificate format or import failed"
        echo "Certificate file info:"
        file distribution.cert 2>/dev/null || echo "file command not available"
        echo "Certificate file size: $(wc -c < distribution.cert) bytes"
        exit 1
    fi
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