## Guidelines

When generating or proposing a commit message, you must follow the Conventional Commits specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools and libraries

### Rules
1. The description must be in the imperative, present tense (e.g., "add feature" not "added feature").
2. Do not capitalize the first letter of the description.
3. Do not place a period `.` at the end of the description.
4. If there are multiple logical changes, use the body to explain them, or suggest splitting them into multiple commits.
