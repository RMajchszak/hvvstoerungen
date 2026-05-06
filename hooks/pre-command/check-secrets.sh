#!/bin/bash
# Pre-command hook: Block commits containing potential secrets
# Exit codes: 0=proceed, 2=block

set -e

# Patterns that indicate potential secrets
SECRET_PATTERNS=(
    'api[_-]?key\s*[:=]\s*["\047][^"\047]+'
    'api[_-]?secret\s*[:=]\s*["\047][^"\047]+'
    'password\s*[:=]\s*["\047][^"\047]+'
    'secret\s*[:=]\s*["\047][^"\047]+'
    'token\s*[:=]\s*["\047][^"\047]+'
    'private[_-]?key'
    'BEGIN RSA PRIVATE KEY'
    'BEGIN OPENSSH PRIVATE KEY'
    'AKIA[0-9A-Z]{16}'  # AWS Access Key
)

# Files to skip
SKIP_PATTERNS=(
    '\.md$'
    '\.txt$'
    'example'
    'sample'
    'test'
    'mock'
    'fixture'
)

check_file() {
    local file=$1

    # Skip if file matches skip patterns
    for pattern in "${SKIP_PATTERNS[@]}"; do
        if echo "$file" | grep -qiE "$pattern"; then
            return 0
        fi
    done

    # Check for secret patterns
    for pattern in "${SECRET_PATTERNS[@]}"; do
        if grep -qiE "$pattern" "$file" 2>/dev/null; then
            echo "Potential secret found in $file matching pattern: $pattern" >&2
            return 1
        fi
    done

    return 0
}

# Main
# Read staged files if this is a pre-commit context
if [ -n "$CLAUDE_FILE_PATHS" ]; then
    FILES="$CLAUDE_FILE_PATHS"
else
    FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
fi

FOUND_SECRETS=false

for file in $FILES; do
    if [ -f "$file" ]; then
        if ! check_file "$file"; then
            FOUND_SECRETS=true
        fi
    fi
done

if [ "$FOUND_SECRETS" = true ]; then
    echo "{\"status\": \"blocked\", \"reason\": \"Potential secrets detected\"}"
    exit 2
fi

echo "{\"status\": \"ok\"}"
exit 0
