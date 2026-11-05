---
name: {{p}}-to-tickets
description: Split a task's approved plan (.ai/tasks/<key>-N-<slug>/plan.md + agent.md) into commit-sized ticket files under tickets/ and a map of batches, each part ending with its E2E and manual check tickets when the plan has such checks.
disable-model-invocation: true
---

# To tickets

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands». Actors: `docs/agents/product.md` «Actors».

Break the approved plan into **tickets**: one ticket = one commit, at most 100 lines of production code
(`docs/agents/stack.md` «Line count»). The developer approved the plan; tickets slice it and add no new decisions.

## Process

### 1. Gather context

Read `plan.md` (its `Criteria` are the acceptance criteria, its `Checks` the tests), `agent.md` and `research.md` from
the task folder. Ask for the key if the folder is unclear. `plan.md` says `Delivery: commits` → stop: the task goes to
`/{{p}}-develop` without tickets.

### 2. Draft tickets

- Slice along `agent.md` «What to fix». Every commit keeps the product working. Layer slices are fine while the new
  code is unreachable — the ticket that wires it into a handler comes last in its part.
- Estimate lines per ticket. Over 100 lines → split at a seam where each part keeps its own acceptance criterion; no
  such seam → the ticket stays whole.
- A step with no acceptance criterion of its own (a helper or refactor only the next ticket uses) folds into that
  ticket.
- The rules of `docs/agents/code-rules.md` «Ticket slicing».
- Each line of `plan.md` «Checks» lands in exactly one ticket, by its mark:
  - `new` / `extend existing` → the `Tests` of the development ticket whose edit it checks;
  - `e2e` → the part's E2E ticket;
  - `manual` → the part's check ticket;
  - `none` → no ticket.
- A development ticket's **Mode** follows from its lines: any `new` / `extend existing` line → `TDD`; none → `no tests`.
  A ticket that changes behaviour and has no check line is a gap in the plan, not a `no tests` ticket.
- A ticket where one part is `TDD` and another `no tests`, and the parts can be delivered and committed separately →
  split in two. A part that only supports the other (a schema migration for a model) stays in the `TDD` ticket.
- Each ticket lists its **blockers**: only tickets that genuinely gate it.
- Parts: take them from `agent.md` «Parts» (older plans: `plan.md` «Parts» or «Branches»). None → one part.
- Each part closes in this order: development tickets → the E2E ticket → the check ticket.
  - The E2E ticket has **Mode** `E2E`, carries the part's `e2e` scenarios from `agent.md` «Tests» and is blocked by
    every development ticket of the part. No `e2e` line for the part → no E2E ticket.
  - The check ticket is blocked by the E2E ticket alone; without one — by every development ticket of the part. Its
    cases are the `plan.md` «Checks» lines marked `manual` for that part (older plans: «Manual checks»). None → no
    check ticket.
- A part has at most 6 development tickets: one part is one batch and one pull request. More → split it into two parts,
  each named after what it delivers (`checkout-map`, `pickup-step`), not numbered (`checkout (1)`). A part that can't
  be named as a finished piece has its boundary in the wrong place.

A plan that cannot be sliced without a new decision (a check that fits no ticket, an edit the plan does not name, a
behaviour change without a check) → stop and show the finding to the user.

### 3. Quiz the user

Ask the user (`docs/agents/harness.md` «Actions») with a table: ID, part, title, mode, blockers, estimated lines.
Below it — what "done" means for each ticket, one line. Ask about granularity (too coarse / too fine), blocking edges,
anything to merge or split. Modes and tests follow from the approved plan and are not asked again.

Iterate until the user approves.

### 4. Write files

One part — `tickets/<NN>-<slug>.md`, numbered from `01` in dependency order, then `<NN>-e2e.md`, the last one `<NN>-check.md`.

Several parts — `tickets/<BB>-<part>-<NN>-<slug>.md`:

- `BB` — the part number from `01`: a part comes after every part that blocks it, independent parts in plan order.
- `NN` — from `01` inside each part in dependency order; the E2E ticket takes the next number with the slug `e2e`,
  the check ticket the last one with the slug `check`.
- The ticket ID is `<part>-<NN>` (`core-01`, `summary-04`), `BB` is not part of it.

```
00-map.md
01-core-01-<slug>.md
01-core-02-<slug>.md
01-core-03-check.md
02-summary-01-<slug>.md
02-summary-02-e2e.md
02-summary-03-check.md
```

Write `tickets/00-map.md` per «Map».

### 5. Report

The map, the ticket file paths and the first ticket to run.

## Map

`tickets/00-map.md` is the order of work and its progress; the user and `/{{p}}-orchestrate` read it instead of the
ticket files. One section is one **batch**: the development tickets of a part, then its E2E ticket, closed by its
**gates**.

```markdown
# <KEY>-N — map

`/{{p}}-orchestrate <KEY>-N` takes the first batch with an unticked ticket. It starts it once every gate of the
batches in «After» is ticked.

## 01 core

**Branch:** <key>-N-core
**After:** —

- [ ] core-01 <title>
- [ ] core-02 <title>
- [ ] core-03 E2E

**Gates:**

- [ ] Agent review → `../reviews/01-core.md`
- [ ] Developer review
- [ ] Manual check → `01-core-04-check.md`

## 02 summary

**Branch:** <key>-N-summary
**After:** core

- [ ] summary-01 <title>
- [ ] summary-02 E2E

**Gates:**

- [ ] Agent review → `../reviews/02-summary.md`
```

- **Branch** — per `docs/agents/git.md` «Branches»: one part → the task branch `<key>-N-<slug>`; several parts →
  `<key>-N-<part>`.
- Ticket line: `- [ ] <ID> <title>`, in file order. `/{{p}}-tdd-develop` (or `/{{p}}-develop` for `no tests`) ticks
  it; `/{{p}}-orchestrate` also appends ` — <short commit hash>`.
- «After» — the sections whose gates gate this one, by part name; `—` for none.
- Gates, in this order, each ticked by:
  - `Agent review` — always; `/{{p}}-develop` after it closes every finding of the review file, or
    `/{{p}}-code-review` when the review has none;
  - `Developer review` — only when `plan.md` «Developer review» is `yes`; the user ticks it;
  - `Manual check` — only when the part has a check ticket; the user, once every case of it is ticked.

## Ticket template

```markdown
# <ID> — <Title>

**What to do:** behaviour from an actor's perspective, not a layer-by-layer list.

**Plan:** agent.md «What to fix» <N, M>.

**Size:** ~<N> lines.

**Mode:** TDD | no tests

**Blocked by:** <ID, ID> | None — can start immediately

**Status:** ready-for-agent

- [ ] Acceptance criterion

**Tests:**

- <check line copied from plan.md «Checks»>
```

Mode `no tests` — `Tests` holds one line: why, and how it is checked by hand.

## E2E ticket template

```markdown
# <ID> — E2E scenarios <part>

**What to do:** the part's behaviour is checked by `e2e`.

**Plan:** agent.md «Tests», the part's e2e scenarios.

**Size:** 0 lines of production code, <N> scenarios.

**Mode:** E2E

**Blocked by:** <all development tickets of the part>

**Status:** ready-for-agent

- [ ] **<what the scenario checks, in plain words>**
  - Given: <data, and what the steps can't be followed without>
  - Steps: <the actor's commands and buttons>
  - Expected: <what the product sent, what is in the DB>
- [ ] Every scenario marked `xfail` with this ticket's ID rewritten or deleted, marker removed.
- [ ] `e2e` green.
```

One checklist item per scenario, copied from `agent.md` «Tests» with its title and sub-bullets. `/{{p}}-tdd-develop` runs the ticket; a scenario that stays red becomes a new development ticket of the same part.

## Check ticket template

```markdown
# <ID> — Manual check <part>

**Blocked by:** <the E2E ticket of the part>

**Status:** ready-for-manual-check

**Check in the product:**

- [ ] <screen → action → expected result>
```

The user ticks every case in the product. A failed case becomes a new ticket of the same part. The tracker issue `<KEY>-N` moves to Done only after every gate of the map is ticked — the user does that, not the agent.

## Ticket rules

- Reference plan sections instead of file paths or code.
- A ticket added later (a red E2E scenario, a failed manual case, a review finding) takes the next free number of its
  part; existing files are not renumbered. Its line goes at the end of its section's ticket list, and that section's
  gates are unticked.
- Manual cases live only in check tickets, so one file holds everything to click before Done. E2E scenarios live only
  in E2E tickets.
- Older tickets carry Russian labels (`Режим`, `без тестов`, `Проверки`, `Ревью агентом`, `Ручная проверка`): read
  them as `Mode`, `no tests`, `Gates`, `Agent review`, `Manual check`.
- English, wrapped at 120 characters. UI texts and button labels stay verbatim.

_Last modified: 2026-11-05_
