---
description: Run headless codebase migration
argument-hint: "<description>" [file-pattern] [-n max-iterations]
allowed-tools: Bash(.claude/scripts/ralph/migrate.sh:*)
---

# Headless Migration

Running headless ralph-loop for migration: **$ARGUMENTS**

Execute:
```bash
./.claude/scripts/ralph/migrate.sh $ARGUMENTS
```

## What This Does

Systematically migrates/refactors codebase patterns:

1. **Creates Beads tasks** - One task per file needing migration
2. **One file per iteration** - Atomic, safe changes
3. **Tests required** - All tests must pass before committing
4. **Tracks progress** - via Beads and activity.md

## Arguments

- `"<description>"`: Description of the migration (required)
- `[file-pattern]`: Optional glob pattern for files (e.g., `"src/**/*.ts"`)
- `-n <N>`: Maximum iterations (default: 60)

## Examples

```bash
# Migrate all applicable files
./.claude/scripts/ralph/migrate.sh "Convert callbacks to async/await"

# Migrate specific file pattern
./.claude/scripts/ralph/migrate.sh "Migrate to React hooks" "src/components/**/*.tsx"

# With iteration limit
./.claude/scripts/ralph/migrate.sh "Update API v1 to v2" "src/api/**/*.ts" -n 100
```

## Workflow

1. First iteration creates a Beads epic and tasks for each file
2. Subsequent iterations:
   - Claim a task
   - Migrate the file
   - Run tests
   - Commit and close task
3. Completes when all migration tasks are closed

## Monitoring

- `bd list --type epic` - Find the migration epic
- `bd list --parent <epic-id>` - See migration task progress
- `activity.md` - Detailed migration log

## Exit Codes

- `0`: Migration complete
- `1`: Max iterations reached
- `2`: Blocked (breaking changes need review)
- `3`: Stuck (file can't be migrated)
