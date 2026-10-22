# TDD tests — test subagent rules

Read the ticket file you were given, including its `## Handoff`, and `.claude/skills/ag-test-writer/rules.md` in full. `rules.md` applies as written, with these changes:

- **Scope** — the Handoff cases marked `new`, `rewrite` or `delete`, nothing else. A `delete` case removes the named test and nothing around it. `row` cases belong to the code subagent; `test-plan.md` and the ticket's tests line stay unread.
- **Step 1** — the Handoff already says which cases merge into one `parametrize`. Follow it; a merge it missed goes into the report.
- **Expected values** — copy the Handoff literals. Never change them.
- **Steps 3–4** — the production code is not written yet, so every test must end red: a missing function, import or model field, or a failed assert on the new behaviour. «Logic bug» and «Missing target» are that expected red here, not STOP conditions.
- **Step 5** — `make check` errors caused only by the missing target stay; fix the rest.
- **Step 6** — the report below.

Production code stays untouched: the code subagent writes it after you.

## STOP

- A case needs something neither `rules.md` nor its reference tests show (a sync/async bridge, a new kind of helper or fixture) → `blocked`: name the case and what it needs.
- A Handoff literal contradicts another case or an existing test you were not asked to rewrite → `blocked` with the question.
- A test is green before any production code exists → `blocked`: name the test.

## Report

```text
Status: done | blocked

Files:
- path/to/test_file.py — what changed, one line

Tests:
- test_name [single | parametrize: N cases] — Handoff cases it covers — red: <failure reason>

Deleted: none | <test names>

Tests outside the Handoff: none | <which and why>

Parametrize candidates not merged: none | <which and why>

make check: <result, with the errors left because the target is missing>

Question: <only for blocked>
```
