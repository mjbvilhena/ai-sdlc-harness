#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export MOCK_HOME="$BATS_TMPDIR/mock_home"
    export MOCK_WORKSPACE="$BATS_TMPDIR/mock_workspace"

    mkdir -p "$MOCK_HOME"
    mkdir -p "$MOCK_WORKSPACE"

    # Override HOME for the installers
    export HOME="$MOCK_HOME"
}

teardown() {
    rm -rf "$MOCK_HOME"
    rm -rf "$MOCK_WORKSPACE"
}

# ---------------------------------------------------------------------------
# Dry-run: no files or MCP config written
# ---------------------------------------------------------------------------

@test "install_claude.sh dry-run does not create files" {
    run "$REPO_ROOT/install/install_claude.sh" --dry-run
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_HOME/.claude/commands" ]
    [[ "$output" == *"[dry-run]"* ]]
}

@test "install_agy.sh dry-run does not create files (global)" {
    run "$REPO_ROOT/install/install_agy.sh" --dry-run
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_HOME/.gemini" ]
    [[ "$output" == *"[dry-run]"* ]]
}

@test "install_agy.sh dry-run with --workspace does not create files" {
    run "$REPO_ROOT/install/install_agy.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_WORKSPACE/.agents" ]
    [[ "$output" == *"[dry-run]"* ]]
}

@test "install_ghcp.sh dry-run does not create files or MCP config" {
    run "$REPO_ROOT/install/install_ghcp.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_WORKSPACE/.github" ]
    [ ! -d "$MOCK_WORKSPACE/.vscode" ]
    [[ "$output" == *"[dry-run]"* ]]
}

@test "install_cursor.sh dry-run does not create files or MCP config" {
    run "$REPO_ROOT/install/install_cursor.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_WORKSPACE/.cursor" ]
    [[ "$output" == *"[dry-run]"* ]]
}

# ---------------------------------------------------------------------------
# Happy-path installs
# ---------------------------------------------------------------------------

@test "install_claude.sh global install works" {
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_HOME/.claude/commands" ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md" ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-a11y-auditor.md" ]
}

@test "install_claude.sh workspace install works" {
    run "$REPO_ROOT/install/install_claude.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.claude/commands" ]
    [ -f "$MOCK_WORKSPACE/.claude/commands/sdlc-code-reviewer.md" ]
    # Ensure it didn't install globally
    [ ! -d "$MOCK_HOME/.claude/commands" ]
}

@test "install_agy.sh global install uses HOME builtin skills path" {
    run "$REPO_ROOT/install/install_agy.sh"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-code-reviewer" ]
    [ -f "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-code-reviewer/SKILL.md" ]
    [ ! -d "$MOCK_WORKSPACE/.agents" ]
}

@test "install_agy.sh workspace install works" {
    run "$REPO_ROOT/install/install_agy.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer" ]
    [ -f "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer/SKILL.md" ]
    [ -f "$MOCK_WORKSPACE/.agents/mcp_config.json" ]
}

@test "install_ghcp.sh workspace install works" {
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.github/instructions" ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
    [ -f "$MOCK_WORKSPACE/.vscode/mcp.json" ]
    grep -q '"servers"' "$MOCK_WORKSPACE/.vscode/mcp.json"
    grep -q 'sdlc-knowledge' "$MOCK_WORKSPACE/.vscode/mcp.json"
}

@test "install_cursor.sh workspace install works" {
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.cursor/prompts" ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-code-reviewer.md" ]
    [ -f "$MOCK_WORKSPACE/.cursor/mcp.json" ]
}

# ---------------------------------------------------------------------------
# Default workspace (PWD) for workspace-scoped harnesses
# ---------------------------------------------------------------------------

@test "install_cursor.sh defaults to PWD when --workspace is omitted" {
    cd "$MOCK_WORKSPACE"
    run "$REPO_ROOT/install/install_cursor.sh"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-code-reviewer.md" ]
}

@test "install_ghcp.sh defaults to PWD when --workspace is omitted" {
    cd "$MOCK_WORKSPACE"
    run "$REPO_ROOT/install/install_ghcp.sh"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
}

# ---------------------------------------------------------------------------
# Idempotency
# ---------------------------------------------------------------------------

@test "install_agy.sh workspace install is idempotent" {
    run "$REPO_ROOT/install/install_agy.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_agy.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer/SKILL.md" ]
    expected="$(mktemp)"
    # shellcheck source=../../install/lib/expand_content.sh
    . "$REPO_ROOT/install/lib/expand_content.sh"
    expand_harness_file "$REPO_ROOT/skills/sdlc-code-reviewer" \
        "$REPO_ROOT/skills/sdlc-code-reviewer/agy/SKILL.md" \
        "$expected" "sdlc-code-reviewer"
    cmp -s "$expected" "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer/SKILL.md"
}

@test "install_ghcp.sh workspace install is idempotent" {
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
    expected="$(mktemp)"
    . "$REPO_ROOT/install/lib/expand_content.sh"
    expand_harness_file "$REPO_ROOT/skills/sdlc-code-reviewer" \
        "$REPO_ROOT/skills/sdlc-code-reviewer/ghcp/instructions.md" \
        "$expected" "sdlc-code-reviewer"
    cmp -s "$expected" "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md"
}

@test "install_cursor.sh workspace install is idempotent" {
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-code-reviewer.md" ]
    expected="$(mktemp)"
    . "$REPO_ROOT/install/lib/expand_content.sh"
    expand_harness_file "$REPO_ROOT/skills/sdlc-code-reviewer" \
        "$REPO_ROOT/skills/sdlc-code-reviewer/cursor/rule.md" \
        "$expected" "sdlc-code-reviewer"
    cmp -s "$expected" "$MOCK_WORKSPACE/.cursor/prompts/sdlc-code-reviewer.md"
}

@test "install_claude.sh global install is idempotent" {
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md" ]
    expected="$(mktemp)"
    . "$REPO_ROOT/install/lib/expand_content.sh"
    expand_harness_file "$REPO_ROOT/skills/sdlc-code-reviewer" \
        "$REPO_ROOT/skills/sdlc-code-reviewer/claude/command.md" \
        "$expected" "sdlc-code-reviewer"
    cmp -s "$expected" "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md"
}

# ---------------------------------------------------------------------------
# MCP config is created once and not overwritten
# ---------------------------------------------------------------------------

@test "install_cursor.sh does not overwrite an existing mcp.json" {
    mkdir -p "$MOCK_WORKSPACE/.cursor"
    printf '%s\n' '{"mcpServers":{"keep-me":{}}}' > "$MOCK_WORKSPACE/.cursor/mcp.json"
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    grep -q 'keep-me' "$MOCK_WORKSPACE/.cursor/mcp.json"
    [[ "$output" == *"already exists"* ]]
}

@test "install_ghcp.sh does not overwrite an existing .vscode/mcp.json" {
    mkdir -p "$MOCK_WORKSPACE/.vscode"
    printf '%s\n' '{"servers":{"keep-me":{}}}' > "$MOCK_WORKSPACE/.vscode/mcp.json"
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    grep -q 'keep-me' "$MOCK_WORKSPACE/.vscode/mcp.json"
    [[ "$output" == *"already exists"* ]]
}

# ---------------------------------------------------------------------------
# Flag / path error cases
# ---------------------------------------------------------------------------

@test "installers reject unknown flags" {
    run "$REPO_ROOT/install/install_agy.sh" --nope
    [ "$status" -eq 1 ]
    run "$REPO_ROOT/install/install_ghcp.sh" --nope
    [ "$status" -eq 1 ]
    run "$REPO_ROOT/install/install_cursor.sh" --nope
    [ "$status" -eq 1 ]
}

@test "installers reject --workspace without a path" {
    run "$REPO_ROOT/install/install_agy.sh" --workspace
    [ "$status" -eq 1 ]
    run "$REPO_ROOT/install/install_cursor.sh" --workspace
    [ "$status" -eq 1 ]
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace
    [ "$status" -eq 1 ]
}

@test "installers reject a missing --workspace path" {
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE/does-not-exist"
    [ "$status" -ne 0 ]
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE/does-not-exist"
    [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Missing agents/ is tolerated (directory is deferred)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# CONTENT.md expansion
# ---------------------------------------------------------------------------

@test "installed files are expanded from CONTENT.md and contain no placeholders" {
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    installed="$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md"
    grep -q 'get_sdlc_template' "$installed"
    grep -q 'code review' "$installed"
    ! grep -q '{{SKILL_BODY}}' "$installed"
    ! grep -q '{{RULE_BODY}}' "$installed"
}

@test "installed rules expand {{RULE_BODY}}" {
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    installed="$MOCK_HOME/.claude/commands/sdlc-dod-checker.md"
    grep -q 'get_definition_of_done' "$installed"
    ! grep -q '{{RULE_BODY}}' "$installed"
}

@test "expand_harness_file fails when CONTENT.md is missing" {
    . "$REPO_ROOT/install/lib/expand_content.sh"
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/skills/broken/agy"
    printf '%s\n' '{{SKILL_BODY}}' > "$tmp/skills/broken/agy/SKILL.md"
    run expand_harness_file "$tmp/skills/broken" "$tmp/skills/broken/agy/SKILL.md" "$tmp/out.md" "broken"
    [ "$status" -ne 0 ]
    [[ "$output" == *"CONTENT.md"* ]]
    [ ! -f "$tmp/out.md" ]
}

@test "expand_harness_file fails when the placeholder is missing" {
    . "$REPO_ROOT/install/lib/expand_content.sh"
    tmp="$(mktemp -d)"
    mkdir -p "$tmp/skills/broken/agy"
    printf '%s\n' '# No placeholder' > "$tmp/skills/broken/agy/SKILL.md"
    printf '%s\n' 'body' > "$tmp/skills/broken/CONTENT.md"
    run expand_harness_file "$tmp/skills/broken" "$tmp/skills/broken/agy/SKILL.md" "$tmp/out.md" "broken"
    [ "$status" -ne 0 ]
    [[ "$output" == *"{{SKILL_BODY}}"* ]]
    [ ! -f "$tmp/out.md" ]
}

@test "installers skip agents/ when the directory is absent" {
    run "$REPO_ROOT/install/install_claude.sh" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"No agents/ directory found"* ]]

    run "$REPO_ROOT/install/install_agy.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No agents/ directory found"* ]]
}

# ---------------------------------------------------------------------------
# sdlc- naming helpers
# ---------------------------------------------------------------------------

@test "sdlc_prefixed_name keeps or adds the sdlc- prefix" {
    # shellcheck source=../../install/lib/sdlc_names.sh
    . "$REPO_ROOT/install/lib/sdlc_names.sh"
    [ "$(sdlc_prefixed_name "sdlc-code-reviewer")" = "sdlc-code-reviewer" ]
    [ "$(sdlc_prefixed_name "code-reviewer")" = "sdlc-code-reviewer" ]
    [ "$(sdlc_prefixed_name "dod-checker")" = "sdlc-dod-checker" ]
}

@test "ensure_sdlc_frontmatter_name rewrites a bare YAML name" {
    # shellcheck source=../../install/lib/sdlc_names.sh
    . "$REPO_ROOT/install/lib/sdlc_names.sh"
    tmp="$(mktemp)"
    cat > "$tmp" <<'EOF'
---
name: code-reviewer
description: test
---

# Body
EOF
    ensure_sdlc_frontmatter_name "$tmp" "sdlc-code-reviewer"
    grep -q '^name: sdlc-code-reviewer$' "$tmp"
    ! grep -q '^name: code-reviewer$' "$tmp"
    grep -q '^# Body$' "$tmp"
}

@test "ensure_sdlc_frontmatter_name leaves files without frontmatter unchanged" {
    # shellcheck source=../../install/lib/sdlc_names.sh
    . "$REPO_ROOT/install/lib/sdlc_names.sh"
    tmp="$(mktemp)"
    printf '%s\n' '# No frontmatter' 'name: leftover' > "$tmp"
    ensure_sdlc_frontmatter_name "$tmp" "sdlc-code-reviewer"
    grep -q '^name: leftover$' "$tmp"
}

# ---------------------------------------------------------------------------
# Cleanup of previously installed sdlc-* artifacts
# ---------------------------------------------------------------------------

@test "install_claude.sh removes stale sdlc-* commands and keeps neighbors" {
    mkdir -p "$MOCK_HOME/.claude/commands"
    printf '%s\n' 'stale' > "$MOCK_HOME/.claude/commands/sdlc-stale-skill.md"
    printf '%s\n' 'keep' > "$MOCK_HOME/.claude/commands/my-custom-command.md"
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    [ ! -f "$MOCK_HOME/.claude/commands/sdlc-stale-skill.md" ]
    [ -f "$MOCK_HOME/.claude/commands/my-custom-command.md" ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md" ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-dod-checker.md" ]
}

@test "install_claude.sh dry-run reports cleanup without deleting" {
    mkdir -p "$MOCK_HOME/.claude/commands"
    printf '%s\n' 'stale' > "$MOCK_HOME/.claude/commands/sdlc-stale-skill.md"
    printf '%s\n' 'keep' > "$MOCK_HOME/.claude/commands/my-custom-command.md"
    run "$REPO_ROOT/install/install_claude.sh" --dry-run
    [ "$status" -eq 0 ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-stale-skill.md" ]
    [ -f "$MOCK_HOME/.claude/commands/my-custom-command.md" ]
    [[ "$output" == *"[dry-run] Would remove:"* ]]
    [[ "$output" == *"sdlc-stale-skill.md"* ]]
    [ ! -f "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md" ]
}

@test "install_cursor.sh removes stale sdlc-* rules and keeps neighbors" {
    mkdir -p "$MOCK_WORKSPACE/.cursor/prompts"
    printf '%s\n' 'stale' > "$MOCK_WORKSPACE/.cursor/prompts/sdlc-stale-skill.md"
    printf '%s\n' 'keep' > "$MOCK_WORKSPACE/.cursor/prompts/my-custom-rule.md"
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ ! -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-stale-skill.md" ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/my-custom-rule.md" ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-code-reviewer.md" ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-dod-checker.md" ]
}

@test "install_cursor.sh dry-run reports cleanup without deleting" {
    mkdir -p "$MOCK_WORKSPACE/.cursor/prompts"
    printf '%s\n' 'stale' > "$MOCK_WORKSPACE/.cursor/prompts/sdlc-stale-skill.md"
    printf '%s\n' 'keep' > "$MOCK_WORKSPACE/.cursor/prompts/my-custom-rule.md"
    run "$REPO_ROOT/install/install_cursor.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-stale-skill.md" ]
    [ -f "$MOCK_WORKSPACE/.cursor/prompts/my-custom-rule.md" ]
    [[ "$output" == *"[dry-run] Would remove:"* ]]
    [[ "$output" == *"sdlc-stale-skill.md"* ]]
    [ ! -f "$MOCK_WORKSPACE/.cursor/prompts/sdlc-code-reviewer.md" ]
}

@test "install_agy.sh removes stale sdlc-* skill dirs and keeps neighbors" {
    mkdir -p "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-stale-skill"
    printf '%s\n' 'stale' > "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-stale-skill/SKILL.md"
    mkdir -p "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/my-custom-skill"
    printf '%s\n' 'keep' > "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/my-custom-skill/SKILL.md"
    run "$REPO_ROOT/install/install_agy.sh"
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-stale-skill" ]
    [ -f "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/my-custom-skill/SKILL.md" ]
    [ -f "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-code-reviewer/SKILL.md" ]
    [ -d "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-dod-checker" ]
}

@test "install_agy.sh dry-run reports cleanup without deleting" {
    mkdir -p "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-stale-skill"
    printf '%s\n' 'stale' > "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-stale-skill/SKILL.md"
    mkdir -p "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/my-custom-skill"
    printf '%s\n' 'keep' > "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/my-custom-skill/SKILL.md"
    run "$REPO_ROOT/install/install_agy.sh" --dry-run
    [ "$status" -eq 0 ]
    [ -f "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-stale-skill/SKILL.md" ]
    [ -f "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/my-custom-skill/SKILL.md" ]
    [[ "$output" == *"[dry-run] Would remove:"* ]]
    [[ "$output" == *"sdlc-stale-skill"* ]]
    [ ! -d "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-code-reviewer" ]
}

@test "install_agy.sh writes sdlc- prefixed frontmatter names" {
    run "$REPO_ROOT/install/install_agy.sh"
    [ "$status" -eq 0 ]
    grep -q '^name: sdlc-code-reviewer$' \
        "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-code-reviewer/SKILL.md"
    grep -q '^name: sdlc-dod-checker$' \
        "$MOCK_HOME/.gemini/antigravity-cli/builtin/skills/sdlc-dod-checker/RULE.md"
}

@test "install_ghcp.sh removes stale sdlc-* instructions and keeps neighbors" {
    mkdir -p "$MOCK_WORKSPACE/.github/instructions"
    printf '%s\n' 'stale' > "$MOCK_WORKSPACE/.github/instructions/sdlc-stale-skill.instructions.md"
    printf '%s\n' 'keep' > "$MOCK_WORKSPACE/.github/instructions/my-custom.instructions.md"
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ ! -f "$MOCK_WORKSPACE/.github/instructions/sdlc-stale-skill.instructions.md" ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/my-custom.instructions.md" ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-dod-checker.instructions.md" ]
}

@test "install_ghcp.sh dry-run reports cleanup without deleting" {
    mkdir -p "$MOCK_WORKSPACE/.github/instructions"
    printf '%s\n' 'stale' > "$MOCK_WORKSPACE/.github/instructions/sdlc-stale-skill.instructions.md"
    printf '%s\n' 'keep' > "$MOCK_WORKSPACE/.github/instructions/my-custom.instructions.md"
    run "$REPO_ROOT/install/install_ghcp.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-stale-skill.instructions.md" ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/my-custom.instructions.md" ]
    [[ "$output" == *"[dry-run] Would remove:"* ]]
    [[ "$output" == *"sdlc-stale-skill.instructions.md"* ]]
    [ ! -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
}
