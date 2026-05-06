---
description: Find and start working on the next available task
allowed-tools: Bash(bd:*), Bash(git:*), Read
---

## Available Work
!`bd ready --json 2>/dev/null || echo "beads not initialized"`

## Task

Find the next task to work on:

1. Check `bd ready` for unblocked tasks (P0 tasks first)
2. If no ready tasks, check `bd list --status=open` and explain blockers
3. For the highest priority ready task:
   - Show issue details with `bd show <id>`
   - Claim it: `bd update <id> --status in_progress`
   - Summarize what needs to be done
4. If beads not initialized, suggest running `bd init`

Present the task clearly with:
- Issue ID and title
- Priority and type
- Description
- Any dependencies or context
- Suggested first steps based on streb architecture
