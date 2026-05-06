# Implement Issue

You are about to implement a single Beads issue end-to-end. The issue ID/hash
is provided as the argument: $ARGUMENTS

Work through the following phases strictly in order. Do not proceed to the
next phase if the current phase fails — report the failure and stop.

---

## Phase 1 — Load Issue Context

1. Run `bd show $ARGUMENTS` to retrieve the full issue specification
2. Read the issue's parent epic specification in beads
3. Locate the tasks.md file for this epic and find the corresponding issue entry
4. Read the implementation-sequence.md for this epic to understand where this
   issue sits in the sequence
5. Check that all issues listed as "Blocked by" in this issue's dependency
   section are in status `done` — if any blocker is not done, stop and report
   which blockers are unresolved
6. Query /docs/arc42 or context7 /adesso-ai/concierge for any architectural
   sections or ADRs referenced by this issue that require implementation-level detail

Do not proceed until you have a complete picture of what needs to be implemented
and have confirmed all blockers are resolved.

---

## Phase 2 — Claim and Branch

1. Run `bd update $ARGUMENTS --status in_progress` to claim the issue
2. DoltLab sync happens automatically before `git push` (Claude Code hook) and at session end.
3. Determine the branch name:
   - Format: `feature/[ISSUE-N]-[short-slug-of-issue-title]`
   - Slug: lowercase, hyphens, max 5 words from the title
4. Run `git checkout -b [branch-name]` from the current main/develop branch
5. Confirm the branch was created and you are on it before proceeding

---

## Phase 3 — Implementation

Implement the issue according to its specification. Apply the following rules
throughout:

- Implement only what is specified in this issue — do not expand scope
- After each logical unit of work, verify against the issue's acceptance
  criteria — do not wait until everything is complete to verify
- If you discover that a dependency is missing or an assumption in the issue
  specification is incorrect, stop, document the finding, and report it rather
  than working around it silently
- Commit regularly with meaningful messages using conventional commits:
  `git commit -m "feat(<issue-id>): <what was done and why>"`
- All acceptance criteria must be met and verified before this phase is complete
- Run all relevant tests and confirm they pass
- If the issue includes infrastructure loose gates (E-I.X dependencies),
  implement and verify locally against Docker Compose — do not wait for
  infrastructure deployment

Do not mark the issue done until every acceptance criterion is explicitly verified.

---

## Phase 4 — Verification

Go through every acceptance criterion in the issue specification one by one.
For each criterion:
- State what was implemented to satisfy it
- State how it was verified (test output, manual check, log output, etc.)
- Mark it explicitly as PASSED or FAILED

If any criterion is FAILED, return to Phase 3. Do not proceed to Phase 5
with any unresolved failures.

---

## Phase 5 — Update README Files

After implementation is verified, update project documentation to reflect any
structural changes made during this issue.

### 5a — Root README (`README.md`)

If directories were added or removed at depth 1 or 2, update the directory
overview section in the repository root `README.md` so it stays current. The
overview should list all directories (max-depth 2) with a coarse one-line
description each.

### 5b — Python Project READMEs

Every Python project directory (any directory containing a `pyproject.toml`)
must have a `README.md`. If this issue added, removed, or renamed files or
directories within a Python project, update that project's `README.md`:

- It must contain a tree-view of all files and directories in the project
- Each entry in the tree must have a brief description of what can be found
  there (purpose of the file or directory)
- Keep descriptions concise — one line per entry
- Exclude generated/transient paths (`.venv`, `__pycache__`, `*.egg-info`,
  `.mypy_cache`, `.pytest_cache`, `.ruff_cache`)

If a Python project does not yet have a `README.md`, create one following the
same structure.

If this issue made no structural changes (no files/directories added, removed,
or renamed), skip this phase.

---

## Phase 6 — Sync and Status Update

1. Run `git add . && git commit -m "feat($ARGUMENTS): complete implementation"`
   if there are any uncommitted changes
2. Run `git push --set-upstream origin [branch-name]`
3. Run `bd close $ARGUMENTS --reason "summary"`
4. Run `bd dolt push`

---

## Phase 7 — Pull Request

Create a pull request with the following structure:

**Title:** `feat(ISSUE-N): Full issue title`

**Body:**

---
## What was implemented
[Concise description of what was built, configured, or changed]

## Acceptance criteria verification
[Copy each criterion from the issue and state PASSED with evidence]

## Architectural notes
[Any arc42 constraints or ADRs that influenced implementation decisions]
[Any deviations from the issue specification and why they were necessary]

## Known issues and limitations
[Anything that works but is not ideal, or scope that was intentionally deferred]
[Any assumptions made that the reviewer should be aware of]

## Cross-epic and infrastructure impacts
[Any side effects on other epics or issues observed during implementation]
[Any infrastructure loose gates that need to be resolved for deployment]

## Reviewer checklist
- [ ] Implementation matches issue specification
- [ ] All acceptance criteria verified
- [ ] No scope creep beyond the issue boundary
- [ ] Tests pass
- [ ] No unresolved cross-epic impacts
---

After the PR is created, output the PR URL and a one-line summary of what
was implemented.
