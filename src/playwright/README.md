
# Playwright (playwright)

Installs Playwright for end-to-end testing with browser automation

## Example Usage

```json
"features": {
    "ghcr.io/siri404/devcontainers/playwright:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of Playwright to install | string | latest |
| browsers | Which browsers to install (chromium, firefox, webkit, or 'all') | string | all |
| installDependencies | Install system dependencies required by browsers | boolean | true |

## About Playwright

Playwright is a modern end-to-end testing framework for web applications. It provides:

- **Cross-browser testing** - Test on Chromium, Firefox, and WebKit
- **Auto-wait functionality** - Automatically waits for elements to be ready
- **Powerful assertions** - Built-in test assertions and matchers
- **Network interception** - Mock and modify network requests
- **Screenshots & videos** - Capture visual evidence of test runs
- **Parallel execution** - Run tests in parallel for faster feedback
- **Debugging tools** - Interactive debugging and trace viewer

## Installation Method

This feature installs:
1. The `@playwright/test` npm package globally
2. Browser binaries (Chromium, Firefox, and/or WebKit)
3. System dependencies required by the browsers

## Usage

### Initialize Playwright in Your Project

```bash
# Initialize a new Playwright project
npm init playwright@latest

# Or install in an existing project
npm install -D @playwright/test
npx playwright install
```

### Writing Tests

Create a test file (e.g., `tests/example.spec.ts`):

```javascript
import { test, expect } from '@playwright/test';

test('basic test', async ({ page }) => {
  await page.goto('https://playwright.dev/');
  
  // Expect a title "to contain" a substring
  await expect(page).toHaveTitle(/Playwright/);
  
  // Click a link
  await page.getByRole('link', { name: 'Get started' }).click();
  
  // Expect URL to contain "intro"
  await expect(page).toHaveURL(/.*intro/);
});
```

### Running Tests

```bash
# Run all tests
npx playwright test

# Run tests in headed mode (see the browser)
npx playwright test --headed

# Run tests in a specific browser
npx playwright test --project=chromium
npx playwright test --project=firefox
npx playwright test --project=webkit

# Run a specific test file
npx playwright test tests/example.spec.ts

# Run tests in debug mode
npx playwright test --debug

# Run tests with UI mode (interactive)
npx playwright test --ui
```

### Configuration

Playwright is configured via `playwright.config.ts`:

```javascript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  
  // Run tests in files in parallel
  fullyParallel: true,
  
  // Fail the build on CI if you accidentally left test.only
  forbidOnly: !!process.env.CI,
  
  // Retry on CI only
  retries: process.env.CI ? 2 : 0,
  
  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,
  
  // Reporter to use
  reporter: 'html',
  
  use: {
    // Base URL to use in actions like `await page.goto('/')`
    baseURL: 'http://localhost:3000',
    
    // Collect trace when retrying the failed test
    trace: 'on-first-retry',
    
    // Screenshot on failure
    screenshot: 'only-on-failure',
  },

  // Configure projects for major browsers
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],

  // Run your local dev server before starting the tests
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Common Test Patterns

#### Navigation and Assertions

```javascript
test('navigation test', async ({ page }) => {
  // Navigate to a page
  await page.goto('https://example.com');
  
  // Check page title
  await expect(page).toHaveTitle('Example Domain');
  
  // Check URL
  await expect(page).toHaveURL('https://example.com/');
});
```

#### Interacting with Elements

```javascript
test('form interaction', async ({ page }) => {
  await page.goto('https://example.com/login');
  
  // Fill input fields
  await page.fill('input[name="email"]', 'user@example.com');
  await page.fill('input[name="password"]', 'password123');
  
  // Click button
  await page.click('button[type="submit"]');
  
  // Wait for navigation
  await page.waitForURL('**/dashboard');
  
  // Check element visibility
  await expect(page.locator('.welcome-message')).toBeVisible();
});
```

#### Taking Screenshots

```javascript
test('screenshot example', async ({ page }) => {
  await page.goto('https://example.com');
  
  // Full page screenshot
  await page.screenshot({ path: 'screenshot.png', fullPage: true });
  
  // Element screenshot
  await page.locator('.header').screenshot({ path: 'header.png' });
});
```

#### Network Mocking

```javascript
test('mock API response', async ({ page }) => {
  // Mock API call
  await page.route('**/api/data', route => {
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ message: 'Mocked response' })
    });
  });
  
  await page.goto('https://example.com');
});
```

### Viewing Test Results

```bash
# Show last test report
npx playwright show-report

# View trace of a failed test
npx playwright show-trace trace.zip
```

### Debugging

```bash
# Debug mode (step through tests)
npx playwright test --debug

# Debug a specific test
npx playwright test example.spec.ts:10 --debug

# Run with browser visible
npx playwright test --headed --workers=1
```

### Code Generation

```bash
# Record interactions and generate test code
npx playwright codegen https://example.com

# Generate code with specific device
npx playwright codegen --device="iPhone 13" https://example.com
```

## Browser Options

When configuring this feature, you can choose which browsers to install:

- **all** - Install Chromium, Firefox, and WebKit (default)
- **chromium** - Install only Chromium
- **firefox** - Install only Firefox
- **webkit** - Install only WebKit
- **chromium firefox** - Install Chromium and Firefox
- **chromium webkit** - Install Chromium and WebKit

## Version Support

This feature supports Playwright versions:
- **latest** - Latest stable version (recommended)
- **1.40** - Playwright 1.40.x
- **1.39** - Playwright 1.39.x
- **1.38** - Playwright 1.38.x

## OS Support

Works on Debian and Ubuntu-based containers including:
- Ubuntu (all versions)
- Debian (Bullseye, Bookworm, etc.)
- Derivative distributions

## Resources

- [Playwright Documentation](https://playwright.dev/)
- [Playwright API Reference](https://playwright.dev/docs/api/class-playwright)
- [Best Practices](https://playwright.dev/docs/best-practices)
- [Playwright GitHub](https://github.com/microsoft/playwright)

## Tips

1. **Use `page.waitForSelector()` sparingly** - Playwright has built-in auto-waiting
2. **Prefer user-facing selectors** - Use `getByRole`, `getByLabel`, `getByText` instead of CSS selectors
3. **Run tests in parallel** - Configure `workers` in `playwright.config.ts`
4. **Use fixtures** - Create reusable test fixtures for common setup
5. **Enable tracing on CI** - Set `trace: 'on-first-retry'` to debug CI failures




---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/siri404/devcontainers/blob/main/src/playwright/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
