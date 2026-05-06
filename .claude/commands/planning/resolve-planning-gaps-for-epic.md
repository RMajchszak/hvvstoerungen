# Resolve Planning Gaps for Epic

You are tasked with researching and writing concrete remedies for every finding
identified by the planning review commands. Your remedies must be grounded
**exclusively** in the arc42 architecture documentation and ADRs in this
repository — do not invent architectural decisions that aren't already documented.

The epic ID (or "all" for cross-epic review) is: $ARGUMENTS

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command produces a remedies document ONLY. It does NOT modify any
existing tasks.md, implementation-sequence.md, or implementation-plan.md files.**

---

## Phase 1 — Gather Context

Read all of the following before writing anything:

### 1a — Identify the Review Reports

Locate the review reports that contain findings to resolve:
- `docs/planning-review-report.md` (from `/review-arc42-alignment-for-issues-for-epic`)
- `planning/<epic-id>/coherence-review.md` (from `/review-issue-coherence-for-epic`)

If `$ARGUMENTS` is a specific epic ID, read only reports relevant to that epic.
If `$ARGUMENTS` is "all", read all available review reports.

If no review reports exist, stop and inform the user that they need to run
`/review-arc42-alignment-for-issues-for-epic` and/or
`/review-issue-coherence-for-epic` first.

### 1b — Read the Arc42 Architecture

Query the arc42 sections referenced by the findings in the review reports.
Use context7 `/adesso-ai/concierge` for targeted queries, or read directly
from `/docs/arc42/`. Focus on the specific sections cited by each finding —
do not do a generic full-document scan.

Read all ADRs referenced by the findings.

### 1c — Read the Planning Artifacts

For each epic in scope, read:
- `planning/<epic-id>/implementation-plan.md`
- `planning/<epic-id>/tasks.md`
- `planning/<epic-id>/implementation-sequence.md`

### 1d — Read the Epic Hierarchy

Read `docs/epic-hierarchy-report.md` to understand cross-epic dependencies
and the full dependency landscape.

### 1e — Read Existing Code

Locate and read any `pyproject.toml` files and key source files that are
relevant to the findings. Use `find` or glob to locate them if paths are
not obvious.

---

## Phase 2 — Resolve Architectural Ambiguities

Before writing remedies, resolve any architectural questions that multiple
findings depend on. For each such question:

1. State the question clearly
2. Identify the options
3. Check what the arc42 and ADRs say (with specific quotes/references)
4. State which option the architecture supports, or state that it's ambiguous
5. If ambiguous, recommend an ADR to resolve it

These decisions govern downstream remedies — get them right first.

---

## Phase 3 — Write Remedies

For **every** finding in the review reports, provide:

```markdown
## [Finding ID]: [Finding Title from Report]

**Severity:** Critical | Important | Advisory
**Affected Issues:** [list from report]
**Arc42/ADR Basis:** [specific sections and ADR numbers, with brief relevant
quotes or paraphrases]

### Diagnosis
[1-3 sentences: what exactly is wrong and why it matters, grounded in what
the arc42 says]

### Recommended Remedy
[Concrete action items. For each one specify:]
- Which epic and issue number to modify (or "new issue in E-X.Y")
- What to add, change, or remove — be specific (e.g., "add field
  `message_index: int | None = None` to the Message model in E-1.4/ISSUE-2")
- If the remedy requires a new issue, draft the issue title and 3-5
  acceptance criteria
- If the remedy is "accept as technical debt," specify the ADR amendment
  text and which future epic resolves it

### Impact on Sequence
[Does this change the implementation sequence or cross-epic gates? If yes,
describe how.]
```

### Remedy Constraints

- Do NOT propose architectural changes beyond what the arc42 and ADRs already
  specify. If the arc42 is silent on something, say so and recommend an ADR.
- Do NOT remove or renumber existing issues. Only add new issues or modify
  acceptance criteria of existing ones.
- When two findings have the same root cause, cross-reference them and avoid
  contradictory remedies.
- Every remedy must be traceable to an arc42 section or ADR.

---

## Phase 4 — Add Decision Log and Summary

At the top of the output file, add:

### Decision Log

For each unresolved architectural question from the review reports:
- The question
- Your recommended resolution based on the arc42
- Your confidence level (high / medium / low)
- The arc42/ADR evidence

### Summary Table

| Finding ID | Severity | Remedy Type | Effort |
|-----------|----------|-------------|--------|

Where Remedy Type is one of:
- **Modify existing issue** — change ACs or description of an existing issue
- **New issue** — add a new issue to an epic
- **ADR amendment** — propose a change to an existing ADR
- **New ADR** — propose a new ADR for an undocumented decision
- **Sequence change** — modify the implementation sequence
- **Accept as tech debt** — defer with explicit tracking

---

## Phase 5 — Write Output

Save the remedies document to:
`planning/<epic-id>/planning-gap-remedies.md`

If `$ARGUMENTS` is "all" (cross-epic review), save to:
`docs/planning-gap-remedies.md`

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every finding from every review report has a remedy entry
- [ ] No remedy contradicts an arc42 section or ADR
- [ ] No remedy removes or renumbers existing issues
- [ ] Findings with shared root causes are cross-referenced
- [ ] Every "new issue" remedy has a title and 3-5 acceptance criteria
- [ ] Every "modify existing issue" remedy specifies exact changes
- [ ] The decision log covers all unresolved architectural questions
- [ ] Impact on sequence is assessed for every non-advisory finding
