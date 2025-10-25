#!/bin/bash
set -e

echo "Activating feature 'redis-cli'"

# Get the version option from devcontainer-feature.json
REDIS_VERSION="${VERSION:-latest}"
echo "Installing Redis CLI version: $REDIS_VERSION"

# Ensure apt is in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if redis-cli is already installed
if command_exists redis-cli; then
    CURRENT_VERSION=$(redis-cli --version 2>&1 | head -n1 || echo "unknown")
    echo "Redis client is already installed: $CURRENT_VERSION"
    exit 0
fi

echo "Installing prerequisites..."
if ! apt-get update -y; then
    echo "Warning: apt-get update failed on first attempt, retrying..."
    sleep 2
    apt-get update -y
fi

# Install required dependencies
PACKAGES_NEEDED="wget ca-certificates gnupg2 lsb-release curl"
apt-get install -y --no-install-recommends $PACKAGES_NEEDED

# Detect OS distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_CODENAME="${VERSION_CODENAME:-}"
    OS_ID="${ID:-}"
else
    OS_CODENAME=$(lsb_release -cs 2>/dev/null || echo "")
    OS_ID="unknown"
fi

echo "Detected OS: $OS_ID $OS_CODENAME"

# Add Redis APT repository
echo "Adding Redis APT repository..."
mkdir -p /etc/apt/keyrings

# Download Redis GPG key
if ! curl -fsSL https://packages.redis.io/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/redis-archive-keyring.gpg 2>&1; then
    echo "Error: Failed to download Redis GPG key"
    echo "Please check your internet connection and try again"
    exit 1
fi

chmod 644 /etc/apt/keyrings/redis-archive-keyring.gpg
echo "✓ Added Redis GPG key"

# Add Redis repository
echo "deb [signed-by=/etc/apt/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb ${OS_CODENAME} main" \
    > /etc/apt/sources.list.d/redis.list
echo "✓ Added Redis apt repository"

# Update package list
echo "Updating package list..."
apt-get update -y

# Determine package to install based on version
if [ "$REDIS_VERSION" = "latest" ]; then
    PACKAGE_NAME="redis-tools"
    echo "Installing latest Redis client tools..."
else
    # For specific versions, we'll still install redis-tools and let apt handle the version
    PACKAGE_NAME="redis-tools"
    echo "Installing Redis client tools version ${REDIS_VERSION}..."
fi

# Install Redis client tools
if ! apt-get install -y --no-install-recommends $PACKAGE_NAME; then
    echo "Error: Failed to install $PACKAGE_NAME"
    echo "Available versions might be: 6, 7, latest"
    exit 1
fi

# Verify installation
if ! command_exists redis-cli; then
    echo "Error: redis-cli command not found after installation"
    exit 1
fi

if ! redis-cli --version >/dev/null 2>&1; then
    echo "Error: redis-cli command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(redis-cli --version 2>&1 | head -n1)
echo "✓ Successfully installed: $INSTALLED_VERSION"
echo "✓ Redis CLI installation complete!"

# Show installed tools
echo ""
echo "Available Redis client tools:"
for cmd in redis-cli redis-benchmark redis-check-aof redis-check-rdb; do
    if command_exists $cmd; then
        echo "  ✓ $cmd"
    fi
done


