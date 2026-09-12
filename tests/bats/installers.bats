#!/usr/bin/env bats

setup() {
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

@test "install_claude.sh dry-run does not create files" {
    run ./install/install_claude.sh --dry-run
    [ "$status" -eq 0 ]
    [ ! -d "$MOCK_HOME/.claude/commands" ]
}

@test "install_claude.sh global install works" {
    run ./install/install_claude.sh
    [ "$status" -eq 0 ]
    [ -d "$MOCK_HOME/.claude/commands" ]
    [ -f "$MOCK_HOME/.claude/commands/sdlc-code-reviewer.md" ]
}

@test "install_claude.sh workspace install works" {
    run ./install/install_claude.sh --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.claude/commands" ]
    [ -f "$MOCK_WORKSPACE/.claude/commands/sdlc-code-reviewer.md" ]
    # Ensure it didn't install globally
    [ ! -d "$MOCK_HOME/.claude/commands" ]
}

@test "install_agy.sh workspace install works" {
    run ./install/install_agy.sh --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer" ]
    [ -f "$MOCK_WORKSPACE/.agents/skills/sdlc-code-reviewer/SKILL.md" ]
}

@test "install_ghcp.sh workspace install works" {
    run ./install/install_ghcp.sh --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.github/instructions" ]
    [ -f "$MOCK_WORKSPACE/.github/instructions/sdlc-code-reviewer.instructions.md" ]
}

@test "install_cursor.sh workspace install works" {
    run ./install/install_cursor.sh --workspace "$MOCK_WORKSPACE"
    [ "$status" -eq 0 ]
    [ -d "$MOCK_WORKSPACE/.cursor/rules" ]
    [ -f "$MOCK_WORKSPACE/.cursor/rules/sdlc-code-reviewer.mdc" ]
}
