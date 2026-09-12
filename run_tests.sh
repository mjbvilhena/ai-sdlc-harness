#!/usr/bin/env bash
set -e

echo "======================================"
echo " Running AI SDLC Harness Test Suites"
echo "======================================"
echo ""

# 1. Metadata Validation
echo "--- 1. Metadata Validation ---"
if command -v python3 >/dev/null 2>&1; then
    python3 .github/scripts/validate_metadata.py
else
    echo "Error: python3 is not installed. Skipping metadata validation."
fi
echo ""

# 2. MCP Server Tests (pytest)
echo "--- 2. MCP Server Tests ---"
if command -v python3 >/dev/null 2>&1; then
    echo "Checking dependencies for MCP server tests..."
    cd mcp-server
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -r requirements.txt -q
    echo "Running pytest..."
    PYTHONPATH=. python3 -m pytest tests/
    deactivate
    cd ..
else
    echo "Error: python3 is not installed. Skipping MCP server tests."
fi
echo ""

# 3. BATS Installer Tests
echo "--- 3. Installer Tests (BATS) ---"
if command -v bats >/dev/null 2>&1; then
    bats tests/bats/installers.bats
else
    # Check if it was installed locally (e.g., in ~/.local/bin)
    if [ -x "$HOME/.local/bin/bats" ]; then
        "$HOME/.local/bin/bats" tests/bats/installers.bats
    else
        echo "Error: 'bats' command not found."
        echo "Please install BATS (Bash Automated Testing System) to run these tests."
        echo "See: https://bats-core.readthedocs.io/en/stable/installation.html"
    fi
fi
echo ""

# 4. E2E Agent Behavior Tests
echo "--- 4. E2E Agent Behavior Tests ---"
if [ -n "$GEMINI_API_KEY" ] || [ -n "$gemini_api_key" ]; then
    echo "API key detected. Running E2E Agent tests..."
    cd mcp-server
    source venv/bin/activate
    PYTHONPATH=. python3 -m pytest ../tests/e2e/
    deactivate
    cd ..
else
    echo "Notice: GEMINI_API_KEY is not set. Skipping E2E Agent tests."
    echo "To run these tests, export GEMINI_API_KEY and run this script again."
fi
echo ""

echo "======================================"
echo " All tests completed successfully! 🎉"
echo "======================================"
