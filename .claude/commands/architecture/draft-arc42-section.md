# Draft Arc42 Section

You are writing one or more arc42 architecture documentation sections based on
source documents, resolved questions, and approved ADRs. The section(s) to draft:
$ARGUMENTS

Arguments can be:
- Section numbers: `01`, `05`, `03 06`
- Section names: `building-block-view`, `runtime-view`
- `all` — draft all sections in dependency order

**You MUST enter plan mode and use ultrathink (extended thinking) for this entire task.**

**This command creates or updates files in `docs/arc42/` ONLY.
Do NOT modify source documents, ADRs, or question files.**

---

## Phase 1 — Load Context

### 1a — Source Inventory and Questions

1. Read `docs/arc42/00-source-inventory.md` — your primary source-to-section map
2. Read `architecture/questions/resolved-questions.md` — decisions that feed
   into this section
3. Read `architecture/questions/open-questions.md` — check that no blocking
   questions remain for the section(s) you're drafting

If blocking questions exist for a section, stop and inform the user. They must
run `/resolve-architecture-questions` first.

### 1b — ADRs

1. Read all ADRs that map to the section(s) being drafted (use the arc42 impact
   tables in ADRs, or the source inventory's ADR-to-section mapping)
2. Read `architecture/adr-consistency-review.md` if it exists — check for any
   open critical findings that affect this section

### 1c — Source Documents

Read the source documents mapped to this section in the source inventory.
Focus on:
- Claims tagged to this specific section
- Cross-references to other sections (these become links in the output)

### 1d — Existing Arc42 Content

If the section file already exists in `docs/arc42/`, read it. You are
**updating**, not starting from scratch. Preserve:
- Manual annotations or notes added by humans
- Content that is still accurate
- Update content that conflicts with newer ADRs or resolved questions
- Add content for newly resolved questions or new ADRs

### 1e — Library Documentation (context7)

For sections that describe technology integration (§04, §05, §06, §07, §08):
1. Identify which libraries/technologies are referenced
2. Use context7 `resolve-library-id` + `query-docs` to get current documentation
3. Use this to ensure described behaviors, APIs, and configurations are accurate

---

## Phase 2 — Draft the Section

### Section-Specific Guidance

Follow the arc42 template structure for the section being drafted:

| Section | Content Focus | Key Sources |
|---------|--------------|-------------|
| §01 Introduction and Goals | Business requirements, quality goals, stakeholders | Specs, research |
| §02 Constraints | Technical, organizational, and convention constraints | ADRs, specs, infra docs |
| §03 Context and Scope | System boundary, external interfaces, business/technical context | Specs, API schemas |
| §04 Solution Strategy | Technology decisions, top-level design approach | ADRs, research |
| §05 Building Block View | Module decomposition at levels 1-3, interfaces | Specs, ADRs |
| §06 Runtime View | Key interaction scenarios as sequence diagrams | Specs, ADRs |
| §07 Deployment View | Infrastructure, environments, topology | Infra docs, ADRs |
| §08 Crosscutting Concepts | Recurring patterns: auth, logging, error handling | ADRs, specs |
| §09 Architecture Decisions | Summary table + links to full ADRs | ADRs |
| §10 Quality Requirements | Quality tree, quality scenarios, SLOs | Specs, ADRs |
| §11 Risks and Technical Debt | Risk catalog, tech debt register | All sources |
| §12 Glossary | Domain terms, abbreviations | All sources |

### Content Rules

1. **Every claim must cite its source.** Use inline citations:
   `(Source: SourceDocuments/adr/016-..., §Context)` or
   `(ADR-016)` or `(Q-7, resolved)` or `(context7: FastMCP docs)`
2. **Use Mermaid for all diagrams.** Validate that diagram syntax is correct
   by reviewing the Mermaid specification via context7 if unsure.
3. **Flag inferences.** If a statement is derived rather than directly sourced,
   mark it: `> ⚠️ Inferred: [rationale for the inference]`
4. **Cross-reference other sections.** Use relative links:
   `See [§05 Building Block View](05-building-block-view.md#section)`
5. **Do not invent.** If sources don't cover something, leave a placeholder:
   `> 📝 TODO: [what information is needed and which source might provide it]`
6. **Use glossary terms.** Terms defined in §12 should be used consistently.

### Recommended Drafting Order (if `all`)

This order respects content dependencies between sections:

1. §12 Glossary — establishes shared vocabulary
2. §01 Introduction and Goals — frames everything
3. §02 Constraints — bounds the solution space
4. §03 Context and Scope — defines system boundary
5. §09 Architecture Decisions — ADR summary (decisions are already written)
6. §04 Solution Strategy — top-level approach
7. §05 Building Block View — module decomposition
8. §06 Runtime View — interaction scenarios
9. §07 Deployment View — infrastructure topology
10. §08 Crosscutting Concepts — recurring patterns
11. §10 Quality Requirements — quality tree and scenarios
12. §11 Risks and Technical Debt — risk catalog

---

## Phase 3 — Write Output

Write each section to `docs/arc42/NN-<section-name>.md`.

Use the existing file naming convention:
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

If the file already exists, use the Edit tool to update specific sections
rather than overwriting the entire file (unless a full rewrite is warranted
by extensive changes).

---

## Phase 4 — Self-Review

Before finalizing each section, verify:

### Traceability
- [ ] Every factual claim cites a source document, ADR, resolved question,
  or context7 library docs
- [ ] Inferences are explicitly flagged
- [ ] TODOs are left for uncovered areas (not invented content)

### Consistency
- [ ] Terminology matches §12 Glossary
- [ ] Cross-references to other sections use correct relative links
- [ ] Mermaid diagrams render correctly (valid syntax)

### Completeness
- [ ] All source claims mapped to this section (from source inventory) are
  addressed
- [ ] All ADRs mapped to this section are referenced
- [ ] All resolved questions affecting this section are incorporated

### Accuracy
- [ ] Library/technology descriptions match context7 documentation
- [ ] No claims contradict accepted ADRs
- [ ] Superseded information from earlier sources is not presented as current

---

## Quality Checklist (Final)

- [ ] Every section file follows the arc42 template structure
- [ ] All diagrams use Mermaid syntax
- [ ] All sources are cited inline
- [ ] No blocking questions remain unresolved for any drafted section
- [ ] Cross-section references are consistent (A references B ↔ B references A)
- [ ] The source inventory's arc42 coverage map would show "rich" or "adequate"
  for every drafted section
