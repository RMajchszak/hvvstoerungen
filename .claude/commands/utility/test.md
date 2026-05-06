---
description: Run tests with analysis of results
argument-hint: [scope] [--coverage] [--watch]
allowed-tools: Read, Grep, Glob, Bash
---

# Run Tests

This command follows the GEV pattern for test execution.

## Arguments
- Scope: $1 (default: all)
- Coverage: $2 contains "coverage"
- Watch: $2 contains "watch"

## Gate Phase

### Detect Test Framework
![ -f "package.json" ] && grep -q '"test"' package.json && echo "Node (npm/jest/vitest)" || \
 [ -f "pyproject.toml" ] && echo "Python (pytest)" || \
 [ -f "Cargo.toml" ] && echo "Rust (cargo test)" || \
 [ -f "go.mod" ] && echo "Go (go test)" || \
 echo "Unknown - configure in toolchain.yaml"

### Verify Test Files Exist
!find . -name "*test*" -o -name "*spec*" 2>/dev/null | head -5 || echo "No test files found"

## Execute Phase

### Run Tests

Based on detected framework:

**Node.js:**
```bash
npm test -- $1
# or for coverage:
npm test -- --coverage $1
```

**Python:**
```bash
pytest $1
# or for coverage:
pytest --cov=$1
```

**Rust:**
```bash
cargo test $1
```

**Go:**
```bash
go test ./...
# or for coverage:
go test -cover ./...
```

## Verify Phase

### Parse Results

Extract from test output:
- Total tests
- Passed
- Failed
- Skipped
- Duration

### For Failures

Provide for each failing test:
- Test name
- File and line
- Expected vs actual
- Stack trace (abbreviated)
- Suggested fix

## Output Format

```
## Test Results

### Summary
| Metric | Value |
|--------|-------|
| Total | [n] |
| Passed | [n] |
| Failed | [n] |
| Skipped | [n] |
| Duration | [time] |

### Status: PASS / FAIL

### Coverage (if requested)
[Coverage percentage and uncovered areas]

### Failures (if any)

#### Test: [test name]
**File:** `path/to/test:line`

**Expected:**
```
expected value
```

**Actual:**
```
actual value
```

**Suggested Fix:**
[Analysis of why it failed and how to fix]

---

### Next Steps
[Recommendations based on results]
```

## Begin

First, detect the test framework, then run the tests and analyze results.
