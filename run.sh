#!/bin/bash

###############################################################################
# Okta React Native iOS POC - Run Script
###############################################################################
#
# This script runs the app in development mode:
# 1. Starts Metro bundler in the background
# 2. Waits for Metro to be ready
# 3. Launches the app on iOS simulator
#
# Usage: ./run.sh
#
# To stop Metro: Press Ctrl+C
#
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Cleanup function
cleanup() {
    echo ""
    print_info "Stopping Metro bundler..."
    if [ ! -z "$METRO_PID" ]; then
        kill $METRO_PID 2>/dev/null || true
    fi
    # Kill any remaining Metro processes
    pkill -f "react-native start" 2>/dev/null || true
    print_success "Metro stopped"
    exit 0
}

# Set up trap to catch Ctrl+C
trap cleanup INT TERM

print_header "Okta React Native iOS POC"

###############################################################################
# Check if dependencies are installed
###############################################################################

if [ ! -d "node_modules" ]; then
    print_error "Dependencies not installed"
    print_info "Run: ./setup.sh"
    exit 1
fi

if [ ! -d "ios/Pods" ]; then
    print_error "iOS dependencies not installed"
    print_info "Run: ./setup.sh"
    exit 1
fi

###############################################################################
# Check for running Metro instances
###############################################################################

print_info "Checking for running Metro instances..."

if pgrep -f "react-native start" > /dev/null; then
    print_info "Metro bundler is already running"
    print_info "Killing existing instance..."
    pkill -f "react-native start"
    sleep 2
    print_success "Existing Metro instance stopped"
fi

###############################################################################
# Start Metro Bundler
###############################################################################

print_header "Starting Metro Bundler"

print_info "Starting Metro in the background..."

# Start Metro and capture its PID
npm start &
METRO_PID=$!

print_success "Metro started (PID: $METRO_PID)"
print_info "Waiting for Metro to be ready..."

# Wait for Metro to be ready (check for port 8081)
MAX_WAIT=60
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if nc -z localhost 8081 2>/dev/null; then
        print_success "Metro is ready!"
        break
    fi
    sleep 1
    WAITED=$((WAITED + 1))
    if [ $((WAITED % 5)) -eq 0 ]; then
        print_info "Still waiting... (${WAITED}s)"
    fi
done

if [ $WAITED -eq $MAX_WAIT ]; then
    print_error "Metro failed to start within ${MAX_WAIT} seconds"
    cleanup
    exit 1
fi

sleep 2  # Give Metro a moment to fully initialize

###############################################################################
# Launch iOS App
###############################################################################

print_header "Launching iOS App"

print_info "Building and launching on iOS Simulator..."
print_info "This may take a few minutes on first run..."

# Run the iOS app
if npm run ios; then
    print_success "App launched successfully!"
else
    print_error "Failed to launch app"
    print_info "Check the error messages above"
    cleanup
    exit 1
fi

###############################################################################
# Keep Metro Running
###############################################################################

print_header "App is Running"

echo -e "${GREEN}✓ App is running on iOS Simulator${NC}"
echo -e "${GREEN}✓ Metro bundler is running${NC}"
echo ""
echo -e "${BLUE}You can now:${NC}"
echo "  1. Test the app in the simulator"
echo "  2. View logs in this terminal"
echo "  3. Enable Fast Refresh by saving files"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop Metro and exit${NC}"
echo ""
echo -e "${BLUE}Logs:${NC}"
echo "-------------------------------------------"

# Wait for Metro to finish (keeps running until Ctrl+C)
wait $METRO_PID
