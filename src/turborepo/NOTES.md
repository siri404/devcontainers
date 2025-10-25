## About Turborepo

[Turborepo](https://turbo.build/repo) is a high-performance build system for JavaScript and TypeScript codebases. It's optimized for monorepos and provides:

- **Blazingly fast builds** - Parallel task execution with intelligent caching
- **Smart caching** - Never do the same work twice
- **Remote caching** - Share build artifacts across your team
- **Task pipelines** - Define relationships between tasks
- **Incremental builds** - Only rebuild what changed

Turborepo is developed by Vercel and is used by companies like AWS, Disney, and Microsoft.

## Installation Method

This feature installs Turborepo globally using npm. It requires Node.js and npm to be installed first.

## Prerequisites

**Important**: This feature requires Node.js to be installed. Make sure to include the Node.js feature before Turborepo:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/YOUR_USERNAME/stripe-cli/turborepo:1": {}
  }
}
```

## Usage

### Initialize a new monorepo

```bash
# Create a new Turborepo project
npx create-turbo@latest

# Or use with a specific package manager
npx create-turbo@latest --use-pnpm
```

### Run tasks

```bash
# Run build task across all packages
turbo build

# Run multiple tasks
turbo build test lint

# Run with specific scope
turbo build --filter=@myapp/web

# Run in development mode with watch
turbo dev
```

### Configuration

Create a `turbo.json` file in your repository root:

```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    },
    "lint": {
      "outputs": []
    },
    "dev": {
      "cache": false
    }
  }
}
```

### Common Commands

```bash
# Check Turborepo version
turbo --version

# Run a task
turbo run build

# Run with caching disabled
turbo run build --force

# Dry run to see what would be executed
turbo run build --dry-run

# Generate task graph
turbo run build --graph

# Clear cache
turbo prune
```

### Remote Caching

Enable remote caching to share build artifacts with your team:

```bash
# Login to Vercel
turbo login

# Link your repository
turbo link

# Now builds will use remote cache automatically
turbo build
```

## OS Support

Works on any system with Node.js and npm installed, including:
- Ubuntu-based containers
- Debian-based containers
- Alpine Linux
- macOS

## Resources

- [Turborepo Documentation](https://turbo.build/repo/docs)
- [Getting Started Guide](https://turbo.build/repo/docs/getting-started)
- [GitHub Repository](https://github.com/vercel/turbo)
- [Examples](https://github.com/vercel/turbo/tree/main/examples)

