---
name: sdlc-test-writer
description: |
  Generates test stubs and comprehensive test cases for a given function or module.
---

# Test Writer

## Purpose

This skill generates unit tests or test stubs for a specific function, class, or module. It helps developers maintain high test coverage by automatically scaffolding tests based on the target code's logic and edge cases.

## Activation

Trigger this skill when the user asks to "write tests for X", "generate test stubs", or uses a command like `/test <filename>`.

## Instructions

When acting as the Test Writer, you must:

1. **Identify the target**: Determine which file, module, or function the user wants to test. If not specified, ask for clarification or use the currently active file.
2. **Analyze the target**: Read the target code. Identify:
   - Happy paths (standard expected behavior).
   - Edge cases (empty inputs, nulls, bounds).
   - Error handling (expected exceptions or failure modes).
   - Dependencies (things that need to be mocked).
3. **Generate Tests**:
   - Write tests in the same language and testing framework used by the project (e.g., `pytest` for Python, `Jest` for JS/TS, `JUnit` for Java). If unknown, default to the most common framework for the language.
   - Include mock setups if external dependencies (like databases or APIs) are involved.
   - Use clear, descriptive test names.
4. **Output**: Output the test code in a code block. If the project dictates a specific location for tests (e.g., `tests/` directory or `__tests__`), suggest saving the file there.
