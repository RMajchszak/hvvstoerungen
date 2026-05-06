---
description: Safely refactor code while preserving behavior
argument-hint: <target> [--scope <area>]
allowed-tools: Read, Edit, Grep, Glob, Bash
---

# Refactor

Safely refactor code: **$ARGUMENTS**

This command follows the GEV pattern with strict behavior preservation.

## Gate Phase

### Prerequisites
Before refactoring, verify:

1. **Tests Exist**: Behavior verification requires tests
!find . -name "*test*" -o -name "*spec*" 2>/dev/null | head -3

2. **Tests Pass**: Baseline must be green
!npm test 2>&1 | tail -5 || pytest 2>&1 | tail -5 || echo "Run tests first"

3. **Clean Working Directory**: No uncommitted changes
!git status --short

### Gate Output
```
## GATE CHECK

| Gate | Status | Details |
|------|--------|---------|
| Tests exist | PASS/FAIL | [count] test files |
| Tests pass | PASS/FAIL | [result] |
| Clean state | PASS/FAIL | [uncommitted count] |

**Overall: PROCEED / ABORT**
```

If tests don't exist or fail, ABORT with message to fix tests first.

## Execute Phase

### Refactoring Types

**Structural Refactoring:**
- Extract function/method
- Inline function/variable
- Move to new file
- Rename symbol

**Code Quality:**
- Remove duplication
- Simplify conditionals
- Improve naming
- Reduce complexity

### Execution Protocol

1. **Identify** the refactoring scope
2. **Plan** the changes
3. **Execute** one change at a time
4. **Verify** tests still pass after EACH change
5. **Rollback** if tests fail

### Safety Rules

- Make ONE logical change at a time
- Run tests after each change
- If tests fail, immediately revert
- Do NOT change behavior
- Do NOT add features

## Verify Phase

### After Refactoring

1. Run full test suite
2. Compare behavior (same inputs → same outputs)
3. Check for regressions

### Output Format

```
## Refactoring Complete

### Target
$ARGUMENTS

### Changes Made
| Change | Type | Files |
|--------|------|-------|
| [description] | extract/rename/move | [files] |

### Verification
- Tests: PASS (N tests)
- Behavior: PRESERVED

### Summary
- Files modified: N
- Lines added: +N
- Lines removed: -N
- Complexity change: [reduced/unchanged]
```

## Error Handling

### If Tests Fail After Change

```
## VERIFICATION FAILED

### Change That Broke Tests
[Description of change]

### Failing Tests
[List of failures]

### Action Taken
Reverted change: `git checkout -- [files]`

### Recommendation
[How to proceed]
```

## Begin

Start by verifying the gate conditions (tests exist and pass).
