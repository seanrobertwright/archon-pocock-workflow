# Tutorial: Building "FlowBoard" — an elaborate Kanban app — with the Pocock workflow family

This tutorial walks a real project from empty repo to shipping PRs using:

- **The `archon` skill** in Claude Code — say "use archon to…" and Claude drives the CLI for you
- **The interactive front-half skills** — `/grill-with-docs`, `/prototype`, `/to-spec`, `/wayfinder`
- **The six AFK workflows** — `pocock-init`, `pocock-spec-to-ship`, `pocock-wayfinder-afk`, `pocock-triage`, `pocock-fix-bug`, `pocock-architecture-health`

**What we'll build:** *FlowBoard* — a Kanban/TODO app with boards, columns, drag-and-drop cards, WIP limits, labels, due dates, filters, and an activity log. Elaborate enough that you'll touch every workflow in the family.

**The rhythm you'll learn** (this is the whole method):

> **Think together, interactively. Ship disciplined, AFK.**
> Grilling, specs, and design decisions happen with you in the loop.
> Tickets, TDD, validation, review, and PRs happen while you're away.

---

## Part 0 — Setup (once per repo)

### 0.1 Prerequisites

- [Archon](https://github.com/coleam00/Archon) CLI installed (`archon help` works) — v0.5+
- `gh` CLI authenticated (`gh auth status`)
- Claude Code with a strong model (check `~/.archon/config.yaml` → `assistants.claude.model` — the implement and diagnose loops should **not** run on haiku)

### 0.2 Create the repo and install the pack

```bash
mkdir flowboard && cd flowboard
git init -b main
gh repo create flowboard --private --source . --push
```

Install the workflow pack (from your clone of this repo):

```powershell
../archon-pocock-workflow/install.ps1 -TargetRepo .
```

You now have `.archon/workflows/pocock-*.yaml`, `.archon/commands/pocock-*.md`, and 18 skills in `.claude/skills/`. Verify:

```bash
archon validate workflows && archon validate commands
```

### 0.3 Initialize the Pocock config

```bash
archon workflow run pocock-init --no-worktree ""
```

This is the non-interactive port of `/setup-matt-pocock-skills`. It scaffolds:

- `docs/agents/issue-tracker.md` — GitHub Issues, via `gh`
- `docs/agents/triage-labels.md` — the five state labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), created on the repo
- `docs/agents/domain.md`, a `CONTEXT.md` stub, `docs/adr/`
- An `## Agent skills` block in `CLAUDE.md`

Read the setup report in the run's artifacts — every defaulted decision is listed so you can revise it.

> **Tip — drive it from Claude Code instead:** the `archon` skill triggers on natural language. In Claude Code, just say:
> *"use archon to run pocock-init on this repo"*
> Claude invokes the skill, runs the workflow in the background, and reports when it's done.

---

## Part 1 — THINK: from idea to spec (interactive, one unbroken context)

Everything in this part happens in **one Claude Code session**. Don't clear or compact until the spec is published — the grilling, domain language, and spec must build on the same thinking.

### 1.1 Grill the idea

In Claude Code, in the flowboard repo:

```
/grill-with-docs I want an elaborate Kanban/TODO app: multiple boards, columns
with WIP limits, drag-and-drop cards with labels and due dates, saved filters,
and an activity log. Local-first, single user for now. Bun + React + SQLite.
```

The agent will interrogate you one question at a time. Expect (and welcome) questions like:

- *"When a column is at its WIP limit and a card is dragged in — reject the drop, allow-but-flag, or bump the oldest card?"*
- *"Is the activity log an audit trail (immutable, everything) or a feed (recent, human-readable)?"*
- *"Can a card exist on two boards? What does 'board' actually own?"*
- *"'Filter' — saved per board or global? Does a filter hide cards or dim them?"*

Two things happen as you answer:

1. **`CONTEXT.md` grows a glossary.** By the end you'll have precise terms — e.g. *Board*, *Column*, *Card*, *WIP limit* (a Column constraint, enforced on drop, reject-with-toast), *Saved Filter* (per-Board, hides), *Activity Entry* (immutable audit record). From now on, every skill, ticket, and commit uses these words — this is the verbosity fix.
2. **Hard-to-reverse decisions become ADRs.** e.g. `docs/adr/0001-sqlite-single-file-storage.md`, `0002-wip-limit-rejects-drops.md`. Future workflows *respect these without re-litigating them*.

### 1.2 Detour to a prototype when talk isn't enough

Drag-and-drop state is exactly the kind of question you can't settle in prose (what happens mid-drag across columns with a WIP-limited target?). Take Pocock's detour:

```
/handoff        ← compacts this conversation to a handoff file
```

Open a **fresh** session:

```
/prototype Using the handoff file at .scratch/handoff-flowboard.md — answer one
question: does a reducer with explicit DragState (idle → lifting → hovering(col)
→ dropped|rejected) feel right for WIP-limit rejection?
```

Keep the answer, delete the code, `/handoff` the findings back, and continue the original thread referencing the file.

### 1.3 Publish the spec

Back in the main session, when grilling has resolved every branch:

```
/to-spec
```

This synthesizes the conversation into a spec and publishes it as a GitHub issue — say it lands as **issue #1, "FlowBoard v1: boards, cards, WIP limits, filters, activity log"**. The spec is the **handoff artifact**: the human context ends here.

> **Scope tip:** for an app this size, aim the first spec at a walking skeleton — boards/columns/cards CRUD + drag-and-drop + WIP limits. Filters and the activity log can be spec #2; you'll have the domain language already.

---

## Part 2 — SHIP: spec to PR, AFK

### 2.1 Launch the main workflow

From the terminal:

```bash
archon workflow run pocock-spec-to-ship --branch feat/flowboard-v1 "#1"
```

Or from Claude Code, via the archon skill:

```
use archon to run pocock-spec-to-ship on issue #1, branch feat/flowboard-v1
```

(The skill runs it in the background in an isolated git worktree; ask Claude "how's the archon run doing?" anytime.)

### 2.2 What happens while you're away

1. **`to-tickets`** — the spec becomes tracer-bullet GitHub issues, each a *vertical slice* (schema → API → UI → tests) with blocking edges. For FlowBoard v1, expect something like:
   - *Card CRUD walking skeleton* (no blockers)
   - *Columns with ordering* (blocked by skeleton)
   - *Drag-and-drop between columns* (blocked by columns)
   - *WIP limit enforcement on drop* (blocked by drag-and-drop)
   Each is labeled `ready-for-agent` + a run label so the loop can find its own frontier. The skill's "quiz the user" step runs as a written self-review (you already aligned during grilling).
2. **`implement-frontier`** — the heart. One ticket per **fresh context window**: find the frontier (open tickets whose blockers are closed), pick one, implement it with `/tdd` (red before green, tests only at the ticket's acceptance-criteria seams — e.g. the `moveCard` API seam, not the reducer internals), run a per-ticket two-axis review, commit referencing the ticket, close it. Repeat until the frontier is clear.
3. **`validate`** — discovers and runs the repo's real suite (what CI runs); a make-green loop fixes failures without weakening tests.
4. **Two-axis final review** — two *isolated, parallel* nodes: **Standards** (repo standards + Fowler smell baseline) and **Spec** (does the diff faithfully implement issue #1 — missing requirements, scope creep, wrong implementations). Findings are fixed; the axes are never merged or reranked.
5. **`create-pr`** — a PR titled in your CONTEXT.md vocabulary, `Closes #…` per ticket, review summary and deferred findings included.

### 2.3 Your job when it's done

Review the PR like a human: pull the branch, run the app, drag a card into a full column and watch the reject-toast your ADR specified. Merge when satisfied. Deferred review findings are already filed as issues.

Then loop back to **Part 1** with spec #2 (filters + activity log) — it will go faster: the glossary and ADRs already exist.

---

## Part 3 — The foggy feature: wayfinder + pocock-wayfinder-afk

Now the elaborate part: you want **real-time multi-user collaboration** (shared boards, live card movement, presence). Too big and too foggy for one grilling session — this is wayfinder territory.

### 3.1 Chart the map (interactive)

```
/wayfinder FlowBoard should support real-time multi-user collaboration on
shared boards. I don't know yet: sync model, conflict handling, auth, or
whether SQLite survives this.
```

One session charts the map: a `wayfinder:map` issue with a **Destination** (e.g. "a spec for collaborative boards we can hand to /to-spec"), child tickets typed `wayfinder:research` / `wayfinder:grilling` / `wayfinder:prototype` / `wayfinder:task`, blocking edges, and the un-ticketable fog written into *Not yet specified*. Say it lands as **issue #40**.

### 3.2 Clear the AFK frontier overnight

```bash
archon workflow run pocock-wayfinder-afk --no-worktree "#40"
```

The workflow works **only** the AFK slice of the frontier — e.g.:

- *"CRDT vs server-authoritative sync for Kanban-shaped data"* (`wayfinder:research`) → cited markdown in `docs/research/`, resolution comment, ticket closed, map index updated
- *"Can better-sqlite3 handle N concurrent writers?"* (`wayfinder:research`) → same

It **never touches** grilling or prototype tickets — those are human-in-the-loop by the skill's own rules — and it ends with a briefing: what was resolved, what graduated from the fog, and the HITL frontier waiting for you.

### 3.3 Resume as a human, informed

Next morning, run `/wayfinder #40` — the grilling tickets you now face are answerable because the research legwork is done. When the map's way is clear: `/to-spec` → `pocock-spec-to-ship`. The circle closes.

---

## Part 4 — Living with the app: the on-ramps

### Bugs arrive → `pocock-fix-bug`

A user reports: *"dragging a card fast between columns sometimes duplicates it."* Classic hard bug — intermittent, timing-dependent.

```bash
archon workflow run pocock-fix-bug --branch fix/card-duplication "#57"
```

The diagnose loop **refuses to theorize** until it has a red-capable feedback loop (for this bug, likely a Playwright script looping the drag 100× to raise the reproduction rate), then minimises, ranks falsifiable hypotheses, instruments one variable at a time, writes the regression test *before* the fix, and PRs with the confirmed hypothesis in the message. If the post-mortem finds there was *no good seam* to lock the bug down — say, drag state is smeared across three components — it auto-files an `architecture-candidate` issue.

### The queue fills up → `pocock-triage`

```bash
archon workflow run pocock-triage --no-worktree ""
```

Runs the triage state machine conservatively: verifies claims (actually reproduces reported bugs), applies `needs-info` with specific questions, writes agent briefs for what's delegable — and **never closes anything**; wontfix candidates come back as recommendations with evidence. Issues that reach `ready-for-agent` are exactly what `pocock-fix-bug` and `pocock-spec-to-ship` consume.

### Every few days → `pocock-architecture-health`

```bash
archon workflow run pocock-architecture-health --no-worktree ""
```

Surveys for shallow modules and missing seams in `codebase-design` vocabulary, renders an HTML report into the run artifacts, and files the strongest candidates as `architecture-candidate` issues. Those are **ideas**, not work orders — take one into `/grill-with-docs` and it re-enters the flow at Part 1. (Pocock: run this "once every few days." It's `--no-worktree` and read-only, so it's safe to schedule.)

---

## Cheat sheet

| Situation | Do this | Mode |
|---|---|---|
| New feature idea | `/grill-with-docs` → (`/prototype` detour) → `/to-spec` | Interactive |
| Spec exists, build it | `pocock-spec-to-ship --branch feat/x "#N"` | AFK |
| Huge foggy effort | `/wayfinder` to chart → `pocock-wayfinder-afk "#map"` overnight → `/wayfinder` again | Mixed |
| Something's broken | `pocock-fix-bug --branch fix/x "#N"` | AFK |
| Issue queue piling up | `pocock-triage --no-worktree ""` | AFK |
| Codebase upkeep | `pocock-architecture-health --no-worktree ""` | AFK, schedulable |
| New repo | `install.ps1` → `pocock-init --no-worktree ""` | AFK |

**Worktree rule of thumb:** anything that writes *code* gets `--branch` (isolated worktree); anything that writes only to the *tracker or artifacts* gets `--no-worktree`.

## Troubleshooting

- **A workflow failed midway** → fix the cause, then `archon workflow run <name> --resume` — completed nodes are skipped.
- **`pocock-fix-bug` failed at the diagnose node** → that's by design when no feedback loop could be built. Read the last iteration's output for what was tried, attach a repro artifact (HAR, trace, recording) to the issue, and `--resume`.
- **Implement loop feels dumb** → check `~/.archon/config.yaml`: loop nodes can fall back to your configured Claude model; if that's `haiku`, raise it.
- **"MISSING docs/agents/…" errors** → run `pocock-init` first; every workflow checks the config docs before doing anything.
- **Watch a run live** → `archon serve` and open the web dashboard, or `archon workflow status`.
