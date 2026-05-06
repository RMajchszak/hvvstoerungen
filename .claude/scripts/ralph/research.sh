#!/bin/bash
# .claude/scripts/ralph/research.sh
# Headless Ralph Wiggum loop for research-to-requirements processing
#
# Usage: ./.claude/scripts/ralph/research.sh <folder-path> [--output <path>] [-n max-iterations]
# Example: ./.claude/scripts/ralph/research.sh ./docs/requirements --output ./requirements.md -n 30

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

show_help() {
    cat << EOF
Usage: $(basename "$0") <folder-path> [options]

Process documents in a folder and produce consolidated requirements documentation.

Arguments:
    folder-path         Path to folder containing documents to process

Options:
    --output            Output path for requirements document (default: ./requirements.md)
    -n, --max-iterations    Maximum iterations (default: 30)
    -h, --help              Show this help message

Supported Formats:
    .md, .txt, .pdf, .docx

Examples:
    $(basename "$0") ./docs/requirements
    $(basename "$0") ./docs/research --output ./output/requirements.md
    $(basename "$0") ./input --output ./specs/requirements.md -n 50

Notes:
    - Processes one document per iteration
    - Extracts and categorizes requirements
    - Deduplicates across sources
    - Creates traceability matrix
    - Exit codes: 0=complete, 1=max iterations, 2=blocked (conflict), 3=stuck
EOF
}

# Parse arguments
FOLDER_PATH=""
OUTPUT_PATH="./requirements.md"
MAX_ITERATIONS=30

while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_PATH="$2"
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
            if [ -z "$FOLDER_PATH" ]; then
                FOLDER_PATH="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$FOLDER_PATH" ]; then
    log_error "Folder path is required"
    show_help
    exit 1
fi

# Validate folder exists
if [ ! -d "$FOLDER_PATH" ]; then
    log_error "Folder does not exist: $FOLDER_PATH"
    exit 1
fi

# Count documents
DOC_COUNT=$(find "$FOLDER_PATH" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.pdf" -o -name "*.docx" \) | wc -l | tr -d ' ')

if [ "$DOC_COUNT" -eq 0 ]; then
    log_error "No supported documents found in: $FOLDER_PATH"
    log_info "Supported formats: .md, .txt, .pdf, .docx"
    exit 1
fi

log_info "Research to Requirements: $FOLDER_PATH"
log_info "Documents found: $DOC_COUNT"
log_info "Output: $OUTPUT_PATH"
log_info "Max iterations: $MAX_ITERATIONS"

# Build the prompt
PROMPT="Research to Requirements: $FOLDER_PATH

## Context
Processing documents to extract and consolidate requirements.
Output file: $OUTPUT_PATH
This is a HEADLESS session - process documents systematically.

## Pre-flight
1. Check activity.md for any previous processing progress
2. Scan folder for documents: $FOLDER_PATH
3. Build document queue with paths and formats
4. Initialize requirements accumulator

## Document Processing Workflow

For each document:
1. Read document content
2. Extract requirements:
   - Explicit markers: 'requirement', 'shall', 'must', 'should', 'will'
   - List structures: numbered items, bullet points
   - Acceptance criteria sections
   - Constraint statements
3. Categorize each requirement:
   - FUNCTIONAL: observable behavior, user-facing features
   - NON-FUNCTIONAL: performance, security, scalability
   - CONSTRAINTS: technical, regulatory, architectural
   - ASSUMPTIONS: implicit requirements, preconditions
4. Deduplicate against accumulated requirements
5. Track provenance (source document, line reference)
6. Check for conflicts with existing requirements

## MUST ASK Conditions

Stop immediately if ANY detected:
- MA-1: Contradictory requirements between documents
- MA-2: Critical ambiguity (undefined terms)
- MA-3: Scope conflict (different projects described)
- MA-4: Priority conflict (competing requirements, no guidance)
- MA-5: Incomplete requirements (insufficient detail)

If any MUST ASK fires:
- Output <promise>BLOCKED:MUST_ASK</promise>
- Include conflict details and decision options

## Output Document Structure

Generate requirements document with:
1. Executive Summary
2. Functional Requirements (FR-XXX)
3. Non-Functional Requirements (NFR-XXX)
4. Constraints (CON-XXX)
5. Assumptions (ASM-XXX)
6. Traceability Matrix
7. Open Questions
8. Source Documents

## Exit Conditions
- <promise>REQUIREMENTS_COMPLETE</promise> when all documents processed and requirements synthesized
- <promise>BLOCKED:MUST_ASK</promise> if requirements conflict detected
- <promise>BLOCKED:RUNTIME</promise> if folder empty or documents unreadable
- <promise>STUCK</promise> if same document fails 3+ times

## Important
- ONE document per iteration
- Track provenance for every requirement
- Deduplicate semantically similar requirements
- Stop immediately on conflicts
- Generate complete traceability matrix
"

# Run the loop
run_ralph_loop "$PROMPT" "REQUIREMENTS_COMPLETE" "$MAX_ITERATIONS"
exit_code=$?

case $exit_code in
    0)
        log_success "Requirements extraction complete!"
        log_info "Output: $OUTPUT_PATH"
        ;;
    1)
        log_warning "Max iterations reached. Processing may be incomplete."
        ;;
    2)
        log_warning "Processing blocked. Requirements conflict detected."
        log_info "Check activity.md for conflict details."
        ;;
    3)
        log_error "Processing stuck. Document may be unreadable."
        ;;
esac

exit $exit_code
