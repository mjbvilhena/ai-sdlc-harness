# GitHub Pages catalog browser

A thin static shell under `docs/browser/` lists **skills** and **MCP knowledge files** in the browser. It does **not** bake a per-skill HTML tree at build time. The inventory is discovered at runtime from the public GitHub repo (default `mjbvilhena/ai-sdlc-harness` @ `master`).

After merge, new `skills/*/skill.yaml` packages and new markdown under `mcp-server/data/*/` show up on **refresh**. You do not need to edit the site or wait for a content rebuild.

## Pages source

Pages is **enabled**. Source is **GitHub Actions** (`build_type: workflow`). The live project site is:

`https://mjbvilhena.github.io/ai-sdlc-harness/`

`deploy` + `e2e-live` run on push to `master` / `main`. Pull requests run shell validation plus mocked Playwright (`e2e-pr`); they do not deploy.

Asset URLs in `docs/browser/index.html` are **relative**, so the same folder also works at that subpath and when served locally.

## How it is wired

`.github/workflows/pages.yaml`:

- Runs on **push** to `master` / `main`, on **pull requests** to those branches, and on **workflow_dispatch**
- **Always** runs `python3 tests/docs_browser/test_dynamic_catalog.py` (no hardcoded skill or MCP filename inventory in the shell)
- **PRs** also run Playwright UI e2e (`e2e-pr`) against a local static server with a **mocked** GitHub API (fixture catalog, not the live inventory)
- **Uploads and deploys** only on `master` / `main` (not on PRs), using `actions/upload-pages-artifact` and `actions/deploy-pages`, with `permissions: pages: write` + `id-token: write` and the `github-pages` environment
- After a successful **deploy** on `master` / `main`, job **`e2e-live`** hits the live Pages URL (waits/retries until HTTP 200, then Playwright). Post-merge path: merge → deploy → live UI e2e.

There is no `gh-pages` branch.

## What the browser does

1. One GitHub **git tree** request (`/git/trees/{ref}?recursive=1`), cached in `sessionStorage`
2. Treats every `skills/<name>/skill.yaml` or `CONTENT.md` as a skill
3. Treats every `mcp-server/data/<dir>/*.md` as a catalog document (`templates/`, `dod/`, and any later data directory)
4. Loads file bodies from `raw.githubusercontent.com` when you open an item (also cached in `sessionStorage`)
5. Renders markdown in the page; skill cards use `skill.yaml` description / targets / triggers / version
6. Turns mermaid fenced code blocks into diagrams via vendored `assets/mermaid.min.js` (dark theme, matching the catalog code-block well)
7. On **Home**, fetches the discovered lifecycle pipeline MCP template and renders its primary mermaid block (the flowchart under “Pipeline graph”). If that fetch or extract fails, Home shows an error — not a hard-coded duplicate graph.

Unauthenticated GitHub API traffic is limited (about 60 requests/hour/IP). The tree call is the expensive one; if GitHub returns 403/429, the UI shows a rate-limit message and will reuse a session cache when one exists. Override source with query parameters if needed: `?owner=…&repo=…&ref=…`.

The shell never reads `.env`, installer credentials, or other private files — only the skill and MCP data path patterns above.

## Preview locally

The catalog fetches GitHub from the browser, so open it over HTTP (not `file://`):

```bash
python3 tests/docs_browser/test_dynamic_catalog.py
python3 -m http.server 8080 --directory docs/browser
```

Then visit `http://127.0.0.1:8080/`. To point at a branch other than `master`:

`http://127.0.0.1:8080/?ref=your-branch`

## UI e2e (Playwright)

From `tests/docs_browser/e2e/` (Chromium):

```bash
cd tests/docs_browser/e2e
npm ci
npx playwright install chromium

# PR-style: local shell + mocked GitHub API (no live Pages, no API quota)
MOCK_GITHUB=1 npm test

# Against the deployed project Pages site
BASE_URL=https://mjbvilhena.github.io/ai-sdlc-harness/ npm test
```

`MOCK_GITHUB=1 npm test` also starts `python3 -m http.server` on port 4173 for `docs/browser/` when `BASE_URL` is unset. Tests assert discovery populated skills/templates/DoD, markdown detail pages, Mermaid diagrams (Home pipeline + fenced blocks), search, and a visible error on a mocked 403 rate limit. They do **not** hardcode the production skill/template inventory.

Live post-deploy e2e (`e2e-live` in CI) uses optional `GITHUB_TOKEN` only inside Playwright’s GitHub API route (never injected into the page) so Actions IPs are less likely to hit the unauthenticated 60/hour cap. Local live runs work unauthenticated.

## Adding catalog entries

Do not edit `docs/browser/` to advertise a new skill or template. Add the files on `master` in the usual place:

- Skills: `skills/<name>/skill.yaml` and `skills/<name>/CONTENT.md`
- MCP: `mcp-server/data/templates/*.md` or `mcp-server/data/dod/*.md` (or another folder under `mcp-server/data/`)
