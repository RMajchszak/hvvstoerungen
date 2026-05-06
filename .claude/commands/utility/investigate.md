---
description: Investigate a topic, bug, or codebase area and report findings
argument-hint: <topic or question>
allowed-tools: Read, Grep, Glob, Bash, WebSearch
---

# Investigate

Research and analyze: **$ARGUMENTS**

This command follows the Investigation pattern for systematic research.

## Investigation Protocol

```
┌─────────────────────────────────────────┐
│  1. SCOPE DEFINITION                    │
│  └── What exactly are we investigating? │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  2. EVIDENCE GATHERING                  │
│  ├── Search codebase                    │
│  ├── Read relevant files                │
│  └── Trace execution flow               │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  3. PATTERN RECOGNITION                 │
│  ├── Identify common themes             │
│  ├── Find anomalies                     │
│  └── Map relationships                  │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  4. STRUCTURED OUTPUT                   │
│  ├── Summary of findings                │
│  ├── Evidence citations                 │
│  └── Recommendations                    │
└─────────────────────────────────────────┘
```

## Phase 1: Scope Definition

Clarify the investigation target:
- What is the question/topic?
- What constitutes a complete answer?
- What areas are out of scope?

Topic: $ARGUMENTS

## Phase 2: Evidence Gathering

### Codebase Search
Use Glob and Grep to find relevant files:
- File patterns related to topic
- Code patterns related to topic
- Configuration related to topic

### File Analysis
Read key files identified:
- Entry points
- Core logic
- Configuration
- Tests (for behavior documentation)

### Execution Tracing
If investigating behavior:
- Identify entry point
- Trace call flow
- Note decision points

## Phase 3: Pattern Recognition

Analyze gathered evidence:
- What patterns emerge?
- What's consistent vs inconsistent?
- What's well-documented vs unclear?
- What are the dependencies?

## Phase 4: Report

## Investigation Report: $ARGUMENTS

### Executive Summary
[1-2 sentence answer to the investigation question]

### Scope
**Question:** $ARGUMENTS
**Boundaries:** [What was in/out of scope]

### Methodology
[How the investigation was conducted]

### Findings

#### Finding 1: [Title]
**Evidence:** `file:line` - [quote or description]
**Significance:** [Why this matters]

#### Finding 2: [Title]
**Evidence:** `file:line` - [quote or description]
**Significance:** [Why this matters]

[Continue for all significant findings]

### Architecture/Flow Diagram
```
[ASCII diagram if helpful]
```

### Key Files
| File | Purpose | Relevance |
|------|---------|-----------|
| `path` | [what it does] | [why it matters for this topic] |

### Conclusions
1. [Main conclusion]
2. [Secondary conclusion]
3. [Additional insights]

### Recommendations
Based on findings:
1. [Actionable recommendation]
2. [Actionable recommendation]

### Open Questions
[Anything that couldn't be determined]

### References
- `file:line` - [description]
- `file:line` - [description]

## Begin

Start by clarifying the scope of the investigation, then systematically gather evidence.
