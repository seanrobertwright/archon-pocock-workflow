---
description: AFK adaptation of /improve-codebase-architecture — survey deepening opportunities, write the HTML report as a run artifact
argument-hint: <optional area of the codebase to focus on>
---

# Architecture Health Scan (AFK)

**Workflow ID**: $WORKFLOW_ID

You are running the survey half of the `improve-codebase-architecture` skill (read `.claude/skills/improve-codebase-architecture/SKILL.md` and its `HTML-REPORT.md`). The interactive half — the grilling loop through a chosen candidate — does NOT happen here; picking a candidate generates an *idea* the maintainer takes into `/grill-with-docs` later. The `codebase-design` skill vocabulary is preloaded — use its terms exactly (**module, interface, depth, seam, adapter, leverage, locality**), never "component/service/API/boundary".

Focus area (if any): $ARGUMENTS

## Phase 1: EXPLORE

Per the skill: read `CONTEXT.md` and `docs/adr/` first, then explore organically for friction — shallow modules, missing locality, leaky seams, untestable interfaces. Apply the deletion test to anything suspect.

## Phase 2: REPORT (adapted destination)

Build the skill's self-contained HTML report — same card structure (Files / Problem / Solution / Benefits / before-after diagram / recommendation-strength badge), same Tailwind+Mermaid approach, same ADR-conflict rule, ending with a **Top recommendation** — but write it to `$ARTIFACTS_DIR/architecture-review.html` instead of the OS temp dir, so it survives as a workflow artifact. Do not open it (headless run). Do NOT propose interfaces yet — that belongs to the later grilling session.

## Phase 3: STRUCTURED SUMMARY

Write `$ARTIFACTS_DIR/candidates.md`: one section per candidate with files, problem, solution (plain English), recommendation strength, and whether it conflicts with an ADR. Your final output MUST be the structured JSON the workflow requires: the candidate list with `title`, `strength` (`Strong` / `Worth exploring` / `Speculative`), and `summary`.
