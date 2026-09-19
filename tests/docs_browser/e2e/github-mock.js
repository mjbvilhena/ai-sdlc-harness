const fs = require("fs");
const path = require("path");

const FIXTURES = path.join(__dirname, "fixtures");

const TREE = {
  truncated: false,
  sha: "fixture",
  tree: [
    { type: "blob", path: "skills/sample-alpha/skill.yaml" },
    { type: "blob", path: "skills/sample-alpha/CONTENT.md" },
    { type: "blob", path: "skills/sample-beta/skill.yaml" },
    { type: "blob", path: "skills/sample-beta/CONTENT.md" },
    { type: "blob", path: "mcp-server/data/templates/note.md" },
    { type: "blob", path: "mcp-server/data/dod/done.md" }
  ]
};

const FILES = {
  "skills/sample-alpha/skill.yaml": fs.readFileSync(path.join(FIXTURES, "sample-alpha.yaml"), "utf8"),
  "skills/sample-alpha/CONTENT.md": fs.readFileSync(path.join(FIXTURES, "sample-alpha.md"), "utf8"),
  "skills/sample-beta/skill.yaml": fs.readFileSync(path.join(FIXTURES, "sample-beta.yaml"), "utf8"),
  "skills/sample-beta/CONTENT.md": fs.readFileSync(path.join(FIXTURES, "sample-beta.md"), "utf8"),
  "mcp-server/data/templates/note.md": fs.readFileSync(path.join(FIXTURES, "note.md"), "utf8"),
  "mcp-server/data/dod/done.md": fs.readFileSync(path.join(FIXTURES, "done.md"), "utf8")
};

function decodeRawPath(url) {
  const parsed = new URL(url);
  const parts = parsed.pathname.split("/").filter(Boolean);
  return parts.slice(3).map(decodeURIComponent).join("/");
}

async function installGitHubMocks(page) {
  await page.route("https://api.github.com/**", async (route) => {
    const url = route.request().url();
    if (url.includes("/git/trees/")) {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify(TREE)
      });
      return;
    }
    await route.fulfill({ status: 404, body: "not mocked" });
  });

  await page.route("https://raw.githubusercontent.com/**", async (route) => {
    const filePath = decodeRawPath(route.request().url());
    const body = FILES[filePath];
    if (body == null) {
      await route.fulfill({ status: 404, body: "missing fixture " + filePath });
      return;
    }
    await route.fulfill({ status: 200, contentType: "text/plain; charset=utf-8", body });
  });
}

async function installLiveApiAuth(page) {
  const token = process.env.GITHUB_TOKEN;
  if (!token) {
    return;
  }
  await page.route("https://api.github.com/**", async (route) => {
    const res = await fetch(route.request().url(), {
      headers: {
        Accept: "application/vnd.github+json",
        Authorization: "Bearer " + token,
        "User-Agent": "ai-sdlc-harness-docs-e2e"
      }
    });
    const body = Buffer.from(await res.arrayBuffer());
    const headers = {};
    const contentType = res.headers.get("content-type");
    if (contentType) {
      headers["content-type"] = contentType;
    }
    await route.fulfill({ status: res.status, headers, body });
  });
}

module.exports = { installGitHubMocks, installLiveApiAuth };
