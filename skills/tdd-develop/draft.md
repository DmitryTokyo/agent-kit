# TDD draft — draft subagent rules

Actors: `docs/agents/product.md` «Actors».

You turn the approved checks into test cases the other subagents work from, and name every deviation from them. Read:

- the ticket file you were given — the unit of work: what to build, acceptance checklist, tests line, plan sections;
- `plan.md` «Checks» — approved by the developer; tests are not approved again;
- `agent.md` «Tests» — only the cases covering this ticket;
- `.agents/skills/{{p}}-test-writer/rules.md` «Test observable behavior» and `docs/agents/testing.md` — what gets no test;
- `.agents/skills/{{p}}-develop/SKILL.md` and `docs/agents/code-rules.md` in full.

Production code and tests stay untouched. You write only the ticket's `## Handoff`.

## TDD ticket

1. Draft the cases from the ticket's tests line + `agent.md` «Tests». A `## Handoff` already in the ticket is a draft too, whatever it says about being agreed.
2. Keep the cases that pass «Test observable behavior» and `testing.md`; name each dropped case and why.
3. Open the existing test file of every seam and mark each case per «Handoff».
4. Group the cases into behaviours.
5. Append `## Handoff` to the end of the ticket file, replacing an existing one.
6. Return the report.

## E2E ticket

1. Draft the scenarios from the ticket's checklist + the `e2e` scenarios of `agent.md` «Tests», one per checklist item: the actor's steps → what the product sent and what is in the DB.
2. Find every scenario marked `xfail` with this ticket's ID: each one is rewritten to the current behaviour or deleted; either way the marker goes.
3. Append `## Handoff` with the scenarios, expected values as literals, replacing an existing one.
4. Return the report; a rewritten or deleted `xfail` scenario is a deviation.

## Handoff

The subagents after you take the ticket from it.

- Test cases: each tagged with its behaviour number — seam, scenario, expected value as a literal, never a type name or the ticket's wording. Each case carries a mark:
  - `row` — the function already has a `parametrize` test and the case differs only by values in its existing columns. Name the test.
  - `rewrite` — an existing test changes beyond a row. Name the test.
  - `new` — everything else, including a new column or turning a single test into `parametrize`. Name the file and which `new` cases merge into one `parametrize`.
  - `delete` — an existing test the approved cases make redundant. Name the test and the case that replaces it.
- Schema changes (model, field, index) the ticket needs, by name. The code subagent makes them with the migration.
- Rules for the code, picked from `docs/agents/code-rules.md` — only the ones this ticket's code will hit. Testing rules stay in `rules.md`, uncopied.

## Deviations

A **deviation** is any difference between the cases you hand off and the ticket's `Tests` lines: a line you drop (it tests an implementation detail, or the change does not move it), a case the lines do not name, an existing test to delete, a case green before any production code (a regression case), or a disagreement between the tests line, the checklist and `agent.md` «Tests». The user answers deviations only; no deviation → nothing is asked.

One line per deviation, in the user's language and `CONTEXT.md` terms: `<condition → expected result> · new | row | rewrite | delete · <why>`. No test names, mocks, fixtures, field or method names, file paths.

## Corrections

The dispatcher may come back with the user's answer to a deviation. Change the cases it touches, rewrite `## Handoff`, return the full report again.

## Report

```text
Status: done | blocked

All cases row: yes | no

Dropped cases: none | <case — why>

Deviations: none | <one line each, per «Deviations»>

Question: <only for blocked>
```

_Last modified: 2026-10-15_
