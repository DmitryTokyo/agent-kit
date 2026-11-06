---
name: {{p}}-develop
description: Write or modify code directly, without a TDD ticket — a task whose approved plan says `Delivery: commits`, a ticket with `Mode: no tests`, a review file, or a plain fix. A ticket from {{work}}/tasks/<key>-N-*/tickets/ with `Mode: TDD` goes to /{{p}}-tdd-develop.
---

# Develop

Project context, domain language and guardrails live in `AGENTS.md` and `CONTEXT.md`. How code is written
lives in `docs/agents/code-rules.md`: read it in full before writing code. Commands (`check`, `unit`, `e2e`, `migrate`)
are keys of `docs/agents/stack.md` «Commands».

## Before implementing

Run `git status --porcelain` first. Any output → stop and ask the user: commit, stash, or continue because the changes
belong to this task. Nothing else happens until the tree is clean or the user said continue.

Then pick the input. Every input but a plain fix works on the task branch: get onto it per `docs/agents/git.md`
«Branches».

### A task with a plan

The task folder `{{work}}/tasks/<key>-N-*/` with the approved `plan.md` and its `agent.md`. Either missing → stop: say
which, the task key and title, and point to `/{{p}}-create-plan`. `plan.md` says `Delivery: tickets` and the folder has
no `tickets/` → stop and suggest `/{{p}}-to-tickets`.

- Work inside the plan's `Boundaries`. A finding from its `Stop conditions` → stop, show it and return the task to
  route selection.
- `agent.md` «What to fix» is the edit list; its «Tests» say where each test goes.
- Tests are the plan's `Checks`: `new` / `extend existing` lines → through `/{{p}}-test-writer`; `e2e`, `manual`
  and `none` lines get no unit test. A test the checks do not name, or a check you cannot test as written, is a
  deviation: ask the user before acting on it.

### A ticket with `Mode: no tests`

Its description and checklist are the task; tests are not needed. Do the manual check from the ticket's tests line,
then tick the checklist and set `Status: done`; once committed, tick its line in `tickets/00-map.md` with
` — <short hash>`. A ticket with `Mode: TDD` → stop, suggest `/{{p}}-tdd-develop`.

### A review file

Input is a review file from `{{work}}/tasks/<key>-N-*/reviews/` → it says what to fix in its «Fixer» line: every open item
that is `hard` or `decision: fix`. A `decision: ?` left → stop and ask the user to set it in the file, naming those
IDs. A finding that changes approved behaviour, or that you disagree with → ask the user. Existing tests are the
check, new ones only when the finding asks for them. Each fixed item gets its box ticked and one `fixed:` line; the
fixes are one commit per `/{{p}}-git-commit-message`, at most 100 lines of production code. No open `hard` or
`decision: fix` item left → tick `Agent review` in the map section for that batch. The final report lists every item
by ID with its outcome: fixed, skipped or asked.

### A plain fix

No task folder: the user's message is the task. If the user did NOT explicitly ask for tests, ask whether tests are
needed before implementing. When tests are agreed, invoke `/{{p}}-test-writer`.

### Recon

When a concrete task is known (feature, fix, refactor), run `/{{p}}-recon` first and use its summary as context — do
not re-read those files. Skip recon only for a single-file change at a known location.

Fixing a test that your change breaks is allowed; keep the fix minimal.

### Scope

The task is the only scope. Read callers and dependents only to see what a choice would break, never to fix or refactor them on your own initiative. When anything about how to proceed is unknown or ambiguous — a new contract not covering what the old one did, an effect reaching beyond what was asked — stop and ask one question instead of deciding.

### Simplicity

Minimum code that solves the task: no features, abstractions, configurability or error handling for cases nobody asked for. If 200 lines could be 50, rewrite.

## After writing code

1. `check` — green. A schema change ends with `migrate` first.
2. Run `/{{p}}-hygiene-review` on the changed files. Clear violations of a rule in `code-rules.md` → fix and include in
   the final report. Ambiguous findings → ask the user before touching.
3. After fixes, `check` again.

A task with a plan, also:

4. Review the diff against `plan.md` `Criteria`: tick each criterion the diff (or a run) confirms. The final report
   lists every unticked criterion as a deviation, with the reason — it goes to the pull request.
5. Behaviour the plan does not describe, or a departure from it → append a check to the end of `plan.md` `Checks`:
   `- <condition → expected result> (added in development)`. Never edit or remove existing items.
6. The worktree stays uncommitted: the next step is `/{{p}}-git-commit-message`, then `/{{p}}-code-review`.

_Last modified: 2026-11-06_
