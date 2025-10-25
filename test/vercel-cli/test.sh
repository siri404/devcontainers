#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'vercel-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "vercel command exists" bash -c "command -v vercel"
check "vercel version" bash -c "vercel --version"
check "vercel help" bash -c "vercel --help | grep -i 'vercel'"
check "vc alias exists" bash -c "command -v vc"
check "node is installed" bash -c "command -v node"
check "npm is installed" bash -c "command -v npm"

# Report results
reportResults

