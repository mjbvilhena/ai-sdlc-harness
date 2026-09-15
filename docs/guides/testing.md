# Testing Guide

The AI SDLC Harness project contains multiple testing suites to ensure the integrity of its shell installers, metadata, and the underlying AI agent behavior.

## Running Tests Locally

You can run all local testing suites simultaneously using the unified runner script at the root of the repository:

```bash
./run_tests.sh
```

This script creates `mcp-server/venv` if needed and runs the following suites (Bandit and Gitleaks are included when those tools are available; E2E is appended only when `GEMINI_API_KEY` is set):

### 1. Metadata Validation
A custom Python script (`.github/scripts/validate_metadata.py`) that strictly validates all `skill.yaml`, `agent.yaml`, and `rule.yaml` files against the schema (requiring Name, Description, Version, Author, and checking directory matching). Cursor's required primary file is `cursor/prompt.md`.

### 2. MCP Server Unit Tests
Standard `pytest` unit tests (`mcp-server/tests/test_server.py`) that evaluate the MCP Python Server. This tests the fuzzy matching logic (`thefuzz`) and verifies that Dynamic Consultants correctly scan the mock workspace for `DOMAIN.md` and `LAYER.md` files. On disk there are **22** templates (including `product_spec.md` from PR #9) and **11** Definitions of Done. `test_catalog_templates_and_dod` still asserts **21** template names and omits `product spec` — Task 10.8.

### 3. BATS (Bash Automated Testing System)
BATS (`tests/bats/installers.bats`) evaluates the shell installer scripts under `install/` (`install_claude.sh`, `install_cursor.sh`, `install_ghcp.sh`, `install_agy.sh`). The suite covers dry-run (no files written), global vs `--workspace` paths, PWD default for Cursor/GHCP, idempotent re-runs, MCP **merge** (existing sibling servers are kept and `sdlc-knowledge` is added), flag/path errors, a missing `agents/` directory, `CONTENT.md` expansion, `sdlc-` destination naming, and cleanup of stale `sdlc-*` artifacts (neighbors without the prefix survive; dry-run reports cleanup without deleting). Cursor destinations under test are `<ws>/.cursor/commands/sdlc-*.md`. It uses a transient mock `$HOME` and workspace so your real machine config is not touched.

Uninstallers (`install/uninstall_*.sh`) and the PowerShell twins are **not** covered by this BATS file.

---

## End-to-End (E2E) LLM Testing

To ensure that the Tri-Dimensional Framework functions correctly, we have an E2E testing framework (`tests/e2e/test_agent_behavior.py`). This framework actively invokes a real LLM (Gemini) headlessly to verify that the agent properly reaches out to the MCP Server tools and applies architectural constraints to its output.

Because this test executes a real LLM, it requires an API key. **If you do not provide an API key, this test will gracefully skip itself** (both locally and in CI).

### Running E2E Tests Locally

1. Export your Gemini API Key in your terminal:
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   ```

2. Run the `run_tests.sh` script again. It will automatically detect the environment variable and append the E2E tests to the end of the suite:
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
3. **Metadata Validation**: Ensures no malformed or undocumented skills are merged into the library.
4. **Security Scans**: Gitleaks + Bandit (`.github/workflows/security.yaml`).

## Security Scanning

This repository is protected by automated security workflows (`.github/workflows/security.yaml`):

1. **Gitleaks (Secret Scanning)**: Automatically scans all commits in a PR to ensure no API keys, passwords, or tokens are accidentally merged into the repository.
2. **Bandit (Python SAST)**: Statically analyzes the Python code in the `mcp-server/` directory to identify common security vulnerabilities before they reach production.

### Real IDE CLI Integration Tests (Headless)
We also include `tests/e2e/test_cli_integration.py` which dynamically checks if you have the `agy` or `claude` CLI installed on your machine. If it detects them, it will use Python's `subprocess` to spawn a headless, non-interactive execution (e.g., `agy -p "/sdlc-example-skill"`) to ensure that the installed skills actually load and execute in a real production binary.
*(Note: If your local CLI is out of credits or requires interactive authentication, this test will gracefully skip itself).*
