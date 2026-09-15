# Product Backlog

> Status convention: each task line includes `*(Done)*`, `*(In progress)*`, or `*(Not done)*` based on the repo audit (2026-09-15, post PRs #9 / #10). Epic 9 closed the pre-#6 docs wave; Epic 12 tracks remaining installer/uninstaller drift (including the #10 Cursor dest move to `.cursor/commands/`).

## Epic 1: Installer Scripts

> Goal: Deliver working installer scripts for each supported harness across macOS, Linux, and Windows.

- **Task 1.1** *(Done)*: Implement `install_claude.sh` — discovers `skills/*/claude/` and copies `.md` files to `~/.claude/commands/`. *(Evidence: `install/install_claude.sh`; also supports `--workspace` → `<ws>/.claude/commands/`.)*
- **Task 1.2** *(Done)*: Implement `install_cursor.sh` — discovers `skills/*/cursor/` and installs Cursor slash commands. *(Evidence: `install/install_cursor.sh` reads `cursor/prompt.md` and writes `<ws>/.cursor/commands/sdlc-<name>.md` as of PR #10. `install_cursor.ps1` is still on the old `.cursor/rules/*.mdc` path — Task 12.1. Bash uninstaller still targets `.cursor/prompts/` — Task 12.3.)*
- **Task 1.3** *(Done)*: Implement `install_ghcp.sh` — discovers `skills/*/ghcp/` and copies instruction files to `.github/instructions/`. Support `--workspace <path>` flag. *(Evidence: `install/install_ghcp.sh`.)*
- **Task 1.4** *(Done)*: Implement `install_agy.sh` — discovers `skills/*/agy/` and copies contents to `~/.gemini/antigravity-cli/builtin/skills/<name>/`. *(Evidence: `install/install_agy.sh`; workspace mode uses `<ws>/.agents/skills/`.)*
- **Task 1.5** *(Done)*: Add agent and rule support to all four installers (i.e., also iterate over `agents/*/` and `rules/*/`). *(Evidence: all four `.sh` and `.ps1` installers call `Process-Category` / loop over `agents` and `rules`. `agents/` itself remains deferred — see Task 9.8.)*
- **Task 1.6** *(Done)*: Write installer test stubs (dry-run mode or `--dry-run` flag) that print what would be copied without performing any file operations. *(Evidence: `--dry-run` on all `.sh`; `-DryRun` on all `.ps1`.)*
- **Task 1.7** *(In progress)*: Implement PowerShell equivalents (`.ps1`) for all installers to provide native, zero-dependency support for Windows users. *(Evidence: all four `install/install_*.ps1` files exist, but `install_cursor.ps1` still looks for `cursor/rule.mdc` and writes `.cursor/rules/*.mdc` — it would skip every current skill/rule and does not follow the #10 `.cursor/commands/` dest. PS1 MCP is still create-once + `python3`, not venv merge. See Tasks 12.1 / 12.2.)*

## Epic 2: Bundled Skill Library

> Goal: Ship a useful, high-quality set of skills and rules ready to install.

- **Task 2.1** *(Done)*: Author `sdlc-code-reviewer` skill — reviews PR diffs, highlights issues. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-code-reviewer/{agy,claude,cursor,ghcp}/`.)*
- **Task 2.2** *(Done)*: Author `sdlc-pr-summarizer` skill — generates a PR description from staged changes. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-pr-summarizer/` all four harnesses.)*
- **Task 2.3** *(Done)*: Author `sdlc-commit-message` rule — passive format guideline for conventional commits. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `rules/sdlc-commit-message/`.)*
- **Task 2.4** *(Done)*: Author `sdlc-test-writer` skill — generates test stubs for a given function or module. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-test-writer/`.)*
- **Task 2.5** *(Done)*: Author `sdlc-docs-updater` skill — updates inline documentation and README sections. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-docs-updater/`.)*
- **Task 2.6** *(Done)*: Review and quality-gate all bundled skills and rules for accuracy and safety before first public release. *(Evidence: strengthened thin prompts for `sdlc-threat-modeler`, `sdlc-a11y-auditor`, `sdlc-user-story-refiner`, `sdlc-code-reviewer`, and Epic 6 drivers; safety language forbids fake product claims, exploit PoCs, and invented facts. MCP wiring completed under Task 9.6.)*
- **Task 2.7** *(Done)*: Author `sdlc-docs-backlog-review` skill — full-repo docs↔code audit + backlog hygiene on the current workspace (not hard-coded to this harness); opens a review PR and does not merge. Distinct from `sdlc-docs-updater`. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-docs-backlog-review/` all four harnesses + `CONTENT.md`.)*
- **Task 2.8** *(Done)*: Author `sdlc-product-owner` skill — expands a vision into epics / product specs; calls MCP `get_sdlc_template("product spec")` and `get_definition_of_done("epic")`. Author for `claude`, `cursor`, `ghcp`, `agy`. *(Evidence: `skills/sdlc-product-owner/` all four harnesses + `CONTENT.md`; template `mcp-server/data/templates/product_spec.md` shipped in PR #9. Catalog tests still omit that template — Task 10.8.)*

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
- **Task 4.4** *(Done)*: Populate the initial database/directory of SDLC standards (ADR templates, PR checklists, etc.). *(Evidence: `mcp-server/data/templates/` (22 files, including `product_spec.md` from PR #9) and `mcp-server/data/dod/` (11 files). `test_catalog_templates_and_dod` still asserts 21 template names and omits `product spec` — Task 10.8.)*
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

- **Task 8.1** *(Done)*: Implement BATS (Bash Automated Testing System) tests for all shell installer scripts to verify idempotency, file copying, and flag handling. *(Evidence: `tests/bats/installers.bats` covers dry-run for all four `.sh` installers, global/workspace paths, PWD default for cursor/ghcp, idempotency, MCP **merge** (sibling servers kept + `sdlc-knowledge` added), Cursor `.cursor/commands/*.md` (updated in PR #10), unknown flags, missing `--workspace` path, `CONTENT.md` expansion, and absent `agents/`. Uninstallers and PS1 are not covered — Task 12.4. BATS still does not assert MCP `command` is `venv/bin/python` or Claude `claude_desktop_config.json`.)*
- **Task 8.2** *(Done)*: Update GitHub Actions CI to include `shellcheck` (for bash scripts) and `markdownlint` (for prompts and docs). *(Evidence: `.github/workflows/lint.yaml` with `scandir: './install'` + markdownlint on `**/*.md`.)*
- **Task 8.3** *(Done)*: Scaffold an E2E agent evaluation framework (e.g., using `promptfoo` or `pytest`) to programmatically test agents against a sandboxed mock repository. *(Evidence: `tests/e2e/test_agent_behavior.py` (Gemini) + `tests/e2e/test_cli_integration.py`; wired optionally via `run_tests.sh` when `GEMINI_API_KEY` is set. Not using promptfoo.)*
- **Task 8.4** *(Done)*: Update `install_claude` and `install_agy` scripts (Bash and PS1) to fully support the `--workspace` flag for workspace-scoped installations, ensuring parity across all installers as mandated by the spec. *(Evidence: `--workspace` / `-Workspace` in `install/install_claude.{sh,ps1}` and `install/install_agy.{sh,ps1}`.)*
- **Task 8.5** *(Done)*: Add security scanning to CI and the local test runner (Gitleaks secret scan + Bandit Python SAST). *(Evidence: `.github/workflows/security.yaml`; `run_tests.sh` steps 3 and 6.)*

## Epic 9: Documentation Drift Remediation

> Goal: Bring README, product docs, and technical design docs back in sync with the actual repository layout and behaviour (post `install/` move, Cursor support, MCP, tests). Re-synced 2026-09-15 for PR #10 (Cursor dest `.cursor/commands/`) and PR #9 (`sdlc-product-owner` / `product_spec`). Remaining code-level installer drift is Epic 12.

- **Task 9.1** *(Done)*: Update root `README.md` to match reality: installers live under `install/`; add **Cursor** to the Supported Harnesses table; example path `skills/sdlc-example-skill/`; `agents/` marked deferred; soften the absolute "No Python" claim given `mcp-server/`; clone URL `mjbvilhena/ai-sdlc-harness`.
- **Task 9.2** *(Done)*: Rewrite `docs/technical_design/directory_structure.md` to show `install/`, `mcp-server/`, `tests/`, `run_tests.sh`, Cursor harness dirs, and `docs/guides/` including `authoring-for-cursor.md`. Stop claiming installers live at repo root and that `agents/` currently exists. Remove the "guides (planned)" wording.
- **Task 9.3** *(Done)*: Align `docs/product/specification.md` and `docs/product/vision.md` with installer paths under `install/`; correct AGY workspace install location to `.agents/skills/` (and MCP config under `.agents/mcp_config.json`); keep global AGY path `~/.gemini/antigravity-cli/builtin/skills/`.
- **Task 9.4** *(Done)*: Update `docs/technical_design/architecture.md` and `docs/technical_design/schemas.md`: use `./install/install_*.sh` in diagrams; include `cursor` in schema `targets:` examples; document CI validation as implemented (`.github/workflows/validate-metadata.yaml`).
- **Task 9.5** *(Done)*: Fix `CONTRIBUTING.md` layout/examples to the `sdlc-*` naming convention; keep `agents/` references accurate (supported by installers, directory not populated).
- **Task 9.6** *(Done)*: Wire MCP tool instructions (`get_sdlc_template`, `get_definition_of_done`, `get_domain_consultant`, `get_layer_consultant` as appropriate) into Lifecycle Driver skills that should use MCP. *(Evidence: also `sdlc-product-owner` and `sdlc-docs-backlog-review`; plus `sdlc-user-story-refiner`, `sdlc-code-reviewer`, `sdlc-threat-modeler`, `sdlc-e2e-scripter`, `sdlc-ci-debugger`, `sdlc-postmortem-writer`, `sdlc-release-notes-generator`, `sdlc-a11y-auditor`, `sdlc-dod-checker`, `sdlc-adr-drafter`, `sdlc-domain-architect`, `sdlc-layer-architect`, `sdlc-pr-summarizer`.)*
- **Task 9.7** *(Done)*: Add MCP auto-configuration to `install/install_ghcp.sh` and `install/install_ghcp.ps1`. Writes `<ws>/.vscode/mcp.json` with the VS Code / Copilot `servers` key. *(Evidence: Bash now **merges** `sdlc-knowledge` into an existing file and points `command` at `mcp-server/venv/bin/python`. PS1 still create-once with `python3` — Task 12.2.)*
- **Task 9.8** *(Done)*: Product decision: do **not** invent full agent packages. Product and technical docs state that `skills/` currently serve as Lifecycle Drivers and `agents/` is deferred. No empty `agents/` scaffolding added (installers already skip a missing directory).
- **Task 9.9** *(Done)*: Expand `docs/guides/installation-and-usage.md` for cursor/ghcp/PS1/`--workspace` nuances and GHCP MCP status (`.vscode/mcp.json` after Task 9.7).

## Epic 10: World-class MCP Knowledge Base & Companion Skills

> Goal: Replace stub MCP templates/DoD with production-grade agent payloads, add the high-value templates existing skills were missing, extend aliases/tests, and ship the focused companion skills those payloads unlock.

- **Task 10.1** *(Done)*: Rewrite the original eight templates (`adr`, `bug_report`, `domain`, `incident_postmortem`, `layer`, `pr`, `rfc`, `user_story`) into dense, practical markdown (sections, checklists, anti-patterns, quality bars). *(Evidence: `mcp-server/data/templates/`.)*
- **Task 10.2** *(Done)*: Add templates the library needed: `threat_model`, `code_review`, `test_plan`, `e2e_test_plan`, `release_notes`, `runbook`, `api_design`, `api_contract`, `security_review`, `accessibility_audit`, `migration_plan`, `onboarding_guide`, plus justified `rollout_plan`. *(Evidence: new files under `mcp-server/data/templates/`.)*
- **Task 10.3** *(Done)*: Rewrite existing DoD (`bugfix`, `epic`, `feature`, `hotfix`, `release`) and add `pr`, `user_story`, `security_change`, `ui_change`, `api_change`, `data_migration`. Extend `ALIASES` with longest-match resolution in `mcp-server/src/server.py`. *(Evidence: `mcp-server/data/dod/`; `resolve_alias` in `server.py`.)*
- **Task 10.4** *(Done)*: Author four-harness companion skills with `skill.yaml`: `sdlc-rfc-drafter`, `sdlc-bug-triager`, `sdlc-runbook-writer`, `sdlc-api-designer`, `sdlc-security-reviewer`, `sdlc-migration-planner`. Each calls MCP templates/DoD and includes safety language. *(Evidence: `skills/sdlc-{rfc-drafter,bug-triager,runbook-writer,api-designer,security-reviewer,migration-planner}/`.)*
- **Task 10.5** *(Done)*: Wire existing Lifecycle Drivers to the new payloads (`sdlc-threat-modeler`, `sdlc-code-reviewer`, `sdlc-test-writer`, `sdlc-e2e-scripter`, `sdlc-release-notes-generator`, `sdlc-pr-summarizer`, `sdlc-user-story-refiner`, `sdlc-a11y-auditor`, `sdlc-dod-checker`). Disambiguate `/threat` vs `/security-review`. *(Evidence: MCP tool lists in those skill/rule files.)*
- **Task 10.6** *(Done)*: Extend `mcp-server/tests/test_server.py` for catalog completeness, new names, aliases, longest-match, and exact-over-short-alias (`bugfix` vs `bug`). *(Evidence: `test_catalog_templates_and_dod` and parametrized alias tests still cover the Epic 10 set. They do **not** include `product spec` added in PR #9 — Task 10.8.)*
- **Task 10.7** *(Done)*: Minimal discoverability docs — architecture catalog, README pointer, installation driver list. *(Evidence: `docs/technical_design/architecture.md`, `README.md`, `docs/guides/installation-and-usage.md`. 2026-09-15 review added `product spec` / `sdlc-product-owner` pointers.)*
- **Task 10.8** *(Not done)*: Close the PR #9 MCP catalog gap. `mcp-server/data/templates/product_spec.md` exists (22 files) and `ALIASES` maps `product spec` / `prd` / `epic` → `product spec`, but `EXPECTED_TEMPLATES` in `mcp-server/tests/test_server.py` still has 21 names, so `test_catalog_templates_and_dod` does not match the tree. Add `product spec` to the expected set, parametrize alias tests (`prd`, `product spec`), and add a regression that `get_definition_of_done("epic")` still returns the Epic DoD (exact catalog match) rather than the product-spec template.

## Epic 11: DRY Skill/Rule Content Model

> Goal: Author each skill and rule once in `CONTENT.md` and expand thin harness shells at install time.

- **Task 11.1** *(Done)*: Add `CONTENT.md` and `{{SKILL_BODY}}` / `{{RULE_BODY}}` shells for every skill and rule (including Epic 10 additions). *(Evidence: `skills/*/CONTENT.md`, `rules/*/CONTENT.md`.)*
- **Task 11.2** *(Done)*: Update all eight installers (`.sh` / `.ps1`) plus `install/lib/expand_content.sh` and `install/lib/Expand-Content.ps1` to expand placeholders, fail on missing `CONTENT.md` or placeholder, and never write unresolved tokens. *(Evidence: `install/`.)*
- **Task 11.3** *(Done)*: Extend BATS for expanded destinations, idempotent expand, and helper failure cases; update E2E prompt loader to substitute `CONTENT.md`. *(Evidence: `tests/bats/installers.bats`, `tests/e2e/test_agent_behavior.py`.)*
- **Task 11.4** *(Done)*: Document the convention in CONTRIBUTING, schemas, authoring guides, architecture, directory structure, README, and specification. CI metadata validation requires `CONTENT.md` and the correct placeholder. *(Evidence: those docs; `.github/scripts/validate_metadata.py` requires `cursor/prompt.md`.)*

## Epic 12: Post-#6 installer / uninstaller parity

> Goal: Close the code and test gaps left after PR #6 (MCP merge, venv Python, uninstallers) and PR #10 (Cursor dest `.cursor/commands/`). Docs were re-synced on 2026-09-15; these items are remaining implementation work.

- **Task 12.1** *(Not done)*: Bring `install/install_cursor.ps1` to parity with `install/install_cursor.sh`. Read `cursor/prompt.md`, write `<ws>/.cursor/commands/sdlc-<name>.md`, and wipe `sdlc-*.md` in that directory. Today the PS1 installer still looks for `cursor/rule.mdc` and writes `.cursor/rules/*.mdc`, so it would skip every current skill and rule.
- **Task 12.2** *(Not done)*: Bring PowerShell MCP wiring to Bash parity on all four installers: merge `sdlc-knowledge` into an existing host config (keep sibling servers) and invoke `mcp-server/venv` Python instead of create-once + `python3`. Align Claude filename: Bash writes `claude_desktop_config.json`; `install_claude.ps1` still writes `claude.json`.
- **Task 12.3** *(Not done)*: Repair uninstallers so they reverse the current installers. Concrete bugs: `uninstall_cursor.sh` still deletes `.cursor/prompts/sdlc-*.md` while `install_cursor.sh` (PR #10) writes `.cursor/commands/`; `uninstall_claude.sh` deletes `sdlc-*.json` (install writes `sdlc-*.md`), parses `--workspace` but always targets `~/.claude/commands`, and ignores workspace MCP; `uninstall_ghcp.sh` / `.ps1` never remove `sdlc-knowledge` from `.vscode/mcp.json`; PS1 uninstallers source missing `lib/sdlc_names.ps1` (actual file is `Sdlc-Names.ps1`), pass `-Pattern` instead of `-Filter`, call `Remove-SdlcDirs` (actual name `Remove-SdlcDirectories`), leave `$McpConfigFile` unset, and `uninstall_cursor.ps1` still targets `.cursor/rules` (comment text says `.cursor/prompts`).
- **Task 12.4** *(Not done)*: Add BATS coverage for all eight uninstallers (dest paths, globs, `--workspace`, MCP key removal, `--dry-run`). Extend installer BATS to assert Bash MCP `command` is `mcp-server/venv/bin/python` and that Claude writes `claude_desktop_config.json`. Add Pester (or equivalent) if PowerShell remains first-class — there is no PS1 test suite today, which is why 12.1–12.3 drifted undetected.
- **Task 12.5** *(Not done)*: Bootstrap or fail-soft when `mcp-server/venv` is missing, and when host `python3` is missing. Bash installers write `mcp-server/venv/bin/python` even if that interpreter does not exist, and they invoke host `python3 -c` to merge MCP JSON (`set -e` fails the installer after skills are already copied if `python3` is absent). `run_tests.sh` creates a venv for tests; installers do not. Either create the venv during install or refuse/warn before writing a broken MCP command.
- **Task 12.6** *(Not done)*: Migrate leftover Cursor dests from prior installer generations. After PR #10 the Bash installer only cleans `.cursor/commands/sdlc-*.md`. Workspaces may still have `.cursor/rules/sdlc-*.mdc` (pre-#6) and `.cursor/prompts/sdlc-*.md` (post-#6 / pre-#10). Add cleanup (or a one-shot migration step on install/uninstall) so stale files do not keep applying.
- **Task 12.7** *(Not done)*: Clean leftover rules-era / prompts-era wording in shipped sources: `skills/sdlc-example-skill/cursor/prompt.md` still says "example rule stub"; `install_cursor.sh` header still says dest `sdlc-<name>.mdc` and "Custom Prompts" while the script writes `.md` under `.cursor/commands/`; `install_claude.sh` dry-run text still says `claude.json`; BATS Cursor cleanup test names still say "rules".

