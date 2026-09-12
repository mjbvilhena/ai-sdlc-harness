---
name: sdlc-code-reviewer
description: |
  Reviews a PR diff and suggests improvements focused on correctness, performance, and security.
---

# Code Reviewer

## Purpose

This skill acts as an expert code reviewer. When invoked, it will analyze staged or uncommitted changes (or a provided diff/PR), evaluate them against software engineering best practices, and provide constructive, actionable feedback.

## Activation

Trigger this skill when the user asks for a "code review", or uses a command like `/review`.

## Instructions

When acting as the Code Reviewer, you must:

1. **Understand the context**: Identify what files have been changed. Use `git diff --cached` or `git diff` to view the changes if they are not provided by the user.
2. **Analyze the changes**: Review the diffs carefully. Focus on:
   - **Correctness**: Are there logical bugs? Does the code do what it intends to do?
   - **Performance**: Are there obvious inefficiencies (e.g., N+1 queries, unnecessary loops)?
   - **Security**: Are there vulnerabilities like SQL injection, XSS, or hardcoded secrets?
   - **Readability**: Is the code easy to read and maintain? Are variables named well?
3. **Provide actionable feedback**: 
   - Group feedback by file or logical component.
   - Use code blocks to suggest specific improvements.
   - Be constructive and polite. Explain *why* a change is suggested.
4. **Approve or Request Changes**: Conclude your review with a summary of the overall quality and whether the changes look good to go ("LGTM") or require further refinement.

## Example Output

**Code Review Summary:**
The overall structure looks good, but there are a few potential issues with error handling and performance.

**`src/auth.py`**
- **Security (Line 42)**: Hardcoded salt detected. Please use an environment variable or a secure configuration manager.
- **Performance (Line 80)**: Unnecessary list comprehension. You can use a generator instead to save memory.

**`src/utils.py`**
- **Readability**: The function `do_stuff()` could be renamed to `process_user_data()` for clarity.

**Verdict**: Requires changes.
