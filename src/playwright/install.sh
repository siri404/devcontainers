#!/bin/bash
set -e

echo "Activating feature 'playwright'"

# Get options from devcontainer-feature.json
PLAYWRIGHT_VERSION="${VERSION:-latest}"
BROWSERS="${BROWSERS:-all}"
INSTALL_DEPS="${INSTALLDEPENDENCIES:-true}"

echo "Installing Playwright version: $PLAYWRIGHT_VERSION"
echo "Browsers to install: $BROWSERS"
echo "Install system dependencies: $INSTALL_DEPS"

# Ensure apt is in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root or with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

# Ensure node and npm are installed
if ! command_exists node; then
    echo "Error: Node.js is not installed"
    echo "Please install the 'node' feature before 'playwright'"
    echo "Add to devcontainer.json: \"ghcr.io/devcontainers/features/node:1\": {}"
    exit 1
fi

if ! command_exists npm; then
    echo "Error: npm is not installed"
    exit 1
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo "Found Node.js: $NODE_VERSION"
echo "Found npm: $NPM_VERSION"

# Install prerequisites
echo "Installing prerequisites..."
if ! apt-get update -y; then
    echo "Warning: apt-get update failed on first attempt, retrying..."
    sleep 2
    apt-get update -y
fi

# Determine the user to install for (prefer non-root user if available)
INSTALL_USER="${_REMOTE_USER:-${USER:-root}}"
if [ "$INSTALL_USER" = "root" ] && command_exists sudo; then
    # Try to find a non-root user
    INSTALL_USER=$(getent passwd 1000 | cut -d: -f1 || echo "root")
fi

USER_HOME=$(eval echo "~${INSTALL_USER}")
echo "Installing for user: $INSTALL_USER (home: $USER_HOME)"

# Install Playwright npm package
echo "Installing Playwright npm package..."

# Determine version to install
if [ "$PLAYWRIGHT_VERSION" = "latest" ]; then
    PACKAGE_VERSION="@playwright/test"
else
    PACKAGE_VERSION="@playwright/test@${PLAYWRIGHT_VERSION}"
fi

# Install globally to make it available system-wide
echo "Installing $PACKAGE_VERSION globally..."
npm install -g "$PACKAGE_VERSION"

# Also install for the user if not root
if [ "$INSTALL_USER" != "root" ]; then
    echo "Installing $PACKAGE_VERSION for user $INSTALL_USER..."
    su - "$INSTALL_USER" -c "npm install -g $PACKAGE_VERSION" || true
fi

# Verify Playwright CLI is available
if ! command_exists playwright; then
    # Try to find it in npm global bin
    NPM_BIN=$(npm bin -g)
    if [ -f "$NPM_BIN/playwright" ]; then
        ln -sf "$NPM_BIN/playwright" /usr/local/bin/playwright
    else
        echo "Warning: Playwright CLI not found in expected location"
    fi
fi

# Install system dependencies if requested
if [ "$INSTALL_DEPS" = "true" ]; then
    echo "Installing system dependencies for browsers..."
    
    # Install common dependencies needed by Playwright browsers
    DEPS="libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libdbus-1-3 \
          libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 \
          libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 libwayland-client0 \
          fonts-liberation fonts-noto-color-emoji libglib2.0-0 \
          libx11-6 libx11-xcb1 libxcb1 libxext6 libgtk-3-0"
    
    apt-get install -y --no-install-recommends $DEPS || {
        echo "Warning: Some dependencies failed to install, but continuing..."
    }
fi

# Install browsers
echo "Installing Playwright browsers: $BROWSERS"

# Install browsers using Playwright CLI
if [ "$BROWSERS" = "all" ]; then
    echo "Installing all browsers (chromium, firefox, webkit)..."
    if [ "$INSTALL_DEPS" = "true" ]; then
        playwright install --with-deps
    else
        playwright install
    fi
else
    # Install specific browsers
    for browser in $BROWSERS; do
        echo "Installing browser: $browser"
        if [ "$INSTALL_DEPS" = "true" ]; then
            playwright install --with-deps "$browser"
        else
            playwright install "$browser"
        fi
    done
fi

# Verify installation
if ! command_exists playwright; then
    echo "Error: playwright command not found after installation"
    exit 1
fi

INSTALLED_VERSION=$(playwright --version 2>&1 | head -n1 || echo "unknown")
echo "✓ Successfully installed: $INSTALLED_VERSION"
echo "✓ Playwright installation complete!"

# Show installed browsers
echo ""
echo "Playwright is ready to use!"
echo ""
echo "Quick test command:"
echo "  playwright --version"
echo ""
echo "To use in your project:"
echo "  npm init playwright@latest"
echo ""


