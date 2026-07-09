---
description: Non-interactive port of /setup-matt-pocock-skills — scaffold issue-tracker config, triage labels, and domain docs (GitHub preset)
argument-hint: (no arguments, or overrides like "PRs as request surface: yes")
---

# Setup Pocock Skills Config (AFK, GitHub preset)

**Workflow ID**: $WORKFLOW_ID

You are running a non-interactive adaptation of the `setup-matt-pocock-skills` skill. Read `.claude/skills/setup-matt-pocock-skills/SKILL.md` first — it is the source of truth for what this step scaffolds. Where that skill would ask the user, apply the defaults below instead, and record every defaulted decision in your final report.

## Defaults (applied where the skill would ask)

- **Issue tracker**: GitHub (this workflow family targets GitHub Issues via the `gh` CLI)
- **PRs as a request surface**: no — unless `$ARGUMENTS` says otherwise
- **Triage label strings**: canonical names (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) — unless existing repo labels clearly map to the same roles, in which case map to the existing strings rather than creating duplicates
- **Domain docs layout**: single-context (`CONTEXT.md` + `docs/adr/` at repo root) — unless a `CONTEXT-MAP.md` already exists, which means multi-context

## Phase 1: EXPLORE

Follow the skill's step 1 exactly: check `git remote -v`, `CLAUDE.md`/`AGENTS.md`, `CONTEXT.md`/`CONTEXT-MAP.md`, `docs/adr/`, `docs/agents/`, `.scratch/`, and existing GitHub labels (`gh label list`).

If `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, and `docs/agents/domain.md` all already exist, verify they are consistent, report "already configured", and stop — do not overwrite user edits.

## Phase 2: WRITE

Following the skill's step 4 rules (edit `CLAUDE.md` if it exists, else `AGENTS.md`; if neither exists, create `CLAUDE.md` since this is an agent-driven repo; update an existing `## Agent skills` block in place):

1. Write `docs/agents/issue-tracker.md` from `.claude/skills/setup-matt-pocock-skills/issue-tracker-github.md`
2. Write `docs/agents/triage-labels.md` from `.claude/skills/setup-matt-pocock-skills/triage-labels.md`, with the label mapping decided in Phase 1
3. Write `docs/agents/domain.md` from `.claude/skills/setup-matt-pocock-skills/domain.md`
4. Ensure every triage-label string chosen in Phase 1 exists on the repo (`gh label create <string> --force` only for labels that don't exist; never rename existing labels)
5. Add/update the `## Agent skills` block per the skill's template
6. If `CONTEXT.md` does not exist, create a minimal stub with a `## Language` section (do not invent domain terms — leave it nearly empty; the interactive `/grill-with-docs` sessions populate it)
7. Ensure `docs/adr/` exists (add a `.gitkeep` if empty)

### PHASE_2_CHECKPOINT
- [ ] Three `docs/agents/*.md` files written
- [ ] `## Agent skills` block present in exactly one of CLAUDE.md/AGENTS.md
- [ ] `CONTEXT.md` and `docs/adr/` exist

## Phase 3: REPORT

Write `$ARTIFACTS_DIR/setup-report.md` listing: every file written or updated, every defaulted decision (so the maintainer can revise), and every existing-label mapping chosen. End your output with a short summary of the same.
