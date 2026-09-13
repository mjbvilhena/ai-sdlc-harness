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
    [ -d "$MOCK_WORKSPACE/.cursor/rules" ]
    [ -f "$MOCK_WORKSPACE/.cursor/rules/sdlc-code-reviewer.mdc" ]
    [ -f "$MOCK_WORKSPACE/.cursor/mcp.json" ]
}

# ---------------------------------------------------------------------------
# Default workspace (PWD) for workspace-scoped harnesses
# ---------------------------------------------------------------------------

@test "install_cursor.sh defaults to PWD when --workspace is omitted" {
    cd "$MOCK_WORKSPACE"
    run "$REPO_ROOT/install/install_cursor.sh"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.cursor/rules/sdlc-code-reviewer.mdc" ]
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
    cmp -s "$REPO_ROOT/skills/sdlc-code-reviewer/agy/SKILL.md" \
           "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer/SKILL.md"
}

@test "install_ghcp.sh workspace install is idempotent" {
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_ghcp.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
    cmp -s "$REPO_ROOT/skills/sdlc-code-reviewer/ghcp/instructions.md" \
           "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md"
}

@test "install_cursor.sh workspace install is idempotent" {
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_cursor.sh" --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_WORKSPACE/.cursor/rules/sdlc-code-reviewer.mdc" ]
    cmp -s "$REPO_ROOT/skills/sdlc-code-reviewer/cursor/rule.mdc" \
           "$MOCK_WORKSPACE/.cursor/rules/sdlc-code-reviewer.mdc"
}

@test "install_claude.sh global install is idempotent" {
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    run "$REPO_ROOT/install/install_claude.sh"
    [ "$status" -eq 0 ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md" ]
    cmp -s "$REPO_ROOT/skills/sdlc-code-reviewer/claude/command.md" \
           "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md"
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

@test "installers skip agents/ when the directory is absent" {
    run "$REPO_ROOT/install/install_claude.sh" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"No agents/ directory found"* ]]

    run "$REPO_ROOT/install/install_agy.sh" --dry-run --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No agents/ directory found"* ]]
}
