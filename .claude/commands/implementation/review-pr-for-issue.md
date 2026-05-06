# Review PR Against Issue Specification

You are reviewing a pull request to verify that the implementation matches the
issue specification, the planning documents, and cross-dependency contracts.
The issue ID is: $ARGUMENTS

**You MUST use ultrathink (extended thinking) for this entire review.**

**This command produces an advisory review ONLY. Do not modify any code or
close any issues.**

---

## Phase 1 — Load the Specification

1. Run `bd show $ARGUMENTS` to retrieve the full issue specification
2. Identify the parent epic and read its planning artifacts:
   - `planning/<epic-id>/implementation-plan.md` — module specs, design decisions
   - `planning/<epic-id>/tasks.md` — find this issue's entry with full ACs
   - `planning/<epic-id>/implementation-sequence.md` — predecessors and successors
3. If a coherence review exists (`planning/<epic-id>/coherence-review.md`),
   read it for known interface contracts and delivery chain expectations
4. Identify predecessor issues (issues this one is "Blocked by") and read
   their entries in `tasks.md` to understand what they delivered
5. Identify successor issues (issues this one "Blocks") and read their entries
   to understand what they expect to consume

---

## Phase 2 — Load the Implementation

1. Identify the PR for this issue:
   - Check the current branch: `git branch --show-current`
   - Find the PR: `gh pr list --head $(git branch --show-current) --json number,url`
   - If no PR found on current branch, try: `gh pr list --search "$ARGUMENTS" --json number,url`
   - If still not found, ask the user for the PR number
2. Load the PR diff: `gh pr diff <number>`
3. Read all files that were added or modified in the PR — use the full file
   content, not just the diff hunks, to understand the complete implementation
4. If tests were added, read them to understand what is actually being verified

---

## Phase 3 — Acceptance Criteria Verification

Go through **every** acceptance criterion from the issue specification one by
one. For each criterion:

1. **State the criterion** exactly as written
2. **Locate the evidence** in the PR diff — which file(s) and line(s) satisfy it
3. **Verdict:** one of:
   - **PASS** — criterion is fully satisfied with evidence cited
   - **PARTIAL** — criterion is addressed but incompletely (explain what's missing)
   - **FAIL** — criterion is not satisfied (explain what's missing)
   - **UNTESTABLE** — criterion cannot be verified from code alone (e.g.,
     requires runtime testing, deployment, or manual verification)

Do not infer satisfaction — if the code doesn't explicitly address a criterion,
mark it PARTIAL or FAIL even if "it would probably work."

---

## Phase 4 — Design Decision Compliance

Check whether the implementation follows the design decisions from the
`implementation-plan.md`:

1. For each key design decision in the plan that applies to this issue:
   - State the decision
   - Check whether the implementation follows it
   - Flag any deviations with rationale assessment (was the deviation justified
     by a discovery during implementation, or was it an oversight?)

2. Check module boundaries:
   - Does the implementation stay within the files/modules specified in the plan?
   - Are there unexpected new files or modifications to files outside the
     issue's scope?

---

## Phase 5 — Cross-Dependency Contract Verification

### 5a — Predecessor Contracts (does this issue properly consume?)

For each predecessor issue:
- What did the predecessor deliver? (from its ACs and the delivery chain)
- Does this implementation import/use those deliverables?
- Are there reimplementations of things the predecessor already provides?
- Do the interface types match? (same method signatures, same return types,
  same class names)

### 5b — Successor Contracts (does this issue properly deliver?)

For each successor issue:
- What does the successor expect to consume? (from its ACs and description)
- Does this implementation export/provide those deliverables?
- Are the interfaces compatible with what successors expect?
- Are there missing exports, missing fixtures, or missing config fields that
  successors will need?

### 5c — Cross-Epic Contracts

If this issue has cross-epic dependencies:
- Does the implementation match the interface contracts expected by the
  downstream epic?
- Are there implicit assumptions about cross-epic deliverables that aren't
  backed by explicit ACs?

---

## Phase 6 — Code Quality Spot Check

Without doing a full code review, flag any of these if observed:

- **Security concerns:** credentials in code, unsanitized input, missing
  validation at boundaries
- **Test coverage gaps:** code paths with no corresponding test, acceptance
  criteria verified by description but not by an actual test assertion
- **Pattern violations:** code that deviates from established patterns in the
  codebase without justification
- **Scope creep:** implementation that goes beyond what the issue specified —
  extra features, extra config, extra endpoints not in the ACs

---

## Phase 7 — Write Review Report

Output the review directly in the conversation (do not write to a file) using
this structure:

```
## PR Review — [Issue ID]: [Issue Title]

**PR:** #[number] ([url])
**Branch:** [branch name]
**Verdict:** [APPROVED | CHANGES REQUESTED | NEEDS DISCUSSION]

### Acceptance Criteria Results

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | [criterion text] | PASS/PARTIAL/FAIL | [file:line or explanation] |

**Summary:** [N/M criteria passed, N partial, N failed]

### Design Decision Compliance

| Decision | Followed? | Notes |
|----------|-----------|-------|
| [decision title] | Yes/No/Partial | [explanation if deviation] |

### Cross-Dependency Contracts

#### Predecessor Consumption
[For each predecessor: what was expected, what was consumed, any gaps]

#### Successor Delivery
[For each successor: what is expected, what is delivered, any gaps]

#### Cross-Epic
[Any cross-epic contract issues, or "No cross-epic dependencies for this issue"]

### Findings

#### Must Fix (blocks merge)
- [Finding with file:line reference and specific remedy]

#### Should Fix (improves quality)
- [Finding with file:line reference and specific remedy]

#### Consider (optional improvement)
- [Finding with file:line reference and suggestion]

### Suggested Remedies

[For each Must Fix and Should Fix finding, provide a concrete action:
which file to change, what to add/modify/remove, and why]
```

---

## Verdict Rules

- **APPROVED:** All ACs pass, no design decision violations, no cross-dependency
  contract issues, no must-fix findings
- **CHANGES REQUESTED:** Any AC is FAIL, or any must-fix finding exists
- **NEEDS DISCUSSION:** Any AC is PARTIAL with ambiguous resolution, or a design
  decision deviation that may be justified but needs team input
