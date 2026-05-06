# Apply Planning Remedies for Epic

You are applying the resolved planning remedies to the issue breakdown. Every
remedy in `planning-gap-remedies.md` must be reflected in the updated `tasks.md`
and `implementation-sequence.md`. The epic ID is: $ARGUMENTS

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command modifies `tasks.md` and `implementation-sequence.md` in place.
It does NOT create beads issues or start implementation.**

---

## Phase 1 — Load All Artifacts

Read all of the following before making any changes:

### 1a — Remedies Document (primary input)

Read `planning/$ARGUMENTS/planning-gap-remedies.md`. This is your authoritative
source of changes to apply. Every remedy entry in this document must result in
a concrete edit to `tasks.md` and/or `implementation-sequence.md`.

If this file does not exist, stop and inform the user that they need to run
`/resolve-planning-gaps-for-epic $ARGUMENTS` first.

### 1b — Review Reports (for cross-reference)

Read the review reports that produced the remedies:
- `docs/planning-review-report.md` (arc42 alignment findings)
- `planning/$ARGUMENTS/coherence-review.md` (inter-issue coherence findings)

Use these to verify that every finding has a corresponding remedy and that no
finding was missed.

### 1c — Current Planning Documents (targets for modification)

Read the files you will modify:
- `planning/$ARGUMENTS/tasks.md`
- `planning/$ARGUMENTS/implementation-sequence.md`

### 1d — Implementation Plan (for context)

Read `planning/$ARGUMENTS/implementation-plan.md` to understand the
architectural context behind each issue.

### 1e — Decision Log

Extract the decision log from the remedies document. These resolved
architectural questions inform how to interpret and apply remedies.

---

## Phase 2 — Build Change Plan

Before editing any file, build a complete change plan by categorizing every
remedy into one of these action types:

### Modify Existing Issue
- Which ISSUE-N to modify
- Exact acceptance criteria to add, change, or remove
- Description changes if needed
- Dependency changes if needed

### Add New Issue
- Where in the sequence (after which ISSUE-N)
- Full issue specification following the `tasks.md` format:
  ```
  ## ISSUE-[N]: [Verb-first title]

  **Type:** task|feature|bug | **Priority:** P0-P4 | **Effort:** S|M|L

  **Description:**
  [Context and rationale]

  **Acceptance Criteria:**
  - [ ] [Specific, testable criterion]

  **Dependencies:**
  - Blocks: [...]
  - Blocked by: [...]
  ```

### Modify Sequence
- Which phase in `implementation-sequence.md` changes
- New dependency edges or reordering

### No Action Required
- Remedies of type "Accept as tech debt" or "New ADR" that don't change
  `tasks.md` — note these for the change log but take no edit action

Present the change plan to the user and ask for approval before proceeding
to Phase 3.

---

## Phase 3 — Apply Changes to tasks.md

Apply all approved changes to `planning/$ARGUMENTS/tasks.md`:

### 3a — Modify Existing Issues

For each "Modify existing issue" remedy:
- Edit the acceptance criteria exactly as specified in the remedy
- Update the description if the remedy calls for it
- Preserve all existing content that is not affected by the remedy
- Add a trailing comment after each modified criterion referencing the finding:
  `<!-- Remedy: [Finding-ID] -->`

### 3b — Insert New Issues

For each "Add new issue" remedy:
- Assign the next available ISSUE-N number (do not renumber existing issues)
- Write the full issue specification in the standard format
- Add dependencies as specified in the remedy
- Update the "Blocks:" field of any issue this new one unblocks
- Add a note in the description: `> Added by remedy [Finding-ID]`

### 3c — Update Dependency Map

After all issue changes:
- Rebuild the dependency map at the bottom of `tasks.md`
- Update the critical path if new dependencies changed it
- Update parallel work opportunities
- Update cross-epic dependencies if any were added
- Update the header metadata (total issues, estimated tests)

---

## Phase 4 — Apply Changes to implementation-sequence.md

Update `planning/$ARGUMENTS/implementation-sequence.md` to reflect:

1. **New issues** — place them in the correct phase based on their dependencies
2. **Changed dependencies** — reorder within phases if needed
3. **Phase changes** — split or merge phases if the remedy requires it
4. **Exit gates** — update phase exit gates to include new acceptance criteria
5. **Solo developer optimal order** — update to account for new issues
6. **Two-developer split** — update if parallelism changed
7. **Summary timeline** — update issue counts and test counts

---

## Phase 5 — Validate Changes

Before finalizing, verify:

- [ ] Every remedy in `planning-gap-remedies.md` has been applied or explicitly
      noted as "no action required" (with reason)
- [ ] No existing ISSUE-N was renumbered — new issues use the next available number
- [ ] All new issues follow the standard format (verb-first title, testable ACs,
      explicit dependencies)
- [ ] No circular dependencies were introduced
- [ ] The dependency map is consistent with the individual issue dependency fields
- [ ] The implementation sequence accounts for all new dependency edges
- [ ] The header metadata (total issues, estimated tests) is updated
- [ ] Every finding from both review reports has a corresponding remedy that was
      applied (cross-reference against the review reports)

---

## Phase 6 — Write Change Log

Append a change log section at the bottom of `tasks.md`:

```markdown
---

## Change Log

### Remedies Applied — [date]

**Source:** `planning/$ARGUMENTS/planning-gap-remedies.md`

| Finding ID | Remedy Type | Action Taken |
|-----------|-------------|--------------|
| [ID]      | [type]      | [brief description of what changed] |

**Issues added:** [count] (ISSUE-N through ISSUE-M)
**Issues modified:** [count] ([list])
**Sequence changes:** [yes/no — brief description if yes]
```

---

## Rules

- NEVER renumber existing issues — new issues get the next available number
- NEVER remove existing acceptance criteria unless the remedy explicitly says to
- NEVER contradict the arc42 or ADRs — if a remedy seems to conflict, flag it
  and ask the user
- Preserve the exact format and style of the existing `tasks.md`
- Every change must be traceable to a specific finding ID in the remedies document
- If a remedy is ambiguous, ask the user rather than guessing
- Present the change plan (Phase 2) for user approval before editing files
