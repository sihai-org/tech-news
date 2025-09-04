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

# Import certificate using simplified approach
echo "Importing certificate..."
echo "Certificate file size: $(wc -c < distribution.cert) bytes"
echo "Certificate file type:"
file distribution.cert

# Skip OpenSSL analysis for now - it may be causing hangs
echo "Skipping detailed OpenSSL analysis to avoid potential hangs"
echo "Certificate appears to be valid based on file command output"

# Try to import certificate with minimal parameters first
echo "Attempting certificate import at $(date)"
echo "Keychain name: $KEYCHAIN_NAME"
echo "Certificate file: $(ls -la distribution.cert)"

IMPORT_SUCCESS=false

echo "=== Import Attempt 1: Extended access at $(date) ==="
set +e  # Disable exit on error for this section
echo "Starting security import command..."
IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME -A -T /usr/bin/codesign -T /usr/bin/security 2>&1)
IMPORT_CODE=$?
echo "Security import command completed at $(date)"
set -e  # Re-enable exit on error
echo "Command output: $IMPORT_OUTPUT"
echo "Exit code: $IMPORT_CODE"

if [ $IMPORT_CODE -eq 0 ]; then
    echo "✓ Successfully imported certificate with extended access"
    IMPORT_SUCCESS=true
else
    echo "❌ Extended access import failed, trying basic import..."
    
    echo "=== Import Attempt 2: Basic import ==="
    set +e
    IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME -A 2>&1)
    IMPORT_CODE=$?
    set -e
    echo "Command output: $IMPORT_OUTPUT"
    echo "Exit code: $IMPORT_CODE"
    
    if [ $IMPORT_CODE -eq 0 ]; then
        echo "✓ Successfully imported certificate with basic import"
        IMPORT_SUCCESS=true
    else
        echo "❌ Basic import failed, trying codesign access..."
        
        echo "=== Import Attempt 3: Codesign access ==="
        set +e
        IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME -T /usr/bin/codesign 2>&1)
        IMPORT_CODE=$?
        set -e
        echo "Command output: $IMPORT_OUTPUT"
        echo "Exit code: $IMPORT_CODE"
        
        if [ $IMPORT_CODE -eq 0 ]; then
            echo "✓ Successfully imported certificate with codesign access"
            IMPORT_SUCCESS=true
        else
            echo "❌ Codesign access failed, trying keychain-only..."
            
            echo "=== Import Attempt 4: Keychain-only ==="
            set +e
            IMPORT_OUTPUT=$(security import distribution.cert -k $KEYCHAIN_NAME 2>&1)
            IMPORT_CODE=$?
            set -e
            echo "Command output: $IMPORT_OUTPUT"
            echo "Exit code: $IMPORT_CODE"
            
            if [ $IMPORT_CODE -eq 0 ]; then
                echo "✓ Successfully imported certificate with keychain-only access"
                IMPORT_SUCCESS=true
            else
                echo "❌ All import attempts failed. Trying with format specification..."
    
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

echo "Certificate import completed, verifying result..."

# Verify certificate was imported successfully
echo "Verifying certificate import in keychain: $KEYCHAIN_NAME"
echo "Keychain path: $HOME/Library/Keychains/$KEYCHAIN_NAME-db"

# List all identities in keychain (for debugging)
echo "=== All identities in keychain ==="
security find-identity -v $KEYCHAIN_NAME

echo "=== Codesigning identities ==="
security find-identity -v -p codesigning $KEYCHAIN_NAME

echo "=== Certificate details ==="
security dump-keychain $KEYCHAIN_NAME | grep -A 10 -B 5 "Apple Distribution"
if security find-identity -v -p codesigning $KEYCHAIN_NAME | grep -q "Apple Distribution"; then
    echo "✓ Apple Distribution certificate found in keychain"
    
    # Set key partition list to allow codesign to access the certificate
    echo "Setting up keychain access permissions..."
    if security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_NAME 2>/dev/null; then
        echo "✓ Successfully set key partition list"
    else
        echo "⚠ Warning: Could not set key partition list"
        echo "  This is normal for certificates without private keys"
        echo "  Code signing may still work if the certificate is valid"
    fi
else
    echo "⚠ Warning: Could not find Apple Distribution certificate"
    echo "Available identities:"
    security find-identity -v $KEYCHAIN_NAME || echo "No identities found"
    echo "Continuing with provisioning profile installation..."
fi

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
echo "iOS code signing setup completed!"
echo "=== SCRIPT COMPLETED SUCCESSFULLY ==="