# Playwright

A devcontainer feature that installs Playwright for end-to-end testing with browser automation.

## Example Usage

```json
"features": {
    "ghcr.io/your-username/stripe-cli/playwright:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of Playwright to install | string | latest |
| browsers | Which browsers to install (chromium, firefox, webkit, or 'all') | string | all |
| installDependencies | Install system dependencies required by browsers | boolean | true |

## Supported Versions

- `latest` - Latest stable Playwright (recommended)
- `1.40` - Playwright 1.40.x
- `1.39` - Playwright 1.39.x
- `1.38` - Playwright 1.38.x

## Browser Options

- `all` - Install Chromium, Firefox, and WebKit (default)
- `chromium` - Install only Chromium
- `firefox` - Install only Firefox
- `webkit` - Install only WebKit
- `chromium firefox` - Install Chromium and Firefox
- `chromium webkit` - Install Chromium and WebKit

## Example with Options

```json
"features": {
    "ghcr.io/your-username/stripe-cli/playwright:1": {
        "version": "latest",
        "browsers": "chromium firefox",
        "installDependencies": true
    }
}
```

## Prerequisites

**Important:** This feature requires Node.js to be installed. Make sure to include the Node.js feature in your devcontainer:

```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/your-username/stripe-cli/playwright:1": {}
}
```

## What's Included

This feature installs:

- `@playwright/test` - The Playwright test runner
- Browser binaries (Chromium, Firefox, and/or WebKit)
- System dependencies required by the browsers
- Playwright CLI for code generation and debugging

## Quick Start

After installation, initialize Playwright in your project:

```bash
# Initialize a new Playwright project
npm init playwright@latest

# Run tests
npx playwright test

# Run tests with UI mode
npx playwright test --ui

# Debug tests
npx playwright test --debug
```

## Common Commands

```bash
# Check Playwright version
playwright --version

# Generate test code by recording interactions
npx playwright codegen https://example.com

# View test report
npx playwright show-report

# Install additional browsers later
npx playwright install webkit
```

## Example Test

```javascript
import { test, expect } from '@playwright/test';

test('homepage has title', async ({ page }) => {
  await page.goto('https://playwright.dev/');
  await expect(page).toHaveTitle(/Playwright/);
});
```

For more detailed usage information, see [NOTES.md](NOTES.md).

---

_Note: This feature installs Playwright globally. For project-specific installations, you can still use `npm install -D @playwright/test` in your project._

