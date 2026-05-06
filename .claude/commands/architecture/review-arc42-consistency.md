# Review Arc42 Consistency

You are the orchestrator for a multi-agent review of the arc42 architecture
documentation. Your job is to verify cross-section consistency, source traceability,
library accuracy, and terminology coherence. The scope is: $ARGUMENTS

If no arguments are provided, review all sections in `docs/arc42/`.
If arguments are section numbers (e.g., "05 06 07"), review only those sections
(but still check their cross-references to other sections).

**You MUST use ultrathink (extended thinking) for consolidation.**

**This command produces ONLY `architecture/arc42-consistency-review.md`.
Do NOT modify any arc42 sections, ADRs, or source files.**

---

## Phase 1 — Discover and Load

1. List all files in `docs/arc42/` to identify which sections exist
2. Read all arc42 sections in scope
3. Read `docs/arc42/00-source-inventory.md` for the source-to-section map
4. Read `architecture/questions/resolved-questions.md` for decision context
5. Read all ADRs referenced by the sections in scope
6. Read `architecture/adr-consistency-review.md` if it exists — check if
   prior ADR review findings have been incorporated

Do not proceed until you have the full set of sections and their context.

---

## Phase 2 — Spawn Specialist Agents

Launch all four agents **in parallel**.

### Agent 1 — Cross-Reference Validator

Read all arc42 sections. Check for:

- **Broken cross-references:** Section A links to Section B, but the linked
  heading or content doesn't exist
- **Asymmetric references:** Section A references Section B, but Section B
  doesn't reference Section A where it should
- **Content contradictions between sections:**
  - §05 (Building Block) describes a component with interface X, but §06
    (Runtime) shows it using interface Y
  - §07 (Deployment) places a service on infrastructure that §05 doesn't
    describe
  - §04 (Solution Strategy) claims a pattern that §08 (Crosscutting) doesn't
    document
  - §09 (Architecture Decisions) summarizes an ADR differently than the
    full ADR states
- **Mermaid diagram inconsistencies:** Component names in §05 diagrams don't
  match names used in §06 sequence diagrams or §07 deployment diagrams

Output: list of cross-reference issues with exact file, line, and section references.

### Agent 2 — Source Traceability Auditor

For each arc42 section, verify the source-to-claim chain:

- **Untraced claims:** Factual statements without any source citation — are
  they derivable from cited sources, or are they unsupported?
- **Missing source claims:** Claims in the source inventory tagged to this
  section that don't appear in the arc42 content
- **Stale citations:** References to source documents that have since been
  superseded
- **Resolved questions not incorporated:** Decisions from
  `architecture/questions/resolved-questions.md` that should appear in
  this section but don't
- **Inference markers:** Are inferred claims properly flagged? Are any
  flagged inferences actually supported by sources?

Output: traceability matrix (section → claims → sources) and list of gaps.

### Agent 3 — Library Alignment Agent (context7)

For every technology, library, or framework mentioned in the arc42 sections:

1. Use context7 `resolve-library-id` to find the library
2. Use context7 `query-docs` to verify described behavior:
   - API signatures and method names
   - Configuration options and defaults
   - Behavioral descriptions (e.g., "FastMCP supports X transport")
   - Version-specific features or limitations
3. Classify each claim:
   - **Confirmed:** Library docs agree
   - **Outdated:** Was true in an older version but not current
   - **Incorrect:** Library docs contradict the claim
   - **Unverifiable:** Library docs don't address this specific claim

Output: table of (section, technology, claim, context7 finding, status).

### Agent 4 — Terminology Consistency Agent

Read §12 (Glossary) and all other sections. Check for:

- **Undefined terms:** Terms used in sections that don't appear in the glossary
  and aren't self-evident to a developer
- **Synonym drift:** Same concept referred to by different names across sections
  (e.g., "session store" in §05 vs "conversation cache" in §06)
- **Glossary orphans:** Terms defined in the glossary that don't appear anywhere
  in the arc42 sections
- **Abbreviation inconsistency:** Abbreviations used without definition, or
  defined differently in different sections
- **Naming mismatches with ADRs:** Component or concept names in arc42 that
  differ from the names used in the ADRs

Output: list of terminology issues with exact section references and
recommended corrections.

---

## Phase 3 — Consolidate Findings

After all four agents have completed:

1. **Collect** all findings
2. **Deduplicate** — merge findings raised by multiple agents
3. **Classify** into severity tiers:
   - **CRITICAL:** Cross-section contradiction that would confuse implementers,
     incorrect library claim that would lead to wrong implementation
   - **IMPORTANT:** Untraced claims, missing source incorporation, outdated
     library descriptions
   - **ADVISORY:** Terminology drift, glossary gaps, asymmetric references,
     minor style issues
4. **Identify loops:** If findings suggest that fixing Section A requires
   changing Section B which in turn affects Section A, flag this as a
   coordination issue

---

## Phase 4 — Write Report

Save to `architecture/arc42-consistency-review.md`:

```markdown
# Arc42 Consistency Review

> **Date:** [today's date]
> **Sections reviewed:** [list]
> **Findings:** [N critical, N important, N advisory]

## Executive Summary

[3-5 sentences: overall documentation health, most significant findings]

## Critical Findings

### [Finding title]
- **Agents:** [which agents flagged this]
- **Affected sections:** [§NN references]
- **Description:** [what the problem is, with exact quotes/references]
- **Evidence:** [source citations, context7 output, cross-reference details]
- **Recommended action:** [specific fix — which section, what to change]

## Important Findings

[Same structure]

## Advisory Findings

[Same structure]

## Library Validation Matrix

| Section | Technology | Claim | context7 Finding | Status |
|---------|-----------|-------|------------------|--------|
| §[NN] | [name] | [what arc42 says] | [what docs say] | [confirmed/outdated/incorrect/unverifiable] |

## Source Traceability Matrix

| Section | Source Claims Expected | Claims Found | Untraced Claims | Missing Claims |
|---------|----------------------|--------------|-----------------|----------------|
| §[NN] | [N] | [N] | [N] | [N] |

## Terminology Report

| Issue Type | Count | Most Affected Sections |
|-----------|-------|----------------------|
| Undefined terms | [N] | §[NN], §[NN] |
| Synonym drift | [N] | §[NN], §[NN] |
| Glossary orphans | [N] | §12 |

## Cross-Section Dependency Map

[Which sections reference each other, and where those references are
inconsistent]

## Coordination Issues

[Findings where fixing one section requires coordinated changes in another]
```

---

## Rules

- **Do not modify** any arc42 section files. This report is advisory only.
- Every finding must include exact file paths, section references, and
  evidence.
- context7 validation must be attempted for every technology-specific claim.
- If no findings exist for a tier, state "No [tier] findings."
- Findings that require looping back to question discovery or ADR drafting
  must be explicitly flagged with the recommended workflow step.
