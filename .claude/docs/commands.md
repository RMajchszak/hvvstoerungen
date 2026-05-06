# Claude Code Commands

Two command pipelines are available: one for **architecture creation** (source
documents → arc42) and one for **epic planning & implementation** (arc42 → code).

---

## Pipeline 1 — Architecture Creation

Takes source documents, requirements, and research through a structured process
to produce consistent, traceable arc42 architecture documentation.

### Overview

```
/architecture:ingest-sources [folder]
     │
     ▼  docs/arc42/00-source-inventory.md
/architecture:discover-architecture-questions [sections]
     │
     ▼  architecture/questions/open-questions.md
/architecture:resolve-architecture-questions [question-ids]
     │
     ▼  architecture/questions/resolved-questions.md
/architecture:draft-adrs [adr-numbers | question-ids]
     │
     ▼  SourceDocuments/adr/NNN-*.md
/architecture:review-adr-consistency [adr-numbers]
     │
     ▼  architecture/adr-consistency-review.md
/architecture:draft-arc42-section [section-numbers | all]
     │
     ▼  docs/arc42/NN-*.md
/architecture:review-arc42-consistency [section-numbers]
     │
     ▼  architecture/arc42-consistency-review.md
/architecture:resolve-arc42-gaps [finding-ids]
     │                    ╭─── may loop back to
     │                    │    /architecture:discover-architecture-questions
     │                    │    /architecture:draft-adrs
     ▼  fixes applied + architecture/arc42-gap-remedies.md
/architecture:finalize-arc42
     │
     ▼  Branch + PR (or blocker report)
/architecture:review-arc42-pr [pr-number]
     │
     ▼  Review verdict
```

### Commands

#### Step 1 — `/architecture:ingest-sources [folder]`

Catalog all source documents with arc42 section mapping and contradiction detection.

- **Input:** Folder path (default: `SourceDocuments/`)
- **Reads:** All documents in the specified folder(s)
- **Output:** `docs/arc42/00-source-inventory.md`
- **Produces:** Document catalog, arc42 coverage map, contradictions, gaps,
  supersession chain
- **Mode:** Planning with ultrathink

#### Step 2 — `/architecture:discover-architecture-questions [sections]`

Identify open questions, ambiguities, and contradictions that must be resolved.

- **Input:** Arc42 section numbers (default: all §01–§12)
- **Reads:** Source inventory, source documents
- **Output:** `architecture/questions/open-questions.md`
- **Uses context7:** Validates library assumptions against current documentation
- **Produces:** Questions classified as blocking / important / clarification /
  auto-resolved
- **Mode:** Planning with ultrathink

#### Step 3 — `/architecture:resolve-architecture-questions [question-ids]`

Resolve open questions using sources, context7, and architectural derivation.

- **Input:** Question IDs (default: all open questions)
- **Reads:** Open questions, source inventory, source documents, ADRs
- **Output:** `architecture/questions/resolved-questions.md` (updates open-questions.md)
- **Uses context7:** Verifies technology-related answers
- **Produces:** Resolved decisions with evidence, ADR candidates, still-open items
  needing human input
- **Mode:** Ultrathink

#### Step 4 — `/architecture:draft-adrs [adr-numbers | question-ids]`

Create or update ADRs based on resolved questions.

- **Input:** ADR numbers, question IDs, or omit for all candidates
- **Reads:** Resolved questions, existing ADRs, source documents
- **Output:** `SourceDocuments/adr/NNN-*.md`
- **Uses context7:** Validates technology choices against current library docs
- **Mode:** Ultrathink

#### Step 5 — `/architecture:review-adr-consistency [adr-numbers]`

Multi-agent review of ADR set for contradictions, source alignment, and
library accuracy.

- **Input:** ADR numbers (default: all ADRs)
- **Reads:** All ADRs, source documents, resolved questions
- **Output:** `architecture/adr-consistency-review.md`
- **Uses context7:** Verifies every technology-specific ADR claim
- **Agents:** Contradiction Detector, Source Alignment Checker, Library
  Validation Agent (context7), Completeness Checker
- **Mode:** Spawns 4 parallel specialist agents

#### Step 6 — `/architecture:draft-arc42-section [section-numbers | all]`

Write arc42 sections from source documents, ADRs, and resolved questions.

- **Input:** Section numbers (e.g., `01`, `05 06`, `all`)
- **Reads:** Source inventory, resolved questions, ADRs, existing arc42 content
- **Output:** `docs/arc42/NN-*.md`
- **Uses context7:** Validates technology descriptions in §04–§08
- **Key behavior:** Every claim cites its source. Inferences are flagged.
  Uncovered areas get TODO markers.
- **Mode:** Planning with ultrathink

#### Step 7 — `/architecture:review-arc42-consistency [section-numbers]`

Multi-agent review of arc42 sections for cross-section consistency, traceability,
library accuracy, and terminology coherence.

- **Input:** Section numbers (default: all sections)
- **Reads:** All arc42 sections, source inventory, ADRs, resolved questions
- **Output:** `architecture/arc42-consistency-review.md`
- **Uses context7:** Verifies every technology claim in arc42 sections
- **Agents:** Cross-Reference Validator, Source Traceability Auditor, Library
  Alignment Agent (context7), Terminology Consistency Agent
- **Mode:** Spawns 4 parallel specialist agents

#### Step 8 — `/architecture:resolve-arc42-gaps [finding-ids]`

Apply fixes for consistency review findings. May loop back to earlier steps.

- **Input:** Finding IDs (default: all findings)
- **Reads:** Consistency review, arc42 sections, source documents, ADRs
- **Output:** `architecture/arc42-gap-remedies.md` + direct edits to arc42 sections
- **Uses context7:** Updates outdated library claims
- **Key behavior:** Applies direct fixes to section files. Findings requiring
  new questions or ADRs are flagged as workflow loops.
- **Mode:** Ultrathink

#### Step 9 — `/architecture:finalize-arc42`

Final verification, traceability summary, and PR creation.

- **Input:** Section numbers (default: all)
- **Reads:** All arc42 sections, all architecture workflow artifacts
- **Output:** Branch + PR (if ready) or blocker report
- **Checks:** No blocking questions, no critical findings, cross-references,
  Mermaid syntax, terminology, ADR alignment
- **Mode:** Ultrathink

#### Step 10 — `/architecture:review-arc42-pr [pr-number]`

Review the arc42 PR against source material, ADRs, and library documentation.

- **Input:** PR number, branch name, or auto-detect
- **Reads:** PR diff, all changed files in full, source documents, ADRs,
  resolved questions
- **Output:** Review verdict (APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION)
- **Uses context7:** Verifies every technology claim in changed sections
- **Checks:** Source traceability, resolved question incorporation, library
  accuracy, cross-section consistency, diagram validity, terminology
- **Mode:** Ultrathink

---

## Pipeline 2 — Epic Planning & Implementation

Takes an existing arc42 architecture and plans, reviews, and implements epics
through to merged PRs.

### Overview

```
/planning:plan-epic XXX
     │
     ▼  implementation-plan.md
/planning:plan-issues-for-epic XXX
     │
     ▼  tasks.md + implementation-sequence.md
     ├──────────────────────────────────────────┐
     ▼                                          ▼
/planning:review-arc42-       /planning:review-issue-
 alignment-for-issues-         coherence-for-epic XXX
 for-epic XXX                          │
     │                                 ▼  coherence-review.md
     ▼  planning-review-report.md      │
     └──────────────┬──────────────────┘
                    ▼
     /planning:resolve-planning-gaps-for-epic XXX
                    │
                    ▼  planning-gap-remedies.md
     /planning:apply-planning-remedies-for-epic XXX
                    │
                    ▼  Updated tasks.md + implementation-sequence.md
     /planning:create-issues-in-beads-for-epic XXX
                    │
                    ▼  Issues live in beads tracker
     /implementation:implement-issue ISSUE-ID
                    │
                    ▼  Code + PR
     /implementation:review-pr-for-issue ISSUE-ID
                    │
                    ▼  Review verdict
```

### Commands

#### Step 1 — `/planning:plan-epic XXX`

Design the technical implementation plan for an epic.

- **Input:** Beads epic ID
- **Reads:** Epic spec from beads, arc42 architecture, existing codebase
- **Output:** `planning/<epic-id>/implementation-plan.md`
- **Mode:** Planning with ultrathink

#### Step 2 — `/planning:plan-issues-for-epic XXX`

Break the implementation plan into discrete, implementable issues.

- **Input:** Beads epic ID (requires `implementation-plan.md` from step 1)
- **Reads:** Implementation plan, epic hierarchy report, codebase
- **Output:** `planning/<epic-id>/tasks.md`, `planning/<epic-id>/implementation-sequence.md`
- **Mode:** Planning with ultrathink

#### Step 3a — `/planning:review-arc42-alignment-for-issues-for-epic XXX`

Verify issues are complete and consistent with the arc42 architecture.

- **Input:** Beads epic ID(s) or omit for all epics
- **Reads:** All `tasks.md` and `implementation-sequence.md` files, arc42
- **Output:** `docs/planning-review-report.md`
- **Checks:** Naming consistency, duplicate issues, conflicting ACs,
  dependency violations, architecture compliance
- **Mode:** Spawns 4 parallel specialist agents

#### Step 3b — `/planning:review-issue-coherence-for-epic XXX`

Verify issues build on predecessors rather than reimplementing their work.

- **Input:** Beads epic ID
- **Reads:** All planning artifacts for the epic, predecessor epic plans
- **Output:** `planning/<epic-id>/coherence-review.md`
- **Checks:** Reimplementation, missing consumption, interface mismatch,
  AC duplication, orphaned deliverables, cross-epic handoff gaps
- **Mode:** Ultrathink

Steps 3a and 3b can run in any order or in parallel.

#### Step 4 — `/planning:resolve-planning-gaps-for-epic XXX`

Write concrete, arc42-grounded remedies for all review findings.

- **Input:** Beads epic ID or "all" for cross-epic review
- **Reads:** Review reports from steps 3a/3b, arc42, ADRs
- **Output:** `planning/<epic-id>/planning-gap-remedies.md` (or `docs/` if "all")
- **Produces:** Remedy per finding, decision log, summary table
- **Mode:** Ultrathink

#### Step 5 — `/planning:apply-planning-remedies-for-epic XXX`

Apply resolved remedies to the issue breakdown and sequence documents.

- **Input:** Beads epic ID (requires `planning-gap-remedies.md` from step 4)
- **Reads:** Gap remedies, review reports, current `tasks.md` and
  `implementation-sequence.md`, implementation plan
- **Output:** Updated `planning/<epic-id>/tasks.md` and
  `planning/<epic-id>/implementation-sequence.md`
- **Key behavior:** Presents change plan for user approval before editing.
  Never renumbers existing issues. Appends a change log to `tasks.md`.
- **Mode:** Ultrathink

#### Step 6 — `/planning:create-issues-in-beads-for-epic XXX`

Create the planned issues in the beads tracker with dependencies.

- **Input:** Beads epic ID
- **Reads:** `tasks.md`, `implementation-sequence.md`, epic hierarchy
- **Output:** Issues created in beads with parent/child and dependency relationships
- **Key behavior:** Ensures beads `.N` suffix matches `ISSUE-N` numbering.
  Updates markdown if IDs differ. Sets cross-epic dependencies.

#### Step 7 — `/implementation:implement-issue ISSUE-ID`

Implement a single issue end-to-end.

- **Input:** Beads issue ID (e.g., `conciergeagent-d5l.3`)
- **Reads:** Issue spec, epic plan, predecessor implementations
- **Output:** Code changes, git commits, PR
- **Phases:** Load context → claim & branch → implement → verify ACs →
  update READMEs → push & close → create PR

#### Step 8 — `/implementation:review-pr-for-issue ISSUE-ID`

Review a PR against the issue specification and planning documents.

- **Input:** Beads issue ID
- **Reads:** Issue spec, implementation plan, PR diff, predecessor/successor contracts
- **Output:** Review verdict (APPROVED / CHANGES REQUESTED / NEEDS DISCUSSION)
- **Checks:** Every AC (PASS/PARTIAL/FAIL), design decision compliance,
  cross-dependency contracts, code quality

---

## Typical Workflows

### Architecture Creation (new project or major rework)

```bash
# Catalog sources
/architecture:ingest-sources SourceDocuments/

# Discover and resolve questions
/architecture:discover-architecture-questions
/architecture:resolve-architecture-questions
# Answer any "needs-human-decision" items, then re-run if needed

# Formalize decisions
/architecture:draft-adrs
/architecture:review-adr-consistency
# Fix critical findings, then re-run review if needed

# Write arc42 sections
/architecture:draft-arc42-section all
# Or incrementally: /architecture:draft-arc42-section 12 01 02 03 ...

# Review and fix
/architecture:review-arc42-consistency
/architecture:resolve-arc42-gaps
# May loop back to /architecture:discover-architecture-questions or /architecture:draft-adrs

# Finalize and review
/architecture:finalize-arc42
/architecture:review-arc42-pr
```

### Epic Implementation (arc42 exists)

```bash
# Plan
/planning:plan-epic conciergeagent-xxx

/planning:plan-issues-for-epic conciergeagent-xxx

# Validate (can run both)
/planning:review-arc42-alignment-for-issues-for-epic conciergeagent-xxx
/planning:review-issue-coherence-for-epic conciergeagent-xxx

# Fix gaps if any found
/planning:resolve-planning-gaps-for-epic conciergeagent-xxx

# Apply remedies to tasks.md
/planning:apply-planning-remedies-for-epic conciergeagent-xxx
# Review updated tasks.md, re-validate if needed

# Create in tracker
/planning:create-issues-in-beads-for-epic conciergeagent-xxx

# Implement (repeat per issue, in sequence order)
/implementation:implement-issue conciergeagent-xxx.1
/implementation:review-pr-for-issue conciergeagent-xxx.1
# ... merge PR ...
/implementation:implement-issue conciergeagent-xxx.2
# etc.
```

---

## File Locations

### Architecture Pipeline

| Artifact | Path |
|----------|------|
| Source inventory | `docs/arc42/00-source-inventory.md` |
| Open questions | `architecture/questions/open-questions.md` |
| Resolved questions | `architecture/questions/resolved-questions.md` |
| ADRs | `SourceDocuments/adr/NNN-*.md` |
| ADR consistency review | `architecture/adr-consistency-review.md` |
| Arc42 sections | `docs/arc42/NN-*.md` |
| Arc42 consistency review | `architecture/arc42-consistency-review.md` |
| Arc42 gap remedies | `architecture/arc42-gap-remedies.md` |

### Epic Pipeline

| Artifact | Path |
|----------|------|
| Implementation plan | `planning/<epic-id>/implementation-plan.md` |
| Issue breakdown | `planning/<epic-id>/tasks.md` |
| Execution sequence | `planning/<epic-id>/implementation-sequence.md` |
| Arc42 alignment report | `docs/planning-review-report.md` |
| Coherence review | `planning/<epic-id>/coherence-review.md` |
| Gap remedies | `planning/<epic-id>/planning-gap-remedies.md` |
