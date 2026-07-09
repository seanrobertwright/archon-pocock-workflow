---
description: Break a spec into tracer-bullet GitHub issues with blocking edges (AFK adaptation of /to-tickets)
argument-hint: <spec issue number, spec file path, or inline spec text>
---

# To Tickets (AFK)

**Workflow ID**: $WORKFLOW_ID

You are running the `to-tickets` skill non-interactively. Its content has been preloaded into your context (or read `.claude/skills/to-tickets/SKILL.md`) — follow it exactly, with one adaptation: **step 4 ("Quiz the user") becomes a self-review pass**, because the human alignment already happened during the interactive grilling/spec session that produced this spec.

## Phase 1: LOAD

The spec reference is: $ARGUMENTS

- If it is or contains an issue number/URL: fetch the full body **and all comments** via `gh issue view <n> --comments`
- If it is a file path: read the file
- Otherwise treat the text itself as the spec

Also read `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, and `CONTEXT.md` (if present) — ticket titles and descriptions must use the project's domain glossary vocabulary, and respect ADRs in `docs/adr/` for the areas touched.

## Phase 2: EXPLORE

Follow the skill's step 2: explore the codebase, look for prefactoring opportunities ("make the change easy, then make the easy change").

## Phase 3: DRAFT + SELF-REVIEW

Draft the tracer-bullet vertical slices per the skill's `<vertical-slice-rules>`, including the wide-refactor expand–contract exception, each ticket declaring its blocking edges.

Then run the skill's step-4 quiz **against yourself**, in writing, in `$ARTIFACTS_DIR/tickets-review.md`:

- Is each slice vertical (schema→API→UI→tests), demoable alone, and sized for one fresh context window?
- Are the blocking edges minimal — does each ticket depend only on tickets that genuinely gate it?
- Should any ticket be merged or split?

Revise the breakdown based on your own answers before publishing.

## Phase 4: PUBLISH

Publish per the skill's step 5, GitHub branch: one issue per ticket in dependency order (blockers first), using the skill's `<issue-template>`. Use native blocking relationships where available; otherwise the "Blocked by" section referencing real issue numbers. Apply the `ready-for-agent` label (mapped per `docs/agents/triage-labels.md`). Reference the parent spec issue if there is one; do NOT close or modify it. Avoid file paths and code snippets except decision-rich prototype output, per the skill.

Also add a label `workflow-$WORKFLOW_ID` to every ticket you create (create the label first with `gh label create "workflow-$WORKFLOW_ID" --force`), so downstream nodes can find exactly this run's frontier.

### PHASE_4_CHECKPOINT
- [ ] All tickets published, blockers first
- [ ] Every ticket labeled `ready-for-agent` (mapped string) and `workflow-$WORKFLOW_ID`
- [ ] Parent spec issue untouched

## Phase 5: REPORT (structured)

Write `$ARTIFACTS_DIR/tickets.md` listing every ticket (number, title, blocked-by). Your final output MUST be the structured JSON the workflow requires: the run label and the full ticket list.
