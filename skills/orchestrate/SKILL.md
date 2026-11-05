---
name: {{p}}-orchestrate
description: Run the next batch of a task's ticket map (.ai/tasks/<key>-N-*/tickets/00-map.md) end to end, each ticket through the skill of its `Mode`, one commit per ticket. Use when the user gives a task key without a ticket ID and wants the tickets developed.
---

# Orchestrate

`<KEY>` is the task key of `docs/agents/issue-tracker.md` «Tracker»; `<key>` is its lowercase form.

Commands (`check`, `unit`, `e2e`, `one-test`, `migrate`) are keys of `docs/agents/stack.md` «Commands».

## Input

`<KEY>-N`. Task folder: `.ai/tasks/<key>-N-*/` (case-insensitive).

The **batch**: the first section of `tickets/00-map.md` (format: `.agents/skills/{{p}}-to-tickets/SKILL.md` «Map») with an
unticked ticket line; its unticked tickets in list order.

- No `tickets/` folder or no `00-map.md` → stop, suggest `/{{p}}-to-tickets`.
- A ticket ID given → stop and name the skill for its `Mode` from «Route».

## Role

Read `.agents/skills/{{p}}-tdd-develop/SKILL.md` once, now: you are its dispatcher, under its «Role», for every ticket of
the batch. Its ticket sections and «Output» apply; this skill replaces its «Input» and «Close». Its stops stop the
batch.

## Start

1. `git status --porcelain` not empty → stop and tell the user: each ticket's commit takes the whole worktree.
2. A section in the batch's «After» with an unticked gate → stop and name the section and its unticked gates.
3. Get onto the section's «Branch» per `docs/agents/git.md` «Branches».

## Route

Each ticket of the batch, by its `**Mode:**` line (older tickets: `Режим`, `без тестов` = `no tests`):

| Mode | Run |
| --- | --- |
| `TDD` | `{{p}}-tdd-develop` «TDD ticket» |
| `E2E` | `{{p}}-tdd-develop` «E2E ticket» |
| `no tests` | worker (`docs/agents/harness.md` «Roles»), standard tier, the subagent prompt of `harness.md` for `.agents/skills/{{p}}-develop/SKILL.md` and `<ticket path>`, plus *"The manual check is the user's: report how to do it and leave the checklist to the dispatcher."*; then `check` green |
| missing | stop: the mode is set by `/{{p}}-to-tickets` |

Then «Commit», and the next ticket.

## Commit

The user authorized these commits by starting this skill; they go without a confirmation question. They carry the
agent identity (see `commit.md`), so the developer's commits and the agent's stay apart in the history and in the PR.

1. Write the message `<KEY>-N: <type>: <description>` — the format of `/{{p}}-git-commit-message` step 4, taken from the
   ticket title and the reports: `feat`/`fix` for a TDD ticket, `test` for an E2E ticket, `docs` for documentation.
2. Worker, cheap tier, the subagent prompt of `docs/agents/harness.md` for
   `.agents/skills/{{p}}-orchestrate/commit.md` and `<ticket path>`, with the message `<message>`.
3. Its report `too-big` → stop and tell the user the production line count: the ticket is too big for one commit.

## After the batch

Nothing is pushed. Once the section's `Agent review` gate is ticked, `/{{p}}-merge-request` pushes the branch and opens
the pull request with the review level and the consequences; the other gates are worked on it. The developer's review comments on it go through `/{{p}}-review-comments`.

## Output

After each ticket — `{{p}}-tdd-develop` «Output».

At the batch end: the commits in order, each with its departures, the manual checks of `no tests` tickets, then the
section's gates in order — the first one is `/{{p}}-code-review <KEY>-N <part>` in a new session.

_Last modified: 2026-11-05_
