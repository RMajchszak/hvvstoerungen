# Git Safety Rules

## Commit Protocol

- NEVER update git config without explicit user permission
- NEVER run destructive commands (`push --force`, `reset --hard`) unless explicitly requested
- NEVER skip hooks (`--no-verify`, `--no-gpg-sign`) unless explicitly requested
- NEVER force push to main/master branches

## Amend Rules

Only use `git commit --amend` when ALL conditions are met:
1. User explicitly requested amend, OR commit succeeded but pre-commit hook auto-modified files
2. HEAD commit was created by you in this conversation
3. Commit has NOT been pushed to remote

If commit FAILED or was REJECTED by hook, NEVER amend - fix the issue and create a NEW commit.

## Commit Message Format

Use conventional commits with beads issue references:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `build`, `ci`

Examples:
- `feat(bd-a1b2): add user authentication`
- `fix(bd-c3d4): resolve nil pointer in darwin installer`
- `refactor: extract validation logic to separate module`

## Branch Workflow

- Create feature branches for non-trivial changes
- Keep main/master clean and deployable
- Sync with remote before pushing
- Resolve conflicts carefully, never blindly accept changes
