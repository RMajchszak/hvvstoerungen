#!/bin/bash
# .claude/scripts/ralph/common.sh
# Shared functions for headless Ralph Wiggum loops
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Path configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
ACTIVITY_FILE="${ACTIVITY_FILE:-$PROJECT_ROOT/activity.md}"

# Default settings
DEFAULT_MAX_ITERATIONS=50
CLAUDE_CMD="claude"

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_iteration() {
    local current=$1
    local max=$2
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ITERATION $current / $max${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

# Check for required tools
check_dependencies() {
    local missing=()

    if ! command -v claude &> /dev/null; then
        missing+=("claude (Claude Code CLI)")
    fi

    if ! command -v bd &> /dev/null; then
        missing+=("bd (Beads CLI)")
    fi

    if ! command -v jq &> /dev/null; then
        missing+=("jq (JSON processor)")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing required dependencies:"
        for dep in "${missing[@]}"; do
            echo "  - $dep"
        done
        exit 1
    fi
}

# Run Claude in headless mode
run_claude_headless() {
    local prompt="$1"
    local output_file=$(mktemp)

    # Run Claude in print mode with output captured
    # --print outputs to stdout instead of interactive mode
    # --permission-mode delegate for safer autonomous operation
    $CLAUDE_CMD --print \
        --permission-mode delegate \
        --output-format text \
        "$prompt" 2>&1 | tee "$output_file"

    # Return the output file path for checking promises
    echo "$output_file"
}

# Check if output contains a promise
check_promise() {
    local output_file="$1"
    local promise="$2"

    if grep -q "<promise>$promise</promise>" "$output_file"; then
        return 0
    fi
    return 1
}

# Extract promise from output (macOS-compatible)
extract_promise() {
    local output_file="$1"
    # Use sed instead of grep -oP for macOS compatibility
    sed -n 's/.*<promise>\([^<]*\)<\/promise>.*/\1/p' "$output_file" | head -1
}

# Update activity log
update_activity() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [ ! -f "$ACTIVITY_FILE" ]; then
        cat > "$ACTIVITY_FILE" << 'EOF'
# Activity Log

This file tracks progress across Ralph Wiggum sessions. Each session appends entries here.

---

EOF
    fi

    echo "## [$timestamp] Headless Ralph" >> "$ACTIVITY_FILE"
    echo "$message" >> "$ACTIVITY_FILE"
    echo "" >> "$ACTIVITY_FILE"
}

# Main loop runner
run_ralph_loop() {
    local prompt_template="$1"
    local success_promise="$2"
    local max_iterations="${3:-$DEFAULT_MAX_ITERATIONS}"
    local iteration=1

    check_dependencies

    log_info "Starting headless Ralph loop"
    log_info "Success promise: $success_promise"
    log_info "Max iterations: $max_iterations"
    log_info "Activity file: $ACTIVITY_FILE"

    update_activity "Started headless loop. Target: $success_promise, Max iterations: $max_iterations"

    while [ $iteration -le $max_iterations ]; do
        log_iteration $iteration $max_iterations

        # Run Claude and capture output
        local output_file=$(run_claude_headless "$prompt_template")

        # Check for success
        if check_promise "$output_file" "$success_promise"; then
            log_success "Task completed! Promise '$success_promise' found."
            update_activity "Completed successfully after $iteration iterations."
            rm -f "$output_file"
            return 0
        fi

        # Check for blocked
        if check_promise "$output_file" "BLOCKED"; then
            log_warning "Agent is blocked. Human intervention required."
            local reason=$(grep -A5 "BLOCKED" "$output_file" | head -5)
            update_activity "BLOCKED after $iteration iterations. Reason: $reason"
            rm -f "$output_file"
            return 2
        fi

        # Check for stuck
        if check_promise "$output_file" "STUCK"; then
            log_error "Agent is stuck. No progress being made."
            update_activity "STUCK after $iteration iterations."
            rm -f "$output_file"
            return 3
        fi

        # Check for any other promise (might be a checkpoint)
        local found_promise=$(extract_promise "$output_file")
        if [ -n "$found_promise" ]; then
            log_info "Found promise: $found_promise"
        fi

        rm -f "$output_file"
        iteration=$((iteration + 1))

        # Small delay between iterations to avoid rate limits
        sleep 2
    done

    log_warning "Max iterations ($max_iterations) reached without completion."
    update_activity "Max iterations reached without completion."
    return 1
}

# Parse common arguments
parse_args() {
    MAX_ITERATIONS=$DEFAULT_MAX_ITERATIONS

    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--max-iterations)
                MAX_ITERATIONS="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                # First positional argument
                if [ -z "${TARGET_ID:-}" ]; then
                    TARGET_ID="$1"
                fi
                shift
                ;;
        esac
    done
}
