---
description: Standards axis of the two-axis /code-review — repo coding standards + Fowler smell baseline over the branch diff
argument-hint: (no arguments - reviews $BASE_BRANCH...HEAD)
---

# Code Review — Standards Axis

**Workflow ID**: $WORKFLOW_ID

You are ONE axis of the two-axis `code-review` skill (its content is preloaded; otherwise read `.claude/skills/code-review/SKILL.md`). You run the **Standards** axis only. A sibling node runs the Spec axis in parallel — deliberately isolated from you so neither pollutes the other. Do not evaluate spec faithfulness.

## Phase 1: PIN

The fixed point is `$BASE_BRANCH`. Confirm it resolves (`git rev-parse $BASE_BRANCH`) and that `git diff $BASE_BRANCH...HEAD` is non-empty. Note the commit list (`git log $BASE_BRANCH..HEAD --oneline`). If the diff is empty, report that and stop.

## Phase 2: SOURCES

Gather the repo's documented standards (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, style sections of `CLAUDE.md`/`AGENTS.md`) plus the skill's fixed Fowler smell baseline. Rules that bind: the repo overrides the baseline; every smell is a labelled judgement call, never a hard violation; skip anything tooling already enforces.

## Phase 3: REVIEW

Work through the full diff. Report — per file/hunk where relevant — (a) every place the diff violates a documented standard, citing the standard (file + rule); (b) any baseline smell, named, with the hunk quoted. Distinguish hard violations from judgement calls.

## Phase 4: REPORT

Write `$ARTIFACTS_DIR/review/standards.md` (create the directory) with the findings under `## Standards`, each finding marked `[hard]` or `[judgement]`. Keep it under 400 words. End your output with: `STANDARDS_FINDINGS: <count-hard> hard / <count-judgement> judgement`.
