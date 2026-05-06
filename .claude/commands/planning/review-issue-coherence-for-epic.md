# Review Issue Coherence for Epic

You are verifying that the issues within an epic form a coherent, non-redundant
implementation chain — where each issue builds on its predecessors rather than
reimplementing their work. The epic ID is: $ARGUMENTS

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command produces an advisory report ONLY. Do not modify any existing files.**

---

## Phase 1 — Load All Context

1. Read `planning/$ARGUMENTS/implementation-plan.md` — this defines the
   intended module boundaries and responsibilities
2. Read `planning/$ARGUMENTS/tasks.md` — the full issue set under review
3. Read `planning/$ARGUMENTS/implementation-sequence.md` — the intended
   execution order
4. Run `bd show $ARGUMENTS` to retrieve the epic specification
5. Read `docs/epic-hierarchy-report.md` to identify upstream epics that
   this epic depends on
6. If upstream epics have planning artifacts, read their `tasks.md` to
   understand what they deliver

Do not proceed until you have the full picture of what each issue produces,
what it consumes, and in what order issues execute.

---

## Phase 2 — Build the Delivery Chain

For each issue in implementation-sequence order, document:

1. **What it creates:** new files, classes, functions, fixtures, config fields
2. **What it modifies:** existing files it changes and how
3. **What it consumes from predecessors:** imports, fixtures, interfaces,
   config fields, or patterns established by earlier issues
4. **What it delivers to successors:** exports, interfaces, or infrastructure
   that later issues depend on

This produces a chain: ISSUE-1 delivers X → ISSUE-2 consumes X and delivers Y →
ISSUE-3 consumes Y, etc.

---

## Phase 3 — Detect Coherence Violations

Walk the delivery chain and check for these violation types:

### 3a — Reimplementation

An issue creates something that a predecessor already delivers.

Examples:
- ISSUE-5 defines a `Session` dataclass when ISSUE-2 already created a
  `Session` Pydantic model
- ISSUE-4 adds a `health_check()` function when ISSUE-3 already exports one
- ISSUE-6 creates test fixtures that ISSUE-1 already provides in `conftest.py`

Flag: which issue reimplements, what it reimplements, and which predecessor
already delivers it.

### 3b — Missing Consumption

An issue should use something from a predecessor but its acceptance criteria
and description show no awareness of it.

Examples:
- ISSUE-4 needs a Valkey client but creates its own instead of using
  `ValkeyClientFactory` from ISSUE-3
- ISSUE-5 writes server wiring but doesn't reference the store backend
  selection pattern from ISSUE-4
- ISSUE-6 writes integration tests but doesn't use the fixtures defined
  in ISSUE-1's conftest additions

Flag: which issue misses the consumption, what it should consume, and from
which predecessor.

### 3c — Interface Mismatch

An issue produces an interface that its successor consumes, but the signatures,
types, or contracts don't match.

Examples:
- ISSUE-2 defines `Session.messages` as `list[Message]` but ISSUE-4's
  acceptance criteria expect `list[dict]`
- ISSUE-3 exports `ValkeyClientFactory.create(settings)` but ISSUE-4's
  description calls `create_valkey_client(host, port)`
- ISSUE-1 defines a `ConversationStore` Protocol with `get_history()` returning
  `list[dict]`, but ISSUE-4's implementation plan shows it returning `list[Message]`

Flag: the producing issue, the consuming issue, and the specific mismatch.

### 3d — Acceptance Criteria Duplication

Two issues have acceptance criteria that test the same thing, creating
redundant verification work.

Examples:
- Both ISSUE-2 and ISSUE-4 have "Session() creates a valid instance with
  all defaults"
- Both ISSUE-5 and ISSUE-6 have "backend selection returns correct store type"

Flag: the duplicated criterion, both issues, and which one should own it.

### 3e — Orphaned Deliverables

An issue creates something that no successor issue and no downstream epic
consumes. This may indicate scope creep or a missing issue.

Examples:
- ISSUE-3 implements `health_check()` on the client factory, but no issue
  in this epic or documented downstream epic calls it
- ISSUE-2 adds a `message_index` field to `Message` but no issue in this
  or any dependent epic uses it

Flag: the orphaned deliverable, the producing issue, and whether it maps to
a known downstream epic (in which case it's fine) or is truly orphaned.

### 3f — Cross-Epic Handoff Gaps

This epic depends on a predecessor epic. Check that:
- What this epic's issues consume from the predecessor is explicitly in the
  predecessor's acceptance criteria (not just implied)
- The interface contracts match (same types, same method signatures)

Flag: any assumption about predecessor deliverables that isn't backed by an
explicit acceptance criterion in the predecessor.

---

## Phase 4 — Write Report

Save the report as `planning/$ARGUMENTS/coherence-review.md`:

```markdown
# Issue Coherence Review — [Epic Title]

> **Date:** [today's date]
> **Epic:** $ARGUMENTS
> **Issues reviewed:** [N]
> **Findings:** [N critical, N important, N advisory]

## Executive Summary

[3-5 sentences: overall coherence health, most significant findings]

## Delivery Chain

[For each issue in sequence order, one-line summary of what it delivers
and what it consumes from predecessors]

## Critical Findings

### [Finding title]
- **Type:** [reimplementation | missing-consumption | interface-mismatch |
  ac-duplication | orphaned-deliverable | cross-epic-handoff-gap]
- **Affected:** [ISSUE-N → ISSUE-M]
- **Description:** [what the problem is]
- **Recommended action:** [specific fix — which issue to update and how]

## Important Findings

[Same structure as critical]

## Advisory Findings

[Same structure as critical]

## Coherence Matrix

| Issue | Creates | Consumes From | Delivers To | Violations |
|-------|---------|---------------|-------------|------------|

## Cross-Epic Handoff Summary

| Predecessor Epic | What This Epic Consumes | Explicit in Predecessor AC? | Match? |
|-----------------|------------------------|----------------------------|--------|
```

---

## Severity Classification

- **CRITICAL:** Reimplementation that would cause merge conflicts or type
  errors. Interface mismatch that would break compilation/tests. Missing
  consumption that leads to duplicate, divergent implementations.
- **IMPORTANT:** Acceptance criteria duplication that wastes verification
  effort. Cross-epic handoff gap that could cause integration surprises.
  Missing consumption that leads to suboptimal but functional code.
- **ADVISORY:** Orphaned deliverables that are justified by downstream epics.
  Minor naming inconsistencies between issue descriptions. Parallelisation
  opportunities within the coherence chain.
