# Design note: `sdlc-conductor`

Status: **implemented** as `skills/sdlc-conductor/` (runtime graph lives in MCP template `lifecycle pipeline`, fetched via `get_sdlc_template`). This note remains the human-facing design. Open questions in §9 may still be parked (Q1 is resolved).

This note records the agreed product intent for a default front-door Lifecycle Driver. Name: **`sdlc-conductor`** (not `sdlc-agent`). A dedicated `agents/` tree remains deferred, and “agent” collides with that future package type.

**Artefact approval (resolved):** product spec, epics, **user-story artefacts**, and technical design documents **including ADRs** need a **named** human sign-off or an explicit “treat as approved” sentence before they count as approved / ready for the next gate. Drafted or merged files and a backlog status flip are **not** approval. Do not invent stakeholder sign-off. See §3 and §9 Q1.

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

Legal progression is a graph, not a slogan. The **runtime** graph lives in MCP template `lifecycle pipeline` (`get_sdlc_template`; aliases `conductor`, `sdlc conductor`). Skill `CONTENT.md` is thin orchestration that must fetch that payload first. This section is the human-facing copy and must stay aligned with the MCP template.

```
vision
  → product-owner / product spec (draft)
    → product spec approval (human)
      → epic approval (human)
        → per-epic user-story refine (draft)
          → story approval (human)
            → design & planning band (per epic or per release slice — may parallelize where legal):
                 • technical design (architecture / API / RFC / ADR as needed)
                     → technical design / ADR approval (human)
                 • UI/UX design (`sdlc-ux-designer` — wireframes/flows/copy from stories; do not invent UI. Human/external artefacts still satisfy this state. `sdlc-a11y-auditor` is verify-time.)
                 • test strategy (test plan + e2e plan; threat model / security review when the slice warrants)
                 • domain/layer update when bounds actually change (hand off to architects)
              → setup-repository (when first code is about to land, if QA not already present)
                → implement against user-story + feature DoD (+ change-type DoD)
                  → verify (automation + review + DoD) — Done only when tests pass with no errors AND all Must AC are met
                    → later/ops drivers as needed
```

The **main path is not** stories → setup → code. Design and planning are first-class. Do not dump RFC, API design, test strategy, or UX into “later drivers”.

| State | Intent | Default child / gate | Exit when |
|---|---|---|---|
| **Vision** | Problem, personas, and goals exist as a durable doc | Human + existing vision (or a short vision draft — not a new skill in v1) | A vision doc the user accepts |
| **Product-owner / spec** | Vision → epics + product spec (PRD), MVP vs later | `sdlc-product-owner` | Spec + epic list are **drafted**; stories **not** written yet. Draft ≠ approval |
| **Product spec approval** | Spec is a product decision | **Human** (conductor recommends; does not invent sign-off) | Named human sign-off or explicit “treat as approved”. A drafted or merged spec file is **not** enough. A backlog status flip is **not** enough |
| **Epic approval** | Scope is a product decision | **Human** (conductor recommends; does not invent sign-off) | Named human sign-off or explicit “treat as approved”. Drafted/merged epic text and a status flip are **not** enough |
| **Story refine** | Per approved epic: BDD stories + AC | `sdlc-user-story-refiner` | Must AC are independently valuable and testable. Drafting the story artefacts is **not** approval |
| **Story approval** | Story artefacts are a product decision — first-class human gate, not only epics | **Human** (conductor recommends; does not invent sign-off) | Named human sign-off or explicit “treat as approved” on the **stories**. Epic approval is not story approval. Drafted or merged story files are **not** enough |
| **Technical design** | Architecture, API shape, and decisions being recorded for the slice about to be built | `sdlc-rfc-drafter`, `sdlc-api-designer`, `sdlc-adr-drafter`; MCP templates `rfc`, `api design` / `api contract`, `adr`. Domain/layer architects when bounds change (same band) | RFC and/or API design/contract **drafted**; ADR drafted if a decision is being recorded. Draft ≠ approval |
| **Technical design / ADR approval** | Technical design documents **including ADRs** are a product/architecture decision | **Human** (conductor recommends; does not invent sign-off) | Named human sign-off or explicit “treat as approved” on the RFC/API/ADR artefacts. Drafted or merged design files are **not** enough |
| **UI/UX design** | Agreed interaction, flow, and copy **before** UI is coded | `sdlc-ux-designer` (`/ux`, `/ux-design`). Conductor **must not invent UI**. An existing human or external artefact still satisfies this state. Fetch MCP template `ux design` (aliases `ux`, `wireframe`). `sdlc-a11y-auditor` is **verify-time**, not design-time | Agreed UX artefact exists (wireframes, flows, copy, or equivalent the user points at) **or** explicit skip recorded (e.g. no UI in this slice) |
| **Test strategy** | How the slice will be proven, written **before** implementation tests are generated | MCP templates `test_plan`, `e2e_test_plan`. `sdlc-threat-modeler` / `sdlc-security-reviewer` (templates `threat_model`, `security review`) when the slice is security-sensitive. `sdlc-test-writer` / `sdlc-e2e-scripter` are **later execution**, not this state’s authors | Test plan (and e2e plan when there is a user journey) exists and is linked; threat/security artefacts exist when warranted |
| **Domain / layer (in-band)** | Constraints match the design that is about to be built | `sdlc-domain-architect` / `sdlc-layer-architect` when a bounded context or layer is new or its constraints **actually changed**. Conductor does not invent `MUST` / `NEVER` | Relevant `DOMAIN.md` / `LAYER.md` exist and do not contradict the spec or tech design — or no bound changed |
| **Setup-repo** | QA gates **after** planning and **before** first implement (or already satisfied) | `sdlc-setup-repository` when first code is about to land and checks are missing. Brownfield: treat as satisfied if CI/lint/secret-scan/ownership already exist, and say so | Repo has agreed checks **or** user agrees the repo is already set up |
| **Implement** | Build the story against **approved** design + AC | Coding session. Meet `user story` + `feature` DoD and change-type DoD (`ui change`, `api change`, `security change`) when those apply | Planning artefacts above are **approved** (or an explicit skip/treat-as-approved was recorded). Must AC in progress; no silent extra features |
| **Verify** | Prove the increment; may stay **adjacent** to implement | `sdlc-test-writer`, `sdlc-e2e-scripter` (execute the strategy), `sdlc-code-reviewer`, `sdlc-dod-checker`, `sdlc-a11y-auditor` for UI | **Done** only when test automation passes without errors **and** all Must AC are fully met. If some Must AC cannot be met: do **not** soft-pass — create additional user stories. Human review for consequential merges |
| **Later / ops drivers** | Ship, operate, recover — **not** a dumping ground for design | `sdlc-release-notes-generator`, `sdlc-runbook-writer`, `sdlc-migration-planner`, `sdlc-postmortem-writer`, `sdlc-ci-debugger`, … | Invoked when the **current** ops/ship need matches |

The **design & planning band** (technical design, UI/UX, test strategy, domain/layer-if-bounds-change) may run **in parallel** where legal — e.g. test strategy and RFC together. It is still a **gate** before setup-repo / implement: do not start first code for that slice while a required band item is missing, unless the user explicitly skipped it (§3.1). Technical design documents **including ADRs** still need **human approval** (named sign-off or “treat as approved”) before implement. UI/UX stays “agreed UX artefact or explicit skip”, consistent with this band.

Optional **on-ramp** (not a skip of vision): `sdlc-researcher` when the user needs a spike before they can write an honest vision or spec.

### 3.1 Skip policy

- **Default:** do not skip. Recommend the next *legal* step even if the user is impatient. That includes **design and planning** — stories are not a license to code.
- **Skip only** with an explicit user sentence (“skip setup-repo”, “we already have a spec, go to stories”, “skip UX — no UI in this epic”, “skip RFC, API already frozen in `docs/…`”).
- **Human approval gates** (product spec, epics, **stories**, technical design/ADRs) advance only with a **named** human sign-off or an explicit “treat as approved” sentence. Merging a file or flipping a backlog status is **not** a skip and **not** approval.
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
| **Product spec approval needed** | Spec file exists; still draft / unapproved; no named human sign-off and no “treat as approved” sentence. |
| **Epic approval needed** | Spec approved (or treat-as-approved); epics still draft / unapproved; product-owner said “run story refine once epics are approved”. A backlog status flip alone is **not** approval. |
| **Story refine needed** | Approved epic with no BDD stories, or stories that are tasks-in-disguise / missing Must AC. |
| **Story approval needed** | Story artefacts exist for the epic; still draft / unapproved. Drafted stories are not permission to skip design or implement. |
| **Design / planning incomplete** | **Approved** stories (or Must AC) exist for the epic/slice about to be built, but one or more required band artefacts are missing: no technical design / RFC, no API design or `api_contract` when the slice adds or changes an interface, no UX artefact (wireframes/flows/copy) when the slice is user-facing, no `test_plan` / `e2e_test_plan`, no threat model when the slice is security-sensitive, or `DOMAIN.md` / `LAYER.md` missing/stale after a bound change. **Do not** treat this as “ready to implement”. |
| **Technical design needed** | Slice touches architecture or a new/changed API and there is no RFC, API design/contract, or ADR covering it. |
| **Technical design / ADR approval needed** | RFC / API design / ADR files exist; still draft / unapproved; no named human sign-off and no “treat as approved”. |
| **UI/UX design needed** | Slice is user-facing and there is no agreed UX artefact. Do **not** invent screens; hand off to `sdlc-ux-designer`, accept an existing human/external artefact, or record an explicit skip. |
| **Test strategy needed** | Slice has stories but no test plan (and no e2e plan when a journey exists). |
| **Setup-repo needed** | Planning band is done or skipped; first implementation about to start; no CI, no lint/SAST/secret-scan, no `CODEOWNERS` (or repo equivalent); `sdlc-setup-repository` has never been run. |
| **Implement** | **Approved** story + AC; technical design/ADRs **approved** or explicitly skipped/treat-as-approved; **remaining design/planning band satisfied or explicitly skipped**; repo checks exist **or** were explicitly skipped; working tree / branches show feature work. |
| **Verify needed** | Code exists for the slice but tests, review, or DoD evidence do not match the test strategy, automation is red, or Must AC are unmet. |
| **Domain/layer steward needed** | Spec, RFC, or code names a bounded context or layer and `DOMAIN.md` / `LAYER.md` is missing, stale vs shipped or designed behavior, or contradicts the spec. **Hand off** to `sdlc-domain-architect` / `sdlc-layer-architect` for authorship; conductor only syncs indexes/links. |
| **Deep docs audit needed** | Many docs disagree with the tree, counts are wrong, or the user asked for a full review. **Invoke** `sdlc-docs-backlog-review` — do not silently rewrite the tree. |
| **Later / ops driver** | Incident → postmortem; failing CI log → `sdlc-ci-debugger`; user-facing ship → release notes; migration about to run → `sdlc-migration-planner`. Design-time RFC/ADR/threat work belongs in the planning band, not here. |

### Honesty rules

- A labeled “planned” / roadmap section is not “missing implementation”.
- Green CI is not artefact approval and not permission to merge.
- Drafted or merged files (spec, epics, stories, RFC/ADR) are not approval. A backlog status flip is not named human approval.
- Absence of `DOMAIN.md` is not permission to invent domain rules.
- Refined stories are not story approval and not permission to skip technical design, UX, or test strategy.
- Do not invent stakeholder sign-off. Do not mark Done without evidence.

## 5. Post-skill memory checklist

Run **after** a confirmed child outcome, not instead of the child. Keep the diff small.

| Artefact | Conductor updates when | Does **not** do |
|---|---|---|
| **Backlog** | Status/evidence no longer match the repo; new leftover work appeared; a skip was agreed | Invent epics the user did not accept; mark Done without evidence / invent approval |
| **Vision ↔ spec links** | Spec or vision headings moved; MVP split changed | Rewrite the vision’s product claims |
| **User-story index** | New stories landed; story IDs or paths changed | Author the stories (that is `sdlc-user-story-refiner`); treat new drafts as approved |
| **Design-artefact index** | RFC, API design/contract, test plan, e2e plan, UX artefact, or threat model **landed** (path + which epic/slice) | Author those bodies — children (`sdlc-ux-designer` for UX) do; treat drafts as approved |
| **ADRs** | A decision was **accepted** (named human sign-off or “treat as approved”) | Draft every design chat as an ADR; use `sdlc-adr-drafter` for the record body; mark Accepted without approval |
| **`DOMAIN.md` / `LAYER.md`** | Evidence shows a boundary or constraint **already** shipped, designed, or already written elsewhere | Invent MUST/NEVER; replace architect skills |
| **README / install / architecture pointers** | A shipped driver or path changed in *this* repo | Giant catalog rewrites (leave that to a review PR) |
| **`sdlc-docs-backlog-review`** | Drift is **suspected across many files**, status convention is unclear, or the user asked for a full audit | Daily silent rewrite; merge the review PR |

If the checklist would become a large audit, **stop** and recommend `/docs-backlog-review`. The conductor is a steward of the sync contract after one handoff, not a second full-repo reviewer.

## 6. Relationship to existing skills

| Skill | Relationship |
|---|---|
| **`sdlc-product-owner`** | Child for vision → epics / product spec **drafts**. Conductor hands off; does not write sprint stories. Next gates are human **spec** approval and human **epic** approval. Does not approve stories. |
| **`sdlc-user-story-refiner`** | Child for per-epic BDD stories. Conductor waits for epic approval (or an explicit skip/treat-as-approved). Drafting ≠ approval; next gate is human **story** approval. |
| **`sdlc-rfc-drafter` / `sdlc-api-designer` / `sdlc-adr-drafter`** | Children in the **technical design** band. Templates `rfc`, `api design` / `api contract`, `adr`. Conductor syncs links after they land; does not author the RFC/API/ADR body. Next gate is human technical design / ADR approval. |
| **`sdlc-ux-designer`** | Child for the **UI/UX design** band. Authors wireframes/flows/copy from stories without inventing product claims. Fetch MCP template `ux design`. Conductor syncs links after the artefact lands; does not invent screens. A human/external artefact still satisfies the state. Task 13.6. |
| **Test strategy vs execution** | Strategy uses MCP `test_plan` / `e2e_test_plan` (and `threat_model` / `security review` when warranted) **before** code. `sdlc-test-writer` / `sdlc-e2e-scripter` execute that plan at **verify** time. `sdlc-threat-modeler` / `sdlc-security-reviewer` sit in the planning band when the slice is security-sensitive. |
| **`sdlc-setup-repository`** | Child **after** planning, when first code is about to land and repo QA is missing. Brownfield CI can satisfy this state. Conductor does not emit workflows itself. |
| **`sdlc-domain-architect` / `sdlc-layer-architect`** | Authors of `DOMAIN.md` / `LAYER.md`. Fire in the design band when bounds actually change; conductor detects staleness and hands off; may add cross-links after. |
| **`sdlc-docs-backlog-review`** | Deep docs↔repo audit that can open a **review PR and leave it open**. Conductor may *invoke* it when drift is suspected. It is not a silent daily rewrite engine, and the conductor is not a replacement for it. |
| **`sdlc-docs-updater`** | Narrow “docs for this code change” helper. Different from both conductor (memory contract) and docs-backlog-review (full audit). |
| **`sdlc-researcher`** | Optional on-ramp / spike. Does not replace vision, spec, or the design band. |
| **Verify-adjacent** (`sdlc-test-writer`, `sdlc-e2e-scripter`, `sdlc-code-reviewer`, `sdlc-dod-checker`, `sdlc-a11y-auditor`) | Adjacent to **implement**, not a substitute for test strategy or UX design. A11y is verify-time. |
| **Later / ops** (`sdlc-release-notes-generator`, `sdlc-runbook-writer`, `sdlc-migration-planner`, `sdlc-postmortem-writer`, `sdlc-ci-debugger`, …) | After a ship/ops need appears. Not where RFC, API design, or test strategy live. |
| **`agents/`** | Still deferred. Conductor is a **skill**, not an agent package. |

MCP: reuse existing tools (`get_sdlc_template`, `get_definition_of_done`, `get_domain_consultant`, `get_layer_consultant`). Runtime payloads include `lifecycle pipeline`, `ux design`, and `docs backlog review`. A new MCP *tool* is **not** required.

## 7. Non-goals

- **Not a prison for power users.** Direct child-skill invocation stays first-class.
- **Not inventing DOMAIN / LAYER rules or UI/UX.** Evidence only; missing file → recommend the architect skill or `sdlc-ux-designer` (or accept an existing human artefact). The conductor still does not invent screens.
- **Not replacing child authorship.** Spec, stories, RFC / API / test-plan / UX bodies, setup instructions, DOMAIN/LAYER bodies, ADRs, and review PRs stay with their skills.
- **Not a silent daily rewrite engine.** That failure mode belongs to a misused docs-backlog-review, not to the conductor.
- **Not treating design as “later drivers”.** Technical design, UX, and test strategy sit on the main line after stories and before (or tightly gated with) first implement.
- **Not an `agents/` package** and not named `sdlc-agent`.
- **Not auto-merge.** Consequential changes stay on a human-gated PR.
- **Not inventing artefact approval.** A draft, merge, or backlog status flip is not named human sign-off. Spec, epics, stories, and technical design/ADRs stay unapproved until that sign-off or an explicit “treat as approved”.
- **Not a new product methodology.** It sequences skills this harness already ships (plus human gates).

## 8. Implementation notes

Shipped as `skills/sdlc-conductor/` (PR #15) with thin four-harness shells. Triggers: `/sdlc-conductor`, `/conductor`, “what next?”, “drive the SDLC”.

- The **pipeline graph** (states, legal edges, skip rule, discovery table) lives in MCP template `lifecycle pipeline`. Skill `CONTENT.md` stays thin and must fetch that payload before executing. Do not fork a second informal list in README, and do not collapse the graph to stories → setup → code.
- UI/UX hand-off is `sdlc-ux-designer` (Task 13.6). Fetch MCP template `ux design` (aliases `ux`, `wireframe`).
- After handoff, run §5 (also in the pipeline template as Job B). If drift looks systemic, invoke `sdlc-docs-backlog-review` (template `docs backlog review`).
- Safety language: no fake approvals (including invented spec, epic, story, or technical-design/ADR sign-off), no invented constraints, no invented UI, no exploit/malware guidance, no merge of the landing PR.

## 9. Open questions

1. **Approval evidence** — **Resolved:** a backlog status flip is **not** enough. Product spec, epics, **user-story artefacts**, and technical design documents **including ADRs** require a **named** human sign-off or an explicit “treat as approved” sentence before they count as approved / ready for the next gate. Drafted or merged files are not approval. Do not invent stakeholder sign-off. Story-artefact approval is a first-class human gate (not only epics). Runtime copy lives in MCP template `lifecycle pipeline`.
2. **In-session handoff vs “please run `/skill`”** — Some hosts nest skills poorly. Prefer in-session follow-through when the child `CONTENT.md` is available; otherwise a one-line invoke.
3. **Pipeline graph home** — **Resolved:** runtime SSOT is MCP template `lifecycle pipeline`; this design note stays human-facing; skill `CONTENT.md` is thin orchestration that fetches the template.
4. **Target-repo conventions** — How far to standardize vision/spec/backlog paths vs “discover like docs-backlog-review”? Recommendation: discover first; only suggest `docs/product/` when the repo has no tracker.
5. **Story index format** — New file vs a section in the spec vs links in the backlog? Leave to implementation once a real target repo is used.
6. **Setup-repo vs brownfield** — For repos that already have CI, is the default “skip with recommendation” or “always ask”? Recommendation: if signals show checks exist, treat setup as satisfied and say so.
7. **Research in the main line** — Keep as optional on-ramp, or add an explicit `research` state when the vision is too thin to spec?
8. **Design band scope** — Is the design & planning band required **per epic** always, or only for “thick” epics? **Recommendation:** default **per-epic** for MVP epics that touch UX or new APIs; allow an **explicit skip** (same skip policy) for pure docs/chore epics. A release-slice band is legal when several thin epics share one API/UX surface — record which epics it covers.
9. **Who authors the test-strategy doc** — There is no `sdlc-test-planner` skill. Until one exists, the conductor should hand the `test_plan` / `e2e_test_plan` templates to the session (or a human) and **not** pretend `sdlc-test-writer` is the strategy author.

---

Related: Epic 13 in [`docs/product/backlog.md`](../product/backlog.md). Child skills live under `skills/`. Consultants remain MCP-discovered `DOMAIN.md` / `LAYER.md`.
