# Definition of Done: Data Migration

A data or schema migration is **Done** when the target shape is verified and the rollback story is real — not when a job printed "OK". Pair with `migration_plan` and skill `sdlc-migration-planner`.

## Required

- [ ] **Written plan** — `migration_plan` with expand/migrate/contract, batches, and abort conditions
- [ ] **Expand before contract** — old readers/writers still work until cutover evidence exists (unless a documented offline window was used)
- [ ] **Rehearsal** — run in a non-prod env *or* an explicit residual-risk acceptance by a named role
- [ ] **Backup/restore known** — or the plan states that backup is unknown and the migration must not proceed
- [ ] **Verification queries** — counts/checksums/canaries recorded (no invented row counts as "success")
- [ ] **Idempotent job** — safe to resume; throttle documented
- [ ] **Rollback** — tested or clearly data-lossy with acceptance
- [ ] **App compatibility** — code that requires the new shape ships in the correct order
- [ ] **Privacy** — no production dumps in tickets; samples anonymized
- [ ] **Follow-up** — contract/cleanup ticket if old columns/paths remain

## Not done if

- Migration mixed with an unrelated feature dump
- Verification is "the deploy succeeded"
- Rollback is "restore from backup" with no backup owner

## Agent notes

`get_definition_of_done("data migration")`. Do not alias this to the `migration plan` template in your head — fetch both. Stay defensive; no data-exfil instructions.
