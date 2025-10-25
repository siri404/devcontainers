#!/bin/bash
set -e

echo "Activating feature 'postgresql-cli'"

# Get the version option from devcontainer-feature.json
PG_VERSION="${VERSION:-latest}"
echo "Installing PostgreSQL CLI version: $PG_VERSION"

# Ensure apt is in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if psql is already installed
if command_exists psql; then
    CURRENT_VERSION=$(psql --version 2>&1 | head -n1 || echo "unknown")
    echo "PostgreSQL client is already installed: $CURRENT_VERSION"
    exit 0
fi

echo "Installing prerequisites..."
if ! apt-get update -y; then
    echo "Warning: apt-get update failed on first attempt, retrying..."
    sleep 2
    apt-get update -y
fi

# Install required dependencies
PACKAGES_NEEDED="wget ca-certificates gnupg2 lsb-release"
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

# Add PostgreSQL APT repository
echo "Adding PostgreSQL APT repository..."
mkdir -p /etc/apt/keyrings

# Download PostgreSQL GPG key
if ! wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg 2>&1; then
    echo "Error: Failed to download PostgreSQL GPG key"
    echo "Please check your internet connection and try again"
    exit 1
fi

chmod 644 /etc/apt/keyrings/postgresql.gpg
echo "✓ Added PostgreSQL GPG key"

# Add PostgreSQL repository
echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt ${OS_CODENAME}-pgdg main" \
    > /etc/apt/sources.list.d/postgresql.list
echo "✓ Added PostgreSQL apt repository"

# Update package list
echo "Updating package list..."
apt-get update -y

# Determine package to install based on version
if [ "$PG_VERSION" = "latest" ]; then
    PACKAGE_NAME="postgresql-client"
    echo "Installing latest PostgreSQL client..."
else
    PACKAGE_NAME="postgresql-client-${PG_VERSION}"
    echo "Installing PostgreSQL client version ${PG_VERSION}..."
fi

# Install PostgreSQL client
if ! apt-get install -y --no-install-recommends $PACKAGE_NAME; then
    echo "Error: Failed to install $PACKAGE_NAME"
    echo "Available versions might be: 12, 13, 14, 15, 16"
    exit 1
fi

# Verify installation
if ! command_exists psql; then
    echo "Error: psql command not found after installation"
    exit 1
fi

if ! psql --version >/dev/null 2>&1; then
    echo "Error: psql command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(psql --version 2>&1 | head -n1)
echo "✓ Successfully installed: $INSTALLED_VERSION"
echo "✓ PostgreSQL CLI installation complete!"

# Show installed tools
echo ""
echo "Available PostgreSQL client tools:"
for cmd in psql pg_dump pg_restore pg_dumpall createdb dropdb; do
    if command_exists $cmd; then
        echo "  ✓ $cmd"
    fi
done

