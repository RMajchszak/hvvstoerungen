---
description: Run headless epic execution
argument-hint: <epic-id> [-n max-iterations]
allowed-tools: Bash(.claude/scripts/ralph/epic.sh:*)
---

# Headless Epic Execution

Running headless ralph-loop for epic: **$ARGUMENTS**

Execute:
```bash
./.claude/scripts/ralph/epic.sh $ARGUMENTS
```

## What This Does

Unlike the interactive `/ralph/epic` command which runs in a single Claude Code context window, this headless version:

1. **Fresh context each iteration** - Each task gets a clean context window
2. **Runs in sandbox mode** - Safe, isolated execution
3. **Logs to activity.md** - Progress tracked across sessions
4. **Can run overnight** - No interaction needed

## Monitoring Progress

While the script runs:
- Watch `activity.md` for progress updates
- Check `bd list --parent <epic-id> --status open` for remaining tasks
- View git log for commits made

## Stopping

To stop the headless loop:
- `Ctrl+C` in the terminal running the script
- The current iteration will complete before stopping

## After Running

Check results:
- `bd list --parent <epic-id>` - See task statuses
- `git log --oneline -20` - See commits made
- `cat activity.md` - See detailed progress log
