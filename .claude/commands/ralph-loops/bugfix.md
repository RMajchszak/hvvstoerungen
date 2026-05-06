---
description: Run headless bug fix sprint
argument-hint: [epic-id] [-n max-iterations]
allowed-tools: Bash(.claude/scripts/ralph/bugfix.sh:*)
---

# Headless Bug Fix Sprint

Running headless ralph-loop for bug fixing: **$ARGUMENTS**

Execute:
```bash
./.claude/scripts/ralph/bugfix.sh $ARGUMENTS
```

## What This Does

Systematically fixes bugs in priority order with headless execution:

1. **Priority-based** - Fixes P0 (critical) bugs first, then P1, P2, P3
2. **Regression tests** - Each fix includes a regression test
3. **Fresh context** - Each bug gets a clean context window
4. **Progress tracking** - Logged to activity.md

## Arguments

- No args: Fix all open bugs in the project
- `<epic-id>`: Fix only bugs under a specific epic
- `-n <N>`: Maximum iterations (default: 30)

## Examples

```bash
# Fix all open bugs
./.claude/scripts/ralph/bugfix.sh

# Fix bugs under a specific epic
./.claude/scripts/ralph/bugfix.sh bd-abc123

# Fix all bugs, max 20 iterations
./.claude/scripts/ralph/bugfix.sh -n 20
```

## Monitoring

- `bd list --type bug --status open` - See remaining bugs
- `activity.md` - See fix progress and details
- `git log --oneline` - See fix commits

## Exit Codes

- `0`: All bugs cleared
- `1`: Max iterations reached
- `2`: Blocked (needs human decision)
- `3`: Stuck (bug can't be fixed automatically)
