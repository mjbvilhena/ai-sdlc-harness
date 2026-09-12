# Test Writer (GitHub Copilot)

When the user asks you to "write tests", "generate tests", or uses the `/test` convention:

1. Analyze the context to find the code to be tested.
2. Generate a suite of unit tests tailored to the project's language and testing framework.
3. Ensure the test suite includes:
   - Happy paths.
   - Edge cases and bounds.
   - Error handling validation.
   - Setup/Teardown or Mocking where appropriate.
4. Output clean, runnable test code with descriptive test names.
