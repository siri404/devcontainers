#!/bin/bash
set -e

echo "Activating feature 'stripe-cli'"

# Get the version option (defaults to 'latest')
VERSION="${VERSION:-latest}"
echo "Installing Stripe CLI version: $VERSION"

# The 'install.sh' entrypoint script is always executed as the root user.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"
echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

# Ensure apt is in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update apt cache if needed
apt_get_update_if_needed() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Ensure required packages are installed
echo "Ensuring prerequisites are installed..."
PACKAGES_TO_INSTALL=""

if ! command_exists curl; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL curl"
fi

if ! command_exists gpg; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL gnupg2"
fi

if ! command_exists tar; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL tar"
fi

if [ -n "$PACKAGES_TO_INSTALL" ]; then
    echo "Installing prerequisites:$PACKAGES_TO_INSTALL"
    apt_get_update_if_needed
    apt-get install -y --no-install-recommends ca-certificates $PACKAGES_TO_INSTALL
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID:-linux}"
    OS_VERSION_ID="${VERSION_ID:-}"
else
    OS_ID="linux"
    OS_VERSION_ID=""
fi
echo "Detected OS: $OS_ID $OS_VERSION_ID"

# Detect architecture
ARCHITECTURE="$(uname -m)"
case "$ARCHITECTURE" in
    x86_64) 
        ARCH_NORMALIZED="x86_64"
        ;;
    aarch64 | armv8* | arm64) 
        ARCH_NORMALIZED="arm64"
        ;;
    armv7* | armhf) 
        ARCH_NORMALIZED="arm"
        ;;
    i?86) 
        ARCH_NORMALIZED="i386"
        ;;
    *)
        echo "Warning: Architecture $ARCHITECTURE may not be fully supported"
        ARCH_NORMALIZED="$ARCHITECTURE"
        ;;
esac
echo "Detected architecture: $ARCH_NORMALIZED"

# Check if stripe is already installed
if command_exists stripe; then
    CURRENT_VERSION=$(stripe --version 2>&1 | head -n1 || echo "unknown")
    echo "Stripe CLI is already installed: $CURRENT_VERSION"
    echo "Skipping installation."
    exit 0
fi

# Function to install via apt (for Debian/Ubuntu)
# Based on: https://docs.stripe.com/stripe-cli/install?install-method=apt
install_via_apt() {
    echo "Attempting to install Stripe CLI via apt (official method)..."
    
    # Ensure /etc/apt/keyrings directory exists
    mkdir -p /etc/apt/keyrings
    
    # Download and add Stripe's GPG key
    echo "→ Adding Stripe GPG key..."
    if ! curl -fsSL --retry 3 --retry-delay 2 \
        https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public \
        | gpg --dearmor -o /etc/apt/keyrings/stripe.gpg 2>/dev/null; then
        echo "✗ Failed to add GPG key"
        return 1
    fi
    chmod 644 /etc/apt/keyrings/stripe.gpg
    echo "✓ Added Stripe GPG key"
    
    # Add Stripe's apt repository
    echo "deb [signed-by=/etc/apt/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" \
        > /etc/apt/sources.list.d/stripe.list
    echo "✓ Added Stripe apt repository"
    
    # Update package list
    echo "→ Updating package list..."
    if ! apt-get update -y 2>&1 | grep -v "^Get:" | grep -v "^Hit:" | grep -v "^Reading" || true; then
        echo "✗ apt-get update failed"
        rm -f /etc/apt/sources.list.d/stripe.list /etc/apt/keyrings/stripe.gpg
        return 1
    fi
    
    # Install stripe
    echo "→ Installing Stripe CLI..."
    if apt-get install -y --no-install-recommends stripe; then
        echo "✓ Successfully installed Stripe CLI via apt"
        return 0
    else
        echo "✗ Failed to install via apt"
        rm -f /etc/apt/sources.list.d/stripe.list /etc/apt/keyrings/stripe.gpg
        return 1
    fi
}

# Function to install via direct binary download (fallback)
# Downloads from: https://github.com/stripe/stripe-cli/releases
install_via_binary() {
    echo "Installing Stripe CLI via direct binary download (fallback method)..."
    
    # Determine OS type for download
    OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    # Construct download URL
    if [ "$VERSION" = "latest" ]; then
        DOWNLOAD_URL="https://github.com/stripe/stripe-cli/releases/latest/download/stripe_${OS_TYPE}_${ARCH_NORMALIZED}.tar.gz"
        echo "→ Fetching latest version from GitHub"
    else
        # Remove 'v' prefix if present
        CLEAN_VERSION="${VERSION#v}"
        DOWNLOAD_URL="https://github.com/stripe/stripe-cli/releases/download/v${CLEAN_VERSION}/stripe_${OS_TYPE}_${ARCH_NORMALIZED}.tar.gz"
        echo "→ Fetching version v${CLEAN_VERSION} from GitHub"
    fi
    
    echo "→ Download URL: $DOWNLOAD_URL"
    
    # Create and use temporary directory
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    
    # Download archive
    echo "→ Downloading..."
    if ! curl -fsSL --retry 3 --retry-delay 2 "$DOWNLOAD_URL" -o stripe.tar.gz; then
        echo "✗ Download failed"
        echo "  Please check: https://github.com/stripe/stripe-cli/releases"
        rm -rf "$TMP_DIR"
        return 1
    fi
    
    # Verify download
    if [ ! -s stripe.tar.gz ]; then
        echo "✗ Downloaded file is empty"
        rm -rf "$TMP_DIR"
        return 1
    fi
    
    # Extract archive
    echo "→ Extracting..."
    if ! tar -xzf stripe.tar.gz 2>/dev/null; then
        echo "✗ Failed to extract archive"
        rm -rf "$TMP_DIR"
        return 1
    fi
    
    # Verify binary exists
    if [ ! -f stripe ]; then
        echo "✗ Binary not found in archive"
        rm -rf "$TMP_DIR"
        return 1
    fi
    
    # Install binary
    echo "→ Installing to /usr/local/bin/stripe..."
    mv stripe /usr/local/bin/stripe
    chmod +x /usr/local/bin/stripe
    
    # Cleanup
    cd /
    rm -rf "$TMP_DIR"
    
    echo "✓ Successfully installed Stripe CLI via binary download"
    return 0
}

# Try installation methods
INSTALL_SUCCESS=0

# Method 1: Try apt for Debian/Ubuntu systems
case "$OS_ID" in
    debian|ubuntu|raspbian)
        if install_via_apt; then
            INSTALL_SUCCESS=1
        else
            echo "⚠ Apt installation failed, trying binary download..."
        fi
        ;;
esac

# Method 2: Try binary download if apt failed or not applicable
if [ "$INSTALL_SUCCESS" = "0" ]; then
    if install_via_binary; then
        INSTALL_SUCCESS=1
    fi
fi

# Check if installation succeeded
if [ "$INSTALL_SUCCESS" = "0" ]; then
    echo ""
    echo "✗ Error: All installation methods failed"
    echo "  Please check your network connection and try again"
    exit 1
fi

# Verify installation
echo ""
echo "Verifying installation..."
if ! command_exists stripe; then
    echo "✗ Error: stripe command not found after installation"
    exit 1
fi

if ! stripe --version >/dev/null 2>&1; then
    echo "✗ Error: stripe command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(stripe --version 2>&1 | head -n1)
echo "✓ Stripe CLI verified: $INSTALLED_VERSION"

# Success message
echo ""
echo "✓ Stripe CLI feature installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  To authenticate with Stripe, run:"
echo "    stripe login"
echo ""
echo "  For more information, visit:"
echo "    https://docs.stripe.com/stripe-cli"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
