---
description: Create a well-formatted commit
argument-hint: [commit message]
allowed-tools: Bash
---

# Commit Changes

Create a commit with conventional commit format.

## Current Changes
!git status --short
!git diff --stat HEAD

## Commit Message

If message provided: $ARGUMENTS

Otherwise, generate based on changes:
- feat: new feature
- fix: bug fix
- refactor: code change without behavior change
- docs: documentation
- test: test changes
- chore: maintenance

## Format
```
<type>(<scope>): <short description>

[optional body with details]
```

## Execute

```bash
# Stage all changes
git add -A

# Create commit
git commit -m "<message>"
```

## Output

Show the created commit:
```bash
git log -1 --stat
```
