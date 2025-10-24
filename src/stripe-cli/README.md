# Stripe CLI (stripe-cli)

Installs the Stripe CLI, a command-line tool for interacting with Stripe APIs.

## Example Usage

```json
"features": {
    "ghcr.io/your-org/stripe-cli/stripe-cli:1": {
        "version": "latest"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of Stripe CLI to install | string | latest |

## About the Stripe CLI

The Stripe CLI is a developer tool to help you build, test, and manage your Stripe integration right from the terminal.

With the Stripe CLI, you can:
- Securely test webhooks without relying on 3rd party software
- Trigger webhook events to test your integration
- Tail your API request logs in real-time
- Create, retrieve, update, and delete API objects

## Usage

Once installed, you can use the `stripe` command:

```bash
# Login to your Stripe account
stripe login

# Listen for webhooks
stripe listen --forward-to localhost:3000/webhook

# Trigger a test webhook event
stripe trigger payment_intent.succeeded

# Make API requests
stripe customers list --limit 5
```

For more information, visit the [Stripe CLI documentation](https://stripe.com/docs/stripe-cli).

## OS Support

This feature should work on Linux and macOS (Darwin) containers with x86_64 or arm64 architectures.

