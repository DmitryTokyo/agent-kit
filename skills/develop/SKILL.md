---
name: {{p}}-develop
description: Write or modify code directly, without a TDD ticket — a ticket with `Режим: без тестов`, a review file, the deferred TODOs, or a plain feature or fix. A ticket from .ai/tasks/<key>-N-*/tickets/ with `Режим: TDD` goes to /{{p}}-tdd-develop.
---

# Develop

Project context, domain language and guardrails live in `CLAUDE.md`, `AGENTS.md` and `CONTEXT.md`. How code is written
lives in `docs/agents/code-rules.md`: read it in full before writing code. Commands (`check`, `unit`, `e2e`, `migrate`)
are keys of `docs/agents/stack.md` «Commands».

## Before implementing

Input is a ticket with `Режим: без тестов` → its description and checklist are the task; tests are not needed, skip the question about them. Do the manual check from the ticket's tests line, then tick the checklist and set `Status: done`; once committed, tick its line in `tickets/00-map.md` with ` — <short hash>`. A ticket with `Режим: TDD` → stop, suggest `/{{p}}-tdd-develop`.

Input is a review file from `.ai/tasks/<key>-N-*/reviews/` → its unticked findings are the task. The developer's answers
are in its digest, `<review>.ru.md`, under the same numbers; a line for all TODOs covers every TODO without its own
answer. Each finding by its tag:

- `FIX` → the outcome in `CONTRIBUTING.md` «Code review».
- `NOTE` → as its answer says.
- `TODO` → `делать`: fixed in this round; `отложить`: appended to `.ai/tasks/<key>-N-*/reviews/todo.md` as an unticked
  line with the review file, its number and the finding; `пропустить`: closed unchanged.

A `NOTE` or `TODO` without an answer, or no digest → stop and ask the user, naming those numbers. Existing tests are
the check, new ones only when the finding asks for them. A finding that changes approved behaviour, or that you
disagree with → ask the user. Each closed finding gets its box ticked, and the fixes are one commit per
`/{{p}}-git-commit-message`, at most 100 lines of production code. Every finding ticked → tick `Ревью агентом` in the
map section for that batch. The final report lists every finding by number with its outcome: fixed, done as answered,
deferred or skipped.

Input is `.ai/tasks/<key>-N-*/reviews/todo.md` → its unticked lines are the task, as `делать` TODOs, in one commit; each
fixed line gets its box ticked.

When a concrete task is known (feature, fix, refactor), run `/{{p}}-recon` first and use its summary as context — do not re-read those files. Skip recon only for a single-file change at a known location.

If the user did NOT explicitly ask for tests, ask whether tests are needed before implementing. Fixing a test that your change breaks is allowed; keep the fix minimal. When tests are agreed, invoke `/{{p}}-test-writer`.

### Scope

The user's task is the only scope. Read callers and dependents only to see what a choice would break, never to fix or refactor them on your own initiative. When anything about how to proceed is unknown or ambiguous — a new contract not covering what the old one did, an effect reaching beyond what was asked — stop and ask one question instead of deciding.

### Simplicity

Minimum code that solves the task: no features, abstractions, configurability or error handling for cases nobody asked for. If 200 lines could be 50, rewrite.

## After writing code

1. `check` — green. A schema change ends with `migrate` first.
2. Run `/{{p}}-hygiene-review` on the changed files. Clear violations of a rule in `code-rules.md` → fix and include in
   the final report. Ambiguous findings → ask the user before touching.
3. After fixes, `check` again.

_Last modified: 2026-10-22_
