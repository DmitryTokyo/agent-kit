---
name: {{p}}-to-tickets
description: Split .ai/tasks/<key>-N-<slug>/plan.md into commit-sized ticket files under tickets/ and a map of batches, each part ending with an E2E ticket and a manual check ticket.
disable-model-invocation: true
---

# To tickets

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands». Actors: `docs/agents/product.md` «Actors».

Break `.ai/tasks/<key>-<N>-<slug>/plan.md` into **tickets**: one ticket = one commit, at most 100 lines of production code (migrations and tests not counted).

## Process

### 1. Gather context

Read `plan.md`, `research.md`, `test-plan.md` from the task folder and the tracker issue `<KEY>-N` (acceptance criteria). Ask for the key if the folder is unclear.

### 2. Draft tickets

- Slice along the plan's sections. Every commit keeps the product working, without feature flags unless `docs/agents/issue-tracker.md` allows them. Layer slices are fine while the new code is unreachable — the ticket that wires it into a handler comes last in its part.
- Estimate lines per ticket. Over 100 lines → split in two.
- The rules of `docs/agents/code-rules.md` «Ticket slicing».
- Each development ticket gets a **Режим**: `TDD` or `без тестов`. `без тестов` only for: a one-off data migration,
  declarative config without logic (an admin listing, a settings entry), documentation. Everything else is `TDD` and is
  developed against the unit cases of `test-plan.md`. Not decided during development: the mode is fixed here.
- A ticket where one part is `TDD` and another `без тестов`, and the parts can be delivered and committed separately →
  split in two. A part that only supports the other (a schema migration for a model) stays in the `TDD` ticket.
- Each ticket lists its **blockers**: only tickets that genuinely gate it.
- Parts: take them from plan.md «Parts» (older plans: «Branches»). No such section → one part, or propose parts (core, then parts independent of each other, each checkable in the product on its own) and ask the user. A part is a logical unit of the map; its git branch is made per batch by `/{{p}}-orchestrate`.
- Each part closes with three levels in this order: development tickets → one E2E ticket → one check ticket.
  - The E2E ticket has **Режим** `E2E`, carries the part's scenarios from `test-plan.md` «E2E scenarios» and is blocked by every development ticket of the part. No scenarios for the part in `test-plan.md` → no E2E ticket.
  - The check ticket is blocked by the E2E ticket alone; without one — by every development ticket of the part. Its cases come from plan.md «Manual checks» for that part.
- A part has at most 6 development tickets: one part is one batch, one pull request and one manual check at its end.
  More → split it into two parts, each named after what it delivers (`checkout-map`, `pickup-step`), not numbered
  (`checkout (1)`). A part that can't be named as a finished piece has its boundary in the wrong place.

### 3. Quiz the user

Show a table: ID, part, title, mode, blockers, estimated lines. Below it — what "done" means for each ticket, one line. Ask about:

- granularity — too coarse / too fine;
- the mode of each ticket;
- blocking edges;
- anything to merge or split.

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

## Map

`tickets/00-map.md` is the order of work and its progress; the user and `/{{p}}-orchestrate` read it instead of the
ticket files. One section is one **batch**: the development tickets of a part, then its E2E ticket, closed by
three **gates**.

```markdown
# <KEY>-N — карта

`/{{p}}-orchestrate <KEY>-N` берёт первую партию с неотмеченным тикетом. Начинает её, когда у партий из «После» отмечены
все проверки.

## 01 core

**После:** —

- [ ] core-01 <title>
- [ ] core-02 <title>
- [ ] core-03 E2E

**Проверки:**

- [ ] Ревью агентом → `../reviews/01-core.md`
- [ ] Ревью разработчиком
- [ ] Ручная проверка → `01-core-04-check.md`

## 02 summary

**После:** core

- [ ] summary-01 <title>
- [ ] summary-02 E2E

**Проверки:**

- [ ] Ревью агентом → `../reviews/02-summary.md`
- [ ] Ревью разработчиком
- [ ] Ручная проверка → `02-summary-03-check.md`
```

- Ticket line: `- [ ] <ID> <title>`, in file order. `/{{p}}-tdd-develop` (or `/{{p}}-develop` for `без тестов`) ticks it; `/{{p}}-orchestrate` also appends ` — <short commit hash>`.
- «После» — the sections whose gates gate this one, by part name; `—` for none.
- A batch whose only tickets are `без тестов` documentation: the third gate reads `Документация просмотрена`.
- Gates, in this order, each ticked by:
  - `Ревью агентом` — `/{{p}}-develop` after it closes every finding of the review file, or `/{{p}}-code-review` when the
    review has none;
  - `Ревью разработчиком` — the user; a user who skips their review ticks it unreviewed;
  - `Ручная проверка` — the user, once every case of the check ticket is ticked.

## Ticket template

```markdown
# <ID> — <Title>

**What to do:** behaviour from an actor's perspective, not a layer-by-layer list.

**Plan:** plan.md edits <N, M>.

**Size:** ~<N> lines.

**Режим:** TDD | без тестов

**Blocked by:** <ID, ID> | None — can start immediately

**Status:** ready-for-agent

- [ ] Acceptance criterion

**Tests (discuss before starting):** candidate cases, parametrize where it fits. Режим `без тестов` — instead: one line why, and how it is checked by hand.
```

## E2E ticket template

```markdown
# <ID> — E2E scenarios <part>

**What to do:** the part's behaviour is checked by `e2e`.

**Plan:** test-plan.md «E2E scenarios», <the part's headings>.

**Size:** 0 lines of production code, <N> scenarios.

**Режим:** E2E

**Blocked by:** <all development tickets of the part>

**Status:** ready-for-agent

- [ ] **<what the scenario checks, in plain words>**
  - Given: <data, and what the steps can't be followed without>
  - Steps: <the actor's commands and buttons>
  - Expected: <what the product sent, what is in the DB>
- [ ] Every scenario marked `xfail` with this ticket's ID rewritten or deleted, marker removed.
- [ ] `e2e` green.
```

One checklist item per scenario, copied from `test-plan.md` with its title and sub-bullets. `/{{p}}-tdd-develop` runs the ticket; a scenario that stays red becomes a new development ticket of the same part.

## Check ticket template

```markdown
# <ID> — Проверка <part> руками

**Blocked by:** <the E2E ticket of the part>

**Status:** ready-for-manual-check

**Проверить в боте:**

- [ ] <экран → действие → ожидаемый результат>
```

The user ticks every case in the product. A failed case becomes a new ticket of the same part. The tracker issue `<KEY>-N` moves to Done only after every gate of the map is ticked — the user does that, not the agent.

## Ticket rules

- Reference plan sections instead of file paths or code.
- A ticket added later (a red E2E scenario, a failed manual case, a review finding) takes the next free number of its
  part; existing files are not renumbered. Its line goes at the end of its section's ticket list, and that section's
  gates are unticked.
- Manual cases live only in check tickets, so one file holds everything to click before Done. E2E scenarios live only in E2E tickets.
- The tests line is a list of candidates to discuss before starting: behaviours only, per «Test observable behavior» in `.claude/skills/{{p}}-test-writer/rules.md` and `docs/agents/testing.md`. An implementation property (query count, prefetch) is an acceptance criterion at most. `без тестов` is set by the mode, not by the tests line.
- English content; UI texts, button labels and the whole check ticket stay Russian. Wrapped at 120 characters.

_Last modified: 2026-10-21_
