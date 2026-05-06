#!/bin/bash
# On-error hook: Capture diagnostic information when commands fail
# Always exits 0 to not block error reporting

DIAGNOSTICS_DIR=".claude/state/diagnostics"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DIAG_FILE="$DIAGNOSTICS_DIR/error_$TIMESTAMP.log"

# Ensure diagnostics directory exists
mkdir -p "$DIAGNOSTICS_DIR"

# Capture diagnostic information
{
    echo "=== Error Diagnostics ==="
    echo "Timestamp: $(date)"
    echo ""

    echo "=== Environment ==="
    echo "PWD: $(pwd)"
    echo "USER: $(whoami)"
    echo ""

    echo "=== Git Status ==="
    git status --short 2>/dev/null || echo "Not a git repository"
    echo ""

    echo "=== Recent Git Log ==="
    git log --oneline -5 2>/dev/null || echo "N/A"
    echo ""

    echo "=== Disk Space ==="
    df -h . 2>/dev/null | head -2
    echo ""

    echo "=== Memory ==="
    if command -v free &> /dev/null; then
        free -h 2>/dev/null
    elif [ "$(uname)" = "Darwin" ]; then
        vm_stat 2>/dev/null | head -5
    fi
    echo ""

    echo "=== Recent Processes ==="
    ps aux | head -10 2>/dev/null
    echo ""

    echo "=== Environment Variables (filtered) ==="
    env | grep -E '^(PATH|HOME|NODE_|PYTHON|RUST|GO|JAVA)' 2>/dev/null
    echo ""

} > "$DIAG_FILE" 2>&1

echo "{\"diagnostics_file\": \"$DIAG_FILE\"}"
exit 0
