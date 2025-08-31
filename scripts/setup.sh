#!/bin/bash

# GitHub Radar Monorepo Setup Script
# Sets up development environment for both CLI and Mobile applications

set -e

echo "🔧 Setting up GitHub Radar Development Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

print_header "Checking prerequisites..."

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status "Node.js found: $NODE_VERSION"
else
    print_error "Node.js not found. Please install Node.js (>=16.x)"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_status "npm found: $NPM_VERSION"
else
    print_error "npm not found. Please install npm"
    exit 1
fi

# Check Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_status "Flutter found: $FLUTTER_VERSION"
    
    print_status "Running Flutter doctor..."
    flutter doctor
else
    print_error "Flutter not found. Please install Flutter (>=3.2.4)"
    exit 1
fi

print_header "Setting up CLI environment..."
if [ -d "cli" ]; then
    cd cli
    
    # Install dependencies
    print_status "Installing CLI dependencies..."
    npm install
    
    # Setup environment file
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            print_status "Creating .env file from template..."
            cp .env.example .env
            print_warning "Please edit cli/.env file with your actual configuration"
        else
            print_warning "No .env.example found in CLI directory"
        fi
    else
        print_status "CLI .env file already exists"
    fi
    
    # Build the project
    print_status "Building CLI..."
    npm run build
    
    cd "$PROJECT_ROOT"
    print_status "CLI setup completed ✅"
else
    print_error "CLI directory not found"
    exit 1
fi

print_header "Setting up Mobile environment..."
if [ -d "mobile" ]; then
    cd mobile
    
    # Get Flutter dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Setup environment file
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            print_status "Creating .env file from template..."
            cp .env.example .env
            print_warning "Please edit mobile/.env file with your Supabase configuration"
        else
            print_warning "No .env.example found in Mobile directory"
        fi
    else
        print_status "Mobile .env file already exists"
    fi
    
    # Generate code
    print_status "Generating JSON serialization code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    cd "$PROJECT_ROOT"
    print_status "Mobile setup completed ✅"
else
    print_error "Mobile directory not found"
    exit 1
fi

print_header "Setting up shared database..."
if [ -d "shared/database" ]; then
    print_status "Database schema found at: shared/database/schema.sql"
    print_warning "Please run the SQL schema in your Supabase project"
    print_warning "1. Go to your Supabase project dashboard"
    print_warning "2. Open SQL Editor"
    print_warning "3. Run the contents of shared/database/schema.sql"
else
    print_error "Shared database directory not found"
fi

print_header "🎉 Setup completed!"
print_status "Next steps:"
print_status "1. Configure environment variables in cli/.env and mobile/.env"
print_status "2. Set up your Supabase database using shared/database/schema.sql"
print_status "3. Start development:"
print_status "   - CLI: cd cli && npm run dev"
print_status "   - Mobile: cd mobile && flutter run"
print_status "4. Or build everything: ./scripts/build-all.sh"