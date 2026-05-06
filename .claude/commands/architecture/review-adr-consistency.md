# Review ADR Consistency

You are the orchestrator for a multi-agent review of all Architecture Decision
Records. Your job is to verify that ADRs are internally consistent, grounded in
source material, and validated against current library documentation. The scope
is: $ARGUMENTS

If no arguments are provided, review all ADRs in `SourceDocuments/adr/`.
If arguments are ADR numbers (e.g., "016 017 018"), review only those.

**You MUST use ultrathink (extended thinking) for consolidation.**

**This command produces ONLY `architecture/adr-consistency-review.md`.
Do NOT modify any ADR or source files.**

---

## Phase 1 — Discover ADRs and Context

1. List all ADR files in `SourceDocuments/adr/`
2. Read all ADRs in scope
3. Read `docs/arc42/00-source-inventory.md` for source document references
4. Read `architecture/questions/resolved-questions.md` if it exists — for
   context on which ADRs were triggered by question resolution
5. Identify which source documents are cited by the ADRs in scope and
   read them

Do not proceed until you have the full set of ADRs and their cited sources.

---

## Phase 2 — Spawn Specialist Agents

Launch all four agents **in parallel**. Each agent reads the ADRs and relevant
context, then produces structured findings.

### Agent 1 — Contradiction Detector

Read all in-scope ADRs. Check for:

- **Inter-ADR contradictions:** Two ADRs that make conflicting decisions about
  the same topic (e.g., ADR-016 says "shared Keycloak" but a new ADR proposes
  a separate auth server)
- **Supersession gaps:** An ADR references superseding another, but the
  superseded ADR's status wasn't updated (or vice versa)
- **Scope overlaps:** Two ADRs that both claim authority over the same
  architectural concern without acknowledging each other
- **Internal inconsistencies:** An ADR's consequences contradict its own
  decision, or its alternatives section describes the chosen approach as rejected

Output: list of contradictions with exact ADR references and quotes.

### Agent 2 — Source Alignment Checker

For each ADR, verify its claims against the source documents it cites:

- **Unsupported claims:** The ADR states something as fact but the cited source
  doesn't actually say it
- **Misquoted sources:** The ADR paraphrases a source but changes the meaning
- **Uncited sources:** The ADR makes a claim that should be cited but isn't —
  check if any source document supports it
- **Stale references:** The ADR cites a source that has since been superseded
  or updated

Output: list of alignment issues with ADR reference, claim, cited source,
and actual source content.

### Agent 3 — Library Validation Agent (context7)

For each ADR that describes a technology choice, library capability, or
framework behavior:

1. Use context7 `resolve-library-id` to find the library
2. Use context7 `query-docs` to verify:
   - Does the described capability exist in the current version?
   - Is the described API or configuration approach current or deprecated?
   - Are there breaking changes that invalidate the ADR's assumptions?
   - Does the library recommend a different approach for the use case described?
3. Record findings even when the ADR is confirmed — this provides a
   validation timestamp

Output: table of (ADR, library, claim, context7 finding, confirmed/contradicted/unverifiable).

### Agent 4 — Completeness Checker

Check the ADR set for completeness:

- **Resolved questions without ADRs:** Do any resolved questions marked
  "ADR candidate: yes" in `architecture/questions/resolved-questions.md`
  lack a corresponding ADR?
- **Source claims without ADRs:** Are there significant architectural decisions
  in source documents that aren't captured in any ADR?
- **Arc42 section coverage:** For each arc42 section, is there at least one
  ADR that addresses it? Which sections have no ADR coverage?
- **Missing consequences:** Do any ADRs have consequences that should trigger
  additional ADRs (e.g., "we use Keycloak" → should there be an ADR about
  token lifetime policy)?

Output: list of gaps with recommended actions.

---

## Phase 3 — Consolidate Findings

After all four agents have completed:

1. **Collect** all findings
2. **Deduplicate** — a finding raised by multiple agents merges into one entry
   noting all contributing agents
3. **Classify** into severity tiers:
   - **CRITICAL:** ADR contradiction that would lead to conflicting implementations,
     library capability that doesn't exist as described
   - **IMPORTANT:** Source misalignment that weakens rationale, stale library
     assumption (deprecated but functional alternative exists)
   - **ADVISORY:** Missing coverage, minor completeness gaps, cosmetic issues

---

## Phase 4 — Write Report

Save to `architecture/adr-consistency-review.md`:

```markdown
# ADR Consistency Review

> **Date:** [today's date]
> **ADRs reviewed:** [list or count]
> **Findings:** [N critical, N important, N advisory]

## Executive Summary

[3-5 sentences: overall ADR health, most significant findings]

## Critical Findings

### [Finding title]
- **Agents:** [which agents flagged this]
- **Affected ADRs:** [ADR numbers]
- **Description:** [what the problem is]
- **Evidence:** [specific quotes, context7 output, or source references]
- **Recommended action:** [what to do about it]

## Important Findings

[Same structure as critical]

## Advisory Findings

[Same structure as critical]

## Library Validation Matrix

| ADR | Library | Capability Claimed | context7 Finding | Status |
|-----|---------|-------------------|------------------|--------|
| [N] | [name] | [what ADR says] | [what docs say] | [confirmed/contradicted/stale/unverifiable] |

## ADR Coverage Matrix

| Arc42 Section | ADRs | Coverage |
|--------------|------|----------|
| §01 | [list] | [adequate/sparse/none] |
| ... | ... | ... |

## Completeness Gaps

[Missing ADRs, untracked decisions, resolved questions without ADRs]
```

---

## Rules

- **Do not modify** any ADR files. This report is advisory only.
- Every finding must include exact ADR references and evidence — no vague
  "some ADRs have issues" statements.
- context7 validation must be attempted for every technology-specific ADR.
- If no findings exist for a tier, state "No [tier] findings."
