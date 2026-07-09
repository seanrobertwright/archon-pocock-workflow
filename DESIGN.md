# Design: Matt Pocock Skills (v1.1) as an Archon Workflow Family

## What this is

An [Archon](https://github.com/coleam00/Archon) (v0.5, TypeScript workflow engine) workflow pack that encodes the end-to-end engineering flow from [Matt Pocock's skills](https://github.com/mattpocock/skills) at tag **v1.1.0**, as documented by his `ask-matt` router skill.

## Source-of-truth note (the "v1.1" question)

The `aurorasoft2/Matt_Pocock_Skills` fork does **not** contain v1.1 — it has no tags/releases and its `main` is a diverged v1.0-era snapshot (~4,400 lines behind). `v1.1.0` is a tag on upstream `mattpocock/skills`. This pack ships the **upstream v1.1.0** skill directories, copied into `.claude/skills/` (MIT, attribution in `LICENSE`; a local `vendor/` clone at the tag is the gitignored dev convenience used to produce/refresh the copies). v1.1 renames: `diagnose`→`diagnosing-bugs`, `to-prd`→`to-spec`, `to-issues`→`to-tickets`, `zoom-out`→`wayfinder`; and adds `implement`, `code-review`, `research`, `domain-modeling`, `codebase-design`, `prototype`, `wayfinder`, `handoff`, `ask-matt`, `grilling`, `teach`, `writing-great-skills`.

## Decisions (made 2026-07-08)

1. **Grilling stays interactive** — the misalignment fix is a human interview. `/grill-with-docs` + `/to-spec` run interactively in Claude Code; the resulting spec is the input artifact to the autonomous workflows. This matches Pocock's own context boundary ("keep grill→spec→tickets in one unbroken window; each `/implement` starts fresh").
2. **Full workflow family** — main flow plus all on-ramps, not just spec-to-ship.
3. **Mount real skills** — Archon nodes preload the actual v1.1.0 SKILL.md content via the per-node `skills:` field (resolved from `.claude/skills/`). Command files orchestrate; skills carry the discipline. Update path: `git -C vendor/Matt_Pocock_Skills fetch --tags && git checkout <new-tag>`, re-copy, re-validate.
4. **GitHub Issues** is the tracker — tickets are real issues with blocking edges, triage uses labels, `gh` CLI everywhere.

## The mapping

| Pocock (v1.1, per `ask-matt`) | This pack |
|---|---|
| `/setup-matt-pocock-skills` (precondition) | `pocock-init` workflow → `pocock-setup-docs` command (GitHub preset, defaults recorded) |
| `/grill-with-docs`, `/to-spec`, `/prototype`, `/handoff`, `/research` | **Interactive front-half** — installed as project skills, run in Claude Code before launching workflows |
| `/wayfinder` | Charting + grilling/prototype tickets stay interactive (HITL by the skill's own typing). The AFK slice — `wayfinder:research` and agent-driveable `wayfinder:task` tickets — is worked by `pocock-wayfinder-afk`: one ticket per fresh-context iteration, claim-by-assignment, resolution comment + close + map index update, fog graduation. It never touches grilling/prototype tickets and ends with a briefing of the HITL frontier left for the human |
| `/to-tickets` | `pocock-spec-to-ship` node `to-tickets` (self-review replaces the user quiz) |
| `/implement` per ticket, fresh context, driving `/tdd`, closing with `/code-review` | `implement-frontier` **loop node**, `fresh_context: true`, one frontier ticket per iteration; `until_bash` checks the run label has no open issues |
| `/code-review` two parallel sub-agents (Standards / Spec) | Two parallel **isolated nodes** (`review-standards`, `review-spec`) + `fix-findings` (axes never merged/reranked) |
| `/triage` on-ramp | `pocock-triage` — conservative AFK (never closes/wontfixes; recommends instead) |
| `/diagnosing-bugs` on-ramp | `pocock-fix-bug` — diagnose loop (threaded context, phases 1–4) → `pocock-diagnose-fix` (phases 5–6) → review → PR; architectural post-mortem finding auto-files an `architecture-candidate` issue |
| `/improve-codebase-architecture` health loop | `pocock-architecture-health` — survey half only; files `architecture-candidate` issues that feed back into interactive `/grill-with-docs` (ideas are grilled, not auto-implemented) |
| `/domain-modeling`, `/codebase-design` vocabulary layers | Mounted via `skills:` on the nodes that need them |

## AFK adaptations (each stays inside the skill's own rules)

- **to-tickets step 4** ("quiz the user") → written self-review in `$ARTIFACTS_DIR/tickets-review.md`. Justified: human alignment already happened in the grilling session that produced the spec.
- **triage** → verification, needs-info, and agent briefs are allowed; `wontfix`/close is never taken autonomously (the interactive skill waits for maintainer direction at exactly those points).
- **diagnosing-bugs phase 3** → the skill itself says "proceed with your ranking if the user is AFK"; the ranked list is recorded in the diagnosis artifact. If no feedback loop can be built, the loop exhausts and the workflow **fails on purpose** — matching "do not proceed to hypothesise without a loop".
- **architecture report** → written to `$ARTIFACTS_DIR/architecture-review.html` instead of the OS temp dir; the grilling loop half is not run.
- **User-invoked skills** (`disable-model-invocation: true`) can't be Skill-tool-invoked by nodes; non-loop nodes get their content injected via Archon's `skills:` field, and loop nodes (which ignore `skills:`) are instructed to `Read` the SKILL.md path directly.

## Ticket-frontier mechanics

`pocock-to-tickets` labels every created issue `workflow-$WORKFLOW_ID` and returns structured JSON (`run_label`, `tickets[]` with `blocked_by`). Each loop iteration recomputes the frontier (open tickets whose blockers are closed) from the tracker — the tracker is the state store, so a killed run resumes cleanly with `--resume` and iterations stay independent.

## Known limitations / watch items

- **Loop nodes and model selection**: node-level `model:` is ignored on loop nodes. Workflow-level `model: sonnet` is set everywhere, but if your `~/.archon/config.yaml` pins `claude: {model: haiku}` (it currently does), confirm loops actually run on the workflow-level model — heavy implement/diagnose loops should not run on haiku.
- `$WORKFLOW_ID` substitution inside `until_bash` is assumed to work like other bash fields; if a run's `until_bash` never fires, the `<promise>FRONTIER_CLEAR</promise>` path still terminates the loop correctly.
- `pocock-triage` and `pocock-architecture-health` should run with `--no-worktree` (they write to the tracker / artifacts, not the tree). `pocock-init` too.
- The pack assumes `gh` is authenticated and Git Bash is available (Archon bash nodes run `bash -c`).
- Windows symlink caveat: skills are **copied**, not symlinked (upstream's `link-skills.sh` approach doesn't survive Windows well). Re-run the installer after bumping the vendor tag.

## Flow of a feature, end to end

1. **Interactive** (Claude Code, one unbroken context): `/grill-with-docs` → optional `/prototype` detour via `/handoff` → `/to-spec` publishes the spec as a GitHub issue.
2. **AFK**: `archon workflow run pocock-spec-to-ship --branch feat/<name> "#<spec-issue>"`.
3. Review the PR. Deferred review findings and architecture candidates surface as labeled issues that re-enter step 1.
