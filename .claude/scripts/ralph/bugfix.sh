#!/bin/bash
# .claude/scripts/ralph/bugfix.sh
# Headless Ralph Wiggum loop for bug fix sprints
#
# Usage: ./.claude/scripts/ralph/bugfix.sh [epic-id] [-n max-iterations]
# Example: ./.claude/scripts/ralph/bugfix.sh bd-abc123 -n 30
# Example: ./.claude/scripts/ralph/bugfix.sh -n 20  # All open bugs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") [epic-id] [options]

Fix bugs in priority order, optionally filtered by epic.

Arguments:
    epic-id             (Optional) Beads epic ID to filter bugs

Options:
    -n, --max-iterations    Maximum iterations (default: 30)
    -h, --help              Show this help message

Examples:
    $(basename "$0")                    # All open bugs
    $(basename "$0") bd-abc123          # Bugs under specific epic
    $(basename "$0") -n 20              # All bugs, max 20 iterations
    $(basename "$0") bd-abc123 -n 50    # Epic bugs, max 50 iterations

Notes:
    - Each bug fix includes a regression test
    - Bugs fixed in priority order (0=critical, 3=low)
    - Exit codes: 0=all cleared, 1=max iterations, 2=blocked, 3=stuck
EOF
}

# Parse arguments
parse_args "$@"

EPIC_ID="${TARGET_ID:-}"
MAX_ITERATIONS="${MAX_ITERATIONS:-30}"

if [ -n "$EPIC_ID" ]; then
    log_info "Bug fix sprint for epic: $EPIC_ID"
    EPIC_FILTER="--parent $EPIC_ID"
    SCOPE_DESC="under epic $EPIC_ID"
else
    log_info "Bug fix sprint for all open bugs"
    EPIC_FILTER=""
    SCOPE_DESC="in the project"
fi

# Check for open bugs
BUG_COUNT=$(bd list --type bug --status open $EPIC_FILTER --json 2>/dev/null | jq 'length' || echo "0")
log_info "Found $BUG_COUNT open bugs $SCOPE_DESC"

if [ "$BUG_COUNT" = "0" ]; then
    log_success "No open bugs found. Nothing to do!"
    exit 0
fi

# Build the prompt
PROMPT="Bug Fix Sprint $SCOPE_DESC:

## Context
Systematically fixing bugs in priority order. Each fix must include a regression test.
This is a HEADLESS session - be thorough and document everything.

## Pre-flight
1. Check activity.md for any bugs recently attempted
2. Run: bd list --type bug --status open $EPIC_FILTER --json | jq 'sort_by(.priority)'
3. Understand the bug landscape before starting

## Workflow
1. Query: bd list --type bug --status open $EPIC_FILTER --json | jq 'sort_by(.priority) | .[0]'
2. If no bugs returned, output <promise>BUGS_CLEARED</promise>
3. Claim: 'bd update <id> --status in_progress'
4. Investigate:
   - Read bug description fully
   - Check linked issues for context
   - Try to reproduce the bug
   - Identify root cause (don't guess - trace the code)
5. Fix:
   - Implement minimal fix for root cause
   - Write regression test FIRST if possible (TDD approach)
   - Fix must not introduce new bugs
6. Verify:
   - Run regression test
   - Run full test suite
   - Manually verify if applicable
7. Commit: 'git add . && git commit -m \"fix(<id>): <root cause summary>\"'
8. Close: 'bd close <id> --reason \"Root cause: <X>. Fixed by: <Y>. Test: <Z>\"'
9. Sync: 'bd sync'

## Quality Requirements
Every bug fix MUST have:
- [ ] Clear root cause identified
- [ ] Minimal fix (no scope creep)
- [ ] Regression test added
- [ ] All existing tests still pass
- [ ] Documentation if behavior changed

## Discovery Protocol
- Related bugs found: 'bd create \"<title>\" --type bug --priority <N> --deps related:<current>'
- Fix reveals deeper issue: 'bd create \"Refactor: <issue>\" --type chore --deps discovered-from:<current>'

## Exit Conditions
- <promise>BUGS_CLEARED</promise> when no open bugs remain $SCOPE_DESC
- <promise>COMPLEX_BUG</promise> if bug requires architectural changes
- <promise>BLOCKED</promise> if cannot reproduce or need more information
- <promise>STUCK</promise> if same bug attempted 3+ times without fix

## Important
- ONE bug per session maximum
- Always leave code in working state
- If you can't fix a bug, document what you tried
"

# Run the loop
run_ralph_loop "$PROMPT" "BUGS_CLEARED" "$MAX_ITERATIONS"
exit_code=$?

case $exit_code in
    0)
        log_success "All bugs cleared!"
        ;;
    1)
        REMAINING=$(bd list --type bug --status open $EPIC_FILTER --json 2>/dev/null | jq 'length' || echo "?")
        log_warning "Max iterations reached. $REMAINING bugs remaining."
        ;;
    2)
        log_warning "Bug fix blocked. Check activity.md for details."
        ;;
    3)
        log_error "Bug fix stuck. Complex bug may need manual investigation."
        ;;
esac

exit $exit_code
