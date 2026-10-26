# TDD draft — draft subagent rules

Actors: `docs/agents/product.md` «Actors».

You draft what the user approves and what the other subagents work from. Read:

- the ticket file you were given — the unit of work: what to build, acceptance checklist, tests line, plan sections;
- `plan.md` — only the sections the ticket references;
- `test-plan.md` — only the sections covering this ticket;
- `.claude/skills/{{p}}-test-writer/rules.md` «Test observable behavior» and `docs/agents/testing.md` — what gets no test;
- `.claude/skills/{{p}}-develop/SKILL.md` and `docs/agents/code-rules.md` in full.

Production code and tests stay untouched. You write only the ticket's `## Handoff`.

## TDD ticket

1. Draft the cases from the ticket's tests line + `test-plan.md`. A `## Handoff` already in the ticket is a draft too, whatever it says about being agreed.
2. Keep the cases that pass «Test observable behavior» and `testing.md`; name each dropped case and why.
3. Open the existing test file of every seam and mark each case per «Handoff».
4. Group the cases into behaviours.
5. Append `## Handoff` to the end of the ticket file, replacing an existing one.
6. Return the report.

## E2E ticket

1. Draft the scenarios from the ticket's checklist + `test-plan.md` «E2E scenarios», one per checklist item: the actor's steps → what the product sent and what is in the DB.
2. Find every scenario marked `xfail` with this ticket's ID: each one is rewritten to the current behaviour or deleted; either way the marker goes.
3. Append `## Handoff` with the scenarios, expected values as literals, replacing an existing one.
4. Return the report; the preview carries one item per scenario, the `xfail` ones included.

## Handoff

The subagents after you take the ticket from it.

- Test cases: each tagged with its behaviour number — seam, scenario, expected value as a literal, never a type name or the ticket's wording. Each case carries a mark:
  - `row` — the function already has a `parametrize` test and the case differs only by values in its existing columns. Name the test.
  - `rewrite` — an existing test changes beyond a row. Name the test.
  - `new` — everything else, including a new column or turning a single test into `parametrize`. Name the file and which `new` cases merge into one `parametrize`.
  - `delete` — an existing test the approved cases make redundant. Name the test and the case that replaces it.
- Schema changes (model, field, index) the ticket needs, by name. The code subagent makes them with the migration.
- Rules for the code, picked from `docs/agents/code-rules.md` — only the ones this ticket's code will hit. Testing rules stay in `rules.md`, uncopied.

## Approval preview

The user approves behaviours and what happens to the tests, not test code. Write it in Russian, in `CONTEXT.md` terms.

- One numbered item per behaviour: condition → expected result, variants as sub-bullets.
- Under each behaviour, one line in plain words on what happens to the tests: a new test is written, a row is added to an existing test, an existing test is changed (say what changes in it), an existing test is deleted (say what makes it redundant).
- No test names, mocks, fixtures, field or method names, file paths. A technical detail stays only when it is the sole difference between two variants.
- A case green before any production code is marked as a regression case, with one line on the risk. Add one only when the behaviour is not covered yet.
- Where the ticket's tests line, its checklist and `test-plan.md` disagree, say so on the item.
- Close with the behaviours existing tests already cover, for which nothing is added, and a total: behaviours, cases, and how many tests are new, get a row, are changed, are deleted.

## Corrections

The dispatcher may come back with the user's correction. Change the cases it touches, rewrite `## Handoff`, return the full report again.

## Report

```text
Status: done | blocked

All cases row: yes | no

Dropped cases: none | <case — why>

Preview:
<the approval preview, verbatim>

Question: <only for blocked>
```

_Last modified: 2026-10-15_
