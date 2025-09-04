#!/bin/bash

# Script to import Apple certificates for iOS signing in CI/CD
# This script is used in GitHub Actions to set up code signing

# Temporarily disable exit on error for debugging
# set -e

echo "=== SCRIPT STARTED ==="
echo "Setting up iOS code signing..."
echo "Script arguments: $@"
echo "Current working directory: $(pwd)"

# Debug: Show all environment variables
echo "=== Environment Variables Debug ==="
echo "DISTRIBUTION_CERT_BASE64 length: ${#DISTRIBUTION_CERT_BASE64}"
echo "PROVISIONING_PROFILE_BASE64 length: ${#PROVISIONING_PROFILE_BASE64}"
echo "DISTRIBUTION_CERT_PASSWORD set: ${DISTRIBUTION_CERT_PASSWORD:+yes}"
echo "KEYCHAIN_PASSWORD set: ${KEYCHAIN_PASSWORD:+yes}"
echo "APPLE_TEAM_ID: ${APPLE_TEAM_ID}"

# Validate required environment variables
if [ -z "$DISTRIBUTION_CERT_BASE64" ]; then
    echo "ERROR: DISTRIBUTION_CERT_BASE64 environment variable is not set"
    echo "Available environment variables:"
    env | grep -E "(CERT|DISTRIBUTION|APPLE)" || echo "No certificate-related env vars found"
    exit 1
fi

if [ -z "$PROVISIONING_PROFILE_BASE64" ]; then
    echo "ERROR: PROVISIONING_PROFILE_BASE64 environment variable is not set" 
    echo "Available environment variables:"
    env | grep -E "(PROFILE|PROVISIONING)" || echo "No provisioning-related env vars found"
    exit 1
fi

echo "✓ Environment variables validation passed"

# Create a temporary keychain
KEYCHAIN_NAME="build.keychain"
# Use provided password or default to a consistent one
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-build_keychain_password}"

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

# Import certificate - check if this is a PKCS#12 or certificate file
echo "Importing certificate..."
echo "Certificate file size: $(wc -c < distribution.cert) bytes"
echo "Certificate file type:"
file distribution.cert

# Check if this is a PKCS#12 file (multiple methods for detection)
IS_PKCS12=false

# Method 1: Check file command output for PKCS patterns
if file distribution.cert | grep -qE "(PKCS|data)"; then
    echo "File command shows potential PKCS#12 format (or generic data)"
    
    # Method 2: Try OpenSSL PKCS#12 verification
    if openssl pkcs12 -info -in distribution.cert -noout -passin pass: 2>/dev/null; then
        echo "✓ OpenSSL confirms this is PKCS#12 format (no password)"
        IS_PKCS12=true
    elif openssl pkcs12 -info -in distribution.cert -noout -passin pass:"${DISTRIBUTION_CERT_PASSWORD:-}" 2>/dev/null; then
        echo "✓ OpenSSL confirms this is PKCS#12 format (with password)"
        IS_PKCS12=true
    elif [ -n "$DISTRIBUTION_CERT_PASSWORD" ]; then
        echo "Password provided - assuming PKCS#12 format and attempting import"
        IS_PKCS12=true
    else
        echo "Cannot verify PKCS#12 with OpenSSL, but file suggests binary format"
        # If file size increased significantly, likely PKCS#12
        if [ $(wc -c < distribution.cert) -gt 2000 ]; then
            echo "File size suggests PKCS#12 format - attempting PKCS#12 import"
            IS_PKCS12=true
        fi
    fi
fi

if [ "$IS_PKCS12" = true ]; then
    echo "=== Importing PKCS#12 certificate ==="
    CERT_PASSWORD="${DISTRIBUTION_CERT_PASSWORD:-}"
    
    if [ -z "$CERT_PASSWORD" ]; then
        echo "Attempting PKCS#12 import without password..."
        set +e
        IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME -A -T /usr/bin/codesign -T /usr/bin/security 2>&1)
        IMPORT_CODE=$?
        set -e
        echo "Import output: $IMPORT_OUTPUT"
        echo "Import exit code: $IMPORT_CODE"
    else
        echo "Attempting PKCS#12 import with password..."
        set +e
        IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME -P "$CERT_PASSWORD" -A -T /usr/bin/codesign -T /usr/bin/security 2>&1)
        IMPORT_CODE=$?
        set -e
        echo "Import output: $IMPORT_OUTPUT"
        echo "Import exit code: $IMPORT_CODE"
    fi
    
    if [ $IMPORT_CODE -eq 0 ]; then
        echo "✅ PKCS#12 certificate imported successfully"
        IMPORT_SUCCESS=true
    else
        echo "❌ PKCS#12 import failed, trying as regular certificate..."
        IMPORT_SUCCESS=false
    fi
else
    echo "=== Detected regular certificate file ==="
    IMPORT_SUCCESS=false
fi

# Fallback: try regular certificate import if PKCS#12 failed or not detected
if [ "$IMPORT_SUCCESS" = false ]; then
    echo "WARNING: Certificate files without private key cannot be used for code signing"
    echo "For GitHub Actions, you typically need a PKCS#12 (.p12) file that includes the private key"
    
    echo "Attempting regular certificate import at $(date)"
    set +e
    IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME -A -T /usr/bin/codesign -T /usr/bin/security 2>&1)
    IMPORT_CODE=$?
    set -e
    echo "Import output: $IMPORT_OUTPUT"
    echo "Import exit code: $IMPORT_CODE"
    
    if [ $IMPORT_CODE -eq 0 ]; then
        echo "✅ Certificate imported (but likely missing private key)"
        IMPORT_SUCCESS=true
    else
        echo "❌ Certificate import failed"
        echo ""
        echo "IMPORTANT: This appears to be neither a valid PKCS#12 nor certificate file"
        echo "Please verify the certificate file format and try again"
    fi
    
    echo ""
    echo "IMPORTANT: If this build fails with 'No valid code signing certificates'"
    echo "you need to export your certificate from Keychain Access as a .p12 file"
    echo "that includes the private key, then encode that .p12 file to base64."
fi

rm -f distribution.cert

echo "Certificate import completed"

# Set up keychain permissions for code signing
echo "Setting up keychain permissions for code signing..."
security set-key-partition-list -S apple-tool:,apple:,codesign: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME 2>/dev/null || echo "Key partition list setup completed with warnings"

echo "Certificate setup completed, proceeding to provisioning profile..."

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

echo "=== FINAL STATUS ==="
if [ "$IMPORT_SUCCESS" = true ]; then
    echo "✅ Certificate import: SUCCESS"
else
    echo "❌ Certificate import: FAILED"
fi
echo "🔑 Keychain created: build.keychain"
echo "📱 Provisioning profile installed"

# Check for available code signing identities
echo "=== Code Signing Identity Check ==="
echo "Checking for code signing identities in keychain..."
security find-identity -v -p codesigning $KEYCHAIN_NAME 2>/dev/null || echo "Could not list code signing identities"

echo "Checking all identities in keychain..."
security find-identity -v $KEYCHAIN_NAME 2>/dev/null || echo "Could not list identities"

# Additional check for certificates
echo "Checking certificates in keychain..."
security find-certificate -a $KEYCHAIN_NAME 2>/dev/null | head -10 || echo "Could not list certificates"

echo "iOS code signing setup completed!"
echo "=== SCRIPT COMPLETED SUCCESSFULLY ==="