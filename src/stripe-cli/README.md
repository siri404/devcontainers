
# Stripe CLI (stripe-cli)

Installs the Stripe CLI for interacting with Stripe APIs

## Example Usage

```json
"features": {
    "ghcr.io/siri404/devcontainers/stripe-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of Stripe CLI to install | string | latest |

## About the Stripe CLI

The [Stripe CLI](https://docs.stripe.com/stripe-cli) is a developer tool to help you build, test, and manage your Stripe integration right from the terminal.

With the Stripe CLI, you can:
- Securely test webhooks without relying on 3rd party software
- Trigger webhook events to test your integration
- Tail your API request logs in real-time
- Create, retrieve, update, and delete API objects

## Installation Methods

This feature uses Stripe's official installation methods:

1. **Primary**: [APT installation](https://docs.stripe.com/stripe-cli/install?install-method=apt) for Debian/Ubuntu-based containers
2. **Fallback**: Direct binary download from [GitHub releases](https://github.com/stripe/stripe-cli/releases) for other systems

The installer automatically detects your OS and architecture, choosing the best installation method.

## Usage

### Authentication

Once installed, authenticate with your Stripe account:

```bash
# Login to your Stripe account (interactive browser authentication)
stripe login

# Or use API key for non-interactive environments (e.g., CI/CD)
stripe login --api-key sk_test_your_key_here
```

### Common Commands

```bash
# Listen for webhooks and forward to your local server
stripe listen --forward-to localhost:3000/webhook

# Trigger a test webhook event
stripe trigger payment_intent.succeeded

# Make API requests
stripe customers list --limit 5

# Create test data
stripe customers create --email="test@example.com"

# View real-time API logs
stripe logs tail

# Get help
stripe --help
```

## OS and Architecture Support

This feature supports:
- **Linux distributions**: Debian, Ubuntu, Raspbian, and other distributions
- **Architectures**: x86_64, arm64, arm, i386

The installer automatically detects your system configuration and uses the appropriate installation method.

## Resources

- [Stripe CLI Documentation](https://docs.stripe.com/stripe-cli)
- [Stripe CLI GitHub Repository](https://github.com/stripe/stripe-cli)
- [Installation Guide](https://docs.stripe.com/stripe-cli/install)
- [CLI Reference](https://docs.stripe.com/cli)



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/siri404/devcontainers/blob/main/src/stripe-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
