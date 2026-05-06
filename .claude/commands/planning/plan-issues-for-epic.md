# Plan Issues for Epic

You are breaking down an existing implementation plan into discrete, implementable
issues. The epic ID is: $ARGUMENTS

**You MUST enter plan mode and use ultrathink (extended thinking) for this entire task.**

**This command produces `tasks.md` and `implementation-sequence.md` ONLY.
Do NOT start implementation.**

---

## Phase 1 — Load Context

1. Read `planning/$ARGUMENTS/implementation-plan.md` fully before proceeding.
   This is your primary context source — the architectural decisions, module
   specs, test strategy, and scope are already distilled there.
2. Read `docs/epic-hierarchy-report.md` to identify:
   - Cross-epic dependencies (hard unless explicitly marked as loose)
   - Infrastructure dependencies (always loose — gate deployment, not development)
   - Downstream epics that depend on this one
3. Run `bd show $ARGUMENTS` to retrieve the epic specification from beads
4. Read the existing codebase — identify files that will be modified or created,
   understand existing patterns, conventions, and interfaces

Do not proceed until you have a complete understanding of the implementation
plan, the dependency landscape, and the current codebase state.

---

## Phase 2 — Break Down into Issues

Break the full implementation plan into distinct issues. For each issue,
use this structure:

```
---

## ISSUE-[N]: [Verb-first title]

**Type:** task|feature|bug | **Priority:** P0-P4 | **Effort:** S|M|L

**Description:**
What needs to be done and why it matters in the context of this epic.
Include enough context that a developer can pick this up without reading
the full implementation plan.

**Acceptance Criteria:**
- [ ] Specific, testable criterion
- [ ] No "should work" or "is complete" — every criterion must be verifiable
- [ ] Include expected test counts where applicable

**Dependencies:**
- Blocks: ISSUE-N (reason)
- Blocked by: ISSUE-N (reason)
- Cross-epic: [Epic ID + issue description] if applicable
- Infrastructure: [E-I.X] if deployment or integration testing depends on it
```

### Rules for issue creation:

- **Independence:** If two things can be worked independently, they are two
  issues. Do not collapse related work into a single issue to save space.
- **Completeness:** Every issue must be fully implementable in isolation — a
  developer picking it up should have everything needed without reading the
  full epic or implementation plan.
- **Verifiability:** Every acceptance criterion must be independently verifiable
  by someone who did not write the issue.
- **No vague criteria:** Ban phrases like "should work", "is complete",
  "is properly configured". Every criterion must specify what to check and
  what the expected result is.
- **Dependency types:**
  - Infrastructure dependencies are **loose** — they gate deployment, not development
  - Cross-epic dependencies from `epic-hierarchy-report.md` are **hard** unless
    explicitly marked as loose in that document
- **Coverage:** Every acceptance criterion from the epic must appear in at
  least one issue's acceptance criteria.
- **Test counts:** Include expected test counts in acceptance criteria
  (e.g., "All 12 unit tests pass (`test_session.py`)")

---

## Phase 3 — Define Implementation Sequence

Create the implementation sequence showing:

1. **Phases** — group issues by dependency layers
2. **ASCII diagrams** — show what feeds into what
3. **Exit gates** — what must pass before moving to the next phase
4. **Parallel opportunities** — which issues at each phase have no
   interdependency
5. **Summary timeline** — table with phase, issue count, parallel count,
   test count, cumulative tests
6. **Solo developer optimal order** — numbered list minimizing idle
   dependencies, with brief rationale for ordering choices
7. **Two-developer split** — table showing how work divides across
   critical path vs. parallel modules

---

## Phase 4 — Append Dependency Map to tasks.md

After all issues, append:

```
## Dependency Map

### Critical Path
[ASCII diagram showing the longest dependency chain]

### Parallel Work Opportunities
[List which issues can run concurrently at each phase]

### Cross-Epic Dependencies
[Table: dependency, type (hard/loose), status, impact]

### Infrastructure Loose Gates
[Table: infra epic, what it gates, impact if delayed]
```

---

## Phase 5 — Write Output Files

Write two files:

### `planning/$ARGUMENTS/tasks.md`

Header format:
```
# [Epic Title] — Issue Breakdown

> **Epic:** [Epic ID] — [Epic Title]
> **Source:** `planning/$ARGUMENTS/implementation-plan.md`
> **Total issues:** [N]
> **Estimated tests:** ~[N]
```

Then all issues from Phase 2, then the dependency map from Phase 4.

### `planning/$ARGUMENTS/implementation-sequence.md`

Header format:
```
# [Epic Title]: Implementation Sequence

> **Epic:** [Epic ID] — [Epic Title]
> **Issues:** [N] (see `tasks.md`)
> **Phases:** [N]
```

Then the sequence from Phase 3.

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every epic acceptance criterion is covered by at least one issue
- [ ] Every issue has testable, specific acceptance criteria
- [ ] No circular dependencies between issues
- [ ] Critical path is identified and minimized
- [ ] Aggregate test coverage target is >90%
- [ ] Cross-epic dependencies match `epic-hierarchy-report.md`
- [ ] No issue requires reading the full implementation plan to understand
- [ ] Two things that can be worked independently are never in the same issue
- [ ] The implementation sequence accounts for all dependency edges
