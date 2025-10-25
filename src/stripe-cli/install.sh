#!/bin/bash
set -e

echo "Activating feature 'stripe-cli'"

# Get the version option from devcontainer-feature.json
VERSION="${VERSION:-latest}"
echo "Installing Stripe CLI version: $VERSION"

# Ensure apt is in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if stripe is already installed
if command_exists stripe; then
    CURRENT_VERSION=$(stripe --version 2>&1 | head -n1 || echo "unknown")
    echo "Stripe CLI is already installed: $CURRENT_VERSION"
    exit 0
fi

echo "Installing prerequisites..."
apt-get update -y

# Install required dependencies
PACKAGES_NEEDED="curl ca-certificates gnupg2"
apt-get install -y --no-install-recommends $PACKAGES_NEEDED

# Add Stripe's GPG key
echo "Adding Stripe GPG key..."
mkdir -p /etc/apt/keyrings

if ! curl -fsSL --retry 3 https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public \
    | gpg --dearmor -o /etc/apt/keyrings/stripe.gpg 2>/dev/null; then
    echo "Error: Failed to download Stripe GPG key"
    exit 1
fi

chmod 644 /etc/apt/keyrings/stripe.gpg
echo "✓ Added Stripe GPG key"

# Add Stripe's apt repository
echo "Adding Stripe apt repository..."
echo "deb [signed-by=/etc/apt/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" \
    > /etc/apt/sources.list.d/stripe.list

# Update package list and install Stripe CLI
echo "Installing Stripe CLI..."
apt-get update -y

if ! apt-get install -y --no-install-recommends stripe; then
    echo "Error: Failed to install Stripe CLI"
    exit 1
fi

# Verify installation
if ! command_exists stripe; then
    echo "Error: stripe command not found after installation"
    exit 1
fi

if ! stripe --version >/dev/null 2>&1; then
    echo "Error: stripe command exists but fails to run"
    exit 1
fi

INSTALLED_VERSION=$(stripe --version 2>&1 | head -n1)
echo "✓ Successfully installed: $INSTALLED_VERSION"

# Optional: Clean up apt cache to reduce image size
apt-get clean
rm -rf /var/lib/apt/lists/*

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Stripe CLI installation complete!"
echo ""
echo "  To authenticate, run:"
echo "    stripe login"
echo ""
echo "  Documentation:"
echo "    https://docs.stripe.com/stripe-cli"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
