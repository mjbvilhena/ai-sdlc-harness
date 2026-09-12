# Installation and Usage Guide

This guide explains how to deploy the AI SDLC Harness to a real repository and begin using it with your AI IDE of choice.

## Step 1: Install Skills & Configure MCP

To deploy the harness into a target repository, run the installer script corresponding to your AI tool. You MUST provide the `--workspace` flag pointing to your project's root directory. 

For example, to configure a project for both Antigravity and Claude Code:

```bash
./install/install_agy.sh --workspace /path/to/your/real-project
./install/install_claude.sh --workspace /path/to/your/real-project
```

### What these installers do automatically:
1. **Inject Skills**: They copy all the prompts and skills from this library directly into the hidden directories of your workspace (e.g., `.agents/skills/` and `.claude/commands/`).
2. **Attach MCP Server**: They automatically generate the `mcp_config.json` or `claude.json` configuration files in your workspace, securely wiring your AI IDE to the Python MCP Knowledge Server hosted in this repository. You do not need to configure anything manually!

## Step 2: Define Your Project Constraints

The AI SDLC Harness uses a "Tri-Dimensional Framework" powered by Dynamic Consultants. This means the AI will dynamically enforce *your* project's rules without you having to copy-paste them into every prompt.

In your real project workspace, create markdown files detailing your architecture:
- **Domains**: `src/domains/auth/DOMAIN.md` (e.g., "All authentication must use the AuthService singleton.")
- **Layers**: `src/ui/LAYER.md` (e.g., "All UI components must be purely functional React components.")

## Step 3: Trigger the AI

Open your real project using your chosen AI IDE (e.g., Antigravity, Cursor, or Claude Code). The IDE will automatically detect the skills and the MCP server you injected in Step 1.

Simply invoke a command in the AI chat:

> `Please run the /review skill on my current branch.`

**The AI will:**
1. Recognize the `/review` command.
2. Read the review instructions.
3. Automatically pause to query the MCP server.
4. Fetch your custom `DOMAIN.md` and `LAYER.md` rules.
5. Review your code strictly against your custom architectural constraints!
