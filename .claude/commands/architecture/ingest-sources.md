# Ingest Source Documents

You are cataloging all source documents that will inform the arc42 architecture
documentation. The source folder or file list is: $ARGUMENTS

If no arguments are provided, default to scanning all of:
- `SourceDocuments/adr/`
- `SourceDocuments/SpecsAndRequirments/`
- `SourceDocuments/research/`
- `SourceDocuments/lead-machine.pdf`

**You MUST enter plan mode and use ultrathink (extended thinking) for this entire task.**

**This command produces ONLY `docs/arc42/00-source-inventory.md`.
Do NOT create, modify, or write any other files.**

---

## Phase 1 — Discover Source Documents

1. List all files in the specified source folder(s)
2. For each document, record:
   - File path (relative to repo root)
   - Document type (ADR, spec, research, infrastructure, API schema, etc.)
   - Title / subject
   - Date (if stated in the document)
   - Author(s) (if stated)
   - Status (accepted, proposed, superseded, draft — if applicable)

Do not proceed until you have a complete file manifest.

---

## Phase 2 — Extract Claims and Constraints

For each source document:

1. **Read the document thoroughly**
2. Extract key claims — factual statements about architecture, technology
   choices, constraints, requirements, or design decisions
3. For each claim, record:
   - The claim itself (concise paraphrase, not full quote)
   - Source location (document path + section/heading)
   - Arc42 section(s) this claim informs (map to §01–§12)
   - Confidence: **explicit** (document states it directly) or **inferred**
     (derived from context)
4. Extract constraints — hard limits, regulations, technology mandates,
   organizational rules
5. Extract open questions — things the document raises but doesn't resolve

### Arc42 Section Mapping Guide

| Arc42 Section | Maps From |
|--------------|-----------|
| §01 Introduction and Goals | Business goals, stakeholder requirements, quality goals |
| §02 Constraints | Technical constraints, organizational constraints, conventions |
| §03 Context and Scope | System boundaries, external interfaces, user channels |
| §04 Solution Strategy | Technology decisions, top-level decomposition approach |
| §05 Building Block View | Module structure, component responsibilities, interfaces |
| §06 Runtime View | Flows, sequences, interaction patterns |
| §07 Deployment View | Infrastructure, environments, scaling, CI/CD |
| §08 Crosscutting Concepts | Auth, logging, error handling, persistence patterns |
| §09 Architecture Decisions | ADRs, rationale for key choices |
| §10 Quality Requirements | SLOs, performance targets, security requirements |
| §11 Risks and Technical Debt | Known risks, deferred items, gaps |
| §12 Glossary | Domain terms, abbreviations, project-specific vocabulary |

---

## Phase 3 — Cross-Reference and Contradiction Detection

1. **Group claims by arc42 section** — identify which sections have rich
   source material and which have gaps
2. **Detect contradictions** — where two or more sources make conflicting
   claims about the same topic:
   - Record both claims with their sources
   - Classify severity: **blocking** (cannot proceed without resolution),
     **important** (affects architecture quality), **minor** (cosmetic or
     terminology)
3. **Detect supersession** — where a later document explicitly overrides an
   earlier one (e.g., ADR-906 supersedes ADR-900)
4. **Detect gaps** — arc42 sections with no source material at all

---

## Phase 4 — Write Output

Write the inventory to `docs/arc42/00-source-inventory.md`.

If the file already exists, read it first and update it — do not discard
prior manual annotations or notes that don't conflict with new findings.

### Required Sections

```markdown
# Source Document Inventory

**Generated:** [today's date]
**Purpose:** Comprehensive inventory of all source documents with arc42
section mapping and cross-reference analysis.

---

## Summary Statistics

| Category | Count |
|----------|-------|
| [category] | [N] |
| **Total** | **[N] documents** |

---

## Document Catalog

### [Category Name] (`path/`)

| # | File | Status | Date | Key Topics | Arc42 Sections | Cross-References |
|---|------|--------|------|------------|----------------|------------------|

[One table per source category]

---

## Arc42 Coverage Map

| Arc42 Section | Source Documents | Coverage |
|--------------|-----------------|----------|
| §01 Introduction and Goals | [list] | [rich / adequate / sparse / none] |
| §02 Constraints | [list] | ... |
| ... | ... | ... |
| §12 Glossary | [list] | ... |

---

## Contradictions

### [Contradiction title]
- **Source A:** [claim] — [document path, section]
- **Source B:** [claim] — [document path, section]
- **Severity:** blocking | important | minor
- **Recommended resolution:** [suggestion]

[If no contradictions: "No contradictions detected."]

---

## Gaps

[Arc42 sections with insufficient or no source material, with notes on
what is missing and where it might come from]

---

## Supersession Chain

| Superseded Document | Superseded By | Date | Reason |
|--------------------|---------------|------|--------|
```

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every source document in the specified folder(s) appears in the catalog
- [ ] Every document has at least one arc42 section mapping
- [ ] All contradictions between sources are explicitly flagged
- [ ] All arc42 sections (§01–§12) appear in the coverage map
- [ ] Sections with "none" coverage are called out in the Gaps section
- [ ] Superseded documents are marked and the supersession chain is clear
- [ ] Cross-references between documents are recorded
