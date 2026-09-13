# Definition of Done: User Story

A user story is **Done** when a user (or stated actor) can achieve the `So that` using the shipped increment, and the Must AC are evidenced. Pair with template `user_story` and skill `sdlc-user-story-refiner`.

## Required

- [ ] **Story shape** — As a / I want / So that with a real actor; no task-disguised-as-story unless the user asked for a chore
- [ ] **Must AC true** — each Given/When/Then demonstrated (automated test and/or recorded check)
- [ ] **Independent value** — can ship without the next story, or the dependency is explicit
- [ ] **Scope** — Nice items not silently required; out-of-scope listed
- [ ] **Domain rules** — MUST/NEVER from the relevant Domain consultant applied
- [ ] **Feature DoD** — implementation also meets `feature` (and `ui change` / `api change` when those apply)
- [ ] **Open questions closed** or moved to a follow-up story (not silently answered with fiction)

## Not done if

- AC were added after coding to match whatever shipped
- Only a backend merged with no user-observable outcome when the story was user-facing
- Invented personas, KPIs, or SLAs

## Agent notes

Aliases: `story`, `user story`, `stories`. Fetch `get_sdlc_template("user story")` before refining. Do not mark Done because a ticket moved on a board.
