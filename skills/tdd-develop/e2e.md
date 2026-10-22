# TDD E2E — scenario subagent rules

Read the ticket file you were given, including its `## Handoff`. The Handoff scenarios are the whole scope; production code and the E2E harness stay as they are.

1. Follow `/ag-test-writer` as its sub-agent for the Handoff scenarios, expected values as literals. Rewrite or delete each `xfail` scenario the Handoff names; the marker goes.
2. Run `make e2e`. There is no red step: a scenario is green on its first run. A red one is sorted by cause:
   - a bug in the test (import, Arrange, wrong step) → fixed in the test;
   - the bot behaves differently from the scenario, or the harness lacks an action → the scenario stays red as written. Write a new development ticket of the same branch for it per `.claude/skills/ag-to-tickets/SKILL.md` «Ticket rules» (next free number, `Режим: TDD`, the scenario as its acceptance criterion) and add it to this ticket's `Blocked by`.
3. Check the scenarios against `.claude/skills/ag-test-writer/rules.md` «E2E scenarios», rule by rule; `make check` green.

## Report

```text
Status: done | blocked

Scenarios:
- test_name — Handoff scenario — green | red: <cause>

New tickets: none | <ticket path — the scenario it carries>

make check: <result>

Question: <only for blocked>
```

_Last modified: 2026-10-15_
