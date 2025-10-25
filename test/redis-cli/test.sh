#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'redis-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "redis-cli command exists" bash -c "command -v redis-cli"
check "redis-cli version" bash -c "redis-cli --version"
check "redis-benchmark exists" bash -c "command -v redis-benchmark"
check "redis-check-aof exists" bash -c "command -v redis-check-aof"
check "redis-check-rdb exists" bash -c "command -v redis-check-rdb"

# Report results
reportResults


