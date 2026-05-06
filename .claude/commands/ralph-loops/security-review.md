---
description: Run headless security review
argument-hint: <path> [--scope] [--compliance]
allowed-tools: Bash(.claude/scripts/ralph/security-review.sh:*)
---

# Headless Security Review

Running headless ralph-loop for security review: **$ARGUMENTS**

Execute:
```bash
./.claude/scripts/ralph/security-review.sh $ARGUMENTS
```

## What This Does

Performs comprehensive security review with headless execution:

1. **Domain-based analysis** - Reviews 7 security domains
2. **Compliance mapping** - Maps findings to OWASP/PCI/HIPAA/SOC2
3. **File:line references** - Precise location of each finding
4. **Progress tracking** - Logged to activity.md

## Arguments

- `<path>`: Path to review (required)
- `--scope <full|api|auth|data|deps>`: Focus area (default: full)
- `--compliance <owasp|pci|hipaa|soc2>`: Framework (default: owasp)
- `-n <N>`: Maximum iterations (default: 30)

## Security Domains

| Scope | Primary Domains |
|-------|-----------------|
| `full` | All 7 domains |
| `api` | API Security, Auth, Input Validation |
| `auth` | Auth, Error Handling |
| `data` | Data Protection, Input Validation, Dependencies |
| `deps` | Dependency Security |

## Examples

```bash
# Full security review
./.claude/scripts/ralph/security-review.sh ./internal

# API-focused review
./.claude/scripts/ralph/security-review.sh ./internal --scope api

# PCI compliance review
./.claude/scripts/ralph/security-review.sh ./internal --compliance pci

# Combined options
./.claude/scripts/ralph/security-review.sh ./internal --scope auth --compliance soc2 -n 50
```

## Monitoring

- `activity.md` - Review progress and findings
- Check for CRITICAL findings that may pause the review

## Exit Codes

- `0`: Review complete
- `1`: Max iterations reached
- `2`: Blocked (critical finding needs decision)
- `3`: Stuck (analysis failed repeatedly)
