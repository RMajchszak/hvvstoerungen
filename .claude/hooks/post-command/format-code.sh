#!/bin/bash
# Post-command hook: Auto-format Go files with gofmt

set -e

# Get modified files
get_modified_files() {
    if [ -n "$CLAUDE_FILE_PATHS" ]; then
        echo "$CLAUDE_FILE_PATHS"
    else
        git diff --name-only HEAD 2>/dev/null || echo ""
    fi
}

format_go_file() {
    local file=$1
    if [[ "$file" == *.go ]] && [ -f "$file" ]; then
        if command -v gofmt &> /dev/null; then
            gofmt -w "$file" 2>/dev/null
            return 0
        fi
    fi
    return 1
}

FILES=$(get_modified_files)
FORMATTED=0

if [ -z "$FILES" ]; then
    echo "{\"formatted\": false, \"reason\": \"no files\"}"
    exit 0
fi

for file in $FILES; do
    if format_go_file "$file"; then
        ((FORMATTED++)) || true
    fi
done

echo "{\"formatted\": true, \"files\": $FORMATTED}"
exit 0
