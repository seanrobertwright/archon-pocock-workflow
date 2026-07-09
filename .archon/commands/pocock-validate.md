---
description: Discover and run the repo's full validation suite (typecheck, lint, tests, build)
argument-hint: (no arguments - reads from workflow artifacts)
---

# Validate

**Workflow ID**: $WORKFLOW_ID

## Phase 1: DISCOVER

Find the project's real validation commands. Check in order: `CLAUDE.md`/`AGENTS.md` instructions, `package.json` scripts, `Makefile`/`justfile`, CI workflow files (`.github/workflows/*.yml`), language conventions (`cargo test`, `pytest`, `go test ./...`, `bun test`, etc.). Prefer what CI runs — that is the repo's definition of green.

## Phase 2: RUN

Run, in order: typecheck, lint, full test suite, and build if CI builds. Record every failure with file path and error message. Do not fix anything in this step.

## Phase 3: REPORT

Write `$ARTIFACTS_DIR/validation.md` with pass/fail per check, the exact commands used, error details for failures, and a final line: `VERDICT: GREEN` or `VERDICT: RED`. End your output with that verdict line and the command list (downstream fix nodes reuse them).
