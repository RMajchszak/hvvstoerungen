# Review Planning Artifacts

You are the orchestrator for a multi-agent architecture review. Your job is to
coordinate specialist agents, consolidate their findings, and produce a single
review report.

**Scope:** Review all epics that have planning artifacts in `planning/`.
If arguments are provided, review only those epics: $ARGUMENTS
If no arguments are provided, auto-discover by listing `planning/*/tasks.md`.

**You MUST use ultrathink (extended thinking) for consolidation.**

---

## Phase 1 — Discover Planning Artifacts

1. List all `planning/*/tasks.md` and `planning/*/implementation-sequence.md`
   files to identify which epics have planning artifacts
2. If `$ARGUMENTS` is provided, filter to only those epic IDs
3. Read `docs/epic-hierarchy-report.md` to understand the full dependency
   landscape across all epics

Do not proceed until you know exactly which epics and files are in scope.

---

## Phase 2 — Spawn Specialist Agents

Launch all four agents **in parallel**. Each agent should read the relevant
files and produce structured findings.

### Agent 1 — Consistency Auditor

Read all in-scope `tasks.md` files. Check for:

- **Naming inconsistencies:** same component or concept referred to differently
  across epics (e.g., one epic calls it `SessionStore`, another calls it
  `ConversationStore` for the same thing)
- **Duplicate issues:** same work appearing in more than one epic
- **Conflicting acceptance criteria:** an outcome required in one epic
  contradicted by another
- **Missing handoffs:** an epic assumes a prior epic delivered something that
  is not explicitly in that epic's acceptance criteria

Output: a structured list of all inconsistencies found, with exact issue
references (Epic / ISSUE-N).

### Agent 2 — Dependency Validator

Read all in-scope `tasks.md` and `implementation-sequence.md` files. Check for:

- **Unilateral dependencies:** cross-epic dependencies referenced in one
  `tasks.md` but not acknowledged in the corresponding epic's `tasks.md`
- **Circular dependencies:** A blocks B blocks C blocks A
- **Sequence violations:** issues scheduled before their blockers are resolved
- **Misclassified gates:** infrastructure loose gates incorrectly modelled as
  hard dependencies, or hard dependencies that should be loose

Output: a dependency graph summary and a list of all violations found, with
exact issue references and recommended corrections.

### Agent 3 — Sequence Coherence Reviewer

Read all in-scope `implementation-sequence.md` files. Check for:

- **Unexploited parallelism:** issues marked sequential that have no actual
  dependency between them
- **Bottlenecks:** single issues that block disproportionately large portions
  of subsequent work
- **Sequencing risks:** issues scheduled late that carry high uncertainty or
  external dependencies and should be pulled earlier
- **Sequence-dependency contradictions:** inconsistencies between the
  `implementation-sequence.md` and the dependency map in `tasks.md`

Output: a sequence assessment with specific recommendations for re-ordering
or parallelising where beneficial.

### Agent 4 — Architecture Compliance Reviewer

Using context7 `/adesso-ai/concierge` and `/docs/arc42/` as reference:

For each in-scope epic's `tasks.md`, evaluate:

- Whether the issues **collectively fulfil** the architectural requirements
  for their epic as defined in arc42
- Any arc42 **constraints, interface contracts, or ADRs** that are not
  addressed by any issue in the relevant epic
- Any issue whose acceptance criteria **conflicts with** an arc42 constraint
  or ADR
- Any **technical debt items** flagged in arc42 that are not tracked in any
  issue

Query arc42 sections relevant to each epic's domain specifically — do not do
a generic full-document scan. Use the epic's arc42 references from
`epic-hierarchy-report.md` to target the right sections.

Output: a compliance matrix (Epic → arc42 sections covered / gaps) and a list
of all violations or omissions found.

---

## Phase 3 — Consolidate Findings

After all four agents have completed:

1. **Collect** all findings from the four agents
2. **Deduplicate and cross-reference** — a finding raised by multiple agents
   should be merged into a single entry with all agent perspectives noted
3. **Prioritise** findings into three tiers:
   - **CRITICAL:** blocks implementation or contradicts architecture — must
     fix before work begins
   - **IMPORTANT:** risks quality or introduces rework — should fix before
     work begins
   - **ADVISORY:** improvement opportunity — fix when convenient
4. **Count** findings per tier for the executive summary

---

## Phase 4 — Write Report

Save the consolidated output as `docs/planning-review-report.md`:

```markdown
# Planning Review Report

> **Date:** [today's date]
> **Epics reviewed:** [list of epic IDs]
> **Findings:** [N critical, N important, N advisory]

## Executive Summary

[3-5 sentence overview of overall planning health and critical findings]

## Critical Findings

### [Finding title]
- **Agents:** [which agents flagged this]
- **Affected:** [Epic / ISSUE-N references]
- **Description:** [what the problem is]
- **Recommended action:** [what to do about it]

## Important Findings

### [Finding title]
- **Agents:** [which agents flagged this]
- **Affected:** [Epic / ISSUE-N references]
- **Description:** [what the problem is]
- **Recommended action:** [what to do about it]

## Advisory Findings

### [Finding title]
- **Agents:** [which agents flagged this]
- **Affected:** [Epic / ISSUE-N references]
- **Description:** [what the problem is]
- **Recommended action:** [what to do about it]

## Architecture Compliance Matrix

| Epic | arc42 Sections | Covered | Gaps |
|------|---------------|---------|------|

## Consolidated Sequence Assessment

[Cross-epic implementation sequence reflecting any corrections from
the findings above. Highlight re-ordering recommendations.]
```

---

## Rules

- **Do not modify** any existing `tasks.md`, `implementation-sequence.md`,
  or `implementation-plan.md` files. The report is advisory only.
- Changes to source files require a separate prompt.
- Every finding must include exact file and issue references — no vague
  "some issues have problems" statements.
- If no findings exist for a tier, state "No [tier] findings" rather than
  omitting the section.
