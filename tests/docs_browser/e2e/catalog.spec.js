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
    await expect(templates).toHaveCount(2);
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
  const templateCard = mocked
    ? page.locator('[data-catalog="templates"] [data-catalog-item="doc"]').filter({ hasText: "note.md" })
    : page.locator('[data-catalog="templates"] [data-catalog-item="doc"]').first();
  await templateCard.click();
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

async function expectRenderedMermaid(host, mark) {
  await expect(host).toHaveAttribute("data-mermaid-status", "ready", { timeout: 45_000 });
  await expect(host.locator("svg")).toBeVisible();
  await expect(host.locator("pre code.language-mermaid")).toHaveCount(0);
  if (mark) {
    await expect(host).toContainText(mark);
  }
}

test("home renders the lifecycle pipeline mermaid from the template", async ({ page }) => {
  await waitForHome(page);
  const diagram = page.locator("[data-home-pipeline-diagram]");
  await expect(page.locator("[data-home-pipeline]")).toBeVisible();
  await expectRenderedMermaid(diagram, mocked ? "HOME_PIPELINE_MARK" : null);
  await expect(page.locator("[data-home-pipeline-error]")).toHaveCount(0);
  await expect(diagram).toContainText(/sdlc-threat-modeler/i);
  await expect(diagram).toContainText(/sdlc-security-reviewer/i);
  await expect(diagram).toContainText(/sdlc-bug-triager/i);
  await expect(diagram).toContainText(/sdlc-pr-summarizer/i);
  await expect(diagram).toContainText(/sdlc-test-planner/i);
  await expect(diagram).toContainText(/sdlc-implementer/i);
  await expect(diagram).toContainText(/unmet Must AC/i);
  await expect(diagram).toContainText(/needs changes/i);
  await expect(diagram).toContainText(/red automation/i);
  await expect(diagram).toContainText(/blocking findings/i);
  if (!mocked) {
    await expect(diagram).toContainText(/sdlc-conductor/i);
    await expect(diagram).toContainText(/sdlc-user-story-refiner/i);
  }
});

test("skill, template, and DoD mermaid fences render as diagrams", async ({ page }) => {
  await waitForHome(page);

  if (mocked) {
    await page.locator('[data-catalog="skills"] [data-catalog-item="skill"]').first().click();
    await expect(page.locator("[data-catalog-loading]")).toHaveCount(0);
    await assertCatalogHealthy(page);
    const skillHost = page.locator('[data-catalog-body="skill"] [data-mermaid-diagram]');
    await expectRenderedMermaid(skillHost, "SKILL_MERMAID_MARK");
    await expect(page.locator('[data-catalog-body="skill"] pre code.language-mermaid')).toHaveCount(0);
    await page.goto("./");
    await expect(page.locator('[data-catalog="templates"] [data-catalog-item="doc"]').first()).toBeVisible();
  }

  const templateCard = page
    .locator('[data-catalog="templates"] [data-catalog-item="doc"]')
    .filter({ hasText: /lifecycle/i });
  await expect(templateCard).toBeVisible();
  await templateCard.click();
  await expect(page.locator("[data-catalog-loading]")).toHaveCount(0);
  await assertCatalogHealthy(page);
  const templateHost = page.locator('[data-catalog-body="doc"] [data-mermaid-diagram]');
  await expectRenderedMermaid(templateHost, mocked ? "HOME_PIPELINE_MARK" : null);
  await expect(page.locator('[data-catalog-body="doc"] pre code.language-mermaid')).toHaveCount(0);
  await expect(templateHost).toContainText(/sdlc-threat-modeler/i);
  await expect(templateHost).toContainText(/sdlc-security-reviewer/i);
  await expect(templateHost).toContainText(/sdlc-test-planner/i);
  await expect(templateHost).toContainText(/sdlc-implementer/i);
  await expect(templateHost).toContainText(/unmet Must AC/i);
  await expect(templateHost).toContainText(/needs changes/i);
  await expect(templateHost).toContainText(/red automation/i);
  if (!mocked) {
    await expect(templateHost).toContainText(/sdlc-conductor/i);
    await expect(templateHost).toContainText(/sdlc-user-story-refiner/i);
  }

  if (mocked) {
    await page.locator('nav.site-nav a', { hasText: "Definitions of Done" }).click();
    await page.locator('[data-catalog="dod"] [data-catalog-item="doc"]').first().click();
    await assertCatalogHealthy(page);
    const dodHost = page.locator('[data-catalog-body="doc"] [data-mermaid-diagram]');
    await expectRenderedMermaid(dodHost, "DOD_MERMAID_MARK");
    await expect(page.locator('[data-catalog-body="doc"] pre code.language-mermaid')).toHaveCount(0);
  }
});

test("home shows an error when the lifecycle pipeline template cannot be read", async ({ page }) => {
  test.skip(!mocked, "injects a 404; live e2e should not hide the real template");
  await page.route("https://raw.githubusercontent.com/**", async (route) => {
    if (route.request().url().includes("lifecycle_pipeline.md")) {
      await route.fulfill({ status: 404, body: "missing pipeline" });
      return;
    }
    await route.fallback();
  });
  await page.goto("./");
  await expect(page.locator('[data-catalog="skills"] [data-catalog-item="skill"]').first()).toBeVisible({
    timeout: 45_000
  });
  const error = page.locator("[data-home-pipeline-error]");
  await expect(error).toBeVisible();
  await expect(error).toContainText(/could not read|lifecycle pipeline/i);
  await expect(page.locator("[data-home-pipeline-diagram] svg")).toHaveCount(0);
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
