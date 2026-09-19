# Design note: `sdlc-conductor`

Status: **proposed** (design + backlog only). The skill is **not shipped**. Do not treat `/sdlc-conductor` as an installed driver until Epic 13 implements `skills/sdlc-conductor/`.

This note records the agreed product intent for a default front-door Lifecycle Driver. Name: **`sdlc-conductor`** (not `sdlc-agent`). A dedicated `agents/` tree remains deferred, and “agent” collides with that future package type.

## 1. Problem / why

Today the harness is a **menu of specialist skills**. That works for experts who already know the legal next step. It fails for the common question:

> “I have this repo / this idea — **what next?**”

Without a conductor, models either:

- jump straight to code and skip vision, spec, epic approval, story refine, **or design/planning**, or
- rewrite `DOMAIN.md` / `LAYER.md` / the backlog from memory instead of evidence, or
- treat `sdlc-docs-backlog-review` as a silent daily rewrite engine.

`sdlc-conductor` is the **single default point of contact** for progression and for keeping cross-cutting institutional memory accurate after each handoff. Child skills still author their primary artefacts. Power users still call those children directly.

## 2. Two jobs in one skill

### Job A — Drive progression

1. Inspect the **target workspace** (the user’s project, not hard-coded to `ai-sdlc-harness`).
2. Recommend the next **legal** pipeline step (see §3), citing discovery signals (§4).
3. **Recommend → confirm → hand off** to the correct child skill (or to a human gate).
4. Skip a step only with **explicit user agreement** (§3.1).

The conductor does not silently become the product owner, story refiner, designer, or implementer. After confirmation it follows the child skill’s own `CONTENT.md` / MCP contract, or tells the user to invoke that skill in a fresh turn when context is tight.

### Job B — Documentation steward / institutional memory

After each child-skill **outcome** (artefact written, status flipped, decision landed), update **cross-cutting** docs so memory stays accurate:

- backlog statuses and evidence notes
- product-spec / vision links
- user-story indexes
- design-artefact indexes (RFC / API design / contract / test plan / e2e plan / UX artefact / ADR links)
- ADRs when decisions actually land
- especially **`DOMAIN.md` / `LAYER.md`** (links, “last updated because…”, missing-file pointers)

Rules:

- Write **from evidence only**. No invented constraints, personas, SLOs, or “the domain forbids X” unless a `DOMAIN.md` (or equivalent) already says so.
- Own the **sync contract**, not every primary artefact. Children still author the spec, stories, RFC / API / test-plan bodies, `DOMAIN.md` body, setup workflows, and so on. The conductor does **not** invent UI or UX.
- Prefer **small, frequent** memory updates after each handoff over giant rewrites.
- Consequential merges stay **human-gated** (same review habit as daily docs/backlog reviews: open a PR, do not merge).

## 3. Pipeline states

Legal progression is a graph, not a slogan. Implementation must treat **one** graph as the source of truth (Epic 13; see §8). Until that artefact exists, this section is the graph.

```
vision
  → product-owner / product spec
    → epic approval (human)
      → per-epic user-story refine
        → design & planning band (per epic or per release slice — may parallelize where legal):
             • technical design (architecture / API / RFC / ADR as needed)
             • UI/UX design (honest: harness has weak dedicated UX skill today — a11y exists; note gap / human or external design artefact)
             • test strategy (test plan + e2e plan; threat model / security review when the slice warrants)
             • domain/layer update when bounds actually change (hand off to architects)
          → setup-repository (when first code is about to land, if QA not already present)
            → implement against user-story + feature DoD (+ change-type DoD)
              → verify (tests, review, DoD check) — may stay adjacent to implement
                → later/ops drivers as needed
```

The **main path is not** stories → setup → code. Design and planning are first-class. Do not dump RFC, API design, test strategy, or UX into “later drivers”.

| State | Intent | Default child / gate | Exit when |
|---|---|---|---|
| **Vision** | Problem, personas, and goals exist as a durable doc | Human + existing vision (or a short vision draft — not a new skill in v1) | A vision doc the user accepts |
| **Product-owner / spec** | Vision → epics + product spec (PRD), MVP vs later | `sdlc-product-owner` | Spec + epic list exist; stories **not** written yet |
| **Epic approval** | Scope is a product decision | **Human** (conductor recommends; does not invent sign-off) | Named approval or explicit “treat as approved” from the user |
| **Story refine** | Per approved epic: BDD stories + AC | `sdlc-user-story-refiner` | Must AC are independently valuable and testable |
| **Technical design** | Architecture, API shape, and accepted decisions for the slice about to be built | `sdlc-rfc-drafter`, `sdlc-api-designer`, `sdlc-adr-drafter`; MCP templates `rfc`, `api design` / `api contract`, `adr`. Domain/layer architects when bounds change (same band) | Agreed tech-design artefact exists for the epic/slice (RFC and/or API design/contract, plus ADR if a decision landed) |
| **UI/UX design** | Agreed interaction, flow, and copy **before** UI is coded | **Skill gap:** no dedicated UX designer skill today. Conductor **must not invent UI**. Recommend a human designer, an existing external artefact (wireframes / flows / copy), or a future `sdlc-ux-designer`. `sdlc-a11y-auditor` is **verify-time**, not design-time | Agreed UX artefact exists (wireframes, flows, copy, or equivalent the user points at) **or** explicit skip recorded (e.g. no UI in this slice) |
| **Test strategy** | How the slice will be proven, written **before** implementation tests are generated | MCP templates `test_plan`, `e2e_test_plan`. `sdlc-threat-modeler` / `sdlc-security-reviewer` (templates `threat_model`, `security review`) when the slice is security-sensitive. `sdlc-test-writer` / `sdlc-e2e-scripter` are **later execution**, not this state’s authors | Test plan (and e2e plan when there is a user journey) exists and is linked; threat/security artefacts exist when warranted |
| **Domain / layer (in-band)** | Constraints match the design that is about to be built | `sdlc-domain-architect` / `sdlc-layer-architect` when a bounded context or layer is new or its constraints **actually changed**. Conductor does not invent `MUST` / `NEVER` | Relevant `DOMAIN.md` / `LAYER.md` exist and do not contradict the spec or tech design — or no bound changed |
| **Setup-repo** | QA gates **after** planning and **before** first implement (or already satisfied) | `sdlc-setup-repository` when first code is about to land and checks are missing. Brownfield: treat as satisfied if CI/lint/secret-scan/ownership already exist, and say so | Repo has agreed checks **or** user agrees the repo is already set up |
| **Implement** | Build the story against agreed design + AC | Coding session. Meet `user story` + `feature` DoD and change-type DoD (`ui change`, `api change`, `security change`) when those apply | Must AC demonstrably in progress or met; no silent extra features |
| **Verify** | Prove the increment; may stay **adjacent** to implement | `sdlc-test-writer`, `sdlc-e2e-scripter` (execute the strategy), `sdlc-code-reviewer`, `sdlc-dod-checker`, `sdlc-a11y-auditor` for UI | Tests + review + DoD check match the strategy; human review for consequential merges |
| **Later / ops drivers** | Ship, operate, recover — **not** a dumping ground for design | `sdlc-release-notes-generator`, `sdlc-runbook-writer`, `sdlc-migration-planner`, `sdlc-postmortem-writer`, `sdlc-ci-debugger`, … | Invoked when the **current** ops/ship need matches |

The **design & planning band** (technical design, UI/UX, test strategy, domain/layer-if-bounds-change) may run **in parallel** where legal — e.g. test strategy and RFC together. It is still a **gate** before setup-repo / implement: do not start first code for that slice while a required band item is missing, unless the user explicitly skipped it (§3.1).

Optional **on-ramp** (not a skip of vision): `sdlc-researcher` when the user needs a spike before they can write an honest vision or spec.

### 3.1 Skip policy

- **Default:** do not skip. Recommend the next *legal* step even if the user is impatient. That includes **design and planning** — stories are not a license to code.
- **Skip only** with an explicit user sentence (“skip setup-repo”, “we already have a spec, go to stories”, “skip UX — no UI in this epic”, “skip RFC, API already frozen in `docs/…`”).
- On skip, record **what was skipped, why, and who agreed** in the backlog or a short note next to the spec — evidence, not folklore. Design/planning skips use the **same** bar as every other stage.
- **Re-entry:** a skipped step can still be recommended later if discovery signals say it is missing (e.g. no CI when the first feature PR appears; no test plan when implementation starts).
- **Experts:** may invoke any child skill directly. The conductor is a front door, not a prison. If the user already named `/sdlc-user-story-refiner` or `/rfc`, do not force them back through vision.
- **Thin / chore epics:** an explicit skip of the design band is legal for pure docs or chore work; still record it. See open question 8.

## 4. Repo phase discovery signals

Discover the **open workspace**. Do not assume this harness’s paths. Prefer that repo’s own docs/backlog conventions (same habit as `sdlc-docs-backlog-review`).

Signals are **implications**, not proofs. Cite the files you actually opened.

| Implied phase | Typical signals (any strong subset) |
|---|---|
| **Vision needed** | No product vision; README is only a tech stub; user has a raw idea and no `docs/product/vision.md` (or equivalent). |
| **Product-owner / spec needed** | Vision exists; no product spec / PRD; backlog missing or has no epics; no MVP vs later split. |
| **Epic approval needed** | Spec + epics exist; epics still draft / unapproved; product-owner said “run story refine once epics are approved”. |
| **Story refine needed** | Approved (or user-confirmed) epic with no BDD stories, or stories that are tasks-in-disguise / missing Must AC. |
| **Design / planning incomplete** | Stories (or Must AC) exist for the epic/slice about to be built, but one or more required band artefacts are missing: no technical design / RFC, no API design or `api_contract` when the slice adds or changes an interface, no UX artefact (wireframes/flows/copy) when the slice is user-facing, no `test_plan` / `e2e_test_plan`, no threat model when the slice is security-sensitive, or `DOMAIN.md` / `LAYER.md` missing/stale after a bound change. **Do not** treat this as “ready to implement”. |
| **Technical design needed** | Slice touches architecture or a new/changed API and there is no RFC, API design/contract, or accepted ADR covering it. |
| **UI/UX design needed** | Slice is user-facing and there is no agreed UX artefact. Do **not** invent screens; ask for human/external design or record an explicit skip. |
| **Test strategy needed** | Slice has stories but no test plan (and no e2e plan when a journey exists). |
| **Setup-repo needed** | Planning band is done or skipped; first implementation about to start; no CI, no lint/SAST/secret-scan, no `CODEOWNERS` (or repo equivalent); `sdlc-setup-repository` has never been run. |
| **Implement** | Refined story + AC exist; **design/planning band satisfied or explicitly skipped**; repo checks exist **or** were explicitly skipped; working tree / branches show feature work. |
| **Verify needed** | Code exists for the slice but tests, review, or DoD evidence do not match the test strategy. |
| **Domain/layer steward needed** | Spec, RFC, or code names a bounded context or layer and `DOMAIN.md` / `LAYER.md` is missing, stale vs shipped or designed behavior, or contradicts the spec. **Hand off** to `sdlc-domain-architect` / `sdlc-layer-architect` for authorship; conductor only syncs indexes/links. |
| **Deep docs audit needed** | Many docs disagree with the tree, counts are wrong, or the user asked for a full review. **Invoke** `sdlc-docs-backlog-review` — do not silently rewrite the tree. |
| **Later / ops driver** | Incident → postmortem; failing CI log → `sdlc-ci-debugger`; user-facing ship → release notes; migration about to run → `sdlc-migration-planner`. Design-time RFC/ADR/threat work belongs in the planning band, not here. |

### Honesty rules

- A labeled “planned” / roadmap section is not “missing implementation”.
- Green CI is not epic approval and not permission to merge.
- Absence of `DOMAIN.md` is not permission to invent domain rules.
- Refined stories are not permission to skip technical design, UX, or test strategy.

## 5. Post-skill memory checklist

Run **after** a confirmed child outcome, not instead of the child. Keep the diff small.

| Artefact | Conductor updates when | Does **not** do |
|---|---|---|
| **Backlog** | Status/evidence no longer match the repo; new leftover work appeared; a skip was agreed | Invent epics the user did not accept; mark Done without evidence |
| **Vision ↔ spec links** | Spec or vision headings moved; MVP split changed | Rewrite the vision’s product claims |
| **User-story index** | New stories landed; story IDs or paths changed | Author the stories (that is `sdlc-user-story-refiner`) |
| **Design-artefact index** | RFC, API design/contract, test plan, e2e plan, UX artefact, or threat model **landed** (path + which epic/slice) | Author those bodies — children (or a human designer) do |
| **ADRs** | A decision was **accepted** in the session or a PR | Draft every design chat as an ADR; use `sdlc-adr-drafter` for the record body |
| **`DOMAIN.md` / `LAYER.md`** | Evidence shows a boundary or constraint **already** shipped, designed, or already written elsewhere | Invent MUST/NEVER; replace architect skills |
| **README / install / architecture pointers** | A shipped driver or path changed in *this* repo | Giant catalog rewrites (leave that to a review PR) |
| **`sdlc-docs-backlog-review`** | Drift is **suspected across many files**, status convention is unclear, or the user asked for a full audit | Daily silent rewrite; merge the review PR |

If the checklist would become a large audit, **stop** and recommend `/docs-backlog-review`. The conductor is a steward of the sync contract after one handoff, not a second full-repo reviewer.

## 6. Relationship to existing skills

| Skill | Relationship |
|---|---|
| **`sdlc-product-owner`** | Child for vision → epics / product spec. Conductor hands off; does not write sprint stories. |
| **`sdlc-user-story-refiner`** | Child for per-epic BDD stories. Conductor waits for epic approval (or an explicit skip). |
| **`sdlc-rfc-drafter` / `sdlc-api-designer` / `sdlc-adr-drafter`** | Children in the **technical design** band. Templates `rfc`, `api design` / `api contract`, `adr`. Conductor syncs links after they land; does not author the RFC/API/ADR body. |
| **UX (gap)** | No dedicated `sdlc-ux-designer` (or similar) yet. Conductor must not invent UI. Recommend human/external artefact; optional future skill is Task 13.6. |
| **Test strategy vs execution** | Strategy uses MCP `test_plan` / `e2e_test_plan` (and `threat_model` / `security review` when warranted) **before** code. `sdlc-test-writer` / `sdlc-e2e-scripter` execute that plan at **verify** time. `sdlc-threat-modeler` / `sdlc-security-reviewer` sit in the planning band when the slice is security-sensitive. |
| **`sdlc-setup-repository`** | Child **after** planning, when first code is about to land and repo QA is missing. Brownfield CI can satisfy this state. Conductor does not emit workflows itself. |
| **`sdlc-domain-architect` / `sdlc-layer-architect`** | Authors of `DOMAIN.md` / `LAYER.md`. Fire in the design band when bounds actually change; conductor detects staleness and hands off; may add cross-links after. |
| **`sdlc-docs-backlog-review`** | Deep docs↔repo audit that can open a **review PR and leave it open**. Conductor may *invoke* it when drift is suspected. It is not a silent daily rewrite engine, and the conductor is not a replacement for it. |
| **`sdlc-docs-updater`** | Narrow “docs for this code change” helper. Different from both conductor (memory contract) and docs-backlog-review (full audit). |
| **`sdlc-researcher`** | Optional on-ramp / spike. Does not replace vision, spec, or the design band. |
| **Verify-adjacent** (`sdlc-test-writer`, `sdlc-e2e-scripter`, `sdlc-code-reviewer`, `sdlc-dod-checker`, `sdlc-a11y-auditor`) | Adjacent to **implement**, not a substitute for test strategy or UX design. A11y is verify-time. |
| **Later / ops** (`sdlc-release-notes-generator`, `sdlc-runbook-writer`, `sdlc-migration-planner`, `sdlc-postmortem-writer`, `sdlc-ci-debugger`, …) | After a ship/ops need appears. Not where RFC, API design, or test strategy live. |
| **`agents/`** | Still deferred. Conductor is a **skill**, not an agent package. |

MCP: reuse existing tools (`get_sdlc_template`, `get_definition_of_done`, `get_domain_consultant`, `get_layer_consultant`). A new MCP tool is **not** required for v1 unless implementation proves the pipeline graph cannot stay a fetched document (see Task 13.4).

## 7. Non-goals

- **Not a prison for power users.** Direct child-skill invocation stays first-class.
- **Not inventing DOMAIN / LAYER rules or UI/UX.** Evidence only; missing file → recommend the architect skill or a human designer. No dedicated UX skill exists yet.
- **Not replacing child authorship.** Spec, stories, RFC / API / test-plan bodies, setup instructions, DOMAIN/LAYER bodies, ADRs, and review PRs stay with their skills (or a human for UX).
- **Not a silent daily rewrite engine.** That failure mode belongs to a misused docs-backlog-review, not to the conductor.
- **Not treating design as “later drivers”.** Technical design, UX, and test strategy sit on the main line after stories and before (or tightly gated with) first implement.
- **Not an `agents/` package** and not named `sdlc-agent`.
- **Not auto-merge.** Consequential changes stay on a human-gated PR.
- **Not a new product methodology.** It sequences skills this harness already ships (plus human gates).

## 8. Implementation notes (for Epic 13 — not this PR)

- Author once in `CONTENT.md` with thin four-harness shells (`agy`, `claude`, `cursor`, `ghcp`), same as every other Lifecycle Driver.
- Suggested triggers: `/sdlc-conductor`, `/conductor`, “what next?”, “drive the SDLC”.
- Encode the **pipeline graph** (states, legal edges, skip rule, discovery table) as a **single source of truth** the skill cites — including the design & planning band. Do not fork a second informal list in README, and do not collapse the graph to stories → setup → code.
- After handoff, run §5. If drift looks systemic, invoke `sdlc-docs-backlog-review`.
- Safety language: no fake approvals, no invented constraints, no invented UI, no exploit/malware guidance, no merge of the landing PR.

## 9. Open questions

1. **Approval evidence** — Is a backlog status flip enough for “epic approved”, or must the user type an explicit approval each time?
2. **In-session handoff vs “please run `/skill`”** — Some hosts nest skills poorly. Prefer in-session follow-through when the child `CONTENT.md` is available; otherwise a one-line invoke.
3. **Pipeline graph home** — Design note vs `CONTENT.md` vs a new MCP template (`lifecycle pipeline`). Recommendation: start in `CONTENT.md` (or a sibling file the skill reads); promote to MCP only if multiple skills must fetch the same graph.
4. **Target-repo conventions** — How far to standardize vision/spec/backlog paths vs “discover like docs-backlog-review”? Recommendation: discover first; only suggest `docs/product/` when the repo has no tracker.
5. **Story index format** — New file vs a section in the spec vs links in the backlog? Leave to implementation once a real target repo is used.
6. **Setup-repo vs brownfield** — For repos that already have CI, is the default “skip with recommendation” or “always ask”? Recommendation: if signals show checks exist, treat setup as satisfied and say so.
7. **Research in the main line** — Keep as optional on-ramp, or add an explicit `research` state when the vision is too thin to spec?
8. **Design band scope** — Is the design & planning band required **per epic** always, or only for “thick” epics? **Recommendation:** default **per-epic** for MVP epics that touch UX or new APIs; allow an **explicit skip** (same skip policy) for pure docs/chore epics. A release-slice band is legal when several thin epics share one API/UX surface — record which epics it covers.
9. **Who authors the test-strategy doc** — There is no `sdlc-test-planner` skill. Until one exists, the conductor should hand the `test_plan` / `e2e_test_plan` templates to the session (or a human) and **not** pretend `sdlc-test-writer` is the strategy author.

---

Related: Epic 13 in [`docs/product/backlog.md`](../product/backlog.md). Child skills live under `skills/`. Consultants remain MCP-discovered `DOMAIN.md` / `LAYER.md`.
