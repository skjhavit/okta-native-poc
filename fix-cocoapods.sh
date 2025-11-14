#!/bin/bash

###############################################################################
# CocoaPods Fix Script
###############################################################################
#
# This script helps fix CocoaPods PATH issues after installation
#
###############################################################################

echo "Checking CocoaPods installation..."

# Check if pod is already available
if command -v pod &> /dev/null; then
    echo "✓ CocoaPods is available: $(pod --version)"
    exit 0
fi

echo "CocoaPods not found in PATH. Attempting to fix..."

# Common locations where pod might be installed
POSSIBLE_PATHS=(
    "/usr/local/bin/pod"
    "$HOME/.gem/ruby/*/bin/pod"
    "/opt/homebrew/bin/pod"
    "/usr/bin/pod"
    "$(gem environment gemdir)/bin/pod"
)

echo ""
echo "Searching for pod executable..."

POD_LOCATION=""
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ] || ls $path 2>/dev/null | head -1; then
        POD_LOCATION=$(ls $path 2>/dev/null | head -1)
        echo "✓ Found pod at: $POD_LOCATION"
        break
    fi
done

if [ -z "$POD_LOCATION" ]; then
    echo "✗ Could not find pod executable"
    echo ""
    echo "Please try these steps:"
    echo "1. Close and reopen your terminal"
    echo "2. Run: gem which cocoapods"
    echo "3. If that works, run: rbenv rehash (if using rbenv)"
    echo "4. Or run: source ~/.zshrc (or ~/.bash_profile)"
    echo ""
    echo "If still not working, reinstall:"
    echo "  sudo gem install cocoapods"
    exit 1
fi

# Add to PATH if needed
echo ""
echo "Adding to PATH..."

POD_DIR=$(dirname "$POD_LOCATION")

# Detect shell
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bash_profile"
else
    SHELL_RC="$HOME/.profile"
fi

# Check if already in PATH
if echo "$PATH" | grep -q "$POD_DIR"; then
    echo "✓ $POD_DIR is already in PATH"
else
    echo "Adding $POD_DIR to $SHELL_RC"
    echo "" >> "$SHELL_RC"
    echo "# CocoaPods" >> "$SHELL_RC"
    echo "export PATH=\"$POD_DIR:\$PATH\"" >> "$SHELL_RC"
    echo "✓ Added to $SHELL_RC"
fi

echo ""
echo "================================================"
echo "CocoaPods Setup Complete!"
echo "================================================"
echo ""
echo "Please run: source $SHELL_RC"
echo "Or close and reopen your terminal"
echo ""
echo "Then verify with: pod --version"
echo ""
