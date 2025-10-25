#!/bin/bash
set -e

echo "Activating feature 'prisma-cli'"

# Get the version option from devcontainer-feature.json
PRISMA_VERSION="${VERSION:-latest}"
echo "Installing Prisma CLI version: $PRISMA_VERSION"

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if prisma is already installed
if command_exists prisma; then
    CURRENT_VERSION=$(prisma --version 2>&1 | grep "prisma" | head -n1 || echo "unknown")
    echo "Prisma CLI is already installed: $CURRENT_VERSION"
    exit 0
fi

# Check if npm is available
if ! command_exists npm; then
    echo "Error: npm is not installed"
    echo "Prisma CLI requires Node.js and npm to be installed first"
    echo "Please add the 'ghcr.io/devcontainers/features/node' feature before prisma-cli"
    exit 1
fi

# Check if node is available
if ! command_exists node; then
    echo "Error: Node.js is not installed"
    echo "Prisma CLI requires Node.js to be installed first"
    echo "Please add the 'ghcr.io/devcontainers/features/node' feature before prisma-cli"
    exit 1
fi

NODE_VERSION=$(node --version 2>&1)
echo "Detected Node.js: $NODE_VERSION"

NPM_VERSION=$(npm --version 2>&1)
echo "Detected npm: $NPM_VERSION"

# Install Prisma CLI globally
echo "Installing Prisma CLI globally via npm..."

if [ "$PRISMA_VERSION" = "latest" ]; then
    if ! npm install -g prisma; then
        echo "Error: Failed to install Prisma CLI"
        exit 1
    fi
else
    if ! npm install -g "prisma@${PRISMA_VERSION}"; then
        echo "Error: Failed to install Prisma CLI version ${PRISMA_VERSION}"
        exit 1
    fi
fi

# Verify installation
if ! command_exists prisma; then
    echo "Error: prisma command not found after installation"
    exit 1
fi

if ! prisma --version >/dev/null 2>&1; then
    echo "Error: prisma command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(prisma --version 2>&1 | grep "prisma" | head -n1)
echo "✓ Successfully installed: $INSTALLED_VERSION"
echo "✓ Prisma CLI installation complete!"

