#!/bin/bash

###############################################################################
# Fix macOS File Watcher Limits
###############################################################################
#
# This script increases the macOS file descriptor limits to prevent
# "EMFILE: too many open files" errors with Metro bundler.
#
# Usage: ./fix-file-watchers.sh
#
###############################################################################

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Fixing macOS File Watcher Limits${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check current limits
echo -e "${BLUE}Current limits:${NC}"
echo "  ulimit -n: $(ulimit -n)"
echo "  launchctl limit maxfiles: $(launchctl limit maxfiles 2>/dev/null || echo 'N/A')"
echo ""

# Increase soft limit for current session
echo -e "${BLUE}Increasing limits for current session...${NC}"
ulimit -n 65536 2>/dev/null && echo -e "${GREEN}✓ Soft limit increased to 65536${NC}" || echo -e "${YELLOW}⚠ Could not increase soft limit${NC}"

# Check if watchman is installed
if command -v watchman &> /dev/null; then
    echo ""
    echo -e "${BLUE}Clearing Watchman cache...${NC}"
    watchman shutdown-server 2>/dev/null || true
    watchman watch-del-all 2>/dev/null || true
    echo -e "${GREEN}✓ Watchman cache cleared${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠ Watchman not installed${NC}"
    echo "  Install with: brew install watchman"
    echo "  Watchman helps prevent file watcher issues"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}File Watcher Limits Fixed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "New limits:"
echo "  ulimit -n: $(ulimit -n)"
echo ""
echo "Note: These changes are temporary for this session."
echo "To make permanent, add to ~/.zshrc:"
echo "  echo 'ulimit -n 65536' >> ~/.zshrc"
echo ""
