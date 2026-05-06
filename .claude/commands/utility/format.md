---
description: Format code files
argument-hint: [file or directory]
allowed-tools: Bash
---

# Format Code

Run the code formatter for this project.

## Target
$ARGUMENTS (default: entire project)

## Detect Formatter
![ -f "package.json" ] && grep -q "prettier" package.json && echo "prettier" || \
 [ -f "pyproject.toml" ] && echo "ruff/black" || \
 [ -f "Cargo.toml" ] && echo "rustfmt" || \
 [ -f "go.mod" ] && echo "gofmt" || \
 echo "unknown"

## Format Commands

**Prettier (JS/TS):**
```bash
npx prettier --write "$TARGET"
```

**Ruff (Python):**
```bash
ruff format $TARGET
```

**Black (Python):**
```bash
black $TARGET
```

**Rustfmt (Rust):**
```bash
cargo fmt
```

**Gofmt (Go):**
```bash
gofmt -w $TARGET
```

## Execute

Run the appropriate formatter.

## Output

Report:
- Files formatted
- Any issues encountered
