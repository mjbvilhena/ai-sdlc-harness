# Definition of Done: Repository Setup

A repository setup is **Done** when the foundational configuration, access, and continuous integration checks are established to ensure a secure and robust software development lifecycle from day one.

## Required

- [ ] **Purpose Defined** — The repository has a `README.md` that clearly states its purpose and expected content.
- [ ] **Ownership Established** — A `CODEOWNERS` file is present, defining default reviewers for pull requests.
- [ ] **Secret Scanning** — CI/CD pipelines (e.g., GitHub Actions) include automated secret scanning (like `gitleaks`) to prevent credential leakage.
- [ ] **Content-Specific QA** — Appropriate linting, formatting, and SAST tools are configured for the primary languages used (e.g., `shellcheck` and `bats` for bash, `bandit` for Python, `markdownlint` for docs).
- [ ] **Gitignore** — A `.gitignore` file exists and covers the relevant tech stack's generated files and artifacts.
- [ ] **Branch Protection** — (If applicable) Guidelines or documentation for branch protection rules (e.g., requiring PR reviews before merging) are noted.

## Not done if

- The repository lacks a clear description or purpose.
- Automated security checks for secrets are omitted.
- Expected content types (like Python scripts) lack foundational linting or testing workflows.

## Agent notes

`get_definition_of_done("repository_setup")` or fuzzy `repo setup`. Used by the `sdlc-setup-repository` skill.
