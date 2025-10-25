#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'prisma-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "prisma command exists" bash -c "command -v prisma"
check "prisma version" bash -c "prisma --version"
check "prisma help" bash -c "prisma --help | grep -i 'prisma'"
check "node is installed" bash -c "command -v node"
check "npm is installed" bash -c "command -v npm"

# Report results
reportResults

