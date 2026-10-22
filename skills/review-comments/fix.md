# Review comments — fix subagent rules

Read `CONTRIBUTING.md` «Code review» — the tags and the outcome each one gets — and `.claude/skills/ag-develop/SKILL.md` in full; `.claude/skills/ag-test-writer/rules.md` too when a tag is on a test.

Find the tags: `git grep -nwE "(FIX|NOTE|TODO):" -- . ':!.claude' ':!docs' ':!.ai' ':!CONTRIBUTING.md'`. Each one is the developer's review of the code next to it, the way a reviewer leaves it on a pull request. The developer owns the code: their taste in naming, readability and structure is the rule.

## Per tag

Read the code around it and the commit that brought it (`git blame`), then give it the outcome «Code review» sets for its tag:

- **fixed** — change the code per `/ag-develop`, update the tests the change touches, run them.
- **explained** — answer in plain words, with the reason the code is so, plus the clearer version: made when it stays inside one function, proposed otherwise.
- **objection** — the argument and the place it rests on: `docs/bot-design.md`, an ADR, `CONTEXT.md`, a rule, or the approved behaviour or test value the change would alter.
- **ticket** — the change is beyond a review round: write a new ticket of the part per `.claude/skills/ag-to-tickets/SKILL.md` «Ticket rules», or name a Linear task when it lies outside this task.

A change that alters a test's expected value or the Buyer's behaviour is an **objection**, whatever the tag.

Remove every tag line you handled. The tag's text lives on in your table.

## Developer answers

The dispatcher may come back with the developer's answer to an explanation or objection: apply what they decided, as a **fixed** row, or close the row as **kept**.

## Finish

Run the changed test files in full, then `make check`.

## Report

Write it in Russian.

```text
| # | Где | Метка | Комментарий | Итог | Что сделано / ответ |
|---|-----|-------|-------------|------|---------------------|
| 1 | path/file.py:42 | FIX | <comment text verbatim> | исправлено / объяснение / возражение / тикет / оставлено | <one line, or the full answer> |

make check: <result>
```

_Last modified: 2026-10-15_
