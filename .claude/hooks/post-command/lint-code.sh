#!/bin/bash
# Post-command hook: Auto-lint Go files with golangci-lint

set -e

# Get modified files
get_modified_files() {
    if [ -n "$CLAUDE_FILE_PATHS" ]; then
        echo "$CLAUDE_FILE_PATHS"
    else
        git diff --name-only HEAD 2>/dev/null || echo ""
    fi
}

FILES=$(get_modified_files)
LINTED=0

if [ -z "$FILES" ]; then
    echo "{\"linted\": false, \"reason\": \"no files\"}"
    exit 0
fi

# Check if any Go files were modified
GO_FILES=""
for file in $FILES; do
    if [[ "$file" == *.go ]] && [ -f "$file" ]; then
        GO_FILES="$GO_FILES $file"
    fi
done

if [ -z "$GO_FILES" ]; then
    echo "{\"linted\": false, \"reason\": \"no go files\"}"
    exit 0
fi

# Run golangci-lint if available
if command -v golangci-lint &> /dev/null; then
    for file in $GO_FILES; do
        golangci-lint run --fix "$file" 2>/dev/null || true
        ((LINTED++)) || true
    done
    echo "{\"linted\": true, \"tool\": \"golangci-lint\", \"files\": $LINTED}"
elif command -v go &> /dev/null; then
    # Fallback to go vet
    for file in $GO_FILES; do
        go vet "$file" 2>/dev/null || true
        ((LINTED++)) || true
    done
    echo "{\"linted\": true, \"tool\": \"go vet\", \"files\": $LINTED}"
else
    echo "{\"linted\": false, \"reason\": \"no linter available\"}"
fi

exit 0
