#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'turborepo' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "turbo command exists" bash -c "command -v turbo"
check "turbo version" bash -c "turbo --version"
check "turbo help" bash -c "turbo --help | grep -i 'turborepo'"
check "node is installed" bash -c "command -v node"
check "npm is installed" bash -c "command -v npm"

# Report results
reportResults

