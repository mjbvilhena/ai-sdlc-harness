#!/usr/bin/env python3
"""Invariants for the GitHub Pages catalog shell.

The browser must discover skills and MCP data files at runtime. A hardcoded
inventory in the site would miss new files until someone edited the shell.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BROWSER = ROOT / "docs/browser"
APP_JS = BROWSER / "assets/app.js"
CONFIG_JS = BROWSER / "config.js"
INDEX = BROWSER / "index.html"


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    sys.exit(1)


def quoted_strings(text: str) -> set[str]:
    return set(re.findall(r'["\']([A-Za-z0-9_./-]+)["\']', text))


def main() -> None:
    if not APP_JS.is_file() or not CONFIG_JS.is_file() or not INDEX.is_file():
        fail("docs/browser is missing index.html, config.js, or assets/app.js")

    app = APP_JS.read_text(encoding="utf-8")
    config = CONFIG_JS.read_text(encoding="utf-8")
    index = INDEX.read_text(encoding="utf-8")

    if "mjbvilhena" not in config or "ai-sdlc-harness" not in config:
        fail("config.js must default to mjbvilhena/ai-sdlc-harness")
    if 'ref: "master"' not in config and "ref: 'master'" not in config:
        fail("config.js must default to ref master")

    for required in (
        "git/trees/",
        "recursive=1",
        "sessionStorage",
        "raw.githubusercontent.com",
        "mcp-server/data/",
        "skills/",
        "rate-limit",
        "skill.yaml",
        "CONTENT.md",
    ):
        if required not in app:
            fail(f"assets/app.js must implement live discovery ({required!r} missing)")

    # Inventory must come from the repo tree, not a baked-in list of packages.
    quoted = quoted_strings(app)
    skill_names = sorted(p.name for p in (ROOT / "skills").iterdir() if p.is_dir())
    if not skill_names:
        fail("no skills/ directories found to check against")
    leaked_skills = [name for name in skill_names if name in quoted]
    if leaked_skills:
        fail("assets/app.js hardcodes skill names: " + ", ".join(leaked_skills))

    data_root = ROOT / "mcp-server/data"
    leaked_files = []
    for folder in sorted(p for p in data_root.iterdir() if p.is_dir()):
        for md in folder.glob("*.md"):
            if md.name in quoted or md.stem in quoted:
                leaked_files.append(str(md.relative_to(ROOT)))
    if leaked_files:
        fail("assets/app.js hardcodes MCP data filenames: " + ", ".join(leaked_files))

    mermaid_js = BROWSER / "assets" / "mermaid.min.js"
    if not mermaid_js.is_file():
        fail("docs/browser/assets/mermaid.min.js is missing (vendored Mermaid renderer)")

    # Project Pages + local preview both need relative asset URLs.
    for rel in (
        'href="assets/style.css"',
        'src="config.js"',
        'src="assets/app.js"',
        'src="assets/marked.min.js"',
        'src="assets/mermaid.min.js"',
    ):
        if rel not in index:
            fail(f"index.html must use relative asset URL {rel}")
    if re.search(r"""(?:href|src)=["']/(?!/)""", index):
        fail("index.html has a root-absolute asset URL; use relative paths for project Pages")
    if "cdn.jsdelivr.net" in index or "unpkg.com" in index or "cdnjs.cloudflare.com" in index:
        fail("index.html must vendor Mermaid locally, not load it from a CDN")
    if "mermaid.render" not in app:
        fail("assets/app.js must run Mermaid on fenced diagrams (mermaid.render missing)")
    if "data-home-pipeline-diagram" not in app:
        fail("assets/app.js must render the lifecycle pipeline on Home")
    if "extractPrimaryMermaid" not in app:
        fail("assets/app.js must extract the primary mermaid block from the pipeline template")

    pipeline = ROOT / "mcp-server/data/templates/lifecycle_pipeline.md"
    if not pipeline.is_file():
        fail("mcp-server/data/templates/lifecycle_pipeline.md is missing (Home pipeline source)")
    pipeline_text = pipeline.read_text(encoding="utf-8")
    heading = re.search(
        r"(?is)##[^\n]*pipeline graph[^\n]*\n(.*)",
        pipeline_text,
    )
    search_in = heading.group(1) if heading else pipeline_text
    fence = re.search(r"```mermaid[ \t]*\r?\n(.*?)```", search_in, re.S)
    if not fence:
        fail("lifecycle_pipeline.md must have a mermaid fence under Pipeline graph (Home renders it)")
    mermaid = fence.group(1)
    for name in (
        "sdlc-threat-modeler",
        "sdlc-security-reviewer",
        "sdlc-bug-triager",
        "sdlc-pr-summarizer",
    ):
        if name not in mermaid:
            fail(f"lifecycle pipeline mermaid must include {name}")

    print(
        "docs browser invariants passed "
        f"({len(skill_names)} skills on disk; no hardcoded inventory in app.js)."
    )


if __name__ == "__main__":
    main()
