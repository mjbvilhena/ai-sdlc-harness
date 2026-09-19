# GitHub Pages catalog browser

A thin static shell under `docs/browser/` lists **skills** and **MCP knowledge files** in the browser. It does **not** bake a per-skill HTML tree at build time. The inventory is discovered at runtime from the public GitHub repo (default `mjbvilhena/ai-sdlc-harness` @ `master`).

After merge, new `skills/*/skill.yaml` packages and new markdown under `mcp-server/data/*/` show up on **refresh**. You do not need to edit the site or wait for a content rebuild.

## One-time repo setting

Pages is not enabled on this repository until someone sets it:

**Settings → Pages → Source = GitHub Actions**

Until that is set, the deploy job on `master` may fail. The pull-request job only validates the shell; it does not deploy.

The live site (project Pages) is:

`https://mjbvilhena.github.io/ai-sdlc-harness/`

Asset URLs in `docs/browser/index.html` are **relative**, so the same folder also works at that subpath and when served locally.

## How it is wired

`.github/workflows/pages.yaml`:

- Runs on **push** to `master` / `main`, on **pull requests** to those branches, and on **workflow_dispatch**
- **Always** runs `python3 tests/docs_browser/test_dynamic_catalog.py` (no hardcoded skill or MCP filename inventory in the shell)
- **Uploads and deploys** only on `master` / `main` (not on PRs), using `actions/upload-pages-artifact` and `actions/deploy-pages`, with `permissions: pages: write` + `id-token: write` and the `github-pages` environment

There is no `gh-pages` branch.

## What the browser does

1. One GitHub **git tree** request (`/git/trees/{ref}?recursive=1`), cached in `sessionStorage`
2. Treats every `skills/<name>/skill.yaml` or `CONTENT.md` as a skill
3. Treats every `mcp-server/data/<dir>/*.md` as a catalog document (`templates/`, `dod/`, and any later data directory)
4. Loads file bodies from `raw.githubusercontent.com` when you open an item (also cached in `sessionStorage`)
5. Renders markdown in the page; skill cards use `skill.yaml` description / targets / triggers / version

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

## Adding catalog entries

Do not edit `docs/browser/` to advertise a new skill or template. Add the files on `master` in the usual place:

- Skills: `skills/<name>/skill.yaml` and `skills/<name>/CONTENT.md`
- MCP: `mcp-server/data/templates/*.md` or `mcp-server/data/dod/*.md` (or another folder under `mcp-server/data/`)
