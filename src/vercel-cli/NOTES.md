## About Vercel CLI

The [Vercel CLI](https://vercel.com/docs/cli) is a command-line interface for deploying and managing applications on Vercel's cloud platform. Features include:

- **Instant Deployments** - Deploy your apps with a single command
- **Preview Deployments** - Automatic previews for every push
- **Environment Variables** - Manage secrets and environment variables
- **Domain Management** - Configure custom domains
- **Project Management** - Create and manage Vercel projects
- **Local Development** - Run your project locally with Vercel dev
- **Team Collaboration** - Work with teams and manage permissions

## Installation Method

This feature installs Vercel CLI globally using npm. It requires Node.js and npm to be installed first.

## Prerequisites

**Important**: This feature requires Node.js to be installed. Make sure to include the Node.js feature before Vercel CLI:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/YOUR_USERNAME/stripe-cli/vercel-cli:1": {}
  }
}
```

## Usage

### Authentication

```bash
# Login to Vercel
vercel login

# Or authenticate with token
vercel login --token YOUR_TOKEN
```

### Deployment

```bash
# Deploy to preview
vercel

# Deploy to production
vercel --prod

# Deploy with specific name
vercel --name my-app

# Deploy from a specific directory
vercel ./dist --prod
```

### Local Development

```bash
# Start development server
vercel dev

# Start on specific port
vercel dev --port 3001
```

### Project Management

```bash
# Link to existing project
vercel link

# Create new project
vercel project add my-project

# List all projects
vercel projects list

# Remove project
vercel project rm my-project
```

### Environment Variables

```bash
# Add environment variable
vercel env add MY_SECRET

# Pull environment variables
vercel env pull

# List environment variables
vercel env ls

# Remove environment variable
vercel env rm MY_SECRET
```

### Domain Management

```bash
# Add domain to project
vercel domains add example.com

# List domains
vercel domains ls

# Remove domain
vercel domains rm example.com
```

### Team Management

```bash
# Switch to team
vercel switch

# Invite team member
vercel teams invite user@example.com

# List team members
vercel teams ls
```

### Common Commands

```bash
# Check CLI version
vercel --version

# Get help
vercel --help

# View deployment logs
vercel logs

# List deployments
vercel ls

# Inspect a deployment
vercel inspect <deployment-url>

# Remove a deployment
vercel rm <deployment-url>

# Rollback to previous deployment
vercel rollback
```

### Alias Commands

The CLI also works with the shorter `vc` command:

```bash
vc              # Same as: vercel
vc --prod       # Same as: vercel --prod
vc dev          # Same as: vercel dev
```

## Framework Support

Vercel CLI has first-class support for many frameworks:
- Next.js
- React
- Vue.js
- Svelte
- Angular
- Nuxt
- Gatsby
- Hugo
- And many more

## CI/CD Integration

The Vercel CLI can be used in CI/CD pipelines:

```bash
# GitHub Actions example
- name: Deploy to Vercel
  run: |
    npm install -g vercel
    vercel deploy --prod --token=${{ secrets.VERCEL_TOKEN }}
```

## OS Support

Works on any system with Node.js and npm installed, including:
- Ubuntu-based containers
- Debian-based containers
- Alpine Linux
- macOS
- Windows

## Resources

- [Vercel CLI Documentation](https://vercel.com/docs/cli)
- [Vercel Platform Documentation](https://vercel.com/docs)
- [Deployment Guides](https://vercel.com/docs/deployments/overview)
- [GitHub Repository](https://github.com/vercel/vercel)
- [Vercel Blog](https://vercel.com/blog)

