# TDD loop — code subagent rules

Read only the ticket file you were given, including its `## Handoff`. Follow the Handoff rules.
The Handoff cases are the whole test scope: `test-plan.md` and the ticket's tests line stay unread.

Each Handoff case carries a mark:

- `row` — you add one row to the named `parametrize`, shaped like its neighbours.
- `new` / `rewrite` — the test is already written and red. It is read-only for you.

## Schema

Schema changes the Handoff names → make them before the loop, with the migration (`uv run manage.py makemigrations`).

## Loop

One Handoff case at a time:

1. `row`: add the row. `new` / `rewrite`: find the test.
2. Run it: `uv run pytest tg_sales_bot/<app>/tests/unit/<file> -k <test> --tb=short -q`. It must fail for the expected reason.
3. Write the minimum production code to pass it.
4. Run it again — green. Only then start the next case.

- Expected values: copy the Handoff literals. Never change them. Never recompute them the way the code does.
- Code only what the ticket asks; refactoring stays out.
- An existing test broken by your change: minimal fix. If the fix needs a different expected value → STOP.
- An E2E scenario broken by your change: leave it as written, mark it
  `@pytest.mark.xfail(strict=True, reason='AG-N <ID of the branch's E2E ticket>: <what changed>')`, list it under
  «Tests outside the Handoff». The E2E ticket rewrites or deletes it.

## After the loop

1. Ticket items no test covers (bot texts, keyboards, admin config): do them per the ticket checklist.
2. Run the changed test files in full, then `make e2e`, then `make check`.

## STOP

- A Handoff literal can't be met without breaking another case or the ticket → `blocked` with the question.
- A `row` case doesn't fit the columns of its `parametrize` → `blocked`: name the case.
- A `new` / `rewrite` test can't go green without editing it → `blocked`: name the test and what is off.
- A test fails for a reason other than the expected one twice in a row → `blocked` with both outputs.
- The ticket doesn't cover the real scope → `needs-replan`; leave it unworked-around.

## Report

```text
Status: done | blocked | needs-replan

Files:
- path/to/file.py — what changed, one line

Cases:
- test_name — Handoff case and its mark — red: <failure reason> → green

Tests outside the Handoff: none | <which and why>

Deviation from the ticket: none | <what and why>

Question: <only for blocked>
```
