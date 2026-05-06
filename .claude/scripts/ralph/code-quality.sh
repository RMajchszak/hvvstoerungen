#!/bin/bash
# .claude/scripts/ralph/code-quality.sh
# Headless Ralph Wiggum loop for code quality reviews
#
# Usage: ./.claude/scripts/ralph/code-quality.sh <path> [--scope <full|complexity|performance|maintainability|correctness>] [-n max-iterations]
# Example: ./.claude/scripts/ralph/code-quality.sh ./internal --scope complexity -n 50

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <path> [options]

Perform comprehensive code quality review of a codebase path.

Arguments:
    path                Path to review (directory, file, or glob pattern)

Options:
    --scope             Focus area: full (default), complexity, performance, maintainability, correctness
    -n, --max-iterations    Maximum iterations (default: 50)
    -h, --help              Show this help message

Examples:
    $(basename "$0") ./internal
    $(basename "$0") ./internal --scope complexity
    $(basename "$0") ./internal --scope performance -n 30

Quality Dimensions:
    - Complexity: cyclomatic complexity, cognitive complexity, nesting depth
    - Performance: algorithmic efficiency, resource usage, caching
    - Maintainability: naming, documentation, modularity, duplication
    - Correctness: type safety, error handling, edge cases

Notes:
    - Analyzes one file per iteration
    - Generates quality score (0-100)
    - Exit codes: 0=complete, 1=max iterations, 2=blocked, 3=stuck
EOF
}

# Parse arguments
TARGET_PATH=""
SCOPE="full"
MAX_ITERATIONS=50

while [[ $# -gt 0 ]]; do
    case $1 in
        --scope)
            SCOPE="$2"
            shift 2
            ;;
        -n|--max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$TARGET_PATH" ]; then
                TARGET_PATH="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$TARGET_PATH" ]; then
    log_error "Target path is required"
    show_help
    exit 1
fi

# Validate path exists
if [ ! -e "$TARGET_PATH" ]; then
    log_error "Path does not exist: $TARGET_PATH"
    exit 1
fi

log_info "Code Quality Review: $TARGET_PATH"
log_info "Scope: $SCOPE"
log_info "Max iterations: $MAX_ITERATIONS"

# Build the prompt
PROMPT="Code Quality Review of $TARGET_PATH:

## Context
Performing code quality review with focus on $SCOPE scope.
This is a HEADLESS session - analyze files systematically and document findings.

## Pre-flight
1. Check activity.md for any previous review progress
2. Build file queue: scan for supported files (.go, .ts, .js, .py, etc.)
3. Initialize tracking structures for findings

## Quality Dimensions

Based on scope '$SCOPE':
$(case $SCOPE in
    full) echo "- Analyze all dimensions: Complexity, Performance, Maintainability, Correctness";;
    complexity) echo "- Focus on: Cyclomatic complexity, cognitive complexity, nesting depth";;
    performance) echo "- Focus on: Algorithmic efficiency, resource usage, caching, N+1 queries";;
    maintainability) echo "- Focus on: Naming, documentation, modularity, duplication, test coverage";;
    correctness) echo "- Focus on: Type safety, error handling, edge cases, null checks, logic errors";;
esac)

## Per-File Analysis

For each file, measure:

**Complexity Metrics:**
- Cyclomatic Complexity: Good <10, Acceptable 10-20, Poor >20
- Cognitive Complexity: Good <10, Acceptable 10-20, Poor >20
- Nesting Depth: Good <=3, Acceptable 4-5, Poor >5

**Maintainability Metrics:**
- Function Length: Good <30 lines, Acceptable 30-75, Poor >75
- Class/Module Size: Good <300 lines, Acceptable 300-600, Poor >600
- Naming Quality: clear, consistent, descriptive
- Code Duplication: similar blocks, copy-paste patterns

**Performance Patterns:**
- Nested loops without bounds
- N+1 query patterns
- Missing caching opportunities
- Unbounded memory allocation

**Correctness Issues:**
- Missing null/nil checks
- Uncaught exceptions
- Off-by-one errors
- Resource leaks

## Finding Format
For each issue:
- Severity: CRITICAL/HIGH/MEDIUM/LOW/INFO
- Category: complexity/performance/maintainability/correctness
- Location: file:line
- Description and code pattern
- Recommendation

## Quality Score Calculation
Base: 100 points
- CRITICAL: -5 points each (max -25)
- HIGH: -1 point each (max -20)
- MEDIUM: -0.5 points each (max -10)
- LOW: -0.1 points each (max -5)

Rating:
- 90-100: Excellent
- 80-89: Good
- 70-79: Acceptable
- 60-69: Needs Work
- <60: Poor

## Exit Conditions
- <promise>QUALITY_REVIEW_COMPLETE</promise> when all files analyzed and report generated
- <promise>BLOCKED:MUST_ASK</promise> if critical issue needs human decision
- <promise>BLOCKED:RUNTIME</promise> if path inaccessible or no supported files
- <promise>STUCK</promise> if same file fails 3+ times

## Important
- ONE file per iteration (progress tracking)
- Document positive findings (well-designed code)
- Generate actionable recommendations
- Include hotspot analysis (files with most issues)
"

# Run the loop
run_ralph_loop "$PROMPT" "QUALITY_REVIEW_COMPLETE" "$MAX_ITERATIONS"
exit_code=$?

case $exit_code in
    0)
        log_success "Code quality review complete: $TARGET_PATH"
        ;;
    1)
        log_warning "Max iterations reached. Review may be incomplete."
        ;;
    2)
        log_warning "Review blocked. Check activity.md for details."
        ;;
    3)
        log_error "Review stuck. Manual intervention needed."
        ;;
esac

exit $exit_code
