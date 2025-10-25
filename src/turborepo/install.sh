#!/bin/bash
set -e

echo "Activating feature 'turborepo'"

# Get the version option from devcontainer-feature.json
TURBO_VERSION="${VERSION:-latest}"
echo "Installing Turborepo version: $TURBO_VERSION"

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if turbo is already installed
if command_exists turbo; then
    CURRENT_VERSION=$(turbo --version 2>&1 || echo "unknown")
    echo "Turborepo is already installed: $CURRENT_VERSION"
    exit 0
fi

# Check if npm is available
if ! command_exists npm; then
    echo "Error: npm is not installed"
    echo "Turborepo requires Node.js and npm to be installed first"
    echo "Please add the 'ghcr.io/devcontainers/features/node' feature before turborepo"
    exit 1
fi

# Check if node is available
if ! command_exists node; then
    echo "Error: Node.js is not installed"
    echo "Turborepo requires Node.js to be installed first"
    echo "Please add the 'ghcr.io/devcontainers/features/node' feature before turborepo"
    exit 1
fi

NODE_VERSION=$(node --version 2>&1)
echo "Detected Node.js: $NODE_VERSION"

NPM_VERSION=$(npm --version 2>&1)
echo "Detected npm: $NPM_VERSION"

# Install Turborepo globally
echo "Installing Turborepo globally via npm..."

if [ "$TURBO_VERSION" = "latest" ]; then
    if ! npm install -g turbo; then
        echo "Error: Failed to install Turborepo"
        exit 1
    fi
else
    if ! npm install -g "turbo@${TURBO_VERSION}"; then
        echo "Error: Failed to install Turborepo version ${TURBO_VERSION}"
        exit 1
    fi
fi

# Verify installation
if ! command_exists turbo; then
    echo "Error: turbo command not found after installation"
    exit 1
fi

if ! turbo --version >/dev/null 2>&1; then
    echo "Error: turbo command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(turbo --version 2>&1)
echo "✓ Successfully installed: Turborepo $INSTALLED_VERSION"
echo "✓ Turborepo installation complete!"

