#!/bin/bash
set -e

echo "Activating feature 'stripe-cli'"

curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor | sudo tee /usr/share/keyrings/stripe.gpg && echo 'deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main' | sudo tee -a /etc/apt/sources.list.d/stripe.list && sudo apt update && sudo apt install stripe"

INSTALLED_VERSION=$(stripe --version 2>&1 | head -n1)
echo "✓ Stripe CLI verified: $INSTALLED_VERSION"

# Success message
echo ""
echo "✓ Stripe CLI feature installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  To authenticate with Stripe, run:"
echo "    stripe login"
echo ""
echo "  For more information, visit:"
echo "    https://docs.stripe.com/stripe-cli"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
