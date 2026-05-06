# Ralph Wiggum Pattern (Autonomous Loop)

This pattern enables long-running autonomous execution with:
- Iterative progress toward a goal
- Self-correction on failures
- Checkpoint-based recovery
- Intelligent termination

## Pattern Structure

```
INITIALIZE
├── Load context and state
├── Define success criteria
└── Set iteration limits
         │
         ▼
ITERATION START ◄────────────────┐
├── Assess current state          │
├── Plan next action              │
└── Save checkpoint               │
         │                        │
         ▼                        │
EXECUTE                           │
├── Invoke mid/micro commands     │
├── Invoke subagents as needed    │
└── Capture results               │
         │                        │
         ▼                        │
EVALUATE                          │
├── Check success criteria        │
├── Analyze failures              │
└── Update progress metrics       │
         │                        │
    ┌────┴────┐                   │
    ▼         ▼                   │
SUCCESS    CONTINUE ──────────────┘
    │
    ▼
FINALIZE
├── Generate summary
└── Cleanup state
```

## Exit Conditions

Commands using this pattern MUST implement these exits:

### COMPLETE
All success criteria met. Output:
```
## COMPLETE
### Summary
[What was accomplished]
### Changes Made
[List of changes]
### Verification
[How success was confirmed]
```

### BLOCKED
Cannot proceed without external input. Output:
```
## BLOCKED
### Blocker
[Specific impediment]
### Attempted Solutions
[What was tried]
### Required to Unblock
[What is needed]
```

### STUCK
No progress after threshold iterations. Output:
```
## STUCK
### Stuck Pattern
[Description of repeated failure]
### Iteration History
[Recent attempts]
### Alternatives Not Tried
[Other approaches]
```

## Stuck Detection Rules

Increment stuck counter when:
- Same error occurs twice consecutively
- Same file edited 3+ times without progress
- Search yields no new results
- Test fails with identical error

Reset stuck counter when:
- New file discovered/created
- Test status changes
- Different error encountered

**Threshold: 3 iterations** → Exit with STUCK

## Usage

Reference in commands:
```markdown
This command follows the Ralph Wiggum pattern.
See: @.claude/patterns/ralph-wiggum.md
```
