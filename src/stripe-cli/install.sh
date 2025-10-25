#!/bin/sh
set -e

echo "Activating feature 'Stripe CLI' (Installing latest)"

# --- Debian/Ubuntu-based logic ---

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure dependencies are installed
apt-get update
if ! command_exists curl || ! command_exists gpg; then
    echo "Installing dependencies (curl, gpg) for Stripe CLI..."
    apt-get install -y --no-install-recommends curl gpg
fi

# Add Stripe's GPG key
echo "Adding Stripe GPG key..."
mkdir -p /etc/apt/keyrings
curl -sS https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor | tee /etc/apt/keyrings/stripe.gpg >/dev/null

# Add Stripe's apt repository
echo "Adding Stripe apt repository..."
echo "deb [signed-by=/etc/apt/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | tee /etc/apt/sources.list.d/stripe.list

# Update package list again and install the Stripe CLI
echo "Updating package list and installing latest Stripe CLI..."
apt-get update
apt-get install -y --no-install-recommends stripe

# Clean up apt cache
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Stripe CLI installation complete."