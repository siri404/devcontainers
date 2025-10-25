#!/bin/bash
set -e

echo "Activating feature 'vercel-cli'"

# Get the version option from devcontainer-feature.json
VERCEL_VERSION="${VERSION:-latest}"
echo "Installing Vercel CLI version: $VERCEL_VERSION"

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if vercel is already installed
if command_exists vercel; then
    CURRENT_VERSION=$(vercel --version 2>&1 || echo "unknown")
    echo "Vercel CLI is already installed: $CURRENT_VERSION"
    exit 0
fi

# Check if npm is available
if ! command_exists npm; then
    echo "Error: npm is not installed"
    echo "Vercel CLI requires Node.js and npm to be installed first"
    echo "Please add the 'ghcr.io/devcontainers/features/node' feature before vercel-cli"
    exit 1
fi

# Check if node is available
if ! command_exists node; then
    echo "Error: Node.js is not installed"
    echo "Vercel CLI requires Node.js to be installed first"
    echo "Please add the 'ghcr.io/devcontainers/features/node' feature before vercel-cli"
    exit 1
fi

NODE_VERSION=$(node --version 2>&1)
echo "Detected Node.js: $NODE_VERSION"

NPM_VERSION=$(npm --version 2>&1)
echo "Detected npm: $NPM_VERSION"

# Install Vercel CLI globally
echo "Installing Vercel CLI globally via npm..."

if [ "$VERCEL_VERSION" = "latest" ]; then
    if ! npm install -g vercel; then
        echo "Error: Failed to install Vercel CLI"
        exit 1
    fi
else
    if ! npm install -g "vercel@${VERCEL_VERSION}"; then
        echo "Error: Failed to install Vercel CLI version ${VERCEL_VERSION}"
        exit 1
    fi
fi

# Verify installation
if ! command_exists vercel; then
    echo "Error: vercel command not found after installation"
    exit 1
fi

if ! vercel --version >/dev/null 2>&1; then
    echo "Error: vercel command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(vercel --version 2>&1)
echo "✓ Successfully installed: Vercel CLI $INSTALLED_VERSION"
echo "✓ Vercel CLI installation complete!"

# Note about vc alias
if command_exists vc; then
    echo "✓ Alias 'vc' is also available"
fi

