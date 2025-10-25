
# PostgreSQL CLI (postgresql-cli)

Installs PostgreSQL client tools (psql, pg_dump, etc.)

## Example Usage

```json
"features": {
    "ghcr.io/siri404/devcontainers/postgresql-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of PostgreSQL client to install | string | latest |

## About PostgreSQL Client

The PostgreSQL client package provides command-line tools for interacting with PostgreSQL databases, including:

- **psql** - Interactive terminal for PostgreSQL
- **pg_dump** - Database backup utility
- **pg_restore** - Database restore utility
- **pg_dumpall** - Backup all databases
- **createdb** - Create a new database
- **dropdb** - Remove a database
- **pg_isready** - Check connection status

## Installation Method

This feature uses the official [PostgreSQL APT Repository](https://www.postgresql.org/download/linux/ubuntu/) to install the latest stable PostgreSQL client tools.

## Usage

### Connect to a PostgreSQL database

```bash
# Connect to a local database
psql -U username -d database_name

# Connect to a remote database
psql -h hostname -U username -d database_name -p 5432

# Connection string format
psql postgresql://username:password@hostname:5432/database_name
```

### Common Commands

```bash
# Check psql version
psql --version

# Backup a database
pg_dump -U username database_name > backup.sql

# Restore a database
psql -U username database_name < backup.sql

# Create a new database
createdb -U username new_database

# Check if PostgreSQL server is ready
pg_isready -h hostname -p 5432
```

### Inside psql

```sql
-- List databases
\l

-- Connect to a database
\c database_name

-- List tables
\dt

-- Describe table structure
\d table_name

-- Show all commands
\?

-- Quit psql
\q
```

## Version Support

This feature supports PostgreSQL client versions:
- **latest** - Latest stable version (recommended)
- **16** - PostgreSQL 16.x
- **15** - PostgreSQL 15.x
- **14** - PostgreSQL 14.x
- **13** - PostgreSQL 13.x
- **12** - PostgreSQL 12.x

## OS Support

Works on Debian and Ubuntu-based containers including:
- Ubuntu (all versions)
- Debian (Bullseye, Bookworm, etc.)
- Derivative distributions

## Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [psql Documentation](https://www.postgresql.org/docs/current/app-psql.html)
- [PostgreSQL Downloads](https://www.postgresql.org/download/)



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/siri404/devcontainers/blob/main/src/postgresql-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
