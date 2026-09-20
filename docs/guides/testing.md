# Testing Guide

The AI SDLC Harness project contains multiple testing suites to ensure the integrity of its shell installers, metadata, and the underlying AI agent behavior.

## Running Tests Locally

You can run all local testing suites simultaneously using the unified runner script at the root of the repository:

```bash
./run_tests.sh
```

This script creates `mcp-server/venv` if needed and runs the following suites in order. If `python3` is missing, steps 1–4 are skipped and the script still continues; if `bats` is missing, step 5 prints an error and the script still exits 0 with a success banner (Task 8.6). Step 1b (docs browser invariants) runs in that same Python block.

### 1. Metadata Validation
A custom Python script (`.github/scripts/validate_metadata.py`, CI workflow `.github/workflows/validate-metadata.yaml`) that strictly validates all `skill.yaml`, `agent.yaml`, and `rule.yaml` files against the schema (requiring Name, Description, Version, Author, and checking directory matching). Cursor's required primary file is `cursor/prompt.md`.

### 1b. Docs browser catalog invariants
`tests/docs_browser/test_dynamic_catalog.py` checks that `docs/browser/` stays a thin shell: relative asset URLs, default `mjbvilhena/ai-sdlc-harness@master`, live git-tree discovery, and **no hardcoded skill or MCP filename inventory**. The same check runs in `.github/workflows/pages.yaml` on every PR.

### 2. MCP Server Unit Tests
Standard `pytest` unit tests (`mcp-server/tests/test_server.py`) that evaluate the MCP Python Server. This tests the fuzzy matching logic (`thefuzz`) and verifies that Dynamic Consultants correctly scan the mock workspace for `DOMAIN.md` and `LAYER.md` files. On disk there are **27** templates (including `product_spec.md`, `research.md`, `repository_setup.md`, `lifecycle_pipeline.md`, `ux_design.md`, and `docs_backlog_review.md`) and **13** Definitions of Done. `test_catalog_templates_and_dod` asserts the same 27 / 13 names. Remaining alias/regression coverage for older payloads is Task 10.9. These tests run locally via `./run_tests.sh`; GitHub Actions does **not** run `pytest` today (Task 8.7).

### 3. Python Security Scan (Bandit)
`run_tests.sh` runs Bandit against `mcp-server/` (excluding tests and `venv`) when Python is available. The same scan runs in CI via `.github/workflows/security.yaml`.

### 4. End-to-End (E2E) LLM Testing
Appended only when `GEMINI_API_KEY` or `gemini_api_key` is set. See the E2E section below. `run_tests.sh` runs `pytest ../tests/e2e/` (both `test_agent_behavior.py` and `test_cli_integration.py`).

### 5. BATS (Bash Automated Testing System)
BATS (`tests/bats/installers.bats`) evaluates the shell installer scripts under `install/` (`install_claude.sh`, `install_cursor.sh`, `install_ghcp.sh`, `install_agy.sh`). The suite covers dry-run (no files written), global vs `--workspace` paths, PWD default for Cursor/GHCP, idempotent re-runs, MCP **merge** (existing sibling servers are kept and `sdlc-knowledge` is added), flag/path errors, a missing `agents/` directory, `CONTENT.md` expansion, `sdlc-` destination naming, and cleanup of stale `sdlc-*` artifacts (neighbors without the prefix survive; dry-run reports cleanup without deleting). Cursor destinations under test are `<ws>/.cursor/commands/sdlc-*.md`. It uses a transient mock `$HOME` and workspace so your real machine config is not touched.

MCP merge assertions exist for Cursor and GHCP only (no Claude/AGY merge cases — Task 12.4). Uninstallers (`install/uninstall_*.sh`) and the PowerShell twins are **not** covered by this BATS file.

### 6. Gitleaks Secret Scan
Run locally when the `gitleaks` binary is installed; always run in CI (`.github/workflows/security.yaml`).

---

## End-to-End (E2E) LLM Testing

To ensure that the Tri-Dimensional Framework functions correctly, we have an E2E testing framework. `tests/e2e/test_agent_behavior.py` invokes a real LLM (Gemini) headlessly with a **stub** `get_domain_consultant` function (it does not start `mcp-server`) and checks that the expanded skill prompt applies a domain constraint. `tests/e2e/test_cli_integration.py` optionally drives installed `agy` / `claude` CLIs when those binaries are present. `run_tests.sh` runs the whole `tests/e2e/` directory.

Because this test executes a real LLM, it requires an API key. **`./run_tests.sh` skips the E2E directory when the key is unset.** Running `pytest tests/e2e/test_agent_behavior.py` directly **fails** (`pytest.fail`) if the key is missing — it does not skip (Task 8.8). CI does not run E2E.

### Running E2E Tests Locally

1. Export your Gemini API Key in your terminal:
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   ```

2. Run the `run_tests.sh` script again. It will automatically detect the environment variable and run `pytest` against `tests/e2e/` as step 4 (before BATS and Gitleaks):
   ```bash
   ./run_tests.sh
   ```

*(Note: Linux environment variables are case-sensitive. The test runner accepts either `GEMINI_API_KEY` or `gemini_api_key`).*

## CI Pipelines (GitHub Actions)

Every Pull Request automatically executes the following CI checks:
1. **BATS Tests**: Runs the installer evaluation matrix (`.github/workflows/bats.yaml`).
2. **Linting** (`.github/workflows/lint.yaml`):
   - `shellcheck` on `./install` (installers, uninstallers, and `lib/`).
   - `markdownlint` on `**/*.md`.
3. **Metadata Validation** (`.github/workflows/validate-metadata.yaml`): Ensures no malformed or undocumented skills are merged into the library.
4. **Security Scans**: Gitleaks + Bandit (`.github/workflows/security.yaml`).
5. **GitHub Pages** (`.github/workflows/pages.yaml`):
   - Validates the docs-browser shell on every PR.
   - **`e2e-pr`**: Playwright against a local `docs/browser/` server with a mocked GitHub API.
   - **`deploy`** + **`e2e-live`**: on `master` / `main`. Pages source is already GitHub Actions; the live catalog is `https://mjbvilhena.github.io/ai-sdlc-harness/`. Live e2e hits that URL (or the deploy `page_url`) after the site returns HTTP 200.

MCP `pytest` (`mcp-server/tests/`) and E2E are **not** GitHub Actions jobs. Catalog and alias regressions only fail locally until Task 8.7.

## Security Scanning

This repository is protected by automated security workflows (`.github/workflows/security.yaml`):

1. **Gitleaks (Secret Scanning)**: Automatically scans all commits in a PR to ensure no API keys, passwords, or tokens are accidentally merged into the repository.
2. **Bandit (Python SAST)**: Statically analyzes the Python code in the `mcp-server/` directory to identify common security vulnerabilities before they reach production.

### Real IDE CLI Integration Tests (Headless)
We also include `tests/e2e/test_cli_integration.py` which dynamically checks if you have the `agy` or `claude` CLI installed on your machine. If it detects them, it will use Python's `subprocess` to spawn a headless, non-interactive execution (e.g., `agy -p "/sdlc-example-skill"` — the installed AGY dest name; `skill.yaml` trigger is `/example`) to ensure that the installed skills actually load and execute in a real production binary.
*(Note: If your local CLI is out of credits or requires interactive authentication, this test will gracefully skip itself).*
