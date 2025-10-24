#!/bin/sh
set -e

echo "Activating feature 'stripe-cli'"

VERSION=${VERSION:-latest}
echo "Installing Stripe CLI version: $VERSION"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

# Detect architecture
ARCHITECTURE="$(uname -m)"
case $ARCHITECTURE in
    x86_64) ARCHITECTURE="x86_64";;
    aarch64 | armv8* | arm64) ARCHITECTURE="arm64";;
    *)
        echo "(!) Architecture $ARCHITECTURE unsupported"
        exit 1
        ;;
esac

# Detect OS
OS="$(uname -s)"
case $OS in
    Linux) OS="linux";;
    Darwin) OS="darwin";;
    *)
        echo "(!) OS $OS unsupported"
        exit 1
        ;;
esac

# Install dependencies
apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install curl and tar if not already installed
if ! type curl > /dev/null 2>&1 || ! type tar > /dev/null 2>&1; then
    apt_get_update
    apt-get -y install --no-install-recommends curl ca-certificates tar
fi

# Determine the download URL
if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/stripe/stripe-cli/releases/latest/download/stripe_${OS}_${ARCHITECTURE}.tar.gz"
else
    DOWNLOAD_URL="https://github.com/stripe/stripe-cli/releases/download/v${VERSION}/stripe_${OS}_${ARCHITECTURE}.tar.gz"
fi

echo "Downloading Stripe CLI from: $DOWNLOAD_URL"

# Download and install Stripe CLI
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
curl -sSL "$DOWNLOAD_URL" -o stripe.tar.gz
tar -xzf stripe.tar.gz
mv stripe /usr/local/bin/stripe
chmod +x /usr/local/bin/stripe

# Cleanup
cd /
rm -rf "$TEMP_DIR"

# Verify installation
if stripe --version > /dev/null 2>&1; then
    echo "Stripe CLI installed successfully!"
    stripe --version
else
    echo "(!) Failed to install Stripe CLI"
    exit 1
fi

