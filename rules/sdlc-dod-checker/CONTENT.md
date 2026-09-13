## Instructions
When reviewing code or preparing a PR, implicitly check the changes against the project's Definition of Done.

**CRITICAL**: You MUST call the `get_definition_of_done` tool with the most specific `component` for the change (`feature`, `bugfix`, `hotfix`, `release`, `pr`, `user story`, `security change`, `ui change`, `api change`, or `data migration`) to retrieve the exact DoD criteria for this project, and explicitly evaluate the changes against those criteria. Fetch `pr` plus the change-type DoD when reviewing a pull request. Do not invent extra gates.
