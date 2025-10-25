#!/bin/bash
# Quick test script for Stripe CLI devcontainer feature

set -e

echo "=================================="
echo "Testing Stripe CLI Feature"
echo "=================================="
echo ""

# Check Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "   Please start Docker Desktop and try again"
    exit 1
fi

echo "✓ Docker is running"
echo ""

# Get the absolute path to the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FEATURE_DIR="$SCRIPT_DIR/src/stripe-cli"

if [ ! -f "$FEATURE_DIR/install.sh" ]; then
    echo "❌ Error: install.sh not found at $FEATURE_DIR"
    exit 1
fi

echo "✓ Found install.sh"
echo ""
echo "Starting Docker test container..."
echo ""

# Run test
docker run --rm \
    -v "$FEATURE_DIR:/tmp/stripe-cli:ro" \
    mcr.microsoft.com/devcontainers/base:ubuntu \
    bash -c '
        set -e
        echo "→ Running install script..."
        export VERSION=latest
        bash /tmp/stripe-cli/install.sh
        
        echo ""
        echo "→ Verifying installation..."
        
        if ! command -v stripe >/dev/null 2>&1; then
            echo "❌ FAIL: stripe command not found"
            exit 1
        fi
        
        echo "✓ stripe command found"
        
        if ! stripe --version >/dev/null 2>&1; then
            echo "❌ FAIL: stripe command exists but does not run"
            exit 1
        fi
        
        VERSION=$(stripe --version 2>&1 | head -n1)
        echo "✓ stripe runs successfully: $VERSION"
        
        echo ""
        echo "→ Testing stripe help..."
        if stripe --help | grep -q "Stripe CLI"; then
            echo "✓ stripe --help works"
        else
            echo "❌ FAIL: stripe --help failed"
            exit 1
        fi
        
        echo ""
        echo "=================================="
        echo "✅ ALL TESTS PASSED!"
        echo "=================================="
    '

echo ""
echo "✅ Test completed successfully!"

