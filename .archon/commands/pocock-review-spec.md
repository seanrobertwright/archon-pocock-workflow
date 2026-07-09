---
description: Spec axis of the two-axis /code-review — does the branch diff faithfully implement the originating spec?
argument-hint: <spec issue number or path> (falls back to artifacts / commit-message references)
---

# Code Review — Spec Axis

**Workflow ID**: $WORKFLOW_ID

You are ONE axis of the two-axis `code-review` skill (its content is preloaded; otherwise read `.claude/skills/code-review/SKILL.md`). You run the **Spec** axis only. A sibling node runs the Standards axis in parallel — deliberately isolated from you. Do not evaluate coding standards or smells.

## Phase 1: PIN

The fixed point is `$BASE_BRANCH`. Confirm it resolves and `git diff $BASE_BRANCH...HEAD` is non-empty. Note the commit list.

## Phase 2: FIND THE SPEC

Locate the originating spec, in the skill's order:

1. The workflow argument, if it names an issue or path: $ARGUMENTS
2. `$ARTIFACTS_DIR/tickets.md` (this run's tickets) and the parent spec issue it references
3. Issue references in the commit messages (`#123`, `Closes #45`) — fetch via `gh issue view <n> --comments`
4. A PRD/spec file under `docs/`, `specs/`, or `.scratch/` matching the branch or feature

If nothing is found, skip the review and report exactly: `SPEC_FINDINGS: no spec available`.

## Phase 3: REVIEW

Compare the diff against the spec. Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding.

## Phase 4: REPORT

Write `$ARTIFACTS_DIR/review/spec.md` (create the directory) with the findings under `## Spec`. Under 400 words. End your output with: `SPEC_FINDINGS: <count>` (or the no-spec line above).
