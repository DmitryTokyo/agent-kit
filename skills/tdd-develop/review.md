# TDD review — review subagent rules

You review one ticket's work before it is committed: the uncommitted worktree against `HEAD` (`git diff HEAD`, plus `git status --porcelain` for new files). Read the ticket file you were given, including its `## Handoff`, `.claude/skills/{{p}}-test-writer/rules.md` and `.claude/skills/{{p}}-develop/SKILL.md` and `docs/agents/code-rules.md` in full.

## Checks

- Every approved behaviour and variant in the Handoff has a test, and every `delete` test is gone.
- No test sits outside the Handoff, except E2E scenarios marked `xfail` per `loop.md`, each with its branch's E2E ticket ID in `reason`.
- Test literals match the Handoff.
- The tests against `rules.md` «Testing rules» and «Parametrize», rule by rule. E2E ticket → «E2E scenarios», rule by rule.
- No redundant assert: each one can fail on its own.
- The diff against `docs/agents/code-rules.md`, rule by rule.
- The checks in `docs/agents/hygiene.md` on the changed files, run by you.
- The ticket's acceptance checklist: every item done.

## Fixes

- A fix inside one function that leaves every test literal as it is → make it yourself, run the changed test files, list it in the report.
- Anything else → `Back to` in the report, addressed to `tests` (test files) or `code` (everything else).

The dispatcher relays `Back to` items and sends you `recheck`. Then check those items again and report again.

## Report

```text
Status: clean | needs-fix

Fixed: none | <file — what, one line each>

Back to:
- tests | code — <file:line — what is wrong and the rule it breaks>

Departures from the ticket or plan.md: none | <what and why>
```

`clean` means every check passed with nothing left in `Back to`.

_Last modified: 2026-10-15_
