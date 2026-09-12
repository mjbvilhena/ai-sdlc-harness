import subprocess
import pytest
import os
import shutil

@pytest.fixture
def check_cli_availability():
    """Check if agy or claude CLI is available, skip if not."""
    agy_path = shutil.which("agy")
    claude_path = shutil.which("claude")
    if not agy_path and not claude_path:
        pytest.skip("Neither 'agy' nor 'claude' CLI is installed.")
    return {"agy": agy_path, "claude": claude_path}

def test_agy_cli_headless(check_cli_availability):
    agy_path = check_cli_availability["agy"]
    if not agy_path:
        pytest.skip("agy CLI not installed.")
        
    # We use -p (print) mode to run non-interactively
    print(f"Running headless agy test via {agy_path}")
    try:
        # We run a very simple prompt to ensure the CLI boots and hits the model
        result = subprocess.run(
            [agy_path, "-p", "/sdlc-example-skill"],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        output = result.stdout + result.stderr
        if "Out of credits" in output or "billing" in output.lower():
            pytest.skip("Skipped due to LLM billing/credits exhaustion.")
            
        assert result.returncode == 0, f"agy failed with output: {output}"
        assert len(output.strip()) > 0, "Expected some output from agy"
        
    except subprocess.TimeoutExpired:
        pytest.skip("agy -p timed out. This can happen if authentication is required interactively.")
    except Exception as e:
        pytest.fail(f"Unexpected error running agy: {e}")
