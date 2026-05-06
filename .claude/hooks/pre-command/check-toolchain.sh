#!/bin/bash
# Pre-command hook: Validate Go toolchain is available
# Exit codes: 0=proceed, 1=warn, 2=abort

set -e

# Check Go is available
check_go() {
    if ! command -v go &> /dev/null; then
        echo "Warning: Go not found" >&2
        return 1
    fi
    return 0
}

# Detect available tools
detect_tools() {
    local tools=()

    command -v go &>/dev/null && tools+=("go")
    command -v golangci-lint &>/dev/null && tools+=("golangci-lint")
    command -v goreleaser &>/dev/null && tools+=("goreleaser")
    command -v git &>/dev/null && tools+=("git")
    command -v bd &>/dev/null && tools+=("bd")

    # Output as JSON array
    if [ ${#tools[@]} -gt 0 ]; then
        printf '%s\n' "${tools[@]}" | jq -R . | jq -s .
    else
        echo "[]"
    fi
}

# Main
TOOLS=$(detect_tools)
echo "{\"toolchain\": \"go\", \"tools\": $TOOLS}"

if check_go; then
    exit 0
else
    exit 1
fi
