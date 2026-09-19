## Purpose

Run a **full-repo docs↔code audit plus backlog hygiene** on the **current workspace** — whichever project the user has open. Discover that repo's layout, docs, backlog, CI, and status conventions. Do not assume this is `ai-sdlc-harness` or any other named product.

This is **not** `sdlc-docs-updater`. That skill updates docstrings/README sections for a *recent code change*. This skill walks the whole tree, finds documentation drift, records it as backlog work, re-evaluates every existing backlog item against the repo, applies only straightforward doc fixes, and lands a **review PR that stays open**.

## Activation

Trigger when the user asks to "run a docs/backlog review", "audit docs vs repo", "sync the backlog", "daily docs review", or uses `/docs-backlog-review` (or an equivalent slash command).

## MCP tools (required)

When MCP is available:

1. **CRITICAL**: Call `get_sdlc_template` with `template_type="docs backlog review"` (aliases `docs backlog`, `backlog review`, `full repo audit` also resolve). Follow that procedure for discovery, the five audit phases, and the final report. Do not invent a different audit shape.
2. Call `get_sdlc_template` with `template_type="pr"` before writing the landing PR body. Follow that shape.
3. Call `get_definition_of_done` with `component="pr"` (docs-only change type). Do **not** treat green CI as permission to merge.
4. If you must add a **new epic**, call `get_definition_of_done` with `component="epic"` and write a short outcome paragraph plus child tasks. You may also fetch `user story` to shape a large item.
5. If docs describe a named domain or layer and `DOMAIN.md` / `LAYER.md` exist, call `get_domain_consultant` / `get_layer_consultant`. Retry only names the tool lists.

If MCP is unavailable, say so in the final report and continue with discover → drift → backlog capture → status audit → warranted doc fixes → open review PR (do not merge).

## Instructions

1. Discover the project's docs, backlog, status convention, code/evidence, and default branch from the workspace. Do not hard-code paths from memory. Code, tests, and CI are source of truth for what ships.
2. Execute the five phases from the fetched template in order. Keep a running log of findings, status flips, and files you will touch.
3. Fix only straightforward doc falsehoods. Backlog larger rewrites. Stay in documentation and the backlog file unless the user explicitly asked otherwise.
4. If nothing material changed, do **not** create a branch, commit, or empty PR. Otherwise open a review PR and **leave it open**.
5. Always return the final report fields from the template (new items, status flips, PR URL or none, not-merged sentence, files touched).

## Safety

- Do not invent product capabilities, pass rates, or review approvals.
- Do not merge, force-push onto the default branch, or delete the review branch.
- Do not paste secrets, tokens, or private URLs from config files into docs or the PR.
- Do not write exploit steps, attack PoCs, or instructions to weaken auth.
- Do not open a PR that is only whitespace or regenerated noise.
