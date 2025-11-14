#!/bin/bash

###############################################################################
# Okta React Native iOS POC - Automated Setup Script
###############################################################################
#
# This script automates the entire setup process:
# 1. Checks prerequisites
# 2. Installs npm dependencies
# 3. Installs iOS dependencies (CocoaPods)
# 4. Verifies configuration
# 5. Prepares the app for running
#
# Usage: ./setup.sh
#
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Step 1: Check Prerequisites
###############################################################################

###############################################################################
# Check if project is initialized
###############################################################################

if [ ! -d "ios/OktaPOC.xcodeproj" ]; then
    print_error "Xcode project not found!"
    echo ""
    print_info "The project needs to be initialized first."
    print_info "Run the bootstrap script to create the Xcode project:"
    echo ""
    echo -e "  ${YELLOW}./bootstrap.sh${NC}"
    echo ""
    print_info "Then run this setup script again."
    exit 1
fi

###############################################################################
# Step 1: Check Prerequisites
###############################################################################

print_header "Step 1: Checking Prerequisites"

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    print_success "Node.js is installed: $NODE_VERSION"

    # Check if Node version is 18+
    NODE_MAJOR=$(node --version | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        print_warning "Node.js version should be 18 or higher (current: $NODE_VERSION)"
        print_info "Please upgrade Node.js: https://nodejs.org/"
    fi
else
    print_error "Node.js is not installed"
    print_info "Install from: https://nodejs.org/"
    exit 1
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    print_success "npm is installed: $NPM_VERSION"
else
    print_error "npm is not installed"
    exit 1
fi

# Check CocoaPods
if command_exists pod; then
    POD_VERSION=$(pod --version)
    print_success "CocoaPods is installed: $POD_VERSION"
else
    print_error "CocoaPods is not installed"
    print_info "Install with: sudo gem install cocoapods"
    exit 1
fi

# Check Xcode (on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command_exists xcodebuild; then
        XCODE_VERSION=$(xcodebuild -version 2>&1 | head -n 1)
        if echo "$XCODE_VERSION" | grep -q "xcode-select: error"; then
            print_error "Xcode path is not set correctly"
            print_info "Current path points to Command Line Tools instead of Xcode.app"
            print_info "Fix with: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
            exit 1
        fi
        print_success "$XCODE_VERSION is installed"
    else
        print_error "Xcode is not installed"
        print_info "Install from Mac App Store"
        exit 1
    fi

    # Check for Xcode Command Line Tools
    if xcode-select -p &> /dev/null; then
        XCODE_PATH=$(xcode-select -p)
        if [[ "$XCODE_PATH" == *"CommandLineTools"* ]]; then
            print_error "Xcode command line tools path is incorrect"
            print_info "Current path: $XCODE_PATH"
            print_info "Fix with: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
            exit 1
        fi
        print_success "Xcode Command Line Tools are installed"
    else
        print_error "Xcode Command Line Tools are not installed"
        print_info "Install with: xcode-select --install"
        exit 1
    fi
else
    print_warning "This script is designed for macOS. Current OS: $OSTYPE"
fi

# Check Watchman (optional but recommended)
if command_exists watchman; then
    WATCHMAN_VERSION=$(watchman --version)
    print_success "Watchman is installed: $WATCHMAN_VERSION"
else
    print_warning "Watchman is not installed (optional but recommended)"
    print_info "Install with: brew install watchman"
fi

###############################################################################
# Step 2: Verify Configuration
###############################################################################

print_header "Step 2: Verifying Configuration"

# Check okta.config.js
if [ -f "okta.config.js" ]; then
    print_success "okta.config.js found"

    # Check if placeholders are still present
    if grep -q "{{OKTA_DOMAIN}}" okta.config.js; then
        print_error "okta.config.js still contains placeholders"
        print_info "Configuration has been updated with Cargill Okta settings"
    else
        print_success "okta.config.js has been configured"
    fi
else
    print_error "okta.config.js not found"
    exit 1
fi

# Check Info.plist
if [ -f "ios/OktaPOC/Info.plist" ]; then
    print_success "Info.plist found"

    # Check if placeholders are still present
    if grep -q "{{APP_SCHEME}}" ios/OktaPOC/Info.plist; then
        print_error "Info.plist still contains placeholders"
        print_info "Configuration has been updated with com.cargill.oktapoc"
    else
        print_success "Info.plist has been configured"
    fi
else
    print_error "ios/OktaPOC/Info.plist not found"
    exit 1
fi

###############################################################################
# Step 3: Clean Previous Installations (if any)
###############################################################################

print_header "Step 3: Cleaning Previous Installations"

# Clean node_modules if exists
if [ -d "node_modules" ]; then
    print_info "Removing old node_modules..."
    rm -rf node_modules
    print_success "Cleaned node_modules"
fi

# Clean package-lock.json if exists
if [ -f "package-lock.json" ]; then
    print_info "Removing old package-lock.json..."
    rm -f package-lock.json
    print_success "Cleaned package-lock.json"
fi

# Clean iOS Pods if exists
if [ -d "ios/Pods" ]; then
    print_info "Removing old Pods..."
    rm -rf ios/Pods
    rm -f ios/Podfile.lock
    print_success "Cleaned Pods"
fi

# Clean iOS build if exists
if [ -d "ios/build" ]; then
    print_info "Removing old iOS build..."
    rm -rf ios/build
    print_success "Cleaned iOS build"
fi

# Clean Watchman (if installed)
if command_exists watchman; then
    print_info "Clearing Watchman cache..."
    watchman watch-del-all 2>/dev/null || true
    print_success "Cleared Watchman cache"
fi

# Clean Metro cache
print_info "Clearing Metro cache..."
rm -rf $TMPDIR/react-* 2>/dev/null || true
rm -rf $TMPDIR/metro-* 2>/dev/null || true
print_success "Cleared Metro cache"

###############################################################################
# Step 4: Install npm Dependencies
###############################################################################

print_header "Step 4: Installing npm Dependencies"

print_info "Running npm install..."
print_info "This may take a few minutes..."

if npm install; then
    print_success "npm dependencies installed successfully"
else
    print_error "npm install failed"
    exit 1
fi

###############################################################################
# Step 5: Install iOS Dependencies (CocoaPods)
###############################################################################

print_header "Step 5: Installing iOS Dependencies"

print_info "Updating CocoaPods repo..."
cd ios

# Update CocoaPods repo
if pod repo update; then
    print_success "CocoaPods repo updated"
else
    print_warning "CocoaPods repo update had warnings (continuing...)"
fi

print_info "Running pod install..."
print_info "This may take a few minutes..."

if pod install; then
    print_success "iOS dependencies installed successfully"
else
    print_error "pod install failed"
    exit 1
fi

cd ..

###############################################################################
# Step 6: Verify Installation
###############################################################################

print_header "Step 6: Verifying Installation"

# Check node_modules
if [ -d "node_modules" ]; then
    print_success "node_modules directory exists"
else
    print_error "node_modules directory not found"
    exit 1
fi

# Check iOS Pods
if [ -d "ios/Pods" ]; then
    print_success "iOS Pods directory exists"
else
    print_error "iOS Pods directory not found"
    exit 1
fi

# Check if Okta SDK is installed
if [ -d "node_modules/@okta/okta-react-native" ]; then
    print_success "Okta React Native SDK installed"
else
    print_error "Okta React Native SDK not found"
    exit 1
fi

# Check if React Navigation is installed
if [ -d "node_modules/@react-navigation/native" ]; then
    print_success "React Navigation installed"
else
    print_error "React Navigation not found"
    exit 1
fi

###############################################################################
# Step 7: Display Configuration Summary
###############################################################################

print_header "Configuration Summary"

echo -e "${BLUE}Okta Configuration:${NC}"
echo "  Issuer: https://login-qa-customer.cargill.com/oauth2/auszzmfs36uUBqxYU0h7"
echo "  Client ID: 0oa2jt1ncajFZjObu0h8"
echo "  Redirect URI: com.cargill.oktapoc:/callback"
echo ""
echo -e "${BLUE}iOS Configuration:${NC}"
echo "  App Scheme: com.cargill.oktapoc"
echo "  Bundle ID: Should be set in Xcode"
echo ""

###############################################################################
# Setup Complete
###############################################################################

print_header "Setup Complete! 🎉"

echo -e "${GREEN}✓ All dependencies installed successfully${NC}"
echo -e "${GREEN}✓ Configuration verified${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Ensure your Okta application has the following settings:${NC}"
echo "  1. Application Type: Native Application"
echo "  2. Grant Types: Authorization Code, Refresh Token"
echo "  3. Sign-in redirect URI: ${GREEN}com.cargill.oktapoc:/callback${NC}"
echo "  4. Sign-out redirect URI: ${GREEN}com.cargill.oktapoc:/callback${NC}"
echo ""
echo -e "${BLUE}To run the app:${NC}"
echo ""
echo "  ${GREEN}Option 1: iOS Simulator${NC}"
echo "    Terminal 1: ${YELLOW}npm start${NC}"
echo "    Terminal 2: ${YELLOW}npm run ios${NC}"
echo ""
echo "  ${GREEN}Option 2: Use the run script${NC}"
echo "    ${YELLOW}./run.sh${NC}"
echo ""
echo "  ${GREEN}Option 3: Physical iPhone${NC}"
echo "    ${YELLOW}open ios/OktaPOC.xcworkspace${NC}"
echo "    Then run from Xcode"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo "  README.md - Complete guide"
echo "  GETTING_STARTED.md - Beginner's guide"
echo "  QUICKSTART.md - Quick reference"
echo "  TROUBLESHOOTING.md - Common issues"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""
