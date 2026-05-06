# Discover Architecture Questions

You are identifying open questions, ambiguities, and contradictions that must be
resolved before the arc42 architecture documentation can be written with confidence.
The scope is: $ARGUMENTS

If no arguments are provided, default to analyzing all arc42 sections (§01–§12).
If arguments are arc42 section numbers (e.g., "01 03 05"), limit analysis to those sections.

**You MUST enter plan mode and use ultrathink (extended thinking) for this entire task.**

**This command produces ONLY `architecture/questions/open-questions.md`.
Do NOT create, modify, or write any other files.**

---

## Phase 1 — Load Source Context

1. Read `docs/arc42/00-source-inventory.md` — this is your primary reference
   for what sources exist, what they cover, and where contradictions were found
2. Read the contradictions and gaps sections carefully — these are your
   starting points for questions
3. For each arc42 section in scope, identify the source documents that inform
   it (from the coverage map)
4. Read those source documents thoroughly

If the source inventory doesn't exist, stop and instruct the user to run
`/ingest-sources` first.

---

## Phase 2 — Identify Questions from Source Gaps

For each arc42 section in scope:

1. **What do the sources cover?** List the claims extracted in the source
   inventory for this section.
2. **What does this arc42 section require?** Based on the arc42 template,
   what information must be present?
3. **What's missing?** The delta between what's required and what the sources
   provide becomes questions.

Categorize each gap:
- **Architectural decision needed** — no source addresses this choice
- **Ambiguity** — sources hint at an answer but don't commit
- **Stakeholder input required** — the answer depends on business/org context
  that sources don't contain
- **Library/technology verification needed** — a source makes an assumption
  about a library that should be validated against current documentation

---

## Phase 3 — Identify Questions from Contradictions

For each contradiction flagged in the source inventory:

1. State both conflicting claims with their sources
2. Determine if a supersession chain resolves it (later document overrides earlier)
3. If unresolved, formulate a question: "Which approach applies: A or B?"
4. Note what evidence would resolve the contradiction

---

## Phase 4 — Validate Library Assumptions with context7

For each question tagged as "library/technology verification needed":

1. Use context7 MCP to query the relevant library's documentation:
   - First resolve the library ID: `resolve-library-id` for the technology
   - Then query specific capabilities: `query-docs` with targeted questions
2. Record what context7 says — does it confirm, contradict, or not address
   the source's assumption?
3. If context7 confirms: mark the question as **auto-resolved** with evidence
4. If context7 contradicts: escalate to **blocking** — the source assumption
   is wrong
5. If context7 is silent: mark as **needs manual verification**

Technologies to check (based on this project's stack):
- FastMCP (MCP server framework)
- Amazon Bedrock (LLM provider)
- Keycloak (OAuth 2.1 / token exchange)
- Valkey (session/cache store)
- OpenTelemetry (tracing)
- PostgreSQL (persistence)
- Any other library referenced in source documents

---

## Phase 5 — Write Output

Write to `architecture/questions/open-questions.md`:

```markdown
# Architecture Open Questions

**Generated:** [today's date]
**Scope:** [which arc42 sections were analyzed]
**Source inventory:** `docs/arc42/00-source-inventory.md`

---

## Summary

| Severity | Count |
|----------|-------|
| Blocking (must resolve before drafting) | [N] |
| Important (should resolve before drafting) | [N] |
| Clarification (can resolve during drafting) | [N] |
| Auto-resolved (answered by library docs) | [N] |
| **Total** | **[N]** |

---

## Auto-Resolved Questions

Questions that were answered by querying library documentation via context7.
These do not require human input but are documented for traceability.

### Q-AR-[N]: [Question title]

- **Arc42 Section:** §[NN]
- **Source assumption:** [what the source document claims] — [source path]
- **Library:** [library name]
- **context7 finding:** [what the documentation actually says]
- **Resolution:** [confirmed / corrected]
- **Evidence:** [context7 query and key quotes]

---

## Blocking Questions

Must be resolved before the affected arc42 section(s) can be drafted.

### Q-[N]: [Question title]

- **Arc42 Section:** §[NN]
- **Category:** [architectural-decision | contradiction | stakeholder-input | library-verification]
- **What sources say:** [summary with citations]
- **What's missing or conflicting:** [the gap or contradiction]
- **Suggested resolution:** [if you can propose one based on available evidence]
- **Who should answer:** [architect | developer | stakeholder | library docs]
- **Blocks:** [which arc42 sections cannot be drafted without this answer]

---

## Important Questions

Should be resolved before drafting for quality, but sections can be drafted
with assumptions noted.

### Q-[N]: [Question title]

[Same structure as blocking]

---

## Clarification Questions

Can be resolved during drafting — the answer doesn't change the section's
structure, only details.

### Q-[N]: [Question title]

[Same structure as blocking]
```

---

## Quality Checklist

Before finalizing, verify:
- [ ] Every arc42 section in scope has been analyzed for completeness
- [ ] Every contradiction from the source inventory has a corresponding question
- [ ] Every "none" or "sparse" coverage section has at least one question
- [ ] Library assumptions have been checked against context7 where possible
- [ ] Each question has a clear severity classification
- [ ] Questions that block other sections are identified in the "Blocks" field
- [ ] Auto-resolved questions include the context7 evidence
- [ ] No question is answerable from existing source documents (those should
  be answers, not questions)
