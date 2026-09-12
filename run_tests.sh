#!/usr/bin/env bash
set -e

echo "======================================"
echo " Running AI SDLC Harness Test Suites"
echo "======================================"
echo ""

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is not installed. Skipping all Python tests."
else
    echo "Setting up isolated virtual environment for Python tests..."
    cd mcp-server
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -r requirements.txt -q
    pip install pyyaml -q
    cd ..

    # 1. Metadata Validation
    echo "--- 1. Metadata Validation ---"
    python3 .github/scripts/validate_metadata.py
    echo ""

    # 2. MCP Server Tests (pytest)
    echo "--- 2. MCP Server Tests ---"
    cd mcp-server
    echo "Running pytest..."
    PYTHONPATH=. python3 -m pytest tests/
    cd ..
    echo ""

    # 3. E2E Agent Behavior Tests
    echo "--- 3. E2E Agent Behavior Tests ---"
    if [ -n "$GEMINI_API_KEY" ] || [ -n "$gemini_api_key" ]; then
        echo "API key detected. Running E2E Agent tests..."
        cd mcp-server
        PYTHONPATH=. python3 -m pytest ../tests/e2e/
        cd ..
    else
        echo "Notice: GEMINI_API_KEY is not set. Skipping E2E Agent tests."
        echo "To run these tests, export GEMINI_API_KEY and run this script again."
    fi
    echo ""
    
    # Cleanup venv context
    deactivate
fi

# 4. BATS Installer Tests
echo "--- 4. Installer Tests (BATS) ---"
if command -v bats >/dev/null 2>&1; then
    bats tests/bats/installers.bats
else
    if [ -x "$HOME/.local/bin/bats" ]; then
        "$HOME/.local/bin/bats" tests/bats/installers.bats
    else
        echo "Error: 'bats' command not found."
        echo "Please install BATS (Bash Automated Testing System) to run these tests."
        echo "See: https://bats-core.readthedocs.io/en/stable/installation.html"
    fi
fi
echo ""

echo "======================================"
echo " All tests completed successfully! 🎉"
echo "======================================"
