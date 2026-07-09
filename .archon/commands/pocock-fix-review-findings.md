---
description: Aggregate the two review axes side by side, fix what warrants fixing, re-validate, and commit
argument-hint: (no arguments - reads $ARTIFACTS_DIR/review/)
---

# Fix Review Findings

**Workflow ID**: $WORKFLOW_ID

## Phase 1: LOAD

Read `$ARTIFACTS_DIR/review/standards.md` and `$ARTIFACTS_DIR/review/spec.md`, plus `$ARTIFACTS_DIR/validation.md` if present. Per the `code-review` skill: the two axes stay separate — do NOT merge or rerank findings across axes; a Standards pass never excuses a Spec fail or vice versa.

## Phase 2: DECIDE

Classify each finding:

- **Fix now** — hard standards violations, missing/wrong spec requirements, scope creep that's cheap to remove
- **Judgement call, adopt** — baseline smells whose fix is small and clearly improves the diff
- **Defer** — judgement calls that would widen the change; record them instead of fixing

## Phase 3: FIX

Apply the "fix now" and adopted findings. For behaviour changes, work test-first per the preloaded `tdd` skill (or `.claude/skills/tdd/SKILL.md`) at the seams the tickets agreed. Re-run the validation commands recorded in `$ARTIFACTS_DIR/validation.md` until green.

Commit the fixes to the current branch with a message summarizing which findings were addressed.

### PHASE_3_CHECKPOINT
- [ ] Every "fix now" finding addressed or explicitly downgraded with a reason
- [ ] Validation green
- [ ] Fixes committed

## Phase 4: REPORT

Write `$ARTIFACTS_DIR/review/resolution.md`: findings fixed, findings deferred (with reasons) under separate `## Standards` / `## Spec` headings, ending with the skill's one-line summary — total findings per axis and the worst issue within each axis. No single winner across axes. End your output with that same summary line.
