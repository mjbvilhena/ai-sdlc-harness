# Release Notes

User-facing notes for a shipped version. Pair with skill `sdlc-release-notes-generator` and Definition of Done `release`.

**Quality bar:** Every item is traceable to a commit, PR, or ticket the user provided. Language is for the user of the product, not the git log. No marketing claims, unreleased work, or invented capabilities.

## Metadata

| Field | Value |
|---|---|
| Version / tag | as given (do not invent semver) |
| Date | |
| Audience | end users / admins / API consumers |
| Source range | `git log A..B`, tag, or PR list |

## Highlights

Optional 1–3 items the audience must not miss (breaking change, required action, major feature that is *in the source range*).

## Breaking changes and required action

Call this section out first when anything in it exists.

- **Change:** what stopped working
- **Who is affected**
- **What to do** (upgrade step, flag, API field)
- **Source:** PR/commit

If none: write `None in this range.`

## New features

- User-visible capability in plain language
- Source: PR/commit
- Flag or entitlement only if evidenced

## Fixes

- What was wrong for the user, now corrected
- Source: PR/commit

## Improvements

Non-functional but user-noticeable (performance, a11y, clarity). Still sourced.

## Deprecations

What will go away, when (only if stated in source), and replacement.

## Internal-only (optional)

Omit by default. Include only if the user asked for a full changelog (chores, refactors).

## Known issues

Only if present in the source materials or the user listed them. Do not invent.

## Anti-patterns

- Invented features or "industry-leading" claims
- Secrets, internal hostnames, customer names
- Commit subjects dumped without translation
- Listing work that is not in the stated range
