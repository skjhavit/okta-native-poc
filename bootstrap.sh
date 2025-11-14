#!/bin/bash

###############################################################################
# Bootstrap Script - Initialize React Native Project
###############################################################################
#
# This script properly initializes the React Native project with all
# required Xcode project files, then applies the Okta configuration.
#
# Usage: ./bootstrap.sh
#
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_header "React Native Project Bootstrap"

print_info "This script will initialize the React Native project with Xcode files"
print_info "and preserve your Okta configuration."
echo ""

###############################################################################
# Check if already initialized
###############################################################################

if [ -d "ios/OktaPOC.xcodeproj" ]; then
    print_success "Xcode project already exists!"
    print_info "You can skip bootstrap and run: ./setup.sh"
    exit 0
fi

###############################################################################
# Check prerequisites
###############################################################################

print_header "Checking Prerequisites"

if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    print_info "Install from: https://nodejs.org/"
    exit 1
fi
print_success "Node.js: $(node --version)"

if ! command -v npm &> /dev/null; then
    print_error "npm is not installed"
    exit 1
fi
print_success "npm: $(npm --version)"

if ! command -v npx &> /dev/null; then
    print_error "npx is not installed"
    exit 1
fi
print_success "npx is available"

###############################################################################
# Backup current files
###############################################################################

print_header "Backing Up Configuration Files"

BACKUP_DIR="/tmp/okta-config-backup-$$"
mkdir -p "$BACKUP_DIR"

# Backup our custom files
print_info "Backing up custom files..."
cp okta.config.js "$BACKUP_DIR/" 2>/dev/null || true
cp ios/OktaPOC/Info.plist "$BACKUP_DIR/" 2>/dev/null || true
cp ios/Podfile "$BACKUP_DIR/" 2>/dev/null || true
cp src/screens/*.js "$BACKUP_DIR/" 2>/dev/null || true
cp src/navigation/*.js "$BACKUP_DIR/" 2>/dev/null || true
cp App.js "$BACKUP_DIR/" 2>/dev/null || true

print_success "Configuration files backed up to $BACKUP_DIR/"

###############################################################################
# Initialize React Native project in temp directory
###############################################################################

print_header "Initializing React Native Project"

print_info "Creating temporary React Native project..."
print_info "This may take a few minutes..."

TEMP_PROJECT="TempRNProject"

# Remove temp project if it exists
rm -rf "$TEMP_PROJECT"

# Create new React Native project in temp directory
npx @react-native-community/cli@latest init "$TEMP_PROJECT" --skip-install

print_success "Temporary project created"

###############################################################################
# Copy Xcode project files
###############################################################################

print_header "Copying Xcode Project Files"

print_info "Copying Xcode project structure..."

# Copy the entire .xcodeproj directory
if [ -d "$TEMP_PROJECT/ios/$TEMP_PROJECT.xcodeproj" ]; then
    cp -r "$TEMP_PROJECT/ios/$TEMP_PROJECT.xcodeproj" ios/OktaPOC.xcodeproj
    print_success "Copied .xcodeproj"
fi

# Copy xcworkspace
if [ -d "$TEMP_PROJECT/ios/$TEMP_PROJECT.xcworkspace" ]; then
    cp -r "$TEMP_PROJECT/ios/$TEMP_PROJECT.xcworkspace" ios/OktaPOC.xcworkspace
    print_success "Copied .xcworkspace"
fi

# Update project name in Xcode project files
print_info "Updating project references..."

# Replace temp project name with OktaPOC in .xcodeproj
if [ -f "ios/OktaPOC.xcodeproj/project.pbxproj" ]; then
    # macOS compatible sed (works on both macOS and Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/$TEMP_PROJECT/OktaPOC/g" ios/OktaPOC.xcodeproj/project.pbxproj
    else
        sed -i "s/$TEMP_PROJECT/OktaPOC/g" ios/OktaPOC.xcodeproj/project.pbxproj
    fi
    print_success "Updated project references"
fi

###############################################################################
# Restore custom files
###############################################################################

print_header "Restoring Okta Configuration"

print_info "Restoring custom files..."

# Restore backed up files
cp "$BACKUP_DIR/okta.config.js" ./ 2>/dev/null || true
cp "$BACKUP_DIR/Info.plist" ios/OktaPOC/ 2>/dev/null || true
cp "$BACKUP_DIR/Podfile" ios/ 2>/dev/null || true
cp "$BACKUP_DIR"/*.js src/screens/ 2>/dev/null || true
cp "$BACKUP_DIR"/AppNavigator.js src/navigation/ 2>/dev/null || true
cp "$BACKUP_DIR/App.js" ./ 2>/dev/null || true

print_success "Configuration files restored"

###############################################################################
# Cleanup
###############################################################################

print_header "Cleaning Up"

print_info "Removing temporary files..."
rm -rf "$TEMP_PROJECT"
print_success "Temporary project removed"

print_info "Backup files cleaned up"
rm -rf "$BACKUP_DIR"

###############################################################################
# Success
###############################################################################

print_header "Bootstrap Complete! 🎉"

echo -e "${GREEN}✓ Xcode project files created${NC}"
echo -e "${GREEN}✓ Okta configuration preserved${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "  1. Run the setup script:"
echo "     ${YELLOW}./setup.sh${NC}"
echo ""
echo "  2. Then run the app:"
echo "     ${YELLOW}./run.sh${NC}"
echo ""
print_success "Ready to continue!"
echo ""
