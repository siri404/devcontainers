#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'playwright' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "node is installed" bash -c "command -v node"
check "npm is installed" bash -c "command -v npm"
check "playwright command exists" bash -c "command -v playwright"
check "playwright version" bash -c "playwright --version"

# Check if @playwright/test is installed
check "playwright test package installed" bash -c "npm list -g @playwright/test"

# Verify browsers are installed (check for chromium by default)
check "playwright browsers installed" bash -c "playwright install --dry-run chromium 2>&1 | grep -q 'is already installed' || playwright install chromium"

# Report results
reportResults


