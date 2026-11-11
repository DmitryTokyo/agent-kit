---
name: {{p}}-tdd-develop
description: Implement one ticket from {{work}}/tasks/<key>-N-*/tickets/ — test-first for `Mode: TDD`, actor scenarios for `Mode: E2E`. Use when the user gives a task key with a ticket ID and wants that ticket implemented.
---

# TDD develop

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands». Actors: `docs/agents/product.md` «Actors».

## Input

`<KEY>-N <ID>` — one ticket, ID as `NN` or `<part>-NN`. Task folder: `{{work}}/tasks/<key>-N-*/` (case-insensitive). Ticket
files: `tickets/<ID>-*.md`, with parts `tickets/<BB>-<ID>-*.md` (`core-01` → `01-core-01-*.md`).

- `<KEY>-N` without an ID → stop, suggest `/{{p}}-orchestrate <KEY>-N`.
- No `tickets/` folder or no ticket file for the ID → stop, tell the user this skill works only from a ticket, suggest `/{{p}}-develop`.
- A check ticket → stop: it is manual.
- No `**Mode:**` or `Mode: no tests` → stop, suggest `/{{p}}-develop` with the ticket path. Never decide the mode here. Older tickets say `Режим` and `без тестов`: the same fields.
- Not under `/{{p}}-orchestrate` → get onto the branch of the ticket's map section («Branch») per `docs/agents/git.md` «Branches».

## Role

You are the dispatcher, on the strong tier (`docs/agents/harness.md` «Tiers»): you hold the queue, the user's answers and the subagents' reports. Running on another tier → stop and tell the user to switch.

Your context stays thin, so a whole `/{{p}}-orchestrate` batch fits one session:

- From a ticket file you read only the `**Mode:**`, `**Blocked by:**` and `**Status:**` lines and the title; the map
  you read whole.
- Code, diffs, tests, `plan.md`, `agent.md` and the skill files the subagents follow stay unread. Subagents read them.
- The command output you read yourself is `check`.

Every subagent is a worker (`docs/agents/harness.md` «Roles») on the tier named below, with the subagent prompt of `harness.md` for `.agents/skills/{{p}}-tdd-develop/<file>` and the ticket path.

## TDD ticket

1. A ticket in `Blocked by` not `done` → stop and tell the user.
2. **Draft** — subagent on `draft.md`, standard tier. It writes `## Handoff` into the ticket and returns its deviations from the approved checks.
3. No deviation → step 4 without asking: the developer approved the checks in `plan.md`. Deviations → ask the user (`docs/agents/harness.md` «Actions») with them. An answer → continue the draft subagent with it and print its new deviations. Done when every deviation has the user's answer.
4. **Tests** — subagent on `tests.md`, standard tier, unless the draft report says every case is `row`. Its report shows every `new` and `rewrite` test red for the expected reason before step 5.
5. **Code** — subagent on `loop.md`, standard tier.
6. **Review** — subagent on `review.md`, strong tier. Each item it sends back → continue the subagent that owns the file with it, then continue the reviewer to recheck those items. Done when the reviewer reports `clean`. The third recheck still `needs-fix` → ask the user (`docs/agents/harness.md` «Actions») with the open `Back to` items.
7. **Close** — run `check`; green → per «Close».

«Continue» is the «continue a worker» of `harness.md`; a harness without it re-dispatches the subagent with its last report pasted in.

A subagent returns `blocked` → continue it with the answer; an answer that changes or drops an approved check, or changes what happens to its tests → ask the user first. `needs-replan` → stop and tell the user.

## E2E ticket

A ticket with `Mode: E2E` adds actor scenarios for behaviour the part's development tickets already built.

1. A ticket in `Blocked by` not `done` → stop and tell the user.
2. **Draft** — subagent on `draft.md`, standard tier; deviations as in «TDD ticket» step 3.
3. **Scenarios** — subagent on `e2e.md`, standard tier.
4. Its report names a new development ticket for a red scenario → stop and tell the user. Every scenario green → `check` green → per «Close».

## Close

Nothing is staged, committed or pushed: the user reviews the worktree with `git diff` and commits it.

1. Tick the ticket's checklist and set its `Status` to `done`.
2. Tick the ticket's line in the map.
3. Every ticket of the map now `done` → per «Last ticket».

## Last ticket

The last ticket of the task closes the task's work, under `/{{p}}-orchestrate` too:

1. A worker (`docs/agents/harness.md` «Roles»), standard tier, reviews the whole branch diff
   (`git diff <main>...HEAD` plus the worktree) against `plan.md` «Criteria» and ticks each criterion it confirms. Every
   unticked criterion goes into «Output» as a deviation: it goes to the pull request.
2. The task folder has `integration.md` → a worker, standard tier, with the subagent prompt of `harness.md` for
   `.agents/skills/{{p}}-integration-test/SKILL.md` and the `integration.md` path. Its report goes into «Output».

## Output

Three lines: the commit with its line count (code, tests) under `/{{p}}-orchestrate`, otherwise «not committed», the
departures from the ticket or `plan.md` with their reason (or «none»), the next unticked ticket of the map.

_Last modified: 2026-11-11_
