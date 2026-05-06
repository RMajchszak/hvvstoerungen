---
description: Run headless research to requirements
argument-hint: <folder-path> [--output]
allowed-tools: Bash(.claude/scripts/ralph/research.sh:*)
---

# Headless Research to Requirements

Running headless ralph-loop for requirements extraction: **$ARGUMENTS**

Execute:
```bash
./.claude/scripts/ralph/research.sh $ARGUMENTS
```

## What This Does

Processes documents and synthesizes consolidated requirements:

1. **Document processing** - One document per iteration
2. **Requirement extraction** - Identifies functional, non-functional, constraints
3. **Deduplication** - Merges similar requirements across sources
4. **Traceability** - Maps each requirement to source document

## Arguments

- `<folder-path>`: Path to folder with documents (required)
- `--output <path>`: Output file path (default: ./requirements.md)
- `-n <N>`: Maximum iterations (default: 30)

## Supported Formats

- Markdown (`.md`)
- Plain text (`.txt`)
- PDF (`.pdf`)
- Word (`.docx`)

## Examples

```bash
# Process requirements folder
./.claude/scripts/ralph/research.sh ./docs/requirements

# Specify output path
./.claude/scripts/ralph/research.sh ./docs/research --output ./output/requirements.md

# With iteration limit
./.claude/scripts/ralph/research.sh ./input --output ./specs/requirements.md -n 50
```

## Output Document Structure

1. Executive Summary
2. Functional Requirements (FR-XXX)
3. Non-Functional Requirements (NFR-XXX)
4. Constraints (CON-XXX)
5. Assumptions (ASM-XXX)
6. Traceability Matrix
7. Open Questions
8. Source Documents

## Conflict Detection

The process will pause (BLOCKED) if it detects:
- Contradictory requirements
- Critical ambiguity
- Scope conflicts
- Priority conflicts

## Monitoring

- `activity.md` - Processing progress
- Check for conflicts that may pause processing

## Exit Codes

- `0`: Requirements complete
- `1`: Max iterations reached
- `2`: Blocked (requirements conflict detected)
- `3`: Stuck (document unreadable)
