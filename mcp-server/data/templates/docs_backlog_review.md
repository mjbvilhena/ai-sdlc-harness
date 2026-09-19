# Docs Backlog Review

Full-repo docs↔code audit plus backlog hygiene for skill `sdlc-docs-backlog-review`. Pair with `get_sdlc_template("docs backlog review")` (aliases `docs backlog`, `backlog review`, `full repo audit`). Pair with template `pr` and Definition of Done `pr` for the landing PR. This is **not** `sdlc-docs-updater` (that skill updates docs for a *recent code change*).

**Quality bar:** Discover the **current workspace** — do not assume `ai-sdlc-harness` or any other named product. Code, tests, and CI are source of truth for what ships. Docs are claims to verify. Every finding cites a file/line or a command actually run. The review PR stays **open**.

## Discover the project first

Do not hard-code paths from memory. From the workspace / `git rev-parse --show-toplevel`:

1. **Docs** — typically `docs/`, root `README.md`, `CONTRIBUTING.md`, plus any install, architecture, authoring, or usage guides the repo actually has. Follow relative links from those files. Skip generated sites (`node_modules`, `dist/`, vendor trees).
2. **Backlog** — often `docs/product/backlog.md`, else `docs/backlog.md`, `BACKLOG.md`, `docs/todo.md`. Prefer an in-repo markdown backlog if one exists. If none exists, introduce a *minimal* markdown backlog next to existing product docs (or `docs/product/backlog.md` if you must create `docs/`) and say that you created it. Do not silently start using GitHub Issues unless that is clearly the project's only tracker and no file exists.
3. **Status convention** — if items already use markers such as `*(Done)*` / `*(In progress)*` / `*(Not done)*` (or checkboxes, `TODO`/`DONE` tags), **match them**. If none exists, propose a minimal three-state convention, document it at the top of the backlog, and use it.
4. **Code & evidence** — source layout, installers/scripts, tests, CI workflows, MCP/config files, package manifests. Counts and commands in docs must match these, not wishful product copy.
5. **Default branch** — `origin/HEAD`, else `main` / `master` as the remote actually uses.

A clearly labeled roadmap or "planned" section is not drift; a doc that presents unbuilt work as shipped is drift.

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

Do not invent product features, certifications, SLOs, or stakeholder sign-off.

### 2) Capture drift as backlog work

For each **material** finding that is not already tracked (fuzzy-match titles and evidence paths before adding):

- Append a clearly worded, **actionable** item: what to change, where, why, with evidence.
- Prefer an **existing epic**. Create a short new epic only when the work does not fit (one goal paragraph, then numbered tasks). If you must add a new epic, fetch Definition of Done `epic`.
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

## Anti-patterns

- Invented product capabilities, pass rates, or review approvals
- Merging, force-pushing onto the default branch, or deleting the review branch
- Secrets, tokens, or private URLs from config files pasted into docs or the PR
- Exploit steps, attack PoCs, or instructions to weaken auth
- A PR that is only whitespace or regenerated noise
- Silent daily rewrite instead of an open review PR
