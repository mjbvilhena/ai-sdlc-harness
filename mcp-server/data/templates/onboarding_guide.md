# Onboarding Guide

Guide for a new contributor (human or agent) to get a **safe local** environment working and make a first change. Pair with docs-updater when the repo layout changes.

**Quality bar:** A reader can clone, run, test, and find where Domain/Layer rules live — without Slack. Commands match the repo. No secrets in the file.

## Metadata

| Field | Value |
|---|---|
| Audience | new engineer / agent / contractor |
| Last verified | date + OS (do not claim unverified steps) |
| Primary languages | as in repo |

## What this system is

5–8 sentences: problem, major runtime pieces, what not to touch in week one. Link vision/architecture docs that exist.

## Prerequisites

- Runtimes and versions *as the repo pins them*
- Accounts/tools that are actually required
- What the installer does vs what the app needs

## First-hour setup

Numbered commands from a clean clone. Expected output for each critical step.

1. Clone / checkout
2. Install dependencies
3. Config: copy `.env.example` (never commit real secrets)
4. Run app or tests
5. How to know it worked

## Repository map

| Path | Why it matters |
|---|---|
| `src/…` | … |
| `DOMAIN.md` / `LAYER.md` | consultant payloads |
| `mcp-server/` if present | JIT templates and DoD |

## How we work

- Branch, commit, PR conventions (link `pr` template / commit rule)
- How to fetch DoD and templates (MCP tools) instead of guessing
- Tests to run before review
- Where ADRs and RFCs live *if those directories exist*

## First useful tasks

3–5 starter tasks that are real in this repo (docs typo, test, small bug). Do not invent a product roadmap.

## Safety

- Local and documented test URLs only
- Never paste production credentials into chat or git
- Domain MUST/NEVER and Layer MUST/NEVER override convenience

## Getting help

- Code owners / team channels *if present in repo*
- What to attach to a question (SHA, command, redacted logs)

## Anti-patterns

- Steps that assume undocumented internal tools
- Fake "certified" training checklists
- Copying production connection strings
- Onboarding that is only a stack-marketing page
