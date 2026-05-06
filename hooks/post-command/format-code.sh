#!/bin/bash
# Post-command hook: Auto-format modified files
# Runs after Edit/Write operations

set -e

# Get modified files from environment or git
get_modified_files() {
    if [ -n "$CLAUDE_FILE_PATHS" ]; then
        echo "$CLAUDE_FILE_PATHS"
    else
        git diff --name-only HEAD 2>/dev/null || echo ""
    fi
}

# Detect formatter for file type
format_file() {
    local file=$1
    local ext="${file##*.}"

    case "$ext" in
        js|jsx|ts|tsx|json|md)
            if command -v npx &> /dev/null && [ -f "node_modules/.bin/prettier" ]; then
                npx prettier --write "$file" 2>/dev/null
            fi
            ;;
        py)
            if command -v ruff &> /dev/null; then
                ruff format "$file" 2>/dev/null
            elif command -v black &> /dev/null; then
                black "$file" 2>/dev/null
            fi
            ;;
        rs)
            if command -v rustfmt &> /dev/null; then
                rustfmt "$file" 2>/dev/null
            fi
            ;;
        go)
            if command -v gofmt &> /dev/null; then
                gofmt -w "$file" 2>/dev/null
            fi
            ;;
    esac
}

# Main
FILES=$(get_modified_files)

if [ -z "$FILES" ]; then
    exit 0
fi

for file in $FILES; do
    if [ -f "$file" ]; then
        format_file "$file"
    fi
done

echo "{\"formatted\": true}"
exit 0
