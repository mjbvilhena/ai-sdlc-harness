# Product Backlog

> Status convention: each task line includes `*(Done)*`, `*(In progress)*`, or `*(Not done)*` based on the repo audit plus the Epic 9 / quality-gate implementation (2026-09-13).

## Epic 1: Installer Scripts

> Goal: Deliver working installer scripts for each supported harness across macOS, Linux, and Windows.

- **Task 1.1** *(Done)*: Implement `install_claude.sh` — discovers `skills/*/claude/` and copies `.md` files to `~/.claude/commands/`. *(Evidence: `install/install_claude.sh`; also supports `--workspace` → `<ws>/.claude/commands/`.)*
- **Task 1.2** *(Done)*: Implement `install_cursor.sh` — discovers `skills/*/cursor/` and copies rules to `.cursor/rules/`. *(Evidence: `install/install_cursor.sh`.)*
- **Task 1.3** *(Done)*: Implement `install_ghcp.sh` — discovers `skills/*/ghcp/` and copies instruction files to `.github/instructions/`. Support `--workspace <path>` flag. *(Evidence: `install/install_ghcp.sh`.)*
- **Task 1.4** *(Done)*: Implement `install_agy.sh` — discovers `skills/*/agy/` and copies contents to `~/.gemini/antigravity-cli/builtin/skills/<name>/`. *(Evidence: `install/install_agy.sh`; workspace mode uses `<ws>/.agents/skills/`.)*
- **Task 1.5** *(Done)*: Add agent and rule support to all four installers (i.e., also iterate over `agents/*/` and `rules/*/`). *(Evidence: all four `.sh` and `.ps1` installers call `Process-Category` / loop over `agents` and `rules`. `agents/` itself remains deferred — see Task 9.8.)*
- **Task 1.6** *(Done)*: Write installer test stubs (dry-run mode or `--dry-run` flag) that print what would be copied without performing any file operations. *(Evidence: `--dry-run` on all `.sh`; `-DryRun` on all `.ps1`.)*
- **Task 1.7** *(Done)*: Implement PowerShell equivalents (`.ps1`) for all installers to provide native, zero-dependency support for Windows users. *(Evidence: `install/install_{claude,cursor,ghcp,agy}.ps1`.)*

## Epic 2: Bundled Skill Library

> Goal: Ship a useful, high-quality set of skills and rules ready to install.

- **Task 2.1** *(Done)*: Author `sdlc-code-reviewer` skill — reviews PR diffs, highlights issues. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-code-reviewer/{agy,claude,cursor,ghcp}/`.)*
- **Task 2.2** *(Done)*: Author `sdlc-pr-summarizer` skill — generates a PR description from staged changes. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-pr-summarizer/` all four harnesses.)*
- **Task 2.3** *(Done)*: Author `sdlc-commit-message` rule — passive format guideline for conventional commits. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `rules/sdlc-commit-message/`.)*
- **Task 2.4** *(Done)*: Author `sdlc-test-writer` skill — generates test stubs for a given function or module. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-test-writer/`.)*
- **Task 2.5** *(Done)*: Author `sdlc-docs-updater` skill — updates inline documentation and README sections. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-docs-updater/`.)*
- **Task 2.6** *(Done)*: Review and quality-gate all bundled skills and rules for accuracy and safety before first public release. *(Evidence: strengthened thin prompts for `sdlc-threat-modeler`, `sdlc-a11y-auditor`, `sdlc-user-story-refiner`, `sdlc-code-reviewer`, and Epic 6 drivers; safety language forbids fake product claims, exploit PoCs, and invented facts. MCP wiring completed under Task 9.6.)*

## Epic 3: Contributor Experience

> Goal: Make it easy for the community to author and contribute new skills, agents, and rules.

- **Task 3.1** *(Done)*: Create `skills/example-skill/` and `rules/example-rule/` with complete stubs for all harness targets and fully-annotated metadata files. *(Evidence: shipped as `skills/sdlc-example-skill/` and `rules/sdlc-example-rule/` with all four harnesses + yaml. Docs now cite the `sdlc-*` names — see Tasks 9.1 / 9.5.)*
- **Task 3.2** *(Done)*: Write `CONTRIBUTING.md` — explains the directory layouts, metadata schemas, how to author for each harness, and the PR checklist. *(Evidence: root `CONTRIBUTING.md`.)*
- **Task 3.3** *(Done)*: Write per-harness authoring guides under `docs/guides/` (e.g., `authoring-for-claude.md`, `authoring-for-cursor.md`, `authoring-for-ghcp.md`, `authoring-for-agy.md`). *(Evidence: all four files present under `docs/guides/`.)*
- **Task 3.4** *(Done)*: Add `skill.yaml`, `agent.yaml`, and `rule.yaml` schema documentation to `docs/technical_design/schemas.md`. *(Evidence: `docs/technical_design/schemas.md`; `cursor` included in `targets:` examples — Task 9.4.)*
- **Task 3.5** *(Done)*: Add a GitHub Actions CI workflow that validates all metadata files for required fields on every PR. *(Evidence: `.github/workflows/validate-metadata.yaml` + `.github/scripts/validate_metadata.py`. `schemas.md` documents this as implemented — Task 9.4.)*

## Epic 4: MCP Knowledge Retrieval Server

> Goal: Build the standalone MCP server to deliver SDLC knowledge (DoD, templates, architecture rules) with high resilience to LLM tool-calling quirks.

- **Task 4.1** *(Done)*: Scaffold a basic Python or TypeScript MCP server with tool definitions for `get_sdlc_template` and `get_definition_of_done`. *(Evidence: `mcp-server/src/server.py`.)*
- **Task 4.2** *(Done)*: Implement fuzzy matching and alias resolution for parameters (e.g., mapping "user story" and "stories" to "story"). *(Evidence: `ALIASES` + `fuzzy_match` / `thefuzz` in `server.py`; covered by `mcp-server/tests/test_server.py`.)*
- **Task 4.3** *(Done)*: Implement graceful degradation so that unrecognized queries return a helpful list of valid options instead of failing blindly. *(Evidence: fallback messages in `get_sdlc_template` / `get_definition_of_done`.)*
- **Task 4.4** *(Done)*: Populate the initial database/directory of SDLC standards (ADR templates, PR checklists, etc.). *(Evidence: `mcp-server/data/templates/` (8 files) and `mcp-server/data/dod/` (5 files).)*
- **Task 4.5** *(Done)*: Add tests for the MCP server ensuring robust LLM interaction flows. *(Evidence: `mcp-server/tests/test_server.py`.)*

## Epic 5: Requirements & Design Phase Skills

> Goal: Equip the harness to assist in the early stages of the SDLC, before code is even written.

- **Task 5.1** *(Done)*: Author `sdlc-user-story-refiner` skill — expands rough feature ideas into BDD-style user stories and acceptance criteria. *(Evidence: `skills/sdlc-user-story-refiner/` all four harnesses; prompts call `get_sdlc_template` / `get_domain_consultant`.)*
- **Task 5.2** *(Done)*: Author `sdlc-dod-checker` rule — checks if staged changes or proposed PRs meet the project's Definition of Done (fetching from MCP). *(Evidence: `rules/sdlc-dod-checker/`; prompts reference MCP DoD retrieval.)*
- **Task 5.3** *(Done)*: Author `sdlc-adr-drafter` skill — writes an Architectural Decision Record from a technical discussion context. *(Evidence: `skills/sdlc-adr-drafter/`; prompts reference `get_sdlc_template`.)*
- **Task 5.4** *(Done)*: Author `sdlc-threat-modeler` skill — performs a high-level STRIDE security review of proposed changes. *(Evidence: `skills/sdlc-threat-modeler/` all four harnesses; quality-gated under Task 2.6 with STRIDE process + safety + MCP consultants.)*
- **Task 5.5** *(Done)*: Author `sdlc-domain-architect` skill — drafts/updates `DOMAIN.md` payloads for dynamic Domain Consultants. *(Evidence: `skills/sdlc-domain-architect/` all four harnesses.)*
- **Task 5.6** *(Done)*: Author `sdlc-layer-architect` skill — drafts/updates `LAYER.md` payloads for dynamic Layer Consultants. *(Evidence: `skills/sdlc-layer-architect/` all four harnesses.)*

## Epic 6: Delivery & Operations Phase Skills

> Goal: Ensure the agent can help with deploying, monitoring, and resolving production issues.

- **Task 6.1** *(Done)*: Author `sdlc-release-notes-generator` skill — generates user-facing release notes by analyzing git history or merged PRs. *(Evidence: `skills/sdlc-release-notes-generator/`; MCP `get_definition_of_done` / optional PR template.)*
- **Task 6.2** *(Done)*: Author `sdlc-e2e-scripter` skill — scaffolds Playwright or Cypress tests from user story acceptance criteria. *(Evidence: `skills/sdlc-e2e-scripter/`; MCP user-story template + layer consultant.)*
- **Task 6.3** *(Done)*: Author `sdlc-ci-debugger` skill — parses raw GitHub Actions or Jenkins logs to identify the root cause of pipeline failures. *(Evidence: `skills/sdlc-ci-debugger/`; MCP consultants/DoD when the failing area maps.)*
- **Task 6.4** *(Done)*: Author `sdlc-postmortem-writer` skill — drafts a blameless post-mortem document from incident timelines and chat logs. *(Evidence: `skills/sdlc-postmortem-writer/`; MCP `incident postmortem` template.)*
- **Task 6.5** *(Done)*: Author `sdlc-a11y-auditor` rule — enforces WCAG accessibility checks on frontend code. *(Evidence: `rules/sdlc-a11y-auditor/`; WCAG 2.2 AA checklist, no conformance claims, optional layer consultant.)*

## Epic 7: Dynamic Consultants & MCP Enhancements

> Goal: Fulfill the Tri-Dimensional Framework requirements for dynamic Domain and Layer Consultants via the MCP server.

- **Task 7.1** *(Done)*: Implement dynamic Consultant discovery in the MCP server (automatically discovering and serving Domain and Layer knowledge payloads based on the workspace structure). *(Evidence: `get_domain_consultant` / `get_layer_consultant` + `scan_for_consultants` in `mcp-server/src/server.py`.)*
- **Task 7.2** *(Done)*: Add MCP tests to verify dynamic Consultant generation as the mock repository evolves. *(Evidence: `test_get_domain_consultant` / `test_get_layer_consultant` in `mcp-server/tests/test_server.py`.)*

## Epic 8: Quality Assurance, Linting & E2E Testing

> Goal: Meet all automated testing and static validation requirements outlined in the product specification (Section 6).

- **Task 8.1** *(Done)*: Implement BATS (Bash Automated Testing System) tests for all shell installer scripts to verify idempotency, file copying, and flag handling. *(Evidence: `tests/bats/installers.bats` covers dry-run for all four `.sh` installers, global/workspace paths, PWD default for cursor/ghcp, idempotency, MCP create-once, unknown flags, missing `--workspace` path, and absent `agents/`.)*
- **Task 8.2** *(Done)*: Update GitHub Actions CI to include `shellcheck` (for bash scripts) and `markdownlint` (for prompts and docs). *(Evidence: `.github/workflows/lint.yaml` with `scandir: './install'` + markdownlint on `**/*.md`.)*
- **Task 8.3** *(Done)*: Scaffold an E2E agent evaluation framework (e.g., using `promptfoo` or `pytest`) to programmatically test agents against a sandboxed mock repository. *(Evidence: `tests/e2e/test_agent_behavior.py` (Gemini) + `tests/e2e/test_cli_integration.py`; wired optionally via `run_tests.sh` when `GEMINI_API_KEY` is set. Not using promptfoo.)*
- **Task 8.4** *(Done)*: Update `install_claude` and `install_agy` scripts (Bash and PS1) to fully support the `--workspace` flag for workspace-scoped installations, ensuring parity across all installers as mandated by the spec. *(Evidence: `--workspace` / `-Workspace` in `install/install_claude.{sh,ps1}` and `install/install_agy.{sh,ps1}`.)*
- **Task 8.5** *(Done)*: Add security scanning to CI and the local test runner (Gitleaks secret scan + Bandit Python SAST). *(Evidence: `.github/workflows/security.yaml`; `run_tests.sh` steps 3 and 6.)*

## Epic 9: Documentation Drift Remediation

> Goal: Bring README, product docs, and technical design docs back in sync with the actual repository layout and behaviour (post `install/` move, Cursor support, MCP, tests).

- **Task 9.1** *(Done)*: Update root `README.md` to match reality: installers live under `install/`; add **Cursor** to the Supported Harnesses table; example path `skills/sdlc-example-skill/`; `agents/` marked deferred; soften the absolute "No Python" claim given `mcp-server/`; clone URL `mjbvilhena/ai-sdlc-harness`.
- **Task 9.2** *(Done)*: Rewrite `docs/technical_design/directory_structure.md` to show `install/`, `mcp-server/`, `tests/`, `run_tests.sh`, Cursor harness dirs, and `docs/guides/` including `authoring-for-cursor.md`. Stop claiming installers live at repo root and that `agents/` currently exists. Remove the "guides (planned)" wording.
- **Task 9.3** *(Done)*: Align `docs/product/specification.md` and `docs/product/vision.md` with installer paths under `install/`; correct AGY workspace install location to `.agents/skills/` (and MCP config under `.agents/mcp_config.json`); keep global AGY path `~/.gemini/antigravity-cli/builtin/skills/`.
- **Task 9.4** *(Done)*: Update `docs/technical_design/architecture.md` and `docs/technical_design/schemas.md`: use `./install/install_*.sh` in diagrams; include `cursor` in schema `targets:` examples; document CI validation as implemented (`.github/workflows/validate-metadata.yaml`).
- **Task 9.5** *(Done)*: Fix `CONTRIBUTING.md` layout/examples to the `sdlc-*` naming convention; keep `agents/` references accurate (supported by installers, directory not populated).
- **Task 9.6** *(Done)*: Wire MCP tool instructions (`get_sdlc_template`, `get_definition_of_done`, `get_domain_consultant`, `get_layer_consultant` as appropriate) into Lifecycle Driver skills that should use MCP. *(Evidence: `sdlc-user-story-refiner`, `sdlc-code-reviewer`, `sdlc-threat-modeler`, `sdlc-e2e-scripter`, `sdlc-ci-debugger`, `sdlc-postmortem-writer`, `sdlc-release-notes-generator`, `sdlc-a11y-auditor`, in addition to the previously MCP-aware `sdlc-dod-checker`, `sdlc-adr-drafter`, `sdlc-domain-architect`, `sdlc-layer-architect`, `sdlc-pr-summarizer`.)*
- **Task 9.7** *(Done)*: Add MCP auto-configuration to `install/install_ghcp.sh` and `install/install_ghcp.ps1`. Writes `<ws>/.vscode/mcp.json` with the VS Code / Copilot `servers` key. Does not overwrite an existing file.
- **Task 9.8** *(Done)*: Product decision: do **not** invent full agent packages. Product and technical docs state that `skills/` currently serve as Lifecycle Drivers and `agents/` is deferred. No empty `agents/` scaffolding added (installers already skip a missing directory).
- **Task 9.9** *(Done)*: Expand `docs/guides/installation-and-usage.md` for cursor/ghcp/PS1/`--workspace` nuances and GHCP MCP status (`.vscode/mcp.json` after Task 9.7).
