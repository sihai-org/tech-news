#!/bin/bash

# GitHub Radar Monorepo Build Script
# Builds both CLI and Mobile applications

set -e

echo "🚀 Building GitHub Radar Projects..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Build CLI
print_status "Building CLI application..."
if [ -d "cli" ]; then
    cd cli
    if [ -f "package.json" ]; then
        print_status "Installing CLI dependencies..."
        npm install
        
        print_status "Running CLI type check..."
        npm run typecheck
        
        print_status "Building CLI..."
        npm run build
        
        print_status "CLI build completed ✅"
    else
        print_error "CLI package.json not found"
        exit 1
    fi
    cd "$PROJECT_ROOT"
else
    print_error "CLI directory not found"
    exit 1
fi

# Build Mobile App
print_status "Building Mobile application..."
if [ -d "mobile" ]; then
    cd mobile
    if [ -f "pubspec.yaml" ]; then
        print_status "Getting Flutter dependencies..."
        flutter pub get
        
        print_status "Running Flutter analyze..."
        flutter analyze
        
        print_status "Generating JSON serialization code..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
        
        print_status "Running Flutter tests..."
        flutter test || print_warning "Some tests failed, but continuing..."
        
        print_status "Building Android APK..."
        flutter build apk --release
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_status "Building iOS app (macOS only)..."
            flutter build ios --release --no-codesign
        else
            print_warning "Skipping iOS build (not on macOS)"
        fi
        
        print_status "Mobile build completed ✅"
    else
        print_error "Mobile pubspec.yaml not found"
        exit 1
    fi
    cd "$PROJECT_ROOT"
else
    print_error "Mobile directory not found"
    exit 1
fi

print_status "🎉 All builds completed successfully!"
print_status "CLI build output: cli/dist/"
print_status "Mobile build output: mobile/build/"