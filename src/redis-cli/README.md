# Redis CLI (redis-cli)

A devcontainer feature that installs Redis client tools including redis-cli, redis-benchmark, and other utilities.

## Example Usage

```json
"features": {
    "ghcr.io/your-username/stripe-cli/redis-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of Redis client to install | string | latest |

## Supported Versions

- `latest` - Latest stable Redis client (recommended)
- `7` - Redis 7.x client tools
- `6` - Redis 6.x client tools

## Example with Version

```json
"features": {
    "ghcr.io/your-username/stripe-cli/redis-cli:1": {
        "version": "7"
    }
}
```

## What's Included

This feature installs the following tools:

- `redis-cli` - Interactive command-line interface for Redis
- `redis-benchmark` - Performance benchmarking tool
- `redis-check-aof` - AOF file checking utility
- `redis-check-rdb` - RDB file checking utility

## Quick Start

After installation, you can immediately start using redis-cli:

```bash
# Connect to a local Redis server
redis-cli

# Connect to a remote Redis server
redis-cli -h redis.example.com -p 6379

# Execute a single command
redis-cli PING

# Check version
redis-cli --version
```

For more detailed usage information, see [NOTES.md](NOTES.md).

---

_Note: This feature only installs the Redis client tools. To run a Redis server, you would need to install Redis server separately or use a Docker container._

