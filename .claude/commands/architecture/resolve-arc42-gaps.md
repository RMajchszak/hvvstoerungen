# Resolve Arc42 Gaps

You are writing concrete remedies for every finding from the arc42 consistency
review. Each remedy must be grounded in source documents, ADRs, resolved
questions, or library documentation. The scope is: $ARGUMENTS

If no arguments are provided, resolve all findings in
`architecture/arc42-consistency-review.md`.
If arguments are finding IDs, resolve only those.

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command produces `architecture/arc42-gap-remedies.md` AND applies
fixes to `docs/arc42/` section files.**

---

## Phase 1 — Load Context

1. Read `architecture/arc42-consistency-review.md` — the findings to resolve
2. Read all arc42 sections affected by findings
3. Read the source documents, ADRs, and resolved questions cited by findings
4. Read `docs/arc42/00-source-inventory.md` for traceability context

If the consistency review doesn't exist, stop and instruct the user to run
`/review-arc42-consistency` first.

---

## Phase 2 — Classify Remedies

For each finding, determine the remedy type:

| Remedy Type | When to Apply |
|------------|---------------|
| **Section fix** | The arc42 section contains an error that can be corrected from existing sources |
| **Section addition** | The arc42 section is missing content that sources provide |
| **Cross-section sync** | Two sections are inconsistent and one must be updated to match the other |
| **New question** | The finding reveals an unresolved architectural question → loops back to `/discover-architecture-questions` |
| **New ADR needed** | The finding reveals a decision that should be formalized → loops back to `/draft-adrs` |
| **Source gap** | The finding can't be resolved because no source covers this topic → document as TODO |
| **context7 update** | The finding is about an outdated library claim → query context7 for current info and update |

---

## Phase 3 — Resolve and Apply

### 3a — Direct Fixes (Section fix, Section addition, Cross-section sync, context7 update)

For findings that can be resolved from available evidence:

1. Identify the exact location in the arc42 section file (file path, line, heading)
2. Draft the corrected or additional content
3. For cross-section sync: determine which section is authoritative (the one
   closer to the source of truth — typically §05 for structure, §09/ADRs for
   decisions, §07 for infrastructure)
4. For context7 updates: query the library documentation and draft updated content
5. **Apply the fix** using the Edit tool on the arc42 section file

### 3b — Workflow Loops (New question, New ADR needed)

For findings that require earlier pipeline steps:

1. Do NOT attempt to resolve these directly
2. Draft the question or ADR recommendation in the remedies document
3. Clearly state which command the user must run next:
   - "Run `/discover-architecture-questions` to add Q-[N]"
   - "Run `/draft-adrs` to create ADR-[NNN]"
4. Mark the corresponding arc42 content as:
   `> 📝 Pending: awaiting resolution of [Q-N / ADR-NNN]`

### 3c — Source Gaps

For findings where no source covers the topic:

1. Add a TODO marker in the arc42 section:
   `> 📝 TODO: [what information is needed, who might provide it]`
2. Record in the remedies document for tracking

---

## Phase 4 — Write Remedies Document

Save to `architecture/arc42-gap-remedies.md`:

```markdown
# Arc42 Gap Remedies

**Generated:** [today's date]
**Findings resolved:** [N of M]
**Findings requiring workflow loops:** [N]
**Source gaps (unresolvable):** [N]

---

## Remedy Summary

| Finding | Severity | Remedy Type | Applied? | Notes |
|---------|----------|-------------|----------|-------|
| [ID] | [level] | [type] | [yes/pending/no] | [brief note] |

---

## Applied Fixes

### [Finding ID]: [Title]

- **Severity:** [Critical / Important / Advisory]
- **Affected section:** §[NN] — `docs/arc42/NN-name.md`
- **Remedy type:** [section-fix / section-addition / cross-section-sync / context7-update]
- **What was changed:** [specific description of the edit]
- **Evidence:** [source citation, ADR reference, or context7 finding]

---

## Workflow Loops Required

These findings cannot be resolved within the arc42 documentation alone.
The user must run additional commands.

### [Finding ID]: [Title]

- **Severity:** [Critical / Important / Advisory]
- **Affected section:** §[NN]
- **Required action:** Run `/[command]` to [what needs to happen]
- **Draft question/ADR:** [if applicable, the draft content]
- **Blocks:** [which section(s) cannot be finalized without this]

---

## Source Gaps

Information that no existing source provides. These remain as TODOs in the
arc42 documentation until the source material is created.

### [Finding ID]: [Title]

- **Affected section:** §[NN]
- **What's missing:** [description]
- **Potential source:** [who or what might provide this information]

---

## Post-Remedy Verification

After applying all fixes, these cross-section relationships should be
re-verified:

| Section A | Section B | Relationship | Status |
|-----------|-----------|-------------|--------|
| §[NN] | §[MM] | [what should be consistent] | [fixed / still needs attention] |
```

---

## Phase 5 — Verify Applied Fixes

After applying all direct fixes:

1. Re-read the modified sections to ensure edits are clean
2. Check that cross-references still work
3. Verify that Mermaid diagram syntax is still valid if diagrams were modified
4. Ensure no new inconsistencies were introduced by the fixes

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every finding from the consistency review has a remedy entry
- [ ] Direct fixes have been applied to the arc42 section files
- [ ] Workflow loops clearly state which command to run next
- [ ] Source gaps are marked as TODOs in the arc42 sections
- [ ] Cross-section fixes are applied consistently to both sides
- [ ] context7 updates include the library documentation evidence
- [ ] No fix introduces a new contradiction with an accepted ADR
- [ ] The post-remedy verification table identifies remaining risks
