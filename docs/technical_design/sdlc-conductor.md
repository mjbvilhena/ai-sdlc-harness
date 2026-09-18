# Design note: `sdlc-conductor`

Status: **proposed** (design + backlog only). The skill is **not shipped**. Do not treat `/sdlc-conductor` as an installed driver until Epic 13 implements `skills/sdlc-conductor/`.

This note records the agreed product intent for a default front-door Lifecycle Driver. Name: **`sdlc-conductor`** (not `sdlc-agent`). A dedicated `agents/` tree remains deferred, and “agent” collides with that future package type.

## 1. Problem / why

Today the harness is a **menu of specialist skills**. That works for experts who already know the legal next step. It fails for the common question:

> “I have this repo / this idea — **what next?**”

Without a conductor, models either:

- jump straight to code and skip vision, spec, epic approval, or story refine, or
- rewrite `DOMAIN.md` / `LAYER.md` / the backlog from memory instead of evidence, or
- treat `sdlc-docs-backlog-review` as a silent daily rewrite engine.

`sdlc-conductor` is the **single default point of contact** for progression and for keeping cross-cutting institutional memory accurate after each handoff. Child skills still author their primary artefacts. Power users still call those children directly.

## 2. Two jobs in one skill

### Job A — Drive progression

1. Inspect the **target workspace** (the user’s project, not hard-coded to `ai-sdlc-harness`).
2. Recommend the next **legal** pipeline step (see §3), citing discovery signals (§4).
3. **Recommend → confirm → hand off** to the correct child skill (or to a human gate).
4. Skip a step only with **explicit user agreement** (§3.1).

The conductor does not silently become the product owner, story refiner, or implementer. After confirmation it follows the child skill’s own `CONTENT.md` / MCP contract, or tells the user to invoke that skill in a fresh turn when context is tight.

### Job B — Documentation steward / institutional memory

After each child-skill **outcome** (artefact written, status flipped, decision landed), update **cross-cutting** docs so memory stays accurate:

- backlog statuses and evidence notes
- product-spec / vision links
- user-story indexes
- ADRs when decisions actually land
- especially **`DOMAIN.md` / `LAYER.md`** (links, “last updated because…”, missing-file pointers)

Rules:

- Write **from evidence only**. No invented constraints, personas, SLOs, or “the domain forbids X” unless a `DOMAIN.md` (or equivalent) already says so.
- Own the **sync contract**, not every primary artefact. Children still author the spec, stories, `DOMAIN.md` body, setup workflows, and so on.
- Prefer **small, frequent** memory updates after each handoff over giant rewrites.
- Consequential merges stay **human-gated** (same review habit as daily docs/backlog reviews: open a PR, do not merge).

## 3. Pipeline states

Legal progression is a graph, not a slogan. Implementation must treat **one** graph as the source of truth (Epic 13; see §8). Until that artefact exists, this section is the graph.

```
vision
  → product-owner / product spec
    → epic approval (human)
      → per-epic user-story refine
        → setup-repository  (when code is about to start)
          → implement against user-story + feature DoD
            → later drivers as needed
              (review, test, e2e, security, RFC, ADR, release, …)
```

| State | Intent | Default child / gate | Exit when |
|---|---|---|---|
| **Vision** | Problem, personas, and goals exist as a durable doc | Human + existing vision (or a short vision draft — not a new skill in v1) | A vision doc the user accepts |
| **Product-owner / spec** | Vision → epics + product spec (PRD), MVP vs later | `sdlc-product-owner` | Spec + epic list exist; stories **not** written yet |
| **Epic approval** | Scope is a product decision | **Human** (conductor recommends; does not invent sign-off) | Named approval or explicit “treat as approved” from the user |
| **Story refine** | Per approved epic: BDD stories + AC | `sdlc-user-story-refiner` | Must AC are independently valuable and testable |
| **Setup-repo** | QA gates before / as first code lands | `sdlc-setup-repository` | Repo has agreed checks (CI, lint, secret scan, ownership) **or** user agrees the repo is already set up |
| **Implement** | Build the story; meet `user story` + `feature` DoD (and change-type DoD when UI/API/security apply) | Coding session + `sdlc-dod-checker` / `sdlc-test-writer` / `sdlc-code-reviewer` as needed | Must AC evidenced; human review for consequential merges |
| **Later drivers** | Research, RFC, ADR, threat/security, a11y, e2e, CI debug, runbook, release, migration, … | Matching existing skill | Invoked when the **current** need matches — not as a second hidden pipeline |

Optional **on-ramp** (not a skip of vision): `sdlc-researcher` when the user needs a spike before they can write an honest vision or spec.

Domain/layer architects are **not** a fixed pipeline stage. They fire when a bounded context or layer is new or its constraints actually changed. The conductor may recommend them; it does not invent `MUST` / `NEVER` lines itself.

### 3.1 Skip policy

- **Default:** do not skip. Recommend the next *legal* step even if the user is impatient.
- **Skip only** with an explicit user sentence (“skip setup-repo”, “we already have a spec, go to stories”).
- On skip, record **what was skipped, why, and who agreed** in the backlog or a short note next to the spec — evidence, not folklore.
- **Re-entry:** a skipped step can still be recommended later if discovery signals say it is missing (e.g. no CI when the first feature PR appears).
- **Experts:** may invoke any child skill directly. The conductor is a front door, not a prison. If the user already named `/sdlc-user-story-refiner`, do not force them back through vision.

## 4. Repo phase discovery signals

Discover the **open workspace**. Do not assume this harness’s paths. Prefer that repo’s own docs/backlog conventions (same habit as `sdlc-docs-backlog-review`).

Signals are **implications**, not proofs. Cite the files you actually opened.

| Implied phase | Typical signals (any strong subset) |
|---|---|
| **Vision needed** | No product vision; README is only a tech stub; user has a raw idea and no `docs/product/vision.md` (or equivalent). |
| **Product-owner / spec needed** | Vision exists; no product spec / PRD; backlog missing or has no epics; no MVP vs later split. |
| **Epic approval needed** | Spec + epics exist; epics still draft / unapproved; product-owner said “run story refine once epics are approved”. |
| **Story refine needed** | Approved (or user-confirmed) epic with no BDD stories, or stories that are tasks-in-disguise / missing Must AC. |
| **Setup-repo needed** | First implementation about to start; no CI, no lint/SAST/secret-scan, no `CODEOWNERS` (or repo equivalent); `sdlc-setup-repository` has never been run. |
| **Implement** | Refined story + AC exist; repo checks exist **or** were explicitly skipped; working tree / branches show feature work. |
| **Domain/layer steward needed** | Code or spec names a bounded context or layer and `DOMAIN.md` / `LAYER.md` is missing, stale vs shipped behavior, or contradicts the spec. **Hand off** to `sdlc-domain-architect` / `sdlc-layer-architect` for authorship; conductor only syncs indexes/links. |
| **Deep docs audit needed** | Many docs disagree with the tree, counts are wrong, or the user asked for a full review. **Invoke** `sdlc-docs-backlog-review` — do not silently rewrite the tree. |
| **Later driver** | Incident → postmortem; failing CI log → `sdlc-ci-debugger`; user-facing ship → release notes; decision in chat → `sdlc-adr-drafter`; and so on. |

### Honesty rules

- A labeled “planned” / roadmap section is not “missing implementation”.
- Green CI is not epic approval and not permission to merge.
- Absence of `DOMAIN.md` is not permission to invent domain rules.

## 5. Post-skill memory checklist

Run **after** a confirmed child outcome, not instead of the child. Keep the diff small.

| Artefact | Conductor updates when | Does **not** do |
|---|---|---|
| **Backlog** | Status/evidence no longer match the repo; new leftover work appeared; a skip was agreed | Invent epics the user did not accept; mark Done without evidence |
| **Vision ↔ spec links** | Spec or vision headings moved; MVP split changed | Rewrite the vision’s product claims |
| **User-story index** | New stories landed; story IDs or paths changed | Author the stories (that is `sdlc-user-story-refiner`) |
| **ADRs** | A decision was **accepted** in the session or a PR | Draft every design chat as an ADR; use `sdlc-adr-drafter` for the record body |
| **`DOMAIN.md` / `LAYER.md`** | Evidence shows a boundary or constraint **already** shipped or already written elsewhere | Invent MUST/NEVER; replace architect skills |
| **README / install / architecture pointers** | A shipped driver or path changed in *this* repo | Giant catalog rewrites (leave that to a review PR) |
| **`sdlc-docs-backlog-review`** | Drift is **suspected across many files**, status convention is unclear, or the user asked for a full audit | Daily silent rewrite; merge the review PR |

If the checklist would become a large audit, **stop** and recommend `/docs-backlog-review`. The conductor is a steward of the sync contract after one handoff, not a second full-repo reviewer.

## 6. Relationship to existing skills

| Skill | Relationship |
|---|---|
| **`sdlc-product-owner`** | Child for vision → epics / product spec. Conductor hands off; does not write sprint stories. |
| **`sdlc-user-story-refiner`** | Child for per-epic BDD stories. Conductor waits for epic approval (or an explicit skip). |
| **`sdlc-setup-repository`** | Child when code is starting and repo QA is missing. Conductor does not emit workflows itself. |
| **`sdlc-domain-architect` / `sdlc-layer-architect`** | Authors of `DOMAIN.md` / `LAYER.md`. Conductor detects staleness and hands off; may add cross-links after. |
| **`sdlc-docs-backlog-review`** | Deep docs↔repo audit that can open a **review PR and leave it open**. Conductor may *invoke* it when drift is suspected. It is not a silent daily rewrite engine, and the conductor is not a replacement for it. |
| **`sdlc-docs-updater`** | Narrow “docs for this code change” helper. Different from both conductor (memory contract) and docs-backlog-review (full audit). |
| **`sdlc-adr-drafter`** | Child when a decision lands. Conductor only decides *that* an ADR is due. |
| **`sdlc-researcher`** | Optional on-ramp / spike. Does not replace vision or spec. |
| **Implement-adjacent** (`sdlc-test-writer`, `sdlc-e2e-scripter`, `sdlc-code-reviewer`, `sdlc-dod-checker`, security/a11y, …) | Later drivers once a story is in implementation. Conductor recommends the one that matches the current gap vs DoD. |
| **`agents/`** | Still deferred. Conductor is a **skill**, not an agent package. |

MCP: reuse existing tools (`get_sdlc_template`, `get_definition_of_done`, `get_domain_consultant`, `get_layer_consultant`). A new MCP tool is **not** required for v1 unless implementation proves the pipeline graph cannot stay a fetched document (see Task 13.4).

## 7. Non-goals

- **Not a prison for power users.** Direct child-skill invocation stays first-class.
- **Not inventing DOMAIN / LAYER rules.** Evidence only; missing file → recommend the architect skill.
- **Not replacing child authorship.** Spec, stories, setup instructions, DOMAIN/LAYER bodies, ADRs, and review PRs stay with their skills.
- **Not a silent daily rewrite engine.** That failure mode belongs to a misused docs-backlog-review, not to the conductor.
- **Not an `agents/` package** and not named `sdlc-agent`.
- **Not auto-merge.** Consequential changes stay on a human-gated PR.
- **Not a new product methodology.** It sequences skills this harness already ships (plus human gates).

## 8. Implementation notes (for Epic 13 — not this PR)

- Author once in `CONTENT.md` with thin four-harness shells (`agy`, `claude`, `cursor`, `ghcp`), same as every other Lifecycle Driver.
- Suggested triggers: `/sdlc-conductor`, `/conductor`, “what next?”, “drive the SDLC”.
- Encode the **pipeline graph** (states, legal edges, skip rule, discovery table) as a **single source of truth** the skill cites — do not fork a second informal list in README.
- After handoff, run §5. If drift looks systemic, invoke `sdlc-docs-backlog-review`.
- Safety language: no fake approvals, no invented constraints, no exploit/malware guidance, no merge of the landing PR.

## 9. Open questions

1. **Approval evidence** — Is a backlog status flip enough for “epic approved”, or must the user type an explicit approval each time?
2. **In-session handoff vs “please run `/skill`”** — Some hosts nest skills poorly. Prefer in-session follow-through when the child `CONTENT.md` is available; otherwise a one-line invoke.
3. **Pipeline graph home** — Design note vs `CONTENT.md` vs a new MCP template (`lifecycle pipeline`). Recommendation: start in `CONTENT.md` (or a sibling file the skill reads); promote to MCP only if multiple skills must fetch the same graph.
4. **Target-repo conventions** — How far to standardize vision/spec/backlog paths vs “discover like docs-backlog-review”? Recommendation: discover first; only suggest `docs/product/` when the repo has no tracker.
5. **Story index format** — New file vs a section in the spec vs links in the backlog? Leave to implementation once a real target repo is used.
6. **Setup-repo vs brownfield** — For repos that already have CI, is the default “skip with recommendation” or “always ask”? Recommendation: if signals show checks exist, treat setup as satisfied and say so.
7. **Research in the main line** — Keep as optional on-ramp, or add an explicit `research` state when the vision is too thin to spec?

---

Related: Epic 13 in [`docs/product/backlog.md`](../product/backlog.md). Child skills live under `skills/`. Consultants remain MCP-discovered `DOMAIN.md` / `LAYER.md`.
