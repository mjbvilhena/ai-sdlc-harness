# Test Writer (Claude Code)

## Trigger
`/test`

## Instructions
Your goal is to write comprehensive tests for a given piece of code.

1. **Understand the target**: Identify the function, class, or file the user wants to test.
2. **Determine the framework**: Use the testing framework currently used in the project (e.g., Jest, Pytest, Go testing).
3. **Scaffold Tests**: Generate tests covering:
   - Happy paths.
   - Edge cases (null, empty, boundary values).
   - Expected errors/exceptions.
4. **Mocking**: Provide necessary mocks for external dependencies or I/O.
5. **Output**: Present the completed test file in a markdown code block, and specify the suggested filename/path for the tests.
