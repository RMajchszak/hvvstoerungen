---
description: Claim a specific Beads task for work
argument-hint: <task-id>
allowed-tools: Bash
---

# Claim Task

Claim a specific Beads task: **$1**

## Task Details

!bd show $1 2>/dev/null || echo "Task not found"

## Claim Workflow

### 1. Verify Task Exists
```bash
bd show $1
```

### 2. Check Task Status
Task must be `open` or `ready` to claim.

### 3. Check for Blockers
```bash
bd show $1 --json | jq '.blocked_by'
```
If blocked, cannot claim.

### 4. Claim the Task
```bash
bd update $1 --status in_progress
```

## Output

```
## Task Claimed

### Task
**ID:** $1
**Title:** [from bd show]
**Type:** [from bd show]
**Priority:** [from bd show]

### Status
Changed: open → in_progress

### Description
[Task description]

### Ready to Work
Start implementing. When done, run `/done` or `/done $1`.
```

## If Task Cannot Be Claimed

```
## Cannot Claim Task

### Reason
- [ ] Task not found
- [ ] Task already in_progress
- [ ] Task is blocked by: [blockers]
- [ ] Task is closed

### Suggestions
1. Run `/next` to find a claimable task
2. Check blockers: `bd show $1`
3. Resolve blockers first
```

## Begin

Show task details and claim if possible.
