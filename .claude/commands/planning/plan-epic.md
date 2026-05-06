# Plan Epic Implementation

You are planning the full implementation of a beads epic. The epic ID is: $ARGUMENTS

**This command produces ONLY the file `planning/$ARGUMENTS/implementation-plan.md`.
No other files may be created, modified, or written — not source code, not tests,
not configuration, not any file outside `planning/`. When the Markdown file is written,
this command is complete. Do NOT enter plan mode. Do NOT implement anything.**

**The plan may contain code sketches (pseudo-code or abbreviated examples) inline
in the Markdown, but these must remain inside the plan document — never written to
disk as actual code.**

---

## Phase 1 — Load Epic Context

1. Run `bd show $ARGUMENTS` to retrieve the full epic specification
2. Read all child issues of the epic if any exist: `bd list --epic $ARGUMENTS`
3. Query the relevant arc42 architecture sections referenced by the epic.
   Use context7 `/adesso-ai/concierge` for targeted queries, or read directly
   from `/docs/arc42/` — whichever is more efficient for the sections needed.
4. Identify all architectural constraints, ADRs, and cross-cutting concerns
   that apply to this epic

Do not proceed until you have a complete understanding of the epic's scope,
constraints, and architectural context.

---

## Phase 2 — Explore the Existing Codebase

1. Identify which existing modules, files, and directories are relevant to
   this epic's implementation
2. Read the key files that will be modified or extended
3. Understand existing patterns, conventions, and interfaces that the
   implementation must follow
4. Identify existing test patterns and coverage infrastructure
5. Check for any existing code that overlaps with or will be impacted by
   this epic

Map out what exists vs. what needs to be created.

---

## Phase 3 — Design the Implementation Plan

Create a comprehensive implementation plan covering:

### Context
- Problem statement: what this epic solves and why
- Desired outcome
- Arc42 references (section numbers, ADR IDs)

### Scope
- In scope: list of acceptance criteria from the epic
- Out of scope: what is explicitly deferred to other epics

### Architecture Constraints
- Table of constraints with specification and source document

### Key Design Decisions
For each decision:
- **Decision N: Title**
- **Decision:** what was decided
- **Rationale:** why this approach wins over alternatives

Include tradeoffs considered.

### Project Structure
- File tree showing which files are NEW, MODIFIED, or EXISTING
- Module dependency graph within the epic
- Clear module boundaries and responsibilities

### Module Specifications
For each new or significantly modified module:
- Purpose and responsibility
- Public API (classes, methods, signatures) with code sketches
- Key design points
- Dependencies on other modules
- Expected test count

### Test Strategy
- Coverage target: **>90% aggregate** for all new code
- Test counts per module (unit + integration)
- Mock patterns and test fixtures (with fixture table)
- Verification approach mapping each epic AC to specific tests
- Quality gates that must pass before closing the epic

### Forward Compatibility
- Analysis of how downstream epics will integrate
- Integration points that must be designed now
- Table: downstream epic, readiness, integration point

### Dependency Changes
- New production and dev dependencies for `pyproject.toml` (if any)

### Verification
- Table mapping each epic acceptance criterion to the tests/evidence
  that verify it

### Key References
- Table of source documents, paths, and relevance

---

## Phase 4 — Write Output

Write the implementation plan to a single file:

### `planning/$ARGUMENTS/implementation-plan.md`

**This is the ONLY file you are allowed to create or modify.**
Do not write any Python, TypeScript, YAML, TOML, shell, or other source files.
All code sketches stay inside this Markdown document.

Use the structure from Phase 3. Follow the format and depth of existing
implementation plans in `planning/` (e.g., `planning/conciergeagent-d5l/`).

Code sketches should be concrete enough to guide implementation but not
so detailed that they become the implementation itself.

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every epic acceptance criterion is addressed in the plan
- [ ] Aggregate test coverage target is >90%
- [ ] Forward compatibility for known downstream epics is addressed
- [ ] All referenced arc42 sections and ADRs are cited
- [ ] Code sketches follow existing codebase patterns and conventions
- [ ] No scope creep beyond what the epic specifies
- [ ] The plan is sufficient for someone to break it into issues independently
