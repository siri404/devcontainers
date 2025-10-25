#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'postgresql-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "psql command exists" bash -c "command -v psql"
check "psql version" bash -c "psql --version"
check "pg_dump exists" bash -c "command -v pg_dump"
check "pg_restore exists" bash -c "command -v pg_restore"
check "createdb exists" bash -c "command -v createdb"
check "dropdb exists" bash -c "command -v dropdb"

# Report results
reportResults

