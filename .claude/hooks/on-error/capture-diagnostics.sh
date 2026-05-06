#!/bin/bash
# On-error hook: Capture diagnostic information when commands fail

DIAGNOSTICS_DIR=".claude/state/diagnostics"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DIAG_FILE="$DIAGNOSTICS_DIR/error_$TIMESTAMP.log"

mkdir -p "$DIAGNOSTICS_DIR"

{
    echo "=== Error Diagnostics ==="
    echo "Timestamp: $(date)"
    echo ""

    echo "=== Environment ==="
    echo "PWD: $(pwd)"
    echo "USER: $(whoami)"
    echo "Go version: $(go version 2>/dev/null || echo 'N/A')"
    echo ""

    echo "=== Git Status ==="
    git status --short 2>/dev/null || echo "Not a git repository"
    echo ""

    echo "=== Recent Git Log ==="
    git log --oneline -5 2>/dev/null || echo "N/A"
    echo ""

    echo "=== Go Module ==="
    cat go.mod 2>/dev/null | head -5 || echo "N/A"
    echo ""

    echo "=== Disk Space ==="
    df -h . 2>/dev/null | head -2
    echo ""

    echo "=== Environment Variables (filtered) ==="
    env | grep -E '^(PATH|HOME|GOPATH|GOROOT|GO)' 2>/dev/null
    echo ""

} > "$DIAG_FILE" 2>&1

echo "{\"diagnostics_file\": \"$DIAG_FILE\"}"
exit 0
