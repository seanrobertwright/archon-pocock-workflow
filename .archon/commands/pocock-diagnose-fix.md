---
description: Phases 5-6 of /diagnosing-bugs — regression test first, fix, cleanup, post-mortem
argument-hint: (no arguments - reads $ARTIFACTS_DIR/diagnosis.md)
---

# Fix + Regression Test + Post-Mortem

**Workflow ID**: $WORKFLOW_ID

You are completing a diagnosis produced by an upstream loop. The `diagnosing-bugs` skill is preloaded (otherwise read `.claude/skills/diagnosing-bugs/SKILL.md`) — you are executing its **Phase 5 (Fix + regression test)** and **Phase 6 (Cleanup + post-mortem)**.

## Phase 1: LOAD

Read `$ARTIFACTS_DIR/diagnosis.md`. It must contain: the red-capable feedback-loop command (already run at least once, with output), the minimised repro, and the confirmed hypothesis. If any of those are missing, stop and report the gap — do not guess a fix without a diagnosis.

## Phase 2: FIX (skill Phase 5)

Follow the skill exactly: regression test **before** the fix, but only at a **correct seam**. If no correct seam exists, that is itself the finding — document it, still apply the fix, and flag the architectural gap. Otherwise: failing test → watch it fail → fix → watch it pass → re-run the original un-minimised feedback loop.

## Phase 3: CLEANUP (skill Phase 6)

Work the skill's checklist: original repro green, regression test in (or seam absence documented), all `[DEBUG-...]` instrumentation removed (grep the prefix), throwaway harnesses deleted, and the confirmed hypothesis stated in the commit message. Commit to the current branch.

Then answer the skill's closing question — what would have prevented this bug? If the answer is architectural (no good seam, tangled callers, hidden coupling), say so explicitly: the workflow will file it as a candidate for `/improve-codebase-architecture`.

## Phase 4: REPORT

Write `$ARTIFACTS_DIR/postmortem.md`: symptom, confirmed hypothesis, the fix, the regression seam (or documented absence), and the prevention recommendation. Your final output MUST be the structured JSON the workflow requires: `architectural_followup` (`yes`/`no`) and `reason`.
