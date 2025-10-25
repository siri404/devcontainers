# Testing the Stripe CLI DevContainer Feature

This guide shows how to test the stripe-cli devcontainer feature locally.

## Prerequisites

- Docker Desktop installed and running
- VS Code (optional, for Method 3)

## Method 1: Quick Docker Test (Easiest)

Test the installation script directly in a Docker container:

```bash
# Build and run test in one command
docker run --rm -it mcr.microsoft.com/devcontainers/base:ubuntu bash -c "
  $(cat src/stripe-cli/install.sh)
  stripe --version
"
```

Or step-by-step:

```bash
# Start a test container
docker run --rm -it mcr.microsoft.com/devcontainers/base:ubuntu bash

# Inside the container, run:
apt-get update
apt-get install -y curl ca-certificates gnupg2

# Copy and paste your install.sh script contents, then:
stripe --version
stripe --help
```

## Method 2: Using DevContainer CLI

### Install DevContainer CLI

```bash
npm install -g @devcontainers/cli
```

### Run the test suite

```bash
# From repository root
devcontainer features test \
  --features stripe-cli \
  --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
  .
```

### Run specific test scenarios

```bash
# Test the default scenario
devcontainer features test \
  --features stripe-cli \
  --skip-scenarios \
  --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
  .

# Test a specific scenario
devcontainer features test \
  --features stripe-cli \
  --scenario stripe-cli-latest \
  --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
  .
```

## Method 3: Test in VS Code

### Create a test project

```bash
# Create test directory
mkdir -p /tmp/test-stripe-cli
cd /tmp/test-stripe-cli

# Create devcontainer.json
cat > .devcontainer.json << 'EOF'
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "/Users/siri/Documents/code/stripe-cli/src/stripe-cli": {
      "version": "latest"
    }
  }
}
EOF
```

### Open in VS Code

1. Open the folder in VS Code
2. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux)
3. Select "Dev Containers: Reopen in Container"
4. Wait for container to build
5. Open terminal and test:
   ```bash
   stripe --version
   stripe --help
   ```

## Method 4: Manual Docker Build

Create a test Dockerfile:

```bash
# In your repository root
cat > Dockerfile.test << 'EOF'
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Copy the feature
COPY src/stripe-cli /tmp/stripe-cli

# Run the install script
RUN bash /tmp/stripe-cli/install.sh

# Verify installation
RUN stripe --version
EOF

# Build it
docker build -f Dockerfile.test -t test-stripe-cli .

# Run it
docker run --rm -it test-stripe-cli bash

# Inside container, test:
# stripe --version
# stripe --help
```

## Method 5: Test with Different Base Images

```bash
# Test with Debian
docker run --rm -it mcr.microsoft.com/devcontainers/base:debian bash

# Test with Ubuntu 22.04
docker run --rm -it mcr.microsoft.com/devcontainers/base:jammy bash

# Test with Node image
docker run --rm -it mcr.microsoft.com/devcontainers/typescript-node:1-22 bash
```

Then inside each container:
```bash
# Run your install script
bash < <(curl -s https://raw.githubusercontent.com/.../install.sh)
# Or copy-paste the script
```

## What to Verify

✓ **Installation succeeds**
```bash
stripe --version
# Should output: stripe version X.Y.Z
```

✓ **Command works**
```bash
stripe --help
# Should show help menu
```

✓ **Binary location**
```bash
which stripe
# Should output: /usr/bin/stripe or /usr/local/bin/stripe
```

✓ **Login flow** (optional, requires auth)
```bash
stripe login --interactive
# Should prompt for API key
```

## Automated Test Script

Run the existing test:

```bash
# Make sure test script is executable
chmod +x test/stripe-cli/test.sh

# Run in a container
docker run --rm -v "$(pwd):/workspace" -w /workspace \
  mcr.microsoft.com/devcontainers/base:ubuntu \
  bash -c "
    bash src/stripe-cli/install.sh
    bash test/stripe-cli/test.sh
  "
```

## Common Issues

### Issue: GPG key download fails
**Fix**: Check internet connection, try with `--retry` flags

### Issue: apt-get update fails
**Fix**: Run `apt-get update` before the install script

### Issue: Permission denied
**Fix**: Run as root or with sudo

### Issue: stripe command not found
**Fix**: Check if `/usr/bin/stripe` or `/usr/local/bin/stripe` exists

## Quick One-Liner Test

```bash
docker run --rm mcr.microsoft.com/devcontainers/base:ubuntu bash -c "
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update -y && \
  apt-get install -y curl ca-certificates gnupg2 && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor -o /etc/apt/keyrings/stripe.gpg && \
  echo 'deb [signed-by=/etc/apt/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main' > /etc/apt/sources.list.d/stripe.list && \
  apt-get update -y && \
  apt-get install -y stripe && \
  stripe --version
"
```

## Clean Up

```bash
# Remove test containers
docker ps -a | grep test-stripe | awk '{print $1}' | xargs docker rm -f

# Remove test images
docker images | grep test-stripe | awk '{print $3}' | xargs docker rmi -f

# Remove test directory
rm -rf /tmp/test-stripe-cli
```

