# Resolve Architecture Questions

You are resolving the open questions identified during architecture discovery.
Each resolution must be grounded in evidence — source documents, library
documentation (via context7), or explicit human decisions. The scope is: $ARGUMENTS

If no arguments are provided, resolve all questions in
`architecture/questions/open-questions.md`.
If arguments are question IDs (e.g., "Q-1 Q-3 Q-7"), resolve only those.

**You MUST use ultrathink (extended thinking) for this entire task.**

**This command updates `architecture/questions/open-questions.md` (moving resolved
questions) and writes `architecture/questions/resolved-questions.md`.**

---

## Phase 1 — Load Context

1. Read `architecture/questions/open-questions.md` — the questions to resolve
2. Read `docs/arc42/00-source-inventory.md` — source document reference
3. Identify which source documents are relevant to the questions in scope
   and read them
4. If any questions reference ADRs, read those ADRs

If the open questions file doesn't exist, stop and instruct the user to run
`/discover-architecture-questions` first.

---

## Phase 2 — Attempt Resolution

For each question in scope, attempt resolution in this order:

### 2a — Check Source Documents

Re-read the relevant source documents more carefully. Sometimes the answer
exists but was missed during discovery. If found:
- Record the answer with precise citation (document path, section, key quote)
- Mark as **resolved-from-sources**

### 2b — Query Library Documentation (context7)

For technology-related questions:
1. Use `resolve-library-id` to find the library in context7
2. Use `query-docs` with targeted queries about the specific capability or
   behavior in question
3. If context7 provides a clear answer:
   - Record the answer with the context7 query and key findings
   - Mark as **resolved-from-library-docs**
4. If context7 contradicts a source assumption:
   - Record the contradiction clearly
   - Recommend whether to update the source assumption or create a new ADR
   - Mark as **resolved-contradiction**

### 2c — Derive from Architectural Principles

If the answer can be logically derived from existing ADRs, documented
constraints, or established architectural principles:
- Record the reasoning chain
- Mark as **resolved-by-derivation**
- Note confidence level: high (single logical conclusion) or medium
  (reasonable inference, alternative exists)

### 2d — Mark as Requiring Human Decision

If the question cannot be resolved from available evidence:
- Summarize what is known and what the options are
- Recommend a preferred option with rationale
- Mark as **needs-human-decision**
- Do NOT invent an answer — the human must decide

---

## Phase 3 — Formulate ADR Candidates

For each resolved question that represents an architectural decision not
already captured in an existing ADR:

1. Determine if this decision warrants a new ADR:
   - Does it affect multiple arc42 sections?
   - Does it constrain future implementation choices?
   - Would a different team member plausibly make a different choice?
   If yes to any → recommend a new ADR
2. Draft the ADR recommendation:
   - Proposed ADR number (next in sequence)
   - Title
   - Context (the question and why it matters)
   - Decision (the resolution)
   - Consequences (what this enables and constrains)

Do NOT write the actual ADR file — that is the job of `/draft-adrs`.

---

## Phase 4 — Write Output

### 4a — Write `architecture/questions/resolved-questions.md`

```markdown
# Resolved Architecture Questions

**Generated:** [today's date]
**Resolved in this pass:** [N]
**Still open:** [N]

---

## Resolution Summary

| Question | Severity | Resolution Method | ADR Needed? |
|----------|----------|-------------------|-------------|
| Q-[N] | [blocking/important/clarification] | [method] | [yes/no] |

---

## Resolved Questions

### Q-[N]: [Question title]

- **Original severity:** [blocking / important / clarification]
- **Arc42 Section:** §[NN]
- **Resolution method:** [resolved-from-sources | resolved-from-library-docs |
  resolved-contradiction | resolved-by-derivation]
- **Answer:** [the resolution — clear, concise, actionable]
- **Evidence:**
  - [Source citation or context7 query and findings]
- **Confidence:** [high / medium]
- **ADR candidate:** [yes — ADR-NNN: "title" | no]
- **Impact on arc42:** [which section(s) this answer feeds into and how]

---

## ADR Candidates

Decisions that should be formalized as Architecture Decision Records
before proceeding to arc42 drafting.

### ADR-[NNN]: [Proposed title]

- **Triggered by:** Q-[N]
- **Context:** [why this decision matters]
- **Decision:** [what was decided]
- **Consequences:** [what this enables and constrains]

---

## Still Open

Questions that could not be resolved and require human decision.

### Q-[N]: [Question title]

- **What is known:** [summary of available evidence]
- **Options:**
  1. [Option A] — [pros/cons]
  2. [Option B] — [pros/cons]
- **Recommended:** [which option and why]
- **Needed from:** [architect / stakeholder / developer]
- **Blocks:** [which arc42 sections]
```

### 4b — Update `architecture/questions/open-questions.md`

Move resolved questions out of the open questions file. For each resolved
question:
- Remove it from its severity section
- Add a line in a new "Resolved" section at the bottom:
  `Q-[N] → resolved [date], see resolved-questions.md`
- Update the summary counts

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every question in scope has been attempted (resolved or marked needs-human-decision)
- [ ] No resolution contradicts an existing accepted ADR
- [ ] Library-based resolutions include context7 evidence
- [ ] Derivation-based resolutions include the reasoning chain
- [ ] ADR candidates are identified for significant decisions
- [ ] The open-questions file is updated to reflect resolved items
- [ ] Confidence levels are honest — medium means "an alternative exists"
- [ ] Still-open questions have concrete options and a recommendation
