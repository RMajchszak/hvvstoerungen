# Draft Architecture Decision Records

You are creating or updating ADR documents based on resolved architecture questions
and source document analysis. The scope is: $ARGUMENTS

If no arguments are provided, draft ADRs for all candidates identified in
`architecture/questions/resolved-questions.md`.
If arguments are ADR numbers (e.g., "018 019"), draft only those.
If arguments are question IDs (e.g., "Q-3 Q-7"), draft ADRs for those questions.

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command creates or updates files in `SourceDocuments/adr/` ONLY.
Do NOT modify arc42 sections, source inventory, or other files.**

---

## Phase 1 — Load Context

1. Read `architecture/questions/resolved-questions.md` — identifies which
   questions need ADRs and their resolutions
2. Read `docs/arc42/00-source-inventory.md` — for existing ADR inventory
   and numbering
3. List existing ADRs in `SourceDocuments/adr/` to determine:
   - The next available ADR number
   - Existing ADRs that may need updating (if a resolution modifies an
     existing decision)
   - The format and conventions used by existing ADRs
4. Read 2-3 existing ADRs to understand the project's ADR style and structure
5. Read the source documents cited by the resolved questions

If the resolved questions file doesn't exist, stop and instruct the user to
run `/resolve-architecture-questions` first.

---

## Phase 2 — Validate with context7

For each ADR candidate that involves a technology choice or library capability:

1. Use context7 `resolve-library-id` to find the relevant library
2. Use context7 `query-docs` to verify:
   - The capability described in the decision actually exists
   - The API/configuration described is current (not deprecated)
   - There are no breaking changes in recent versions that affect the decision
3. Record the context7 evidence in the ADR's context section

This prevents writing ADRs based on outdated library assumptions.

---

## Phase 3 — Draft Each ADR

For each ADR to create, write a file following the project's existing format.
Use the naming convention: `SourceDocuments/adr/NNN-<slug>.md`

### ADR Structure

Follow the existing ADR format in this repository. At minimum, include:

```markdown
# ADR-[NNN]: [Title]

**Status:** Proposed
**Date:** [today's date]
**Triggered by:** [Q-N from resolved-questions.md, or source document reference]

## Context

[Why this decision is needed. Reference the original question, the conflicting
sources, or the gap that surfaced during architecture discovery.]

[If context7 was used to validate technology assumptions, cite the findings here.]

## Decision

[The decision, stated clearly and unambiguously.]

## Consequences

### Positive
- [What this enables]

### Negative
- [What this constrains or makes harder]

### Neutral
- [Side effects that are neither positive nor negative]

## Arc42 Impact

| Section | Impact |
|---------|--------|
| §[NN] | [How this decision affects the section] |

## Alternatives Considered

### [Alternative 1]
- **Description:** [what it is]
- **Rejected because:** [why]

### [Alternative 2]
- **Description:** [what it is]
- **Rejected because:** [why]

## References

- [Source documents that informed this decision]
- [context7 library documentation consulted]
- [Related ADRs]
```

### Rules for ADR Drafting

- **New decisions** get new ADR numbers in the existing numbering scheme
- **Modifications to existing decisions** update the existing ADR file:
  - Add a dated amendment section at the bottom
  - Do NOT change the original status without explicit instruction
  - Cross-reference the question that triggered the update
- **Contradictions with accepted ADRs** must NOT be silently resolved —
  if a resolved question contradicts an accepted ADR, draft the new ADR
  as `Status: Proposed` and explicitly state the conflict in the Context
  section. The human must decide whether to supersede.
- Every ADR must cite at least one source document or resolved question
- Technology-specific ADRs must include context7 validation evidence

---

## Phase 4 — Update Cross-References

After writing all ADR files:

1. Check if any existing ADRs reference the newly created ones (or should)
2. Note any cross-reference updates needed but do NOT modify existing ADRs
   unless explicitly updating them per Phase 3
3. Note which arc42 sections need to reference the new ADRs

---

## Phase 5 — Write Summary

Output a summary to the conversation (not a file):

```
## ADRs Drafted

| ADR | Title | Status | Triggered By | Arc42 Sections |
|-----|-------|--------|-------------|----------------|

## Existing ADRs Updated

| ADR | Amendment | Triggered By |
|-----|-----------|-------------|

## Cross-Reference Notes

[Any existing ADRs or arc42 sections that should reference the new ADRs]

## context7 Validations Performed

| ADR | Library | Finding | Confirmed? |
|-----|---------|---------|------------|
```

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every ADR candidate from resolved-questions.md has been addressed
- [ ] ADR numbers follow the existing numbering scheme with no collisions
- [ ] Every ADR cites its triggering question or source document
- [ ] Technology ADRs include context7 validation evidence
- [ ] No new ADR silently contradicts an accepted ADR
- [ ] The ADR format matches the project's existing conventions
- [ ] Alternatives are documented with rejection rationale
- [ ] Arc42 impact is mapped for every ADR
