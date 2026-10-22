---
name: {{p}}-tdd-develop
description: Implement one ticket from .ai/tasks/<key>-N-*/tickets/ — test-first for `Режим: TDD`, actor scenarios for `Режим: E2E`. Use when the user gives a task key with a ticket ID and wants that ticket implemented.
---

# TDD develop

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands». Actors: `docs/agents/product.md` «Actors».

## Input

`<KEY>-N <ID>` — one ticket, ID as `NN` or `<part>-NN`. Task folder: `.ai/tasks/<key>-N-*/` (case-insensitive). Ticket
files: `tickets/<ID>-*.md`, with parts `tickets/<BB>-<ID>-*.md` (`core-01` → `01-core-01-*.md`).

- `<KEY>-N` without an ID → stop, suggest `/{{p}}-orchestrate <KEY>-N`.
- No `tickets/` folder or no ticket file for the ID → stop, tell the user this skill works only from a ticket, suggest `/{{p}}-develop`.
- A check ticket → stop: it is manual.
- No `**Режим:**` or `Режим: без тестов` → stop, suggest `/{{p}}-develop` with the ticket path. Never decide the mode here.

## Role

You are the dispatcher, on Opus: you hold the queue, the user's approvals and the subagents' reports. Running on another model (see «You are powered by» in the system prompt) → stop and tell the user to switch with `/model`.

Your context stays thin, so a whole `/{{p}}-orchestrate` batch fits one session:

- From a ticket file you read only the `**Режим:**`, `**Blocked by:**` and `**Status:**` lines and the title; the map
  you read whole.
- Code, diffs, tests, `plan.md`, `test-plan.md` and the skill files the subagents follow stay unread. Subagents read them.
- The command output you read yourself is `check`.

Every subagent is `subagent_type: general-purpose` and gets the prompt *"Read `.claude/skills/{{p}}-tdd-develop/<file>` and follow it for `<ticket path>`. You are the subagent — do not spawn anything, you cannot talk to the user."*

## TDD ticket

1. A ticket in `Blocked by` not `done` → stop and tell the user.
2. **Draft** — subagent on `draft.md`, `model: sonnet`. It writes `## Handoff` into the ticket and returns the approval preview.
3. Print the preview as a plain message and end the turn; `AskUserQuestion` hides both the text before it and its option `preview` in the desktop app. The user's reply approves it or corrects it. A correction → pass it to the draft subagent via `SendMessage` and print its new preview. Done when the user approves the preview in this session.
4. **Tests** — subagent on `tests.md`, `model: sonnet`, unless the draft report says every case is `row`. Its report shows every `new` and `rewrite` test red for the expected reason before step 5.
5. **Code** — subagent on `loop.md`, `model: sonnet`.
6. **Review** — subagent on `review.md`, `model: opus`. Each item it sends back → `SendMessage` to the subagent that owns the file, then `SendMessage` the reviewer to recheck those items. Done when the reviewer reports `clean`.
7. **Close** — run `check`; green → per «Close».

A subagent returns `blocked` → answer via `SendMessage`; an answer that changes or drops an approved behaviour, or changes what happens to its tests → ask the user first. `needs-replan` → stop and tell the user.

## E2E ticket

A ticket with `Режим: E2E` adds actor scenarios for behaviour the part's development tickets already built.

1. A ticket in `Blocked by` not `done` → stop and tell the user.
2. **Draft** — subagent on `draft.md`, `model: sonnet`; approval as in «TDD ticket» step 3.
3. **Scenarios** — subagent on `e2e.md`, `model: sonnet`.
4. Its report names a new development ticket for a red scenario → stop and tell the user. Every scenario green → `check` green → per «Close».

## Close

Nothing is staged, committed or pushed: the user reviews the worktree with `git diff` and commits it.

1. Tick the ticket's checklist and set its `Status` to `done`.
2. Tick the ticket's line in the map.

## Output

Three lines: the commit with its line count (code, tests) under `/{{p}}-orchestrate`, otherwise «not committed», the
departures from the ticket or `plan.md` with their reason (or «none»), the next unticked ticket of the map.

_Last modified: 2026-10-21_
