# Create Issues in Beads for Epic

You are creating beads issues from the planning documents. Each issue defined
in `tasks.md` must be created in beads with correct parent, dependencies, and
cross-epic relationships. The epic ID is: $ARGUMENTS

**You MUST use ultrathink (extended thinking) for this task.**

**CRITICAL: The beads issue ID suffix (the `.N` part of `<epic-id>.N`) MUST
match the ISSUE-N number in tasks.md. If beads assigns a different suffix,
you must update tasks.md and implementation-sequence.md to reflect the actual
beads ID.**

---

## Phase 1 — Load Planning Documents

1. Run `bd show $ARGUMENTS` to confirm the epic exists and get its full ID
2. Read `planning/$ARGUMENTS/tasks.md` — this defines all issues to create
3. Read `planning/$ARGUMENTS/implementation-sequence.md` — this defines
   dependency order and cross-epic relationships
4. Read `planning/$ARGUMENTS/implementation-plan.md` if it exists — for
   additional context on priorities
5. Check if any issues already exist under this epic:
   `bd list --parent $ARGUMENTS --all`
   If issues already exist, report which ones and ask the user whether to
   skip existing issues or abort entirely. Do NOT create duplicates.
6. Read `docs/epic-hierarchy-report.md` to identify cross-epic dependency
   epic IDs

---

## Phase 2 — Map Cross-Epic Dependencies

Before creating issues, resolve all cross-epic dependency references to
actual beads issue IDs:

1. For each cross-epic dependency mentioned in `tasks.md` (e.g.,
   "Blocked by: E-1.1/ISSUE-6"), find the actual beads issue ID by:
   - Identifying the epic's beads ID from `docs/epic-hierarchy-report.md`
     or by searching beads: `bd search "<epic title>"`
   - Listing that epic's issues: `bd list --parent <epic-beads-id> --all`
   - Matching the ISSUE-N number to the `.N` suffix
   - Verifying the title matches

2. Build a lookup table:
   ```
   E-1.1/ISSUE-6 → conciergeagent-69r.6
   E-1.2/ISSUE-5 → conciergeagent-yvu.5
   ```

3. If a cross-epic dependency references an issue that doesn't exist in
   beads yet, note it as "pending" — the dependency will be added after
   that epic's issues are created.

---

## Phase 3 — Create Issues Sequentially

Create issues **one at a time, in ISSUE-N order** (ISSUE-1 first, then
ISSUE-2, etc.). This ensures parent-child ordering is correct.

For each issue in `tasks.md`:

### 3a — Create the Issue

```bash
bd create \
  --parent $ARGUMENTS \
  --title "<issue title from tasks.md>" \
  --description "<full description from tasks.md>" \
  --type <type from tasks.md: task|feature|bug> \
  --priority <priority from tasks.md: 0-4> \
  --acceptance "<acceptance criteria as markdown checklist>"
```

### 3b — Verify the Issue ID

After creation, beads will output the new issue ID (e.g., `conciergeagent-xxx.3`).

**Check that the `.N` suffix matches the ISSUE-N number from tasks.md.**

- If `ISSUE-3` was created as `conciergeagent-xxx.3` → correct, proceed
- If `ISSUE-3` was created as `conciergeagent-xxx.7` → **mismatch detected**
  Record this for Phase 5 (markdown update)

### 3c — Add Intra-Epic Dependencies

For each "Blocked by: ISSUE-N" entry in this issue's dependencies:

```bash
bd dep add <this-issue-id> <blocker-issue-id>
```

This means: `<this-issue>` depends on `<blocker-issue>` (blocker blocks this).

Example: If ISSUE-4 is blocked by ISSUE-2 and ISSUE-3:
```bash
bd dep add conciergeagent-xxx.4 conciergeagent-xxx.2
bd dep add conciergeagent-xxx.4 conciergeagent-xxx.3
```

### 3d — Add Cross-Epic Dependencies

For each cross-epic dependency resolved in Phase 2:

```bash
bd dep add <this-issue-id> <cross-epic-issue-id>
```

If the cross-epic issue doesn't exist yet (marked "pending" in Phase 2),
skip and note it for the user.

---

## Phase 4 — Verify All Dependencies

After all issues are created:

1. List all issues: `bd list --parent $ARGUMENTS`
2. For each issue, verify dependencies: `bd dep list <issue-id>`
3. Check for missing dependencies by comparing against `tasks.md`
4. Run `bd dep cycles` to verify no circular dependencies were introduced
5. Run `bd blocked` to see which issues are correctly blocked

---

## Phase 5 — Update Markdown if IDs Differ

If any beads issue ID suffix does NOT match the ISSUE-N number from
`tasks.md`:

1. Update `planning/$ARGUMENTS/tasks.md`:
   - Change all references from `ISSUE-N` to match the actual beads suffix
   - Update the dependency map section
   - Add a note at the top: `> **Beads ID mapping:** ISSUE-N references
     correspond to beads issue suffix .N (e.g., ISSUE-3 = $ARGUMENTS.3)`

2. Update `planning/$ARGUMENTS/implementation-sequence.md`:
   - Change all ISSUE-N references to match actual beads suffixes

3. If other epics' `tasks.md` reference this epic's issues in their
   cross-epic dependencies, note these for the user (do NOT modify
   other epics' files without explicit instruction).

---

## Phase 6 — Report Summary

Output a summary showing:

```
## Issues Created

| Beads ID | ISSUE-N | Title | Priority | Dependencies |
|----------|---------|-------|----------|-------------|

## Cross-Epic Dependencies Set

| From | To | Type |
|------|----|------|

## Pending Cross-Epic Dependencies

[Dependencies that couldn't be set because the target issue doesn't exist yet.
These need to be added after the target epic's issues are created.]

## ID Mismatches (if any)

[List any cases where the beads suffix didn't match ISSUE-N, and what was
updated in the markdown files.]
```

---

## Rules

- Create issues **one at a time** in order — do not batch or parallelize
  creation, as beads assigns sequential IDs
- Never create an issue if one with the same title already exists under
  this epic
- Dependencies use `bd dep add <dependent> <dependency>` — the first
  argument depends on the second
- Infrastructure dependencies (E-I.x) are noted in the issue description
  but NOT set as beads dependencies (they are loose gates)
- If `bd create` fails, report the error and stop — do not continue creating
  subsequent issues that may depend on the failed one
