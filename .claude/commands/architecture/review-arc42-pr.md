# Review Arc42 Pull Request

You are reviewing a pull request that contains arc42 architecture documentation
changes. Your job is to verify the documentation against source material, ADRs,
library documentation, and internal consistency. The scope is: $ARGUMENTS

Arguments can be:
- A PR number: `123`
- A branch name: `docs/arc42-finalization`
- Empty: auto-detect from current branch

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command produces an advisory review report ONLY. It does NOT modify
any files or merge the PR.**

---

## Phase 1 — Load PR Context

1. Identify the PR:
   - If argument is a number: `gh pr view $ARGUMENTS`
   - If argument is a branch: `gh pr list --head $ARGUMENTS`
   - If empty: `git branch --show-current` → `gh pr list --head <branch>`
2. Get the diff: `gh pr diff <number>`
3. List all files changed in the PR
4. Read all changed arc42 section files **in full** (not just the diff)
5. Read all added or modified architecture workflow artifacts

---

## Phase 2 — Load Reference Material

1. Read `docs/arc42/00-source-inventory.md` — the source-to-section mapping
2. Read the source documents cited by the changed sections
3. Read all ADRs referenced by the changed sections
4. Read `architecture/questions/resolved-questions.md` — decisions that should
   be reflected in the documentation
5. Read `architecture/arc42-consistency-review.md` and
   `architecture/arc42-gap-remedies.md` if they exist — verify that review
   findings were addressed

---

## Phase 3 — Source Traceability Verification

For each changed arc42 section:

1. **Check every factual claim** in the section:
   - Is it cited? (source document, ADR, resolved question, or context7)
   - If cited, does the source actually support the claim?
   - If uncited, is it derivable from cited sources?
   - If uncited and not derivable, flag as **untraced**
2. **Check resolved questions:**
   - Are all resolved questions that affect this section incorporated?
   - Do the incorporated answers match the resolutions?
3. **Check for omissions:**
   - Are there source claims (from the source inventory) mapped to this
     section that aren't reflected in the content?

---

## Phase 4 — Library Accuracy Verification (context7)

For each technology-specific claim in the changed sections:

1. Use context7 `resolve-library-id` to find the library
2. Use context7 `query-docs` to verify:
   - API descriptions are accurate
   - Configuration details are current
   - Behavioral descriptions match the library's documentation
   - Version-specific features are correctly attributed
3. Record findings for the review report

---

## Phase 5 — Internal Consistency Verification

### 5a — Cross-Section Consistency

For each changed section, check its references to other sections:
- Do referenced sections contain what this section claims they do?
- Are component names, interface descriptions, and flow descriptions
  consistent across sections?
- Do Mermaid diagrams in different sections use the same component names?

### 5b — ADR Alignment

For each ADR referenced in the changed sections:
- Does the arc42 content accurately reflect the ADR's decision?
- Are consequences of the ADR visible in the relevant sections?
- Is the ADR status correctly reported in §09?

### 5c — Terminology

- Are terms used consistently with §12 Glossary?
- Are any new terms introduced without glossary definitions?

---

## Phase 6 — Diagram Verification

For each Mermaid diagram in the changed sections:

1. Verify syntax is valid
2. Verify component/actor names match the text
3. Check that the diagram accurately represents what the text describes
4. Verify labels on arrows/connections are correct

---

## Phase 7 — Write Review Report

```markdown
## Arc42 PR Review

**PR:** #[number] ([url])
**Branch:** [branch name]
**Sections changed:** [list]
**Verdict:** [APPROVED | CHANGES REQUESTED | NEEDS DISCUSSION]

---

### Source Traceability

| Section | Claims Checked | Cited | Derivable | Untraced | Missing Sources |
|---------|---------------|-------|-----------|----------|-----------------|
| §[NN] | [N] | [N] | [N] | [N] | [N] |

**Untraced claims:**
- §[NN]: "[claim]" — no source found
- ...

**Missing source claims:**
- §[NN]: Source "[doc]" states "[claim]" but section doesn't include it
- ...

### Resolved Questions Incorporation

| Question | Expected In | Incorporated? | Accurate? |
|----------|-----------|---------------|-----------|
| Q-[N] | §[NN] | [yes/no] | [yes/partial/no] |

### Library Accuracy (context7)

| Section | Technology | Claim | context7 Finding | Status |
|---------|-----------|-------|------------------|--------|
| §[NN] | [name] | [claim] | [finding] | [confirmed/outdated/incorrect] |

### Cross-Section Consistency

| Section A | Section B | Issue | Severity |
|-----------|-----------|-------|----------|
| §[NN] | §[MM] | [description] | [critical/important/advisory] |

### ADR Alignment

| ADR | Referenced In | Accurately Reflected? | Notes |
|-----|-------------|----------------------|-------|
| [N] | §[NN] | [yes/partial/no] | [if partial/no, what's wrong] |

### Diagrams

| Section | Diagram | Valid Syntax | Accurate | Notes |
|---------|---------|-------------|----------|-------|
| §[NN] | [type] | [yes/no] | [yes/no] | [issues if any] |

### Terminology

- Undefined terms: [list or "none"]
- Inconsistent usage: [list or "none"]

---

### Findings

#### Must Fix (blocks merge)
- [Issue with section:location and specific remedy]

#### Should Fix (improves quality)
- [Issue with section:location and specific remedy]

#### Consider (optional improvement)
- [Suggestion with section:location]

---

### Verdict Rationale

[Explanation of the verdict decision]
```

### Verdict Rules

- **APPROVED:** All claims are traced or derivable, no library inaccuracies,
  no cross-section contradictions, no must-fix findings
- **CHANGES REQUESTED:** Any untraced claim that could mislead implementers,
  any incorrect library description, any cross-section contradiction, any
  must-fix finding
- **NEEDS DISCUSSION:** Ambiguous cases where the reviewer cannot determine
  correctness without additional domain knowledge or stakeholder input

---

## Rules

- **Do not modify** any files. This review is advisory only.
- Every finding must cite the specific section, heading, and ideally the
  claim or line that is problematic.
- context7 verification must be attempted for every technology-specific claim
  in the changed sections.
- Compare against the source material, not your general knowledge — if a
  claim isn't in the sources, flag it as untraced even if you believe it's
  correct.
- Do not approve based on "it looks reasonable" — approval requires positive
  evidence of traceability and accuracy.
