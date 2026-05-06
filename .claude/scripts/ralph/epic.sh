#!/bin/bash
# .claude/scripts/ralph/epic.sh
# Headless Ralph Wiggum loop for executing Beads epics
#
# Usage: ./.claude/scripts/ralph/epic.sh <epic-id> [-n max-iterations]
# Example: ./.claude/scripts/ralph/epic.sh bd-abc123 -n 50

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <epic-id> [options]

Execute all tasks under a Beads epic autonomously in headless mode.

Arguments:
    epic-id             The Beads epic ID to execute (e.g., bd-abc123)

Options:
    -n, --max-iterations    Maximum iterations (default: 50)
    -h, --help              Show this help message

Examples:
    $(basename "$0") bd-abc123
    $(basename "$0") bd-abc123 -n 100
    $(basename "$0") bd-abc123 --max-iterations 30

Notes:
    - Runs in Claude Code sandbox mode for safety
    - Creates fresh context window each iteration
    - Progress logged to activity.md
    - Exit codes: 0=success, 1=max iterations, 2=blocked, 3=stuck
EOF
}

# Parse arguments
parse_args "$@"

EPIC_ID="${TARGET_ID:-}"

if [ -z "$EPIC_ID" ]; then
    log_error "Epic ID is required"
    show_help
    exit 1
fi

# Verify epic exists
if ! bd show "$EPIC_ID" &> /dev/null; then
    log_error "Epic '$EPIC_ID' not found in Beads"
    exit 1
fi

log_info "Executing epic: $EPIC_ID"

# Build the prompt
PROMPT="Execute Beads epic $EPIC_ID:

## Context
Working through all tasks under epic $EPIC_ID using Beads dependency-aware workflow.
This is a HEADLESS session - be thorough and explicit in your work.

## Pre-flight
1. Read activity.md if it exists for recent context
2. Run 'bd show $EPIC_ID --json' to understand epic scope
3. Run 'bd list --parent $EPIC_ID --json' to see all tasks

## Workflow
1. Run 'bd ready --json' to find unblocked tasks
2. Filter to tasks with parent $EPIC_ID
3. If no ready tasks but open tasks exist, check for circular dependencies
4. Select highest priority ready task
5. Claim: 'bd update <id> --status in_progress'
6. Implement fully:
   - Write code following project conventions
   - Add/update tests as needed
   - Run linter and fix issues
7. Verify: run test suite, ensure all pass
8. Commit: 'git add . && git commit -m \"feat(<id>): <description>\"'
9. Close: 'bd close <id> --reason \"<summary>\"'
10. Sync: 'bd sync'

## After Each Task
Update activity.md with:
- Task ID completed
- What was implemented
- Any issues encountered
- Time spent (estimate)

## Discovery Protocol
If you find new work:
- File: 'bd create \"<title>\" --type <bug|task> --parent $EPIC_ID --deps discovered-from:<current>'
- Continue with current task

## Exit Conditions
- Output <promise>EPIC_COMPLETE</promise> when 'bd list --parent $EPIC_ID --status open' returns empty
- Output <promise>BLOCKED</promise> if human decision required
- Output <promise>STUCK</promise> after working on same task for entire session without progress

## Important
- Complete AT LEAST one task per session if possible
- Leave codebase in clean, working state
- Commit before session ends
- Be explicit about what you accomplished
"

# Run the loop
run_ralph_loop "$PROMPT" "EPIC_COMPLETE" "$MAX_ITERATIONS"
exit_code=$?

case $exit_code in
    0)
        log_success "Epic $EPIC_ID completed successfully!"
        ;;
    1)
        log_warning "Max iterations reached. Epic may be partially complete."
        log_info "Run 'bd list --parent $EPIC_ID --status open' to see remaining tasks."
        ;;
    2)
        log_warning "Epic execution blocked. Check activity.md for details."
        ;;
    3)
        log_error "Epic execution stuck. Manual intervention needed."
        ;;
esac

exit $exit_code
