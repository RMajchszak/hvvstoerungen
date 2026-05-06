# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
```

## Workflow

1. Check `bd ready` for unblocked tasks before starting new work
2. Claim work with `bd update <id> --status in_progress`
3. Make atomic commits linking to issue: `feat(<id>): description`
4. Run tests and linting before committing
5. Close completed work: `bd close <id> --reason "summary"`

## Code Quality

- Write tests for new functionality
- Follow existing patterns in the codebase
- Keep changes focused and atomic
- Avoid introducing security vulnerabilities (OWASP Top 10)

## Git Discipline

- Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Never force push to main/master
- Never commit secrets or credentials
- Run quality checks before committing

## Session Close Protocol

Before ending a session:
1. Run tests and linting
2. Update issue status in beads
3. Commit and push changes
4. Provide handoff context for next session

@.claude/rules/git-safety.md
@.claude/rules/security.md
