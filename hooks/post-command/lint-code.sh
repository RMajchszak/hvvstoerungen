#!/bin/bash
# Post-command hook: Auto-lint modified files based on detected toolchain
# Runs after Edit/Write operations

set -e

# Detect project toolchain (reuses logic from check-toolchain.sh)
detect_toolchain() {
    if [ -f "tsconfig.json" ]; then
        echo "typescript"
    elif [ -f "package.json" ]; then
        echo "javascript"
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        echo "python"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    else
        echo "generic"
    fi
}

# Get modified files from environment or git
get_modified_files() {
    if [ -n "$CLAUDE_FILE_PATHS" ]; then
        echo "$CLAUDE_FILE_PATHS"
    else
        git diff --name-only HEAD 2>/dev/null || echo ""
    fi
}

# Check if file matches toolchain
file_matches_toolchain() {
    local file=$1
    local toolchain=$2
    local ext="${file##*.}"

    case "$toolchain" in
        javascript)
            [[ "$ext" =~ ^(js|jsx|mjs|cjs)$ ]]
            ;;
        typescript)
            [[ "$ext" =~ ^(ts|tsx|js|jsx|mjs|cjs)$ ]]
            ;;
        python)
            [[ "$ext" == "py" ]]
            ;;
        rust)
            [[ "$ext" == "rs" ]]
            ;;
        go)
            [[ "$ext" == "go" ]]
            ;;
        java)
            [[ "$ext" == "java" ]]
            ;;
        ruby)
            [[ "$ext" == "rb" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Run linter based on toolchain
run_linter() {
    local toolchain=$1
    local files=$2
    local linted=0

    case "$toolchain" in
        javascript|typescript)
            # ESLint with auto-fix
            if [ -f "node_modules/.bin/eslint" ]; then
                for file in $files; do
                    if file_matches_toolchain "$file" "$toolchain" && [ -f "$file" ]; then
                        npx eslint --fix "$file" 2>/dev/null || true
                        ((linted++)) || true
                    fi
                done
            fi
            ;;
        python)
            # Ruff with auto-fix (preferred) or flake8
            if command -v ruff &> /dev/null; then
                for file in $files; do
                    if file_matches_toolchain "$file" "$toolchain" && [ -f "$file" ]; then
                        ruff check --fix "$file" 2>/dev/null || true
                        ((linted++)) || true
                    fi
                done
            elif command -v flake8 &> /dev/null; then
                # flake8 doesn't auto-fix, just report
                for file in $files; do
                    if file_matches_toolchain "$file" "$toolchain" && [ -f "$file" ]; then
                        flake8 "$file" 2>/dev/null || true
                        ((linted++)) || true
                    fi
                done
            fi
            ;;
        rust)
            # Clippy with auto-fix
            if command -v cargo &> /dev/null; then
                # Clippy works on the whole project, not individual files
                cargo clippy --fix --allow-dirty --allow-staged 2>/dev/null || true
                linted=1
            fi
            ;;
        go)
            # golangci-lint with auto-fix
            if command -v golangci-lint &> /dev/null; then
                for file in $files; do
                    if file_matches_toolchain "$file" "$toolchain" && [ -f "$file" ]; then
                        golangci-lint run --fix "$file" 2>/dev/null || true
                        ((linted++)) || true
                    fi
                done
            elif command -v go &> /dev/null; then
                # Fallback to go vet (no auto-fix)
                for file in $files; do
                    if file_matches_toolchain "$file" "$toolchain" && [ -f "$file" ]; then
                        go vet "$file" 2>/dev/null || true
                        ((linted++)) || true
                    fi
                done
            fi
            ;;
        java)
            # Checkstyle or SpotBugs (no standard auto-fix)
            # Just skip for now - Java linting typically runs via build tools
            ;;
        ruby)
            # RuboCop with auto-fix
            if command -v rubocop &> /dev/null; then
                for file in $files; do
                    if file_matches_toolchain "$file" "$toolchain" && [ -f "$file" ]; then
                        rubocop --autocorrect "$file" 2>/dev/null || true
                        ((linted++)) || true
                    fi
                done
            fi
            ;;
    esac

    echo $linted
}

# Main
TOOLCHAIN=$(detect_toolchain)
FILES=$(get_modified_files)

if [ -z "$FILES" ]; then
    echo "{\"linted\": false, \"reason\": \"no files\"}"
    exit 0
fi

if [ "$TOOLCHAIN" = "generic" ]; then
    echo "{\"linted\": false, \"reason\": \"unknown toolchain\"}"
    exit 0
fi

LINTED=$(run_linter "$TOOLCHAIN" "$FILES")

echo "{\"linted\": true, \"toolchain\": \"$TOOLCHAIN\", \"files_checked\": $LINTED}"
exit 0
