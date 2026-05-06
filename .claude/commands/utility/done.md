---
description: Complete current work, close Beads task, and commit
argument-hint: [task-id] [commit message]
allowed-tools: Read, Grep, Glob, Bash
---

# Done (Complete Current Work)

Finalize current work with quality checks, close Beads task, and commit.

This command follows the GEV pattern for work completion.

## Current State

### Beads - In Progress Tasks
!bd list --status in_progress 2>/dev/null || echo "No in-progress tasks"

### Git Status
!git status --short

### Changed Files
!git diff --stat HEAD

### Current Branch
!git branch --show-current

## Gate Phase

### Pre-completion Checks

Before marking work as done:

1. **Beads Task Claimed**
   - Must have an in_progress task (or provide task-id)

2. **No Syntax Errors**
   - Code must compile/parse without errors

3. **Tests Pass**
   - All existing tests should pass
   - New tests for new code (if applicable)

4. **Lint Clean** (if linter available)
   - No errors
   - Warnings acceptable but noted

## Execute Phase

### Step 1: Identify Beads Task

If `$1` provided, use as task ID.
Otherwise, get the in_progress task:
```bash
TASK_ID=$(bd list --status in_progress --json 2>/dev/null | jq -r '.[0].id')
```

Show task details:
```bash
bd show $TASK_ID
```

### Step 2: Run Quality Checks

```bash
# Run tests
npm test || pytest || cargo test || go test ./... || echo "No test command"

# Run linter
npm run lint || ruff check . || cargo clippy || golangci-lint run || echo "No lint command"
```

### Step 3: Stage and Commit

```bash
# Stage changes
git add -A

# Commit with task reference
git commit -m "<type>($TASK_ID): <description>"
```

Commit types: feat, fix, refactor, docs, test, chore, perf

### Step 4: Close Beads Task

```bash
bd close $TASK_ID --reason "<summary of what was accomplished>"
```

### Step 5: Sync Beads

```bash
bd sync
```

## Verify Phase

### Post-completion Verification

```bash
# Verify commit was created
git log -1 --oneline

# Verify task is closed
bd show $TASK_ID

# Verify working directory is clean
git status --short
```

## Output Format

```
## Work Completed

### Beads Task
!bd show $TASK_ID

### Quality Gates
| Gate | Status | Details |
|------|--------|---------|
| Tests | PASS/FAIL | [summary] |
| Lint | PASS/FAIL | [summary] |

### Commit
!git log -1 --stat

### Task Closed
- ID: $TASK_ID
- Reason: [completion summary]

### Beads Synced
!bd sync

### Next Steps
- [ ] Push changes: `git push`
- [ ] Check next task: `/next`
```

## Error Handling

### If No In-Progress Task
```
## ERROR: No Task Claimed

No in_progress task found. Either:
1. Provide task ID: `/done <task-id>`
2. Claim a task first: `/next`
```

### If Tests Fail
Do not commit or close task. Report failures:
```bash
bd update $TASK_ID --notes "Tests failing: <summary>"
```

### If Nothing to Commit
Close the task anyway if work is complete:
```bash
bd close $TASK_ID --reason "Completed without code changes"
```

## Begin

Start by identifying the in-progress Beads task, then run quality gates.
