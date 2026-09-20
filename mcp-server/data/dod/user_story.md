# Definition of Done: User Story

A user story **artefact** is ready for the human approval gate when the shape checks below pass. Drafting that artefact (or merging the file) is **not** approval — a **named** human sign-off or an explicit “treat as approved” sentence is required. Do not invent stakeholder sign-off.

A user story’s **implementation** is **Done** when a user (or stated actor) can achieve the `So that` using the shipped increment, **test automation passes without errors**, and **all Must acceptance criteria are fully met**. Pair with template `user_story`, skill `sdlc-user-story-refiner` (artefact), and `sdlc-implementer` (code).

If some Must AC cannot be met: do **not** soft-pass — **create additional user stories** for the unmet criteria (this story stays not-Done until its remaining Musts are met).

## Required

- [ ] **Story shape** — As a / I want / So that with a real actor; no task-disguised-as-story unless the user asked for a chore
- [ ] **Must AC fully met** — every Must Given/When/Then is true in the shipped increment
- [ ] **Automation green** — test automation for those Must AC passes without errors (not “draft exists”, not a board status flip, not a recorded check that substitutes for failing or missing automation)
- [ ] **Independent value** — can ship without the next story, or the dependency is explicit
- [ ] **Scope** — Nice items not silently required; out-of-scope listed
- [ ] **Domain rules** — MUST/NEVER from the relevant Domain consultant applied
- [ ] **Feature DoD** — implementation also meets `feature` (and `ui change` / `api change` when those apply)
- [ ] **Open questions closed** or moved to a follow-up story (not silently answered with fiction)

## Not done if

- Only a draft exists, a file was merged, or a ticket moved on a board
- AC were added after coding to match whatever shipped
- Automation is red, skipped, or absent for Must AC
- Some Must AC were dropped or “partially met” without splitting them into new stories
- Only a backend merged with no user-observable outcome when the story was user-facing
- Invented personas, KPIs, or SLAs
- Invented human approval

## Agent notes

Aliases: `story`, `user story`, `stories`. Fetch `get_sdlc_template("user story")` before refining. Do not mark Done because a ticket moved on a board. Do not mark the artefact approved because it was drafted or merged.
