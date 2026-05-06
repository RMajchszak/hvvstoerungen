---
description: Run linter with optional auto-fix
argument-hint: [--fix] [path]
allowed-tools: Bash
---

# Lint Code

Run the linter for this project.

## Arguments
- `--fix`: Auto-fix issues where possible
- Path: Specific file/directory (default: all)

## Detect Linter
![ -f "package.json" ] && grep -q "eslint" package.json && echo "eslint" || \
 [ -f "pyproject.toml" ] && echo "ruff" || \
 [ -f "Cargo.toml" ] && echo "clippy" || \
 [ -f "go.mod" ] && echo "golangci-lint" || \
 echo "unknown"

## Lint Commands

**ESLint (JS/TS):**
```bash
npx eslint . --ext .js,.ts,.jsx,.tsx
# with fix:
npx eslint . --ext .js,.ts,.jsx,.tsx --fix
```

**Ruff (Python):**
```bash
ruff check .
# with fix:
ruff check . --fix
```

**Clippy (Rust):**
```bash
cargo clippy
# with fix:
cargo clippy --fix
```

**golangci-lint (Go):**
```bash
golangci-lint run
# with fix:
golangci-lint run --fix
```

## Execute

Run the appropriate linter.

## Output

Report:
- Errors found (count)
- Warnings found (count)
- Files with issues
- Auto-fixed (if --fix)
