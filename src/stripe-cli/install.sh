#!/bin/sh
set -e

echo "Activating feature 'stripe-cli'"

# Get the version option (defaults to 'latest')
VERSION=${VERSION:-latest}
echo "Installing Stripe CLI version: $VERSION"

# The 'install.sh' entrypoint script is always executed as the root user.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"
echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

# Ensure apt is in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run apt-get update if needed
apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Function to ensure prerequisites are installed
ensure_prerequisites() {
    local packages_needed=""
    
    if ! command_exists curl; then
        packages_needed="$packages_needed curl"
    fi
    
    if ! command_exists gpg; then
        packages_needed="$packages_needed gnupg2"
    fi
    
    if ! command_exists tar; then
        packages_needed="$packages_needed tar"
    fi
    
    if [ -n "$packages_needed" ]; then
        echo "Installing prerequisites:$packages_needed"
        apt_get_update
        apt-get install -y --no-install-recommends ca-certificates$packages_needed
    fi
}

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="$ID"
        OS_VERSION_ID="$VERSION_ID"
    elif command_exists lsb_release; then
        OS_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        OS_VERSION_ID=$(lsb_release -sr)
    else
        OS_ID=$(uname -s | tr '[:upper:]' '[:lower:]')
        OS_VERSION_ID=""
    fi
    
    echo "Detected OS: $OS_ID $OS_VERSION_ID"
}

# Function to detect architecture
detect_architecture() {
    ARCHITECTURE="$(uname -m)"
    case $ARCHITECTURE in
        x86_64) ARCHITECTURE="x86_64";;
        aarch64 | armv8* | arm64) ARCHITECTURE="arm64";;
        armv7* | armhf) ARCHITECTURE="arm";;
        i?86) ARCHITECTURE="i386";;
        *)
            echo "Warning: Architecture $ARCHITECTURE may not be supported"
            ;;
    esac
    echo "Detected architecture: $ARCHITECTURE"
}

# Function to install via apt (Debian/Ubuntu)
install_via_apt() {
    echo "Installing Stripe CLI via apt..."
    
    # Ensure /etc/apt/keyrings directory exists
    mkdir -p /etc/apt/keyrings
    
    # Add Stripe's GPG key with retry logic
    local retry=0
    local max_retries=3
    while [ $retry -lt $max_retries ]; do
        if curl -fsSL --retry 3 --retry-delay 2 https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | \
           gpg --dearmor --yes -o /etc/apt/keyrings/stripe.gpg 2>/dev/null; then
            echo "Successfully added Stripe GPG key"
            break
        fi
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo "Failed to add GPG key, retrying ($retry/$max_retries)..."
            sleep 2
        else
            echo "Failed to add GPG key after $max_retries attempts"
            return 1
        fi
    done
    
    # Set proper permissions on the GPG key
    chmod 644 /etc/apt/keyrings/stripe.gpg
    
    # Add Stripe's apt repository
    echo "deb [signed-by=/etc/apt/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | \
        tee /etc/apt/sources.list.d/stripe.list >/dev/null
    
    # Update package list
    if ! apt-get update -y 2>/dev/null; then
        echo "Warning: apt-get update failed, cleaning up and retrying..."
        rm -f /etc/apt/sources.list.d/stripe.list
        apt-get update -y
        return 1
    fi
    
    # Install stripe
    if apt-get install -y --no-install-recommends stripe; then
        echo "Successfully installed Stripe CLI via apt"
        return 0
    else
        echo "Failed to install via apt"
        return 1
    fi
}

# Function to install via direct binary download (fallback)
install_via_binary() {
    echo "Installing Stripe CLI via direct binary download..."
    
    # Determine OS for download
    local os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    # Determine download URL
    local download_url
    if [ "$VERSION" = "latest" ]; then
        download_url="https://github.com/stripe/stripe-cli/releases/latest/download/stripe_${os_type}_${ARCHITECTURE}.tar.gz"
    else
        # Remove 'v' prefix if present
        local clean_version="${VERSION#v}"
        download_url="https://github.com/stripe/stripe-cli/releases/download/v${clean_version}/stripe_${os_type}_${ARCHITECTURE}.tar.gz"
    fi
    
    echo "Downloading from: $download_url"
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    cd "$TEMP_DIR"
    
    # Download with retry logic
    local retry=0
    local max_retries=3
    while [ $retry -lt $max_retries ]; do
        if curl -fsSL --retry 3 --retry-delay 2 "$download_url" -o stripe.tar.gz; then
            echo "Successfully downloaded Stripe CLI"
            break
        fi
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo "Download failed, retrying ($retry/$max_retries)..."
            sleep 2
        else
            echo "Failed to download after $max_retries attempts"
            return 1
        fi
    done
    
    # Verify the downloaded file
    if [ ! -f stripe.tar.gz ] || [ ! -s stripe.tar.gz ]; then
        echo "Error: Downloaded file is missing or empty"
        return 1
    fi
    
    # Extract the archive
    if ! tar -xzf stripe.tar.gz 2>/dev/null; then
        echo "Error: Failed to extract archive"
        return 1
    fi
    
    # Verify the binary exists
    if [ ! -f stripe ]; then
        echo "Error: stripe binary not found in archive"
        return 1
    fi
    
    # Install the binary
    mv stripe /usr/local/bin/stripe
    chmod +x /usr/local/bin/stripe
    
    echo "Successfully installed Stripe CLI via binary download"
    return 0
}

# Function to verify installation
verify_installation() {
    echo "Verifying Stripe CLI installation..."
    
    if ! command_exists stripe; then
        echo "Error: stripe command not found"
        return 1
    fi
    
    # Test that the binary works
    if ! stripe --version >/dev/null 2>&1; then
        echo "Error: stripe command exists but fails to run"
        return 1
    fi
    
    local installed_version=$(stripe --version 2>&1 | head -n1)
    echo "✓ Stripe CLI installed successfully: $installed_version"
    return 0
}

# Cleanup function for error handling
cleanup_on_error() {
    echo "Cleaning up after error..."
    rm -f /etc/apt/sources.list.d/stripe.list
    rm -f /etc/apt/keyrings/stripe.gpg
}

# Main installation logic
main() {
    # Detect system information
    detect_os
    detect_architecture
    
    # Ensure prerequisites are installed
    ensure_prerequisites
    
    # Check if stripe is already installed
    if command_exists stripe; then
        local current_version=$(stripe --version 2>&1 | head -n1)
        echo "Stripe CLI is already installed: $current_version"
        
        if [ "$VERSION" = "latest" ]; then
            echo "Continuing with installation to ensure latest version..."
        else
            echo "Skipping installation. Use a different version number to reinstall."
            return 0
        fi
    fi
    
    # Try installation methods in order
    local installation_success=false
    
    # Method 1: Try apt installation for Debian/Ubuntu-based systems
    case "$OS_ID" in
        debian|ubuntu|raspbian)
            if install_via_apt; then
                installation_success=true
            else
                echo "Apt installation failed, trying binary installation..."
                cleanup_on_error
            fi
            ;;
    esac
    
    # Method 2: Fallback to binary installation
    if [ "$installation_success" = "false" ]; then
        if install_via_binary; then
            installation_success=true
        fi
    fi
    
    # Check if installation succeeded
    if [ "$installation_success" = "false" ]; then
        echo "Error: All installation methods failed"
        exit 1
    fi
    
    # Verify the installation
    if ! verify_installation; then
        echo "Error: Installation verification failed"
        exit 1
    fi
    
    echo "✓ Stripe CLI feature installation complete!"
}

# Run main function
main