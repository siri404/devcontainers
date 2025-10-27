
# Redis CLI (redis-cli)

Installs Redis client tools (redis-cli, redis-benchmark, etc.)

## Example Usage

```json
"features": {
    "ghcr.io/siri404/devcontainers/redis-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of Redis client to install | string | latest |

## About Redis Client

The Redis client package provides command-line tools for interacting with Redis databases, including:

- **redis-cli** - Interactive terminal for Redis
- **redis-benchmark** - Performance testing utility
- **redis-check-aof** - AOF file checking utility
- **redis-check-rdb** - RDB file checking utility

## Installation Method

This feature uses the official [Redis APT Repository](https://redis.io/docs/install/install-redis/install-redis-on-linux/) to install the latest stable Redis client tools.

## Usage

### Connect to a Redis server

```bash
# Connect to a local Redis server
redis-cli

# Connect to a remote Redis server
redis-cli -h hostname -p 6379

# Connect with authentication
redis-cli -h hostname -p 6379 -a password

# Connect using a URI
redis-cli -u redis://username:password@hostname:6379/0
```

### Common Commands

```bash
# Check redis-cli version
redis-cli --version

# Execute a single command
redis-cli PING
redis-cli SET mykey "Hello"
redis-cli GET mykey

# Test Redis server performance
redis-benchmark -h hostname -p 6379 -n 100000

# Execute commands from stdin
echo "PING" | redis-cli

# Monitor all commands being executed
redis-cli MONITOR

# Get Redis server information
redis-cli INFO
```

### Inside redis-cli

```bash
# Ping the server
PING

# Set a key
SET mykey "Hello World"

# Get a key
GET mykey

# List all keys
KEYS *

# Get information about the server
INFO

# Select a database (0-15 by default)
SELECT 1

# Delete a key
DEL mykey

# Check if a key exists
EXISTS mykey

# Set expiration on a key (in seconds)
EXPIRE mykey 3600

# Get time to live for a key
TTL mykey

# Quit redis-cli
QUIT
```

### Working with Different Data Types

```bash
# Strings
SET user:1000:name "John Doe"
GET user:1000:name

# Lists
LPUSH mylist "item1"
LPUSH mylist "item2"
LRANGE mylist 0 -1

# Sets
SADD myset "member1"
SADD myset "member2"
SMEMBERS myset

# Hashes
HSET user:1000 name "John Doe" email "john@example.com"
HGET user:1000 name
HGETALL user:1000

# Sorted Sets
ZADD leaderboard 100 "player1"
ZADD leaderboard 200 "player2"
ZRANGE leaderboard 0 -1 WITHSCORES
```

## Version Support

This feature supports Redis client versions:
- **latest** - Latest stable version (recommended)
- **7** - Redis 7.x
- **6** - Redis 6.x

## OS Support

Works on Debian and Ubuntu-based containers including:
- Ubuntu (all versions)
- Debian (Bullseye, Bookworm, etc.)
- Derivative distributions

## Resources

- [Redis Documentation](https://redis.io/docs/)
- [redis-cli Documentation](https://redis.io/docs/ui/cli/)
- [Redis Commands Reference](https://redis.io/commands/)
- [Redis Downloads](https://redis.io/download/)




---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/siri404/devcontainers/blob/main/src/redis-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
