const { test, expect } = require("@playwright/test");
const { installGitHubMocks, installLiveApiAuth } = require("./github-mock");

const mocked = process.env.MOCK_GITHUB === "1";

async function assertCatalogHealthy(page) {
  const error = page.locator("[data-catalog-error]");
  if (await error.count()) {
    const text = (await error.first().innerText()).trim();
    throw new Error(
      /rate limit/i.test(text)
        ? "GitHub API rate limit while loading the catalog: " + text
        : "Catalog discovery error: " + text
    );
  }
  const empty = page.locator("[data-catalog-empty]");
  if (await empty.count()) {
    throw new Error("Catalog discovery returned no skills or MCP data files.");
  }
}

async function waitForHome(page) {
  await page.goto("./");
  await expect(
    page.locator('[data-catalog-error], [data-catalog="skills"] [data-catalog-item="skill"]').first()
  ).toBeVisible({ timeout: 45_000 });
  await expect(page.locator("[data-catalog-loading]")).toHaveCount(0);
  await assertCatalogHealthy(page);
  await expect(page.locator('[data-catalog="skills"] [data-catalog-item="skill"]').first()).toBeVisible();
}

test.beforeEach(async ({ page }) => {
  if (mocked) {
    await installGitHubMocks(page);
  } else {
    await installLiveApiAuth(page);
  }
});

test("home lists skills, templates, and DoD from discovery", async ({ page }) => {
  await waitForHome(page);

  const skills = page.locator('[data-catalog="skills"] [data-catalog-item="skill"]');
  const templates = page.locator('[data-catalog="templates"] [data-catalog-item="doc"]');
  const dod = page.locator('[data-catalog="dod"] [data-catalog-item="doc"]');

  await expect(skills, "expected at least one discovered skill").not.toHaveCount(0);
  await expect(templates, "expected at least one discovered template").not.toHaveCount(0);
  await expect(dod, "expected at least one discovered DoD").not.toHaveCount(0);

  if (mocked) {
    await expect(skills).toHaveCount(2);
    await expect(templates).toHaveCount(1);
    await expect(dod).toHaveCount(1);
  }
});

test("search filter hides non-matching cards", async ({ page }) => {
  await waitForHome(page);
  const skills = page.locator('[data-catalog="skills"] [data-catalog-item="skill"]');
  const name = (await skills.first().locator("h3").innerText()).trim();
  expect(name.length, "skill card is missing a name").toBeGreaterThan(0);

  await page.locator("#catalog-filter").fill(name);
  const visible = page.locator('[data-catalog="skills"] [data-catalog-item="skill"]:not(.hidden)');
  await expect(visible).toHaveCount(1);
  await expect(visible.first().locator("h3")).toHaveText(name);
});

test("skill detail renders markdown body", async ({ page }) => {
  await waitForHome(page);
  await page.locator('[data-catalog="skills"] [data-catalog-item="skill"]').first().click();
  await expect(page.locator("[data-catalog-loading]")).toHaveCount(0);
  await assertCatalogHealthy(page);
  const body = page.locator('[data-catalog-body="skill"]');
  await expect(body).toBeVisible();
  await expect(body).not.toHaveText(/^\s*$/);
  if (mocked) {
    await expect(body).toContainText("ALPHA_MARKDOWN_BODY");
  }
});

test("template and DoD details render markdown bodies", async ({ page }) => {
  await waitForHome(page);
  await page.locator('[data-catalog="templates"] [data-catalog-item="doc"]').first().click();
  await expect(page.locator("[data-catalog-loading]")).toHaveCount(0);
  await assertCatalogHealthy(page);
  const templateBody = page.locator('[data-catalog-body="doc"]');
  await expect(templateBody).toBeVisible();
  await expect(templateBody).not.toHaveText(/^\s*$/);
  if (mocked) {
    await expect(templateBody).toContainText("TEMPLATE_MARKDOWN_BODY");
  }

  await page.locator('nav.site-nav a', { hasText: "Definitions of Done" }).click();
  await expect(page.locator('[data-catalog="dod"] [data-catalog-item="doc"]').first()).toBeVisible();
  await page.locator('[data-catalog="dod"] [data-catalog-item="doc"]').first().click();
  await assertCatalogHealthy(page);
  const dodBody = page.locator('[data-catalog-body="doc"]');
  await expect(dodBody).toBeVisible();
  await expect(dodBody).not.toHaveText(/^\s*$/);
  if (mocked) {
    await expect(dodBody).toContainText("DOD_MARKDOWN_BODY");
  }
});

test("rate-limited GitHub API shows a clear error", async ({ page }) => {
  test.skip(!mocked, "injects a 403; live post-deploy e2e should not fake a rate limit");
  await page.unroute("https://api.github.com/**");
  await page.route("https://api.github.com/**", (route) =>
    route.fulfill({ status: 403, body: '{"message":"API rate limit exceeded"}' })
  );
  await page.goto("./");
  const error = page.locator("[data-catalog-error]");
  await expect(error).toBeVisible();
  await expect(error).toContainText(/rate limit/i);
});
