---
name: ag-create-task
description: Create tasks in the Aura Group (AG) Linear team for tg-sales-bot. Use when the user asks to create, add, file, or register a task, issue, bug, or work item, or to cut an epic into tasks.
---

# Create Linear tasks

Linear team `Aura Group` (`AG`) is the single source of truth for tasks: goal, acceptance criteria, status. Plans and commit-sized tickets come later, locally, via `/ag-create-plan` and `/ag-to-tickets`.

## Defaults

- Team: `Aura Group` (`AG`), even when a global skill has another default.
- Assignee: the current user (`me`) unless the user names another person.
- An epic is a Linear project; its tasks are issues in that project.
- No feature flags in this project — task descriptions carry none.
- Normal/default issue type.
- Title and description in Russian — the same for projects (epics). Code identifiers, model names and statuses stay as in the code (`Cart`, `shipment_failed`); bot button labels and screen texts stay verbatim.
- Domain terms from `CONTEXT.md` (Покупатель, Заказ, Корзина, Канал).

## Collect missing fields

Infer what the user already supplied. Ask only for what's missing, in one message, before creating anything:

- status: «Какой статус задачи?» — free-form answer, no choices offered;
- priority: «Какой приоритет?» — preserve the user's value, never invent one;
- project (epic), when the task clearly belongs to one and the user hasn't named it.

## Task shape

```markdown
## Goal
What the Buyer or the seller can do after this task, 1–2 sentences.

## Scope
- bullets; what's out of scope, if it's easy to confuse with a neighbouring task

## Acceptance criteria
- [ ] <screen → action → expected result>   ← manual checks in the bot
- [ ] <non-UI criterion>

## References
- docs/bot-design.md, section <N>
- ADR-000X
```

A task is sized to one coherent behaviour a Buyer or the seller notices — several commits, one manual check pass. Bigger → propose splitting it into several tasks before creating anything.

## Create

1. Resolve team, project, status, assignee. Any value ambiguous or missing → ask; never silently switch.
2. Search the team for an existing matching task (`list_issues` with `fields: ["id", "title"]`) to avoid duplicates on retries.
3. Create the issue.
4. List the issues of the project «Вопросы к бизнесу» that are not `Done`: these are themes of business questions. For each open question the new task cannot be finished without, record it on the task as `/ag-business-questions` describes under «Development side».

## Business questions

A question to the partner or the business is a line in a theme of the project «Вопросы к бизнесу», not a development task: use `/ag-business-questions`.

## Report

Each task identifier with its clickable link, plus team, project, status, priority, assignee. For a new development task, also the business questions that block it.

_Last modified: 2026-10-11_
