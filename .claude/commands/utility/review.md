---
description: Review code changes for quality, patterns, and issues
argument-hint: [file or directory]
allowed-tools: Read, Grep, Glob, Bash
---

# Code Review

This command follows the GEV pattern for structured code review.

## Target
$ARGUMENTS

If no target specified, review recent changes:
!git diff --stat HEAD~1 2>/dev/null || echo "Review entire project"

## Gate Phase

### Prerequisites
- [ ] Target files exist and are readable
- [ ] Git repository initialized (for diff context)

## Execute Phase

Review the code for:

### 1. Correctness
- Logic errors
- Edge cases not handled
- Null/undefined handling
- Error handling completeness

### 2. Code Quality
- Naming clarity
- Function length
- Code duplication
- Complexity

### 3. Security
- Input validation
- Injection vulnerabilities (SQL, XSS, command)
- Sensitive data exposure
- Authentication/authorization issues

### 4. Performance
- Unnecessary computations
- N+1 queries
- Memory leaks
- Inefficient algorithms

### 5. Maintainability
- Documentation
- Test coverage
- Clear interfaces
- Dependency management

## Output Format

For each issue found:

```
### [SEVERITY] Issue Title

**Location:** `file:line`

**Issue:**
Description of the problem

**Suggestion:**
How to fix it

**Code Example:**
```language
// Before
old_code

// After
improved_code
```
```

## Severity Levels

| Level | Criteria |
|-------|----------|
| CRITICAL | Security vulnerability, data loss risk |
| HIGH | Bug, incorrect behavior |
| MEDIUM | Code smell, maintainability issue |
| LOW | Style, minor improvement |

## Verify Phase

### Review Summary
```
## Code Review Summary

### Target
$ARGUMENTS

### Statistics
- Files reviewed: [count]
- Issues found: [count]
  - Critical: [n]
  - High: [n]
  - Medium: [n]
  - Low: [n]

### Verdict
[APPROVED | CHANGES REQUESTED | NEEDS DISCUSSION]

### Key Findings
1. [Most important finding]
2. [Second most important]
3. [Third most important]
```

## Begin

Start by identifying the files to review and reading their contents.
