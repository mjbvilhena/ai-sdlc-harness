# Definition of Done: PR

A pull request is **Done** (ready to merge, or merged per team practice) when reviewers can judge it from the page and the change-type DoD is also satisfied. Pair with template `pr` and skill `sdlc-pr-summarizer` / `sdlc-code-reviewer`.

## Required

- [ ] **Description matches the diff** — why, what, how to test; change-type boxes honest
- [ ] **Title** — conventional and specific
- [ ] **Review** — required approvals; comments resolved or explicitly deferred with a ticket
- [ ] **CI green** on the merge commit / latest revision
- [ ] **Tests and docs** — updated when behavior or contract changed
- [ ] **Consultants** — Domain/Layer MUST/NEVER not violated
- [ ] **Change-type DoD** — also fetch `feature`, `bugfix`, `hotfix`, `api change`, `ui change`, `security change`, or `data migration` as applicable
- [ ] **No secrets**, credentials, or personal data in the diff or screenshots
- [ ] **Conflicts resolved**; revert story is plausible

## Not done if

- WIP / draft still has "do not merge" intent
- Reviewers were told tests exist but CI does not run them
- Multiple unrelated features bundled to dodge review

## Agent notes

Aliases: `pr`, `pull request`. Always fetch the PR template. Pick the most specific additional DoD; do not only use `feature` for a migration.
