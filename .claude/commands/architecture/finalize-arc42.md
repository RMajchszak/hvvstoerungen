# Finalize Arc42 Documentation

You are performing the final verification and packaging of the arc42 architecture
documentation for commit and review. The scope is: $ARGUMENTS

If no arguments are provided, finalize all sections.
If arguments are section numbers, finalize only those.

**You MUST use ultrathink (extended thinking) for this entire task.**

---

## Phase 1 — Pre-Flight Checks

### 1a — Verify No Blocking Items Remain

1. Read `architecture/questions/open-questions.md` — verify no **blocking**
   questions remain unresolved
2. Read `architecture/arc42-consistency-review.md` — verify no **critical**
   findings remain unaddressed
3. Read `architecture/arc42-gap-remedies.md` — verify no **workflow loops**
   are still pending
4. Search all arc42 section files for `📝 TODO:` and `📝 Pending:` markers

If any blockers remain, stop and report them. The user must resolve them
before finalization.

### 1b — Verify All Sections Exist

Check that all 12 arc42 sections plus the source inventory exist in `docs/arc42/`:
- `00-source-inventory.md`
- `01-introduction-and-goals.md`
- `02-constraints.md`
- `03-context-and-scope.md`
- `04-solution-strategy.md`
- `05-building-block-view.md`
- `06-runtime-view.md`
- `07-deployment-view.md`
- `08-crosscutting-concepts.md`
- `09-architecture-decisions.md`
- `10-quality-requirements.md`
- `11-risks-and-technical-debt.md`
- `12-glossary.md`

Report any missing sections.

---

## Phase 2 — Final Consistency Pass

Perform a rapid final check (not a full multi-agent review — that was done
in `/review-arc42-consistency`):

### 2a — Cross-Reference Integrity

Scan all sections for links to other sections (`](NN-`). Verify each link
target exists and the referenced heading is present.

### 2b — Mermaid Diagram Validation

For each Mermaid code block in all sections:
- Verify the diagram type is valid (`graph`, `sequenceDiagram`, `classDiagram`,
  `flowchart`, `C4Context`, etc.)
- Check for common syntax errors (missing arrows, unclosed brackets)
- Verify component names are consistent with the text that references them

### 2c — Terminology Final Check

Read §12 Glossary. Spot-check 5-10 key terms across sections to verify
consistent usage. Flag any drift found.

### 2d — ADR Alignment

Read §09 Architecture Decisions. Verify that every ADR listed there:
- Exists in `SourceDocuments/adr/`
- Has the same status as recorded in §09
- Is referenced by the arc42 sections it claims to affect

---

## Phase 3 — Update Source Inventory

Update `docs/arc42/00-source-inventory.md`:

1. **Update the Arc42 Coverage Map** to reflect the current state of all
   sections — every section should now show "rich" or "adequate" coverage
2. **Update contradiction status** — contradictions resolved during the
   architecture workflow should be marked as resolved with the resolution
   method
3. **Add a finalization note** with today's date

---

## Phase 4 — Generate Traceability Summary

Add or update a traceability section in `docs/arc42/00-source-inventory.md`:

```markdown
## Traceability Matrix

| Arc42 Section | Source Documents | ADRs | Resolved Questions | context7 Validations |
|--------------|-----------------|------|--------------------|---------------------|
| §01 | [list] | [list] | [list] | [list] |
| ... | ... | ... | ... | ... |

## Architecture Workflow Artifacts

| Artifact | Path | Purpose |
|----------|------|---------|
| Source Inventory | `docs/arc42/00-source-inventory.md` | Source-to-section mapping |
| Open Questions | `architecture/questions/open-questions.md` | Unresolved questions |
| Resolved Questions | `architecture/questions/resolved-questions.md` | Decision log |
| ADR Consistency Review | `architecture/adr-consistency-review.md` | ADR quality report |
| Arc42 Consistency Review | `architecture/arc42-consistency-review.md` | Section quality report |
| Arc42 Gap Remedies | `architecture/arc42-gap-remedies.md` | Applied fixes log |
```

---

## Phase 5 — Report

Output a finalization report to the conversation:

```markdown
## Arc42 Finalization Report

**Date:** [today's date]
**Sections finalized:** [N of 12]

### Section Status

| Section | Status | TODOs | Blocking Items |
|---------|--------|-------|----------------|
| §01 | [complete/has-todos/missing] | [N] | [N] |
| ... | ... | ... | ... |

### Pre-Flight Results

- Blocking questions: [N remaining]
- Critical review findings: [N unaddressed]
- Pending workflow loops: [N]
- TODO markers in sections: [N]

### Cross-Reference Integrity

- Total cross-references checked: [N]
- Broken links: [N]

### Mermaid Diagrams

- Total diagrams: [N]
- Syntax issues: [N]

### Terminology

- Glossary terms: [N]
- Drift issues found: [N]

### Verdict

[READY FOR REVIEW | BLOCKERS REMAIN — list them]
```

### If Verdict is READY FOR REVIEW

Create a git branch and commit:

1. Create branch: `docs/arc42-finalization`
2. Stage all arc42 files and architecture workflow artifacts:
   - `docs/arc42/*.md`
   - `architecture/questions/*.md`
   - `architecture/*.md`
3. Commit: `docs: finalize arc42 architecture documentation`
4. Push and create a PR with the finalization report as the PR body

### If Verdict is BLOCKERS REMAIN

Do NOT create a branch or commit. List the blockers and recommend which
commands to run to resolve them.

---

## Quality Checklist

- [ ] No blocking questions remain open
- [ ] No critical review findings are unaddressed
- [ ] All 12 arc42 sections exist and have content
- [ ] All cross-references between sections are valid
- [ ] All Mermaid diagrams have valid syntax
- [ ] Terminology is consistent with the glossary
- [ ] Source inventory is updated with finalization status
- [ ] Traceability matrix covers all sections
