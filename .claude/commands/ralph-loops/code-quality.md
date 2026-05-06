---
description: Run headless code quality review
argument-hint: <path> [--scope] [--max-iterations]
allowed-tools: Bash(.claude/scripts/ralph/code-quality.sh:*)
---

# Headless Code Quality Review

Running headless ralph-loop for code quality review: **$ARGUMENTS**

Execute:
```bash
./.claude/scripts/ralph/code-quality.sh $ARGUMENTS
```

## What This Does

Performs comprehensive code quality analysis with headless execution:

1. **File-by-file analysis** - One file per iteration
2. **Quality metrics** - Complexity, maintainability, performance, correctness
3. **Quality score** - 0-100 rating with breakdown
4. **Hotspot identification** - Files needing most attention

## Arguments

- `<path>`: Path to review (required)
- `--scope <full|complexity|performance|maintainability|correctness>`: Focus (default: full)
- `-n <N>`: Maximum iterations (default: 50)

## Quality Dimensions

| Scope | Focus Areas |
|-------|-------------|
| `full` | All dimensions |
| `complexity` | Cyclomatic complexity, cognitive complexity, nesting |
| `performance` | Algorithms, resource usage, caching, N+1 queries |
| `maintainability` | Naming, docs, modularity, duplication |
| `correctness` | Type safety, error handling, edge cases |

## Examples

```bash
# Full quality review
./.claude/scripts/ralph/code-quality.sh ./internal

# Complexity-focused review
./.claude/scripts/ralph/code-quality.sh ./internal --scope complexity

# With iteration limit
./.claude/scripts/ralph/code-quality.sh ./internal --scope performance -n 30
```

## Quality Score

| Score | Rating |
|-------|--------|
| 90-100 | Excellent |
| 80-89 | Good |
| 70-79 | Acceptable |
| 60-69 | Needs Work |
| <60 | Poor |

## Monitoring

- `activity.md` - Review progress and findings
- Final report includes hotspots and recommendations

## Exit Codes

- `0`: Review complete
- `1`: Max iterations reached
- `2`: Blocked (critical issue needs decision)
- `3`: Stuck (file analysis failed repeatedly)
