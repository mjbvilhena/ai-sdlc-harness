const { defineConfig } = require("@playwright/test");
const path = require("path");

const rawBase = process.env.BASE_URL || "http://127.0.0.1:4173";
const baseURL = rawBase.endsWith("/") ? rawBase : rawBase + "/";
const isLocal = /localhost|127\.0\.0\.1/.test(baseURL);
const repoRoot = path.resolve(__dirname, "../../..");

module.exports = defineConfig({
  testDir: __dirname,
  testMatch: "**/*.spec.js",
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  timeout: 90_000,
  expect: { timeout: 20_000 },
  reporter: process.env.CI ? [["github"], ["list"]] : "list",
  use: {
    baseURL,
    browserName: "chromium",
    trace: "on-first-retry",
    screenshot: "only-on-failure"
  },
  webServer: isLocal
    ? {
        command: `python3 -m http.server 4173 --directory ${JSON.stringify(path.join(repoRoot, "docs/browser"))}`,
        url: "http://127.0.0.1:4173",
        reuseExistingServer: !process.env.CI,
        timeout: 30_000
      }
    : undefined
});
