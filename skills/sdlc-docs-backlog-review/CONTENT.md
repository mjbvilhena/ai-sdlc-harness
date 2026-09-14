## Purpose

Run a **full-repo docs↔code audit plus backlog hygiene** on the **current workspace** — whichever project the user has open. Discover that repo's layout, docs, backlog, CI, and status conventions. Do not assume this is `ai-sdlc-harness` or any other named product.

This is **not** `sdlc-docs-updater`. That skill updates docstrings/README sections for a *recent code change*. This skill walks the whole tree, finds documentation drift, records it as backlog work, re-evaluates every existing backlog item against the repo, applies only straightforward doc fixes, and lands a **review PR that stays open**.

## Activation

Trigger when the user asks to "run a docs/backlog review", "audit docs vs repo", "sync the backlog", "daily docs review", or uses `/docs-backlog-review` (or an equivalent slash command).

## MCP tools (when helpful)

When MCP is available, use it to structure artifacts — never to invent product facts:

1. Call `get_sdlc_template` with `template_type="pr"` before writing the landing PR body. Follow that shape.
2. Call `get_definition_of_done` with `component="pr"` (docs-only change type). Do **not** treat green CI as permission to merge.
3. If you must add a **new epic**, call `get_definition_of_done` with `component="epic"` and write a short outcome paragraph plus child tasks. You may also fetch `user story` to shape a large item.
4. If docs describe a named domain or layer and `DOMAIN.md` / `LAYER.md` exist, call `get_domain_consultant` / `get_layer_consultant`. Retry only names the tool lists.

If MCP is unavailable, say so in the final report and continue with the workflow below.

## Discover the project first

Do not hard-code paths from memory. From the workspace / `git rev-parse --show-toplevel`:

1. **Docs** — typically `docs/`, root `README.md`, `CONTRIBUTING.md`, plus any install, architecture, authoring, or usage guides the repo actually has. Follow relative links from those files. Skip generated sites (`node_modules`, `dist/`, vendor trees).
2. **Backlog** — often `docs/product/backlog.md`, else `docs/backlog.md`, `BACKLOG.md`, `docs/todo.md`. Prefer an in-repo markdown tracker if one exists. If none exists, introduce a *minimal* markdown backlog next to existing product docs (or `docs/product/backlog.md` if you must create `docs/`) and say that you created it. Do not silently start using GitHub Issues unless that is clearly the project's only tracker and no file exists.
3. **Status convention** — if items already use markers such as `*(Done)*` / `*(In progress)*` / `*(Not done)*` (or checkboxes, `TODO`/`DONE` tags), **match them**. If none exists, propose a minimal three-state convention, document it at the top of the backlog, and use it.
4. **Code & evidence** — source layout, installers/scripts, tests, CI workflows, MCP/config files, package manifests. Counts and commands in docs must match these, not wishful product copy.
5. **Default branch** — `origin/HEAD`, else `main` / `master` as the remote actually uses.

Treat **code, tests, and CI as source of truth** for what ships. Treat docs as claims to verify. A clearly labeled roadmap or "planned" section is not drift; a doc that presents unbuilt work as shipped is drift.

## Workflow

Work through these five phases in order. Keep a running log of findings, status flips, and files you will touch.

### 1) Deep documentation drift

Cross-check every in-scope doc against the real tree:

- **Contradictions** — two docs (or a doc vs code) disagree on paths, flags, install locations, harness names, or behavior.
- **Outdated paths and commands** — files moved, flags renamed, examples that would fail today.
- **Missing documented features** — README/install guides omit a shipped, user-facing path (installer, uninstaller, config file, important flag).
- **Documented but absent** — features, files, or counts claimed in docs that are not in the repo.
- **Dead links** — relative markdown targets that 404; skip flaky external URLs unless a local equivalent exists.
- **Stale architecture** — diagrams or "how it works" sections that describe a previous layout (wrong directories, old destination paths, obsolete "no runtime" claims when a server exists, and similar).
- **Wrong counts and evidence** — "N templates", "N skills", catalog lists, test-suite claims. Recount from the tree and from tests that assert those numbers.

Do not invent product features, certifications, SLOs, or stakeholder sign-off. Every finding needs a file/line or command you actually ran.

### 2) Capture drift as backlog work

For each **material** finding that is not already tracked (fuzzy-match titles and evidence paths before adding):

- Append a clearly worded, **actionable** item: what to change, where, why, with evidence.
- Prefer an **existing epic**. Create a short new epic only when the work does not fit (one goal paragraph, then numbered tasks).
- New items start as not-done (or the repo's equivalent). Do not mark them Done in the same pass unless you also ship the fix in this run.
- Small, clearly warranted doc falsehoods belong in phase 4, not as backlog noise. Backlog the rest (redesigns, installer bugs, test gaps, large rewrites).

### 3) Backlog status audit

Re-evaluate **every** existing item against the current repo, not the last review's notes:

- **Done** only if the claimed evidence still holds (file exists, behavior matches, tests cover it).
- **In progress** if the work is partially present (e.g. Bash done, PowerShell not).
- **Not done** if it is still missing.
- Previously Done items **may flip** if the evidence is now wrong. Say so in the item's evidence note and in the report.
- Update stale evidence notes (paths, counts, "create-once vs merge") even when the status stays the same.

Do not close or delete epics that still have open children. Do not mark an epic Done because one PR was green.

### 4) Doc fixes that are clearly warranted

Fix **straightforward falsehoods** when the correction is short and tied to this drift: wrong path, obsolete command, leftover old-name wording, count that tests already assert, missing one-line pointer to a sibling skill.

- Prefer an accurate short update over a redesign.
- Put larger rewrites, new catalogs, and taste-driven restyles on the backlog.
- Stay in documentation and the backlog file. Do not "while you're here" refactor installers, MCP, or tests unless the user explicitly asked.

### 5) Land changes for human review

If **nothing material** changed (no backlog edits, no status flips, no doc fixes): do **not** create a branch, commit, or empty PR. Report that the audit was clean.

Otherwise:

1. Create a dated branch from the default branch:
   - Scheduled / daily automation: `docs/daily-backlog-review-YYYY-MM-DD`
   - Manual `/docs-backlog-review`: `docs/backlog-review-YYYY-MM-DD`
   - If the environment **requires** a different prefix (for example a cloud-agent `cursor/` prefix), keep that prefix and still include `backlog-review-YYYY-MM-DD` in the name.
2. Commit with a conventional message (e.g. `docs: backlog review YYYY-MM-DD`).
3. Open a PR to the **default branch**. Title and body must summarize new drift items, status flips, and doc files touched. Use the MCP PR template when available.
4. **Do not merge the PR.** **Do not delete the branch.** Leave it open for the user to review — even if CI is green, you are an admin, or a bypass would work. State that explicitly in the PR body and in the user report.

## Final report

Always return a short report with all of:

- **(a)** Count of **new** drift backlog items (0 is allowed).
- **(b)** Notable status flips (item id, old → new, one-line reason). Evidence-only note updates can be listed briefly.
- **(c)** PR URL, or `no PR — nothing material`.
- **(d)** Explicit sentence: the PR is **left open for review and was not merged** (omit only when there is no PR).
- **(e)** Brief list of doc files touched (paths).

Optional: MCP used / unavailable; new epic name if you created one.

## Safety

- Do not invent product capabilities, pass rates, or review approvals.
- Do not merge, force-push onto the default branch, or delete the review branch.
- Do not paste secrets, tokens, or private URLs from config files into docs or the PR.
- Do not write exploit steps, attack PoCs, or instructions to weaken auth.
- Do not open a PR that is only whitespace or regenerated noise.
