# Gate-Execute-Verify (GEV) Pattern

The standard pattern for mid-level workflow commands.

## Pattern Structure

```
┌─────────────────────────────────────────┐
│                 GATE                     │
│  ├── Check prerequisites                 │
│  ├── Validate state                      │
│  └── Confirm permissions                 │
│                                          │
│  If ANY gate fails → ABORT with message  │
└────────────────┬────────────────────────┘
                 │
                 ▼ (all gates pass)
┌─────────────────────────────────────────┐
│               EXECUTE                    │
│  ├── Create backup/rollback point        │
│  ├── Perform core operation              │
│  └── Handle errors with recovery         │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│               VERIFY                     │
│  ├── Check syntax/compilation            │
│  ├── Run functional validation           │
│  └── Verify no unintended changes        │
│                                          │
│  Output: VERIFIED or UNVERIFIED          │
└─────────────────────────────────────────┘
```

## Gate Phase

### Environment Gates
```
[ ] Project root is valid
[ ] Required tools available
[ ] No conflicting operations
```

### Target Gates
```
[ ] Target exists
[ ] Target is accessible
[ ] No lock files blocking
```

### Dependency Gates
```
[ ] Required files present
[ ] Dependencies installed
```

### Gate Output Format
```markdown
## GATE CHECK

| Gate | Status | Details |
|------|--------|---------|
| Environment | PASS/FAIL | [reason] |
| Target | PASS/FAIL | [reason] |
| Dependencies | PASS/FAIL | [reason] |

**Overall: PROCEED / ABORT**
```

## Execute Phase

1. **Prepare**
   - Create rollback point if destructive
   - Load context from parent command

2. **Execute**
   - Invoke micro commands
   - Call subagents as needed
   - Capture all outputs

3. **Handle Errors**
   - Classify error type
   - Attempt recovery if safe
   - Rollback if recovery fails

## Verify Phase

### Verification Checks
- Syntax/compilation valid
- Functional behavior correct
- No regressions introduced

### Verification Output
```markdown
## VERIFICATION

| Check | Status | Output |
|-------|--------|--------|
| Syntax | PASS/FAIL | [summary] |
| Functional | PASS/FAIL | [summary] |

**Overall: VERIFIED / UNVERIFIED**
```

## Error Recovery Matrix

| Error Type | Recovery Action | Fallback |
|------------|-----------------|----------|
| File not found | Search with Glob | BLOCKED |
| Permission denied | Check ownership | BLOCKED |
| Syntax error | Show and suggest fix | Manual |
| Test failure | Show details | UNVERIFIED |
| Tool missing | Suggest install | BLOCKED |

## Usage

Reference in commands:
```markdown
This command follows the GEV pattern.
See: @.claude/patterns/gev.md
```
