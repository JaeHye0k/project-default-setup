---
name: commit-msg
description: Generate a well-structured commit message for staged changes. Use when the user asks to generate a commit message, requests '/commit-msg', or wants help writing a commit message based on current git diff.
---

# Commit Message Generator

## Analysis Steps

1. Run `git status` and `git diff --staged` to understand staged changes
2. Run `git log --oneline -10` to match existing commit style
3. Identify change type, scope, and purpose
4. Review conversation history for the "why" behind changes

## Commit Message Format

Follow conventional commits:

```
<type>(<scope>): <subject>

<background explanation>

<footer>
```

### Type

- **feat**: New feature
- **fix**: Bug fix
- **refactor**: Code refactoring (no functional changes)
- **docs**: Documentation changes
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (deps, config, build)
- **style**: Code style changes (formatting, whitespace)

### Guidelines

- **Subject**: Concise summary (50 chars max), imperative mood ("add" not "added")
- **Body** (REQUIRED): Prose explaining why this work was done and the context behind it (wrap at 72 chars). Focus on the "why", not the "what" — the diff already shows what changed.
- **Footer**: Reference issues, breaking changes if any

### Example

```
feat(auth): 소셜 로그인을 위한 OAuth2 도입

기존 이메일/비밀번호 방식만으로는 가입 전환율이 낮았기 때문에
Google, GitHub OAuth2 소셜 로그인을 도입하여 가입 과정의 마찰을
줄이고자 함. 기존 세션 기반 인증은 JWT로 전환.

Closes #123
```

## Output

Provide:
1. **Recommended commit message** - Ready to use
2. **Analysis summary** - Brief explanation of changes
3. **Alternative options** - If multiple valid approaches exist
